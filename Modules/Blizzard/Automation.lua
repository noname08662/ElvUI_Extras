local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Automation", "AceHook-3.0", "AceEvent-3.0")

local modName = mod:GetName()

local pairs, select = pairs, select
local tinsert, tsort = table.insert, table.sort
local match, gsub, format = string.match, string.gsub, string.format
local ConfirmLootRoll, LootSlot, GetLootSlotInfo = ConfirmLootRoll, LootSlot, GetLootSlotInfo
local GetNumLootItems, GetLootSlotLink =  GetNumLootItems, GetLootSlotLink
local QuestGetAutoAccept, AcceptQuest, CloseQuest, ConfirmAcceptQuest = QuestGetAutoAccept, AcceptQuest, CloseQuest, ConfirmAcceptQuest
local GetNumQuestChoices, IsQuestCompletable, CompleteQuest, GetQuestReward = GetNumQuestChoices, IsQuestCompletable, CompleteQuest, GetQuestReward
local GossipFrame, GetNumGossipOptions, GetGossipAvailableQuests = GossipFrame, GetNumGossipOptions, GetGossipAvailableQuests
local GetGossipActiveQuests, SelectGossipOption = GetGossipActiveQuests, SelectGossipOption
local StaticPopupDialogs, StaticPopup_Hide = StaticPopupDialogs, StaticPopup_Hide
local IsModifierKeyDown, GetItemInfo = IsModifierKeyDown, GetItemInfo
local localizedQuestItemString = select(12,GetAuctionItemClasses())
local DELETE_ITEM_CONFIRM_STRING = DELETE_ITEM_CONFIRM_STRING

P["Extras"]["blizzard"][modName] = {
	["ConfirmRolls"] = {
		["enabled"] = false,
	},
	["PickupQuest"] = {
		["enabled"] = false,
		["itemsToPickUp"] = {},
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
	core.blizzard.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) db[info[#info-1]][gsub(info[#info], info[#info-1], '')] = value mod:Toggle(db) end,
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
			PickupQuest = {
				type = "group",
				name = L["Quest Items and Money"],
				guiInline = true,
				args = {
					enabledPickupQuest = {
						order = 1,
						type = "toggle",
						width = "full",
						name = core.pluginColor..L["Enable"],
						desc = L["Picks up quest items and money automatically."],
					},
					addItem = {
						order = 2,
						type = "input",
						name = L["Add Item (by ID)"],
						desc = L["More items to pick up automatically."],
						get = function() return "" end,
						set = function(_, value)
							if value and GetItemInfo(value) then
								db.PickupQuest.itemsToPickUp[value] = true
								local _, link, _, _, _, _, _, _, _, icon = GetItemInfo(value)
								core:print('ADDED', '\124T'..gsub(icon, '\124', '\124\124')..':16:16\124t'..link)
							end
						end,
					},
					removeItem = {
						order = 3,
						type = "select",
						name = L["Remove Item"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							db.PickupQuest.itemsToPickUp[value] = nil
							local _, link, _, _, _, _, _, _, _, icon = GetItemInfo(value)
							core:print('REMOVED', '\124T'..gsub(icon, '\124', '\124\124')..':16:16\124t'..link)
						end,
						values = function()
							local values = {}
							for id in pairs(db.PickupQuest.itemsToPickUp or {}) do
								local name, _, _, _, _, _, _, _, _, icon = GetItemInfo(id)
								icon = icon and "|T"..icon..":0|t" or ""
								values[id] = format("%s %s (%s)", icon, name or "", id)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {}
							for id in pairs(db.PickupQuest.itemsToPickUp or {}) do
								tinsert(sortedKeys, id)
							end
							tsort(sortedKeys, function(a, b)
								local nameA = GetItemInfo(a) or ""
								local nameB = GetItemInfo(b) or ""
								return nameA < nameB
							end)
							return sortedKeys
						end,
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
						desc = L["Fills 'DELETE' field automatically."],
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
						desc = L["Selects the first gossip option if it's the only one available unless holding a modifier.\nCareful with important event triggers, there's no fail-safe mechanism."],
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

	if db.PickupQuest.enabled then
		local itemsToPickUp = db.PickupQuest.itemsToPickUp or {}
		self:RegisterEvent('LOOT_OPENED', function()
			for i = 1, GetNumLootItems() do
				local lootLink = GetLootSlotLink(i)
				if lootLink then
					local itemID = match(lootLink, 'item:(%d+)')
					local itemType = select(6,GetItemInfo(itemID))
					if (itemType and itemType == localizedQuestItemString) or itemsToPickUp[itemID] then
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
				StaticPopup_Hide("QUEST_ACCEPT_CONFIRM")
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
			StaticPopup_Hide("CONFIRM_LOOT_ROLL")
		end)
		self:RegisterEvent('CONFIRM_DISENCHANT_ROLL', function(_, id, rollType)
			if not id or not rollType then return end
			ConfirmLootRoll(id, rollType)
			StaticPopup_Hide("CONFIRM_LOOT_ROLL")
		end)
		self:RegisterEvent('LOOT_BIND_CONFIRM', function(_, id, rollType)
			if not id or not rollType then return end
			ConfirmLootRoll(id, rollType)
			StaticPopup_Hide("CONFIRM_LOOT_ROLL")
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
