local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Chat", "AceHook-3.0")
local S = E:GetModule("Skins")
local CH = E:GetModule("Chat")
local EMB = E.modules.EmbedSystem and E:GetModule("EmbedSystem")
local LSM = E.Libs.LSM

local modName = mod:GetName()

mod.initialized = {}

local chatTypeIndexToName = {}
local lastHisoryMsgIndex = {}
local filteredMsgs, searchResults = {}, {}
local savedChatState, blockedMsgs = {}, {}
local recentQueries = {}

local flashingButtons = {}
local MessageEventHandlerPreHooks, MessageEventHandlerPostHooks = {}, {}
local alertingTabs = {right = {}, left = {}}

local historyIndex = 1
local hlR, hlB, hlG = 1, 1, 1
local prompts, queries = {}, {}
local parseOr, parseAnd, parseTerm
local rBad, gBad, bBad
local copyChatLines

local chatEnabled = E.private.chat.enable

local localizedTypes = {
	["SAY"] = L["Say"],
	["YELL"] = L["Yell"],
	["PARTY"] = L["Party"],
	["RAID"] = L["Raid"],
	["GUILD"] = L["Guild"],
	["BATTLEGROUND"] = L["Battleground"],
	["WHISPER"] = L["Whisper"],
	["CHANNEL"] = L["Channel"],
	["OTHER"] = L["Other"],
}

local chatTypes = {
	["LIVE"] = true,
	["HISTORY"] = true,
	["ALL"] = true,
	["SAY"] = true,
	["YELL"] = true,
	["PARTY"] = true,
	["RAID"] = true,
	["GUILD"] = true,
	["BATTLEGROUND"] = true,
	["WHISPER"] = true,
	["CHANNEL"] = true,
	["OTHER"] = true
}

local date = date
local min, max = math.min, math.max
local _G, pairs, ipairs, next, unpack, tonumber = _G, pairs, ipairs, next, unpack, tonumber
local gsub, find, match, byte, sub = string.gsub, string.find, string.match, string.byte, string.sub
local upper, lower, reverse, format, len = string.upper, string.lower, string.reverse, string.format, string.len
local tinsert, tremove, twipe, tsort, tconcat, tcontains = table.insert, table.remove, table.wipe, table.sort, table.concat, tContains
local UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo = UIDropDownMenu_Initialize, UIDropDownMenu_CreateInfo
local UIDropDownMenu_AddButton = UIDropDownMenu_AddButton
local CloseDropDownMenus, ToggleDropDownMenu = CloseDropDownMenus, ToggleDropDownMenu
local InCombatLockdown, IsCombatLog = InCombatLockdown, IsCombatLog
local UIParent, ShowUIPanel = UIParent, ShowUIPanel
local UIFrameFlash, UIFrameFlashRemoveFrame = UIFrameFlash, UIFrameFlashRemoveFrame
local PlaySoundFile, Chat_GetChatCategory, MouseIsOver = PlaySoundFile, Chat_GetChatCategory, MouseIsOver
local IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown, IsModifierKeyDown = IsShiftKeyDown, IsAltKeyDown, IsControlKeyDown, IsModifierKeyDown
local NUM_CHAT_WINDOWS, CHAT_FRAMES, FONT_SIZE, FONT_SIZE_TEMPLATE = NUM_CHAT_WINDOWS, CHAT_FRAMES, FONT_SIZE, FONT_SIZE_TEMPLATE
local NEW_CHAT_WINDOW, RESET_ALL_WINDOWS, RENAME_CHAT_WINDOW = NEW_CHAT_WINDOW, RESET_ALL_WINDOWS, RENAME_CHAT_WINDOW
local CLOSE_CHAT_WINDOW, CHAT_CONFIGURATION = CLOSE_CHAT_WINDOW, CHAT_CONFIGURATION

local E_Delay, E_UIFrameFadeIn, E_UIFrameFadeOut = E.Delay, E.UIFrameFadeIn, E.UIFrameFadeOut

local colorPattern = "^|c%x%x%x%x%x%x%x%x"
local linkPattern = "(.-|h)(.-)|h"
local codePattern = "^|%d%p%d%((.+)%)"

for chatType in pairs(ChatTypeInfo) do
	chatTypeIndexToName[GetChatTypeIndex(chatType)] = chatType
end

for _, frameName in ipairs(CHAT_FRAMES) do
	lastHisoryMsgIndex[_G[frameName]] = 1
end

local function colorLine(msg, origColor)
	if lower(origColor) == "|cffffffff" then return msg end

	if not find(msg, "^|%x%x%x%x%x%x%x%x%x") then msg = origColor..msg end

    return gsub(msg, "(|[rR])([^|]*)", "%1"..origColor.."%2")
end

local function getChatTypeFromMessage(msg)
    local linkType, linkInfo = match(msg, "|H(%w+):([^|]+)")

    if linkType == "channel" then
        local channelType = match(linkInfo, "^(%w+)")
        return channelType and (channelType == "OFFICER" and "GUILD" or channelType)
    elseif linkType == "player" then
        local _, chatType = match(linkInfo, "^[^:]+:(%d+):(%w+)")
        return chatType == nil and "OTHER" or chatType == "channel" and "CHANNEL" or chatType
    end

    if match(msg, "^%[.*%].*:") then
        local channelName = match(msg, "^%[(.-)%]")
        if tonumber(channelName) then
            return "CHANNEL"
        else
            return "WHISPER"
        end
    else
        return "OTHER"
    end
end

local function isRightChatTab(chat)
	local rightChatLeft = RightChatPanel:GetLeft()
    local rightChatRight = RightChatPanel:GetRight()
    local chatLeft = chat:GetLeft()
    local chatRight = chat:GetRight()

    if chatLeft and chatRight and rightChatLeft and rightChatRight then
        if chatLeft >= rightChatLeft and chatRight <= rightChatRight then
            return true
        end
    end
end


local function restoreChatState(frame, isUpdate)
	CH.db.copyChatLines = false

	frame.displayingSearchResults = true
    frame:Clear()

	if not isUpdate then
        for _, info in ipairs(savedChatState[frame]) do
            frame:AddMessage(info.msg)
        end
    end

	local targetTable = frame.displayingFiltered and filteredMsgs[frame].raw or blockedMsgs[frame]
	local maxLines = frame:GetMaxLines()
	local numMessages = #targetTable

    for i = max(1, numMessages - maxLines + 1), numMessages do
        frame:AddMessage(unpack(targetTable[i]))
    end

	twipe(targetTable)

	CH.db.copyChatLines = copyChatLines
	frame.displayingSearchResults = nil
end

local function updateChatState(frame)
	restoreChatState(frame, true)

	local targetTable = frame.displayingFiltered and filteredMsgs[frame].processed or savedChatState[frame]
	local maxLines = frame:GetMaxLines()
	local numMessages = frame:GetNumMessages()
	local ChatTypeInfo = ChatTypeInfo
	for i = min(maxLines, numMessages), 1, -1 do
		local msg, _, lineID = frame:GetMessageInfo(numMessages - i + 1)
		local chatType = chatTypeIndexToName[lineID]
        local info = ChatTypeInfo[chatType]
		local origColor = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255)
		tinsert(targetTable, {msg = colorLine(msg, origColor), chatType = chatType})
	end
end

local function saveChatState(frame)
	twipe(savedChatState[frame])

    local maxLines = frame:GetMaxLines()
    local numMessages = frame:GetNumMessages()
	local ChatTypeInfo = ChatTypeInfo
    for i = 1, min(maxLines, numMessages) do
        local msg, _, lineID = frame:GetMessageInfo(numMessages - i + 1)
		local chatType = chatTypeIndexToName[lineID]
        local info = ChatTypeInfo[chatType]
        local origColor = format("|cff%02x%02x%02x", info.r * 255, info.g * 255, info.b * 255)
        tinsert(savedChatState[frame], 1, {msg = colorLine(msg, origColor), chatType = chatType})
    end

	if frame.displayingFiltered then
		updateChatState(frame)
	end
end


if E.db.chat.chatHistory then
	if not mod:IsHooked(CH, "DisplayChatHistory") then
		mod.soundTimer = true
		mod:SecureHook(CH, "DisplayChatHistory", function(self)
			for _, frameName in ipairs(CHAT_FRAMES) do
				local frame = _G[frameName]
				lastHisoryMsgIndex[frame] = frame:GetNumMessages()
			end

			if not mod:IsHooked(CH, "ChatFrame_MessageEventHandler") then
				mod:RawHook(CH, "ChatFrame_MessageEventHandler", function(self, frame, event, ...)
					for _, func in pairs(MessageEventHandlerPreHooks) do
						func(self, frame, event, ...)
					end

					mod.hooks[CH].ChatFrame_MessageEventHandler(self, frame, event, ...)

					for _, func in pairs(MessageEventHandlerPostHooks) do
						func(self, frame, event, ...)
					end
				end)
			end

			tinsert(MessageEventHandlerPreHooks, function()
				CH.SoundTimer = true
			end)

			tinsert(MessageEventHandlerPostHooks, function()
				CH.SoundTimer = nil
			end)

			mod.soundTimer = nil
		end)
	end
elseif not mod:IsHooked(CH, "ChatFrame_MessageEventHandler") then
	mod:RawHook(CH, "ChatFrame_MessageEventHandler", function(self, frame, event, ...)
		for _, func in pairs(MessageEventHandlerPreHooks) do
			func(self, frame, event, ...)
		end

		mod.hooks[CH].ChatFrame_MessageEventHandler(self, frame, event, ...)

		for _, func in pairs(MessageEventHandlerPostHooks) do
			func(self, frame, event, ...)
		end
	end)

	tinsert(MessageEventHandlerPreHooks, function()
		CH.SoundTimer = true
	end)

	tinsert(MessageEventHandlerPostHooks, function()
		CH.SoundTimer = nil
	end)
end

if not mod:IsHooked(CH, "AddMessage") then
	mod:RawHook(CH, "AddMessage", function(self, msg, infoR, infoG, infoB, infoID, accessID, typeID, extraData, isHistory, historyTime)
		if not find(msg, "^[|%x]*%[[|:%d%s%xaApPmMr]*%][|rR]*%s*") then
			mod.hooks[CH].AddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID, extraData, isHistory, historyTime)
		else
			local curStampFormat = CH.db.timeStampFormat
			CH.db.timeStampFormat = "NONE"
			mod.hooks[CH].AddMessage(self, msg, infoR, infoG, infoB, infoID, accessID, typeID, extraData, isHistory, historyTime)
			CH.db.timeStampFormat = curStampFormat
		end
	end)
end


local function setupHooks(db)
	local function filterMessage(frame, msg, r, g, b, lineID, ...)
		if frame.displayingSearchResults then return end

		local chatType = chatTypeIndexToName[lineID]
		if chatType and mod:FilterNotPassed(frame, msg, match(chatType, "%P*")) then
			tinsert(filteredMsgs[frame].raw, {msg, r, g, b, lineID, ...})
			return true
		end
	end

	local function playSound(chatType, cleanMsg)
		if not find(cleanMsg, "^%p+"..E.myname) and not mod.soundTimer and (not CH.db.noAlertInCombat or not InCombatLockdown()) then
			local chatGroup = Chat_GetChatCategory(chatType)
			local channels = chatGroup ~= "WHISPER" and chatGroup or (chatType == "WHISPER" or chatType == "BN_WHISPER") and "WHISPER"
			local alertType = CH.db.channelAlerts[channels]

			if alertType and alertType ~= "None" then
				PlaySoundFile(LSM:Fetch("sound", alertType), "Master")
				mod.soundTimer = E_Delay(nil, 1, function() mod.soundTimer = nil end)
			end
		end
	end

	local function processMessageElv(frame, displayingFiltered, displayingSearchResults, msg, r, g, b, lineID, ...)
		local chatType = chatTypeIndexToName[lineID]

		if frame:searchActive() and not displayingSearchResults then
			local query = frame.searchBar:GetText()

			if not displayingFiltered then
				tinsert(blockedMsgs[frame], {msg, r, g, b, lineID, ...})
			end

			if query == "" then
				if not displayingFiltered then
					local cleanMsg = mod:StripMsg(msg)
					playSound(chatType, cleanMsg)
				end
				return
			end

			local queryTree = mod:ParseExpression(mod:Tokenize(query))
			local highlight_patterns = {}

			local validType = frame.searchArgs["LIVE"]

			if validType then
				if not frame.searchArgs["ALL"] then
					local extractedChatType = getChatTypeFromMessage(msg)
					validType = frame.searchArgs[extractedChatType]
				end

				if not validType then return end

				local cleanMsg, msgMap = mod:StripMsg(msg)
				local cleanMsgLower = lower(cleanMsg)
				if mod:MatchPattern(queryTree, highlight_patterns, cleanMsg, cleanMsgLower) then
					if frame.searchNoResults then
						frame:Clear()
						frame.searchNoResults = nil
					end

					if not displayingFiltered then
						playSound(chatType, cleanMsg)
					end
					mod.hooks[frame].AddMessage(frame, mod:HighlightText(msg, cleanMsg, cleanMsgLower, msgMap, highlight_patterns), r, g, b, lineID, ...)
				end
			end
		else
			if not displayingSearchResults then
				local cleanMsg = mod:StripMsg(msg)
				playSound(chatType, cleanMsg)
			end

			if not frame:searchActive() and frame:GetNumMessages() >= frame:GetMaxLines() then
				lastHisoryMsgIndex[frame] = lastHisoryMsgIndex[frame] - 1
			end
			mod.hooks[frame].AddMessage(frame, msg, r, g, b, lineID, ...)
		end
	end

	local function processMessage(frame, displayingFiltered, displayingSearchResults, msg, r, g, b, lineID, ...)
		if frame:searchActive() and not displayingSearchResults then
			local query = frame.searchBar:GetText()

			if not displayingFiltered then
				tinsert(blockedMsgs[frame], {msg, r, g, b, lineID, ...})
			end

			if query == "" then
				return
			end

			local queryTree = mod:ParseExpression(mod:Tokenize(query))
			local highlight_patterns = {}

			local validType = frame.searchArgs["LIVE"]

			if validType then
				if not frame.searchArgs["ALL"] then
					local extractedChatType = getChatTypeFromMessage(msg)
					validType = frame.searchArgs[extractedChatType]
				end

				if not validType then return end

				local cleanMsg, msgMap = mod:StripMsg(msg)
				local cleanMsgLower = lower(cleanMsg)
				if mod:MatchPattern(queryTree, highlight_patterns, cleanMsg, cleanMsgLower) then
					if frame.searchNoResults then
						frame:Clear()
						frame.searchNoResults = nil
					end
					mod.hooks[frame].AddMessage(frame, mod:HighlightText(msg, cleanMsg, cleanMsgLower, msgMap, highlight_patterns), r, g, b, lineID, ...)
				end
			end
		else
			if not frame:searchActive() and frame:GetNumMessages() >= frame:GetMaxLines() then
				lastHisoryMsgIndex[frame] = lastHisoryMsgIndex[frame] - 1
			end
			mod.hooks[frame].AddMessage(frame, msg, r, g, b, lineID, ...)
		end
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		if not IsCombatLog(frame) then
			if db.enabled then
				if not mod:IsHooked(frame, "SetMaxLines") then
					mod:RawHook(frame, "SetMaxLines", function(self, maxLines)
						self.searchBar:Hide()
						mod.hooks[self].SetMaxLines(self, maxLines)
					end, true)
				end
				if chatEnabled then
					if not mod:IsHooked(frame, "AddMessage") then
						mod:RawHook(frame, "AddMessage", function(self, msg, r, g, b, lineID, ...)
							local filtered = filterMessage(self, msg, r, g, b, lineID, ...)
							local displayingFiltered = self.displayingFiltered
							local displayingSearchResults = self.displayingSearchResults

							if displayingFiltered then
								if displayingSearchResults or filtered then
									processMessageElv(self, displayingFiltered, displayingSearchResults, msg, r, g, b, lineID, ...)
								else
									tinsert(blockedMsgs[self], {msg, r, g, b, lineID, ...})
									local chatType = chatTypeIndexToName[lineID]
									local cleanMsg = mod:StripMsg(msg)
									playSound(chatType, cleanMsg)
								end
							elseif not filtered then
								processMessageElv(self, displayingFiltered, displayingSearchResults, msg, r, g, b, lineID, ...)
							end
						end, true)
					end
				elseif not mod:IsHooked(frame, "AddMessage") then
					mod:RawHook(frame, "AddMessage", function(self, msg, r, g, b, lineID, ...)
						local filtered = filterMessage(self, msg, r, g, b, lineID, ...)
						local displayingFiltered = self.displayingFiltered
						local displayingSearchResults = self.displayingSearchResults

						if displayingFiltered then
							if displayingSearchResults or filtered then
								processMessage(self, displayingFiltered, displayingSearchResults, msg, r, g, b, lineID, ...)
							else
								tinsert(blockedMsgs[self], {msg, r, g, b, lineID, ...})
							end
						elseif not filtered then
							processMessage(self, displayingFiltered, displayingSearchResults, msg, r, g, b, lineID, ...)
						end
					end, true)
				end
			else
				if mod:IsHooked(frame, "AddMessage") then mod:Unhook(frame, "AddMessage") end
				if mod:IsHooked(frame, "SetMaxLines") then mod:Unhook(frame, "SetMaxLines") end
				if mod:IsHooked(CH, "ChatFrame_MessageEventHandler") then mod:Unhook(CH, "ChatFrame_MessageEventHandler") end
			end
		end
	end

	if db.enabled then
		if not mod:IsHooked("FCF_Tab_OnClick") then
			mod:SecureHook("FCF_Tab_OnClick", function(tab)
				local frame = _G["ChatFrame"..tab:GetID()]
				if not IsCombatLog(frame) and frame:searchActive() then
					frame.searchBar:Show()
				end
			end)
		end
		if E.Options and E.Options.args.chat then
			if not mod:IsHooked(E.Options.args.chat, "set") then
				mod:SecureHook(E.Options.args.chat, "set", function(info, value)
					if info[#info] == 'copyChatLines' then
						copyChatLines = value
					end
				end)
			end
		elseif not mod:IsHooked(E, "ToggleOptionsUI") then
			mod:SecureHook(E, "ToggleOptionsUI", function()
				if E.Options.args.chat and not mod:IsHooked(E.Options.args.chat, "set") then
					mod:SecureHook(E.Options.args.chat, "set", function(info, value)
						if info[#info] == 'copyChatLines' then
							copyChatLines = value
						end
					end)
					mod:Unhook(E, "ToggleOptionsUI")
				end
			end)
		end
	else
		if E.Options and E.Options.args.chat and mod:IsHooked(E.Options.args.chat, "set") then mod:Unhook(E.Options.args.chat, "set") end
		if mod:IsHooked(E, "ToggleOptionsUI") then mod:Unhook(E, "ToggleOptionsUI") end
		if mod:IsHooked("FCF_Tab_OnClick") then mod:Unhook("FCF_Tab_OnClick") end
	end
end

local function setupSearchFilter(db)
	if not core.reload then
		hlR, hlG, hlB = unpack(db.highlightColor)
		prompts, queries = db.prompts, db.queries
		historyIndex = #prompts
		copyChatLines = CH.db.copyChatLines
	end

	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]

		if not IsCombatLog(frame) then
			if db.enabled then
				db.frames[i] = db.frames[i] or {
					["selectedRule"] = 1,
					["rules"] = {
						{
							["terms"] = "",
							["queryTree"] = {},
							["parsedExpression"] = {},
							["types"] = {},
							["blacklist"] = true,
						},
					},
				}

				frame.filterRules = db.frames[i].rules
				for _, rule in ipairs(db.frames[i].rules) do
					rule.queryTree = mod:Tokenize(rule.terms)
					rule.parsedExpression = mod:ParseExpression(rule.queryTree)
				end
				if not frame.searchBar then
					blockedMsgs[frame] = {}
					savedChatState[frame] = {}
					filteredMsgs[frame] = { raw = {}, processed = {} }

					saveChatState(frame)
					for j = #savedChatState[frame], 1, -1 do
						local info = savedChatState[frame][j]
						if mod:FilterNotPassed(frame, info.msg, info.chatType) then
							tremove(savedChatState[frame], j)
						end
					end
					restoreChatState(frame)

					local function saveQuery(index)
						local query = recentQueries[index]
						local timestamp = date("%d/%m")

						tremove(recentQueries, index)

						for _, info in ipairs(queries) do
							if info.query == query then
								info.timestamp = timestamp
								return
							end
						end
						tinsert(queries, {query = query, timestamp = timestamp})
					end

					local function deleteQuery(index)
						tremove(queries, index)
					end

					frame.searchArgs = {["ALL"] = true, ["HISTORY"] = true, ["LIVE"] = true}

					frame.searchActive = function(self)
						return self.searchBar:IsShown()
					end

					local button = CreateFrame("Button", "ChatFrame"..i.."SearchButton", frame, "UIPanelButtonTemplate")
					button:SetFrameStrata("LOW")

					button.texture = button:CreateTexture(nil, "OVERLAY")
					button.texture:SetAllPoints(button)
					button.texture:SetTexture("Interface\\Minimap\\Tracking\\NONE")

					button.highlightTexture = button:CreateTexture(nil, "HIGHLIGHT")
					button.highlightTexture:SetAllPoints(button)
					button.highlightTexture:SetTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight")
					button.highlightTexture:SetBlendMode("ADD")

					button.texture:Size(16)
					button:Size(16)

					if chatEnabled then
						S:HandleButton(button)
					end

					button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
					button:SetScript("OnMouseUp", function()
						button.texture:SetAllPoints(button)
					end)
					button:SetScript("OnMouseDown", function(self, clickButton)
						button.texture:ClearAllPoints()
						button.texture:SetPoint("CENTER", button, 1, -1)
						if clickButton == "LeftButton" then
							if frame:searchActive() then
								frame.searchBar:Hide()
							else
								frame.searchBar:Show()
							end
						elseif clickButton == "RightButton" then
							if IsShiftKeyDown() then
								ToggleDropDownMenu(1, nil, self.configDropdown, self, 0, 0)
							elseif IsAltKeyDown() then
								if frame:searchActive() then
									frame.searchBar:Hide()
								else
									frame.displayingFiltered = true
									frame.searchBar.blockedText:Show()
									local searchBar = frame.searchBar
									searchBar:SetText("@.@")
									searchBar:Show()
								end
							elseif IsControlKeyDown() then
								twipe(filteredMsgs[frame].processed)
								print(core.customColorBeta .. L["Cache purged."])
							else
								ToggleDropDownMenu(1, nil, self.historyDropdown, self, 0, 0)
							end
						end
					end)

                    local function initializeConfigDropdown(self, level)
						if not level then return end

						if level == 1 then
							for j, event in ipairs({"LIVE", "HISTORY", "ALL",
													"SAY", "YELL", "PARTY", "RAID",
													"BATTLEGROUND", "GUILD", "WHISPER", "CHANNEL", "OTHER"}) do
								if j <= 3 or not frame.searchArgs["ALL"] then
									local info = UIDropDownMenu_CreateInfo()
									info.text = event == "LIVE" and L["Live"] or event == "HISTORY" and L["History"] or event == "ALL" and L["All"] or localizedTypes[event]
									info.colorCode = frame.searchArgs[event] and core.customColorAlpha or "|cff808080"
									if db.tooltips then
										if event == "LIVE" then
											info.tooltipOnButton = 1
											info.tooltipTitle = core.customColorAlpha .. L["immediately show newly received messages that match the search terms."]
											info.colorCode = core.customColorAlpha
										elseif event == "HISTORY" then
											info.tooltipOnButton = 1
											info.tooltipTitle = core.customColorAlpha .. L["Also parse history messages."]
											info.colorCode = core.customColorAlpha
										end
									end
									info.checked = function()
										return frame.searchArgs[event]
									end
									info.func = function()
										frame.searchArgs[event] = not frame.searchArgs[event]
										if frame:searchActive() then
											mod:PerformSearch(frame, frame.searchBar:GetText())
										end
										CloseDropDownMenus()
										local searchButton = self:GetParent()
										ToggleDropDownMenu(1, nil, searchButton.configDropdown, searchButton, 0, 0)
									end
									info.value = event
									UIDropDownMenu_AddButton(info, level)
								end
							end
						end
					end

					local function initializeSearchHistoryDropdown(self, level)
						if level == 1 then
							if next(recentQueries) then
								local info = UIDropDownMenu_CreateInfo()
								info.notClickable = true
								info.notCheckable = true
								info.text = core.customColorBeta..L["Recent queries:"]
								UIDropDownMenu_AddButton(info, level)
							end

							for i = #recentQueries, 1, -1 do
								local info = UIDropDownMenu_CreateInfo()
								info.text = recentQueries[i]
								info.notCheckable = true
								if db.tooltips then
									info.tooltipOnButton = 1
									info.tooltipTitle = core.customColorAlpha .. L["Save: shift-click."]
									info.colorCode = core.customColorAlpha
								end
								info.func = function()
									if IsShiftKeyDown() then
										saveQuery(i)
										CloseDropDownMenus()
										local searchButton = self:GetParent()
										ToggleDropDownMenu(1, nil, searchButton.historyDropdown, searchButton, 0, 0)
									else
										local query = recentQueries[i]
										local searchBar = frame.searchBar
										searchBar:SetText(query)
										searchBar:SetCursorPosition(#searchBar:GetText())
										searchBar:Show()
									end
								end
								UIDropDownMenu_AddButton(info, level)
							end

							if next(queries) then
								local info = UIDropDownMenu_CreateInfo()
								info.notClickable = true
								info.notCheckable = true
								info.text = core.customColorBeta..L["Saved queries:"]
								UIDropDownMenu_AddButton(info, level)
							end

							for i = #queries, 1, -1 do
								local info = UIDropDownMenu_CreateInfo()
								info.text = queries[i].query .. " (" .. queries[i].timestamp .. ")"
								info.notCheckable = true
								if db.tooltips then
									info.tooltipOnButton = 1
									info.tooltipTitle = core.customColorAlpha .. L["Delete: shift-click."]
									info.colorCode = core.customColorAlpha
								end
								info.func = function()
									if IsShiftKeyDown() then
										deleteQuery(i)
										CloseDropDownMenus()
										local searchButton = self:GetParent()
										ToggleDropDownMenu(1, nil, searchButton.historyDropdown, searchButton, 0, 0)
									else
										local query = queries[i].query
										local searchBar = frame.searchBar
										searchBar:SetText(query)
										searchBar:SetCursorPosition(#searchBar:GetText())
										searchBar:Show()
									end
								end
								UIDropDownMenu_AddButton(info, level)
							end
						end
					end

					button.configDropdown = CreateFrame("Frame", "ChatFrame"..i.."Dropdown", button, "UIDropDownMenuTemplate")
					UIDropDownMenu_Initialize(button.configDropdown, initializeConfigDropdown)

					button.historyDropdown = CreateFrame("Frame", "ChatFrame"..i.."HistoryDropdown", button, "UIDropDownMenuTemplate")
					UIDropDownMenu_Initialize(button.historyDropdown, initializeSearchHistoryDropdown)

					local searchEditBox = CreateFrame("EditBox", "ChatFrame"..i.."SearchBar", frame, "InputBoxTemplate")
					searchEditBox.blockedText = searchEditBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
					searchEditBox.blockedText:SetText("[BLOCKED]")
					searchEditBox.blockedText:SetPoint("LEFT", searchEditBox, "RIGHT", 5, 0)
					searchEditBox.blockedText:SetTextColor(rBad, gBad, bBad)
					searchEditBox.blockedText:Hide()
					searchEditBox:SetAutoFocus(false)
					searchEditBox:Point("TOPLEFT", frame, "TOPLEFT", 5, -5)
					searchEditBox:Point("TOPRIGHT", frame, "TOPRIGHT", -frame:GetWidth()*(1/3), -5)
					searchEditBox:Size(frame:GetWidth()*(2/3), 20)
					searchEditBox:Hide()

					if chatEnabled then
						S:HandleEditBox(searchEditBox)
					end

					searchEditBox:SetScript("OnShow", function(self)
						self:SetFocus()
						saveChatState(frame)
						mod:PerformSearch(frame, self:GetText())
					end)

					searchEditBox:SetScript("OnHide", function(self)
						frame.displayingFiltered = nil
						frame.searchBar.blockedText:Hide()
						restoreChatState(frame)
					end)

					local function navigateSearchHistory(editBox)
						if not next(prompts) then return end

						if IsShiftKeyDown() then
							historyIndex = (historyIndex - 2) % #prompts + 1
						else
							historyIndex = historyIndex % #prompts + 1
						end

						editBox:SetText(prompts[historyIndex])
						editBox:SetCursorPosition(#editBox:GetText())
					end

					searchEditBox:SetScript("OnEnterPressed", function(self)
						local query = self:GetText()
						if query == "" then
							frame:Clear()
						else
							mod:PerformSearch(frame, query)
						end
					end)

                    searchEditBox:SetScript("OnTabPressed", function(self)
						navigateSearchHistory(self)
                    end)

					frame.searchButton = button
					frame.searchBar = searchEditBox
				elseif frame:searchActive() then
					mod:PerformSearch(frame, frame.searchBar:GetText())
				end

				local button = frame.searchButton
				local offsetX = find(db.point, "LEFT") and 1 or -1
				local offsetY = find(db.point, "BOTTOM") and 1 or -1

				if db.mouseover then
					button:SetScript("OnEnter", function(self) E_UIFrameFadeIn(nil, self, 0.1, 0, 1) end)
					button:SetScript("OnLeave", function(self) E_UIFrameFadeOut(nil, self, 0.1, 1, 0) end)
					button:SetAlpha(0)
				else
					button:SetScript("OnEnter", nil)
					button:SetScript("OnLeave", nil)
					button:SetAlpha(1)
				end

				button:ClearAllPoints()
				button:Point(db.point, frame, db.point, offsetX * 5, offsetY * 5)
				button:Show()
			elseif frame.searchBar then
				frame.searchBar:Hide()
				frame.searchButton:Hide()
			end
		end
	end

	setupHooks(db)
end

local function setupCompactChat(db)
	if not chatEnabled then return end

	if db.enabled then
		local emb_db = EMB and E.db.addOnSkins.embed

		local function updateChatVisibility(selectedRightTab)
			for i = 1, NUM_CHAT_WINDOWS do
				local chatFrame = _G["ChatFrame"..i]
				if db.rightSideChats[i] then
					local isSelected = i == selectedRightTab
					local searchButton = chatFrame.searchButton
					local embedded = EMB and EMB.mainFrame and EMB.mainFrame:IsShown() and emb_db.rightChatPanel

					chatFrame:SetParent((isSelected and not embedded) and RightChatPanel or E.HiddenFrame)

					if searchButton then
						if isSelected then
							searchButton:Show()
						else
							searchButton:Hide()
						end
					end
				elseif chatFrame:IsShown() then
					db.selectedLeftTab = i
				end
			end
		end

		local function selectChatTab(chatFrame, id, isRightSide)
			if not chatFrame then return end

			FCF_Tab_OnClick(chatFrame)

			if isRightSide then
				db.selectedRightTab = id
				updateChatVisibility(id)
			else
				db.selectedLeftTab = id
			end

			alertingTabs[(isRightSide and 'right' or 'left')][id] = nil

			local button = (isRightSide and RightChatPanel or LeftChatPanel).tabManagerButton
			button:StopFlashing(button.flash:GetAlpha())
		end

		local function moveChatFrame(chatFrame, id, moveDir)
			local parentFrame = moveDir == "right" and RightChatPanel or LeftChatPanel
			local isMovingRight = moveDir == "right"

			chatFrame:ClearAllPoints()
			chatFrame:Point("TOPLEFT", parentFrame, "TOPLEFT", db.rightOffset, -db.topOffset)
			chatFrame:Point("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -db.leftOffset, db.bottomOffset)
			chatFrame:SetFrameStrata(parentFrame:GetFrameStrata() or "LOW")
			chatFrame:SetFrameLevel(parentFrame:GetFrameLevel() or 100)

			local tab = _G["ChatFrame"..id.."Tab"]
			tab:ClearAllPoints()
			tab:Point("BOTTOMLEFT", parentFrame, "TOPLEFT", 0, 2)

			if chatFrame:GetLeft() then
				FCF_SavePositionAndDimensions(chatFrame, true)
			end

			db.rightSideChats[id] = isMovingRight

			if isMovingRight then
				FCF_UnDockFrame(chatFrame)
				db.selectedRightTab = id
			else
				FCF_DockFrame(chatFrame)
				FCF_SelectDockFrame(chatFrame)

			chatFrame:SetParent(LeftChatPanel)
				for id, val in pairs(db.rightSideChats) do
					if val then
						db.selectedRightTab = id
						break
					end
				end
				db.selectedLeftTab = id
			end

			updateChatVisibility(db.selectedRightTab)
		end

		if not mod.initialized.compactChat then
			local isRightClick = false

			local LeftChatModFrame = CreateFrame("Frame", "ChatModOptionsDropDown", UIParent, "UIDropDownMenuTemplate")
			local RightChatModFrame = CreateFrame("Frame", "RightChatModOptionsDropDown", UIParent, "UIDropDownMenuTemplate")

			local function getEmbeddedAddonName()
				if emb_db.embedType == "SINGLE" then
					return emb_db.leftWindow
				elseif emb_db.embedType == "DOUBLE" then
					return emb_db.leftWindow .. " / " .. emb_db.rightWindow
				end
				return "Embedded Addon"
			end

			local function ChatModOptionsDropDown_Initialize(self, level)
				local isRightSide = self == RightChatModFrame

				if level == 1 then
					local info = UIDropDownMenu_CreateInfo()
					local buttonIndex = 1

					if EMB and EMB.mainFrame then
						if (isRightSide and emb_db.rightChatPanel) or (not isRightSide and not emb_db.rightChatPanel) then
							local color = gsub(core.customColorAlpha, "|%x%x%x(%x%x)(%x%x)(%x%x)", function(r1, g1, b1)
								local r2, g2, b2 = match(core.customColorBeta, "|%x%x%x(%x%x)(%x%x)(%x%x)")
								r1, g1, b1 = tonumber(r1, 16), tonumber(g1, 16), tonumber(b1, 16)
								r2, g2, b2 = tonumber(r2, 16), tonumber(g2, 16), tonumber(b2, 16)

								return format("|cff%02x%02x%02x", (r1 + r2) / 2, (g1 + g2) / 2, (b1 + b2) / 2)
							end)

							info.text = (EMB.mainFrame:IsShown() and color or "|cff696969") .. getEmbeddedAddonName()
							info.hasArrow = false
							info.notCheckable = true
							info.value = "EmbeddedAddon"
							info.func = function()
								if EMB.mainFrame:IsShown() then
									EMB.mainFrame:Hide()
								else
									EMB.mainFrame:Show()
								end
							end

							UIDropDownMenu_AddButton(info, level)
							buttonIndex = buttonIndex + 1
						end
					end

					for i = 1, NUM_CHAT_WINDOWS do
						local chatFrame = _G["ChatFrame"..i]
						local id = chatFrame:GetID()
						if (isRightSide and db.rightSideChats[id]) or (not isRightSide and chatFrame.isDocked) then
							info.text = ((isRightSide and db.selectedRightTab or db.selectedLeftTab) == id
											and core.customColorAlpha or core.customColorBeta) .. chatFrame.name
							info.hasArrow = isRightClick
							info.notCheckable = true
							info.value = id
							info.func = function() selectChatTab(chatFrame, id, isRightSide) end

							local button = _G["DropDownList1Button"..buttonIndex]
							if button then
								if not button.highlightTexture then
									button.highlightTexture = button:CreateTexture(nil, "OVERLAY")
									button.highlightTexture:SetAllPoints(button)
									button.highlightTexture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
									button.highlightTexture:SetBlendMode("ADD")
									button.highlightTexture:SetAlpha(0)
								end

								local alertTabs = isRightSide and alertingTabs.right or alertingTabs.left

								if alertTabs[id] then
									if not tcontains(flashingButtons, button.highlightTexture) then
										UIFrameFlash(button.highlightTexture, 1.0, 1.0, -1, false, 0, 0, "chat")
										tinsert(flashingButtons, button.highlightTexture)
									end
								else
									UIFrameFlashRemoveFrame(button.highlightTexture)
									button.highlightTexture:SetAlpha(0)
								end
							end

							UIDropDownMenu_AddButton(info, level)
							buttonIndex = buttonIndex + 1
						end
					end

					if isRightClick then
						info.text = NEW_CHAT_WINDOW
						info.hasArrow = false
						info.func = FCF_NewChatWindow
						info.notCheckable = true
						UIDropDownMenu_AddButton(info, level)

						info.text = RESET_ALL_WINDOWS
						info.hasArrow = false
						info.func = FCF_ResetAllWindows
						info.notCheckable = true
						UIDropDownMenu_AddButton(info)
					end
				 elseif level == 2 then
					local id = UIDROPDOWNMENU_MENU_VALUE
					CURRENT_CHAT_FRAME_ID = id
					local chatFrame = _G["ChatFrame"..id]

					local info = UIDropDownMenu_CreateInfo()

					if isRightSide or id > 2 then
						info.text = isRightSide and L["Move left"] or L["Move right"]
						info.hasArrow = false
						info.func = function()
							CloseDropDownMenus()

							moveChatFrame(chatFrame, id, isRightSide and "left" or "right")

							local button = isRightSide and LeftChatPanel.tabManagerButton or RightChatPanel.tabManagerButton
							if button then
								button.justMoved = true
								button:StartFlashing()
								button:SetScript("OnEnter", function(self)
									self:StopFlashing(self.flash:GetAlpha())
									self.justMoved = nil

									if button.mouseover then
										self:SetScript("OnEnter", function(self) E_UIFrameFadeIn(nil, self, 0.5, 0, 1) end)
									else
										self:SetScript("OnEnter", nil)
									end
								end)
							end
						end
						info.notCheckable = true
						UIDropDownMenu_AddButton(info, level)
					end

					info.text = RENAME_CHAT_WINDOW
					info.func = function() FCF_RenameChatWindow_Popup() CloseDropDownMenus() end
					info.notCheckable = true
					UIDropDownMenu_AddButton(info, level)

					if chatFrame ~= DEFAULT_CHAT_FRAME then
						info.text = CLOSE_CHAT_WINDOW
						info.func = function() FCF_Close() CloseDropDownMenus() end
						info.arg1 = chatFrame
						info.notCheckable = true
						UIDropDownMenu_AddButton(info, level)
					end

					info.text = FONT_SIZE
					info.hasArrow = true
					info.func = nil
					info.notCheckable = true
					UIDropDownMenu_AddButton(info, level)

					info.text = CHAT_CONFIGURATION
					info.hasArrow = false
					info.func = function() ShowUIPanel(ChatConfigFrame) CloseDropDownMenus() end
					info.notCheckable = true
					UIDropDownMenu_AddButton(info, level)
				elseif level == 3 and UIDROPDOWNMENU_MENU_VALUE == FONT_SIZE then
					local info = UIDropDownMenu_CreateInfo()
					for _, value in ipairs(CHAT_FONT_HEIGHTS) do
						info.text = format(FONT_SIZE_TEMPLATE, value)
						info.value = value
						info.func = FCF_SetChatWindowFontSize
						info.checked = nil
						UIDropDownMenu_AddButton(info, level)
					end
				end
			end

			UIDropDownMenu_Initialize(LeftChatModFrame, ChatModOptionsDropDown_Initialize, "MENU")
			UIDropDownMenu_Initialize(RightChatModFrame, ChatModOptionsDropDown_Initialize, "MENU")

			local function createChatManagerButton(parent, side)
				local button = CreateFrame("Button", "$parentTabManagerButton", parent, "UIPanelButtonTemplate")

				button:SetFrameStrata("LOW")
				button:SetFrameLevel(999)
				button:Size(16)

				S:HandleButton(button)

				local normalTexture = button:CreateTexture(nil, "ARTWORK")
				normalTexture:SetTexture("Interface\\Buttons\\UI-MultiCheck-Up")
				normalTexture:Point("CENTER")
				normalTexture:Size(20)
				button.normalTexture = normalTexture

				local pushedTexture = button:CreateTexture(nil, "ARTWORK")
				pushedTexture:SetTexture("Interface\\Buttons\\UI-MultiCheck-Disabled")
				pushedTexture:Point("CENTER")
				pushedTexture:Size(20)
				button.pushedTexture = pushedTexture

				button:SetNormalTexture(normalTexture)
				button:SetPushedTexture(pushedTexture)

				button.highlightTexture = button:CreateTexture(nil, "HIGHLIGHT")
				button.highlightTexture:SetAllPoints(button)
				button.highlightTexture:SetTexture("Interface\\Buttons\\UI-Common-MouseHilight")
				button.highlightTexture:SetBlendMode("ADD")

				button:RegisterForClicks("LeftButtonDown", "RightButtonDown")

				button:SetScript("OnClick", function(self, clicked)
					if IsModifierKeyDown()
						and EMB and EMB.mainFrame
						and (side == "right" and emb_db.rightChatPanel) or (side == "left" and not emb_db.rightChatPanel) then
							if EMB.mainFrame:IsShown() then
								EMB.mainFrame:Hide()
							else
								EMB.mainFrame:Show()
							end
					else
						isRightClick = clicked == "RightButton"
						ToggleDropDownMenu(1, nil, side == "left" and LeftChatModFrame or RightChatModFrame, self, 0, 0)
					end
				end)

				button.flash = CreateFrame("Frame", nil, button)
				button.flash:SetAllPoints(button)
				button.flash:SetFrameLevel(999)
				button.flash:CreateShadow()
				button.flash:SetAlpha(0)

				local function flashButton(self)
					local curAlpha = self.flash:GetAlpha()
					if curAlpha == 1 then
						E_UIFrameFadeOut(nil, self.flash, 1, 1, 0)
					elseif curAlpha == 0 then
						E_UIFrameFadeIn(nil, self.flash, 1, 0, 1)
					end
				end

				function button:StartFlashing()
					if self.isFlashing then return end

					local hex = gsub(core.customColorBeta, "|c%w%w", "")
					local r = tonumber(sub(hex, 1, 2), 16) / 255
					local g = tonumber(sub(hex, 3, 4), 16) / 255
					local b = tonumber(sub(hex, 5, 6), 16) / 255

					self.flash.shadow:SetBackdropBorderColor(r, g, b)
					self.isFlashing = true

					if self.mouseover then
						E_UIFrameFadeIn(nil, self, 0.5, 0, 1)
						self:SetScript("OnEnter", nil)
						self:SetScript("OnLeave", nil)
					end

					E_UIFrameFadeIn(nil, self.flash, 1, 0, 1)
					self:SetScript("OnUpdate", flashButton)
				end

				function button:StopFlashing(curAlpha)
					self.isFlashing = false
					self:SetScript("OnUpdate", nil)

					if self.mouseover then
						self:SetScript("OnEnter", function(self) E_UIFrameFadeIn(nil, self, 0.5, 0, 1) end)
						self:SetScript("OnLeave", function(self) E_UIFrameFadeOut(nil, self, 0.5, 1, 0) end)
						E_UIFrameFadeOut(nil, self, 0.5, 1, 0)
					end

					E_UIFrameFadeOut(nil, self.flash, curAlpha, curAlpha, 0)
				end

				parent.tabManagerButton = button
			end

			createChatManagerButton(LeftChatPanel, "left")
			createChatManagerButton(RightChatPanel, "right")

			mod.initialized.compactChat = true
		end

		if not MessageEventHandlerPostHooks['compactChat'] then
			MessageEventHandlerPostHooks['compactChat'] = function(self, frame, event, arg1, _, _, arg4, _, _, arg7, arg8, arg9)
				if not frame:IsShown() or frame:GetAlpha() ~= 1 then
					local chatType = sub(event, 10)
					local info = ChatTypeInfo[chatType]

					if (sub(chatType, 1, 7) == "CHANNEL") and (chatType ~= "CHANNEL_LIST") and ((arg1 ~= "INVITE") or (chatType ~= "CHANNEL_NOTICE_USER")) then
						local channelLength = len(arg4)

						if arg1 == "WRONG_PASSWORD" then
							local staticPopup = _G[StaticPopup_Visible("CHAT_CHANNEL_PASSWORD") or ""]
							if staticPopup and upper(staticPopup.data) == upper(arg9) then
								-- Don't display invalid password messages if we're going to prompt for a password (bug 102312)
								return
							end
						end

						for index, value in pairs(frame.channelList) do
							if channelLength > len(value) then
								-- arg9 is the channel name without the number in front...
								if ((arg7 > 0) and (frame.zoneChannelList[index] == arg7)) or (upper(value) == upper(arg9)) then
									local infoType = "CHANNEL"..arg8
									info = ChatTypeInfo[infoType]
									break
								end
							end
						end
						if not info then
							return true
						end
					end

					if (frame == DEFAULT_CHAT_FRAME and info.flashTabOnGeneral) or (frame ~= DEFAULT_CHAT_FRAME and info.flashTab) then
						if not CHAT_OPTIONS.HIDE_FRAME_ALERTS or chatType == "WHISPER" or chatType == "BN_WHISPER" then
							local isRightSide = isRightChatTab(frame)

							alertingTabs[(isRightSide and 'right' or 'left')][frame:GetID()] = true

							local button = isRightChatTab(frame) and RightChatPanel.tabManagerButton or LeftChatPanel.tabManagerButton
							button:StartFlashing()
						end
					end
				end
			end
		end

		if EMB then
			if not mod:IsHooked(EMB, "UpdateSwitchButton") then
				mod:SecureHook(EMB, "UpdateSwitchButton", function()
					EMB.switchButton:Hide()
				end)
			end
			if EMB.mainFrame then
				if not mod:IsHooked(EMB.mainFrame, "OnShow") then
					mod:SecureHookScript(EMB.mainFrame, "OnShow", function() updateChatVisibility(db.selectedRightTab) end)
				end
				if not mod:IsHooked(EMB.mainFrame, "OnHide") then
					mod:SecureHookScript(EMB.mainFrame, "OnHide", function() updateChatVisibility(db.selectedRightTab) end)
				end
			end
		end

		if not mod:IsHooked(CH, "PositionChat") then
			mod:SecureHook(CH, "PositionChat", function(_, chat)
				local tab = CH:GetTab(chat)

				local isRight = isRightChatTab(chat)
				local parentFrame

				if isRight then
					parentFrame = RightChatPanel
				else
					parentFrame = LeftChatPanel
				end

				local offset = ((isRight and E.db.datatexts.rightChatPanel)
								or (not isRight and E.db.datatexts.leftChatPanel)) and E.Border*3 - E.Spacing + 22
								or 0

				chat:ClearAllPoints()
				chat:Point("TOPLEFT", parentFrame, "TOPLEFT", db.leftOffset, -db.topOffset)
				chat:Point("BOTTOMRIGHT", parentFrame, "BOTTOMRIGHT", -db.rightOffset, db.bottomOffset + offset)

				tab:ClearAllPoints()
				tab:Point("BOTTOMLEFT", parentFrame, "TOPLEFT", 0, 2)

				if not chat.skipPositioning and chat:GetLeft() then
					chat.skipPositioning = true
					FCF_SavePositionAndDimensions(chat, true)
					chat.skipPositioning = nil
				end
				updateChatVisibility(db.selectedRightTab)
			end)
		end

		local channelButton = _G.ChatFrameChannelButton
		if db.mouseoverChannelButton then
			if not mod:IsHooked(channelButton, "OnEnter") then
				mod:SecureHookScript(channelButton, "OnEnter", function(self)
					E_UIFrameFadeIn(nil, self, 0.1, 0, 1)
				end)
			end
			if not mod:IsHooked(channelButton, "OnLeave") then
				mod:SecureHookScript(channelButton, "OnLeave", function(self)
					E_UIFrameFadeOut(nil, self, 0.5, 1, 0)
				end)
			end
			if not MouseIsOver(channelButton) then
				channelButton:SetAlpha(0)
			end
		else
			if mod:IsHooked(channelButton, "OnEnter") then
				mod:Unhook(channelButton, "OnEnter")
			end
			if mod:IsHooked(channelButton, "OnLeave") then
				mod:Unhook(channelButton, "OnLeave")
			end
			channelButton:SetAlpha(1)
		end
		if not mod:IsHooked(channelButton, "OnMouseUp") then
			mod:SecureHookScript(channelButton, "OnMouseUp", function(self)
				self:ClearAllPoints()
				self:Point("TOPRIGHT", _G.GeneralDockManager, "BOTTOMRIGHT", -6, -10)
			end)
		end
		if not mod:IsHooked(channelButton, "OnMouseDown") then
			mod:SecureHookScript(channelButton, "OnMouseDown", function(self)
				self:ClearAllPoints()
				self:Point("TOPRIGHT", _G.GeneralDockManager, "BOTTOMRIGHT", -3, -9)
			end)
		end
		channelButton:ClearAllPoints()
		channelButton:Point("TOPRIGHT", _G.GeneralDockManager, "BOTTOMRIGHT", -6, -10)

		if not mod:IsHooked(CH, "StyleChat") then
			mod:SecureHook(CH, "StyleChat", function(_, chat)
				local copyButton = chat.copyButton
				if db.mouseoverCopyButton then
					if not mod:IsHooked(copyButton, "OnEnter") then
						mod:SecureHookScript(copyButton, "OnEnter", function(self)
							E_UIFrameFadeIn(nil, self, 0.1, 0, 1)
						end)
					end
					if not mod:IsHooked(copyButton, "OnLeave") then
						mod:SecureHookScript(copyButton, "OnLeave", function(self)
							E_UIFrameFadeOut(nil, self, 0.5, 1, 0)
						end)
					end
					if not MouseIsOver(copyButton) then
						copyButton:SetAlpha(0)
					end
				else
					if mod:IsHooked(copyButton, "OnEnter") then
						mod:Unhook(copyButton, "OnEnter")
					end
					if mod:IsHooked(copyButton, "OnLeave") then
						mod:Unhook(copyButton, "OnLeave")
					end
					copyButton:SetAlpha(0.35)
				end
				copyButton:ClearAllPoints()
				copyButton:Point("TOPRIGHT", 0, db.enabled and (IsCombatLog(chat) and -9 or -25) or -2)
			end)
		end

		if not mod:IsHooked(DropDownList1, "OnHide") then
			mod:SecureHookScript(DropDownList1, "OnHide", function()
				for i = #flashingButtons, 1, -1 do
					local buttonTex = flashingButtons[i]
					UIFrameFlashRemoveFrame(buttonTex)
					buttonTex:SetAlpha(0)
					tremove(flashingButtons, i)
				end
			end)
		end

		if not mod:IsHooked("FCFDockOverflowButton_UpdatePulseState") then
			mod:SecureHook("FCFDockOverflowButton_UpdatePulseState", function(self)
				self:Hide()
			end)
		end

		if not mod:IsHooked("FCF_OpenNewWindow") then
			mod:SecureHook("FCF_OpenNewWindow", function()
				for i = 1, NUM_CHAT_WINDOWS do
					local chatFrame = _G["ChatFrame"..i]
					if chatFrame.isDocked and db.rightSideChats[i] then
						db.rightSideChats[i] = nil
					end
				end
			end)
		end

		if not mod:IsHooked("FCF_FadeInChatFrame") then
			mod:SecureHook("FCF_FadeInChatFrame", function(chatFrame)
				_G[chatFrame:GetName().."Tab"]:Hide()
			end)
		end

		if not mod:IsHooked("FCF_FadeOutChatFrame") then
			mod:SecureHook("FCF_FadeOutChatFrame", function(chatFrame)
				_G[chatFrame:GetName().."Tab"]:Hide()
			end)
		end

		if not mod:IsHooked("FCFDock_UpdateTabs") then
			mod:SecureHook("FCFDock_UpdateTabs", function()
				for i = 1, NUM_CHAT_WINDOWS do
					_G["ChatFrame"..i.."Tab"]:Hide()
				end
			end)
		end

		if not mod:IsHooked("FCF_Close") then
			mod:SecureHook("FCF_Close", function(chatFrame)
				if not chatFrame then
					chatFrame = FCF_GetCurrentChatFrame()
				end
				db.rightSideChats[chatFrame:GetID()] = nil
			end)
		end

		for i, button in ipairs({LeftChatPanel.tabManagerButton, RightChatPanel.tabManagerButton}) do
			button.mouseover = (i == 1 and db.mouseoverL) or (i == 2 and db.mouseoverR)

			if button.mouseover then
				button:SetScript("OnEnter", function(self) E_UIFrameFadeIn(nil, self, 0.5, 0, 1) end)
				button:SetScript("OnLeave", function(self) E_UIFrameFadeOut(nil, self, 0.5, 1, 0) end)
				button:SetAlpha(0)
			else
				button:SetScript("OnEnter", nil)
				button:SetScript("OnLeave", nil)
				button:SetAlpha(1)
			end
			button:Show()
		end

		CombatLogQuickButtonFrame_Custom:ClearAllPoints()
		CombatLogQuickButtonFrame_Custom:Point("TOPLEFT", LeftChatPanel, "TOPLEFT", 4, -4)
		CombatLogQuickButtonFrame_Custom:Point("TOPRIGHT", LeftChatPanel, "TOPRIGHT", -28, -4)
		CombatLogQuickButtonFrame_Custom:SetParent(LeftChatPanel)

		local offsetX = find(db.point, "LEFT") and 1 or -1
		local offsetY = find(db.point, "BOTTOM") and 1 or -1

		for _, button in ipairs({LeftChatPanel.tabManagerButton, RightChatPanel.tabManagerButton}) do
			button:ClearAllPoints()
			button:Point(db.point, offsetX * 5, offsetY * 5)
		end

		CH:PositionChats()

		if #db.rightSideChats == 0 then
			for i = 1, NUM_CHAT_WINDOWS do
				local chatFrame = _G["ChatFrame"..i]
				local _, anchor = chatFrame:GetPoint()
				if anchor == RightChatPanel then
					db.rightSideChats[i] = true
				end
			end
		end

		local oldSelectedRight = db.selectedRightTab

		for i = 1, NUM_CHAT_WINDOWS do
			local chatFrame = _G["ChatFrame"..i]
			if db.rightSideChats[i] then
				if not mod:IsHooked(chatFrame, "OnUpdate") then
					mod:SecureHookScript(chatFrame, "OnUpdate", function(self)
						local _, anchor = self:GetPoint()
						if anchor ~= RightChatPanel then
							moveChatFrame(self, i, "right")
						else
							mod:Unhook(self, "OnUpdate")
						end
					end)
				end
			end
			select(2,mod:IsHooked(CH, "StyleChat"))(nil, chatFrame)
		end

		db.selectedRightTab = oldSelectedRight

		selectChatTab(_G["ChatFrame"..db.selectedLeftTab], db.selectedLeftTab)
		selectChatTab(_G["ChatFrame"..db.selectedRightTab], db.selectedRightTab, true)
	elseif mod.initialized.compactChat then
		if MessageEventHandlerPostHooks['compactChat'] then MessageEventHandlerPostHooks['compactChat'] = nil end
		if EMB then
			if mod:IsHooked(EMB, "UpdateSwitchButton") then mod:Unhook(EMB, "UpdateSwitchButton") end
			if EMB.mainFrame and mod:IsHooked(EMB.mainFrame, "OnShow") then mod:Unhook(EMB.mainFrame, "OnShow") end
			if EMB.mainFrame and mod:IsHooked(EMB.mainFrame, "OnHide") then mod:Unhook(EMB.mainFrame, "OnHide") end
		end
		if mod:IsHooked(CH, "PositionChat") then mod:Unhook(CH, "PositionChat") end
		if mod:IsHooked(CH, "StyleChat") then mod:Unhook(CH, "StyleChat") end

		if mod:IsHooked("ToggleDropDownMenu") then mod:Unhook("ToggleDropDownMenu") end
		if mod:IsHooked("FCFDockOverflowButton_UpdatePulseState") then mod:Unhook("FCFDockOverflowButton_UpdatePulseState") end
		if mod:IsHooked("FCF_FadeInChatFrame") then mod:Unhook("FCF_FadeInChatFrame") end
		if mod:IsHooked("FCF_FadeOutChatFrame") then mod:Unhook("FCF_FadeOutChatFrame") end
		if mod:IsHooked("FCFDock_UpdateTabs") then mod:Unhook("FCFDock_UpdateTabs") end
		if mod:IsHooked("FCF_Close") then mod:Unhook("FCF_Close") end

		LeftChatPanel.tabManagerButton:Hide()
		RightChatPanel.tabManagerButton:Hide()

		for i = 1, NUM_CHAT_WINDOWS do
			local chatFrame = _G["ChatFrame"..i]
			if IsCombatLog(chatFrame) then
				CombatLogQuickButtonFrame_Custom:ClearAllPoints()
				CombatLogQuickButtonFrame_Custom:Point("BOTTOMLEFT", chatFrame, "TOPLEFT", 0, -6)
				CombatLogQuickButtonFrame_Custom:Point("BOTTOMRIGHT", LeftChatPanel, "TOPRIGHT", -8, 0)

				chatFrame:ClearAllPoints()
				chatFrame:Point("TOPLEFT", GeneralDockManager, "BOTTOMLEFT", 0, -6)
				chatFrame:Point("TOPRIGHT", GeneralDockManager, "BOTTOMRIGHT", 0, -6)
			end
			if mod:IsHooked(chatFrame, "OnUpdate") then
				mod:Unhook(chatFrame, "OnUpdate")
			end
		end
		local channelButton = _G.ChatFrameChannelButton
		if mod:IsHooked(channelButton, "OnEnter") then
			mod:Unhook(channelButton, "OnEnter")
		end
		if mod:IsHooked(channelButton, "OnLeave") then
			mod:Unhook(channelButton, "OnLeave")
		end
		if mod:IsHooked(channelButton, "OnMouseUp") then
			mod:Unhook(channelButton, "OnMouseUp")
		end
		if mod:IsHooked(channelButton, "OnMouseDown") then
			mod:Unhook(channelButton, "OnMouseDown")
		end
		channelButton:SetAlpha(1)
		channelButton:PointXY(-2, -1)

		for _, buttonTex in ipairs(flashingButtons) do
			UIFrameFlashRemoveFrame(buttonTex)
			buttonTex:SetAlpha(0)
		end
	end

	if not mod.initialized.compactChat then return end

	for id, frameName in ipairs(CHAT_FRAMES) do
		local chat = _G[frameName]
		if (id <= NUM_CHAT_WINDOWS) then
			chat.copyButton:ClearAllPoints()
			chat.copyButton:Point("TOPRIGHT", 0, db.enabled and (IsCombatLog(chat) and -9 or -25) or (IsCombatLog(chat) and -11 or -2))
		end
	end
end

local function setupChatEditBox(db)
	if chatEnabled and db.enabled then
		for _, frameName in ipairs(CHAT_FRAMES) do
			local chatFrame = _G[frameName.."EditBox"]

			chatFrame:ClearAllPoints()
			if E.db.chat.editBoxPosition == 'BELOW_CHAT' then
				chatFrame:Point("TOPLEFT", ChatFrame1, "BOTTOMLEFT", -db.widthOffset, db.heightOffset + db.yOffset)
				chatFrame:Point("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", db.widthOffset, -LeftChatTab:GetHeight() - db.heightOffset + db.yOffset)
			else
				chatFrame:Point("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -db.widthOffset, db.heightOffset + db.yOffset)
				chatFrame:Point("TOPRIGHT", ChatFrame1, "TOPRIGHT", db.widthOffset, LeftChatTab:GetHeight() + db.heightOffset + db.yOffset)
			end
		end
	end
end


P["Extras"]["general"][modName] = {
	["SearchFilter"] = {
		["enabled"] = false,
		["tooltips"] = true,
		["mouseover"] = false,
		["highlightColor"] = {1, 0.6, 0},
		["point"] = "BOTTOMRIGHT",
		["queries"] = {},
		["prompts"] = {},
		["frames"] = {
			["selectedFrame"] = 1,
			{
				["selectedRule"] = 1,
				["rules"] = {
					{
						["terms"] = "",
						["queryTree"] = {},
						["parsedExpression"] = {},
						["types"] = {},
						["blacklist"] = true,
					},
				},
			},
		},
	},
	["CompactChat"] = {
		["enabled"] = false,
		["mouseover"] = false,
		["mouseoverChannelButton"] = true,
		["mouseoverCopyButton"] = true,
		["point"] = "TOPLEFT",
		["topOffset"] = 5,
		["bottomOffset"] = 5,
		["leftOffset"] = 5,
		["rightOffset"] = 5,
		["rightSideChats"] = {},
		["selectedLeftTab"] = 1,
		["selectedRightTab"] = 1,
	},
	["ChatEditBox"] = {
		["enabled"] = false,
		["heightOffset"] = 0,
		["widthOffset"] = -12,
		["yOffset"] = -12,
	},
}

function mod:LoadConfig(db)
	local function selectedFrame() return db.SearchFilter.frames.selectedFrame or 1 end
    local function selectedRule()
		return core:getSelected("general", modName, format("SearchFilter.frames[%s]", selectedFrame() or ""), 1).selectedRule or 1
	end
	local function selectedRuleData()
		return core:getSelected("general", modName, format("SearchFilter.frames.%s.rules[%s]", selectedFrame(), selectedRule() or ""), 1)
	end
    local function createChatTypeToggle(key, order)
        return {
            order = order,
            type = "toggle",
            width = key == "ALL" and "double" or "normal",
            name = localizedTypes[key] or L["All"],
            desc = "",
            get = function() return selectedRuleData().types[key] end,
            set = function(_, value)
				local ruleData = selectedRuleData()
				if ruleData.terms == "" then
					for type in pairs(localizedTypes) do
						ruleData.types[type] = false
					end
				else
					ruleData.types[key] = value
					if key == "ALL" then
						for type in pairs(localizedTypes) do
							ruleData.types[type] = not value
						end
					elseif key ~= "ALL" and value then
						ruleData.types["ALL"] = false
					end
				end
            end,
            hidden = function()
                if key == "ALL" then return false end
                return selectedRuleData().types["ALL"]
            end,
        }
    end

	core.general.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			SearchFilter = {
				order = 1,
                type = "group",
                name = L["Chat Search and Filter"],
				guiInline = true,
				get = function(info) return db.SearchFilter[info[#info]] end,
				set = function(info, value) db.SearchFilter[info[#info]] = value self:Toggle(db) end,
				disabled = function() return not db.SearchFilter.enabled end,
                args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "full",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Search and filter utility for the chat frames."..
								"\n\nSynax:"..
								"\n  :: - 'and' statement"..
								"\n  ( ; ) - 'or' statement"..
								"\n  ! ! - 'not' statement"..
								"\n  [ ] - case sensitive"..
								"\n  @ @ - lua pattern"..
								"\n\nSample messages:"..
								"\n  1. [4][Bigguy]: lfg yo moms place"..
								"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
								"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
								"\n  4. [W][Noobkillaz]: delete game bro"..
								"\n  5. SYSTEM: You should buy gold at our website NOW!"..
								"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
								"\n\nSearch queries and results:"..
								"\n  yo - 1,2,3,5,6"..
								"\n  !yo! - 4"..
								"\n  !yo!::!delete! - empty"..
								"\n  [dElete];crab - 6"..
								"\n  (@LF%d*M@;lfg)::mom - 1,2"..
								"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
								"\n\nTab/Shift-Tab to navigate the prompts."..
								"\nRight-Click the search button to access recent queries."..
								"\nShift-Right-Click it to access the search config."..
								"\nAlt-Right-Click for the blocked messages."..
								"\nCtrl-Right-Click to purge filtered messages cache."..
								"\n\nChannel names and timestamps are not parsed."],
					},
					mouseover = {
						order = 2,
						type = "toggle",
						name = L["Mouseover"],
						desc = L["Search button visibility."],
					},
					point = {
						order = 3,
						type = "select",
						name = L["Point"],
						desc = L["Search button point."],
						values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOPRIGHT"] = "TOPRIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					},
					tooltips = {
						order = 4,
						type = "toggle",
						name = L["Config Tooltips"],
						desc = "",
					},
					highlightColor = {
						order = 5,
						type = "color",
						name = L["Highlight Color"],
						desc = L["Match highlight color."],
						get = function(info) return unpack(db.SearchFilter[info[#info]]) end,
						set = function(info, r, g, b) db.SearchFilter[info[#info]] = {r, g, b} self:Toggle(db) end,
					},
				},
			},
			settings = {
				order = 2,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function() return not db.SearchFilter.enabled end,
				hidden = function() return not db.SearchFilter.enabled end,
				args = {
					filterType = {
						order = 1,
						type = "select",
						name = L["Filter Type"],
						desc = "",
						values = {
							[true] = L["Blacklist"],
							[false] = L["Whitelist"],
						},
						get = function() return selectedRuleData().blacklist end,
						set = function(_, value)
							selectedRuleData().blacklist = value
							self:Toggle(db)
						end,
					},
					terms = {
						order = 2,
						type = "input",
						name = L["Rule Terms"],
						desc = L["Same logic as with the search."],
						get = function() return selectedRuleData().terms end,
						set = function(_, value)
							local ruleData = selectedRuleData()
							if value == "" then
								for type in pairs(localizedTypes) do
									ruleData.types[type] = false
								end
							end
							ruleData.terms = value
							self:Toggle(db)
						end,
					},
					description = {
						order = 2.5,
						type = "header",
						name = L["Select Chat Types"],
					},
					chatTypeALL = createChatTypeToggle("ALL", 3),
					chatTypeSAY = createChatTypeToggle("SAY", 3.1),
					chatTypeYELL = createChatTypeToggle("YELL", 3.2),
					chatTypePARTY = createChatTypeToggle("PARTY", 3.3),
					chatTypeRAID = createChatTypeToggle("RAID", 3.4),
					chatTypeGUILD = createChatTypeToggle("GUILD", 3.5),
					chatTypeBATTLEGROUND = createChatTypeToggle("BATTLEGROUND", 3.6),
					chatTypeWHISPER = createChatTypeToggle("WHISPER", 3.7),
					chatTypeCHANNEL = createChatTypeToggle("CHANNEL", 3.8),
					chatTypeOTHER = createChatTypeToggle("OTHER", 3.9),
					selectedRule = {
						order = 4,
						type = "select",
						width = "double",
						name = L["Select Rule"],
						desc = "",
						values = function()
							local values = {}
							for i, info in ipairs(db.SearchFilter.frames[selectedFrame()].rules) do
								values[i] = sub(info.terms, 1, 20) .. (#info.terms > 20 and "..." or "")
							end
							return values
						end,
						get = function() return selectedRule() end,
						set = function(_, value) db.SearchFilter.frames[selectedFrame()].selectedRule = value end,
					},
					selectFrame = {
						order = 5,
						type = "select",
						width = "double",
						name = L["Select Chat Frame"],
						desc = "",
						values = function()
							local values = {}
							for i = 1, NUM_CHAT_WINDOWS do
								local frame = _G["ChatFrame"..i]
								if frame and not IsCombatLog(frame) then
									values[i] = frame.name or ("Chat " .. i)
								end
							end
							return values
						end,
						get = function() return selectedFrame() end,
						set = function(_, value)
							db.SearchFilter.frames.selectedFrame = value
							db.SearchFilter.frames[value].selectedRule = 1
						end,
					},
					addRule = {
						order = 6,
						type = "execute",
						name = L["Add Rule"],
						desc = "",
						func = function()
							local frameRules = db.SearchFilter.frames[selectedFrame()].rules
							tinsert(frameRules, { 	["terms"] = "",
													["queryTree"] = "",
													["parsedExpression"] = {},
													["blacklist"] = true,
													["types"] = {}
												})
							db.SearchFilter.frames[selectedFrame()].selectedRule = #frameRules
							self:Toggle(db)
						end,
					},
					deleteRule = {
						order = 7,
						type = "execute",
						name = L["Delete Rule"],
						desc = "",
						func = function()
							local frameRules = db.SearchFilter.frames[selectedFrame()].rules
							if #frameRules > 0 then
								tremove(frameRules, selectedRule())
								db.SearchFilter.frames[selectedFrame()].selectedRule = min(selectedRule(), #frameRules)
								self:Toggle(db)
							end
						end,
						disabled = function() return not db.SearchFilter.enabled or #db.SearchFilter.frames[selectedFrame()].rules == 1 end,
					},
				},
			},
			CompactChat = {
				order = 4,
                type = "group",
                name = L["Compact Chat"],
				guiInline = true,
				get = function(info) return db.CompactChat[info[#info]] end,
				set = function(info, value) db.CompactChat[info[#info]] = value setupCompactChat(db.CompactChat) end,
				disabled = function() return not chatEnabled or not db.CompactChat.enabled end,
                args = {
					enabled = {
						order = 1,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."],
					},
					point = {
						order = 2,
						type = "select",
						name = L["Point"],
						desc = L["Manager point."],
						values = {
							["TOPLEFT"] = "TOPLEFT",
							["TOPRIGHT"] = "TOPRIGHT",
							["BOTTOMLEFT"] = "BOTTOMLEFT",
							["BOTTOMRIGHT"] = "BOTTOMRIGHT",
						},
					},
					mouseoverChannelButton = {
						order = 3,
						type = "toggle",
						name = L["Mouseover: Channel Button"],
						desc = L["Channel button visibility."],
					},
					mouseoverCopyButton = {
						order = 4,
						type = "toggle",
						name = L["Mouseover: Copy Button"],
						desc = L["Copy button visibility."],
					},
					mouseoverL = {
						order = 5,
						type = "toggle",
						name = L["Mouseover: Left"],
						desc = L["Manager button visibility."],
					},
					mouseoverR = {
						order = 6,
						type = "toggle",
						name = L["Mouseover: Right"],
						desc = L["Manager button visibility."],
					},
					topOffset = {
						order = 7,
						type = "range",
						name = L["Top Offset"],
						desc = "",
						min = 0, max = 25, step = 1
					},
					bottomOffset = {
						order = 8,
						type = "range",
						name = L["Bottom Offset"],
						desc = "",
						min = 0, max = 25, step = 1
					},
					leftOffset = {
						order = 9,
						type = "range",
						name = L["Left Offset"],
						desc = "",
						min = 0, max = 25, step = 1
					},
					rightOffset = {
						order = 10,
						type = "range",
						name = L["Right Offset"],
						desc = "",
						min = 0, max = 25, step = 1
					},
				},
			},
			ChatEditBox = {
				type = "group",
				name = L["ChatEditBox"],
				guiInline = true,
				get = function(info) return db.ChatEditBox[info[#info]] end,
				set = function(info, value) db.ChatEditBox[info[#info]] = value setupChatEditBox(db.ChatEditBox) end,
				disabled = function() return not db.ChatEditBox.enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Custom editbox position and size."],
					},
					yOffset = {
						order = 2,
						type = "range",
						min = -40, max = 40, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
					heightOffset = {
						order = 3,
						type = "range",
						name = L["Height Offset"],
						min = -8, max = 8, step = 1,
						desc = "",
					},
					widthOffset = {
						order = 4,
						type = "range",
						min = -40, max = 40, step = 1,
						name = L["Width Offset"],
						desc = "",
					},
				},
			},
		},
	}
end


function mod:FilterNotPassed(frame, msg, chatType)
	chatType = chatTypes[chatType] and chatType or "OTHER"

	local cleanMsg = mod:StripMsg(msg)
	for _, info in ipairs(frame.filterRules) do
		if (info.types["ALL"] or info.types[chatType]) then
			local matched = mod:MatchPattern(info.parsedExpression, nil, cleanMsg, lower(cleanMsg))
			if (info.blacklist and matched) or (not info.blacklist and not matched) then
				return true
			end
		end
	end
end


local function parsePattern(term)
    if not term then
        return {type = "normal", pattern = ""}
    end

    local pattern = {
        type = "normal",
        pattern = term
    }

    if sub(term, 1, 1) == "!" and sub(term, -1) == "!" then
        pattern.type = "not"
        pattern.pattern = sub(term, 2, -2)
    end

    if sub(term, 1, 1) == "[" and sub(term, -1) == "]" then
        pattern.type = "case"
        pattern.pattern = sub(term, 2, -2)
    end

    if sub(term, 1, 1) == "@" and sub(term, -1) == "@" then
        pattern.type = "lua"
        pattern.pattern = sub(term, 2, -2)
    end

    return pattern
end

function parseOr(tokens, index)
    local left, newIndex = parseAnd(tokens, index)
    while newIndex <= #tokens and tokens[newIndex] == ';' do
        newIndex = newIndex + 1
        local right
        right, newIndex = parseAnd(tokens, newIndex)
        left = {type = "or", left = left, right = right}
    end
    return left, newIndex
end

function parseAnd(tokens, index)
    local left, newIndex = parseTerm(tokens, index)
    while newIndex <= #tokens and tokens[newIndex] == '::' do
        newIndex = newIndex + 1
        local right
        right, newIndex = parseTerm(tokens, newIndex)
        left = {type = "and", left = left, right = right}
    end
    return left, newIndex
end

function parseTerm(tokens, index)
    if index > #tokens then
        return nil, index
    end

    local token = tokens[index]
    if token == '(' then
        local expr, newIndex = parseOr(tokens, index + 1)
        if newIndex <= #tokens and tokens[newIndex] == ')' then
            return expr, newIndex + 1
        else
            return parsePattern('('), index + 1
        end
    elseif token == ')' then
        return parsePattern(')'), index + 1
    else
        return parsePattern(token), index + 1
    end
end

function mod:ParseExpression(tokens)
    return parseOr(tokens, 1)
end


function mod:Tokenize(query)
	if not query then return {} end

    local tokens = {}
    local current = ""
    local inQuotes = false
    local i = 1

    while i <= #query do
        local char = sub(query, i, i)
        if char == '"' then
            inQuotes = not inQuotes
            current = current .. char
        elseif not inQuotes and (char == '(' or char == ')' or char == ';' or (char == ':' and sub(query, i + 1, i + 1) == ':')) then
            if current ~= "" then
                tinsert(tokens, current)
                current = ""
            end
            if char == ':' then
                tinsert(tokens, '::')
                i = i + 1
            else
                tinsert(tokens, char)
            end
        else
            current = current .. char
        end
        i = i + 1
    end

    if current ~= "" then
        tinsert(tokens, current)
    end

    return tokens
end

function mod:StripMsg(msg)
    local strippedMsg, msgMap = "", {}
    local i, j = 1, 1
    local tempMsg = lower(msg)
    local strLen = #tempMsg

    -- timestamps
    local stampStart, stampEnd = find(msg, "^[|%x]*%[[|:%d%s%xaApPmMr]*%][|rR]*[|%x%x%x%x%x%x%x%x%x]*%s*")

    if stampStart then
        i = stampEnd + 1
    end

    -- strip junk text and store real positions
    while i <= strLen do
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
                if link and find(link, "^channel") then
                    i = linkEnd + 1
                elseif linkEnd then
                    i = i + #link + 2 -- skip coded part
                    while i < linkEnd - 1 do
                        local b = byte(tempMsg, i)
                        if b == 124 then -- '|, code start'
                            local nextB = byte(tempMsg, i+1)
                            if nextB == 99 then -- 'c, color code'
                                i = i + 10
                            elseif nextB == 114 then -- 'r, color breaker'
                                i = i + 2
							elseif nextB == 116 then -- 't, texture code'
								i = (find(tempMsg, "|t", i+2) or i) + 2
                            else
                                strippedMsg = strippedMsg .. sub(msg, i, i)
                                msgMap[j], i, j = i, i + 1, j + 1
                            end
                        else
                            strippedMsg = strippedMsg .. sub(msg, i, i)
                            msgMap[j], i, j = i, i + 1, j + 1
                        end
                    end
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
                        if link and find(link, "^channel") then
                            i = linkEnd + 1
                        elseif linkEnd then
                            i = i + #link + 2 -- skip coded part
                            while i < linkEnd - 1 do
                                local b = byte(tempMsg, i)
                                if b == 124 then -- '|, code start'
                                    local nextB = byte(tempMsg, i+1)
                                    if nextB == 99 then -- 'c, color code'
                                        i = i + 10
                                    elseif nextB == 114 then -- 'r, color breaker'
                                        i = i + 2
									elseif nextB == 116 then -- 't, texture code'
										i = (find(tempMsg, "|t", i+2) or i) + 2
                                    else
                                        strippedMsg = strippedMsg .. sub(msg, i, i)
                                        msgMap[j], i, j = i, i + 1, j + 1
                                    end
                                else
                                    strippedMsg = strippedMsg .. sub(msg, i, i)
                                    msgMap[j], i, j = i, i + 1, j + 1
                                end
                            end
                            i = linkEnd + 1
                        else
                            strippedMsg = strippedMsg .. sub(msg, i, codeEnd - 1)
                            for k = i, codeEnd - 1 do
                                msgMap[j], j = k, j + 1
                            end
                            i = codeEnd + 1
                            break
                        end
                    end
                end
            else
                strippedMsg = strippedMsg .. sub(msg, i, i)
                msgMap[j], i, j = i, i + 1, j + 1
            end
        else
            strippedMsg = strippedMsg .. sub(msg, i, i)
            msgMap[j], i, j = i, i + 1, j + 1
        end
    end

    return strippedMsg, msgMap
end

function mod:HighlightText(msg, cleanMsg, cleanMsgLower, msgMap, terms)
    local highlightColor = format("|cff%02x%02x%02x", hlR * 255, hlG * 255, hlB * 255)
    local matches = {}
    local ranges = {}

    -- find matched text
    for _, term in ipairs(terms) do
		local type, patt = term.type, term.pattern
        local pattern = type == "lua" and patt or gsub(type ~= "case" and lower(patt) or patt, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
        local targetMsg = (type ~= "case" and type ~= "lua") and cleanMsgLower or cleanMsg

        local lastIndex = 1
        while true do
            local startClean, endClean = find(sub(targetMsg, lastIndex), pattern)
            if not startClean then break end

            startClean = startClean + lastIndex - 1
            endClean = endClean + lastIndex - 1

            local realStart = msgMap[startClean]
            local realEnd = msgMap[endClean]

            tinsert(matches, {realStart, realEnd})

            lastIndex = endClean + 1
        end
    end

    -- organize matches
    tsort(matches, function(a, b) return a[1] < b[1] end)

    local currentRange = nil
    for _, matchVal in ipairs(matches) do
        if currentRange then
            if matchVal[1] <= currentRange[2] + 1 then
                currentRange[2] = max(currentRange[2], matchVal[2])
            else
                tinsert(ranges, currentRange)
                currentRange = {matchVal[1], matchVal[2]}
            end
        else
            currentRange = {matchVal[1], matchVal[2]}
        end
    end

    if currentRange then
        tinsert(ranges, currentRange)
    end

    -- apply highlights with color restoration
    local parts = {}
    local lastPos = 1
	local lastColor = ""

    for _, range in ipairs(ranges) do
        if range[1] > lastPos then
            tinsert(parts, sub(msg, lastPos, range[1] - 1))
        end

		local highlightedPart = sub(msg, range[1], range[2])
		local reversedPart = reverse(sub(msg, lastPos, range[1] - 1))
		local colorStart, _, prevColor = find(reversedPart, "(%x%x%x%x%x%x%x%x%x|)")
		local resetStart = find(reversedPart, "[rR]|")

		if not resetStart then
			resetStart = find(reverse(highlightedPart), "[rR]|")
			if resetStart then
				colorStart, _, prevColor = find(reverse(highlightedPart), "(%x%x%x%x%x%x%x%x%x|)")
			end
		end

		if prevColor and (not resetStart or resetStart > colorStart) then
			lastColor = reverse(prevColor)
		end

		local cleanedTargetPart = gsub(gsub(highlightedPart, "|[rR]", ""), "|%x%x%x%x%x%x%x%x%x", "")
        tinsert(parts, highlightColor)
        tinsert(parts, cleanedTargetPart)
        tinsert(parts, "|r"..lastColor)

        lastPos = range[2] + 1
    end

    if lastPos <= #msg then
        tinsert(parts, lastColor..sub(msg, lastPos))
    end

    return tconcat(parts)
end

function mod:MatchPattern(pattern, highlight_patterns, cleanMsg, cleanMsgLower)
	if not pattern then return true end

	local found = false
	if pattern.type == "normal" then
		found = find(cleanMsgLower, lower(pattern.pattern), 1, true)
		if found and highlight_patterns then
			tinsert(highlight_patterns, {type = "normal", pattern = pattern.pattern})
		end
	elseif pattern.type == "not" then
		if sub(pattern.pattern, 1, 1) == "[" and sub(pattern.pattern, -1) == "]" then
			found = not find(cleanMsg, sub(pattern.pattern, 2, -2), 1, true)
		elseif sub(pattern.pattern, 1, 1) == "@" and sub(pattern.pattern, -1) == "@" then
			found = not find(cleanMsg, sub(pattern.pattern, 2, -2))
		else
			found = not find(cleanMsgLower, lower(pattern.pattern), 1, true)
		end
	elseif pattern.type == "case" then
		found = find(cleanMsg, pattern.pattern, 1, true)
		if found and highlight_patterns then
			tinsert(highlight_patterns, {type = "case", pattern = pattern.pattern})
		end
	elseif pattern.type == "lua" then
		found = find(cleanMsg, pattern.pattern)
		if found and highlight_patterns then
			tinsert(highlight_patterns, {type = "lua", pattern = pattern.pattern})
		end
	elseif pattern.type == "and" then
		found = self:MatchPattern(pattern.left, highlight_patterns, cleanMsg, cleanMsgLower) and self:MatchPattern(pattern.right, highlight_patterns, cleanMsg, cleanMsgLower)
	elseif pattern.type == "or" then
		found = self:MatchPattern(pattern.left, highlight_patterns, cleanMsg, cleanMsgLower) or self:MatchPattern(pattern.right, highlight_patterns, cleanMsg, cleanMsgLower)
	end

	return found
end

function mod:PerformSearch(frame, query)
	if not query or query == "" then
		frame:Clear()
		return
	end

    twipe(searchResults)

    local queryTree = self:ParseExpression(self:Tokenize(query))
	local displayingFiltered = frame.displayingFiltered
    local lastHistoryMsg = (not displayingFiltered and lastHisoryMsgIndex[frame] and not frame.searchArgs["HISTORY"]) and lastHisoryMsgIndex[frame] or -1
	local targetTable = (displayingFiltered and filteredMsgs[frame].processed) or (not displayingFiltered and savedChatState[frame])
    local highlight_patterns = {}

	if frame.searchArgs["LIVE"] and ((displayingFiltered and next(filteredMsgs[frame].raw)) or (not displayingFiltered and next(blockedMsgs[frame]))) then
		updateChatState(frame)
	end

    for i, info in ipairs(targetTable) do
		if i > lastHistoryMsg then
			local validType = true
			if not frame.searchArgs["ALL"] then
				local extractedChatType = getChatTypeFromMessage(info.msg)
				validType = frame.searchArgs[extractedChatType]
			end
			if validType then
				local cleanMsg, msgMap = self:StripMsg(info.msg)
				local cleanMsgLower = lower(cleanMsg)
				if self:MatchPattern(queryTree, highlight_patterns, cleanMsg, cleanMsgLower) then
					tinsert(searchResults, self:HighlightText(info.msg, cleanMsg, cleanMsgLower, msgMap, highlight_patterns))
				end

				twipe(highlight_patterns)
			end
		end
    end

    self:DisplaySearchResults(frame, searchResults, query)
end

function mod:DisplaySearchResults(frame, results, query)
	CH.db.copyChatLines = false

	frame.displayingSearchResults = true
    frame:Clear()

    for _, msg in ipairs(results) do
		frame:AddMessage(msg)
    end

    if #results == 0 then
        frame:AddMessage("No results found.", rBad, gBad, bBad)
		frame.searchNoResults = true
    end

	frame.displayingSearchResults = nil

	if frame.displayingFiltered then return end

	if not tcontains(prompts, query) then
		if #prompts > 20 then
			tremove(prompts, 1)
			for i = 1, 20 do
				tremove(prompts, i)
				tinsert(prompts, i, prompts[i+1])
			end
		else
			tinsert(prompts, query)
		end
		historyIndex = #prompts
	end

	if not tcontains(recentQueries, query) then
		if #recentQueries > 10 then
			tremove(recentQueries, 1)
			for i = 1, 10 do
				tremove(recentQueries, i)
				tinsert(recentQueries, i, recentQueries[i+1])
			end
		else
			tinsert(recentQueries, query)
		end
	end
	CH.db.copyChatLines = copyChatLines
end


function mod:Toggle(db)
	setupSearchFilter(db.SearchFilter)
	setupCompactChat(db.CompactChat)
	setupChatEditBox(db.ChatEditBox)
end

function mod:InitializeCallback()
	local hex = gsub(core.customColorBad, "|c%w%w", "")
	rBad = tonumber(sub(hex, 1, 2), 16) / 255
	gBad = tonumber(sub(hex, 3, 4), 16) / 255
	bBad = tonumber(sub(hex, 5, 6), 16) / 255

	local db = E.db.Extras.general[modName]
	mod:LoadConfig(db)
	mod:Toggle(core.reload and {SearchFilter = {}, CompactChat = {}, ChatEditBox = {}} or db)
	if core.reload then twipe(mod.initialized) end
end

core.modules[modName] = mod.InitializeCallback