local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("AurasUF", "AceHook-3.0")
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM

local modName = mod:GetName()

local _G, unpack, pairs, ipairs, select, tonumber, type = _G, unpack, pairs, ipairs, select, tonumber, type
local match, format, gsub, find = string.match, string.format, string.gsub, string.find
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local tinsert, tcontains = table.insert, tContains
local UnitIsUnit, CancelUnitBuff, UnitCanAttack = UnitIsUnit, CancelUnitBuff, UnitCanAttack
local DebuffTypeColor, GetSpellInfo, GetSpellLink = DebuffTypeColor, GetSpellInfo, GetSpellLink

local function centerAuras(_, frame)
	for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
		if frame[auraType] and frame[auraType].db.enable and frame[auraType].PostUpdate and frame[auraType]['visible'..auraType] then
			frame[auraType]:PostUpdate()
		end
	end
end

P["Extras"]["unitframes"][modName] = {
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

function mod:LoadConfig()
	local function selectedType() return E.db.Extras.unitframes[modName].Highlights.selectedType end
	local function selectedSpellorFilter() return E.db.Extras.unitframes[modName].Highlights.types[selectedType()].selected end
	local function getHighlightSettings(selectedType, spellOrFilter)
		local db = E.db.Extras.unitframes[modName].Highlights.types[selectedType]
		if spellOrFilter == "GLOBAL" then
			return db.global
		elseif spellOrFilter == "CURABLE" or spellOrFilter == "STEALABLE" then
			return db.special
		elseif type(spellOrFilter) == 'number' then
			return db.spellList[spellOrFilter].useGlobal and db.global or db.spellList[spellOrFilter]
		elseif db.filterList[spellOrFilter] then
			return db.filterList[spellOrFilter].useGlobal and db.global or db.filterList[spellOrFilter]
		end
		return db.global
	end
	core.unitframes.args[modName] = {
		type = "group",
		name = L["Auras"],
		get = function(info) return E.db.Extras.unitframes[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) E.db.Extras.unitframes[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] = value self:Toggle() UF:Update_AllFrames() end,
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
						get = function() return E.db.Extras.unitframes[modName].Highlights.types[selectedType()].enabled end,
						set = function(_, value) E.db.Extras.unitframes[modName].Highlights.types[selectedType()].enabled = value self:UpdatePostUpdateAura(value) UF:Update_AllFrames() end,
					},
					typeDropdown = {
						order = 2,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function() return E.db.Extras.unitframes[modName].Highlights.selectedType end,
						set = function(_, value) E.db.Extras.unitframes[modName].Highlights.selectedType = value end,
						values = function() return core:GetUnitDropdownOptions(E.db.Extras.unitframes[modName].Highlights.types) end,
					},
				},
			},
			highlightSettings = {
				order = 2,
				type = "group",
				name = L["Highlights Settings"],
				guiInline = true,
				disabled = function() return not E.db.Extras.unitframes[modName].Highlights.types[selectedType()].enabled end,
				hidden = function() return not E.db.Extras.unitframes[modName].Highlights.types[selectedType()].enabled end,
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
								E.db.Extras.unitframes[modName].Highlights.types[selectedType()].spellList[tonumber(spellID)] = {
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
								core:print('ADDED', string)
							end
							UF:Update_AllFrames()
						end,
					},
					addFilter = {
						order = 2,
						type = "select",
						name = L["Add Filter"],
						desc = L["Aplies highlights to all auras passing the selected filter."],
						values = function()
							local filters = {}
							for filterName in pairs(E.global.unitframe.aurafilters) do
								if filterName ~= 'Blacklist' then
									filters[filterName] = filterName
								end
							end
							return filters
						end,
						get = function() return "" end,
						set = function(_, value)
							E.db.Extras.unitframes[modName].Highlights.types[selectedType()].filterList[value] = {
								["border"] = false,
								["shadow"] = false,
								["useGlobal"] = false,
								["size"] = 3,
								["color"] = { 0.93, 0.91, 0.55, 1 },
								["shadowColor"] = { 0.93, 0.91, 0.55, 1 },
							}
							core:print('ADDED', value, L[" filter added."])
							UF:Update_AllFrames()
						end,
					},
					removeSelected = {
						order = 3,
						type = "execute",
						name = L["Remove Selected"],
						desc = "",
						func = function()
							local selected = selectedSpellorFilter()
							local db = E.db.Extras.unitframes[modName].Highlights.types[selectedType()]
							if type(selected) == 'number' then
								db.spellList[selected] = nil
								local _, _, icon = GetSpellInfo(selected)
								local link = GetSpellLink(selected)
								icon = gsub(icon, '\124', '\124\124')
								local string = '\124T' .. icon .. ':16:16\124t' .. link
								core:print('REMOVED', string)
							else
								db.filterList[selected] = nil
								core:print('REMOVED', selected, L[" filter removed."])
							end
							db.selected = "GLOBAL"
							UF:Update_AllFrames()
						end,
						disabled = function() return selectedSpellorFilter() == "GLOBAL" or selectedSpellorFilter() == "CURABLE" or selectedSpellorFilter() == "STEALABLE" end,
					},
					spellOrFilterDropdown = {
						order = 4,
						type = "select",
						name = L["Select Spell or Filter"],
						desc = L["Priority: spell, filter, curable/stealable."],
						get = function() return selectedSpellorFilter() end,
						set = function(_, value)
							if (value == '--filters--' or value == '--spells--') then value = 'GLOBAL' end
							E.db.Extras.unitframes[modName].Highlights.types[selectedType()].selected = value
						end,
						values = function()
							local effectType = selectedType() == 'FRIENDLY' and "CURABLE" or "STEALABLE"
							local values = {
								["GLOBAL"] = L["GLOBAL"],
								[effectType] = L[effectType],
								["--filters--"] = L["--Filters--"],
							}
							for filter in pairs(E.db.Extras.unitframes[modName].Highlights.types[selectedType()].filterList) do
								values[filter] = filter
							end
							values["--spells--"] = L["--Spells--"]
							for spellID in pairs(E.db.Extras.unitframes[modName].Highlights.types[selectedType()].spellList) do
								local name, _, icon = GetSpellInfo(spellID)
								icon = icon and "|T"..icon..":0|t" or ""
								values[spellID] = format("%s %s (%s)", icon, name or "", spellID)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {"GLOBAL", selectedType() == 'FRIENDLY' and "CURABLE" or "STEALABLE", "--filters--"}
							for filter in pairs(E.db.Extras.unitframes[modName].Highlights.types[selectedType()].filterList) do
								tinsert(sortedKeys, filter)
							end
							tinsert(sortedKeys, "--spells--")
							for spellID in pairs(E.db.Extras.unitframes[modName].Highlights.types[selectedType()].spellList) do
								tinsert(sortedKeys, spellID)
							end
							return sortedKeys
						end,
					},
					useGlobal = {
						order = 5,
						type = "toggle",
						name = L["Use Global Settings"],
						desc = L["If toggled, the GLOBAL Spell or Filter entry values would be used."],
						get = function()
							local selected = selectedSpellorFilter()
							local db = E.db.Extras.unitframes[modName].Highlights.types[selectedType()]
							local target = type(selected) == 'number' and db.spellList[selected] or db.filterList[selected]
							return selected == 'GLOBAL' or selected == 'CURABLE' or selected == 'STEALABLE' or target.useGlobal
						end,
						set = function(_, value)
							local selected = selectedSpellorFilter()
							local db = E.db.Extras.unitframes[modName].Highlights.types[selectedType()]
							local target = type(selected) == 'number' and db.spellList[selected] or db.filterList[selected]
							target.useGlobal = value
							UF:Update_AllFrames()
						end,
						hidden = function() return selectedSpellorFilter() == "GLOBAL" or selectedSpellorFilter() == "CURABLE" or selectedSpellorFilter() == "STEALABLE" end,
						disabled = function() return selectedSpellorFilter() == "GLOBAL" or selectedSpellorFilter() == "CURABLE" or selectedSpellorFilter() == "STEALABLE" end,
					},
				},
			},
			highlightValues = {
				order = 3,
				type = "group",
				name = L["Selected Spell or Filter Values"],
				inline = true,
				disabled = function() return not E.db.Extras.unitframes[modName].Highlights.types[selectedType()].enabled end,
				hidden = function() return not E.db.Extras.unitframes[modName].Highlights.types[selectedType()].enabled end,
				get = function(info) return getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]] end,
				set = function(info, value)
					getHighlightSettings(selectedType(), selectedSpellorFilter())[info[#info]] = value
					UF:Update_AllFrames()
				end,
				args = {
					shadow = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Enable Shadow"],
						desc = "",
					},
					size = {
						order = 2,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 1, max = 20, step = 1,
						hidden = function() return not getHighlightSettings(selectedType(), selectedSpellorFilter()).shadow end,
					},
					shadowColor = {
						order = 3,
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
						order = 4,
						type = "toggle",
						name = L["Enable Border"],
						desc = "",
					},
					color = {
						order = 5,
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
	if not E.db.Extras.unitframes[modName].Highlights.types['ENEMY'] then
		E.db.Extras.unitframes[modName].Highlights.types['ENEMY'] = CopyTable(E.db.Extras.unitframes[modName].Highlights.types['FRIENDLY'])
	end
end


function mod:UpdateCenteredAuras(enable)
	local function locals(self)
		local parent = self:GetParent()
		local db = parent.db
		local buffs = parent.Buffs
		local debuffs = parent.Debuffs
		local numBuffs = self.visibleBuffs
		local numDebuffs = self.visibleDebuffs
		local offsetb = (buffs.size + buffs.spacing)
		local offsetd = (debuffs.size + debuffs.spacing)
		local perRowb = db.buffs.perrow
		local perRowd = db.debuffs.perrow
		local numRowsb = db.buffs.numrows
		local numRowsd = db.debuffs.numrows

		return buffs, debuffs, numDebuffs, numBuffs, offsetb, offsetd, perRowb, perRowd, numRowsb, numRowsd
	end

	local directionProperties = {
		["CENTER"] = {
			isVertical = true,
			firstInRowPoint = 'BOTTOM',
			subsequentPoint = 'BOTTOMLEFT',
			framePoint = 'BOTTOM'
		},
		["TOP"] = {
			isVertical = true,
			firstInRowPoint = 'BOTTOM',
			subsequentPoint = 'BOTTOMLEFT',
			framePoint = 'BOTTOM'
		},
		["BOTTOM"] = {
			isVertical = true,
			isReverse = true,
			firstInRowPoint = 'TOP',
			subsequentPoint = 'TOPLEFT',
			framePoint = 'TOP'
		},
		["LEFT"] = {
			isVertical = false,
			firstInRowPoint = 'RIGHT',
			subsequentPoint = 'TOPRIGHT',
			framePoint = 'RIGHT'
		},
		["RIGHT"] = {
			isVertical = false,
			isReverse = true,
			firstInRowPoint = 'LEFT',
			subsequentPoint = 'TOPLEFT',
			framePoint = 'LEFT'
		},
		["TOPLEFT"] = {
			isVertical = true,
			firstInRowPoint = 'BOTTOM',
			subsequentPoint = 'BOTTOMLEFT',
			framePoint = 'BOTTOM'
		},
		["TOPRIGHT"] = {
			isVertical = true,
			firstInRowPoint = 'BOTTOM',
			subsequentPoint = 'BOTTOMLEFT',
			framePoint = 'BOTTOM'
		},
		["BOTTOMLEFT"] = {
			isVertical = true,
			isReverse = true,
			firstInRowPoint = 'TOP',
			subsequentPoint = 'TOPLEFT',
			framePoint = 'TOP'
		},
		["BOTTOMRIGHT"] = {
			isVertical = true,
			isReverse = true,
			firstInRowPoint = 'TOP',
			subsequentPoint = 'TOPLEFT',
			framePoint = 'TOP'
		}
	}

	function mod:CenterAlignAuras(frame, numElements, perRow, offset)
		if not numElements or perRow == 1 then return end

		local anchorPoint = frame.anchorPoint
		local isVertical = directionProperties[anchorPoint].isVertical
		local isReverse = directionProperties[anchorPoint].isReverse
		local firstInRowPoint = directionProperties[anchorPoint].firstInRowPoint
		local subsequentPoint = directionProperties[anchorPoint].subsequentPoint
		local framePoint = directionProperties[anchorPoint].framePoint

		for i = 1, numElements do
			local child = frame[i]
			if child then
				child:ClearAllPoints()
				if i == (perRow * floor(i / perRow) + 1) then
					local numOtherRow = min(perRow, (numElements - (perRow * floor(i / perRow))))
					local OtherRowSize = (numOtherRow * offset)
					local xOffset = isVertical and -(OtherRowSize - offset) / 2 or ((isReverse and 1 or -1) * offset * floor(i / perRow))
					local yOffset = isVertical and ((isReverse and -1 or 1) * offset * floor(i / perRow)) or -(OtherRowSize - offset) / 2
					child:Point(firstInRowPoint, frame, framePoint, xOffset, yOffset)
					anchorPoint = child
				else
					local xOffset = isVertical and offset or 0
					local yOffset = isVertical and 0 or offset
					child:Point(subsequentPoint, anchorPoint, subsequentPoint, xOffset, yOffset)
					anchorPoint = child
				end
			end
		end

		local spacing = frame.spacing
		local numRows = ceil(numElements/perRow)
		local width = max(offset, offset * min(perRow, numElements) - spacing)
		local height = max(offset, offset * numRows - spacing)

		frame:Size(isVertical and width or height, isVertical and height or width)

		if frame.auraBarsHolder then
			frame.auraBarsHolder:Height(isVertical and height or width)
		end
	end

	function mod:UpdateBuffsHeaderPosition()
		local buffs, debuffs, numDebuffs, numBuffs, offsetb, offsetd, perRowb, perRowd = locals(self)
		if not numDebuffs or numDebuffs == 0 then
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		else
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		end
	end

	function mod:UpdateDebuffsHeaderPosition()
		local buffs, debuffs, numDebuffs, numBuffs, offsetb, offsetd, perRowb, perRowd = locals(self)
		if not numBuffs or numBuffs == 0 then
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
		else
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		end
	end

	function mod:UpdateBuffsPositionAndDebuffHeight()
		local buffs, debuffs, numDebuffs, numBuffs, offsetb, offsetd, perRowb, perRowd = locals(self)
		if not numDebuffs or numDebuffs == 0 then
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		else
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		end
	end

	function mod:UpdateDebuffsPositionAndBuffHeight()
		local buffs, debuffs, numDebuffs, numBuffs, offsetb, offsetd, perRowb, perRowd = locals(self)
		if not numBuffs or numBuffs == 0 then
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
		else
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		end
	end

	function mod:UpdateBuffsHeight()
		local buffs, _, _, numBuffs, offsetb, _, perRowb = locals(self)
		if numBuffs and numBuffs > 0 then
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		end
	end

	function mod:UpdateDebuffsHeight()
		local _, debuffs, numDebuffs, _, _, offsetd, _, perRowd = locals(self)
		if numDebuffs and numDebuffs > 0 then
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
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
		if not frame.VARIABLES_SET then return end

		local auraBars = frame.AuraBars
		local db = frame.db
		if db.aurabar.enable then

			local numElements, perRow, attachTo
			if db.aurabar.attachTo == "BUFFS" then
				attachTo = frame.Buffs
				numElements = attachTo.visibleBuffs or 0
				perRow = db.buffs.perrow
			elseif db.aurabar.attachTo == "DEBUFFS" then
				attachTo = frame.Debuffs
				numElements = attachTo.visibleDebuffs or 0
				perRow = db.debuffs.perrow
			end

			if not attachTo then return end

			local anchorPoint, anchorTo = "BOTTOM", "TOP"
			if db.aurabar.anchorPoint == "BELOW" then
				anchorPoint, anchorTo = "TOP", "BOTTOM"
			end

			local offset = attachTo.size + attachTo.spacing
			local width = offset * max(1, perRow) - attachTo.spacing
			local height = offset * max(1, numElements) - attachTo.spacing

			attachTo.auraBarsHolder = attachTo.auraBarsHolder or CreateFrame("Frame")
			attachTo.auraBarsHolder:ClearAllPoints()
			attachTo.auraBarsHolder:Point(anchorPoint, attachTo, anchorPoint, 0, 0)
			attachTo.auraBarsHolder:Width(width, height)

			mod:CenterAlignAuras(attachTo, numElements, perRow, offset)

			attachTo = attachTo.auraBarsHolder

			local yOffset
			local spacing = (((db.aurabar.attachTo == "FRAME" and 3) or (db.aurabar.attachTo == "PLAYER_AURABARS" and 4) or 2) * frame.SPACING)
			local border = (((db.aurabar.attachTo == "FRAME" or db.aurabar.attachTo == "PLAYER_AURABARS") and 2 or 1) * frame.BORDER)

			if db.aurabar.anchorPoint == "BELOW" then
				yOffset = -spacing + border - (not db.aurabar.yOffset and 0 or db.aurabar.yOffset)
			else
				yOffset = spacing - border + (not db.aurabar.yOffset and 0 or db.aurabar.yOffset)
			end

			local xOffset = (db.aurabar.attachTo == "FRAME" and frame.SPACING or 0)
			local offsetLeft = xOffset + ((db.aurabar.attachTo == "FRAME" and ((anchorTo == "TOP" and frame.ORIENTATION ~= "LEFT") or (anchorTo == "BOTTOM" and frame.ORIENTATION == "LEFT"))) and frame.POWERBAR_OFFSET or 0)
			local offsetRight = -xOffset - ((db.aurabar.attachTo == "FRAME" and ((anchorTo == "TOP" and frame.ORIENTATION ~= "RIGHT") or (anchorTo == "BOTTOM" and frame.ORIENTATION == "RIGHT"))) and frame.POWERBAR_OFFSET or 0)

			auraBars:ClearAllPoints()
			auraBars:Point(anchorPoint.."LEFT", attachTo, anchorTo.."LEFT", offsetLeft, yOffset)
			auraBars:Point(anchorPoint.."RIGHT", attachTo, anchorTo.."RIGHT", offsetRight, yOffset)
			auraBars:SetAnchors()
		end
	end

	function mod:UpdateFrame(frame, db)
		local buffs = frame.Buffs
		local debuffs = frame.Debuffs
		local numBuffs = buffs.visibleBuffs
		local numDebuffs = debuffs.visibleDebuffs
		local offsetb = (buffs.size + buffs.spacing)
		local offsetd = (debuffs.size + debuffs.spacing)
		local perRowb = db.buffs.perrow
		local perRowd = db.debuffs.perrow

		if numDebuffs and numDebuffs > 0 then
			mod:CenterAlignAuras(debuffs, numDebuffs, perRowd, offsetd)
		end

		if numBuffs and numBuffs > 0 then
			mod:CenterAlignAuras(buffs, numBuffs, perRowb, offsetb)
		end
	end

	if not tcontains(core.frameUpdates, centerAuras) then
		tinsert(core.frameUpdates, centerAuras)
	end

	if enable then
		for _, type in ipairs({'Configure_Auras', 'Configure_AuraBars', 'UpdateBuffsHeaderPosition', 'UpdateDebuffsHeaderPosition', 'UpdateBuffsPositionAndDebuffHeight', 'UpdateDebuffsPositionAndBuffHeight', 'UpdateDebuffsHeight', 'UpdateBuffsHeight'}) do
			if not self:IsHooked(UF, type) then self:SecureHook(UF, type, self[type]) end
		end
		for _, type in ipairs({'Update_PlayerFrame', 'Update_TargetFrame', 'Update_FocusFrame', 'Update_PetFrame'}) do
			if not self:IsHooked(UF, type) then self:SecureHook(UF, type, self.UpdateFrame) end
		end
	else
		for _, type in ipairs({'Configure_Auras', 'Configure_AuraBars', 'UpdateBuffsHeaderPosition', 'UpdateDebuffsHeaderPosition', 'UpdateBuffsPositionAndDebuffHeight', 'UpdateDebuffsPositionAndBuffHeight', 'UpdateDebuffsHeight', 'UpdateBuffsHeight'}) do
			if self:IsHooked(UF, type) then self:Unhook(UF, type) end
		end
		for _, type in ipairs({'Update_PlayerFrame', 'Update_TargetFrame', 'Update_FocusFrame', 'Update_PetFrame'}) do
			if self:IsHooked(UF, type) then self:Unhook(UF, type) end
		end
	end
end

function mod:UpdateClickCancel(enable)
	local function RMBCancelBuff(self, button)
		button:HookScript('OnClick', function(self, button)
			if button == 'RightButton' then CancelUnitBuff("player", self:GetID()) end
		end)
	end

	if enable then
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

function mod:UpdatePostUpdateAura(enable)
	local dispellList, purgeList = core.DispellList[E.myclass], core.PurgeList[E.myclass]
	function mod:PostUpdateAura(unit, button)
		local db = E.db.Extras.unitframes[modName]

		local attackable = UnitCanAttack('player', unit) == 1
		local isDebuff = button.isDebuff

		if isDebuff then
			if db.SaturatedDebuffs.enabled then
				button.icon:SetDesaturated(false)
			end
			if db.TypeBorders.enabled then
				button:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
			end
		end

		if attackable then
			db = db.Highlights.types['ENEMY']
		else
			db = db.Highlights.types['FRIENDLY']
		end

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
		else
			local tempFilterList, checkFilters = {}
			for filterName, info in pairs(db.filterList) do
				if info.shadow or info.border or info.useGlobal then
					tempFilterList[filterName] = info.useGlobal and db.global or info
					checkFilters = true
				end
			end
			local settings
			if checkFilters then
				local parent = button:GetParent()
				if not parent then return end
				local grandParent = button:GetParent():GetParent()
				if not grandParent then return end
				local isPlayer, caster, duration = button.isPlayer, button.owner, button.duration
				local isUnit = unit and caster and UnitIsUnit(unit, caster)
				local db = grandParent.db[parent.type]
				local noDuration = (not duration or duration == 0)
				local allowDuration = noDuration or (duration and (duration > 0) and (db.maxDuration == 0 or duration <= db.maxDuration) and (db.minDuration == 0 or duration >= db.minDuration))
				local canDispell = (parent.type == "buffs" and button.isStealable) or (parent.type == "debuffs" and debuffType and E:IsDispellableByMe(debuffType))
				for filterName, db in pairs(tempFilterList) do
					if UF:CheckFilter(name, caster, spellID, not attackable, isPlayer, isUnit, allowDuration, noDuration, canDispell, filterName) then
						settings = db
						break
					end
				end
			end
			if not settings then
				mod:HandleCurableStealable(db.special, button, unit, debuffType, unstableAffliction, vampiricTouch, attackable, dtype, isDebuff, name, dispellList, purgeList)
			elseif settings.border or settings.shadow then
				mod:ApplyHighlight(settings, button)
			elseif button.highlightApplied then
				mod:ClearHighlights(button, isDebuff, debuffType, unstableAffliction, vampiricTouch)
			end
		end
	end

	if enable then
		if not self:IsHooked(UF, "PostUpdateAura") then self:SecureHook(UF, "PostUpdateAura", self.PostUpdateAura) end
	else
		if self:IsHooked(UF, "PostUpdateAura") then self:Unhook(UF, "PostUpdateAura") end
	end

	local units = core:AggregateUnitFrames()
	for _, frame in ipairs(units) do
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


function mod:Toggle()
	self:UpdateCenteredAuras(E.db.Extras.unitframes[modName].CenteredAuras.enabled)
	self:UpdateClickCancel(E.db.Extras.unitframes[modName].ClickCancel.enabled)
	local enabled = false
	for _, type in pairs({'TypeBorders', 'SaturatedDebuffs'}) do
		if E.db.Extras.unitframes[modName][type].enabled then
			enabled = true
			break
		end
	end
	if not enabled then
		for _, info in pairs(E.db.Extras.unitframes[modName].Highlights.types) do
			if info.enabled then enabled = true break end
		end
	end
	self:UpdatePostUpdateAura(enabled)
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback
