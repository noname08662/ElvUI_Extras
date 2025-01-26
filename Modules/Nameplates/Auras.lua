local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("AurasNP", "AceHook-3.0")
local NP = E:GetModule("NamePlates")
local LAI = E.Libs.LAI
local LSM = E.Libs.LSM

local modName = mod:GetName()
local iconPositions = {}

local pairs, ipairs, unpack, type, tonumber, tostring = pairs, ipairs, unpack, type, tonumber, tostring
local tinsert, tsort, twipe = table.insert, table.sort, table.wipe
local floor, ceil, min, max, abs = math.floor, math.ceil, math.min, math.max, math.abs
local find, gmatch, match, gsub, format, split = string.find, string.gmatch, string.match, string.gsub, string.format, string.split
local GetTime, DebuffTypeColor, UnitCanAttack, GetSpellInfo, GetSpellLink, CreateFrame = GetTime, DebuffTypeColor, UnitCanAttack, GetSpellInfo, GetSpellLink, CreateFrame

local dispellList, purgeList = core.DispellList[E.myclass], core.PurgeList[E.myclass]
local filterList, checkFilters = {["FRIENDLY"] = {}, ["ENEMY"] = {}}, {}


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
	}
}

local funcMap = {
	["UpdateTime"] = 'AnimateFadeOut',
	["UpdateElement_Auras"] = 'CenteredAuras, SortMethods',
	["SetAura"] = 'TypeBorders, Highlights, CooldownDisable',
}


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
    for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER", "FRIENDLY_NPC", "ENEMY_NPC"}) do
        iconPositions[unitType] = {}
        for _, auraType in ipairs({"buffs", "debuffs"}) do
            iconPositions[unitType][auraType] = { positions = {}, sizes = {} }
			local data = NP.db.units[unitType][auraType]
			local cache = iconPositions[unitType][auraType]

			if db.CenteredAuras.enabled then
				local anchorPoint = data.anchorPoint
				local points = directionProperties[anchorPoint]
				local isVertical = points.isVertical
				local isReverse = points.isReverse
				local firstInRowPoint = points.firstInRowPoint
				local subsequentPoint = points.subsequentPoint
				local framePoint = points.framePoint
				local growthX = (data.growthX == "LEFT" and -1) or 1
				local growthY = (data.growthY == "DOWN" and -1) or 1
				local offset, spacing, perRow = data.size + data.spacing, data.spacing, data.perrow

				for numElements = 1, perRow * data.numrows do
					cache.positions[numElements] = {}
					local lastAnchor = nil

					for i = 1, numElements do
						if i == (perRow * floor((i-1) / perRow) + 1) then
							local numOtherRow = min(perRow, (numElements - (perRow * floor((i-1) / perRow))))
							local OtherRowSize = (numOtherRow * offset)
							local xOffset = (isVertical and -(OtherRowSize - offset) / 2
														or ((isReverse and 1 or -1) * offset * floor((i-1) / perRow))) * growthX
							local yOffset = (isVertical and ((isReverse and -1 or 1) * offset * floor((i-1) / perRow))
														or -(OtherRowSize - offset) / 2) * growthY

							cache.positions[numElements][i] = {
								point = firstInRowPoint,
								firstInRow = true,
								relativeTo = framePoint,
								xOffset = xOffset,
								yOffset = yOffset
							}
						else
							local xOffset = (isVertical and offset or 0) * growthX
							local yOffset = (isVertical and 0 or offset) * growthY

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
			else
				local size = data.size + data.spacing
				local anchor = E.InversePoints[data.anchorPoint]
				local growthx = (data.growthX == "LEFT" and -1) or 1
				local growthy = (data.growthY == "DOWN" and -1) or 1
				local cols = data.perrow
				local maxWidth = cols * size - data.spacing
				local maxHeight = data.numrows * size - data.spacing

				for numElements = 1, cols * data.numrows do
					cache.positions[numElements] = {}

					for i = 1, numElements do
						cache.positions[numElements][i] = {
							point = anchor,
							relativeTo = anchor,
							xOffset = ((i - 1) % cols) * size * growthx,
							yOffset = (floor((i - 1) / cols)) * size * growthy
						}
					end
					cache.sizes[numElements] = {maxWidth, maxHeight}
				end
			end
			if db.SortMethods.enabled and data.filters then
				cache.filterPriority = {}
				for i, filter in ipairs({split(",", data.filters.priority)}) do
					cache.filterPriority[filter] = i
				end
				cache.sortDirection = db.SortMethods.types[unitType][auraType].sortDirection
				cache.sortMethod = db.SortMethods.types[unitType][auraType].sortMethod
			end
        end
    end
	if core.reload or (not db.CenteredAuras.enabled and not db.SortMethods.enabled) then
		if mod.ishooked then
			if E.Options and E.Options.args.nameplate then
				for _, unitGroup in pairs({["FRIENDLY_PLAYER"] = 'friendlyPlayerGroup', ["FRIENDLY_NPC"] = 'friendlyNPCGroup',
												["ENEMY_PLAYER"] = 'enemyPlayerGroup', ["ENEMY_NPC"] = 'enemyNPCGroup'}) do
					for _, auraGroup in ipairs({"buffsGroup", "debuffsGroup"}) do
						if mod:IsHooked(E.Options.args.nameplate.args[unitGroup].args[auraGroup], "set") then
							mod:Unhook(E.Options.args.nameplate.args[unitGroup].args[auraGroup], "set")
						end
						if mod:IsHooked(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup, "set") then
							mod:Unhook(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup, "set")
						end
						for _, t in pairs(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup.args) do
							if type(t) == 'table' and t.set and mod:IsHooked(t, "set") then
								mod:Unhook(t, "set")
							end
						end
					end
				end
			elseif mod:IsHooked(E, "ToggleOptionsUI") then
				mod:Unhook(E, "ToggleOptionsUI")
			end
			mod.ishooked = false
		end
	elseif not mod.ishooked then
		if E.Options and E.Options.args.nameplate then
			for unitType, unitGroup in pairs({["FRIENDLY_PLAYER"] = 'friendlyPlayerGroup', ["FRIENDLY_NPC"] = 'friendlyNPCGroup',
											["ENEMY_PLAYER"] = 'enemyPlayerGroup', ["ENEMY_NPC"] = 'enemyNPCGroup'}) do
				for auraType, auraGroup in pairs({["buffs"] = 'buffsGroup', ["debuffs"] = 'debuffsGroup'}) do
					if not mod:IsHooked(E.Options.args.nameplate.args[unitGroup].args[auraGroup], "set") then
						mod:RawHook(E.Options.args.nameplate.args[unitGroup].args[auraGroup], "set", function(info, value)
							E.db.nameplates.units[unitType][auraType][info[#info]] = value
							cachePositions(db)
							mod.hooks[E.Options.args.nameplate.args[unitGroup].args[auraGroup]].set(info, value)
						end)
					end
					if db.SortMethods.enabled then
						if not mod:IsHooked(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup, "set") then
							mod:SecureHook(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup, "set", function()
								cachePositions(db)
								NP:ConfigureAll()
							end)
						end
						for _, t in pairs(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup.args) do
							if type(t) == 'table' and t.set and not mod:IsHooked(t, "set") then
								mod:SecureHook(t, "set", function()
									cachePositions(db)
									NP:ConfigureAll()
								end)
							end
						end
					end
				end
			end
		elseif not mod:IsHooked(E, "ToggleOptionsUI") then
			mod:SecureHook(E, "ToggleOptionsUI", function()
				if E.Options.args.nameplate then
					for unitType, unitGroup in pairs({["FRIENDLY_PLAYER"] = 'friendlyPlayerGroup', ["FRIENDLY_NPC"] = 'friendlyNPCGroup',
													["ENEMY_PLAYER"] = 'enemyPlayerGroup', ["ENEMY_NPC"] = 'enemyNPCGroup'}) do
						for auraType, auraGroup in pairs({["buffs"] = 'buffsGroup', ["debuffs"] = 'debuffsGroup'}) do
							if not mod:IsHooked(E.Options.args.nameplate.args[unitGroup].args[auraGroup], "set") then
								mod:RawHook(E.Options.args.nameplate.args[unitGroup].args[auraGroup], "set", function(info, value)
									E.db.nameplates.units[unitType][auraType][info[#info]] = value
									cachePositions(db)
									mod.hooks[E.Options.args.nameplate.args[unitGroup].args[auraGroup]].set(info, value)
								end)
							end
							if db.SortMethods.enabled then
								if not mod:IsHooked(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup, "set") then
									mod:SecureHook(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup, "set", function()
										cachePositions(db)
										NP:ConfigureAll()
									end)
								end
								for _, t in pairs(E.Options.args.nameplate.args[unitGroup].args[auraGroup].args.filtersGroup.args) do
									if type(t) == 'table' and t.set and not mod:IsHooked(t, "set") then
										mod:SecureHook(t, "set", function()
											cachePositions(db)
											NP:ConfigureAll()
										end)
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

local function updateVisiblePlates(mod_db)
	for plate in pairs(NP.VisiblePlates) do
		for auraType, AuraType in pairs({buffs = 'Buffs', debuffs = 'Debuffs'}) do
			local db = NP.db.units[plate.UnitType][auraType]
			if db.enable then
				local frame = plate[AuraType]
				for _, button in ipairs(frame) do
					button:SetAlpha(1)
					if button.bg:GetAlpha() == 0 then
						if db.reverseCooldown then
							button:SetStatusBarColor(0, 0, 0, 0.5)
							button.bg:SetTexture(0, 0, 0, 0)
						else
							button:SetStatusBarColor(0, 0, 0, 0)
							button.bg:SetTexture(0, 0, 0, 0.5)
						end
						button.bg:SetAlpha(1)
					end
					if button.highlightApplied then
						mod:ClearHighlights(mod_db, button, false, nil)
					end
				end
			end
		end
		NP:UpdateAllFrame(plate, nil, true)
	end
end


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


P["Extras"]["nameplates"][modName] = {
	["SortMethods"] = {
		["enabled"] = false,
		["selectedType"] = "ENEMY_NPC",
		["selectedAuraType"] = "buffs",
		["types"] = {
			["ENEMY_NPC"] = {
				["buffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
				["debuffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
			},
			["ENEMY_PLAYER"] = {
				["buffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
				["debuffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
			},
			["FRIENDLY_NPC"] = {
				["buffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
				["debuffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
			},
			["FRIENDLY_PLAYER"] = {
				["buffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
				["debuffs"] = {
					["sortDirection"] = "DESCENDING",
					["sortMethod"] = "TIME_REMAINING",
				},
			},
		},
	},
	["CenteredAuras"] = {
		["enabled"] = false,
	},
	["CooldownDisable"] = {
		["enabled"] = false,
	},
	["AnimateFadeOut"] = {
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
	local function selectedSortType() return db.SortMethods.selectedType end
	local function selectedSortAuraType() return db.SortMethods.selectedAuraType end
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
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Auras"],
		get = function(info) return db[info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) db[info[#info-1]][gsub(info[#info], info[#info-1], '')] = value self:Toggle(db) end,
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
						set = function(_, value) db.Highlights.types[selectedType()].enabled = value self:Toggle(db) end,
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
									["priority"] = 1,
								}
								local _, _, icon = GetSpellInfo(spellID)
								local link = GetSpellLink(spellID)
								icon = gsub(icon, '\124', '\124\124')
								local string = '\124T' .. icon .. ':16:16\124t' .. link
								core:print('ADDED', string)
							end
							updateVisiblePlates(db)
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
							}
							core:print('ADDED', value, L[" filter added."])
							updateVisiblePlates(db)
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
							updateVisiblePlates(db)
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
								core:print('REMOVED', selected, L[" filter removed."])
							end
							data.selected = "GLOBAL"
							updateFilters(db)
							updateVisiblePlates(db)
						end,
						hidden = function()
							return selectedSpellorFilter() == "GLOBAL"
									or selectedSpellorFilter() == "CURABLE"
									or selectedSpellorFilter() == "STEALABLE" end,
					},
					useGlobal = {
						order = 5,
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
							updateVisiblePlates(db)
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
					updateVisiblePlates(db)
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
							updateVisiblePlates(db)
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
							updateVisiblePlates(db)
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
						order = 1,
						type = "toggle",
						width = "full",
						name = core.pluginColor..L["Enable"],
						desc = L["Makes aura sorting abide filter priorities."],
					},
					selectedSortType = {
						order = 2,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function() return db.SortMethods.selectedType end,
						set = function(_, value) db.SortMethods.selectedType = value end,
						values = function()
							return {
								["ENEMY_NPC"] = L["ENEMY_NPC"],
								["ENEMY_PLAYER"] = L["ENEMY_PLAYER"],
								["FRIENDLY_NPC"] = L["FRIENDLY_NPC"],
								["FRIENDLY_PLAYER"] = L["FRIENDLY_PLAYER"],
							}
						end,
						disabled = function() return not db.SortMethods.enabled end,
					},
					selectedAuraType = {
						order = 3,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function() return db.SortMethods.selectedAuraType end,
						set = function(_, value) db.SortMethods.selectedAuraType = value end,
						values = {
							["buffs"] = L["Buffs"],
							["debuffs"] = L["Debuffs"],
						},
						disabled = function() return not db.SortMethods.enabled end,
					},
					sortMethod = {
						order = 4,
						type = "select",
						name = function() return L["Sort By"] end,
						desc = function() return L["Method to sort by."] end,
						get = function() return db.SortMethods.types[selectedSortType()][selectedSortAuraType()].sortMethod end,
						set = function(_, value)
							db.SortMethods.types[selectedSortType()][selectedSortAuraType()].sortMethod = value
							self:Toggle(db)
						end,
						values = function()
							return {
								["TIME_REMAINING"] = L["Time Remaining"],
								["DURATION"] = L["Duration"],
								["NAME"] = L["NAME"],
								["INDEX"] = L["Index"],
								["PLAYER"] = L["PLAYER"]
							}
						end,
						disabled = function() return not db.SortMethods.enabled end,
					},
					sortDirection = {
						order = 5,
						type = "select",
						name = function() return L["Sort Direction"] end,
						desc = function() return L["Ascending or Descending order."] end,
						get = function() return db.SortMethods.types[selectedSortType()][selectedSortAuraType()].sortDirection end,
						set = function(_, value)
							db.SortMethods.types[selectedSortType()][selectedSortAuraType()].sortDirection = value
							self:Toggle(db)
						end,
						values = function()
							return {
								["ASCENDING"] = L["Ascending"],
								["DESCENDING"] = L["Descending"]
							}
						end,
						disabled = function() return not db.SortMethods.enabled end,
					},
				},
			},
			CooldownDisable = {
				type = "group",
				name = L["Cooldown Disable"],
				guiInline = true,
				args = {
					enabledCooldownDisable = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Turns off texture fill."],
					},
				},
			},
			AnimateFadeOut = {
				type = "group",
				name = L["Animate Fade-Out"],
				guiInline = true,
				args = {
					enabledAnimateFadeOut = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Makes auras flicker right before fading out."],
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


function mod:Update_AurasPosition(frame)
    local numElements = frame.type == 'debuffs' and frame.visibleDebuffs or frame.visibleBuffs

	if numElements and numElements > 0 then
		local data = iconPositions[frame:GetParent().UnitType][frame.type]
		local sortDirection = data.sortDirection

		if sortDirection then
			local sortMethod = data.sortMethod
			local filterOrder = data.filterPriority

			if filterOrder then
				local buttonFilters = {}
				local filters = E.global.unitframe.aurafilters

				for i = 1, numElements do
					local button = frame[i]
					if button then
						local filterIndex
						local name = button.name
						local spellID = button.spellID
						local isPlayer = button.isPlayer

						for filterName, index in pairs(filterOrder) do
							local filter = filters[filterName]
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
							end
						end
						buttonFilters[button] = filterIndex or 99999
					end
				end
				tsort(frame, function(a,b)
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
				tsort(frame, function(a,b)
					if not a:IsShown() then
						return false
					elseif not b:IsShown() then
						return true
					end
					return SortAurasByTime(a, b, sortDirection)
				end)
			elseif sortMethod == "NAME" then
				tsort(frame, function(a,b)
					if not a:IsShown() then
						return false
					elseif not b:IsShown() then
						return true
					end
					return SortAurasByName(a, b, sortDirection)
				end)
			elseif sortMethod == "DURATION" then
				tsort(frame, function(a,b)
					if not a:IsShown() then
						return false
					elseif not b:IsShown() then
						return true
					end
					return SortAurasByDuration(a, b, sortDirection)
				end)
			elseif sortMethod == "PLAYER" then
				tsort(frame, function(a,b)
					if not a:IsShown() then
						return false
					elseif not b:IsShown() then
						return true
					end
					return SortAurasByCaster(a, b, sortDirection)
				end)
			end
		end
		local el = 0
		for i = 1, numElements do
			local child = frame[i]
			if child then
				if child:IsShown() then
					el = el + 1
				end
			end
		end
		local points = data.positions[numElements]
		for i = 1, numElements do
			local child = frame[i]
			if child then
				local vals = points[i]
				child:ClearAllPoints()
				child:Point(vals.point, vals.firstInRow and frame or frame[vals.anchor], vals.relativeTo, vals.xOffset, vals.yOffset)
			end
		end

		frame:Size(unpack(data.sizes[numElements]))
	end
end

function mod:UpdateElement_Auras(frame)
	if not frame.Health:IsShown() then return end

	local db = NP.db.units[frame.UnitType]
	if db.buffs.enable then
		mod:Update_AurasPosition(frame.Buffs)
	end
	if db.debuffs.enable then
		mod:Update_AurasPosition(frame.Debuffs)
	end
end

function mod:UpdateTime()
	local remaining = self.timeLeft
	local progress = remaining / (self.duration)

	if progress < 0.25 and remaining < 6 then
		local f = abs(0.5 - GetTime() % 1) * 3
		self:SetAlpha(f)
	else
		self:SetAlpha(1)
	end
end


function mod:ApplyHighlight(db, button)
	if db.border then
		NP:StyleFrameColor(button, unpack(db.color))
	end
	if db.shadow then
		if not button.shadow then
			local shadow = CreateFrame("Frame", nil, button)
			button.shadow = shadow
		end
		button.shadow:SetOutside(button, db.size, db.size)
		button.shadow:SetBackdrop({edgeFile = LSM:Fetch("border", "ElvUI GlowBorder"), edgeSize = E:Scale(db.size)})
		button.shadow:SetBackdropBorderColor(unpack(db.shadowColor))
		button.shadow:Show()
	elseif button.shadow then
		button.shadow:Hide()
	end
	button.highlightApplied = true
end

function mod:ClearHighlights(mod_db, button, isDebuff, debuffType, unstableAffliction, vampiricTouch)
	if isDebuff then
		if mod_db.TypeBorders.enabled then
			NP:StyleFrameColor(button, unpack(E.media.bordercolor))
		elseif (button.name and (button.name == unstableAffliction or button.name == vampiricTouch) and E.myclass ~= "WARLOCK") then
			NP:StyleFrameColor(button, 0.05, 0.85, 0.94)
		else
			local color = (debuffType and DebuffTypeColor[debuffType]) or DebuffTypeColor.none
			NP:StyleFrameColor(button, color.r * 0.6, color.g * 0.6, color.b * 0.6)
		end
	else
		NP:StyleFrameColor(button, unpack(E.media.bordercolor))
	end
	if button.shadow then
		button.shadow:Hide()
	end
	button.highlightApplied = false
end

function mod:HandleCurableStealable(mod_db, db, button, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name)
	if (db.shadow or db.border)
		and (attackable
			or (E.myclass == "WARLOCK"
				or (name and (name ~= unstableAffliction and name ~= vampiricTouch)))) and dtype and find(dtype, '%S+') then
		if (attackable and isDebuff) or (not attackable and not isDebuff)
									or (isDebuff and not (dispellList and dispellList[dtype]))
									or (not isDebuff and not purgeList) then
			if button.highlightApplied then
				self:ClearHighlights(mod_db, button, isDebuff, debuffType, unstableAffliction, vampiricTouch)
			end
			return
		end
		self:ApplyHighlight(db, button)
	elseif button.highlightApplied then
		self:ClearHighlights(mod_db, button, isDebuff, debuffType, unstableAffliction, vampiricTouch)
	end
end

function mod:SetAura(frame, guid, index, filter, isDebuff, visible)
	local isAura, name, _, _, debuffType, _, _, _, spellID = LAI:GUIDAura(guid, index, filter)
	if isAura then
		local position = visible + 1
		local button = frame[position] or NP:Construct_AuraIcon(frame, position)
		local mod_db = E.db.Extras.nameplates[modName]

		if mod_db.CooldownDisable.enabled then
			button:SetStatusBarColor(1,1,1,0)
			button.bg:SetAlpha(0)
		end

		if isDebuff and mod_db.TypeBorders.enabled then
			NP:StyleFrameColor(button, unpack(E.media.bordercolor))
		end

		local plate = frame:GetParent()
		local parent = plate:GetParent()
		local unitType = plate.UnitType
		local attackable = parent.unit and UnitCanAttack('player', parent.unit) == 1 or (unitType and find(unitType, 'ENEMY'))

		local attackType = attackable and 'ENEMY' or 'FRIENDLY'
		local db = mod_db.Highlights.types[attackType]

		if not db.enabled then return end

		local dtype = button.dtype
		local dbSpell = db.spellList[spellID]
		local unstableAffliction = GetSpellInfo(30108)
		local vampiricTouch = GetSpellInfo(34914)
		if dbSpell then
			local settings = (dbSpell.shadow or dbSpell.border or dbSpell.useGlobal) and (dbSpell.useGlobal and db.global or dbSpell)
			if not settings then
				mod:HandleCurableStealable(mod_db, db.special, button, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name)
			else
				mod:ApplyHighlight(settings, button)
			end
		elseif checkFilters[attackType][isDebuff or false] then
			local parent = button:GetParent()
			local parentType = parent.type
			local np_db = NP.db.units[unitType][parentType]
			if np_db then
				local duration = button.duration
				local noDuration = (not duration or duration == 0)
				local allowDuration = noDuration
										or (duration and (duration > 0) and np_db.filters.maxDuration == 0 or duration <= np_db.filters.maxDuration)
											and (np_db.filters.minDuration == 0 or duration >= np_db.filters.minDuration)
				for _, data in ipairs(filterList[attackType][isDebuff or false]) do
					if NP:CheckFilter(name, spellID, button.isPlayer, allowDuration, noDuration, data.filterName) then
						if data.border or data.shadow then
							mod:ApplyHighlight(data.info, button)
						elseif button.highlightApplied then
							mod:ClearHighlights(button, isDebuff, debuffType, unstableAffliction, vampiricTouch)
						end
						return
					end
				end
				mod:HandleCurableStealable(mod_db, db.special, button, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name)
			end
		else
			mod:HandleCurableStealable(mod_db, db.special, button, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name)
		end
	end
end


function mod:Toggle(db)
	local toggles = {}
	for func, settings in pairs(funcMap) do
		toggles[func] = false
		for setting in gmatch(settings, "%a+") do
			local config = db[setting]
			if setting == 'Highlights' and (config.types['FRIENDLY'].enabled or config.types['ENEMY'].enabled) then
				updateFilters(db)
				toggles[func] = not core.reload
			elseif config.enabled then
				toggles[func] = not core.reload
			end
		end
	end
	if next(toggles) then
		cachePositions(db)
	end
	for func, enable in pairs(toggles) do
		if enable then
			if not self:IsHooked(NP, func) then self:SecureHook(NP, func, self[func]) end
		elseif self:IsHooked(NP, func) then
			self:Unhook(NP, func)
		end
	end
	if not core.reload then
		updateVisiblePlates(db)
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback