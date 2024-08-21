-- original code by: 5.4.8 ElvUI_Enhanced
local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("GuildsTitles", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local isAwesome = C_NamePlate

local scanner = CreateFrame("GameTooltip", "ExtrasGT_ScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local healthEnabled = {["FRIENDLY_NPC"] = false, ["ENEMY_NPC"] = false,}

mod:SecureHook(NP, "UpdateAllFrame", function()
	healthEnabled["FRIENDLY_NPC"] = NP.db.units["FRIENDLY_NPC"].health.enable
	healthEnabled["ENEMY_NPC"] = NP.db.units["ENEMY_NPC"].health.enable
end)

local trackingTypes = {}
local iconIndex = 1

local max = math.max
local _G, pairs, ipairs, tonumber = _G, pairs, ipairs, tonumber
local twipe, tinsert, tremove = table.wipe, table.insert, table.remove
local format, match, find, gsub = string.format, string.match, string.find, string.gsub
local UIParent, GetGuildInfo = UIParent, GetGuildInfo
local UnitInRaid, UnitInParty, UnitIsPlayer, UnitReaction, UnitName, UnitPlayerControlled = UnitInRaid, UnitInParty, UnitIsPlayer, UnitReaction, UnitName, UnitPlayerControlled
local IsResting, IsInInstance= IsResting, IsInInstance
local UNKNOWN, UNIT_LEVEL_TEMPLATE = UNKNOWN, UNIT_LEVEL_TEMPLATE
local TOOLTIP_UNIT_LEVEL_RACE_CLASS = gsub(table.concat({strsplit(1, string.format(TOOLTIP_UNIT_LEVEL_RACE_CLASS, 1, 1, 1))}), '[%d%p%s]+', '')

local E_Delay = E.Delay
local updatePending = false

local separatorMap = {
	NONE = "%s",
	ARROW = ">%s<",
	ARROW1 = "> %s <",
	ARROW2 = "<%s>",
	ARROW3 = "< %s >",
	BOX = "[%s]",
	BOX1 = "[ %s ]",
	CURLY = "{%s}",
	CURLY1 = "{ %s }",
	CURVE = "(%s)",
	CURVE1 = "( %s )"
}

mod.trackingTexMap = {
	"Interface\\Minimap\\Tracking\\Ammunition", -- 1
	"Interface\\Minimap\\Tracking\\Auctioneer", -- 2
	"Interface\\Minimap\\Tracking\\Banker", -- 3
	"Interface\\Minimap\\Tracking\\BattleMaster", -- 4
	"Interface\\Minimap\\Tracking\\Class", -- 5
	"Interface\\Minimap\\Tracking\\Food", -- 6
	"Interface\\Minimap\\Tracking\\Innkeeper", -- 7
	"Interface\\Minimap\\Tracking\\Mailbox", -- 8
	"Interface\\Minimap\\Tracking\\Poisons", -- 9
	"Interface\\Minimap\\Tracking\\Reagents", -- 10
	"Interface\\Minimap\\Tracking\\Profession", -- 11
	"Interface\\Minimap\\Tracking\\Repair", -- 12
	"Interface\\Minimap\\Tracking\\StableMaster", -- 13
	"Interface\\Minimap\\Tracking\\FlightMaster" -- 14
}


P["Extras"]["nameplates"][modName] = {
	["selectedSubSection"] = 'OccupationIcon',
	["UnitTitle"] = {},
	["NPCList"] = {},
	["GuildList"] = {},
	["NPCOccupations"] = {},
	["OccupationIcon"] = {
		["enabled"] = false,
		["desc"] = L["An icon similar to the minimap search."..
					"\n\nTooltip scanning, might not be precise."..
					"\n\nFor consistency reasons, no keywards are added by defult, "..
					"use /addOccupation command to mark the appropriate ones yourself (only need to do it once per unique occupation text)."],
		["size"] = 24,
		["point"] = "TOP",
		["relativeTo"] = "BOTTOM",
		["xOffset"] = 0,
		["yOffset"] = -16,
		["level"] = 40,
		["anchor"] = "FRAME",
		["playerList"] = {},
		["playerTextures"] = {},
		["modifier"] = 'Alt',
		["backdrop"] = false,
	},
	["Titles"] = {
		["enabled"] = false,
		["desc"] = L["Displays NPC occupation text."],
		["font"] = "Expressway",
		["fontSize"] = 11,
		["fontOutline"] = "OUTLINE",
		["separator"] = "BOX",
		["point"] = "CENTER",
		["relativeTo"] = "CENTER",
		["xOffset"] = 0,
		["yOffset"] = -4,
		["level"] = 15,
		["color"] = { r = 0.9, g = 0.9, b = 0.3 },
		["reactionColor"] = false,
	},
	["Guilds"] = {
		["enabled"] = false,
		["desc"] = L["Displays player guild text."],
		["visibility"] = {
			["city"] = true,
			["pvp"] = true,
			["arena"] = true,
			["party"] = true,
			["raid"] = true,
		},
		["font"] = "Expressway",
		["fontSize"] = 11,
		["fontOutline"] = "OUTLINE",
		["separator"] = "ARROW",
		["point"] = "CENTER",
		["relativeTo"] = "CENTER",
		["xOffset"] = 0,
		["yOffset"] = -4,
		["level"] = 15,
		["colors"] = {
			["raid"] = { r = 0.3, g = 0.6, b = 0.9 },
			["party"] = { r = 0.6, g = 0.9, b = 0.3 },
			["guild"] = { r = 0.9, g = 0.6, b = 0.3 },
			["none"] = { r = 0.6, g = 0.6, b = 0.6 },
		},
	},
}

function mod:LoadConfig()
	local function selectedSubSection() return E.db.Extras.nameplates[modName].selectedSubSection end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Guilds&Titles"],
		get = function(info) return E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] end,
		set = function(info, value) E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] = value mod:UpdateAllSettings() end,
		args = {
			SubSection = {
				order = 1,
				type = "group",
				name = L["Sub-Section"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = function() return E.db.Extras.nameplates[modName][selectedSubSection()].desc end,
						get = function() return E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
						set = function(_, value) E.db.Extras.nameplates[modName][selectedSubSection()].enabled = value mod:Toggle() end,
					},
					selectedSubSection = {
						order = 2,
						type = "select",
						name = L["Select"],
						desc = "",
						get = function() return E.db.Extras.nameplates[modName].selectedSubSection end,
						set = function(_, value) E.db.Extras.nameplates[modName].selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(E.db.Extras.nameplates[modName]) do
								if section == 'Guilds' or section == 'Titles' or section == 'OccupationIcon' then
									dropdownValues[section] = L[section]
								end
							end
							return dropdownValues
						end,
					},
					purgeCache = {
						type = "execute",
						width = "double",
						name = L["Purge Cache"],
						desc = "",
						func = function() E.db.Extras.nameplates[modName].UnitTitle = {} print(core.customColorBeta .. L["Cache purged."]) end,
					},
				},
			},
			Guilds = {
				order = 2,
				type = "group",
				name = L["Guilds"],
				guiInline = true,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Guilds' end,
				args = {
					font = {
						order = 2,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end
					},
					fontSize = {
						order = 3,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1
					},
					fontOutline = {
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
					},
					separator = {
						order = 5,
						type = "select",
						name = L["Separator"],
						desc = "",
						values = {
							NONE = L["None"],
							ARROW = "><",
							ARROW1 = ">  <",
							ARROW2 = "<>",
							ARROW3 = "<  >",
							BOX = "[]",
							BOX1 = "[  ]",
							CURLY = "{}",
							CURLY1 = "{  }",
							CURVE = "()",
							CURVE1 = "(  )"
						},
					},
					point = {
						order = 6,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 7,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 8,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 9,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					level = {
						order = 10,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -200, max = 200, step = 1
					},
				},
			},
			visibility = {
				order = 3,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return E.db.Extras.nameplates[modName].Guilds.visibility[info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName].Guilds.visibility[info[#info]] = value NP:ConfigureAll() end,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Guilds' end,
				args = {
					city = {
						order = 1,
						type = "toggle",
						name = L["City (Resting)"],
						desc = "",
					},
					pvp = {
						order = 2,
						type = "toggle",
						name = L["PvP"],
						desc = "",
					},
					arena = {
						order = 3,
						type = "toggle",
						name = L["Arena"],
						desc = "",
					},
					party = {
						order = 4,
						type = "toggle",
						name = L["Party"],
						desc = "",
					},
					raid = {
						order = 5,
						type = "toggle",
						name = L["Raid"],
						desc = "",
					},
				},
			},
			colors = {
				order = 4,
				type = "group",
				name = L["Colors"],
				guiInline = true,
				get = function(info) return E.db.Extras.nameplates[modName].Guilds.colors[info[#info]].r, E.db.Extras.nameplates[modName].Guilds.colors[info[#info]].g, E.db.Extras.nameplates[modName].Guilds.colors[info[#info]].b end,
				set = function(info, r, g, b) E.db.Extras.nameplates[modName].Guilds.colors[info[#info]].r, E.db.Extras.nameplates[modName].Guilds.colors[info[#info]].g, E.db.Extras.nameplates[modName].Guilds.colors[info[#info]].b = r, g, b NP:ConfigureAll() end,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Guilds' end,
				args = {
					raid = {
						order = 1,
						type = "color",
						name = L["Raid"],
						desc = "",
					},
					party = {
						order = 2,
						type = "color",
						name = L["Party"],
						desc = "",
					},
					guild = {
						order = 3,
						type = "color",
						name = L["Guild"],
						desc = "",
					},
					none = {
						order = 4,
						type = "color",
						name = L["All"],
						desc = "",
					},
				},
			},
			OccupationIcon = {
				type = "group",
				name = L["Occupation Icon"],
				guiInline = true,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'OccupationIcon' end,
				args = {
					size = {
						order = 2,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 4, max = 48, step = 1
					},
					anchor = {
						order = 2,
						type = "select",
						name = L["Anchor"],
						desc = "",
						get = function(info) return E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] = value
							mod:UpdateAllSettings()
							if E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] == 'TEXT' then
								for frame in pairs(NP.CreatedPlates) do
									if frame and frame.UnitFrame then
										if self:IsHooked(frame.UnitFrame.Health, "OnShow") then
											self:Unhook(frame.UnitFrame.Health, "OnShow")
										end
									end
								end
							end
						end,
						values = {
							["FRAME"] = L["Frame"],
							["TEXT"] = L["Text"],
						},
					},
					point = {
						order = 4,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 5,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 6,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 7,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					level = {
						order = 8,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -200, max = 200, step = 1
					},
					addOccupation = {
						order = 9,
						type = "input",
						name = L["/addOccupation"],
						desc = format(L["Usage:\n%%d=%%s\n\n%%d - index from the list below\n%%s - keywords to look for\n\nIndexes of icons:"..
									"\n1 - %s"..
									"\n2 - %s"..
									"\n3 - %s"..
									"\n4 - %s"..
									"\n5 - %s"..
									"\n6 - %s"..
									"\n7 - %s"..
									"\n8 - %s"..
									"\n9 - %s"..
									"\n10 - %s"..
									"\n11 - %s"..
									"\n12 - %s"..
									"\n13 - %s"..
									"\n14 - %s"..
									"\n\n\nAlso available as a '/addOccupation %%d' slash command where %%d is an optional icon index. "..
									"If no index is provided, this command will cycle through all of the available icons. Works on either TARGET or MOUSEOVER, prioritising the latter."],
									MINIMAP_TRACKING_VENDOR_AMMO, MINIMAP_TRACKING_AUCTIONEER, MINIMAP_TRACKING_BANKER, MINIMAP_TRACKING_BATTLEMASTER, MINIMAP_TRACKING_TRAINER_CLASS,
									MINIMAP_TRACKING_VENDOR_FOOD, MINIMAP_TRACKING_INNKEEPER, MINIMAP_TRACKING_MAILBOX, MINIMAP_TRACKING_VENDOR_POISON, MINIMAP_TRACKING_VENDOR_REAGENT,
									MINIMAP_TRACKING_TRAINER_PROFESSION, MINIMAP_TRACKING_REPAIR, MINIMAP_TRACKING_STABLEMASTER, MINIMAP_TRACKING_FLIGHTMASTER),
						set = function(_, value)
							if value and value ~= "" then
								tinsert(E.db.Extras.nameplates[modName].OccupationIcon.playerList, value)
								mod:UpdateAllSettings()
							end
						end,
					},
					removeOccupation = {
						order = 10,
						type = "select",
						name = L["Remove occupation"],
						desc = "",
						values = function()
							local list = {}
								for i = 1, #E.db.Extras.nameplates[modName].OccupationIcon.playerList do
									local entry = E.db.Extras.nameplates[modName].OccupationIcon.playerList[i]
									list[entry] = entry
								end
							return list
						end,
						set = function(_, value)
							for i, occupation in ipairs(E.db.Extras.nameplates[modName].OccupationIcon.playerList) do
								if occupation == value then
									tremove(E.db.Extras.nameplates[modName].OccupationIcon.playerList, i)
								end
							end
							mod:UpdateAllSettings()
						end,
					},
					modifier = {
						order = 11,
						type = "select",
						name = L["Modifier"],
						desc = L["Hold this while using /addOccupation command to clear the list of the current target/mouseover occupation.\nDon't forget to unbind the modifier+key bind!"],
						get = function(info) return E.db.Extras.nameplates[modName].OccupationIcon[info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName].OccupationIcon[info[#info]] = value end,
						values = function()
							local modsList = {}
							for mod, val in pairs(E.db.Extras.modifiers) do
								if mod ~= 'ANY' then
									modsList[mod] = val
								end
							end
							return modsList
						end,
					},
					addTexture = {
						order = 12,
						type = "input",
						name = L["Add Texture Path"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
						set = function(_, value)
							if value and match(value, '%S+') then
								tinsert(mod.trackingTexMap, value)
								tinsert(E.db.Extras.nameplates[modName].OccupationIcon.playerTextures, value)
							end
						end,
					},
					backdrop = {
						order = 13,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
					},
					removeTexture = {
						order = 14,
						type = "select",
						width = "double",
						name = L["Remove Selected Texture"],
						desc = "",
						set = function(_, value)
							for i in ipairs(E.db.Extras.nameplates[modName].OccupationIcon.playerTextures) do
								if i == value then
									tremove(E.db.Extras.nameplates[modName].OccupationIcon.playerTextures, i)
									tremove(mod.trackingTexMap, 14 + i)
								end
							end
						end,
						values = function()
							local list = {}
							for i, icon in ipairs(E.db.Extras.nameplates[modName].OccupationIcon.playerTextures) do
								list[i] = icon .. ' |T' .. icon .. ':16:16|t'
							end
							return list
						end,
					},
				},
			},
			Titles = {
				type = "group",
				name = L["Titles"],
				guiInline = true,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Titles' end,
				args = {
					font = {
						order = 2,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end
					},
					fontSize = {
						order = 3,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1
					},
					fontOutline = {
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
					},
					separator = {
						order = 5,
						type = "select",
						name = L["Separator"],
						desc = "",
						values = {
							NONE = L["None"],
							ARROW = "><",
							ARROW1 = "> <",
							ARROW2 = "<>",
							ARROW3 = "< >",
							BOX = "[]",
							BOX1 = "[ ]",
							CURLY = "{}",
							CURLY1 = "{ }",
							CURVE = "()",
							CURVE1 = "( )"
						},
					},
					reactionColor = {
						order = 6,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Color based on reaction type."]
					},
					color = {
						order = 7,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return E.db.Extras.nameplates[modName].Titles.color.r, E.db.Extras.nameplates[modName].Titles.color.g, E.db.Extras.nameplates[modName].Titles.color.b end,
						set = function(_, r, g, b) E.db.Extras.nameplates[modName].Titles.color.r, E.db.Extras.nameplates[modName].Titles.color.g, E.db.Extras.nameplates[modName].Titles.color.b = r, g, b NP:ConfigureAll() end,
						disabled = function() return E.db.Extras.nameplates[modName].Titles.reactionColor end
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
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 11,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					level = {
						order = 12,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -200, max = 200, step = 1
					},
				},
			},
		},
	}
	for _, tex in pairs(E.db.Extras.nameplates[modName].OccupationIcon.playerTextures) do
		tinsert(self.trackingTexMap , tex)
	end
end


local function constructTitle(frame)
	if frame.Title then return end
	frame.Title = CreateFrame('Frame', '$parentTitle', frame)
	frame.Title.str = frame.Title:CreateFontString(nil, "OVERLAY")
	frame.Title.str:SetWordWrap(false)
	frame.Title.str:SetAllPoints(frame.Title)
	frame.Title.iconHolder = CreateFrame('Frame', '$parentIconHolder', frame)
	frame.Title.icon = frame.Title.iconHolder:CreateTexture('$parentOccupationIcon', "OVERLAY")
	frame.Title.icon:SetAllPoints(frame.Title.iconHolder)
	frame.Title.scanner = CreateFrame('Frame', nil, UIParent)
	frame.Title.scanner:Show()
end

local function findPlateByName(unit)
	local name = UnitName(unit)
	for plate in pairs(NP.VisiblePlates) do
		if plate.UnitName == name then
			return plate
		end
	end
end

local function manageTitleFrame(frame, db, unitType, addIcon)
	local Title = frame.Title
	Title.str:SetFont(E.LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
	Title:Height(db.fontSize)

	Title:ClearAllPoints()
	Title:Point(db.point, frame, db.relativeTo, db.xOffset, db.yOffset)
	Title:SetFrameLevel(max(1,frame:GetFrameLevel()+db.level))

	if not addIcon then return end

	local iconHolder, anchor = Title.iconHolder

	db = E.db.Extras.nameplates[modName].OccupationIcon

	if db.anchor == "FRAME" then
		anchor = frame.Health:IsShown() and frame.Health or frame.Name

		if not healthEnabled[unitType] and not mod:IsHooked(frame.Health, "OnShow") then
			mod:SecureHookScript(frame.Health, "OnShow", function(self)
				if Title and Title.iconHolder then
					Title.iconHolder:ClearAllPoints()
					Title.iconHolder:Point(db.point, self, db.relativeTo, db.xOffset, db.yOffset)
				end
			end)
		end
	else
		if mod:IsHooked(frame.Health, "OnShow") then
			mod:Unhook(frame.Health, "OnShow")
		end

		anchor = Title
	end

	iconHolder:ClearAllPoints()
	iconHolder:Size(db.size)
	iconHolder:Point(db.point, anchor, db.relativeTo, db.xOffset, db.yOffset)
	iconHolder:SetFrameLevel(max(1,frame:GetFrameLevel()+db.level))

	if db.backdrop then
		if not iconHolder.backdrop then
			iconHolder:CreateBackdrop("Transparent")
		end
		iconHolder.backdrop:Show()
	elseif iconHolder.backdrop then
		iconHolder.backdrop:Hide()
	end
end

function mod:UpdateTitle(frame, unit, UnitTitle, name)
	name = name and name or frame.UnitName
	unit = unit and unit or name
	UnitTitle = UnitTitle and UnitTitle or db.UnitTitle[name]

	if not unit or not name or not UnitTitle then return end

	local db = E.db.Extras.nameplates[modName]

	local _, unitType = NP:GetUnitInfo(frame)
	if db.Guilds.enabled and (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
		db = db.Guilds

		local shown
		if IsResting() then
			shown = db.visibility.city
		else
			local _, instanceType = IsInInstance()
			if instanceType == "pvp" then
				shown = db.visibility.pvp
			elseif instanceType == "arena" then
				shown = db.visibility.arena
			elseif instanceType == "party" then
				shown = db.visibility.party
			elseif instanceType == "raid" then
				shown = db.visibility.raid
			else
				shown = true
			end
		end

		if shown then
			manageTitleFrame(frame, db, unitType)

			local color
			if UnitInRaid(unit) then
				color = db.colors.raid
			elseif UnitInParty(unit) then
				color = db.colors.party
			elseif GetGuildInfo("player") == UnitTitle then
				color = db.colors.guild
			else
				color = db.colors.none
			end

			frame.Title.str:SetTextColor(color.r, color.g, color.b)
			frame.Title.str:SetFormattedText(separatorMap[db.separator], UnitTitle)
			frame.Title:Width(frame.Title.str:GetStringWidth())

			frame.Title:Show()
			frame.Title.iconHolder:Hide()
		else
			frame.Title:Hide()
			frame.Title.iconHolder:Hide()
		end
	elseif (db.Titles.enabled or db.OccupationIcon.enabled) and (unitType == 'FRIENDLY_NPC' or unitType == 'ENEMY_NPC') then
		manageTitleFrame(frame, db.Titles, unitType, db.OccupationIcon.enabled)

		if db.OccupationIcon.enabled then
			frame.Title.iconHolder:Hide()

			if db.NPCOccupations[name] then
				frame.Title.icon:SetTexture(db.NPCOccupations[name].icon)
				frame.Title.iconHolder:Show()
			else
				for type, icon in pairs(trackingTypes) do
					if find(gsub(gsub(UnitTitle, '%p+', ''), '%s+', ''), type) then
						frame.Title.icon:SetTexture(icon)
						frame.Title.iconHolder:Show()
						db.NPCOccupations[name] = { occupation = type, icon = icon }
						break
					end
				end
			end
		end

		db = db.Titles
		if not db.enabled then return end

		if db.reactionColor then
			local colors = NP.db.colors
			local r, g, b
			if frame.UnitReaction then
				if frame.UnitReaction == 1 then
					r, g, b = colors.reactions.tapped.r, colors.reactions.tapped.g, colors.reactions.tapped.b
				elseif frame.UnitReaction == 4 then
					r, g, b = colors.reactions.neutral.r, colors.reactions.neutral.g, colors.reactions.neutral.b
				elseif frame.UnitReaction > 4 then
					r, g, b = colors.reactions.good.r, colors.reactions.good.g, colors.reactions.good.b
				else
					r, g, b = colors.reactions.bad.r, colors.reactions.bad.g, colors.reactions.bad.b
				end
			else
				r, g, b = 1, 1, 1
			end

			frame.Title.str:SetTextColor(r, g, b)
		else
			frame.Title.str:SetTextColor(db.color.r, db.color.g, db.color.b)
		end

		frame.Title.str:SetFormattedText(separatorMap[db.separator], UnitTitle)
		frame.Title:Width(frame.Title.str:GetStringWidth())

		frame.Title:Show()
	end
end

function mod:AwesomeUpdateUnitInfo(frame, unit)
	local db = E.db.Extras.nameplates[modName]

	if UnitIsPlayer(unit) and UnitReaction(unit, "player") ~= 2 then
		local name, realm = UnitName(unit)
		if realm or not name or name == UNKNOWN then return end

		scanner:ClearLines()
		scanner:SetUnit(unit)

		local guildName = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not guildName then
			frame.Title:Hide()
			frame.Title.iconHolder:Hide()
			return
		end

		if find(gsub(guildName, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_RACE_CLASS) then
			-- sometimes the guild info is too late to load
			if updatePending then return end
			updatePending = true

			E_Delay(nil, 0.1, function()
				if name ~= UnitName(unit) then return end

				guildName = GetGuildInfo(unit)
				if guildName then
					mod:UpdateTitle(frame, unit, guildName, name)
				end
				updatePending = false
			end)
			return
		end

		self:UpdateTitle(frame, unit, guildName, name)
	else
		scanner:ClearLines()
		scanner:SetUnit(unit)

		local name = _G["ExtrasGT_ScanningTooltipTextLeft1"]:GetText()
		if not name then return end
		local description = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()

		if match(description, UNIT_LEVEL_TEMPLATE) or find(gsub(description, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_RACE_CLASS) then return end

		name = gsub(gsub((name), "|c........", ""), "|r", "")
		if name ~= UnitName(unit) then return end
		if UnitPlayerControlled(unit) then return end

		self:UpdateTitle(frame, unit, description, name)
	end
end

function mod:UpdateUnitInfo(frame, unit)
	local db = E.db.Extras.nameplates[modName]
	if UnitIsPlayer(unit) and UnitReaction(unit, "player") ~= 2 then
		local name, realm = UnitName(unit)
		if realm or not name or name == UNKNOWN then return end

		scanner:ClearLines()
		scanner:SetUnit(unit)

		local guildName = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not guildName then
			if db.UnitTitle[name] then
				db.UnitTitle[name] = nil
				frame.Title:Hide()
				frame.Title.iconHolder:Hide()
			end
			return
		end

		if find(gsub(guildName, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_RACE_CLASS) then return end

		if db.UnitTitle[name] ~= guildName then
			db.UnitTitle[name] = guildName
		end
		self:UpdateTitle(frame, unit, guildName, name)
	else
		scanner:ClearLines()
		scanner:SetUnit(unit)

		local name = _G["ExtrasGT_ScanningTooltipTextLeft1"]:GetText()
		if not name then return end
		local description = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not description then return end

		if match(description, UNIT_LEVEL_TEMPLATE) or find(gsub(description, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_RACE_CLASS) then return end

		name = gsub(gsub((name), "|c........", ""), "|r", "")
		if name ~= UnitName(unit) then return end
		if UnitPlayerControlled(unit) then return end

		if db.UnitTitle[name] ~= description then
			db.UnitTitle[name] = description
		end
		self:UpdateTitle(frame, unit, description, name)
	end
end

function mod:UpdateTrackingTypes()
	local db = E.db.Extras.nameplates[modName]
	if #db.OccupationIcon.playerList > 0 then
		for i = 1, #db.OccupationIcon.playerList do
			local entry = db.OccupationIcon.playerList[i]
			local iconIndex, occupation = match(entry, '(%d+)%s*=%s*(.+)')
			if iconIndex and occupation then
				trackingTypes[gsub(gsub(occupation, '%p+', ''), '%s+', '')] = self.trackingTexMap[tonumber(iconIndex)]
			end
		end
	end
	for name, info in pairs(db.NPCOccupations) do
		if not trackingTypes[info.occupation] or trackingTypes[info.occupation] ~= info.icon then
			db.NPCOccupations[name] = nil
		end
	end
end

function mod:UpdateAllSettings()
	twipe(trackingTypes)
	mod:UpdateTrackingTypes()
	for frame in pairs(NP.VisiblePlates) do
		if frame.Title then frame.Title:Hide() end
	end
	NP:ConfigureAll()
end

function mod:addOccupation(msg)
	local db = E.db.Extras.nameplates[modName]
	for _, unit in ipairs({'mouseover', 'target'}) do
		if not UnitIsPlayer(unit) then
			scanner:ClearLines()
			scanner:SetUnit(unit)
			local name = _G["ExtrasGT_ScanningTooltipTextLeft1"]:GetText()
			local title = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
			if name and title then
				if not match(title, UNIT_LEVEL_TEMPLATE) then
					if _G['Is'..db.OccupationIcon.modifier..'KeyDown']() then
						for i, occupation in ipairs(db.OccupationIcon.playerList) do
							if find(gsub(gsub(occupation, '%p+', ''), '%s+', ''), gsub(gsub(title, '%p+', ''), '%s+', '')) then
								tremove(db.OccupationIcon.playerList, i)
								self:UpdateAllSettings()
								return
							end
						end
					end
					local icon = find(msg, '%d+') and msg or iconIndex
					for i, occupation in ipairs(db.OccupationIcon.playerList) do
						if find(gsub(gsub(occupation, '%p+', ''), '%s+', ''), gsub(gsub(title, '%p+', ''), '%s+', '')) then
							db.OccupationIcon.playerList[i] = icon.."="..title
							iconIndex = (iconIndex % #self.trackingTexMap) + 1
							self:UpdateAllSettings()
							return
						end
					end
					tinsert(db.OccupationIcon.playerList, icon.."="..title)
					iconIndex = (iconIndex % #self.trackingTexMap) + 1
					self:UpdateAllSettings()
					return
				end
			end
		end
	end
end

function mod:OnEvent(unit)
	local frame = findPlateByName(unit)
	if not frame then return end
	self:UpdateUnitInfo(frame, unit)
end

function mod:Toggle()
	local db = E.db.Extras.nameplates[modName]
	if not db.Guilds.enabled and not db.Titles.enabled and not db.OccupationIcon.enabled then
		if isAwesome then if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end end
		if self:IsHooked(NP, "Update_Name") then self:Unhook(NP, "Update_Name") end
		if self:IsHooked(NP, "OnCreated") then self:Unhook(NP, "OnCreated") end
		if self:IsHooked(NP, "ResetNameplateFrameLevel") then self:Unhook(NP, "ResetNameplateFrameLevel") end
		self:UnregisterAllEvents()
		SLASH_ADDOCCUPATION1 = nil
		SlashCmdList["ADDOCCUPATION"] = nil
		hash_SlashCmdList["/ADDOCCUPATION"] = nil
	else
		for plate in pairs(NP.VisiblePlates) do constructTitle(plate) end
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", mod.UpdateAllSettings)
		self:RegisterEvent("GUILD_ROSTER_UPDATE", mod.UpdateAllSettings)
		self:RegisterEvent("RAID_ROSTER_UPDATE", mod.UpdateAllSettings)
		if not self:IsHooked(NP, "OnCreated") then self:SecureHook(NP, "OnCreated", function(self, frame) constructTitle(frame.UnitFrame) end) end
		if isAwesome then
			if not self:IsHooked(NP, "OnShow") then
				self:SecureHook(NP, "OnShow", function(self)
					if not self.unit then return end
					local frame = self.UnitFrame
					local title = frame.Title
					if title then
						title:Hide()
						title.iconHolder:Hide()
						mod:AwesomeUpdateUnitInfo(frame, self.unit)
					end
				end)
			end
		else
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function() mod:OnEvent('mouseover') end)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", function() mod:OnEvent('target') end)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", function() mod:OnEvent('focus') end)
			if not self:IsHooked(NP, "ResetNameplateFrameLevel") then
				self:SecureHook(NP, "ResetNameplateFrameLevel", function(self, frame)
					local title = frame.Title
					if title then
						title:SetFrameLevel(max(1,title:GetParent():GetFrameLevel()+db.Titles.level))
						title.iconHolder:SetFrameLevel(max(1,title:GetParent():GetFrameLevel()+db.OccupationIcon.level))
					end
				end)
			end
			if not self:IsHooked(NP, "OnShow") then
				self:SecureHook(NP, "OnShow", function(self)
					local frame = self.UnitFrame
					local title = frame.Title
					if title then
						title:Hide()
						title.iconHolder:Hide()
						mod:UpdateTitle(frame, nil, nil, frame.UnitName)
					end
				end)
			end
			if not self:IsHooked(NP, "Update_Name") then
				self:SecureHook(NP, "Update_Name", function(self, frame, triggered)
					local title = frame.Title
					if title then
						title:Hide()
						title.iconHolder:Hide()
						mod:UpdateTitle(frame)
					end
				end)
			end
		end
		if db.OccupationIcon.enabled then
			SLASH_ADDOCCUPATION1 = "/addOccupation"
			SlashCmdList["ADDOCCUPATION"] = function(msg) mod:addOccupation(msg) end
		end
	end

	self:UpdateAllSettings()
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback