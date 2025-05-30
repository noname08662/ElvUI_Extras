local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("UFMisc.", "AceHook-3.0")
local UF = E:GetModule("UnitFrames")

local modName = mod:GetName()

local pairs, ipairs = pairs, ipairs
local format = string.format


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

function mod:LoadConfig(db)
	local uf_units = E.db.unitframe.units
	local function selectedDetachUnit() return db.DetachPower.selectedUnit end
	local function selectedShortenUnit() return db.NameAutoShorten.selectedUnit end
	local function selectedDetachData()
		return core:getSelected("unitframes", modName, format("DetachPower.units[%s]", selectedDetachUnit() or ""), "party")
	end
	local function selectedShortenData()
		return core:getSelected("unitframes", modName, format("NameAutoShorten.units[%s]", selectedShortenUnit() or ""), "player")
	end
	local function updateConfigMode(mode)
		local units = core:AggregateUnitFrames()
		local update = false
		for _, frame in ipairs(units) do
			if mode == 'DP' and db.DetachPower.units[frame.unitframeType] then
				frame.POWERBAR_DETACHED = db.DetachPower.units[frame.unitframeType].enabled
				update = true
			else
				local fdb = frame.db
				if not fdb.power or not fdb.power.enable or not fdb.power.hideonnpc then
					local attachPoint, x, y = UF:GetObjectAnchorPoint(frame, fdb.name.attachTextTo), fdb.name.xOffset, fdb.name.yOffset
					frame.Name:ClearAllPoints()
					frame.Name:Point(fdb.name.position, attachPoint, fdb.name.position, x, y)
				end
			end
		end
		if update then UF:Update_AllFrames() end
	end
	local function selectedSubSection() return db.selectedSubSection end
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
						desc = function() return db[selectedSubSection()].desc end,
						get = function()
							if selectedSubSection() == 'DetachPower' then
								return uf_units[selectedDetachUnit()] and uf_units[selectedDetachUnit()].power.detachFromFrame
							elseif selectedSubSection() == 'NameAutoShorten' then
								return db.NameAutoShorten.enabled
							end
						end,
						set = function(_, value)
							if selectedSubSection() == 'DetachPower' then
								if uf_units[selectedDetachUnit()] then
									uf_units[selectedDetachUnit()].power.detachFromFrame = value
								end
								selectedDetachData().enabled = value
								self:Toggle(db)
								updateConfigMode('DP')
							elseif selectedSubSection() == 'NameAutoShorten' then
								db.NameAutoShorten.enabled = value
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
						get = function() return db.selectedSubSection end,
						set = function(_, value) db.selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(db) do
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
				get = function(info) return selectedDetachData()[info[#info]] end,
				set = function(info, value) selectedDetachData()[info[#info]] = value updateConfigMode('DP') end,
				disabled = function() return not uf_units[selectedDetachUnit()] and uf_units[selectedDetachUnit()].power.detachFromFrame end,
				hidden = function() return selectedSubSection() ~= 'DetachPower' end,
				args = {
					detachAll = {
						order = 1,
						type = "toggle",
						width = "full",
						disabled = false,
						name = L["Detach All"],
						desc = "",
						get = function() return db.DetachPower.detachAll end,
						set = function(_, value)
							for groupName in pairs(db.DetachPower.units) do
								if uf_units[groupName] then
									uf_units[groupName].power.detachFromFrame = value
								end
								db.DetachPower.units[groupName].enabled = value
							end
							db.DetachPower.detachAll = value
							self:Toggle(db)
							updateConfigMode('DP')
						end,
					},
					unitDropdown = {
						order = 2,
						type = "select",
						disabled = false,
						name = L["Select Unit"],
						desc = "",
						get = function() return db.DetachPower.selectedUnit end,
						set = function(_, value) db.DetachPower.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(db.DetachPower.units) end,
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
				get = function(info) return selectedShortenData()[info[#info]] end,
				set = function(info, value) selectedShortenData()[info[#info]] = value UF:Update_AllFrames() end,
				disabled = function() return not db.NameAutoShorten.enabled end,
				hidden = function() return selectedSubSection() ~= 'NameAutoShorten' end,
				args = {
					unitDropdown = {
						order = 1,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function() return db.NameAutoShorten.selectedUnit end,
						set = function(_, value) db.NameAutoShorten.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(db.NameAutoShorten.units) end,
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
	if not db.DetachPower.units.raid then
		for _, type in ipairs({'raid', 'raid40', 'arena', 'boss'}) do
			db.DetachPower.units[type] = CopyTable(db.DetachPower.units.party)
		end
	end
	if not db.NameAutoShorten.units.target then
		local units = core:getAllFrameTypes()
		units['player'] = nil
		for unitframeType in pairs(units) do
			db.NameAutoShorten.units[unitframeType] = CopyTable(db.NameAutoShorten.units.player)
		end
	end
end


function mod:Configure_Power(frame, noTemplateChange)
	if not frame.VARIABLES_SET then return end
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

function mod:UpdateNameSettings(units_db, frame, childType)
	local unit_db = units_db[frame.unitframeType]
	if unit_db and unit_db.xOffset ~= 0 then
		local db = frame.db
		if childType == "pet" then
			db = frame.db.petsGroup
		elseif childType == "target" then
			db = frame.db.targetsGroup
		end
		if not db.power or not db.power.enable or not db.power.hideonnpc then
			frame.Name:SetJustifyH("LEFT")
			frame.Name:Point(
				'RIGHT',
				(unit_db.toHealth and frame.Health and frame.Health.value) and frame.Health.value
					or UF:GetObjectAnchorPoint(frame, db.name.attachTextTo),
				unit_db.toHealth and 'LEFT' or 'RIGHT',
				unit_db.xOffset,
				db.name.yOffset
			)
		end
	end
end


function mod:Toggle(db)
	local enable = db.DetachPower.detachAll
	if not enable then
		for _, info in pairs(db.DetachPower.units) do
			if info.enabled then enable = true break end
		end
	end
	if not core.reload and enable then
		if not self:IsHooked(UF, "Configure_Power") then self:RawHook(UF, "Configure_Power", self.Configure_Power, true) end
	elseif self:IsHooked(UF, "Configure_Power") then self:Unhook(UF, "Configure_Power") end

	if not core.reload and db.NameAutoShorten.enabled then
		if not self:IsHooked(UF, "UpdateNameSettings") then
			local units_db = db.NameAutoShorten.units
			self:SecureHook(UF, "UpdateNameSettings", function(_, ...)
				self:UpdateNameSettings(units_db, ...)
			end)
		end
		if not self:IsHooked(UF, "Configure_HealthBar") then
			self:SecureHook(UF, "Configure_HealthBar", function(self, frame)
				UF:UpdateNameSettings(frame, frame.childType)
			end)
		end
	else
		if self:IsHooked(UF, "UpdateNameSettings") then self:Unhook(UF, "UpdateNameSettings") end
		if self:IsHooked(UF, "Configure_HealthBar") then self:Unhook(UF, "Configure_HealthBar") end
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback