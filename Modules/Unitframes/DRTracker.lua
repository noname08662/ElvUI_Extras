-- modified version of this -> https://www.curseforge.com/wow/addons/drtracker-elvuitukuiwod
local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("DRTracker", "AceEvent-3.0")
local UF = E:GetModule("UnitFrames")
local ElvUF = E.oUF
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI

local modName = mod:GetName()

local framelist, activeGUIDs, lastUpdateTime = {}, {}, {}
local spells = LAI.drSpells
local pveDR = LAI.pveDR

-- Improved Counterspell, not sure why the spellid is off
spells[55021] = "silence"

local eventRegistered = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
	["SPELL_AURA_REMOVED"] = true,
	["SPELL_CAST_SUCCESS"] = true,
}

local _G, pairs, ipairs, unpack, tonumber, select, next, print = _G, pairs, ipairs, unpack, tonumber, select, next, print
local band = bit.band
local random = math.random
local twipe, tinsert, tsort = table.wipe, table.insert, table.sort
local match, format, gsub, lower = string.match, string.format, string.gsub, string.lower
local GetSpellLink= GetSpellLink
local CooldownFrame_SetTimer, UnitGUID = CooldownFrame_SetTimer, UnitGUID
local GetSpellInfo, GetTime, UnitExists = GetSpellInfo, GetTime, UnitExists
local COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_NEUTRAL, COMBATLOG_OBJECT_REACTION_HOSTILE = COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER, COMBATLOG_OBJECT_REACTION_NEUTRAL, COMBATLOG_OBJECT_REACTION_HOSTILE
local ERR_NOT_IN_COMBAT, InCombatLockdown = ERR_NOT_IN_COMBAT, InCombatLockdown


P["Extras"]["unitframes"][modName] = {
	["selectedUnit"] = 'target',
	["selectedCat"] = 'fear',
	["playersOnly"] = false,
	["DRtime"] = 18,
	["catList"] = {},
	["catColors"] = {
		["banish"] = { 0.2, 0.6, 0.2 },
		["charge"] = { 0.8, 0.2, 0.2 },
		["cheapshot"] = { 1, 0.6, 0 },
		["ctrlstun"] = { 1, 0.6, 0 },
		["cyclone"] = { 0.6, 0.6, 0.6 },
		["disarm"] = { 0.8, 0.8, 0.1 },
		["disorient"] = { 0, 0.6, 1 },
		["entrapment"] = { 0.8, 0.8, 0.1 },
		["fear"] = { 0.8, 0.1, 0.8 },
		["horror"] = { 0.8, 0.1, 0.8 },
		["mc"] = { 0.8, 0.1, 0.8 },
		["rndroot"] = { 0, 0.8, 0.2 },
		["rndstun"] = { 1, 0.6, 0 },
		["ctrlroot"] = { 0, 0.8, 0.2 },
		["scatters"] = { 0, 0.6, 1 },
		["silence"] = { 0.8, 0.8, 0.1 },
		["sleep"] = { 0, 0.6, 1 },
		["taunt"] = { 0.8, 0.2, 0.2 }
	},
	["units"] = {
		["target"] = {
			["enabled"] = false,
			["noCdNumbers"] = false,
			["typeBorders"] = false,
			["iconsLimit"] = 3,
			["point"] = 'TOPLEFT',
			["relativeTo"] = 'BOTTOMLEFT',
			["growthDir"] = 'RIGHT',
			["xOffset"] = -4,
			["yOffset"] = -36,
			["spacing"] = 4,
			["iconSize"] = 24,
			["strengthIndicator"] = {
				["colors"] = {
					["good"] = ElvUF.colors.reaction[5],
					["neutral"] = ElvUF.colors.reaction[4],
					["bad"] = ElvUF.colors.reaction[1],
				},
				["text"] = {
					["enabled"] = false,
					["font"] = "Expressway",
					["size"] = 12,
					["flag"] = "OUTLINE",
					["point"] = 'TOP',
					["relativeTo"] = 'BOTTOM',
					["x"] = 0,
					["y"] = -4,
				},
				["box"] = {
					["enabled"] = false,
					["size"] = 12,
					["point"] = 'TOPLEFT',
				},
			},
		},
	},
}

function mod:LoadConfig()
	local function selectedUnit() return E.db.Extras.unitframes[modName].selectedUnit end
	local function selectedCat() return E.db.Extras.unitframes[modName].selectedCat end
	core.unitframes.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			DRTracker = {
				order = 1,
				type = "group",
				name = L["DR Tracker"],
				guiInline = true,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Appends a diminishing returns tracker to frames."],
						get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] end,
						set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] = value self:Toggle() end,
						disabled = function() return not E.db.unitframe.units[selectedUnit()].enable end,
					},
					unitDropdown = {
						order = 1,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function() return E.db.Extras.unitframes[modName].selectedUnit end,
						set = function(_, value) E.db.Extras.unitframes[modName].selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(E.db.Extras.unitframes[modName].units) end,
					},
				},
			},
			settings = {
				order = 2,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.unitframe.units[selectedUnit()].enable end,
				args = {
					DRtime = {
						order = 2,
						type = "range",
						min = 16, max = 20, step = 1,
						name = L["DR Time"],
						desc = L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."],
						get = function() return E.db.Extras.unitframes[modName].DRtime end,
						set = function(_, value) E.db.Extras.unitframes[modName].DRtime = value self:Toggle() end,
					},
					test = {
						order = 3,
						type = "execute",
						name = L["Test"],
						desc = "",
						func = function() mod:TDR() end,
					},
					playersOnly = {
						order = 4,
						type = "toggle",
						name = L["Players Only"],
						desc = L["Ignore NPCs when setting up icons."],
						get = function() return E.db.Extras.unitframes[modName].playersOnly end,
						set = function(_, value) E.db.Extras.unitframes[modName].playersOnly = value self:Toggle() end,
						hidden = function() return selectedUnit() == 'arena' end,
					},
					noCdNumbers = {
						order = 5,
						type = "toggle",
						name = L["No Cooldown Numbers"],
						desc = L["Go to 'Cooldown Text' > 'Global' to configure."],
					},
					typeBorders = {
						order = 6,
						type = "toggle",
						name = L["Color Borders"],
						desc = "",
					},
					growthDir = {
						order = 7,
						type = "select",
						name = L["Growth Direction"],
						desc = "",
						values = {
							["RIGHT"] = L["Right"],
							["LEFT"] = L["Left"],
							["TOP"] = L["Up"],
							["BOTTOM"] = L["Down"],
						},
					},
					point = {
						order = 8,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 9,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 10,
						type = "range",
						min = -80, max = 80, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 11,
						type = "range",
						min = -80, max = 80, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
					spacing = {
						order = 12,
						type = "range",
						min = 0, max = 16, step = 1,
						name = L["Spacing"],
						desc = "",
					},
					iconSize = {
						order = 13,
						type = "range",
						min = 4, max = 128, step = 1,
						name = L["Icon Size"],
						desc = "",
					},
					--[[
					iconsLimit = {
						order = 14,
						type = "range",
						min = 1, max = 18, step = 1,
						name = L["Icons Limit"],
						desc = "",
					},
					]]--
				},
			},
			strText = {
				order = 3,
				type = "group",
				name = L["DR Strength Indicator: Text"],
				guiInline = true,
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.text[info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.text[info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.text.enabled or not E.db.unitframe.units[selectedUnit()].enable end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = "",
						disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.unitframe.units[selectedUnit()].enable end,
					},
					size = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1
					},
					font = {
						order = 3,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end
					},
					flag = {
						order = 4,
						type = "select",
						name = L["Font Outline"],
						desc = "",
						values = {
							["NONE"] = L["NONE"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
					},
					point = {
						order = 5,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 6,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					x = {
						order = 7,
						type = "range",
						min = -80, max = 80, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					y = {
						order = 8,
						type = "range",
						min = -80, max = 80, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
				},
			},
			strBox = {
				order = 4,
				type = "group",
				name = L["DR Strength Indicator: Box"],
				guiInline = true,
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.box[info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.box[info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.box.enabled or not E.db.unitframe.units[selectedUnit()].enable end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "double",
						name = core.pluginColor..L["Enable"],
						desc = "",
						disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.unitframe.units[selectedUnit()].enable end,
					},
					size = {
						order = 2,
						type = "range",
						min = 4, max = 40, step = 1,
						name = L["Size"],
						desc = "",
					},
					point = {
						order = 3,
						type = "select",
						name = L["Point"],
						desc = "",
						values = {
							['CENTER'] = 'CENTER',
							['TOPLEFT'] = 'TOPLEFT',
							['TOPRIGHT'] = 'TOPRIGHT',
							['BOTTOMLEFT'] = 'BOTTOMLEFT',
							['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
						},
					},
				},
			},
			colors = {
				order = 5,
				type = "group",
				name = L["Colors"],
				guiInline = true,
				get = function(info) return unpack(E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.colors[info[#info]]) end,
				set = function(info, r, g, b) E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.colors[info[#info]] = { r, g, b } self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not (E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.text.enabled or E.db.Extras.unitframes[modName].units[selectedUnit()].strengthIndicator.box.enabled) or not E.db.unitframe.units[selectedUnit()].enable end,
				args = {
					good = {
						order = 1,
						type = "color",
						name = L["Good"],
						desc = L["50% DR for hostiles, 100% DR for the player."],
					},
					neutral = {
						order = 2,
						type = "color",
						name = L["Neutral"],
						desc = L["75% DR for all."],
					},
					bad = {
						order = 3,
						type = "color",
						name = L["Bad"],
						desc = L["100% DR for hostiles, 50% DR for the player."],
					},
					catColors = {
						order = 4,
						type = "color",
						name = L["Category Border"],
						desc = "",
						get = function() return unpack(E.db.Extras.unitframes[modName].catColors[selectedCat()]) end,
						set = function(_, r, g, b) E.db.Extras.unitframes[modName].catColors[selectedCat()] = { r, g, b } self:Toggle() end,
						disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.unitframe.units[selectedUnit()].enable end,
					},
					catDropdown = {
						order = 5,
						type = "select",
						width = "double",
						name = L["Select Category"],
						desc = "",
						get = function() return E.db.Extras.unitframes[modName].selectedCat end,
						set = function(_, value) E.db.Extras.unitframes[modName].selectedCat = value end,
						values = core:GetUnitDropdownOptions(E.db.Extras.unitframes[modName].catColors),
					},
				},
			},
			categories = {
				order = 6,
				type = "group",
				name = L["Categories"],
				guiInline = true,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or not E.db.unitframe.units[selectedUnit()].enable end,
				args = {
					addCategory = {
						order = 1,
						type = "input",
						width = "double",
						name = L["Add Category"],
						desc = L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."],
						get = function() return "" end,
						set = function(_, value)
							local cat, spellID = match(value, '%s*(%S+)%D*(%d+)')
							if spellID and cat and GetSpellInfo(spellID) then
								if not E.db.Extras.unitframes[modName].catColors[cat] then print(core.customColorBad..L["Invalid category."]) return end
								if E.db.Extras.unitframes[modName].catList[cat] then
									for id, category in pairs(E.db.Extras.unitframes[modName].catList) do
										if tonumber(id) then
											if cat == category then
												E.db.Extras.unitframes[modName].catList[id] = nil
												for cat, spellId in pairs(E.db.Extras.unitframes[modName].catList) do
													if id == spellId then E.db.Extras.unitframes[modName].catList[cat] = nil end
												end
												break
											end
										end
									end
									print(format(core.customColorAlpha..L["Category \"%s\" already exists, updating icon."], core.customColorBeta..cat..core.customColorAlpha))
								else
									local _, _, icon = GetSpellInfo(spellID)
									local link = GetSpellLink(spellID)
									local string = '\124T' .. gsub(icon, '\124', '\124\124') .. ':16:16\124t' .. link
									print(format(core.customColorAlpha..L["Category \"%s\" added with %s icon."], core.customColorBeta..cat..core.customColorAlpha, string))
								end
								E.db.Extras.unitframes[modName].catList[spellID] = cat
								E.db.Extras.unitframes[modName].catList[cat] = spellID
							end
						end,
					},
					removeCategory = {
						order = 2,
						type = "select",
						width = "double",
						name = L["Remove Category"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							for id, cat in pairs(E.db.Extras.unitframes[modName].catList) do
								if id == value then
									E.db.Extras.unitframes[modName].catList[id] = nil
									for cat, spellId in pairs(E.db.Extras.unitframes[modName].catList) do
										if id == spellId then E.db.Extras.unitframes[modName].catList[cat] = nil end
									end
									print(format(core.customColorAlpha..L["Category \"%s\" removed."], core.customColorBeta..cat..core.customColorAlpha))
									break
								end
							end
						end,
						values = function()
							local values = {}
							for id, cat in pairs(E.db.Extras.unitframes[modName].catList) do
								if tonumber(id) then
									local name = GetSpellInfo(id) or ""
									local icon = select(3, GetSpellInfo(id))
									icon = icon and "|T"..icon..":0|t" or ""
									values[id] = format("%s %s (%s)", icon, name, cat)
								end
							end
							return values
						end,
					},
				},
			},
		},
	}
	if not E.db.Extras.unitframes[modName].units.focus then
		E.db.Extras.unitframes[modName].units.player = CopyTable(E.db.Extras.unitframes[modName].units.target)
		E.db.Extras.unitframes[modName].units.focus = CopyTable(E.db.Extras.unitframes[modName].units.target)
		E.db.Extras.unitframes[modName].units.arena = CopyTable(E.db.Extras.unitframes[modName].units.target)
	end
end


local function calculateNextX(db)
    if db.growthDir == 'RIGHT' then
        return db.iconSize + db.spacing
    elseif db.growthDir == 'LEFT' then
        return -1 * (db.spacing + db.iconSize)
    end
    return 0
end

local function calculateNextY(db)
    if db.growthDir == 'TOP' then
        return db.iconSize + db.spacing
    elseif db.growthDir == 'BOTTOM' then
        return -1 * (db.spacing + db.iconSize)
    end
    return 0
end

local function getEvaluatedColor(count, isAffectingPlayer, colors)
    if count == 1 then
        return isAffectingPlayer and colors.bad or colors.good
    elseif count == 2 then
        return colors.neutral
    else
        return isAffectingPlayer and colors.good or colors.bad
    end
end

local function createAura(self, index, db)
    local aura = CreateFrame("Frame", self.target.."DrFrame"..index, self)
	aura:Width(db.iconSize)
	aura:Height(db.iconSize)
	aura:SetTemplate("Transparent")

	aura.icon = aura:CreateTexture("$parenticon", "ARTWORK")
	aura.icon:SetInside(aura, E.mult, E.mult)
	aura.icon:SetTexCoord(unpack(E.TexCoords))

	aura.cooldown = CreateFrame("Cooldown", "$parentCD", aura, "CooldownFrameTemplate")
	aura.cooldown:SetAllPoints(aura.icon)
	aura.cooldown:SetReverse()

	if db.strengthIndicator.text.enabled then
		local db = db.strengthIndicator.text
		aura.count = aura:CreateFontString("OVERLAY")
		aura.count:SetFont(LSM:Fetch("font", db.font), db.size, db.flag)
		aura.count:Point(db.point, aura, db.relativeTo, db.x, db.y)
		aura.count:Show()
	end

	if db.strengthIndicator.box.enabled then
		local db = db.strengthIndicator.box
		aura.indicator = CreateFrame("Button", nil, aura)
		aura.indicator:SetTemplate()
		aura.indicator:Size(db.size)
		aura.indicator:Point(db.point, aura, db.point)
		aura.indicator:SetFrameLevel(aura.cooldown:GetFrameLevel() + 2)
	end

	if not db.noCdNumbers then
		E:RegisterCooldown(aura.cooldown)
	end

	aura.start = 0

    return aura
end

local function combatLogCheck(...)
	local event, _, eventType, sourceGUID, _, _, destGUID, _, destFlags, spellID, _, _, auraType = ...
    if event == 'COMBAT_LOG_EVENT_UNFILTERED' and not eventRegistered[eventType] then return end

    local db = E.db.Extras.unitframes[modName]
    local isAffectingPlayer, isAnotherPlayer = destGUID == UnitGUID('player')
    if destFlags then
        isAnotherPlayer = (band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER or band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER)
        local isHostileOrNeutral = (band(destFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) == COMBATLOG_OBJECT_REACTION_HOSTILE or band(destFlags, COMBATLOG_OBJECT_REACTION_NEUTRAL) == COMBATLOG_OBJECT_REACTION_NEUTRAL)

        if (event == 'COMBAT_LOG_EVENT_UNFILTERED' and (not isHostileOrNeutral and not isAffectingPlayer)) or ((db.playersOnly and (not isAnotherPlayer or isAffectingPlayer))) then return end
    end

    local needupdate = false
    local catList = db.catList
    local DRtime = db.DRtime
    if (eventType == "SPELL_AURA_APPLIED") or (eventType == "SPELL_AURA_REFRESH") or (eventType == "SPELL_CAST_SUCCESS") then
        if (auraType == "DEBUFF") or (eventType == "SPELL_CAST_SUCCESS") then
            local drCat = spells[spellID]

            if not drCat or not catList[drCat] then return end
            if not isAnotherPlayer and not pveDR[drCat] then return end

			-- sometimes (silences) a spellcast triggers both a SPELL_CAST_SUCCESS and some other event
			lastUpdateTime[sourceGUID] = lastUpdateTime[sourceGUID] or {}
			local lastUpdate = lastUpdateTime[sourceGUID][spellID] or 0
			local currentTime = GetTime()
			if currentTime - lastUpdate < 1 then return end
			lastUpdateTime[sourceGUID][spellID] = currentTime

            local color = db.catColors[drCat]

            if not activeGUIDs[destGUID] then activeGUIDs[destGUID] = {} end
            if not activeGUIDs[destGUID][drCat] then activeGUIDs[destGUID][drCat] = {} end

            local _, _, icon = GetSpellInfo(catList[drCat])
			local start = activeGUIDs[destGUID][drCat].start
            local count = (start and start + DRtime > GetTime()) and activeGUIDs[destGUID][drCat].count + 1 or 1
            activeGUIDs[destGUID][drCat].spellID = spellID
            activeGUIDs[destGUID][drCat].count = count
            activeGUIDs[destGUID][drCat].start = GetTime()
            activeGUIDs[destGUID][drCat].icon = icon
            activeGUIDs[destGUID][drCat].color = color

            needupdate = true
        end
    elseif event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
        local unit = lower(match(event, "_(.-)_"))
        if not UnitExists(unit) then return end

		local unitGUID = UnitGUID(unit)
		if activeGUIDs[unitGUID] and next(activeGUIDs[unitGUID]) then
			needupdate = true
		else
			local frame = UF[unit]
			if frame and frame.DrTracker then
				local drTracker = frame.DrTracker
				for i = 1, #drTracker.auras do
					drTracker.auras[i]:Hide()
					drTracker.auras[i]:SetScript("OnUpdate", nil)
				end
			end
		end
    end

    if needupdate then
        for frame, target in pairs(framelist) do
			local targetGUID = UnitExists(target[1]) and UnitGUID(target[1])
			if targetGUID and activeGUIDs[targetGUID] then
				mod:DisplayDrActives(_G[frame].DrTracker)
			end
        end
    end
end

local function setupDRUnits()
	twipe(framelist)
	local db = E.db.Extras.unitframes[modName].units

	--[FRAME NAME]	= {UNITID,SIZE,ANCHOR,ANCHORFRAME,X,Y,"ANCHORNEXT","ANCHORPREVIOUS",nextx,nexty},

	if db.player.enabled then
		framelist["ElvUF_Player"] = {"player", db.player.point, db.player.relativeTo, db.player.xOffset, db.player.yOffset, "LEFT", "RIGHT", 2, 0}
	end

	if db.target.enabled then
		framelist["ElvUF_Target"] = {"target", db.target.point, db.target.relativeTo, db.target.xOffset, db.target.yOffset, "LEFT", "RIGHT", 2, 0}
	end

	if db.focus.enabled then
		framelist["ElvUF_Focus"] = {"focus", db.focus.point, db.focus.relativeTo, db.focus.xOffset, db.focus.yOffset, "LEFT","RIGHT",2,0}
	end

	if db.arena.enabled then
		framelist["ElvUF_Arena1"] = {"arena1", db.arena.point, db.arena.relativeTo, db.arena.xOffset, db.arena.yOffset, "RIGHT","LEFT",-2,0}
		framelist["ElvUF_Arena2"] = {"arena2", db.arena.point, db.arena.relativeTo, db.arena.xOffset, db.arena.yOffset, "RIGHT","LEFT",-2,0}
		framelist["ElvUF_Arena3"] = {"arena3", db.arena.point, db.arena.relativeTo, db.arena.xOffset, db.arena.yOffset, "RIGHT","LEFT",-2,0}
		framelist["ElvUF_Arena4"] = {"arena4", db.arena.point, db.arena.relativeTo, db.arena.xOffset, db.arena.yOffset, "RIGHT","LEFT",-2,0}
		framelist["ElvUF_Arena5"] = {"arena5", db.arena.point, db.arena.relativeTo, db.arena.xOffset, db.arena.yOffset, "RIGHT","LEFT",-2,0}
	end
end


function mod:UpdateDRTracker(self, cat, targetGUID, DRtime)
    if self.start + DRtime <= GetTime() then
        self:Hide()
        self:SetScript("OnUpdate", nil)
		activeGUIDs[targetGUID][cat] = nil
		if next(activeGUIDs[targetGUID]) then
			mod:DisplayDrActives(self:GetParent())
		end
    end
end

function mod:UpdateAura(aura, targetGUID, cat, entry, db, DRtime)
    aura.icon:SetTexture(entry.icon)
    CooldownFrame_SetTimer(aura.cooldown, entry.start, DRtime, 1)
    aura.start = entry.start

    if aura.count or aura.indicator then
        local colors = db.strengthIndicator.colors
        local isAffectingPlayer = targetGUID == UnitGUID('player')
        local evaluatedColor = getEvaluatedColor(entry.count, isAffectingPlayer, colors)

        if aura.count then
            aura.count:SetText(entry.count)
            aura.count:SetTextColor(unpack(evaluatedColor))
        end
        if aura.indicator then
            aura.indicator:SetBackdropColor(unpack(evaluatedColor))
        end
    end

    if db.typeBorders then
        aura:SetBackdropBorderColor(unpack(entry.color))
        if aura.indicator then
            aura.indicator:SetBackdropBorderColor(unpack(entry.color))
        end
    end

    aura:SetScript("OnUpdate", function(self) mod:UpdateDRTracker(self, cat, targetGUID, DRtime) end)
    aura:Show()
end

function mod:DisplayDrActives(self)
    local target = self.target
    local targetGUID = UnitExists(target) and UnitGUID(target)
    local db = E.db.Extras.unitframes[modName]
    local DRtime = db.DRtime
    db = db.units[gsub(target, '%d', '')]

    local index = 1
    local sorted = {}
    for cat, entry in pairs(activeGUIDs[targetGUID]) do
        local aura = self.auras[index]
		if not aura then
			self.auras[index] = createAura(self, index, db)
			aura = self.auras[index]
		end
        mod:UpdateAura(aura, targetGUID, cat, entry, db, DRtime)
        tinsert(sorted, { aura = aura, start = entry.start })
        index = index + 1
    end

    -- hide and clear unused auras
    for i = index, #self.auras do
        self.auras[i]:Hide()
        self.auras[i]:SetScript("OnUpdate", nil)
    end

    -- sort and position auras
    tsort(sorted, function(a, b) return a.start < b.start end)
    for i, data in ipairs(sorted) do
        local aura = data.aura
        aura:ClearAllPoints()
        if i == 1 then
            aura:Point(self.anchor, self:GetParent(), self.anchorframe, self.x, self.y)
        else
            aura:Point(self.nextanchor, sorted[i-1].aura, self.nextanchorframe, self.nextx, self.nexty)
        end
    end
end

function mod:UpdateDRTrackerFrames()
    local db = E.db.Extras.unitframes[modName]
    local catColors = E.db.Extras.unitframes[modName].catColors

    for frame, target in pairs(framelist) do
        frame = _G[frame]
        local DrTracker = frame.DrTracker or CreateFrame("Frame", nil, frame)
        local unit_db = db.units[gsub(target[1], '%d', '')]

        -- update DrTracker properties
        DrTracker.target = target[1]

        DrTracker.anchor, DrTracker.anchorframe = target[2], target[3]
        DrTracker.x, DrTracker.y = target[4], target[5]
        DrTracker.nextanchor = unit_db.growthDir
        DrTracker.nextanchorframe = unit_db.growthDir
        DrTracker.nextx = calculateNextX(unit_db)
        DrTracker.nexty = calculateNextY(unit_db)

        DrTracker:ClearAllPoints()
        DrTracker:Size(unit_db.iconSize)
        DrTracker:Point(target[2], frame, target[3], target[4], target[5])

		DrTracker.auras = DrTracker.auras or {}

        frame.DrTracker = DrTracker

		local targetGUID = UnitExists(DrTracker.target) and UnitGUID(DrTracker.target)
		if targetGUID and activeGUIDs[targetGUID] then
			local drTracker = frame.DrTracker
			for i = 1, #drTracker.auras do
				drTracker.auras[i]:Hide()
				drTracker.auras[i] = nil
			end
			for cat, entry in pairs(activeGUIDs[targetGUID]) do
				entry.color = catColors[cat]
			end
			self:DisplayDrActives(frame.DrTracker)
		end
    end
end

function mod:TDR()
    if InCombatLockdown() then
        print(core.customColorBad..ERR_NOT_IN_COMBAT)
        return
    end

    local db = E.db.Extras.unitframes[modName]
    for frame, target in pairs(framelist) do
        if _G[frame]:IsShown() then
            local drTracker = _G[frame].DrTracker

            local testSpells = {}
            local entryCount = 0

            for spellId, cat in pairs(db.catList) do
                testSpells[spellId] = cat
                entryCount = entryCount + 1
            end

            -- add dummy entries if we don't have at least 3
            while entryCount < 3 do
                for spellId, cat in pairs(LAI.drSpells) do
                    if entryCount > 3 then
                        break
                    elseif random(1, 7) == 7 and not testSpells[cat] then
                        testSpells[spellId] = cat
                        entryCount = entryCount + 1
                    end
                end
            end

            local dummyGUID = UnitGUID(target[1])
            activeGUIDs[dummyGUID] = {}

            for spellId, cat in pairs(testSpells) do
                if not tonumber(cat) then
                    activeGUIDs[dummyGUID][cat] = {
                        color = db.catColors[cat],
                        start = GetTime() - random(1, 10),
                        icon = select(3, GetSpellInfo(spellId)),
                        count = random(1, 3)
                    }
                end
            end

            self:DisplayDrActives(drTracker)
        end
    end
end

function mod:Toggle()
	setupDRUnits()
	if next(framelist) then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLogCheck)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", combatLogCheck)
		self:RegisterEvent("PLAYER_FOCUS_CHANGED", combatLogCheck)
	else
		self:UnregisterAllEvents()
	end
	self:UpdateDRTrackerFrames()
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback