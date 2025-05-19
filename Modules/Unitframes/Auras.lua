local E, L, _, P, G = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("AurasUF", "AceHook-3.0")
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM

local modName = mod:GetName()

local _G, unpack, pairs, ipairs, select = _G, unpack, pairs, ipairs, select
local tonumber, tostring, type = tonumber, tostring, type
local match, format, gsub, find, split = string.match, string.format, string.gsub, string.find, string.split
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local tinsert, tsort, twipe = table.insert, table.sort, table.wipe
local UnitIsUnit, CancelUnitBuff, UnitCanAttack = UnitIsUnit, CancelUnitBuff, UnitCanAttack
local DebuffTypeColor, GetSpellInfo, GetSpellLink = DebuffTypeColor, GetSpellInfo, GetSpellLink

local filterList, checkFilters = {["FRIENDLY"] = {}, ["ENEMY"] = {}}, {}
local iconPositions = {}

mod.filterList = filterList
mod.checkFilters = checkFilters
mod.initialized = {}

local directionProperties = {
	["CENTER"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
	},
	["TOP"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
	},
	["BOTTOM"] = {
		isVertical = true,
		isReverse = true,
		firstInRowPoint = 'TOP',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'TOP',
	},
	["LEFT"] = {
		isVertical = false,
		firstInRowPoint = 'RIGHT',
		subsequentPoint = 'TOPRIGHT',
		framePoint = 'RIGHT',
	},
	["RIGHT"] = {
		isVertical = false,
		isReverse = true,
		firstInRowPoint = 'LEFT',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'LEFT',
	},
	["TOPLEFT"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
	},
	["TOPRIGHT"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
	},
	["BOTTOMLEFT"] = {
		isVertical = true,
		isReverse = true,
		firstInRowPoint = 'TOP',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'TOP',
	},
	["BOTTOMRIGHT"] = {
		isVertical = true,
		isReverse = true,
		firstInRowPoint = 'TOP',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'TOP',
	},
}

function mod:CenterAuras(frame)
	for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
		local element = frame[auraType]
		if element and element.db.enable and element.PostUpdate and element['visible'..auraType] then
			element:PostUpdate()
		end
	end
end

local function updateFilters(db)
	twipe(checkFilters)
	for _, unitType in ipairs({'FRIENDLY', 'ENEMY'}) do
		filterList[unitType] = {[true] = {}, [false] = {}}
		checkFilters[unitType] = {}
		for filterName, info in pairs(db.Highlights.types[unitType].filterList) do
			if info.shadow or info.border or info.useGlobal then
				for isDebuff, entry in pairs({[true] = "treatBuffs", [false] = "treatDebuffs"}) do
					if info[entry] then
						tinsert(filterList[unitType][isDebuff], {	filterName = filterName,
																	priority = info.priority or 999,
																	border = info.border,
																	shadow = info.shadow,
																	info = info.useGlobal and db.global or info,	})
						checkFilters[unitType][isDebuff] = true
					end
				end
			end
		end
		tsort(filterList[unitType], function(a, b) return a.priority < b.priority end)
	end
end

local function cachePositions(db)
	if core.reload or (not db.CenteredAuras.enabled and not db.SortMethods.enabled) then
		if mod.ishooked then
			if E.Options and E.Options.args.unitframe then
				if E.Options.args.CustomTweaks then
					for _, setting in ipairs({"spacing", "units"}) do
						if not mod:IsHooked(E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting], "set") then
							mod:Unhook(E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting], "set")
						end
					end
				end
				for frameType in pairs(core:getAllFrameTypes()) do
					if E.Options.args.unitframe.args[frameType] then
						for _, auraType in ipairs({"buffs", "debuffs"}) do
							if mod:IsHooked(E.Options.args.unitframe.args[frameType].args[auraType], "set") then
								mod:Unhook(E.Options.args.unitframe.args[frameType].args[auraType], "set")
							end
							for _, t in pairs(E.Options.args.unitframe.args[frameType].args[auraType].args.filters.args) do
								if type(t) == 'table' and t.set and not mod:IsHooked(t, "set") then
									mod:Unhook(t, "set")
								end
							end
						end
					end
				end
			elseif mod:IsHooked(E, "ToggleOptionsUI") then
				mod:Unhook(E, "ToggleOptionsUI")
			end
			mod.ishooked = false
		end
		return
	end
	if db.CenteredAuras.enabled then
		local customTweaksUnits = E.db.CustomTweaks and E.db.CustomTweaks.AuraIconSpacing.units
		local customTweaksSpacing = E.db.CustomTweaks and E.db.CustomTweaks.AuraIconSpacing.spacing
		for frameType in pairs(core:getAllFrameTypes()) do
			if UF.db.units[frameType] then
				iconPositions[frameType] = {}
				for _, auraType in ipairs({"buffs", "debuffs"}) do
					local data = UF.db.units[frameType][auraType]

					if data then
						iconPositions[frameType][auraType] = { positions = {}, sizes = {} }

						local cache = iconPositions[frameType][auraType]
						local points = directionProperties[data.anchorPoint]
						local isVertical = points.isVertical
						local isReverse = points.isReverse
						local firstInRowPoint = points.firstInRowPoint
						local subsequentPoint = points.subsequentPoint
						local framePoint = points.framePoint
						local spacing = (customTweaksUnits and customTweaksUnits[frameType]) and customTweaksSpacing or E.Spacing
						local offset, perRow = (data.sizeOverride or 0) + spacing, data.perrow

						for numElements = 1, perRow * data.numrows do
							cache.positions[numElements] = {}
							local lastAnchor = nil

							for i = 1, numElements do
								if i == (perRow * floor((i-1) / perRow) + 1) then
									local numOtherRow = min(perRow, (numElements - (perRow * floor((i-1) / perRow))))
									local OtherRowSize = (numOtherRow * offset)
									local xOffset = isVertical and -(OtherRowSize - offset) / 2 or ((isReverse and 1 or -1) * offset * floor((i-1) / perRow))
									local yOffset = isVertical and ((isReverse and -1 or 1) * offset * floor((i-1) / perRow)) or -(OtherRowSize - offset) / 2

									cache.positions[numElements][i] = {
										point = firstInRowPoint,
										firstInRow = true,
										relativeTo = framePoint,
										xOffset = xOffset,
										yOffset = yOffset
									}
								else
									local xOffset = isVertical and offset or 0
									local yOffset = isVertical and 0 or offset

									cache.positions[numElements][i] = {
										point = subsequentPoint,
										anchor = lastAnchor,
										relativeTo = subsequentPoint,
										xOffset = xOffset,
										yOffset = yOffset
									}
								end
								lastAnchor = i
							end

							local numRows = ceil(numElements/perRow)
							local width = max(offset, offset * min(perRow, numElements) - spacing)
							local height = max(offset, offset * numRows - spacing)
							cache.sizes[numElements] = {
								isVertical and width or height,
								isVertical and height or width
							}
						end
					end
				end
			end
		end
	end
	if not mod.ishooked then
		if E.Options and E.Options.args.unitframe then
			if E.Options.args.CustomTweaks and E.private.CustomTweaks.AuraIconSpacing and db.CenteredAuras.enabled then
				for _, setting in ipairs({"spacing", "units"}) do
					if not mod:IsHooked(E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting], "set") then
						mod:RawHook(E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting], "set",
							function(info, key, value)
								if setting == 'units' then
									E.db.CustomTweaks.AuraIconSpacing.units[key] = value
								else
									E.db.CustomTweaks.AuraIconSpacing[setting] = key
								end
								cachePositions(db)
								mod.hooks[E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting]].set(info,key,value)
								for _, frame in ipairs(core:AggregateUnitFrames()) do
									mod:CenterAuras(frame)
								end
							end
						)
					end
				end
			end
			for frameType in pairs(core:getAllFrameTypes()) do
				if E.Options.args.unitframe.args[frameType] then
					for _, auraType in ipairs({"buffs", "debuffs"}) do
						if db.CenteredAuras.enabled then
							if not mod:IsHooked(E.Options.args.unitframe.args[frameType].args[auraType], "set") then
								mod:RawHook(E.Options.args.unitframe.args[frameType].args[auraType], "set", function(info, value)
									E.db.unitframe.units[frameType][auraType][info[#info]] = value
									cachePositions(db)
									mod.hooks[E.Options.args.unitframe.args[frameType].args[auraType]].set(info, value)
								end)
							end
						end
						if db.SortMethods.enabled then
							for _, t in pairs(E.Options.args.unitframe.args[frameType].args[auraType].args.filters.args) do
								if type(t) == 'table' and t.set and not mod:IsHooked(t, "set") then
									mod:SecureHook(t, "set", function()
										cachePositions(db)
										for _, frame in ipairs(core:AggregateUnitFrames()) do
											for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
												local element = frame[auraType]
												if element and element.db.enable
														and element.PostUpdate and element.PreSetPosition
														and element['visible'..auraType] then
													element:PreSetPosition()
													element:PostUpdate()
												end
											end
										end
									end)
								end
							end
						end
					end
				end
			end
		elseif not mod:IsHooked(E, "ToggleOptionsUI") then
			mod:SecureHook(E, "ToggleOptionsUI", function()
				if E.Options.args.unitframe then
					if E.Options.args.CustomTweaks and E.private.CustomTweaks.AuraIconSpacing and db.CenteredAuras.enabled then
						for _, setting in ipairs({"spacing", "units"}) do
							if not mod:IsHooked(E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting], "set") then
								mod:RawHook(E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting], "set",
									function(info, key, value)
										if setting == 'units' then
											E.db.CustomTweaks.AuraIconSpacing.units[key] = value
										else
											E.db.CustomTweaks.AuraIconSpacing[setting] = key
										end
										cachePositions(db)
										mod.hooks[E.Options.args.CustomTweaks.args.Unitframe.args.options.args.AuraIconSpacing.args[setting]].set(info,key,value)
										for _, frame in ipairs(core:AggregateUnitFrames()) do
											mod:CenterAuras(frame)
										end
									end
								)
							end
						end
					end
					for frameType in pairs(core:getAllFrameTypes()) do
						if E.Options.args.unitframe.args[frameType] then
							for _, auraType in ipairs({"buffs", "debuffs"}) do
								if db.CenteredAuras.enabled then
									if not mod:IsHooked(E.Options.args.unitframe.args[frameType].args[auraType], "set") then
										mod:RawHook(E.Options.args.unitframe.args[frameType].args[auraType], "set", function(info, value)
											E.db.unitframe.units[frameType][auraType][info[#info]] = value
											cachePositions(db)
											mod.hooks[E.Options.args.unitframe.args[frameType].args[auraType]].set(info, value)
										end)
									end
								end
								if db.SortMethods.enabled then
									for _, t in pairs(E.Options.args.unitframe.args[frameType].args[auraType].args.filters.args) do
										if type(t) == 'table' and t.set and not mod:IsHooked(t, "set") then
											mod:SecureHook(t, "set", function()
												cachePositions(db)
												for _, frame in ipairs(core:AggregateUnitFrames()) do
													for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
														local element = frame[auraType]
														if element and element.db.enable
																and element.PostUpdate and element.PreSetPosition
																and element['visible'..auraType] then
															element:PreSetPosition()
															element:PostUpdate()
														end
													end
												end
											end)
										end
									end
								end
							end
						end
					end
					mod:Unhook(E, "ToggleOptionsUI")
				end
			end)
		end
		mod.ishooked = true
	end
end


P["Extras"]["unitframes"][modName] = {
	["SortMethods"] = {
		["enabled"] = false,
	},
	["CenteredAuras"] = {
		["enabled"] = false,
	},
	["ClickCancel"] = {
		["enabled"] = false,
	},
	["SaturatedDebuffs"] = {
		["enabled"] = false,
	},
	["TypeBorders"] = {
		["enabled"] = false,
	},
	["Highlights"] = {
		["selectedType"] = 'FRIENDLY',
		["types"] = {
			["FRIENDLY"] = {
				["selected"] = 'GLOBAL',
				["enabled"] = false,
				["global"] = {
					["border"] = false,
					["shadow"] = false,
					["size"] = 3,
					["color"] = { 0.93, 0.91, 0.55, 1 },
					["shadowColor"] = { 0.93, 0.91, 0.55, 1 },
				},
				["special"] = {
					["border"] = false,
					["shadow"] = false,
					["size"] = 3,
					["color"] = { 0.93, 0.91, 0.55, 1 },
					["shadowColor"] = { 0.93, 0.91, 0.55, 1 },
				},
				["spellList"] = {},
				["filterList"] = {},
			},
		},
	},
}

function mod:LoadConfig(db)
	local function selectedType() return db.Highlights.selectedType or "FRIENDLY" end
	local function selectedSpellorFilter() return db.Highlights.types[selectedType()].selected or "GLOBAL" end
	local function getHighlightSettings(selected, spellOrFilter)
		local data = db.Highlights.types[selected]
		if spellOrFilter == "GLOBAL" then
			return data.global
		elseif spellOrFilter == "CURABLE" or spellOrFilter == "STEALABLE" then
			return data.special
		elseif type(spellOrFilter) == 'number' then
			return data.spellList[spellOrFilter].useGlobal and data.global or data.spellList[spellOrFilter]
		elseif data.filterList[spellOrFilter] then
			return data.filterList[spellOrFilter].useGlobal and data.global or data.filterList[spellOrFilter]
		end
		return data.global
	end
	local specialFilters = {
		["Personal"] = "Personal",
		["nonPersonal"] = "nonPersonal",
		["CastByUnit"] = "CastByUnit",
		["notCastByUnit"] = "notCastByUnit",
		["Dispellable"] = "Dispellable",
		["notDispellable"] = "notDispellable",
	}
	core.unitframes.args[modName] = {
		type = "group",
		name = L["Auras"],
		get = function(info) return db[info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) db[info[#info-1]][gsub(info[#info], info[#info-1], '')] = value self:Toggle(db) UF:Update_AllFrames() end,
		args = {
			Highlights = {
				order = 1,
				type = "group",
				name = L["Highlights"],
				guiInline = true,
				args = {
					enabledHighlights = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Highlights auras."],
						get = function() return db.Highlights.types[selectedType()].enabled end,
						set = function(_, value)
							db.Highlights.types[selectedType()].enabled = value
							self:UpdatePostUpdateAura(db, value)
							UF:Update_AllFrames()
						end,
					},
					typeDropdown = {
						order = 2,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function() return db.Highlights.selectedType end,
						set = function(_, value) db.Highlights.selectedType = value end,
						values = function() return core:GetUnitDropdownOptions(db.Highlights.types) end,
					},
				},
			},
			highlightSettings = {
				order = 2,
				type = "group",
				name = L["Highlights Settings"],
				guiInline = true,
				disabled = function() return not db.Highlights.types[selectedType()].enabled end,
				hidden = function() return not db.Highlights.types[selectedType()].enabled end,
				args = {
					addSpell = {
						order = 1,
						type = "input",
						name = L["Add Spell (by ID)"],
						desc = L["E.g. 42292"],
						get = function() return "" end,
						set = function(_, value)
							local spellID = match(value, '%D*(%d+)%D*')
							if spellID and GetSpellInfo(spellID) then
								db.Highlights.types[selectedType()].spellList[tonumber(spellID)] = {
									["border"] = false,
									["shadow"] = false,
									["useGlobal"] = false,
									["size"] = 3,
									["color"] = { 0.93, 0.91, 0.55, 1 },
									["shadowColor"] = { 0.93, 0.91, 0.55, 1 },
								}
								local _, _, icon = GetSpellInfo(spellID)
								local link = GetSpellLink(spellID)
								icon = gsub(icon, '\124', '\124\124')
								local string = '\124T' .. icon .. ':16:16\124t' .. link
								UF:Update_AllFrames()
								core:print('ADDED', string)
							end
						end,
					},
					addFilter = {
						order = 2,
						type = "select",
						name = L["Add Filter"],
						desc = L["Applies highlights to all auras passing the selected filter."],
						values = function()
							local filters = CopyTable(specialFilters)
							for filterName in pairs(E.global.unitframe.aurafilters) do
								if filterName ~= 'Blacklist' then
									filters[filterName] = filterName
								end
							end
							return filters
						end,
						get = function() return "" end,
						set = function(_, value)
							db.Highlights.types[selectedType()].filterList[value] = {
								["border"] = false,
								["shadow"] = false,
								["useGlobal"] = false,
								["size"] = 3,
								["color"] = { 0.93, 0.91, 0.55, 1 },
								["shadowColor"] = { 0.93, 0.91, 0.55, 1 },
								["priority"] = 1,
							}
							updateFilters(db)
							UF:Update_AllFrames()
							core:print('ADDED', value, L[" filter added."])
						end,
					},
					filterPriority = {
						order = 3,
						type = "input",
						name = L["Filter Priority"],
						desc = "",
						get = function() return tostring(getHighlightSettings(selectedType(), selectedSpellorFilter()).priority or "") end,
						set = function(_, value)
							getHighlightSettings(selectedType(), selectedSpellorFilter()).priority = tonumber(value) or 999
							updateFilters(db)
							UF:Update_AllFrames()
						end,
						disabled = function()
							return not db.Highlights.types[selectedType()].enabled
									or (not E.global.unitframe.aurafilters[selectedSpellorFilter()]
										and not specialFilters[selectedSpellorFilter()]) end,
					},
					spellOrFilterDropdown = {
						order = 4,
						type = "select",
						name = L["Select Spell or Filter"],
						desc = L["Priority: spell, filter, curable/stealable."],
						get = function() return selectedSpellorFilter() end,
						set = function(_, value)
							if (value == '--filters--' or value == '--spells--') then value = 'GLOBAL' end
							db.Highlights.types[selectedType()].selected = value
						end,
						values = function()
							local effectType = selectedType() == 'FRIENDLY' and "CURABLE" or "STEALABLE"
							local values = {
								["GLOBAL"] = L["GLOBAL"],
								[effectType] = L[effectType],
								["--filters--"] = L["--Filters--"],
							}
							for filter in pairs(db.Highlights.types[selectedType()].filterList) do
								values[filter] = filter
							end
							values["--spells--"] = L["--Spells--"]
							for spellID in pairs(db.Highlights.types[selectedType()].spellList) do
								local name, _, icon = GetSpellInfo(spellID)
								icon = icon and "|T"..icon..":0|t" or ""
								values[spellID] = format("%s %s (%s)", icon, name or "", spellID)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {"GLOBAL", selectedType() == 'FRIENDLY' and "CURABLE" or "STEALABLE", "--filters--"}
							for filter in pairs(db.Highlights.types[selectedType()].filterList) do
								tinsert(sortedKeys, filter)
							end
							tinsert(sortedKeys, "--spells--")
							for spellID in pairs(db.Highlights.types[selectedType()].spellList) do
								tinsert(sortedKeys, spellID)
							end
							return sortedKeys
						end,
					},
					removeSelected = {
						order = 5,
						type = "execute",
						name = L["Remove Selected"],
						desc = "",
						func = function()
							local selected = selectedSpellorFilter()
							local data = db.Highlights.types[selectedType()]
							if type(selected) == 'number' then
								data.spellList[selected] = nil
								local _, _, icon = GetSpellInfo(selected)
								local link = GetSpellLink(selected)
								icon = gsub(icon, '\124', '\124\124')
								local string = '\124T' .. icon .. ':16:16\124t' .. link
								core:print('REMOVED', string)
							else
								data.filterList[selected] = nil
								updateFilters(db)
								core:print('REMOVED', selected, L[" filter removed."])
							end
							data.selected = "GLOBAL"
							UF:Update_AllFrames()
						end,
						hidden = function()
							return selectedSpellorFilter() == "GLOBAL"
									or selectedSpellorFilter() == "CURABLE"
									or selectedSpellorFilter() == "STEALABLE" end,
					},
					useGlobal = {
						order = 6,
						type = "toggle",
						name = L["Use Global Settings"],
						desc = L["If toggled, the GLOBAL Spell or Filter entry values would be used."],
						get = function()
							local selected = selectedSpellorFilter()
							local data = db.Highlights.types[selectedType()]
							local target = type(selected) == 'number' and data.spellList[selected] or data.filterList[selected]
							return selected == 'GLOBAL' or selected == 'CURABLE' or selected == 'STEALABLE' or target.useGlobal
						end,
						set = function(_, value)
							local selected = selectedSpellorFilter()
							local data = db.Highlights.types[selectedType()]
							local target = type(selected) == 'number' and data.spellList[selected] or data.filterList[selected]
							target.useGlobal = value
							updateFilters(db)
							UF:Update_AllFrames()
						end,
						hidden = function()
							return selectedSpellorFilter() == "GLOBAL"
									or selectedSpellorFilter() == "CURABLE"
									or selectedSpellorFilter() == "STEALABLE" end,
						disabled = function() return selectedSpellorFilter() == "GLOBAL" or selectedSpellorFilter() == "CURABLE" or selectedSpellorFilter() == "STEALABLE" end,
					},
				},
			},
			highlightValues = {
				order = 3,
				type = "group",
				name = L["Selected Spell or Filter Values"],
				inline = true,
				disabled = function() return not db.Highlights.types[selectedType()].enabled end,
				hidden = function() return not db.Highlights.types[selectedType()].enabled end,
				get = function(info) return getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]] end,
				set = function(info, value)
					getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]] = value
					updateFilters(db)
					UF:Update_AllFrames()
				end,
				args = {
					treatDebuffs = {
						order = 1,
						type = "toggle",
						name = L["Buffs"],
						desc = "",
						hidden = function()
							local currSelected = selectedSpellorFilter()
							return not db.Highlights.types[selectedType()].enabled
									or type(currSelected) == 'number'
									or currSelected == "GLOBAL"
									or currSelected == "CURABLE"
									or currSelected == "STEALABLE"
						end,
					},
					treatBuffs = {
						order = 2,
						type = "toggle",
						name = L["Debuffs"],
						desc = "",
						hidden = function()
							local currSelected = selectedSpellorFilter()
							return not db.Highlights.types[selectedType()].enabled
									or type(currSelected) == 'number'
									or currSelected == "GLOBAL"
									or currSelected == "CURABLE"
									or currSelected == "STEALABLE"
						end,
					},
					shadow = {
						order = 3,
						type = "toggle",
						width = "full",
						name = L["Enable Shadow"],
						desc = "",
					},
					size = {
						order = 4,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 1, max = 20, step = 1,
						hidden = function() return not getHighlightSettings(selectedType(), selectedSpellorFilter()).shadow end,
					},
					shadowColor = {
						order = 5,
						type = "color",
						name = L["Shadow Color"],
						desc = "",
						hasAlpha = true,
						get = function(info) return unpack(getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]]) end,
						set = function(info, r, g, b, a)
							getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]] = {r, g, b, a}
							UF:Update_AllFrames()
						end,
						hidden = function() return not getHighlightSettings(selectedType(), selectedSpellorFilter()).shadow end,
					},
					border = {
						order = 6,
						type = "toggle",
						name = L["Enable Border"],
						desc = "",
					},
					color = {
						order = 7,
						type = "color",
						name = L["Border Color"],
						desc = "",
						get = function(info) return unpack(getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]]) end,
						set = function(info, r, g, b)
							getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]] = {r, g, b}
							UF:Update_AllFrames()
						end,
						hidden = function() return not getHighlightSettings(selectedType(), selectedSpellorFilter()).border end,
					},
				},
			},
			CenteredAuras = {
				type = "group",
				name = L["Centered Auras"],
				guiInline = true,
				args = {
					enabledCenteredAuras = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Makes auras grow sideswise."],
					},
				},
			},
			SortMethods = {
				type = "group",
				name = L["Sort by Filter"],
				guiInline = true,
				args = {
					enabledSortMethods = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Makes aura sorting abide filter priorities."],
					},
				},
			},
			ClickCancel = {
				type = "group",
				name = L["Click Cancel"],
				guiInline = true,
				args = {
					enabledClickCancel = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Right-click a player buff to cancel it."],
					},
				},
			},
			SaturatedDebuffs = {
				type = "group",
				name = L["Saturated Debuffs"],
				guiInline = true,
				args = {
					enabledSaturatedDebuffs = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Disables debuffs desaturation."],
					},
				},
			},
			TypeBorders = {
				type = "group",
				name = L["Type Borders"],
				guiInline = true,
				args = {
					enabledTypeBorders = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Disables border coloring."],
					},
				},
			},
		},
	}
	if not db.Highlights.types['ENEMY'] then
		db.Highlights.types['ENEMY'] = CopyTable(db.Highlights.types['FRIENDLY'])
	end
end


function mod:UpdateSortMethods(db)
	if self:IsHooked(UF, "SortAuras") then self:Unhook(UF, "SortAuras") end
	local units = core:AggregateUnitFrames()

	if not core.reload and db.SortMethods.enabled then
		local function SortAurasByTime(a, b, sortDirection)
			local aTime = a.expiration or -1
			local bTime = b.expiration or -1
			if sortDirection == "DESCENDING" then
				return aTime < bTime
			else
				return aTime > bTime
			end
		end
		local function SortAurasByName(a, b, sortDirection)
			local aName = a.spell or ""
			local bName = b.spell or ""
			if sortDirection == "DESCENDING" then
				return aName < bName
			else
				return aName > bName
			end
		end
		local function SortAurasByDuration(a, b, sortDirection)
			local aTime = a.duration or -1
			local bTime = b.duration or -1
			if sortDirection == "DESCENDING" then
				return aTime < bTime
			else
				return aTime > bTime
			end
		end
		local function SortAurasByCaster(a, b, sortDirection)
			local aPlayer = a.isPlayer or false
			local bPlayer = b.isPlayer or false
			if sortDirection == "DESCENDING" then
				return (aPlayer and not bPlayer)
			else
				return (not aPlayer and bPlayer)
			end
		end
		self:RawHook(UF, "SortAuras", function(self)
			if not self.db then return end

			local btn = self[1]
			if btn then
				local aurasFrame = btn:GetParent()
				local filterOrder = aurasFrame.filterPriority
				local sortMethod = aurasFrame.db.sortMethod
				local sortDirection = aurasFrame.db.sortDirection

				if filterOrder then
					local buttonFilters = {}
					local frame = aurasFrame:GetParent()
					local aurafilters = E.global.unitframe.aurafilters

					for i = 1, (aurasFrame.type == 'debuffs' and aurasFrame.visibleDebuffs or aurasFrame.visibleBuffs) or 0 do
						local button = self[i]
						if button then
							local filterIndex
							local name = button.name
							local spellID = button.spellID
							local caster = button.owner
							local isPlayer = button.isPlayer
							local isUnit = button.owner and UnitIsUnit(frame.unit, button.owner)
							local canDispell = (aurasFrame.type == "buffs" and button.isStealable)
								or (aurasFrame.type == "debuffs" and button.dtype and E:IsDispellableByMe(button.dtype))

							for index, filterName in ipairs(filterOrder) do
								local filter = aurafilters[filterName]
								if filter then
									local filterType = filter.type
									local spellList = filter.spells
									local spell = spellList and (spellList[spellID] or spellList[name])

									if filterType and (filterType == "Whitelist") and (spell and spell.enable) then
										filterIndex = index
										break
									end
								elseif filterName == "Personal" and isPlayer then
									filterIndex = index
									break
								elseif filterName == "nonPersonal" and (not isPlayer) then
									filterIndex = index
									break
								elseif filterName == "CastByUnit" and (caster and isUnit) then
									filterIndex = index
									break
								elseif filterName == "notCastByUnit" and (caster and not isUnit) then
									filterIndex = index
									break
								elseif filterName == "Dispellable" and canDispell then
									filterIndex = index
									break
								elseif filterName == "notDispellable" and (not canDispell) then
									filterIndex = index
									break
								end
							end
							buttonFilters[button] = filterIndex or 99999
						end
					end
					tsort(self, function(a, b)
						if not a:IsShown() then
							return false
						elseif not b:IsShown() then
							return true
						end

						local aFilter = buttonFilters[a] or 0
						local bFilter = buttonFilters[b] or 0

						if aFilter ~= bFilter then
							return aFilter < bFilter
						elseif sortMethod == "TIME_REMAINING" then
							return SortAurasByTime(a, b, sortDirection)
						elseif sortMethod == "NAME" then
							return SortAurasByName(a, b, sortDirection)
						elseif sortMethod == "DURATION" then
							return SortAurasByDuration(a, b, sortDirection)
						elseif sortMethod == "PLAYER" then
							return SortAurasByCaster(a, b, sortDirection)
						end
					end)
				elseif sortMethod == "TIME_REMAINING" then
					tsort(self, function(a,b)
						if not a:IsShown() then
							return false
						elseif not b:IsShown() then
							return true
						end
						return SortAurasByTime(a, b, sortDirection)
					end)
				elseif sortMethod == "NAME" then
					tsort(self, function(a,b)
						if not a:IsShown() then
							return false
						elseif not b:IsShown() then
							return true
						end
						return SortAurasByName(a, b, sortDirection)
					end)
				elseif sortMethod == "DURATION" then
					tsort(self, function(a,b)
						if not a:IsShown() then
							return false
						elseif not b:IsShown() then
							return true
						end
						return SortAurasByDuration(a, b, sortDirection)
					end)
				elseif sortMethod == "PLAYER" then
					tsort(self, function(a,b)
						if not a:IsShown() then
							return false
						elseif not b:IsShown() then
							return true
						end
						return SortAurasByCaster(a, b, sortDirection)
					end)
				end
			end
			return 1, #self
		end)
		core:Tag('sortMethods', nil, function(_, frame)
			for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
				local element = frame[auraType]
				if element then
					if element.db and element.db.enable then
						if element.db.priority and element.db.priority ~= "" then
							element.filterPriority = {}
							for _, filter in ipairs({split(",", element.db.priority)}) do
								tinsert(element.filterPriority, filter)
							end
						else
							element.filterPriority = nil
						end
					else
						element.filterPriority = nil
					end
				end
			end
		end)
		self.initialized['sortMethods'] = true
	elseif self.initialized['sortMethods'] then
		core:Untag('sortMethods')
	end
	if self.initialized['sortMethods'] then
		for _, frame in ipairs(units) do
			for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
				local element = frame[auraType]
				if element and element.db and element.db.enable then
					element.PreSetPosition = (not frame:GetScript("OnUpdate")) and UF.SortAuras or nil
					if element.PostUpdate and element['visible'..auraType] then
						element:PostUpdate()
					end
				end
			end
		end
    end
end

function mod:UpdateCenteredAuras(db)
	if not core.reload and db.CenteredAuras.enabled then
		cachePositions(db)

		function mod:CenterAlignAuras(self, numElements, auraType, auraTypeRef)
			if not numElements or numElements == 0 then return end

			local parent = self:GetParent()
			local overRide = parent.db[auraType] and parent.db[auraType].sizeOverride

			if overRide and overRide > 0 then
				local frame = parent[auraTypeRef]
				local data = iconPositions[parent.unitframeType][frame.type]
				local points = data.positions[numElements]

				for i = 1, numElements do
					local child = frame[i]
					if child then
						local vals = points[i]
						child:ClearAllPoints()
						child:Point(vals.point, vals.firstInRow and frame or frame[vals.anchor], vals.relativeTo, vals.xOffset, vals.yOffset)
					end
				end
				local height, width = unpack(data.sizes[numElements])
				frame:Size(height, width)

				if frame.auraBarsHolder then
					frame.auraBarsHolder:Height(width)
				end
			end
		end

		function mod:UpdateBuffsHeaderPosition()
			local numDebuffs = self.visibleDebuffs
			if not numDebuffs or numDebuffs == 0 then
				mod:CenterAlignAuras(self, self.visibleBuffs, 'buffs', 'Buffs')
			else
				mod:CenterAlignAuras(self, numDebuffs, 'debuffs', 'Debuffs')
				mod:CenterAlignAuras(self, self.visibleBuffs, 'buffs', 'Buffs')
			end
		end

		function mod:UpdateDebuffsHeaderPosition()
			local numBuffs = self.visibleBuffs
			if not numBuffs or numBuffs == 0 then
				mod:CenterAlignAuras(self, self.visibleDebuffs, 'debuffs', 'Debuffs')
			else
				mod:CenterAlignAuras(self, self.visibleDebuffs, 'debuffs', 'Debuffs')
				mod:CenterAlignAuras(self, numBuffs, 'buffs', 'Buffs')
			end
		end

		function mod:UpdateBuffsPositionAndDebuffHeight()
			local numDebuffs = self.visibleDebuffs
			if not numDebuffs or numDebuffs == 0 then
				mod:CenterAlignAuras(self, self.visibleBuffs, 'buffs', 'Buffs')
			else
				mod:CenterAlignAuras(self, numDebuffs, 'debuffs', 'Debuffs')
				mod:CenterAlignAuras(self, self.visibleBuffs, 'buffs', 'Buffs')
			end
		end

		function mod:UpdateDebuffsPositionAndBuffHeight()
			local numBuffs = self.visibleBuffs
			if not numBuffs or numBuffs == 0 then
				mod:CenterAlignAuras(self, self.visibleDebuffs, 'debuffs', 'Debuffs')
			else
				mod:CenterAlignAuras(self, self.visibleDebuffs, 'debuffs', 'Debuffs')
				mod:CenterAlignAuras(self, numBuffs, 'buffs', 'Buffs')
			end
		end

		function mod:UpdateBuffsHeight()
			local numBuffs = self.visibleBuffs
			if numBuffs and numBuffs > 0 then
				mod:CenterAlignAuras(self, numBuffs, 'buffs', 'Buffs')
			end
		end

		function mod:UpdateDebuffsHeight()
			local numDebuffs = self.visibleDebuffs
			if numDebuffs and numDebuffs > 0 then
				mod:CenterAlignAuras(self, numDebuffs, 'debuffs', 'Debuffs')
			end
		end

		function mod:Configure_Auras(frame)
			if not frame.Buffs.PostUpdate then
				frame.Buffs.PostUpdate = mod.UpdateBuffsHeaderPosition
			end
			if not frame.Debuffs.PostUpdate then
				frame.Debuffs.PostUpdate = mod.UpdateDebuffsHeaderPosition
			end
		end

		function mod:Configure_AuraBars(frame)
			if not frame.VARIABLES_SET or (E.db.abm and E.db.abm[frame.unitframeType]) then
				return
			end

			local db = frame.db
			if db.aurabar.enable and db.aurabar.attachTo ~= "FRAME" then
				local attachTo, anchorPoint, anchorTo

				if db.aurabar.attachTo == "BUFFS" then
					attachTo = frame.Buffs
					local numElements = attachTo.visibleBuffs or 0
					local offset = attachTo.size + attachTo.spacing

					if db.aurabar.anchorPoint == "BELOW" then
						anchorPoint, anchorTo = "TOP", "BOTTOM"
					else
						anchorPoint, anchorTo = "BOTTOM", "TOP"
					end

					attachTo.auraBarsHolder = attachTo.auraBarsHolder or CreateFrame("Frame")
					attachTo.auraBarsHolder:ClearAllPoints()
					attachTo.auraBarsHolder:Point(anchorPoint, attachTo)
					attachTo.auraBarsHolder:Size(offset*max(1,db.buffs.perrow)-attachTo.spacing, offset*max(1,numElements)-attachTo.spacing)

					mod:CenterAlignAuras(attachTo, numElements, 'buffs', 'Buffs')
				elseif db.aurabar.attachTo == "DEBUFFS" then
					attachTo = frame.Debuffs
					local numElements = attachTo.visibleDebuffs or 0
					local offset = attachTo.size + attachTo.spacing

					if db.aurabar.anchorPoint == "BELOW" then
						anchorPoint, anchorTo = "TOP", "BOTTOM"
					else
						anchorPoint, anchorTo = "BOTTOM", "TOP"
					end

					attachTo.auraBarsHolder = attachTo.auraBarsHolder or CreateFrame("Frame")
					attachTo.auraBarsHolder:ClearAllPoints()
					attachTo.auraBarsHolder:Point(anchorPoint, attachTo)
					attachTo.auraBarsHolder:Size(offset*max(1,db.debuffs.perrow)-attachTo.spacing, offset*max(1,numElements)-attachTo.spacing)

					mod:CenterAlignAuras(attachTo, numElements, 'debuffs', 'Debuffs')
				else
					return
				end

				local auraBars = frame.AuraBars
				auraBars:ClearAllPoints()
				auraBars:Point(anchorPoint.."LEFT", attachTo.auraBarsHolder, anchorTo.."LEFT")
				auraBars:Point(anchorPoint.."RIGHT", attachTo.auraBarsHolder, anchorTo.."RIGHT")
				auraBars:SetAnchors()
			end
		end

		function mod:UpdateFrame(frame)
			local buffs = frame.Buffs
			local debuffs = frame.Debuffs
			local numBuffs = buffs.visibleBuffs
			local numDebuffs = debuffs.visibleDebuffs

			if numDebuffs and numDebuffs > 0 then
				mod:CenterAlignAuras(debuffs, debuffs.visibleDebuffs, 'debuffs', 'Debuffs')
			end

			if numBuffs and numBuffs > 0 then
				mod:CenterAlignAuras(buffs, buffs.visibleBuffs, 'buffs', 'Buffs')
			end
		end

		for _, func in ipairs({'Configure_Auras', 'Configure_AuraBars', 'UpdateBuffsHeaderPosition', 'UpdateDebuffsHeaderPosition', 'UpdateBuffsPositionAndDebuffHeight', 'UpdateDebuffsPositionAndBuffHeight', 'UpdateDebuffsHeight', 'UpdateBuffsHeight'}) do
			if not self:IsHooked(UF, func) then self:SecureHook(UF, func, self[func]) end
		end
		for _, func in ipairs({'Update_PlayerFrame', 'Update_TargetFrame', 'Update_FocusFrame', 'Update_PetFrame'}) do
			if not self:IsHooked(UF, func) then self:SecureHook(UF, func, self.UpdateFrame) end
		end
		core:Tag('centerAuras', nil, function(_, frame) E:ScheduleTimer(function() self:CenterAuras(frame) end, 0.1) end)
	else
		cachePositions(db)

		for _, func in ipairs({'Configure_Auras', 'Configure_AuraBars', 'UpdateBuffsHeaderPosition', 'UpdateDebuffsHeaderPosition', 'UpdateBuffsPositionAndDebuffHeight', 'UpdateDebuffsPositionAndBuffHeight', 'UpdateDebuffsHeight', 'UpdateBuffsHeight'}) do
			if self:IsHooked(UF, func) then self:Unhook(UF, func) end
		end
		for _, func in ipairs({'Update_PlayerFrame', 'Update_TargetFrame', 'Update_FocusFrame', 'Update_PetFrame'}) do
			if self:IsHooked(UF, func) then self:Unhook(UF, func) end
		end
		core:Untag('centerAuras')
	end
end

function mod:UpdateClickCancel(db)
	local function RMBCancelBuff(self, button)
		button:HookScript('OnClick', function(self, button)
			if button == 'RightButton' then CancelUnitBuff("player", self:GetID()) end
		end)
	end

	if not core.reload and db.ClickCancel.enabled then
		if not self:IsHooked(_G['ElvUF_PlayerBuffs'], "PostCreateIcon") then self:SecureHook(_G['ElvUF_PlayerBuffs'], "PostCreateIcon", RMBCancelBuff) end
	else
		if self:IsHooked(_G['ElvUF_PlayerBuffs'], "PostCreateIcon") then self:Unhook(_G['ElvUF_PlayerBuffs'], "PostCreateIcon") end
	end

	for i = 1, _G['ElvUF_PlayerBuffs']:GetNumChildren() do
		local child = select(i, _G['ElvUF_PlayerBuffs']:GetChildren())
		_G['ElvUF_PlayerBuffs']:PostCreateIcon(child)
	end
end


function mod:ApplyHighlight(db, button)
	if db.border then
		button:SetBackdropBorderColor(unpack(db.color))
	end
	if db.shadow then
		if not button.shadow then
			local shadow = CreateFrame("Frame", nil, button)
			button.shadow = shadow
		end
		button.shadow:SetOutside(button, db.size, db.size)
		button.shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(db.size)})
		button.shadow:SetBackdropBorderColor(unpack(db.shadowColor))
	elseif button.shadow then
		button.shadow:Hide()
		button.shadow = nil
	end
	button.highlightApplied = true
end

function mod:ClearHighlights(button, unit, isDebuff, _, unstableAffliction, vampiricTouch)
	if isDebuff then
		if not button.isFriend and not button.isPlayer then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not find(unit, "arena%d")) and true or false)
		else
			local color = (button.dtype and DebuffTypeColor[button.dtype]) or DebuffTypeColor.none
			if button.name and (button.name == unstableAffliction or button.name == vampiricTouch) and E.myclass ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if button.isStealable and not button.isFriend then
			button:SetBackdropBorderColor(0.93, 0.91, 0.55, 1.0)
		else
			button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end
	end
	if button.shadow then
		button.shadow:Hide()
		button.shadow = nil
	end
	button.highlightApplied = false
end

function mod:HandleCurableStealable(db, button, unit, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name, dispellList, purgeList)
	if (db.shadow or db.border) and (attackable or (E.myclass == "WARLOCK" or (name and (name ~= unstableAffliction and name ~= vampiricTouch)))) and dtype and find(dtype, '%S+') then
		if (attackable and isDebuff) or (not attackable and not isDebuff)
		 or (isDebuff and not (dispellList and dispellList[dtype])) or (not isDebuff and not purgeList) then
			if button.highlightApplied then
				self:ClearHighlights(button, unit, isDebuff, debuffType, unstableAffliction, vampiricTouch)
			end
			return
		end
		self:ApplyHighlight(db, button)
	elseif button.highlightApplied then
		self:ClearHighlights(button, unit, isDebuff, debuffType, unstableAffliction, vampiricTouch)
	end
end

function mod:UpdatePostUpdateAura(database, enable)
	if enable then
		updateFilters(database)
		local dispellList, purgeList = core.DispellList[E.myclass], core.PurgeList[E.myclass]
		function mod:PostUpdateAura(unit, button)
			local attackable = UnitCanAttack('player', unit) == 1
			local isDebuff = button.isDebuff

			if isDebuff then
				if database.SaturatedDebuffs.enabled then
					button.icon:SetDesaturated(false)
				end
				if database.TypeBorders.enabled then
					button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
				end
			end

			local unitType = attackable and 'ENEMY' or 'FRIENDLY'
			local db = database.Highlights.types[unitType]

			if not db.enabled then return end

			local name, dtype, debuffType, spellID = button.name, button.dtype, button.debuffType, button.spellID
			local unstableAffliction = GetSpellInfo(30108)
			local vampiricTouch = GetSpellInfo(34914)
			local dbSpell = db.spellList[spellID]
			if dbSpell then
				local settings = (dbSpell.shadow or dbSpell.border or dbSpell.useGlobal) and (dbSpell.useGlobal and db.global or dbSpell)
				if not settings then
					mod:HandleCurableStealable(db.special, button, unit, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name, dispellList, purgeList)
				else
					mod:ApplyHighlight(settings, button)
				end
			elseif checkFilters[unitType][isDebuff or false] then
				local parent = button:GetParent()
				if not parent then return end
				local grandParent = button:GetParent():GetParent()
				if not grandParent then return end
				local isPlayer, caster, duration = button.isPlayer, button.owner, button.duration
				local isUnit = unit and caster and UnitIsUnit(unit, caster)
				local db_type = grandParent.db[parent.type]
				local noDuration = (not duration or duration == 0)
				local allowDuration = noDuration
										or (duration and (duration > 0)
											and (db_type.maxDuration == 0 or duration <= db_type.maxDuration)
											and (db_type.minDuration == 0 or duration >= db_type.minDuration))
				local canDispell = (parent.type == "buffs" and button.isStealable) or (parent.type == "debuffs" and debuffType and E:IsDispellableByMe(debuffType))
				for _, data in ipairs(filterList[unitType][isDebuff or false]) do
					if UF:CheckFilter(name, caster, spellID, not attackable, isPlayer, isUnit, allowDuration, noDuration, canDispell, data.filterName) then
						if data.border or data.shadow then
							mod:ApplyHighlight(data.info, button)
						elseif button.highlightApplied then
							mod:ClearHighlights(button, isDebuff, debuffType, unstableAffliction, vampiricTouch)
						end
						return
					end
				end
				mod:HandleCurableStealable(db.special, button, unit, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name, dispellList, purgeList)
			else
				mod:HandleCurableStealable(db.special, button, unit, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name, dispellList, purgeList)
			end
		end
		if not self:IsHooked(UF, "PostUpdateAura") then self:SecureHook(UF, "PostUpdateAura", self.PostUpdateAura) end
		self.initialized['highlights'] = true
	elseif self.initialized['highlights'] then
		if self:IsHooked(UF, "PostUpdateAura") then self:Unhook(UF, "PostUpdateAura") end
	end
	if not self.initialized['highlights'] then return end

	for _, frame in ipairs(core:AggregateUnitFrames()) do
		for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
			if frame[auraType] and frame[auraType].db and frame[auraType].db.enable then
				frame[auraType].PostUpdateIcon = UF.PostUpdateAura
				-- hide leftover shadows
				for _, button in ipairs({frame[auraType]:GetChildren()}) do
					frame[auraType]:PostUpdateIcon(frame.unit, button)
					if button.shadow then
						button.shadow:Hide()
						button.shadow = nil
					end
					button.highlightApplied = nil
				end
			end
		end
	end
end


function mod:Toggle(db)
	if core.reload then
		self:UpdateCenteredAuras(db)
		self:UpdateClickCancel(db)
		self:UpdatePostUpdateAura(db, false)
	else
		self:UpdateSortMethods(db)
		self:UpdateCenteredAuras(db)
		self:UpdateClickCancel(db)
		local enabled = false
		if not core.reload then
			for _, subMod in pairs({'TypeBorders', 'SaturatedDebuffs'}) do
				if db[subMod].enabled then
					enabled = true
					break
				end
			end
			if not enabled then
				for _, info in pairs(db.Highlights.types) do
					if info.enabled then enabled = true break end
				end
			end
		end
		self:UpdatePostUpdateAura(db, enabled)
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback