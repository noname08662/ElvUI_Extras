local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ClassificationIndicator", "AceHook-3.0", "AceEvent-3.0")

local modName = mod:GetName()

local pairs, ipairs = pairs, ipairs
local rad = math.rad
local tinsert = table.insert
local gsub, upper, find, format, match = string.gsub, string.upper, string.find, string.format, string.match
local UnitClass, UnitIsPlayer, UnitClassification = UnitClass, UnitIsPlayer, UnitClassification

mod.initialized = false

local classifications = {worldboss = {1,0.5,1}, elite = {1,1,0}, rare = {1,1,1}, rareelite = {0.5,1,1}}


P["Extras"]["unitframes"][modName] = {
	["selectedUnit"] = "target",
	["selectedTexList"] = "GENERAL",
	["selectedTexture"] = 'Skull',
	["units"] = {
		["target"] = {
			["enabled"] = false,
			["backdrop"] = false,
			["enableClasses"] = false,
			["enableNPCs"] = false,
			["selectedEnemyType"] = "elite",
			["frameRotation"] = 0,
			["frameStrata"] = 'LOW',
			["frameLevel"] = 65,
			["width"] = 24,
			["height"] = 24,
			["points"] = {
				["point"] = 'LEFT',
				["relativeTo"] = 'RIGHT',
				["xOffset"] = -12,
				["yOffset"] = 0,
			},
			["elite"] = {
				["texture"] = 'Interface\\WorldMap\\Skull_64',
				["texCoords"] = {
					["left"] = 0,
					["right"] = 1,
					["top"] = 0,
					["bottom"] = 1
				},
				["flipIndicator"] = false,
				["colorByType"] = false,
			},
		},
	},
}

function mod:LoadConfig(db)
	local function selectedUnit() return db.selectedUnit end
    local function selectedUnitData()
		return core:getSelected("unitframes", modName, format("units[%s]", selectedUnit() or ""), "target")
	end
	local function selectedEnemyData()
		return core:getSelected("unitframes", modName, format("units.%s.[%s]", selectedUnit(), selectedUnitData().selectedEnemyType or ""), "elite")
	end
	local function updateAllElements()
		local units = core:AggregateUnitFrames()
		for _, frame in ipairs(units) do
			local unitframeType = frame.unitframeType
			if frame.classificationIndicator and db.units[unitframeType] and db.units[unitframeType].enabled then
				self:UpdateElement(frame, frame.unit, db.units[unitframeType])
			end
		end
	end
	core.unitframes.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			ClassificationIndicator = {
				order = 1,
				type = "group",
				name = L["Classification Indicator"],
				guiInline = true,
				get = function(info) return selectedEnemyData()[info[#info]] end,
				set = function(info, value) selectedEnemyData()[info[#info]] = value updateAllElements() end,
				disabled = function() return not db.units[selectedUnit()].enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Enables classification indicator for the selected unit."],
						get = function() return selectedUnitData().enabled end,
						set = function(_, value) selectedUnitData().enabled = value self:Toggle(db) end,
					},
					backdrop = {
						order = 1,
						type = "toggle",
						name = L["Use Backdrop"],
						get = function(info) return selectedUnitData()[info[#info]] end,
						set = function(info, value) selectedUnitData()[info[#info]] = value updateAllElements() end,
						desc = "",
					},
					unitDropdown = {
						order = 2,
						type = "select",
						disabled = false,
						name = L["Select Unit"],
						desc = "",
						get = function() return db.selectedUnit end,
						set = function(_, value) db.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(db.units) end,
					},
					copyUnitSettings = {
						order = 3,
						type = "select",
						disabled = false,
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
					enableClasses = {
						order = 4,
						type = "toggle",
						width = "full",
						name = L["Enable Player Class Icons"],
						desc = "",
						get = function(info) return selectedUnitData()[info[#info]] end,
						set = function(info, value) selectedUnitData()[info[#info]] = value updateAllElements() end,
						hidden = function() return selectedUnit() == 'boss' end,
					},
					enableNPCs = {
						order = 5,
						type = "toggle",
						width = "full",
						name = L["Enable NPC Classification Icons"],
						desc = "",
						get = function(info) return selectedUnitData()[info[#info]] end,
						set = function(info, value) selectedUnitData()[info[#info]] = value updateAllElements() end,
						hidden = function()
							return selectedUnit() ~= 'boss' and not (find(selectedUnit(), 'target') or find(selectedUnit(), 'focus'))
						end,
					},
					unitTypeDropdown = {
						order = 6,
						type = "select",
						width = "double",
						name = L["Type"],
						desc = L["Select unit type."],
						get = function() return selectedUnitData().selectedEnemyType end,
						set = function(_, value) selectedUnitData().selectedEnemyType = value end,
						values = function()
							local list = {}
							if find(selectedUnit(), 'target') or find(selectedUnit(), 'focus') then
								if selectedUnitData().enableClasses then
									list = CopyTable(E.db.Extras.classList)
								end
								if selectedUnitData().enableNPCs then
									list.worldboss = L["World Boss"]
									list.elite = L["Elite"]
									list.rare = L["Rare"]
									list.rareelite = L["Rare Elite"]
								end
							else
								list = E.db.Extras.classList
							end
							return list
						end,
						hidden = function() return selectedUnit() == 'boss' end,
					},
					spacer = {
						order = 7,
						type = "description",
						name = " "
					},
					NPIcon = {
						order = 8,
						type = "toggle",
						name = L["Use Nameplates' Icons"],
						desc = "",
						hidden = function()
							return not (find(selectedUnit(), 'target') or find(selectedUnit(), 'focus') or selectedUnit() == 'boss')
						end,
					},
					colorByType = {
						order = 9,
						type = "toggle",
						name = L["Color by Type"],
						desc = L["Color enemy NPC icon based on the unit type."],
						hidden = function()
							return not (find(selectedUnit(), 'target') or find(selectedUnit(), 'focus') or selectedUnit() == 'boss')
						end,
					},
					texListSelector = {
						order = 10,
						type = "select",
						name = L["Texture List"],
						desc = "",
						get = function() return db.selectedTexList end,
						set = function(_, value) db.selectedTexList = value end,
						hidden = function() return selectedEnemyData().NPIcon end,
						values = {
							["CLASS"] = L["Class Icons"],
							["VECTOR"] = L["Vector Class Icons"],
							["CREST"] = L["Class Crests"],
							["SPEC"] = L["Class Spec Icons"],
							["CLASSIFICATION"] = L["Classification Textures"],
							["GENERAL"] = L["General"],
						},
					},
					texture = {
						order = 11,
						type = "select",
						name = L["Texture"],
						hidden = function() return selectedEnemyData().NPIcon end,
						values = function()
							local type = db.selectedTexList
							local list = (type == 'CLASS' and 'texClass')
										or (type == 'VECTOR' and 'texClassVector')
										or (type == 'CREST' and 'texClassCrest')
										or (type == 'SPEC'  and 'texSpec')
										or (type == 'CLASSIFICATION' and 'texClassificaion')
										or 'texGeneral'
							return core:GetIconList(E.db.Extras[list])
						end,
					},
				},
			},
			texCoords = {
				order = 2,
				type = "group",
				name = L["Texture Coordinates"],
				guiInline = true,
				get = function(info) return selectedEnemyData().texCoords[info[#info]] end,
				set = function(info, value) selectedEnemyData().texCoords[info[#info]] = value updateAllElements() end,
				disabled = function() return not selectedUnitData().enabled or selectedEnemyData().NPIcon end,
				args = {
					left = {
						order = 1,
						type = "range",
						min = 0, max = 1, step = 0.01,
						name = L["Left"],
						desc = "",
					},
					right = {
						order = 2,
						type = "range",
						min = 0, max = 1, step = 0.01,
						name = L["Right"],
						desc = "",
					},
					top = {
						order = 3,
						type = "range",
						min = 0, max = 1, step = 0.01,
						name = L["Top"],
						desc = "",
					},
					bottom = {
						order = 4,
						type = "range",
						min = 0, max = 1, step = 0.01,
						name = L["Bottom"],
						desc = "",
					},
				},
			},
			iconVars = {
				order = 3,
				type = "group",
				name = L["Icon"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value updateAllElements() end,
				args = {
					width = {
						order = 1,
						type = "range",
						min = 1, max = 500, step = 1,
						name = L["Width"],
						desc = "",
					},
					height = {
						order = 2,
						type = "range",
						min = 1, max = 500, step = 1,
						name = L["Height"],
						desc = "",
					},
					flipIndicator = {
						order = 3,
						type = "toggle",
						name = L["Flip Icon"],
						desc = "",
						get = function(info) return selectedEnemyData()[info[#info]] end,
						set = function(info, value) selectedEnemyData()[info[#info]] = value updateAllElements() end,
						hidden = function() return selectedEnemyData().NPIcon end,
					},
					frameRotation = {
						order = 4,
						type = "range",
						min = 0, max = 360, step = 1,
						name = L["Rotate Icon"],
						desc = "",
						hidden = function() return selectedEnemyData().NPIcon end,
					},
				},
			},
			points = {
				order = 4,
				type = "group",
				name = L["Points"],
				guiInline = true,
				get = function(info) return selectedUnitData().points[info[#info]] end,
				set = function(info, value) selectedUnitData().points[info[#info]] = value updateAllElements() end,
				args = {
					point = {
						order = 1,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 2,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 3,
						type = "range",
						min = -100, max = 100, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 4,
						type = "range",
						min = -100, max = 100, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
				},
			},
			strataLevel = {
				order = 5,
				type = "group",
				name = L["Strata and Level"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value updateAllElements() end,
				args = {
					frameStrata = {
						order = 1,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
					},
					frameLevel = {
						order = 2,
						type = "range",
						min = 0, max = 200, step = 1,
						name = L["Level"],
						desc = "",
					},
				},
			},
		},
	}
	if not db.units.target.worldboss then
		for _, unitType in ipairs({'rare', 'rareelite', 'worldboss',
									'WARRIOR', 'WARLOCK', 'PRIEST', 'PALADIN', 'DRUID',
									'ROGUE', 'MAGE', 'HUNTER', 'SHAMAN', 'DEATHKNIGHT'}) do
			db.units.target[unitType] = CopyTable(db.units.target.elite)
			if upper(unitType) == unitType then
				for _, info in pairs(E.db.Extras.texClass) do
					if upper(gsub(info.label, "%s+", "")) == unitType then
						db.units.target[unitType].texture = info.icon
						break
					end
				end
			elseif unitType == 'rare' then
				db.units.target[unitType].texture = "Interface\\WorldMap\\Skull_64Grey"
			elseif unitType == 'rareelite' then
				db.units.target[unitType].texture = "Interface\\WorldMap\\Skull_64Purple"
			elseif unitType == 'worldboss' then
				db.units.target[unitType].texture = "Interface\\WorldMap\\Skull_64Red"
			end
		end
		db.units.target['elite'].texCoords.right = 0.5
		db.units.target['elite'].texCoords.top = 0.5
		local units = core:getAllFrameTypes()
		for _, unit in ipairs({'target', 'pet', 'raidpet', 'partypet'}) do
			units[unit] = nil
		end
		for unitframeType in pairs(units) do
			db.units[unitframeType] = CopyTable(db.units.target)
		end
	end
end


function mod:UpdateElement(frame, unit, db)
	if not unit or not db or not db.enabled then return end

	local classificationIndicator = frame.classificationIndicator
	local unitClassification = UnitClassification(unit)
	local enemyType, colorByType, texture, r, g, b

	if UnitIsPlayer(unit) then
		if db.enableClasses then
			local _, class = UnitClass(unit)
			if class then
				enemyType = db[class]
				texture = db[class].texture
			end
		else
			classificationIndicator:Hide()
			return
		end
	elseif db.enableNPCs then
		for type, color in pairs(classifications) do
			if unitClassification == type then
				enemyType = db[type]
				if enemyType and enemyType.NPIcon then
					texture = E.Media.Textures.Nameplates
				else
					texture = enemyType.texture
				end
				colorByType = enemyType.colorByType
				r, g, b = color[1], color[2], color[3]
				break
			end
		end
	end

	if enemyType then
		local unitTexture = classificationIndicator.texture
		if colorByType then
			unitTexture:SetVertexColor(r, g, b)
		else
			unitTexture:SetVertexColor(1, 1, 1)
		end

		unitTexture:SetTexture(texture)

		if db.backdrop then
			classificationIndicator.backdrop:Show()
		else
			classificationIndicator.backdrop:Hide()
		end

		if enemyType.NPIcon then
			local top, bottom = unitClassification == 'worldboss' and 0.62 or 0.35, unitClassification == 'worldboss' and 0.94 or 0.63
			unitTexture:SetTexCoord(0, 0.15, top, bottom)
		elseif enemyType.flipIndicator then
			unitTexture:SetTexCoord(1, 0, 0, 1)
		else
			local texCoords = enemyType.texCoords
			unitTexture:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
		end

		local rotation = db.frameRotation
		if not enemyType.flipIndicator and rotation ~= 0 and rotation ~= 360 then
			unitTexture:SetRotation(rad(rotation))
		end

		local points = db.points
		classificationIndicator:ClearAllPoints()
		classificationIndicator:Size(db.width, db.height)
		classificationIndicator:Point(points.point, frame, points.relativeTo, points.xOffset, points.yOffset)
		classificationIndicator:SetFrameStrata(db.frameStrata)
		classificationIndicator:SetFrameLevel(db.frameLevel)
		classificationIndicator:Show()
	else
		classificationIndicator:Hide()
	end
end

function mod:ManageClassificationIndicator(db, frame, unit)
	if frame.classificationIndicator then return end
	local values = db[unit]

	local classificationIndicator = CreateFrame("Frame", nil,frame)
	classificationIndicator:Size(values.width, values.height)
	classificationIndicator:Point(values.points.point, frame, values.points.relativeTo, values.points.xOffset, values.points.yOffset)
	classificationIndicator:SetFrameStrata(values.frameStrata)
	classificationIndicator:SetFrameLevel(values.frameLevel)

	classificationIndicator:CreateBackdrop()

	local Texture = classificationIndicator:CreateTexture(nil, "OVERLAY")
	Texture:SetAllPoints(classificationIndicator)

	classificationIndicator.texture = Texture

	frame.classificationIndicator = classificationIndicator
end

function mod:Toggle(db)
	local units = db.units
	local enabled
	for _, frame in ipairs(core:AggregateUnitFrames()) do
		local unitframeType = frame.unitframeType
		if not core.reload and units[unitframeType] and units[unitframeType].enabled then
			if match(unitframeType, '%w+target') or match(unitframeType, 'boss%d?$') then
				frame.__elements['classificationIcon'] = function(frame, _, unit) self:UpdateElement(frame, unit, units[unitframeType]) end
			end
			self:ManageClassificationIndicator(units, frame, unitframeType)
			self:UpdateElement(frame, frame.unit, units[unitframeType])
			enabled = true
		elseif frame.classificationIndicator then
			frame.classificationIndicator:Hide()
		end
	end
	if enabled then
		core:Tag("classification",
			function(_, frame, unit)
				self:UpdateElement(frame, unit, units[frame.unitframeType])
			end,
			function(_, frame)
				local unitframeType = frame.unitframeType
				if units[unitframeType] and units[unitframeType].enabled then
					if match(unitframeType, '%w+target') or match(unitframeType, 'boss%d?$') then
						frame.__elements['classificationIcon'] = function(frame, _, unit) self:UpdateElement(frame, unit, units[unitframeType]) end
					end
					self:ManageClassificationIndicator(units, frame, unitframeType)
					self:UpdateElement(frame, frame.unit, units[unitframeType])
				end
			end
		)
		self.initialized = true
	elseif self.initialized then
		core:Untag("classification")
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback
