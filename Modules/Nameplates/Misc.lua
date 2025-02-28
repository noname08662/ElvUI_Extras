local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("NPMisc.", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local isAwesome = C_NamePlate
local modName = mod:GetName()
mod.initialized = {}

local pairs, ipairs, tonumber, next = pairs, ipairs, tonumber, next
local format, upper = string.format, string.upper
local UnitInParty, UnitInRaid = UnitInParty, UnitInRaid


local function updateVisibilityState(db, areaType)
	for _, unitType in ipairs({'ENEMY_PLAYER', 'FRIENDLY_PLAYER', 'ENEMY_NPC', 'FRIENDLY_NPC'}) do
		local data = db[unitType]
		if unitType == "FRIENDLY_PLAYER" then
			local checkType = tonumber(data[areaType])
			if not checkType then
				NP.db.units[unitType].health.enable = data[areaType]
				db.shouldCheckFriendlies = false
			elseif checkType == 1 then
				db.shouldCheckFriendlies = function(unit)
					return unit and (UnitInParty(unit) or UnitInRaid(unit))
				end
			else
				db.shouldCheckFriendlies = function(unit)
					return unit and not (UnitInParty(unit) or UnitInRaid(unit))
				end
			end
		else
			NP.db.units[unitType].health.enable = data[areaType]
		end
	end
end


P["Extras"]["nameplates"][modName] = {
	["FRIENDLY_PLAYER"] = {},
	["selectedType"] = 'FRIENDLY_PLAYER',
	["healerIcon"] = {
		["enabled"] = false,
		["point"] = 'LEFT',
		["relativeTo"] = 'RIGHT',
		["xOffset"] = 4,
		["yOffset"] = 0,
		["size"] = 20,
	},
}

function mod:LoadConfig(db)
	local testing = false
	local function selectedType() return db.selectedType end
    local function selectedTypeData()
		return core:getSelected("nameplates", modName, format("[%s]", selectedType() or ""), "FRIENDLY_PLAYER")
	end
	local function buildConfig(name, order)
		return {
			order = order,
			type = "select",
			name = name,
			desc = "",
			values = function()
				if selectedType() == "FRIENDLY_PLAYER" then
					return {
						[1] = L["Show Group Members"],
						[2] = L["Hide Group Members"],
						[true] = L["Show"],
						[false] = L["Hide"],
					}
				else
					return {
						[true] = L["Show"],
						[false] = L["Hide"],
					}
				end
			end,
			disabled = function() return selectedTypeData().useDefaults end,
		}
	end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Misc."],
		get = function(info) return selectedTypeData()[info[#info-1]][info[#info]] end,
		set = function(info, value) selectedTypeData()[info[#info-1]][info[#info]] = value end,
		args = {
			selected = {
				order = 1,
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
			visibility = {
				order = 3,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info]] end,
				set = function(info, value)
					selectedTypeData()[info[#info]] = value
					if not isAwesome then
						E:StaticPopup_Show("PRIVATE_RL")
					else
						self:Toggle(db)
					end
				end,
				args = {
					useDefaults = {
						order = 1,
						type = "toggle",
						name = L["Use Default Handling"],
						desc = "",
					},
					showCity = buildConfig(L["Show in Cities"], 2),
					showBG = buildConfig(L["Show in Battlegrounds"], 3),
					showArena = buildConfig(L["Show in Arenas"], 4),
					showInstance = buildConfig(L["Show in Instances"], 5),
					showWorld = buildConfig(L["Show in the World"], 6),
				},
			},
			healerIcon = {
				order = 4,
				type = "group",
				name = function() return L["Healer Icon"] end,
				guiInline = true,
				get = function(info) return selectedType() == 'ENEMY_PLAYER' and db.healerIcon[info[#info]] end,
				set = function(info, value)
					db.healerIcon[info[#info]] = value
					self:Toggle(db)
					if testing then
						for frame in pairs(NP.VisiblePlates) do
							if frame.HealerIcon then
								frame.HealerIcon:Show()
							end
						end
					end
				end,
				disabled = function() return not db.healerIcon.enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = "",
						set = function(info, value)
							db.healerIcon[info[#info]] = value
							self:Toggle(db)
							if not value then
								testing = false
								for plate in pairs(NP.CreatedPlates) do
									local frame = plate.UnitFrame
									if self:IsHooked(frame.HealerIcon, "Hide") then
										self:Unhook(frame.HealerIcon, "Hide")
									end
									if frame:IsShown() then
										NP:Update_HealerIcon(frame)
									end
								end
							end
						end,
						disabled = false,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					point = {
						order = 2,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					relativeTo = {
						order = 3,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					xOffset = {
						order = 4,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					yOffset = {
						order = 5,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					size = {
						order = 6,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 4, max = 60, step = 1,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					test = {
						order = 7,
						type = "execute",
						width = "double",
						name = L["Test Mode"],
						desc = "",
						func = function()
							testing = not testing
							if testing then
								for plate in pairs(NP.CreatedPlates) do
									local frame = plate.UnitFrame
									if not self:IsHooked(frame.HealerIcon, "Hide") then
										self:SecureHook(frame.HealerIcon, "Hide", function(icon)
											icon:Show()
										end)
									end
									if frame:IsShown() then
										NP:Update_HealerIcon(frame)
									end
								end
							else
								for plate in pairs(NP.CreatedPlates) do
									local frame = plate.UnitFrame
									if self:IsHooked(frame.HealerIcon, "Hide") then
										self:Unhook(frame.HealerIcon, "Hide")
									end
									if frame:IsShown() then
										NP:Update_HealerIcon(frame)
									end
								end
							end
						end,
						hidden = function() return selectedType() ~= 'ENEMY_PLAYER' end,
					},
					notenemyplayer = {
						type = "description",
						name = core.pluginColor..L["Select 'Enemy Player' to configure."],
						hidden = function() return selectedType() == 'ENEMY_PLAYER' end,
					},
				},
			},
		},
	}
	if not next(db["FRIENDLY_PLAYER"]) then
		local visibility = NP.db.units["FRIENDLY_PLAYER"].health.enable
		db["FRIENDLY_PLAYER"] = {
			["useDefaults"] = true,
			["showCity"] = visibility,
			["showBG"] = visibility,
			["showArena"] = visibility,
			["showInstance"] = visibility,
			["showWorld"] = visibility,
		}
	end
	for _, type in ipairs({'FRIENDLY_NPC', 'ENEMY_PLAYER', 'ENEMY_NPC'}) do
		if not db[type] then
			local visibility = NP.db.units[type].health.enable
			db[type] = {
				["useDefaults"] = true,
				["showCity"] = visibility,
				["showBG"] = visibility,
				["showArena"] = visibility,
				["showInstance"] = visibility,
				["showWorld"] = visibility,
			}
		end
	end
end

function mod:OnShow()
end


function mod:Toggle(db)
	local enabled
	if not core.reload then
		for _, type in ipairs({'FRIENDLY_PLAYER', 'FRIENDLY_NPC', 'ENEMY_PLAYER', 'ENEMY_NPC'}) do
			if not db[type].useDefaults then
				enabled = true
				break
			end
		end
	end
	if not core.reload and db.healerIcon.enabled then
		local vals = db.healerIcon
		if not self:IsHooked(NP, "Construct_CPoints") then
			self:SecureHook(NP, "Construct_CPoints", function(_, frame)
				frame.HealerIcon:Size(vals.size)
			end)
		end
		if not self:IsHooked(NP, "Update_HealerIcon") then
			self:SecureHook(NP, "Update_HealerIcon", function(_, frame)
				local icon = frame.HealerIcon
				if icon:IsShown() then
					icon:ClearAllPoints()
					icon:Point(vals.point, frame.Health:IsShown() and frame.Health or frame.Name, vals.relativeTo, vals.xOffset, vals.yOffset)
				end
			end)
		end
		if not enabled then
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame then
					local icon = frame.HealerIcon
					if icon then
						icon:Size(vals.size)
						if frame:IsShown() then
							NP:Update_HealerIcon(frame)
						end
					end
				end
			end
		else
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame then
					local icon = frame.HealerIcon
					if icon then
						icon:Size(vals.size)
					end
				end
			end
		end
		self.initialized.healerIcon = true
	elseif self.initialized.healerIcon then
		if self:IsHooked(NP, "Construct_CPoints") then
			self:Unhook(NP, "Construct_CPoints")
		end
		if self:IsHooked(NP, "Update_HealerIcon") then
			self:Unhook(NP, "Update_HealerIcon")
		end
		if not enabled then
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame then
					local icon = frame.HealerIcon
					if icon then
						icon:SetSize(40, 40)
						if frame:IsShown() then
							NP:Update_HealerIcon(frame)
						end
					end
				end
			end
		else
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame then
					local icon = frame.HealerIcon
					if icon then
						icon:SetSize(40, 40)
					end
				end
			end
		end
		self.initialized.healerIcon = nil
	end
	if enabled then
		self.OnShow = function(_, plate, ...)
			local frame = plate.UnitFrame
			local _, unitType = NP:GetUnitInfo(frame)
			if unitType == "FRIENDLY_PLAYER" and db.shouldCheckFriendlies then
				NP.db.units["FRIENDLY_PLAYER"].health.enable = db.shouldCheckFriendlies(NP:GetUnitByName(frame, unitType))
			end
			self.hooks[NP].OnShow(plate, ...)
		end
		core:RegisterAreaUpdate(modName, function()
			updateVisibilityState(db, core:GetCurrentAreaType())
			for frame in pairs(NP.VisiblePlates) do
				NP:UpdateAllFrame(frame, nil, true)
			end
		end)
		updateVisibilityState(db, core:GetCurrentAreaType())
		if not self:IsHooked(NP, "OnShow") then
			self:RawHook(NP, "OnShow")
		end
		for frame in pairs(NP.VisiblePlates) do
			NP:UpdateAllFrame(frame, nil, true)
		end
		self.initialized.visibility = true
	elseif self.initialized.visibility then
		core:RegisterAreaUpdate(modName)
		if isAwesome or not core.reload then
			if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		else
			self.OnShow = function() end
		end
		for frame in pairs(NP.VisiblePlates) do
			NP:UpdateAllFrame(frame, nil, true)
		end
		self.initialized.visibility = nil
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback