local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Secure Execution Manager", "AceHook-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local ElvUFColors = E.oUF.colors

local modName = mod:GetName()
local isAwesome = C_NamePlate
local GetNamePlates = isAwesome and C_NamePlate.GetNamePlates
local initialized

local broomedFrames = {}
local hiddenFrames = {}
local existingFrames = {}
local pendingPlates = {}
local sortedUnits = {}
local clampStates = {}

local buttonIndex = 1

local min = math.min
local _G, type, select, unpack, pairs, ipairs, tostring, tonumber, pcall, loadstring = _G, type, select, unpack, pairs, ipairs, tostring, tonumber, pcall, loadstring
local gsub, find, format, match, gmatch, byte, trim, utf8lower, utf8sub = string.gsub, string.find, string.format, string.match, string.gmatch, string.byte, string.trim, string.utf8lower, string.utf8sub
local twipe, tinsert, tremove, tsort, tcontains = table.wipe, table.insert, table.remove, table.sort, tContains
local UIParent = UIParent
local RegisterStateDriver, SetOverrideBindingClick, ClearOverrideBindings = RegisterStateDriver, SetOverrideBindingClick, ClearOverrideBindings
local GetCursorPosition, GetScreenWidth, GetScreenHeight, GetTime = GetCursorPosition, GetScreenWidth, GetScreenHeight, GetTime
local UnitAffectingCombat, UnitCastingInfo, UnitChannelInfo, UnitHealth, UnitHealthMax, UnitExists = UnitAffectingCombat, UnitCastingInfo, UnitChannelInfo, UnitHealth, UnitHealthMax, UnitExists
local UnitName, UnitClass, UnitIsPlayer, UnitReaction = UnitName, UnitClass, UnitIsPlayer, UnitReaction
local GetSpellCooldown, GetItemCooldown, GetSpellInfo, GetItemInfo, GetItemIcon, GetItemCount, IsSpellKnown = GetSpellCooldown, GetItemCooldown, GetSpellInfo, GetItemInfo, GetItemIcon, GetItemCount, IsSpellKnown

local function restoreUI()
	for _, child in ipairs(hiddenFrames) do
		child:Show()
	end

	for _, child in ipairs(broomedFrames) do
		child:SetClampedToScreen(clampStates[child] or false)
		child:SetClampRectInsets(0, 0, 0, 0)
	end

	for _, frame in ipairs(pendingPlates) do
		frame:SetClampedToScreen(clampStates[frame] or false)
		frame:SetClampRectInsets(0, 0, 0, 0)
	end

	twipe(broomedFrames)
	twipe(hiddenFrames)
	twipe(pendingPlates)
end

local function broomUI(screenWidth, screenHeight)
	for _, child in ipairs({UIParent:GetChildren()}) do
		if not child:IsProtected() then
			if child:IsShown() then
				child:Hide()
				tinsert(hiddenFrames, child)
			end
		elseif not child.dontBroom then
			child:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)

			local left = child:GetLeft()

			if left and left > 0 then
				clampStates[child] = true
			else
				child:SetClampedToScreen(true)
				child:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)
			end
			tinsert(broomedFrames, child)
		end
	end

	for _, child in ipairs({ElvUIParent:GetChildren()}) do
		if not child:IsProtected() then
			if child:IsShown() then
				child:Hide()
				tinsert(hiddenFrames, child)
			end
		else
			child:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)

			local left = child:GetLeft()

			if left and left > 0 then
				clampStates[child] = true
			else
				child:SetClampedToScreen(true)
				child:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)
			end
			tinsert(broomedFrames, child)
		end
	end
end

local function wipeButtons()
	for key, property in pairs(mod) do
		if type(property) == "table" and property.GetObjectType and property:GetObjectType() == "Button" then
			ClearOverrideBindings(property)

			if E.CreatedMovers[key.."Mover"] then
				local oldMover = _G[key.."Mover"]

				if oldMover then
					oldMover:Hide()
					oldMover:SetScript("OnDragStart", nil)
					oldMover:SetScript("OnDragStop", nil)
					oldMover:SetScript("OnEnter", nil)
					oldMover:SetScript("OnLeave", nil)
					oldMover:SetScript("OnShow", nil)
					oldMover:SetScript("OnMouseDown", nil)
					oldMover:SetScript("OnMouseUp", nil)
					oldMover:SetScript("OnMouseWheel", nil)
					oldMover:ClearAllPoints()
					oldMover:SetParent(nil)
					_G[key.."Mover"] = nil
				end

				E.CreatedMovers[key.."Mover"] = nil
			end

			if E.DisabledMovers[key.."Mover"] then
				E.DisabledMovers[key.."Mover"] = nil
			end

			_G[property:GetName()]:Kill()
			_G[property:GetName()] = nil

			mod[key] = nil
		end
	end
end

local function setIconProperties(button, info)
	if info.icon.fade then
		button:SetAlpha(1 - info.icon.fadeStrength)

		local function UpdateFadeState()
			local inCombat = UnitAffectingCombat("player")
			local casting = UnitCastingInfo("player") or UnitChannelInfo("player")
			local health = UnitHealth("player") / UnitHealthMax("player")
			local hasTarget = UnitExists("target")
			local hasFocus = UnitExists("focus")

			if inCombat or casting or health < 1 or hasTarget or hasFocus then
				E:UIFrameFadeIn(button, 0.2, button:GetAlpha(), 1)
			else
				E:UIFrameFadeOut(button, 0.2, button:GetAlpha(), 1 - info.icon.fadeStrength)
			end
		end

		button:RegisterEvent("PLAYER_REGEN_DISABLED")
		button:RegisterEvent("PLAYER_REGEN_ENABLED")
		button:RegisterEvent("PLAYER_TARGET_CHANGED")
		button:RegisterEvent("UNIT_SPELLCAST_START")
		button:RegisterEvent("UNIT_SPELLCAST_STOP")
		button:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
		button:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		button:RegisterEvent("UNIT_HEALTH")
		button:RegisterEvent("PLAYER_FOCUS_CHANGED")

		button:SetScript("OnEvent", UpdateFadeState)

		button:HookScript("OnEnter", function(self)
			E:UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		end)

		button:HookScript("OnLeave", function(self)
			E:UIFrameFadeOut(self, 0.2, self:GetAlpha(), 1 - info.icon.fadeStrength)
		end)
	end

    button.texture:SetTexCoord(unpack(E.TexCoords))
    button.texture:SetInside(button, E.mult, E.mult)

	button.count:SetPoint("TOPLEFT", 2, -2)
	button.count:SetFont(LSM:Fetch("font", info.icon.font.font), info.icon.font.size, info.icon.font.flag)
	button.count:SetTextColor(unpack(info.icon.font.color))

	if info.icon.retrieveName then
        button.name:SetFont(LSM:Fetch("font", info.icon.font.font), info.icon.font.size, info.icon.font.flag)
        button.name:SetTextColor(unpack(info.icon.font.color))
        button.name:SetPoint(info.icon.namePos, 0, E:Scale((info.icon.namePos == "TOP" and 1 or -1) * 16))
	end

    if info.icon.bindKey then
		button.bindKey = button:CreateFontString(nil, "OVERLAY")
        button.bindKey:SetFont(LSM:Fetch("font", info.icon.font.font), info.icon.font.size, info.icon.font.flag)
        button.bindKey:SetTextColor(unpack(info.icon.font.color))
		button.bindKey:SetText(info.keybind)

		local hotkeyPosition = E.db.actionbar.hotkeyTextPosition or "TOPRIGHT"
		local hotkeyXOffset = E.db.actionbar.hotkeyTextXOffset or 0
		local hotkeyYOffset = E.db.actionbar.hotkeyTextYOffset or -3

		local justify = "RIGHT"
		local text = info.keybind

		if hotkeyPosition == "TOPLEFT" or hotkeyPosition == "BOTTOMLEFT" then
			justify = "LEFT"
		elseif hotkeyPosition == "TOP" or hotkeyPosition == "BOTTOM" then
			justify = "CENTER"
		end

		if text then
			text = gsub(text, "SHIFT%-", L["KEY_SHIFT"])
			text = gsub(text, "ALT%-", L["KEY_ALT"])
			text = gsub(text, "CTRL%-", L["KEY_CTRL"])
			text = gsub(text, "BUTTON", L["KEY_MOUSEBUTTON"])
			text = gsub(text, "MOUSEWHEELUP", L["KEY_MOUSEWHEELUP"])
			text = gsub(text, "MOUSEWHEELDOWN", L["KEY_MOUSEWHEELDOWN"])
			text = gsub(text, "NUMPAD", L["KEY_NUMPAD"])
			text = gsub(text, "PAGEUP", L["KEY_PAGEUP"])
			text = gsub(text, "PAGEDOWN", L["KEY_PAGEDOWN"])
			text = gsub(text, "SPACE", L["KEY_SPACE"])
			text = gsub(text, "INSERT", L["KEY_INSERT"])
			text = gsub(text, "HOME", L["KEY_HOME"])
			text = gsub(text, "DELETE", L["KEY_DELETE"])
			text = gsub(text, "NMULTIPLY", "*")
			text = gsub(text, "NMINUS", "N-")
			text = gsub(text, "NPLUS", "N+")

			button.bindKey:SetText(text)
			button.bindKey:SetJustifyH(justify)
		end

		button.bindKey:ClearAllPoints()
		button.bindKey:Point(hotkeyPosition, hotkeyXOffset, hotkeyYOffset)
    end

    if info.icon.macroText then
        button.macroText:ClearAllPoints()
        button.macroText:SetPoint("BOTTOM", 0, 1)
        button.macroText:SetFont(LSM:Fetch("font", info.icon.font.font), info.icon.font.size, info.icon.font.flag)
        button.macroText:SetTextColor(unpack(info.icon.font.color))
    end
end

local function updateTip(button, id)
	button.isHovered = true

	if not id then
		GameTooltip:Hide()
		return
	end

	GameTooltip:SetOwner(button, "ANCHOR_TOP")

	if IsSpellKnown(id) then
		GameTooltip:SetSpellByID(id)
	else
		local _, itemLink = GetItemInfo(id)
		GameTooltip:ClearLines()
		GameTooltip:SetHyperlink(itemLink)
	end

	GameTooltip:Show()
end

local function abbrev(name)
	local letters, lastWord = "", match(name, ".+%s(.+)$")

	if lastWord then
		for word in gmatch(name, ".-%s") do
			local firstLetter = utf8sub(gsub(word, "^[%s%p]*", ""), 1, 1)
			if firstLetter ~= utf8lower(firstLetter) then
				letters = format("%s%s. ", letters, firstLetter)
			end
		end
		name = format("%s%s", letters, lastWord)
	end

	return name
end


P["Extras"]["general"][modName] = {
    ["enabled"] = false,
    ["selectedButton"] = 1,
    ["buttons"] = {
		{
			["name"] = L["Default Button"],
			["keybind"] = "",
			["blockCondition"] = "",
			["tabs"] = {
				{
					["enabled"] = false,
					["scanPlates"] = false,
					["condition"] = "",
					["attributes"] = {},
					["selectedAttribute"] = "macrotext",
					["selectedType"] = "macro",
                    ["texture"] = "Interface\\Icons\\INV_Misc_QuestionMark",
					["shadowSize"] = 3,
					["shadowColor"] = {0,0,0,0},
					["borderColor"] = {0,0,0},
				}
			},
			["icon"] = {
				["enabled"] = false,
				["size"] = 30,
				["font"] = {
					["font"] = "Expressway",
					["flag"] = "OUTLINE",
					["color"] = {1, 1, 1},
					["size"] = 12,
				},
				["bindKey"] = false,
				["macroText"] = false,
				["throttle"] = 0,
				["level"] = 45,
				["strata"] = "MEDIUM",
				["fade"] = false,
				["fadeStrength"] = 0.6,
				["shadowSize"] = 3,
				["shadowColor"] = {0,0,0,0},
				["borderColor"] = {0,0,0},
				["namePos"] = "TOP",
				["stateDriver"] = "show",
			},
			["selectedTab"] = 1,
		}
	},
}

function mod:LoadConfig()
    local db = E.db.Extras.general[modName]
    local function selectedButton() return db.selectedButton end
    local function selectedTab() return db.buttons[selectedButton()].selectedTab end
    local function selectedType() return db.buttons[selectedButton()].tabs[selectedTab()].selectedType end
    local function selectedAttribute() return db.buttons[selectedButton()].tabs[selectedTab()].selectedAttribute end

	local actionTypes = {
		["actionbar"] = "actionbar",
		["action"] = "action",
		["pet"] = "pet",
		["spell"] = "spell",
		["item"] = "item",
		["macro"] = "macro",
		["glyph"] = "glyph",
		["cancelaura"] = "cancelaura",
		["target"] = "target",
		["focus"] = "focus",
		["assist"] = "assist",
		["mainassist"] = "mainassist",
		["maintank"] = "maintank",
		["attribute"] = "attribute",
		["destroytotem"] = "destroytotem",
	}

	local function getActionAttributes(actionType)
		local attributes = {
			["actionbar"] = {"action"},
			["action"] = {"unit", "action", "actionpage"},
			["pet"] = {"unit", "action"},
			["spell"] = {"unit", "spell"},
			["item"] = {"unit", "item", "bag", "slot"},
			["macro"] = {"macro", "macrotext"},
			["glyph"] = {"glyph", "slot"},
			["cancelaura"] = {"unit", "spell", "rank", "target-slot", "index", "filter"},
			["target"] = {"unit"},
			["focus"] = {"unit"},
			["assist"] = {"unit"},
			["mainassist"] = {"action", "unit"},
			["maintank"] = {"action", "unit"},
			["attribute"] = {"attribute-frame", "attribute-name", "attribute-value"},
			["destroytotem"] = {"totem-slot"},
		}

		return attributes[actionType] or {}
	end

	local function nameButton(buttonName)
		for _, info in ipairs(db.buttons) do
			if info.name == buttonName then
				buttonName = gsub(buttonName, "%d", #db.buttons + 2)
				nameButton(buttonName)
			end
		end
		return buttonName
	end

    core.general.args[modName] = {
        type = "group",
        name = L[modName],
        args = {
            SecureExecutionManager = {
				order = 1,
                type = "group",
                name = L[modName],
                guiInline = true,
				get = function(info) return db.buttons[selectedButton()] and db.buttons[selectedButton()][info[#info]] end,
				set = function(info, value) db.buttons[selectedButton()][info[#info]] = value self:Toggle(true) end,
				disabled = function() return not db.enabled or not db.buttons[selectedButton()] end,
                args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
						disabled = false,
                        name = core.pluginColor..L["Enable"],
                        desc = "",
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value self:Toggle(value) end,
                    },
					keybind = {
						order = 2,
						type = "input",
						name = L["Keybind"],
						desc = L["ALT-CTRL-F, SHIFT-T, W, BUTTON4, etc."],
						set = function(_, value)
							if find(value, "%S+") then
								self:Toggle(true)
							end
						end,
					},
					name = {
                        order = 3,
                        type = "input",
                        name = L["Rename Button"],
                        desc = "",
                        set = function(_, value)
							if find(value, "%S+") then
								for _, button in ipairs(db.buttons) do
									if button.name == value then
										return
									end
								end
								db.buttons[selectedButton()].name = value
							end
						end,
					},
                    selectedButton = {
                        order = 4,
                        type = "select",
                        name = L["Select Button"],
                        desc = "",
                        values = function()
                            local buttons = {}
                            for i, button in ipairs(db.buttons) do
                                buttons[i] = button.name
                            end
                            return buttons
                        end,
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value end,
                    },
                    createButton = {
                        order = 5,
                        type = "execute",
                        name = L["Create New Button"],
                        desc = "",
                        func = function()
							local buttonName = nameButton(format(L["Button"]..(" %d"), #db.buttons + 1))
                            local buttonConfig = {
                                ["name"] = buttonName,
                                ["keybind"] = "",
								["blockCondition"] = "",
                                ["tabs"] = {
                                    {
										["enabled"] = false,
										["scanPlates"] = false,
										["condition"] = "",
										["attributes"] = {},
										["selectedAttribute"] = "macrotext",
										["selectedType"] = "macro",
										["texture"] = "Interface\\Icons\\INV_Misc_QuestionMark",
										["shadowSize"] = 3,
										["shadowColor"] = {0,0,0,0},
										["borderColor"] = {0,0,0},
                                    }
                                },
								["icon"] = {
									["enabled"] = false,
									["size"] = 30,
									["font"] = {
										["font"] = "Expressway",
										["flag"] = "OUTLINE",
										["color"] = {1, 1, 1},
										["size"] = 12,
									},
									["bindKey"] = false,
									["macroText"] = false,
									["throttle"] = 0,
									["level"] = 45,
									["strata"] = "MEDIUM",
									["fade"] = false,
									["fadeStrength"] = 0.6,
									["shadowSize"] = 3,
									["shadowColor"] = {0,0,0,0},
									["borderColor"] = {0,0,0},
									["namePos"] = "TOP",
									["stateDriver"] = "show",
								},
								["selectedTab"] = 1
                            }

							for type in pairs(actionTypes) do
								local attributes = getActionAttributes(type)
								buttonConfig.tabs[1].attributes[type] = {}

								for _, attr in ipairs(attributes) do
									buttonConfig.tabs[1].attributes[type][attr] = ""
								end
							end

                            tinsert(db.buttons, buttonConfig)
                            db.selectedButton = #db.buttons
                            self:Toggle(true)
                        end,
						disabled = function() return not db.enabled end,
                    },
                    deleteButton = {
                        order = 6,
                        type = "execute",
                        name = L["Delete Selected Button"],
                        desc = "",
                        func = function()
                            tremove(db.buttons, selectedButton())
                            db.selectedButton = min(db.selectedButton, #db.buttons)
                            self:Toggle(true)
                        end,
						disabled = function() return not db.enabled or #db.buttons == 1 end,
                    },
					openEditor = {
						order = 7,
						type = "execute",
						width = "double",
						name = L["Open Editor"],
						desc = "",
						func = function()
							if not db.buttons[selectedButton()] then return end
							core:OpenEditor(L["Secure Execution: Block"], db.buttons[selectedButton()].blockCondition, function() db.buttons[selectedButton()].blockCondition = core.EditFrame.editBox:GetText() mod:Toggle(true) end)
						end
					},
					blockCondition = {
						order = 8,
						type = "input",
						width = "double",
						multiline = true,
						name = L["Block Condition"],
						desc = L["Prevents any action upon meeting set conditions.\nAccepts function bodies, no payload arguments."],
					},
				},
			},
			icon = {
				order = 2,
                type = "group",
                name = L["Icon"],
                guiInline = true,
                get = function(info) return db.buttons[selectedButton()] and db.buttons[selectedButton()].icon[info[#info]] end,
                set = function(info, value) db.buttons[selectedButton()].icon[info[#info]] = value self:Toggle(true) end,
				disabled = function() return not db.enabled or not db.buttons[selectedButton()] end,
				hidden = function() return not db.buttons[selectedButton()] end,
                args = {
					enabled = {
                        order = 1,
                        type = "toggle",
						width = "full",
                        name = core.pluginColor..L["Enable"],
                        desc = "",
                    },
					size = {
						order = 2,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 18, max = 60, step = 1,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					throttle = {
						order = 3,
						type = "range",
						name = L["Throttle Time"],
						desc = "",
						min = 0, max = 1, step = 0.01,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					stateDriver = {
                        order = 4,
                        type = "input",
						width = "double",
                        name = L["Visibility State"],
						desc = L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] showhide'"],
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					fade = {
                        order = 5,
                        type = "toggle",
                        name = L["Fade"],
                        desc = "",
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					fadeStrength = {
						order = 6,
						type = "range",
						name = L["Fade Strength"],
						desc = "",
						min = 0, max = 1, step = 0.01,
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.fade end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					shadowColor = {
						order = 7,
						type = "color",
						name = L["Shadow Color"],
						desc = "",
						hasAlpha = true,
						get = function() return unpack(db.buttons[selectedButton()] and db.buttons[selectedButton()].icon.shadowColor) end,
						set = function(_, r, g, b, a) db.buttons[selectedButton()].icon.shadowColor = {r, g, b, a} self:Toggle(true) end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					borderColor = {
						order = 8,
						type = "color",
						name = L["Border Color"],
						desc = "",
						get = function() return unpack(db.buttons[selectedButton()] and db.buttons[selectedButton()].icon.borderColor) end,
						set = function(_, r, g, b) db.buttons[selectedButton()].icon.borderColor = {r, g, b} self:Toggle(true) end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					shadowSize = {
						order = 9,
						type = "range",
						name = L["Shadow Size"],
						desc = "",
						min = 1, max = 20, step = 1,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					namePos = {
                        order = 10,
                        type = "select",
                        name = L["Name Position"],
                        desc = "",
						values = {
							["TOP"] = "TOP",
							["BOTTOM"] = "BOTTOM",
						},
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.retrieveName end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					retrieveName = {
                        order = 11,
                        type = "toggle",
                        name = L["Retrieve Name"],
                        desc = L["Displays matched character's name."],
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					abbreviateName = {
                        order = 12,
                        type = "toggle",
                        name = L["Abbreviate Name"],
                        desc = "",
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.retrieveName end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					reactionName = {
                        order = 13,
                        type = "toggle",
                        name = L["Color Name by Reaction"],
                        desc = "",
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.retrieveName end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					className = {
                        order = 14,
                        type = "toggle",
                        name = L["Color Name by Class"],
                        desc = "",
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.retrieveName end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					fontColor = {
						order = 15,
						type = "color",
						name = L["Font Color"],
						desc = "",
						get = function() return unpack(db.buttons[selectedButton()] and db.buttons[selectedButton()].icon.font.color) end,
						set = function(_, r, g, b) db.buttons[selectedButton()].icon.font.color = {r, g, b} self:Toggle(true) end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled or not (db.buttons[selectedButton()].icon.bindKey or db.buttons[selectedButton()].icon.macroText) end,
					},
					fontSize = {
						order = 16,
						type = "range",
						name = L["Font Size"],
						desc = "",
						get = function() return db.buttons[selectedButton()] and db.buttons[selectedButton()].icon.font.size end,
						set = function(_, value) db.buttons[selectedButton()].icon.font.size = value self:Toggle(true) end,
						min = 4, max = 33, step = 1,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled or not (db.buttons[selectedButton()].icon.bindKey or db.buttons[selectedButton()].icon.macroText) end,
					},
					font = {
						order = 17,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						get = function(info) return db.buttons[selectedButton()] and db.buttons[selectedButton()].icon.font[info[#info]] end,
						set = function(info, value) db.buttons[selectedButton()].icon.font[info[#info]] = value self:Toggle(true) end,
						values = function() return AceGUIWidgetLSMlists.font end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled or not (db.buttons[selectedButton()].icon.bindKey or db.buttons[selectedButton()].icon.macroText) end,
					},
					flag = {
						order = 18,
						type = "select",
						name = L["Font Outline"],
						desc = "",
						get = function(info) return db.buttons[selectedButton()] and db.buttons[selectedButton()].icon.font[info[#info]] end,
						set = function(info, value) db.buttons[selectedButton()].icon.font[info[#info]] = value self:Toggle(true) end,
						values = {
							["NONE"] = L["NONE"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled or not (db.buttons[selectedButton()].icon.bindKey or db.buttons[selectedButton()].icon.macroText) end,
					},
					level = {
						order = 19,
						type = "range",
						name = L["Level"],
						desc = "",
						min = 1, max = 200, step = 1,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					strata = {
						order = 20,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					bindKey = {
                        order = 21,
                        type = "toggle",
                        name = L["Show Bind Key"],
                        desc = "",
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
					macroText = {
                        order = 22,
                        type = "toggle",
                        name = L["Show Macro Text"],
                        desc = "",
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
                    },
				},
			},
			settings = {
				order = 3,
				type = "group",
				name = L["Settings"],
                guiInline = true,
				get = function(info) return db.buttons[selectedButton()] and db.buttons[selectedButton()].tabs[selectedTab()][info[#info]] end,
				set = function(info, value) db.buttons[selectedButton()].tabs[selectedTab()][info[#info]] = value self:Toggle(true) end,
				disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
				hidden = function() return not db.buttons[selectedButton()] end,
				args = {
                    enabled = {
                        order = 1,
                        type = "toggle",
						width = "full",
                        name = core.pluginColor..L["Enable"],
                        desc = "",
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] end,
                    },
                    scanPlates = {
                        order = 2,
                        type = "toggle",
                        name = L["Scan Plates"],
                        desc = "",
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
                    },
                    retrieveUnit = {
                        order = 3,
                        type = "toggle",
                        name = L["Retrieve Unit"],
                        desc = L["Fetches matched character's unitId, if available.\nAll instances of @unit found within the value section are going to get replaced with a fetched unitId (e.g. /target [@unit] -> /target [@raid3])."],
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
                    },
                    putOnCursor = {
                        order = 4,
                        type = "toggle",
                        name = L["Put Unit on Cursor"],
                        desc = L["This exists due to nameplateN unitIds being unavailable inside the secure environment.\nAwesome WotLK only."],
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].scanPlates end,
						hidden = function() return not isAwesome or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
                    },
                    targetName = {
                        order = 5,
                        type = "toggle",
                        name = L["Target by Name"],
                        desc = L["When used with a name of those characters that are not a part of your group/guild/friendlist, the @nameString unitIds only work for the /target command, I think.\nTargets nearest matched name carrier.\nAwesome WotLK only."],
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].scanPlates or not db.buttons[selectedButton()].tabs[selectedTab()].retrieveUnit end,
						hidden = function() return not isAwesome or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
                    },
                    broomUI = {
                        order = 6,
                        type = "toggle",
                        name = L["Broom UI"],
                        desc = L["Hides the UI temporarily. The game prioritizes 3d models over frames, so be careful to not mouse any while scanning."],
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].scanPlates end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
                    },
					shadowSize = {
						order = 7,
						type = "range",
						name = L["Shadow Size"],
						desc = "",
						min = 1, max = 20, step = 1,
						disabled = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
					},
					shadowColor = {
						order = 8,
						type = "color",
						name = L["Shadow Color"],
						desc = "",
						hasAlpha = true,
						get = function(info) return unpack(db.buttons[selectedButton()] and db.buttons[selectedButton()].tabs[selectedTab()][info[#info]]) end,
						set = function(info, r, g, b, a) db.buttons[selectedButton()].tabs[selectedTab()][info[#info]] = {r, g, b, a} self:Toggle(true) end,
						disabled = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
					},
					borderColor = {
						order = 9,
						type = "color",
						name = L["Border Color"],
						desc = "",
						get = function(info) return unpack(db.buttons[selectedButton()] and db.buttons[selectedButton()].tabs[selectedTab()][info[#info]]) end,
						set = function(info, r, g, b, a) db.buttons[selectedButton()].tabs[selectedTab()][info[#info]] = {r, g, b, a} self:Toggle(true) end,
						disabled = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].tabs[selectedTab()].enabled end,
					},
					priority = {
						order = 10,
						type = "input",
						name = L["Tab Priority"],
						desc = "",
						get = function() return db.buttons[selectedButton()] and tostring(selectedTab()) end,
						set = function(_, value)
							local tabCount = #db.buttons[selectedButton()].tabs
							local targetTab = tonumber(value)

							if targetTab and targetTab >= 1 and targetTab <= tabCount and targetTab ~= selectedTab() then
								local tempHolder = db.buttons[selectedButton()].tabs[targetTab]
								db.buttons[selectedButton()].tabs[targetTab] = db.buttons[selectedButton()].tabs[selectedTab()]
								db.buttons[selectedButton()].tabs[selectedTab()] = tempHolder
								db.buttons[selectedButton()].selectedTab = targetTab
							elseif targetTab and targetTab > tabCount then
								-- If the target tab is higher than the number of tabs, switch with the highest tab
								local highestTab = tabCount
								local tempHolder = db.buttons[selectedButton()].tabs[highestTab]
								db.buttons[selectedButton()].tabs[highestTab] = db.buttons[selectedButton()].tabs[selectedTab()]
								db.buttons[selectedButton()].tabs[selectedTab()] = tempHolder
								db.buttons[selectedButton()].selectedTab = highestTab
							end
							self:Toggle(true)
						end,
					},
					selectedTab = {
						order = 11,
						type = "select",
						name = L["Select Tab"],
						desc = "",
						values = function()
							local tabs = {}
							for i in ipairs(db.buttons[selectedButton()].tabs) do
								tabs[i] = i
							end
							return tabs
						end,
						get = function() return db.buttons[selectedButton()].selectedTab or 1 end,
						set = function(_, value) db.buttons[selectedButton()].selectedTab = value end,
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] end,
					},
					addTab = {
						order = 12,
						type = "execute",
						name = L["Add Tab"],
						desc = "",
						func = function()
							local tabConfig = {
								["enabled"] = false,
								["scanPlates"] = false,
								["condition"] = "",
								["attributes"] = {},
								["selectedAttribute"] = "macrotext",
								["selectedType"] = "macro",
								["texture"] = "Interface\\Icons\\INV_Misc_QuestionMark",
								["shadowSize"] = 3,
								["shadowColor"] = {0,0,0,0},
								["borderColor"] = {0,0,0},
							}

							for type in pairs(actionTypes) do
								local attributes = getActionAttributes(type)
								tabConfig.attributes[type] = {}

								for _, attr in ipairs(attributes) do
									tabConfig.attributes[type][attr] = ""
								end
							end

							tinsert(db.buttons[selectedButton()].tabs, tabConfig)
						end,
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] end,
					},
					deleteTab = {
						order = 13,
						type = "execute",
						name = L["Delete Tab"],
						desc = "",
						func = function()
							local tabs = db.buttons[selectedButton()].tabs
							if #tabs <= 1 then return end

							tremove(tabs, selectedTab())
							db.buttons[selectedButton()].selectedTab = 1
							self:Toggle(true)
						end,
						disabled = function() return not db.enabled or not db.buttons[selectedButton()] or #db.buttons[selectedButton()].tabs <= 1 end,
					},
					selectedType = {
						order = 14,
						type = "select",
						name = L["Action Type"],
						desc = "",
						set = function(info, value)
							db.buttons[selectedButton()].tabs[selectedTab()].selectedAttribute = getActionAttributes(value)[1] or ""
							db.buttons[selectedButton()].tabs[selectedTab()][info[#info]] = value
							self:Toggle(true)
						end,
						values = actionTypes,
					},
					selectedAttribute = {
						order = 15,
						type = "select",
						name = L["Action Attribute"],
						desc = "",
						values = function()
							local attributes = getActionAttributes(selectedType())
							local values = {}
							for _, attr in ipairs(attributes) do
								values[attr] = attr
							end
							return values
						end,
					},
					texture = {
						order = 16,
						type = "input",
						name = L["Texture"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					id = {
						order = 17,
						type = "input",
						name = L["Item or Spell ID"],
						desc = L["Fetches tooltip info, texture, and item count."],
						hidden = function() return not db.buttons[selectedButton()] or not db.buttons[selectedButton()].icon.enabled end,
					},
					openEditor = {
						order = 18,
						type = "execute",
						width = "double",
						name = L["Open Editor"],
						desc = "",
						func = function()
							if not db.buttons[selectedButton()] then return end
							core:OpenEditor(L["Secure Execution: Condition"], db.buttons[selectedButton()].tabs[selectedTab()].condition, function() db.buttons[selectedButton()].tabs[selectedTab()].condition = core.EditFrame.editBox:GetText() mod:Toggle(true) end)
						end
					},
					value = {
						order = 19,
						type = "input",
						width = "double",
						multiline = true,
						name = L["Action Value Editor"],
						desc = "",
						get = function() return db.buttons[selectedButton()] and db.buttons[selectedButton()].tabs[selectedTab()].attributes[selectedType()][selectedAttribute()] end,
						set = function(_, value)
							db.buttons[selectedButton()].tabs[selectedTab()].attributes[selectedType()][selectedAttribute()] = value
							self:Toggle(true)
						end,
					},
					condition = {
						order = 20,
						type = "input",
						width = "double",
						multiline = true,
						name = L["Condition Editor"],
						desc = L["Accepts function bodies.\nPayload:\n  frame - matched character's UF/plate\n  unit - matched character's unitId\n  isPlate - true for plates"],
					},
				},
			},
        },
    }

	for _, info in ipairs(db.buttons) do
		for _, tab in ipairs(info.tabs) do
			if not tab.attributes.macro then
				for type in pairs(actionTypes) do
					local attributes = getActionAttributes(type)
					tab.attributes[type] = {}

					for _, attr in ipairs(attributes) do
						tab.attributes[type][attr] = ""
					end
				end
			end
		end
	end
end


function mod:SetButtonIcon(button, info, tabsIconInfo)
	if not info.icon.enabled then return end

	RegisterStateDriver(button, "visibility", info.icon.stateDriver)

	button.iconHandler = CreateFrame("Frame", nil, button)
	button:SetFrameLevel(info.icon.level)
	button:SetFrameStrata(info.icon.strata)
	button:CreateShadow()

	button.texture = button:CreateTexture(nil, "BORDER")
	button.texture:SetInside(button, E.mult, E.mult)
	button.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")

	button.cooldown = CreateFrame("Cooldown", info.name.."Cooldown", button, "CooldownFrameTemplate")
	button.cooldown:SetAllPoints()

	button.macroText = button:CreateFontString(nil, "OVERLAY")
	button.macroText:FontTemplate()

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:FontTemplate()

	button.name = button:CreateFontString(nil, "OVERLAY")
	button.name:FontTemplate()

	E:RegisterCooldown(button.cooldown)

	button:Size(info.icon.size)
	button:Point("CENTER")
	button:SetTemplate("Transparent")
	button:StyleButton()

	setIconProperties(button, info)

	E:CreateMover(button, info.name.."Mover", info.name, nil, nil, nil, "ALL,SOLO")

	if E.ConfigurationMode then
		_G[info.name.."Mover"]:Show()
	end

	local sS = info.icon.shadowSize
	local sR, sG, sB, sA = unpack(info.icon.shadowColor)
	local bR, bG, bB = unpack(info.icon.borderColor)

	local timeElapsed, throttle = 0, info.icon.throttle

	button:HookScript("OnEnter", function(self)
		updateTip(self, self.currentId)
	end)

	button:HookScript("OnLeave", function(self)
		self.isHovered = false

		GameTooltip:Hide()
	end)

	button.iconHandler:SetScript("OnUpdate", function(_, elapsed)
		timeElapsed = timeElapsed + elapsed

		if timeElapsed > throttle then
			timeElapsed = 0

			if button:blockFunc() then
				button.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				button:SetBackdropBorderColor(bR, bG, bB)
				button.shadow:SetBackdropBorderColor(sR, sG, sB, sA)
				button.shadow:SetScale(sS)
				button.cooldown:Hide()
				if button.macroText then button.macroText:SetText("") end
				return
			end

			local found = false

			for _, tab in ipairs(tabsIconInfo) do
				local func = tab.func
				local unitFound = false

				for _, frame in ipairs(existingFrames) do
					local unit = frame.unit
					if frame:IsShown() and unit and func(frame, unit) then
						unitFound = unit
						break
					end
				end

				if not unitFound and tab.scanPlates then
					for _, plate in pairs(GetNamePlates()) do
						local frame, unit = plate.UnitFrame, plate.unit
						if frame and unit and func(frame, unit, true) then
							unitFound = unit
							break
						end
					end
				end

				if unitFound then
					button:SetBackdropBorderColor(unpack(tab.borderColor))
					button.shadow:SetBackdropBorderColor(unpack(tab.shadowColor))
					button.shadow:SetScale(tab.shadowSize)

					if tab.namePos then
						local name = UnitName(unitFound) or ""

						if name ~= button.currentName then
							button.name:SetText(tab.abbreviateName and abbrev(name) or name)

							if tab.reactionName or tab.className then
								local _, class = UnitClass(unitFound)

								if class and tab.className and UnitIsPlayer(unitFound) then
									local values = ElvUFColors.class[class]
									local r, g, b

									if values then
										r, g, b = values[1], values[2], values[3]
									else
										r, g, b = unpack(info.icon.font.color)
									end

									button.name:SetTextColor(r, g, b)
								else
									local reaction = UnitReaction(unitFound, "player")
									local values = reaction and ElvUFColors.reaction[reaction]
									local r, g, b

									if values then
										r, g, b = values[1], values[2], values[3]
									else
										r, g, b = unpack(info.icon.font.color)
									end

									button.name:SetTextColor(r, g, b)
								end
							end

							button.currentName = name
						end
					end

					local id = tab.id

					if button.isHovered and id ~= button.currentId then
						updateTip(button, id)
					end

					if id then
						local cdInfo = tab.cdInfo
						local start, duration, enable = cdInfo.start, cdInfo.duration, cdInfo.enable

						if not enable then
							start, duration, enable = tab.cdCheck()

							cdInfo.start = start
							cdInfo.duration = duration
							cdInfo.enable = enable
						end

						if enable then
							if (start + duration) - GetTime() > 0 then
								button.cooldown:SetCooldown(start, duration)
								button.cooldown:Show()
							else
								button.cooldown:Hide()
								twipe(cdInfo)
							end
						else
							button.cooldown:Hide()
							twipe(cdInfo)
						end

						button.currentId = id
						button.texture:SetTexture(tab.texture == "" and tab.idTexture or tab.texture)
					else
						button.currentId = nil
						button.texture:SetTexture(tab.texture)
						button.cooldown:Hide()
					end

					if tab.macroText then
						button.macroText:SetText(tab.macroText or "")
					else
						button.macroText:SetText("")
					end

					if tab.idSpell then
						button.count:SetText("")
					else
						local count = GetItemCount(id)
						button.count:SetText(count > 1 and count or "")
					end

					found = true
					break
				end
			end

			if not found then
				button.texture:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
				button:SetBackdropBorderColor(bR, bG, bB)
				button.shadow:SetBackdropBorderColor(sR, sG, sB, sA)
				button.shadow:SetScale(sS)
				button.currentId = nil
				button.currentName = nil
				button.cooldown:Hide()
				button.macroText:SetText("")
				button.count:SetText("")
				button.name:SetText("")

				if button.isHovered then
					GameTooltip:Hide()
				end
			end
		end
	end)
end

function mod:EncodeName(name, screenWidth, screenHeight)
    local pairs = {}
    local x, y = 0, 0

    for i = 1, #name do
        local value = byte(name, i)

        if i % 2 == 1 then
            if x * 256 + value > screenWidth then
                tinsert(pairs, {x, y})
            end
            x, y = x * 256 + value, 0
        else
            if y * 256 + value > screenHeight then
                tinsert(pairs, {x, y})
            end
            x, y = 0, y * 256 + value
        end
    end

    if x ~= 0 or y ~= 0 then
        tinsert(pairs, {x, y})
    end

    return pairs
end

function mod:PrepSecureButtons(button, unit, tabInfo, screenWidth, screenHeight, scaledWidth, scaledHeight, unitName)
	button.targetSecureFrame = tabInfo.button
	button.targetSecureFrame:SetClampedToScreen(true)
	button.targetSecureFrame:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)

	if tabInfo.retrieveUnit then
		if unit == 'nameplate' then
			local encodedName = self:EncodeName(unitName, screenWidth, screenHeight)

			for i, pair in ipairs(encodedName) do
				local unitButton = self.units["coder"..i]

				if unitButton then
					local newX = -1 * pair[1] + scaledWidth
					local newY = -1 * pair[2] + scaledHeight

					unitButton:SetClampedToScreen(true)
					unitButton:SetClampRectInsets(
						-newX,
						screenWidth - newX,
						screenHeight - newY,
						-newY
					)

					tinsert(button.unitSecureFrames, unitButton)
				end
			end
		else
			local unitButton = self.units[unit]

			if unitButton then
				unitButton:SetClampedToScreen(true)
				unitButton:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)

				tinsert(button.unitSecureFrames, unitButton)
			end
		end
	end
end

function mod:SetPosition(frame, scaledWidth, scaledHeight, screenWidth, screenHeight, frameWidth, frameHeight)
    local cursorX, cursorY = GetCursorPosition()

    local newX = (cursorX + scaledWidth) - frameWidth / 2
    local newY = (cursorY + scaledHeight) - frameHeight / 2

	frame:SetClampedToScreen(true)
    frame:SetClampRectInsets(
        -newX,
        screenWidth - (newX + frameWidth),
        screenHeight - (newY + frameHeight),
        -newY
    )
end

function mod:GetFrame(button, scaledWidth, scaledHeight, screenWidth, screenHeight, startPos)
	local tabsInfo = button.tabsInfo

	for i = startPos or 1, #tabsInfo do
		local tabInfo = tabsInfo[i]
		local func = tabInfo.func

		for _, frame in ipairs(existingFrames) do
			local unit = frame.unit

			if frame:IsShown() and unit and func(frame, unit) then
				self:PrepSecureButtons(button, unit, tabInfo, screenWidth, screenHeight)

				return frame, true
			end
		end

		if tabInfo.scanPlates then
			if isAwesome then
				for _, plate in pairs(GetNamePlates()) do
					local frame, unit = plate.UnitFrame, plate.unit

					if frame and unit and func(frame, unit, true) then
						if tabInfo.targetName then
							self:PrepSecureButtons(button, 'nameplate', tabInfo, screenWidth, screenHeight, scaledWidth, scaledHeight, UnitName(unit))
						else
							self:PrepSecureButtons(button, 'mouseover', tabInfo, screenWidth, screenHeight)
						end

						if tabInfo.putOnCursor then
							button:SetScript("OnUpdate", function(self)
								if not plate:IsShown() then
									self:SetScript("OnUpdate", nil)

									restoreUI(self)
									return
								else
									mod:SetPosition(plate, scaledWidth, scaledHeight, screenWidth, screenHeight, plate:GetSize())
								end
							end)

							tinsert(broomedFrames, plate)

							if tabInfo.broomUI then
								broomUI(screenWidth, screenHeight)
							end
						end

						return plate, nil
					end
				end
			else
				twipe(pendingPlates)

				for plate in pairs(NP.VisiblePlates) do
					local frame = plate:GetParent()
					frame:SetClampedToScreen(true)
					frame:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)

					if not plate.isTarget then
						tinsert(pendingPlates, frame)
					else
						tinsert(broomedFrames, frame)
					end
				end

				local j = 1
				local frame = pendingPlates[j]

				if frame then
					if tabInfo.broomUI then
						broomUI(screenWidth, screenHeight)
					end

					button.isScaning = true
					button:SetScript("OnUpdate", function(self)
						if not self.isScaning or not frame then
							self:SetScript("OnUpdate", nil)
							restoreUI(self)
							if not frame then
								button.frame = mod:GetFrame(button, scaledWidth, scaledHeight, screenWidth, screenHeight, i + 1)
							end
						elseif UnitExists('mouseover') then
							if func(frame, 'mouseover', true) then
								mod:PrepSecureButtons(self, 'mouseover', tabInfo, screenWidth, screenHeight)
								self:SetScript("OnUpdate", function(self)
									if not frame:IsShown() then
										self:SetScript("OnUpdate", nil)
										restoreUI(self)
									else
										mod:SetPosition(frame, scaledWidth, scaledHeight, screenWidth, screenHeight, frame:GetSize())
									end
								end)
							else
								j = j + 1
								frame:SetClampedToScreen(true)
								frame:SetClampRectInsets(screenWidth, screenWidth, screenHeight, screenHeight)
								frame = pendingPlates[j]
							end
						else
							mod:SetPosition(frame, scaledWidth, scaledHeight, screenWidth, screenHeight, frame:GetSize())
						end
					end)
				else
					button.frame = self:GetFrame(button, scaledWidth, scaledHeight, screenWidth, screenHeight, i + 1)
				end
				return
			end
		end
	end
end

function mod:PreClick(button, _, down)
	if not down or button:blockFunc() then return end

	local screenWidth, screenHeight = GetScreenWidth(), GetScreenHeight()
	local scale = UIParent:GetEffectiveScale()
	local scaledWidth = (screenWidth * (1 - scale))
	local scaledHeight = (screenHeight * (1 - scale))

	button.frame = self:GetFrame(button, scaledWidth, scaledHeight, screenWidth, screenHeight)
end

function mod:PostClick(button, _, down)
	if down then return end

	local frame = button.frame

	button.isScaning = false
	button.startTime = GetTime()
	button:HookScript("OnUpdate", function(self)
		if not frame or not frame:IsShown() or UnitExists('target') or GetTime() - self.startTime > 0.1 then
			if self.targetSecureFrame then
				self.targetSecureFrame:SetClampedToScreen(true)
				self.targetSecureFrame:SetClampRectInsets(0, 0, 0, 0)
				self.targetSecureFrame = nil
			end

			for _, button in ipairs(self.unitSecureFrames) do
				button:SetClampedToScreen(true)
				button:SetClampRectInsets(0, 0, 0, 0)
			end

			twipe(self.unitSecureFrames)

			self:SetScript("OnUpdate", nil)
			restoreUI(self)
		end
	end)
end


function mod:Toggle(enable)
	if enable then
		existingFrames = core:AggregateUnitFrames()

		if not self.units then
			self.units = {}

			local unitTypes = {
				"mouseover", "player", "target", "focus", "pet",
				"targettarget", "focustarget", "pettarget",
				"maintank", "mainassist", "vehicle",
			}

			local function createButton(unit)
				local frame = CreateFrame("Button", nil, UIParent, "SecureHandlerBaseTemplate")
				frame:SetAttribute("unit", unit)
				frame:Size(1)
				frame:Point("BOTTOMLEFT")
				frame:SetClampedToScreen(true)
				frame:SetClampRectInsets(0, 0, 0, 0)
				frame.dontBroom = true

				return frame
			end

			if isAwesome then
				for i = 1, 40 do
					self.units["coder"..i] = createButton("coder"..i)
					self.units["coder"..i]:SetAttribute("coder", true)
				end
			end

			for _, type in ipairs(unitTypes) do
				self.units[type] = createButton(type)
			end

			for i = 1, 8 do
				if i < 5 then
					self.units["party"..i] = createButton("party"..i)
					self.units["party"..i.."pet"] = createButton("party"..i.."pet")
				end

				if i < 6 then
					self.units["arena"..i] = createButton("arena"..i)
				end

				self.units["boss"..i] = createButton("boss"..i)
			end

			for i = 1, 40 do
				self.units["raid"..i] = createButton("raid"..i)
				self.units["raid"..i.."pet"] = createButton("raid"..i.."pet")
			end

			for _, frame in pairs(self.units) do
				tinsert(sortedUnits, frame)
			end

			local function getFramePriority(unit)
				if tcontains(unitTypes, unit) then
					for i, value in ipairs(unitTypes) do
						if value == unit then
							return i
						end
					end
				elseif find(unit, "^coder%d+$") then
					return 100 + tonumber(match(unit, "^coder(%d+)$"))
				elseif find(unit, "^arena%d+$") then
					return 200 + tonumber(match(unit, "^arena(%d+)$"))
				elseif find(unit, "^party%d+$") then
					return 300 + tonumber(match(unit, "^party(%d+)$"))
				elseif find(unit, "^raid%d+$") then
					return 400 + tonumber(match(unit, "^raid(%d+)$"))
				elseif find(unit, "^party%d+pet$") then
					return 500 + tonumber(match(unit, "^party(%d+)pet$"))
				elseif find(unit, "^raid%d+pet$") then
					return 600 + tonumber(match(unit, "^raid(%d+)pet$"))
				elseif find(unit, "^boss%d+$") then
					return 700 + tonumber(match(unit, "^boss(%d+)$"))
				else
					return 999
				end
			end

			tsort(sortedUnits, function(a, b)
				return getFramePriority(a:GetAttribute("unit")) < getFramePriority(b:GetAttribute("unit"))
			end)
		end

		wipeButtons()

		for _, info in ipairs(E.db.Extras.general[modName].buttons) do
			self[info.name] = CreateFrame("Button", buttonIndex..info.name, UIParent, "SecureActionButtonTemplate, SecureHandlerBaseTemplate")

			if not self:IsHooked(self[info.name], "PreClick") then self:SecureHookScript(self[info.name], "PreClick") end
			if not self:IsHooked(self[info.name], "PostClick") then self:SecureHookScript(self[info.name], "PostClick") end

			self[info.name].tabsInfo = {}
			self[info.name].tabsIconInfo = {}
			self[info.name].unitSecureFrames = {}

			self[info.name].blockFunc = function() end
			self[info.name].dontBroom = true

			local luaFunction, errorMsg = loadstring("return function() " .. info.blockCondition .. " end")

			if luaFunction then
				local success, customFunc = pcall(luaFunction)

				if not success then
					core:print('FAIL', L[modName], customFunc)
				else
					self[info.name].blockFunc = customFunc
				end
			else
				core:print('LUA', L[modName], errorMsg)
			end

			self[info.name]:RegisterForClicks("AnyUp", "AnyDown")
			self[info.name]:SetAttribute("downbutton", "Button31")

			self[info.name]:WrapScript(self[info.name], "OnClick", [[
				if down then return end

				local i = 1
				local buttonName = self:GetName()
				local ref = self:GetFrameRef(buttonName..i)

                self:SetAttribute("type1", "")

				while ref do
					if ref:GetRect() < 0 then
						local j = 1
                        local attr = ref:GetAttribute("attr"..j)
                        local value = ref:GetAttribute("value"..j)
						local retrieve = ref:GetAttribute("retrieve")

                        self:SetAttribute("type1", ref:GetAttribute("type"))

						while attr do
							if retrieve then
								local k = 1
								local unit = self:GetFrameRef("unit"..k)
								local unitFound = false

								while unit do
									if unit:GetRect() < 0 then
										if unit:GetAttribute("coder") then
											local floor, ceil = math.floor, math.ceil
											local char = string.char
											local name = ""
											local n = k

											while unit:GetAttribute("coder") do
												local x, y = unit:GetRect()
												local bytesX = ""
												local bytesY = ""

												x, y = -1 * ceil(x), -1 * ceil(y)

												while x > 0 do
													bytesX = char(x % 256) .. bytesX
													x = floor(x / 256)
												end

												while y > 0 do
													bytesY = char(y % 256) .. bytesY
													y = floor(y / 256)
												end

												name = name .. bytesX .. bytesY

												n = n + 1
												unit = self:GetFrameRef("unit"..n)
											end

											self:SetAttribute(attr, string.gsub(value, "@unit", "@"..name))
										else
											self:SetAttribute(attr, string.gsub(value, "@unit", "@"..unit:GetAttribute("unit")))
										end

										unitFound = true
										break
									end

									k = k + 1
									unit = self:GetFrameRef("unit"..k)
								end

								if not unitFound then
									self:SetAttribute(attr, value)
								end
							else
								self:SetAttribute(attr, value)
							end

							j = j + 1
							value = ref:GetAttribute("value"..j)
							attr = ref:GetAttribute("attr"..j)
						end
						break
					end

					i = i + 1
					ref = self:GetFrameRef(buttonName..i)
				end
			]])

			SetOverrideBindingClick(self[info.name], true, info.keybind, self[info.name]:GetName())
			RegisterStateDriver(self[info.name], "visibility", info.visibilityState or "show")

			for i, frame in ipairs(sortedUnits) do
				self[info.name]:SetFrameRef("unit"..i, frame)
			end

			for j, values in ipairs(info.tabs) do
				self[info.name..j] = self[info.name..j] or CreateFrame("Button", buttonIndex..info.name..j, UIParent, "SecureHandlerBaseTemplate")
				self[info.name..j]:Size(1)
				self[info.name..j]:Point("BOTTOMLEFT")
				self[info.name..j]:SetClampedToScreen(true)
				self[info.name..j]:SetClampRectInsets(0, 0, 0, 0)
				self[info.name..j].dontBroom = true

				self[info.name]:SetFrameRef(buttonIndex..info.name..j, self[info.name..j])

				if values.enabled then
					if values.attributes[values.selectedType] then
						local p = 1
						local unitFound = false

						for attr, value in pairs(values.attributes[values.selectedType]) do
							if trim(value) ~= "" then
								self[info.name..j]:SetAttribute("attr"..p, attr)
								self[info.name..j]:SetAttribute("value"..p, trim(value))

								unitFound = unitFound or find(value, "@unit")
								p = p + 1
							end
						end

						self[info.name..j]:SetAttribute("type", values.selectedType)
						self[info.name..j]:SetAttribute("retrieve", values.retrieveUnit and unitFound)
					else
						core:print('FAIL', L[modName], L["Something went wrong while retrieving the action attributes."])
					end

					local luaFunction, errorMsg = loadstring("return function(frame, unit, isPlate) " .. values.condition .. " end")

					if luaFunction then
						local success, customFunc = pcall(luaFunction)

						if not success then
							core:print('FAIL', L[modName], customFunc)
						else
							tinsert(self[info.name].tabsInfo, {
								func = customFunc,
								button = self[info.name..j],
								scanPlates = values.scanPlates,
								retrieveUnit = values.retrieveUnit,
								broomUI = values.scanPlates and values.broomUI,
								putOnCursor = isAwesome and values.scanPlates and values.putOnCursor,
								targetName = isAwesome and values.scanPlates and values.retrieveUnit and values.targetName
							})

							if info.icon.enabled then
								local id = values.id
								local isSpell = id and IsSpellKnown(id)
								tinsert(self[info.name].tabsIconInfo, {
									id = id,
									idSpell = isSpell,
									idTexture = isSpell and select(3,GetSpellInfo(id)) or GetItemIcon(id),
									cdCheck = isSpell and function() return GetSpellCooldown(id) end or function() return GetItemCooldown(id) end,
									cdInfo = {},
									texture = values.texture,
									borderColor = values.borderColor,
									shadowSize = values.shadowSize,
									shadowColor = values.shadowColor,
									macroText = info.icon.macroText and values.selectedType == "macro" and values.attributes[values.selectedType].macro,
									namePos = info.icon.retrieveName and info.icon.namePos,
									abbreviateName = info.icon.abbreviateName,
									reactionName = info.icon.reactionName,
									className = info.icon.className,

									func = customFunc,
									scanPlates = isAwesome and values.scanPlates,
								})
							end
						end
					else
						core:print('LUA', L[modName], errorMsg)
					end
				end
			end

			self:SetButtonIcon(self[info.name], info, self[info.name].tabsIconInfo)
		end

		-- fucking blizzard caching my shit
		buttonIndex = buttonIndex + 1

		initialized = true
	elseif initialized then
		for _, info in ipairs(E.db.Extras.general[modName].buttons) do
			if self:IsHooked(self[info.name], "PreClick") then self:Unhook(self[info.name], "PreClick") end
			if self:IsHooked(self[info.name], "PostClick") then self:Unhook(self[info.name], "PostClick") end

			ClearOverrideBindings(self[info.name])
		end

		wipeButtons()
	end
end

function mod:InitializeCallback()
	mod:LoadConfig()
	mod:Toggle(E.db.Extras.general[modName].enabled)

	tinsert(core.frameUpdates, function()
		existingFrames = core:AggregateUnitFrames()
	end)
end

core.modules[modName] = mod.InitializeCallback