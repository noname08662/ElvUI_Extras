local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("GeneralMisc.", "AceHook-3.0")
local S = E:GetModule("Skins")

local modName = mod:GetName()
local alertFrame
local chatTypeIndexToName = {}

mod.initialized = {}

local max, floor = math.max, math.floor
local _G, unpack, pairs, ipairs, tonumber, print, pcall, loadstring, tostring = _G, unpack, pairs, ipairs, tonumber, print, pcall, loadstring, tostring
local lower, find, match, gsub, sub, format = string.lower, string.find, string.match, string.gsub, string.sub, string.format
local twipe, tinsert = table.wipe, table.insert
local ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter = ChatFrame_AddMessageEventFilter, ChatFrame_RemoveMessageEventFilter
local GetSpellLink, GetSpellTexture = GetSpellLink, GetSpellTexture
local GetLFGQueueStats, GetLFGInfoServer = GetLFGQueueStats, GetLFGInfoServer
local GetTime = GetTime
local UnitExists, GetItemIcon = UnitExists, GetItemIcon
local ITEM_SPELL_TRIGGER_ONEQUIP = "^"..ITEM_SPELL_TRIGGER_ONEQUIP
local ITEM_SPELL_TRIGGER_ONUSE = "^"..ITEM_SPELL_TRIGGER_ONUSE
local ITEM_COOLDOWN_TOTAL = format(gsub(ITEM_COOLDOWN_TOTAL, "[%(%)]", ""), gsub(SECONDS_ABBR, "%.$", ""))
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
			"\n/tnote list - returns all existing notes"..
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
	["RDFQueueTracker"] = {
		["enabled"] = false,
		["desc"] = L["Random dungeon finder queue status frame."],
		["iconSize"] = 15,
		["iconSpacing"] = 5,
		["point"] = "TOP",
		["relativeTo"] = "BOTTOM",
		["xOffset"] = 0,
		["yOffset"] = -15,
		["queueTime"] = true,
		["queueTimeColor"] = {0.7,0.7,0.7},
		["font"] = E.db.general.font,
		["fontSize"] = E.db.general.fontSize,
		["fontOutline"] = "OUTLINE",
		["timeXOffset"] = 0,
		["timeYOffset"] = -20,
	},
}

function mod:LoadConfig(db)
	local function selectedSubSection() return db.selectedSubSection end
	core.general.args[modName] = {
		type = "group",
		name = L["Misc."],
		get = function(info) return db[selectedSubSection()][info[#info]] end,
		set = function(info, value) db[selectedSubSection()][info[#info]] = value self:Toggle(db) end,
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
						set = function(_, value) db[selectedSubSection()].enabled = value self:Toggle(db)
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
						set = function(_, r, g, b) db.EnterCombatAlert.textColor = { r, g, b } self:EnterCombatAlert(db) end,
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
			RDFQueueTracker = {
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function(info) return not db[info[#info-1]].enabled end,
				hidden = function() return selectedSubSection() ~= 'RDFQueueTracker' end,
				args = {
					queueTime = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Queue Time"],
						desc = "",
					},
					queueTimeColor = {
						order = 2,
						type = "color",
						name = L["Text Color"],
						desc = "",
						get = function(info) return unpack(db[selectedSubSection()][info[#info]]) end,
						set = function(info, r, g, b) db[selectedSubSection()][info[#info]] = {r,g,b} self:RDFQueueTracker(db.RDFQueueTracker) end,
						hidden = function(info) return not db[info[#info-1]].queueTime end,
					},
					fontSize = {
						order = 3,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1,
						hidden = function(info) return not db[info[#info-1]].queueTime end,
					},
					font = {
						order = 4,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end,
						hidden = function(info) return not db[info[#info-1]].queueTime end,
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
						hidden = function(info) return not db[info[#info-1]].queueTime end,
					},
					timeXOffset = {
						order = 6,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -200, max = 200, step = 1,
						hidden = function(info) return not db[info[#info-1]].queueTime end,
					},
					timeYOffset = {
						order = 7,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -200, max = 200, step = 1,
						hidden = function(info) return not db[info[#info-1]].queueTime end,
					},
					point = {
						order = 8,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 9,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 10,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -200, max = 200, step = 1,
					},
					yOffset = {
						order = 11,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -200, max = 200, step = 1,
					},
					iconSize = {
						order = 12,
						type = "range",
						name = L["Icon Size"],
						desc = "",
						min = 4, max = 60, step = 1,
					},
					iconSpacing = {
						order = 13,
						type = "range",
						name = L["Icon Spacing"],
						desc = "",
						min = 0, max = 10, step = 1,
					},
				},
			},
		},
	}
end


function mod:InternalCooldowns(db)
	if db.enabled then
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
		self.initialized.InternalCooldowns = true
	elseif self.initialized.InternalCooldowns then
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

function mod:TooltipNotes(db)
	if db.enabled then
		mod.ttfuncs = {}

		local notes = db.notes
		local notesIndex = {}

		local function manageFuncNotes(data, key)
			if data then
				local luaFunction, errorMsg = loadstring(data.text)
				if luaFunction then
					local success, func = pcall(luaFunction)
					if not success then
						core:print('FAIL', L["TooltipNotes"], func)
						return
					else
						mod.ttfuncs[key] = luaFunction
					end
				elseif mod.ttfuncs[key] then
					core:print('LUA', L["TooltipNotes"], errorMsg)
					mod.ttfuncs[key] = nil
				end
			else
				for noteKey, noteData in pairs(notes) do
					local luaFunction = loadstring(noteData.text)
					if luaFunction then
						local success, func = pcall(luaFunction)
						if not success then
							core:print('FAIL', L["TooltipNotes"], func)
							return
						else
							mod.ttfuncs[noteKey] = luaFunction
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
				manageFuncNotes(notes[key], key)
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
			local icon, text, func = notes[key].icon, notes[key].text, mod.ttfuncs[key]
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
		self.initialized.TooltipNotes = true
	elseif self.initialized.TooltipNotes then
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

function mod:ItemIcons(db)
	local ChatTypeInfo = ChatTypeInfo

	if db.enabled then
		if not self.initialized.ItemIcons then
			-- credit: ElvUI_ChatTweaks
			function mod:ItemIconsFilter(_, msg, ...)
				msg = gsub(msg, "(\124%x%x%x%x%x%x%x%x%x\124[Hh]item:.-\124[hH]\124[rR])", function(link)
					return (db.orientation == "left")
							and "\124T" .. (GetItemIcon(link) or "Interface\\Icons\\INV_Misc_QuestionMark") .. ":" .. db.size .. "\124t" .. link
							or link .. "\124T" .. (GetItemIcon(link) or "Interface\\Icons\\INV_Misc_QuestionMark") .. ":" .. db.size .. "\124t"
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

				for j = max(1, numMessages - maxLines + 1), numMessages do
					if numMessages - j > maxLines then break end
					local msg, _, lineID = frame:GetMessageInfo(j)
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
			self.initialized.ItemIcons = true
		end

		for _, event in ipairs(chatMsgEvents) do
			local filterFuncs = ChatFrame_GetMessageEventFilters(event)
			local hasFilter = false
			if filterFuncs then
				for _, filter in ipairs(filterFuncs) do
					if filter == self.ItemIconsFilter then
						hasFilter = true
						break
					end
				end
			end
			if not hasFilter then
				ChatFrame_AddMessageEventFilter(event, self.ItemIconsFilter)
			end
		end
	elseif self.initialized.ItemIcons then
		for _, event in ipairs(chatMsgEvents) do
			local filterFuncs = ChatFrame_GetMessageEventFilters(event)
			local hasFilter = false
			if filterFuncs then
				for _, filter in ipairs(filterFuncs) do
					if filter == self.ItemIconsFilter then
						hasFilter = true
						break
					end
				end
			end
			if hasFilter then
				ChatFrame_RemoveMessageEventFilter(event, self.ItemIconsFilter)
			end
		end
	end
end

function mod:EnterCombatAlert(db)
	if db.enabled then
		if not self.initialized.EnterCombatAlert then
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

			self.initialized.EnterCombatAlert = true
		end
		E:EnableMover("alertFrameMover")

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
	elseif self.initialized.EnterCombatAlert then
		E:DisableMover("alertFrameMover")
		alertFrame:SetScript("OnEvent", nil)
		alertFrame:Hide()
	end
end

function mod:GlobalShadow(db)
	E.globalShadow = db.enabled and db
end

function mod:RDFQueueTracker(db)
    if db.enabled then
        local BATTLEFIELD_IN_QUEUE = match(BATTLEFIELD_IN_QUEUE, ".+\n(.+)")
        local iconSize = db.iconSize
        local iconSpacing = db.iconSpacing
		local queueTracker = self.queueTracker

		if not queueTracker then
			queueTracker = CreateFrame("Frame", "ElvUI_RDFQueueTracker", UIParent)
			queueTracker:SetFrameStrata("LOW")
			queueTracker.waitTimeText = queueTracker:CreateFontString(nil, "OVERLAY")
			queueTracker.roleIcons = {}
		end

        for i, role in ipairs({"Tank", "Healer", "DPS1", "DPS2", "DPS3"}) do
			if not queueTracker.roleIcons[role] then
				local icon = CreateFrame("Button", nil, queueTracker)
				icon:Size(iconSize)
				icon:ClearAllPoints()
				icon:Point("LEFT", (i-1) * (iconSize + iconSpacing), 0)
				icon:SetScript("OnClick", MiniMapLFGFrame_OnClick)
				S:HandleButton(icon)

				local texture = icon:CreateTexture(nil, "ARTWORK")
				texture:SetAllPoints()
				texture:SetTexture(E.Media.Textures[gsub(role, "%d", "")])
				icon.texture = texture

				queueTracker.roleIcons[role] = icon
			else
				local icon = queueTracker.roleIcons[role]
				icon:Size(iconSize)
				icon:ClearAllPoints()
				icon:Point("LEFT", (i-1) * (iconSize + iconSpacing), 0)
			end
        end

		if db.queueTime then
			queueTracker.elapsed = 0
			queueTracker.waitTimeText:ClearAllPoints()
			queueTracker.waitTimeText:Point("CENTER", queueTracker, db.timeXOffset, db.timeYOffset)
			queueTracker.waitTimeText:SetFont(E.Libs.LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)
			queueTracker.waitTimeText:SetTextColor(unpack(db.queueTimeColor))
			queueTracker:SetScript("OnUpdate", function(self, elapsed)
				self.elapsed = self.elapsed + elapsed
				if self.elapsed > 1 then
					local _, _, _, _, _, _, _, _, _, _, _, _, queuedTime = GetLFGQueueStats()
					if queuedTime then
						local seconds = GetTime() - queuedTime
						local hours, minutes, secs = floor(seconds/3600), floor((seconds % 3600)/60), seconds % 60
						if hours > 0 then
							self.waitTimeText:SetText(format(BATTLEFIELD_IN_QUEUE, format("%d:%02d:%02d", hours, minutes, secs)))
						else
							self.waitTimeText:SetText(format(BATTLEFIELD_IN_QUEUE, format("%02d:%02d", minutes, secs)))
						end
					else
						self.waitTimeText:SetText(format(BATTLEFIELD_IN_QUEUE, "--:--"))
					end
					self.elapsed = 0
				end
			end)
			queueTracker.waitTimeText:Show()
		else
			queueTracker:SetScript("OnUpdate", nil)
			queueTracker.waitTimeText:Hide()
		end

        function mod:UpdateRDFTracker()
            local _, _, tankNeeds, healerNeeds, dpsNeeds = GetLFGQueueStats()
			local _, _, queued = GetLFGInfoServer()
            if queued then
				if tankNeeds ~= 0 then
					queueTracker.roleIcons["Tank"].texture:SetDesaturated(true)
					queueTracker.roleIcons["Tank"].texture:SetAlpha(0.5)
				else
					queueTracker.roleIcons["Tank"].texture:SetDesaturated(false)
					queueTracker.roleIcons["Tank"].texture:SetAlpha(1)
				end
				if healerNeeds ~= 0 then
					queueTracker.roleIcons["Healer"].texture:SetDesaturated(true)
					queueTracker.roleIcons["Healer"].texture:SetAlpha(0.5)
				else
					queueTracker.roleIcons["Healer"].texture:SetDesaturated(false)
					queueTracker.roleIcons["Healer"].texture:SetAlpha(1)
				end
				queueTracker.roleIcons["DPS1"].texture:SetDesaturated(not dpsNeeds or dpsNeeds > 2)
				queueTracker.roleIcons["DPS1"].texture:SetAlpha((not dpsNeeds or dpsNeeds > 2) and 0.5 or 1)
				queueTracker.roleIcons["DPS2"].texture:SetDesaturated(not dpsNeeds or dpsNeeds > 1)
				queueTracker.roleIcons["DPS2"].texture:SetAlpha((not dpsNeeds or dpsNeeds > 1) and 0.5 or 1)
				queueTracker.roleIcons["DPS3"].texture:SetDesaturated(not dpsNeeds or dpsNeeds > 0)
				queueTracker.roleIcons["DPS3"].texture:SetAlpha((not dpsNeeds or dpsNeeds > 0) and 0.5 or 1)
                queueTracker:Show()
            else
                queueTracker:Hide()
            end
        end

        queueTracker:Size(5 * (iconSize + iconSpacing) - iconSpacing, iconSize)
        queueTracker:ClearAllPoints()
        queueTracker:Point(db.point, MMHolder, db.relativeTo, db.xOffset, db.yOffset)
        queueTracker:Hide()

		queueTracker:RegisterEvent("LFG_UPDATE")
		queueTracker:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
		queueTracker:RegisterEvent("LFG_PROPOSAL_SHOW")
		queueTracker:RegisterEvent("LFG_PROPOSAL_FAILED")
		queueTracker:RegisterEvent("LFG_PROPOSAL_UPDATE")
		queueTracker:RegisterEvent("LFG_QUEUE_STATUS_UPDATE")
		queueTracker:RegisterEvent("PARTY_MEMBERS_CHANGED")
		queueTracker:RegisterEvent("UPDATE_LFG_LIST")

		queueTracker:SetScript("OnEvent", self.UpdateRDFTracker)

		self.queueTracker = queueTracker
		self:UpdateRDFTracker()
        self.initialized.RDFQueueTracker = true
    elseif self.initialized.RDFQueueTracker then
        self.queueTracker:UnregisterAllEvents()
        self.queueTracker:Hide()
    end
end


function mod:Toggle(db)
	for subMod, info in pairs(db) do
		if self[subMod] and info.enabled ~= nil then
			self[subMod](self, core.reload and {enabled = false} or info)
		end
	end
end

function mod:InitializeCallback()
	local db = E.db.Extras.general[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback