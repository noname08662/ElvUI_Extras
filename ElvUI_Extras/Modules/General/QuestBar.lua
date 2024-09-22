local E, L, _, P = unpack(ElvUI)
local AB = E:GetModule("ActionBars")
local core = E:GetModule("Extras")
local mod = core:NewModule("Quest Bar", "AceHook-3.0", "AceEvent-3.0")

local modName = mod:GetName()
local initialized

local _G = _G
local tinsert, twipe = table.insert, table.wipe
local pairs, ipairs, select = pairs, ipairs, select
local GetContainerItemQuestInfo, GetContainerNumSlots, GetContainerItemID = GetContainerItemQuestInfo, GetContainerNumSlots, GetContainerItemID
local PickupContainerItem, PlaceAction, ClearCursor = PickupContainerItem, PlaceAction, ClearCursor
local InCombatLockdown, GetItemInfo, GetAuctionItemClasses = InCombatLockdown, GetItemInfo, GetAuctionItemClasses
local GetActionInfo, PickupAction, IsModifierKeyDown = GetActionInfo, PickupAction, IsModifierKeyDown
local GetCursorInfo, GetMouseFocus = GetCursorInfo, GetMouseFocus
local GetItemSpell, NUM_ACTIONBAR_BUTTONS = GetItemSpell, NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver, UnregisterStateDriver = RegisterStateDriver, UnregisterStateDriver
local NUM_BAG_SLOTS = NUM_BAG_SLOTS


P["Extras"]["general"][modName] = {
	["enabled"] = false,
	["mouseover"] = false,
	["buttons"] = 12,
	["buttonsPerRow"] = 12,
	["point"] = "BOTTOMLEFT",
	["backdrop"] = true,
	["heightMult"] = 1,
	["widthMult"] = 1,
	["buttonsize"] = 32,
	["buttonspacing"] = 2,
	["backdropSpacing"] = 2,
	["alpha"] = 1,
	["inheritGlobalFade"] = false,
	["showGrid"] = false,
	["paging"] = {},
	["visibility"] = "[vehicleui] hide; show",

	["blacklist"] = {},
	["modifier"] = 'Alt'
}

P["actionbar"]["bar"..modName] = CopyTable(P.Extras.general[modName])

AB["barDefaults"]["bar"..modName] = {
	["page"] = 10,
	["bindButtons"] = "ELVUIQUESTBARBUTTON",
	["conditions"] = "",
	["position"] = "BOTTOM,ElvUI_Bar1,TOP,0,82"
}

function mod:LoadConfig()
	local db = E.db.Extras.general[modName]
	local actionbar_db = E.db.actionbar["bar"..modName]
	core.general.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value actionbar_db[info[#info]] = value AB:PositionAndSizeBar("bar"..modName) end,
		disabled = function() return not E.private.actionbar.enable end,
		args = {
			QuestBar = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L[modName],
				args = {
					enabled = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."],
						set = function(info, value) db[info[#info]] = value mod:Toggle(value) end,
					},
				},
			},
			settings = {
				order = 2,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function() return not db.enabled end,
				args = {
					backdrop = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Backdrop"],
						desc = L["Toggles the display of the actionbars backdrop."],
					},
					showGrid = {
						order = 2,
						type = "toggle",
						name = L["Show Empty Buttons"],

							hidden = function() return true end,

						set = function(info, value)
							db[info[#info]] = value
							actionbar_db[info[#info]] = value
							AB:UpdateButtonSettingsForBar("bar" .. modName)
						end,
					},
					mouseover = {
						order = 3,
						type = "toggle",
						name = L["Mouse Over"],
						desc = L["The frame won't show unless you mouse over it."],
					},
					inheritGlobalFade = {
						order = 4,
						type = "toggle",
						name = L["Inherit Global Fade"],
						desc = L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."],
					},
					point = {
						order = 5,
						type = "select",
						name = L["Anchor Point"],
						desc = L["The first button anchors itself to this point on the bar."],
						values = E.db.Extras.pointOptions,
					},
					modifier = {
						order = 6,
						type = "select",
						name = L["Modifier"],
						desc = L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."],
						values = E.db.Extras.modifiers,
					},
					buttons = {
						order = 7,
						type = "range",
						name = L["Buttons"],
						desc = L["The amount of buttons to display."],

							hidden = function() return true end,

						min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					},
					buttonsPerRow = {
						order = 8,
						type = "range",
						name = L["Buttons Per Row"],
						desc = L["The amount of buttons to display per row."],

							hidden = function() return true end,

						min = 1, max = NUM_ACTIONBAR_BUTTONS, step = 1,
					},
					buttonsize = {
						order = 9,
						type = "range",
						name = L["Button Size"],
						desc = L["The size of the action buttons."],
						min = 15, max = 60, step = 1,
					},
					buttonspacing = {
						order = 10,
						type = "range",
						name = L["Button Spacing"],
						desc = L["The spacing between buttons."],
						min = -1, max = 10, step = 1,
					},
					backdropSpacing = {
						order = 11,
						type = "range",
						name = L["Backdrop Spacing"],
						desc = L["The spacing between the backdrop and the buttons."],
						min = 0, max = 10, step = 1,
					},
					heightMult = {
						order = 12,
						type = "range",
						name = L["Height Multiplier"],
						desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
						min = 1, max = 5, step = 1,
					},
					widthMult = {
						order = 13,
						type = "range",
						name = L["Width Multiplier"],
						desc = L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."],
						min = 1, max = 5, step = 1,
					},
					alpha = {
						order = 14,
						type = "range",
						name = L["Alpha"],
						desc = "",
						isPercent = true,
						min = 0, max = 1, step = 0.01,
					},
					visibility = {
						order = 15,
						type = "input",
						name = L["Visibility State"],
						desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] showhide'"],
						width = "double",
						multiline = true,
						set = function(info, value)
							db[info[#info]] = value
							actionbar_db[info[#info]] = value
							AB:UpdateButtonSettings()
						end,
					},
				},
			},
		},
	}
end


function mod:CreateQuestBar()
    if AB.handledBars["bar"..modName] then return end

    local bar = AB:CreateBar(modName)
	bar.db.enabled = true

	AB.handledBars["bar"..modName] = bar
	E:CreateMover(bar, "ElvAB_QuestBar", L["bar"..modName], nil, nil, nil,"ALL,ACTIONBARS",nil,"actionbar,barQuestBar")

	local localizedQuestItemType = select(12,GetAuctionItemClasses())
	local function BlockAction(self, button)
		local _, itemID = GetActionInfo(self._state_action)
		if not itemID then return end
		if select(6,GetItemInfo(itemID)) ~= localizedQuestItemType then
			PickupAction(self._state_action)
		elseif button == 'RightButton' and IsModifierKeyDown() and (E.db.Extras.general[modName].modifier == 'ANY' or _G['Is'..E.db.Extras.general[modName].modifier..'KeyDown']()) then
			E.db.Extras.general[modName].blacklist[itemID] = true
			mod:CheckQuestItems()
			self:SetAttribute("type", nil)
		end
	end

	for _, button in pairs(bar.buttons) do
		button:HookScript("PreClick", BlockAction)
		button:HookScript("PostClick", function(self) self:SetAttribute("type", "action") end)
		button:HookScript("OnReceiveDrag", BlockAction)
		button:HookScript("OnDragStop", function(self)
			if not GetCursorInfo() then return end
			if GetMouseFocus():GetParent() ~= self:GetParent() then
				PickupAction(self._state_action)
			else
				PickupAction(GetMouseFocus()._state_action)
				PickupAction(self._state_action)
			end
		end)
	end
end

function mod:CheckQuestItems()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED', function()
			mod:CheckQuestItems()
			mod:UnregisterEvent('PLAYER_REGEN_ENABLED')
		end)
		return
	end

    local bar = AB.handledBars["bar"..modName]
    if not bar then return end

    local questItems = {}

    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, GetContainerNumSlots(bag) do
            local itemID = GetContainerItemID(bag, slot)
            if itemID then
				local quetItem = GetContainerItemQuestInfo(bag, slot)
				if quetItem and GetItemSpell(itemID) and not E.db.Extras.general[modName].blacklist[itemID] then
					tinsert(questItems, {bag = bag, slot = slot, itemID = itemID})
				end
            end
        end
    end

    for _, button in ipairs(bar.buttons) do
        PickupAction(button._state_action)
        ClearCursor()
        button:SetAttribute("itemID", nil)
    end

    local actives = 0
    for i = 1, #questItems do
        local questItem = questItems[i]
        local button = bar.buttons[i]
        if button then
            PickupContainerItem(questItem.bag, questItem.slot)
            PlaceAction(button._state_action)
            ClearCursor()
            button:SetAttribute("itemID", questItem.itemID)
            actives = actives + 1
        end
    end

    bar.db.buttons = actives
    if actives == 0 then
        bar.db.visibility = "hide"
    else
        bar.db.visibility = E.db.Extras.general[modName].visibility
    end
    AB:PositionAndSizeBar("bar" .. modName)
end


function mod:Toggle(enable)
    if enable then
        local bar = AB.handledBars["bar"..modName]
        if bar then
			bar.db.enabled = true
		else
			self:CreateQuestBar()
		end
		if E.Options.args.actionbar and E.Options.args.actionbar.args.bar10 then
			E.Options.args.actionbar.args.bar10.hidden = true
			if E.RefreshGUI then E:RefreshGUI() end
		else
			if not self:IsHooked(E, 'ToggleOptionsUI') then
				self:SecureHook(E, 'ToggleOptionsUI', function()
					if not E.Options.args.actionbar or not E.Options.args.actionbar.args.bar10 then
						self:Unhook(E, 'ToggleOptionsUI')
						return
					end

					E.Options.args.actionbar.args.bar10.hidden = true
					E:RefreshGUI()
				end)
			end
		end
		self:RegisterEvent("BAG_UPDATE", function() mod:CheckQuestItems() end)
		E:EnableMover("ElvAB_QuestBar")
		SLASH_QUESTBARRESTORE1 = "/questbarRestore"
		SlashCmdList["QUESTBARRESTORE"] = function() twipe(E.db.Extras.general[modName].blacklist) mod:CheckQuestItems() end
		mod.CheckQuestItems()
		initialized = true
	elseif initialized then
        self:UnregisterEvent("BAG_UPDATE")
        local bar = AB.handledBars["bar"..modName]
		if E.Options.args.actionbar and E.Options.args.actionbar.args.bar10 then
			E.Options.args.actionbar.args.bar10.hidden = false
			if self:IsHooked(E, 'ToggleOptionsUI') then self:Unhook(E, 'ToggleOptionsUI') end
			if E.RefreshGUI then E:RefreshGUI() end
		end
        if bar then
            RegisterStateDriver(bar, "visibility", "hide")
            UnregisterStateDriver(bar, "page")
			E:DisableMover("ElvAB_QuestBar")
			SLASH_QUESTBARRESTORE1 = nil
			SlashCmdList["QUESTBARRESTORE"] = nil
			hash_SlashCmdList["/QUESTBARRESTORE"] = nil
			bar.db.enabled = false
        end
    end
end

function mod:InitializeCallback()
	mod:LoadConfig()

	if not E.private.actionbar.enable then return end
	mod:Toggle(E.db.Extras.general[modName].enabled)
end

core.modules[modName] = mod.InitializeCallback