local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ColorFilter", "AceHook-3.0", "AceEvent-3.0")
local UF = E:GetModule("UnitFrames")
local S = E:GetModule("Skins")

local modName = mod:GetName()
local metaFrame, modEditFrame, elvloaded = CreateFrame("Frame")
local metaTable = { units = {}, statusbars = {}, events = {} }

local _G, pairs, ipairs, tonumber, tostring, unpack, select, loadstring, type, pcall, print = _G, pairs, ipairs, tonumber, tostring, unpack, select, loadstring, type, pcall, print
local find, gsub, match, sub, upper, lower = string.find, string.gsub, string.match, string.sub, string.upper, string.lower
local tinsert, twipe, tremove = table.insert, table.wipe, table.remove
local GetTime, UIParent, GetNumPartyMembers, GetNumRaidMembers = GetTime, UIParent, GetNumPartyMembers, GetNumRaidMembers
local GetThreatStatusColor = GetThreatStatusColor


local function convertToValue(value, unit)
	if value == '@unit' then
		return gsub(value, '@unit', unit)
	elseif value == 'nil' then
		return nil
	elseif value == 'true' then
		return true
	elseif value == 'false' then
		return false
	else
		return value
	end
end

local function compare(value, operator, target)
	if operator == '>' then
		return value > target
	elseif operator == '<' then
		return value < target
	elseif operator == '=' then
		return value == target
	elseif operator == '~=' then
		return value ~= target
	elseif operator == '<=' then
		return value <= target
	elseif operator == '>=' then
		return value >= target
	else
		return false
	end
end

local function updateHooks(frame, hook, statusbar)
	local function ToggleHook(target, extension)
		if hook then
			if not mod:IsHooked(UF, target) then
				mod:SecureHook(UF, target, extension)
			end
		else
			if mod:IsHooked(UF, target) then
				mod:Unhook(UF, target, extension)
			end
		end
	end
	
	if statusbar == 'Castbar' then
		ToggleHook("PostCastStart", mod.PostCastStart)
		ToggleHook("PostCastStop", mod.PostCastStop)
		
		frame[statusbar].PostCastStart = UF.PostCastStart
		frame[statusbar].PostCastStop = UF.PostCastStop
		if hook then
			if not mod:IsHooked(frame[statusbar], "OnUpdate") then 
				frame[statusbar].CFtimeElapsed = 0
				mod:SecureHookScript(frame[statusbar], "OnUpdate", function(self, elapsed)
					self.CFtimeElapsed = self.CFtimeElapsed + elapsed
					if self.CFtimeElapsed > 0.05 then
						self.CFtimeElapsed = 0
						mod.PostCastStart(self)
						if frame.colorFilter[statusbar].colorApplied then 
							self.receivedColor = true 
						elseif self.receivedColor then
							self:PostCastStart()
							self.receivedColor = false 
						end
					end
				end)
			end
		elseif mod:IsHooked(frame[statusbar], "OnUpdate") then 
			mod:Unhook(frame[statusbar], "OnUpdate")
		end
	else
		ToggleHook("PostUpdate"..statusbar.."Color", statusbar == 'Health' and mod.PostUpdateHealthColor or mod.PostUpdatePowerColor)
		
		frame[statusbar]['PostUpdateColor'] = UF['PostUpdate'..statusbar..'Color']
	end

	if frame.ThreatIndicator then
		frame.ThreatIndicator.PostUpdate = UF.UpdateThreat
	end
end

local function constructAnimation(bar, colorFilter)
	colorFilter.flashTexture = bar:CreateTexture(nil, 'OVERLAY')
	colorFilter.flashTexture:SetAllPoints(bar:GetStatusBarTexture())
	colorFilter.flashTexture:SetTexture(E.media.blankTex)
	
	colorFilter.flashTexture.anim = colorFilter.flashTexture:CreateAnimationGroup("Flash")
	colorFilter.flashTexture.anim.fadein = colorFilter.flashTexture.anim:CreateAnimation("ALPHA", "FadeIn")
	colorFilter.flashTexture.anim.fadein:SetChange(1)
	colorFilter.flashTexture.anim.fadein:SetOrder(2)

	colorFilter.flashTexture.anim.fadeout = colorFilter.flashTexture.anim:CreateAnimation("ALPHA", "FadeOut")
	colorFilter.flashTexture.anim.fadeout:SetChange(-1)
	colorFilter.flashTexture.anim.fadeout:SetOrder(1)

	colorFilter.flashTexture.anim:SetScript("OnFinished", function(self) self:Play() end)
end


P["Extras"]["unitframes"][modName] = {
	["selectedUnit"] = 'player',
	["units"] = {
		["player"] = { 
			["enabled"] = false,
			["selectedBar"] = 'Health',
			["glowPriority"] = 'Health',
			["bordersPriority"] = 'Health',
			["infoPanelBorderAdapt"] = 'Health',
			["classBarBorderAdapt"] = 'Health',
			["statusbars"] = {
				["Health"] = {
					["enabled"] = false,
					["selectedTab"] = 1,
					["events"] = "", 
					["tabs"] = {
						{	["enabled"] = false,
							["name"] = "New Tab", 
							["conditions"] = "", 
							["colors"] = {1, 1, 1}, 
							["enableColors"] = false,
							["flash"] = {
								["enabled"] = false,
								["colors"] = {1, 1, 1, 1},
								["speed"] = 0.5,
							},
							["highlight"] = {
								["glow"] = {
									["enabled"] = false, 
									["castbarIcon"] = false,
									["colors"] = {1, 1, 1, 1},
									["size"] = 3,
									["castbarIconSize"] = 3,
									["castbarIconColors"] = {1, 1, 1, 1},
								},
								["borders"] = {
									["enabled"] = false, 
									["castbarIcon"] = false,
									["colors"] = {1, 1, 1},
									["overrideMode"] = 'NONE',
									["castbarIconColors"] = {1, 1, 1},
									["infoPanelBorderEnabled"] = false,
									["infoPanelBorderColors"] = {1, 1, 1},
									["classBarBorderEnabled"] = false, 
									["classBarBorderColors"] = {1, 1, 1},
								},
							}, 
						},
					},
				},
			},
		},
	},
}

function mod:LoadConfig()
	local customFrames = { ['tanktarget'] = true, ['assisttarget'] = true }
	local db = E.db.Extras.unitframes[modName]
	local function selectedUnit() return db.selectedUnit end
	local function selectedBar() return db.units[selectedUnit()].selectedBar end
	local function selectedTab() return db.units[selectedUnit()].statusbars[selectedBar()].selectedTab end
	local function unitEnabled() return db.units[selectedUnit()].enabled end
	local function barEnabled() return db.units[selectedUnit()].statusbars[selectedBar()].enabled end
	local function tabEnabled() return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].enabled end
	local function UFUnitEnabled() return not customFrames[E.db.unitframe.units[selectedUnit()]] and (E.db.unitframe.units[selectedUnit()] and E.db.unitframe.units[selectedUnit()].enable) or (E.db.unitframe.units[gsub(selectedUnit(), 'target', '')] and E.db.unitframe.units[gsub(selectedUnit(), 'target', '')].enable) end
	core.unitframes.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			ColorFilter = {
				order = 1,
				type = "group",
				name = L["Color Filter"],
				guiInline = true,
				disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or UFUnitEnabled() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Enables color filter for the selected unit."],
						disabled = function() return not UFUnitEnabled() end,
						get = function(info) return db.units[selectedUnit()][info[#info]] end,
						set = function(info, value) db.units[selectedUnit()][info[#info]] = value self:Toggle() end,
					},
					enabledBar = {
						order = 2,
						type = "toggle",	
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle for the currently selected statusbar."],
						disabled = function() return not unitEnabled() or not UFUnitEnabled() end,
						get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].enabled end,
						set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].enabled = value self:Toggle() end,
					},
					unitDropdown = {
						order = 3,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						disabled = function() return not UFUnitEnabled() end,
						get = function(info) return selectedUnit() end,
						set = function(info, value)
							db.selectedUnit = value
							if (find(value, 'tank') or find(value, 'assist')) then db.units[selectedUnit()].selectedBar = 'Health' end
							db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = 1
						end,
						values = function() return core:GetUnitDropdownOptions(db.units) end,
					},
					selectedBar = {
						order = 4,
						type = "select",
						name = L["Select Statusbar"],
						desc = "",
						disabled = function() return not unitEnabled() or not UFUnitEnabled() end,
						get = function(info) return selectedBar() end,
						set = function(info, value)
							db.units[selectedUnit()].selectedBar = value
							db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = 1
						end,
						values = function()
							local dropdownValues = {}
							for statusbar, bar in pairs(db.units[selectedUnit()].statusbars) do
								dropdownValues[tostring(statusbar)] = L[statusbar]
							end
							return dropdownValues
						end,
					},
					events = {
						order = 5,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Events (optional)"],
						desc = L["Events to call updates on."..
							"\n\nEVENT[n~=nil]"..
							"\n[n~=value]"..
							"\n[m=false]"..
							"\n[q=@unit]"..
							"\n[k~=@@UnitName('player')]"..
							"\n\n'EVENT' - Event from the events section above"..
							"\n'n, m, q, k' - indexes of the desired payload args (number)"..
							"\n'nil/value/boolean/lua code' - desired output arg value"..
							"\n'@unit' - UnitID of a currently selected unit"..
							"\n'@@' - lua arg flag, must go before the lua code within the args' value section"..
							"\n'~' - negate flag, add before the equals sign to have the code executed if n/m/q/k values do not match the arg value"..
							"\n\nExample:"..
							"\n\nUNIT_AURA[1=player]"..
							"\n\nCHAT_MSG_WHISPER"..
							"\n[5~=@@UnitName(@unit)]"..
							"\n[14=false]"..
							"\n\nCOMBAT_LOG_EVENT_"..
							"\nUNFILTERED"..
							"\n[5=@@UnitName('arena1')]"..
							"\n[5=@@UnitName('arena2')]"..
							"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."],
						hidden = function() return selectedBar() == 'Castbar' end,
						get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].events and db.units[selectedUnit()].statusbars[selectedBar()].events or "" end,
						set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].events = value self:Toggle() end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
					},
				},
			},
			tabSection = {
				order = 2,
				type = "group",
				name = L["Tab Section"],
				guiInline = true,
				get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] end,
				set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] = value self:Toggle() end,
				disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						width = "double",
						disabled = function() return not unitEnabled() or not barEnabled() or not UFUnitEnabled() end,
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle current tab."],
					},
					tabSelection = {
						order = 1,
						type = "select",
						name = L["Select Tab"],
						desc = "",
						get = function(info) return tostring(selectedTab()) end,
						set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = tonumber(value) end,
						values = function()
							local dropdownValues = {}
							for i, tab in ipairs(db.units[selectedUnit()].statusbars[selectedBar()].tabs) do
								dropdownValues[tostring(i)] = tab.name
							end
							return dropdownValues
						end,
						disabled = function() return not unitEnabled() or not barEnabled() or not UFUnitEnabled() end,
					},
					tabPriority = {
						order = 2,
						type = "input",
						name = L["Tab Priority"],
						desc = L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."],
						get = function() return tostring(selectedTab()) end,
						set = function(info, value)
							local colorFilter = db
							local tabCount = #colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs
							local targetTab = tonumber(value)

							if targetTab and targetTab >= 1 and targetTab <= tabCount and targetTab ~= selectedTab() then
								local tempHolder = colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[targetTab]
								colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[targetTab] = colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()]
								colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()] = tempHolder
								db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = targetTab
							elseif targetTab and targetTab > tabCount then
								-- If the target tab is higher than the number of tabs, switch with the highest tab
								local highestTab = tabCount
								local tempHolder = colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[highestTab]
								colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[highestTab] = colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()]
								colorFilter.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()] = tempHolder
								db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = highestTab
							end
							self:Toggle()
						end,
					},
					tabCopyDropdown = {
						order = 3,
						type = "select",
						width = "double",
						name = L["Copy Tab"],
						desc = L["Select a tab to copy its settings onto the current tab."],
						get = function() return "" end,
						set = function(info, value)
							if value then
								local values = info.option.values()
								for index, entry in pairs(values) do
									if index == value then
										local unitName, barName, tabIndex = match(entry, "^[^:]+:%s*(.+),%s*%[%]:%s*(.+),%s*#:%s*(%d+)$")
										db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()] = CopyTable(db.units[unitName].statusbars[barName].tabs[tonumber(tabIndex)])
										break
									end
								end
								self:Toggle()
							end
						end,
						values = function()
							local tabValues = {}
							for unitName, unitTable in pairs(db.units) do
								if unitTable.statusbars then
									for statusbar, bar in pairs(unitTable.statusbars) do
										for tabIndex, tab in ipairs(bar.tabs) do
											if tab.conditions ~= '' and tab ~= db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()] then
												tinsert(tabValues, tabIndex, 'id: '..unitName..', []: '..statusbar..', #: '..tabIndex)
											end
										end
									end
								end
							end
							return tabValues
						end,
					},
					renameTabEditbox = {
						order = 4,
						type = "input",
						width = "double",
						name = L["Rename Tab"],
						desc = "",
						get = function() return "" end,
						set = function(info, value)
							if value and value ~= "" then
								db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].name = value
							end
						end,
					},						
					addTab = {
						order = 5,
						type = "execute",
						name = L["Add Tab"],
						desc = "",
						func = function()
							local newTab = {
							["enabled"] = false,
							["name"] = "New Tab", 
								["conditions"] = "", 
								["colors"] = {1, 1, 1}, 
								["enableColors"] = false,
								["flash"] = {
									["enabled"] = false,
									["colors"] = {1, 1, 1, 1},
									["speed"] = 0.5,
								},
								["highlight"] = {
									["glow"] = {
										["enabled"] = false, 
										["castbarIcon"] = false,
										["colors"] = {1, 1, 1, 1},
										["size"] = 3,
										["castbarIconSize"] = 3,
										["castbarIconColors"] = {1, 1, 1, 1},
									},
									["borders"] = {
										["enabled"] = false, 
										["castbarIcon"] = false,
										["colors"] = {1, 1, 1},
										["overrideMode"] = 'NONE',
										["castbarIconColors"] = {1, 1, 1},
										["infoPanelBorderEnabled"] = false,
										["infoPanelBorderColors"] = {1, 1, 1},
										["classBarBorderEnabled"] = false, 
										["classBarBorderColors"] = {1, 1, 1},
									},
								}, 
							}
							tinsert(db.units[selectedUnit()].statusbars[selectedBar()].tabs, newTab)
							db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = #db.units[selectedUnit()].statusbars[selectedBar()].tabs
						end,
						disabled = function() return not unitEnabled() or not barEnabled() or not UFUnitEnabled() end,
					},
					deleteTab = {
						order = 6,
						type = "execute",
						name = L["Delete Tab"],
						desc = "",
						func = function()
							tremove(db.units[selectedUnit()].statusbars[selectedBar()].tabs, selectedTab())
							db.units[selectedUnit()].statusbars[selectedBar()].selectedTab = selectedTab() > 1 and selectedTab() - 1 or 1
						end,
						disabled = function() return #db.units[selectedUnit()].statusbars[selectedBar()].tabs == 1 or not unitEnabled() or not barEnabled() or not UFUnitEnabled() end,
					},
				},
			},
			flash = {
				order = 3,
				type = "group",
				name = L["Flash"],
				guiInline = true,
				get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].flash[info[#info]] end,
				set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].flash[info[#info]] = value self:Toggle() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "double",
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle color flash for the current tab."],
					},
					colors = {
						order = 2,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].flash.colors) end,
						set = function(info, r, g, b) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].flash.colors = { r, g, b } self:Toggle() end,
						hidden = function() return not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].flash.enabled end,
					},
					speed = {
						order = 3,
						type = "range",
						min = 0.1, max = 5, step = 0.1,
						name = L["Speed"],
						desc = "",
						hidden = function() return not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].flash.enabled end,
					},
				},
			},
			glow = {
				order = 4,
				type = "group",
				name = L["Glow"],
				guiInline = true,
				get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow[info[#info]] end,
				set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow[info[#info]] = value self:Toggle() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						hidden = false,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
						name = core.pluginColor..L["Enable"],
						desc = "",
					},
					glowPriority = {
						order = 2,
						type = "select",
						name = L["Priority"],
						desc = L["Determines which glow to apply when statusbars are not detached from frame."],
						get = function(info) return db.units[selectedUnit()].glowPriority end,
						set = function(info, value) db.units[selectedUnit()].glowPriority = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
						},
						hidden = function() return customFrames[selectedUnit()] or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,
						disabled = function() return not unitEnabled() or not tabEnabled() or not barEnabled() or selectedBar() == 'Castbar' or find(selectedUnit(),'assist') or find(selectedUnit(),'tank') or (E.db.unitframe.units[selectedUnit()].power and E.db.unitframe.units[selectedUnit()].power.detachFromFrame) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,
					},
					colors = {
						order = 3,
						type = "color",
						hasAlpha = true,
						name = L["Color"],
						desc = "",
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.colors) end,
						set = function(info, r, g, b, a) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.colors = { r, g, b, a } self:Toggle() end,
						hidden = function() return not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,
					},
					size = {
						order = 4,
						type = "range",
						min = 1, max = 20, step = 1,
						name = L["Size"],
						desc = "",	
						hidden = function() return not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,											
					},
					castbarIcon = {
						order = 5,
						type = "toggle",
						width = "full",
						name = L["Enable"],
						desc = L["When handling castbar, also manage its icon."],
						hidden = function() return selectedBar() ~= 'Castbar' or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,
					},
					castbarIconColors = {
						order = 6,
						type = "color",
						hasAlpha = true,
						name = L["CastBar Icon Glow Color"],
						desc = "",
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.castbarIconColors) end,
						set = function(info, r, g, b, a) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.castbarIconColors = { r, g, b, a } self:Toggle() end,
						hidden = function() return selectedBar() ~= 'Castbar' or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.castbarIcon end,
					},
					castbarIconSize = {
						order = 7,
						type = "range",
						min = 1, max = 20, step = 1,
						name = L["CastBar Icon Glow Size"],
						desc = "",
						hidden = function() return selectedBar() ~= 'Castbar' or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.glow.castbarIcon end,
					},
				},
			},
			borders = {
				order = 4,
				type = "group",
				name = L["Borders"],
				guiInline = true,
				get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders[info[#info]] end,
				set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders[info[#info]] = value self:Toggle() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
						name = core.pluginColor..L["Enable"],
						desc = "",
					},
					bordersColors = {
						order = 3,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.colors) end,
						set = function(info, r, g, b) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.colors = { r, g, b } self:Toggle() end,
						hidden = function() return not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
					},
					castbarIcon = {
						order = 3,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["When handling castbar, also manage its icon."],
						hidden = function() return selectedBar() ~= 'Castbar' or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
					},
					castbarIconColors = {
						order = 4,
						type = "color",
						name = L["CastBar Icon Color"],
						desc = "",
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.castbarIconColors) end,
						set = function(info, r, g, b) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.castbarIconColors = { r, g, b } self:Toggle() end,
						hidden = function() return selectedBar() ~= 'Castbar' or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.castbarIcon end,
					},
					classBarBorderEnabled = {
						order = 4,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle classbar borders."],
						hidden = function() return customFrames[selectedUnit()] or not (E.db.unitframe.units[selectedUnit()].classbar and E.db.unitframe.units[selectedUnit()].classbar.enable) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not (E.db.unitframe.units[selectedUnit()].classbar and E.db.unitframe.units[selectedUnit()].classbar.enable) end,
					},
					infoPanelBorderEnabled = {
						order = 5,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle infopanel borders."],
						hidden = function() return customFrames[selectedUnit()] or not (E.db.unitframe.units[selectedUnit()].infoPanel and E.db.unitframe.units[selectedUnit()].infoPanel.enable) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not (E.db.unitframe.units[selectedUnit()].infoPanel and E.db.unitframe.units[selectedUnit()].infoPanel.enable) end,
					},
					classBarBorderColors = {
						order = 5,
						type = "color",
						name = L["ClassBar Color"],
						desc = L["Disabled unless classbar is enabled."],
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.classBarBorderColors) end,
						set = function(info, r, g, b) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.classBarBorderColors = { r, g, b } self:Toggle() end,
						hidden = function() return customFrames[selectedUnit()] or not (E.db.unitframe.units[selectedUnit()].classbar and E.db.unitframe.units[selectedUnit()].classbar.enable) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not (E.db.unitframe.units[selectedUnit()].classbar and E.db.unitframe.units[selectedUnit()].classbar.enable) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.classBarBorderEnabled end,
					},
					bordersInfoPanelColors = {
						order = 6,
						type = "color",
						name = L["InfoPanel Color"],
						desc = L["Disabled unless infopanel is enabled."],
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.infoPanelBorderColors) end,
						set = function(info, r, g, b) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.infoPanelBorderColors = { r, g, b } self:Toggle() end,
						hidden = function() return customFrames[selectedUnit()] or not (E.db.unitframe.units[selectedUnit()].infoPanel and E.db.unitframe.units[selectedUnit()].infoPanel.enable) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not (E.db.unitframe.units[selectedUnit()].infoPanel and E.db.unitframe.units[selectedUnit()].infoPanel.enable) or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.infoPanelBorderEnabled end,
					},
					classBarBorderAdapt = {
						order = 7,
						type = "select",
						name = L["ClassBar Adapt To"],
						desc = L["Copies color of the selected bar."],
						get = function(info) return db.units[selectedUnit()].classBarBorderAdapt end,
						set = function(info, value) db.units[selectedUnit()].classBarBorderAdapt = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["None"],
						},
						hidden = function() return not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not (E.db.unitframe.units[selectedUnit()].infoPanel and E.db.unitframe.units[selectedUnit()].infoPanel.enable) end,
					},
					infoPanelBorderAdapt = {
						order = 8,
						type = "select",
						name = L["InfoPanel Adapt To"],
						desc = L["Copies color of the selected bar."],
						get = function(info) return db.units[selectedUnit()].infoPanelBorderAdapt end,
						set = function(info, value) db.units[selectedUnit()].infoPanelBorderAdapt = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["None"],
						},
						hidden = function() return customFrames[selectedUnit()] or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not (E.db.unitframe.units[selectedUnit()].infoPanel and E.db.unitframe.units[selectedUnit()].infoPanel.enable) end,
					},
					overrideMode = {
						order = 10,
						type = "select",
						name = L["Override Mode"],
						desc = L["'None' - threat borders highlight will be prioritized over this one"..
								 "\n'Threat' - this highlight will be prioritized."],
						values = {
							["NONE"] = L["None"],
							["THREAT"] = L["Threat"],
						},
						hidden = function() return customFrames[selectedUnit()] or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
					},
					bordersPriority = {
						order = 11,
						type = "select",
						name = L["Priority"],
						desc = L["Determines which borders to apply when statusbars are not detached from frame."],
						get = function(info) return db.units[selectedUnit()].bordersPriority end,
						set = function(info, value) db.units[selectedUnit()].bordersPriority = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["Bar-specific"],
						},
						hidden = function() return customFrames[selectedUnit()] or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].highlight.borders.enabled end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or selectedBar() == 'Castbar' or find(selectedUnit(),'assist') or find(selectedUnit(),'tank') or (E.db.unitframe.units[selectedUnit()].power and E.db.unitframe.units[selectedUnit()].power.detachFromFrame) end,
					},
				},
			},
			colors = {
				order = 10,
				type = "group",
				name = L["Colors"],
				guiInline = true,
				get = function(info) return db.units[selectedUnit()][info[#info]] end,
				set = function(info, value) db.units[selectedUnit()][info[#info]] = value self:Toggle() end,
				disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
				args = {	
					enableColors = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle bar coloring."],
						get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] end,
						set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] = value self:Toggle() end,
					},
					colors = {
						order = 2,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info) return unpack(db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].colors) end,
						set = function(info, r, g, b) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].colors = { r, g, b } self:Toggle() end,
						disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() or not db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].enableColors end,
					},
				},
			},	
			luaSection = {
				order = 11,
				type = "group",
				name = L["Lua Section"],
				guiInline = true,
				get = function(info) return db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] and db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] or "" end,
				set = function(info, value) db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()][info[#info]] = value self:Toggle() end,
				disabled = function() return not unitEnabled() or not barEnabled() or not tabEnabled() or not UFUnitEnabled() end,
				args = 	{
					openEditFrame = {
						order = 1,
						type = "execute",
						width = "double",
						name = L["Open Edit Frame"],
						desc = "",
						func = function()
							core:OpenEditor(L["Color Filter"], db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].conditions or "", function() db.units[selectedUnit()].statusbars[selectedBar()].tabs[selectedTab()].conditions = core.EditFrame.editBox:GetText() mod:InitAndUpdateColorFilter() end)
						end,
					},
					conditions = {
						order = 2,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Conditions"],
						desc = L["Usage example:"..
								"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
								"\nlocal r, g, b = ElvUF_Target.Health:GetStatusBarColor() return true, {mR = r, mG = g, mB = b} end \nif UnitIsUnit(@unit, 'target') then return true end \n\n@@[raid, Health, 2, >5]@@ - returns true/false based on whether the tab in question (in the example above: 'player' - target unit; 'Power' - target statusbar; '3' - target tab) is active or not (mentioning the same unit/group is disabled; isn't recursive)"..
								"\n(>/>=/<=/</~= num) - (optional, group units only) match against a particular count of triggered frames within the group (more than 5 in the example above)"..
								"\n'return {}' - you can dynamically color the frames by returning the colors in a table format: to apply to the statusbar, assign your rgb values to mR, mG and mB respectively; to apply the glow - to gR, gG, gB, gA (alpha); for borders - bR, bG, bB; and for the flash - fR, fG, fB, fA."..
								"\n\nFeel free to use '@unit' to register current unit like this: UnitBuff(@unit, 'player')."..
								"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."],
					},
				},
			},
		},
	}
	if not db.units.target then
		db.units.player.statusbars.Power = CopyTable(db.units.player.statusbars.Health)
		db.units.player.statusbars.Castbar = CopyTable(db.units.player.statusbars.Health)
		
		local units = core:getAllFrameTypes()
		units['player'] = nil
		
		for unitframeType in pairs(units) do
			db.units[unitframeType] = CopyTable(db.units.player)
			if not UF.db.units[unitframeType] or not UF.db.units[unitframeType].power then
				db.units[unitframeType].statusbars.Power = nil
			end
			if not UF.db.units[unitframeType] or not UF.db.units[unitframeType].power then
				db.units[unitframeType].statusbars.Castbar = nil
			end
		end
	end	
end


function mod:SetupUnits()
	-- shutdown the highlights
	for unit, unitsCluster in pairs(metaTable.units) do
		for _, frame in pairs(unitsCluster) do
			if frame.colorFilter then
				local colorFilter = frame.colorFilter
				for statusbar, bar in pairs(metaTable.statusbars[unit]) do
					self:UpdateGlow(frame, nil, statusbar, unit, false)
					self:UpdateBorders(frame, nil, statusbar, unit, false)
					local targetBar = colorFilter[statusbar]
					if targetBar.flashTexture and targetBar.flashTexture:IsShown() then
						targetBar.flashTexture:Hide()
					end
					if metaTable.events[unit] then
						metaFrame[unit]:UnregisterAllEvents()
						metaFrame[unit]:SetScript('OnEvent', nil)
					end
				end
				frame.colorFilter:Hide()
				frame.colorFilter = nil
			end
		end
	end
	
	-- repopulate
	twipe(metaTable.units)
	local units = core:AggregateUnitFrames()
	local db_units = E.db.Extras.unitframes[modName].units
	for _, frame in ipairs(units) do
		if db_units[frame.unitframeType].enabled then
			if not metaTable.units[frame.unitframeType] then				
				metaTable.units[frame.unitframeType] = {}
				metaTable.statusbars[frame.unitframeType] = {}
			end
			tinsert(metaTable.units[frame.unitframeType], frame)
		end
	end
end

function mod:ConstructHighlight(frame)
	if not frame.colorFilter then
		local colorFilter = CreateFrame("Frame", nil, frame)
		colorFilter.appliedGlowColors = {}
		colorFilter.appliedBordersColors = {}

		colorFilter.Health = CreateFrame("Frame", nil, frame.Health)
		colorFilter.Health:CreateShadow(nil, true)
		colorFilter.Health:SetAllPoints(frame)
		
		colorFilter.Health.shadow:SetFrameLevel(colorFilter.Health:GetFrameLevel()+15)
		
		colorFilter.appliedGlowColors.Health = { applied = false }
		colorFilter.appliedBordersColors.Health = { applied = false }
		
		constructAnimation(frame.Health, colorFilter.Health)
		colorFilter.Health.flashTexture:Hide()

		colorFilter.Health:Hide()
		
		frame.colorFilter = colorFilter
	end

	if frame.USE_POWERBAR and not frame.colorFilter.Power then
		local colorFilter = frame.colorFilter
		local power = frame.Power
		colorFilter.Power = CreateFrame("Frame", nil, power)
		colorFilter.Power:CreateShadow(nil, true)
		colorFilter.Power:SetAllPoints(frame.Power)
		
		colorFilter.Power.shadow:SetFrameLevel(colorFilter.Power:GetFrameLevel()+15)
		
		colorFilter.appliedGlowColors.Power = { applied = false }
		colorFilter.appliedBordersColors.Power = { applied = false }
		
		constructAnimation(power, colorFilter.Power)
		colorFilter.Power.flashTexture:Hide()
		
		colorFilter.Power:Hide()
	end
	
	if frame.Castbar and not frame.colorFilter.Castbar then
		local colorFilter = frame.colorFilter
		local castbar = frame.Castbar
		colorFilter.Castbar = CreateFrame("Frame", nil, castbar)
		colorFilter.Castbar:CreateShadow(nil, true)
		colorFilter.Castbar:SetAllPoints(castbar)
		
		colorFilter.Castbar.shadow:SetFrameLevel(colorFilter.Castbar:GetFrameLevel()+15)
		
		colorFilter.appliedGlowColors.Castbar = { applied = false }
		colorFilter.appliedBordersColors.Castbar = { applied = false }
		
		constructAnimation(castbar, colorFilter.Castbar)
		colorFilter.Castbar.flashTexture:Hide()
		
		colorFilter.Castbar:Hide()
		if castbar.Icon then
			colorFilter.CastbarIcon = CreateFrame("Frame", nil, castbar.Icon.bg)
			colorFilter.CastbarIcon:CreateShadow(nil, true)
			colorFilter.CastbarIcon:SetAllPoints(castbar.Icon.bg)
			
			colorFilter.CastbarIcon.shadow:SetFrameLevel(colorFilter.CastbarIcon:GetFrameLevel()+15)
			
			colorFilter.CastbarIcon:Hide()
		end
	end

	-- overlaps
	local infoPanel = frame.InfoPanel
	if infoPanel then 
		infoPanel.backdrop:Hide() 
		infoPanel.backdrop:Show() 
	end
end


function mod:SortArgs(bar, eventsString, argsBlockStartIndex, unit)
	while sub(eventsString, argsBlockStartIndex, argsBlockStartIndex) == '[' do
		local argsBlockEndIndex = find(eventsString, "]", argsBlockStartIndex + 1)
		local arguments = sub(eventsString, argsBlockStartIndex + 1, argsBlockEndIndex - 1)

		local _, _, argIndex, negate, argValue = find(arguments, "(%d+)(~?)=([^%]]+)")
		eventsString = gsub(eventsString, "(%d+)(~?)=([^%]]+)", '', 1)

		if argValue then
			-- check for lua flag
			local argIsLua = sub(argValue, 1, 2) == '@@'
			
			if argIsLua then 
				argValue = sub(argValue, 3, #argValue)
			else
				argValue = convertToValue(argValue, unit)
			end
			
			tinsert(bar.args, { index = argIndex, argIsLua = argIsLua, arg = argValue, negate = negate == '~' })
		end

		argsBlockStartIndex = argsBlockEndIndex + 1
	end
	
	return eventsString
end

function mod:SortEvents(db, bar, statusbar, bar, unit)
	local startIndex = 1
	local eventsString = bar.events
	bar.args = {}
	startIndex = 1

	-- locate and register events
	while true do
		local eventStart, eventEnd = find(eventsString, "[%u_]+", startIndex)
		if not eventStart then break end

		local argsBlockStartIndex = eventEnd + 1	

		eventsString = self:SortArgs(bar, eventsString, argsBlockStartIndex, unit)
		local event = sub(eventsString, eventStart, eventEnd)

		metaFrame[unit]:RegisterEvent(event)
		metaTable.events[unit] = {[statusbar] = bar}

		startIndex = eventEnd + 1
	end
end

function mod:SortTabsState(frame, conditions, mentionedByUnit, statusbarToUpd)
	local triggerCount = 0
	while match(conditions, '@@%[.-%]@@') do
		local tabsStateCondition = match(conditions, '@@%[(.-)%]@@')
		local unit, statusbar, tabIndex = match(tabsStateCondition, '([^,%s]+),%s*([^,%s]+),%s*([%d]+)')
		local _, operator, triggerCountStr = match(gsub(tabsStateCondition, '([^,%s]+),%s*([^,%s]+),%s*([%d]+)', ''), '(([~=<>]*)%s*([%d]+))')

		if unit and statusbar and tabIndex then
			local ogunit = unit
			unit = lower(gsub(unit, '[%d]+', ''))
			statusbar = gsub(statusbar, "(%a)([%w_']*)", function(first, rest)
				return upper(first) .. lower(rest)
			end)
			tabIndex = tonumber(tabIndex)
		
			local result
			if metaTable.units[unit] and metaTable.statusbars[unit][statusbar] then
				for _, frame in pairs(metaTable.units[unit]) do
					if frame:IsShown() and frame.colorFilter[statusbar].appliedColorTabIndex == tabIndex then
						triggerCount = triggerCount + 1
						result = true
					end
				end
			end

			if triggerCountStr and tonumber(triggerCountStr) then
				result = result and compare(triggerCount, operator, tonumber(triggerCountStr))
			end
			
			-- assign true/false based on whether the respected tab conditions are applied
			conditions = gsub(conditions, '@@%[.-%]@@', (result and (statusbarToUpd ~= statusbar or ogunit ~= mentionedByUnit)) and 'true' or 'false', 1)

			frame.colorFilter[statusbarToUpd].mentionedTab = tabIndex
		else
			core:print('FORMATTING', L["Color Filter"])
			break
		end
	end

	return conditions
end

function mod:SortMentions(db, frame, conditions, mentionedByUnit, statusbarToUpd, mentionedByTabIndex)
	while match(conditions, '@@%[.-%]@@') do
		local tabsStateCondition = match(conditions, '@@%[(.-)%]@@')
		local unit, statusbar, tabIndex = match(tabsStateCondition, '([^,%s]+),%s*([^,%s]+),%s*([%d]+)')

		if unit and statusbar and tabIndex then
			unit = lower(unit)
			statusbar = gsub(statusbar, "(%a)([%w_']*)", function(first, rest)
				return upper(first) .. lower(rest)
			end)
			tabIndex = tonumber(tabIndex)

			if metaTable.units[unit] and metaTable.statusbars[unit][statusbar] then
				for _, mentionedFrame in pairs(metaTable.units[unit]) do
					if not mentionedFrame.colorFilter[statusbar].mentions then
						mentionedFrame.colorFilter[statusbar].mentions = {}
					end

					local mentionInfo = { frame = frame:GetName(), statusbar = statusbarToUpd, unit = mentionedByUnit, tabs = db.units[mentionedByUnit].statusbars[statusbarToUpd].tabs, tabIndex = tabIndex }

					-- check if an entry with the matching mentionedByTabIndex already exists
					local entryExists = false
					for _, existingInfo in pairs(mentionedFrame.colorFilter[statusbar].mentions) do
						if existingInfo.tabIndex == mentionedByTabIndex then
							entryExists = true
						end
					end
					if not entryExists and unit ~= mentionedByUnit then
						tinsert(mentionedFrame.colorFilter[statusbar].mentions, mentionInfo)
					end
				end
			end
			
			conditions = gsub(conditions, '@@%[.-%]@@', '', 1)
		else
			core:print('FORMATTING', L["Color Filter"])
			break
		end
	end	
end


function mod:HandleExtraBars(frame, statusbar, unit, threatBorders, mode, hideBorders)
	local db = E.db.Extras.unitframes[modName].units[unit]
	local borderColor
	local colorFilter = frame.colorFilter
	local appliedBorders = colorFilter.appliedBordersColors[statusbar]
	local infoPanel = frame.InfoPanel
	local threatColors = colorFilter.threatBordersColors and {GetThreatStatusColor(colorFilter.threatBordersColors)}
	if infoPanel and mode ~= 'CLASSBAR' then
		local appliedBordersAdapt = colorFilter.appliedBordersColors[db.infoPanelBorderAdapt]
		if appliedBorders.highlight.borders.infoPanelBorderEnabled or (appliedBordersAdapt and db.statusbars[db.infoPanelBorderAdapt].infoPanelBorderEnabled) then
			if db.infoPanelBorderAdapt ~= 'NONE' and (appliedBordersAdapt and appliedBordersAdapt.applied) then
				borderColor = (threatBorders and threatBorders ~= 'HEALTHBORDER' and not appliedBordersAdapt.override) and threatColors or appliedBordersAdapt.highlight.borders.colors
			else
				borderColor = (threatBorders and threatBorders ~= 'HEALTHBORDER' and not appliedBorders.override) and threatColors or appliedBorders.highlight.borders.infoPanelBorderColors
			end

			borderColor = (hideBorders and (not threatBorders or threatBorders == 'HEALTHBORDER')) and E.media.unitframeBorderColor or (db.infoPanelBorderAdapt ~= 'NONE' and (not appliedBordersAdapt.applied and appliedBordersAdapt.override) and threatBorders == 'INFOPANELBORDER') and threatColors or borderColor
			
			if borderColor then infoPanel.backdrop:SetBackdropBorderColor(unpack(borderColor)) end
		elseif threatBorders and threatBorders ~= 'HEALTHBORDER' then
			infoPanel.backdrop:SetBackdropBorderColor(unpack(threatColors))
		else
			local statusbars, skipRevert = frame.USE_POWERBAR and {'Health', 'Power'} or {'Health'}
			for _, statusbar in ipairs(statusbars) do
				if appliedBorders and appliedBorders.applied then skipRevert = true break end
			end
			if not skipRevert then
				infoPanel.backdrop:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
			end
		end
	end

	if frame.CLASSBAR_SHOWN and mode ~= 'INFOPANEL' then
		local classBar = frame[frame.ClassBar]
		if appliedBorders.highlight.borders.classBarBorderEnabled then
			local appliedBordersAdapt = colorFilter.appliedBordersColors[db.classBarBorderAdapt]
			if db.classBarBorderAdapt ~= 'NONE' and (appliedBordersAdapt and appliedBordersAdapt.applied) then
				borderColor = (threatBorders and not appliedBordersAdapt.override) and threatColors or appliedBordersAdapt.highlight.borders.colors
			else
				borderColor = (threatBorders and not appliedBorders.override) and threatColors or appliedBorders.highlight.borders.classBarBorderColors
			end

			borderColor = (hideBorders and not threatBorders) and E.media.unitframeBorderColor or borderColor

			if borderColor then classBar.backdrop:SetBackdropBorderColor(unpack(borderColor)) end
		elseif threatBorders then
			classBar.backdrop:SetBackdropBorderColor(unpack(threatColors))
		else
			classBar.backdrop:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
		end
	end
end

function mod:UpdateGlow(frame, colors, statusbar, unit, showGlow, highlight)
	local detached = frame.USE_POWERBAR and frame.POWERBAR_DETACHED
	local colorFilter = frame.colorFilter
	local appliedGlowColors = colorFilter.appliedGlowColors
	if showGlow then
		local glow = highlight.glow
		local glowSize = highlight.glow.size
		local glowColors = glow.colors
		local r, g, b, a = glowColors[1], glowColors[2], glowColors[3], glowColors[4]
		
		if colors then
			r, g, b, a = colors.gR and colors.gR or r, colors.gG and colors.gG or g, colors.gB and colors.gB or b, colors.gA and colors.gA or 1
		end
		
		-- highlight all if not detached
		local appliedGlowColorsPriority = colorFilter.appliedGlowColors[E.db.Extras.unitframes[modName].units[unit].glowPriority]
		if (not detached and statusbar ~= 'Castbar') and (appliedGlowColorsPriority and appliedGlowColorsPriority.applied) then 
			r, g, b, a = unpack(appliedGlowColorsPriority.color)
			glowSize = appliedGlowColorsPriority.highlight.glow.size
		end
		
		local targetBar = (detached or statusbar == 'Castbar') and statusbar or 'Health'
		colorFilter[targetBar]:SetScale(glowSize)
		colorFilter[targetBar].shadow:SetBackdropBorderColor(r, g, b, a or 1)
		colorFilter[targetBar]:Show()
		
		if statusbar == 'Castbar' then
			local castbarIcon = colorFilter.CastbarIcon
			if glow.castbarIcon then
				castbarIcon:Show() 
				castbarIcon:SetScale(glow.castbarIconSize)
				castbarIcon.shadow:SetBackdropBorderColor(unpack(glow.castbarIconColors))
			elseif castbarIcon:IsShown() then
				castbarIcon:Hide()
			end
		end		

		colorFilter.appliedGlowColors[statusbar] = { applied = true, color = {r, g, b, a}, highlight = highlight }
	else
		colorFilter[statusbar]:Hide()
		
		if statusbar == 'Castbar' then
			local castbarIcon = colorFilter.CastbarIcon
			if castbarIcon then castbarIcon:Hide() end
		end
		
		if not detached and statusbar ~= 'Castbar' then
			if statusbar == 'Health' and frame.USE_POWERBAR and appliedGlowColors.Power and appliedGlowColors.Power.applied then
				local r, g, b, a = unpack(appliedGlowColors.Power.highlight.glow.colors)
				local health = frame.colorFilter.Health
				health:SetScale(appliedGlowColors.Power.highlight.glow.size)
				health.shadow:SetBackdropBorderColor(r, g, b, a or 1)
				health:Show()
			elseif statusbar == 'Power' and not appliedGlowColors.Health.applied and colorFilter.Health:IsShown() then
				colorFilter.Health:Hide()
			end
		end
		
		colorFilter.appliedGlowColors[statusbar].applied = false
	end
end

function mod:UpdateBorders(frame, colors, statusbar, unit, showBorders, highlight)
	local detached = frame.USE_POWERBAR and frame.POWERBAR_DETACHED
	local colorFilter = frame.colorFilter
	local appliedBorders = colorFilter.appliedBordersColors[statusbar]
	local threatBorders = colorFilter.threatBordersActive
	local power = frame.Power
	local health = frame.Health
	local db = E.db.Extras.unitframes[modName].units[unit]
	if showBorders then
		local borders = highlight.borders
		-- in case no borders have been applied prior to the threat borders
		if not appliedBorders.override then
			colorFilter.appliedBordersColors[statusbar].override = borders.overrideMode == 'THREAT' 
		end

		if statusbar ~= 'Castbar' and ((threatBorders == 'BORDERS' or (threatBorders == 'HEALTHBORDER' and statusbar == 'Health')) and not appliedBorders.override) then 
			frame[statusbar].backdrop:SetBackdropBorderColor(GetThreatStatusColor(colorFilter.threatBordersColors))
			self:HandleExtraBars(frame, statusbar, unit, threatBorders, nil)
			return 
		end
		
		local borderColors = borders.colors
		local r, g, b = borderColors[1], borderColors[2], borderColors[3] 
		if colors then
			r, g, b = colors.bR and colors.bR or r, colors.bG and colors.bG or g, colors.bB and colors.bB or b
		end
		
		colorFilter.appliedBordersColors[statusbar] = { applied = true, color = {r, g, b}, highlight = highlight }
		colorFilter.appliedBordersColors[statusbar].override = borders.overrideMode == 'THREAT' 

		-- apply whatever if detached or bar-specific
		if statusbar == 'Castbar' then
			frame.Castbar.backdrop:SetBackdropBorderColor(r, g, b)
			if borders.castbarIcon then
				frame.Castbar.Icon.bg:SetBackdropBorderColor(r, g, b)
			end
			return
		elseif detached or db.bordersPriority == 'NONE' then
			frame[statusbar].backdrop:SetBackdropBorderColor(r, g, b)
		else
			-- color all with priority
			appliedBorders = colorFilter.appliedBordersColors[db.bordersPriority]
			if appliedBorders and appliedBorders.applied then 
				r, g, b = unpack(appliedBorders.color)
				colorFilter.appliedBordersColors[db.bordersPriority ~= 'Health' and 'Power' or 'Health'].applied = true
			end

			if power then 
				power.backdrop:SetBackdropBorderColor(r, g, b) 
			end
			
			if threatBorders ~= 'HEALTHBORDER' or borders.overrideMode == 'THREAT' then
				health.backdrop:SetBackdropBorderColor(r, g, b)
			end
		end
		
		self:HandleExtraBars(frame, statusbar, unit, threatBorders, nil)
	elseif appliedBorders.applied then
		local r, g, b = (threatBorders and (threatBorders == 'BORDERS' or (threatBorders == 'HEALTHBORDER' and statusbar == 'Health'))) and GetThreatStatusColor(colorFilter.threatBordersColors) or unpack(E.media.unitframeBorderColor)
		colorFilter.appliedBordersColors[statusbar].applied = false 
		colorFilter.appliedBordersColors[statusbar].override = false

		if statusbar == 'Castbar' then
			frame.Castbar.backdrop:SetBackdropBorderColor(r, g, b)
			frame.Castbar.Icon.bg:SetBackdropBorderColor(r, g, b)
		elseif not detached and db.bordersPriority ~= 'NONE' then
			local statusbars = frame.USE_POWERBAR and {'Health', 'Power'} or {'Health'}
			for _, statusbar in ipairs(statusbars) do
				if appliedBorders and appliedBorders.applied and (not threatBorders or appliedBorders.override) then
					r, g, b = unpack(appliedBorders.highlight.borders.colors)
				end
			end

			health.backdrop:SetBackdropBorderColor(r, g, b)
			if power then
				r, g, b = threatBorders == 'HEALTHBORDER' and statusbar == 'Health' and unpack(E.media.unitframeBorderColor) or r, g, b
				power.backdrop:SetBackdropBorderColor(r, g, b)
			end
		else
			frame[statusbar].backdrop:SetBackdropBorderColor(r, g, b)
		end

		self:HandleExtraBars(frame, statusbar, unit, threatBorders, nil, true)
	end
end

function mod:UpdateMentions(bar)
	for _, mentionInfo in pairs(bar.mentions) do
		local frame, statusbar, unit, tabs, tabIndex = _G[mentionInfo.frame], mentionInfo.statusbar, mentionInfo.unit, mentionInfo.tabs, mentionInfo.tabIndex
		local targetBar = frame.colorFilter[statusbar]
		if (bar.appliedColorTabIndex == tabIndex 
		 or (bar.appliedColorTabIndex ~= tabIndex and targetBar.appliedColorTabIndex == tabIndex) 
		  or not targetBar.appliedColorTabIndex) then 
			local result, colors, tab = self:ParseTabs(frame, statusbar, unit, tabs)
			
			local highlight = tab and tab.highlight
			self:UpdateGlow(frame, colors, statusbar, unit, result and highlight.glow.enabled, highlight)
			self:UpdateBorders(frame, colors, statusbar, unit, result and highlight.borders.enabled, highlight)
			
			if not targetBar.colorApplied then
				frame[statusbar]:ForceUpdate()
				local flashTexture = targetBar.flashTexture
				if flashTexture:IsShown() then
					flashTexture.anim:Stop()
					flashTexture:Hide()
				end
			end
		end
	end
end

function mod:UpdateThreat(unit, status, r, g, b)
	local parent = self:GetParent()
	
	if (parent.unit ~= unit) or not unit then return end
	
	local db = parent.db
	if not db then return end
	
	local colorFilter = parent.colorFilter
	if not colorFilter then return end
	
	local unit, threatStyle = parent.unitframeType, db.threatStyle
	if threatStyle == 'BORDERS' or threatStyle == 'HEALTHBORDER' or threatStyle == 'INFOPANELBORDER' then
		if status then
			colorFilter.threatBordersActive = threatStyle == 'BORDERS' and 'BORDERS' or threatStyle == 'HEALTHBORDER' and 'HEALTHBORDER' or threatStyle == 'INFOPANELBORDER' and 'INFOPANELBORDER'
			colorFilter.threatBordersColors = status

			-- revert to the filter colors
			for statusbar, tabInfo in pairs(colorFilter.appliedBordersColors) do
				if threatStyle == 'INFOPANELBORDER' and tabInfo.applied then
					mod:HandleExtraBars(parent, statusbar, parent.unit, colorFilter.threatBordersActive, 'INFOPANEL')
					return
				end

				if tabInfo.override and statusbar ~= 'Castbar' and (threatStyle ~= 'HEALTHBORDER' or statusbar == 'Health') then
					colorFilter.appliedBordersColors[statusbar].applied = false
					mod:UpdateBorders(parent, tabInfo.color, statusbar, parent.unit, true, tabInfo.highlight)
				end
			end
		else
			colorFilter.threatBordersActive = false
			-- roll parser again, cause the conditions have changed by the time threat goes down
			if metaTable.statusbars[unit] then
				for statusbar, bar in pairs(metaTable.statusbars[unit]) do
					local targetBar = colorFilter[statusbar]
					local parentBar = parent[statusbar]
					if parentBar and parentBar:IsShown() then
						local result, colors, tab = mod:ParseTabs(parent, statusbar, parent.unit, bar.tabs)
						
						local highlight = tab and tab.highlight
						mod:UpdateGlow(parent, colors, statusbar, unit, result and highlight.glow.enabled, highlight)
						mod:UpdateBorders(parent, colors, statusbar, unit, result and highlight.borders.enabled, highlight)
					
						if not targetBar.colorApplied then
							parentBar:ForceUpdate()
							local flashTexture = targetBar.flashTexture
							if flashTexture:IsShown() then
								flashTexture.anim:Stop()
								flashTexture:Hide()
							end
						end
					end
					
					if targetBar and targetBar.mentions then
						mod:UpdateMentions(targetBar)
					end
				end
			end
		end
	end
end


function mod:LoadConditions(frame, statusbar, unit, tab, eventArg, tabArg)
	if not tab then return end
	
	local success, result, colors
	local conditions = tab.conditions or tab

	local function executeCondition(isArgLua)
		local luaFunction, errorMsg = loadstring(conditions)

		if luaFunction then
			local wrapperFunction = function(isArgLua)
				if isArgLua then
					local evaluatedTabArg = loadstring("return "..tabArg)()
					return pcall(luaFunction, eventArg, evaluatedTabArg)
				else
					return pcall(luaFunction)
				end
			end
			
			success, result = wrapperFunction(isArgLua)
			
			if not success then
				core:print('FAIL', L["Color Filter"], result)
				return
			end
			
			if type(result) == "table" then
				colors = result
			end
		else
			core:print('LUA', L["Color Filter"], errorMsg)
		end
	end

	-- check the lua arg/conditions
	if tabArg then
		tabArg = gsub(tabArg, '@unit', "'"..unit.."'")
		executeCondition(true)
	else
		conditions = gsub(conditions, '@unit', "'"..unit.."'")
		
		-- check tabs state
		local tabsStateBlock = match(conditions, '@@%[.-%]@@')

		if tabsStateBlock then
			conditions = self:SortTabsState(frame, conditions, unit, statusbar)
		end
		
		executeCondition()
	end

	return result, colors
end

function mod:CheckArgs(frame, unit, tab, ...)
	for _, argTab in ipairs(tab.args) do
		local eventArg = select(argTab.index, ...)
		if argTab.argIsLua then 
			-- check the lua arg
			local result = self:LoadConditions(nil, nil, unit, "if select(1, ...) == select(2, ...) then return true end", nil, eventArg, argTab.arg)
		
			if (result and argTab.negate) or (not result and not argTab.negate) then 
				return true
			end
		else
			-- check if negated
			if (not argTab.negate and argTab.arg ~= eventArg)
			 or (argTab.negate and argTab.arg == eventArg) then
				return true
			end
		end
	end
end

function mod:ParseTabs(frame, statusbar, unit, tabs, isEvent, event, ...)
	local targetBar = frame.colorFilter[statusbar]
	local appliedColorTabIndex = targetBar.appliedColorTabIndex
	for tabIndex, tab in ipairs(tabs) do
		-- if colored already, do not check tabs with lower priority
		if appliedColorTabIndex and tabIndex > appliedColorTabIndex then break end

		if tab.enabled then
			local failedTheArgs
			
			if isEvent and ... and tab.args and #tab.args > 0 then
				failedTheArgs = self:CheckArgs(frame, unit, tab, ...)
			end

			-- continue only if the args are fine (this is an overkill...)
			if not failedTheArgs then
				local result, colors = self:LoadConditions(frame, statusbar, unit, tab, tabIndex)

				if result then
					-- no retriggering please
					local flash = tab.flash
					local flashTexture = targetBar.flashTexture
					if flash.enabled then
						local flashColors = flash.colors
						local r, g, b = flashColors[1], flashColors[2], flashColors[3]
						if colors then
							r, g, b = colors.fR and colors.fR or r, colors.fG and colors.fG or g, colors.fB and colors.fB or b
						end
						flashTexture:SetVertexColor(r, g, b)
						flashTexture:Show()
						
						local anim = flashTexture.anim
						local IsPlaying = anim and anim:IsPlaying()
						if (not anim or not IsPlaying) or (not appliedColorTabIndex or tabIndex < appliedColorTabIndex) then
							if IsPlaying then anim:Stop() end
							anim.fadein:SetDuration(flash.speed)
							anim.fadeout:SetDuration(flash.speed)
							anim:Play()
						end
					elseif flashTexture and flashTexture:IsShown() then
						local anim = flashTexture.anim
						if anim:IsPlaying() then anim:Stop() end
						flashTexture:Hide()
					end
					
					local tabColors = tab.colors
					local r, g, b = tabColors[1], tabColors[2], tabColors[3]

					if colors then
						r, g, b = colors.mR and colors.mR or r, colors.mG and colors.mG or g, colors.mB and colors.mB or b
					end
					
					if tab.enableColors then
						frame[statusbar]:SetStatusBarColor(r, g, b)
					end
						
					-- store the current tab index
					targetBar.colorApplied = true
					targetBar.appliedColorTabIndex = tabIndex

					return result, colors, tab
				elseif appliedColorTabIndex and tabIndex == appliedColorTabIndex then
					-- conditions from the tab currently coloring the bar are no longer true, revert
					targetBar.colorApplied = false
					targetBar.appliedColorTabIndex = nil
				end
			end
		end
	end
end


function mod:Configure_Castbar(frame)
	-- for the icon
	mod:InitAndUpdateColorFilter()
end

function mod:PostUpdateHealthColor(unit, r, g, b)
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not colorFilter then return end

	unit = frame.unitframeType
	
	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Health and frame:IsShown() then
		local result, colors, tab = mod:ParseTabs(frame, 'Health', frame.unit, unitInfo.Health.tabs)
		
		local highlight = tab and tab.highlight
		mod:UpdateGlow(frame, colors, 'Health', unit, result and highlight.glow.enabled, highlight)
		mod:UpdateBorders(frame, colors, 'Health', unit, result and highlight.borders.enabled, highlight)
	
		if colorFilter.Health.mentions then 
			mod:UpdateMentions(colorFilter.Health)
		end
		
		local targetBar = colorFilter['Health']
		if not targetBar.colorApplied then
			local flashTexture = targetBar.flashTexture
			if flashTexture:IsShown() then
				flashTexture.anim:Stop()
				flashTexture:Hide()
			end
		end
	end
end

function mod:PostUpdatePowerColor()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Power) then return end

	local parent = self.origParent or self:GetParent()
	local unit = parent.unitframeType
	
	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Power and frame:IsShown() then
		local result, colors, tab = mod:ParseTabs(frame, 'Power', frame.unit, unitInfo.Power.tabs)
		
		local highlight = tab and tab.highlight
		mod:UpdateGlow(frame, colors, 'Power', unit, result and highlight.glow.enabled, highlight)
		mod:UpdateBorders(frame, colors, 'Power', unit, result and highlight.borders.enabled, highlight)
		
		if colorFilter.Power.mentions then 
			mod:UpdateMentions(colorFilter.Power)
		end
		
		local targetBar = colorFilter['Power']
		if not targetBar.colorApplied then
			local flashTexture = targetBar.flashTexture
			if flashTexture:IsShown() then
				flashTexture.anim:Stop()
				flashTexture:Hide()
			end
		end
	end
end

function mod:CastOnupdate(elapsed)
	--self.CFtimeElapsed = self.CFtimeElapsed + elapsed
	--if self.CFtimeElapsed > 0.05 then
	--	self.CFtimeElapsed = 0
		
		local frame = self:GetParent()
		local colorFilter = frame.colorFilter
		if not (colorFilter and colorFilter.Castbar) then return end
		
		local unit = frame.unitframeType

		local unitInfo = metaTable.statusbars[unit]
		if unitInfo and unitInfo.Castbar and frame:IsShown() then
			local result, colors, tab = mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs)

			local highlight = tab and tab.highlight
			mod:UpdateGlow(frame, colors, 'Castbar', unit, result and highlight.glow.enabled, highlight)
			mod:UpdateBorders(frame, colors, 'Castbar', unit, result and highlight.borders.enabled, highlight)
		
			if colorFilter.Castbar.mentions then 
				mod:UpdateMentions(colorFilter.Castbar)
			end
			
			local targetBar = colorFilter['Castbar']
			if not targetBar.colorApplied then
				frame.Castbar:ForceUpdate()
				local flashTexture = targetBar.flashTexture
				if flashTexture:IsShown() then
					flashTexture.anim:Stop()
					flashTexture:Hide()
				end
			end
		end
	--end
end

function mod:PostCastStart(unit)
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end
	
	unit = frame.unitframeType

	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Castbar and frame:IsShown() then
		local result, colors, tab = mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs)

		local highlight = tab and tab.highlight
		mod:UpdateGlow(frame, colors, 'Castbar', unit, result and highlight.glow.enabled, highlight)
		mod:UpdateBorders(frame, colors, 'Castbar', unit, result and highlight.borders.enabled, highlight)
	
		if colorFilter.Castbar.mentions then 
			mod:UpdateMentions(colorFilter.Castbar)
		end
		
		local targetBar = colorFilter['Castbar']
		if not targetBar.colorApplied then
			local flashTexture = targetBar.flashTexture
			if flashTexture:IsShown() then
				flashTexture.anim:Stop()
				flashTexture:Hide()
			end
		end
	end
end

function mod:PostCastStop(unit)
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	unit = frame.unitframeType
	colorFilter = colorFilter.Castbar

	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Castbar then
		if colorFilter.mentions then 
			colorFilter.appliedColorTabIndex = nil
			mod:UpdateMentions(colorFilter)
		end
	end
end

function mod:Construct_PowerBar(frame, bg, text, textPos)
	mod:ConstructHighlight(frame)
end	

function mod:Construct_Castbar(frame, moverName)
	mod:ConstructHighlight(frame)
end	

function mod:InitAndUpdateColorFilter()
	local db = E.db.Extras.unitframes[modName]
	
	self:SetupUnits()
	
	for unit, unitsCluster in pairs(metaTable.units) do
		for _, frame in ipairs(unitsCluster) do
			self:ConstructHighlight(frame)
		end
	end
	
	for unit, unitsCluster in pairs(metaTable.units) do
		for _, frame in ipairs(unitsCluster) do
			for statusbar, bar in pairs(db.units[unit].statusbars) do
				local targetBar = frame.colorFilter[statusbar]
				local unitInfo = metaTable.statusbars[unit][statusbar]
				if bar.enabled and targetBar then
					if not unitInfo then
						metaTable.statusbars[unit][statusbar] = bar
						unitInfo = metaTable.statusbars[unit][statusbar]
						
						if find(unitInfo.events, '%S+') then
							if not metaFrame[unit] then metaFrame[unit] = CreateFrame("Frame") end
							self:SortEvents(db, unitInfo, statusbar, bar, unit)
						end
					end
					
					frame[statusbar]:ForceUpdate()
					
					updateHooks(frame, bar.enabled, statusbar)
				elseif unitInfo then
					metaTable.statusbars[unit][statusbar] = nil
				end
			end
		end
	end	
	
	for unit, unitsCluster in pairs(metaTable.units) do
		for _, frame in ipairs(unitsCluster) do
			for statusbar, bar in pairs(metaTable.statusbars[unit]) do	
				local unitInfo = metaTable.statusbars[unit][statusbar]
				local tabs = unitInfo.tabs
				for i = 1, #tabs do
					local tab = tabs[i]
					if tab.enabled and find(tab.conditions, '%S+') then
						local tabsStateBlock = match(tab.conditions, '@@%[.-%]@@')

						if tabsStateBlock then								
							self:SortMentions(db, frame, tab.conditions, unit, statusbar, i)
						end
					end
				end
				
				local eventsInfo = metaTable.events[unit]
				local unitInfo = metaTable.units[unit]
				if eventsInfo and not metaFrame[unit]:GetScript('OnEvent') then
					metaFrame[unit]:SetScript('OnEvent', function(self, event, ...)
						for _, frame in ipairs(unitInfo) do
							if frame:IsShown() and (not frame.id or (frame.isForced or (GetNumPartyMembers() >= 1 or GetNumRaidMembers() >= 1))) then
								for statusbar, bar in pairs(eventsInfo) do
									local frameBar = frame[statusbar]
									local targetBar = frame.colorFilter[statusbar]
									if frameBar:IsShown() then
										local result, colors, tab = mod:ParseTabs(frame, statusbar, frame.unit, bar.tabs, true, event, ...)

										local highlight = tab and tab.highlight
										mod:UpdateGlow(frame, colors, statusbar, unit, result and highlight.glow.enabled, highlight)
										mod:UpdateBorders(frame, colors, statusbar, unit, result and highlight.borders.enabled, highlight)
										
										if not targetBar.colorApplied then
											frameBar:ForceUpdate()
											local flashTexture = targetBar.flashTexture
											if flashTexture:IsShown() then
												flashTexture.anim:Stop()
												flashTexture:Hide()
											end
										end		
									end
									if targetBar.mentions then
										mod:UpdateMentions(targetBar)
									end
								end
							end
						end
					end)
				end
			end
		end
	end
end


function mod:Toggle()
	local enable
	
	for _, info in pairs(E.db.Extras.unitframes[modName].units) do
		if info.enabled then enable = true break end
	end
	
	for _, func in ipairs({'Configure_Castbar', 'Construct_Castbar', 'Construct_PowerBar', 'UpdateThreat'}) do
		if enable then
			if not self:IsHooked(UF, func) then self:SecureHook(UF, func, mod[func]) end
		elseif self:IsHooked(UF, func) then
			self:Unhook(UF, func)
		end
	end
	
	self:InitAndUpdateColorFilter()
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end
	
	mod:LoadConfig()
	mod:Toggle()
	
	tinsert(core.frameUpdates, function() mod:InitAndUpdateColorFilter() end)
end

core.modules[modName] = mod.InitializeCallback