local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("FCFV2", "AceHook-3.0")
local ElvUF = E.oUF
local LSM = E.Libs.LSM

local modName = mod:GetName()

local pairs, ipairs, loadstring, pcall, type, tonumber, select, unpack = pairs, ipairs, loadstring, pcall, type, tonumber, select, unpack
local random = math.random
local find, gsub, match, format = string.find, string.gsub, string.match, string.format
local tsort, tinsert, twipe = table.sort, table.insert, table.wipe
local GetSpellInfo, GetSpellLink, CopyTable = GetSpellInfo, GetSpellLink, CopyTable
local SCHOOL_MASK_NONE, SCHOOL_MASK_PHYSICAL, SCHOOL_MASK_HOLY, SCHOOL_MASK_FIRE,
		SCHOOL_MASK_NATURE, SCHOOL_MASK_FROST, SCHOOL_MASK_SHADOW, SCHOOL_MASK_ARCANE =
			SCHOOL_MASK_NONE, SCHOOL_MASK_PHYSICAL, SCHOOL_MASK_HOLY, SCHOOL_MASK_FIRE,
			SCHOOL_MASK_NATURE, SCHOOL_MASK_FROST, SCHOOL_MASK_SHADOW, SCHOOL_MASK_ARCANE

mod.updatePending = false
mod.initialized = false


function mod:tagFunc(frame)
	if frame.FloatingCombatFeedback then
		ElvUF.uaeHook(frame)
	end
end


local testing = false
local testindex = 1
local playerGUID = E.myguid or UnitGUID("player")
local schools = { heal = {2,8,32}, wound = {1,2,4,8,16,32,64} }

local testEvents = {
    ["WOUND"] = {
        "SWING_DAMAGE",
        playerGUID, "Player", 0x511,
        playerGUID, "Player", 0x10a48,
        function()
			local val = random()
            return {
                random(500, 2000),     								-- amount
                random(0, 500),       								-- overkill
                schools.wound[random(1,#schools.wound)],			-- school (physical)
                val < 0.15 and random(100, 500),					-- resisted
                val > 0.85 and random(100, 500),					-- blocked
                (val > 0.70 and val < 0.85) and random(100, 500),	-- absorbed
                val > 0.50 and val < 0.70,							-- critical
                val > 0.15 and val < 0.30,							-- glancing
                val > 0.30 and val < 0.50							-- crushing
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
        48089, "Circle of Healing",
        function()
			local val = random(3000, 6000)
            return {
				schools.heal[random(1, 3)],				-- school
                val,									-- amount
                val,									-- amount
                random() < 0.2 and random(0, 1000),		-- overhealing
                random() < 0.3 and 1					-- critical
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
	E:Delay(db.scrollTime/3, function()
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
			["textLevel"] = 85,
			["textStrata"] = 'LOW',
			["scrollTime"] = 1.2,
			["fadeTime"] = 3,
			["blacklist"] = {},
			["events"] = {
				["ABSORB"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {217/255, 196/255, 92/255},
					["tryToColorBySchool"] = false
				},
				["BLOCK"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["DEFLECT"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["DODGE"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["ENERGIZE"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {105/255, 204/255, 240/255},
					["tryToColorBySchool"] = false
				},
				["EVADE"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["HEAL"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {26/255, 204/255, 26/255},
					["tryToColorBySchool"] = false
				},
				["IMMUNE"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["INTERRUPT"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["MISS"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["PARRY"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["REFLECT"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["RESIST"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["WOUND"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {199/255, 64/255, 64/255},
					["tryToColorBySchool"] = false
				},
				["DEBUFF"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
				["BUFF"] = {
					["disabled"] = false,
					["iconPosition"] = "before",
					["customAnimation"] = '',
					["animation"] = 'fountain',
					["color"] = {1, 1, 1},
					["tryToColorBySchool"] = false
				},
			},
			["school"] = {
				[SCHOOL_MASK_ARCANE] = {1, 128/255, 1},
				[SCHOOL_MASK_FIRE] = {1, 128/255, 0},
				[SCHOOL_MASK_FROST] = {128/255, 1, 1},
				[SCHOOL_MASK_HOLY] = {1, 230/255, 128/255},
				[SCHOOL_MASK_NATURE] = {77/255, 1, 77/255},
				[SCHOOL_MASK_NONE] = {1, 1, 1},
				[SCHOOL_MASK_PHYSICAL] = {179/255, 26/255, 26/255},
				[SCHOOL_MASK_SHADOW] = {128/255, 128/255, 1},
				-- multi-schools
				[72] = {166/255, 192/255, 166/255}, -- SCHOOL_MASK_ASTRAL
				[127] = {182/255, 164/255, 142/255}, -- SCHOOL_MASK_CHAOS
				[28] = {153/255, 212/255, 111/255}, -- SCHOOL_MASK_ELEMENTAL
				[126] = {183/255, 187/255, 162/255}, -- SCHOOL_MASK_MAGIC
				[40] = {103/255, 192/255, 166/255}, -- SCHOOL_MASK_PLAGUE
				[6] = {1, 178/255, 64/255}, -- SCHOOL_MASK_RADIANT
				[36] = {192/255, 128/255, 128/255}, -- SCHOOL_MASK_SHADOWFLAME
				[48] = {128/255, 192/255, 1}, -- SCHOOL_MASK_SHADOWFROST
			},
			["flags"] = {
				["ABSORB"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["BLOCK"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["CRITICAL"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 1.25 },
				["CRUSHING"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 1.25 },
				["GLANCING"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["RESIST"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["PERIODICWOUND"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["PERIODICHEAL"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["NOFLAGHEAL"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
				["NOFLAGWOUND"] = { ["customAnimation"] = '', ["animationsByFlag"] = false, ["animation"] = 'fountain', ["fontMult"] = 0.75 },
			},
		},
	},
}

function mod:LoadConfig(db)
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
		name = "FCF",
		args = {
			FCFV2 = {
				order = 1,
				type = "group",
				name = L["Floating Combat Feedback"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Appends floating combat feedback fontstrings to frames."],
						get = function() return selectedUnitData().enabled end,
						set = function(_, value) selectedUnitData().enabled = value self:Toggle(db) end,
					},
					testMode = {
						order = 2,
						type = "execute",
						name = L["Test Mode"],
						desc = "",
						func = function() testMode(selectedUnitData()) testing = not testing end,
					},
					unitDropdown = {
						order = 3,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function() return db.selectedUnit end,
						set = function(_, value) db.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(db.units) end,
					},
					copySettings = {
						order = 4,
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
				},
			},
			fontSettings = {
				order = 2,
				type = "group",
				name = L["Font Settings"],
				inline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value self:UpdateAll(db) end,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					abbreviateNumbers = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Abbreviate Numbers"],
						desc = "",
					},
					textLevel = {
						order = 2,
						type = "range",
						name = L["Level"],
						desc = "",
						min = 1, max = 200, step = 1
					},
					textStrata = {
						order = 3,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
					},
				},
			},
			events = {
				order = 3,
				type = "group",
				name = L["Event Settings"],
				inline = true,
				get = function(info) return selectedEventData()[info[#info]] end,
				set = function(info, value) selectedEventData()[info[#info]] = value self:UpdateAll(db) end,
				disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled end,
				args = {
					copyEvent = {
						order = 1,
						type = "select",
						name = L["Copy"],
						desc = "",
						set = function(_, value)
							local t = selectedUnitData().events[value]
							if t then
								selectedUnitData().events[selectedEvent()] = CopyTable(t)
								if value == 'WOUND' or value == 'HEAL' and (selectedEvent() ~= 'WOUND' and selectedEvent() ~= 'HEAL') then
									selectedEventData().tryToColorBySchool = false
								end
								self:UpdateAll(db)
							end
						end,
						values = function()
							local vals = {
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
							}
							vals[selectedEvent()] = nil
							return vals
						end,
					},
					event = {
						order = 2,
						type = "select",
						name = L["Event"],
						desc = "",
						disabled = false,
						get = function() return selectedEvent() end,
						set = function(_, value)
							db.selectedEvent = value
							db.selectedFlag = "CRITICAL"
							db.selectedSchool = SCHOOL_MASK_SHADOW
						end,
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
					removeFilter = {
						order = 3,
						type = "select",
						name = L["Remove Selected"],
						desc = "",
						values = function()
							local filters = {}
							for filterName in pairs(selectedEventData().filters or {}) do
								filters[filterName] = filterName
							end
							return filters
						end,
						get = function() return "" end,
						set = function(_, value)
							local data = selectedEventData()
							if not data.spellList then
								data.filters = {}
							end
							data.filters[value] = nil
							core:print('ADDED', value, L[" filter removed."])
							self:UpdateAll(db)
						end,
						hidden = function() return not find(selectedEvent(), "BUFF") end,
					},
					addFilter = {
						order = 4,
						type = "select",
						name = L["Add Filter"],
						desc = L["Spells outside the selected whitelist filters will not be displayed."],
						values = function()
							local filters = {}
							for filterName, info in pairs(E.global.unitframe.aurafilters) do
								if info.type == "Whitelist" then
									filters[filterName] = filterName
								end
							end
							return filters
						end,
						get = function() return "" end,
						set = function(_, value)
							local data = selectedEventData()
							if not data.spellList then
								data.filters = {}
							end
							data.filters[value] = true
							core:print('ADDED', value, L[" filter added."])
							self:UpdateAll(db)
						end,
						hidden = function() return not find(selectedEvent(), "BUFF") end,
					},
					disabled = {
						order = 5,
						type = "toggle",
						disabled = false,
						name = L["Disable Event"],
						desc = "",
					},
					playerOnly = {
						order = 6,
						type = "toggle",
						name = L["Player Only"],
						desc = L["Handle only player combat log events."],
					},
					school = {
						order = 7,
						type = "select",
						name = L["School"],
						desc = "",
						get = function() return db.selectedSchool end,
						set = function(_, value) db.selectedSchool = value end,
						values = function()
							if selectedEvent() == 'WOUND' then
								return {
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
								}
							else
								return {
									[SCHOOL_MASK_HOLY] = L["Holy"],
									[SCHOOL_MASK_NATURE] = L["Nature"],
									[SCHOOL_MASK_SHADOW] = L["Shadow"],
								}
							end
						end,
						hidden = function() return selectedEvent() ~= 'WOUND' and selectedEvent() ~= 'HEAL' end,
					},
					tryToColorBySchool = {
						order = 8,
						type = "toggle",
						name = L["Use School Colors"],
						desc = L["Not every event is eligible for this. But some are."],
						hidden = function() return selectedEvent() ~= 'WOUND' and selectedEvent() ~= 'HEAL' end,
					},
					color = {
						order = 9,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedEventData().color or {}) end,
						set = function(_, r, g, b) selectedEventData().color = {r, g, b} self:UpdateAll(db) end,
					},
					colorSchool = {
						order = 10,
						type = "color",
						name = L["Color (School)"],
						desc = "",
						get = function() return unpack(selectedUnitData().school[db.selectedSchool]) end,
						set = function(_, r, g, b) selectedUnitData().school[db.selectedSchool] = {r, g, b} self:UpdateAll(db) end,
						disabled = function()
							return not selectedUnitData().enabled
									or selectedEventData().disabled
									or (selectedEvent() ~= 'WOUND' and selectedEvent() ~= 'HEAL')
						end,
					},
					animation = {
						order = 11,
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
					xDirection = {
						order = 12,
						type = "select",
						name = L["X Direction"],
						desc = "",
						values = {
							[true] = L["Bounce"],
							[1] = L["Right"],
							[-1] = L["Left"],
						}
					},
					yDirection = {
						order = 13,
						type = "select",
						name = L["Y Direction"],
						desc = "",
						values = {
							[true] = L["Bounce"],
							[1] = L["Top"],
							[-1] = L["Bottom"],
						}
					},
					customAnimation = {
						order = 14,
						type = "input",
						width = "double",
						multiline = true,
						name = L["Custom Animation"],
						desc = L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
								"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
								"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"],
					},
					showIcon = {
						order = 15,
						type = "toggle",
						width = "full",
						name = L["Show Icon"],
						desc = "",
					},
					iconPosition = {
						order = 16,
						type = "select",
						name = L["Icon Position"],
						desc = "",
						values = {
							["before"] = L["Before Text"],
							["after"] = L["After Text"],
						},
						hidden = function() return not selectedEventData().showIcon end,
					},
					iconBounce = {
						order = 17,
						type = "toggle",
						name = L["Bounce"],
						desc = L["Flip position left-right."],
						hidden = function() return not selectedEventData().showIcon end,
					},
					font = {
						order = 18,
						type = "select",
						name = L["Font"],
						desc = "",
						dialogControl = "LSM30_Font",
						values = function() return AceGUIWidgetLSMlists.font end,
					},
					fontSize = {
						order = 19,
						type = "range",
						name = L["Font Size"],
						desc = L["There seems to be a font size limit?"],
						min = 10, max = 25, step = 1,
					},
					fontFlags = {
						order = 20,
						type = "select",
						name = L["Font Flags"],
						desc = "",
						values = E.db.Extras.fontFlags,
					},
					scrollTime = {
						order = 21,
						type = "range",
						name = L["Scroll Time"],
						desc = "",
						min = 0.6, max = 6, step = 0.1,
					},
					--[[
					fadeTime = {
						order = 22,
						type = "range",
						name = L["Fade Time"],
						desc = "",
						min = 0.1, max = 3, step = 0.1,
						get = function(info)
					},
					]]--
					textPoint = {
						order = 23,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					textRelativeTo = {
						order = 24,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					textX = {
						order = 25,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -80, max = 80, step = 1,
					},
					textY = {
						order = 26,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -80, max = 80, step = 1,
					},
				},
			},
			flags = {
				order = 4,
				type = "group",
				name = L["Flag Settings"],
				inline = true,
				get = function(info) return selectedFlagData()[info[#info]] end,
				set = function(info, value) selectedFlagData()[info[#info]] = value self:UpdateAll(db) end,
				disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled or selectedFlagData().disabled end,
				hidden = function() return selectedEvent() ~= 'WOUND' and selectedEvent() ~= 'HEAL' end,
				args = {
					disabled = {
						order = 0,
						type = "toggle",
						width = "full",
						name = L["Disable"],
						desc = "",
						disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled end,
					},
					flag = {
						order = 1,
						type = "select",
						name = L["Flag"],
						desc = "",
						get = function() return db.selectedFlag end,
						set = function(_, value)
							db.selectedFlag = value
							if not selectedUnitData().flags[value] then
								selectedUnitData().flags[value] = CopyTable(selectedUnitData().flags["CRITICAL"])
							end
						end,
						values = function()
							if selectedEvent() == 'WOUND' then
								return {
									["ABSORB"       ] = L["ABSORB"],
									["BLOCK"        ] = L["BLOCK"],
									["CRITICAL"     ] = L["CRITICAL"],
									["CRUSHING"     ] = L["CRUSHING"],
									["GLANCING"     ] = L["GLANCING"],
									["RESIST"       ] = L["RESIST"],
									["PERIODICWOUND"] = L["PERIODIC"],
									["NOFLAGWOUND"  ] = L["None"],
								}
							else
								return {
									["ABSORB"		] = L["ABSORB"],
									["CRITICAL"		] = L["CRITICAL"],
									["PERIODICHEAL"	] = L["PERIODIC"],
									["NOFLAGHEAL"  	] = L["None"],
								}
							end
						end,
						disabled = function() return not selectedUnitData().enabled or selectedEventData().disabled end,
					},
					fontMult = {
						order = 2,
						type = "range",
						name = L["Font Size Multiplier"],
						desc = L["There seems to be a font size limit?"],
						min = 0.25, max = 3, step = 0.25,
					},
					animation = {
						order = 3,
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
					animationsByFlag = {
						order = 4,
						type = "toggle",
						name = L["Animation by Flag"],
						desc = L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."],
					},
					xDirection = {
						order = 5,
						type = "select",
						name = L["X Direction"],
						desc = "",
						values = {
							[true] = L["Bounce"],
							[1] = L["Right"],
							[-1] = L["Left"],
						}
					},
					yDirection = {
						order = 6,
						type = "select",
						name = L["Y Direction"],
						desc = "",
						values = {
							[true] = L["Bounce"],
							[1] = L["Top"],
							[-1] = L["Bottom"],
						}
					},
					customAnimation = {
						order = 7,
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
			blacklist = {
				order = 5,
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
							self:UpdateAll(db)
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
							self:UpdateAll(db)
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
	fcf:SetAllPoints(frame)

	fcf.useCLEU = true

	for i = 1, 6 do
		-- give names to these font strings to avoid breaking /fstack and /tinspect
		fcf[i] = fcf:CreateFontString("$parentFCFText" .. i, "OVERLAY")
	end

	frame.FloatingCombatFeedback = fcf
end

function mod:UpdateFCFSettings(frame, db)
	if core.reload then
		return
	else
		frame:DisableElement('FloatingCombatFeedback')
	end
	local enabled
	local data = db.units[frame.unitframeType]
	if data then
		if data.enabled then
			self:ConstructFCF(frame, data)
			local fcf = frame.FloatingCombatFeedback

			frame:EnableElement('FloatingCombatFeedback')

			fcf.abbreviateNumbers = data.abbreviateNumbers
			fcf.blacklist = CopyTable(data.blacklist)

			for event, info in pairs(data.events) do
				if not info.disabled then
					if info.showIcon then
						fcf.iconBounce[event] = info.iconBounce
						if info.iconPosition == 'before' then
							fcf.formats[event] = "|T%2$s:0:0:0:0:64:64:4:60:4:60|t %1$s"
							fcf.iconFormats[event]= {"|T%2$s:0:0:0:0:64:64:4:60:4:60|t %1$s", "%1$s |T%2$s:0:0:0:0:64:64:4:60:4:60|t"}
						else
							fcf.formats[event] = "%1$s |T%2$s:0:0:0:0:64:64:4:60:4:60|t"
							fcf.iconFormats[event] = {"%1$s |T%2$s:0:0:0:0:64:64:4:60:4:60|t", "|T%2$s:0:0:0:0:64:64:4:60:4:60|t %1$s"}
						end
					end
					if event == "BUFF" or event == "DEBUFF" then
						if info.filters and next(info.filters) then
							for filterName in pairs(info.filters) do
								local filter = E.global.unitframe.aurafilters[filterName]
								if filter then
									for spellID in pairs(filter.spells) do
										fcf.filterAuras[event][spellID] = true
									end
								else
									info.filters[filterName] = nil
								end
							end
						else
							twipe(fcf.filterAuras[event])
						end
					end
					if info.tryToColorBySchool then
						fcf.tryToColorBySchool[event] = true
					else
						local color = info.color or {1,1,1}
						fcf.tryToColorBySchool[event] = false
						fcf.colors[event] = { r = color[1], g = color[2], b = color[3] }
					end
					fcf.playerOnlyEvents[event] = info.playerOnly
					fcf.animationsByEvent[event] = {	info.animation,
														tonumber(info.xDirection) or 1,
														tonumber(info.yDirection) or 1,
														not tonumber(info.xDirection),
														info.yDirection and not tonumber(info.yDirection) or false,
													}
					fcf.fontData[event] = {	point = info.textPoint or "CENTER",
											relativeTo = info.textRelativeTo or "CENTER",
											x = info.textX or 0,
											y = info.textY or 24,
											fontSize = info.fontSize or 18,
											fontFlags = info.fontFlags or "",
											font = LSM:Fetch("font", info.font or "Expressway"),
											scrollTime = info.scrollTime or 1.2,
										}
					self:CustomAnim(frame, info.customAnimation, event)
				end
			end
			for school, color in pairs(data.school) do
				fcf.schoolColors[school] = { r = color[1] or 1, g = color[2] or 1, b = color[3] or 1 }
			end
			for flag, info in pairs(data.flags) do
				if not info.disabled then
					fcf.multipliersByFlag[flag] = info.fontMult
					if info.animationsByFlag then
						fcf.animationsByFlag[flag] = {	info.animation,
														tonumber(info.xDirection) or 1,
														tonumber(info.yDirection) or 1,
														not tonumber(info.xDirection),
														info.yDirection and not tonumber(info.yDirection) or false,
													}
						self:CustomAnim(frame, info.customAnimation, nil, flag)
					else
						fcf.animationsByFlag[flag] = nil
					end
				else
					fcf.multipliersByFlag[flag] = nil
				end
			end
			enabled = true
		end
	end
	return enabled
end

function mod:UpdateAll(db)
	for _, frame in ipairs(core:AggregateUnitFrames()) do
		self:UpdateFCFSettings(frame, db)
	end
end


function mod:Toggle(db)
	local enabled
	for _, frame in ipairs(core:AggregateUnitFrames()) do
		enabled = self:UpdateFCFSettings(frame, db) or enabled
	end
	if enabled then
		core:Tag("fcf", self.tagFunc, function()
			if not self.updatePending then
				self.updatePending = E:ScheduleTimer(function() self:UpdateAll(db) self.updatePending = false end, 0.1)
			else
				E:CancelTimer(self.updatePending)
				self.updatePending = E:ScheduleTimer(function() self:UpdateAll(db) self.updatePending = false end, 0.1)
			end
		end)
		self.initialized = true
	elseif self.initialized then
		core:Untag("fcf")
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback