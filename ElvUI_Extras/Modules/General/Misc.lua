local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("GeneralMisc.", "AceHook-3.0")

local modName = mod:GetName()
local initialized, alertFrame = {}
local chatTypeIndexToName = {}

local max = math.max
local _G, unpack, pairs, ipairs, tonumber, print, pcall, loadstring, tostring = _G, unpack, pairs, ipairs, tonumber, print, pcall, loadstring, tostring
local lower, find, match, gsub, sub, format = string.lower, string.find, string.match, string.gsub, string.sub, string.format
local twipe, tinsert = table.wipe, table.insert
local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter
local GetSpellLink, GetSpellTexture = GetSpellLink, GetSpellTexture
local UnitExists, GetItemIcon = UnitExists, GetItemIcon
local ITEM_SPELL_TRIGGER_ONEQUIP = "^"..ITEM_SPELL_TRIGGER_ONEQUIP
local ITEM_SPELL_TRIGGER_ONUSE = "^"..ITEM_SPELL_TRIGGER_ONUSE
local ITEM_COOLDOWN_TOTAL = format(gsub(ITEM_COOLDOWN_TOTAL, "[%(%)]", ""), SECONDS_ABBR)
local ITEM_SET_BONUS = gsub(format(ITEM_SET_BONUS, 1), "[1%p]+", "")

local procStats = core.Misc_data and core.Misc_data[GetLocale()] or {}
local allTipScrits = {}

local function runAllScripts(tt)
	for _, script in pairs(allTipScrits) do
		script(tt)
	end
end

local chatMsgEvents = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_MONSTER_PARTY",
	"CHAT_MSG_MONSTER_SAY",
	"CHAT_MSG_MONSTER_WHISPER",
	"CHAT_MSG_MONSTER_YELL",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SYSTEM",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_YELL",
	"CHAT_MSG_COMBAT_MISC_INFO",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_ITEM_PUSH",
	"CHAT_MSG_TRADESKILLS",
	"CHAT_MSG_CURRENCY",
	"CHAT_MSG_BATTLEGROUND_LEADER",
}

for chatType in pairs(ChatTypeInfo) do
	chatTypeIndexToName[GetChatTypeIndex(chatType)] = chatType
end


P["Extras"]["general"][modName] = {
	["selectedSubSection"] = 'ItemIcons',
	["InternalCooldowns"] = {
		["enabled"] = false,
		["desc"] = L["Displays internal cooldowns on trinket tooltips."],
	},
	["ItemIcons"] = {
		["enabled"] = false,
		["desc"] = L["Adds an icon next to chat hyperlinks."],
		["size"] = 16,
		["orientation"] = "left",
	},
	["TooltipNotes"] = {
		["enabled"] = false,
		["desc"] = L["Usage:"..
					"\n/tnote list - returns all eixting notes"..
					"\n/tnote wipe - clears all existing notes"..
					"\n/tnote 1 icon Interface\\Path\\ToYourIcon - same as set (except for the lua part)"..
					"\n/tnote 1 get - same as set, returns existing notes"..
					"\n/tnote 1 set YourNoteHere - adds a note to the designated index from the list "..
					"or to a currently shown tooltip text if the second argument (1 in this case) is ommitted, "..
					"supports functions and coloring "..
					"(providing no text clears the note);"..
					"\nto break the lines, use ::"..
					"\n\nExample:"..
					"\n\n/tnote 3 set fire pre-bis::source: Joseph Mama"..
					"\n\n/tnote set local percentage ="..
					"\n  UnitHealth('mouseover') / "..
					"\n  UnitHealthMax('mouseover')"..
					"\nreturn string.format('\124\124cffffd100(default color)'"..
					"\n  ..UnitName('mouseover')"..
					"\n  ..': \124\124cff%02x%02x00'"..
					"\n  ..UnitHealth('mouseover'), "..
					"\n  (1-percentage)*255, percentage*255)"],
		["notes"] = {},
	},
	["EnterCombatAlert"] = {
		["enabled"] = false,
		["desc"] = L["Combat state notification alerts."],
		["customText"] = false,
		["customTextEnter"] = "Combat Engaged",
		["customTextLeave"] = "Left Combat",
		["customTex"] = "",
		["textColor"] = { 1, 1, 1 },
		["font"] = E.db.general.font,
		["fontSize"] = E.db.general.fontSize,
		["fontOutline"] = "OUTLINE",
		["bgWidth"] = 400,
		["bgHeight"] = 60,
	},
	["GlobalShadow"] = {
		["enabled"] = false,
		["desc"] = L["Adds shadows to all of the frames."..
		"\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."],
		["size"] = 2,
		["color"] = {0,0,0,0.8},
	},
}

function mod:LoadConfig()
	local db = E.db.Extras.general[modName]
	local function selectedSubSection() return db.selectedSubSection end
	core.general.args[modName] = {
		type = "group",
		name = L["Misc."],
		get = function(info) return db[selectedSubSection()][info[#info]] end,
		set = function(info, value) db[selectedSubSection()][info[#info]] = value self:Toggle() end,
		args = {
			SubSection = {
				order = 1,
				type = "group",
				name = L["Sub-Section"],
				guiInline = true,
				disabled = false,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = function() return L[db[selectedSubSection()].desc] end,
						get = function() return db[selectedSubSection()].enabled end,
						set = function(_, value) db[selectedSubSection()].enabled = value self:Toggle()
							if selectedSubSection() == 'GlobalShadow' then E:StaticPopup_Show("PRIVATE_RL") end
						end,
					},
					selectedSubSection = {
						order = 2,
						type = "select",
						name = L["Select"],
						desc = "",
						get = function() return selectedSubSection() end,
						set = function(_, value) db.selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(db) do
								if section ~= 'selectedSubSection' then
									dropdownValues[section] = L[section]
								end
							end
							return dropdownValues
						end,
					},
				},
			},
			GlobalShadow = {
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function(info) return not db[info[#info-1]].enabled end,
				hidden = function() return selectedSubSection() ~= 'GlobalShadow' end,
				args = {
					color = {
						type = "color",
						hasAlpha = true,
						name = L["Color"],
						desc = L["REQUIRES RELOAD."],
						get = function(info) return unpack(db[selectedSubSection()][info[#info]]) end,
						set = function(info, r, g, b, a) db[selectedSubSection()][info[#info]] = {r,g,b,a} E:StaticPopup_Show("PRIVATE_RL") end,
					},
					size = {
						type = "range",
						min = 1, max = 8, step = 1,
						name = L["Size"],
						desc = L["REQUIRES RELOAD."],
						set = function(info, value) db[selectedSubSection()][info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
					},
				},
			},
			ItemIcons = {
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function(info) return not db[info[#info-1]].enabled end,
				hidden = function() return selectedSubSection() ~= 'ItemIcons' end,
				args = {
					orientation = {
						type = "select",
						order = 1,
						name = L["Icon Orientation"],
						desc = L["Icon to the left or right of the item link."],
						values = {
							["left"] = L["Left"],
							["right"] = L["Right"],
						},
					},
					size = {
						type = "range",
						order = 2,
						min = 8, max = 32, step = 1,
						name = L["Icon Size"],
						desc = L["The size of the icon in the chat frame."],
					},
				},
			},
			EnterCombatAlert = {
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function(info) return not db[info[#info-1]].enabled end,
				hidden = function() return selectedSubSection() ~= 'EnterCombatAlert' end,
				args = {
					textColor = {
						order = 1,
						type = "color",
						width = "full",
						name = L["Text Color"],
						desc = L["255, 210, 0 - Blizzard's yellow."],
						get = function() return unpack(db.EnterCombatAlert.textColor) end,
						set = function(_, r, g, b) db.EnterCombatAlert.textColor = { r, g, b } self:EnterCombatAlert(true) end,
					},
					customTextEnter = {
						order = 2,
						type = "input",
						name = L["Entering combat"],
						desc = L["Text to display upon entering combat."],
					},
					customTextLeave = {
						order = 3,
						type = "input",
						name = L["Leaving combat"],
						desc = L["Text to display upon leaving combat."],
					},
					font = {
						order = 4,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end,
					},
					fontOutline = {
						order = 5,
						type = "select",
						name = L["Font Outline"],
						desc = "",
						values = {
							[""] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE",
							["MONOCHROME"] = "MONOCHROME",
							["OUTLINEMONOCHROME"] = "OUTLINEMONOCHROME",
						},
					},
					fontSize = {
						order = 6,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1
					},
					bgWidth = {
						order = 7,
						type = "range",
						name = L["Texture Width"],
						desc = "",
						min = 4, max = 800, step = 1
					},
					bgHeight = {
						order = 8,
						type = "range",
						name = L["Texture Height"],
						desc = "",
						min = 4, max = 600, step = 1
					},
					customTex = {
						order = 9,
						type = "input",
						name = L["Custom Texture"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
					},
				},
			},
		},
	}
end


function mod:InternalCooldowns(enable)
	if enable then
		local function appendICD(tt)
			local _, itemLink = tt:GetItem()
			if not itemLink then return end

			local itemID = match(itemLink, "item:(%d+)")
			if not itemID then return end

			local data = procStats[itemID]
			if not data then return end

			local greentexts = 1
			for i = 1, tt:NumLines() do
				local leftLine = _G[tt:GetName().."TextLeft"..i]
				if leftLine then
					local lineText = leftLine:GetText()
					if lineText and (find(lineText, ITEM_SPELL_TRIGGER_ONEQUIP) or find(lineText, ITEM_SPELL_TRIGGER_ONUSE)
								or find(lineText, ITEM_SET_BONUS)) then
						if greentexts == data.pos then
							leftLine:SetText(lineText.." "..format(data.text, format(ITEM_COOLDOWN_TOTAL, data.cooldown)))
							tt:Show()
							break
						end
						greentexts = greentexts + 1
					end
				end
			end
		end

		if not self:IsHooked(GameTooltip, 'OnTooltipSetItem') then
			self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', runAllScripts)
		end
		if not self:IsHooked(ItemRefTooltip, 'OnTooltipSetItem') then
			self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', runAllScripts)
		end
		if not self:IsHooked(ShoppingTooltip1, 'OnTooltipSetItem') then
			self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', runAllScripts)
		end
		if not self:IsHooked(ShoppingTooltip2, 'OnTooltipSetItem') then
			self:SecureHookScript(ShoppingTooltip2, 'OnTooltipSetItem', runAllScripts)
		end
		allTipScrits['icd'] = appendICD
		initialized.InternalCooldowns = true
	elseif initialized.InternalCooldowns then
		allTipScrits['icd'] = nil
		if not E.db.Extras.general[modName].TooltipNotes.enabled then
			if self:IsHooked(GameTooltip, 'OnTooltipSetItem') then
				self:Unhook(GameTooltip, 'OnTooltipSetItem')
			end
			if self:IsHooked(ItemRefTooltip, 'OnTooltipSetItem') then
				self:Unhook(ItemRefTooltip, 'OnTooltipSetItem')
			end
			if self:IsHooked(ShoppingTooltip1, 'OnTooltipSetItem') then
				self:Unhook(ShoppingTooltip1, 'OnTooltipSetItem')
			end
			if self:IsHooked(ShoppingTooltip2, 'OnTooltipSetItem') then
				self:Unhook(ShoppingTooltip2, 'OnTooltipSetItem')
			end
		end
	end
end


function mod:TooltipNotes(enable)
	if enable then
		local notes = E.db.Extras.general[modName].TooltipNotes.notes
		local notesIndex = {}

		local function manageFuncNotes(data)
			if data then
				local luaFunction, errorMsg = loadstring(data.text)
				if luaFunction then
					local success, func = pcall(luaFunction)
					if not success then
						core:print('FAIL', L["TooltipNotes"], func)
						return
					else
						data.func = luaFunction
					end
				elseif data.func then
					core:print('LUA', L["TooltipNotes"], errorMsg)
					data.func = nil
				end
			else
				for _, noteData in pairs(notes) do
					local luaFunction = loadstring(noteData.text)
					if luaFunction then
						local success, func = pcall(luaFunction)
						if not success then
							core:print('FAIL', L["TooltipNotes"], func)
							return
						else
							noteData.func = luaFunction
						end
					end
				end
			end
		end
		manageFuncNotes()

		local function updateNotesIndex()
			twipe(notesIndex)
			for key in pairs(notes) do
				tinsert(notesIndex, key)
			end
		end
		updateNotesIndex()

		local function getTooltipKey()
			local _, itemLink = GameTooltip:GetItem()
			if itemLink then
				return "item:" .. itemLink
			end
			local _, _, spellID = GameTooltip:GetSpell()
			if spellID then
				return "spell:" .. spellID
			end
			local unitName = GameTooltip:GetUnit()
			if unitName then
				return "unit:" .. unitName
			end
			local tooltipText = GameTooltipTextLeft1:GetText()
			if tooltipText then
				return "text:" .. tooltipText
			end
			return nil
		end

		local function getTargetInfo(type, target)
			if type == 'item' then
				return target, GetItemIcon(tonumber(match(target, "item:(%d+)")))
			elseif type == 'spell' then
				return GetSpellLink(tonumber(target)), GetSpellTexture(tonumber(target))
			elseif type == 'unit' then
				return "|cffffd100"..target.."|r", "Interface\\CharacterFrame\\TempPortrait"
			else
				return "|cff71D5FF"..target.."|r"
			end
		end

		local function updateTooltip()
			local tt = GameTooltip
			if not tt:IsShown() then return end

			local _, unit = tt:GetUnit()
			local _, itemLink = tt:GetItem()
			local _, _, spellID = tt:GetSpell()

			if unit then
				tt:SetUnit(unit)
			elseif itemLink then
				tt:ClearLines()
				tt:SetHyperlink(itemLink)
			elseif spellID then
				tt:SetSpellByID(spellID)
			else
				local owner = tt:GetOwner()
				if owner then
					local OnEnterScript = owner:GetScript("OnEnter")
					if OnEnterScript then
						OnEnterScript(owner)
						return
					end
				end
				print(core.customColorAlpha..L["Hover again to see the changes."])
			end
		end

		local function setNoteForTooltip(key, type, target, note)
			local link, texture = getTargetInfo(type, target and target or "")
			local icon = notes[key] and notes[key].icon

			if note and match(note, '%S+') then
				notes[key] = notes[key] or {}
				notes[key].text = note
				updateNotesIndex()
				manageFuncNotes(notes[key])
				print(core.customColorAlpha..L["Note set for "]..(texture and ("|T"..texture..":0|t ") or "")..link.."|r:", icon and "|T"..icon..":0|t "..(note or "") or note)
			elseif notes[key] then
				if not notes[key].icon then notes[key] = nil else notes[key].text = nil end
				updateNotesIndex()
				print(core.customColorAlpha..L["Note cleared for "]..(texture and ("|T"..texture..":0|t ") or "")..link)
			else
				print(core.customColorAlpha..L["No note to clear for "]..(texture and ("|T"..texture..":0|t ") or "")..link)
			end
		end

		local function setIconForTooltip(key, type, target, icon)
			local link, texture = getTargetInfo(type, target and target or "")

			if icon and match(icon, '%S+') then
				notes[key] = notes[key] or {}
				notes[key].icon = icon
				updateNotesIndex()
				print(core.customColorAlpha..L["Added icon to the note for "]..(texture and ("|T"..texture..":0|t ") or "")..link.."|r:", "|T"..icon..":0|t")
			elseif notes[key].icon then
				if not notes[key].text then notes[key] = nil else notes[key].icon = nil end
				updateNotesIndex()
				print(core.customColorAlpha..L["Note icon cleared for "]..(texture and ("|T"..texture..":0|t ") or "")..link)
			else
				print(core.customColorAlpha..L["No note icon to clear for "]..(texture and ("|T"..texture..":0|t ") or "")..link)
			end
		end

		local function getNoteForTooltip(key, type, target)
			if notes[key] then
				local link, texture = getTargetInfo(type, target and target or "")
				local icon, text = notes[key].icon, notes[key].text
				local note = icon and "|T"..icon..":0|t "..(text or "") or text

				print(core.customColorAlpha..L["Current note for "]..(texture and ("|T"..texture..":0|t ") or "")..link.."|r:", note)
			else
				print(core.customColorAlpha..L["No note found for this tooltip."])
			end
		end

		local function listAllNotes()
			local noteList = {}
			for index, key in ipairs(notesIndex) do
				local type, target = match(key, '(%P+):(.+)')
				local link, texture = getTargetInfo(type, target and target or "")
				local icon, text = notes[key].icon, notes[key].text
				local note = icon and "|T"..icon..":0|t "..(text or "") or text
				tinsert(noteList, index .. ". " .. (texture and ("|T"..texture..":0|t ") or "")..link.."|r: "..note)
			end
			if #noteList > 0 then
				print(core.customColorAlpha..L["Notes: "].."|r")
				for _, note in ipairs(noteList) do
					print(note)
				end
			else
				print(core.customColorBeta..L["No notes are set."])
			end
		end

		SLASH_TOOLTIPNOTES1 = "/tnote"
		SlashCmdList["TOOLTIPNOTES"] = function(msg)
			local index, command, value = match(msg, "^(%d*)%s*(%S*)%s*(.-)$")

			if command == "set" or command == "get" or command == "icon" then
				local key
				index = tonumber(index)
				if index and notesIndex[index] then
					key = notesIndex[index]
				else
					key = getTooltipKey()
				end

				if not key then
					print(core.customColorBeta..L["No tooltip is currently shown or unsupported tooltip type."])
					return
				else
					local type, target = match(key, '(%P+):(.+)')
					if command == "set" or command == "icon" then
						if command == "set" then
							setNoteForTooltip(key, type, target, value)
						else
							setIconForTooltip(key, type, target, value)
						end
						updateTooltip()
					else
						getNoteForTooltip(key, type, target)
					end
				end
			elseif command == "list" then
				listAllNotes()
			elseif command == "wipe" then
				twipe(notes)
				updateNotesIndex()
				updateTooltip()
				print(core.customColorAlpha..L["All notes have been cleared."])
			else
				print(core.customColorBeta..L[E.db.Extras.general[modName].TooltipNotes.desc])
			end
		end

		local function exactSplit(text, delimiter)
			local results = {}
			local startIndex = 1
			local delimiterLength = #delimiter

			while true do
				local delimiterIndex = find(text, delimiter, startIndex, true)
				if not delimiterIndex then
					tinsert(results, sub(text, startIndex))
					break
				end

				tinsert(results, sub(text, startIndex, delimiterIndex - 1))
				startIndex = delimiterIndex + delimiterLength
			end

			return results
		end

		local function applyColors(text)
			if not text or not tostring(text) then return end

			local lines = {}
			local defaultR, defaultG, defaultB = 1, 0.82, 0

			for _, line in ipairs(exactSplit(text, "::")) do
				local r, g, b = defaultR, defaultG, defaultB
				local loweredLine = lower(line)

				-- find the first color code in the line
				local _, _, color = find(loweredLine, "\124cff(%x%x%x%x%x%x)")
				if color then
					r = tonumber(sub(color, 1, 2), 16) / 255
					g = tonumber(sub(color, 3, 4), 16) / 255
					b = tonumber(sub(color, 5, 6), 16) / 255
				end

				tinsert(lines, {text = line, r = r, g = g, b = b})
			end

			return lines
		end

		local funcHandler = CreateFrame("Frame")
		funcHandler.elapsed = 0

		local function handler(tt)
			local key = getTooltipKey()
			if not key or not notes[key] then return end
			local icon, text, func = notes[key].icon, notes[key].text, notes[key].func
			local iconString = icon and ("|T"..icon..":0|t ") or ""
			tt:AddLine(" ")
			if text then
				if func then
					funcHandler:SetScript("OnUpdate", function(self, elapsed)
						self.elapsed = self.elapsed + elapsed
						if UnitExists('mouseover') then
							text = applyColors(func())
							for i, line in pairs(text) do
								if line.text ~= "" then
									if i == 1 then
										tt:AddLine(iconString..line.text, line.r, line.g, line.b)
									else
										tt:AddLine(line.text, line.r, line.g, line.b)
									end
								end
							end
							tt:Show()
							self.elapsed = 0
							self:SetScript("OnUpdate", nil)
						elseif self.elapsed > 0.1 then
							self.elapsed = 0
							self:SetScript("OnUpdate", nil)
						end
					end)
					return
				else
					for i, line in ipairs(exactSplit(text, "::")) do
						if line ~= "" then
							if i == 1 then
								tt:AddLine(iconString..line, 1, 0.82, 0)
							else
								tt:AddLine(line, 1, 0.82, 0)
							end
						end
					end
				end
			elseif icon then
				tt:AddLine(iconString, 1, 0.82, 0)
			end
			tt:Show()
		end

		if not self:IsHooked(GameTooltip, "OnShow") then
			self:SecureHookScript(GameTooltip, "OnShow", function(tt)
				local key = getTooltipKey()
				if not key then return end
				local type = match(key, '(%P+):')
				if type == 'text' then handler(tt) end
			end)
		end

		for _, func in pairs({'OnTooltipSetUnit', 'OnTooltipSetSpell'}) do
			if not self:IsHooked(GameTooltip, func) then self:SecureHookScript(GameTooltip, func, handler) end
		end
		if not self:IsHooked(GameTooltip, 'OnTooltipSetItem') then
			self:SecureHookScript(GameTooltip, 'OnTooltipSetItem', runAllScripts)
		end
		if not self:IsHooked(ItemRefTooltip, 'OnTooltipSetItem') then
			self:SecureHookScript(ItemRefTooltip, 'OnTooltipSetItem', runAllScripts)
		end
		if not self:IsHooked(ShoppingTooltip1, 'OnTooltipSetItem') then
			self:SecureHookScript(ShoppingTooltip1, 'OnTooltipSetItem', runAllScripts)
		end
		if not self:IsHooked(ShoppingTooltip2, 'OnTooltipSetItem') then
			self:SecureHookScript(ShoppingTooltip2, 'OnTooltipSetItem', runAllScripts)
		end
		allTipScrits['notes'] = handler
		initialized.TooltipNotes = true
	elseif initialized.TooltipNotes then
		allTipScrits['notes'] = nil
		SLASH_TOOLTIPNOTES1 = nil
		SlashCmdList["TOOLTIPNOTES"] = nil
		hash_SlashCmdList["/TOOLTIPNOTES"] = nil
		for _, func in pairs({'OnShow', 'OnTooltipSetUnit', 'OnTooltipSetSpell'}) do
			if self:IsHooked(GameTooltip, func) then self:Unhook(GameTooltip, func) end
		end
		if not E.db.Extras.general[modName].InternalCooldowns.enabled then
			if self:IsHooked(GameTooltip, 'OnTooltipSetItem') then
				self:Unhook(GameTooltip, 'OnTooltipSetItem')
			end
			if self:IsHooked(ItemRefTooltip, 'OnTooltipSetItem') then
				self:Unhook(ItemRefTooltip, 'OnTooltipSetItem')
			end
			if self:IsHooked(ShoppingTooltip1, 'OnTooltipSetItem') then
				self:Unhook(ShoppingTooltip1, 'OnTooltipSetItem')
			end
			if self:IsHooked(ShoppingTooltip2, 'OnTooltipSetItem') then
				self:Unhook(ShoppingTooltip2, 'OnTooltipSetItem')
			end
		end
	end
end

function mod:ItemIcons(enable)
	local ChatTypeInfo = ChatTypeInfo

	if enable then
		if not initialized.ItemIcons then
			-- credit: ElvUI_ChatTweaks
			local db = E.db.Extras.general[modName].ItemIcons
			function mod:ItemIconsFilter(_, msg, ...)
				msg = gsub(msg, "(\124%x%x%x%x%x%x%x%x%x\124[Hh]item:.-\124[hH]\124[rR])", function(link)
					local texture = GetItemIcon(link)
					return (db.orientation == "left") and "\124T" .. texture .. ":" .. db.size .. "\124t" .. link or link .. "\124T" .. texture .. ":" .. db.size .. "\124t"
				end)
				return false, msg, ...
			end

			local messages = {}

			for i = 1, NUM_CHAT_WINDOWS do
				local frame = _G["ChatFrame"..i]
				messages[frame] = {}
				local maxLines = frame:GetMaxLines()
				local numMessages = frame:GetNumMessages()
				local ChatTypeInfo = ChatTypeInfo

				for i = max(1, numMessages - maxLines + 1), numMessages do
					if numMessages - i > maxLines then break end
					local msg, _, lineID = frame:GetMessageInfo(i)
					local info = ChatTypeInfo[chatTypeIndexToName[lineID]]
					local r, g, b = info.r, info.g, info.b
					tinsert(messages[frame], {msg = msg, r = r, g = g, b = b})
				end

				frame:Clear()

				for _, info in ipairs(messages[frame]) do
					local msg = info.msg
					frame:AddMessage(gsub(msg, "(\124c%x+\124Hitem:.-\124h\124r)",
						function(link)
							local texture = GetItemIcon(link)
							return (db.orientation == "left") and "\124T"..(texture or "")..":"..db.size.."\124t"..link
																or link.."\124T"..(texture or "")..":"..db.size.."\124t"
						end),
						info.r, info.g, info.b)
				end
			end
			initialized.ItemIcons = true
		end

		for _, event in ipairs(chatMsgEvents) do
			ChatFrame_AddMessageEventFilter(event, self.ItemIconsFilter)
		end
	elseif initialized.ItemIcons then
		for _, event in ipairs(chatMsgEvents) do
			ChatFrame_RemoveMessageEventFilter(event, self.ItemIconsFilter)
		end
	end
end

function mod:EnterCombatAlert(enable)
	if enable then
		if not initialized.EnterCombatAlert then
			alertFrame = CreateFrame("Frame", "alertFrame", UIParent)
			alertFrame:SetClampedToScreen(true)
			alertFrame:Size(300, 65)
			alertFrame:Point("TOP", UIParent, "TOP", 0, -280)
			alertFrame.text = alertFrame:CreateFontString(nil, "ARTWORK", "GameTooltipText")
			alertFrame.Bg = alertFrame:CreateTexture(nil, "BACKGROUND")
			alertFrame.text:SetAllPoints()
			alertFrame.text:SetJustifyH("CENTER")
			alertFrame.Bg:SetAllPoints()
			alertFrame:SetScript("OnUpdate", function(self, elapsed)
				self.timer = self.timer + elapsed
				if (self.timer > self.totalTime) then self:Hide() end
				if (self.timer <= 0.5) then
					self:SetAlpha(self.timer * 2)
				elseif (self.timer > 2) then
					self:SetAlpha(1 - (self.timer - 2) /(self.totalTime - 2))
				end
			end)
			alertFrame:SetScript("OnShow", function(self)
				self.totalTime = 2.5
				self.timer = 0
			end)
			alertFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
			alertFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
			alertFrame:Hide()

			E:CreateMover(alertFrame, "alertFrameMover", L["Enter Combat Alert"], nil, nil, nil, 'ALL,SOLO')

			initialized.EnterCombatAlert = true
		end
		E:EnableMover("alertFrameMover")

		local db = E.db.Extras.general[modName].EnterCombatAlert
		alertFrame.text:SetTextColor(unpack(db.textColor))
		alertFrame.text:SetFont(E.Libs.LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
		alertFrame.Bg:SetTexture(db.customTex)
		alertFrame:Size(db.bgWidth, db.bgHeight)
		alertFrame:SetScript("OnEvent", function(self, event)
			self:Hide()
			if (event == "PLAYER_REGEN_DISABLED") then
				self.text:SetText(db.customTextEnter)
			elseif (event == "PLAYER_REGEN_ENABLED") then
				self.text:SetText(db.customTextLeave)
			end
			self:Show()
		end)
	elseif initialized.EnterCombatAlert then
		E:DisableMover("alertFrameMover")
		alertFrame:SetScript("OnEvent", nil)
		alertFrame:Hide()
	end
end

function mod:GlobalShadow(enable)
	if enable then
		E.globalShadow = E.db.Extras.general[modName].GlobalShadow
	end
end

function mod:Toggle()
	for mod, info in pairs(E.db.Extras.general[modName]) do
		if self[mod] and info.enabled ~= nil then
			self[mod](self, info.enabled)
		end
	end
end

function mod:InitializeCallback()
	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback