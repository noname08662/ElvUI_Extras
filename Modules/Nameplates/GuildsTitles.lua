-- original code by: 5.4.8 ElvUI_Enhanced
local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("GuildsTitles", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local modName = mod:GetName()
local NPCOccupations_data = {}
local NPCOccupations_cache = {}
local isAwesome = C_NamePlate

local scanner = CreateFrame("GameTooltip", "ExtrasGT_ScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local trackingTypes = {}
local iconIndex = 1

local max = math.max
local _G, pairs, ipairs, tonumber, select = _G, pairs, ipairs, tonumber, select
local twipe, tinsert, tremove, tcontains = table.wipe, table.insert, table.remove, tContains
local format, match, find, gsub, sub = string.format, string.match, string.find, string.gsub, string.sub
local GetGuildInfo = GetGuildInfo
local UnitInRaid, UnitInParty, UnitIsPlayer, UnitGUID = UnitInRaid, UnitInParty, UnitIsPlayer, UnitGUID
local UnitReaction, UnitName, UnitPlayerControlled, UnitCanAttack = UnitReaction, UnitName, UnitPlayerControlled, UnitCanAttack
local IsResting, IsInInstance = IsResting, IsInInstance
local UNKNOWN, UNIT_LEVEL_TEMPLATE = UNKNOWN, UNIT_LEVEL_TEMPLATE
local TOOLTIP_UNIT_LEVEL_RACE_CLASS = gsub(table.concat({strsplit(1, string.format(TOOLTIP_UNIT_LEVEL_RACE_CLASS, 1, 1, 1))}), '[%d%p%s]+', '')
local MINIMAP_TRACKING_VENDOR_AMMO, MINIMAP_TRACKING_AUCTIONEER, MINIMAP_TRACKING_BANKER,
		MINIMAP_TRACKING_BATTLEMASTER, MINIMAP_TRACKING_TRAINER_CLASS, MINIMAP_TRACKING_VENDOR_FOOD,
		MINIMAP_TRACKING_INNKEEPER, MINIMAP_TRACKING_MAILBOX, MINIMAP_TRACKING_VENDOR_POISON,
		MINIMAP_TRACKING_VENDOR_REAGENT, MINIMAP_TRACKING_TRAINER_PROFESSION, MINIMAP_TRACKING_REPAIR,
		MINIMAP_TRACKING_STABLEMASTER, MINIMAP_TRACKING_FLIGHTMASTER, BARBERSHOP, GUILD, MERCHANT, ALL =
			MINIMAP_TRACKING_VENDOR_AMMO, MINIMAP_TRACKING_AUCTIONEER, MINIMAP_TRACKING_BANKER,
			MINIMAP_TRACKING_BATTLEMASTER, MINIMAP_TRACKING_TRAINER_CLASS, MINIMAP_TRACKING_VENDOR_FOOD,
			MINIMAP_TRACKING_INNKEEPER, MINIMAP_TRACKING_MAILBOX, MINIMAP_TRACKING_VENDOR_POISON,
			MINIMAP_TRACKING_VENDOR_REAGENT, MINIMAP_TRACKING_TRAINER_PROFESSION, MINIMAP_TRACKING_REPAIR,
			MINIMAP_TRACKING_STABLEMASTER, MINIMAP_TRACKING_FLIGHTMASTER, BARBERSHOP, GUILD, MERCHANT, ALL


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

local dataTexMap = {
	["Auctioneer"] = "Interface\\Minimap\\Tracking\\Auctioneer",
	["Banker"] = "Interface\\Minimap\\Tracking\\Banker",
	["BattleMaster"] = "Interface\\Minimap\\Tracking\\BattleMaster",
	["Class"] = "Interface\\Minimap\\Tracking\\Class",
	["FlightMaster"] = "Interface\\Minimap\\Tracking\\FlightMaster",
	["Innkeeper"] = "Interface\\Minimap\\Tracking\\Innkeeper",
	["Reagents"] = "Interface\\Minimap\\Tracking\\Reagents",
	["Repair"] = "Interface\\Minimap\\Tracking\\Repair",
	["StableMaster"] = "Interface\\Minimap\\Tracking\\StableMaster",
	["Tabard"] = "Interface\\GossipFrame\\TabardGossipIcon",
	["Profession"] = "Interface\\Minimap\\Tracking\\Profession",
	["Vendor"] = "Interface\\GossipFrame\\VendorGossipIcon",
	["Barber"] = "Interface\\GossipFrame\\HealerGossipIcon",
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
	["NPCOccupations_cache"] = {},
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
		["types"] = {},
	},
	["Titles"] = {
		["enabled"] = false,
		["desc"] = L["Displays NPC occupation text."],
		["selectedType"] = "ENEMY_NPC",
		["ENEMY_NPC"] = {
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
		["FRIENDLY_NPC"] = {
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
	},
	["Guilds"] = {
		["enabled"] = false,
		["desc"] = L["Displays player guild text."],
		["selectedType"] = "ENEMY_PLAYER",
		["ENEMY_PLAYER"] = {
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
		["FRIENDLY_PLAYER"] = {
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
	},
}

function mod:LoadConfig()
	local db = E.db.Extras.nameplates[modName]
	local function selectedSubSection() return db.selectedSubSection or "Titles" end
	local function selectedType() return db.Titles.selectedType or "ENEMY_NPC" end
	local function selectedPlayerType() return db.Guilds.selectedType or "ENEMY_PLAYER" end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Guilds&Titles"],
		get = function(info) return db[selectedSubSection()][info[#info]] end,
		set = function(info, value) db[selectedSubSection()][info[#info]] = value self:UpdateAllSettings(db) end,
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
						desc = function() return db[selectedSubSection()].desc end,
						get = function() return db[selectedSubSection()].enabled end,
						set = function(_, value) db[selectedSubSection()].enabled = value self:Toggle(db) end,
					},
					selectedSubSection = {
						order = 2,
						type = "select",
						name = L["Select"],
						desc = "",
						get = function() return db.selectedSubSection end,
						set = function(_, value) db.selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(db) do
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
						func = function()
							if selectedSubSection() == 'OccupationIcon' then
								db.NPCOccupations_cache = {}
							else
								db.UnitTitle = {}
							end
							self:UpdateAllSettings(db)
							print(core.customColorBeta .. L["Cache purged."])
						end,
					},
				},
			},
			Guilds = {
				order = 2,
				type = "group",
				name = L["Guilds"],
				guiInline = true,
				get = function(info) return db[selectedSubSection()][selectedPlayerType()][info[#info]] end,
				set = function(info, value) db[selectedSubSection()][selectedPlayerType()][info[#info]] = value self:UpdateAllSettings(db) end,
				disabled = function() return not db[selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Guilds' end,
				args = {
					selectedType = {
						order = 1,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function(info) return db[selectedSubSection()][info[#info]] end,
						set = function(info, value) db[selectedSubSection()][info[#info]] = value end,
						values = {
							["ENEMY_PLAYER"] = L["ENEMY_PLAYER"],
							["FRIENDLY_PLAYER"] = L["FRIENDLY_PLAYER"],
						},
					},
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
				get = function(info) return db.Guilds[selectedPlayerType()].visibility[info[#info]] end,
				set = function(info, value) db.Guilds[selectedPlayerType()].visibility[info[#info]] = value NP:ConfigureAll() end,
				disabled = function() return not db[selectedSubSection()].enabled end,
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
				get = function(info)
					local colors = db.Guilds[selectedPlayerType()].colors[info[#info]]
					return colors.r, colors.g, colors.b
				end,
				set = function(info, r, g, b)
					local colors = db.Guilds[selectedPlayerType()].colors[info[#info]]
					colors.r, colors.g, colors.b = r, g, b
					NP:ConfigureAll()
				end,
				disabled = function() return not db[selectedSubSection()].enabled end,
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
				disabled = function() return not db[selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'OccupationIcon' end,
				args = {
					size = {
						order = 1,
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
						get = function(info) return db[selectedSubSection()][info[#info]] end,
						set = function(info, value) db[selectedSubSection()][info[#info]] = value
							self:UpdateAllSettings(db)
							if db[selectedSubSection()][info[#info]] == 'TEXT' then
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
						order = 3,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 4,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 5,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 6,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					level = {
						order = 7,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -200, max = 200, step = 1
					},
					addOccupation = {
						order = 8,
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
								tinsert(db.OccupationIcon.playerList, value)
								self:UpdateAllSettings(db)
							end
						end,
					},
					removeOccupation = {
						order = 9,
						type = "select",
						name = L["Remove occupation"],
						desc = "",
						values = function()
							local list = {}
								for i = 1, #db.OccupationIcon.playerList do
									local entry = db.OccupationIcon.playerList[i]
									list[entry] = entry
								end
							return list
						end,
						set = function(_, value)
							for i, occupation in ipairs(db.OccupationIcon.playerList) do
								if occupation == value then
									tremove(db.OccupationIcon.playerList, i)
								end
							end
							self:UpdateAllSettings(db)
						end,
					},
					modifier = {
						order = 10,
						type = "select",
						name = L["Modifier"],
						desc = L["Hold this while using /addOccupation command to clear the list of the current target/mouseover occupation.\nDon't forget to unbind the modifier+key bind!"],
						get = function(info) return db.OccupationIcon[info[#info]] end,
						set = function(info, value) db.OccupationIcon[info[#info]] = value end,
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
						order = 11,
						type = "input",
						name = L["Add Texture Path"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
						set = function(_, value)
							if value and match(value, '%S+') then
								tinsert(mod.trackingTexMap, value)
								tinsert(db.OccupationIcon.playerTextures, value)
							end
						end,
					},
					backdrop = {
						order = 12,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
					},
					removeTexture = {
						order = 13,
						type = "select",
						width = "double",
						name = L["Remove Selected Texture"],
						desc = "",
						set = function(_, value)
							for i in ipairs(db.OccupationIcon.playerTextures) do
								if i == value then
									tremove(db.OccupationIcon.playerTextures, i)
									tremove(mod.trackingTexMap, 14 + i)
								end
							end
						end,
						values = function()
							local list = {}
							for i, icon in ipairs(db.OccupationIcon.playerTextures) do
								list[i] = icon .. ' |T' .. icon .. ':16:16|t'
							end
							return list
						end,
					},
				},
			},
			automaticOnset = {
				order = 2,
				type = "group",
				name = L["Automatic Onset"],
				guiInline = true,
				get = function(info) return db.OccupationIcon.types[info[#info]] end,
				set = function(info, value) db.OccupationIcon.types[info[#info]] = value self:UpdateAllSettings(db) end,
				disabled = function() return not db[selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'OccupationIcon' end,
				args = {
					All = {
						order = 0,
						type = "toggle",
						name = ALL,
						desc = "",
					},
					Auctioneer = {
						order = 1,
						type = "toggle",
						name = MINIMAP_TRACKING_AUCTIONEER,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Banker = {
						order = 2,
						type = "toggle",
						name = MINIMAP_TRACKING_BANKER,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Barber = {
						order = 3,
						type = "toggle",
						name = BARBERSHOP,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					BattleMaster = {
						order = 4,
						type = "toggle",
						name = MINIMAP_TRACKING_BATTLEMASTER,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Class = {
						order = 5,
						type = "toggle",
						name = MINIMAP_TRACKING_TRAINER_CLASS,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					FlightMaster = {
						order = 6,
						type = "toggle",
						name = MINIMAP_TRACKING_FLIGHTMASTER,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Innkeeper = {
						order = 7,
						type = "toggle",
						name = MINIMAP_TRACKING_INNKEEPER,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Reagents = {
						order = 8,
						type = "toggle",
						name = MINIMAP_TRACKING_VENDOR_REAGENT,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Repair = {
						order = 9,
						type = "toggle",
						name = MINIMAP_TRACKING_REPAIR,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					StableMaster = {
						order = 10,
						type = "toggle",
						name = MINIMAP_TRACKING_STABLEMASTER,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Tabard = {
						order = 11,
						type = "toggle",
						name = GUILD,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Profession = {
						order = 12,
						type = "toggle",
						name = MINIMAP_TRACKING_TRAINER_PROFESSION,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
					Vendor = {
						order = 13,
						type = "toggle",
						name = MERCHANT,
						desc = "",
						hidden = function() return db.OccupationIcon.types["All"] end,
					},
				},
			},
			Titles = {
				type = "group",
				name = L["Titles"],
				guiInline = true,
				get = function(info) return db[selectedSubSection()][selectedType()][info[#info]] end,
				set = function(info, value) db[selectedSubSection()][selectedType()][info[#info]] = value self:UpdateAllSettings(db) end,
				disabled = function() return not db[selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Titles' end,
				args = {
					selectedType = {
						order = 1,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function(info) return db[selectedSubSection()][info[#info]] end,
						set = function(info, value) db[selectedSubSection()][info[#info]] = value end,
						values = {
							["ENEMY_NPC"] = L["ENEMY_NPC"],
							["FRIENDLY_NPC"] = L["FRIENDLY_NPC"],
						},
					},
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
					color = {
						order = 5,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function()
							local colors = db.Titles[selectedType()].color
							return colors.r, colors.g, colors.b
						end,
						set = function(_, r, g, b)
							local colors = db.Titles[selectedType()].color
							colors.r, colors.g, colors.b = r, g, b
							NP:ConfigureAll()
						end,
						disabled = function() return db.Titles.reactionColor end
					},
					reactionColor = {
						order = 6,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Color based on reaction type."]
					},
					separator = {
						order = 7,
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
	for _, tex in pairs(db.OccupationIcon.playerTextures) do
		tinsert(self.trackingTexMap , tex)
	end
end


local function constructTitle(frame)
	if frame.Title then return end
	frame.Title = CreateFrame('Frame', '$parentTitle', frame)
	frame.Title.str = frame.Title:CreateFontString(nil, "OVERLAY")
	frame.Title.str:SetWordWrap(false)
	frame.Title.str:SetAllPoints(frame.Title)
	frame.Title.scanner = CreateFrame('Frame', nil, UIParent)
	frame.Title.scanner:Show()
	frame.OccupationIcon = CreateFrame('Frame', '$parentOccupationIcon', frame)
	frame.OccupationIcon.icon = frame.OccupationIcon:CreateTexture('$parentOccupationIcon', "OVERLAY")
	frame.OccupationIcon.icon:SetAllPoints(frame.OccupationIcon)
end

local function findPlateByName(unit)
	local name = UnitName(unit)
	for plate in pairs(NP.VisiblePlates) do
		if plate.UnitName == name then
			return plate
		end
	end
end

local function manageTitleFrame(frame, title, db, unitType, db_icon)
	title.str:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
	title:Height(db.fontSize)

	local health = frame.Health
	local anchor = health:IsVisible() and health or frame.Name

	title:ClearAllPoints()
	title:Point(db.point, anchor, db.relativeTo, db.xOffset, db.yOffset)
	title:SetFrameLevel(max(1, frame:GetFrameLevel() + db.level))

	if not db_icon then return end

	local occupationIcon = frame.OccupationIcon

	if db_icon.anchor ~= "FRAME" then
		anchor = title
	end

	occupationIcon:ClearAllPoints()
	occupationIcon:Size(db_icon.size)
	occupationIcon:Point(db_icon.point, anchor, db_icon.relativeTo, db_icon.xOffset, db_icon.yOffset)
	occupationIcon:SetFrameLevel(max(1,frame:GetFrameLevel() + db_icon.level))

	if db_icon.backdrop then
		if not occupationIcon.backdrop then
			occupationIcon:CreateBackdrop("Transparent")
		end
		occupationIcon.backdrop:Show()
	elseif occupationIcon.backdrop then
		occupationIcon.backdrop:Hide()
	end
end


function mod:UpdateTitle(frame, db, unit, unitTitle, name)
	name = name and name or frame.UnitName
	unit = unit and unit or name
	unitTitle = unitTitle or db.UnitTitle[name]

	if not unit or not name then return end

	local title = frame.Title
	local _, unitType = NP:GetUnitInfo(frame)

	if unitType == 'FRIENDLY_NPC' or unitType == 'ENEMY_NPC' then
		local iconEnabled = db.OccupationIcon.enabled
		if not unitTitle or match(unitTitle, UNIT_LEVEL_TEMPLATE) or find(gsub(unitTitle, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_RACE_CLASS) then
			if iconEnabled then
				manageTitleFrame(frame, title, db.Titles[unitType], unitType, db.OccupationIcon)
				self:UpdateOccupation(frame.OccupationIcon, db, unit, unitTitle, name)
			end
		elseif unitTitle and db.Titles.enabled then
			if not isAwesome and db.UnitTitle[name] ~= unitTitle then
				db.UnitTitle[name] = unitTitle
			end
			if iconEnabled then
				manageTitleFrame(frame, title, db.Titles[unitType], unitType, db.OccupationIcon)
				self:UpdateOccupation(frame.OccupationIcon, db, unit, unitTitle, name)
			else
				manageTitleFrame(frame, title, db.Titles[unitType], unitType)
			end
			db = db.Titles[unitType]

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

				title.str:SetTextColor(r, g, b)
			else
				title.str:SetTextColor(db.color.r, db.color.g, db.color.b)
			end
			title.str:SetFormattedText(separatorMap[db.separator], unitTitle)
			title:Width(title.str:GetStringWidth())
			title:Show()
		elseif iconEnabled then
			manageTitleFrame(frame, title, db.Titles[unitType], unitType, db.OccupationIcon)
			self:UpdateOccupation(frame.OccupationIcon, db, unit, unitTitle, name)
		end
	elseif unitTitle and db.Guilds.enabled and (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
		db = db.Guilds[unitType]

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
			manageTitleFrame(frame, title, db, unitType)

			local color

			if UnitInRaid(unit) then
				color = db.colors.raid
			elseif UnitInParty(unit) then
				color = db.colors.party
			elseif GetGuildInfo("player") == unitTitle then
				color = db.colors.guild
			else
				color = db.colors.none
			end

			title.str:SetTextColor(color.r, color.g, color.b)
			title.str:SetFormattedText(separatorMap[db.separator], unitTitle)
			title:Width(title.str:GetStringWidth())

			title:Show()
			frame.OccupationIcon:Hide()
		end
	end
end

function mod:AwesomeUpdateUnitInfo(frame, db, unit)
	if UnitIsPlayer(unit) and UnitReaction(unit, "player") ~= 2 then
		local name, realm = UnitName(unit)
		if realm or not name or name == UNKNOWN then return end

		scanner:ClearLines()
		scanner:SetUnit(unit)

		local guildName = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not guildName then
			frame.Title:Hide()
			frame.OccupationIcon:Hide()
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
					mod:UpdateTitle(frame, db, unit, guildName, name)
				end
				updatePending = false
			end)
			return
		end

		self:UpdateTitle(frame, db, unit, guildName, name)
	elseif not UnitPlayerControlled(unit) then
		scanner:ClearLines()
		scanner:SetUnit(unit)

		local name = _G["ExtrasGT_ScanningTooltipTextLeft1"]:GetText()
		if not name then return end
		local description = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not description then return end

		name = gsub(gsub((name), "|c........", ""), "|r", "")
		if name ~= UnitName(unit) then return end

		self:UpdateTitle(frame, db, unit, description, name)
	end
end

function mod:UpdateOccupation(occupationIcon, db, unit, unitTitle, name)
	if db.NPCOccupations[name] then
		occupationIcon.icon:SetTexture(db.NPCOccupations[name].icon)
		occupationIcon:Show()
		return
	elseif not isAwesome and NPCOccupations_cache[name] then
		occupationIcon.icon:SetTexture(NPCOccupations_cache[name])
		occupationIcon:Show()
		return
	elseif unitTitle then
		for type, icon in pairs(trackingTypes) do
			if find(gsub(gsub(unitTitle, '%p+', ''), '%s+', ''), type) then
				occupationIcon.icon:SetTexture(icon)
				occupationIcon:Show()
				db.NPCOccupations[name] = { occupation = type, icon = icon }
				return
			end
		end
	end

	local guid = unit and UnitGUID(unit)
	if guid and not UnitCanAttack('player', unit) then
		local npcId = tonumber(sub(guid, -10, -7), 16)
		for occupation, entries in pairs(NPCOccupations_data) do
			if tcontains(entries, npcId) then
				local tex = dataTexMap[occupation]
				occupationIcon.icon:SetTexture(tex)
				occupationIcon:Show()
				if not isAwesome and not db.NPCOccupations_cache[name] then
					db.NPCOccupations_cache[name] = { occupation = occupation, tex = tex }
					NPCOccupations_cache[name] = tex
				end
				return
			end
		end
	end
	occupationIcon:Hide()
end

function mod:UpdateUnitInfo(frame, db, unit)
	if UnitIsPlayer(unit) then
		local name, realm = UnitName(unit)
		if realm or not name or name == UNKNOWN then return end

		scanner:ClearLines()
		scanner:SetUnit(unit)

		local guildName = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not guildName then
			if db.UnitTitle[name] then
				db.UnitTitle[name] = nil
			end
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
					mod:UpdateTitle(frame, db, unit, guildName, name)
				end
				updatePending = false
			end)
			return
		end

		if db.UnitTitle[name] ~= guildName then
			db.UnitTitle[name] = guildName
		end
		self:UpdateTitle(frame, db, unit, guildName, name)
	elseif not UnitPlayerControlled(unit) then
		scanner:ClearLines()
		scanner:SetUnit(unit)

		local name = _G["ExtrasGT_ScanningTooltipTextLeft1"]:GetText()
		if not name then return end
		local description = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if not description then return end

		name = gsub(gsub((name), "|c........", ""), "|r", "")
		if name ~= UnitName(unit) then return end

		self:UpdateTitle(frame, db, unit, description, name)
	end
end

function mod:UpdateTrackingTypes(db)
	twipe(trackingTypes)
	twipe(NPCOccupations_data)
	twipe(NPCOccupations_cache)
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
	local all = db.OccupationIcon.types["All"]
	for occupation, data in pairs(core.NPCOccupations_data or {}) do
		if all or db.OccupationIcon.types[occupation] then
			NPCOccupations_data[occupation] = data
		end
	end
	for name, info in pairs(db.NPCOccupations_cache) do
		if all or db.OccupationIcon.types[info.occupation] then
			NPCOccupations_cache[name] = info.tex
		end
	end
	if db.OccupationIcon.enabled then
		if db.OccupationIcon.anchor == "FRAME" then
			core.plateAnchoring['OccupationIcon'] = function(unitType, frame)
				if unitType == 'FRIENDLY_NPC' or unitType == 'ENEMY_NPC' then
					return db.OccupationIcon
				end
			end
		else
			core.plateAnchoring['OccupationIcon'] = nil
		end
	else
		core.plateAnchoring['OccupationIcon'] = nil
	end
end

function mod:UpdateAllSettings(db)
	self:UpdateTrackingTypes(db)
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
								self:UpdateAllSettings(db)
								return
							end
						end
					end
					local icon = find(msg, '%d+') and msg or iconIndex
					for i, occupation in ipairs(db.OccupationIcon.playerList) do
						if find(gsub(gsub(occupation, '%p+', ''), '%s+', ''), gsub(gsub(title, '%p+', ''), '%s+', '')) then
							db.OccupationIcon.playerList[i] = icon.."="..title
							iconIndex = (iconIndex % #self.trackingTexMap) + 1
							self:UpdateAllSettings(db)
							return
						end
					end
					tinsert(db.OccupationIcon.playerList, icon.."="..title)
					iconIndex = (iconIndex % #self.trackingTexMap) + 1
					self:UpdateAllSettings(db)
					return
				end
			end
		end
	end
end

function mod:OnEvent(db, unit)
	local frame = findPlateByName(unit)
	if not frame then return end
	self:UpdateUnitInfo(frame, db, unit)
end


function mod:Toggle(db)
	if not db.Guilds.enabled and not db.Titles.enabled and not db.OccupationIcon.enabled then
		if not db.Guilds.enabled and not db.Titles.enabled then
			core.plateAnchoring['Title'] = nil
		end
		if not db.OccupationIcon.enabled then
			core.plateAnchoring['OccupationIcon'] = nil
		end
		if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		if self:IsHooked(NP, "Update_Name") then self:Unhook(NP, "Update_Name") end
		if self:IsHooked(NP, "OnCreated") then self:Unhook(NP, "OnCreated") end
		if self:IsHooked(NP, "ResetNameplateFrameLevel") then self:Unhook(NP, "ResetNameplateFrameLevel") end
		self:UnregisterAllEvents()
		SLASH_ADDOCCUPATION1 = nil
		SlashCmdList["ADDOCCUPATION"] = nil
		hash_SlashCmdList["/ADDOCCUPATION"] = nil
	else
		if db.Guilds.enabled or db.Titles.enabled then
			core.plateAnchoring['Title'] = function(unitType, frame)
				if unitType == 'FRIENDLY_NPC' or unitType == 'ENEMY_NPC' then
					return db.Titles[unitType]
				elseif unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
					return db.Guilds[unitType]
				end
			end
		end
		self:RegisterEvent("PARTY_MEMBERS_CHANGED", function() self:UpdateAllSettings(db) end)
		self:RegisterEvent("GUILD_ROSTER_UPDATE", function() self:UpdateAllSettings(db) end)
		self:RegisterEvent("RAID_ROSTER_UPDATE", function() self:UpdateAllSettings(db) end)
		if isAwesome then
			if not self:IsHooked(NP, "OnCreated") then
				self:SecureHook(NP, "OnCreated", function(self, frame)
					constructTitle(frame.UnitFrame)
				end)
			end
			if not self:IsHooked(NP, "OnShow") then
				self:SecureHook(NP, "OnShow", function(self)
					if not self.unit then return end
					local frame = self.UnitFrame
					if frame.Title then
						frame.Title:Hide()
						frame.OccupationIcon:Hide()
						mod:AwesomeUpdateUnitInfo(frame, db, self.unit)
					end
				end)
			end
		else
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function() mod:OnEvent(db, 'mouseover') end)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", function() mod:OnEvent(db, 'target') end)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", function() mod:OnEvent(db, 'focus') end)
			if not self:IsHooked(NP, "ResetNameplateFrameLevel") then
				self:SecureHook(NP, "ResetNameplateFrameLevel", function(self, frame)
					if frame.Title then
						local unitType = frame.UnitType or select(2,NP:GetUnitInfo(frame))
						if unitType and (unitType == "FRIENDLY_NPC" or unitType == "ENEMY_NPC") then
							local level = frame:GetFrameLevel()
							frame.Title:SetFrameLevel(max(1, level + db.Titles[unitType].level))
							frame.OccupationIcon:SetFrameLevel(max(1, level + db.OccupationIcon.level))
						end
					end
				end)
			end
			if not self:IsHooked(NP, "OnShow") then
				self:SecureHook(NP, "OnShow", function(self)
					local frame = self.UnitFrame
					constructTitle(frame)
					frame.Title:Hide()
					frame.OccupationIcon:Hide()
					mod:UpdateTitle(frame, db, nil, nil, frame.UnitName)
				end)
			end
		end
		if db.OccupationIcon.enabled then
			SLASH_ADDOCCUPATION1 = "/addOccupation"
			SlashCmdList["ADDOCCUPATION"] = function(msg) mod:addOccupation(msg) end
		end
	end
	self:UpdateAllSettings(db)
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	mod:LoadConfig()
	mod:Toggle(E.db.Extras.nameplates[modName])
end

core.modules[modName] = mod.InitializeCallback