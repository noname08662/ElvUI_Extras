local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Movers Plus", "AceHook-3.0")
local S = E:GetModule("Skins")

local modName = mod:GetName()
local pickMode, frameToAnchor = false

mod.initialized = false

local _G, pairs, unpack = _G, pairs, unpack
local format, split = string.format, string.split
local EditBox_ClearFocus = EditBox_ClearFocus
local UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, UIDropDownMenu_SetSelectedValue, UIDropDownMenu_Initialize = UIDropDownMenu_CreateInfo, UIDropDownMenu_AddButton, UIDropDownMenu_SetSelectedValue, UIDropDownMenu_Initialize


local function setMovers(enable)
	for mover in pairs(E.CreatedMovers) do
		if E.db.movers and E.db.Extras.movers and E.db.movers[mover] and E.db.Extras.movers[mover] then
			local point, anchor, relativeTo, x, y = split(",", enable and E.db.Extras.movers[mover] or E.db.movers[mover])
			local anchorFrame = _G[anchor]

			if anchorFrame then
				_G[mover]:ClearAllPoints()
				_G[mover]:Point(point, anchorFrame, relativeTo, x, y)
			end

			if not enable and _G[mover]:GetScript("OnDragStart") then
				_G[mover]:RegisterForDrag("LeftButton", "RightButton")
			end
		end
	end
end


P["Extras"].movers = {}
P["Extras"]["general"][modName] = {
	["enabled"] = false,

	--[[ 						in case i'll be bringing it back
	selectedProfile = 1,
	profiles = { { name = "New Profile", moversData = E.db.movers } },
	specProfiles = {
		[1] = { enabled = false, profileToLoad = 1 },
		[2] = { enabled = false, profileToLoad = 1 },
		[3] = { enabled = false, profileToLoad = 1 },
	},	]]--
}

function mod:LoadConfig(db)
	core.general.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value mod:Toggle(db) end,
		args = {
			MoversPlus = {
                type = "group",
                name = L[modName],
				guiInline = true,
                args = {
					enabled = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Adds anchoring options to the movers' nudges."],
					},
				},
			},
		},
	}
end


function mod:ResetMovers(self, arg)
	local all = not arg or arg == ""
	if all then self.db.movers = nil end

	for name, holder in pairs(E.CreatedMovers) do
		if all or (holder.mover and holder.mover.textString == arg) then
			if all then
				self.db.Extras.movers = nil
			else
				self.db.Extras.movers[name] = nil
				if _G[name]:GetScript("OnDragStart") then _G[name]:RegisterForDrag("LeftButton", "RightButton") end
				break
			end
		end
	end
end

function mod:NudgeMover(self, nudgeX, nudgeY, pointCustom, anchorFrame, relativeToCustom)
	local mover = ElvUIMoverNudgeWindow.child
	local point, anchor, relativeTo, x, y

	if E.db.Extras.movers[mover.name] then
		point, anchor, relativeTo, x, y = split(",", E.db.Extras.movers[mover.name])
	end

	if anchorFrame ~= nil then
		mover:ClearAllPoints()
		mover:Point('CENTER', anchorFrame)
		if mover:GetScript('OnDragStart') then mover:RegisterForDrag(nil) end
		E.db.Extras.movers[mover.name] = format("%s,%s,%s,%d,%d", "CENTER", anchorFrame:GetName() or "UIParent", "CENTER", 0, 0)
		E:UpdateNudgeFrame(mover)
	elseif anchor and anchor ~= E.UIParent then
		point, anchor, relativeTo, x, y =
			pointCustom or point or "CENTER", _G[anchor] or E.UIParent, relativeToCustom or relativeTo or "CENTER",
			(x or 0) + (nudgeX or 0), (y or 0) + (nudgeY or 0)
		mover:ClearAllPoints()
		mover:Point(point, anchor, relativeTo, x, y)
		E.db.Extras.movers[mover.name] = format("%s,%s,%s,%d,%d", point, anchor:GetName(), relativeTo, x, y)
		E:UpdateNudgeFrame(mover)
	end
end

function mod:UpdateNudgeFrame(self, mover)
	local ElvUIMoverNudgeWindow = ElvUIMoverNudgeWindow
	local anchoredTo = ElvUIMoverNudgeWindow.anchoredTo
	if not anchoredTo then
		local anchoredTo = CreateFrame("EditBox", "$parentAnchoredTo", ElvUIMoverNudgeWindow, "InputBoxTemplate")
		anchoredTo:Size(160, 17)
		anchoredTo:SetAutoFocus(false)
		anchoredTo.currentValue = "ElvUIParent"
		anchoredTo:SetScript("OnEditFocusGained", function(eb) EditBox_ClearFocus(eb) end)
		anchoredTo:SetScript("OnShow", function(eb)
			EditBox_ClearFocus(eb)
			eb:SetText(anchoredTo.currentValue)
		end)

		anchoredTo.text = anchoredTo:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		anchoredTo.text:Point("BOTTOM", anchoredTo, "TOP", 0, 4)
		anchoredTo.text:SetText("Anchored to:")
		anchoredTo:Point("TOP", ElvUIMoverNudgeWindow, "TOP", 0, -32)
		ElvUIMoverNudgeWindow.anchoredTo = anchoredTo
		S:HandleEditBox(anchoredTo)

		ElvUIMoverNudgeWindow.xOffset:ClearAllPoints()
		ElvUIMoverNudgeWindow.yOffset:ClearAllPoints()
		ElvUIMoverNudgeWindow.xOffset:Point("TOPRIGHT", anchoredTo, "BOTTOM", -8, -8)
		ElvUIMoverNudgeWindow.yOffset:Point("TOPLEFT", anchoredTo, "BOTTOM", 16, -8)
		ElvUIMoverNudgeWindow.resetButton:ClearAllPoints()
		ElvUIMoverNudgeWindow.resetButton:Point('BOTTOM', ElvUIMoverNudgeWindow, 'BOTTOM', 0, 32)

		local function createDropdown(name, text, anchor, x, y)
			local dropdown = CreateFrame("Frame", "$parent"..name, ElvUIMoverNudgeWindow, "UIDropDownMenuTemplate")
			dropdown:Point('TOPRIGHT', anchor, 'BOTTOMRIGHT', x, y)
			dropdown.text = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			dropdown.text:Point("RIGHT", dropdown.backdrop, "LEFT", 4, 2)
			dropdown.text:SetText(text)
			dropdown:Hide()
			S:HandleDropDownBox(dropdown, 120)
			return dropdown
		end

		local function populateDropdown(dropdown, type)
			local function CreateDropdownMenuItem(point)
				local info = UIDropDownMenu_CreateInfo()
				info.text = point
				info.value = point
				info.func = function()
					UIDropDownMenu_SetSelectedValue(dropdown, point)
					E:NudgeMover(nil, nil, type == 'point' and point, nil, type == 'relativeTo' and point)
				end
				return info
			end
			for _, point in pairs(E.db.Extras.pointOptions) do
				UIDropDownMenu_AddButton(CreateDropdownMenuItem(point))
			end
		end

		local pointDropdown = createDropdown("PointDropdown", L["Point:"], anchoredTo, 8, -30)
		ElvUIMoverNudgeWindow.pointDropdown = pointDropdown

		local relativeToDropdown = createDropdown("RelativeToDropdown", L["Relative:"], pointDropdown, 0, 4)
		ElvUIMoverNudgeWindow.relativeToDropdown = relativeToDropdown

		UIDropDownMenu_Initialize(pointDropdown, function() populateDropdown(pointDropdown, 'point') end)
		UIDropDownMenu_Initialize(relativeToDropdown, function() populateDropdown(relativeToDropdown, 'relativeTo') end)

		local pickMoverButton = CreateFrame("Button", "$parentPickMoverButton", ElvUIMoverNudgeWindow, "UIPanelButtonTemplate")
		pickMoverButton:SetText(L["Pick a..."])
		pickMoverButton:Point("BOTTOM", ElvUIMoverNudgeWindow.resetButton, "TOP", 0, 24)
		pickMoverButton:Size(100, 25)
		ElvUIMoverNudgeWindow.pickMoverButton = pickMoverButton
		S:HandleButton(pickMoverButton)

		local pickModeHint = pickMoverButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		pickModeHint:Point("TOP", pickMoverButton, "BOTTOM", 0, -4)
		pickModeHint:SetText(L["...mover to anchor to."])

		local function togglePickMode()
			pickMode = not pickMode
			if pickMode then
				frameToAnchor = ElvUIMoverNudgeWindow.child
				ElvUIMoverNudgeWindow:SetBackdropBorderColor(0,1,0)
				pickModeHint:SetText(L["...mover to anchor."])
			else
				ElvUIMoverNudgeWindow:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
				pickModeHint:SetText(L["...mover to anchor to."])
			end
		end

		pickMoverButton:SetScript("OnClick", function()
			if not pickMode then togglePickMode() return end
			if ElvUIMoverNudgeWindow.child ~= frameToAnchor and ElvUIMoverNudgeWindow.child:GetParent() ~= frameToAnchor and frameToAnchor:GetParent() ~= ElvUIMoverNudgeWindow.child then
				anchoredTo:SetText(frameToAnchor.name)
				E:NudgeMover(nil, nil, nil, frameToAnchor)
				togglePickMode()
			end
		end)

		pickMoverButton:EnableKeyboard(true)
		pickMoverButton:SetScript("OnKeyDown", function(_, key)
			if key == 'ESCAPE' then
				if pickMode then
					togglePickMode()
				else
					ElvUIMoverNudgeWindow:Hide()
				end
			end
		end)
	elseif not anchoredTo:IsShown() then
		ElvUIMoverNudgeWindow.anchoredTo:Show()
		ElvUIMoverNudgeWindow.pointDropdown:Show()
		ElvUIMoverNudgeWindow.relativeToDropdown:Show()
		ElvUIMoverNudgeWindow.pickMoverButton:Show()
		ElvUIMoverNudgeWindow.xOffset:ClearAllPoints()
		ElvUIMoverNudgeWindow.yOffset:ClearAllPoints()
		ElvUIMoverNudgeWindow.xOffset:Point("TOPRIGHT", anchoredTo, "BOTTOM", -8, -8)
		ElvUIMoverNudgeWindow.yOffset:Point("TOPLEFT", anchoredTo, "BOTTOM", 16, -8)
		ElvUIMoverNudgeWindow.resetButton:ClearAllPoints()
		ElvUIMoverNudgeWindow.resetButton:Point("BOTTOM", ElvUIMoverNudgeWindow, "BOTTOM", 0, 32)
	end

	local point, anchor, relativeTo, x, y
	if E.db.Extras.movers and E.db.Extras.movers[mover.name] then
		point, anchor, relativeTo, x, y = split(",", E.db.Extras.movers[mover.name])
	end

	if not anchor or anchor == E.UIParent then
		x, y = E:CalculateMoverPoints(mover)
		ElvUIMoverNudgeWindow.anchoredTo:SetText("")
		ElvUIMoverNudgeWindow.anchoredTo.currentValue = ""
		ElvUIMoverNudgeWindow.pointDropdown:Hide()
		ElvUIMoverNudgeWindow.relativeToDropdown:Hide()
		ElvUIMoverNudgeWindow:Height(190)
	else
		ElvUIMoverNudgeWindow.anchoredTo:SetText(anchor)
		ElvUIMoverNudgeWindow.anchoredTo.currentValue = anchor
		UIDropDownMenu_SetSelectedValue(ElvUIMoverNudgeWindow.pointDropdown, point)
		UIDropDownMenu_SetSelectedValue(ElvUIMoverNudgeWindow.relativeToDropdown, relativeTo)
		ElvUIMoverNudgeWindow.pointDropdown:Show()
		ElvUIMoverNudgeWindow.relativeToDropdown:Show()
		ElvUIMoverNudgeWindow:Height(245)
	end

	x = E:Round(x)
	y = E:Round(y)
	ElvUIMoverNudgeWindow.xOffset:SetText(x)
	ElvUIMoverNudgeWindow.yOffset:SetText(y)
	ElvUIMoverNudgeWindow.xOffset.currentValue = x
	ElvUIMoverNudgeWindow.yOffset.currentValue = y
end


function mod:Toggle(db)
	if not core.reload and db.enabled then
		for _, func in pairs({'UpdateNudgeFrame', 'NudgeMover', 'ResetMovers'}) do
			if not self:IsHooked(E, func) then self:SecureHook(E, func) end
		end
		setMovers(true)
		self.initialized = true
	elseif self.initialized then
		for _, func in pairs({'UpdateNudgeFrame', 'NudgeMover', 'ResetMovers'}) do
			if self:IsHooked(E, func) then self:Unhook(E, func) end
		end
		local nudge = ElvUIMoverNudgeWindow
		if nudge then
			nudge.anchoredTo:Hide()
			nudge.pointDropdown:Hide()
			nudge.relativeToDropdown:Hide()
			nudge.pickMoverButton:Hide()
			nudge.xOffset:ClearAllPoints()
			nudge.xOffset:Point("BOTTOMRIGHT", nudge, "CENTER", -6, 8)
			nudge.yOffset:ClearAllPoints()
			nudge.yOffset:Point("BOTTOMLEFT", nudge, "CENTER", 16, 8)
			nudge.resetButton:ClearAllPoints()
			nudge.resetButton:Point("TOP", nudge, "CENTER", 0, 2)
			nudge:Size(200, 110)
		end
		setMovers()
	end
end

function mod:InitializeCallback()
	local db = E.db.Extras.general[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback