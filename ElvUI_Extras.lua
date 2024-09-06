local E, L, _, P = unpack(ElvUI)
local core = E:NewModule("Extras", "AceHook-3.0", "AceEvent-3.0")
local UF = E:GetModule("UnitFrames")
local NP = E:GetModule("NamePlates")
local S = E:GetModule("Skins")
local EP = E.Libs.EP
local LSM = E.Libs.LSM
local ElvUF = E.oUF

local AddOnName = ...
local isAwesome = C_NamePlate and E.private.nameplates.enable
local taggedFrames, tags = {}, {}

core.modules = {}
core.nameUpdates = {}
core.frameUpdates = {}

local CreateFrame, UIParent, UIDropDownMenu_Refresh = CreateFrame, UIParent, UIDropDownMenu_Refresh
local _G, unpack, pairs, ipairs, select, tonumber, print = _G, unpack, pairs, ipairs, select, tonumber, print
local gsub, find, sub, lower, upper, format = string.gsub, string.find, string.sub, string.lower, string.upper, string.format
local max, ceil, floor = math.max, math.ceil, math.floor
local tinsert, tremove, twipe, tsort = table.insert, table.remove, table.wipe, table.sort
local UnitGUID, UnitClass, UnitExists = UnitGUID, UnitClass, UnitExists
local UnitThreatSituation, GetThreatStatusColor = UnitThreatSituation, GetThreatStatusColor
local UnitReaction, UnitIsPlayer, UnitFactionGroup = UnitReaction, UnitIsPlayer, UnitFactionGroup
local GetNumMacroIcons, GetMacroIconInfo, GameTooltip = GetNumMacroIcons, GetMacroIconInfo, GameTooltip
local UnitPopupMenus, UnitPopupShown = UnitPopupMenus, UnitPopupShown
local GetRaidRosterInfo, IsPartyLeader, IsRaidOfficer = GetRaidRosterInfo, IsPartyLeader, IsRaidOfficer
local InCombatLockdown, IsControlKeyDown = InCombatLockdown, IsControlKeyDown
local LUA_ERROR, FORMATTING, ERROR_CAPS = LUA_ERROR, FORMATTING, ERROR_CAPS

local E_Delay = E.Delay
local updatePending = false

local function colorConvert(r, g, b)
	if tonumber(r) then
        return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	else
		local hex = gsub(r, "|c%w%w", "")

		r = tonumber(sub(hex, 1, 2), 16) / 255
		g = tonumber(sub(hex, 3, 4), 16) / 255
		b = tonumber(sub(hex, 5, 6), 16) / 255

		return r, g, b
	end
end


-- make worlmap quests open quest log on ctrl-click
if not core:IsHooked("WorldMapQuestFrame_OnMouseUp") then
	core:SecureHook("WorldMapQuestFrame_OnMouseUp", function(self)
		if InCombatLockdown() then
			return
		elseif IsControlKeyDown() then
			if not QuestLogFrame:IsShown() then
				ShowUIPanel(QuestLogFrame)
			end

			QuestLog_SetSelection(self.questLogIndex)
			QuestLog_Update()
		end
	end)
end


-- restored raid controls
local function createSecurePromoteButton(name, role)
    local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    button:SetFrameStrata("TOOLTIP")
    button:Hide()

    button:SetAttribute("type", role)
    button:SetAttribute("unit", "target")
    button:SetAttribute("action", "toggle")

	button:RegisterEvent("PLAYER_REGEN_DISABLED")
	button:RegisterEvent("PLAYER_REGEN_ENABLED")

	RegisterStateDriver(button, "visibility", "[combat] hide")
    return button
end

local function setButton(unit, button, newButton)
	newButton:SetAllPoints(button)
	newButton:SetAttribute("unit", unit or "target")
	newButton:SetScript("OnEnter", function()
		button:GetScript("OnEnter")(button)
	end)
	newButton:SetScript("OnLeave", function()
		button:GetScript("OnLeave")(button)
	end)
	newButton:SetScript("OnMouseDown", function()
		button:SetButtonState("PUSHED")
	end)
	newButton:SetScript("OnMouseUp", function()
		button:SetButtonState("NORMAL")
	end)
	newButton:SetScript("PostClick", function()
		button:GetScript("OnClick")(button)
	end)
	newButton:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_REGEN_DISABLED" then
			self:EnableMouse(false)
			button:EnableMouse(false)
            button:SetAlpha(0.5)
		else
			self:EnableMouse(true)
			button:EnableMouse(true)
            button:SetAlpha(1)
		end
	end)
	newButton:Show()
end

local secureTankButton = createSecurePromoteButton("ElvUI_SecureTankButton", "maintank")
local secureAssistButton = createSecurePromoteButton("ElvUI_SecureAssistButton", "mainassist")

if not core:IsHooked("UnitPopup_OnClick") then
    core:SecureHook("UnitPopup_OnClick", function(self)
        local button = self.value
        local dropdownFrame = UIDROPDOWNMENU_INIT_MENU

        if button == "RAID_MAINTANK" or button == "RAID_MAINASSIST" then
           UIDropDownMenu_Refresh(dropdownFrame, nil, 1)
        end
    end)
end

if not core:IsHooked("UnitPopup_ShowMenu") then
    core:SecureHook("UnitPopup_ShowMenu", function(_, _, unit)
        if UIDROPDOWNMENU_MENU_LEVEL ~= 1 then return end

		for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
			local button = _G["DropDownList1Button"..i]
			if button and button:IsShown() then
				if button.value == "RAID_MAINTANK" then
					setButton(unit, button, secureTankButton)
				elseif button.value == "RAID_MAINASSIST" then
					setButton(unit, button, secureAssistButton)
				end
			end
		end
    end)
end

if not core:IsHooked("UnitPopup_HideButtons") then
    core:SecureHook("UnitPopup_HideButtons", function()
        local dropdownMenu = UIDROPDOWNMENU_INIT_MENU
		local isAuthority = IsPartyLeader() or IsRaidOfficer()

		if dropdownMenu.which ~= "RAID" or not isAuthority then return end

        for index, value in ipairs(UnitPopupMenus[dropdownMenu.which]) do
            if value == "RAID_MAINTANK" then
				local role = select(10,GetRaidRosterInfo(dropdownMenu.userData))
				if role ~= "MAINTANK" or not dropdownMenu.name then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 1
				end
			elseif value == "RAID_MAINASSIST" then
				local role = select(10,GetRaidRosterInfo(dropdownMenu.userData))
				if role ~= "MAINASSIST" or not dropdownMenu.name then
					UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 1
				end
            end
        end
    end)
end

if not core:IsHooked(DropDownList1, "OnHide") then
	core:SecureHookScript(DropDownList1, "OnHide", function()
		if InCombatLockdown() then return end
        secureTankButton:Hide()
        secureAssistButton:Hide()
	end)
end


function core:getAllFrameTypes()
	return {
		["player"] = true,
		["target"] = true,
		["targettarget"] = true,
		["targettargettarget"] = true,
		["focus"] = true,
		["focustarget"] = true,
		["pet"] = true,
		["pettarget"] = true,
		["raid"] = true,
		["raid40"] = true,
		["raidpet"] = true,
		["party"] = true,
		["partypet"] = true,
		["partytarget"] = true,
		["boss"] = true,
		["arena"] = true,
		["assist"] = true,
		["assisttarget"] = true,
		["tank"] = true,
		["tanktarget"] = true,
	}
end

function core:print(type, ...)
	if type == 'LUA' then
		print(format(core.customColorAlpha.."ElvUI "..core.pluginColor.."Extras"..core.customColorAlpha..","..
					core.customColorBeta.." %s "..core.customColorBad..LUA_ERROR..core.customColorAlpha..":|r %s", ...))
	elseif type == 'FORMATTING' then
		print(format(core.customColorAlpha.."ElvUI "..core.pluginColor.."Extras"..core.customColorAlpha..","..
					core.customColorBeta.." %s "..core.customColorBad.." "..FORMATTING.." "..ERROR_CAPS, ...))
	elseif type == 'FAIL' then
		print(format(core.customColorAlpha.."ElvUI "..core.pluginColor.."Extras"..core.customColorAlpha..","..
					core.customColorBeta.." %s "..core.customColorAlpha..":|r %s", ...))
	elseif type == 'ADDED' then
		print(format(core.customColorAlpha.."%s"..core.customColorBeta..(select(2,...) and "%s" or L[" added."]), ...))
	elseif type == 'REMOVED' then
		print(format(core.customColorAlpha.."%s"..core.customColorBeta..(select(2,...) and "%s" or L[" removed."]), ...))
	end
end


core.PurgeList = {
	MAGE = true,
	PRIEST = true,
	SHAMAN = true,
	WARLOCK = true,
}

core.DispellList = {
	PRIEST = {Magic = true, Disease = true},
	SHAMAN = {Poison = true, Disease = true, Curse = false},
	PALADIN = {Poison = true, Magic = true, Disease = true},
	MAGE = {Curse = true},
	DRUID = {Curse = true, Poison = true},
	WARLOCK = {Magic = true},
}


-- Awesome WOTLK
if isAwesome then
	local target = CreateFrame("Frame")
	local mouseover = CreateFrame("Frame")
	local GetNamePlates = C_NamePlate.GetNamePlates
	local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
	local LAI = E.Libs.LAI


	core:RegisterEvent('PLAYER_TARGET_CHANGED', function()
		if not UnitExists('target') then return end
		if target.exists then
			for _, np in pairs(GetNamePlates()) do
				NP:SetTargetFrame(np.UnitFrame)
				NP:ResetNameplateFrameLevel(np.UnitFrame)
			end
		else
			target.exists = true
			target:SetScript('OnUpdate', function()
				for _, np in pairs(GetNamePlates()) do
					local frame = np.UnitFrame
					if not frame.isTarget then
						frame.alpha = np:GetAlpha()
						np:SetAlpha(1)
						NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), NP.db.nonTargetTransparency)
					end
				end
				if not UnitExists('target') then
					for _, np in pairs(GetNamePlates()) do
						NP:SetTargetFrame(np.UnitFrame)
					end
					target.exists = false
					target:SetScript('OnUpdate', nil)
				end
			end)
			local plate = GetNamePlateForUnit('target')
			if not plate or not plate.UnitFrame then return end
			local frame = plate.UnitFrame
			NP:SetTargetFrame(frame)
			for _, np in pairs(GetNamePlates()) do
				NP:ResetNameplateFrameLevel(np.UnitFrame)
			end
		end
	end)

	core:RegisterEvent('UPDATE_MOUSEOVER_UNIT', function()
		local plate = GetNamePlateForUnit('mouseover')
		if not plate or not plate.UnitFrame then return end
		local frame = plate.UnitFrame
		NP:SetMouseoverFrame(frame)
		mouseover:SetScript("OnUpdate", function()
			for _, np in pairs(GetNamePlates()) do
				local unitframe = np.UnitFrame
				local unit = np.unit
				if unitframe and unitframe.isMouseover and unit and plate.unit and UnitGUID(plate.unit) ~= UnitGUID(unit) then
					NP:SetMouseoverFrame(unitframe)
				end
			end
			if not UnitExists('mouseover') then
				NP:SetMouseoverFrame(frame)
				mouseover:SetScript("OnUpdate", nil)
				return
			end
		end)
	end)

	core:RegisterEvent('UNIT_THREAT_LIST_UPDATE', function(_, unit)
		if not unit then return end
		local plate = GetNamePlateForUnit(unit)
		if not plate or not plate.UnitFrame or not find(unit, 'nameplate') then return end
		local status = UnitThreatSituation("player", unit)
		if plate.UnitFrame.ThreatStatus ~= status then
			plate.UnitFrame.ThreatStatus = status
			NP:Update_HealthColor(plate.UnitFrame)
		end
	end)

	core:RegisterEvent('NAME_PLATE_CREATED', function(_, plate)
		local onShow, onHide = plate:GetScript("OnShow"), plate:GetScript("OnHide")
		NP:OnCreated(plate)
		plate:SetScript("OnShow", onShow)
		plate:SetScript("OnHide", onHide)
	end)

	core:RegisterEvent('NAME_PLATE_OWNER_CHANGED', function(_, unit)
		local plate = GetNamePlateForUnit(unit)
		core:UpdateNameplate(plate.UnitFrame, unit)
		NP.OnShow(plate, nil, true)
	end)

	core:RegisterEvent('NAME_PLATE_UNIT_REMOVED', function(_, unit)
		local plate = GetNamePlateForUnit(unit)
		if plate then plate.unit = nil end
		NP.OnHide(plate, nil, true)
	end)

	core:RegisterEvent('NAME_PLATE_UNIT_ADDED', function(_, unit)
		local plate = GetNamePlateForUnit(unit)
		if plate then plate.unit = unit end
		core:UpdateNameplate(plate.UnitFrame, unit)
		NP.OnShow(plate, nil, true)
	end)


	function core:UpdateNameplate(frame, unit)
		local guid = UnitGUID(unit)
		LAI:RemoveAllAurasFromGUID(guid)
		LAI.frame:UNIT_AURA(nil, unit)
		if UnitThreatSituation('player') and UnitThreatSituation('player') > 1 then
			frame.ThreatStatus = UnitThreatSituation("player", unit)
		end
	end

	function core:SetTargetFrame(_, frame)
		local unit = frame:GetParent().unit
		if not unit then return end
		local isTargetUnit = UnitGUID(unit) == UnitGUID("target")

		if isTargetUnit then
			if not frame.isTarget then
				NP:PlateFade(frame, 0, frame:GetAlpha(), 1)
				frame.isTarget = true
				if NP.db.useTargetScale then
					NP:SetFrameScale(frame, (frame.ThreatScale or 1) * NP.db.targetScale)
				end
				if not NP.db.units[frame.UnitType].health.enable and NP.db.alwaysShowTargetHealth then
					frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil
					NP:Configure_HealthBar(frame)
					NP:Configure_CastBar(frame)
					NP:Configure_Elite(frame)
					NP:Configure_CPoints(frame)
					NP:RegisterEvents(frame)
					NP:UpdateElement_All(frame, true)
				end
				NP:Update_Highlight(frame)
				NP:Update_CPoints(frame)
				NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
				NP:ForEachVisiblePlate("ResetNameplateFrameLevel")
			end
		else
			NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), UnitExists('target') and NP.db.nonTargetTransparency or 1)
			if frame.isTarget then
				frame.isTarget = nil
				if NP.db.useTargetScale then
					NP:SetFrameScale(frame, (frame.ThreatScale or 1))
				end
				if not frame.isGroupUnit then
					if frame.isEventsRegistered then
						NP:UnregisterAllEvents(frame)
						NP:Update_CastBar(frame)
					end
				end
				if not NP.db.units[frame.UnitType].health.enable then
					NP:UpdateAllFrame(frame, nil, true)
				end
				NP:Update_CPoints(frame)
				frame:SetFrameLevel(#GetNamePlates())
			end
			NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
		end
		NP:Configure_Glow(frame)
		NP:Update_Glow(frame)
	end

	function core:GetUnitByName(self, frame, unitType)
		local plate = frame:GetParent()
		if plate.unit then return plate.unit end
		return core.hooks[NP].GetUnitByName(self, frame, unitType)
	end

	function core:UnitClass(self, frame, unitType)
		local plate = frame:GetParent()
		if plate.unit then return select(2,UnitClass(plate.unit)) end
		return core.hooks[NP].UnitClass(self, frame, unitType)
	end

	function core:GetUnitInfo(self, frame)
		local plate = frame:GetParent()
		if plate.unit then
			local reaction = UnitReaction("player", plate.unit)
			local isPlayer = UnitIsPlayer(plate.unit)
			local unitType

			if isPlayer and reaction and reaction >= 5 then
				unitType = "FRIENDLY_PLAYER"
			elseif not isPlayer and (reaction and reaction >= 5) or UnitFactionGroup(plate.unit) == "Neutral" then
				unitType = "FRIENDLY_NPC"
			elseif not isPlayer and (reaction and reaction <= 4) then
				unitType = "ENEMY_NPC"
			else
				unitType = "ENEMY_PLAYER"
			end
			return reaction, unitType
		end
		return core.hooks[NP].GetUnitInfo(self, frame)
	end

	function core:UnitDetailedThreatSituation(self, frame)
		local plate = frame:GetParent()
		if plate.unit then return UnitThreatSituation("player", plate.unit) end
		return core.hooks[NP].UnitDetailedThreatSituation(self, frame)
	end

	function core:ResetNameplateFrameLevel(_, frame)
		if frame.FrameLevelChanged then
			--calculate Style Filter FrameLevelChanged leveling
			--level method: (10*(40*2)) max 800 + max 80 (40*2) = max 880
			--highest possible should be level 880 and we add 1 to all so 881
			--local leveledCount = NP.CollectedFrameLevelCount or 1
			--level = (frame.FrameLevelChanged*(40*NP.levelStep)) + (leveledCount*NP.levelStep)
			local level = #GetNamePlates() + frame.FrameLevelChanged * 10

			frame:SetFrameLevel(level+1)
			frame.Shadow:SetFrameLevel(level-1)
			frame.Buffs:SetFrameLevel(level+1)
			frame.Debuffs:SetFrameLevel(level+1)
			frame.LevelHandled = true

			local target = GetNamePlateForUnit('target')
			local plate = target and target.UnitFrame

			if plate and plate:IsShown() and frame ~= plate then
				if level > plate:GetFrameLevel() then
					plate:SetFrameLevel(frame:GetFrameLevel() + 10)
				end
			end
		elseif frame.LevelHandled then
			local level = #GetNamePlates()
			frame:SetFrameLevel(level-1)
			frame.Shadow:SetFrameLevel(level-2)
			frame.Buffs:SetFrameLevel(level-1)
			frame.Debuffs:SetFrameLevel(level-1)
			frame.LevelHandled = false
		end
	end


	if not core:IsHooked(NP, "OnUpdate") then
		core:RawHook(NP, "OnUpdate", function(self) self:SetScript('OnUpdate', nil) end)
	end
end
--


function core:AggregateUnitFrames()
    local units = {}
	for _, frame in ipairs(ElvUF.objects) do
		tinsert(units, frame)
	end
	return units
end

function core:GetUnitDropdownOptions(db)
	local options = {}
	for option in pairs(db) do
		options[option] = L[option] and L[option] or option
	end
	return options
end

function core:GetIconList(texList)
    local list = {}
    local sortedKeys = {}

    for path, info in pairs(texList) do
        tinsert(sortedKeys, {path = path, label = info.label, ["icon"] = info.icon})
    end
    tsort(sortedKeys, function(a, b)
        return a.label < b.label
    end)
    for _, item in ipairs(sortedKeys) do
        list[item.path] = item.label .. ' |T' .. item.icon .. ':16:16|t'
    end
    return list
end

function core:OpenEditor(title, text, acceptFunc)
	if not self.EditFrame then
		self.EditFrame = CreateFrame("Frame", "ElvUI_Extras_Editor", UIParent)
		self.EditFrame:Size(600, 400)
		self.EditFrame:SetPoint("CENTER")
		self.EditFrame:SetMovable(true)
		self.EditFrame:SetTemplate('Transparent')
		self.EditFrame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		self.EditFrame:SetScript("OnKeyDown", function(_, key)
			if key == "ESCAPE" then
				core.EditFrame:Hide()
				E:ToggleOptionsUI()
			end
		end)

		self.EditFrame.header = CreateFrame("Button", nil, self.EditFrame)
		self.EditFrame.header:SetTemplate(nil, true)
		self.EditFrame.header:Size(100, 25)
		self.EditFrame.header:Point("CENTER", self.EditFrame, "TOP")
		self.EditFrame.header:SetFrameLevel(self.EditFrame.header:GetFrameLevel() + 2)
		self.EditFrame.header:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		self.EditFrame.header:SetScript("OnShow", E.MoverNudgeOnShow)
		self.EditFrame.header:EnableMouse(true)
		self.EditFrame.header:RegisterForClicks("AnyUp", "AnyDown")

		self.EditFrame.header:SetScript("OnMouseDown", function()
			core.EditFrame:StartMoving()
		end)

		self.EditFrame.header:SetScript("OnMouseUp", function()
			core.EditFrame:StopMovingOrSizing()
		end)

		self.EditFrame.title = self.EditFrame.header:CreateFontString("OVERLAY")
		self.EditFrame.title:FontTemplate()
		self.EditFrame.title:Point("CENTER", self.EditFrame.header, "CENTER")
		self.EditFrame.title:SetText(title)
		self.EditFrame.title:SetTextColor(1, 0.82, 0)

		self.EditFrame.header:Width(self.EditFrame.title:GetStringWidth() + 16)

		self.EditFrame.scrollFrame = CreateFrame("ScrollFrame", "ElvUI_Extras_EditorScrollFrame", self.EditFrame, "UIPanelScrollFrameTemplate")
		self.EditFrame.scrollFrame:Point("TOP", self.EditFrame.title, "BOTTOM", 0, -16)
		self.EditFrame.scrollFrame:Size(540, 330)

		local scrollBar = _G['ElvUI_Extras_EditorScrollFrameScrollBar']
		scrollBar:SetAlpha(0)

		self.EditFrame.editBox = CreateFrame("EditBox", "ElvUI_Extras_EditorEditBox", self.EditFrame.scrollFrame)
		self.EditFrame.editBox:SetMultiLine(true)
		self.EditFrame.editBox:SetFontObject(ChatFontNormal)

		self.EditFrame.editBox:Size(540, 330)
		self.EditFrame.editBox:SetAutoFocus(false)
		self.EditFrame.editBox:SetFrameLevel(self.EditFrame:GetFrameLevel() + 10)
		self.EditFrame.editBox:SetText(text)
		self.EditFrame.editBox:SetTextColor(1,0.82,0)
		self.EditFrame.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
		
		self.EditFrame.editBox:SetScript("OnTabPressed", function(self)
			self:Insert("    ")
		end)

		self.EditFrame.scrollFrame:SetScrollChild(self.EditFrame.editBox)

		self.EditFrame.acceptButton = CreateFrame("Button", "ElvUI_Extras_EditorAccept", self.EditFrame, "UIPanelButtonTemplate")
		self.EditFrame.acceptButton:Size(80, 22)
		self.EditFrame.acceptButton:Point("BOTTOMLEFT", self.EditFrame, "BOTTOMLEFT", 20, 20)
		self.EditFrame.acceptButton:SetText(L["Accept"])
		self.EditFrame.acceptButton:SetScript("OnClick", function()
			acceptFunc()
			E:ToggleOptionsUI()
			self.EditFrame:Hide()
		end)

		self.EditFrame.cancelButton = CreateFrame("Button", "ElvUI_Extras_EditorCancel", self.EditFrame, "UIPanelButtonTemplate")
		self.EditFrame.cancelButton:Size(80, 22)
		self.EditFrame.cancelButton:Point("BOTTOMRIGHT", self.EditFrame, "BOTTOMRIGHT", -20, 20)
		self.EditFrame.cancelButton:SetText(L["Cancel"])
		self.EditFrame.cancelButton:SetScript("OnClick", function()
			self.EditFrame:Hide()
			E:ToggleOptionsUI()
		end)

		S:HandleScrollBar(scrollBar)
		S:HandleButton(self.EditFrame.acceptButton)
		S:HandleButton(self.EditFrame.cancelButton)

		tinsert(UISpecialFrames, 'ElvUI_Extras_Editor')
	else
		self.EditFrame:Show()
		self.EditFrame.title:SetText(title)
		self.EditFrame.header:Width(self.EditFrame.title:GetStringWidth() + 16)
		self.EditFrame.editBox:SetText(text)
		self.EditFrame.acceptButton:SetScript("OnClick", function()
			acceptFunc()
			E:ToggleOptionsUI()
			self.EditFrame:Hide()
		end)
	end

	E:ToggleOptionsUI()
end


function core:Tag(name, func)
	if tags[name] then return end

	tinsert(core.nameUpdates, func)
	tags[name] = #core.nameUpdates
end

function core:Untag(name)
	if not tags[name] then return end

	tremove(core.nameUpdates, tags[name])
	tags[name] = nil
end

-- update new elements
core:SecureHook(E, "ToggleOptionsUI", function()
	if not E.Options.args.tagGroup then return end
	E.Options.args.tagGroup.args.Miscellaneous.args.updateshandler.hidden = true
end)

ElvUF.Tags.Events["updateshandler"] = "UNIT_NAME_UPDATE"
ElvUF.Tags.Methods["updateshandler"] = function(unit)
	if not UnitExists(unit) then return end

	local frame = UF[unit]

	if frame then
		if frame.ThreatIndicator and (frame.db.threatStyle == 'BORDERS' or frame.db.threatStyle == 'HEALTHBORDERS') then
			local status = UnitThreatSituation(unit)
			frame.ThreatIndicator:PostUpdate(unit, status, GetThreatStatusColor(status))
		end

		for _, auraType in ipairs({'Buffs', 'Debuffs'}) do
			if frame[auraType] and frame[auraType].db.enable and frame[auraType].PostUpdate then
				frame[auraType]:PostUpdate()
			end
		end

		for _, func in ipairs(core.nameUpdates) do
			func(frame, unit)
		end
	end
end

do
	local db = E.db.unitframe.units
	local types = core:getAllFrameTypes()

	for type in pairs(types) do
		if db[type] and db[type].power then
			type = gsub(gsub(type, "target", "Target"), "^(.)", function(firstLetter)
				return upper(firstLetter)
			end)
			local func = "Update_"..type.."Frame"
			local groupFunc = "Update_"..type.."Frames"
			if (UF[func] or UF[groupFunc]) and not core:IsHooked(UF, UF[func] and func or groupFunc) then
				core:SecureHook(UF, UF[func] and func or groupFunc, function(self, frame, db)
					if not taggedFrames[frame] then
						frame.updatesHandler = frame:CreateFontString(nil, "OVERLAY")
						frame.updatesHandler:FontTemplate()
						frame.updatesHandler:Show()
						frame:Tag(frame.updatesHandler, "[updateshandler]")

						taggedFrames[frame] = true

						for _, func in ipairs(core.frameUpdates) do
							func(self, frame, db)
						end
					elseif not updatePending then
						updatePending = true

						E_Delay(nil, 0.1, function()
							for _, func in ipairs(core.frameUpdates) do
								func(self, frame, db)
							end
							updatePending = false
						end)
					end
				end)
			end
		end
	end
end


P["Extras"] = {
	["pluginColor"] = '|cffaf73cd',
	["customColorBad"] = '|cffce1a1a',
	["customColorAlpha"] = '|cff9999ff',
	["customColorBeta"] = '|cffff8c00',
	["classList"] = {
		["WARRIOR"] = L['Warrior'],
		["WARLOCK"] = L['Warlock'],
		["PRIEST"] = L['Priest'],
		["PALADIN"] = L['Paladin'],
		["DRUID"] = L['Druid'],
		["ROGUE"] = L['Rogue'],
		["MAGE"] = L['Mage'],
		["HUNTER"] = L['Hunter'],
		["SHAMAN"] = L['Shaman'],
		["DEATHKNIGHT"] = L['Deathknight']
	},
	["modifiers"] = {
		["ANY"] = L['Any'],
		["Alt"] = 'ALT',
		["Shift"] = 'SHIFT',
		["Control"] = 'CTRL',
	},
	["frameStrata"] = {
		["BACKGROUND"] = 'BACKGROUND',
		["LOW"] = 'LOW',
		["MEDIUM"] = 'MEDIUM',
		["HIGH"] = 'HIGH',
		["DIALOG"] = 'DIALOG',
		["FULLSCREEN"] = 'FULLSCREEN',
		["FULLSCREEN_DIALOG"] = 'FULLSCREEN_DIALOG',
		["TOOLTIP"] = 'TOOLTIP',
	},
	["pointOptions"] = {
		["TOP"] = 'TOP',
		["BOTTOM"] = 'BOTTOM',
		["LEFT"] = 'LEFT',
		["RIGHT"] = 'RIGHT',
		["CENTER"] = 'CENTER',
		["TOPLEFT"] = 'TOPLEFT',
		["TOPRIGHT"] = 'TOPRIGHT',
		["BOTTOMLEFT"] = 'BOTTOMLEFT',
		["BOTTOMRIGHT"] = 'BOTTOMRIGHT',
	},
	["texClass"] = {
		["Interface\\Icons\\spell_deathknight_classicon"] = {
			["icon"] = 'Interface\\Icons\\spell_deathknight_classicon',
			["label"] = 'Death Knight',
		},
		["Interface\\Icons\\inv_misc_monsterclaw_04"] = {
			["icon"] = 'Interface\\Icons\\inv_misc_monsterclaw_04',
			["label"] = 'Druid',
		},
		["Interface\\Icons\\inv_weapon_bow_07"] = {
			["icon"] = 'Interface\\Icons\\inv_weapon_bow_07',
			["label"] = 'Hunter',
		},
		["Interface\\Icons\\inv_staff_13"] = {
			["icon"] = 'Interface\\Icons\\inv_staff_13',
			["label"] = 'Mage',
		},
		["Interface\\Icons\\inv_hammer_01"] = {
			["icon"] = 'Interface\\Icons\\inv_hammer_01',
			["label"] = 'Paladin',
		},
		["Interface\\Icons\\inv_staff_30"] = {
			["icon"] = 'Interface\\Icons\\inv_staff_30',
			["label"] = 'Priest',
		},
		["Interface\\Icons\\inv_throwingknife_04"] = {
			["icon"] = 'Interface\\Icons\\inv_throwingknife_04',
			["label"] = 'Rogue',
		},
		["Interface\\Icons\\inv_jewelry_talisman_04"] = {
			["icon"] = 'Interface\\Icons\\inv_jewelry_talisman_04',
			["label"] = 'Shaman',
		},
		["Interface\\Icons\\spell_nature_drowsy"] = {
			["icon"] = 'Interface\\Icons\\spell_nature_drowsy',
			["label"] = 'Warlock',
		},
		["Interface\\Icons\\inv_sword_27"] = {
			["icon"] = 'Interface\\Icons\\inv_sword_27',
			["label"] = 'Warrior',
		},
	},
	["texClassVector"] = {
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_deathknight"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_deathknight',
			["label"] = 'Death Knight',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_druid"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_druid',
			["label"] = 'Druid',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_hunter"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_hunter',
			["label"] = 'Hunter',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_mage"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_mage',
			["label"] = 'Mage',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_paladin"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_paladin',
			["label"] = 'Paladin',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_priest"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_priest',
			["label"] = 'Priest',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_rogue"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_rogue',
			["label"] = 'Rogue',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_shaman"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_shaman',
			["label"] = 'Shaman',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warlock"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warlock',
			["label"] = 'Warlock',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warrior"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warrior',
			["label"] = 'Warrior',
		},
	},
	["texClassCrest"] = {
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\DeathKnight"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\DeathKnight',
			["label"] = 'Death Knight',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Druid"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Druid',
			["label"] = 'Druid',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Hunter"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Hunter',
			["label"] = 'Hunter',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Mage"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Mage',
			["label"] = 'Mage',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Paladin"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Paladin',
			["label"] = 'Paladin',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Priest"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Priest',
			["label"] = 'Priest',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Rogue"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Rogue',
			["label"] = 'Rogue',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Shaman"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Shaman',
			["label"] = 'Shaman',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warlock"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warlock',
			["label"] = 'Warlock',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warrior"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warrior',
			["label"] = 'Warrior',
		},
	},
	["texSpec"] = {
		["Interface\\Icons\\Spell_Deathknight_BloodPresence"] = {
			["icon"] = 'Interface\\Icons\\Spell_Deathknight_BloodPresence',
			["label"] = 'Death Knight - Blood',
		},
		["Interface\\Icons\\Spell_Deathknight_FrostPresence"] = {
			["icon"] = 'Interface\\Icons\\Spell_Deathknight_FrostPresence',
			["label"] = 'Death Knight - Frost',
		},
		["Interface\\Icons\\Spell_Deathknight_UnholyPresence"] = {
			["icon"] = 'Interface\\Icons\\Spell_Deathknight_UnholyPresence',
			["label"] = 'Death Knight - Unholy',
		},
		["Interface\\Icons\\Spell_Nature_StarFall"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_StarFall',
			["label"] = 'Druid - Balance',
		},
		["Interface\\Icons\\Ability_Druid_CatForm"] = {
			["icon"] = 'Interface\\Icons\\Ability_Druid_CatForm',
			["label"] = 'Druid - Feral',
		},
		["Interface\\Icons\\Spell_Nature_HealingTouch"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_HealingTouch',
			["label"] = 'Druid - Restoration',
		},
		["Interface\\Icons\\Ability_Hunter_BeastTaming"] = {
			["icon"] = 'Interface\\Icons\\Ability_Hunter_BeastTaming',
			["label"] = 'Hunter - Beast Mastery',
		},
		["Interface\\Icons\\Ability_Hunter_FocusedAim"] = {
			["icon"] = 'Interface\\Icons\\Ability_Hunter_FocusedAim',
			["label"] = 'Hunter - Marksmanship',
		},
		["Interface\\Icons\\Ability_Hunter_SwiftStrike"] = {
			["icon"] = 'Interface\\Icons\\Ability_Hunter_SwiftStrike',
			["label"] = 'Hunter - Survival',
		},
		["Interface\\Icons\\Spell_Holy_MagicalSentry"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_MagicalSentry',
			["label"] = 'Mage - Arcane',
		},
		["Interface\\Icons\\Spell_Fire_FireBolt02"] = {
			["icon"] = 'Interface\\Icons\\Spell_Fire_FireBolt02',
			["label"] = 'Mage - Fire',
		},
		["Interface\\Icons\\Spell_Frost_FrostBolt02"] = {
			["icon"] = 'Interface\\Icons\\Spell_Frost_FrostBolt02',
			["label"] = 'Mage - Frost',
		},
		["Interface\\Icons\\Spell_Holy_HolyBolt"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_HolyBolt',
			["label"] = 'Paladin - Holy',
		},
		["Interface\\Icons\\Ability_Paladin_ShieldoftheTemplar"] = {
			["icon"] = 'Interface\\Icons\\Ability_Paladin_ShieldoftheTemplar',
			["label"] = 'Paladin - Protection',
		},
		["Interface\\Icons\\Spell_Holy_AuraOfLight"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_AuraOfLight',
			["label"] = 'Paladin - Retribution',
		},
		["Interface\\Icons\\Spell_Holy_PowerWordShield"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_PowerWordShield',
			["label"] = 'Priest - Discipline',
		},
		["Interface\\Icons\\Spell_Holy_GuardianSpirit"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_GuardianSpirit',
			["label"] = 'Priest - Holy',
		},
		["Interface\\Icons\\Spell_Shadow_ShadowWordPain"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_ShadowWordPain',
			["label"] = 'Priest - Shadow',
		},
		["Interface\\Icons\\Ability_Rogue_Eviscerate"] = {
			["icon"] = 'Interface\\Icons\\Ability_Rogue_Eviscerate',
			["label"] = 'Rogue - Assassination',
		},
		["Interface\\Icons\\Ability_BackStab"] = {
			["icon"] = 'Interface\\Icons\\Ability_BackStab',
			["label"] = 'Rogue - Combat',
		},
		["Interface\\Icons\\Ability_Stealth"] = {
			["icon"] = 'Interface\\Icons\\Ability_Stealth',
			["label"] = 'Rogue - Subtlety',
		},
		["Interface\\Icons\\Spell_Nature_Lightning"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_Lightning',
			["label"] = 'Shaman - Elemental',
		},
		["Interface\\Icons\\Spell_Shaman_ImprovedStormstrike"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shaman_ImprovedStormstrike',
			["label"] = 'Shaman - Enhancement',
		},
		["Interface\\Icons\\Spell_Nature_MagicImmunity"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_MagicImmunity',
			["label"] = 'Shaman - Restoration',
		},
		["Interface\\Icons\\Spell_Shadow_DeathCoil"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_DeathCoil',
			["label"] = 'Warlock - Affliction',
		},
		["Interface\\Icons\\Spell_Shadow_Metamorphosis"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_Metamorphosis',
			["label"] = 'Warlock - Demonology',
		},
		["Interface\\Icons\\Spell_Shadow_RainOfFire"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_RainOfFire',
			["label"] = 'Warlock - Destruction',
		},
		["Interface\\Icons\\Ability_Warrior_SavageBlow"] = {
			["icon"] = 'Interface\\Icons\\Ability_Warrior_SavageBlow',
			["label"] = 'Warrior - Arms',
		},
		["Interface\\Icons\\Ability_Warrior_InnerRage"] = {
			["icon"] = 'Interface\\Icons\\Ability_Warrior_InnerRage',
			["label"] = 'Warrior - Fury',
		},
		["Interface\\Icons\\Ability_Warrior_DefensiveStance"] = {
			["icon"] = 'Interface\\Icons\\Ability_Warrior_DefensiveStance',
			["label"] = 'Warrior - Protection',
		},
	},
	["texClassificaion"] = {
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicBoss"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicBoss',
			["label"] = 'ClassicBoss',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicElite',
			["label"] = 'ClassicElite',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRare"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRare',
			["label"] = 'ClassicRare',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRareElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRareElite',
			["label"] = 'ClassicRareElite',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticBoss"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticBoss',
			["label"] = 'MinimalisticBoss',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRare"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRare',
			["label"] = 'MinimalisticRare',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRareElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRareElite',
			["label"] = 'MinimalisticRareElite',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticElite',
			["label"] = 'MinimalisticElite',
		},
		["Interface\\WorldMap\\GlowSkull_64"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64',
			["label"] = 'GlowSkull',
		},
		["Interface\\WorldMap\\GlowSkull_64Grey"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Grey',
			["label"] = 'GlowSkullGrey',
		},
		["Interface\\WorldMap\\GlowSkull_64Red"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Red',
			["label"] = 'GlowSkullRed',
		},
		["Interface\\WorldMap\\GlowSkull_64Green"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Green',
			["label"] = 'GlowSkullGreen',
		},
		["Interface\\WorldMap\\GlowSkull_64Blue"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Blue',
			["label"] = 'GlowSkullBlue',
		},
		["Interface\\WorldMap\\GlowSkull_64Purple"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Purple',
			["label"] = 'GlowSkullPurple',
		},
		["Interface\\WorldMap\\Skull_64"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64',
			["label"] = 'Skull',
		},
		["Interface\\WorldMap\\Skull_64Grey"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Grey',
			["label"] = 'SkullGrey',
		},
		["Interface\\WorldMap\\Skull_64Red"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Red',
			["label"] = 'SkullRed',
		},
		["Interface\\WorldMap\\Skull_64Green"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Green',
			["label"] = 'SkullGreen',
		},
		["Interface\\WorldMap\\Skull_64Blue"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Blue',
			["label"] = 'SkullBlue',
		},
		["Interface\\WorldMap\\Skull_64Purple"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Purple',
			["label"] = 'SkullPurple',
		},
	},
	["texGeneral"] = {
		["Interface\\GossipFrame\\AvailableQuestIcon"] = {
			["icon"] = 'Interface\\GossipFrame\\AvailableQuestIcon',
			["label"] = 'Quest Mark',
		},
		["Interface\\Icons\\ABILITY_DualWield"] = {
			["icon"] = 'Interface\\Icons\\ABILITY_DualWield',
			["label"] = 'Kill Mark',
		},
		["Interface\\Icons\\INV_Misc_Note_01"] = {
			["icon"] = 'Interface\\Icons\\INV_Misc_Note_01',
			["label"] = 'Chat Mark',
		},
		["Interface\\Icons\\INV_Misc_Bag_08"] = {
			["icon"] = 'Interface\\Icons\\INV_Misc_Bag_08',
			["label"] = 'Pickup Mark',
		},
		["Interface\\Icons\\ability_hunter_markedfordeath"] = {
			["icon"] = 'Interface\\Icons\\ability_hunter_markedfordeath',
			["label"] = "Hunter's Mark",
		},
    },

	["general"] = {},
	["blizzard"] = {},
	["nameplates"] = {},
	["unitframes"] = {},
}

core.general = { type = "group", name = L["General"], args = {} }
core.blizzard = { type = "group", name = "Blizzard", args = {} }
core.nameplates = { type = "group", name = L["Nameplates"], disabled = function() return not E.private.nameplates.enable end, args = {} }
core.unitframes = { type = "group", name = L["Unitframes"], disabled = function() return not E.private.unitframe.enable end, args = {} }

function core:GetOptions()
	local iconsBrowser, selectedButton
	local ICONS_PER_PAGE, currentPage = 100, 1
	local filteredIcons, allIcons, iconButtons = {}, {}, {}
	local lastSelected = ""

	local function getAllIcons()
		for i = 1, GetNumMacroIcons() do
			local texture = GetMacroIconInfo(i)
			tinsert(allIcons, texture)
		end
		tsort(allIcons)
	end

	local function filterIcons(searchText)
		twipe(filteredIcons)
		searchText = searchText:lower()
		for _, icon in ipairs(allIcons) do
			if find(lower(icon), searchText, 1, true) then
				tinsert(filteredIcons, icon)
			end
		end
	end

	local function highlightButton(button, highlight)
		if highlight then
			button:SetBackdropBorderColor(1, 210/255, 0, 1)
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	local function updateIconDisplay(frame)
		local iconContainer = frame.iconContainer
		local pathEditBox = frame.pathEditBox

		local startIndex = (currentPage - 1) * ICONS_PER_PAGE + 1

		for i = 1, ICONS_PER_PAGE do
			local button = iconButtons[i]
			if not button then
				button = CreateFrame("Button", nil, iconContainer)
				button.texture = button:CreateTexture(nil, "ARTWORK")
				button.texture:SetInside(button, E.mult, E.mult)
				button:Size(30)
				S:HandleButton(button)
				button:SetTemplate("Transparent")
				button:StyleButton()

				button:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
					GameTooltip:AddLine(self.iconPath)
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(L["Click to select."])
					GameTooltip:Show()
				end)

				button:SetScript("OnLeave", function() GameTooltip:Hide() end)

				button:SetScript("OnClick", function(self)
					if selectedButton then
						highlightButton(selectedButton, false)
					end
					selectedButton = self
					highlightButton(self, true)
					lastSelected = self.iconPath
					pathEditBox:SetText(self.iconPath)
					pathEditBox:HighlightText()
					pathEditBox:SetFocus()
				end)

				local col = (i - 1) % 10
				local row = floor((i - 1) / 10)
				button:Point("TOPLEFT", iconContainer, "TOPLEFT", col * 32, -row * 32)

				iconButtons[i] = button
			end

			local iconIndex = startIndex + i - 1
			if iconIndex <= #filteredIcons then
				button.iconPath = filteredIcons[iconIndex]
				button.texture:SetTexture(button.iconPath)
				button:Show()
				if button.iconPath == lastSelected then
					highlightButton(button, true)
					selectedButton = button
				else
					highlightButton(button, false)
				end
			else
				button:Hide()
			end
		end
	end

	local function createIconsBrowser()
		if iconsBrowser then
			if iconsBrowser:IsShown() then
				iconsBrowser:Hide()
			else
				iconsBrowser:Show()
			end
			return
		end

		iconsBrowser = CreateFrame("Frame", "iconsBrowser", UIParent)
		iconsBrowser:SetFrameStrata("FULLSCREEN_DIALOG")
		iconsBrowser:SetFrameLevel(999)
		iconsBrowser:Size(360, 440)
		iconsBrowser:SetClampedToScreen(true)
		iconsBrowser:CreateBackdrop("Transparent")

		iconsBrowser:Point("CENTER", UIParent, "CENTER", 0, 0)

		iconsBrowser:SetMovable(true)
		iconsBrowser:EnableMouse(true)
		iconsBrowser:EnableMouseWheel(1)
		iconsBrowser:RegisterForDrag("LeftButton")
		iconsBrowser:SetScript("OnDragStart", function(self) self:StartMoving() end)
		iconsBrowser:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		iconsBrowser:SetScript("OnMouseWheel", function(self, dir)
			if dir == -1 then
				self.nextButton:GetScript("OnClick")()
			else
				self.prevButton:GetScript("OnClick")()
			end
		end)
		iconsBrowser:SetScript("OnMouseDown", function(self)
			self:SetFrameLevel(999)
			local level = self:GetFrameLevel()
			for _, child in ipairs({self:GetChildren()}) do
				child:SetFrameLevel(level+2)
			end
			self.searchBox.backdrop:SetFrameLevel(level+1)
			self.pathEditBox.backdrop:SetFrameLevel(level+1)
		end)

		local labelHolder = CreateFrame("Frame", "iconsBrowserLabel", iconsBrowser)
		labelHolder:Point("TOP", iconsBrowser, "TOP", 0, -8)
		labelHolder:Size(96, 24)
		local label = labelHolder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetAllPoints()
		label:SetText(L["Icons Browser"])

		local closeButton = CreateFrame("Button", "iconsBrowserClose", iconsBrowser, "UIPanelCloseButton")
		closeButton:Point("TOPRIGHT", iconsBrowser, "TOPRIGHT")
		closeButton:SetScript("OnClick", function() iconsBrowser:Hide() end)
		S:HandleCloseButton(closeButton)

		local iconContainer = CreateFrame("Frame", "iconsBrowserContainer", iconsBrowser)
		iconContainer:Size(320, 300)
		iconContainer:Point("CENTER", iconsBrowser, "CENTER", 0, -8)
		iconContainer:CreateBackdrop()

		local pathEditBox = CreateFrame("EditBox", "iconsBrowserPath", iconsBrowser, "InputBoxTemplate")
		pathEditBox:Point("TOPLEFT", iconContainer, "TOPLEFT", 0, 24)
		pathEditBox:Point("BOTTOMRIGHT", iconContainer, "TOPRIGHT", 0, 8)
		pathEditBox:SetAutoFocus(false)
		S:HandleEditBox(pathEditBox)

		pathEditBox:SetScript("OnChar", function()
			pathEditBox:SetText(lastSelected)
			pathEditBox:HighlightText()
		end)

		local searchBox = CreateFrame("EditBox", "iconsBrowserSearch", iconsBrowser, "InputBoxTemplate")
		searchBox:Point("TOPLEFT", pathEditBox, "TOPLEFT", 42, 20)
		searchBox:Point("BOTTOMRIGHT", pathEditBox, "TOPRIGHT", 0, 4)
		searchBox:SetAutoFocus(false)
		S:HandleEditBox(searchBox)

		local searchLabelHolder = CreateFrame("Frame", "iconsBrowserSearchLabel", iconsBrowser)
		searchLabelHolder:Point("TOPLEFT", searchBox, "TOPLEFT", -42, 0)
		searchLabelHolder:Point("BOTTOMRIGHT", searchBox, "BOTTOMLEFT", -4, 0)
		local searchLabel = searchLabelHolder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		searchLabel:SetAllPoints()
		searchLabel:SetText(L["Search:"])

		searchBox:SetScript("OnTextChanged", function(self)
			filterIcons(self:GetText())
			currentPage = 1
			updateIconDisplay(iconsBrowser)
			iconsBrowser.pageText:SetText(format("%d/%d", currentPage, max(1, ceil(#filteredIcons / ICONS_PER_PAGE))))
		end)

		local prevButton = CreateFrame("Button", "iconsBrowserPrev", iconsBrowser, "UIPanelButtonTemplate")
		prevButton:Size(24, 16)
		prevButton:Point("TOPLEFT", iconContainer, "BOTTOMLEFT", 0, -32)
		prevButton:SetText("<")
		S:HandleButton(prevButton)

		local nextButton = CreateFrame("Button", "iconsBrowserNext", iconsBrowser, "UIPanelButtonTemplate")
		nextButton:Size(24, 16)
		nextButton:Point("TOPRIGHT", iconContainer, "BOTTOMRIGHT", 0, -32)
		nextButton:SetText(">")
		S:HandleButton(nextButton)

		local pageTextHolder = CreateFrame("Frame", "iconsBrowserPageText", iconsBrowser)
		pageTextHolder:Point("TOPLEFT", prevButton, "TOPRIGHT", 0, 0)
		pageTextHolder:Point("BOTTOMRIGHT", nextButton, "BOTTOMLEFT", 0, 0)
		local pageText = pageTextHolder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		pageText:SetAllPoints()
		pageText:SetText("1/1")

		prevButton:SetScript("OnClick", function()
			if currentPage == 1 then
				currentPage = ceil(#filteredIcons / ICONS_PER_PAGE)
			else
				currentPage = currentPage - 1
			end
			updateIconDisplay(iconsBrowser)
			pageText:SetText(format("%d/%d", currentPage, max(1, ceil(#filteredIcons / ICONS_PER_PAGE))))
		end)

		nextButton:SetScript("OnClick", function()
			if currentPage == ceil(#filteredIcons / ICONS_PER_PAGE) then
				currentPage = 1
			else
				currentPage = currentPage + 1
			end
			updateIconDisplay(iconsBrowser)
			pageText:SetText(format("%d/%d", currentPage, max(1, ceil(#filteredIcons / ICONS_PER_PAGE))))
		end)

		iconsBrowser.searchBox = searchBox
		iconsBrowser.pathEditBox = pathEditBox
		iconsBrowser.iconContainer = iconContainer
		iconsBrowser.nextButton = nextButton
		iconsBrowser.prevButton = prevButton
		iconsBrowser.pageText = pageText

		getAllIcons()
		filterIcons("")
		updateIconDisplay(iconsBrowser)

		iconsBrowser:Show()
		iconsBrowser:GetScript("OnMouseDown")(iconsBrowser)

		tinsert(UISpecialFrames, "iconsBrowser")
	end

	E.Options.args.Extras = {
		type = "group",
		childGroups = "tab",
		name = core.pluginColor.."Extras",
		args = {
			general = core.general,
			blizzard = core.blizzard,
			nameplates = core.nameplates,
			unitframes = core.unitframes,
			plugin = {
				type = "group",
				name = L["Plugin"],
				args = {
					colors = {
						type = "group",
						name = L["Version: "].."1.03",
						guiInline = true,
						get = function(info) return colorConvert(E.db.Extras[info[#info]]) end,
						set = function(info, r, g, b) local color = colorConvert(r, g, b) E.db.Extras[info[#info]] = color core[info[#info]] = color E:RefreshGUI() end,
						args = {
							customColorAlpha = {
								order = 1,
								type = "color",
								name = L["Color A"],
								desc = L["Chat messages, etc."],
							},
							customColorBeta = {
								order = 2,
								type = "color",
								name = L["Color B"],
								desc = L["Chat messages, etc."],
							},
							pluginColor = {
								order = 3,
								type = "color",
								name = L["Plugin Color"],
								desc = "",
							},
							iconsBrowser = {
								order = 4,
								type = "execute",
								name = L["Icons Browser"],
								desc = L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."],
								func = createIconsBrowser,
							},
							addTexture = {
								order = 5,
								type = "input",
								width = "double",
								name = L["Add Texture"],
								desc = L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"],
								get = function() return "" end,
								set = function(_, value)
									if value and value ~= "" then
										local texInfo = {
											icon = value,
											label = gsub(value, ".*\\", ""),
										}
										E.db.Extras.texGeneral[value] = texInfo
										local string = '\124T' .. value .. ':16:16\124t'
										print(core.customColorAlpha .. string .. core.customColorBeta .. L[" added."])
									end
								end,
							},
							removeTexture = {
								order = 6,
								type = "select",
								width = "double",
								name = L["Remove Texture"],
								desc = "",
								get = function() return "" end,
								set = function(_, value)
									for icon in pairs(E.db.Extras.texGeneral) do
										if icon == value then
											E.db.Extras.texGeneral[icon] = nil
											local string = '\124T' .. value .. ':16:16\124t'
											print(core.customColorAlpha .. string .. core.customColorBeta .. L[" removed."])
											break
										end
									end
								end,
								values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
							},
						},
					},
				},
			},
		}
	}
	E.Options.args.Extras.args.general.order = 1
	E.Options.args.Extras.args.blizzard.order = 2
	E.Options.args.Extras.args.nameplates.order = 3
	E.Options.args.Extras.args.unitframes.order = 4
	E.Options.args.Extras.args.plugin.order = 99
end


function core:Initialize()
	self.pluginColor = E.db.Extras.pluginColor
	self.customColorBad = E.db.Extras.customColorBad
	self.customColorAlpha = E.db.Extras.customColorAlpha
	self.customColorBeta = E.db.Extras.customColorBeta

	if isAwesome then
		NP:UnregisterEvent("PLAYER_TARGET_CHANGED")
		NP:UnregisterEvent("PLAYER_FOCUS_CHANGED")
		NP:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
		NP:UnregisterEvent("ARENA_OPPONENT_UPDATE")
		NP:UnregisterEvent("PARTY_MEMBERS_CHANGED")
		NP:UnregisterEvent("RAID_ROSTER_UPDATE")
		NP:UnregisterEvent("UNIT_NAME_UPDATE")

		for _, func in pairs({'UnitClass', 'GetUnitInfo', 'GetUnitByName', 'SetTargetFrame', 'ResetNameplateFrameLevel', 'UnitDetailedThreatSituation'}) do
			if not self:IsHooked(NP, func) then self:RawHook(NP, func) end
		end
	end

	EP:RegisterPlugin(AddOnName, self.GetOptions)

	for _, module in pairs(self.modules) do
        module()
    end

	local shadow_db = E.globalShadow

	if shadow_db then
		local M = E:GetModule("Misc")
		local createShadow = E.CreateGlobalShadow
		local size = shadow_db.size

		createShadow(nil, shadow_db, _G["Minimap"])

		if E.pendingShadowUpdate then
			for frame in pairs(E.pendingShadowUpdate) do
				createShadow(nil, shadow_db, frame)
			end
		end

		if not self:IsHooked(NP, "StyleFrame") then
			self:SecureHook(NP, "StyleFrame", function(_, frame)
				createShadow(nil, shadow_db, frame)
			end)
		end

		if not self:IsHooked(M, "SkinBubble") then
			self:SecureHook(M, "SkinBubble", function(_, frame)
				createShadow(nil, shadow_db, frame)
			end)
		end

		tinsert(core.frameUpdates, function()
			local units = core:AggregateUnitFrames()

			for _, frame in ipairs(units) do
				local healthBackdrop = frame.Health.backdrop
				local powerBackdrop = (frame.USE_POWERBAR and frame.Power) and frame.Power.backdrop
				local infoPanelBackdrop = (frame.USE_INFO_PANEL and frame.InfoPanel) and frame.InfoPanel.backdrop

				if healthBackdrop.globalShadow and powerBackdrop and powerBackdrop.globalShadow then
					healthBackdrop.globalShadow:SetOutside(frame, size, size)

					if frame.POWERBAR_DETACHED then
						powerBackdrop.globalShadow:Show()
					else
						powerBackdrop.globalShadow:Hide()
					end
				end

				if infoPanelBackdrop and infoPanelBackdrop.globalShadow then
					infoPanelBackdrop.globalShadow:Hide()
				end
			end

			local target = _G["ElvUF_Target"]

			if target and target.USE_CLASSBAR then
				for _, comboPoint in ipairs(target.ComboPoints) do
					local backdrop = comboPoint.backdrop

					if backdrop and backdrop.globalShadow then
						if not target.USE_MINI_CLASSBAR then
							backdrop.globalShadow:Hide()
						else
							backdrop.globalShadow:Show()
						end
					end
				end

				local backdrop = target.ComboPoints and target.ComboPoints.backdrop

				if backdrop and backdrop.globalShadow then
					if not target.CLASSBAR_DETACHED then
						backdrop.globalShadow:Hide()
					else
						backdrop.globalShadow:Show()
					end
				end
			end
		end)
	end

	E.pendingShadowUpdate = nil
end

local function InitializeCallback()
	core:Initialize()
end

LSM:Register("font", "Extras_Favourite (Montserrat)", "Interface\\AddOns\\ElvUI_Extras\\Media\\Favourite.ttf")
LSM:Register("font", "Invisible", "Interface\\AddOns\\ElvUI_Extras\\Media\\Invisible.ttf")

E:RegisterModule(core:GetName(), InitializeCallback)