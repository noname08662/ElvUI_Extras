local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("NameLevel", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()

local _G, unpack, pairs = _G, unpack, pairs
local upper, find = string.upper, string.find


P["Extras"]["nameplates"][modName] = {
	["FRIENDLY_PLAYER"] = {
		["Name"] = {
			["enabled"] = false,
			["xOffset"] = 0,
			["yOffset"] = 0,
			["reactionColor"] = false,
			["customColor"] = false,
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
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Name&Level"],
		get = function(info) return E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] end,
		set = function(info, value) E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value NP:ForEachVisiblePlate("Update_"..info[#info-1]) end,
		args = {
			Name = {
				type = "group",
				name = L["Name"],
				guiInline = true,
				disabled = function(info) return not E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType].Name.enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Handles positioning and color."],
						set = function(info, value) E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value self:Toggle() NP:ForEachVisiblePlate("Update_Name") end,
					},
					reactionColor = {
						order = 1,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Reaction based coloring for non-cached characters."],
						set = function(info, value) 
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value 
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]].customColor = false
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
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value 
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]].reactionColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1]) 
						end,
					},
					color = {
						order = 5,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info)
							local color = E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]]
							return color[1], color[2], color[3]
						end,
						set = function(info, r, g, b)
							local color = E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]]
							color[1], color[2], color[3] = r, g, b
							NP:ForEachVisiblePlate("Update_Name") 
						end,
						disabled = function() return not E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType].Name.customColor end,
					},
				},
			},
			Level = {
				type = "group",
				name = L["Level"],
				guiInline = true,
				disabled = function(info) return not E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType].Level.enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Handles positioning and color."],
						set = function(info, value) E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value self:Toggle() NP:ForEachVisiblePlate("Update_Level") end,
					},
					spacer = {
						order = 1,
						type = "description",
						name = "",
						hidden = function() return not find(E.db.Extras.nameplates[modName].selectedType, 'PLAYER') end,
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
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]].reactionColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1]) 
						end,
					},
					color = {
						order = 5,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info)
							local color = E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]]
							return color[1], color[2], color[3]
						end,
						set = function(info, r, g, b)
							local color = E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]]
							color[1], color[2], color[3] = r, g, b
							NP:ForEachVisiblePlate("Update_Color")
						end,
						disabled = function() return not E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType].Level.customColor end,
					},
					reactionColor = {
						order = function() return find(E.db.Extras.nameplates[modName].selectedType, 'PLAYER') and 6 or 1 end,
						type = "toggle",
						name = L["Reaction Color"],
						desc = L["Reaction based coloring for non-cached characters."],
						set = function(info, value) 
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]][info[#info]] = value 
							E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType][info[#info-1]].customColor = false
							NP:ForEachVisiblePlate("Update_"..info[#info-1]) 
						end,
					},
					classColor = {
						order = 7,
						type = "toggle",
						name = L["Class Color"],
						desc = L["Use class colors."],
						hidden = function() return not find(E.db.Extras.nameplates[modName].selectedType, 'PLAYER') end,
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
						values = function(info)
							local list = {}
							for type in pairs(E.db.Extras.nameplates[modName]) do
								if upper(type) == type then list[type] = L[type] end
							end
							return list
						end,
						get = function(info) return E.db.Extras.nameplates[modName][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][info[#info]] = value end,
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
	
	mod.hooks[NP].Update_Level(self, frame)
	
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
		local mod_db = db
		local db = self.db.colors
		if class and mod_db.classColor then
			classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
			useClassColor = unitType_db.name and unitType_db.name.useClassColor
		end
		if reactionType and mod_db.reactionColor then
			useReactionColor = unitType_db.name and unitType_db.name.useReactionColor
		end
		if useClassColor and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") then
			if class and classColor then
				r, g, b = classColor.r, classColor.g, classColor.b
			end
		elseif (not unitType_db.health.enable and not frame.isTarget) or ((useReactionColor and (unitType == "FRIENDLY_NPC" or unitType == "ENEMY_NPC")) or mod_db.reactionColor) then
			if reactionType and reactionType == 1 then
				r, g, b = db.reactions.tapped.r, db.reactions.tapped.g, db.reactions.tapped.b
			elseif reactionType and reactionType == 4 then
				r, g, b = db.reactions.neutral.r, db.reactions.neutral.g, db.reactions.neutral.b
			elseif reactionType and reactionType > 4 then
				if unitType == "FRIENDLY_PLAYER" then
					r, g, b = db.reactions.friendlyPlayer.r, db.reactions.friendlyPlayer.g, db.reactions.friendlyPlayer.b
				else
					r, g, b = db.reactions.good.r, db.reactions.good.g, db.reactions.good.b
				end
			else
				r, g, b = db.reactions.bad.r, db.reactions.bad.g, db.reactions.bad.b
			end
		end
		level:SetTextColor(r, g, b)
	end
end
	
function mod:Update_Name(frame, triggered)
	mod.hooks[NP].Update_Name(self, frame, triggered)
	
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
			name:Point("BOTTOMRIGHT", frame.Level, "BOTTOMLEFT", 0, 0)
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
				
			if reactionType then
				useReactionColor = unitType_db.name and (unitType_db.name.useReactionColor or db.reactionColor)
				if useReactionColor and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") and frame.UnitClass then return end
			end

			local db = self.db.colors
			if useClassColor and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") then
				if class and classColor then
					r, g, b = classColor.r, classColor.g, classColor.b
				end
			elseif triggered or (not frame.Health:IsShown() and not frame.isTarget) or useReactionColor then
				if reactionType and reactionType == 1 then
					r, g, b = db.reactions.tapped.r, db.reactions.tapped.g, db.reactions.tapped.b
				elseif reactionType and reactionType == 4 then
					r, g, b = db.reactions.neutral.r, db.reactions.neutral.g, db.reactions.neutral.b
				elseif reactionType and reactionType > 4 then
					if unitType == "FRIENDLY_PLAYER" then
						r, g, b = db.reactions.friendlyPlayer.r, db.reactions.friendlyPlayer.g, db.reactions.friendlyPlayer.b
					else
						r, g, b = db.reactions.good.r, db.reactions.good.g, db.reactions.good.b
					end
				else
					r, g, b = db.reactions.bad.r, db.reactions.bad.g, db.reactions.bad.b
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


function mod:Toggle()
	local enableName, enableLevel
	for _, type in pairs({'FRIENDLY_NPC', 'ENEMY_PLAYER', 'ENEMY_NPC'}) do
		if not E.db.Extras.nameplates[modName][type] then 
			E.db.Extras.nameplates[modName][type]  = CopyTable(E.db.Extras.nameplates[modName]['FRIENDLY_PLAYER']) 
		end
		for _, element in pairs({'Name', 'Level'}) do
			if E.db.Extras.nameplates[modName][type][element].enabled then _G['enable'..element] = true end
		end
	end
	for _, element in pairs({'Name', 'Level'}) do
		if _G['enable'..element] then
			if not self:IsHooked(NP, "Update_"..element) then
				self:RawHook(NP, "Update_"..element, self["Update_"..element], true)
			end
		elseif self:IsHooked(NP, "Update_"..element) then
			self:Unhook(NP, "Update_"..element)
		end	
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	
	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback