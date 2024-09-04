local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("LootStyle", "AceHook-3.0", "AceEvent-3.0")
local M = E:GetModule("Misc")
local CH = E:GetModule("Chat")
local B = E:GetModule("Blizzard")

local modName = mod:GetName()
local styleHistory, filterApplied, testlootbar
local guildMap, friendMap, indicators, pendingMsgs, messageToSender = {}, {}, {}, {}, {}
local initialized = {}

local _G, unpack, tonumber, select, pairs, ipairs, print, type, next = _G, unpack, tonumber, select, pairs, ipairs, print, type, next
local tinsert, tremove, twipe, tsort, tconcat = table.insert, table.remove, table.wipe, table.sort, table.concat
local lower, find, match, format, gsub, sub, byte, split = string.lower, string.find, string.match, string.format, string.gsub, string.sub, string.byte, string.split
local max, ceil, floor = math.max, math.ceil, math.floor
local UnitClass, UnitName, GetTime, AlertFrame_FixAnchors = UnitClass, UnitName, GetTime, AlertFrame_FixAnchors
local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter
local GetNumFriends, GetFriendInfo, IsInGuild = GetNumFriends, GetFriendInfo, IsInGuild
local GetNumGuildMembers, GetGuildRosterInfo = GetNumGuildMembers, GetGuildRosterInfo
local NUM_CHAT_WINDOWS, RANDOM_ROLL_RESULT, UNKNOWN = NUM_CHAT_WINDOWS, RANDOM_ROLL_RESULT, UNKNOWN
local ERR_FRIEND_ONLINE_SS, ERR_GUILD_JOIN_S = ERR_FRIEND_ONLINE_SS, ERR_GUILD_JOIN_S
local LOOT_MONEY, YOU_LOOT_MONEY, LOOT_MONEY_SPLIT = LOOT_MONEY, YOU_LOOT_MONEY, LOOT_MONEY_SPLIT
local GOLD_AMOUNT, SILVER_AMOUNT, COPPER_AMOUNT = GOLD_AMOUNT, SILVER_AMOUNT, COPPER_AMOUNT
local SPELL_FAILED_TRY_AGAIN, ERR_ITEM_NOT_FOUND, HELPFRAME_ITEM_TITLE = SPELL_FAILED_TRY_AGAIN, ERR_ITEM_NOT_FOUND, HELPFRAME_ITEM_TITLE
local KBASE_SEARCH_RESULTS, BNET_BROADCAST_SENT_TIME = KBASE_SEARCH_RESULTS, BNET_BROADCAST_SENT_TIME
local PLAYER, OPTIONAL, SECONDS, MINUTES = PLAYER, OPTIONAL, SECONDS, MINUTES

local function simulateLootRoll()
	local itemID = 49623
	local name, itemLink, quality = GetItemInfo(itemID)
	local db = E.db.Extras.blizzard[modName].LootBars
	local FRAME_WIDTH, FRAME_HEIGHT = db.widthBar, db.heightBar

	testlootbar = testlootbar or CreateFrame("Frame", "extrastestlootbar", E.UIParent)
	testlootbar:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
	testlootbar:SetTemplate()
	testlootbar:SetFrameStrata("DIALOG")
	testlootbar:SetPoint("TOP", AlertFrameHolder, "BOTTOM", 0, -4)
	testlootbar:Show()

	local itemButton = testlootbar.itemButton or CreateFrame("Button", "$parentIconFrame", testlootbar)
	itemButton:Size(db.sizeIcon)
	itemButton:Point('BOTTOMRIGHT', testlootbar, 'BOTTOMLEFT', -4, 1)
	itemButton:CreateBackdrop()

	itemButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	itemButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetHyperlink(itemLink)
		GameTooltip:Show()
	end)

	itemButton.icon = itemButton:CreateTexture(nil, "OVERLAY")
	itemButton.icon:SetAllPoints()
	itemButton.icon:SetTexCoord(unpack(E.TexCoords))
	itemButton.icon:SetTexture("Interface\\Icons\\INV_Axe_113")

	testlootbar.itemButton = itemButton

	if testlootbar.status then
		testlootbar.status:Hide()
		testlootbar.status = nil
	end

	local status = CreateFrame("StatusBar", "$parentStatusBar", testlootbar)
	status:SetInside()
	status:SetFrameLevel(status:GetFrameLevel() - 1)
	status:SetStatusBarTexture(E.media.normTex)
	status:SetStatusBarColor(0.8, 0.8, 0.8, 0.9)
	testlootbar.status = status

	status.bg = status:CreateTexture(nil, "BACKGROUND")
	status.bg:SetAlpha(0.1)
	status.bg:SetAllPoints()

	local itemName = testlootbar.itemName or testlootbar:CreateFontString(nil, "ARTWORK")
	itemName:FontTemplate(nil, nil, "OUTLINE")
	itemName:Point("BOTTOMLEFT", testlootbar, "TOPLEFT", 4, 0)
	itemName:Point("TOPRIGHT", testlootbar.bindText, "TOPLEFT", -6, 0)
	itemName:SetJustifyH("LEFT")
	itemName:SetText(name)
	testlootbar.itemName = itemName

	testlootbar.bindText = testlootbar.bindText or testlootbar:CreateFontString(nil, "ARTWORK")
	testlootbar.bindText:Point("RIGHT", testlootbar.needButton, "LEFT", 0, 1)
	testlootbar.bindText:FontTemplate(nil, nil, "OUTLINE")
	testlootbar.bindText:SetText("BoP")
	testlootbar.bindText:SetVertexColor(1, 0.3, 0.1)

	testlootbar.passButton = testlootbar.passButton or M:CreateRollButton(testlootbar, 0)
	testlootbar.needButton = testlootbar.needButton or M:CreateRollButton(testlootbar, 1)
	testlootbar.greedButton = testlootbar.greedButton or M:CreateRollButton(testlootbar, 2)
	testlootbar.disenchantButton = testlootbar.disenchantButton or M:CreateRollButton(testlootbar, 3)

	for _, button in ipairs({testlootbar.needButton, testlootbar.greedButton, testlootbar.disenchantButton, testlootbar.passButton}) do
		button:ClearAllPoints()
		button:SetHitRectInsets(0, 0, -2, 0)
		button:SetScript("OnClick", nil)
		button:SetScript("OnEnter", nil)
		button:SetScript("OnLeave", nil)
	end

	testlootbar.passButton:Point("BOTTOMRIGHT", testlootbar, "TOPRIGHT", -4, 0)
	testlootbar.disenchantButton:Point("RIGHT", testlootbar.passButton, "LEFT", 0, -1)
	testlootbar.greedButton:Point("RIGHT", testlootbar.disenchantButton, "LEFT", 1, -2)
	testlootbar.needButton:Point("RIGHT", testlootbar.greedButton, "LEFT", 1, 1)
	testlootbar.bindText:Point("RIGHT", testlootbar.needButton, "LEFT", 0, 1)

	local color = ITEM_QUALITY_COLORS[quality]
	status:SetStatusBarColor(color.r, color.g, color.b, 0.7)
	status.bg:SetTexture(color.r, color.g, color.b)

	local rollTime = 15
	status:SetMinMaxValues(0, rollTime)
	status:SetValue(rollTime)

	local p, pa, re, x, y = testlootbar:GetPoint()
	testlootbar:ClearAllPoints()
	testlootbar:Point(p, pa, re, x, p == 'TOP' and (y - (db.sizeIcon - FRAME_HEIGHT / 2)) or (y + (db.sizeIcon + FRAME_HEIGHT / 2)))

	testlootbar:SetScript("OnUpdate", function(self, elapsed)
		rollTime = rollTime - elapsed
		status:SetValue(rollTime)
		if rollTime < 0 then
			self:Hide()
		end
	end)
end

local chatMsgs = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_YELL",
    "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_WHISPER",
    "CHAT_MSG_PARTY",
    "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID",
    "CHAT_MSG_RAID_LEADER",
    "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_OFFICER",
    "CHAT_MSG_EMOTE",
    "CHAT_MSG_TEXT_EMOTE",
    "CHAT_MSG_MONSTER_SAY",
    "CHAT_MSG_MONSTER_YELL",
    "CHAT_MSG_MONSTER_WHISPER",
    "CHAT_MSG_MONSTER_EMOTE",
    "CHAT_MSG_CHANNEL",
    "CHAT_MSG_SYSTEM",
    "CHAT_MSG_ACHIEVEMENT",
    "CHAT_MSG_GUILD_ACHIEVEMENT",
    "CHAT_MSG_BG_SYSTEM_NEUTRAL",
    "CHAT_MSG_BG_SYSTEM_ALLIANCE",
    "CHAT_MSG_BG_SYSTEM_HORDE",
    "CHAT_MSG_RAID_BOSS_EMOTE",
    "CHAT_MSG_RAID_BOSS_WHISPER",
    "CHAT_MSG_INSTANCE_CHAT",
    "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_BATTLEGROUND_LEADER"
}

local classNameToID = {
    [LOCALIZED_CLASS_NAMES_MALE.WARRIOR] = "WARRIOR",
    [LOCALIZED_CLASS_NAMES_MALE.PALADIN] = "PALADIN",
    [LOCALIZED_CLASS_NAMES_MALE.HUNTER] = "HUNTER",
    [LOCALIZED_CLASS_NAMES_MALE.ROGUE] = "ROGUE",
    [LOCALIZED_CLASS_NAMES_MALE.PRIEST] = "PRIEST",
    [LOCALIZED_CLASS_NAMES_MALE.DEATHKNIGHT] = "DEATHKNIGHT",
    [LOCALIZED_CLASS_NAMES_MALE.SHAMAN] = "SHAMAN",
    [LOCALIZED_CLASS_NAMES_MALE.MAGE] = "MAGE",
    [LOCALIZED_CLASS_NAMES_MALE.WARLOCK] = "WARLOCK",
    [LOCALIZED_CLASS_NAMES_MALE.DRUID] = "DRUID",
    [LOCALIZED_CLASS_NAMES_FEMALE.WARRIOR] = "WARRIOR",
    [LOCALIZED_CLASS_NAMES_FEMALE.PALADIN] = "PALADIN",
    [LOCALIZED_CLASS_NAMES_FEMALE.HUNTER] = "HUNTER",
    [LOCALIZED_CLASS_NAMES_FEMALE.ROGUE] = "ROGUE",
    [LOCALIZED_CLASS_NAMES_FEMALE.PRIEST] = "PRIEST",
    [LOCALIZED_CLASS_NAMES_FEMALE.DEATHKNIGHT] = "DEATHKNIGHT",
    [LOCALIZED_CLASS_NAMES_FEMALE.SHAMAN] = "SHAMAN",
    [LOCALIZED_CLASS_NAMES_FEMALE.MAGE] = "MAGE",
    [LOCALIZED_CLASS_NAMES_FEMALE.WARLOCK] = "WARLOCK",
    [LOCALIZED_CLASS_NAMES_FEMALE.DRUID] = "DRUID",
}
--[[
	1 - need
	2 - greed
	3 - disenchant
	4 - everone passed
	5 - passed
	6 - won
--]]
local rollMsgs = {
	{ LOOT_ROLL_NEED, LOOT_ROLL_NEED_SELF, LOOT_ROLL_ROLLED_NEED },
	{ LOOT_ROLL_GREED, LOOT_ROLL_GREED_SELF, LOOT_ROLL_ROLLED_GREED },
	{ LOOT_ROLL_DISENCHANT, LOOT_ROLL_DISENCHANT_SELF, LOOT_ROLL_ROLLED_DE },
	{ LOOT_ROLL_ALL_PASSED },
	{ LOOT_ROLL_PASSED, LOOT_ROLL_PASSED_AUTO, LOOT_ROLL_PASSED_AUTO_FEMALE, LOOT_ROLL_PASSED_SELF, LOOT_ROLL_PASSED_SELF_AUTO },
	{ LOOT_ROLL_WON, LOOT_ROLL_WON_NO_SPAM_DE, LOOT_ROLL_WON_NO_SPAM_GREED, LOOT_ROLL_WON_NO_SPAM_NEED },
	{ LOOT_ITEM, LOOT_ITEM_MULTIPLE },
}

local rollIcons = {
	"Interface\\BUTTONS\\UI-GroupLoot-Dice-Up",
	"Interface\\BUTTONS\\UI-GroupLoot-Coin-Up",
	"Interface\\BUTTONS\\UI-GroupLoot-DE-Up",
	"Interface\\BUTTONS\\UI-GroupLoot-Pass-Up",
	"Interface\\BUTTONS\\UI-GROUPLOOT-PASS-HIGHLIGHT"
}

local rollMsgsProcessed = {}
for type, messages in ipairs(rollMsgs) do
    rollMsgsProcessed[type] = {}
    for i, message in ipairs(messages) do
        local processedMessage = {}
        local formattedMsg = format(message, 1, 1, 1, 1, 1)
        local parts = { split(1, formattedMsg) }
        for j, part in ipairs(parts) do
            part = gsub(part, "[1%s%p%d]+", "")
            if part ~= "" and part ~= "x" then
                tinsert(processedMessage, part)
            end
        end
        rollMsgsProcessed[type][i] = processedMessage
    end
end

local function parseEventMsg(msg)
    msg = gsub(gsub(gsub(msg, '|[tT].+|[tT]', ''), '|%x%x%x%x%x%x%x%x%x.+|[hH]|[rR][%w-]*', ''), '[%s%p%d]', '')

	for type, messages in pairs(rollMsgsProcessed) do
        for _, processedMessage in ipairs(messages) do
            local tempMsg = msg
            local matched = true
            for _, part in ipairs(processedMessage) do
                if not find(tempMsg, part) then
                    matched = false
                    break
                end
                tempMsg = gsub(tempMsg, part, "", 1)
            end
            if matched then
                return type, tempMsg
            end
        end
    end
    return nil, nil
end

local function updateChatHooks(enable)
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		if frame.AddMessage then
			if enable then
				if not mod:IsHooked(frame, "AddMessage") then
					mod:RawHook(frame, "AddMessage", true)
				end
			elseif mod:IsHooked(frame, "AddMessage") then
				mod:Unhook(frame, "AddMessage")
			end
		end
	end
end

local function getClassColor(class)
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	return format("|cff%02x%02x%02x", classColor.r * 255, classColor.g * 255, classColor.b * 255)
end


-- hook early
if not mod:IsHooked(CH, "DisplayChatHistory") then
	mod:RawHook(CH, "DisplayChatHistory", function(self)
		local data = ElvCharacterDB.ChatHistoryLog
		if not next(data) then return end
		if E.db.Extras.blizzard[modName].StyledMsgs.enabled and not styleHistory then
			styleHistory = data
			return
		end
		mod.hooks[CH].DisplayChatHistory(self)
	end)
end


P["Extras"]["blizzard"][modName] = {
	["LootInfo"] = {
		["enabled"] = false,
	},
	["StyledMsgs"] = {
		["enabled"] = false,
		["selected"] = "friend",
		["self"] = { ["indicator"] = "•", ["color"] = { PASSIVE_SPELL_FONT_COLOR.r, PASSIVE_SPELL_FONT_COLOR.g, PASSIVE_SPELL_FONT_COLOR.b } },
		["friend"] = { ["indicator"] = "•", ["color"] = { ORANGE_FONT_COLOR.r, ORANGE_FONT_COLOR.g, ORANGE_FONT_COLOR.b } },
		["guild"] = { ["indicator"] = "•", ["color"] = { GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b } },
	},
	["StyledLootings"] = {
		["enabled"] = false,
		["iconSize"] = 16,
	},
	["LootBars"] = {
		["enabled"] = false,
		["sizeIcon"] = 26,
		["heightBar"] = 12,
		["widthBar"] = 312,
	},
}

function mod:LoadConfig()
	local function selected() return E.db.Extras.blizzard[modName].StyledMsgs.selected end
	core.blizzard.args[modName] = {
		type = "group",
		name = L["Loot&Style"],
		get = function(info) return E.db.Extras.blizzard[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
		set = function(info, value) E.db.Extras.blizzard[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] = value mod:Toggle() end,
		disabled = function(info) return info[#info] ~= modName and not match(info[#info], '^enabled') and not E.db.Extras.blizzard[modName][info[#info-1]].enabled end,
		args = {
			LootInfo = {
				type = "group",
				name = L["Loot Info"],
				guiInline = true,
				args = {
					enabledLootInfo = {
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["/lootinfo slash command to get a quick rundown of the recent lootings."..
						"\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name "..
						"\n(search @self to get player loot)\n'60' - "..
						"\ntime limit (<60 seconds ago), optional,"..
						"\n/lootinfo !wipe - purge loot cache."],
					},
				},
			},
			StyledMsgs = {
				type = "group",
				name = L["Styled Messages"],
				guiInline = true,
				get = function(info) return unpack(E.db.Extras.blizzard[modName].StyledMsgs[selected()][info[#info]]) end,
				set = function(info, r, g, b)
					E.db.Extras.blizzard[modName].StyledMsgs[selected()][info[#info]] = { r, g, b }
					self:StyledMsgs(E.db.Extras.blizzard[modName].StyledMsgs.enabled)
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Colors online friends' and guildmates' names in some of the messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."],
						get = function() return E.db.Extras.blizzard[modName].StyledMsgs.enabled end,
						set = function(_, value)
							E.db.Extras.blizzard[modName].StyledMsgs.enabled = value
							self:StyledMsgs(value)
						end,
					},
					color = {
						order = 2,
						type = "color",
						name = L["Indicator Color"],
						desc = "",
						hidden = function() return not E.db.Extras.blizzard[modName].StyledMsgs.enabled end,
					},
					selected = {
						order = 3,
						type = "select",
						name = L["Select Status"],
						desc = "",
						get = function() return E.db.Extras.blizzard[modName].StyledMsgs.selected end,
						set = function(_, value) E.db.Extras.blizzard[modName].StyledMsgs.selected = value end,
						hidden = function() return not E.db.Extras.blizzard[modName].StyledMsgs.enabled end,
						values = {
							["self"] = L["Self"],
							["friend"] = L["Friend"],
							["guild"] = L["Guildmate"],
						},
					},
					indicator = {
						order = 4,
						type = "select",
						name = L["Select Indicator"],
						desc = "",
						get = function() return E.db.Extras.blizzard[modName].StyledMsgs[selected()].indicator end,
						set = function(_, value)
							E.db.Extras.blizzard[modName].StyledMsgs[selected()].indicator = value
							self:StyledMsgs(E.db.Extras.blizzard[modName].StyledMsgs.enabled)
						end,
						hidden = function() return not E.db.Extras.blizzard[modName].StyledMsgs.enabled end,
						values = {
							["~"] = "~",
							["!"] = "!",
							["-"] = "-",
							["+"] = "+",
							["ˆ"] = "ˆ",
							["*"] = "*",
							["_"] = "_",
							["x"] = "x",
                            ["•"] = "•",
							["°"] = "°",
							["◊"] = "◊",
							["¤"] = "¤",
							["_XxX_"] = "_XxX_",
							["NONE"] = L["None"],
						},
					},
				},
			},
			StyledLootings = {
				type = "group",
				name = L["Styled Loot Messages"],
				guiInline = true,
				args = {
					enabledStyledLootings = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Colors loot roll messages for you and other players."],
					},
					iconSize = {
						type = "range",
						order = 2,
						min = 8, max = 32, step = 1,
						name = L["Icon Size"],
						desc = L["Loot rolls icon size."],
						hidden = function() return not E.db.Extras.blizzard[modName].StyledLootings.enabled end,
					},
				},
			},
			LootBars = {
				type = "group",
				name = L["Loot Bars"],
				guiInline = true,
				get = function(info) return E.db.Extras.blizzard[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] end,
				set = function(info, value) E.db.Extras.blizzard[modName][info[#info-1]][gsub(info[#info], info[#info-1], '')] = value simulateLootRoll() mod:Toggle() end,
				args = {
					enabledLootBars = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Restyles loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."],
					},
					sizeIcon = {
						order = 2,
						type = "range",
						min = 8, max = 36, step = 1,
						name = L["Icon Size"],
						desc = "",
						hidden = function() return not E.db.Extras.blizzard[modName].LootBars.enabled end,
					},
					heightBar = {
						order = 3,
						type = "range",
						min = 4, max = 24, step = 1,
						name = L["Bar Height"],
						desc = "",
						hidden = function() return not E.db.Extras.blizzard[modName].LootBars.enabled end,
					},
					widthBar = {
						order = 4,
						type = "range",
						min = 40, max = 600, step = 1,
						name = L["Bar Width"],
						desc = "",
						hidden = function() return not E.db.Extras.blizzard[modName].LootBars.enabled end,
					},
				},
			},
		},
	}
end


function mod:StyledMsgs(enable)
    if enable then
        local db = E.db.Extras.blizzard[modName].StyledMsgs
        indicators["self"] = {indicator = db.self.indicator, color = format("|cff%02x%02x%02x", db.self.color[1] * 255, db.self.color[2] * 255, db.self.color[3] * 255)}
        indicators["friend"] = {indicator = db.friend.indicator, color = format("|cff%02x%02x%02x", db.friend.color[1] * 255, db.friend.color[2] * 255, db.friend.color[3] * 255)}
        indicators["guild"] = {indicator = db.guild.indicator, color = format("|cff%02x%02x%02x", db.guild.color[1] * 255, db.guild.color[2] * 255, db.guild.color[3] * 255)}

		if not initialized.StyledMsgs then
			local myname, myclass = E.myname, E.myclass
			local playerName = lower(myname)
			local friendOnlineMsgProcessed = gsub(tconcat({split(1, format(gsub(ERR_FRIEND_ONLINE_SS, '[%[%]]',''), 1, 1))}), "|H.+|h", "")
			local _, playerJoinsGuild = split(1, format(ERR_GUILD_JOIN_S, 1))
			local _, part1, part2, part3 = split(1, format(RANDOM_ROLL_RESULT, 1, 1, 1, 1))
			part2 = match(part2 or "", ".*%.") or match(part3 or "", ".*%.") or false

			function mod:UpdateFriendMap()
				twipe(friendMap)
				for i = 1, GetNumFriends() do
					local friendName, _, friendClass = GetFriendInfo(i)
					if friendName and friendClass ~= UNKNOWN then
						friendMap[lower(friendName)] = classNameToID[friendClass]
					end
				end
			end

			function mod:UpdateGuildMap()
				twipe(guildMap)
				for i = 1, GetNumGuildMembers() do
					local guildName, _, _, _, _, _, _, _, isOnline, _, guildClass = GetGuildRosterInfo(i)
					if guildName and isOnline and guildName ~= myname then guildMap[lower(guildName)] = guildClass end
				end
			end

			function mod:GetPlayerRelationship(name)
				if name == playerName then
					return "self", myclass
				elseif friendMap[name] then
					return "friend", friendMap[name]
				elseif guildMap[name] then
					return "guild", guildMap[name]
				end
				return nil
			end

			function mod:GetPlayerInfo(playerName)
				local relationship, relClass = self:GetPlayerRelationship(playerName)
				if relationship and indicators[relationship].indicator ~= "NONE" then
					local info = indicators[relationship]
					return relationship, relClass, info.indicator, info.color
				end
			end

			local function getString(playerName, indicator, indicatorColor, classColor)
				local parts = {}

				if indicator then
					tinsert(parts, indicatorColor)
					tinsert(parts, indicator)
					tinsert(parts, '|r')
				end

				tinsert(parts, classColor or '')
				tinsert(parts, playerName)

				if indicator then
					tinsert(parts, indicatorColor)
					tinsert(parts, indicator)
					tinsert(parts, '|r')
				else
					tinsert(parts, '|r')
				end

				return tconcat(parts)
			end

			local function formatPlayerName(playerName, isPlayer)
				local _, relClass, indicator, indicatorColor

				if isPlayer then
					_, relClass = "self", myclass
					local db = indicators["self"]
					if db.indicator ~= "NONE" then
						indicatorColor = db.color
						indicator = db.indicator
					end
				else
					_, relClass, indicator, indicatorColor = mod:GetPlayerInfo(lower(playerName))
				end

				if relClass then
					return getString(playerName, indicator, indicatorColor, getClassColor(relClass) or '')
				end

				return playerName
			end

			local function stripMsg(msg)
				local strippedMsg, msgMap = "", {}
				local i, j = 1, 1
				local tempMsg = lower(msg)
				local len = #tempMsg

				local colorPattern = "^|c%x%x%x%x%x%x%x%x"
				local linkPattern = "(.-|h)(.-)|h"
				local codePattern = "^|%d%p%d%((.+)%)"

				-- timestamps
				local stampStart, stampEnd = find(msg, "^[|%x]*%[[|:%d%s%xaApPmMr]*%][|rR]*[|%x%x%x%x%x%x%x%x%x]*%s*")

				if stampStart then
					i = stampEnd + 1
				end

				-- strip junk text and store real positions
				while i <= len do
					local b1, b2 = byte(tempMsg, i, i+1)

					if b1 == 124 then -- '|, code start'
						if b2 == 99 then -- 'c, color code'
							if find(tempMsg, colorPattern, i) then
								i = i + 10
							else
								i = i + 1
							end
						elseif b2 == 114 then -- 'r, color breaker'
							i = i + 2
						elseif b2 == 104 then -- 'h, hyperlink code'
							local _, linkEnd, link = find(tempMsg, linkPattern, i+2)
							if link then -- 'afaik, player links are only available in combat log, which i don't want to style'
								i = linkEnd + 1
							else
								i = i + 2
							end
						elseif b2 == 116 then -- 't, texture code'
							i = (find(tempMsg, "|t", i+2) or i) + 2
						elseif find(tempMsg, codePattern, i) then -- 'localization bs'
							local _, codeEnd = find(tempMsg, codePattern, i)
							i = i + 5
							while i <= codeEnd do
								if i == codeEnd then
									i = i + 1
								else
									local _, linkEnd, link = find(tempMsg, linkPattern, i+2)
									if link then
										i = linkEnd + 1
									else
										i = i + 2
									end
								end
							end
						else
							strippedMsg = strippedMsg .. sub(msg, i, i)
							msgMap[j], i, j = i, i + 1, j + 1
						end
					elseif find(tempMsg, "^[%p%d%s]", i) then
						i = i + 1
					else
						strippedMsg = strippedMsg .. sub(msg, i, i)
						msgMap[j], i, j = i, i + 1, j + 1
					end
				end

				return strippedMsg, msgMap
			end

			local function handleFound(strippedMsg, strippedLower, playerName, msgMap, isPlayer)
				local replacements = {}
				local nameStart, nameEnd = find(strippedLower, lower(playerName))
				while nameStart do
					local originalName = sub(strippedMsg, nameStart, nameEnd)
					local formattedName = formatPlayerName(originalName, isPlayer)
					tinsert(replacements, {
						start = msgMap[nameStart],
						endPos = msgMap[nameEnd],
						replacement = formattedName
					})
					nameStart, nameEnd = find(strippedLower, lower(playerName), nameEnd + 1)
				end
				return replacements
			end

			local function handleNormalMessage(msg)
				local strippedMsg, msgMap = stripMsg(msg)
				local strippedLower = lower(strippedMsg)
				local replacements = {}
				local handledNames = {[playerName] = true}

				for _, rep in ipairs(handleFound(strippedMsg, strippedLower, playerName, msgMap, true)) do
					tinsert(replacements, rep)
				end

				for _, map in ipairs({friendMap, guildMap}) do
					for name in pairs(map) do
						if not handledNames[name] then
							for _, rep in ipairs(handleFound(strippedMsg, strippedLower, name, msgMap)) do
								tinsert(replacements, rep)
							end
							handledNames[name] = true
						end
					end
				end

				tsort(replacements, function(a, b) return a.start > b.start end)

				for _, rep in ipairs(replacements) do
					msg = sub(msg, 1, rep.start - 1) .. rep.replacement .. sub(msg, rep.endPos + 1)
				end

				return msg
			end

			local function handleRollMessage(msg)
				local playerName, rollResult, rollStart, rollEnd = match(msg, '[%p%d]*([^%p*]+)'..part1..'%D*(%d+).*(%d+)%D+(%d+)')
				local playerClass = playerName and select(2, UnitClass(playerName))

				if playerClass then
					rollResult, rollStart, rollEnd = tonumber(rollResult), tonumber(rollStart), tonumber(rollEnd)

					local color
					if rollStart == 1 and rollEnd == 100 then
						local valuePercent = (rollResult - rollStart + 1) / (rollEnd - rollStart + 1)
						local r, g, b = playerName == UnitName('player') and 1 - valuePercent or valuePercent, playerName == UnitName('player') and valuePercent or 1 - valuePercent, 0
						color = format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
					else
						color = core.customColorAlpha
					end

					local _, _, indicator, indicatorColor = mod:GetPlayerInfo(lower(playerName))
					local formattedName = getString(playerName, indicator, indicatorColor, getClassColor(playerClass) or '')

					msg = gsub(msg, rollResult, color .."[".. rollResult .. "]|r", 1)
					msg = gsub(msg, playerName, formattedName)
					if rollStart == 1 and rollEnd == 100 then
						local _, newMsgEndIndex = find(msg, part2 or rollResult .. "]|r")
						msg = sub(msg, 1, newMsgEndIndex)
					end
				end
				return msg
			end

			function mod:StyledMsgsFilter(event, msg, ...)
				if event == "CHAT_MSG_ACHIEVEMENT" then
					local playerName = ...
					local formattedName = formatPlayerName(playerName, playerName == myname)
					msg = gsub(msg, '%%s', format('|Hplayer:%s|h[%s]|h', playerName, formattedName), 1)
					return false, msg, formattedName, ...
				elseif event == "CHAT_MSG_SYSTEM" then
					if find(msg, part1) then
						return false, handleRollMessage(msg), ...
					elseif find(msg, playerJoinsGuild) then
						local playerName = match(msg, '[%p%d]*([^%p*]+)'..playerJoinsGuild)
						local playerNameLower = lower(playerName)
						if not guildMap[playerNameLower] then
							tinsert(pendingMsgs, {playerName = playerNameLower, msg = msg, args = {...}})
							return true
						else
							return false, handleNormalMessage(msg), ...
						end
					elseif find(msg, friendOnlineMsgProcessed) then
						local playerName = match(msg, '%[(.+)%]')
						local playerNameLower = lower(playerName)
						if IsInGuild() and not friendMap[playerNameLower] and not guildMap[playerNameLower] then
							tinsert(pendingMsgs, {playerName = playerNameLower, msg = msg, args = {...}})
							return true
						else
							msg = gsub(msg, '|Hplayer:.+|h%[(.+)%]|h', format('|Hplayer:%s|h[%s]|h', playerName, formatPlayerName(playerName)), 1)
							return false, msg, ...
						end
					end
				end
				return false, handleNormalMessage(msg), ...
			end

			function mod:StyleName(playerName)
				return formatPlayerName(playerName)
			end

			function mod:StyleMessage(msg)
				return handleNormalMessage(msg)
			end

			function mod:UpdateMessages()
				for i = #pendingMsgs, 1, -1 do
					local info = pendingMsgs[i]
					local playerName, msg = info.playerName, info.msg
					local playerClass = guildMap[playerName]
					if playerClass then
						for j = 1, NUM_CHAT_WINDOWS do
							local chatFrame = _G["ChatFrame"..j]
							if chatFrame and chatFrame:IsEventRegistered("CHAT_MSG_SYSTEM") then
								ChatFrame_MessageEventHandler(chatFrame, "CHAT_MSG_SYSTEM", msg, unpack(info.args))
							end
						end
						tremove(pendingMsgs, i)
					end
				end
			end

			function mod:AddMessage(frame, msg, ...)
				local formattedMessage = gsub(msg, "|Hplayer:(.-)|h%[(.-)%]|h", function(link, playerName)
					local colorlessName = find(playerName, "|[rR]") and match(playerName, "|%x%x%x%x%x%x%x%x%x(.+)|[rR]") or playerName

					if find(colorlessName, "|%x%x%x%x%x%x%x%x%x") then
						local colorPatterns = {}

						colorlessName = gsub(playerName, "|(%x%x%x%x%x%x%x%x%x)([^|]+)", function(color, text)
							tinsert(colorPatterns, {color = color, text = text})
							return text
						end)
						colorlessName = gsub(gsub(colorlessName, "|%x%x%x%x%x%x%x%x%x", ""), "|[rR]", "")

						local formattedName = formatPlayerName(colorlessName)

						if formattedName ~= colorlessName then
							local coloredName = colorlessName
							for _, pattern in ipairs(colorPatterns) do
								coloredName = gsub(coloredName, pattern.text, format("|%s%s", pattern.color, pattern.text), 1)
							end
							return format("|Hplayer:%s|h[%s]|h", link, gsub(formattedName, colorlessName, coloredName))
						else
							return format("|Hplayer:%s|h[%s]|h", link, playerName)
						end
					else
						local formattedName = formatPlayerName(colorlessName)

						if formattedName ~= colorlessName then
							return format("|Hplayer:%s|h[%s]|h", link, formattedName)
						else
							return format("|Hplayer:%s|h[%s]|h", link, playerName)
						end
					end
				end)

				mod.hooks[frame].AddMessage(frame, formattedMessage, ...)
			end

			self:UpdateFriendMap()
			self:UpdateGuildMap()

			if styleHistory then
				for _, d in ipairs(styleHistory) do
					if type(d) == "table" then
						if d[52] and self:GetPlayerRelationship(lower(d[2])) then d[52] = self:StyleName(d[2]) end
						if not d["styled"] then
							d[1] = self:StyleMessage(d[1])
							d["styled"] = true
						end
					end
				end
				CH:DisplayChatHistory()
			end

			initialized.StyledMsgs = true
		end

        for _, type in ipairs(chatMsgs) do
            ChatFrame_AddMessageEventFilter(type, mod.StyledMsgsFilter)
        end

		if not E.db.Extras.blizzard[modName].StyledLootings.enabled then
			ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", mod.StyledMsgsFilter)
			ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", mod.StyledMsgsFilter)
			filterApplied = true
		end

		self:RegisterEvent("FRIENDLIST_UPDATE", self.UpdateFriendMap)
		self:RegisterEvent("GUILD_ROSTER_UPDATE", function()
			self:UpdateGuildMap()
			if #pendingMsgs > 0 then
				self:UpdateMessages()
			end
		end)

		if not self:IsHooked("FCF_OpenNewWindow") then
			self:SecureHook("FCF_OpenNewWindow", function() updateChatHooks(db.enabled) end)
		end

		if M.BubbleFrame and not self:IsHooked(M.BubbleFrame, "OnEvent") then
			self:SecureHookScript(M.BubbleFrame, "OnEvent", function(self, _, msg, sender) messageToSender[msg] = sender end)
		end

		if not self:IsHooked(M, "UpdateBubbleBorder") then
			self:SecureHook(M, "UpdateBubbleBorder", function(self)
				if not self.text then return end
				if E.private.general.chatBubbles == "backdrop" then
					local text = self.text:GetText()
					local name = messageToSender[text]
					if not name then return end
					local rel = mod:GetPlayerRelationship(lower(name))
					if rel then
						local color = db[rel].color
						local r, g, b = color[1], color[2], color[3]
						if E.PixelMode then
							self:SetBackdropBorderColor(r, g, b)
						else
							self.bordertop:SetTexture(r, g, b)
							self.borderbottom:SetTexture(r, g, b)
							self.borderleft:SetTexture(r, g, b)
							self.borderright:SetTexture(r, g, b)
						end
						messageToSender[text] = nil
					end
				end
				local msg = mod:StyleMessage(self.text:GetText())
				self.text:SetText(msg)
			end)
		end

		if not self:IsHooked(M, "AddChatBubbleName") then
			self:RawHook(M, "AddChatBubbleName", function(self, chatBubble, guid, name)
				if not name then return end
				chatBubble.Name:SetFormattedText("%s", mod:StyleName(name))
			end)
		end
    elseif initialized.StyledMsgs then
        for _, type in ipairs(chatMsgs) do
            ChatFrame_RemoveMessageEventFilter(type, mod.StyledMsgsFilter)
        end

		if filterApplied then
			ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", mod.StyledMsgsFilter)
			ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONEY", mod.StyledMsgsFilter)
			if E.db.Extras.blizzard[modName].StyledLootings.enabled then
				ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", mod.StyledLootingsFilter)
				ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", mod.StyledLootingsFilter)
			end
			filterApplied = false
		end

		self:UnregisterEvent("GUILD_ROSTER_UPDATE")
		if self:IsHooked("FCF_OpenNewWindow") then self:Unhook("FCF_OpenNewWindow") end
		if self:IsHooked(M, "UpdateBubbleBorder") then self:Unhook(M, "UpdateBubbleBorder") end
		if self:IsHooked(M, "AddChatBubbleName") then self:Unhook(M, "AddChatBubbleName") end

		local data = ElvCharacterDB.ChatHistoryLog
		if next(data) then
			for _, d in ipairs(data) do
				if type(d) == "table" then
					if d[52] then d[52] = CH:GetColoredName(d[50], _, d[2], _, _, _, _, _, d[8], _, _, _, d[12]) end
					if d["styled"] then
						for _, info in pairs(indicators) do
							d[1] = gsub(d[1], info.color..info.indicator.."|r", "")
						end
						d["styled"] = false
					end
				end
			end
		end
    end
	updateChatHooks(enable)
end

function mod:StyledLootings(enable)
    if enable then
		if not initialized.StyledLootings then
			local moneyMsgsProcessed = {}
			local _, moneyMsgLOOT_MONEY = split(1, format(LOOT_MONEY, 1, 1))
			local goldProcessed, silverProcessed, copperProcessed = gsub(format(GOLD_AMOUNT, 1), 1, ""), gsub(format(SILVER_AMOUNT, 1), 1, ""), gsub(format(COPPER_AMOUNT, 1), 1, "")
			local styledb = E.db.Extras.blizzard[modName].StyledMsgs

			for _, message in ipairs({YOU_LOOT_MONEY, LOOT_MONEY_SPLIT}) do
				local lootmsg = split(1, format(message, 1))
				tinsert(moneyMsgsProcessed, lootmsg)
			end

			local function processMoney(msg)
				msg = gsub(msg, "(%d*)"..goldProcessed,
					"|cffffd700%1|r|TInterface\\MoneyFrame\\UI-GoldIcon:12:12:0:0|t", 1)
				msg = gsub(msg, "(%d*)"..silverProcessed,
					"|cffc0c0c0%1|r|TInterface\\MoneyFrame\\UI-SilverIcon:12:12:0:0|t", 1)
				msg = gsub(msg, "(%d*)"..copperProcessed,
					"|cffb87333%1|r|TInterface\\MoneyFrame\\UI-CopperIcon:12:12:0:0|t", 1)
				return "+"..gsub(msg, "(.*|t).*", "%1")
			end

			local function formatPlayerName(playerName, playerClass)
				if styledb.enabled then
					local _, relClass, indicator, indicatorColor = mod:GetPlayerInfo(lower(playerName))

					return format("%s%s|r%s%s|r%s%s|r", indicatorColor, indicator, getClassColor(relClass), playerName, indicatorColor, indicator)
				else
					return format("%s%s|r", getClassColor(playerClass), playerName)
				end
			end

			function mod:StyledLootingsFilter(event, msg, ...)
				if event == 'CHAT_MSG_MONEY' then
					for _, lootmsg in ipairs(moneyMsgsProcessed) do
						if find(msg, lootmsg) then
							return false, processMoney(gsub(msg, lootmsg, "", 1)), ...
						end
					end
					if find(msg, moneyMsgLOOT_MONEY) then
						local playerName = match(msg, '(%S+)'..moneyMsgLOOT_MONEY)
						local _, playerClass = UnitClass(playerName)
						local formattedName = formatPlayerName(playerName, playerClass)
						local processedMoney = processMoney(match(msg, moneyMsgLOOT_MONEY..'(.+)'))
						return false, format("%s, %s", processedMoney, formattedName), ...
					end
					return false, msg, ...
				end

				local itemLink, quantity = match(msg, '(|cff.+|h|r)([%w-]*)')
				local rollType, playerName = parseEventMsg(msg)
				local playerClass = playerName and select(2,UnitClass(playerName))
				local rollResult = match(gsub(gsub(gsub(msg, '|cff.+|h|r', ''), playerName and '%|.*%('..playerName..'%)' or '', ''), '|T.+|t', ''), '(%d+)')

				if rollType and rollType < 6 then
					local iconSize = E.db.Extras.blizzard[modName].StyledLootings.iconSize
					if playerClass then
						local formattedName = formatPlayerName(playerName, playerClass)

						if not rollResult then
							return false, format("[\124T%s:%d\124t]|r%s%s, %s", rollIcons[rollType], iconSize, itemLink, quantity, formattedName), ...
						end

						local valuePercent = (tonumber(rollResult)) / 100
						local r, g, b = playerName == UnitName('player') and 1 - valuePercent or valuePercent, playerName == UnitName('player') and valuePercent or 1 - valuePercent, 0
						local rollColor = format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)

						return false, format("%s[%d\124T%s:%d\124t]|r%s%s, %s", rollColor, rollResult, rollIcons[rollType], iconSize, itemLink, quantity, formattedName), ...
					else
						return false, format("[\124T%s:%d\124t]|r%s%s", rollIcons[rollType], iconSize, itemLink, quantity), ...
					end
				elseif playerClass then
					local formattedName = formatPlayerName(playerName, playerClass)
					return false, format("+%s%s, %s%s", itemLink, quantity, formattedName, mod.lootInfoPrints or ''), ...
				else
					return false, format("+%s%s%s", itemLink, quantity, mod.lootInfoPrints or ''), ...
				end
			end

			initialized.StyledLootings = true
		end
        ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", mod.StyledLootingsFilter)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", mod.StyledLootingsFilter)
		if filterApplied then
			ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", mod.StyledMsgsFilter)
			ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONEY", mod.StyledMsgsFilter)
			filterApplied = false
		end
    elseif initialized.StyledLootings then
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_LOOT", mod.StyledLootingsFilter)
        ChatFrame_RemoveMessageEventFilter("CHAT_MSG_MONEY", mod.StyledLootingsFilter)
		if E.db.Extras.blizzard[modName].StyledMsgs.enabled then
			ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", mod.StyledMsgsFilter)
			ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", mod.StyledMsgsFilter)
			filterApplied = true
		end
    end
end

function mod:LootInfo(enable)
	if enable then
		if not initialized.LootInfo then
			local function round(num)
				local decimal = num % 1
				if decimal >= 0.5 then
					return ceil(num)
				else
					return floor(num)
				end
			end

			local lootMessages = {}
			local index = 1
			function mod:CHAT_MSG_LOOT(_, msg, ...)
				local rollType, playerName = parseEventMsg(msg)
				if rollType and rollType < 6 then return end

				lootMessages[index] = { msg = msg, args = {...}, timestamp = GetTime(), isPlayer = not playerName or playerName == YOU }

				index = index % 256 + 1
			end

			function mod:GetLootMessages(itemName, timeLimit)
				local lootMessagesFound = {}
				tsort(lootMessages, function(a,b)
					if a.isPlayer ~= b.isPlayer then
						return not a.isPlayer
					else
						return a.timestamp < b.timestamp
					end
				end)
				for _, lootMessage in ipairs(lootMessages) do
					local msg = lower(gsub(lootMessage.msg, '|[hH].*%[', ''))
					if (not tonumber(timeLimit) or (lootMessage.timestamp > GetTime() - tonumber(timeLimit))) and
						(find(msg, itemName, 1, true) or (find(itemName, '@self', 1, true) and lootMessage.isPlayer)) then
						tinsert(lootMessagesFound, lootMessage)
					end
				end
				return lootMessagesFound
			end

			function mod:LootInfoCommand(msg)
				if lower(msg) == '!wipe' then twipe(lootMessages) print(core.customColorBeta..L["Loot info wiped."]) return end
				local itemName, timeLimit = match(msg, '^([^%s]+)%s*(%d*)$')

				if not itemName then
					print(core.customColorBad..SPELL_FAILED_TRY_AGAIN..".")
					print(core.customColorBeta.."/lootinfo"..core.customColorAlpha..' '..HELPFRAME_ITEM_TITLE..'/'..PLAYER..' (60 - '..OPTIONAL..')')
					print(core.customColorBeta.."/lootinfo"..core.customColorAlpha..' !wipe')
					return
				end

				local looters = self:GetLootMessages(lower(itemName), timeLimit)

				if find(itemName, '@self', 1, true) then
					itemName = UnitName('player')
				end

				if #looters == 0 then
					print(core.customColorBeta..ERR_ITEM_NOT_FOUND)
				else
					local styled = E.db.Extras.blizzard[modName].StyledLootings.enabled
					print(core.customColorBeta..KBASE_SEARCH_RESULTS..":", '"'..core.customColorAlpha..itemName.."|r"..core.customColorBeta..'"')
					for _, lootMessage in ipairs(looters) do
						local msg = lootMessage.msg
						local timePassed = round(GetTime() - lootMessage.timestamp)

						local timeStamp
						local timeUnit
						if timePassed > 60 then
							timeStamp = floor(timePassed / 60)
							timeUnit = MINUTES
						else
							timeStamp = timePassed
							timeUnit = SECONDS
						end

						if styled then
							self.lootInfoPrints = (timeLimit and (core.customColorAlpha..' - '..lower(format(BNET_BROADCAST_SENT_TIME, timeStamp ..' '..timeUnit))) or '')
							ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, "CHAT_MSG_LOOT", msg, unpack(lootMessage.args))
							self.lootInfoPrints = false
						else
							ChatFrame_MessageEventHandler(DEFAULT_CHAT_FRAME, "CHAT_MSG_LOOT",
								msg .. (timeLimit and (lower(format(' '..core.customColorAlpha..'- '..BNET_BROADCAST_SENT_TIME, timeStamp ..' '..timeUnit))) or ''),
								unpack(lootMessage.args))
						end
					end
				end
			end
			initialized.LootInfo = true
		end
		self:RegisterEvent("CHAT_MSG_LOOT")
		SLASH_LOOTINFO1 = "/lootinfo"
		SlashCmdList["LOOTINFO"] = function(msg) mod:LootInfoCommand(msg) end
	elseif initialized.LootInfo then
		self:UnregisterEvent("CHAT_MSG_LOOT")
		SLASH_LOOTINFO1 = nil
		SlashCmdList["LOOTINFO"] = nil
		hash_SlashCmdList["/LOOTINFO"] = nil
	end
end

function mod:LootBars(enable)
	local db = E.db.Extras.blizzard[modName].LootBars

	local function updateBars()
		for _, frame in pairs(M.RollBars) do
			local p, pa, re, x, y = frame:GetPoint()
			frame:Height(db.heightBar)
			frame:Width(db.widthBar)
			frame.itemButton:ClearAllPoints()
			frame.itemButton:Point('BOTTOMRIGHT', frame, 'BOTTOMLEFT', -4, 1)
			frame.itemButton:Size(db.sizeIcon)
			frame.needButton:ClearAllPoints()
			frame.greedButton:ClearAllPoints()
			frame.disenchantButton:ClearAllPoints()
			frame.passButton:ClearAllPoints()
			frame.bindText:ClearAllPoints()
			frame.itemName:ClearAllPoints()
			frame.passButton:Point("BOTTOMRIGHT", frame, "TOPRIGHT", -4, -0)
			frame.disenchantButton:Point("RIGHT", frame.passButton, "LEFT", 0, -1)
			frame.greedButton:Point("RIGHT", frame.disenchantButton, "LEFT", 1, -2)
			frame.needButton:Point("RIGHT", frame.greedButton, "LEFT", 1, 1)
			frame.bindText:Point("RIGHT", frame.needButton, "LEFT", 0, 1)
			frame.itemName:Point("BOTTOMLEFT", frame, "TOPLEFT", 4, 0)
			frame.itemName:Point("TOPRIGHT", frame.bindText, "TOPLEFT", -6, 0)
			frame:ClearAllPoints()
			frame:Point(p, pa, re, x, p == 'TOP' and (y - (max(26, db.sizeIcon) - db.heightBar/2)) or (y + (max(26, db.sizeIcon) + db.heightBar/2)))
		end
	end

	if enable then
		local passBarsUpdate = false
		if not E.private.general.lootRoll then E.private.general.lootRoll = true E:StaticPopup_Show("PRIVATE_RL") end
		if not self:IsHooked(E, "PostAlertMove") then
			self:SecureHook(E, "PostAlertMove", function()
				if passBarsUpdate then return end
				updateBars()

				passBarsUpdate = true
				AlertFrame_FixAnchors()
				passBarsUpdate = false
			end)
		end
		if B:IsHooked("AlertFrame_FixAnchors") then B:Unhook("AlertFrame_FixAnchors") end
		B:SecureHook("AlertFrame_FixAnchors", E.PostAlertMove)

		AlertFrame_FixAnchors()
	elseif self:IsHooked(E, "PostAlertMove") then
		self:Unhook(E, "PostAlertMove")

		if M.numFrames > 1 then
			for _, frame in pairs(M.RollBars) do
				frame:Size(328, 28)
				frame.itemButton:Size(28 - (E.Border * 2))
				frame.itemButton:ClearAllPoints()
				frame.itemButton:Point("RIGHT", frame, "LEFT", -(E.Spacing * 3), 0)
				frame.itemButton:Size(db.sizeIcon, db.sizeIcon)
				frame.needButton:ClearAllPoints()
				frame.greedButton:ClearAllPoints()
				frame.disenchantButton:ClearAllPoints()
				frame.passButton:ClearAllPoints()
				frame.bindText:ClearAllPoints()
				frame.itemName:ClearAllPoints()
				frame.needButton:Point("LEFT", frame.itemButton, "RIGHT", 4, -1)
				frame.greedButton:Point("LEFT", frame.needButton, "RIGHT", 1, -1)
				frame.disenchantButton:Point("LEFT", frame.greedButton, "RIGHT", 0, 1)
				frame.passButton:Point("LEFT", frame.disenchantButton, "RIGHT", 0, 2)
				frame.bindText:Point("LEFT", frame.passButton, "RIGHT", 2, 0)
				frame.itemName:Point("LEFT", frame.bindText, "RIGHT", 1, 0)
				frame.itemName:Point("RIGHT", frame, "RIGHT", -5, 0)
			end
			AlertFrame_FixAnchors()
		end
	end
end


function mod:Toggle()
	for mod, info in pairs(E.db.Extras.blizzard[modName]) do
		self[mod](self, info.enabled)
	end
end

function mod:InitializeCallback()
	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback