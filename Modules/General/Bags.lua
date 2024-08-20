local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Bags", "AceHook-3.0")
local B = E:GetModule("Bags")
local S = E:GetModule("Skins")
local LSM = E.Libs.LSM
local LibProcessable = LibStub("LibProcessable")

local modName = mod:GetName()
local buttonMap, lastScan, equippedBags, tooltipInfo = {}, {}, {}, {}
local globalSort, initialized = {}, {}
mod.localhooks = {}

local prospectingSpellID = 31252
local disenchantingSpellID = 13262
local millingSpellID = 51005
local lockpickingSpellID = 1804

local _G, unpack, pairs, ipairs, select, print, tonumber, tostring, loadstring, pcall, type = _G, unpack, pairs, ipairs, select, print, tonumber, tostring, loadstring, pcall, type
local twipe, tinsert, tremove, tsort = table.wipe, table.insert, table.remove, table.sort
local min, max, floor, ceil, huge = min, max, floor, ceil, math.huge
local find, format, lower, match, gmatch, gsub, sub = string.find, string.format, string.lower, string.match, string.gmatch, string.gsub, string.sub
local UIParent, GameTooltip_Hide, InCombatLockdown, UnitFactionGroup = UIParent, GameTooltip_Hide, InCombatLockdown, UnitFactionGroup
local GetItemInfo, GetInventoryItemTexture, BankButtonIDToInvSlotID, GetBagName = GetItemInfo, GetInventoryItemTexture, BankButtonIDToInvSlotID, GetBagName
local ContainerIDToInventoryID, GetContainerNumSlots, GetContainerNumFreeSlots = ContainerIDToInventoryID, GetContainerNumSlots, GetContainerNumFreeSlots
local GetCurrencyListInfo, GetCurrencyListSize, GetItemQualityColor = GetCurrencyListInfo, GetCurrencyListSize, GetItemQualityColor
local StackSplitFrame, StackSplitOkayButton, StackSplitRightButton, StackSplitLeftButton = StackSplitFrame, StackSplitOkayButton, StackSplitRightButton, StackSplitLeftButton
local MerchantFrame, BuyMerchantItem, GetAuctionItemClasses, GetSpellLink, ClearCursor = MerchantFrame, BuyMerchantItem, GetAuctionItemClasses, GetSpellLink, ClearCursor
local IsModifierKeyDown, GetContainerItemID, GetSpellInfo, GetKeyRingSize = IsModifierKeyDown, GetContainerItemID, GetSpellInfo, GetKeyRingSize
local ERR_NOT_IN_COMBAT, ERR_INVALID_ITEM_TARGET, ERR_SPLIT_FAILED = ERR_NOT_IN_COMBAT, ERR_INVALID_ITEM_TARGET, ERR_SPLIT_FAILED
local CURRENCY, NUM_BAG_SLOTS, EMPTY = CURRENCY, NUM_BAG_SLOTS, EMPTY

local B_PickupItem, B_GetNumSlots, B_GetItemID, B_GetItemInfo, B_GetContainerFrame, B_SplitItem = B.PickupItem, B.GetNumSlots, B.GetItemID, B.GetItemInfo, B.GetContainerFrame, B.SplitItem
local E_Delay = E.Delay
local updatePending = false

local scanner = CreateFrame("GameTooltip", "ExtrasBags_ScanningTooltip", nil, "GameTooltipTemplate")
scanner:SetOwner(WorldFrame, "ANCHOR_NONE")

local Weapon, Armor, Container, Consumable, Glyph, TradeGoods, Projectile, Quiver, Recipe, Gem, Miscellaneous, Quest = GetAuctionItemClasses()
local _, _, Leather = GetAuctionItemSubClasses(2)
local _, _, _, MetalStone, _, Herb, Enchanting, _, Parts = GetAuctionItemSubClasses(6)
local Arrow, Bullet = GetAuctionItemSubClasses(7)
local Inscription = select(12,GetAuctionItemSubClasses(9))

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

local filter = {
	id = function(item) return item.id end,
    type = function(item) return lower(gsub(gsub(item.type, '%s+', ''), '%p+', '')) end,
    subtype = function(item) return lower(gsub(gsub(item.subType, '%s+', ''), '%p+', '')) end,
    ilvl = function(item) return item.ilvl end,
    uselevel = function(item) return item.useLevel end,
    quality = function(item) return item.quality end,
    name = function(item) return lower(gsub(gsub(item.name, '%s+', ''), '%p+', '')) end,
    equipslot = function(item) return inventorySlotIDs[item.equipSlot] end,
    maxstack = function(item) return item.maxStack end,
    price = function(item) return item.sellPrice end,
	tooltip = function(item) return tooltipInfo[item.id] end,
}

local specialBagFilters = {
    [1] = "subtype@"..Arrow, -- Quiver
    [2] = "subtype@"..Bullet, -- Ammo Pouch
	[4] = "id@6265", -- Soul Bag
    [8] = "subtype@"..Leather, -- Leatherworking Bag
    [16] = "subtype@"..Inscription, -- Inscription Bag
    [32] = "subtype@"..Herb, -- Herb Bag
    [64] = "subtype@"..Enchanting, -- Enchanting Bag
    [128] = "subtype@"..Parts, -- Engineering Bag
    [512] = "type@"..Gem, -- Gem Bag
    [1024] = "subtype@"..gsub(gsub(MetalStone, '%s+', ''), '%p+', ''), -- Mining Bag
}


local function getItemTooltipText(bagID, slotID)
    scanner:ClearLines()
    if bagID == -1 then
        scanner:SetInventoryItem("player", BankButtonIDToInvSlotID(slotID))
    else
        scanner:SetBagItem(bagID, slotID)
    end
    
    local tooltipText = ''
    for i = 2, scanner:NumLines() do
        local left = _G["ExtrasBags_ScanningTooltipTextLeft"..i]:GetText()
        local right = _G["ExtrasBags_ScanningTooltipTextRight"..i]:GetText()
		
        tooltipText = tooltipText .. (left or '')
        tooltipText = tooltipText .. (right or '')
    end

    return tooltipText
end

local function getItemDetails(bagID, slotID, itemID)
    if not itemID then return nil end
    
    local itemName, _, quality, itemLevel, useLevel, itemType, itemSubType, maxStack, equipSlot, _, sellPrice = GetItemInfo(itemID)
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
    }
end

local function defaultSort(a, b)
	local bagIDA, slotIDA, bagIDB, slotIDB = a.bagID, a.slotID, b.bagID, b.slotID
	local itemIDA, itemIDB = B_GetItemID(nil, bagIDA, slotIDA), B_GetItemID(nil, bagIDB, slotIDB)

    if not itemIDA and not itemIDB then return false end
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


local function formatCondition(filterName, operator, value)
	if filterName == "name" then
		return format('string.match(string.lower(filterFuncs.%s(item) or ""), "%s")', filterName, lower(value))
	else
		if tonumber(value) then
			return format('(filterFuncs.%s(item) and filterFuncs.%s(item) %s %s or false)', filterName, filterName, operator, value)
		elseif operator == '~=' then
			return format('not string.match(string.lower(filterFuncs.%s(item) or ""), "%s")', filterName, lower(value))
		else
			return format('string.match(string.lower(filterFuncs.%s(item) or ""), "%s")', filterName, lower(value))
		end
	end
end

local function parseCollectionString(conditions)
    local formattedConditions = conditions
    local startIndex = 1

    while true do
        local conditionStart, conditionEnd = find(formattedConditions, '%S+@[<>=~!]*%S+', startIndex)
        if not conditionStart then break end

        local pair, filterName, operator, value = match(formattedConditions:sub(conditionStart, conditionEnd), '(([^%s%p]*)@(%p*)([^%s%p]*))')
        if filterName and filter[filterName] and value then
            operator = operator ~= '' and operator or '=='
            local formattedCondition = formatCondition(filterName, operator, value)
            formattedConditions = gsub(formattedConditions, pair, formattedCondition)
            startIndex = conditionStart + #formattedCondition
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


local function wipeLayout(layout)
	if not layout then return end
	for _, section in ipairs(layout.sections) do
		local frame = section.frame
		if frame then
			frame:Hide()
			frame.concatenateButton:Hide()
			frame.concatenateButton = nil
			frame.expandButton:Hide()
			frame.expandButton = nil
			if frame.title then
				frame.title:Hide()
				frame.title = nil
			end
			if section.frame.icon then
				frame.icon:Hide()
				frame.icon = nil
			end
			if frame.minimizeHandler then
				frame.minimizeHandler:Hide()
				frame.minimizeHandler = nil
				frame.minimizedLine:Hide()
				frame.minimizedLine = nil
			end
			section.frame = nil
		end
	end
	layout = nil
end

local function runAllScripts(self, event, ...)
	for _, info in pairs(mod.localhooks) do
		for type, script in pairs(info) do 
			if type == event and script then script(self, ...) end
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
	["BagsExtended"] = {
		["enabled"] = false,
		["selectedContainer"] = 'bags',
		["containers"] = {
			["bags"] = {
				["selectedSection"] = 1,
				["sectionSpacing"] = 14,
				["iconSpacing"] = 4,
				["specialBags"] = {},
				["sections"] = {
					{
						["length"] = 8,
						["yOffset"] = 4,
						["sortMethod"] = '',
						["collectionMethod"] = 'type@'..Consumable,
						["ignoreList"] = {},
						["title"] = {
							["enabled"] = true,
							["text"] = "Consumables",
							["toIcon"] = true,
							["color"] = { 1, 1, 1 },
							["font"] = "Expressway",
							["size"] = 13,
							["flags"] = "OUTLINE",
							["point"] = "BOTTOMLEFT",
							["relativeTo"] = "TOPLEFT",
							["xOffset"] = 0,
							["yOffset"] = 4,
						},
						["icon"] = {
							["enabled"] = false,
							["texture"] = "Interface\\Icons\\INV_Potion_93",
							["point"] = "RIGHT",
							["relativeTo"] = "LEFT",
							["xOffset"] = 0,
							["yOffset"] = 0,
							["toText"] = false,
							["size"] = 12,
						},
						["minimize"] = {
							["enabled"] = true,
							["lineColor"] = { 1, 1, 1, 0.5 },
						},
					},
					{
						["length"] = 999,
						["yOffset"] = 0,
						["sortMethod"] = '',
						["collectionMethod"] = '',
						["ignoreList"] = {},
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
						["minimize"] = {
							["enabled"] = false,
							["lineColor"] = { 1, 1, 1, 0.5 },
						},
						["title"] = {
							["enabled"] = false,
							["text"] = "Remaining",
							["color"] = { 1, 1, 1 },
							["font"] = "Expressway",
							["size"] = 13,
							["flags"] = "OUTLINE",
							["point"] = "BOTTOMLEFT",
							["relativeTo"] = "TOPLEFT",
							["xOffset"] = 0,
							["yOffset"] = 4,
						},
					},
				},
			},
		},
	},
}

function mod:LoadConfig()
    local function selectedContainer() return E.db.Extras.general[modName].BagsExtended.selectedContainer end
    local function selectedSection() return E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection end
    core.general.args[modName] = {
        type = "group",
        name = L[modName],
		get = function(info) return E.db.Extras.general[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) E.db.Extras.general[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] = value mod:Toggle() end,
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
						desc = L["Mod-clicking an item suggest a skill/item to process it."],
					},
					modifierEasierProcessing = {
						order = 2,
						type = "select",
						name = L["Modifier"],
						desc = "",
						values = E.db.Extras.modifiers,
						disabled = function(info) return not E.db.Extras.general[modName].EasierProcessing.enabled end,
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
						desc = format(L["Holding %s while left-clicking a stack splits it in two; to combine available copies, right-click instead."..
								"\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."], E.db.Extras.general[modName].SplitStack.modifier),
					},
					modifierSplitStack = {
						order = 2,
						type = "select",
						name = L["Modifier"],
						desc = "",
						values = E.db.Extras.modifiers,
						disabled = function(info) return not E.db.Extras.general[modName].SplitStack.enabled end,
					},
				},
			},
            BagsExtended = {
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
						get = function(info) return E.db.Extras.general[modName].BagsExtended.enabled end,
						set = function(info, value) E.db.Extras.general[modName].BagsExtended.enabled = value self:Toggle() end,
                    },
					selectedContainer = {
						order = 2,
						type = "select",
						name = L["Select Container Type"],
						desc = "",
						get = function(info) return E.db.Extras.general[modName].BagsExtended.selectedContainer end,
						set = function(info, value) E.db.Extras.general[modName].BagsExtended.selectedContainer = value end,
						values = {
							['bags'] = L['Bags'],
							['bank'] = L['Bank'],
						},
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled end,
					},
				},
			},
			settings = {
				order = 4,
                type = "group",
                name = L["Settings"],
                guiInline = true,
				get = function(info) return E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()][info[#info]] end,
				set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()][info[#info]] = value self:UpdateAll() end,
                disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled end,
				hidden = function() return not E.db.Extras.general[modName].BagsExtended.enabled end,
                args = {
					addSection = {
						order = 1,
						type = "execute",
						name = L["Add Section"],
						desc = "",
						func = function()
							local newSection = {
								["length"] = 8,
								["yOffset"] = 4,
								["sortMethod"] = '',
								["collectionMethod"] = '',
								["ignoreList"] = {},
								["title"] = {
									["enabled"] = true,
									["text"] = "New Section",
									["toIcon"] = true,
									["color"] = { 1, 1, 1 },
									["font"] = "Expressway",
									["size"] = 13,
									["flags"] = "OUTLINE",
									["point"] = "BOTTOMLEFT",
									["relativeTo"] = "TOPLEFT",
									["xOffset"] = 0,
									["yOffset"] = 4,
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
								["minimize"] = {
									["enabled"] = true,
									["lineColor"] = { 1, 1, 1, 0.5 },
								},
							}
							local sections = E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections
							tinsert(sections, #sections - 1, newSection)
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection = #sections - 1
							self:UpdateAll()
						end,
					},
					deleteSection = {
						order = 2,
						type = "execute",
						name = L["Delete Section"],
						desc = "",
						func = function() 
							tremove(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections, selectedSection())
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection = 1
							self:UpdateAll()
						end,
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections or E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].isSpecialBag end,
					},
					length = {
						order = 3,
						type = "range",
						name = L["Section Length"],
						desc = "",
						min = 1, max = 28, step = 1,
						set = function(info, value) 
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()][info[#info]] = value 
							self:UpdateAll()
						end,
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections or E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].isSpecialBag end,
					},
                    selectedSection = {
						order = 4,
						type = "select",
						name = L["Select Section"],
						desc = "",
						get = function(info) return tostring(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection) end,
						set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection = tonumber(value) end,
						values = function()
							local dropdownValues = {}
							for i, section in ipairs(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections) do
								dropdownValues[tostring(i)] = section.title.text
							end
							return dropdownValues
						end,
					},
					sectionPriority = {
						order = 5,
						type = "input",
						name = L["Section Priority"],
						desc = "",
						get = function() return tostring(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection) end,
						set = function(info, value)
							local sections = E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections
							local currentIndex = E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection
							local targetIndex = tonumber(value)
							local sectionCount = #sections - 1 

							if targetIndex and targetIndex >= 1 and targetIndex <= sectionCount and targetIndex ~= currentIndex then
								local tempHolder = sections[targetIndex]
								sections[targetIndex] = sections[currentIndex]
								sections[currentIndex] = tempHolder
								E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection = targetIndex
							elseif targetIndex and targetIndex > sectionCount then
								local bottomIndex = sectionCount
								local tempHolder = sections[bottomIndex]
								sections[bottomIndex] = sections[currentIndex]
								sections[currentIndex] = tempHolder
								E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection = bottomIndex
							elseif targetIndex and targetIndex < 1 then
								local tempHolder = sections[1]
								sections[1] = sections[currentIndex]
								sections[currentIndex] = tempHolder
								E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].selectedSection = 1
							end
							self:UpdateAll()
						end,
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections end,
					},
                    sectionSpacing = {
                        order = 6,
                        type = "range",
                        name = L["Section Spacing"],
						desc = "",
                        min = 0, max = 40, step = 1,
                        get = function(info) return E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sectionSpacing end,
                        set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sectionSpacing = value self:UpdateAll() end,
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections end,
                    },
					collectionMethod = {
						order = 7,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Collection Method"],
						desc = L["Handles automated repositioning of the newly received items."..
								"\n\Syntax: filter@value\n\n"..
								"Available filters:\n"..
								"id@number - matches itemID,\n"..
								"name@string - matches name,\n"..
								"subtype@string - matches subtype,\n"..
								"ilvl@number - matches ilvl,\n"..
								"uselevel@number - matches equip level,\n"..
								"quality@number - matches quality,\n"..
								"equipslot@number - matches nventorySlotID,\n"..
								"maxstack@number - matches stack limit,\n"..
								"price@number - matches sell price,\n\n"..
								"tooltip@string - matches tooltip text,\n\n"..
								"All string matches are not case sensitive and match only the alphanumeric symbols. Standart lua logic applies. "..
								"Look up GetItemInfo API for more info on filters. "..
								"Use GetAuctionItemClasses and GetAuctionItemSubClasses (same as on the AH) to get the localized types and subtypes values.\n\n"..
								"Example usage (priest t8 or Shadowmourne):\n"..
								"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
								"Accepts custom functions (bagID, slotID, itemID are exposed)\n"..
								"The below one notifies of the newly aquired items.\n\n"..
								"local icon = GetContainerItemInfo(bagID, slotID)\n"..
								"local _, link = GetItemInfo(itemID)\n"..
								"icon = gsub(icon, '\\124', '\\124\\124')\n"..
								"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
								"print('Item received: ' .. string)"],
						set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()][info[#info]] = value 
							self:UpdateAll()
						end,
					},
					sortMethod = {
						order = 8,
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
						set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()][info[#info]] = value 
							self:UpdateAll()
						end,
					},
					addItem = {
						order = 9,
						type = "input",
						width = "double",
						name = L["Ignore Item (by ID)"],
						desc = L["Listed ItemIDs will not get sorted."],
						get = function(info) return "" end,
						set = function(info, value)
							local itemID = match(value, '%D*(%d+)%D*')
							if itemID and GetItemInfo(itemID) then
								E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].ignoreList[tonumber(itemID)] = true
								local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
								texture = gsub(texture, '\124', '\124\124')
								local string = '\124T' .. texture .. ':16:16\124t' .. link
								core:print('ADDED', string)
							end
						end,
					},
					removeItem = {
						order = 10,
						type = "select",
						width = "double",
						name = L["Remove Ignored"],
						desc = "",
						get = function(info) return "" end,
						set = function(info, value)
							local ignoreList = E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].ignoreList
							for itemID in pairs(ignoreList) do
								if itemID == value then
									ignoreList[itemID] = nil
									local _, link, _, _, _, _, _, _, _, texture = GetItemInfo(itemID)
									texture = gsub(texture, '\124', '\124\124')
									local string = '\124T' .. texture .. ':16:16\124t' .. link
									core:print('REMOVED', string)
									self:UpdateAll()
									break
								end
							end
						end,
						values = function()
							local values = {}
							for itemID in pairs(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].ignoreList) do
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
			minimize = {
                type = "group",
                name = L["Minimize"],
                guiInline = true,						
				disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled end,
				hidden = function() return not E.db.Extras.general[modName].BagsExtended.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
                        name = core.pluginColor..L["Enable"],
						desc = L["Double-click the title text to minimize the section."],
						get = function(info) return E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].minimize[info[#info]] end,
						set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].minimize[info[#info]] = value self:UpdateAll() end,
					},
					lineColor = {
						order = 2,
						type = "color",
						hasAlpha = true,
						name = L["Line Color"],
						desc = L["Minimized section's line color."],
						get = function(info) return unpack(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].minimize[info[#info]]) end,
						set = function(info, r, g, b, a) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].minimize[info[#info]] = { r, g, b, a } self:UpdateAll() end,
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled or not E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].minimize.enabled end,
					},
				},
			},
			title = {
                type = "group",
                name = L["Title"],
                guiInline = true,
				get = function(info) return E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].title[info[#info]] end,
				set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].title[info[#info]] = value self:UpdateAll() end,
                disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled end,
				hidden = function() return not E.db.Extras.general[modName].BagsExtended.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections end,
				args = {
					color = {
						order = 0,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info) return unpack(E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].title.color) end,
						set = function(info, r, g, b) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].title.color = { r, g, b } self:UpdateAll() end,
					},
					toIcon = {
						order = 1,
						type = "toggle",
						name = L["Attach to Icon"],
						set = function(info, value) 
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].title[info[#info]] = value 
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].icon.toText = not value
							self:UpdateAll()
						end,
						desc = "",
						disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled or not E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].icon.enabled end,
					},
					text = {
						order = 2,
						type = "input",
						name = L["Text"],
						desc = "",
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
					},
					relativeTo = {
						order = 7,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
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
				get = function(info) return E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].icon[info[#info]] end,
				set = function(info, value) E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].icon[info[#info]] = value self:UpdateAll() end,
                disabled = function() return not E.db.Extras.general[modName].BagsExtended.enabled end,
				hidden = function() return not E.db.Extras.general[modName].BagsExtended.enabled or not E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].icon.enabled or selectedSection() == #E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections end,
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
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].icon[info[#info]] = value 
							E.db.Extras.general[modName].BagsExtended.containers[selectedContainer()].sections[selectedSection()].title.toIcon = not value
							self:UpdateAll()
						end,
					},
					texture = {
						order = 3,
						type = "input",
						name = L["Texture"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
					},
					size = {
						order = 4,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 8, max = 32, step = 1,
					},
					point = {
						order = 5,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 6,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 7,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -40, max = 40, step = 1,
					},
					yOffset = {
						order = 8,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -40, max = 40, step = 1,
					},
				},
			},
        },
    }
	if not E.db.Extras.general[modName].BagsExtended.containers['bank'] then
		E.db.Extras.general[modName].BagsExtended.containers['bank'] = CopyTable(E.db.Extras.general[modName].BagsExtended.containers['bags'])
	end
end


function mod:UpdateAll(disable)
	for _, isBank in pairs({false, true}) do
		local f = B_GetContainerFrame(nil, isBank)
		if f then
			if disable and f.currentLayout then
				wipeLayout(f.currentLayout)
				f.holderFrame:ClearAllPoints()
				f.holderFrame:Point("TOP", f, "TOP", 0, -f.topOffset)
				f.holderFrame:Point("BOTTOM", f, "BOTTOM", 0, 8)
				f.heldCurrencies:Hide()
				self:HandleSortButton(f, false, isBank)
			end
			B:Layout(isBank)
		end
	end
end

function mod:EvaluateItem(sections, bagID, slotID, itemID)
    for _, section in ipairs(sections) do
		if section.collectionMethodFunc then
			local result = section.collectionMethodFunc(bagID, slotID, itemID)
			if result then
				for _, button in ipairs(section.buttons) do
					if not button.hasItem then
						return button.bagID, button.slotID, section
					end
				end
			end
		end
    end
end

function mod:HandleControls(f, section, buttonSize)
	local sectionFrame, sectionButtons, db = section.frame, section.buttons, section.db
	if not sectionFrame.concatenateButton then
		sectionFrame.concatenateButton = CreateFrame("Button", "$parentConcatenateButton", sectionFrame, "UIPanelButtonTemplate")
		S:HandleButton(sectionFrame.concatenateButton)
		sectionFrame.concatenateButton:StyleButton()
		sectionFrame.concatenateButton:SetText("-")
		sectionFrame.concatenateButton:Show()
		sectionFrame.concatenateButton:SetScript("OnHide", function() 
			sectionFrame.concatenateButton:SetScript('OnUpdate', nil)
			sectionFrame.isBeingSorted = false
		end)
		sectionFrame.concatenateButton:SetScript("OnMouseDown", function()
			if sectionFrame.isBeingSorted or sectionFrame.minimized then return end
			sectionFrame.isBeingSorted = true
			sectionFrame.expanded = false
			local timeElapsed, buttons, stacked, positioned = 0, {}
			if not globalSort[f] then E:StartSpinnerFrame(f) end
			sectionFrame.concatenateButton:SetScript('OnUpdate', function(self, elapsed)
				timeElapsed = timeElapsed + elapsed
				if timeElapsed > 0.1 then
					if InCombatLockdown() then 
						print(core.customColorBad..ERR_NOT_IN_COMBAT)
						sectionFrame.isBeingSorted = false
						sectionFrame.concatenateButton:SetScript('OnUpdate', nil)
						mod:UpdateSection(f, section, buttonSize)
						if not globalSort[f] then mod:ScanBags(f, true) E:StopSpinnerFrame(f) end
						return 
					end
					timeElapsed = 0
					if not stacked then
						stacked = mod:StackSection(sectionButtons)
						if stacked then
							local ignoreList = db.ignoreList
							for i, button in ipairs(sectionButtons) do 
								local bagID, slotID = button.bagID, button.slotID
								local itemID = B_GetItemID(nil, bagID, slotID)
								if ignoreList[itemID] then
									tinsert(buttons, {positioned = true})
								else
									tinsert(buttons, {itemID = itemID, bagID = bagID, slotID = slotID})
								end
							end
							tsort(buttons, section.sortMethodFunc)
						end
					elseif not positioned then
						positioned = mod:SortSection(buttons, sectionButtons)
					else
						sectionFrame.isBeingSorted = false
						sectionFrame.concatenateButton:SetScript('OnUpdate', nil)
						mod:UpdateSection(f, section, buttonSize)
						if not globalSort[f] then mod:ScanBags(f, true) E:StopSpinnerFrame(f) end
					end
				end
			end)
		end)
	end
	sectionFrame.concatenateButton:Size(buttonSize / 2, buttonSize / 2)
	if not sectionFrame.expandButton then
		sectionFrame.expandButton = CreateFrame("Button", "$parentExpandButton", sectionFrame, "UIPanelButtonTemplate")
		S:HandleButton(sectionFrame.expandButton)
		sectionFrame.expandButton:StyleButton()
		sectionFrame.expandButton:SetText("+")
		sectionFrame.expandButton:Show()
		sectionFrame.expandButton:SetScript("OnMouseDown", function()
			for i, button in ipairs(sectionButtons) do
				if not button:IsShown() and sectionButtons[i-1] then 
					sectionButtons[i-1].Count:Hide()
				end
				button:Show()
			end
			sectionFrame.expanded = true
			mod:UpdateSection(f, section, buttonSize)
		end)
	end
	sectionFrame.expandButton:Size(buttonSize / 2, buttonSize / 2)

	if db.minimize.enabled then
		section.frame.minimized = section.db.minimized
		if not sectionFrame.minimizeHandler then
			sectionFrame.minimizeHandler = CreateFrame("Button", nil, sectionFrame, "UIPanelButtonTemplate")
			sectionFrame.minimizeHandler:SetAllPoints(sectionFrame.title)
			sectionFrame.minimizeHandler:SetScript("OnDoubleClick", function()
				section.db.minimized = not section.db.minimized
				section.frame.minimized = section.db.minimized
				mod:ToggleMinimizeSection(f, section, buttonSize)
			end)
			sectionFrame.minimizeHandler:SetAlpha(0)
			
			sectionFrame.minimizedLine = sectionFrame:CreateTexture(nil, "OVERLAY")
			sectionFrame.minimizedLine:Point("TOPLEFT", sectionButtons[1], "TOPLEFT", 0, 0)
			sectionFrame.minimizedLine:Point("TOPRIGHT", f.holderFrame, "TOPRIGHT", 0, 0)
			sectionFrame.minimizedLine:Height(1)
		end
		sectionFrame.minimizeHandler:Show()
		sectionFrame.minimizedLine:SetTexture(unpack(db.minimize.lineColor))
	else
		section.frame.minimized = false
	end
end

function mod:ToggleMinimizeSection(f, section, buttonSize)
    if not section.frame.minimized then
        section.frame.concatenateButton:Show()
        section.frame.expandButton:Show()
		if section.frame.minimizedLine then
			section.frame.minimizedLine:Hide()
		end
		if section.frame.title then
			section.frame.minimizedCount = nil
			section.frame.title:SetText(section.db.title.text)
		end
	else
		for _, button in ipairs(section.buttons) do button:Hide() button.isHidden = true end
        section.frame.concatenateButton:Hide()
        section.frame.expandButton:Hide()
		if section.frame.minimizedLine then
			section.frame.minimizedLine:Show()
		end
    end
    mod:UpdateSection(f, section, buttonSize)
    mod:ResizeFrame(f, E.Border * 2, buttonSize)
end

function mod:HandleSortButton(f, enable, isBank)
	if enable then
		f.sortButton:SetScript("OnClick", nil)
		f.sortButton:SetScript("OnMouseDown", function()
			local sections = {}
			for _, section in ipairs(f.currentLayout.sections) do
				tinsert(sections, section)
			end
			
			tsort(sections, function(a,b) return a.order < b.order end)
		
			local timeElapsed, index = 0, 1
			local section = sections[index]
			globalSort[f] = true
			E:StartSpinnerFrame(f)
			section.frame.concatenateButton:GetScript("OnMouseDown")()
			
			f.sortButton:SetScript("OnUpdate", function(self, elapsed)
				timeElapsed = timeElapsed + elapsed
				if timeElapsed > 0.1 then
					if index == #sections then
						if not section.frame.isBeingSorted then
							f.sortButton:SetScript("OnUpdate", nil) 
							mod:ScanBags(f, true)
							E:StopSpinnerFrame(f)
							globalSort[f] = false
						end
					elseif not section.frame.isBeingSorted then 
						index = index + 1
						section = sections[index]
						section.frame.concatenateButton:GetScript("OnMouseDown")()
					end
				end
			end)
		end)
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

function mod:ConfigureContainer(f, isBank, maxSectionWidth, numContainerColumns, buttonSize)
    local db = E.db.Extras.general[modName].BagsExtended.containers[isBank and 'bank' or 'bags']

    wipeLayout(f.currentLayout)

    local sections = db.sections
    local yOffset = -buttonSize/2
    local buttons, specialButtons = {}, {}
    local specialBags = {}

    for i, bagID in ipairs(f.BagIDs) do
		buttonMap[bagID] = {}
		specialButtons[bagID] = {}
        local _, bagType = GetContainerNumFreeSlots(bagID)
		if f.Bags[bagID] and f.Bags[bagID].numSlots > 0 then
			if bagType and bagType ~= 0 and (not db.specialBags[bagID] or db.specialBags[bagID] ~= GetBagName(bagID)) then
                specialBags[bagID] = {
                    numSlots = GetContainerNumSlots(bagID),
					buttons = {},
					bagType = bagType,
                }
            end
			for slotID = 1, f.Bags[bagID].numSlots do
				local button = f.Bags[bagID][slotID]
                if bagType ~= 0 then
					tinsert(specialButtons[bagID], button)
				else
					tinsert(buttons, button)
				end
			end
		end
	end

    self:HandleSortButton(f, true)

    local processedSections = {}
    if not f.Sections then f.Sections = {} end
    
	for i, section in ipairs(sections) do
		if section.isSpecialBag then
			local bagID = section.bagID
			local numSlots, bagType = GetContainerNumFreeSlots(bagID)
			if numSlots == 0 or bagType == 0 or (db.specialBags[bagID] and db.specialBags[bagID] ~= GetBagName(bagID)) then
				db.specialBags[bagID] = false
				tremove(sections, i)
				if E.RefreshGUI then E:RefreshGUI() end
			end
		end
	end

	for bagID, bagInfo in pairs(specialBags) do
		local specialSection = {
			["length"] = bagInfo.numSlots,
			["yOffset"] = 4,
			["sortMethod"] = '',
			["collectionMethod"] = specialBagFilters[bagInfo.bagType],
			["ignoreList"] = {},
			["title"] = {
				["enabled"] = true,
				["text"] = GetBagName(bagID) or "Special Bag",
				["toIcon"] = true,
				["color"] = { 1, 1, 1 },
				["font"] = "Expressway",
				["size"] = 13,
				["flags"] = "OUTLINE",
				["point"] = "BOTTOMLEFT",
				["relativeTo"] = "TOPLEFT",
				["xOffset"] = 0,
				["yOffset"] = 4,
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
			["minimize"] = {
				["enabled"] = true,
				["lineColor"] = { 1, 1, 1, 0.5 },
			},
			["isSpecialBag"] = true,
			["bagID"] = bagID,
		}
		db.specialBags[bagID] = GetBagName(bagID)
		tinsert(sections, 1, specialSection)
		if E.RefreshGUI then E:RefreshGUI() end
	end

	for i, section in ipairs(sections) do
		local sectionFrame = f.Sections[i]
		
		if not sectionFrame then
			sectionFrame = CreateFrame("Frame", "$parentSection"..i, f.holderFrame)
			f.Sections[i] = sectionFrame
		end
		
		sectionFrame:ClearAllPoints()
		sectionFrame:Point("TOPLEFT", f.holderFrame, "TOPLEFT", 0, yOffset)
		sectionFrame:Width(maxSectionWidth)
		sectionFrame.occupied = {}
		sectionFrame:Show()

		local sectionButtons = {}
		if section.isSpecialBag then
			sectionButtons = specialButtons[section.bagID]
		else
			for j = 1, section.length do
				local button = tremove(buttons, 1)
				if not button then break end
				tinsert(sectionButtons, button)
			end
		end
		
		if #sectionButtons == 0 then break end
		
		if section.title.enabled then
			sectionFrame.title = sectionFrame.title or sectionFrame:CreateFontString(nil, "OVERLAY")
			sectionFrame.title:SetFont(LSM:Fetch('font', section.title.font), section.title.size, section.title.flags)
			sectionFrame.title:SetText(section.title.text)
			sectionFrame.title:SetTextColor(unpack(section.title.color))
			sectionFrame.title:Show()
			sectionFrame.title:ClearAllPoints()
		end
		
		if section.icon.enabled then
			sectionFrame.icon = sectionFrame.icon or sectionFrame:CreateTexture(nil, "OVERLAY")
			sectionFrame.icon:SetTexture(section.icon.texture)
			sectionFrame.icon:Size(section.icon.size, section.icon.size)
			sectionFrame.icon:Show()
			sectionFrame.icon:ClearAllPoints()
		elseif sectionFrame.icon then 
			sectionFrame.icon:Hide() 
			sectionFrame.icon = nil
		end
		
		if section.title.enabled and section.icon.enabled then
			if section.icon.toText then
				sectionFrame.icon:Point(section.icon.point, sectionFrame.title, section.icon.relativeTo, section.icon.xOffset, section.icon.yOffset)
				sectionFrame.title:Point(section.title.point, sectionButtons[1], section.title.relativeTo, section.title.xOffset, section.title.yOffset)
			elseif section.title.toIcon then
				sectionFrame.title:Point(section.title.point, sectionFrame.icon, section.title.relativeTo, section.title.xOffset, section.title.yOffset)
				sectionFrame.icon:Point(section.icon.point, sectionButtons[1], section.icon.relativeTo, section.icon.xOffset, section.icon.yOffset)
			end
		elseif section.title.enabled then
			sectionFrame.title:Point(section.title.point, sectionButtons[1], section.title.relativeTo, section.title.xOffset, section.title.yOffset)
		elseif section.icon.enabled then
			sectionFrame.icon:Point(section.icon.point, sectionButtons[1], section.icon.relativeTo, section.icon.xOffset, section.icon.yOffset)
		end
		
		for i, button in ipairs(sectionButtons) do
			sectionFrame.occupied[i] = B_GetItemID(nil, button.bagID, button.slotID)
		end
		
		local processedSection = {
			frame = sectionFrame,
			buttons = sectionButtons,
			numColumns = numContainerColumns,
			sectionSpacing = db.sectionSpacing,
			db = section,
			order = i,
		}
		
		self:HandleControls(f, processedSection, buttonSize)
		tinsert(processedSections, processedSection)
	end
	
    f.currentLayout = {
        sections = processedSections,
        buttonSize = buttonSize
    }
end

function mod:Layout(self, isBank)
    if not E.private.bags.enable then return end
    local f = B_GetContainerFrame(nil, isBank)
    if not f then return end
	
	local db = E.db.Extras.general[modName]
	if db.SplitStack.enabled or db.EasierProcessing.enabled then
		for i, bagID in ipairs(f.BagIDs) do
			if f.Bags[bagID] then
				for slotID = 1, f.Bags[bagID].numSlots do
					local button = f.Bags[bagID][slotID]
					if button then
						for _, info in pairs(mod.localhooks) do
							for type, script in pairs(info) do 
								if not mod:IsHooked(button, type) then
									mod:SecureHookScript(button, type, function(self, ...) runAllScripts(self, type, ...) end)
								end
							end
						end
					end
				end
			end
		end
	end

	if not db.BagsExtended.enabled then return end
	
	local buttonSpacing = E.Border * 2
	local buttonSize = isBank and B.db.bankSize or B.db.bagSize
	local containerWidth = (isBank and B.db.bankWidth) or B.db.bagWidth
	local numContainerColumns = floor(containerWidth / (buttonSize + buttonSpacing))
	local maxSectionWidth = (numContainerColumns * (buttonSize + buttonSpacing) - buttonSpacing) + buttonSize
	
	f:Width(maxSectionWidth)
	
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
					local name, isHeader, _, _, _, count, _, icon, itemID = GetCurrencyListInfo(i)
					if not isHeader and count > 0 then
						if itemID == 43307 then icon = "Interface\\PVPFrame\\PVP-ArenaPoints-Icon" 
						elseif itemID == 43308 then icon = "Interface\\PVPFrame\\PVP-Currency-"..UnitFactionGroup("player")
						end
						hasCurrencies = true
						local name, _, quality = GetItemInfo(itemID)
						local r, g, b = GetItemQualityColor(quality)
						local iconString = "|T" .. icon .. ":0|t "
						local countText = count
						local pvpCurrency = itemID == 43307 or itemID == 43308
						local emblem = itemID == 40752 or itemID == 40753 or itemID == 45624 or itemID == 47241 or itemID == 49426
						tinsert(lines, { emblem = emblem, pvpCurrency = pvpCurrency, quality = quality, name = name, lineL = iconString..name, lineR = countText, r = r, g = g, b = b, } )
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

	mod:ConfigureContainer(f, isBank, maxSectionWidth, numContainerColumns, buttonSize)
		
	local minIconLeft = huge
	for _, section in ipairs(f.currentLayout.sections) do
		for _, button in ipairs(section.buttons) do
			buttonMap[button.bagID][button.slotID] = section
		end
		mod:ToggleMinimizeSection(f, section, buttonSize)
		if section.db.icon.enabled then
			minIconLeft = min(minIconLeft, section.frame.icon:GetLeft())
		end
		updateSortMethods(section)
		updateCollectionMethods(section)
	end
	
	if minIconLeft < f.holderFrame:GetLeft() then
		local offset = f.holderFrame:GetLeft() - minIconLeft
		local point, parent, relativeTo, x, y = f.holderFrame:GetPoint()
		f.holderFrame:Point(point, parent, relativeTo, offset/2 - buttonSize/4, y)
		f:Width(maxSectionWidth + offset)
	else
		f.holderFrame:ClearAllPoints()
		f.holderFrame:Point("TOP", f, "TOP", -buttonSize/4, -f.topOffset)
		f.holderFrame:Point("BOTTOM", f, "BOTTOM", 0, 8)
	end
	
    mod:ScanBags(f, true)
end

function mod:ResizeFrame(f, buttonSpacing, buttonSize)
    local yOffset = -buttonSize/4
    local totalHeight = f.topOffset + f.bottomOffset
	local layout = f.currentLayout
	
    for i, section in ipairs(layout.sections) do
        section.frame:ClearAllPoints()
        section.frame:Point("TOPLEFT", f.holderFrame, "TOPLEFT", 0, yOffset)

        local sectionHeight = section.frame:GetHeight()
        
        yOffset = yOffset - sectionHeight
		if i == #layout.sections then
			totalHeight = totalHeight + buttonSize/2
		else
            yOffset = yOffset - section.sectionSpacing
            totalHeight = totalHeight + section.sectionSpacing
        end
        totalHeight = totalHeight + sectionHeight
    end

    f:Height(totalHeight)
end

function mod:ScanBags(f, updateLast)
    local changes, inventory = {}, {}
    for _, bagID in ipairs(f.BagIDs) do
        local bag = f.Bags[bagID]
        if bag and bag.numSlots > 0 then
			changes[bagID] = {}
            for slotID = 1, bag.numSlots do
                local button = bag[slotID]
                local itemID = B_GetItemID(nil, bagID, slotID)
                if button and itemID then
                    if not inventory[itemID] then
						local name, _, _, _, _, _, _, maxStack = GetItemInfo(itemID)
                        inventory[itemID] = { positions = {}, count = 0, maxStack = maxStack or 1 }
                    end
                    tinsert(inventory[itemID].positions, {bagID = bagID, slotID = slotID})
                    inventory[itemID].count = inventory[itemID].count + button.count/inventory[itemID].maxStack
                    if not tooltipInfo[itemID] then tooltipInfo[itemID] = lower(gsub(gsub(getItemTooltipText(bagID, slotID), '%s+', ''), '%p+', '')) end
                end
            end
        end
    end

	if not updateLast then
		for itemID, info in pairs(inventory) do
			local lastInfo = lastScan[f][itemID]
			if not lastInfo then
				for _, pos in ipairs(info.positions) do
					changes[pos.bagID][pos.slotID] = itemID
				end
			elseif info.count > lastInfo.count then
				for _, pos in ipairs(info.positions) do
					local isNewPosition = true
					for _, lastPos in ipairs(lastInfo.positions) do
						if pos.bagID == lastPos.bagID and pos.slotID == lastPos.slotID then
							isNewPosition = false
							break
						end
					end
					if isNewPosition then
						changes[pos.bagID][pos.slotID] = itemID
					end
				end
			end
		end
	end
		
    lastScan[f] = inventory
    
    return changes
end

function mod:ApplyBagChanges(f, changes)
	local occupied = {}
	local layout = f.currentLayout
    for bagID, slots in pairs(changes) do
		local index = 1
        for slotID, itemID in pairs(slots) do
            local targetBagID, targetSlotID, section = mod:EvaluateItem(layout.sections, bagID, slotID, itemID)
            if targetBagID and targetSlotID then
				if occupied[targetBagID..'-'..targetSlotID] then
					for _, button in ipairs(section.buttons) do
						local bagID, slotID = button.bagID, button.slotID
						if not occupied[bagID..'-'..slotID] and not button.hasItem then
							targetBagID, targetSlotID = bagID, slotID
							break
						end
					end
				end
                local currentSection = buttonMap[bagID][slotID]
                local targetSection = buttonMap[targetBagID][targetSlotID]
                if currentSection ~= targetSection then
                    B_PickupItem(nil, bagID, slotID)
                    B_PickupItem(nil, targetBagID, targetSlotID)
                    mod:UpdateSection(f, section, layout.buttonSize)
					occupied[targetBagID..'-'..targetSlotID] = true
                end
            end
        end
    end
end

function mod:UpdateBagSlots(self, f, bagID)
    local layout = f.currentLayout
    if not layout then return end
	
	if not equippedBags[bagID] then equippedBags[bagID] = GetBagName(bagID) end
	
    for _, section in ipairs(layout.sections) do
		mod:UpdateSection(f, section, layout.buttonSize)
    end
	
	if updatePending then return end
	updatePending = true
	
	E_Delay(nil, 0.1, function()
		local changes = mod:ScanBags(f)
		mod:ApplyBagChanges(f, changes)
		for bagID, bagName in pairs(equippedBags) do
			if bagName ~= GetBagName(bagID) then
				-- due to increased load (i guess?) introduced by this plugin, real bag removal isn't being registered properly
				equippedBags[bagID] = GetBagName(bagID)
				B:UpdateAll()
			end
		end
		updatePending = false
	end)
end

function mod:UpdateSlot(self, f, bagID, slotID)
	if not f.currentLayout or (f.Bags[bagID] and f.Bags[bagID].numSlots ~= GetContainerNumSlots(bagID)) or not f.Bags[bagID] or not f.Bags[bagID][slotID] then return end
	
    local button = f.Bags[bagID][slotID]
	if button.isHidden then button:Hide() end
end

function mod:UpdateSection(f, section, buttonSize)
    local sectionFrame = section.frame
	
	--if sectionFrame.isBeingSorted then return end
	-- ^ less stutter, but the the hidden buttons flicker

    local buttonSpacing = E.Border * 2
    local sectionHeaderHeight = section.sectionSpacing or 0
    local visibleButtons, lastEmpty = 0, 0
    local oldNumRows = section.numRows or 0

	if sectionFrame.minimized then
        sectionFrame:Height(section.sectionSpacing)
		section.buttons[1]:Point("TOPLEFT", sectionFrame, "TOPLEFT", buttonSpacing, -sectionHeaderHeight/2 - buttonSpacing*2)
		if section.frame.title then
			local minimizedCount = section.frame.minimizedCount or 0
			section.frame.newUnshown = section.frame.newUnshown or {}
			for i, button in ipairs(section.buttons) do
				local occupied, unshown = section.frame.occupied[i], section.frame.newUnshown[i]
				local itemID = B_GetItemID(nil, button.bagID, button.slotID)
				if not occupied or (itemID and occupied ~= itemID) then
					section.frame.occupied[i] = itemID
					if not unshown and itemID then
						minimizedCount = minimizedCount + 1
						section.frame.newUnshown[i] = true
					elseif unshown and not itemID then
						minimizedCount = minimizedCount - 1
						section.frame.newUnshown[i] = false
					end
				elseif section.frame.newUnshown[i] and not itemID then
					section.frame.occupied[i] = false
					section.frame.newUnshown[i] = false
					minimizedCount = minimizedCount - 1
				end
			end
			section.frame.title:SetText(section.db.title.text .. (minimizedCount > 0 and " (+" .. minimizedCount .. ")" or ""))
			section.frame.minimizedCount = max(0, minimizedCount)
		end
		return
    end

	if sectionFrame.expanded then
        visibleButtons = #section.buttons
	else
		for i, button in ipairs(section.buttons) do
			if button.hasItem then
				visibleButtons = i
			end
		end
    end

    for i, button in ipairs(section.buttons) do
		local itemID = B_GetItemID(nil, button.bagID, button.slotID)
		section.frame.occupied[i] = itemID

		if not itemID and i > visibleButtons + 1 then
			button:Hide()
		else
			lastEmpty = i
			button:Show()
			button.isHidden = false
		end

        if button:IsShown() then
            local col = (i - 1) % section.numColumns
            local row = floor((i - 1) / section.numColumns)
            button:Point("TOPLEFT", sectionFrame, "TOPLEFT", 
                            buttonSpacing + col * (buttonSize + buttonSpacing), 
                            -sectionHeaderHeight/2 - buttonSpacing*2 - row * (buttonSize + buttonSpacing))
        end
    end
		
    local emptyCount = #section.buttons - lastEmpty + 1
    if lastEmpty and emptyCount > 0 and not sectionFrame.expanded then
        self:UpdateEmptySlotCount(section.buttons[lastEmpty], emptyCount)
    end

	if sectionFrame.concatenateButton and sectionFrame.expandButton then
		sectionFrame.concatenateButton:ClearAllPoints()
		sectionFrame.concatenateButton:Point("TOPLEFT", section.buttons[lastEmpty], "TOPRIGHT", buttonSpacing, 0)
		sectionFrame.expandButton:ClearAllPoints()
		sectionFrame.expandButton:Point("BOTTOMLEFT", section.buttons[lastEmpty], "BOTTOMRIGHT", buttonSpacing, 0)
	end

    local numRows = ceil(lastEmpty / section.numColumns)
	local totalSectionHeight = sectionHeaderHeight + numRows * (buttonSize + buttonSpacing) - buttonSpacing

    sectionFrame:Height(totalSectionHeight)
	
    if f.currentLayout and numRows ~= oldNumRows then
        self:ResizeFrame(f, buttonSpacing, buttonSize)
    end
	
	section.numRows = numRows
end

function mod:SortSection(sortMap, sectionButtons)
    for i, info in ipairs(sortMap) do
        local targetButton = sectionButtons[i]
        local currentItemID = B_GetItemID(nil, targetButton.bagID, targetButton.slotID)

        if currentItemID ~= info.itemID then
            for j, button in ipairs(sectionButtons) do
                local itemID = B_GetItemID(nil, button.bagID, button.slotID)
                if not sortMap[j].positioned and itemID and itemID == info.itemID then
                    B_PickupItem(nil, button.bagID, button.slotID)
                    B_PickupItem(nil, targetButton.bagID, targetButton.slotID)
					ClearCursor()
                    
                    info.bagID = targetButton.bagID
                    info.slotID = targetButton.slotID
                    break
                end
            end
        else
            info.positioned = true
        end
    end
    
    local allPositioned = true
    for i, info in ipairs(sortMap) do
        if not info.positioned then
            allPositioned = false
            break
        end
    end
    
    return allPositioned
end

function mod:StackSection(buttons)
	local complete = true
	local stacks = {}
	for _, button in ipairs(buttons) do
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

	for _, stack in pairs(stacks) do
		if #stack > 1 then
			tsort(stack, function(a, b) return a.count > b.count end)
			local targetIndex = 1
			for sourceIndex = 2, #stack do
				local target = stack[targetIndex]
				local source = stack[sourceIndex]
				local spaceInTarget = target.maxStack - target.count
				if target.count == target.maxStack then
					targetIndex = targetIndex + 1
				end
				if spaceInTarget > 0 then
					local amountToMove = min(spaceInTarget, source.count)
					B_SplitItem(nil, source.button.bagID, source.button.slotID, amountToMove)
					B_PickupItem(nil, target.button.bagID, target.button.slotID)
					target.count = target.count + amountToMove
					source.count = source.count - amountToMove
					complete = false
				end
			end
		end
	end

	return complete
end

function mod:UpdateEmptySlotCount(button, count)
	if not button then return end

    if count > 1 then
        button.Count:SetText(count)
        button.Count:Show()
    elseif not button.count or button.count < 2 then
        button.Count:Hide()
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

function mod:BagsExtended(enable)
	if enable then
		E.db.bags.reverseSlots = false
		for _, func in pairs({'Layout', 'UpdateSlot', 'UpdateBagSlots', 'SetSlotAlphaForBag', 'ResetSlotAlphaForBags'}) do
			if not self:IsHooked(B, func) then self:SecureHook(B, func) end
		end
		if E.Options.args.bags then
			E.Options.args.bags.args.general.args.reverseSlots.hidden = true
		else
			if not self:IsHooked(E, 'ToggleOptionsUI') then 
				self:SecureHook(E, 'ToggleOptionsUI', function() 
					if not E.Options.args.bags then return end
					
					E.Options.args.bags.args.general.args.reverseSlots.hidden = true 
					E:RefreshGUI()
				end) 
			end
		end
		self:UpdateAll()
		initialized.BagsExtended = true
	elseif initialized.BagsExtended then
		if E.Options.args.bags then E.Options.args.bags.args.general.args.reverseSlots.hidden = false end
		if self:IsHooked(E, 'ToggleOptionsUI') then self:Unhook(E, 'ToggleOptionsUI') end
		for _, func in pairs({'Layout', 'UpdateSlot', 'UpdateBagSlots', 'SetSlotAlphaForBag', 'ResetSlotAlphaForBags'}) do
			if self:IsHooked(B, func) then self:Unhook(B, func) end
		end
		self:UpdateAll(true)
		initialized.BagsExtended = false
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
	ProcessButton:Size(size, size)
	
	ProcessButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(ProcessButton)
		GameTooltip:SetHyperlink(ProcessButton.isKey and ProcessButton.currentSpellID or GetSpellLink(ProcessButton.currentSpellID) or "")
		GameTooltip:Show()
	end)

	ProcessButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	
	return ProcessButton
end

function mod:Process(self)
	local ProcessButton = mod.ProcessButton
	if not ProcessButton then return end
	if InCombatLockdown() then 
		print(core.customColorBad..ERR_NOT_IN_COMBAT) 
		return 
	end
	local modifier = E.db.Extras.general[modName].EasierProcessing.modifier
	if IsModifierKeyDown() and (modifier == 'ANY' or _G['Is'..modifier..'KeyDown']()) then
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
					local itemID = GetContainerItemID(-2, i)
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
			ProcessButton:Point("TOP", self, "TOP", 0, self:GetHeight())
			ProcessButton:Show()
		end
	end
end

function mod:FindEmpty(isBagsExtended, bagSpace)
	if isBagsExtended then
		for _, button in ipairs(bagSpace.buttons) do
			local bagID, slotID = button.bagID, button.slotID
			if not B_GetItemInfo(nil, bagID, slotID) then
				return bagID, slotID
			end
		end
	else
		for _, bagID in ipairs(bagSpace.BagIDs) do
			if bagSpace.Bags[bagID] and bagSpace.Bags[bagID].numSlots > 0 then
				for slotID = 1, GetContainerNumSlots(bagID) do
					if not B_GetItemInfo(nil, bagID, slotID) then
						return bagID, slotID
					end
				end
			end
		end
	end
end

function mod:SplitHandler(self, button)
    local modifier = E.db.Extras.general[modName].SplitStack.modifier
    local isBagsExtended = E.db.Extras.general[modName].BagsExtended.enabled

    if IsModifierKeyDown() and (modifier == 'ANY' or _G['Is'..modifier..'KeyDown']()) then
        local bagID, slotID = self.bagID, self.slotID
        local bagSpace = isBagsExtended and buttonMap[bagID][slotID] or B_GetContainerFrame(nil, bagID < 0 or bagID > NUM_BAG_SLOTS)
		
		if not bagSpace then return end
		
        if button == 'LeftButton' then
            local stackCount = select(2, B_GetItemInfo(nil, bagID, slotID))
            if not stackCount or stackCount == 1 then return end
            
            local split = floor(stackCount / 2)
            local freeBagID, freeSlotID = mod:FindEmpty(isBagsExtended, bagSpace)
			
            if freeSlotID then
                B_SplitItem(nil, bagID, slotID, split)
                B_PickupItem(nil, freeBagID, freeSlotID)
            else
                print(core.customColorBad..ERR_SPLIT_FAILED)
            end
        elseif button == 'RightButton' then
            if not self.isStacking then
                local itemID = B_GetItemID(nil, bagID, slotID)
				if not itemID then return end
				
                self.isStacking = true
                local timeElapsed, partialStacks = 0, {}
                local _, _, _, _, _, _, _, maxStack = GetItemInfo(itemID)

                if isBagsExtended then
                    for _, button in ipairs(bagSpace.buttons) do
                        local buttonBagID, buttonSlotID = button.bagID, button.slotID
                        if B_GetItemID(nil, buttonBagID, buttonSlotID) == itemID then
							tinsert(partialStacks, button)
                        end
                    end
                else
					for _, bagID in ipairs(bagSpace.BagIDs) do
						if bagSpace.Bags[bagID] and bagSpace.Bags[bagID].numSlots > 0 then
							for slotID = 1, GetContainerNumSlots(bagID) do
								if bagSpace.Bags[bagID][slotID] and B_GetItemID(nil, bagID, slotID) == itemID then
									tinsert(partialStacks, bagSpace.Bags[bagID][slotID])
								end
							end
						end
					end
                end
				if #partialStacks == 0 then return end
				
				local stacked, positioned
                self:SetScript('OnUpdate', function(self, elapsed)
                    timeElapsed = timeElapsed + elapsed
                    if timeElapsed > 0.1 then
                        if InCombatLockdown() then 
                            print(core.customColorBad..ERR_NOT_IN_COMBAT)
                            self.isStacking = false
                            self:SetScript('OnUpdate', nil)
                            return 
                        end
                        timeElapsed = 0
                        
                        stacked = mod:StackSection(partialStacks)
						ClearCursor()
                        
                        if stacked then
							positioned = true
							for i = #partialStacks, 1, -1 do
								local button = partialStacks[i]
								local buttonBagID, buttonSlotID = button.bagID, button.slotID
								local buttonItemID = B_GetItemID(nil, buttonBagID, buttonSlotID)
								if buttonItemID then
									local freeBagID, freeSlotID = mod:FindEmpty(isBagsExtended, bagSpace)
									if freeBagID and freeSlotID and (freeBagID ~= buttonBagID or freeSlotID < buttonSlotID) then
										B_PickupItem(nil, buttonBagID, buttonSlotID)
										B_PickupItem(nil, freeBagID, freeSlotID)
										positioned = false
										break
									end
								else
									tremove(partialStacks, i)
								end
							end
							
							if positioned or #partialStacks == 0 then
								self.isStacking = false
								self:SetScript('OnUpdate', nil)
							end
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

function mod:EasierProcessing(enable)
	if enable then
		if not self:IsHooked(B, 'Layout') then self:SecureHook(B, 'Layout') end
		self.localhooks.EasierProcessing = { 
			["OnClick"] = function(self) mod:Process(self) end, 
			["OnHide"] = function() if mod.ProcessButton:IsShown() then mod.ProcessButton:Hide() end end
		}
		self.ProcessButton = self.ProcessButton and self.ProcessButton or self:CreateProcessingButton()
		initialized.EasierProcessing = true
	elseif initialized.EasierProcessing then
		local db = E.db.Extras.general[modName]
		if self:IsHooked(B, 'Layout') and not (db.BagsExtended.enabled or db.SplitStack.enabled) then self:Unhook(B, 'Layout') end
		self.localhooks.EasierProcessing["OnClick"] = false
		self.localhooks.EasierProcessing["OnHide"] = false
		self.ProcessButton:Hide()
		self.ProcessButton = nil
		initialized.EasierProcessing = false
	end
end

function mod:SplitStack(enable)
	if enable then
		if not self:IsHooked(B, 'Layout') then self:SecureHook(B, 'Layout') end
		self.localhooks.SplitStack = { 
			["OnClick"] = function(self, button) mod:SplitHandler(self, button) end 
		}
		self:ModifyStackSplitFrame(true)
		initialized.SplitStack = true
	elseif initialized.SplitStack then
		local db = E.db.Extras.general[modName]
		if self:IsHooked(B, 'Layout') and not (db.BagsExtended.enabled or db.EasierProcessing.enabled) then self:Unhook(B, 'Layout') end
		self.localhooks.SplitStack["OnClick"] = false
		self:ModifyStackSplitFrame(false)
		initialized.SplitStack = false
	end
end


function mod:Toggle()
	local db = E.db.Extras.general[modName]
	self:EasierProcessing(db.EasierProcessing.enabled)
	self:SplitStack(db.SplitStack.enabled)
	self:BagsExtended(db.BagsExtended.enabled)
end

function mod:InitializeCallback()
	mod:LoadConfig()

	if not E.private.bags.enable then return end
	mod:Toggle(E.db.Extras.general[modName].BagsExtended.enabled)
end

core.modules[modName] = mod.InitializeCallback