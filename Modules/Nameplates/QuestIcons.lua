local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("QuestIcons", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local modName = mod:GetName()
local isAwesome = C_NamePlate
local markedUnits = {}
local quests = {}

local _G, pairs, ipairs, unpack, tonumber = _G, pairs, ipairs, unpack, tonumber
local find, match, format, lower = string.find, string.match, string.format, string.lower
local tinsert, twipe = table.insert, table.wipe
local UnitName, UnitIsPlayer = UnitName, UnitIsPlayer
local GetQuestLink, GetQuestLogLeaderBoard, GetQuestLogTitle = GetQuestLink, GetQuestLogLeaderBoard, GetQuestLogTitle
local GetNumQuestLogEntries, GetNumQuestLeaderBoards = GetNumQuestLogEntries, GetNumQuestLeaderBoards
local THREAT_TOOLTIP = gsub(THREAT_TOOLTIP, '%%d', '%%d-')


local typesLocalized = {
	enUS = {
		--- short matching applies here so,
		-- kill: killed, destory: destoryed, etc ...
		KILL = {'slain', 'destroy', 'eliminate', 'repel', 'kill', 'defeat'},
		CHAT = {'speak', 'talk'}
	},
	deDE = {
		KILL = {'besiegen', 'besiegt', 'getötet', 'töten', 'tötet', 'vernichtet', 'zerstört', 'genährt'},
		CHAT = {'befragt', 'sprecht'}
	},
	ruRU = {
		KILL = {'убит', 'уничтож', 'разбомблен', 'разбит', 'сразит'},
		CHAT = {'поговорит', 'спрашивать'}
	},
	esMX = {
		-- asesinad: asesinado, asesinados, asesinada, asesinadas
		-- derrota: derrotar, derrotado, derrotados, derrotada, derrotadas
		-- destrui: destruir, destruido, destruidos, destruida, destruidas
		-- elimin: eliminar, elimine, eliminadas, eliminada, eliminados, eliminado
		-- repel: repele, repelido, repelidos, repelida, repelidas
		KILL = {'asesinad', 'destrui', 'elimin', 'repel', 'derrota'},
		CHAT = {'habla', 'pídele'}
	},
	ptBR = {
		-- destrui: above but also destruição
		-- repel: repelir, repelido, repelidos, repelida, repelidas
		KILL = {'morto', 'morta', 'matar', 'destrui', 'elimin', 'repel', 'derrota'},
		CHAT = {'falar', 'pedir'}
	},
	frFR = {
		-- tué: tués, tuée, tuées
		-- abattu: abattus, abattue
		-- détrui: détruite, détruire, détruit, détruits, détruites
		-- repouss: repousser, repoussés, repoussée, repoussées
		-- élimin: éliminer, éliminé, éliminés, éliminée, éliminées
		KILL = {'tué', 'tuer', 'attaqué', 'attaque', 'abattre', 'abattu', 'détrui', 'élimin', 'repouss', 'vaincu', 'vaincre'},
		-- demande: demander, demandez
		-- parle: parler, parlez
		CHAT = {'parle', 'demande'}
	},
	koKR = {
		KILL = {'쓰러뜨리기', '물리치기', '공격', '파괴'},
		CHAT = {'대화'}
	},
	zhCN = {
		KILL = {'消灭', '摧毁', '击败', '毁灭', '击退'},
		CHAT = {'交谈', '谈一谈'}
	},
	zhTW = {
		KILL = {'毀滅', '擊退', '殺死'},
		CHAT = {'交談', '說話'}
	},
}


local itemPickupQuests = {}
local questTypes = typesLocalized[GetLocale()] or typesLocalized.enUS

local iconTypes = {}
local iconTypesDefaults = {
    DEFAULT = 'Interface\\Icons\\INV_Misc_QuestionMark',
    KILL = 'Interface\\Icons\\ABILITY_DualWield',
    CHAT = 'Interface\\Icons\\INV_Misc_Note_01',
	ITEM = 'Interface\\Icons\\INV_Misc_Bag_08'
}


P["Extras"]["nameplates"][modName] = {
	["enabled"] = false,
	["useBackdrop"] = true,
	["iconSize"] = 16,
	["xOffset"] = -4,
	["yOffset"] = 0,
	["point"] = 'RIGHT',
	["relativeTo"] = 'LEFT',
	["iconDEFAULT"] = 'Interface\\GossipFrame\\AvailableQuestIcon',
	["iconKILL"] = 'Interface\\Icons\\ABILITY_DualWield',
	["iconCHAT"] = 'Interface\\Icons\\INV_Misc_Note_01',
	["iconITEM"] = 'Interface\\Icons\\INV_Misc_Bag_08',
	["strata"] = 'BACKGROUND',
	["textFont"] = 'Expressway',
	["textFontSize"] = 11,
	["textFontOutline"] = 'OUTLINE',
	["textPoint"] = 'TOP',
	["textRelativeTo"] = 'CENTER',
	["textX"] = 0,
	["textY"] = -2,
	["modifiers"] = {
		["mark"] = 'NONE',
		["unmark"] = 'Shift',
		["unmarkall"] = 'Alt',
	},
}

function mod:LoadConfig()
	local db = E.db.Extras.nameplates[modName]
	local function populateModifierValues(othervala, othervalb)
		local modsList = {}
		for mod, val in pairs(E.db.Extras.modifiers) do
			if mod ~= 'ANY' and db.modifiers[othervala] ~= mod and db.modifiers[othervalb] ~= mod then
				modsList[mod] = val
			end
		end
		if db.modifiers[othervala] ~= 'NONE' and db.modifiers[othervalb] ~= 'NONE' then
			modsList['NONE'] = L["None"]
		end
		return modsList
	end

	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value self:UpdateIconSettings(db) end,
		args = {
			QuestIcons = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L["QuestIcons"],
				disabled = function() return not db.enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"],
						set = function(info, value) db[info[#info]] = value self:Toggle(db) end,
						disabled = false,
					},
					automatic = {
						order = 2,
						type = "toggle",
						name = L["Automatic Onset"],
						desc = L["Scans tooltip texts and sets icons automatically."],
						set = function(info, value) db[info[#info]] = value self:Toggle(db) end,
					},
				},
			},
			settings = {
				type = "group",
				guiInline = true,
				name = L["Settings"],
				disabled = function() return not db.enabled end,
				args = {
					useBackdrop = {
						order = 1,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
					},
					iconSize = {
						order = 2,
						type = "range",
						min = 4, max = 60, step = 1,
						name = L["Icon Size"],
						desc = "",
					},
					iconDEFAULT = {
						order = 3,
						type = "select",
						name = L["Icon (Default)"],
						desc = "",
						values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
					},
					iconKILL = {
						order = 4,
						type = "select",
						name = L["Icon (Kill)"],
						desc = "",
						values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
					},
					iconCHAT = {
						order = 5,
						type = "select",
						name = L["Icon (Chat)"],
						desc = "",
						values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
					},
					iconITEM = {
						order = 6,
						type = "select",
						name = L["Icon (Item)"],
						desc = "",
						values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
					},
					xOffset = {
						order = 7,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 8,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
					point = {
						order = 9,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 10,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					strata = {
						order = 11,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
					},
					mark = {
						order = 12,
						type = "select",
						name = L["Mark"],
						desc = L["Mark the target/mouseover plate."],
						get = function(info) return db.modifiers[info[#info]] end,
						set = function(info, value) db.modifiers[info[#info]] = value end,
						values = function() return populateModifierValues('unmark', 'unmarkall') end,
					},
					unmark = {
						order = 13,
						type = "select",
						name = L["Unmark"],
						desc = L["Unmark the target/mouseover plate."],
						get = function(info) return db.modifiers[info[#info]] end,
						set = function(info, value) db.modifiers[info[#info]] = value end,
						values = function() return populateModifierValues('mark', 'unmarkall') end,
					},
					unmarkall = {
						order = 14,
						type = "select",
						name = L["Unmark All"],
						desc = L["Unmark all plates."],
						get = function(info) return db.modifiers[info[#info]] end,
						set = function(info, value) db.modifiers[info[#info]] = value end,
						values = function() return populateModifierValues('mark', 'unmark') end,
					},
				},
			},
			text = {
				type = "group",
				guiInline = true,
				name = L["Settings"],
				get = function(info) return db[info[#info]] end,
				set = function(info, value) db[info[#info]] = value self:UpdateIconSettings(db) end,
				disabled = function() return not db.enabled end,
				args = {
					showText = {
						order = 1,
						type = "toggle",
						name = L["Show Text"],
						desc = L["Display progress status."],
					},
					textFontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1,
						hidden = function() return not db.showText end,
					},
					textFont = {
						order = 3,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end,
						hidden = function() return not db.showText end,
					},
					textFontOutline = {
						order = 4,
						type = "select",
						name = L["Font Outline"],
						desc = "",
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						hidden = function() return not db.showText end,
					},
					textPoint = {
						order = 5,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not db.showText end,
					},
					textRelativeTo = {
						order = 6,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not db.showText end,
					},
					textX = {
						order = 7,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -60, max = 60, step = 1,
						hidden = function() return not db.showText end,
					},
					textY = {
						order = 8,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -60, max = 60, step = 1,
						hidden = function() return not db.showText end,
					},
				},
			},
		},
	}
end


local function scanTooltipText(text)
	local count, total = match(text, '(%d+)/(%d+)')

	if count and total then
		return tonumber(count), tonumber(total)
	elseif not match(text, THREAT_TOOLTIP) then
		local progress = tonumber(match(text, '([%d%.]+)%%'))

		if progress and progress <= 100 then
			return progress, 100, true
		end
	end
end

local function getQuests(unit, unitName, unitType)
    if not unit or UnitIsPlayer(unit) then return end

    E.ScanTooltip:SetOwner(_G.UIParent, 'ANCHOR_NONE')
    E.ScanTooltip:SetUnit(unit)
    E.ScanTooltip:Show()

    quests[unitName..unitType] = {}

	local questType = 'DEFAULT'

    for i = 3, E.ScanTooltip:NumLines() do
        local str = _G['ElvUI_ScanTooltipTextLeft' .. i]
        local text = str and str:GetText()

        if not text or text == '' then break end

        local count, total, isPercent = scanTooltipText(text)

		if itemPickupQuests[text] then
			questType = 'ITEM'
		end

        if count and total then
			if questType == 'DEFAULT' then
                for typeKey, typeTexts in pairs(questTypes) do
                    for _, typeText in ipairs(typeTexts) do
                        if find(lower(text), typeText, nil, true) then
                            questType = typeKey
                            break
                        end
                    end
                    if questType ~= 'DEFAULT' then break end
                end
			end

            tinsert(quests[unitName..unitType], {
                count = count,
                total = total,
                isPercent = isPercent,
                questType = questType
            })
        end
    end

    E.ScanTooltip:Hide()

    return quests[unitName..unitType]
end

local function createIcon(frame, db)
	if not frame or frame.questIcon then return end

	local questIcon = CreateFrame("Frame", "$parentQuestIcon", frame)
	local texture = questIcon:CreateTexture(nil, "ARTWORK")

	texture:SetTexCoord(unpack(E.TexCoords))

	local offset = E.PixelMode and E.mult or E.Border
	texture:SetInside(questIcon, offset, offset)

	questIcon.texture = texture

	questIcon:SetParent(frame)
	questIcon:Hide()

    local countText = questIcon:CreateFontString(nil, "OVERLAY")
	countText:FontTemplate()

    questIcon.countText = countText

	mod:UpdateQuestIcon(frame, questIcon, db or E.db.Extras.nameplates[modName])

	return questIcon
end

local function updateCount(questIcon, count, total, isPercent)
    if count and total then
        local progress = count / total
        local displayText
        if isPercent then
            displayText = format("%.1f%%", count)
        else
            displayText = format("%d/%d", count, total)
        end
        questIcon.countText:SetText(displayText)
        questIcon.countText:SetTextColor(1 - progress, progress, 0)
        questIcon.countText:Show()
    else
        questIcon.countText:Hide()
    end
end


function mod:UpdateQuestStatus(frame, unit, unitName, unitType)
    local questIcon = frame.questIcon
    local unitQuests = getQuests(unit, unitName, unitType)

    if unitQuests and #unitQuests > 0 then
        markedUnits[unitType..unitName] = true
        local count, total, isPercent, questType
        local allComplete = true

        for _, quest in ipairs(unitQuests) do
            if quest.count ~= quest.total or quest.isPercent then
                count, total, isPercent = quest.count, quest.total, quest.isPercent
                questType = quest.questType
                allComplete = false
                break
            end
        end

        if allComplete then
            markedUnits[unitType..unitName] = nil
            questIcon:Hide()
        else
            if questIcon.showText then
                updateCount(questIcon, count, total, isPercent)
            end
			questIcon.texture:SetTexture(iconTypes[questType] or iconTypes.DEFAULT)
            questIcon:Show()
        end
    else
        markedUnits[unitType..unitName] = nil
        questIcon:Hide()
    end
end

function mod:UpdateQuestIcon(frame, questIcon, db)
	if db.useBackdrop then
		if not questIcon.backdrop then
			questIcon:CreateBackdrop('Transparent')
		end
		questIcon.backdrop:Show()
	elseif questIcon.backdrop then
		questIcon.backdrop:Hide()
	end

	local _, unitType = NP:GetUnitInfo(frame)
	questIcon:ClearAllPoints()
	questIcon:SetFrameStrata(db.strata)
	questIcon:Size(db.iconSize)
	questIcon:Point(db.point, NP.db.units[unitType].health.enable and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
	questIcon.texture:SetTexture(db.iconDEFAULT)

	if db.showText then
		questIcon.countText:SetFont(LSM:Fetch("font", db.textFont), db.textFontSize, db.textFontOutline)
		questIcon.countText:ClearAllPoints()
		questIcon.countText:Point(db.textPoint, questIcon, db.textRelativeTo, db.textX, db.textY)
		questIcon.showText = true
	else
		questIcon.countText:Hide()
		questIcon.showText = nil
	end
end

function mod:UpdateAllPlates(db)
    for plate in pairs(NP.CreatedPlates) do
        local frame = plate.UnitFrame

        if frame then
            frame.questIcon = frame.questIcon or createIcon(frame, db)
            local questIcon = frame.questIcon
            local unitType, unitName = frame.UnitType, frame.UnitName

            if unitType and unitName then
                if isAwesome and db.automatic then
                    local unit = plate.unit
                    if unit then
                        self:UpdateQuestStatus(frame, unit, unitName, unitType)
                    end
                elseif markedUnits[unitType..unitName] then
                    local unitQuests = quests[unitName..unitType]
                    if unitQuests and #unitQuests > 0 then
                        local count, total, isPercent
                        for _, quest in ipairs(unitQuests) do
                            if quest.count ~= quest.total or quest.isPercent then
                                count, total, isPercent = quest.count, quest.total, quest.isPercent
                                break
                            end
                        end

                        if count then
                            updateCount(questIcon, count, total, isPercent)
                            questIcon:Show()
                        else
                            questIcon:Hide()
                        end
                    else
                        questIcon:Show()
                    end
                else
                    questIcon:Hide()
                end
            end
        end
    end
end

function mod:UpdateIconSettings(db)
	for type, iconTex in pairs(iconTypesDefaults) do
		iconTypes[type] = db['icon'..type] or iconTex
	end

	 for plate in pairs(NP.CreatedPlates) do
		local frame = plate.UnitFrame

		if frame then
			frame.questIcon = frame.questIcon or createIcon(frame, db)

			self:UpdateQuestIcon(frame, frame.questIcon, db)
			self:UpdateAllPlates(db)
		end
	end
end

function mod:MarkUnmark(show, unitType, unitName)
	if show then
		markedUnits[unitType..unitName] = true
	else
		markedUnits[unitType..unitName] = nil
	end
end

function mod:SlashCommandHandler(msg)
	local modifier = msg
	local db = E.db.Extras.nameplates[modName]
	if not find(modifier, '%S+') then

		for _, toggle in ipairs({"mark", "unmark", "unmarkall"}) do
			if db.modifiers[toggle] == 'NONE' or _G['Is'..db.modifiers[toggle]..'KeyDown']() then
				modifier = toggle
			end
		end
	end

	if not modifier then return end

	if modifier == "unmarkall" then
		twipe(markedUnits)
		self:UpdateAllPlates(db)
		return
	else
		for _, unit in ipairs({'mouseover', 'target'}) do
			local name = UnitName(unit)
			if name and not UnitIsPlayer(unit) then
				local unitType = NP:GetUnitTypeFromUnit(unit)
				if modifier == "mark" or modifier == "unmark" then
					self:MarkUnmark(modifier == "mark" and true or false, unitType, name)
					self:UpdateAllPlates(db)
				end
				return
			end
		end
	end
end

function mod:OnShow(self)
    local frame = self.UnitFrame
    local unitType, unitName = frame.UnitType, frame.UnitName
    frame.questIcon = frame.questIcon or createIcon(frame)

    if markedUnits[unitType..unitName] then
        local questIcon = frame.questIcon
        local unitQuests = quests[unitName..unitType]

        if unitQuests and #unitQuests > 0 then
            local count, total, isPercent, questType
            for _, quest in ipairs(unitQuests) do
                if quest.count ~= quest.total or quest.isPercent then
                    count, total, isPercent = quest.count, quest.total, quest.isPercent
					questType = quest.questType
                    break
                end
            end

            if count then
                updateCount(questIcon, count, total, isPercent)

				questIcon.texture:SetTexture(iconTypes[questType] or iconTypes.DEFAULT)
                questIcon:Show()
            else
                questIcon:Hide()
            end
        else
            questIcon:Show()
        end
    else
        frame.questIcon:Hide()
    end
end

function mod:OnShowAwesome(plate)
	local unit = plate.unit
    if not unit then return end

    local frame = plate.UnitFrame
	frame.questIcon = frame.questIcon or createIcon(frame)

	mod:UpdateQuestStatus(frame, unit, frame.UnitName, frame.UnitType)
end

function mod:OnCreated(self, plate)
	local frame = plate.UnitFrame
    frame.questIcon = frame.questIcon or createIcon(frame)
end


function mod:QUEST_ACCEPTED(_, questIndex)
	E:Delay(0.1, function()
		local questLink = GetQuestLink(questIndex)

		if questLink then
			local _, item = GetQuestLogLeaderBoard(questIndex)
			if item then
				itemPickupQuests[GetQuestLogTitle(questIndex)] = true
			end
		end
		if isAwesome then
			self:UpdateAllPlates(E.db.Extras.nameplates[modName])
		end
	end)
end

function mod:QUEST_REMOVED()
	E:Delay(0.1, function()
		twipe(itemPickupQuests)

		for i = 1, GetNumQuestLogEntries() do
			for j = 1, GetNumQuestLeaderBoards(i) do
				local _, objectiveType, completed = GetQuestLogLeaderBoard(j, i)
				if objectiveType == "item" and not completed then
					itemPickupQuests[GetQuestLogTitle(i)] = true
					break
				end
			end
		end
		if isAwesome then
			self:UpdateAllPlates(E.db.Extras.nameplates[modName])
		end
	end)
end


function mod:Toggle(db)
	if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
	self:UnregisterAllEvents()
	twipe(markedUnits)

    if db.enabled then
		core.plateAnchoring['questIcon'] = function() return db end

		SLASH_QMARK1 = "/qmark"
		SlashCmdList["QMARK"] = function(msg) self:SlashCommandHandler(msg) end
		if not self:IsHooked(NP, "OnCreated") then self:SecureHook(NP, "OnCreated") end
		if not self:IsHooked(NP, "OnShow") then
			if isAwesome and db.automatic then
				self:SecureHook(NP, "OnShow", function(plate) self:OnShowAwesome(plate) end)
			else
				self:SecureHook(NP, "OnShow")
			end
		end
		local function parseTip(unit)
			local name = UnitName(unit)
			local unitType = NP:GetUnitTypeFromUnit(unit)

			if name and unitType then
				for plate in pairs(NP.CreatedPlates) do
					local frame = plate.UnitFrame

					if frame and frame.UnitName == name and frame.UnitType == unitType then
						frame.questIcon = frame.questIcon or createIcon(frame)
						self:UpdateQuestStatus(frame, unit, name, unitType)
					end
				end
			end
		end

		self:RegisterEvent("QUEST_ACCEPTED")
		self:RegisterEvent("QUEST_REMOVED")
		self:RegisterEvent("QUEST_LOG_UPDATE", function()
			self:QUEST_REMOVED()
			self:UnregisterEvent("QUEST_LOG_UPDATE")

			if isAwesome then
				self:RegisterEvent("QUEST_LOG_UPDATE", function()
					for frame in pairs(NP.VisiblePlates) do
						local unit = frame:GetParent().unit
						if unit then
							self:UpdateQuestStatus(frame, unit, frame.UnitName or UnitName(unit), frame.UnitType or NP:GetUnitTypeFromUnit(unit))
						end
					end
				end)
			end
		end)

		if db.automatic and not isAwesome then
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function() parseTip('mouseover') end)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", function() parseTip('target') end)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", function() parseTip('focus') end)
		end

		for plate in pairs(NP.CreatedPlates) do
			if plate:GetName() ~= "ElvNP_Test" then
				local frame = plate.UnitFrame
				frame.questIcon = frame.questIcon or createIcon(frame)
			end
		end
		self:UpdateIconSettings(db)
	else
		core.plateAnchoring['questIcon'] = nil
		SLASH_QMARK1 = nil
		SlashCmdList["QMARK"] = nil
		hash_SlashCmdList["/QMARK"] = nil
		if self:IsHooked(NP, "OnCreated") then self:Unhook(NP, "OnCreated") end

		for plate in pairs(NP.CreatedPlates) do
			local frame = plate.UnitFrame
			if frame and frame.questIcon then
				frame.questIcon:Hide()
				frame.questIcon = nil
			end
		end
    end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	mod:LoadConfig()
	mod:Toggle(E.db.Extras.nameplates[modName])
end

core.modules[modName] = mod.InitializeCallback