local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("QuestIcons", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local modName = mod:GetName()
local isAwesome = C_NamePlate

mod.initialized = false

local _G, pairs, ipairs, unpack, tonumber = _G, pairs, ipairs, unpack, tonumber
local find, match, lower, sub = string.find, string.match, string.lower, string.sub
local twipe = table.wipe
local UnitName, UnitGUID = UnitName, UnitGUID
local GetQuestLogLeaderBoard, GetQuestLogTitle = GetQuestLogLeaderBoard, GetQuestLogTitle
local GetNumQuestLogEntries, GetNumQuestLeaderBoards = GetNumQuestLogEntries, GetNumQuestLeaderBoards
local THREAT_TOOLTIP = gsub(THREAT_TOOLTIP, '%%d', '%%d-')

local r1, g1, b1
local r2, g2, b2

local markedUnits = {}

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
    ["DEFAULT"] = 'Interface\\Icons\\INV_Misc_QuestionMark',
    ["KILL"] = 'Interface\\Icons\\ABILITY_DualWield',
    ["CHAT"] = 'Interface\\Icons\\INV_Misc_Note_01',
	["ITEM"] = 'Interface\\Icons\\INV_Misc_Bag_08'
}
local scanTool = CreateFrame("GameTooltip", "ElvUI_ExtrasScanTooltipQI", nil, "GameTooltipTemplate")
scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")


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
	["level"] = 0,
	["textFont"] = 'Expressway',
	["textFontSize"] = 11,
	["textFontOutline"] = 'OUTLINE',
	["textPoint"] = 'TOP',
	["textRelativeTo"] = 'CENTER',
	["textX"] = 0,
	["textY"] = -2,
}

function mod:LoadConfig(db)
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value self:UpdateIconSettings(db) self:UpdateAllPlates(db) end,
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
						desc = "",
						set = function(info, value)
							db[info[#info]] = value
							if value and not isAwesome then
								E:StaticPopup_Show("PRIVATE_RL")
							else
								self:Toggle(db)
							end
						end,
						disabled = false,
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
					level = {
						order = 11,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -5, max = 50, step = 1,
					},
				},
			},
			text = {
				type = "group",
				guiInline = true,
				name = L["Settings"],
				get = function(info) return db[info[#info]] end,
				set = function(info, value) db[info[#info]] = value self:UpdateIconSettings(db) self:UpdateAllPlates(db) end,
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


local function scanTooltipText(line)
	local text, count, total = match(line, '((%d+)/(%d+))')

	if count and total then
		return text, tonumber(count) / tonumber(total)
	elseif not match(line, THREAT_TOOLTIP) then
		local progress = tonumber(match(line, '([%d]+)%.*%d*%%'))

		if progress and progress <= 100 then
			return progress .. '%', progress / 100
		end
	end
end

local function getQuests(unit)
    scanTool:ClearLines()
    scanTool:SetUnit(unit)

    for i = 3, scanTool:NumLines() do
        local str = _G['ElvUI_ExtrasScanTooltipQITextLeft' .. i]
        local line = str and str:GetText()

        if not line or line == '' then break end

        local text, progress = scanTooltipText(line)

        if text and progress < 1 then
			local questType
			if itemPickupQuests[text] then
				questType = 'ITEM'
			else
                for typeKey, typeTexts in pairs(questTypes) do
                    for _, typeText in ipairs(typeTexts) do
                        if find(lower(line), typeText, nil, true) then
                            questType = typeKey
                            break
                        end
                    end
                    if questType then break end
                end
			end

			return {
				text = text,
				progress = progress,
                questType = questType or 'DEFAULT'
            }
        end
    end
    return nil
end

local function parseTip(unit, db)
	local unitType = NP:GetUnitTypeFromUnit(unit)

	if unitType ~= "FRIENDLY_NPC" and unitType ~= "ENEMY_NPC" then
		return
	end

	local name = UnitName(unit)
	if name and unitType then
		for frame in pairs(NP.VisiblePlates) do
			if frame.UnitName == name and frame.UnitType == unitType then
				mod:UpdateQuestStatus(db, frame, unit, name, unitType)
			end
		end
	end
end

local function createIcon(frame, db)
	local questIcon = CreateFrame("Frame", "$parentQuestIcon", frame)
	questIcon:SetParent(frame)

	local texture = questIcon:CreateTexture(nil, "ARTWORK")
	local offset = E.PixelMode and E.mult or E.Border
	texture:SetTexCoord(unpack(E.TexCoords))
	texture:SetInside(questIcon, offset, offset)

    local countText = questIcon:CreateFontString(nil, "OVERLAY")
	countText:FontTemplate()

	questIcon.texture = texture
    questIcon.countText = countText

	mod:UpdateQuestIcon(frame, questIcon, db)

	return questIcon
end


function mod:UpdateQuestStatus(db, frame, unit, unitName, unitType)
    local questIcon = frame.questIcon
	local unitQuest

	if unit then
		unitQuest = getQuests(unit)
		if unitQuest then
			local data = unitQuest
			markedUnits[unitType..unitName] = unitQuest

			local text, progress, questType = data.text, data.progress, data.questType
			if questIcon.showText and text then
				questIcon.countText:SetText(text)
				questIcon.countText:SetTextColor(r1 + (r2 - r1) * progress, g1 + (g2 - g1) * progress, b1 + (b2 - b1) * progress)
				questIcon.countText:Show()
			end
			questIcon:ClearAllPoints()
			questIcon:Point(db.point, NP.db.units[unitType].health.enable and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
			questIcon.texture:SetTexture(iconTypes[questType])
			questIcon:Show()
			return
		end
	else
		unitQuest = markedUnits[unitType..unitName]
		if unitQuest then
			local data = unitQuest
			local text, progress, questType = data.text, data.progress, data.questType
			if questIcon.showText and text then
				questIcon.countText:SetText(text)
				questIcon.countText:SetTextColor(r1 + (r2 - r1) * progress, g1 + (g2 - g1) * progress, b1 + (b2 - b1) * progress)
				questIcon.countText:Show()
			end
			questIcon:ClearAllPoints()
			questIcon:Point(db.point, NP.db.units[unitType].health.enable and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
			questIcon.texture:SetTexture(iconTypes[questType])
			questIcon:Show()
			return
		end
	end
	markedUnits[unitType..unitName] = nil
	questIcon:Hide()
end

function mod:UpdateQuestIcon(frame, questIcon, db)
	local level = frame.Health:GetFrameLevel() + db.level
	questIcon:SetFrameLevel(level)
	questIcon:Size(db.iconSize)

	if db.useBackdrop then
		if not questIcon.backdrop then
			questIcon:CreateBackdrop('Transparent')
		end
		questIcon.backdrop:SetFrameLevel(level)
		questIcon.backdrop:Show()
	elseif questIcon.backdrop then
		questIcon.backdrop:Hide()
	end

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
	for frame in pairs(NP.VisiblePlates) do
		self:OnShow(frame, db)
	end
end

function mod:QueueUpdate(db)
	if not self.updatePending then
		self.updatePending = E:ScheduleTimer(function()
			self:UpdateAllPlates(db)
			self.updatePending = false
		end, 0.1)
	else
		E:CancelTimer(self.updatePending)
		self.updatePending = E:ScheduleTimer(function()
			self:UpdateAllPlates(db)
			self.updatePending = false
		end, 0.1)
	end
end

function mod:UpdateIconSettings(db)
	for iconType, iconTex in pairs(iconTypesDefaults) do
		iconTypes[iconType] = db['icon'..iconType] or iconTex
	end

	for plate in pairs(NP.CreatedPlates) do
		local frame = plate.UnitFrame

		if frame then
			if not frame.questIcon then
				frame.questIcon = createIcon(frame, db)
			end
			self:UpdateQuestIcon(frame, frame.questIcon, db)
			self:OnShow(frame, db)
		end
	end
end

function mod:OnShow(frame, db)
    local unitType = frame.UnitType

	if unitType ~= "FRIENDLY_NPC" and unitType ~= "ENEMY_NPC" then
		frame.questIcon:Hide()
		return
	end
	mod:UpdateQuestStatus(db, frame, frame.unit or frame:GetParent().unit, frame.UnitName, unitType)
end


function mod:QUEST_ACCEPTED(questIndex, db)
	E:Delay(0.1, function()
		for j = 1, GetNumQuestLeaderBoards(questIndex) do
			local _, objectiveType = GetQuestLogLeaderBoard(j, questIndex)
			if objectiveType == "item" then
				itemPickupQuests[GetQuestLogTitle(questIndex)] = true
				break
			end
		end
		if isAwesome then
			self:UpdateAllPlates(db)
		end
	end)
end

function mod:QUEST_REMOVED(db)
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
			self:UpdateAllPlates(db)
		end
	end)
end


function mod:Toggle(db)
	if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
	self:UnregisterAllEvents()

    if not core.reload and db.enabled then
		local reactions = NP.db.colors.reactions
		local bad = reactions.bad
		local good = reactions.good
		r1, g1, b1 = bad.r, bad.g, bad.b
		r2, g2, b2 = good.r, good.g, good.b

		if not self.ishooked then
			if E.Options and E.Options.args.nameplate then
				if not self:IsHooked(E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.reactions, "set") then
					self:SecureHook(E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.reactions, "set", function()
						r1, g1, b1 = bad.r, bad.g, bad.b
						r2, g2, b2 = good.r, good.g, good.b
						self:QueueUpdate(db)
					end)
				end
			elseif not self:IsHooked(E, "ToggleOptionsUI") then
				self:SecureHook(E, "ToggleOptionsUI", function()
					if E.Options.args.nameplate then
						self:SecureHook(E.Options.args.nameplate.args.generalGroup.args.colorsGroup.args.reactions, "set", function()
							r1, g1, b1 = bad.r, bad.g, bad.b
							r2, g2, b2 = good.r, good.g, good.b
							self:QueueUpdate(db)
						end)
						self:Unhook(E, "ToggleOptionsUI")
					end
				end)
			end
			self.ishooked = true
		end

		local Questie = _G.Questie
		if Questie then
			local qIcons = Questie.icons
			local GetValidIcon = _G.QuestieLoader:ImportModule("QuestieNameplate").private.GetValidIcon
			local QuestieTooltips = _G.QuestieLoader:ImportModule("QuestieTooltips")
			local QuestieTracker = _G.QuestieLoader:ImportModule("QuestieTracker")
			local _QuestEventHandler = _G.QuestieLoader:ImportModule("QuestEventHandler").private
			local GetTooltip = QuestieTooltips.GetTooltip

			if not self:IsHooked(QuestieTooltips, "RemoveQuest") then
				self:SecureHook(QuestieTooltips, "RemoveQuest", function()
					self:QueueUpdate(db)
				end)
			end
			if not self:IsHooked(_QuestEventHandler, "QuestLogUpdate") then
				self:SecureHook(_QuestEventHandler, "QuestLogUpdate", function()
					self:QueueUpdate(db)
				end)
			end
			if not self:IsHooked(QuestieTracker, "Initialize") then
				self:SecureHook(QuestieTracker, "Initialize", function()
					self:QueueUpdate(db)
				end)
			end

			getQuests = function(unit)
				local key = "m_" .. (tonumber(sub(UnitGUID(unit), -10, -7), 16) or "")
				local icon = GetValidIcon(QuestieTooltips.lookupByKey[key])

				if icon then
					local tooltipData = GetTooltip(_, key)
					if tooltipData then
						for _, qline in ipairs(tooltipData) do
							local text, progress = scanTooltipText(qline)
							if (text and progress < 1) or find(qline, "^%s+") then
								return {
									text = text,
									progress = progress,
									questType = icon == qIcons["loot"] and "ITEM"
												or icon == qIcons["slay"] and "KILL"
												or icon == qIcons["talk"] and "CHAT"
												or "DEFAULT"
								}
							end
						end
					end
				end
				return nil
			end
		else
			SetCVar("showQuestTrackingTooltips", 1)
			self:RegisterEvent("QUEST_ACCEPTED", function(_, questIndex) self:QUEST_ACCEPTED(questIndex, db) end)
			self:RegisterEvent("QUEST_REMOVED", function() self:QUEST_REMOVED(db) end)
			self:RegisterEvent("QUEST_LOG_UPDATE", function()
				self:QueueUpdate(db)
			end)
			self:QueueUpdate(db)
		end

		core:RegisterNPElement('questIcon', function(_, frame, element)
			if frame.questIcon then
				frame.questIcon:ClearAllPoints()
				frame.questIcon:Point(db.point, element, db.relativeTo, db.xOffset, db.yOffset)
			end
		end)

		self.OnShow = self.origOnshow or self.OnShow
		if not self:IsHooked(NP, "OnShow") then
			self:SecureHook(NP, "OnShow", function(plate) self:OnShow(plate.UnitFrame, db) end)
		end

		if not self:IsHooked(NP, "Construct_Highlight") then
			self:SecureHook(NP, "Construct_Highlight", function(_, frame)
				frame.questIcon = createIcon(frame, db)
			end)
		end

		if not isAwesome then
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function() parseTip('mouseover', db) end)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", function() parseTip('target', db) end)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", function() parseTip('focus', db) end)
		end

		core:RegisterAreaUpdate(modName, function()
			scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")
		end)

		self:UpdateIconSettings(db)
		self.initialized = true
	elseif self.initialized then
		core:RegisterNPElement('questIcon')
		core:RegisterAreaUpdate(modName)
		if self:IsHooked(E, "ToggleOptionsUI") then self:Unhook(E, "ToggleOptionsUI") self.ishooked = nil end
		if self:IsHooked(E, "Construct_Highlight") then self:Unhook(E, "Construct_Highlight") end
		if isAwesome or not core.reload then
			if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		else
			self.origOnshow = self.origOnshow or self.OnShow
			self.OnShow = function() end
		end
		self:UnregisterAllEvents()

		for plate in pairs(NP.CreatedPlates) do
			local frame = plate.UnitFrame
			if frame and frame.questIcon then
				frame.questIcon:Hide()
				frame.questIcon = nil
			end
		end
		if _G.Questie and not core.reload then E:StaticPopup_Show("PRIVATE_RL") end
		self.initialized = false
    end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback