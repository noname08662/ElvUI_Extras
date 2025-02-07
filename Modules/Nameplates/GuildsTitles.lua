-- original code by: 5.4.8 ElvUI_Enhanced
local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("GuildsTitles", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local modName = mod:GetName()
local NPCOccupations_data = {}
local NPCOccupations_cache = {}
local dataTexMap = {}
local dataTexMapDefaults = {
	[MINIMAP_TRACKING_AUCTIONEER		] = "Interface\\Minimap\\Tracking\\Auctioneer",
	[MINIMAP_TRACKING_BANKER			] = "Interface\\Minimap\\Tracking\\Banker",
	[MINIMAP_TRACKING_BATTLEMASTER		] = "Interface\\Minimap\\Tracking\\BattleMaster",
	[MINIMAP_TRACKING_TRAINER_CLASS		] = "Interface\\Minimap\\Tracking\\Class",
	[MINIMAP_TRACKING_FLIGHTMASTER		] = "Interface\\Minimap\\Tracking\\FlightMaster",
	[MINIMAP_TRACKING_INNKEEPER			] = "Interface\\Minimap\\Tracking\\Innkeeper",
	[MINIMAP_TRACKING_VENDOR_REAGENT	] = "Interface\\Minimap\\Tracking\\Reagents",
	[MINIMAP_TRACKING_REPAIR			] = "Interface\\Minimap\\Tracking\\Repair",
	[MINIMAP_TRACKING_STABLEMASTER		] = "Interface\\Minimap\\Tracking\\StableMaster",
	[GUILD								] = "Interface\\GossipFrame\\TabardGossipIcon",
	[MINIMAP_TRACKING_TRAINER_PROFESSION] = "Interface\\Minimap\\Tracking\\Profession",
	[MERCHANT							] = "Interface\\GossipFrame\\VendorGossipIcon",
	[BARBERSHOP							] = "Interface\\GossipFrame\\HealerGossipIcon",
}

local isAwesome = C_NamePlate
local GetNamePlateForUnit = isAwesome and C_NamePlate.GetNamePlateForUnit

mod.initialized = false

local scanner = CreateFrame("GameTooltip", "ExtrasGT_ScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local _G, pairs, ipairs, tonumber = _G, pairs, ipairs, tonumber
local twipe, tinsert, tsort = table.wipe, table.insert, table.sort
local format, find, gsub, sub = string.format, string.find, string.gsub, string.sub
local GetGuildInfo = GetGuildInfo
local UnitInRaid, UnitInParty, UnitIsPlayer, UnitGUID = UnitInRaid, UnitInParty, UnitIsPlayer, UnitGUID
local UnitReaction, UnitName, UnitPlayerControlled, UnitCanAttack = UnitReaction, UnitName, UnitPlayerControlled, UnitCanAttack
local UNKNOWN = UNKNOWN
local TOOLTIP_UNIT_LEVEL_CLASS = gsub(table.concat({strsplit(1, format(TOOLTIP_UNIT_LEVEL_CLASS, 1, 1, 1))}), '[%d%p%s]+', '')
local TOOLTIP_UNIT_LEVEL = gsub(format(TOOLTIP_UNIT_LEVEL, 1), '[%s%d%p]+', '')
local MINIMAP_TRACKING_AUCTIONEER, MINIMAP_TRACKING_BANKER,
		MINIMAP_TRACKING_BATTLEMASTER, MINIMAP_TRACKING_TRAINER_CLASS, MINIMAP_TRACKING_INNKEEPER,
		MINIMAP_TRACKING_VENDOR_REAGENT, MINIMAP_TRACKING_TRAINER_PROFESSION, MINIMAP_TRACKING_REPAIR,
		MINIMAP_TRACKING_STABLEMASTER, MINIMAP_TRACKING_FLIGHTMASTER, BARBERSHOP, GUILD, MERCHANT, ALL =
			MINIMAP_TRACKING_AUCTIONEER, MINIMAP_TRACKING_BANKER,
			MINIMAP_TRACKING_BATTLEMASTER, MINIMAP_TRACKING_TRAINER_CLASS, MINIMAP_TRACKING_INNKEEPER,
			MINIMAP_TRACKING_VENDOR_REAGENT, MINIMAP_TRACKING_TRAINER_PROFESSION, MINIMAP_TRACKING_REPAIR,
			MINIMAP_TRACKING_STABLEMASTER, MINIMAP_TRACKING_FLIGHTMASTER, BARBERSHOP, GUILD, MERCHANT, ALL


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


local function updateVisibilityState(db, areaType)
	for _, unitType in ipairs({'ENEMY_PLAYER', 'FRIENDLY_PLAYER'}) do
		local data = db[unitType]
		data.isShown = data['showAll'] or data[areaType]
	end
end


P["Extras"]["nameplates"][modName] = {
	["selectedSubSection"] = 'OccupationIcon',
	["UnitTitle"] = {},
	["NPCOccupations_cache"] = {},
	["NPCOccupations_data"] = {
		[MINIMAP_TRACKING_AUCTIONEER] = {},
		[MINIMAP_TRACKING_BANKER] = {},
		[MINIMAP_TRACKING_BATTLEMASTER] = {},
		[MINIMAP_TRACKING_TRAINER_CLASS] = {},
		[MINIMAP_TRACKING_FLIGHTMASTER] = {},
		[MINIMAP_TRACKING_INNKEEPER] = {},
		[MINIMAP_TRACKING_VENDOR_REAGENT] = {},
		[MINIMAP_TRACKING_REPAIR] = {},
		[MINIMAP_TRACKING_STABLEMASTER] = {},
		[GUILD] = {},
		[MINIMAP_TRACKING_TRAINER_PROFESSION] = {},
		[MERCHANT] = {},
		[BARBERSHOP] = {},
	},
	["OccupationIcon"] = {
		["enabled"] = false,
		["desc"] = L["An icon similar to the minimap search."],
		["size"] = 24,
		["point"] = "TOP",
		["relativeTo"] = "BOTTOM",
		["xOffset"] = 0,
		["yOffset"] = -16,
		["level"] = 0,
		["anchor"] = "FRAME",
		["modifier"] = 'Alt',
		["backdrop"] = false,
		["types"] = {},
		["selectedOccupation"] = MERCHANT,
		["dataTexMap"] = {
			[MINIMAP_TRACKING_AUCTIONEER		] = "Interface\\Minimap\\Tracking\\Auctioneer",
			[MINIMAP_TRACKING_BANKER			] = "Interface\\Minimap\\Tracking\\Banker",
			[MINIMAP_TRACKING_BATTLEMASTER		] = "Interface\\Minimap\\Tracking\\BattleMaster",
			[MINIMAP_TRACKING_TRAINER_CLASS		] = "Interface\\Minimap\\Tracking\\Class",
			[MINIMAP_TRACKING_FLIGHTMASTER		] = "Interface\\Minimap\\Tracking\\FlightMaster",
			[MINIMAP_TRACKING_INNKEEPER			] = "Interface\\Minimap\\Tracking\\Innkeeper",
			[MINIMAP_TRACKING_VENDOR_REAGENT	] = "Interface\\Minimap\\Tracking\\Reagents",
			[MINIMAP_TRACKING_REPAIR			] = "Interface\\Minimap\\Tracking\\Repair",
			[MINIMAP_TRACKING_STABLEMASTER		] = "Interface\\Minimap\\Tracking\\StableMaster",
			[GUILD								] = "Interface\\GossipFrame\\TabardGossipIcon",
			[MINIMAP_TRACKING_TRAINER_PROFESSION] = "Interface\\Minimap\\Tracking\\Profession",
			[MERCHANT							] = "Interface\\GossipFrame\\VendorGossipIcon",
			[BARBERSHOP							] = "Interface\\GossipFrame\\HealerGossipIcon",
		},
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
			["level"] = 0,
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
			["level"] = 0,
			["color"] = { r = 0.9, g = 0.9, b = 0.3 },
			["reactionColor"] = false,
		},
	},
	["Guilds"] = {
		["enabled"] = false,
		["desc"] = L["Displays player guild text."],
		["selectedType"] = "ENEMY_PLAYER",
		["ENEMY_PLAYER"] = {
			["showAll"] = true,
			["showCity"] = false,
			["showBG"] = false,
			["showArena"] = false,
			["showInstance"] = false,
			["showWorld"] = false,
			["font"] = "Expressway",
			["fontSize"] = 11,
			["fontOutline"] = "OUTLINE",
			["separator"] = "ARROW",
			["point"] = "CENTER",
			["relativeTo"] = "CENTER",
			["xOffset"] = 0,
			["yOffset"] = -4,
			["level"] = 0,
			["colors"] = {
				["raid"] = { r = 0.3, g = 0.6, b = 0.9 },
				["party"] = { r = 0.6, g = 0.9, b = 0.3 },
				["guild"] = { r = 0.9, g = 0.6, b = 0.3 },
				["none"] = { r = 0.6, g = 0.6, b = 0.6 },
			},
		},
		["FRIENDLY_PLAYER"] = {
			["showAll"] = true,
			["showCity"] = false,
			["showBG"] = false,
			["showArena"] = false,
			["showInstance"] = false,
			["showWorld"] = false,
			["font"] = "Expressway",
			["fontSize"] = 11,
			["fontOutline"] = "OUTLINE",
			["separator"] = "ARROW",
			["point"] = "CENTER",
			["relativeTo"] = "CENTER",
			["xOffset"] = 0,
			["yOffset"] = -4,
			["level"] = 0,
			["colors"] = {
				["raid"] = { r = 0.3, g = 0.6, b = 0.9 },
				["party"] = { r = 0.6, g = 0.9, b = 0.3 },
				["guild"] = { r = 0.9, g = 0.6, b = 0.3 },
				["none"] = { r = 0.6, g = 0.6, b = 0.6 },
			},
		},
	},
}

function mod:LoadConfig(db)
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
						set = function(_, value)
							if isAwesome then
								db[selectedSubSection()].enabled = value
								self:Toggle(db)
							else
								for _, subSection in ipairs({'OccupationIcon', 'Titles', 'Guilds'}) do
									if db[subSection].enabled then
										db[selectedSubSection()].enabled = value
										self:Toggle(db)
										return
									end
								end
								db[selectedSubSection()].enabled = value
								E:StaticPopup_Show("PRIVATE_RL")
							end
						end,
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
							StaticPopupDialogs["PURGECHACHEDDATA"] = {
								text = L["Purge Cache"]..'?',
								button1 = YES,
								button2 = NO,
								OnAccept = function()
									if selectedSubSection() == 'OccupationIcon' then
										db.NPCOccupations_cache = {}
									else
										db.UnitTitle = {}
									end
									self:UpdateAllSettings(db)
									print(core.customColorBeta .. L["Cache purged."])
								end,
								timeout = 0,
								whileDead = true,
								hideOnEscape = true,
							}
							StaticPopup_Show("PURGECHACHEDDATA")
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
						min = -5, max = 50, step = 1
					},
				},
			},
			visibility = {
				order = 3,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return db.Guilds[selectedPlayerType()][info[#info]] end,
				set = function(info, value)
					local data = db.Guilds[selectedPlayerType()]
					data[info[#info]] = value
					local enabled = false
					for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
						if data[showType] then
							enabled = true
							break
						end
					end
					if not enabled then data['showAll'] = true end
					updateVisibilityState(db.Guilds, core:GetCurrentAreaType())
					self:UpdateAllSettings(db)
				end,
				disabled = function() return not db[selectedSubSection()].enabled end,
				hidden = function() return selectedSubSection() ~= 'Guilds' end,
				args = {
					showAll = {
						order = 1,
						type = "toggle",
						name = L["Show Everywhere"],
						desc = "",
						set = function(info, value)
							db.Guilds[selectedPlayerType()][info[#info]] = value
							if not value then
								for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
									db.Guilds[selectedPlayerType()][showType] = true
								end
							end
							updateVisibilityState(db.Guilds, core:GetCurrentAreaType())
							self:UpdateAllSettings(db)
						end,
					},
					showCity = {
						order = 2,
						type = "toggle",
						name = L["Show in Cities"],
						desc = "",
						hidden = function() return db.Guilds[selectedPlayerType()].showAll end,
					},
					showBG = {
						order = 3,
						type = "toggle",
						name = L["Show in Battlegrounds"],
						desc = "",
						hidden = function() return db.Guilds[selectedPlayerType()].showAll end,
					},
					showArena = {
						order = 4,
						type = "toggle",
						name = L["Show in Arenas"],
						desc = "",
						hidden = function() return db.Guilds[selectedPlayerType()].showAll end,
					},
					showInstance = {
						order = 5,
						type = "toggle",
						name = L["Show in Instances"],
						desc = "",
						hidden = function() return db.Guilds[selectedPlayerType()].showAll end,
					},
					showWorld = {
						order = 6,
						type = "toggle",
						name = L["Show in the World"],
						desc = "",
						hidden = function() return db.Guilds[selectedPlayerType()].showAll end,
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
						min = -5, max = 50, step = 1
					},
					modifier = {
						order = 8,
						type = "select",
						name = L["Modifier"],
						desc = L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."],
						get = function(info) return db.OccupationIcon[info[#info]] end,
						set = function(info, value) db.OccupationIcon[info[#info]] = value end,
						values = function()
							local modsList = {}
							for modifier, val in pairs(E.db.Extras.modifiers) do
								if modifier ~= 'ANY' then
									modsList[modifier] = val
								end
							end
							return modsList
						end,
					},
					backdrop = {
						order = 9,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
					},
					addOccupation = {
						order = 10,
						type = "input",
						name = L["/addOccupation"],
						desc = L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."],
						get = function() return "/addOccupation" end,
					},
					removeOccupation = {
						order = 11,
						type = "select",
						width = "double",
						name = L["Remove a NPC"],
						desc = "",
						values = function()
							local list = {}
							for occupation, data in pairs(db.NPCOccupations_data) do
								for id, name in pairs(data) do
									list[id] = format("%s (%s)", name, occupation)
								end
							end
							return list
						end,
						set = function(_, value)
							for _, data in pairs(db.NPCOccupations_data) do
								for id, name in pairs(data) do
									if id == value then
										data[id] = nil
										db.NPCOccupations_cache[name] = nil
										self:UpdateAllSettings(db)
										return
									end
								end
							end
						end,
					},
					changeNPCOccupation = {
						order = 12,
						type = "select",
						width = "double",
						name = L["Change a NPC's Occupation"],
						desc = L["...to the currently selected one."],
						values = function()
							local list = {}
							for occupation, data in pairs(db.NPCOccupations_data) do
								for id, name in pairs(data) do
									list[id] = format("%s (%s)", name, occupation)
								end
							end
							return list
						end,
						get = function() return "" end,
						set = function(_, value)
							local occupation = db[selectedSubSection()].selectedOccupation
							for oc, data in pairs(db.NPCOccupations_data) do
								if oc ~= occupation then
									for id, name in pairs(data) do
										if id == value then
											data[id] = nil
											db.NPCOccupations_data[occupation][id] = name
											db.NPCOccupations_cache[name] = occupation
											self:UpdateAllSettings(db)
											return
										end
									end
								end
							end
						end,
					},
					selectedOccupation = {
						order = 13,
						type = "select",
						width = "double",
						name = L["Select Occupation"],
						desc = "",
						values = function()
							local list = {}
							for occupation in pairs(db.NPCOccupations_data) do
								list[occupation] = occupation
							end
							return list
						end,
						set = function(_, value) db[selectedSubSection()].selectedOccupation = value end,
					},
					dataTexMap = {
						order = 14,
						type = "input",
						width = "double",
						name = L["Texture"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
						get = function() return db.OccupationIcon.dataTexMap[db[selectedSubSection()].selectedOccupation] end,
						set = function(_, value)
							local occupation = db[selectedSubSection()].selectedOccupation
							db.OccupationIcon.dataTexMap[occupation] = value == "" and dataTexMapDefaults[occupation] or value
							NP:ConfigureAll()
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
						min = -5, max = 50, step = 1
					},
				},
			},
		},
	}
end


local function updateAllVisiblePlates(db)
	if isAwesome then
		for frame in pairs(NP.VisiblePlates) do
			if frame.unit and frame.Title then
				frame.Title:Hide()
				frame.OccupationIcon:Hide()
				mod:AwesomeUpdateUnitInfo(frame, db, frame.unit)
			end
		end
	else
		for frame in pairs(NP.VisiblePlates) do
			if frame.Title then
				frame.Title:Hide()
				frame.OccupationIcon:Hide()
				mod:UpdateTitle(frame, db, nil, nil, frame.UnitName)
			end
		end
	end
end

local function constructTitle(frame)
	if frame.Title then return end
	frame.Title = CreateFrame('Frame', '$parentTitle', frame)
	frame.Title.str = frame.Title:CreateFontString(nil, "OVERLAY")
	frame.Title.str:SetWordWrap(false)
	frame.Title.str:SetAllPoints(frame.Title)
	frame.OccupationIcon = CreateFrame('Frame', '$parentOccupationIcon', frame)
	frame.OccupationIcon.icon = frame.OccupationIcon:CreateTexture('$parentOccupationIcon', "OVERLAY")
	frame.OccupationIcon.icon:SetAllPoints(frame.OccupationIcon)
end

local function manageTitleFrame(frame, title, db, db_icon)
	local health = frame.Health
	if db then
		title.str:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
		title:Height(db.fontSize)
		title:ClearAllPoints()
		title:Point(db.point, health:IsShown() and health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
		title:SetFrameLevel(frame.Health:GetFrameLevel() + db.level)
	end
	if db_icon then
		local occupationIcon = frame.OccupationIcon
		local level = frame.Health:GetFrameLevel() + db_icon.level

		occupationIcon:ClearAllPoints()
		occupationIcon:Size(db_icon.size)
		occupationIcon:Point(db_icon.point,
							db_icon.anchor ~= "FRAME" and title or (health:IsShown() and health) or frame.Name,
							db_icon.relativeTo, db_icon.xOffset, db_icon.yOffset)
		occupationIcon:SetFrameLevel(level)

		if db_icon.backdrop then
			if not occupationIcon.backdrop then
				occupationIcon:CreateBackdrop("Transparent")
			end
			occupationIcon.backdrop:SetFrameLevel(level)
			occupationIcon.backdrop:Show()
		elseif occupationIcon.backdrop then
			occupationIcon.backdrop:Hide()
		end
	end
end


function mod:UpdateTitle(frame, db, unit, unitTitle, name)
	name = name or frame.UnitName
	unit = unit or name
	unitTitle = unitTitle or db.UnitTitle[name]

	if not unit or not name or not unitTitle then return end

	local title, unitType = frame.Title, frame.UnitType

	if unitType == 'FRIENDLY_NPC' or unitType == 'ENEMY_NPC' then
		if db.Titles.enabled then
			if not isAwesome and db.UnitTitle[name] ~= unitTitle then
				db.UnitTitle[name] = unitTitle
			end
			if db.OccupationIcon.enabled and unitType == 'FRIENDLY_NPC' then
				manageTitleFrame(frame, title, db.Titles[unitType], db.OccupationIcon)
				self:UpdateOccupation(frame.OccupationIcon, db, unit, name)
			else
				manageTitleFrame(frame, title, db.Titles[unitType])
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
		elseif db.OccupationIcon.enabled and unitType == 'FRIENDLY_NPC' then
			manageTitleFrame(frame, title, nil, db.OccupationIcon)
			self:UpdateOccupation(frame.OccupationIcon, db, unit, name)
		end
	elseif db.Guilds.enabled and (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
		db = db.Guilds[unitType]

		if db.isShown then
			manageTitleFrame(frame, title, db)

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
		end
	end
end

function mod:AwesomeUpdateUnitInfo(frame, db, unit)
	if UnitIsPlayer(unit) then
		local name, realm = UnitName(unit)
		if realm or not name or name == UNKNOWN then return end

		scanner:ClearLines()
		scanner:SetUnit(unit)

		local guildName = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText() or GetGuildInfo(unit)
		if not guildName or find(gsub(guildName, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_CLASS, 1, true) then
			return
		end

		self:UpdateTitle(frame, db, unit, guildName, name)
	elseif not UnitPlayerControlled(unit) then
		scanner:ClearLines()
		scanner:SetUnit(unit)

		local name = _G["ExtrasGT_ScanningTooltipTextLeft1"]:GetText()
		if not name then return end
		local description = _G["ExtrasGT_ScanningTooltipTextLeft2"]:GetText()
		if description then
			local cleanDesc = gsub(description, "[%s%d%p]+", "")
			if find(cleanDesc, TOOLTIP_UNIT_LEVEL, 1, true) or find(cleanDesc, TOOLTIP_UNIT_LEVEL_CLASS, 1, true) then
				if db.OccupationIcon.enabled and frame.UnitType == 'FRIENDLY_NPC' then
					manageTitleFrame(frame, frame.Title, nil, db.OccupationIcon)
					self:UpdateOccupation(frame.OccupationIcon, db, unit, name)
				end
				return
			end
		else
			if db.OccupationIcon.enabled and frame.UnitType == 'FRIENDLY_NPC' then
				manageTitleFrame(frame, frame.Title, nil, db.OccupationIcon)
				self:UpdateOccupation(frame.OccupationIcon, db, unit, name)
			end
			return
		end

		name = gsub(gsub((name), "|c........", ""), "|r", "")
		if name ~= UnitName(unit) then return end

		self:UpdateTitle(frame, db, unit, description, name)
	end
end

function mod:UpdateOccupation(occupationIcon, db, unit, name)
	if not isAwesome then
		local cachedOccupation = NPCOccupations_cache[name]
		if cachedOccupation then
			occupationIcon.icon:SetTexture(dataTexMap[cachedOccupation])
			occupationIcon:Show()
			return
		else
			local guid = unit and UnitGUID(unit)
			if guid then
				local npcId = tonumber(sub(guid, -10, -7), 16)
				for occupation, entries in pairs(NPCOccupations_data) do
					if entries[npcId] then
						occupationIcon.icon:SetTexture(dataTexMap[occupation])
						occupationIcon:Show()
						if not db.NPCOccupations_cache[name] then
							db.NPCOccupations_cache[name] = occupation
							NPCOccupations_cache[name] = occupation
						end
						return
					end
				end
			end
		end
	else
		local guid = unit and UnitGUID(unit)
		if guid then
			local npcId = tonumber(sub(guid, -10, -7), 16)
			for occupation, entries in pairs(NPCOccupations_data) do
				if entries[npcId] then
					occupationIcon.icon:SetTexture(dataTexMap[occupation])
					occupationIcon:Show()
					return
				end
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
		if not guildName or find(gsub(guildName, "[%s%d%p]+", ""), TOOLTIP_UNIT_LEVEL_CLASS, 1, true) then
			if db.UnitTitle[name] then
				db.UnitTitle[name] = nil
			end
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
		if description then
			local cleanDesc = gsub(description, "[%s%d%p]+", "")
			if find(cleanDesc, TOOLTIP_UNIT_LEVEL, 1, true) or find(cleanDesc, TOOLTIP_UNIT_LEVEL_CLASS, 1, true) then
				if db.OccupationIcon.enabled and frame.UnitType == 'FRIENDLY_NPC' then
					manageTitleFrame(frame, frame.Title, nil, db.OccupationIcon)
					self:UpdateOccupation(frame.OccupationIcon, db, unit, name)
				end
				return
			end
		else
			if db.OccupationIcon.enabled and frame.UnitType == 'FRIENDLY_NPC' then
				manageTitleFrame(frame, frame.Title, nil, db.OccupationIcon)
				self:UpdateOccupation(frame.OccupationIcon, db, unit, name)
			end
			return
		end

		name = gsub(gsub((name), "|c........", ""), "|r", "")
		if name ~= UnitName(unit) then return end

		self:UpdateTitle(frame, db, unit, description, name)
	end
end

function mod:UpdateAllSettings(db)
	if db.OccupationIcon.enabled then
		SLASH_ADDOCCUPATION1 = "/addOccupation"
		SlashCmdList["ADDOCCUPATION"] = function(msg) mod:addOccupation(msg) end
		twipe(NPCOccupations_data)
		twipe(NPCOccupations_cache)
		dataTexMap = db.OccupationIcon.dataTexMap
		local all = db.OccupationIcon.types["All"]
		for occupation, data in pairs(core.NPCOccupations_data or {}) do
			if all or db.OccupationIcon.types[occupation] then
				NPCOccupations_data[occupation] = {}
				local occupation_data = NPCOccupations_data[occupation]
				for id in pairs(data) do
					occupation_data[id] = true
				end
			end
		end
		for occupation, data in pairs(db.NPCOccupations_data) do
			if all or db.OccupationIcon.types[occupation] then
				NPCOccupations_data[occupation] = NPCOccupations_data[occupation] or {}
				local occupation_data = NPCOccupations_data[occupation]
				for id in pairs(data) do
					occupation_data[id] = true
				end
			end
		end
		for name, occupation in pairs(db.NPCOccupations_cache) do
			if all or db.OccupationIcon.types[occupation] then
				NPCOccupations_cache[name] = occupation
			end
		end
		if db.OccupationIcon.anchor == "FRAME" then
			core:RegisterNPElement('OccupationIcon', function(unitType, frame, element)
				if frame.OccupationIcon and (unitType == 'FRIENDLY_NPC' or unitType == 'ENEMY_NPC') then
					local points = db.OccupationIcon
					frame.OccupationIcon:ClearAllPoints()
					frame.OccupationIcon:Point(points.point, element, points.relativeTo, points.xOffset, points.yOffset)
				end
			end)
		else
			core:RegisterNPElement('OccupationIcon')
		end
	else
		core:RegisterNPElement('OccupationIcon')
	end
	for plate in pairs(NP.CreatedPlates) do
		local frame = plate and plate.UnitFrame
		if frame then
			if frame.Title then frame.Title:Hide() end
			if frame.OccupationIcon then frame.OccupationIcon:Hide() end
		end
	end
	if not core.reload then
		updateAllVisiblePlates(db)
	end
end

function mod:addOccupation()
	local db = E.db.Extras.nameplates[modName]
	for _, unit in ipairs({'mouseover', 'target'}) do
		if not UnitIsPlayer(unit) and not UnitCanAttack('player', unit) then
			local guid = UnitGUID(unit)
			local npcId = guid and tonumber(sub(guid, -10, -7), 16)
			if npcId then
				local name = UnitName(unit)
				if _G['Is'..db.OccupationIcon.modifier..'KeyDown']() then
					for occupation, entries in pairs(NPCOccupations_data) do
						if entries[npcId] then
							entries[npcId] = nil
							db.NPCOccupations_data[occupation][npcId] = nil
							db.NPCOccupations_cache[name] = nil
							NPCOccupations_cache[name] = nil
							NP:ConfigureAll()
							if E.RefreshGUI then E:RefreshGUI() end
							return
						end
					end
				end
				for _, entries in pairs(core.NPCOccupations_data or {}) do
					if entries[npcId] then
						return
					end
				end
				local foundOccupation
				local order = {}
				for occupation, entries in pairs(db.NPCOccupations_data) do
					if not foundOccupation and entries[npcId] then
						entries[npcId] = nil
						NPCOccupations_data[occupation][npcId] = nil
						NPCOccupations_cache[name] = nil
						db.NPCOccupations_cache[name] = nil
						foundOccupation = occupation
					end
					tinsert(order, occupation)
				end
				if foundOccupation then
					tsort(order)
					for i, occupation in ipairs(order) do
						if occupation == foundOccupation then
							local newOccupation = order[i % #order+1]
							NPCOccupations_data[newOccupation][npcId] = name
							db.NPCOccupations_data[newOccupation][npcId] = name
							NPCOccupations_cache[name] = newOccupation
							db.NPCOccupations_cache[name] = newOccupation
							break
						end
					end
				else
					NPCOccupations_data[MERCHANT][npcId] = name
					db.NPCOccupations_data[MERCHANT][npcId] = name
					NPCOccupations_cache[name] = MERCHANT
					db.NPCOccupations_cache[name] = MERCHANT
				end
				NP:ConfigureAll()
				if E.RefreshGUI then E:RefreshGUI() end
				return
			end
		end
	end
end

function mod:AwesomeOnEvent(db, unit)
	if UnitIsPlayer(unit) and UnitReaction(unit, "player") ~= 2 then
		local plate = GetNamePlateForUnit(unit)
		local frame = plate and plate.UnitFrame
		if frame then
			local title = frame.Title
			if not title:IsShown() then
				local guildName = GetGuildInfo(unit)
				if guildName then
					db = db.Guilds[frame.UnitType]

					if db and db.isShown then
						manageTitleFrame(frame, title, db)

						local color
						if UnitInRaid(unit) then
							color = db.colors.raid
						elseif UnitInParty(unit) then
							color = db.colors.party
						elseif GetGuildInfo("player") == guildName then
							color = db.colors.guild
						else
							color = db.colors.none
						end

						title.str:SetTextColor(color.r, color.g, color.b)
						title.str:SetFormattedText(separatorMap[db.separator], guildName)
						title:Width(title.str:GetStringWidth())

						title:Show()
					end
				end
			end
		end
	end
end

function mod:OnEvent(db, unit)
	local name = UnitName(unit)
	if name then
		for frame in pairs(NP.VisiblePlates) do
			if frame.UnitName == name then
				self:UpdateUnitInfo(frame, db, unit)
			end
		end
	end
end


function mod:Toggle(db)
	if core.reload or (not db.Guilds.enabled and not db.Titles.enabled and not db.OccupationIcon.enabled) then
		if self.initialized then
			if not db.Guilds.enabled and not db.Titles.enabled then
				core:RegisterNPElement('Title')
			end
			if not db.OccupationIcon.enabled then
				core:RegisterNPElement('OccupationIcon')
			end
			if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
			if self:IsHooked(NP, "Update_Name") then self:Unhook(NP, "Update_Name") end
			if self:IsHooked(NP, "OnCreated") then self:Unhook(NP, "OnCreated") end
			SLASH_ADDOCCUPATION1 = nil
			SlashCmdList["ADDOCCUPATION"] = nil
			hash_SlashCmdList["/ADDOCCUPATION"] = nil
			self:UnregisterAllEvents()
			core:RegisterAreaUpdate(modName)
			self:UpdateAllSettings(db)
		end
	else
		if db.Guilds.enabled or db.Titles.enabled then
			core:RegisterNPElement('Title', function(unitType, frame, element)
				if frame.Title then
					local points = db.Titles[unitType] or db.Guilds[unitType]
					frame.Title:ClearAllPoints()
					frame.Title:Point(points.point, element, points.relativeTo, points.xOffset, points.yOffset)
				end
			end)
			core:RegisterAreaUpdate(modName, function()
				if db.Guilds.enabled then
					updateVisibilityState(db.Guilds, core:GetCurrentAreaType())
					updateAllVisiblePlates(db)
				end
				scanner:SetOwner(WorldFrame, "ANCHOR_NONE")
			end)
		end
		if db.Guilds.enabled then
			self:RegisterEvent("PARTY_MEMBERS_CHANGED", function() updateAllVisiblePlates(db) end)
			self:RegisterEvent("GUILD_ROSTER_UPDATE", function() updateAllVisiblePlates(db) end)
			self:RegisterEvent("RAID_ROSTER_UPDATE", function() updateAllVisiblePlates(db) end)
			if isAwesome then
				self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function() self:AwesomeOnEvent(db, 'mouseover') end)
				self:RegisterEvent("PLAYER_TARGET_CHANGED", function() self:AwesomeOnEvent(db, 'target') end)
				self:RegisterEvent("PLAYER_FOCUS_CHANGED", function() self:AwesomeOnEvent(db, 'focus') end)
			end
			updateVisibilityState(db.Guilds, core:GetCurrentAreaType())
		else
			self:UnregisterEvent("PARTY_MEMBERS_CHANGED")
			self:UnregisterEvent("GUILD_ROSTER_UPDATE")
			self:UnregisterEvent("RAID_ROSTER_UPDATE")
			if isAwesome then
				self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
				self:UnregisterEvent("PLAYER_TARGET_CHANGED")
				self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			end
		end
		if isAwesome then
			if not self:IsHooked(NP, "OnCreated") then
				self:SecureHook(NP, "OnCreated", function(self, plate)
					constructTitle(plate.UnitFrame)
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
			self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function() self:OnEvent(db, 'mouseover') end)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", function() self:OnEvent(db, 'target') end)
			self:RegisterEvent("PLAYER_FOCUS_CHANGED", function() self:OnEvent(db, 'focus') end)
			if not self:IsHooked(NP, "OnCreated") then
				self:SecureHook(NP, "OnCreated", function(self, plate)
					local frame = plate.UnitFrame
					constructTitle(frame)
					frame.Title:Hide()
					frame.OccupationIcon:Hide()
					mod:UpdateTitle(frame, db, nil, nil, frame.UnitName)
				end)
			end
			if not self:IsHooked(NP, "OnShow") then
				self:SecureHook(NP, "OnShow", function(self)
					local frame = self.UnitFrame
					if frame and frame.Title then
						frame.Title:Hide()
						frame.OccupationIcon:Hide()
						mod:UpdateTitle(frame, db, nil, nil, frame.UnitName)
					end
				end)
			end
		end
		for plate in pairs(NP.CreatedPlates) do
			local frame = plate and plate.UnitFrame
			if frame then
				constructTitle(frame)
			end
		end
		self:UpdateAllSettings(db)
		self.initialized = true
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback