local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("NameLevel", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()

local unpack, pairs = unpack, pairs
local upper, find = string.upper, string.find


P["Extras"]["nameplates"][modName] = {
	["FRIENDLY_PLAYER"] = {
		["Name"] = {
			["enabled"] = false,
			["xOffset"] = 0,
			["yOffset"] = 0,
			["reactionColor"] = false,
			["customColor"] = false,
			["toLevel"] = true,
			["xOffsetShorten"] = 0,
			["color"] = { 1, 1, 1 },
		},
		["Level"] = {
			["enabled"] = false,
			["xOffset"] = 0,
			["yOffset"] = 0,
			["classColor"] = false,
			["reactionColor"] = false,
			["customColor"] = false,
			["color"] = { 1, 1, 1 },
		},
	},
	["selectedType"] = 'FRIENDLY_PLAYER',
}

function mod:LoadConfig()
	local db = E.db.Extras.nameplates[modName]
	local function selectedType() return db.selectedType end
    local function selectedTypeData()
		return core:getSelected("nameplates", modName, format("[%s]", selectedType() or ""), "FRIENDLY_PLAYER")
	end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Name&Level"],
		get = function(info) return selectedTypeData()[info[#info-1]][info[#info]] end,
		set = function(info, value) selectedTypeData()[info[#info-1]][info[#info]] = value NP:ForEachVisiblePlate("Update_"..info[#info-1]) end,
		args = {
			Name = {
				type = "group",
				name = L["Name"],
				guiInline = true,
				disabled = function() return not selectedTypeData().Name.enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Handles positioning and color."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							self:Toggle(db)
							NP:ForEachVisiblePlate("Update_Name")
						end,
					},
					reactionColor = {
						order = 1,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Reaction based coloring for non-cached characters."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].customColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1])
						end,
					},
					xOffset = {
						order = 2,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 3,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
					customColor = {
						order = 4,
						type = "toggle",
						name = L["Apply Custom Color"],
						desc = "",
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].reactionColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1])
						end,
					},
					color = {
						order = 5,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info)
							local color = selectedTypeData()[info[#info-1]][info[#info]]
							return color[1], color[2], color[3]
						end,
						set = function(info, r, g, b)
							local color = selectedTypeData()[info[#info-1]][info[#info]]
							color[1], color[2], color[3] = r, g, b
							NP:ForEachVisiblePlate("Update_Name")
						end,
						disabled = function() return not selectedTypeData().Name.customColor end,
					},
					toLevel = {
						order = 6,
						type = "toggle",
						name = L["To Level"],
						desc = L["Names will be shortened based on level text position."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							self:Toggle(db)
							NP:ForEachVisiblePlate("Update_Name")
						end,
					},
					xOffsetShorten = {
						order = 7,
						type = "range",
						min = -240, max = 80, step = 1,
						name = L["Shortening X Offset"],
						desc = "",
						disabled = function() return not selectedTypeData().Name.enabled or selectedTypeData().Name.toLevel end,
					},
				},
			},
			Level = {
				type = "group",
				name = L["Level"],
				guiInline = true,
				disabled = function() return not selectedTypeData().Level.enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Handles positioning and color."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							self:Toggle(db)
							NP:ForEachVisiblePlate("Update_Level")
						end,
					},
					spacer = {
						order = 1,
						type = "description",
						name = "",
						hidden = function() return not find(selectedType(), 'PLAYER') end,
					},
					xOffset = {
						order = 2,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 3,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
					customColor = {
						order = 4,
						type = "toggle",
						name = L["Apply Custom Color"],
						desc = "",
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].reactionColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1])
						end,
					},
					color = {
						order = 5,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info)
							local color = selectedTypeData()[info[#info-1]][info[#info]]
							return color[1], color[2], color[3]
						end,
						set = function(info, r, g, b)
							local color = selectedTypeData()[info[#info-1]][info[#info]]
							color[1], color[2], color[3] = r, g, b
							NP:ForEachVisiblePlate("Update_Color")
						end,
						disabled = function() return not selectedTypeData().Level.customColor end,
					},
					reactionColor = {
						order = function() return find(db.selectedType, 'PLAYER') and 6 or 1 end,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Reaction based coloring for non-cached characters."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].customColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1])
						end,
					},
					classColor = {
						order = 7,
						type = "toggle",
						name = L["Class Color"],
						desc = L["Use class colors."],
						hidden = function() return not find(db.selectedType, 'PLAYER') end,
					},
				},
			},
			Selected = {
				order = 99,
				type = "group",
				name = L["Selected Type"],
				guiInline = true,
				args = {
					selectedType = {
						type = "select",
						name = L["Select"],
						desc = "",
						values = function()
							local list = {}
							for type in pairs(db) do
								if upper(type) == type then list[type] = L[type] end
							end
							return list
						end,
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value end,
					},
				},
			},
		},
	}
end


function mod:Update_Level(frame)
	local unitType = frame.UnitType
	local unitType_db = self.db.units[unitType]

	if not unitType_db.level.enable or (frame.UnitTrivial and NP.db.trivial) then return end

	local db = E.db.Extras.nameplates[modName][unitType].Level
	if not db.enabled then return end

	local levelText, r, g, b = self:UnitLevel(frame)
	local level = frame.Level

	level:ClearAllPoints()

	if frame.Health:IsShown() then
		level:SetJustifyH("RIGHT")
		level:Point("BOTTOMRIGHT", frame.Health, "TOPRIGHT", db.xOffset ~= 0 and db.xOffset or 0, db.yOffset ~= 0 and db.yOffset or E.Border*2)
		level:SetText(levelText)
	else
		if unitType_db.name.enable then
			level:Point("LEFT", frame.Name, "RIGHT", 0, 0)
		else
			level:Point("TOPLEFT", frame, "TOPRIGHT", -38, 0)
		end
		level:SetJustifyH("LEFT")
		level:SetFormattedText(" [%s]", levelText)
	end

	if db.customColor then
		level:SetTextColor(unpack(db.color))
	elseif db.reactionColor or db.classColor then
		local class = frame.UnitClass
		local reactionType = frame.UnitReaction
		local classColor, useClassColor, useReactionColor
		local colors = self.db.colors
		if class and db.classColor then
			classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			useClassColor = unitType_db.name and unitType_db.name.useClassColor
		end
		if reactionType and db.reactionColor then
			useReactionColor = unitType_db.name and unitType_db.name.useReactionColor
		end
		if useClassColor and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") then
			if class and classColor then
				r, g, b = classColor.r, classColor.g, classColor.b
			end
		elseif (not unitType_db.health.enable and not frame.isTarget) or ((useReactionColor and (unitType == "FRIENDLY_NPC" or unitType == "ENEMY_NPC")) or db.reactionColor) then
			if reactionType and reactionType == 4 then
				r, g, b = colors.reactions.neutral.r, colors.reactions.neutral.g, colors.reactions.neutral.b
			elseif reactionType and reactionType > 4 then
				if unitType == "FRIENDLY_PLAYER" then
					r, g, b = colors.reactions.friendlyPlayer.r, colors.reactions.friendlyPlayer.g, colors.reactions.friendlyPlayer.b
				else
					r, g, b = colors.reactions.good.r, colors.reactions.good.g, colors.reactions.good.b
				end
			else
				r, g, b = colors.reactions.bad.r, colors.reactions.bad.g, colors.reactions.bad.b
			end
		end
		level:SetTextColor(r, g, b)
	end
end

function mod:Update_Name(frame, triggered)
	local db = E.db.Extras.nameplates[modName][frame.UnitType].Name
	if not db.enabled then return end

	local unitType = frame.UnitType
	local unitType_db = self.db.units[unitType]
	local name = frame.Name

	name:ClearAllPoints()

	if frame.Health:IsShown() or (self.db.alwaysShowTargetHealth and frame.isTarget) then
		if frame.UnitTrivial and NP.db.trivial then
			name:SetJustifyH("CENTER")
			name:Point("BOTTOM", frame.Health, "TOP", db.xOffset ~= 0 and db.xOffset or 0, db.yOffset ~= 0 and db.yOffset or E.Border*2)
		else
			name:SetJustifyH("LEFT")
			name:Point("BOTTOMLEFT", frame.Health, "TOPLEFT", db.xOffset ~= 0 and db.xOffset or 0, db.yOffset ~= 0 and db.yOffset or E.Border*2)
			if db.toLevel then
				name:Point("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT", 0, 0)
			else
				local nameShortener = frame.nameShortener
				if not nameShortener then
					nameShortener = CreateFrame("Frame", nil, frame)
					nameShortener:Size(1)
					frame.nameShortener = nameShortener
				end
				nameShortener:ClearAllPoints()
				nameShortener:Point("BOTTOMRIGHT", frame.Health, "TOPRIGHT", db.xOffsetShorten or 0, 0)
				name:Point("BOTTOMRIGHT", frame.nameShortener, "BOTTOMLEFT", 0, 0)
			end
		end
	else
		name:SetJustifyH("CENTER")
		name:Point("TOP", frame, "TOP", 0, 0)
	end

	if db.reactionColor or db.classColor or db.customColor then
		local r, g, b = 1, 1, 1

		if db.customColor then
			r, g, b = unpack(db.color)
		else
			local classColor, useClassColor, useReactionColor

			local class = frame.UnitClass
			local reactionType = frame.UnitReaction

			if class then
				classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				useClassColor = self.db.units[frame.UnitType].name and self.db.units[frame.UnitType].name.useClassColor
			end

			if reactionType then
				useReactionColor = unitType_db.name and (unitType_db.name.useReactionColor or db.reactionColor)
				if useReactionColor and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") and frame.UnitClass then return end
			end

			local colors = self.db.colors

			if useClassColor and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") then
				if class and classColor then
					r, g, b = classColor.r, classColor.g, classColor.b
				end
			elseif triggered or (not frame.Health:IsShown() and not frame.isTarget) or useReactionColor then
				if reactionType and reactionType == 4 then
					r, g, b = colors.reactions.neutral.r, colors.reactions.neutral.g, colors.reactions.neutral.b
				elseif reactionType and reactionType > 4 then
					if unitType == "FRIENDLY_PLAYER" then
						r, g, b = colors.reactions.friendlyPlayer.r, colors.reactions.friendlyPlayer.g, colors.reactions.friendlyPlayer.b
					else
						r, g, b = colors.reactions.good.r, colors.reactions.good.g, colors.reactions.good.b
					end
				else
					r, g, b = colors.reactions.bad.r, colors.reactions.bad.g, colors.reactions.bad.b
				end
			end
			if not (r and g and b) then r, g, b = 1, 1, 1 end
		end

		if triggered or (r ~= name.r or g ~= name.g or b ~= name.b) then
			name:SetTextColor(r, g, b)
			if not triggered then frame.Name.r, frame.Name.g, frame.Name.b = r, g, b end
		end

		if self.db.nameColoredGlow then
			name.NameOnlyGlow:SetVertexColor(r - 0.1, g - 0.1, b - 0.1, 1)
		else
			db = self.db.colors.glowColor
			name.NameOnlyGlow:SetVertexColor(db.r, db.g, db.b, db.a)
		end
	end
end


function mod:Toggle(db)
	local enabled = {}
	for _, type in ipairs({'FRIENDLY_NPC', 'ENEMY_PLAYER', 'ENEMY_NPC'}) do
		if not db[type] then
			db[type]  = CopyTable(db['FRIENDLY_PLAYER'])
		end
		for i, element in ipairs({'Name', 'Level'}) do
			if db[type][element].enabled then
				enabled[element] = not core.reload
				if i == 1 and not db[type][element].toLevel then
					enabled['nameshorten'] = not core.reload
				end
			end
		end
	end
	for type, element in ipairs({'Name', 'Level'}) do
		if enabled[element] then
			if not self:IsHooked(NP, "Update_"..element) then
				if type == 'Name' then
					if enabled['nameshorten'] then
						for plate in pairs(NP.CreatedPlates) do
							local frame = plate.UnitFrame
							frame.nameShortener = frame.nameShortener or CreateFrame("Frame", nil, frame)
						end
					else
						for plate in pairs(NP.CreatedPlates) do
							plate.UnitFrame.nameShortener = nil
						end
					end
				end
				self:SecureHook(NP, "Update_"..element, self["Update_"..element])
			end
		elseif self:IsHooked(NP, "Update_"..element) then
			self:Unhook(NP, "Update_"..element)
		end
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	mod:LoadConfig()
	mod:Toggle(E.db.Extras.nameplates[modName])
end

core.modules[modName] = mod.InitializeCallback
