local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("FCF", "AceHook-3.0")
local ElvUF = E.oUF
local LSM = E.Libs.LSM

local modName = mod:GetName()

local pairs, ipairs, loadstring, pcall, type, tonumber, select = pairs, ipairs, loadstring, pcall, type, tonumber, select
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
	local function selectedUnit() return E.db.Extras.unitframes[modName].selectedUnit end
	local function selectedEvent() return E.db.Extras.unitframes[modName].selectedEvent end
	local function selectedFlag() return E.db.Extras.unitframes[modName].selectedFlag end
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
						get = function() return E.db.Extras.unitframes[modName].units[selectedUnit()].enabled end,
						set = function(_, value) E.db.Extras.unitframes[modName].units[selectedUnit()].enabled = value self:Toggle() end,
					},
					unitDropdown = {
						order = 2,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function() return E.db.Extras.unitframes[modName].selectedUnit end,
						set = function(_, value) E.db.Extras.unitframes[modName].selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(E.db.Extras.unitframes[modName].units) end,
					},
					playerOnly = {
						order = 3,
						type = "toggle",
						name = L["Player Only"],
						desc = L["Handle only player combat log events."],
						get = function() return E.db.Extras.unitframes[modName].units[selectedUnit()].playerOnly end,
						set = function(_, value) E.db.Extras.unitframes[modName].units[selectedUnit()].playerOnly = value self:Toggle() end,
						hidden = function() local unit = selectedUnit() return find(unit, 'pet') and not find(unit, 'target') or unit == 'boss' or unit == 'arena' end,
					},
				},
			},
			fontSettings = {
				order = 2,
				type = "group",
				name = L["Font Settings"],
				inline = true,
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled end,
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
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].disabled end,
				args = {
					event = {
						order = 1,
						type = "select",
						name = L["Event"],
						desc = "",
						disabled = false,
						get = function() return selectedEvent() end,
						set = function(_, value) E.db.Extras.unitframes[modName].selectedEvent = value end,
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
						get = function() return E.db.Extras.unitframes[modName].selectedSchool end,
						set = function(_, value) E.db.Extras.unitframes[modName].selectedSchool = value end,
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
						get = function() local color = E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].colors return color[1], color[2], color[3] end,
						set = function(_, r, g, b) E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].colors = {r, g, b} self:Toggle() end,
					},
					colorsSchool = {
						order = 6,
						type = "color",
						name = L["Colors (School)"],
						desc = "",
						get = function() local color = E.db.Extras.unitframes[modName].units[selectedUnit()].school[E.db.Extras.unitframes[modName].selectedSchool] return color[1], color[2], color[3] end,
						set = function(_, r, g, b) E.db.Extras.unitframes[modName].units[selectedUnit()].school[E.db.Extras.unitframes[modName].selectedSchool] = {r, g, b} self:Toggle() end,
					},
					animation = {
						order = 7,
						type = "select",
						width = "double",
						name = L["Animation Type"],
						desc = "",
						values = function()
							local animations = {}
							for animation, info in pairs(E.db.Extras.unitframes[modName].animations) do
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
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()].flags[selectedFlag()][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()].flags[selectedFlag()][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].disabled end,
				args = {
					flag = {
						order = 1,
						type = "select",
						name = L["Flag"],
						desc = "",
						get = function() return E.db.Extras.unitframes[modName].selectedFlag end,
						set = function(_, value) E.db.Extras.unitframes[modName].selectedFlag = value end,
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
							for animation, info in pairs(E.db.Extras.unitframes[modName].animations) do
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
				get = function(info) return E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].units[selectedUnit()][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].disabled end,
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
						disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].disabled or not E.db.Extras.unitframes[modName].units[selectedUnit()].showIcon end,
					},
					iconBounce = {
						order = 3,
						type = "toggle",
						name = L["Bounce"],
						desc = L["Flip position left-right."],
						disabled = function() return not E.db.Extras.unitframes[modName].units[selectedUnit()].enabled or E.db.Extras.unitframes[modName].units[selectedUnit()].events[selectedEvent()].disabled or not E.db.Extras.unitframes[modName].units[selectedUnit()].showIcon end,
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
								E.db.Extras.unitframes[modName].units[selectedUnit()].blacklist[tonumber(spellID)] = true
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
							for spellID in pairs(E.db.Extras.unitframes[modName].units[selectedUnit()].blacklist) do
								if spellID == value then
									E.db.Extras.unitframes[modName].units[selectedUnit()].blacklist[spellID] = nil
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
							for id in pairs(E.db.Extras.unitframes[modName].units[selectedUnit()].blacklist) do
								local name = GetSpellInfo(id) or ""
								local icon = select(3, GetSpellInfo(id))
								icon = icon and "|T"..icon..":0|t" or ""
								values[id] = format("%s %s (%s)", icon, name, id)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {}
							for id in pairs(E.db.Extras.unitframes[modName].units[selectedUnit()].blacklist) do
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
	if not E.db.Extras.unitframes[modName].units.target then
		for _, unitframeType in ipairs({'target', 'focus', 'raid', 'raid40', 'party', 'arena'}) do
			E.db.Extras.unitframes[modName].units[unitframeType] = CopyTable(E.db.Extras.unitframes[modName].units.player)
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