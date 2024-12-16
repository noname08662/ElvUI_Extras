local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Automation", "AceHook-3.0", "AceEvent-3.0")
local B = E:GetModule("Bags")

local modName = mod:GetName()

local _G, ipairs, select, type, unpack, next, setfenv = _G, ipairs, select, type, unpack, next, setfenv
local loadstring, pcall, tonumber, tostring = loadstring, pcall, tonumber, tostring
local tinsert, tremove, tconcat = table.insert, table.remove, table.concat
local gmatch, match, gsub, format, find, lower = string.gmatch, string.match, string.gsub, string.format, string.find, string.lower
local ConfirmLootRoll, LootSlot, GetLootSlotInfo = ConfirmLootRoll, LootSlot, GetLootSlotInfo
local GetNumLootItems, GetLootSlotLink =  GetNumLootItems, GetLootSlotLink
local QuestGetAutoAccept, AcceptQuest, CloseQuest, ConfirmAcceptQuest = QuestGetAutoAccept, AcceptQuest, CloseQuest, ConfirmAcceptQuest
local GetNumQuestChoices, IsQuestCompletable, CompleteQuest, GetQuestReward = GetNumQuestChoices, IsQuestCompletable, CompleteQuest, GetQuestReward
local GossipFrame, GetNumGossipOptions, GetGossipAvailableQuests = GossipFrame, GetNumGossipOptions, GetGossipAvailableQuests
local GetGossipActiveQuests, SelectGossipOption = GetGossipActiveQuests, SelectGossipOption
local StaticPopupDialogs, StaticPopup_Hide, StaticPopup_Show = StaticPopupDialogs, StaticPopup_Hide, StaticPopup_Show
local IsModifierKeyDown, InCombatLockdown = IsModifierKeyDown, InCombatLockdown
local GetItemInfo, GetItemCount, UseContainerItem = GetItemInfo, GetItemCount, UseContainerItem
local GetMerchantItemLink, BuyMerchantItem = GetMerchantItemLink, BuyMerchantItem
local GetAuctionItemClasses, GetAuctionItemSubClasses = GetAuctionItemClasses, GetAuctionItemSubClasses
local BROWSE_NO_RESULTS, PURCHASE, DELETE_ITEM_CONFIRM_STRING = BROWSE_NO_RESULTS, PURCHASE, DELETE_ITEM_CONFIRM_STRING
local YES, NO, ERR_NOT_IN_COMBAT = YES, NO, ERR_NOT_IN_COMBAT

local methodFuncs, swiftBuyButton = {}
local scanner = CreateFrame("GameTooltip", "ExtrasAutomation_ScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

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
		scanner:ClearLines()
		scanner:SetHyperlink(item.link)
		local tooltipText = ''
		for i = 2, scanner:NumLines() do
			local left = _G["ExtrasAutomation_ScanningTooltipTextLeft"..i]:GetText()
			local right = _G["ExtrasAutomation_ScanningTooltipTextRight"..i]:GetText()

			tooltipText = tooltipText .. (left or '')
			tooltipText = tooltipText .. (right or '')
		end
		return lower(gsub(tooltipText, '[%s%p]+', ''))
	end,
}

local function formatCondition(filterName, operator, value, amount)
	if tonumber(value) then
		return format('((filterFuncs.%s(item) and filterFuncs.%s(item) %s %s) and %s)', filterName, filterName, operator, value, amount)
	elseif operator == '~=' then
		return format('not find(filterFuncs.%s(item) or "", "%s", 1, true) and %s', filterName, lower(value), amount)
	else
		return format('find(filterFuncs.%s(item) or "", "%s", 1, true) and %s', filterName, lower(value), amount)
	end
end

local function parseCollectionString(conditions)
    local formattedConditions = conditions

    for condition in gmatch(formattedConditions, '%S+@[<>=~!]*%S+') do
        local pair, filterName, operator, value, amount = match(condition, '(([^%s%p]*)@(%p*)([^%s%p]*)@*([+%d]*))')
		if filterName and filter[filterName] and value then
			local formattedCondition = formatCondition(filterName, operator ~= '' and operator or '==',
														value, amount ~= '' and (tonumber(amount) or format("'%s'", amount or 1)) or 1)
			formattedConditions = gsub(formattedConditions, gsub(pair, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1"), formattedCondition)
		else
			core:print('FORMATTING', L["Automations"])
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

local function updateCollectionMethods(collectionMethod)
	if not find(collectionMethod or "", '%S+') then
		return
	end

	local parsedString = parseCollectionString(collectionMethod)
	if not parsedString then return end

	local luaFunction, errorMsg = loadstring(parsedString)
	if luaFunction then
		setfenv(luaFunction, {find = find})
		local success, customFuncGenerator = pcall(luaFunction)
		if not success then
			core:print('FAIL', L["Automations"], customFuncGenerator)
		else
			local customFunc = customFuncGenerator(filter)

			if type(customFunc) == "function" then
				return function(itemInfo)
					return itemInfo and customFunc(itemInfo) or false
				end
			else
				core:print('LUA', L["Automations"], L["The generated custom looting method did not return a function."])
			end
		end
	else
		core:print('LUA', L["Automations"], errorMsg)
	end
end

local function getItemDetails(itemID)
	local itemName, itemLink, quality, itemLevel, useLevel, itemType, itemSubType, maxStack, equipSlot, _, sellPrice = GetItemInfo(itemID)
	return {
		id = tonumber(itemID),
		name = itemName,
		link = itemLink,
		quality = quality,
		ilvl = itemLevel,
		useLevel = useLevel,
		type = itemType,
		subType = itemSubType,
		equipSlot = equipSlot,
		maxStack = maxStack,
		sellPrice = sellPrice,
	}
end

local function createTex(button, texture, size)
	local tex = button:CreateTexture(nil, "ARTWORK")
	tex:SetTexture(texture)
	tex:Point("CENTER")
	tex:Size(size)

	return tex
end


local function updatePopupDialog(pending, popupsCount, index, itemLink, amount, bagID, slotID)
	StaticPopupDialogs["CONFIRM_BUY_ITEM"..popupsCount] = {
		text = format("%s %s x%s?", index and PURCHASE or L["Sell"], itemLink, amount),
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if index then
				BuyMerchantItem(index, amount)
			else
				UseContainerItem(bagID, slotID)
			end
			if #pending > 0 then
				StaticPopup_Hide("CONFIRM_BUY_ITEM"..popupsCount)
				updatePopupDialog(pending, popupsCount, unpack(tremove(pending)))
				StaticPopup_Show("CONFIRM_BUY_ITEM"..popupsCount)
				return true
			end
		end,
		OnCancel = function()
			if #pending > 0 then
				StaticPopup_Hide("CONFIRM_BUY_ITEM"..popupsCount)
				updatePopupDialog(pending, popupsCount, unpack(tremove(pending)))
				StaticPopup_Show("CONFIRM_BUY_ITEM"..popupsCount)
				return true
			end
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
	}
end

local function buyMerchantStuff(collectionMethod, failsafe, buyOne)
	local index = 1
	local staticOffset = 1
	local pending = {}
	local itemLink = GetMerchantItemLink(index)
	while itemLink do
		local itemID = tonumber(match(itemLink, "item:(%d+)"))
		local buyoutAmount = collectionMethod(getItemDetails(itemID))
		if buyoutAmount then
			if buyOne then
				buyoutAmount = 1
			end
            if failsafe then
				local popupsCount = staticOffset
				local staticbuyoutAmount
				if buyoutAmount == '+' then
					local maxStack = select(8, GetItemInfo(itemID))
					local heldAmount = maxStack - GetItemCount(itemID)
					staticbuyoutAmount = heldAmount > 0 and heldAmount or maxStack
				else
					local amount1, amount2 = match(buyoutAmount, '(%d*)+(%d*)')
					local buyoutAmountVal = tonumber(amount1 or amount2)
					if buyoutAmountVal then
						local topAmount = buyoutAmountVal - GetItemCount(itemID)
						if topAmount > 0 then
							staticbuyoutAmount = topAmount
						end
					else
						staticbuyoutAmount = tonumber(buyoutAmount)
					end
				end
				if staticbuyoutAmount then
					if popupsCount > 4 then
						tinsert(pending, 1, {index, itemLink, staticbuyoutAmount})
					else
						updatePopupDialog(pending, popupsCount, index, itemLink, staticbuyoutAmount)
						StaticPopup_Show("CONFIRM_BUY_ITEM"..popupsCount)
					end
					staticOffset = staticOffset + 1
				end
            elseif buyoutAmount == '+' then
				local maxStack = select(8,GetItemInfo(itemID))
				local heldAmount = maxStack - GetItemCount(itemID)
				BuyMerchantItem(index, heldAmount > 0 and heldAmount or maxStack)
			else
				local amount1, amount2 = match(buyoutAmount, '(%d*)+(%d*)')
				local buyoutAmountVal = tonumber(amount1 or amount2)
				if buyoutAmountVal then
					local topAmount = buyoutAmountVal - GetItemCount(itemID)
					if topAmount > 0 then
						BuyMerchantItem(index, topAmount)
					end
				else
					BuyMerchantItem(index, tonumber(buyoutAmount))
				end
			end
		end
		index = index + 1
		itemLink = GetMerchantItemLink(index)
	end
end

local function sellMerchantStuff(collectionMethod, failsafe)
	if InCombatLockdown() then
		print(core.customColorBad..ERR_NOT_IN_COMBAT)
		return
	end
	local f = B:GetContainerFrame()
	if f then
		local staticOffset = 1
		local pending = {}
		for _, bagID in ipairs(f.BagIDs) do
			local bag = f.Bags[bagID]
			local bagSlots = bag and bag.numSlots
			if bagSlots and bagSlots > 0 then
				for slotID = 1, bagSlots do
					local button = bag[slotID]
					if button then
						local itemID = B:GetItemID(bagID, slotID)
						if itemID then
							local _, itemLink, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemID)
							if sellPrice and sellPrice > 0 and collectionMethod(getItemDetails(itemID)) then
								if failsafe then
									if staticOffset > 4 then
										tinsert(pending, 1, {nil, itemLink, button.count, bagID, slotID})
									else
										updatePopupDialog(pending, staticOffset, nil, itemLink, button.count, bagID, slotID)
										StaticPopup_Show("CONFIRM_BUY_ITEM"..staticOffset)
									end
									staticOffset = staticOffset + 1
								else
									UseContainerItem(bagID, slotID)
								end
							end
						end
					end
				end
			end
		end
	end
end

local function probeMerchantStuff(collectionMethod)
	local index = 1
	local itemLink = GetMerchantItemLink(index)
	while itemLink do
		local itemID = tonumber(match(itemLink, "item:(%d+)"))
		local buyoutAmount = collectionMethod(getItemDetails(itemID))
		if buyoutAmount then
			return true
		else
			index = index + 1
			itemLink = GetMerchantItemLink(index)
		end
	end
end

local function probeBagsStuff(collectionMethod)
	local f = B:GetContainerFrame()
	if f then
		for _, bagID in ipairs(f.BagIDs) do
			local bag = f.Bags[bagID]
			local bagSlots = bag and bag.numSlots
			if bagSlots and bagSlots > 0 then
				for slotID = 1, bagSlots do
					local button = bag[slotID]
					if button then
						local itemID = B:GetItemID(bagID, slotID)
						if itemID then
							local sellPrice = select(11,GetItemInfo(itemID))
							if sellPrice and sellPrice > 0 and collectionMethod(getItemDetails(itemID)) then
								return true
							end
						end
					end
				end
			end
		end
	end
end


P["Extras"]["blizzard"][modName] = {
	["ConfirmRolls"] = {
		["enabled"] = false,
	},
	["AutoPickup"] = {
		["enabled"] = false,
		["collectionMethod"] = "type@"..select(12,GetAuctionItemClasses()),
	},
	["SwiftBuy"] = {
		["enabled"] = false,
		["modifier"] = "Alt",
		["selectedSet"] = 0,
		["defaultCollectionMethod"] = "",
		["defaultFailsafe"] = true,
		["sets"] = {},
	},
	["FillDelete"] = {
		["enabled"] = false,
	},
	["Gossip"] = {
		["enabled"] = false,
	},
	["AcceptQuest"] = {
		["enabled"] = false,
	}
}

function mod:LoadConfig(db)
	local selectedItemType = 0
    local function selectedSet() return db.SwiftBuy.selectedSet end
    local function selectedSetData()
		return core:getSelected("blizzard", modName, format("SwiftBuy.sets[%s]", selectedSet() or ""), 0)
	end
	core.blizzard.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) db[info[#info-1]][gsub(info[#info], info[#info-1], '')] = value self:Toggle(db) end,
		disabled = function(info) return info[#info] ~= modName and not match(info[#info], '^enabled') and not db[info[#info-1]].enabled end,
		args = {
			ConfirmRolls = {
				type = "group",
				name = L["Confirm Rolls"],
				guiInline = true,
				args = {
					enabledConfirmRolls = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Hits the 'Confirm' button automatically."],
					},
				},
			},
			AutoPickup = {
				type = "group",
				name = L["Auto Pickup"],
				guiInline = true,
				args = {
					enabledAutoPickup = {
						order = 1,
						type = "toggle",
						width = "full",
						name = core.pluginColor..L["Enable"],
						desc = L["Picks up items and money automatically."],
					},
					collectionMethod = {
						order = 2,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Collection Method"],
						desc = L["Syntax: filter@value\n\n"..
								"Available filters:\n"..
								" id@number - matches itemID,\n"..
								" name@string - matches name,\n"..
								" type@string - matches type,\n"..
								" subtype@string - matches subtype,\n"..
								" ilvl@number - matches ilvl,\n"..
								" uselevel@number - matches equip level,\n"..
								" quality@number - matches quality,\n"..
								" equipslot@number - matches inventorySlotID,\n"..
								" maxstack@number - matches stack limit,\n"..
								" price@number - matches sell price,\n"..
								" tooltip@string - matches tooltip text.\n\n"..
								"All string matches are case-insensitive and match only alphanumeric symbols.\n"..
								"Standard Lua logic for branching (and/or/parenthesis/etc.) applies.\n\n"..
								"Example usage (priest t8 or Shadowmourne):\n"..
								"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."],
					},
					itemTypeInfo = {
						order = 3,
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
						hidden = function() return not db.AutoPickup.enabled end,
					},
					subTypeInfo = {
						order = 4,
						type = "description",
						name = function()
							return tconcat({GetAuctionItemSubClasses(selectedItemType-1)}, ", ")
						end,
						hidden = function() return not (db.AutoPickup.enabled and selectedItemType and selectedItemType > 1) end,
					},
				},
			},
			SwiftBuy = {
				type = "group",
				name = L["Swift Buy"],
				guiInline = true,
				args = {
					enabledSwiftBuy = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Buys out items automatically."],
					},
					modifier = {
						order = 2,
						type = "select",
						name = L["Modifier"],
						desc = L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
								"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."],
						values = E.db.Extras.modifiers,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					failsafe = {
						order = 3,
						type = "toggle",
						name = L["Failsafe"],
						desc = L["Enables popup confirmation dialog."],
						get = function() return selectedSet() == 0 and db.SwiftBuy.defaultFailsafe or selectedSetData().failsafe end,
						set = function(_, value)
							if selectedSet() == 0 then
								db.SwiftBuy.defaultFailsafe = value
							else
								selectedSetData().failsafe = value
							end
							self:Toggle(db)
						end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					color = {
						order = 4,
						type = "color",
						name = L["Text Color"],
						desc = "",
						get = function() return unpack(selectedSet() == 0 and {} or selectedSetData().color or {}) end,
						set = function(_, r, g, b)
							selectedSetData().color = {r, g, b}
							self:Toggle(db)
						end,
						disabled = function() return selectedSet() == 0 end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					addSet = {
						order = 5,
						type = "execute",
						name = L["Add Set"],
						desc = "",
						func = function()
							tinsert(db.SwiftBuy.sets, 1,
									{["failsafe"] = true,
									["actionType"] = "SELL",
									["title"] = "",
									["collectionMethod"] = "",
									["icon"] = "",
									["color"] = {1,1,1}})
							db.SwiftBuy.selectedSet = 1
							self:Toggle(db)
						end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					deleteSet = {
						order = 6,
						type = "execute",
						name = L["Delete Set"],
						desc = "",
						func = function()
							tremove(db.SwiftBuy.sets, selectedSet())
							db.SwiftBuy.selectedSet = 0
							self:Toggle(db)
						end,
						disabled = function() return selectedSet() == 0 end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					title = {
						order = 7,
						type = "input",
						name = L["Title"],
						desc = "",
						get = function() return selectedSet() == 0 and L["Auto Buy"] or selectedSetData().title end,
						set = function(_, value) selectedSetData().title = value end,
						disabled = function() return selectedSet() == 0 end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					selectedSet = {
						order = 8,
						type = "select",
						name = L["Select Set"],
						desc = "",
						get = function() return tostring(selectedSet()) end,
						set = function(_, value) db.SwiftBuy.selectedSet = tonumber(value) end,
						values = function()
							local dropdownValues = {[0] = L["Auto Buy"]}
							for i, set in ipairs(db.SwiftBuy.sets) do
								dropdownValues[tostring(i)] = set.title
							end
							return dropdownValues
						end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					icon = {
						order = 9,
						type = "input",
						name = L["Icon"],
						desc = "",
						get = function() return selectedSet() == 0 and "" or selectedSetData().icon end,
						set = function(_, value)
							selectedSetData().icon = value
							self:Toggle(db)
						end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					actionType = {
						order = 10,
						type = "select",
						name = L["Action Type"],
						desc = "",
						get = function() return selectedSetData().actionType end,
						set = function(_, value) selectedSetData().actionType = value self:Toggle(db) end,
						values = {
							["BUY"] = PURCHASE,
							["SELL"] = L["Sell"],
						},
						disabled = function() return selectedSet() == 0 end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					collectionMethod = {
						order = 11,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Collection Method"],
						desc = function()
							local actionType = selectedSetData().actionType
							return not actionType or actionType == "BUY" and
							L["Syntax: filter@value@amount\n\n"..
								"Available filters:\n"..
								" id@number@amount(+)/+ - matches itemID,\n"..
								" name@string@amount(+)/+ - matches name,\n"..
								" type@string@amount(+)/+ - matches type,\n"..
								" subtype@string@amount(+)/+ - matches subtype,\n"..
								" ilvl@number@amount(+)/+ - matches ilvl,\n"..
								" uselevel@number@amount(+)/+ - matches equip level,\n"..
								" quality@number@amount(+)/+ - matches quality,\n"..
								" equipslot@number@amount(+)/+ - matches inventorySlotID,\n"..
								" maxstack@number@amount(+)/+ - matches stack limit,\n"..
								" price@number@amount(+)/+ - matches sell price,\n"..
								" tooltip@string@amount(+)/+ - matches tooltip text.\n\n"..
								"The optional 'amount' part could be:\n"..
								"  a number - to purchase a static amount,\n"..
								"  a + sign - to replenish the existing partial stack or purchase a new one,\n"..
								"  both (e.g. 5+) - to purchase enough items to reach a specified total (in this case, 5),\n"..
								"  ommited - defaults to 1.\n\n"..
								"All string matches are case-insensitive and match only alphanumeric symbols.\n"..
								"Standard Lua logic for branching (and/or/parenthesis/etc.) applies.\n\n"..
								"Example usage (priest t8 or Shadowmourne):\n"..
								"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."]
							or L["Syntax: filter@value\n\n"..
								"Available filters:\n"..
								" id@number - matches itemID,\n"..
								" name@string - matches name,\n"..
								" type@string - matches type,\n"..
								" subtype@string - matches subtype,\n"..
								" ilvl@number - matches ilvl,\n"..
								" uselevel@number - matches equip level,\n"..
								" quality@number - matches quality,\n"..
								" equipslot@number - matches inventorySlotID,\n"..
								" maxstack@number - matches stack limit,\n"..
								" price@number - matches sell price,\n"..
								" tooltip@string - matches tooltip text.\n\n"..
								"All string matches are case-insensitive and match only alphanumeric symbols.\n"..
								"Standard Lua logic for branching (and/or/parenthesis/etc.) applies.\n\n"..
								"Example usage (priest t8 or Shadowmourne):\n"..
								"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."]
						end,
						get = function()
							if selectedSet() == 0 then
								return db.SwiftBuy.defaultCollectionMethod
							else
								return selectedSetData().collectionMethod
							end
						end,
						set = function(_, value)
							if selectedSet() == 0 then
								db.SwiftBuy.defaultCollectionMethod = value
							else
								selectedSetData().collectionMethod = value
							end
							self:Toggle(db)
						end,
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					itemTypeInfo = {
						order = 12,
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
						hidden = function() return not db.SwiftBuy.enabled end,
					},
					subTypeInfo = {
						order = 13,
						type = "description",
						name = function()
							return tconcat({GetAuctionItemSubClasses(selectedItemType-1)}, ", ")
						end,
						hidden = function() return not (db.SwiftBuy.enabled and selectedItemType and selectedItemType > 1) end,
					},
				},
			},
			FillDelete = {
				type = "group",
				name = L["Fill Delete"],
				guiInline = true,
				args = {
					enabledFillDelete = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Automatically fills the 'DELETE' field."],
					},
				},
			},
			Gossip = {
				type = "group",
				name = L["Gossip"],
				guiInline = true,
				args = {
					enabledGossip = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."],
					},
				},
			},
			AcceptQuest = {
				type = "group",
				name = L["Accept Quest"],
				guiInline = true,
				args = {
					enabledAcceptQuest = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Accepts and turns in quests automatically while holding a modifier."],
					},
				},
			},
		},
	}
end


function mod:Automations(db)
	-- some of these have been stolen from LeatrixPlus
	if db.FillDelete.enabled then
		if not self:IsHooked(StaticPopupDialogs["DELETE_GOOD_ITEM"], 'OnShow') then
			self:SecureHook(StaticPopupDialogs["DELETE_GOOD_ITEM"], 'OnShow', function(self)
				self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
			end)
		end
	elseif self:IsHooked(StaticPopupDialogs["DELETE_GOOD_ITEM"], 'OnShow') then
		self:Unhook(StaticPopupDialogs["DELETE_GOOD_ITEM"], 'OnShow')
	end

	if db.Gossip.enabled then
		if not self:IsHooked(GossipFrame, 'OnShow') then
			self:SecureHookScript(GossipFrame, 'OnShow', function()
				if (GetNumGossipOptions() == 1) and not (GetGossipAvailableQuests() or GetGossipActiveQuests()) and not IsModifierKeyDown() then
					SelectGossipOption(1)
				end
			end)
		end
	elseif self:IsHooked(GossipFrame, 'OnShow') then
		self:Unhook(GossipFrame, 'OnShow')
	end

	if db.AutoPickup.enabled then
		local collectionMethod = updateCollectionMethods(db.AutoPickup.collectionMethod) or function() return end
		self:RegisterEvent('LOOT_OPENED', function()
			for i = 1, GetNumLootItems() do
				local lootLink = GetLootSlotLink(i)
				if lootLink then
					local itemID = match(lootLink, 'item:(%d+)')
					local itemInfo = getItemDetails(itemID)

					if collectionMethod(itemInfo) then
						LootSlot(i)
					end
				elseif i == 1 and select(4,GetLootSlotInfo(i)) == 0 then
					LootSlot(i)
				end
			end
		end)
	else
		self:UnregisterEvent('LOOT_OPENED')
	end

	if db.SwiftBuy.enabled then
		local swiftBuy = db.SwiftBuy
		local modifier = swiftBuy.modifier or 'Alt'
		local isModDown = modifier == 'ANY'
							and function() return IsModifierKeyDown() end
							or function() return _G['Is'..modifier..'KeyDown']() end

		methodFuncs = {['autobuy'] = updateCollectionMethods(swiftBuy.defaultCollectionMethod) or function() return end}

		for _, entry in ipairs(swiftBuy.sets) do
			local r, g, b = unpack(entry.color or {1,1,1})
			tinsert(methodFuncs,
					{updateCollectionMethods(entry.collectionMethod) or function() return end,
					(not entry.icon or entry.icon == "") and "" or format("|T%s:12|t", entry.icon),
					format("|cff%02x%02x%02x", r * 255, g * 255, b * 255),
					entry.actionType or "BUY",
					})
		end

		if not swiftBuyButton then
			swiftBuyButton = CreateFrame("Button", "SwiftBuyButton", MerchantFrame, "UIPanelButtonTemplate")
			swiftBuyButton:Size(24)
			swiftBuyButton:ClearAllPoints()
			swiftBuyButton:Point("TOPLEFT", MerchantFrame, "TOPLEFT", 20, -20)
			swiftBuyButton:SetNormalTexture(createTex(swiftBuyButton, "Interface\\GossipFrame\\VendorGossipIcon", 24))
			swiftBuyButton:SetPushedTexture(createTex(swiftBuyButton, "Interface\\GossipFrame\\VendorGossipIcon", 24))
			swiftBuyButton:SetHighlightTexture(createTex(swiftBuyButton, "Interface\\GossipFrame\\VendorGossipIcon", 24))
			swiftBuyButton:SetScript("OnMouseDown", function(self)
				self:Point("TOPLEFT", MerchantFrame, "TOPLEFT", 21, -21)
			end)
			swiftBuyButton:SetScript("OnMouseUp", function(self)
				self:Point("TOPLEFT", MerchantFrame, "TOPLEFT", 20, -20)
			end)
			swiftBuyButton:SetScript("OnEnter", function(self)
				for i = 1, #swiftBuy.sets do
					local data = methodFuncs[i]
					if data[4] == "BUY" and probeMerchantStuff(methodFuncs[i][1]) or probeBagsStuff(methodFuncs[i][1]) then
						return
					end
				end
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetText(BROWSE_NO_RESULTS)
				GameTooltip:Show()
			end)
			swiftBuyButton:SetScript("OnLeave", function(self)
				GameTooltip:Hide()
			end)
			swiftBuyButton.dropdownMenu = CreateFrame("Frame", "SwiftBuyDropdown", UIParent, "UIDropDownMenuTemplate")

			local function initializeDropdown(self, level)
				local sellEntries = {}
				local purchaseEntries = {}
				for i, entry in ipairs(swiftBuy.sets) do
					local data = methodFuncs[i]
					if data[4] == "BUY" then
						if probeMerchantStuff(data[1]) then
							tinsert(purchaseEntries, {data = data, entry = entry})
						end
					elseif probeBagsStuff(data[1]) then
						tinsert(sellEntries, {data = data, entry = entry})
					end
				end
				if next(purchaseEntries) then
					local header = UIDropDownMenu_CreateInfo()
					header.text = PURCHASE
					header.isTitle = true
					header.notCheckable = true
					UIDropDownMenu_AddButton(header, level)
					for _, values in ipairs(purchaseEntries) do
						local info = UIDropDownMenu_CreateInfo()
						info.text = format("%s%s%s", values.data[2], values.data[3], values.entry.title)
						info.menuList = values.entry.title
						info.func = function()
							buyMerchantStuff(values.data[1], values.entry.failsafe, isModDown())
						end
						UIDropDownMenu_AddButton(info, level)
					end
				end
				if next(sellEntries) then
					local header = UIDropDownMenu_CreateInfo()
					header.text = L["Sell"]
					header.isTitle = true
					header.notCheckable = true
					UIDropDownMenu_AddButton(header, level)
					for _, values in ipairs(sellEntries) do
						local info = UIDropDownMenu_CreateInfo()
						info.text = format("%s%s%s", values.data[2], values.data[3], values.entry.title)
						info.menuList = values.entry.title
						info.func = function()
							sellMerchantStuff(values.data[1], values.entry.failsafe)
						end
						UIDropDownMenu_AddButton(info, level)
					end
				end
			end
			UIDropDownMenu_Initialize(swiftBuyButton.dropdownMenu, initializeDropdown, "MENU")

			swiftBuyButton:SetScript("OnClick", function(self)
				ToggleDropDownMenu(1, nil, self.dropdownMenu, self, 0, 0)
			end)
		end
		self:RegisterEvent('MERCHANT_SHOW', function()
			if isModDown() then
				buyMerchantStuff(methodFuncs['autobuy'], swiftBuy.defaultFailsafe)
			end
		end)
	elseif swiftBuyButton then
		self:UnregisterEvent('MERCHANT_SHOW')
		swiftBuyButton:Hide()
		swiftBuyButton = nil
	end

	if db.AcceptQuest.enabled then
		self:RegisterEvent('QUEST_DETAIL', function()
			if IsModifierKeyDown() then
				if not QuestGetAutoAccept() then
					AcceptQuest()
				else
					CloseQuest()
				end
			end
		end)
		self:RegisterEvent('QUEST_ACCEPT_CONFIRM', function()
			if IsModifierKeyDown() then
				ConfirmAcceptQuest()
				StaticPopup_Hide('QUEST_ACCEPT_CONFIRM')
			end
		end)
		self:RegisterEvent('QUEST_PROGRESS', function()
			if IsModifierKeyDown() and IsQuestCompletable() then
				CompleteQuest()
			end
		end)
		self:RegisterEvent('QUEST_COMPLETE', function()
			if IsModifierKeyDown() and GetNumQuestChoices() <= 1 then
				GetQuestReward(GetNumQuestChoices())
			end
		end)
	else
		self:UnregisterEvent('QUEST_DETAIL')
		self:UnregisterEvent('QUEST_ACCEPT_CONFIRM')
		self:UnregisterEvent('QUEST_PROGRESS')
		self:UnregisterEvent('QUEST_COMPLETE')
	end

	if db.ConfirmRolls.enabled then
		self:RegisterEvent('CONFIRM_LOOT_ROLL', function(_, id, rollType)
			if not id or not rollType then return end
			ConfirmLootRoll(id, rollType)
			StaticPopup_Hide('CONFIRM_LOOT_ROLL')
		end)
		self:RegisterEvent('CONFIRM_DISENCHANT_ROLL', function(_, id, rollType)
			if not id or not rollType then return end
			ConfirmLootRoll(id, rollType)
			StaticPopup_Hide('CONFIRM_LOOT_ROLL')
		end)
		self:RegisterEvent('LOOT_BIND_CONFIRM', function(_, id, rollType)
			if not id or not rollType then return end
			ConfirmLootRoll(id, rollType)
			StaticPopup_Hide('CONFIRM_LOOT_ROLL')
		end)
	else
		self:UnregisterEvent('CONFIRM_LOOT_ROLL')
		self:UnregisterEvent('CONFIRM_DISENCHANT_ROLL')
		self:UnregisterEvent('LOOT_BIND_CONFIRM')
	end
end


function mod:Toggle(db)
	self:Automations(db)
end

function mod:InitializeCallback()
	local db = E.db.Extras.blizzard[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback
