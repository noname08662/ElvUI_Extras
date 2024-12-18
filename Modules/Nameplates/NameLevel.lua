local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("NameLevel", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()

local unpack, pairs, ipairs = unpack, pairs, ipairs
local upper, find, format = string.upper, string.find, string.format


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

function mod:LoadConfig(db)
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
						order = 1,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = "",
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							self:Toggle(db)
							NP:ForEachVisiblePlate("Update_Name")
						end,
					},
					reactionColor = {
						order = 2,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Reaction based coloring for non-cached characters."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].customColor = false
							NP:ForEachVisiblePlate("Update_Name")
						end,
					},
					customColor = {
						order = 3,
						type = "toggle",
						name = L["Apply Custom Color"],
						desc = "",
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].reactionColor = false
							NP:ForEachVisiblePlate("Update_Name")
						end,
					},
					color = {
						order = 4,
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
						order = 5,
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
						order = 6,
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
						order = 1,
						type = "toggle",
						width = "full",
						name = core.pluginColor..L["Enable"],
						desc = "",
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							self:Toggle(db)
							NP:ForEachVisiblePlate("Update_Level")
						end,
						disabled = false,
					},
					customColor = {
						order = 2,
						type = "toggle",
						name = L["Apply Custom Color"],
						desc = "",
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].reactionColor = false
							selectedTypeData()[info[#info-1]].classColor = false
							NP:ForEachVisiblePlate("Update_Level")
						end,
					},
					color = {
						order = 3,
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
							NP:ForEachVisiblePlate("Update_Level")
						end,
						disabled = function() return not selectedTypeData().Level.customColor end,
					},
					reactionColor = {
						order = 4,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Reaction based coloring for non-cached characters."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].customColor = false
							selectedTypeData()[info[#info-1]].classColor = false
							NP:ForEachVisiblePlate("Update_Level")
						end,
					},
					classColor = {
						order = 5,
						type = "toggle",
						name = L["Class Color"],
						desc = L["Use class colors."],
						set = function(info, value)
							selectedTypeData()[info[#info-1]][info[#info]] = value
							selectedTypeData()[info[#info-1]].customColor = false
							selectedTypeData()[info[#info-1]].reactionColor = false
							NP:ForEachVisiblePlate("Update_Level")
						end,
						disabled = function() return not selectedTypeData().Level.enabled or not find(db.selectedType, 'PLAYER') end,
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

	if not unitType_db.level.enable then return end

	local db = E.db.Extras.nameplates[modName][unitType].Level
	if not db.enabled then return end

	if db.customColor then
		frame.Level:SetTextColor(unpack(db.color))
	elseif db.reactionColor or db.classColor then
		local _, r, g, b = self:UnitLevel(frame)
		local class = frame.UnitClass
		local classColor = (class and db.classColor) and (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])

		if classColor then
			r, g, b = classColor.r, classColor.g, classColor.b
		elseif db.reactionColor then
			local reactionType = frame.UnitReaction
			if reactionType then
				local colors = self.db.colors
				if reactionType == 4 then
					r, g, b = colors.reactions.neutral.r, colors.reactions.neutral.g, colors.reactions.neutral.b
				elseif reactionType > 4 then
					if unitType == "FRIENDLY_PLAYER" then
						r, g, b = colors.reactions.friendlyPlayer.r, colors.reactions.friendlyPlayer.g, colors.reactions.friendlyPlayer.b
					else
						r, g, b = colors.reactions.good.r, colors.reactions.good.g, colors.reactions.good.b
					end
				else
					r, g, b = colors.reactions.bad.r, colors.reactions.bad.g, colors.reactions.bad.b
				end
			end
		end
		frame.Level:SetTextColor(r, g, b)
	end
end

function mod:Update_Name(frame)
	local unitType = frame.UnitType
	local db = E.db.Extras.nameplates[modName][unitType].Name
	if not db.enabled then return end

	local name = frame.Name

	if frame.Health:IsShown() then
		if db.toLevel then
			name:Point("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT")
		else
			name:Point("BOTTOMRIGHT", frame.Health, "TOPRIGHT", (db.xOffsetShorten or 0) * (frame.currentScale or 1), 0)
		end
	end

	if db.reactionColor or db.customColor then
		local r, g, b = 1, 1, 1

		if db.customColor then
			r, g, b = unpack(db.color)
		else
			local reactionType = frame.UnitReaction
			if reactionType then
				local colors = self.db.colors
				if reactionType == 4 then
					r, g, b = colors.reactions.neutral.r, colors.reactions.neutral.g, colors.reactions.neutral.b
				elseif reactionType > 4 then
					if unitType == "FRIENDLY_PLAYER" then
						r, g, b = colors.reactions.friendlyPlayer.r, colors.reactions.friendlyPlayer.g, colors.reactions.friendlyPlayer.b
					else
						r, g, b = colors.reactions.good.r, colors.reactions.good.g, colors.reactions.good.b
					end
				else
					r, g, b = colors.reactions.bad.r, colors.reactions.bad.g, colors.reactions.bad.b
				end
				if not (r and g and b) then r, g, b = 1, 1, 1 end
			end
		end
		if r ~= name.r or g ~= name.g or b ~= name.b then
			name:SetTextColor(r, g, b)
			name.r, name.g, name.b = r, g, b
		end
	end
end


function mod:Toggle(db)
	local enabled = {}
	for _, type in ipairs({'FRIENDLY_PLAYER', 'FRIENDLY_NPC', 'ENEMY_PLAYER', 'ENEMY_NPC'}) do
		if not db[type] then
			db[type]  = CopyTable(db['FRIENDLY_PLAYER'])
		end
		for _, element in ipairs({'Name', 'Level'}) do
			if db[type][element].enabled then
				enabled[element] = not core.reload
			end
		end
	end
	for _, element in ipairs({'Name', 'Level'}) do
		if enabled[element] then
			if not self:IsHooked(NP, "Update_"..element) then
				self:SecureHook(NP, "Update_"..element, self["Update_"..element])
			end
		elseif self:IsHooked(NP, "Update_"..element) then
			self:Unhook(NP, "Update_"..element)
		end
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback
