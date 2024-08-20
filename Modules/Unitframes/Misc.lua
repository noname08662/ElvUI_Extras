local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("UFMisc.", "AceHook-3.0")
local UF = E:GetModule("UnitFrames")

local modName = mod:GetName()

local pairs, ipairs = pairs, ipairs
local gsub, find, upper = string.gsub, string.find, string.upper


P["Extras"]["unitframes"][modName] = {
	["selectedSubSection"] = 'DetachPower',
	["DetachPower"] = {
		["enabled"] = false,
		["desc"] = L["Detaches power for the currently selected group."],
		["detachAll"] = false,
		["selectedUnit"] = "party",
		["units"] = {
			["party"] = {	
				["enabled"] = true,
				["xOffset"] = 0,
				["yOffset"] = -4,
				["width"] = 0,
				["point"] = 'TOP',
				["relativeTo"] = 'BOTTOM',
			},
		},
	},
	["NameAutoShorten"] = {
		["enabled"] = false,
		["desc"] = L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."],
		["selectedUnit"] = 'player',
		["units"] = {
			["player"] = { 
				["toHealth"] = false, 
				["xOffset"] = 0 
			},
		},
	},
}

function mod:LoadConfig()
	local function updateConfigMode(mode)
		local units = core:AggregateUnitFrames()
		local update = false
		for _, frame in ipairs(units) do
			if mode == 'DP' and E.db.Extras.unitframes[modName].DetachPower.units[frame.unitframeType] then
				frame.POWERBAR_DETACHED = E.db.Extras.unitframes[modName].DetachPower.units[frame.unitframeType].enabled
				update = true
			else
				local db = frame.db
				if not db.power or not db.power.enable or not db.power.hideonnpc then
					local attachPoint, x, y = UF:GetObjectAnchorPoint(frame, db.name.attachTextTo), db.name.xOffset, db.name.yOffset
					frame.Name:ClearAllPoints()
					frame.Name:Point(db.name.position, attachPoint, db.name.position, db.name.xOffset, db.name.yOffset)
				end
			end
		end
		if update then UF:Update_AllFrames() end
	end
	local function selectedSubSection() return E.db.Extras.unitframes[modName].selectedSubSection end
	core.unitframes.args[modName] = {
		type = "group",
		name = L["Misc."],
		args = {
			SubSection = {
				order = 1,
				type = "group",
				name = L["Sub-Section"],
				guiInline = true,
				disabled = false,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = function() return E.db.Extras.unitframes[modName][selectedSubSection()].desc end,
						get = function(info) 
							if selectedSubSection() == 'DetachPower' then
								return E.db.unitframe.units[E.db.Extras.unitframes[modName].DetachPower.selectedUnit].power.detachFromFrame
							elseif selectedSubSection() == 'NameAutoShorten' then
								return E.db.Extras.unitframes[modName].NameAutoShorten.enabled
							end
						end,
						set = function(info, value) 
							if selectedSubSection() == 'DetachPower' then
								E.db.unitframe.units[E.db.Extras.unitframes[modName].DetachPower.selectedUnit].power.detachFromFrame = value 
								E.db.Extras.unitframes[modName].DetachPower.units[E.db.Extras.unitframes[modName].DetachPower.selectedUnit].enabled = value 
								self:Toggle() 
								updateConfigMode('DP')
							elseif selectedSubSection() == 'NameAutoShorten' then
								E.db.Extras.unitframes[modName].NameAutoShorten.enabled = value 
								updateConfigMode() 
								if value then UF:Update_AllFrames() end
							end
						end,
					},
					selectedSubSection = {
						order = 2,
						type = "select",
						name = L["Select"],
						desc = "",
						get = function(info) return E.db.Extras.unitframes[modName].selectedSubSection end,
						set = function(info, value) E.db.Extras.unitframes[modName].selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(E.db.Extras.unitframes[modName]) do
								if section ~= 'selectedSubSection' then
									dropdownValues[section] = L[section]
								end
							end
							return dropdownValues
						end,
					},
				},
			},
			DetachPower = {
				type = "group",
				name = L["Detach Power"],
				guiInline = true,
				get = function(info) return E.db.Extras.unitframes[modName].DetachPower.units[E.db.Extras.unitframes[modName].DetachPower.selectedUnit][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].DetachPower.units[E.db.Extras.unitframes[modName].DetachPower.selectedUnit][info[#info]] = value updateConfigMode('DP') end,
				disabled = function() return not E.db.unitframe.units[E.db.Extras.unitframes[modName].DetachPower.selectedUnit].power.detachFromFrame end,
				hidden = function(info) return selectedSubSection() ~= 'DetachPower' end,
				args = {
					detachAll = {
						order = 1,
						type = "toggle",
						width = "full",
						disabled = false,
						name = L["Detach All"],
						desc = "",
						get = function(info) return E.db.Extras.unitframes[modName].DetachPower.detachAll end,
						set = function(info, value)
							for groupName in pairs(E.db.Extras.unitframes[modName].DetachPower.units) do
								E.db.unitframe.units[groupName].power.detachFromFrame = value
								E.db.Extras.unitframes[modName].DetachPower.units[groupName].enabled = value
							end
							E.db.Extras.unitframes[modName].DetachPower.detachAll = value
							self:Toggle()
							updateConfigMode('DP')
						end,
					},
					unitDropdown = {
						order = 2,
						type = "select",
						disabled = false,
						name = L["Select Unit"],
						desc = "",
						get = function(info) return E.db.Extras.unitframes[modName].DetachPower.selectedUnit end,
						set = function(info, value) E.db.Extras.unitframes[modName].DetachPower.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(E.db.Extras.unitframes[modName].DetachPower.units) end,
					},
					width = {
						order = 3,
						type = "range",
						min = 0, max = 400, step = 1,
						name = L["Width"],
						desc = L["0 to match frame width."],
					},
					xOffset = {
						order = 4,
						type = "range",
						min = -80, max = 80, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 5,
						type = "range",
						min = -80, max = 80, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
					point = {
						order = 6,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 7,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
				},
			},
			NameAutoShorten = {
				type = "group",
				name = L["Name Auto-Shorten"],
				guiInline = true,
				get = function(info) return E.db.Extras.unitframes[modName].NameAutoShorten.units[E.db.Extras.unitframes[modName].NameAutoShorten.selectedUnit][info[#info]] end,
				set = function(info, value) E.db.Extras.unitframes[modName].NameAutoShorten.units[E.db.Extras.unitframes[modName].NameAutoShorten.selectedUnit][info[#info]] = value UF:Update_AllFrames() end,
				disabled = function() return not E.db.Extras.unitframes[modName].NameAutoShorten.enabled end,
				hidden = function(info) return selectedSubSection() ~= 'NameAutoShorten' end,
				args = {
					unitDropdown = {
						order = 1,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function(info) return E.db.Extras.unitframes[modName].NameAutoShorten.selectedUnit end,
						set = function(info, value) E.db.Extras.unitframes[modName].NameAutoShorten.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(E.db.Extras.unitframes[modName].NameAutoShorten.units) end,
					},
					xOffset = {
						order = 2,
						type = "range",
						min = -80, max = 0, step = 1,
						name = L["X Offset"],
						desc = L["0 to disable."],
					},
					toHealth = {
						order = 3,
						type = "toggle",
						name = L["Anchor to Health"],
						desc = L["Adjusts the shortening based on the 'Health' text position."],
					},
				},
			},
		},
	}
	if not E.db.Extras.unitframes[modName].DetachPower.units.raid then
		for _, type in ipairs({'raid', 'raid40', 'arena', 'boss'}) do
			E.db.Extras.unitframes[modName].DetachPower.units[type] = CopyTable(E.db.Extras.unitframes[modName].DetachPower.units.party)
		end
	end
	if not E.db.Extras.unitframes[modName].NameAutoShorten.units.target then
		local units = core:getAllFrameTypes()
		units['player'] = nil
		for unitframeType in pairs(units) do
			E.db.Extras.unitframes[modName].NameAutoShorten.units[unitframeType] = CopyTable(E.db.Extras.unitframes[modName].NameAutoShorten.units.player) 
		end
	end
end	

		
function mod:Configure_Power(frame, noTemplateChange)
	if not frame.VARIABLES_SET then return end
	local db = frame.db
	local power = frame.Power

	frame.POWERBAR_DETACHED = frame.db.power.detachFromFrame
	
	mod.hooks[UF].Configure_Power(self, frame, noTemplateChange)
	
	frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)
	UF:Configure_HealthBar(frame, true)
	UF:Configure_InfoPanel(frame, true)
	
	for groupName, values in pairs(E.db.Extras.unitframes[modName].DetachPower.units) do
		if frame.unitframeType == groupName and frame.db.power.detachFromFrame then
			power:ClearAllPoints()
			power:Point(values.point, frame, values.relativeTo, values.xOffset, values.yOffset)
			power:Width(values.width ~= 0 and values.width or frame.POWERBAR_WIDTH)
			break
		end
	end
end

function mod:UpdateNameSettings(frame, childType)
	local db = frame.db
	if childType == "pet" then
		db = frame.db.petsGroup
	elseif childType == "target" then
		db = frame.db.targetsGroup
	end
	if not db.power or not db.power.enable or not db.power.hideonnpc then
		local attachPoint, x, y = UF:GetObjectAnchorPoint(frame, db.name.attachTextTo), db.name.xOffset, db.name.yOffset
		frame.Name:ClearAllPoints()
		frame.Name:Point(db.name.position, attachPoint, db.name.position, db.name.xOffset, db.name.yOffset)
		db = E.db.Extras.unitframes[modName].NameAutoShorten.units[frame.unitframeType]
		if db then
			frame.Name:SetJustifyH("LEFT")
			frame.Name:Point('RIGHT', (db.toHealth and frame.Health and frame.Health.value:GetText()) and frame.Health.value or attachPoint, db.toHealth and 'LEFT' or 'RIGHT', db.xOffset ~= 0 and db.xOffset or x, y)
		end
	end
end
	
	
function mod:Toggle()
	local enable = E.db.Extras.unitframes[modName].DetachPower.detachAll
	if not enable then
		for _, info in pairs(E.db.Extras.unitframes[modName].DetachPower.units) do
			if info.enabled then enable = true break end
		end
	end
	if enable then
		if not self:IsHooked(UF, "Configure_Power") then self:RawHook(UF, "Configure_Power", self.Configure_Power, true) end
	elseif self:IsHooked(UF, "Configure_Power") then self:Unhook(UF, "Configure_Power") end
	
	if E.db.Extras.unitframes[modName].NameAutoShorten.enabled then 
		if not self:IsHooked(UF, "UpdateNameSettings") then self:SecureHook(UF, "UpdateNameSettings", self.UpdateNameSettings) end
		if not self:IsHooked(UF, "Configure_HealthBar") then self:SecureHook(UF, "Configure_HealthBar", function(self, frame) UF:UpdateNameSettings(frame, frame.childType) end) end
	else
		if self:IsHooked(UF, "UpdateNameSettings") then self:Unhook(UF, "UpdateNameSettings") end
		if self:IsHooked(UF, "Configure_HealthBar") then self:Unhook(UF, "Configure_HealthBar") end
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end
	
	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback