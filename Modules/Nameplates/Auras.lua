local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("AurasNP", "AceHook-3.0")
local NP = E:GetModule("NamePlates")
local LAI = E.Libs.LAI
local LSM = E.Libs.LSM

local modName = mod:GetName()

local pairs, ipairs, unpack, type, tonumber, tostring = pairs, ipairs, unpack, type, tonumber, tostring
local tinsert, tsort, twipe = table.insert, table.sort, table.wipe
local floor, ceil, min, abs = math.floor, math.ceil, math.min, math.abs
local find, gmatch, match, gsub, format = string.find, string.gmatch, string.match, string.gsub, string.format
local GetTime, DebuffTypeColor, UnitCanAttack, GetSpellInfo, GetSpellLink, CreateFrame = GetTime, DebuffTypeColor, UnitCanAttack, GetSpellInfo, GetSpellLink, CreateFrame

local dispellList, purgeList = core.DispellList[E.myclass], core.PurgeList[E.myclass]
local filterList, checkFilters = {["FRIENDLY"] = {}, ["ENEMY"] = {}}, {}

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

local funcMap = {
	["UpdateTime"] = 'AnimateFadeOut',
	["UpdateElement_Auras"] = 'CenteredAuras',
	["Update_AurasPosition"] = 'CenteredAuras',
	["SetAura"] = 'TypeBorders, Highlights, CooldownDisable',
}

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
		NP.OnShow(plate:GetParent(), nil, true)
	end
end


P["Extras"]["nameplates"][modName] = {
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


local directionProperties = {
	["CENTER"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
		growthX = 1,
	},
	["TOP"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
		growthX = 1,
	},
	["BOTTOM"] = {
		isVertical = true,
		isReverse = true,
		firstInRowPoint = 'TOP',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'TOP',
		growthX = 1,
	},
	["LEFT"] = {
		isVertical = false,
		firstInRowPoint = 'RIGHT',
		subsequentPoint = 'TOPRIGHT',
		framePoint = 'RIGHT',
		growthX = 1,
	},
	["RIGHT"] = {
		isVertical = false,
		isReverse = true,
		firstInRowPoint = 'LEFT',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'LEFT',
		growthX = 1,
	},
	["TOPLEFT"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
		growthX = 1,
	},
	["TOPRIGHT"] = {
		isVertical = true,
		firstInRowPoint = 'BOTTOM',
		subsequentPoint = 'BOTTOMLEFT',
		framePoint = 'BOTTOM',
		growthX = -1,
	},
	["BOTTOMLEFT"] = {
		isVertical = true,
		isReverse = true,
		firstInRowPoint = 'TOP',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'TOP',
		growthX = 1,
	},
	["BOTTOMRIGHT"] = {
		isVertical = true,
		isReverse = true,
		firstInRowPoint = 'TOP',
		subsequentPoint = 'TOPLEFT',
		framePoint = 'TOP',
		growthX = -1,
	}
}

function mod:CenterAlignAuras(frame, db)
	local aurasFrame = frame
	local offset, spacing, perRow = db.size + db.spacing, db.spacing, db.perrow
	local numElements = aurasFrame.type == 'debuffs' and aurasFrame.visibleDebuffs or aurasFrame.visibleBuffs

	local anchorPoint = db.anchorPoint
	local points = directionProperties[anchorPoint]
	local isVertical = points.isVertical
	local isReverse = points.isReverse
	local firstInRowPoint = points.firstInRowPoint
	local subsequentPoint = points.subsequentPoint
	local framePoint = points.framePoint
	local growthX = points.growthX

	for i = 1, numElements do
		local child = frame[i]
		if child then
			child:ClearAllPoints()
			if i == (perRow * floor(i / perRow) + 1) then
				local numOtherRow = min(perRow, (numElements - (perRow * floor(i / perRow))))
				local OtherRowSize = (numOtherRow * offset)
				local xOffset = (isVertical and -(OtherRowSize - offset) / 2 or ((isReverse and 1 or -1) * offset * floor(i / perRow))) * growthX
				local yOffset = isVertical and ((isReverse and -1 or 1) * offset * floor(i / perRow)) or -(OtherRowSize - offset) / 2
				child:Point(firstInRowPoint, aurasFrame, framePoint, xOffset, yOffset)
				anchorPoint = child
			else
				local xOffset = (isVertical and offset or 0) * growthX
				local yOffset = isVertical and 0 or offset
				child:Point(subsequentPoint, anchorPoint, subsequentPoint, xOffset, yOffset)
				anchorPoint = child
			end
		end
	end

	local numRows = ceil(numElements / perRow)
    local maxWidth = min(numElements, perRow) * offset - spacing
    local maxHeight = numRows * offset - spacing

	if isVertical then
        aurasFrame:Size(maxWidth, maxHeight)
    else
        aurasFrame:Size(maxHeight, maxWidth)
    end
end

function mod:Update_AurasPosition(frame, db)
	mod:CenterAlignAuras(frame, db)
end

function mod:UpdateElement_Auras(frame)
	if not frame.Health:IsShown() then return end

	local db = NP.db.units[frame.UnitType].buffs
	if db.enable and not (frame.UnitTrivial and NP.db.trivial) then
		if frame.Buffs.visibleBuffs and frame.Buffs.visibleBuffs > 0 then
			mod:CenterAlignAuras(frame.Buffs, db)
		end
	end
	db = NP.db.units[frame.UnitType].debuffs
	if db.enable and not (frame.UnitTrivial and NP.db.trivial) then
		if frame.Debuffs.visibleDebuffs and frame.Debuffs.visibleDebuffs > 0 then
			mod:CenterAlignAuras(frame.Debuffs, db)
		end
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
	for func, enable in pairs(toggles) do
		if enable then
			if not self:IsHooked(NP, func) then self:SecureHook(NP, func, self[func]) end
		elseif self:IsHooked(NP, func) then
			self:Unhook(NP, func)
			NP:ForEachPlate("UpdateAllFrame", true, true)
		end
	end
	updateVisiblePlates(db)
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback