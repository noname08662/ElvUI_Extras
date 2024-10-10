local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("FCF", "AceHook-3.0")
local ElvUF = E.oUF
local LSM = E.Libs.LSM

local modName = mod:GetName()

local pairs, ipairs, loadstring, pcall, type, tonumber, select, unpack = pairs, ipairs, loadstring, pcall, type, tonumber, select, unpack
local random = math.random
local find, gsub, match, format = string.find, string.gsub, string.match, string.format
local tsort, tinsert = table.sort, table.insert
local GetSpellInfo, GetSpellLink, CopyTable = GetSpellInfo, GetSpellLink, CopyTable
local SCHOOL_MASK_NONE, SCHOOL_MASK_PHYSICAL, SCHOOL_MASK_HOLY, SCHOOL_MASK_FIRE,
	SCHOOL_MASK_NATURE, SCHOOL_MASK_FROST, SCHOOL_MASK_SHADOW, SCHOOL_MASK_ARCANE =
		SCHOOL_MASK_NONE, SCHOOL_MASK_PHYSICAL, SCHOOL_MASK_HOLY, SCHOOL_MASK_FIRE,
		SCHOOL_MASK_NATURE, SCHOOL_MASK_FROST, SCHOOL_MASK_SHADOW, SCHOOL_MASK_ARCANE

local function tagFunc(frame)
	if frame.FloatingCombatFeedback then
		ElvUF.uaeHook(frame)
	end
end


local testing = false
local testindex = 1
local playerGUID = E.myguid or UnitGUID("player")

local testEvents = {
    ["WOUND"] = {
        "SWING_DAMAGE",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        function()
			local val = random()
            return {
                random(500, 2000),     				-- amount
                random(0, 500),       				-- overkill
                1,                     				-- school (physical)
                val < 0.5 and random(100, 500),		-- resisted
                val < 0.25 and random(100, 500),	-- blocked
                val > 0.75 and random(100, 500),	-- absorbed
                val > 0.5,							-- critical
                val > 0.25 and val < 0.5,			-- glancing
                val < 0.75 and val > 0.5			-- crushing
            }
        end
    },
	["ABSORB"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "ABSORB"
    },
	["BLOCK"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "BLOCK"
    },
    ["DEFLECT"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "DEFLECT"
    },
    ["DODGE"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "DODGE"
    },
    ["EVADE"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "EVADE"
    },
    ["IMMUNE"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "IMMUNE"
    },
    ["MISS"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "MISS"
    },
    ["PARRY"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "PARRY"
    },
    ["REFLECT"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "REFLECT"
    },
    ["RESIST"] = {
        "SPELL_MISSED",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        48127, "Mind Blast", 0x20,
        "RESIST"
    },
    ["HEAL"] = {
        "SPELL_HEAL",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x511,
        48089, "Circle of Healing", 0x1,
        function()
            return {
                random(3000, 6000),                    -- amount
                random(0, 1000),                       -- overhealing
                random() < 0.2 and random(100, 500),   -- absorbed
                random() < 0.3 and 1                   -- critical
            }
        end
    },
    ["ENERGIZE"] = {
        "SPELL_ENERGIZE",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x511,
        57669, "Replenishment", 0x1,
        random(1000, 2000),    -- amount
        0,                     -- overEnergize
        0                      -- powerType (0 = mana)
    },
    ["DEBUFF"] = {
		{
			"SPELL_AURA_APPLIED",
			playerGUID, "Player", 0x511,
			playerGUID, "Player", 0x10a48,
			48300, "Devouring Plague", 0x20,
			"DEBUFF"
		},
		{
			"SPELL_AURA_REMOVED",
			playerGUID, "Player", 0x511,
			playerGUID, "Player", 0x10a48,
			48300, "Devouring Plague", 0x20,
			"DEBUFF"
		},
	},
	["BUFF"] = {
		{
			"SPELL_AURA_APPLIED",
			playerGUID, "Player", 0x511,
			playerGUID, "Player", 0x511,
			48168, "Inner Fire", 0x1,
			"BUFF"
		},
		{
			"SPELL_AURA_REMOVED",
			playerGUID, "Player", 0x511,
			playerGUID, "Player", 0x511,
			48168, "Inner Fire", 0x1,
			"BUFF"
		},
	},
    ["INTERRUPT"] = {
        "SPELL_INTERRUPT",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        1766, "Kick", 1,
        48071, "Flash Heal", 0x1
    }
}

local function testMode(db)
	E:Delay(db.scrollTime+0.1, function()
		if not testing or not ElvUF.CLEUDispatcher then return end

		local events = {}
		for event, info in pairs(testEvents) do
			if not db.events[event].disabled then
				if event == "BUFF" or event == "DEBUFF" then
					for _, data in ipairs(info) do
						tinsert(events, data)
					end
				else
					tinsert(events, info)
				end
			end
		end

		local count = #events
		if count == 0 then testing = false return end

		local eventData = events[testindex] or events[1]
        local processedEventData = {}

        for i, v in ipairs(eventData) do
            if type(v) ~= "function" then
                processedEventData[i] = v
            end
        end

        for i, v in ipairs(eventData) do
            if type(v) == "function" then
                local dynamicValues = v()
                for j, dv in ipairs(dynamicValues) do
                    processedEventData[i + j - 1] = dv
                end
            end
        end

		ElvUF.CLEUDispatcher:GetScript("OnEvent")(ElvUF.CLEUDispatcher, nil, nil, unpack(processedEventData))
		testindex = testindex % count + 1
		testMode(db)
	end)
end


P["Extras"]["unitframes"][modName] = {
	["selectedUnit"] = "player",
	["selectedEvent"] = "WOUND",
	["selectedSchool"] = SCHOOL_MASK_PHYSICAL,
	["selectedFlag"] = "CRITICAL",
	["animations"] = {
		["diagonal"] = { ["name"] = L["Diagonal"] },
		["fountain"] = { ["name"] = L["Fountain"] },
		["horizontal"] = { ["name"] = L["Horizontal"] },
		["random"] = { ["name"] = L["Random"] },
		["static"] = { ["name"] = L["Static"] },
		["vertical"] = { ["name"] = L["Vertical"] },
	},
	["units"] = {
		["player"] = {
			["enabled"] = false,
			["animation"] = "fountain",
			["font"] = "Expressway",
			["fontSize"] = 18,
			["fontFlags"] = "",
			["textPoint"] = 'BOTTOM',
			["textRelativeTo"] = 'TOP',
			["textLevel"] = 85,
			["textStrata"] = 'LOW',
			["textX"] = 0,
			["textY"] = 24,
			["scrollTime"] = 1.2,
			["fadeTime"] = 3,
			["showIcon"] = false,
			["iconPosition"] = "before",
			["blacklist"] = {},
			["events"] = {
				["ABSORB"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["BLOCK"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["DEFLECT"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["DODGE"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["ENERGIZE"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {105, 204, 240}, ["tryToColorBySchool"] = false },
				["EVADE"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["HEAL"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {26, 204, 26}, ["tryToColorBySchool"] = false },
				["IMMUNE"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["INTERRUPT"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["MISS"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["PARRY"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["REFLECT"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["RESIST"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["WOUND"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {179, 26, 26}, ["tryToColorBySchool"] = false },
				["DEBUFF"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
				["BUFF"] = { ["disabled"] = false, ["customAnimation"] = '', ["animation"] = 'fountain', ["colors"] = {255, 255, 255}, ["tryToColorBySchool"] = false },
			},
			["school"] = {
				[SCHOOL_MASK_ARCANE] = {255, 128, 255},
				[SCHOOL_MASK_FIRE] = {255, 128, 000},
				[SCHOOL_MASK_FROST] = {128, 255, 255},
				[SCHOOL_MASK_HOLY] = {255, 230, 128},
				[SCHOOL_MASK_NATURE] = {77, 255, 77},
				[SCHOOL_MASK_NONE] = {255, 255, 255},
				[SCHOOL_MASK_PHYSICAL] = {179, 26, 26},
				[SCHOOL_MASK_SHADOW] = {128, 128, 255},
				-- multi-schools
				[72] = {166, 192, 166}, -- SCHOOL_MASK_ASTRAL
				[127] = {182, 164, 142}, -- SCHOOL_MASK_CHAOS
				[28] = {153, 212, 111}, -- SCHOOL_MASK_ELEMENTAL
				[126] = {183, 187, 162}, -- SCHOOL_MASK_MAGIC
				[40] = {103, 192, 166}, -- SCHOOL_MASK_PLAGUE
				[6] = {255, 178, 64}, -- SCHOOL_MASK_RADIANT
				[36] = {192, 128, 128}, -- SCHOOL_MASK_SHADOWFLAME
				[48] = {128, 192, 255}, -- SCHOOL_MASK_SHADOWFROST
			},
			["flags"] = {
				["ABSORB"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["BLOCK"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["CRITICAL"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 1.25 },
				["CRUSHING"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 1.25 },
				["GLANCING"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["RESIST"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
			},
		},
	},
}

function mod:LoadConfig()
	local db = E.db.Extras.unitframes[modName]
	local function selectedUnit() return db.selectedUnit end
	local function selectedEvent() return db.selectedEvent end
	local function selectedFlag() return db.selectedFlag end
	local function selectedUnitData()
		return core:getSelected("unitframes", modName, format("units[%s]", selectedUnit() or ""), "player")
	end
	local function selectedEventData()
		return core:getSelected("unitframes", modName, format("units.%s.events[%s]", selectedUnit(), selectedEvent() or ""), "WOUND")
	end
	local function selectedFlagData()
		return core:getSelected("unitframes", modName, format("units.%s.flags[%s]", selectedUnit(), selectedFlag() or ""), "CRITICAL")
	end
	core.unitframes.args[modName] = {
		type = "group",
		name = modName,
		args = {
			FCF = {
				order = 1,
				type = "group",
				name = L["Floating Combat Feedback"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "full",
						name = core.pluginColor..L["Enable"],
						desc = L["Appends floating combat feedback fontstrings to frames."],
						get = function() return selectedUnitData().enabled end,
						set = function(_, value) selectedUnitData().enabled = value self:Toggle() end,
					},
					unitDropdown = {
						order = 2,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function() return db.selectedUnit end,
						set = function(_, value) db.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(db.units) end,
					},
					copySettings = {
						order = 3,
						type = "select",
						name = L["Copy Unit Settings"],
						desc = "",
						get = function() return "" end,
						set = function(info, value)
							if value then
								local values = info.option.values()
								for index, entry in pairs(values) do
									if index == value then
										db.units[selectedUnit()] = CopyTable(db.units[entry])
										break
									end
								end
							end
						end,
						values = function()
							local list = {}
							for unit in pairs(db.units) do
								if unit ~= selectedUnit() then tinsert(list, L[unit]) end
							end
							return list
						end,
					},
					playerOnly = {
						order = 3,
						type = "toggle",
						name = L["Player Only"],
						desc = L["Handle only player combat log events."],
						get = function() return selectedUnitData().playerOnly end,
						set = function(_, value) selectedUnitData().playerOnly = value self:Toggle() end,
						hidden = function()
							local unit = selectedUnit()
							return find(unit, 'pet') and not find(unit, 'target')
								or unit == 'boss' or unit == 'arena'
						end,
					},
					testMode = {
						order = 4,
						type = "execute",
						name = L["Test Mode"],
						desc = "",
						func = function() testMode(selectedUnitData()) testing = not testing end,
					},
				},
			},
			fontSettings = {
				order = 2,
				type = "group",
				name = L["Font Settings"],
				inline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle() end,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					font = {
						order = 1,
						type = "select",
						name = L["Font"],
						desc = "",
						dialogControl = "LSM30_Font",
						values = function() return AceGUIWidgetLSMlists.font end,
					},
					fontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						desc = L["There seems to be a font size limit?"],
						min = 10, max = 25, step = 1,
					},
					fontFlags = {
						order = 3,
						type = "select",
						name = L["Font Flags"],
						desc = "",
						values = {
							[""] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["THINOUTLINE"] = "THINOUTLINE",
							["MONOCHROME"] = "MONOCHROME",
						},
					},
					scrollTime = {
						order = 4,
						type = "range",
						name = L["Scroll Time"],
						desc = "",
						min = 0.6, max = 6, step = 0.1,
					},
					--[[
					fadeTime = {
						order = 5,
						type = "range",
						name = L["Fade Time"],
						desc = "",
						min = 0.1, max = 3, step = 0.1,
						get = function(info)
					},
					]]--
					textPoint = {
						order = 6,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					textRelativeTo = {
						order = 7,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					textLevel = {
						order = 8,
						type = "range",
						name = L["Level"],
						desc = "",
						min = 1, max = 200, step = 1
					},
					textStrata = {
						order = 9,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
					},
					textX = {
						order = 10,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -80, max = 80, step = 1,
					},
					textY = {
						order = 11,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -80, max = 80, step = 1,
					},
				},
			},
			events = {
				order = 3,
				type = "group",
				name = L["Event Settings"],
				inline = true,
				get = function(info) return selectedEventData()[info[#info]] end,
				set = function(info, value) selectedEventData()[info[#info]] = value self:Toggle() end,
				disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled end,
				args = {
					event = {
						order = 1,
						type = "select",
						name = L["Event"],
						desc = "",
						disabled = false,
						get = function() return selectedEvent() end,
						set = function(_, value) db.selectedEvent = value end,
						values = {
							["ABSORB"] = L["ABSORB"],
							["BLOCK"] = L["BLOCK"],
							["DEFLECT"] = L["DEFLECT"],
							["DODGE"] = L["DODGE"],
							["ENERGIZE"] = L["ENERGIZE"],
							["EVADE"] = L["EVADE"],
							["HEAL"] = L["HEAL"],
							["IMMUNE"] = L["IMMUNE"],
							["INTERRUPT"] = L["INTERRUPT"],
							["MISS"] = L["MISS"],
							["PARRY"] = L["PARRY"],
							["REFLECT"] = L["REFLECT"],
							["RESIST"] = L["RESIST"],
							["WOUND"] = L["WOUND"],
							["DEBUFF"] = L["Debuff applied/faded/refreshed"],
							["BUFF"] = L["Buff applied/faded/refreshed"],
						},
					},
					disabled = {
						order = 2,
						type = "toggle",
						disabled = false,
						name = L["Disable Event"],
						desc = "",
					},
					school = {
						order = 3,
						type = "select",
						name = L["School"],
						desc = "",
						get = function() return db.selectedSchool end,
						set = function(_, value) db.selectedSchool = value end,
						values = {
							[SCHOOL_MASK_NONE] = L["None"],
							[SCHOOL_MASK_PHYSICAL] = L["Physical"],
							[SCHOOL_MASK_HOLY] = L["Holy"],
							[SCHOOL_MASK_FIRE] = L["Fire"],
							[SCHOOL_MASK_NATURE] = L["Nature"],
							[SCHOOL_MASK_FROST] = L["Frost"],
							[SCHOOL_MASK_SHADOW] = L["Shadow"],
							[SCHOOL_MASK_ARCANE] = L["Arcane"],
							[72] = L["Astral"],
							[127] = L["Chaos"],
							[28] = L["Elemental"],
							[126] = L["Magic"],
							[40] = L["Plague"],
							[6] = L["Radiant"],
							[36] = L["Shadowflame"],
							[48] = L["Shadowfrost"],
						},
					},
					tryToColorBySchool = {
						order = 4,
						type = "toggle",
						name = L["Use School Colors"],
						desc = L["Not every event is eligible for this. But some are."],
					},
					colors = {
						order = 5,
						type = "color",
						name = L["Colors"],
						desc = "",
						get = function() local color = selectedEventData().colors return color[1], color[2], color[3] end,
						set = function(_, r, g, b) selectedEventData().colors = {r, g, b} self:Toggle() end,
					},
					colorsSchool = {
						order = 6,
						type = "color",
						name = L["Colors (School)"],
						desc = "",
						get = function() local color = selectedUnitData().school[db.selectedSchool] return color[1], color[2], color[3] end,
						set = function(_, r, g, b) selectedUnitData().school[db.selectedSchool] = {r, g, b} self:Toggle() end,
					},
					animation = {
						order = 7,
						type = "select",
						width = "double",
						name = L["Animation Type"],
						desc = "",
						values = function()
							local animations = {}
							for animation, info in pairs(db.animations) do
								animations[animation] = info.name
							end
							return animations
						end,
					},
					customAnimation = {
						order = 8,
						type = "input",
						width = "double",
						multiline = true,
						name = L["Custom Animation"],
						desc = L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
								"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
								"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"],
					},
				},
			},
			flags = {
				order = 4,
				type = "group",
				name = L["Flag Settings"],
				inline = true,
				get = function(info) return selectedFlagData()[info[#info]] end,
				set = function(info, value) selectedFlagData()[info[#info]] = value self:Toggle() end,
				disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled end,
				args = {
					flag = {
						order = 1,
						type = "select",
						name = L["Flag"],
						desc = "",
						get = function() return db.selectedFlag end,
						set = function(_, value) db.selectedFlag = value end,
						values = {
							["ABSORB"  ] = L["ABSORB"],
							["BLOCK"   ] = L["BLOCK"],
							["CRITICAL"] = L["CRITICAL"],
							["CRUSHING"] = L["CRUSHING"],
							["GLANCING"] = L["GLANCING"],
							["RESIST"  ] = L["RESIST"],
						},
					},
					fontMult = {
						order = 2,
						type = "range",
						name = L["Font Size Multiplier"],
						desc = L["There seems to be a font size limit?"],
						min = 0, max = 3, step = 0.25,
					},
					animationsByFlag = {
						order = 3,
						type = "toggle",
						name = L["Animation by Flag"],
						desc = L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."],
					},
					animation = {
						order = 4,
						type = "select",
						name = L["Animation Type"],
						desc = "",
						values = function()
							local animations = {}
							for animation, info in pairs(db.animations) do
								animations[animation] = info.name
							end
							return animations
						end,
					},
					customAnimation = {
						order = 5,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Custom Animation"],
						desc = L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
								"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
								"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"],
					},
				},
			},
			iconSettings = {
				order = 5,
				type = "group",
				name = L["Icon Settings"],
				inline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle() end,
				disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled end,
				args = {
					showIcon = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Show Icon"],
						desc = "",
					},
					iconPosition = {
						order = 2,
						type = "select",
						name = L["Icon Position"],
						desc = "",
						values = {
							["before"] = L["Before Text"],
							["after"] = L["After Text"],
						},
						disabled = function()
							return not selectedUnitData().enabled or selectedEventData().disabled or not selectedUnitData().showIcon end,
					},
					iconBounce = {
						order = 3,
						type = "toggle",
						name = L["Bounce"],
						desc = L["Flip position left-right."],
						disabled = function()
							return not selectedUnitData().enabled or selectedEventData().disabled or not selectedUnitData().showIcon end,
					},
				},
			},
			blacklist = {
				order = 6,
				type = "group",
				name = L["Blacklist"],
				inline = true,
				args = {
					addSpell = {
						order = 1,
						type = "input",
						width = "double",
						name = L["Add Spell (by ID)"],
						desc = L["E.g. 42292"],
						get = function() return "" end,
						set = function(_, value)
							local spellID = match(value, '%D*(%d+)%D*')
							if spellID and GetSpellInfo(spellID) then
								selectedUnitData().blacklist[tonumber(spellID)] = true
								local _, _, icon = GetSpellInfo(spellID)
								local link = GetSpellLink(spellID)
								icon = gsub(icon, '\124', '\124\124')
								local string = '\124T' .. icon .. ':16:16\124t' .. link
								core:print('ADDED', string)
							end
							self:Toggle()
						end,
					},
					removeSpell = {
						order = 2,
						type = "select",
						width = "double",
						name = L["Remove Spell"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							for spellID in pairs(db.units[selectedUnit()].blacklist) do
								if spellID == value then
									selectedUnitData().blacklist[spellID] = nil
									local _, _, icon = GetSpellInfo(spellID)
									local link = GetSpellLink(spellID)
									icon = gsub(icon, '\124', '\124\124')
									local string = '\124T' .. icon .. ':16:16\124t' .. link
									core:print('REMOVED', string)
									break
								end
							end
							self:Toggle()
						end,
						values = function()
							local values = {}
							for id in pairs(db.units[selectedUnit()].blacklist) do
								local name = GetSpellInfo(id) or ""
								local icon = select(3, GetSpellInfo(id))
								icon = icon and "|T"..icon..":0|t" or ""
								values[id] = format("%s %s (%s)", icon, name, id)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {}
							for id in pairs(db.units[selectedUnit()].blacklist) do
								tinsert(sortedKeys, id)
							end
							tsort(sortedKeys, function(a, b)
								local nameA = GetSpellInfo(a) or ""
								local nameB = GetSpellInfo(b) or ""
								return nameA < nameB
							end)
							return sortedKeys
						end,
					},
				},
			},
		},
	}
	if not db.units.target then
		for _, unitframeType in ipairs({'target', 'focus', 'raid', 'raid40', 'party', 'arena'}) do
			db.units[unitframeType] = CopyTable(db.units.player)
		end
	end
end


function mod:CustomAnim(frame, customAnimation, event, flag)
	if find(customAnimation, '%S+') then
		local luaFunction, errorMsg = loadstring("return " .. customAnimation)

		if luaFunction then
			local success, customFunc = pcall(luaFunction)

			if not success then
				core:print('FAIL', "FCF", customFunc)
			else
				local fcf = frame.FloatingCombatFeedback

				if type(customFunc) == "function" then
					fcf.animations["animName"] = customFunc
					fcf.xOffsetsByAnimation["animName"] = 0
					fcf.yOffsetsByAnimation["animName"] = 0
					if event then
						fcf.animationsByEvent[event] = "animName"
					elseif flag then
						fcf.animationsByFlag[flag] = "animName"
					end
				else
					core:print('LUA', "FCF", L["Loaded custom animation did not return a function."])
				end
			end
		else
			core:print('LUA', "FCF", errorMsg)
		end
	end
end

function mod:ConstructFCF(frame, info)
	local fcf = frame.FloatingCombatFeedback
	if fcf then
		fcf:SetFrameStrata(info.textStrata)
		fcf:SetFrameLevel(info.textLevel)
		return
	end

	fcf = CreateFrame("Frame", nil, frame)
	fcf:SetFrameStrata(info.textStrata)
	fcf:SetFrameLevel(info.textLevel)
	fcf:Size(32, 32)
	fcf:SetPoint("CENTER")

	for i = 1, 6 do
		-- give names to these font strings to avoid breaking /fstack and /tinspect
		fcf[i] = fcf:CreateFontString("$parentFCFText" .. i, "OVERLAY")
	end

	frame.FloatingCombatFeedback = fcf

	core:Tag("fcf", tagFunc)
end

function mod:UpdateFCFSettings(frame)
	frame:DisableElement('FloatingCombatFeedback')

	local db = E.db.Extras.unitframes[modName]
	for unit, info in pairs(db.units) do
		if frame.unitframeType == unit then
			local fcf = frame.FloatingCombatFeedback
			if info.enabled then
				self:ConstructFCF(frame, info)
				fcf = frame.FloatingCombatFeedback
				fcf.useCLEU = true
				fcf:ClearAllPoints()
				fcf:Point(info.textPoint, frame, info.textRelativeTo, info.textX, info.textY)

				frame:EnableElement('FloatingCombatFeedback')

				fcf.font = LSM:Fetch("font", info.font)
				fcf.fontHeight = info.fontSize
				fcf.fontFlags = info.fontFlags
				fcf.scrollTime = info.scrollTime
				fcf.playerOnly = info.playerOnly
				--fcf.fadeTime = info.fadeTime

				fcf.format = info.showIcon and (info.iconPosition == 'before' and "|T%2$s:0:0:0:0:64:64:4:60:4:60|t %1$s" or "%1$s |T%2$s:0:0:0:0:64:64:4:60:4:60|t") or '%1$s'
				fcf.iconBounce = info.showIcon and info.iconBounce or false

				fcf.blacklist = CopyTable(info.blacklist)

				for event, info in pairs(info.events) do
					fcf.animationsByEvent[event] = not info.disabled and info.animation or false

					if info.tryToColorBySchool then
						fcf.tryToColorBySchool[event] = true
					else
						fcf.tryToColorBySchool[event] = false
						fcf.colors[event] = { r = info.colors[1], g = info.colors[2], b = info.colors[3] }
					end

					self:CustomAnim(frame, info.customAnimation, event)
				end
				for school, colors in pairs(info.school) do
					fcf.schoolColors[school] = { r = colors[1], g = colors[2], b = colors[3] }
				end
				for flag, info in pairs(info.flags) do
					fcf.multipliersByFlag[flag] = info.fontMult
					if info.animationsByFlag then
						fcf.animationsByFlag[flag] = info.animation
						self:CustomAnim(frame, info.customAnimation, nil, flag)
					elseif fcf then
						fcf.animationsByFlag[flag] = nil
					end
				end
			elseif fcf then
				core:Untag("fcf")
			end
		end
	end
end

local function manageFCF()
	local units = core:AggregateUnitFrames()
	for _, frame in ipairs(units) do
		mod:UpdateFCFSettings(frame)
	end
end


function mod:Toggle()
	manageFCF()
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	mod:LoadConfig()
	mod:Toggle()

	tinsert(core.frameUpdates, manageFCF)
end

core.modules[modName] = mod.InitializeCallback
