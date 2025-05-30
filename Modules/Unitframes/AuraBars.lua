local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("AuraBars", "AceHook-3.0")
local UF = E:GetModule("UnitFrames")

local modName = mod:GetName()
local barsCreated = {}

local _G, pairs, ipairs, unpack = _G, pairs, ipairs, unpack
local twipe = table.wipe

mod.initialized = false

P["Extras"]["unitframes"][modName] = {
	["selectedUnit"] = 'player',
	["units"] = {
		["player"] = {
			["enabled"] = false,
			["spelltimeHide"] = false,
			["spelltimePoint"] = 'RIGHT',
			["spelltimeRelativeTo"] = 'RIGHT',
			["spelltimeXOffset"] = 0,
			["spelltimeYOffset"] = 0,
			["spellnameHide"] = false,
			["spellnamePoint"] = 'LEFT',
			["spellnameRelativeTo"] = 'LEFT',
			["spellnameXOffset"] = 0,
			["spellnameYOffset"] = 0,
			["bounce"] = true,
			["bounceFlipStartPos"] = false,
			["iconSize"] = 24,
			["barWidth"] = 0,
			["iconXoffset"] = 8,
		},
	},
}

function mod:LoadConfig(db)
	local function selectedUnit() return db.selectedUnit end
    local function selectedUnitData()
		return core:getSelected("unitframes", modName, format("units[%s]", selectedUnit() or ""), "player")
	end
	core.unitframes.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return selectedUnitData()[info[#info]] end,
		set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle(db) end,
		args = {
			AuraBars = {
				order = 1,
				type = "group",
				name = L["Aura Bars"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"],
					},
					unitDropdown = {
						order = 2,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						get = function() return db.selectedUnit end,
						set = function(_, value) db.selectedUnit = value end,
						values = function() return core:GetUnitDropdownOptions(db.units) end,
					},
				},
			},
			spellTime = {
				order = 2,
				type = "group",
				name = L["Spell Time"],
				guiInline = true,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					spelltimeHide = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Hide"],
						desc = "",
					},
					spelltimePoint = {
						order = 2,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return selectedUnitData().spelltimeHide end,
					},
					spelltimeRelativeTo = {
						order = 3,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return selectedUnitData().spelltimeHide end,
					},
					spelltimeXOffset = {
						order = 4,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["X Offset"],
						desc = "",
						hidden = function() return selectedUnitData().spelltimeHide end,
					},
					spelltimeYOffset = {
						order = 5,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["Y Offset"],
						desc = "",
						hidden = function() return selectedUnitData().spelltimeHide end,
					},
				},
			},
			spellName = {
				order = 3,
				type = "group",
				name = L["Spell Name"],
				guiInline = true,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					spellnameHide = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Hide"],
						desc = "",
					},
					spellnamePoint = {
						order = 2,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return selectedUnitData().spellnameHide end,
					},
					spellnameRelativeTo = {
						order = 3,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return selectedUnitData().spellnameHide end,
					},
					spellnameXOffset = {
						order = 4,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["X Offset"],
						desc = "",
						hidden = function() return selectedUnitData().spellnameHide end,
					},
					spellnameYOffset = {
						order = 5,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["Y Offset"],
						desc = "",
						hidden = function() return selectedUnitData().spellnameHide end,
					},
				},
			},
			icon = {
				order = 4,
				type = "group",
				name = L["Icon"],
				guiInline = true,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					bounce = {
						order = 1,
						type = "toggle",
						name = L["Bounce Icon Points"],
						desc = L["Set icon to the opposite side of the bar each new bar."],
					},
					bounceFlipStartPos = {
						order = 2,
						type = "toggle",
						name = L["Flip Starting Position"],
						desc = "",
						disabled = function() return not selectedUnitData().enabled or not selectedUnitData().bounce end,
					},
					iconSize = {
						order = 3,
						type = "range",
						min = 4, max = 60, step = 1,
						name = L["Icon Size"],
						desc = "",
					},
					iconXoffset = {
						order = 4,
						type = "range",
						min = 0, max = 40, step = 1,
						name = L["X Offset"],
						desc = L["0 to disable."],
					},
				},
			},
		},
	}
	if not db.units.target then
		for _, type in pairs({'target', 'focus', 'pet'}) do
			db.units[type] = CopyTable(db.units.player)
		end
	end
end


local function positionBars(db, bar, iconHolder, barIndex)
	if db.bounce then
		iconHolder:ClearAllPoints()

		local isEvenBar = (barIndex % 2 == 0)

		if db.bounceFlipStartPos then
			if isEvenBar then
				iconHolder:Point("RIGHT", bar, "LEFT", -db.iconXoffset, 0)
			else
				iconHolder:Point("LEFT", bar, "RIGHT", db.iconXoffset, 0)
			end
		else
			if isEvenBar then
				iconHolder:Point("LEFT", bar, "RIGHT", db.iconXoffset, 0)
			else
				iconHolder:Point("RIGHT", bar, "LEFT", -db.iconXoffset, 0)
			end
		end
	elseif db.iconXoffset ~= 0 then
		iconHolder:ClearAllPoints()
		iconHolder:Point("RIGHT", bar, "LEFT", -db.iconXoffset, 0)
	end
end

function mod:Construct_AuraBars()
	local frame = self:GetParent():GetParent()
	local unitframeType = frame.unitframeType
	local db = E.db.Extras.unitframes[modName].units[unitframeType]

	if not db.enabled then return end

	barsCreated[unitframeType] = barsCreated[unitframeType] + 1

	local bar = self.statusBar
	positionBars(db, bar, bar.iconHolder, barsCreated[unitframeType])

	if db.spelltimeHide then
		bar.spelltime:Hide()
	else
		bar.spelltime:ClearAllPoints()
		bar.spelltime:Point(db.spelltimePoint, bar, db.spelltimeRelativeTo, db.spelltimeXOffset, db.spelltimeYOffset)
		bar.spelltime:Show()
	end
	if db.spellnameHide then
		bar.spellname:Hide()
	else
		bar.spellname:ClearAllPoints()
		bar.spellname:Point(db.spellnamePoint, bar, db.spellnameRelativeTo, db.spellnameXOffset, db.spellnameYOffset)
		if not db.spelltimeHide then
			bar.spellname:Point("RIGHT", bar.spelltime, "LEFT", 0, 0)
		end
		bar.spellname:Show()
	end

	bar.iconHolder:Size(db.iconSize, db.iconSize)
end

function mod:UpdateFrame(frame, db)
	local auraBars = frame.AuraBars
	if not auraBars or not db.aurabar.enable then return end

	local unitframeType = frame.unitframeType

	barsCreated[unitframeType] = 0
	for _, bar in ipairs(auraBars.bars) do
		UF.Construct_AuraBars(bar)
		bar.statusBar.icon:SetTexCoord(unpack(E.TexCoords))
	end

	if frame == _G["ElvUF_Player"] and _G["ElvUF_Target"]
	 and E.db.unitframe.units.target.aurabar.enable
	 and E.db.unitframe.units.target.aurabar.attachTo == "PLAYER_AURABARS" then
		barsCreated['target'] = 0
		for _, bar in ipairs(_G["ElvUF_Target"].AuraBars.bars) do
			UF.Construct_AuraBars(bar)
			bar.statusBar.icon:SetTexCoord(unpack(E.TexCoords))
		end
	end
end

function mod:UpdatePostUpdateAuraBars(db)
	twipe(barsCreated)
	local units = db.units
	for _, frame in ipairs(core:AggregateUnitFrames()) do
		local unitframeType = frame.unitframeType
		if units[unitframeType] then
			if frame.db.aurabar and frame.db.aurabar.enable then
				local auraBars = frame.AuraBars

				auraBars.gap = units[unitframeType].enabled and -frame.db.aurabar.height or (-frame.BORDER + frame.SPACING*3)
				auraBars.PostCreateBar = UF.Construct_AuraBars
				auraBars:SetAnchors()

				UF:Configure_AuraBars(frame)

				-- update existing bars
				barsCreated[unitframeType] = 0
				for _, bar in ipairs(auraBars.bars) do
					UF.Construct_AuraBars(bar)
					if not units[unitframeType].enabled then
						bar.statusBar.iconHolder:ClearAllPoints()
						bar.statusBar.iconHolder:Point("RIGHT", bar.statusBar, "LEFT", 0, 0)
						bar.statusBar.spelltime:ClearAllPoints()
						bar.statusBar.spelltime:Point("RIGHT", bar.statusBar, "RIGHT", 0, 0)
					end
					bar.statusBar.icon:SetTexCoord(unpack(E.TexCoords))
				end
			end
		end
	end
end


function mod:Toggle(db)
	local enable
	if not core.reload then
		for _, enabled in pairs(db.units) do
			if enabled then enable = true break end
		end
	end
	if enable then
		if not self:IsHooked(UF, "Construct_AuraBars") then self:SecureHook(UF, "Construct_AuraBars", self.Construct_AuraBars) end
		for _, type in ipairs({"Update_PlayerFrame", "Update_TargetFrame", "Update_FocusFrame", "Update_PetFrame"}) do
			if not self:IsHooked(UF, type) then self:SecureHook(UF, type, self.UpdateFrame) end
		end
		self.initialized = true
	elseif self.initialized then
		if self:IsHooked(UF, "Construct_AuraBars") then self:Unhook(UF, "Construct_AuraBars") end
		for _, type in ipairs({"Update_PlayerFrame", "Update_TargetFrame", "Update_FocusFrame", "Update_PetFrame"}) do
			if self:IsHooked(UF, type) then self:Unhook(UF, type) end
		end
	end
	if self.initialized then
		self:UpdatePostUpdateAuraBars(db)
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback