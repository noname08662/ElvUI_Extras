local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Bags", "AceHook-3.0", "AceEvent-3.0")
local B = E:GetModule("Bags")
local S = E:GetModule("Skins")
local LSM = E.Libs.LSM
local LibProcessable = LibStub("LibProcessable")

local modName = mod:GetName()
local buttonMap, tooltipInfo = {}, {}
local equipmentSets = {}
local removingBag = false

mod.initialized = {}
mod.localhooks = {}

mod.buttonMap = buttonMap

local prospectingSpellID = 31252
local disenchantingSpellID = 13262
local millingSpellID = 51005
local lockpickingSpellID = 1804

local _G, unpack, pairs, ipairs, select, print, next, setfenv = _G, unpack, pairs, ipairs, select, print, next, setfenv
local tonumber, tostring, loadstring, pcall, type = tonumber, tostring, loadstring, pcall, type
local tinsert, tremove, twipe, tsort, tconcat = table.insert, table.remove, table.wipe, table.sort, table.concat
local min, max, floor, ceil, huge, pi = min, max, floor, ceil, math.huge, math.pi
local find, format, lower, match, gmatch, gsub = string.find, string.format, string.lower, string.match, string.gmatch, string.gsub
local UIParent, GameTooltip_Hide, InCombatLockdown, UnitFactionGroup = UIParent, GameTooltip_Hide, InCombatLockdown, UnitFactionGroup
local GetItemInfo, GetInventoryItemTexture, GetBagName, GetCursorInfo = GetItemInfo, GetInventoryItemTexture, GetBagName, GetCursorInfo
local ContainerIDToInventoryID, GetContainerItemID = ContainerIDToInventoryID, GetContainerItemID
local GetContainerNumSlots, GetContainerNumFreeSlots = GetContainerNumSlots, GetContainerNumFreeSlots
local GetCurrencyListInfo, GetCurrencyListSize, GetItemQualityColor = GetCurrencyListInfo, GetCurrencyListSize, GetItemQualityColor
local StackSplitFrame, StackSplitOkayButton = StackSplitFrame, StackSplitOkayButton
local StackSplitRightButton, StackSplitLeftButton = StackSplitRightButton, StackSplitLeftButton
local BuyMerchantItem, GetMerchantItemLink = BuyMerchantItem, GetMerchantItemLink
local GetAuctionItemClasses, GetAuctionItemSubClasses = GetAuctionItemClasses, GetAuctionItemSubClasses
local GetSpellInfo, GetSpellLink, GetKeyRingSize = GetSpellInfo, GetSpellLink, GetKeyRingSize
local IsModifierKeyDown, IsAltKeyDown, IsShiftKeyDown, ClearCursor = IsModifierKeyDown, IsAltKeyDown, IsShiftKeyDown, ClearCursor
local GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetLocations = GetNumEquipmentSets, GetEquipmentSetInfo, GetEquipmentSetLocations
local EquipmentManager_UnpackLocation, GetInventoryItemID = EquipmentManager_UnpackLocation, GetInventoryItemID
local ERR_NOT_IN_COMBAT, ERR_INVALID_ITEM_TARGET, ERR_SPLIT_FAILED = ERR_NOT_IN_COMBAT, ERR_INVALID_ITEM_TARGET, ERR_SPLIT_FAILED
local CURRENCY, NUM_BAG_SLOTS, EMPTY = CURRENCY, NUM_BAG_SLOTS, EMPTY
local NUM_FREE_SLOTS, FILTERS = NUM_FREE_SLOTS, FILTERS
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS

local B_PickupItem, B_GetItemID, B_GetItemInfo = B.PickupItem, B.GetItemID, B.GetItemInfo
local B_GetContainerFrame, B_SplitItem = B.GetContainerFrame, B.SplitItem

local holderTT = CreateFrame("GameTooltip", "ExtrasBags_DescTooltip", nil, "GameTooltipTemplate")
local scanner = CreateFrame("GameTooltip", "ExtrasBags_ScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local Weapon, Armor, Container, Consumable, Glyph, TradeGoods, Projectile, Quiver, Recipe, Gem, Miscellaneous, Quest = GetAuctionItemClasses()

local itemTypePriority = {
    [Weapon] = 1,
    [Armor] = 2,
    [Container] = 3,
    [Quiver] = 4,
    [Recipe] = 5,
    [Gem] = 6,
    [TradeGoods] = 7,
    [Glyph] = 8,
    [Projectile] = 9,
    [Quest] = 10,
    [Consumable] = 11,
    [Miscellaneous] = 12,
}

local armorSlotPriority = {
    ["INVTYPE_SHIELD"] = 1,
    ["INVTYPE_HOLDABLE"] = 2,
    ["INVTYPE_HEAD"] = 3,
    ["INVTYPE_SHOULDER"] = 4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5,
    ["INVTYPE_HAND"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_WAIST"] = 8,
    ["INVTYPE_FEET"] = 9,
    ["INVTYPE_WRIST"] = 10,
    ["INVTYPE_CLOAK"] = 11,
    ["INVTYPE_NECK"] = 12,
    ["INVTYPE_FINGER"] = 13,
    ["INVTYPE_TRINKET"] = 14,
    --["INVTYPE_RELIC"] = 15
}

local inventorySlotIDs = {
	["INVTYPE_AMMO"] = 0,
    ["INVTYPE_HEAD"] = 1,
    ["INVTYPE_NECK"] = 2,
    ["INVTYPE_SHOULDER"] = 3,
    ["INVTYPE_BODY"] = 4,
    ["INVTYPE_CHEST"] = 5,
    ["INVTYPE_ROBE"] = 5,
    ["INVTYPE_WAIST"] = 6,
    ["INVTYPE_LEGS"] = 7,
    ["INVTYPE_FEET"] = 8,
    ["INVTYPE_WRIST"] = 9,
    ["INVTYPE_HAND"] = 10,
    ["INVTYPE_FINGER"] = 11,
    ["INVTYPE_TRINKET"] = 13,
    ["INVTYPE_CLOAK"] = 15,
    ["INVTYPE_WEAPON"] = 16,
    ["INVTYPE_SHIELD"] = 17,
    ["INVTYPE_2HWEAPON"] = 16,
    ["INVTYPE_WEAPONMAINHAND"] = 16,
    ["INVTYPE_WEAPONOFFHAND"] = 17,
    ["INVTYPE_HOLDABLE"] = 17,
    ["INVTYPE_RANGED"] = 18,
    ["INVTYPE_THROWN"] = 18,
    ["INVTYPE_RELIC"] = 18,
}


local function getItemDetails(bagID, slotID, itemID)
    if not itemID then return nil end

    local itemName, itemLink, quality, itemLevel, useLevel, itemType, itemSubType, maxStack, equipSlot, _, sellPrice = GetItemInfo(itemID)
    local stackCount = select(2, B_GetItemInfo(nil, bagID, slotID))

    return {
        id = itemID,
        name = itemName,
        quality = quality,
        ilvl = itemLevel,
        useLevel = useLevel,
        type = itemType,
        subType = itemSubType,
        equipSlot = equipSlot,
        stackCount = stackCount,
        maxStack = maxStack,
		sellPrice = sellPrice,
		itemLink = itemLink,
		bagID = bagID,
		slotID = slotID,
    }
end

local filter = {
	id = function(item) return item.id end,
    type = function(item) return item.type and lower(gsub(item.type, '[%s%p]+', '')) end,
    subtype = function(item) return item.subType and lower(gsub(item.subType, '[%s%p]+', '')) end,
    ilvl = function(item) return item.ilvl end,
    uselevel = function(item) return item.useLevel end,
    quality = function(item) return item.quality end,
    name = function(item) return item.name and lower(gsub(item.name, '[%s%p]+', '')) end,
    equipslot = function(item) return inventorySlotIDs[item.equipSlot] end,
    maxstack = function(item) return item.maxStack end,
    price = function(item) return item.sellPrice end,
	tooltip = function(item)
		if tooltipInfo[item.id] then
			return tooltipInfo[item.id]
		else
			scanner:ClearLines()
			scanner:SetHyperlink(item.itemLink)

			local tooltipText = ''
			for i = 2, scanner:NumLines() do
				local left = _G["ExtrasBags_ScanningTooltipTextLeft"..i]:GetText()
				local right = _G["ExtrasBags_ScanningTooltipTextRight"..i]:GetText()

				tooltipText = tooltipText .. (left or '')
				tooltipText = tooltipText .. (right or '')
			end
			tooltipText = lower(gsub(tooltipText, '[%s%p]+', ''))
			tooltipInfo[item.id] = tooltipText
			return tooltipText
		end
	end,
	set = function(item)
		local sets = {}
		local setsInfo = equipmentSets[item.id]
		if setsInfo then
			for _, equipmentSet in ipairs(setsInfo) do
				local _, bank, bags, setSlotID, setBagID =
					EquipmentManager_UnpackLocation(GetEquipmentSetLocations(equipmentSet.setName)[equipmentSet.equipmentSlot])
				if (bags and item.slotID == setSlotID and item.bagID == setBagID) or (bank and setSlotID - 39 == item.slotID) then
					sets[equipmentSet.setNameClean] = true
				end
			end
		end
		return sets
	end,
}


local function defaultSort(a, b)
	local bagIDA, slotIDA, bagIDB, slotIDB = a.bagID, a.slotID, b.bagID, b.slotID
	local itemIDA, itemIDB = a.itemID or B_GetItemID(nil, bagIDA, slotIDA), b.itemID or B_GetItemID(nil, bagIDB, slotIDB)

    if not itemIDA and not itemIDB then return (bagIDA * 100) + slotIDA < (bagIDB * 100) + slotIDB end
    if not itemIDA then return false end
    if not itemIDB then return true end

    local itemA = getItemDetails(bagIDA, slotIDA, itemIDA)
    local itemB = getItemDetails(bagIDB, slotIDB, itemIDB)

    local typeA = itemTypePriority[itemA.type] or 99
    local typeB = itemTypePriority[itemB.type] or 99

    if typeA ~= typeB then
        return typeA < typeB
    end

    if itemA.type == Armor and itemB.type == Armor then
        local slotA = armorSlotPriority[itemA.equipSlot] or 99
        local slotB = armorSlotPriority[itemB.equipSlot] or 99
        if slotA ~= slotB then
            return slotA < slotB
        end
    end

    if itemA.ilvl ~= itemB.ilvl then
        return itemA.ilvl > itemB.ilvl
    end

	if itemA.name ~= itemB.name then
		return itemA.name < itemB.name
	end

	return itemA.stackCount > itemB.stackCount
end

local function updateSetsInfo()
	twipe(equipmentSets)
    for i = 1, GetNumEquipmentSets() do
        local setName = GetEquipmentSetInfo(i)
        if setName then
            local locations = GetEquipmentSetLocations(setName)
            if locations then
                for slotID, location in pairs(locations) do
                    if location then
						local itemID
                        local player, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location)
                        if bags then
                            itemID = B_GetItemID(nil, bag, slot)
						elseif bank then
							itemID = B_GetItemID(nil, -1, slot - 39)
                        elseif player then
							itemID = GetInventoryItemID("player", slot)
                        end
                        if itemID then
							if not equipmentSets[itemID] then
								equipmentSets[itemID] = {}
							end
                            tinsert(equipmentSets[itemID], {setName = setName,
															setNameClean = lower(gsub(setName, '[%s%p]+', '')),
															equipmentSlot = slotID})
                        end
                    end
                end
            end
        end
    end
end

local function formatCondition(filterName, operator, value)
	if filterName == "set" then
		return format('filterFuncs.%s(item)[%q]', filterName, lower(value))
	elseif filterName == "name" or filterName == "tooltip" then
		return format('find(filterFuncs.%s(item) or "", "%s", 1, true)', filterName, lower(value))
	else
		if tonumber(value) then
			return format('(filterFuncs.%s(item) and filterFuncs.%s(item) %s %s or false)', filterName, filterName, operator, value)
		elseif operator == '~=' then
			return format('not find(filterFuncs.%s(item) or "", "%s", 1, true)', filterName, lower(value))
		else
			return format('find(filterFuncs.%s(item) or "", "%s", 1, true)', filterName, lower(value))
		end
	end
end

local function parseCollectionString(conditions)
    local formattedConditions = conditions

    for condition in gmatch(formattedConditions, '%S+@[<>=~!]*%S+') do
        local pair, filterName, operator, value = match(condition, '(([^%s%p]*)@(%p*)([^%s%p]*))')

        if filterName and filter[filterName] and value then
            operator = operator ~= '' and operator or '=='
            local formattedCondition = formatCondition(filterName, operator, value)
            formattedConditions = gsub(formattedConditions, pair, formattedCondition, 1)
        else
            core:print('FORMATTING', L["Bags"])
            return
        end
    end

    if formattedConditions ~= conditions then
        return format([[
            return function(filterFuncs)
                return function(item)
                    return %s
                end
            end
        ]], formattedConditions)
    end
end

local function updateCollectionMethods(section)
	if not find(section.db.collectionMethod, '%S+') then section.collectionMethodFunc = nil return end
	local parsedString = parseCollectionString(section.db.collectionMethod)

	if not parsedString then return end

	local luaFunction, errorMsg = loadstring(parsedString)

	if luaFunction then
		setfenv(luaFunction, {find = find})
		local success, customFuncGenerator = pcall(luaFunction)
		if not success then
			core:print('FAIL', L["Bags"], customFuncGenerator)
		else
			local customFunc = customFuncGenerator(filter)

			if type(customFunc) == "function" then
				section.collectionMethodFunc = function(bagID, slotID, itemID)
					local item = getItemDetails(bagID, slotID, itemID)
					return item and customFunc(item) or false
				end
			else
				core:print('LUA', L["Bags"], L["The generated custom sorting method did not return a function."])
			end
		end
	else
		core:print('LUA', L["Bags"], errorMsg)
	end
end

local function updateSortMethods(section)
	if find(section.db.sortMethod, '%S+') then
		local luaFunction, errorMsg = loadstring("return " .. section.db.sortMethod)

		if luaFunction then
			local success, customFunc = pcall(luaFunction)

			if not success then
				core:print('FAIL', L["Bags"], customFunc)
				section.sortMethodFunc = defaultSort
			else
				if type(customFunc) == "function" then
					section.sortMethodFunc = customFunc
				else
					core:print('LUA', L["Bags"], L["The loaded custom sorting method did not return a function."])
					section.sortMethodFunc = defaultSort
				end
			end
		else
			core:print('LUA', L["Bags"], errorMsg)
			section.sortMethodFunc = defaultSort
		end
	else
		section.sortMethodFunc = defaultSort
	end
end


function mod:ToggleLayoutMode(f, toggle)
	if toggle then
		for _, section in ipairs(f.currentLayout.sections) do
			local sectionFrame = section.frame
			if not sectionFrame.sizeCrosshairs then
				sectionFrame.sizeCrosshairs = CreateFrame("Frame", '$parentSizeCrosshairs', sectionFrame)
				sectionFrame.sizeCrosshairs:Point("CENTER", sectionFrame, "RIGHT")
				sectionFrame.sizeCrosshairs:Size(30)
				sectionFrame.sizeCrosshairs:EnableMouse(true)
				sectionFrame.sizeCrosshairs:RegisterForDrag("LeftButton")
				sectionFrame.sizeCrosshairs:SetMovable(true)
				sectionFrame.sizeCrosshairs:SetClampedToScreen(true)

				sectionFrame.sizeCrosshairs.tex = sectionFrame.sizeCrosshairs:CreateTexture(nil, "BACKGROUND")
				sectionFrame.sizeCrosshairs.tex:SetAllPoints()
				sectionFrame.sizeCrosshairs.tex:Size(20)
				sectionFrame.sizeCrosshairs.tex:SetTexture(E.Media.Textures.Spark)
				sectionFrame.sizeCrosshairs.tex:SetAlpha(0)

				sectionFrame.sizeCrosshairs.tex1 = sectionFrame.sizeCrosshairs:CreateTexture(nil, "ARTWORK")
				sectionFrame.sizeCrosshairs.tex1:Point("CENTER", sectionFrame.sizeCrosshairs, "CENTER", 5, 0)
				sectionFrame.sizeCrosshairs.tex1:Size(20)
				sectionFrame.sizeCrosshairs.tex1:SetRotation(-pi/2)
				sectionFrame.sizeCrosshairs.tex1:SetTexture(E.Media.Arrows.ArrowUp)

				sectionFrame.sizeCrosshairs.tex2 = sectionFrame.sizeCrosshairs:CreateTexture(nil, "ARTWORK")
				sectionFrame.sizeCrosshairs.tex2:Point("CENTER", sectionFrame.sizeCrosshairs, "CENTER", -5, 0)
				sectionFrame.sizeCrosshairs.tex2:Size(20)
				sectionFrame.sizeCrosshairs.tex2:SetRotation(pi/2)
				sectionFrame.sizeCrosshairs.tex2:SetTexture(E.Media.Arrows.ArrowUp)

				sectionFrame.sizeCrosshairs:SetScript("OnEnter", function(self)
					E:UIFrameFadeIn(self.tex, 0.2, self.tex:GetAlpha(), 0.5)
				end)
				sectionFrame.sizeCrosshairs:SetScript("OnLeave", function(self)
					E:UIFrameFadeOut(self.tex, 0.2, self.tex:GetAlpha(), 0)
				end)
				sectionFrame.sizeCrosshairs:SetScript("OnMouseDown", function()
					sectionFrame.header.highlight.tex:SetAlpha(0.8)
					sectionFrame.header.highlight.tex2:SetAlpha(0)
					E:UIFrameFadeIn(sectionFrame.header.highlight, 0.2, sectionFrame.header.highlight:GetAlpha(), 1)
				end)
				sectionFrame.sizeCrosshairs:SetScript("OnMouseUp", function()
					sectionFrame.header.highlight.tex:SetAlpha(0.1)
					sectionFrame.header.highlight.tex2:SetAlpha(1)
					E:UIFrameFadeOut(sectionFrame.header.highlight, 0.2, sectionFrame.header.highlight:GetAlpha(), 0)
				end)
				sectionFrame.sizeCrosshairs:SetScript("OnDragStop", function(self)
					self.tex:SetVertexColor(1, 1, 1)
					self:StopMovingOrSizing()
					self:SetScript("OnUpdate", nil)
					self:ClearAllPoints()
					self:Point("CENTER", sectionFrame, "RIGHT")
					sectionFrame.header.highlight.tex:SetAlpha(0.1)
					sectionFrame.header.highlight.tex2:SetAlpha(1)
					E:UIFrameFadeOut(sectionFrame.header.highlight, 0.2, sectionFrame.header.highlight:GetAlpha(), 0)
				end)
				sectionFrame.sizeCrosshairs:SetScript("OnDragStart", function(self)
					local layout = f.currentLayout
					local buttonSize, buttonSpacing = layout.buttonSize, layout.buttonSpacing
					local numColumns, maxButtons = layout.numColumns, layout.maxButtons
					local buttonOffset = buttonSize + buttonSpacing
					local currentSection = f.currentLayout.sections[sectionFrame.order]
					self.tex:SetVertexColor(0, 0.5, 0)
					self:StartMoving()
					self.x = select(4, self:GetPoint())
					self.existingColumns = currentSection.db.numColumns
					self:SetScript("OnUpdate", function()
						self.totalDragged = (select(4, self:GetPoint()) - self.x)
						self.numColumns = self.totalDragged < 0 and floor(self.totalDragged / (buttonSize + buttonSpacing))
																or ceil(self.totalDragged / (buttonSize + buttonSpacing))
						local newNumColumns = max(1, min(numColumns, self.existingColumns + self.numColumns))
						sectionFrame:Width(newNumColumns * (buttonSize + buttonSpacing) - buttonSpacing)
						currentSection.db.numColumns = newNumColumns
						twipe(currentSection.db.buttonPositions)
						for j = 1, maxButtons do
							local col = (j - 1) % newNumColumns
							local row = floor((j - 1) / newNumColumns)
							tinsert(currentSection.db.buttonPositions, {col * buttonOffset, -row * buttonOffset})
						end
						mod:UpdateSection(f, currentSection, numColumns, buttonSize, buttonSpacing, true)
					end)
				end)
			end
			sectionFrame.sizeCrosshairs:Show()
			sectionFrame.sizeCrosshairs:SetFrameLevel(10000)
		end
	else
		for _, section in ipairs(f.currentLayout.sections) do
			if section.frame.sizeCrosshairs then
				section.frame.sizeCrosshairs:Hide()
			end
		end
	end
end

function mod:UpdateButtonPositions(button, bagMap, bagID, slotID, currentSection, targetSection)
	if currentSection then
		local buttons = currentSection.buttons
		for i, btn in ipairs(buttons) do
			if btn == button then
				tremove(buttons, i)
				currentSection.db.storedPositions[bagID..'-'..slotID] = nil
				for j = i, #buttons do
					local otherButton = buttons[j]
					if otherButton then
						currentSection.db.storedPositions[otherButton.bagID..'-'..otherButton.slotID] = j
					end
				end
			end
		end
	end
	if targetSection then
		tinsert(targetSection.buttons, button)
		targetSection.db.storedPositions[bagID..'-'..slotID] = #targetSection.buttons
		bagMap[slotID] = targetSection
	end
end

function mod:UpdateEmptyButtonCount(f, update)
	local emptyButton = f.emptyButton
	if update then
		if emptyButton.emptySlotsSelection == 0 then
			local empty = 0
			for _ in pairs(buttonMap[f]) do
				empty = empty + 1
			end
			emptyButton.emptySlotsText:SetText(empty)
			emptyButton.emptySlotsText:SetTextColor(1,1,1)
		else
			for _, section in ipairs(f.currentLayout.sections) do
				if section.db.bagID == emptyButton.emptySlotsSelection then
					emptyButton.emptySlotsText:SetTextColor(unpack(section.db.title.color))
					emptyButton.emptySlotsText:SetText(GetContainerNumFreeSlots(emptyButton.emptySlotsSelection))
					return
				end
			end
			emptyButton.emptySlotsText:SetTextColor(1,1,1)
			emptyButton.emptySlotsText:SetText(GetContainerNumFreeSlots(emptyButton.emptySlotsSelection))
		end
	else
		local nextBagSlots, color
		for _, bagID in ipairs(f.BagIDs) do
			local bag = bagID ~= emptyButton.emptySlotsSelection and f.Bags[bagID]
			if bag and bag.numSlots > 0 and bag.type and bag.type ~= 0 then
				nextBagSlots = GetContainerNumFreeSlots(bagID)
				emptyButton.emptySlotsSelection = bagID
				for _, section in ipairs(f.currentLayout.sections) do
					if section.db.bagID == bagID then
						color = section.db.title.color
					end
				end
				break
			end
		end
		if nextBagSlots then
			emptyButton.emptySlotsText:SetText(nextBagSlots)
			emptyButton.emptySlotsText:SetTextColor(unpack(color or {1,1,1}))
		else
			local empty = 0
			for _ in pairs(buttonMap[f]) do
				empty = empty + 1
			end
			emptyButton.emptySlotsText:SetText(empty)
			emptyButton.emptySlotsText:SetTextColor(1,1,1)
			emptyButton.emptySlotsSelection = 0
		end
	end
end

local function showEmptyButtonTT(f)
	local total, empty = 0, 0
	for _, bagID in ipairs(f.BagIDs) do
		local bag = f.Bags[bagID]
		if bag and bag.numSlots > 0 then
			empty = empty + GetContainerNumFreeSlots(bagID)
			total = total + bag.numSlots
		end
	end
	GameTooltip:SetOwner(f.emptyButton)
	GameTooltip:ClearLines()
	if not f.emptyButton.hideHints then
		GameTooltip:AddLine(L["Click: toggle layout mode."])
		GameTooltip:AddLine(L["Alt-Click: re-evaluate all items."])
		GameTooltip:AddLine(L["Shift-Alt-Click: toggle these hints."])
		GameTooltip:AddLine(L["Mouse-Wheel: navigate between special and normal bags."])
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L["This button accepts cursor item drops."])
		GameTooltip:AddLine(" ")
	end
	GameTooltip:AddLine(format(NUM_FREE_SLOTS, empty))
	GameTooltip:Show()
end

local function handleButton(f, button)
	if not button.highlight then
		button.highlight = CreateFrame("Frame", nil, button)
		button.highlight:SetAllPoints()

		button.highlight.glow = CreateFrame("Frame", nil, button.highlight)
		button.highlight.glow:SetAllPoints()
		button.highlight.glow.tex = button.highlight.glow:CreateTexture(nil, "OVERLAY")
		button.highlight.glow.tex:SetAllPoints()
		button.highlight.glow.tex:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		button.highlight.glow.tex:SetBlendMode("ADD")

		button.highlight.pulse = CreateFrame("Frame", nil, button.highlight)
		button.highlight.pulse:SetAllPoints()
		button.highlight.pulse.tex = button.highlight.pulse:CreateTexture(nil, "OVERLAY")
		button.highlight.pulse.tex:SetAllPoints()
		button.highlight.pulse.tex:SetTexture("Interface\\Cooldown\\star4")
		button.highlight.pulse.tex:SetBlendMode("ADD")

		button.highlight:Hide()

		button.highlight:HookScript("OnShow", function(self)
			E:Flash(self.pulse, 1, true)
		end)

		button.highlight:HookScript("OnHide", function(self)
			E:StopFlash(self.pulse)
		end)
	end
	if not mod:IsHooked(button, "OnEnter") then
		mod:SecureHookScript(button, "OnEnter", function(self)
			if self.atHeader == 'evaluate' then
				E:UIFrameFadeIn(f.emptyButton.highlight, 0.2, f.emptyButton.highlight:GetAlpha(), 1)
				showEmptyButtonTT(f)
			elseif self.atHeader then
				E:UIFrameFadeIn(self.atHeader.frame.header.highlight, 0.2, self.atHeader.frame.header.highlight:GetAlpha(), 1)
			else
				self.highlight:Hide()
			end
		end)
	end
	if not mod:IsHooked(button, "OnLeave") then
		mod:SecureHookScript(button, "OnLeave", function(self)
			if self.atHeader then
				if self.atHeader == 'evaluate' then
					E:UIFrameFadeOut(f.emptyButton.highlight, 0.2, f.emptyButton.highlight:GetAlpha(), 0)
					f.emptyButton.highlight:SetFrameLevel(999)
					GameTooltip_Hide()
				else
					local header = self.atHeader.frame.header
					E:UIFrameFadeOut(self.atHeader.frame.header.highlight, 0.2, self.atHeader.frame.header.highlight:GetAlpha(), 0)
					header:SetFrameLevel(999)
					if header.prevEmptySlotsSelection then
						f.emptyButton.emptySlotsSelection = header.prevEmptySlotsSelection
						header.prevEmptySlotsSelection = nil
						mod:UpdateEmptyButtonCount(f, true)
					end
				end
				self:Hide()
				self:SetAlpha(1)
				self.atHeader = false
			end
		end)
	end
	if not mod:IsHooked(button, "OnMouseWheel") then
		button:EnableMouseWheel(true)
		mod:SecureHookScript(button, "OnMouseWheel", function(self)
			if self.atHeader == 'evaluate' then
				self:GetScript("OnLeave")(self)
				f.emptyButton:GetScript("OnMouseWheel")(f.emptyButton)
			end
		end)
	end
	if not mod:IsHooked(button, "OnDragStart") then
		mod:SecureHookScript(button, "OnDragStart", function(self)
			if GetCursorInfo() then
				local header = buttonMap[self.bagID][self.slotID].frame.header
				if header:IsMouseOver() then
					header:GetScript("OnEnter")(header)
				end
				f.draggedButton = button
				f.emptyButton:SetScript("OnUpdate", function(eb)
					if not GetCursorInfo() and not button.atHeader then
						f.draggedButton = false
						eb:SetScript("OnUpdate", nil)
					end
				end)
			end
		end)
	end
end


local function wipeLayout(f, isBank)
	mod:ToggleLayoutMode(f)
	mod.localhooks[f] = nil
	for _, section in ipairs(f.currentLayout.sections) do
		for _, button in ipairs(section.buttons) do
			if button.highlight then
				button.highlight:Hide()
				button.highlight = nil
			end
			if mod:IsHooked(button, "OnEnter") then
				mod:Unhook(button, "OnEnter")
			end
			if mod:IsHooked(button, "OnLeave") then
				mod:Unhook(button, "OnLeave")
			end
			if mod:IsHooked(button, "OnMouseWheel") then
				mod:Unhook(button, "OnMouseWheel")
			end
			if mod:IsHooked(button, "OnDragStart") then
				mod:Unhook(button, "OnDragStart")
			end
			if mod:IsHooked(button, "OnClick") then
				mod:Unhook(button, "OnClick")
			end
		end
		local frame = section.frame
		if frame then
			frame:Hide()
			section.frame = nil
		end
	end
	if f.heldCurrencies then
		f.heldCurrencies:Hide()
		f.heldCurrencies = nil
	end
	if f.qualityFilterButton then
		f.qualityFilterButton:Hide()
		f.qualityFilterButton = nil
	end
	if f.qualityFilterBar then
		for _, bar in ipairs(f.qualityFilterBar) do
			bar:Hide()
		end
		f.qualityFilterBar:Hide()
		f.qualityFilterBar = nil
	end
	f.emptyButton:Hide()
	f.emptyButton = nil
	f.currentLayout = nil
	f.editBox:ClearAllPoints()
	if isBank then
		f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", (E.Border * 2) + 18, E.Border * 2 + 2)
		f.editBox:Point("RIGHT", f.purchaseBagButton, "LEFT", -5, 0)
	else
		f.currencyButton:ClearAllPoints()
		f.currencyButton:Point("BOTTOM", 0, 4)
		f.currencyButton:Point("TOPLEFT", f.holderFrame, "BOTTOMLEFT", 0, 18)
		f.currencyButton:Point("TOPRIGHT", f.holderFrame, "BOTTOMRIGHT", 0, 18)

		f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", (E.Border * 2) + 18, E.Border * 2 + 2)
		f.editBox:Point("RIGHT", f.vendorGraysButton, "LEFT", -5, 0)
	end
end

local function runAllScripts(self, event, ...)
	for _, info in pairs(mod.localhooks) do
		for handler, script in pairs(info) do
			if handler == event and script then script(self, ...) end
		end
	end
end


P["Extras"]["general"][modName] = {
	["EasierProcessing"] = {
		["enabled"] = false,
		["modifier"] = 'Alt',
	},
	["SplitStack"] = {
		["enabled"] = false,
		["modifier"] = 'Control',
	},
	["BagsExtendedV2"] = {
		["enabled"] = false,
		["selectedContainer"] = 'bags',
		["containers"] = {
			["bags"] = {
				["selectedSection"] = 1,
				["iconSpacing"] = 4,
				["specialBags"] = {},
				["sections"] = {
					{
						["sortMethod"] = '',
						["collectionMethod"] = '',
						["ignoreList"] = {},
						["storedPositions"] = {},
						["sectionSpacing"] = 14,
						["icon"] = {
							["enabled"] = false,
							["texture"] = "Interface\\Icons\\INV_Potion_93",
							["point"] = "BOTTOMRIGHT",
							["relativeTo"] = "BOTTOMLEFT",
							["xOffset"] = 0,
							["yOffset"] = 0,
							["toText"] = true,
							["size"] = 16,
						},
						["title"] = {
							["text"] = OTHER,
							["color"] = { 1, 1, 1 },
							["font"] = "Expressway",
							["size"] = 13,
							["flags"] = "OUTLINE",
							["point"] = "BOTTOMLEFT",
							["relativeTo"] = "BOTTOMRIGHT",
							["xOffset"] = 0,
							["yOffset"] = 0,
						},
					},
				},
			},
		},
	},
}

function mod:LoadConfig(db)
	local selectedItemType = 0
    local function selectedContainer() return db.BagsExtendedV2.selectedContainer end
    local function selectedContainerData()
		return core:getSelected("general", modName, format("BagsExtendedV2.containers[%s]", selectedContainer() or ""), "bags")
	end
    local function selectedSection() return selectedContainerData().selectedSection or 1 end
	local function selectedSectionData()
		return core:getSelected("general", modName, format("BagsExtendedV2.containers.%s.sections[%s]", selectedContainer() or "bags", selectedSection() or ""), 1)
	end
	local function setupSections(isBank)
		local data = selectedContainerData()
		local buttonSpacing = data.buttonSpacing or E.Border * 2
		local buttonSize = isBank and B.db.bankSize or B.db.bagSize
		local numColumns = floor((isBank and B.db.bankWidth or B.db.bagWidth) / (buttonSize + buttonSpacing))
		local splitCol = floor(numColumns/3)
		local splitColumns
		if numColumns > 6 then
			splitColumns = {splitCol, splitCol, numColumns - splitCol*2}
		else
			splitColumns = {numColumns, numColumns, numColumns}
		end
		local icons = {
			"Interface\\Icons\\INV_Chest_Chain_15",
			"Interface\\Icons\\INV_Sword_27",
			"Interface\\Icons\\INV_Jewelcrafting_Gem_32",
			"Interface\\Icons\\INV_Engineering_90_Gear",
			"Interface\\Icons\\INV_Ammo_Arrow_02",
			"Interface\\Icons\\INV_Scroll_06",
			"Interface\\Icons\\INV_Potion_51",
			"Interface\\Icons\\INV_Letter_05",
			"Interface\\Icons\\INV_Misc_Rune_01",
		}
		for i, sectionType in ipairs({Armor, Weapon, Gem, TradeGoods, Projectile, Recipe, Consumable, Quest, Miscellaneous}) do
			tinsert(data.sections, 1, {
				["shouldPopulate"] = true,
				["numColumns"] = i > 3 and splitColumns[i%3+1] or numColumns,
				["sortMethod"] = '',
				["collectionMethod"] = 'type@'..lower(gsub(sectionType, '[%s%p]+', '')),
				["ignoreList"] = {},
				["storedPositions"] = {},
				["sectionSpacing"] = 22,
				["title"] = {
					["text"] = sectionType,
					["toIcon"] = true,
					["color"] = { 1, 1, 1 },
					["font"] = "Expressway",
					["size"] = 13,
					["flags"] = "OUTLINE",
					["point"] = "BOTTOMLEFT",
					["relativeTo"] = "BOTTOMRIGHT",
					["xOffset"] = 0,
					["yOffset"] = 0,
				},
				["icon"] = {
					["enabled"] = true,
					["texture"] = icons[i],
					["point"] = "TOPLEFT",
					["relativeTo"] = "TOPLEFT",
					["xOffset"] = 0,
					["yOffset"] = 2,
					["toText"] = false,
					["size"] = 16,
				},
			})
		end
		for i = 1, GetNumEquipmentSets() do
			local setName = GetEquipmentSetInfo(i)
			if setName then
				tinsert(data.sections, 1, {
					["shouldPopulate"] = true,
					["numColumns"] = numColumns,
					["sortMethod"] = '',
					["collectionMethod"] = 'set@'..lower(gsub(setName, '[%s%p]+', '')),
					["ignoreList"] = {},
					["storedPositions"] = {},
					["sectionSpacing"] = 22,
					["title"] = {
						["text"] = setName,
						["toIcon"] = true,
						["color"] = { 1, 1, 1 },
						["font"] = "Expressway",
						["size"] = 13,
						["flags"] = "OUTLINE",
						["point"] = "BOTTOMLEFT",
						["relativeTo"] = "BOTTOMRIGHT",
						["xOffset"] = 0,
						["yOffset"] = 0,
					},
					["icon"] = {
						["enabled"] = true,
						["texture"] = select(2,GetEquipmentSetInfo(i)),
						["point"] = "TOPLEFT",
						["relativeTo"] = "TOPLEFT",
						["xOffset"] = 0,
						["yOffset"] = 2,
						["toText"] = false,
						["size"] = 16,
					},
				})
			end
		end
		data.selectedSection = 1
		data.topOffset = 8
	end
    core.general.args[modName] = {
        type = "group",
        name = L[modName],
		get = function(info) return db[info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) db[info[#info-1]][gsub(info[#info], info[#info-1], '')] = value mod:Toggle(db) end,
		disabled = function() return not E.private.bags.enable end,
        args = {
			EasierProcessing = {
				order = 1,
				type = "group",
				name = L["Easier Processing"],
				guiInline = true,
				args = {
					enabledEasierProcessing = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Mod-clicking an item suggests a skill/item to process it."],
					},
					modifierEasierProcessing = {
						order = 2,
						type = "select",
						name = L["Modifier"],
						desc = "",
						values = E.db.Extras.modifiers,
						disabled = function() return not db.EasierProcessing.enabled end,
					},
				},
			},
			SplitStack = {
				order = 1,
				type = "group",
				name = L["Split Stack"],
				guiInline = true,
				args = {
					enabledSplitStack = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = format(L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies."..
								"\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."], db.SplitStack.modifier),
					},
					modifierSplitStack = {
						order = 2,
						type = "select",
						name = L["Modifier"],
						desc = "",
						values = E.db.Extras.modifiers,
						disabled = function() return not db.SplitStack.enabled end,
					},
				},
			},
            BagsExtendedV2 = {
				order = 3,
                type = "group",
                name = L["Bags Extended"],
                guiInline = true,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
                        name = core.pluginColor..L["Enable"],
                        desc = L["Extends the bags functionality."],
						get = function() return db.BagsExtendedV2.enabled end,
						set = function(_, value) db.BagsExtendedV2.enabled = value self:Toggle(db) end,
                    },
					setupSections = {
						order = 2,
						type = "execute",
						name = L["Setup Sections"],
						desc = L["Adds default sections set to the currently selected container."],
						func = function()
							setupSections(selectedContainer() == 'bank')
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function() return not db.BagsExtendedV2.enabled end,
					},
					buttonSpacing = {
						order = 3,
						type = "range",
						name = L["Button Spacing"],
						desc = "",
						min = 0, max = 20, step = 1,
						get = function() return selectedContainerData().buttonSpacing end,
						set = function(_, value)
							selectedContainerData().buttonSpacing = value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function() return not db.BagsExtendedV2.enabled end,
					},
					selectedContainer = {
						order = 4,
						type = "select",
						name = L["Select Container Type"],
						desc = "",
						get = function() return db.BagsExtendedV2.selectedContainer end,
						set = function(_, value) db.BagsExtendedV2.selectedContainer = value end,
						values = {
							['bags'] = L['Bags'],
							['bank'] = L['Bank'],
						},
						disabled = function() return not db.BagsExtendedV2.enabled end,
					},
					topOffset = {
						order = 5,
						type = "range",
						name = L["Top Offset"],
						desc = "",
						min = 0, max = 60, step = 1,
						get = function() return selectedContainerData().topOffset end,
						set = function(_, value)
							selectedContainerData().topOffset = value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function() return not db.BagsExtendedV2.enabled end,
					},
					bottomOffset = {
						order = 6,
						type = "range",
						name = L["Bottom Offset"],
						desc = "",
						min = 0, max = 60, step = 1,
						get = function() return selectedContainerData().bottomOffset end,
						set = function(_, value)
							selectedContainerData().bottomOffset = value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function() return not db.BagsExtendedV2.enabled end,
					},
				},
			},
			settings = {
				order = 4,
                type = "group",
                name = L["Settings"],
                guiInline = true,
				get = function(info) return selectedSectionData()[info[#info]] end,
				set = function(info, value)
					selectedSectionData()[info[#info]] = value
					self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
				end,
                disabled = function() return not db.BagsExtendedV2.enabled end,
				hidden = function() return not db.BagsExtendedV2.enabled end,
                args = {
					addSection = {
						order = 1,
						type = "execute",
						name = L["Add Section"],
						desc = "",
						func = function()
							local newSection = {
								["sortMethod"] = '',
								["collectionMethod"] = '',
								["ignoreList"] = {},
								["storedPositions"] = {},
								["sectionSpacing"] = 14,
								["title"] = {
									["text"] = "New Section",
									["toIcon"] = true,
									["color"] = { 1, 1, 1 },
									["font"] = "Expressway",
									["size"] = 13,
									["flags"] = "OUTLINE",
									["point"] = "BOTTOMLEFT",
									["relativeTo"] = "BOTTOMRIGHT",
									["xOffset"] = 0,
									["yOffset"] = 0,
								},
								["icon"] = {
									["enabled"] = false,
									["texture"] = "Interface\\Icons\\INV_Potion_93",
									["point"] = "TOPLEFT",
									["relativeTo"] = "TOPLEFT",
									["xOffset"] = 0,
									["yOffset"] = 0,
									["toText"] = false,
									["size"] = 16,
								},
							}
							tinsert(selectedContainerData().sections, 1, newSection)
							selectedContainerData().selectedSection = 1
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true}, true)
						end,
					},
					deleteSection = {
						order = 2,
						type = "execute",
						name = L["Delete Section"],
						desc = "",
						func = function()
							tremove(selectedContainerData().sections, selectedSection())
							selectedContainerData().selectedSection = 1
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function()
							return not db.BagsExtendedV2.enabled
									or selectedSection() == #selectedContainerData().sections
									or selectedSectionData().isSpecialBag
						end,
					},
                    sectionSpacing = {
                        order = 3,
                        type = "range",
                        name = L["Section Spacing"],
						desc = "",
                        min = 0, max = 40, step = 1,
                        get = function() return selectedSectionData().sectionSpacing end,
                        set = function(_, value)
							selectedSectionData().sectionSpacing = value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function() return not db.BagsExtendedV2.enabled end,
                    },
					sectionPriority = {
						order = 4,
						type = "input",
						name = L["Section Priority"],
						desc = "",
						get = function() return tostring(selectedContainerData().selectedSection) end,
						set = function(_, value)
							local sections = selectedContainerData().sections
							local currentIndex = selectedContainerData().selectedSection
							local targetIndex = tonumber(value)
							local sectionCount = #sections - 1

							if targetIndex and targetIndex >= 1 and targetIndex <= sectionCount and targetIndex ~= currentIndex then
								local tempHolder = sections[targetIndex]
								sections[targetIndex] = sections[currentIndex]
								sections[currentIndex] = tempHolder
								selectedContainerData().selectedSection = targetIndex
							elseif targetIndex and targetIndex > sectionCount then
								local bottomIndex = sectionCount
								local tempHolder = sections[bottomIndex]
								sections[bottomIndex] = sections[currentIndex]
								sections[currentIndex] = tempHolder
								selectedContainerData().selectedSection = bottomIndex
							elseif targetIndex and targetIndex < 1 then
								local tempHolder = sections[1]
								sections[1] = sections[currentIndex]
								sections[currentIndex] = tempHolder
								selectedContainerData().selectedSection = 1
							end
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function()
							return not db.BagsExtendedV2.enabled
									or selectedSection() == #selectedContainerData().sections
						end,
					},
                    selectedSection = {
						order = 5,
						type = "select",
						width = "double",
						name = L["Select Section"],
						desc = "",
						get = function() return tostring(selectedSection()) end,
						set = function(_, value) selectedContainerData().selectedSection = tonumber(value) end,
						values = function()
							local dropdownValues = {}
							for i, section in ipairs(selectedContainerData().sections) do
								dropdownValues[tostring(i)] = section.title.text
							end
							return dropdownValues
						end,
					},
					collectionMethod = {
						order = 6,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Collection Method"],
						desc = L["Handles the automated repositioning of the newly received items."..
						"\nSyntax: filter@value\n\n"..
						"Available filters:\n"..
						" id@number - matches itemID,\n"..
						" name@string - matches name,\n"..
						" subtype@string - matches subtype,\n"..
						" ilvl@number - matches ilvl,\n"..
						" uselevel@number - matches equip level,\n"..
						" quality@number - matches quality,\n"..
						" equipslot@number - matches inventorySlotID,\n"..
						" maxstack@number - matches stack limit,\n"..
						" price@number - matches sell price,\n\n"..
						" tooltip@string - matches tooltip text,\n\n"..
						"All string matches are case-insensitive and match only alphanumeric symbols. Standard Lua logic applies. "..
						"Look up GetItemInfo API for more info on filters. "..
						"Use GetAuctionItemClasses and GetAuctionItemSubClasses (same as on the AH) to get the localized types and subtypes values.\n\n"..
						"Example usage (priest t8 or Shadowmourne):\n"..
						"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
						"Accepts custom functions (bagID, slotID, itemID are exposed)\n"..
						"The below one notifies of the newly acquired items.\n\n"..
						"local icon = GetContainerItemInfo(bagID, slotID)\n"..
						"local _, link = GetItemInfo(itemID)\n"..
						"icon = gsub(icon, '\\124', '\\124\\124')\n"..
						"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
						"print('Item received: ' .. string)"],
						set = function(info, value)
							selectedSectionData()[info[#info]] = value
							selectedSectionData().shouldPopulate = true
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						hidden = function() return selectedSectionData().isSpecialBag end,
					},
					itemTypeInfo = {
						order = 7,
						type = "select",
						width = "double",
						name = L["Available Item Types"],
						desc = L["Lists all available item subtypes for each available item type."],
						get = function() return selectedItemType end,
						set = function(_, value) selectedItemType = value end,
						values = function()
							local dropdownValues = {[1] = ""}
							for _, itemType in ipairs({GetAuctionItemClasses()}) do
								tinsert(dropdownValues, itemType)
							end
							return dropdownValues
						end,
						hidden = function() return selectedSectionData().isSpecialBag or selectedContainer() == 'bank' end,
					},
					subTypeInfo = {
						order = 8,
						type = "description",
						name = function()
							return tconcat({GetAuctionItemSubClasses(selectedItemType-1)}, ", ")
						end,
						hidden = function() return selectedSectionData().isSpecialBag or selectedContainer() == 'bank' end,
					},
					sortMethod = {
						order = 9,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Sorting Method"],
						desc = L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
								"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
								"function(a,b)\n"..
								"--your sorting logic here\n"..
								"end\n\n"..
								"Leave blank to go default."],
						set = function(info, value)
							selectedSectionData()[info[#info]] = value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
					},
					addItem = {
						order = 10,
						type = "input",
						width = "double",
						name = L["Ignore Item (by ID)"],
						desc = L["Listed ItemIDs will not get sorted."],
						get = function() return "" end,
						set = function(_, value)
							local itemID = match(value, '%D*(%d+)%D*')
							if itemID and GetItemInfo(itemID) then
								selectedSectionData().ignoreList[tonumber(itemID)] = true
								local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
								texture = gsub(texture, '\124', '\124\124')
								local string = '\124T' .. texture .. ':16:16\124t' .. link
								core:print('ADDED', string)
							end
						end,
					},
					removeItem = {
						order = 11,
						type = "select",
						width = "double",
						name = L["Remove Ignored"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							local ignoreList = selectedSectionData().ignoreList
							for itemID in pairs(ignoreList) do
								if itemID == value then
									ignoreList[itemID] = nil
									local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
									texture = gsub(texture, '\124', '\124\124')
									local string = '\124T' .. texture .. ':16:16\124t' .. link
									core:print('REMOVED', string)
									self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
									break
								end
							end
						end,
						values = function()
							local values = {}
							for itemID in pairs(selectedSectionData().ignoreList) do
								local itemName = GetItemInfo(itemID)
								local itemIcon = select(10, GetItemInfo(itemID))
								itemIcon = itemIcon and "|T"..itemIcon..":0|t" or ""
								values[itemID] = format("%s %s", itemIcon, itemName)
							end
							return values
						end,
					},
				},
			},
			title = {
                type = "group",
                name = L["Title"],
                guiInline = true,
				get = function(info) return selectedSectionData().title[info[#info]] end,
				set = function(info, value)
					selectedSectionData().title[info[#info]] = value
					self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
				end,
                hidden = function() return not db.BagsExtendedV2.enabled end,
				args = {
					color = {
						order = 0,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedSectionData().title.color) end,
						set = function(_, r, g, b)
							selectedSectionData().title.color = { r, g, b }
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
					},
					toIcon = {
						order = 1,
						type = "toggle",
						name = L["Attach to Icon"],
						desc = "",
						set = function(info, value)
							selectedSectionData().title[info[#info]] = value
							selectedSectionData().icon.toText = not value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						disabled = function() return not db.BagsExtendedV2.enabled or not selectedSectionData().icon.enabled end,
					},
					text = {
						order = 2,
						type = "input",
						width = "double",
						name = L["Text"],
						desc = "",
					},
					justify = {
						order = 3,
						type = "select",
						name = L["Justify"],
						values = {
							["LEFT"] = L["Left"],
							["CENTER"] = L["Center"],
							["RIGHT"] = L["Right"],
						},
						desc = "",
						disabled = function()
							return not db.BagsExtendedV2.enabled
									or (selectedSectionData().icon.enabled and selectedSectionData().icon.toText)
						end,
					},
					size = {
						order = 3,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 8, max = 20, step = 1,
					},
					font = {
						order = 4,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end,
					},
					flags = {
						order = 5,
						type = "select",
						name = L["Font Flags"],
						desc = "",
						values = {
							[""] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
							["MONOCHROME"] = "MONOCHROME",
							["OUTLINEMONOCHROME"] = "OUTLINEMONOCHROME",
						},
					},
					point = {
						order = 6,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
					relativeTo = {
						order = 7,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
					xOffset = {
						order = 8,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -40, max = 40, step = 1,
					},
					yOffset = {
						order = 9,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -40, max = 40, step = 1,
					},
				},
			},
			icon = {
                type = "group",
                name = L["Icon"],
                guiInline = true,
				get = function(info) return selectedSectionData().icon[info[#info]] end,
				set = function(info, value)
					selectedSectionData().icon[info[#info]] = value
					self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
				end,
                hidden = function() return not db.BagsExtendedV2.enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
                        name = core.pluginColor..L["Enable"],
						desc = "",
					},
					toText = {
						order = 2,
						type = "toggle",
						name = L["Attach to Text"],
						desc = "",
						set = function(info, value)
							selectedSectionData().icon[info[#info]] = value
							selectedSectionData().title.toIcon = not value
							self:UpdateAll(nil, selectedContainer() == 'bags' and {false} or {true})
						end,
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
					texture = {
						order = 3,
						type = "input",
						name = L["Texture"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
					size = {
						order = 4,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 8, max = 32, step = 1,
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
					point = {
						order = 5,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not selectedSectionData().icon.enabled or not selectedSectionData().icon.toText end,
					},
					relativeTo = {
						order = 6,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not selectedSectionData().icon.enabled or not selectedSectionData().icon.toText end,
					},
					xOffset = {
						order = 7,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -40, max = 40, step = 1,
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
					yOffset = {
						order = 8,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -40, max = 40, step = 1,
						hidden = function() return not selectedSectionData().icon.enabled end,
					},
				},
			},
        },
    }
	if not db.BagsExtendedV2.containers['bank'] then
		db.BagsExtendedV2.containers['bank'] = CopyTable(db.BagsExtendedV2.containers['bags'])
	end
end


function mod:UpdateAll(disable, containerType, highlight)
	for _, isBank in pairs(containerType or {false, true}) do
		local f = B_GetContainerFrame(nil, isBank)
		if f then
			if disable and f.currentLayout then
				mod.localhooks[f] = nil
				wipeLayout(f, isBank)
				f.holderFrame:ClearAllPoints()
				f.holderFrame:Point("TOP", f, "TOP", 0, -f.topOffset)
				f.holderFrame:Point("BOTTOM", f, "BOTTOM", 0, 8)
				self:HandleSortButton(f, false, isBank)
			else
				mod.localhooks[f] = {
					["OnClick"] = function(self)
						if GetCursorInfo() then
							f.draggedButton = self
							f.emptyButton:SetScript("OnUpdate", function(emptyButton)
								if not GetCursorInfo() and not self.atHeader then
									f.draggedButton = false
									emptyButton:SetScript("OnUpdate", nil)
								end
							end)
						end
					end
				}
			end
			B:Layout(isBank)
			if highlight then
				f.emptyButton.highlight.tex:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
				f.emptyButton.highlight.tex:SetVertexColor(0, 1, 1)
				E:UIFrameFadeIn(f.emptyButton.highlight, 1, f.emptyButton.highlight:GetAlpha(), 1)
				E:Delay(1, function()
					E:Flash(f.emptyButton.highlight, 1, true)
				end)
			end
		end
	end
end

function mod:EvaluateItem(sections, bagID, slotID, itemID)
    for _, section in ipairs(sections) do
        if (section.collectionMethodFunc and section.collectionMethodFunc(bagID, slotID, itemID))
				or (section.db.isSpecialBag and section.db.bagID == bagID) then
			return section, true
        end
    end
	return sections[#sections]
end

function mod:SortAllSections(f)
	local layout = f.currentLayout
	for _, section in ipairs(layout.sections) do
		if not section.frame.minimized then
			local ignoreList = section.db.ignoreList
			local sortedButtons = {}
			local ignoredButtons = {}

			for i, button in ipairs(section.buttons) do
				if ignoreList[button.itemID or B_GetItemID(nil, button.bagID, button.slotID)] then
					ignoredButtons[i] = button
				else
					tinsert(sortedButtons, button)
				end
			end

			tsort(sortedButtons, section.sortMethodFunc)
			for i, ignoredButton in pairs(ignoredButtons) do
				tinsert(sortedButtons, i, ignoredButton)
			end
			for i, button in ipairs(sortedButtons) do
				section.db.storedPositions[button.bagID..'-'..button.slotID] = i
			end
			section.buttons = {unpack(sortedButtons)}

			self:UpdateSection(f, section, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
		end
	end
end

function mod:HandleSortButton(f, enable, isBank)
	if enable then
		f.sortButton:SetScript("OnClick", nil)
		f.sortButton:SetScript("OnMouseDown", function() self:SortAllSections(f) end)
	else
		f.sortButton:SetScript("OnUpdate", nil)
		f.sortButton:SetScript("OnMouseDown", nil)
		f.sortButton:SetScript("OnClick", function()
			f:UnregisterAllEvents()
			if not f.registerUpdate then
				B:SortingFadeBags(f, true)
			end
			B:CommandDecorator(B.SortBags, isBank and "bank" or "bags")()

			E:StartSpinnerFrame(f.holderFrame)
		end)
	end
end

function mod:ConfigureContainer(f, isBank, db, numColumns, buttonSize, buttonSpacing)
    local sections = db.sections
    local buttons = {}
	local specialBags, specialButtons = {}, {}
    local processedSections = {}
	local minIconLeft = huge
	local buttonOffset = buttonSize + buttonSpacing
	local maxButtons = 0
	local layoutSections = f.currentLayout and f.currentLayout.sections or {}

	buttonMap[f] = {}

    for _, bagID in ipairs(f.BagIDs) do
		specialButtons[bagID] = {}
		local bag = f.Bags[bagID]
		local bagSlots = bag and bag.numSlots
		if bagSlots and bagSlots > 0 then
			buttonMap[bagID] = {}
			local bagType = bag.type
			if bagType and bagType ~= 0 then
				local exists = false
				for _, section in ipairs(sections) do
					if section.isSpecialBag and section.bagID == bagID then
						exists = true
						break
					end
				end
				if not exists or (not db.specialBags[bagID] or db.specialBags[bagID] ~= GetBagName(bagID)) then
					specialBags[bagID] = {
						numSlots = bagSlots,
						buttons = {},
						bagType = bagType,
					}
				end
				for slotID = 1, bagSlots do
					local button = bag[slotID]
					tinsert(specialButtons[bagID], button)
					handleButton(f, button)
				end
			else
				for slotID = 1, bagSlots do
					local button = bag[slotID]
					if button.hasItem then
						local itemID = B_GetItemID(nil, bagID, slotID)
						button.itemID = itemID
						tinsert(buttons, button)
					else
						button.itemID = false
						button:Hide()
						buttonMap[f][button] = true
					end
					handleButton(f, button)
				end
            end
			maxButtons = maxButtons + bagSlots
		end
	end

    self:HandleSortButton(f, true, isBank, numColumns, buttonSize, buttonSpacing)

    if next(layoutSections) then
		local cleanup = {}
		for i, section in ipairs(sections) do
			if section.isSpecialBag then
				local bagID = section.bagID
				if buttonMap[bagID] then
					local numSlots, bagType = GetContainerNumFreeSlots(bagID)
					if numSlots == 0 or (not bagType or bagType == 0) or (db.specialBags[bagID] and db.specialBags[bagID] ~= GetBagName(bagID)) then
						buttonMap[bagID] = {}
						db.specialBags[bagID] = false
						tremove(sections, i)
						tremove(layoutSections, i)
						cleanup[bagID] = true
					end
				end
			end
		end
		if next(cleanup) then
			for _, section in ipairs(layoutSections) do
				if section.isSpecialBag and cleanup[section.bagID] then
					for _, button in ipairs(section.buttons) do
						if button.highlight then
							button.highlight:Hide()
							button.highlight = nil
						end
					end
					local frame = section.frame
					if frame then
						frame:Hide()
						section.frame = nil
					end
				end
			end
			if E.RefreshGUI then E:RefreshGUI() end
		end
		local currentRowColumns
		for i, section in ipairs(layoutSections) do
			if i == 1 then
				currentRowColumns = section.db.numColumns
				section.db.numColumns = min(section.db.numColumns, numColumns)
			else
				if currentRowColumns + section.db.numColumns <= numColumns then
					currentRowColumns = currentRowColumns + section.db.numColumns
				else
					section.db.numColumns = min(section.db.numColumns, numColumns)
					currentRowColumns = section.db.numColumns
				end
			end
		end
	end

	for bagID, bagInfo in pairs(specialBags) do
		local specialSection = {
			["sortMethod"] = '',
			["collectionMethod"] = '',
			["ignoreList"] = {},
			["storedPositions"] = {},
			["sectionSpacing"] = 14,
			["title"] = {
				["enabled"] = true,
				["text"] = GetBagName(bagID) or "Special Bag",
				["toIcon"] = true,
				["color"] = {unpack(B.ProfessionColors[bagInfo.bagType])},
				["font"] = "Expressway",
				["size"] = 13,
				["flags"] = "OUTLINE",
				["point"] = "BOTTOMLEFT",
				["relativeTo"] = "TOPLEFT",
				["xOffset"] = 0,
				["yOffset"] = 0,
			},
			["icon"] = {
				["enabled"] = false,
				["texture"] = GetInventoryItemTexture("player", ContainerIDToInventoryID(bagID)),
				["point"] = "TOPLEFT",
				["relativeTo"] = "TOPLEFT",
				["xOffset"] = 0,
				["yOffset"] = 0,
				["toText"] = false,
				["size"] = 16,
			},
			["isSpecialBag"] = true,
			["bagID"] = bagID,
		}
		db.specialBags[bagID] = GetBagName(bagID)
		tinsert(sections, 1, specialSection)
		if f.emptyButton then
			f.emptyButton.highlight.tex:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
			f.emptyButton.highlight.tex:SetVertexColor(0, 1, 1)
			E:UIFrameFadeIn(f.emptyButton.highlight, 1, f.emptyButton.highlight:GetAlpha(), 1)
			E:Delay(1, function()
				E:Flash(f.emptyButton.highlight, 1, true)
			end)
		end
		if E.RefreshGUI then E:RefreshGUI() end
	end

	for i, section in ipairs(sections) do
		local sectionFrame = layoutSections[i] and layoutSections[i].frame

		section.buttonPositions = {}
		section.numColumns = section.numColumns or numColumns

		local columns = section.numColumns
		for j = 1, maxButtons do
			local col = (j - 1) % columns
			local row = floor((j - 1) / columns)
			tinsert(section.buttonPositions, {col * buttonOffset, -row * buttonOffset})
		end

		if not sectionFrame then
			sectionFrame = CreateFrame("Frame", "$parentSection"..i, f.holderFrame)
			sectionFrame.header = CreateFrame("Button", "$parentSection"..i.."Header", sectionFrame, "UIPanelButtonTemplate")
			sectionFrame.header:SetNormalTexture(nil)
			sectionFrame.header:SetPushedTexture(nil)
			sectionFrame.header:SetHighlightTexture(nil)

			sectionFrame.header.highlight = CreateFrame("Frame", nil, sectionFrame)
			sectionFrame.header.highlight:SetFrameLevel(999)
			sectionFrame.header.highlight:SetAllPoints()
			sectionFrame.header.highlight:Hide()

			sectionFrame.header.highlight.tex = sectionFrame.header.highlight:CreateTexture(nil, "BACKGROUND")
			sectionFrame.header.highlight.tex:Point("TOPLEFT", sectionFrame.header, "TOPLEFT")
			sectionFrame.header.highlight.tex:Point("BOTTOMRIGHT", sectionFrame, "BOTTOMRIGHT")
			sectionFrame.header.highlight.tex:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			sectionFrame.header.highlight.tex:SetBlendMode("ADD")
			sectionFrame.header.highlight.tex:SetDesaturated(true)
			sectionFrame.header.highlight.tex:SetAlpha(0.1)

			sectionFrame.header.highlight.tex2 = sectionFrame.header.highlight:CreateTexture(nil, "BACKGROUND")
			sectionFrame.header.highlight.tex2:Point("TOPLEFT", sectionFrame.header, "TOPLEFT")
			sectionFrame.header.highlight.tex2:Point("BOTTOMRIGHT", sectionFrame.header, "BOTTOMRIGHT")
			sectionFrame.header.highlight.tex2:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			sectionFrame.header.highlight.tex2:SetBlendMode("ADD")
			sectionFrame.header.highlight.tex2:SetVertexColor(0, 0.5, 0)

			sectionFrame.header:SetScript("OnDoubleClick", function()
				local layout = f.currentLayout
				local currentSection = f.currentLayout.sections[sectionFrame.order]
				currentSection.db.minimized = not currentSection.db.minimized
				if not currentSection.db.minimized then
					sectionFrame.minimizedLine:Hide()
					sectionFrame.title:SetText(currentSection.db.title.text)
					for _, button in ipairs(currentSection.buttons) do
						local rarity = button.rarity or select(3,GetItemInfo(button.itemID or B_GetItemID(nil, button.bagID, button.slotID)))
						if layout.filter[rarity] then
							button.isHidden = false
							button:Show()
						end
					end
				else
					sectionFrame.minimizedLine:Show()
					sectionFrame:Height(1)
				end
				self:UpdateSection(f, currentSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing, true)
			end)
			sectionFrame.header:SetScript("OnReceiveDrag", function()
				if f.draggedButton then
					f.draggedButton.atHeader = f.currentLayout.sections[sectionFrame.order]
					ClearCursor()
					f.draggedButton = nil
				end
			end)
			sectionFrame.header:SetScript("OnMouseDown", function()
				if f.draggedButton then
					f.draggedButton.atHeader = f.currentLayout.sections[sectionFrame.order]
					ClearCursor()
					f.draggedButton = nil
				end
			end)
			sectionFrame.header:SetScript("OnEnter", function(self)
				local cursorInfo = GetCursorInfo()
				if cursorInfo == 'item' or cursorInfo == 'merchant' then
					local emptyButton
					local currentSection = f.currentLayout.sections[sectionFrame.order]
					if removingBag then
						for button in pairs(buttonMap[f]) do
							if button.bagID ~= removingBag then
								emptyButton = button
								break
							end
						end
					elseif currentSection.db.isSpecialBag then
						self.prevEmptySlotsSelection = f.emptyButton.emptySlotsSelection
						emptyButton = mod:FindEmpty(nil, f, currentSection.db.bagID)
						mod:UpdateEmptyButtonCount(f, false)
					else
						emptyButton = next(buttonMap[f])
					end
					if emptyButton then
						self.highlight.tex2:SetVertexColor(0, 0.5, 0)
						self:SetFrameLevel(1)

						emptyButton.atHeader = currentSection
						emptyButton:SetAllPoints(self)
						emptyButton:SetAlpha(0)
						emptyButton:Show()
					elseif f.draggedButton then
						self.shouldFade = true
						self.highlight.tex2:SetVertexColor(0, 0.5, 0)
						E:UIFrameFadeIn(self.highlight, 0.2, self.highlight:GetAlpha(), 1)
					else
						self.shouldFade = true
						self.highlight.tex2:SetVertexColor(0.5, 0, 0)
						E:UIFrameFadeIn(self.highlight, 0.2, self.highlight:GetAlpha(), 1)
					end
				end
			end)
			sectionFrame.header:SetScript("OnLeave", function(self)
				if self.shouldFade then
					self.shouldFade = false
					E:UIFrameFadeOut(self.highlight, 0.2, self.highlight:GetAlpha(), 0)
					if self.prevEmptySlotsSelection then
						f.emptyButton.emptySlotsSelection = self.prevEmptySlotsSelection
						self.prevEmptySlotsSelection = nil
						mod:UpdateEmptyButtonCount(f, true)
					end
				end
			end)

			sectionFrame.minimizedLine = sectionFrame:CreateTexture(nil, "OVERLAY")
			sectionFrame.minimizedLine:Point("TOPLEFT", sectionFrame, "TOPLEFT")
			sectionFrame.minimizedLine:Point("TOPRIGHT", sectionFrame, "TOPRIGHT")
			sectionFrame.minimizedLine:Height(1)
		end

		if not section.minimized then
			sectionFrame.minimizedLine:Hide()
		else
			sectionFrame.minimizedLine:Show()
		end
		sectionFrame.order = i
		sectionFrame:Width(section.numColumns * (buttonSize + buttonSpacing) - buttonSpacing)

		local storedPositions = section.storedPositions
		local processedSection = {
			frame = sectionFrame,
			buttons = {},
			db = section,
		}
		updateSortMethods(processedSection)
		updateCollectionMethods(processedSection)

		if section.isSpecialBag then
            local bagID = section.bagID
            local buttonsSpecial = specialButtons[bagID]
            tsort(buttonsSpecial, function(a, b)
                return (storedPositions[a.bagID..'-'..a.slotID] or 999) < (storedPositions[b.bagID..'-'..b.slotID] or 999)
            end)
            for _, button in ipairs(buttonsSpecial) do
				if button.hasItem then
					local itemID = B_GetItemID(nil, bagID, button.slotID)
					button.itemID = itemID
					tinsert(processedSection.buttons, button)
					section.storedPositions[bagID..'-'..button.slotID] = #processedSection.buttons
				else
					button.itemID = false
					button:Hide()
				end
				buttonMap[bagID][button.slotID] = processedSection
            end
        elseif section.shouldPopulate then
			local reserved = {}
			for j, button in ipairs(buttons) do
				local bagID, slotID = button.bagID, button.slotID
				local hash = bagID..'-'..slotID
				local _, pass = self:EvaluateItem({processedSection}, bagID, slotID, button.itemID or B_GetItemID(nil, bagID, slotID))
				if pass or i == #sections then
					tinsert(reserved, {index = j, hash = hash})
					tinsert(processedSection.buttons, button)
					buttonMap[bagID][slotID] = processedSection
					section.storedPositions[hash] = #processedSection.buttons
				elseif section.storedPositions[hash] then
					section.storedPositions[hash] = nil
				end
			end
			tsort(reserved, function(a,b) return a.index > b.index end)
			for _, info in ipairs(reserved) do
				tremove(buttons, info.index)
				for _, otherSection in ipairs(sections) do
					if otherSection ~= section then
						local removedPos = otherSection.storedPositions[info.hash]
						if removedPos then
							otherSection.storedPositions[info.hash] = nil
							for hash, pos in pairs(otherSection.storedPositions) do
								if pos > removedPos then
									otherSection.storedPositions[hash] = pos - 1
								end
							end
						end
					end
				end
			end
			section.shouldPopulate = nil
		else
			local reserved = {}
			local buttonsWithPos = {}
			for j, button in ipairs(buttons) do
				local bagID, slotID = button.bagID, button.slotID
				local pos = storedPositions[bagID..'-'..slotID]
				if pos then
					tinsert(reserved, j)
					tinsert(buttonsWithPos, {button = button, pos = pos, bagID = bagID, slotID = slotID})
				end
			end
			tsort(buttonsWithPos, function(a, b) return a.pos < b.pos end)
			for _, data in ipairs(buttonsWithPos) do
				tinsert(processedSection.buttons, data.button)
				buttonMap[data.bagID][data.slotID] = processedSection
			end

			tsort(reserved, function(a,b) return a > b end)
			for _, index in ipairs(reserved) do
				tremove(buttons, index)
			end
		end

		sectionFrame.title = sectionFrame.title or sectionFrame:CreateFontString(nil, "OVERLAY")
		sectionFrame.title:SetFont(LSM:Fetch('font', section.title.font), section.title.size, section.title.flags)
		sectionFrame.title:SetText(section.title.text)
		sectionFrame.title:SetTextColor(unpack(section.title.color))
		sectionFrame.title:SetJustifyH(section.title.justify or "LEFT")
		sectionFrame.title:Show()
		sectionFrame.title:ClearAllPoints()

		sectionFrame.header:ClearAllPoints()
		sectionFrame.header:Point("BOTTOMLEFT", sectionFrame, "TOPLEFT", 0, section.title.yOffset)
		sectionFrame.header:Point("BOTTOMRIGHT", sectionFrame, "TOPRIGHT", 0, section.title.yOffset)
		sectionFrame.header:Size(section.title.size)

		sectionFrame.minimizedLine:SetTexture(unpack(section.title.color))

		if section.icon.enabled then
			sectionFrame.icon = sectionFrame.icon or sectionFrame:CreateTexture(nil, "OVERLAY")
			sectionFrame.icon:SetTexture(section.icon.texture)
			sectionFrame.icon:Size(section.icon.size, section.icon.size)
			sectionFrame.icon:Show()
			sectionFrame.icon:ClearAllPoints()
			if section.icon.toText then
				sectionFrame.icon:Point(section.icon.point, sectionFrame.title, section.icon.relativeTo, section.icon.xOffset, section.icon.yOffset)
				sectionFrame.title:Point("BOTTOMLEFT", sectionFrame, "TOPLEFT", section.title.xOffset, section.title.yOffset)
				sectionFrame.title:Point("BOTTOMRIGHT", sectionFrame, "TOPRIGHT", 0, section.title.yOffset)
			elseif section.title.toIcon then
				sectionFrame.title:Point(section.title.point, sectionFrame.icon, section.title.relativeTo, section.title.xOffset, section.title.yOffset)
				sectionFrame.title:Point("BOTTOMRIGHT", sectionFrame, "TOPRIGHT", 0, section.title.yOffset)
				sectionFrame.icon:Point("BOTTOMLEFT", sectionFrame, "TOPLEFT", section.icon.xOffset, section.icon.yOffset)
			end
			minIconLeft = min(minIconLeft, section.icon.xOffset)
		else
			if sectionFrame.icon then
				sectionFrame.icon:Hide()
				sectionFrame.icon = nil
			end
			sectionFrame.title:Point("BOTTOMLEFT", sectionFrame, "TOPLEFT", section.title.xOffset, section.title.yOffset)
			sectionFrame.title:Point("BOTTOMRIGHT", sectionFrame, "TOPRIGHT", -buttonSpacing, section.title.yOffset)
		end

		tinsert(processedSections, processedSection)
	end

	for _, button in ipairs(buttons) do
		local bagID, slotID = button.bagID, button.slotID
		local targetSection = self:EvaluateItem(processedSections, bagID, slotID, button.itemID or B_GetItemID(nil, bagID, slotID))
		tinsert(targetSection.buttons, button)
		buttonMap[bagID][slotID] = targetSection
		targetSection.db.storedPositions[bagID..'-'..slotID] = #targetSection.buttons
	end

	while #sections < #layoutSections do
		local section = layoutSections[#layoutSections]
		for _, button in ipairs(section.buttons) do
			if button.highlight then
				button.highlight:Hide()
				button.highlight = nil
			end
		end
		local frame = section.frame
		if frame then
			frame:Hide()
			section.frame = nil
		end
		tremove(layoutSections, #layoutSections)
	end

	if not db.activeFilters then
		db.activeFilters = {
			[0] = true, [1] = true, [2] = true,
			[3] = true, [4] = true, [5] = true, [6] = true,
		}
	end

    f.currentLayout = {
        sections = processedSections,
		numColumns = numColumns,
		maxButtons = maxButtons,
        buttonSize = buttonSize,
        buttonSpacing = buttonSpacing,
		filter = db.activeFilters,
    }

	for i = -1, NUM_BANKBAGSLOTS do
		local holder = f.ContainerHolder[i]
		if holder and i ~= 0 then
			for script, val in pairs({["OnDragStart"] = true, ["OnDragStop"] = false}) do
				if not self:IsHooked(holder, script) then
					self:SecureHookScript(holder, script, function()
						removingBag = val and i - 1
					end)
				end
			end
			if not self:IsHooked(holder, "OnEnter") then
				self:SecureHookScript(holder, "OnEnter", function(self)
					holderTT:SetTemplate()
					holderTT:SetOwner(holder, "ANCHOR_RIGHT")
					holderTT:AddLine(L["Alt-Click: free bag slots, if possible."])
					holderTT:Show()
				end)
			end
			if not self:IsHooked(holder, "OnLeave") then
				self:SecureHookScript(holder, "OnLeave", function(self)
					holderTT:Hide()
				end)
			end
			if not self:IsHooked(holder, "OnMouseDown") then
				self:SecureHookScript(holder, "OnMouseDown", function(self)
					if IsAltKeyDown() then
						if InCombatLockdown() then
							print(core.customColorBad..ERR_NOT_IN_COMBAT)
							return
						end
						local bagID = self.id
						local bag = f.Bags[bagID]
						if bag and bag.numSlots > 0 then
							local heldButtons, emptyButtons = {}, {}
							for slotID = 1, GetContainerNumSlots(bagID) do
								local button = bag[slotID]
								if button and button.hasItem then
									tinsert(heldButtons, button)
								end
							end
							for button in pairs(buttonMap[f]) do
								if button.bagID ~= bagID then
									tinsert(emptyButtons, button)
								end
							end
							if #heldButtons > 0 and #emptyButtons > 0 then
								self.elapsed = 0
								self:SetScript("OnUpdate", function(self, elapsed)
									self.elapsed = self.elapsed + elapsed
									if self.elapsed > 0.1 then
										local held = tremove(heldButtons)
										local empty = tremove(emptyButtons)
										B_PickupItem(nil, held.bagID, held.slotID)
										B_PickupItem(nil, empty.bagID, empty.slotID)
										if #heldButtons == 0 or #emptyButtons == 0 then
											self:SetScript("OnUpdate", nil)
										end
									end
								end)
							end
						end
					end
				end)
			end
			if not self:IsHooked(holder, "OnHide") then
				self:SecureHookScript(holder, "OnHide", function(self)
					self:SetScript("OnUpdate", nil)
				end)
			end
		end
	end

	if not isBank then
		if not f.heldCurrencies then
			f.heldCurrencies = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
			f.heldCurrencies:SetAllPoints(f.goldText)
			f.heldCurrencies:SetAlpha(0)
			f.heldCurrencies:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:SetText(CURRENCY..":")

				local numCurrencies = GetCurrencyListSize()
				local hasCurrencies = false

				local lines = {}
				for i = 1, numCurrencies do
					local _, isHeader, _, _, _, count, _, icon, itemID = GetCurrencyListInfo(i)
					if not isHeader and count > 0 then
						if itemID == 43307 then
							icon = "Interface\\PVPFrame\\PVP-ArenaPoints-Icon"
						elseif itemID == 43308 then
							icon = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player")
						end
						hasCurrencies = true
						local name, _, quality = GetItemInfo(itemID)
						local r, g, b = GetItemQualityColor(quality)
						local iconString = "|T" .. icon .. ":0|t "
						local countText = count
						local pvpCurrency = itemID == 43307 or itemID == 43308
						local emblem = itemID == 40752 or itemID == 40753 or itemID == 45624 or itemID == 47241 or itemID == 49426
						tinsert(lines, {
								emblem = emblem,
								pvpCurrency = pvpCurrency,
								quality = quality,
								name = name,
								lineL = iconString..name,
								lineR = countText,
								r = r,
								g = g,
								b = b,
							}
						)
					end
				end
				if not hasCurrencies then
					GameTooltip:SetText(EMPTY)
				else
					tsort(lines, function(a, b)
						if a.emblem ~= b.emblem then return a.emblem
						elseif a.pvpCurrency and not b.pvpCurrency then return false
						elseif a.quality ~= b.quality then return a.quality > b.quality
						else return a.name < b.name
						end
					end)
					for i, info in ipairs(lines) do
						if i > 1 then
							if not info.emblem and lines[i-1].emblem then GameTooltip:AddLine(" ") end
							if info.pvpCurrency and not lines[i-1].pvpCurrency then GameTooltip:AddLine(" ") end
						end
						GameTooltip:AddDoubleLine(info.lineL, info.lineR, info.r, info.g, info.b, 1, 1, 1)
					end
				end
				GameTooltip:Show()
			end)
			f.heldCurrencies:SetScript("OnLeave", GameTooltip_Hide)
		else
			f.heldCurrencies:Show()
		end
	end

	if not f.emptyButton then
		f.emptyButton = CreateFrame("Button", '$parentEmptyButton', f, "UIPanelButtonTemplate")
		f.emptyButton:Size(24)
		f.emptyButton:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", 0, 6)
		f.emptyButton.showEmptySections = false
		f.emptyButton.hideHints = db.hideHints
		f.emptyButton:EnableMouseWheel(true)

		f.emptyButton.eyeTex = f.emptyButton:CreateTexture(nil, "OVERLAY")
		f.emptyButton.eyeTex:Point("BOTTOMRIGHT", f.emptyButton, "BOTTOMRIGHT")
		f.emptyButton.eyeTex:SetTexture("Interface\\LFGFrame\\LFG-Eye")
		f.emptyButton.eyeTex:Size(16)
		f.emptyButton.eyeTex:SetTexCoord(0, 0.1, 0, 0.20)
		f.emptyButton.eyeTex:Hide()

		f.emptyButton.highlight = CreateFrame("Frame", nil, f.emptyButton)
		f.emptyButton.highlight:SetFrameLevel(999)
		f.emptyButton.highlight:Point("CENTER", f.emptyButton, "CENTER")
		f.emptyButton.highlight:Size(30)
		f.emptyButton.highlight:Hide()

		f.emptyButton.highlight.tex = f.emptyButton.highlight:CreateTexture(nil, "OVERLAY")
		f.emptyButton.highlight.tex:Point("TOPLEFT", f.emptyButton.highlight, "TOPLEFT")
		f.emptyButton.highlight.tex:Point("BOTTOMRIGHT", f.emptyButton.highlight, "BOTTOMRIGHT")
		f.emptyButton.highlight.tex:SetBlendMode("ADD")

		f.emptyButton.normalTex = f.emptyButton:CreateTexture(nil, "ARTWORK")
		f.emptyButton.normalTex:SetTexture("Interface\\Minimap\\Tracking\\Banker")
		f.emptyButton.normalTex:Point("CENTER")
		f.emptyButton.normalTex:Size(24)

		f.emptyButton.pushedTex = f.emptyButton:CreateTexture(nil, "ARTWORK")
		f.emptyButton.pushedTex:SetTexture("Interface\\Minimap\\Tracking\\Banker")
		f.emptyButton.pushedTex:Point("CENTER")
		f.emptyButton.pushedTex:Size(24)

		f.emptyButton.highlightTex = f.emptyButton:CreateTexture(nil, "ARTWORK")
		f.emptyButton.highlightTex:SetTexture("Interface\\Minimap\\Tracking\\Banker")
		f.emptyButton.highlightTex:Point("CENTER")
		f.emptyButton.highlightTex:SetAlpha(0.25)
		f.emptyButton.highlightTex:Size(24)

		f.emptyButton:SetNormalTexture(f.emptyButton.normalTex)
		f.emptyButton:SetPushedTexture(f.emptyButton.pushedTex)
		f.emptyButton:SetHighlightTexture(f.emptyButton.highlightTex)

		f.emptyButton.emptySlotsText = f.emptyButton:CreateFontString(nil, "OVERLAY")
		f.emptyButton.emptySlotsText:Point("BOTTOMLEFT", f.emptyButton.totalEmptySlotsText, "BOTTOMLEFT")
		f.emptyButton.emptySlotsText:FontTemplate()
		local empty = 0
		for _ in pairs(buttonMap[f]) do
			empty = empty + 1
		end
		f.emptyButton.emptySlotsText:SetText(empty)

		f.emptyButton.emptySlotsSelection = 0
		f.emptyButton:SetScript("OnMouseWheel", function(self)
			mod:UpdateEmptyButtonCount(f)
			self:GetScript("OnEnter")(self)
		end)
		f.emptyButton:SetScript("OnReceiveDrag", function(self)
			if f.draggedButton then
				f.draggedButton.atHeader = 'evaluate'
				ClearCursor()
				f.draggedButton = nil
			end
		end)
		f.emptyButton:SetScript("OnEnter", function(self)
			local cursorInfo = GetCursorInfo()
			if cursorInfo == 'item' or cursorInfo == 'merchant' then
				local _, itemID, itemLink
				if cursorInfo == 'item' then
					_, _, itemLink = GetCursorInfo()
				else
					_, itemID = GetCursorInfo()
					itemLink = GetMerchantItemLink(itemID)
				end

				if itemLink then
					local emptyButton
					if removingBag then
						for button in pairs(buttonMap[f]) do
							if button.bagID ~= removingBag then
								emptyButton = button
								break
							end
						end
					elseif self.emptySlotsSelection ~= 0 then
						emptyButton = mod:FindEmpty(nil, f, self.emptySlotsSelection)
					else
						emptyButton = next(buttonMap[f])
					end
					if emptyButton then
						self.highlight.tex:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
						self.highlight.tex:SetVertexColor(0, 1, 0)
						self.highlight:SetFrameLevel(f.emptyButton:GetFrameLevel())

						emptyButton.atHeader = 'evaluate'
						emptyButton:SetAllPoints(self)
						emptyButton:SetAlpha(0)
						emptyButton:Show()
					elseif f.draggedButton then
						self.highlight.shouldFade = true
						self.highlight.tex:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
						self.highlight.tex:SetVertexColor(0, 1, 0)
						E:UIFrameFadeIn(self.highlight, 0.2, self.highlight:GetAlpha(), 1)
					else
						self.highlight.shouldFade = true
						self.highlight.tex:SetTexture("Interface\\Buttons\\UI-GROUPLOOT-PASS-HIGHLIGHT")
						self.highlight.tex:SetVertexColor(1, 0, 0)
						E:UIFrameFadeIn(self.highlight, 0.2, self.highlight:GetAlpha(), 1)
					end
				end
			end
			showEmptyButtonTT(f)
		end)
		f.emptyButton.highlight:SetScript("OnLeave", function(self)
			if self.shouldFade then
				self.shouldFade = false
				E:UIFrameFadeOut(self.highlight, 0.2, self.highlight:GetAlpha(), 0)
			end
		end)
		f.emptyButton:SetScript("OnLeave", function(self)
			if self.highlight.shouldFade then
				self.highlight.shouldFade = false
				E:UIFrameFadeOut(self.highlight, 0.2, self.highlight:GetAlpha(), 0)
			end
			GameTooltip_Hide()
		end)
		f.emptyButton:SetScript("OnMouseUp", function(self)
			self:ClearAllPoints()
			self:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", 0, 6)
		end)
		f.emptyButton:SetScript("OnMouseDown", function(self)
			self:ClearAllPoints()
			self:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", 1, 5)
			local draggingItem = GetCursorInfo()
			if f.draggedButton then
				f.draggedButton.atHeader = 'evaluate'
				ClearCursor()
				f.draggedButton = nil
			end
			local layout = f.currentLayout
			if IsAltKeyDown() then
				if IsShiftKeyDown() then
					f.emptyButton.hideHints = not f.emptyButton.hideHints
					db.hideHints = f.emptyButton.hideHints
					showEmptyButtonTT(f)
				elseif not draggingItem then
					for _, section in ipairs(layout.sections) do
						section.db.storedPositions = {}
					end
					mod:Layout(B, f.isBank)
					mod:SortAllSections(f)
				end
			elseif not draggingItem then
				self.showEmptySections = not self.showEmptySections
				self.showSizing = not self.showSizing
				mod:ToggleLayoutMode(f, self.showSizing)
				if self.showEmptySections then
					f.emptyButton.eyeTex:Show()
					for i, section in ipairs(layout.sections) do
						f.forceShow = true
						db.forceShow = true
						mod:UpdateSection(f, section, layout.numColumns, layout.buttonSize, layout.buttonSpacing, i == #layout.sections)
					end
				else
					f.emptyButton.eyeTex:Hide()
					for i, section in ipairs(layout.sections) do
						f.forceShow = false
						db.forceShow = false
						mod:UpdateSection(f, section, layout.numColumns, layout.buttonSize, layout.buttonSpacing, i == #layout.sections)
					end
				end
				E:StopFlash(self.highlight)
				E:UIFrameFadeOut(self.highlight, 1, self.highlight:GetAlpha(), 0)
			end
		end)
	end

	if not f.qualityFilterBar then
		f.qualityFilterBar = CreateFrame("Frame", '$parentQualityFilterBar', f)
		f.qualityFilterBar:Point("BOTTOMLEFT", f.holderFrame, "BOTTOMLEFT")
		f.qualityFilterBar:Point("BOTTOMRIGHT", f.holderFrame, "BOTTOMRIGHT")
		f.qualityFilterBar:Height(5)

		if not isBank then
			f.currencyButton:ClearAllPoints()
			f.currencyButton:Point("TOPLEFT", f.qualityFilterBar, "BOTTOMLEFT", 0, db.qualityFilterShown and 28 or 18)
			f.currencyButton:Point("TOPRIGHT", f.qualityFilterBar, "BOTTOMRIGHT", 0, db.qualityFilterShown and 28 or 18)
		end

		local barWidth = (((buttonSize + buttonSpacing) * numColumns) - buttonSpacing - 30)/7
		for i = 6, 0, -1 do
			local color = ITEM_QUALITY_COLORS[i]
			local bar = CreateFrame("Button", nil, f.qualityFilterBar)
			bar:Size(barWidth, 5)
			bar:Point("TOPLEFT", f.qualityFilterBar, "TOPLEFT", i * (barWidth+5), 0)
			bar:CreateBackdrop()
			bar:StyleButton()
			bar:RegisterForClicks("LeftButtonDown", "RightButtonDown")
			bar.isActive = db.activeFilters[i]
			bar.quality = i

			if not db.qualityFilterShown then
				bar:Hide()
			end

			bar.bg = bar:CreateTexture(nil, "ARTWORK")
			bar.bg:SetAllPoints(bar)
			if not bar.isActive then
				bar.bg:SetTexture(color.r * 0.5, color.g * 0.5, color.b * 0.5)
			else
				bar.bg:SetTexture(color.r, color.g, color.b)
			end

			bar:SetScript("OnClick", function(self, clickButton)
				local layout = f.currentLayout
				if clickButton == "RightButton" then
					for j = 0, 6 do
						local filterBar = f.qualityFilterBar[j+1]
						if filterBar then
							local filterColor = ITEM_QUALITY_COLORS[j]
							if filterBar == self then
								filterBar.bg:SetTexture(filterColor.r, filterColor.g, filterColor.b)
								filterBar.isActive = true
								db.activeFilters[j] = true
							else
								filterBar.bg:SetTexture(filterColor.r * 0.5, filterColor.g * 0.5, filterColor.b * 0.5)
								filterBar.isActive = false
								db.activeFilters[j] = false
							end
						end
					end
					for j, section in ipairs(f.currentLayout.sections) do
						for _, button in ipairs(section.buttons) do
							local rarity = button.rarity or select(3,GetItemInfo(button.itemID or B_GetItemID(nil, button.bagID, button.slotID)))
							button.isHidden = (rarity ~= i)
							if button.isHidden then
								button:Hide()
							else
								button:Show()
							end
						end
						mod:UpdateSection(f, section, layout.numColumns, layout.buttonSize, layout.buttonSpacing, j == #layout.sections)
					end
				elseif self.isActive then
					self.bg:SetTexture(color.r * 0.5, color.g * 0.5, color.b * 0.5)
					self.isActive = false
					db.activeFilters[i] = false
					for j, section in ipairs(f.currentLayout.sections) do
						for _, button in ipairs(section.buttons) do
							local rarity = button.rarity or select(3,GetItemInfo(button.itemID or B_GetItemID(nil, button.bagID, button.slotID)))
							if rarity == i then
								button.isHidden = true
								button:Hide()
							end
						end
						mod:UpdateSection(f, section, layout.numColumns, layout.buttonSize, layout.buttonSpacing, j == #layout.sections)
					end
				else
					self.bg:SetTexture(color.r, color.g, color.b)
					self.isActive = true
					db.activeFilters[i] = true
					for j, section in ipairs(f.currentLayout.sections) do
						for _, button in ipairs(section.buttons) do
							local rarity = button.rarity or select(3,GetItemInfo(button.itemID or B_GetItemID(nil, button.bagID, button.slotID)))
							if rarity == i then
								button.isHidden = false
								button:Show()
							end
						end
						mod:UpdateSection(f, section, layout.numColumns, layout.buttonSize, layout.buttonSpacing, j == #layout.sections)
					end
				end
			end)
			f.qualityFilterBar[i+1] = bar
		end
		f.qualityFilterButton = CreateFrame("Button", '$parentQualityFilterButton', f.holderFrame)
		f.qualityFilterButton:Size(16 + E.Border)
		f.qualityFilterButton:SetTemplate()
		f.qualityFilterButton:Point("RIGHT", isBank and f.purchaseBagButton or f.vendorGraysButton, "LEFT", -5, 0)
		f.qualityFilterButton:SetNormalTexture("Interface\\Icons\\INV_Misc_Gear_01")
		f.qualityFilterButton:GetNormalTexture():SetTexCoord(unpack(E.TexCoords))
		f.qualityFilterButton:GetNormalTexture():SetInside()
		f.qualityFilterButton:SetPushedTexture("Interface\\Icons\\INV_Misc_Gear_01")
		f.qualityFilterButton:GetPushedTexture():SetTexCoord(unpack(E.TexCoords))
		f.qualityFilterButton:GetPushedTexture():SetInside()
		f.qualityFilterButton:StyleButton(nil, true)
		f.qualityFilterButton.ttText = FILTERS
		f.qualityFilterButton:SetScript("OnEnter", B.Tooltip_Show)
		f.qualityFilterButton:SetScript("OnLeave", GameTooltip_Hide)
		f.qualityFilterButton:SetScript("OnClick", function(self)
			if db.qualityFilterShown then
				for _, bar in ipairs(f.qualityFilterBar) do
					bar:Hide()
				end
				f.currencyButton:ClearAllPoints()
				f.currencyButton:Point("TOPLEFT", f.qualityFilterBar, "BOTTOMLEFT", 0, 18)
				f.currencyButton:Point("TOPRIGHT", f.qualityFilterBar, "BOTTOMRIGHT", 0, 18)
				f.newbottomOffset = db.bottomOffset or 0
			else
				for _, bar in ipairs(f.qualityFilterBar) do
					bar:Show()
				end
				f.currencyButton:ClearAllPoints()
				f.currencyButton:Point("TOPLEFT", f.qualityFilterBar, "BOTTOMLEFT", 0, 28)
				f.currencyButton:Point("TOPRIGHT", f.qualityFilterBar, "BOTTOMRIGHT", 0, 28)
				f.newbottomOffset = (db.bottomOffset or 0) + 10
			end
			local layout = f.currentLayout
			mod:UpdateSection(f, layout.sections[#layout.sections], layout.numColumns, layout.buttonSize, layout.buttonSpacing, true)
			db.qualityFilterShown = not db.qualityFilterShown
		end)
	else
		local barWidth = (((buttonSize + buttonSpacing) * numColumns) - buttonSpacing - 30)/7
		for i, bar in ipairs(f.qualityFilterBar) do
			bar:Width(barWidth)
			bar:ClearAllPoints()
			bar:Point("TOPLEFT", f.qualityFilterBar, "TOPLEFT", (i - 1) * (barWidth+5), 0)
		end
	end

	f.editBox:ClearAllPoints()
	if (isBank and B.db.bankWidth or B.db.bagWidth) < 250 then
		if not isBank then
			f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", E.Border * 2 + 18, E.Border * 2 - 32)
			f.editBox:Point("TOPRIGHT", f.sortButton, "BOTTOMRIGHT", 0, -E.Border * 2 - 2)
			f.sortButton:ClearAllPoints()
			f.sortButton:Point("TOPRIGHT", f.goldText, "BOTTOMRIGHT", 0, -E.Border * 2)
		else
			f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", E.Border * 2 + 18, E.Border * 2 - 32)
			f.editBox:Point("TOPRIGHT", f.sortButton, "BOTTOMRIGHT", 0, -E.Border * 2 - 2)
			f.sortButton:ClearAllPoints()
			f.sortButton:Point("TOPRIGHT", f.bagText, "BOTTOMRIGHT", 0, -E.Border * 2)
		end
	else
		f.editBox:Point("BOTTOMLEFT", f.holderFrame, "TOPLEFT", E.Border * 2 + 48, E.Border * 2 + 2 + E.Border)
		f.editBox:Point("TOPRIGHT", f.qualityFilterButton, "TOPLEFT", -5, -2)
		if not isBank then
			f.sortButton:ClearAllPoints()
			f.sortButton:Point("RIGHT", f.goldText, "LEFT", -5, E.Border * 2)
		else
			f.sortButton:ClearAllPoints()
			f.sortButton:Point("RIGHT", f.bagText, "LEFT", -5, E.Border * 2)
		end
	end

	local offset1, offset2 = 8
	if minIconLeft < 0 then
		offset2 = offset1 - minIconLeft
	end

	f.holderFrame:ClearAllPoints()
	f.holderFrame:Point("TOPLEFT", f, "TOPLEFT", offset2 or offset1, -f.topOffset+(buttonSize/4))
	f.holderFrame:Point("BOTTOMRIGHT", f, "BOTTOMRIGHT", -offset1, 8)

	f:Width(numColumns * (buttonSize + buttonSpacing) + (offset2 or offset1) * 2 - buttonSpacing)

	for _, section in ipairs(f.currentLayout.sections) do
		for _, button in ipairs(section.buttons) do
			local rarity = button.rarity or select(3,GetItemInfo(button.itemID or B_GetItemID(nil, button.bagID, button.slotID)))
			if not f.currentLayout.filter[rarity] then
				button.isHidden = true
				button:Hide()
			else
				button.isHidden = nil
				button:Show()
			end
		end
		self:UpdateSection(f, section, numColumns, buttonSize, buttonSpacing)
	end

	self:ToggleLayoutMode(f, f.emptyButton.showSizing)
	self:UpdateEmptyButtonCount(f, true)
end

function mod:Layout(self, isBank)
    if not E.private.bags.enable then return end
    local f = B_GetContainerFrame(nil, isBank)
    if not f then return end

	if not f.SplitStackHandler then
		f.SplitStackHandler = CreateFrame("Frame", nil, f)
		f.SplitStackHandler:SetScript("OnHide", function(self)
			self.isStacking = false
			self:SetScript("OnUpdate", nil)
		end)
	end
	for _, bagID in ipairs(f.BagIDs) do
		local bag = f.Bags[bagID]
		if bag then
			for slotID = 1, bag.numSlots do
				local button = bag[slotID]
				if button then
					for _, info in pairs(mod.localhooks) do
						for event in pairs(info) do
							if not mod:IsHooked(button, event) then
								mod:SecureHookScript(button, event, function(self, ...) runAllScripts(self, event, ...) end)
							end
						end
					end
				end
			end
		end
	end

	if not E.db.Extras.general[modName].BagsExtendedV2.enabled then return end
	local db = E.db.Extras.general[modName].BagsExtendedV2.containers[isBank and 'bank' or 'bags']

	local buttonSpacing = db.buttonSpacing or E.Border * 2
	local buttonSize = isBank and B.db.bankSize or B.db.bagSize
	local numColumns = floor((isBank and B.db.bankWidth or B.db.bagWidth) / (buttonSize + buttonSpacing))

	if db.qualityFilterShown then
		f.newbottomOffset = (db.bottomOffset or 0) + 10
	else
		f.newbottomOffset = db.bottomOffset or 0
	end
	if (isBank and B.db.bankWidth or B.db.bagWidth) < 250 then
		f.newtopOffset = (db.topOffset or 0) + 42
	else
		f.newtopOffset = db.topOffset or 0
	end

	updateSetsInfo()
	mod:ConfigureContainer(f, isBank, db, numColumns, buttonSize, buttonSpacing)
end

function mod:UpdateSlot(self, f, bagID, slotID)
	local bag = f.Bags[bagID]
	local bagMap = buttonMap[bagID]

	if not bag or not bag[slotID] or not bagMap or (bag.numSlots ~= GetContainerNumSlots(bagID)) then return end

	local layout = f.currentLayout
    local button = bag[slotID]
	local bagType = bag.type

	if not button.hasItem then
		button:Hide()
		local itemID = button.itemID
		if itemID then
			button.itemID = nil
			local currentSection = bagMap[slotID]
			if currentSection then
				if not bagType or bagType == 0 then
					buttonMap[f][button] = true
					bagMap[slotID] = nil
				end
				mod:UpdateButtonPositions(button, bagMap, bagID, slotID, currentSection)
				mod:UpdateSection(f, currentSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
			end
			mod:UpdateEmptyButtonCount(f, true)
		end
	else
		local oldID = button.itemID
		local itemID = B_GetItemID(nil, bagID, slotID)

		if button.shouldEvaluate then
			local currentSection = bagMap[slotID]
			local targetSection = mod:EvaluateItem(layout.sections, bagID, slotID, itemID)

			mod:UpdateButtonPositions(button, bagMap, bagID, slotID, currentSection, targetSection)
			if currentSection then
				mod:UpdateSection(f, currentSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
			end

			if not layout.filter[button.rarity or select(3,GetItemInfo(itemID))] then
				button:Hide()
			else
				button.isHidden = nil
				mod:UpdateSection(f, targetSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
			end
			button.shouldEvaluate = nil
		elseif button.isHidden then
			button:Hide()
		elseif not oldID then
			local targetSection
			buttonMap[f][button] = nil
			if not button:IsVisible() then
				button.highlight:Show()
			end

			if button.atHeader then
				if button.atHeader == 'evaluate' then
					targetSection = (bagType and bagType ~= 0) and bagMap[slotID] or mod:EvaluateItem(layout.sections, bagID, slotID, itemID)
					f.emptyButton.highlight:SetFrameLevel(999)
					E:UIFrameFadeOut(f.emptyButton.highlight, 0.2, f.emptyButton.highlight:GetAlpha(), 0)
				else
					local header = button.atHeader.frame.header
					targetSection = button.atHeader
					header:SetFrameLevel(999)
					E:UIFrameFadeOut(header.highlight, 0.2, header.highlight:GetAlpha(), 0)
					if header.prevEmptySlotsSelection then
						f.emptyButton.emptySlotsSelection = header.prevEmptySlotsSelection
						header.prevEmptySlotsSelection = nil
					end
				end
				button:SetAlpha(1)
				button.atHeader = false
			else
				targetSection = mod:EvaluateItem(layout.sections, bagID, slotID, itemID)
			end
			mod:UpdateButtonPositions(button, bagMap, bagID, slotID, nil, targetSection)

			local rarity = button.rarity or select(3,GetItemInfo(itemID))
			if not rarity or layout.filter[rarity] then
				mod:UpdateSection(f, targetSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
			else
				button.isHidden = true
				button:Hide()
			end
			mod:UpdateEmptyButtonCount(f, true)
		elseif f.draggedButton == button then
			local currentSection = bagMap[slotID]
			if currentSection and button.atHeader then
				local targetSection
				if button.atHeader == 'evaluate' then
					targetSection = (bagType and bagType ~= 0) and currentSection or mod:EvaluateItem(layout.sections, bagID, slotID, itemID)
					E:UIFrameFadeOut(f.emptyButton.highlight, 0.2, f.emptyButton.highlight:GetAlpha(), 0)
				else
					local header = button.atHeader.frame.header
					targetSection = button.atHeader
					E:UIFrameFadeOut(header.highlight, 0.2, header.highlight:GetAlpha(), 0)
					if header.prevEmptySlotsSelection then
						f.emptyButton.emptySlotsSelection = header.prevEmptySlotsSelection
						header.prevEmptySlotsSelection = nil
					end
				end
				mod:UpdateButtonPositions(button, bagMap, bagID, slotID, currentSection, targetSection)
				mod:UpdateSection(f, currentSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
				mod:UpdateSection(f, targetSection, layout.numColumns, layout.buttonSize, layout.buttonSpacing)
			end
			button.atHeader = nil
		end
		button.itemID = itemID
	end
end

function mod:UpdateSection(f, section, numColumns, buttonSize, buttonSpacing, resize)
    local sectionFrame = section.frame
	local buttons = section.buttons
	local numRows
	local sectionHeight = 1

	if not f.forceShow and #buttons < 1 then
		sectionFrame:Hide()
	elseif section.db.minimized then
		local minimizedCount = 0
		local layoutFilter = f.currentLayout.filter
		for _, button in ipairs(buttons) do
			local rarity = button.rarity or select(3,GetItemInfo(button.itemID or B_GetItemID(nil, button.bagID, button.slotID)))
			if layoutFilter[rarity] and button.highlight:IsShown() then
				minimizedCount = minimizedCount + 1
			end
			button:Hide()
			button.isHidden = true
		end
		sectionFrame.title:SetText(section.db.title.text..(minimizedCount > 0 and " (+" .. minimizedCount .. ")" or ""))
		sectionFrame:Show()
	else
		local pos = 1
		local buttonPos = section.db.buttonPositions
		local isEmpty = true
		for _, button in ipairs(buttons) do
			if not button.isHidden then
				button:ClearAllPoints()
				button:SetPoint("TOPLEFT", section.frame, "TOPLEFT", unpack(buttonPos[pos]))
				pos = pos + 1
				isEmpty = false
			end
		end
		if isEmpty then
			if not f.forceShow then
				sectionFrame:Hide()
			else
				sectionFrame:Show()
			end
		else
			numRows = ceil((pos - 1) / section.db.numColumns)
			sectionHeight = ceil(numRows * (buttonSize + buttonSpacing) - buttonSpacing)
			sectionFrame:Show()
		end
	end

	sectionFrame:Height(sectionHeight)
	sectionFrame.height = sectionHeight

	if resize or numRows ~= (section.numRows or 0) then
		local offsetY = buttonSize/4
		local lastVisibleSection
		local currentRowColumns = 0
		local currentRowBottom = 0

		for _, section in ipairs(f.currentLayout.sections) do
			local sectionFrame = section.frame
			sectionFrame:ClearAllPoints()

			if sectionFrame:IsShown() then
				local sectionHeight = sectionFrame.height or sectionFrame:GetHeight()

				if not lastVisibleSection then
					sectionFrame:Point("TOPLEFT", f.holderFrame, "TOPLEFT", 0, -(offsetY + f.newtopOffset))
					currentRowColumns = section.db.numColumns
					currentRowBottom = offsetY + sectionHeight
				else
					if currentRowColumns + section.db.numColumns <= numColumns then
						sectionFrame:Point("TOPLEFT", lastVisibleSection.frame, "TOPRIGHT", buttonSpacing, 0)
						currentRowColumns = currentRowColumns + section.db.numColumns
						currentRowBottom = max(currentRowBottom, offsetY + sectionHeight)
					else
						offsetY = currentRowBottom + (section.db.sectionSpacing or 14)
						sectionFrame:Point("TOPLEFT", f.holderFrame, "TOPLEFT", 0, -(offsetY + f.newtopOffset))
						currentRowColumns = section.db.numColumns
						currentRowBottom = offsetY + sectionHeight
					end
				end
				lastVisibleSection = section
			end
		end

		if lastVisibleSection then
			f:Height(f.topOffset + f.bottomOffset + f.newtopOffset + f.newbottomOffset + currentRowBottom - buttonSize/4)
		else
			f:Height(f.topOffset + f.bottomOffset + f.newtopOffset + f.newbottomOffset)
		end
		section.numRows = numRows
	end
end

function mod:SetSlotAlphaForBag(self, f)
	for _, section in ipairs(f.currentLayout.sections) do
		local show = false
		for _, button in ipairs(section.buttons) do
			if button:GetAlpha() == 1 then show = true break end
		end
		if show then
			section.frame:SetAlpha(1)
		else
			section.frame:SetAlpha(0.4)
		end
	end
end

function mod:ResetSlotAlphaForBags(self, f)
	for _, section in ipairs(f.currentLayout.sections) do
		section.frame:SetAlpha(1)
	end
end


function mod:BagsExtendedV2(db)
	if db.BagsExtendedV2.enabled then
		self:Unhook(B, 'Layout')
		self:SecureHook(B, 'Layout', function(self, isBank)
			mod:Unhook(B, 'Layout')
			mod:Layout(self, isBank)
			for _, func in ipairs({'Layout', 'UpdateSlot', 'SetSlotAlphaForBag', 'ResetSlotAlphaForBags'}) do
				if not mod:IsHooked(B, func) then mod:SecureHook(B, func) end
			end
		end)
		if not self:IsHooked(E, 'ToggleOptionsUI') then
			self:SecureHook(E, 'ToggleOptionsUI', function()
				if not E.Options.args.bags then
					return
				end
				E:RefreshGUI()
			end)
		end
		if not self:IsHooked("EquipmentManager_EquipSet") then
			self:SecureHook("EquipmentManager_EquipSet", function(setName)
				local locations = GetEquipmentSetLocations(setName)
				if locations then
					for _, location in pairs(locations) do
						if location then
							local _, bank, bags, slot, bag = EquipmentManager_UnpackLocation(location)
							if bank then
								local f = B_GetContainerFrame(nil, true)
								local button = f and f.Bags[-1] and f.Bags[-1][slot-39]
								if button then
									button.shouldEvaluate = true
								end
							elseif bags then
								local f = B_GetContainerFrame(nil, bag < 0 or bag > NUM_BAG_SLOTS)
								local button = f and f.Bags[bag] and f.Bags[bag][slot]
								if button then
									button.shouldEvaluate = true
								end
							end
						end
					end
				end
			end)
		end
		self:UpdateAll()
		self:RegisterEvent("EQUIPMENT_SETS_CHANGED", updateSetsInfo)
		self:RegisterEvent("EQUIPMENT_SWAP_FINISHED", updateSetsInfo)
		self.initialized.BagsExtendedV2 = true
	elseif self.initialized.BagsExtendedV2 then
		for _, func in pairs({'UpdateSlot', 'SetSlotAlphaForBag', 'ResetSlotAlphaForBags'}) do
			if self:IsHooked(B, func) then self:Unhook(B, func) end
		end
		if self:IsHooked(B, 'Layout') and not (db.EasierProcessing.enabled or db.SplitStack.enabled) then
			self:Unhook(B, 'Layout')
		end
		if self:IsHooked(E, 'ToggleOptionsUI') then
			self:Unhook(E, 'ToggleOptionsUI')
		end
		self:UpdateAll(true)
		self:UnregisterEvent("EQUIPMENT_SETS_CHANGED")
		self:UnregisterEvent("EQUIPMENT_SWAP_FINISHED")
		self.initialized.BagsExtendedV2 = false
	end
end


function mod:CreateProcessingButton()
	local ProcessButton = CreateFrame("Button", "ElvUI_ProcessButton", UIParent, "SecureActionButtonTemplate")
	ProcessButton:StyleButton()

	local offset = E.PixelMode and E.mult or E.Border
	ProcessButton.texture = ProcessButton:CreateTexture(nil, E.db.bags.strata or "DIALOG")
	ProcessButton.texture:SetInside(ProcessButton, offset, offset)
	ProcessButton.texture:SetTexCoord(unpack(E.TexCoords))

	ProcessButton:SetTemplate(nil, nil, nil, E.PixelMode, true)
	ProcessButton:EnableMouse(true)
	ProcessButton:RegisterForClicks("LeftButtonDown")
	ProcessButton:SetAttribute("type", "macro")
	ProcessButton:SetAttribute("macrotext", "/cast Prospecting")
	ProcessButton:SetScript('PostClick', function() ProcessButton:Hide() end)
	ProcessButton:SetFrameStrata(E.db.bags.strata or "DIALOG")
	ProcessButton:SetFrameLevel(10000)
	local size = (B.db.bagSize) * (3/4)
	ProcessButton:Size(size)

	ProcessButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self)
		GameTooltip:SetHyperlink(self.isKey and self.currentSpellID or GetSpellLink(self.currentSpellID) or "")
		GameTooltip:Show()
	end)

	ProcessButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	RegisterStateDriver(ProcessButton, "visibility", "[combat] hide")

	return ProcessButton
end

function mod:Process(self, modifier)
	local ProcessButton = mod.ProcessButton
	if not ProcessButton then return end

	if IsModifierKeyDown() and (modifier == 'ANY' or _G['Is'..modifier..'KeyDown']()) then
		if InCombatLockdown() then
			print(core.customColorBad..ERR_NOT_IN_COMBAT)
			return
		end

		local itemID = GetContainerItemID(self.bagID, self.slotID)
		if not itemID then return end

		ProcessButton.isKey = false
		local spellName, texturePath, spellID

		if LibProcessable:IsProspectable(itemID) then
			spellName, _, texturePath = GetSpellInfo(prospectingSpellID)
			spellID = prospectingSpellID
		elseif LibProcessable:IsDisenchantable(itemID) then
			spellName, _, texturePath = GetSpellInfo(disenchantingSpellID)
			spellID = disenchantingSpellID
		elseif LibProcessable:IsMillable(itemID) then
			spellName, _, texturePath = GetSpellInfo(millingSpellID)
			spellID = millingSpellID
		elseif LibProcessable:IsOpenable(itemID) then
			local _, openedItemID = LibProcessable:IsOpenable(itemID)
			if openedItemID then
				for i = 1, GetKeyRingSize() do
					itemID = GetContainerItemID(-2, i)
					if itemID == openedItemID then
						local keyName, link, _, _, _, _, _, _, _, keyTexture = GetItemInfo(itemID)
						spellName, texturePath = keyName, keyTexture
						spellID = link
						ProcessButton.isKey = true
						break
					end
				end
			else
				spellName, _, texturePath = GetSpellInfo(lockpickingSpellID)
				spellID = lockpickingSpellID
			end
		else
			print(core.customColorBad..ERR_INVALID_ITEM_TARGET)
			return
		end
		if spellName then
			ProcessButton.texture:SetTexture(texturePath)
			ProcessButton:SetAttribute("macrotext", (ProcessButton.isKey and "/use " or "/cast ")..spellName.."\n/use "..self.bagID.." "..self.slotID)
			ProcessButton.currentSpellID = spellID
			ProcessButton:ClearAllPoints()
			local x, y = self:GetCenter()
			ProcessButton:Point("CENTER", UIParent, "BOTTOMLEFT", x, y + self:GetHeight())
			ProcessButton:Show()
			ProcessButton:SetScript("OnUpdate", function()
				ProcessButton:ClearAllPoints()
				x, y = self:GetCenter()
				ProcessButton:Point("CENTER", UIParent, "BOTTOMLEFT", x, y + self:GetHeight())
			end)
		end
	end
end

function mod:FindEmpty(isBagsExtendedV2, bagSpace, bagID)
	if isBagsExtendedV2 then
		for i, button in ipairs(bagSpace.buttons) do
			if not button.hasItem then
				return button, button.bagID, button.slotID, i
			end
		end
	else
		local targetBag = bagSpace.Bags[bagID]
		if targetBag and targetBag.numSlots > 0 then
			for slotID = 1, targetBag.numSlots do
				local button = targetBag[slotID]
				if button and not button.hasItem then
					return button, bagID, slotID, slotID
				end
			end
		else
			for _, bagID in ipairs(bagSpace.BagIDs) do
				local bag = bagSpace.Bags[bagID]
				local bagSlots = bag and bag.numSlots
				if bagSlots and bagSlots > 0 and (not bag.type or bag.type == 0) then
					for slotID = 1, bagSlots do
						local button = bag[slotID]
						if button and not button.hasItem then
							return button, bagID, slotID, slotID
						end
					end
				end
			end
		end
	end
end

function mod:SplitHandler(self, button)
    local modifier = E.db.Extras.general[modName].SplitStack.modifier
    local isBagsExtendedV2 = E.db.Extras.general[modName].BagsExtendedV2.enabled

    if IsModifierKeyDown() and (modifier == 'ANY' or _G['Is'..modifier..'KeyDown']()) then
        local bagID, slotID = self.bagID, self.slotID
		local f = B_GetContainerFrame(nil, bagID < 0 or bagID > NUM_BAG_SLOTS)

        if button == 'LeftButton' then
            local stackCount = select(2, B_GetItemInfo(nil, bagID, slotID))
            if not stackCount or stackCount == 1 then return end
            local split = floor(stackCount / 2)
            local _, freeBagID, freeSlotID

			if isBagsExtendedV2 then
				local section = buttonMap[bagID][slotID]
				local emptyButton = section.isSpecialBag and mod:FindEmpty(nil, f, section.bagID) or next(buttonMap[f])
				if emptyButton then
					freeBagID, freeSlotID = emptyButton.bagID, emptyButton.slotID
				end
			else
				_, freeBagID, freeSlotID = mod:FindEmpty(nil, f)
			end
            if freeSlotID then
                B_SplitItem(nil, bagID, slotID, split)
                B_PickupItem(nil, freeBagID, freeSlotID)
            else
                print(core.customColorBad..ERR_SPLIT_FAILED)
            end
        elseif button == 'RightButton' then
			local handler = f.SplitStackHandler
            if not handler.isStacking then
                local itemID = B_GetItemID(nil, bagID, slotID)
				if not itemID then return end

                handler.isStacking = true
                local timeElapsed, partialStacks = 0, {}

                if isBagsExtendedV2 then
					local section = buttonMap[bagID][slotID]
					if section then
						for _, button in ipairs(section.buttons) do
							if B_GetItemID(nil, button.bagID, button.slotID) == itemID then
								tinsert(partialStacks, button)
							end
						end
					end
                else
					for _, bagID in ipairs(f.BagIDs) do
						local bag = f.Bags[bagID]
						if bag and bag.numSlots > 0 then
							for slotID = 1, bag.numSlots do
								local bagButton = bag[slotID]
								if bagButton and B_GetItemID(nil, bagID, slotID) == itemID then
									tinsert(partialStacks, bagButton)
								end
							end
						end
					end
                end
				if #partialStacks == 0 then return end

				local stacks = {}
				for _, button in ipairs(partialStacks) do
					local bagID, slotID = button.bagID, button.slotID
					local itemID = B_GetItemID(nil, bagID, slotID)
					if itemID then
						local stackCount = select(2, B_GetItemInfo(nil, bagID, slotID))
						local _, _, _, _, _, _, _, maxStack = GetItemInfo(itemID)
						if not stacks[itemID] then
							stacks[itemID] = {}
						end
						tinsert(stacks[itemID], {button = button, count = stackCount, maxStack = maxStack})
					end
				end
                handler:SetScript('OnUpdate', function(self, elapsed)
                    timeElapsed = timeElapsed + elapsed
                    if timeElapsed > 0.1 then
                        if InCombatLockdown() then
                            print(core.customColorBad..ERR_NOT_IN_COMBAT)
                            self.isStacking = false
                            self:SetScript('OnUpdate', nil)
                            return
                        end
                        timeElapsed = 0

						local complete = true
						for _, stack in pairs(stacks) do
							if #stack > 1 then
								tsort(stack, function(a, b) return a.count > b.count end)
								local targetIndex = 1
								for sourceIndex = 2, #stack do
									local target = stack[targetIndex]
									local source = stack[sourceIndex]
									if source.count >= 0 then
										local spaceInTarget = target.maxStack - target.count
										while targetIndex < sourceIndex and target.count >= target.maxStack do
											targetIndex = targetIndex + 1
											target = stack[targetIndex]
											spaceInTarget = target.maxStack - target.count
										end
										if source.button ~= target.button and spaceInTarget > 0 and source.count > 0 then
											local amountToMove = min(spaceInTarget, source.count)
											B_SplitItem(nil, source.button.bagID, source.button.slotID, amountToMove)
											B_PickupItem(nil, target.button.bagID, target.button.slotID)
											target.count = target.count + amountToMove
											source.count = source.count - amountToMove
											ClearCursor()
											complete = false
											break
										end
									end
								end
							end
						end
                        if complete then
							self.isStacking = false
							self:SetScript('OnUpdate', nil)
                        end
                    end
                end)
            end
        end
    end
end

function mod:ModifyStackSplitFrame(enable)
	if enable then
		if not mod:IsHooked(StackSplitFrame, 'OnShow') then
			mod:SecureHookScript(StackSplitFrame, 'OnShow', function()
				StackSplitFrame.editBox:ClearAllPoints()
				StackSplitFrame.editBox:Point('TOPLEFT', StackSplitLeftButton, 'TOPLEFT', 0, 0)
				StackSplitFrame.editBox:Point('BOTTOMRIGHT', StackSplitRightButton, 'BOTTOMRIGHT', -4, -0)
				StackSplitFrame.editBox:SetFocus()
			end)
		end

		local origOnClick = StackSplitOkayButton:GetScript('OnClick')
		local origOnKeyDown = StackSplitOkayButton:GetScript('OnKeyDown')
		local function OnOkay()
			local parent = select(2, StackSplitFrame:GetPoint())
			local bag, slot = parent.bagID, parent.slotID
			local stack = StackSplitFrame.editBox:GetText() ~= '' and tonumber(StackSplitFrame.editBox:GetText()) or 1

			ClearCursor()
			if MerchantFrame:IsShown() and find(parent:GetName(), 'Merchant') then
				-- block original buyout
				StackSplitOkayButton:SetScript('OnClick', nil)
				StackSplitFrame:SetScript('OnKeyDown', nil)
				BuyMerchantItem(parent:GetID(), stack)
				StackSplitFrame:Hide()
				return
			end
			B_SplitItem(nil, bag, slot, stack)
		end

		if not mod:IsHooked(StackSplitOkayButton, 'PreClick') then
			mod:SecureHookScript(StackSplitOkayButton, 'PreClick', OnOkay)
			mod:SecureHookScript(StackSplitOkayButton, 'PostClick', function()
				StackSplitOkayButton:SetScript('OnClick', origOnClick)
				StackSplitFrame:SetScript('OnKeyDown', origOnKeyDown)
			end)
		end

		if not StackSplitFrame.editBox then
			local editBox = CreateFrame('EditBox', "StackSplitFrameEditBox", StackSplitFrame, 'InputBoxTemplate')
			editBox:SetNumeric(true)
			S:HandleEditBox(editBox)
			editBox:Show()

			StackSplitFrame.editBox = editBox
			StackSplitFrame.editBox:SetScript('OnEscapePressed', function(self) StackSplitFrame:Hide() end)
			StackSplitFrame.editBox:SetScript('OnEnterPressed', function(self) StackSplitOkayButton:Click() end)
		else
			StackSplitFrame.editBox:Show()
		end

		StackSplitRightButton:Disable()
		StackSplitLeftButton:Disable()
		StackSplitRightButton:Hide()
		StackSplitLeftButton:Hide()
		StackSplitFrame:Height(80)
	else
		if self:IsHooked(StackSplitFrame, 'OnShow') then
			self:Unhook(StackSplitFrame, 'OnShow')
		end
		if self:IsHooked(StackSplitOkayButton, 'OnClick') then
			self:Unhook(StackSplitOkayButton, 'OnClick')
		end
		StackSplitRightButton:Enable()
		StackSplitLeftButton:Enable()
		StackSplitRightButton:Show()
		StackSplitLeftButton:Show()
		StackSplitFrame.editBox:Hide()
		StackSplitFrame:Height(96)
	end
end

function mod:EasierProcessing(db)
	if db.EasierProcessing.enabled then
		if not self:IsHooked(B, 'Layout') then self:SecureHook(B, 'Layout') end

		if InCombatLockdown() then
			local f = CreateFrame()
			f:RegisterEvent("PLAYER_REGEN_ENABLED")
			f:SetScript("OnEvent", function(self)
				self.ProcessButton = self.ProcessButton and self.ProcessButton or self:CreateProcessingButton()
				self.localhooks.EasierProcessing = {
					["OnClick"] = function(self) mod:Process(self, db.EasierProcessing.modifier) end,
					["OnHide"] = function() if self.ProcessButton:IsShown() then
												self.ProcessButton:Hide()
												self.ProcessButton:SetScript("OnUpdate", nil)
											end
										end
				}
				self:Hide()
				self = nil
			end)
		else
			self.ProcessButton = self.ProcessButton and self.ProcessButton or self:CreateProcessingButton()
			self.localhooks.EasierProcessing = {
				["OnClick"] = function(self) mod:Process(self, db.EasierProcessing.modifier) end,
				["OnHide"] = function() if self.ProcessButton:IsShown() then
												self.ProcessButton:Hide()
												self.ProcessButton:SetScript("OnUpdate", nil)
											end
										end
			}
		end

		self.initialized.EasierProcessing = true
	elseif self.initialized.EasierProcessing then
		if self:IsHooked(B, 'Layout') and not (db.BagsExtendedV2.enabled or db.SplitStack.enabled) then
			self:Unhook(B, 'Layout')
		end
		self.localhooks.EasierProcessing["OnClick"] = false
		self.localhooks.EasierProcessing["OnHide"] = false
		self.ProcessButton:Hide()
		self.ProcessButton = nil
		self.initialized.EasierProcessing = false
	end
end

function mod:SplitStack(db)
	if db.SplitStack.enabled then
		if not self:IsHooked(B, 'Layout') then self:SecureHook(B, 'Layout') end

		self.localhooks.SplitStack = {
			["OnClick"] = function(self, button) mod:SplitHandler(self, button) end
		}

		self:ModifyStackSplitFrame(true)
		self.initialized.SplitStack = true
	elseif self.initialized.SplitStack then
		if self:IsHooked(B, 'Layout') and not (db.BagsExtendedV2.enabled or db.EasierProcessing.enabled) then
			self:Unhook(B, 'Layout')
		end
		self.localhooks.SplitStack["OnClick"] = false
		self:ModifyStackSplitFrame(false)
		self.initialized.SplitStack = false
	end
end


function mod:Toggle(db)
	if core.reload then
		local reload = {BagsExtendedV2 = {}, EasierProcessing = {}, SplitStack = {}}
		self:BagsExtendedV2(reload)
		self:EasierProcessing(reload)
		self:SplitStack(reload)
	else
		self:BagsExtendedV2(db)
		self:EasierProcessing(db)
		self:SplitStack(db)
	end
end

function mod:InitializeCallback()
	local db = E.db.Extras.general[modName]
	mod:LoadConfig(db)
	if not E.private.bags.enable then return end
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback
