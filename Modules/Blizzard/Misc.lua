local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("BlizzardMisc.", "AceHook-3.0", "AceEvent-3.0")
local TT = E:GetModule("Tooltip")

local modName = mod:GetName()

mod.initialized = {}

local _G, pairs, ipairs = _G, pairs, ipairs
local gsub, match, format = gsub, string.match, string.format
local WorldFrame, UIErrorsFrame, GetTime, IsModifierKeyDown = WorldFrame, UIErrorsFrame, GetTime, IsModifierKeyDown
local UnitClass, UnitName, GetActionInfo = UnitClass, UnitName, GetActionInfo
local GetMerchantItemCostItem, GetMerchantItemInfo, GetItemCount = GetMerchantItemCostItem, GetMerchantItemInfo, GetItemCount
local MAX_ITEM_COST, MERCHANT_ITEMS_PER_PAGE = MAX_ITEM_COST, MERCHANT_ITEMS_PER_PAGE
local ERR_INV_FULL, ERR_QUEST_LOG_FULL, ERR_RAID_GROUP_ONLY, ERR_PARTY_LFG_BOOT_LIMIT, ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE,
		ERR_PARTY_LFG_BOOT_IN_COMBAT, ERR_PARTY_LFG_BOOT_IN_PROGRESS, ERR_PARTY_LFG_BOOT_LOOT_ROLLS, ERR_PARTY_LFG_TELEPORT_IN_COMBAT,
		ERR_PET_SPELL_DEAD, ERR_PLAYER_DEAD, ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S =
		ERR_INV_FULL, ERR_QUEST_LOG_FULL, ERR_RAID_GROUP_ONLY, ERR_PARTY_LFG_BOOT_LIMIT, ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE,
		ERR_PARTY_LFG_BOOT_IN_COMBAT, ERR_PARTY_LFG_BOOT_IN_PROGRESS, ERR_PARTY_LFG_BOOT_LOOT_ROLLS, ERR_PARTY_LFG_TELEPORT_IN_COMBAT,
		ERR_PET_SPELL_DEAD, ERR_PLAYER_DEAD, ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S


local OrigErrHandler = UIErrorsFrame:GetScript('OnEvent')

P["Extras"]["blizzard"][modName] = {
	["PlayerPings"] = {
		["enabled"] = false,
	},
	["HeldCurrency"] = {
		["enabled"] = false,
	},
	["LetterBox"] = {
		["enabled"] = false,
		["left"] = 0,
		["right"] = 0,
		["top"] = 0,
		["bottom"] = 0,
	},
	["HideErrors"] = {
		["enabled"] = false,
		["showQuestUpdates"] = false,
	},
	["LessTooltips"] = {
		["enabled"] = false,
	},
}

function mod:LoadConfig(db)
	core.blizzard.args[modName] = {
		type = "group",
		name = L["Misc."],
		get = function(info) return db[info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) db[info[#info-1]][gsub(info[#info], info[#info-1], '')] = value self:Toggle(db) end,
		disabled = function(info) return info[#info] ~= modName and not match(info[#info], '^enabled') and not db[info[#info-1]].enabled end,
		args = {
			PlayerPings = {
				type = "group",
				name = L["Player Pings"],
				guiInline = true,
				args = {
					enabledPlayerPings = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Displays the name of the player pinging the minimap."],
					},
				},
			},
			HeldCurrency = {
				type = "group",
				name = L["Held Currency"],
				guiInline = true,
				args = {
					enabledHeldCurrency = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Displays the currently held currency amount next to the item prices."],
					},
				},
			},
			LetterBox = {
				type = "group",
				name = L["LetterBox"],
				guiInline = true,
				args = {
					enabledLetterBox = {
						order = 1,
						type = "toggle",
						width = "full",
						name = core.pluginColor..L["Enable"],
						desc = L["Narrows down the World(..Frame)."],
					},
					left = {
						order = 2,
						type = "range",
						name = L["Left"],
						desc = "",
						min = 0, max = 100, step = 1,
						hidden = function() return not db.LetterBox.enabled end,
					},
					right = {
						order = 3,
						type = "range",
						name = L["Right"],
						desc = "",
						min = 0, max = 100, step = 1,
						hidden = function() return not db.LetterBox.enabled end,
					},
					top = {
						order = 4,
						type = "range",
						name = L["Top"],
						desc = "",
						min = 0, max = 100, step = 1,
						hidden = function() return not db.LetterBox.enabled end,
					},
					bottom = {
						order = 5,
						type = "range",
						name = L["Bottom"],
						desc = "",
						min = 0, max = 100, step = 1,
						hidden = function() return not db.LetterBox.enabled end,
					},
				},
			},
			HideErrors = {
				type = "group",
				name = L["Hide Errors"],
				guiInline = true,
				args = {
					enabledHideErrors = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["'Out of mana', 'Ability is not ready yet', etc."],
					},
					showQuestUpdates = {
						order = 2,
						type = "toggle",
						name = L["Show quest updates"],
						desc = L["Re-enable quest updates."],
						hidden = function() return not db.HideErrors.enabled end,
					},
				},
			},
			LessTooltips = {
				type = "group",
				name = L["Less Tooltips"],
				guiInline = true,
				args = {
					enabledLessTooltips = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."],
					},
				},
			},
		},
	}
end


function mod:CreatePingFrame()
	local PlayerPingFrame = CreateFrame("Frame", nil, Minimap)
	PlayerPingFrame:SetParent(MinimapPing)
	PlayerPingFrame:SetClampedToScreen(true)

	PlayerPingFrame:Height(12)

	local PingText = PlayerPingFrame:CreateFontString(nil, "OVERLAY")
	PingText:FontTemplate()
	PingText:SetAllPoints()

	PlayerPingFrame.PingText = PingText

	return PlayerPingFrame
end

function mod:ShowPlayerPing(playerName)
	local _, playerClass = UnitClass(playerName)
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[playerClass] or RAID_CLASS_COLORS[playerClass]

	mod.PlayerPingFrame.PingText:SetText(playerName)
	mod.PlayerPingFrame.PingText:SetTextColor(classColor and classColor.r or 1, classColor and  classColor.g or 1, classColor and classColor.b or 1)
	mod.PlayerPingFrame:Width(mod.PlayerPingFrame.PingText:GetStringWidth())

	E:UIFrameFadeIn(mod.PlayerPingFrame.PingText, 0.5, 0, 1)
	local mapX, mapY = Minimap:GetCenter()
	local offsetX = mod.PlayerPingFrame.PingText:GetStringWidth() / 2

	mod.PlayerPingFrame.start = GetTime()

	local x, y = MinimapPing:GetCenter()
	x, y = (x > mapX and -1 or 1) * offsetX, (y > mapY and -1 or 1) * 12
	mod.PlayerPingFrame:Point("CENTER", MinimapPing, "CENTER", x, y)
end

function mod:LetterBox(db)
	if db.enabled then
		WorldFrame:SetUserPlaced(true)
		WorldFrame:ClearAllPoints()
		WorldFrame:SetPoint("TOPLEFT", db.left, -db.top)
		WorldFrame:SetPoint("BOTTOMRIGHT", -db.right, db.bottom)
	else
		WorldFrame:SetUserPlaced(false)
		WorldFrame:ClearAllPoints()
		WorldFrame:SetPoint("TOPLEFT")
		WorldFrame:SetPoint("BOTTOMRIGHT")
	end
end

function mod:PlayerPings(db)
	if db.enabled then
		if not self.initialized.PlayerPings then
			self.PlayerPingFrame = self:CreatePingFrame()
			self.initialized.PlayerPings = true
		end
		self:RegisterEvent("MINIMAP_PING", function(_, unit)
			self:ShowPlayerPing(UnitName(unit))
		end)
	elseif self.initialized.PlayerPings then
		self.PlayerPingFrame.PingText:Hide()
		self:UnregisterEvent("MINIMAP_PING")
	end
end

function mod:HeldCurrency(db)
    local function updateAltCurrencyText(merchantItem, itemIndex)
        for j = 1, MAX_ITEM_COST do
            local altCurrencyFrame = _G[merchantItem.."AltCurrencyFrame"]
            local altCurrencyItem = _G[merchantItem.."AltCurrencyFrameItem"..j]
            local altCurrencyText = _G[merchantItem.."AltCurrencyFrameItem"..j.."Text"]

            if altCurrencyFrame and altCurrencyItem and altCurrencyText and altCurrencyFrame:IsShown() then
                local _, itemCount, itemLink = GetMerchantItemCostItem(itemIndex, j)
                if itemCount and itemLink then
                    local playerItemCount = GetItemCount(itemLink)
                    local originalText = altCurrencyText:GetText()
					local existingText = match(originalText, "%((%d+)%)$")
					if playerItemCount > 0 then
						if not existingText then
							altCurrencyText:SetText(originalText .. " (" .. playerItemCount .. ")")
						elseif existingText ~= playerItemCount then
							altCurrencyText:SetText(gsub(originalText, "%((%d+)%)$", "(" .. playerItemCount .. ")"))
						end
                    end
                end
            else
                break
            end
        end
    end

    local function updateMerchantCurrency()
		if not MerchantFrame:IsShown() then return end

		local itemsCount = MERCHANT_ITEMS_PER_PAGE
        for i = 1, itemsCount do
            local merchantItem = "MerchantItem"..i
            local _, _, _, _, _, _, extendedCost = GetMerchantItemInfo(i)
            if extendedCost then
				local offset = (MerchantFrame.page - 1) * itemsCount
				local itemIndex = i + offset
                updateAltCurrencyText(merchantItem, itemIndex)
            end
        end
    end

    if db.enabled then
		local processing = false
		MerchantFrame.heldCurrencyHandler = MerchantFrame.heldCurrencyHandler or CreateFrame("Frame", nil, MerchantFrame)
		MerchantFrame.heldCurrencyHandler:SetScript("OnEvent", function()
			if processing then return end
			processing = true

			E:Delay(0.1, function()
				updateMerchantCurrency()
				processing = false
			end)
		end)
		MerchantFrame.heldCurrencyHandler:SetScript("OnShow", function(self)
			self:RegisterEvent("BAG_UPDATE")
			self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
		end)
		MerchantFrame.heldCurrencyHandler:SetScript("OnHide", function(self)
			self:UnregisterEvent("BAG_UPDATE")
			self:UnregisterEvent("CURRENCY_DISPLAY_UPDATE")
		end)

		if not self:IsHooked("MerchantFrame_UpdateMerchantInfo") then self:SecureHook("MerchantFrame_UpdateMerchantInfo", updateMerchantCurrency) end
		if not self:IsHooked("MerchantFrame_UpdateBuybackInfo") then self:SecureHook("MerchantFrame_UpdateBuybackInfo", updateMerchantCurrency) end
		updateMerchantCurrency()
    else
		if self:IsHooked("MerchantFrame_UpdateMerchantInfo") then self:Unhook("MerchantFrame_UpdateMerchantInfo") end
		if self:IsHooked("MerchantFrame_UpdateBuybackInfo") then self:Unhook("MerchantFrame_UpdateBuybackInfo") end
        for i = 1, MERCHANT_ITEMS_PER_PAGE do
            for j = 1, MAX_ITEM_COST do
                local altCurrencyText = _G["MerchantItem"..i.."AltCurrencyFrameItem"..j.."Text"]
                if altCurrencyText then
                    local text = altCurrencyText:GetText()
                    if text then
                        altCurrencyText:SetText(gsub(text, " %([%d]+%)$", ""))
                    end
                end
            end
        end
    end
end

function mod:HideErrors(db)
	if db.enabled then
		UIErrorsFrame:SetScript('OnEvent', function (self, event, err, ...)
			if event == 'UI_ERROR_MESSAGE' then
				if 	err == ERR_INV_FULL or
					err == ERR_QUEST_LOG_FULL or
					err == ERR_RAID_GROUP_ONLY	or
					err == ERR_PARTY_LFG_BOOT_LIMIT or
					err == ERR_PARTY_LFG_BOOT_DUNGEON_COMPLETE or
					err == ERR_PARTY_LFG_BOOT_IN_COMBAT or
					err == ERR_PARTY_LFG_BOOT_IN_PROGRESS or
					err == ERR_PARTY_LFG_BOOT_LOOT_ROLLS or
					err == ERR_PARTY_LFG_TELEPORT_IN_COMBAT or
					err == ERR_PET_SPELL_DEAD or
					err == ERR_PLAYER_DEAD or
					err:find(format(ERR_PARTY_LFG_BOOT_NOT_ELIGIBLE_S, ".+")) then
					return OrigErrHandler(self, event, err, ...)
				end
			elseif db.showQuestUpdates and event == 'UI_INFO_MESSAGE' then
				return OrigErrHandler(self, event, err, ...)
			end
		end)
	else
		UIErrorsFrame:SetScript('OnEvent', OrigErrHandler)
	end
end

function mod:LessTooltips(db)
	if db.enabled then
		if not self.initialized.LessTooltips then
			function self:GameTooltip_OnTooltipSetStuff(tt)
				if not (IsModifierKeyDown()) and tt:GetAnchorType() == 'ANCHOR_CURSOR' then
					tt:Hide()
					return
				end
			end
			self.initialized.LessTooltips = true
		end
		for _, funcType in ipairs({'Unit', 'Item', 'Spell'}) do
			if not self:IsHooked(TT, "GameTooltip_OnTooltipSet"..funcType) then
				self:SecureHook(TT, "GameTooltip_OnTooltipSet"..funcType, self.GameTooltip_OnTooltipSetStuff)
			end
		end
		if not self:IsHooked("GameTooltip_SetDefaultAnchor") then
			self:SecureHook("GameTooltip_SetDefaultAnchor", function(tt, parent)
				local action = parent._state_action
				if action and GetActionInfo(action) == "macro" then
					self:GameTooltip_OnTooltipSetStuff(tt)
				end
			end)
		end
	elseif self.initialized.LessTooltips then
		if self:IsHooked(TT, "GameTooltip_OnTooltipSetUnit") then self:Unhook(TT, "GameTooltip_OnTooltipSetUnit") end
		if self:IsHooked(TT, "GameTooltip_OnTooltipSetItem") then self:Unhook(TT, "GameTooltip_OnTooltipSetItem") end
		if self:IsHooked(TT, "GameTooltip_OnTooltipSetSpell") then self:Unhook(TT, "GameTooltip_OnTooltipSetSpell") end
		if self:IsHooked(TT, "GameTooltip_SetDefaultAnchor") then self:Unhook(TT, "GameTooltip_SetDefaultAnchor") end
	end
end


function mod:Toggle(db)
	for subMod, info in pairs(db) do
		self[subMod](self, core.reload and {enabled = false} or info)
	end
end

function mod:InitializeCallback()
	local db = E.db.Extras.blizzard[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback