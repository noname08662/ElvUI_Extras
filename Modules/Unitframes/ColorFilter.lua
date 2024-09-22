local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ColorFilter", "AceHook-3.0", "AceEvent-3.0")
local UF = E:GetModule("UnitFrames")

local modName = mod:GetName()
local metaFrame = CreateFrame("Frame")
local metaTable = { units = {}, statusbars = {}, events = {} }
local updatePending = false

local _G, pairs, ipairs, tonumber, tostring, unpack, loadstring, type, pcall = _G, pairs, ipairs, tonumber, tostring, unpack, loadstring, type, pcall
local find, gsub, match, sub, upper, lower, format = string.find, string.gsub, string.match, string.sub, string.upper, string.lower, string.format
local tinsert, twipe, tremove = table.insert, table.wipe, table.remove
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local InCombatLockdown, GetTime = InCombatLockdown, GetTime

local E_Delay = E.Delay

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

local function toggleHook(target, hook, extension)
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

local function updateHooks(frame, hook, statusbar)
	if statusbar == 'Castbar' then
		toggleHook("PostCastStart", hook, mod.PostCastStart)
		toggleHook("PostCastStop", hook, mod.PostCastStop)

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
		toggleHook("PostUpdate"..statusbar.."Color", hook, statusbar == 'Health' and mod.PostUpdateHealthColor or mod.PostUpdatePowerColor)

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

local function calculateWeight(overrideH, overrideP, bordersPriority, threatBorders)
    local result = {
        Health = 2,
        Power = 2
    }

    if bordersPriority == 'Health' then
        result.Health = 4
        result.Power = 3
    elseif bordersPriority == 'Power' then
        result.Health = 3
        result.Power = 4
    else
        result.Health = 3
        result.Power = 3
    end

    if threatBorders == 'BORDERS' then
        if not overrideH then
            result.Health = 0
        end
        if not overrideP then
            result.Power = 0
        end
    elseif threatBorders == 'HEALTHBORDER' then
        if not overrideH then
            result.Health = 1
        end
    end

    return result
end

local function calculateAdaptWeight(overrideH, overrideP, adaptPriority, threatBorders, isInfoPanel)
    local result = {
        Health = 2,
        Power = 2
    }

    if adaptPriority == 'Health' then
        result.Health = 4
        result.Power = 3
    elseif adaptPriority == 'Power' then
        result.Health = 3
        result.Power = 4
    else
        result.Health = 3
        result.Power = 3
    end

    if threatBorders == 'BORDERS' or (isInfoPanel and threatBorders == 'INFOPANELBORDER') then
        if not overrideH then
            result.Health = 0
        end
        if not overrideP then
            result.Power = 0
        end
    end

    return result
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
					["frequentUpdates"] = false,
					["updateThrottle"] = 0.1,
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
	local units = E.db.unitframe.units
	local function selectedUnit() return db.selectedUnit end
	local function selectedUnitData()
		return core:getSelected("unitframes", modName, format("units[%s]", selectedUnit() or ""), "player")
	end
	local function selectedBar() return selectedUnitData().selectedBar end
	local function selectedBarData()
		return core:getSelected("unitframes", modName, format("units.%s.statusbars[%s]", selectedUnit(), selectedBar() or ""), "Health")
	end
	local function selectedTab() return db.units[selectedUnit()].statusbars[selectedBar()].selectedTab end
	local function selectedTabData()
		return core:getSelected("unitframes", modName,
								format("units.%s.statusbars.%s.tabs[%s]", selectedUnit(), selectedBar(), selectedTab() or ""), 1)
	end
	local function selectedUFData() return units[selectedUnit()] end
	local function unitEnabled() return selectedUnitData().enabled end
	local function barEnabled() return selectedBarData().enabled end
	local function UFUnitEnabled()
		return not customFrames[selectedUnit()]
				and (selectedUFData() and selectedUFData().enable)
				or (units[gsub(selectedUnit(),'target','')] and units[gsub(selectedUnit(),'target','')].enable)
	end
	local function greyed()
		return not selectedUnitData().enabled
				or not selectedBarData().enabled
				or not selectedTabData().enabled
				or not UFUnitEnabled()
	end
	core.unitframes.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			ColorFilter = {
				order = 1,
				type = "group",
				name = L["Color Filter"],
				guiInline = true,
				disabled = function() return greyed() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Enables color filter for the selected unit."],
						disabled = function() return not UFUnitEnabled() end,
						get = function(info) return selectedUnitData()[info[#info]] end,
						set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle() end,
					},
					enabledBar = {
						order = 2,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle for the currently selected statusbar."],
						disabled = function() return not unitEnabled() or not UFUnitEnabled() end,
						get = function() return selectedBarData().enabled end,
						set = function(_, value) selectedBarData().enabled = value self:Toggle() end,
					},
					unitDropdown = {
						order = 3,
						type = "select",
						name = L["Select Unit"],
						desc = "",
						disabled = false,
						get = function() return selectedUnit() end,
						set = function(_, value)
							db.selectedUnit = value
							if (find(value, 'tank') or find(value, 'assist')) then selectedUnitData().selectedBar = 'Health' end
							selectedBarData().selectedTab = 1
						end,
						values = function() return core:GetUnitDropdownOptions(db.units) end,
					},
					selectedBar = {
						order = 4,
						type = "select",
						name = L["Select Statusbar"],
						desc = "",
						disabled = function() return not unitEnabled() or not UFUnitEnabled() end,
						get = function() return selectedBar() end,
						set = function(_, value)
							selectedUnitData().selectedBar = value
							selectedBarData().selectedTab = 1
						end,
						values = function()
							local dropdownValues = {}
							for statusbar in pairs(selectedUnitData().statusbars) do
								dropdownValues[tostring(statusbar)] = L[statusbar]
							end
							return dropdownValues
						end,
					},
					frequentUpdates = {
						order = 5,
						type = "toggle",
						name = L["Frequent Updates"],
						desc = "",
						disabled = function() return greyed() or selectedBar() == 'Castbar' end,
						hidden = function() return selectedBar() == 'Castbar' end,
						get = function(info) return selectedBarData()[info[#info]] end,
						set = function(info, value) selectedBarData()[info[#info]] = value self:Toggle() end,
					},
					updateThrottle = {
						order = 6,
						type = "range",
						min = 0, max = 10, step = 0.1,
						name = L["Throttle Time"],
						desc = "",
						disabled = function() return greyed() or not selectedBarData().frequentUpdates end,
						hidden = function() return selectedBar() == 'Castbar' end,
						get = function(info) return selectedBarData()[info[#info]] end,
						set = function(info, value) selectedBarData()[info[#info]] = value self:Toggle() end,
					},
					events = {
						order = 7,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Events (optional)"],
						desc = L["UNIT_AURA CHAT_MSG_WHISPER etc."],
						hidden = function() return selectedBar() == 'Castbar' end,
						get = function() return selectedBarData().events or "" end,
						set = function(_, value) selectedBarData().events = value self:Toggle() end,
					},
				},
			},
			tabSection = {
				order = 2,
				type = "group",
				name = L["Tab Section"],
				guiInline = true,
				get = function(info) return selectedTabData()[info[#info]] end,
				set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle() end,
				disabled = function() return greyed() end,
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
						get = function() return tostring(selectedTab()) end,
						set = function(_, value) selectedBarData().selectedTab = tonumber(value) end,
						values = function()
							local dropdownValues = {}
							for i, tab in ipairs(selectedBarData().tabs) do
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
						set = function(_, value)
							local tabCount = #selectedBarData().tabs
							local targetTab = tonumber(value)

							if targetTab and targetTab >= 1 and targetTab <= tabCount and targetTab ~= selectedTab() then
								local tempHolder = selectedBarData().tabs[targetTab]
								selectedBarData().tabs[targetTab] = selectedTabData()
								selectedBarData().tabs[selectedTab()] = tempHolder
								selectedBarData().selectedTab = targetTab
							elseif targetTab and targetTab > tabCount then
								-- If the target tab is higher than the number of tabs, switch with the highest tab
								local highestTab = tabCount
								local tempHolder = selectedBarData().tabs[highestTab]
								selectedBarData().tabs[highestTab] = selectedTabData()
								selectedBarData().tabs[selectedTab()] = tempHolder
								selectedBarData().selectedTab = highestTab
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
							if not value then return end
							local values = info.option.values()
							for index, entry in pairs(values) do
								if index == value then
									local unitName, barName, tabIndex = match(entry, "^[^:]+:%s*(.+),%s*%[%]:%s*(.+),%s*#:%s*(%d+)$")
									selectedBarData().tabs[selectedTab()] = CopyTable(db.units[unitName].statusbars[barName].tabs[tonumber(tabIndex)])
									break
								end
							end
							self:Toggle()
						end,
						values = function()
							local tabValues = {}
							for unitName, unitTable in pairs(db.units) do
								if unitTable.statusbars then
									for statusbar, bar in pairs(unitTable.statusbars) do
										for tabIndex, tab in ipairs(bar.tabs) do
											if tab.conditions ~= '' and tab ~= selectedTabData() then
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
						set = function(_, value)
							if value and value ~= "" then
								selectedTabData().name = value
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
							tinsert(selectedBarData().tabs, newTab)
							selectedBarData().selectedTab = #selectedBarData().tabs
						end,
						disabled = function() return not unitEnabled() or not barEnabled() or not UFUnitEnabled() end,
					},
					deleteTab = {
						order = 6,
						type = "execute",
						name = L["Delete Tab"],
						desc = "",
						func = function()
							tremove(selectedBarData().tabs, selectedTab())
							selectedBarData().selectedTab = selectedTab() > 1 and selectedTab() - 1 or 1
						end,
						disabled = function() return #selectedBarData().tabs == 1
													or not unitEnabled() or not barEnabled() or not UFUnitEnabled() end,
					},
				},
			},
			flash = {
				order = 3,
				type = "group",
				name = L["Flash"],
				guiInline = true,
				get = function(info) return selectedTabData().flash[info[#info]] end,
				set = function(info, value) selectedTabData().flash[info[#info]] = value self:Toggle() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "double",
						disabled = function() return greyed() end,
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle color flash for the current tab."],
					},
					colors = {
						order = 2,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedTabData().flash.colors) end,
						set = function(_, r, g, b) selectedTabData().flash.colors = { r, g, b } self:Toggle() end,
						hidden = function() return not selectedTabData().flash.enabled end,
					},
					speed = {
						order = 3,
						type = "range",
						min = 0.1, max = 5, step = 0.1,
						name = L["Speed"],
						desc = "",
						hidden = function() return not selectedTabData().flash.enabled end,
					},
				},
			},
			glow = {
				order = 4,
				type = "group",
				name = L["Glow"],
				guiInline = true,
				get = function(info) return selectedTabData().highlight.glow[info[#info]] end,
				set = function(info, value) selectedTabData().highlight.glow[info[#info]] = value self:Toggle() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						hidden = false,
						disabled = function() greyed() end,
						name = core.pluginColor..L["Enable"],
						desc = "",
					},
					glowPriority = {
						order = 2,
						type = "select",
						name = L["Priority"],
						desc = L["Determines which glow to apply when statusbars are not detached from frame."],
						get = function() return selectedUnitData().glowPriority end,
						set = function(_, value) selectedUnitData().glowPriority = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
						},
						hidden = function() return customFrames[selectedUnit()] or not selectedTabData().highlight.glow.enabled end,
						disabled = function()
							return greyed() or selectedBar() == 'Castbar'
								or find(selectedUnit(),'assist') or find(selectedUnit(),'tank')
								or (selectedUFData().power and selectedUFData().power.detachFromFrame)
								or not selectedTabData().highlight.glow.enabled end,
					},
					colors = {
						order = 3,
						type = "color",
						hasAlpha = true,
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedTabData().highlight.glow.colors) end,
						set = function(_, r, g, b, a) selectedTabData().highlight.glow.colors = { r, g, b, a } self:Toggle() end,
						hidden = function() return not selectedTabData().highlight.glow.enabled end,
					},
					size = {
						order = 4,
						type = "range",
						min = 1, max = 20, step = 1,
						name = L["Size"],
						desc = "",
						hidden = function() return not selectedTabData().highlight.glow.enabled end,
					},
					castbarIcon = {
						order = 5,
						type = "toggle",
						width = "full",
						name = L["Enable"],
						desc = L["When handling castbar, also manage its icon."],
						hidden = function() return selectedBar() ~= 'Castbar' or not selectedTabData().highlight.glow.enabled end,
					},
					castbarIconColors = {
						order = 6,
						type = "color",
						hasAlpha = true,
						name = L["CastBar Icon Glow Color"],
						desc = "",
						get = function() return unpack(selectedTabData().highlight.glow.castbarIconColors) end,
						set = function(_, r, g, b, a) selectedTabData().highlight.glow.castbarIconColors = {r, g, b, a} self:Toggle() end,
						hidden = function() return selectedBar() ~= 'Castbar' or not selectedTabData().highlight.glow.enabled end,
						disabled = function() return greyed() or not selectedTabData().highlight.glow.castbarIcon end,
					},
					castbarIconSize = {
						order = 7,
						type = "range",
						min = 1, max = 20, step = 1,
						name = L["CastBar Icon Glow Size"],
						desc = "",
						hidden = function() return selectedBar() ~= 'Castbar' or not selectedTabData().highlight.glow.enabled end,
						disabled = function() return greyed() or not selectedTabData().highlight.glow.castbarIcon end,
					},
				},
			},
			borders = {
				order = 4,
				type = "group",
				name = L["Borders"],
				guiInline = true,
				get = function(info) return selectedTabData().highlight.borders[info[#info]] end,
				set = function(info, value) selectedTabData().highlight.borders[info[#info]] = value self:Toggle() end,
				disabled = function() return greyed() end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = "",
					},
					bordersColors = {
						order = 3,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedTabData().highlight.borders.colors) end,
						set = function(_, r, g, b) selectedTabData().highlight.borders.colors = {r, g, b} self:Toggle() end,
						hidden = function() return not selectedTabData().highlight.borders.enabled end,
					},
					castbarIcon = {
						order = 3,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["When handling castbar, also manage its icon."],
						hidden = function() return selectedBar() ~= 'Castbar' or not selectedTabData().highlight.borders.enabled end,
					},
					castbarIconColors = {
						order = 4,
						type = "color",
						name = L["CastBar Icon Color"],
						desc = "",
						get = function() return unpack(selectedTabData().highlight.borders.castbarIconColors) end,
						set = function(_, r, g, b) selectedTabData().highlight.borders.castbarIconColors = {r, g, b} self:Toggle() end,
						hidden = function() return selectedBar() ~= 'Castbar' or not selectedTabData().highlight.borders.enabled end,
						disabled = function() return greyed() or not selectedTabData().highlight.borders.castbarIcon end,
					},
					classBarBorderEnabled = {
						order = 4,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle classbar borders."],
						hidden = function()
							return customFrames[selectedUnit()]
									or not (selectedUFData().classbar and selectedUFData().classbar.enable)
									or not selectedTabData().highlight.borders.enabled end,
						disabled = function() return greyed() or not selectedUFData().classbar.enable end,
					},
					infoPanelBorderEnabled = {
						order = 5,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle infopanel borders."],
						hidden = function()
							return customFrames[selectedUnit()]
									or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable)
									or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed() or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable) end,
					},
					classBarBorderColors = {
						order = 5,
						type = "color",
						name = L["ClassBar Color"],
						desc = L["Disabled unless classbar is enabled."],
						get = function() return unpack(selectedTabData().highlight.borders.classBarBorderColors) end,
						set = function(_, r, g, b) selectedTabData().highlight.borders.classBarBorderColors = {r, g, b} self:Toggle() end,
						hidden = function()
							return customFrames[selectedUnit()]
								or not (selectedUFData().classbar and selectedUFData().classbar.enable)
								or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed() or not (selectedUFData().classbar and selectedUFData().classbar.enable)
							or not selectedTabData().highlight.borders.classBarBorderEnabled end,
					},
					bordersInfoPanelColors = {
						order = 6,
						type = "color",
						name = L["InfoPanel Color"],
						desc = L["Disabled unless infopanel is enabled."],
						get = function() return unpack(selectedTabData().highlight.borders.infoPanelBorderColors) end,
						set = function(_, r, g, b) selectedTabData().highlight.borders.infoPanelBorderColors = {r, g, b} self:Toggle() end,
						hidden = function()
							return customFrames[selectedUnit()]
								or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable)
								or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed()
								or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable)
								or not selectedTabData().highlight.borders.infoPanelBorderEnabled end,
					},
					classBarBorderAdapt = {
						order = 7,
						type = "select",
						name = L["ClassBar Adapt To"],
						desc = L["Copies color of the selected bar."],
						get = function() return selectedUnitData().classBarBorderAdapt end,
						set = function(_, value) selectedUnitData().classBarBorderAdapt = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["None"],
						},
						hidden = function() return not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed()
								or not (selectedUFData().classbar and selectedUFData().classbar.enable) end,
					},
					infoPanelBorderAdapt = {
						order = 8,
						type = "select",
						name = L["InfoPanel Adapt To"],
						desc = L["Copies color of the selected bar."],
						get = function() return selectedUnitData().infoPanelBorderAdapt end,
						set = function(_, value) selectedUnitData().infoPanelBorderAdapt = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["None"],
						},
						hidden = function()
							return customFrames[selectedUnit()] or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed() or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable) end,
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
						hidden = function()
							return customFrames[selectedUnit()] or not selectedTabData().highlight.borders.enabled end,
					},
					bordersPriority = {
						order = 11,
						type = "select",
						name = L["Priority"],
						desc = L["Determines which borders to apply when statusbars are not detached from frame."],
						get = function() return selectedUnitData().bordersPriority end,
						set = function(_, value) selectedUnitData().bordersPriority = value self:Toggle() end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["Bar-specific"],
						},
						hidden = function()
							return customFrames[selectedUnit()] or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed() or selectedBar() == 'Castbar'
								or find(selectedUnit(),'assist') or find(selectedUnit(),'tank')
								or (selectedUFData().power and selectedUFData().power.detachFromFrame) end,
					},
				},
			},
			colors = {
				order = 10,
				type = "group",
				name = L["Colors"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle() end,
				disabled = function() return greyed() end,
				args = {
					enableColors = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle bar coloring."],
						get = function(info) return selectedTabData()[info[#info]] end,
						set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle() end,
					},
					colors = {
						order = 2,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedTabData().colors) end,
						set = function(_, r, g, b) selectedTabData().colors = {r, g, b} self:Toggle() end,
						disabled = function() return greyed() or not selectedTabData().enableColors end,
					},
				},
			},
			luaSection = {
				order = 11,
				type = "group",
				name = L["Lua Section"],
				guiInline = true,
				get = function(info) return selectedTabData()[info[#info]] or "" end,
				set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle() end,
				disabled = function() return greyed() end,
				args = 	{
					openEditFrame = {
						order = 1,
						type = "execute",
						width = "double",
						name = L["Open Edit Frame"],
						desc = "",
						func = function()
							core:OpenEditor(
								L["Color Filter"],
								selectedTabData().conditions or "",
								function()
									selectedTabData().conditions = core.EditFrame.editBox:GetText()
									mod:InitAndUpdateColorFilter()
								end
							)
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
									"\nlocal r, g, b = ElvUF_Target.Health:GetStatusBarColor() return true, {mR = r, mG = g, mB = b} end"..
									"\nif UnitIsUnit(@unit, 'target') then return true end"..
									"\n\n@@[raid, Health, 2, >5]@@ - returns true/false based on whether the tab in question (in the example above: 'player' - target unit; 'Power' - target statusbar; '3' - target tab) is active or not (mentioning the same unit/group is disabled; isn't recursive)"..
									"\n(>/>=/<=/</~= num) - (optional, group units only) match against a particular count of triggered frames within the group (more than 5 in the example above)"..
									"\n\n'return {bR=1,f=false}' - you can dynamically color the frames by returning the colors in a table format:"..
									"\n  to apply to the statusbar, assign your rgb values to mR, mG and mB respectively"..
									"\n  to apply the glow - to gR, gG, gB, gA (alpha)"..
									"\n  for borders - bR, bG, bB"..
									"\n  and for the flash - fR, fG, fB, fA"..
									"\n  to prevent the elements styling, return {m = false, g = false, b = false, f = false}"..
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
				for statusbar in pairs(metaTable.statusbars[unit]) do
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
		colorFilter.appliedBordersColors.Health = { applied = false, override = false }

		constructAnimation(frame.Health, colorFilter.Health)
		colorFilter.Health.flashTexture:Hide()

		colorFilter.Health.shadow:Hide()

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
		colorFilter.appliedBordersColors.Power = { applied = false, override = false }

		constructAnimation(power, colorFilter.Power)
		colorFilter.Power.flashTexture:Hide()

		colorFilter.Power.shadow:Hide()
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

		colorFilter.Castbar.shadow:Hide()
		if castbar.Icon then
			colorFilter.CastbarIcon = CreateFrame("Frame", nil, castbar.Icon.bg)
			colorFilter.CastbarIcon:CreateShadow(nil, true)
			colorFilter.CastbarIcon:SetAllPoints(castbar.Icon.bg)

			colorFilter.CastbarIcon.shadow:SetFrameLevel(colorFilter.CastbarIcon:GetFrameLevel()+15)

			colorFilter.CastbarIcon.shadow:Hide()
		end
	end

	-- overlaps
	local infoPanel = frame.InfoPanel
	if infoPanel then
		infoPanel.backdrop:Hide()
		infoPanel.backdrop:Show()
	end
end


function mod:SortEvents(bar, statusbar, unit)
	local startIndex = 1
	local eventsString = bar.events
	bar.args = {}

	-- locate and register events
	while true do
		local eventStart, eventEnd = find(eventsString, "[%u_]+", startIndex)
		if not eventStart then break end

		metaFrame[unit]:RegisterEvent(sub(eventsString, eventStart, eventEnd))
		metaTable.events[unit] = metaTable.events[unit] or {}
		metaTable.events[unit][statusbar] = bar

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


function mod:UpdateGlow(frame, colors, statusbar, unit, showGlow, highlight)
	local detached = frame.USE_POWERBAR and frame.POWERBAR_DETACHED
	local colorFilter = frame.colorFilter
	local appliedGlowColors = colorFilter.appliedGlowColors

	if showGlow and (not colors or colors.g ~= false) then
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
		colorFilter[targetBar].shadow:Show()

		if statusbar == 'Castbar' then
			local castbarIcon = colorFilter.CastbarIcon
			if glow.castbarIcon then
				castbarIcon:SetScale(glow.castbarIconSize)
				castbarIcon.shadow:SetBackdropBorderColor(unpack(glow.castbarIconColors))
				castbarIcon.shadow:Show()
			elseif castbarIcon:IsShown() then
				castbarIcon.shadow:Hide()
			end
		end

		colorFilter.appliedGlowColors[statusbar] = { applied = true, color = {r, g, b, a}, highlight = highlight }
	else
		colorFilter[statusbar].shadow:Hide()

		if statusbar == 'Castbar' then
			local castbarIcon = colorFilter.CastbarIcon
			if castbarIcon then castbarIcon.shadow:Hide() end
		end

		if not detached and statusbar ~= 'Castbar' then
			if statusbar == 'Health' and frame.USE_POWERBAR and appliedGlowColors.Power and appliedGlowColors.Power.applied then
				local r, g, b, a = unpack(appliedGlowColors.Power.highlight.glow.colors)
				local health = frame.colorFilter.Health
				health:SetScale(appliedGlowColors.Power.highlight.glow.size)
				health.shadow:SetBackdropBorderColor(r, g, b, a or 1)
				health.shadow:Show()
			elseif statusbar == 'Power' and not appliedGlowColors.Health.applied and colorFilter.Health:IsShown() then
				colorFilter.Health.shadow:Hide()
			end
		end

		colorFilter.appliedGlowColors[statusbar].applied = false
	end
end

function mod:UpdateBorders(frame, colors, statusbar, unit, showBorders, highlight)
    local detached = frame.USE_POWERBAR and frame.POWERBAR_DETACHED
    local colorFilter = frame.colorFilter
    local appliedBorders = colorFilter.appliedBordersColors
    local threatBorders = colorFilter.threatBordersActive
    local power = frame.USE_POWERBAR and frame.Power
    local health = frame.Health
    local db = E.db.Extras.unitframes[modName].units[unit]

    if showBorders and (not colors or colors.b ~= false) then
        local borders = highlight.borders
        local borderColors = borders.colors
        local r, g, b = borderColors[1], borderColors[2], borderColors[3]

        if colors then
            r, g, b = colors.bR or r, colors.bG or g, colors.bB or b
        end

        -- handle Castbar separately
        if statusbar == 'Castbar' then
            frame.Castbar.backdrop:SetBackdropBorderColor(r, g, b)
            if borders.castbarIcon then
                frame.Castbar.Icon.bg.backdrop:SetBackdropBorderColor(r, g, b)
            end
            return
        end

		appliedBorders[statusbar].override = borders.overrideMode == 'THREAT'

		local weights = calculateWeight(appliedBorders.Health.override,
										power and appliedBorders.Power.override,
										db.bordersPriority, threatBorders)

        appliedBorders[statusbar].applied = true
        appliedBorders[statusbar].color = {r, g, b}
        appliedBorders[statusbar].highlight = highlight
        appliedBorders[statusbar].weight = weights[statusbar]

        if detached or db.bordersPriority == 'NONE' then
			if weights[statusbar] < 2 then
				frame[statusbar].backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
			else
				frame[statusbar].backdrop:SetBackdropBorderColor(r, g, b)
			end
        else
			local otherStatusbar = statusbar == 'Health' and 'Power' or 'Health'
			if not appliedBorders[otherStatusbar].applied then
				if weights[statusbar] < 2 then
					if power then
						if weights[statusbar] == 1 then
							power.backdrop:SetBackdropBorderColor(r, g, b)
						else
							power.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
						end
					end
					health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
				else
					if power then
						power.backdrop:SetBackdropBorderColor(r, g, b)
					end
					health.backdrop:SetBackdropBorderColor(r, g, b)
				end
			elseif weights[statusbar] > weights[otherStatusbar] then
				if power then
					power.backdrop:SetBackdropBorderColor(r, g, b)
				end
				if weights[statusbar] == 1 then
					health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
				else
					health.backdrop:SetBackdropBorderColor(r, g, b)
				end
			elseif weights[statusbar] < weights[otherStatusbar] then
				local otherAppliedBorders = appliedBorders[otherStatusbar]
				if weights[statusbar] == 1 then
					if power then
						if db.bordersPriority == statusbar then
							power.backdrop:SetBackdropBorderColor(r, g, b)
						else
							power.backdrop:SetBackdropBorderColor(unpack(otherAppliedBorders.color))
						end
					end
					health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
				else
					if power then
						power.backdrop:SetBackdropBorderColor(unpack(otherAppliedBorders.color))
					end
					health.backdrop:SetBackdropBorderColor(unpack(otherAppliedBorders.color))
				end
			elseif weights[statusbar] == 0 then
				if power then
					power.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
				end
				health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
			end
        end
    elseif appliedBorders[statusbar].applied then
		appliedBorders[statusbar].applied = false
		appliedBorders[statusbar].override = false
		appliedBorders[statusbar].weight = 2

		if statusbar == 'Castbar' then
			local r, g, b = unpack(E.media.unitframeBorderColor)
			frame.Castbar.backdrop:SetBackdropBorderColor(r, g, b)
			if highlight.borders.castbarIcon then
				frame.Castbar.Icon.bg.backdrop:SetBackdropBorderColor(r, g, b)
			end
		else
			local weights = calculateWeight(appliedBorders.Health.override,
											power and appliedBorders.Power.override,
											db.bordersPriority, threatBorders)

			if not detached and db.bordersPriority ~= 'NONE' then
				local otherbar = statusbar == 'Health' and 'Power' or 'Health'
				local otherAppliedBorders = appliedBorders[otherbar]

				if otherAppliedBorders.applied then
					if weights[otherbar] < 2 then
						if power then
							if weights[otherbar] == 1 then
								power.backdrop:SetBackdropBorderColor(unpack(otherAppliedBorders.color))
							else
								power.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
							end
						end
						health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
					else
						if power then
							power.backdrop:SetBackdropBorderColor(unpack(otherAppliedBorders.color))
						end
						if weights[statusbar] == 1 and not appliedBorders.Power.override then
							health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
						else
							health.backdrop:SetBackdropBorderColor(unpack(otherAppliedBorders.color))
						end
					end
				else
					if power then
						if weights.Power < 1 then
							power.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
						else
							power.backdrop:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
						end
					end
					if weights.Health < 2 then
						health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
					else
						health.backdrop:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
					end
				end
			else
				if weights[statusbar] < 2 then
					frame[statusbar].backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
				else
					frame[statusbar].backdrop:SetBackdropBorderColor(unpack(E.media.unitframeBorderColor))
				end
			end
        end
    end

	if statusbar == 'Castbar' then return end

    -- Handle InfoPanel border
    if frame.USE_INFO_PANEL then
		local adapt = db.infoPanelBorderAdapt
        local infoPanel = frame.InfoPanel
		local finalColor = E.media.unitframeBorderColor
		local weights = calculateAdaptWeight(appliedBorders.Health.override,
											power and appliedBorders.Power.override,
											adapt, threatBorders, true)

        --if highlight and highlight.borders.infoPanelBorderEnabled then
        if showBorders then
			if adapt ~= 'NONE' then
				local appliedBordersAdapt = appliedBorders[adapt]

				if appliedBordersAdapt.applied and weights[adapt] ~= 0 then
					finalColor = appliedBordersAdapt.color
				elseif adapt == statusbar then
					local otherbar = statusbar == 'Health' and 'Power' or 'Health'
					if appliedBorders[otherbar].applied and weights[otherbar] ~= 0 then
						finalColor = appliedBorders[otherbar].highlight.borders.infoPanelBorderColors
					else
						finalColor = colorFilter.threatBordersColor
					end
				elseif weights[statusbar] == 0 then
					finalColor = colorFilter.threatBordersColor
				else
					finalColor = highlight.borders.infoPanelBorderColors
				end
            elseif weights[statusbar] == 0 then
				local otherbar = statusbar == 'Health' and 'Power' or 'Health'
				if appliedBorders[otherbar].applied and weights[otherbar] ~= 0 then
					finalColor = appliedBorders[otherbar].highlight.borders.infoPanelBorderColors
				else
					finalColor = colorFilter.threatBordersColor
				end
			else
				finalColor = highlight.borders.infoPanelBorderColors
            end
		else
			local otherbar = statusbar == 'Health' and 'Power' or 'Health'
			local otherBorders = appliedBorders[otherbar]
			if otherBorders.applied and otherBorders.highlight.borders.infoPanelBorderEnabled then
				if weights[otherbar] == 0 then
					finalColor = colorFilter.threatBordersColor
				elseif adapt == otherbar then
					finalColor = otherBorders.color
				else
					finalColor = otherBorders.highlight.borders.infoPanelBorderColors
				end
			elseif weights[statusbar] == 0 then
				finalColor = colorFilter.threatBordersColor
			end
		end

		infoPanel.backdrop:SetBackdropBorderColor(unpack(finalColor))
		infoPanel.lastColor = finalColor
    end

    -- Handle ClassBar border
	if frame.CLASSBAR_SHOWN then
		local adapt = db.classBarBorderAdapt
        local classBar = frame[frame.ClassBar]
        local finalColor = E.media.unitframeBorderColor
		local weights = calculateAdaptWeight(appliedBorders.Health.override,
											power and appliedBorders.Power.override,
											adapt, threatBorders)

        --if highlight and highlight.borders.classBarBorderEnabled then
        if showBorders then
            if adapt ~= 'NONE' then
                local appliedBordersAdapt = appliedBorders[adapt]
                if appliedBordersAdapt.applied and weights[adapt] ~= 0 then
					finalColor = appliedBordersAdapt.color
				elseif adapt == statusbar then
					local otherbar = statusbar == 'Health' and 'Power' or 'Health'
					if appliedBorders[otherbar].applied and weights[otherbar] ~= 0 then
						finalColor = appliedBorders[otherbar].highlight.borders.classBarBorderColors
					else
						finalColor = colorFilter.threatBordersColor
					end
				elseif weights[statusbar] == 0 then
					finalColor = colorFilter.threatBordersColor
				else
                    finalColor = highlight.borders.classBarBorderColors
                end
            elseif weights[statusbar] == 0 then
				local otherbar = statusbar == 'Health' and 'Power' or 'Health'
				if appliedBorders[otherbar].applied and weights[otherbar] ~= 0 then
					finalColor = appliedBorders[otherbar].highlight.borders.classBarBorderColors
				else
					finalColor = colorFilter.threatBordersColor
				end
			else
                finalColor = highlight.borders.classBarBorderColors
            end
		else
			local otherbar = statusbar == 'Health' and 'Power' or 'Health'
			local otherBorders = appliedBorders[otherbar]
			if otherBorders.applied and otherBorders.highlight.borders.classBarBorderEnabled then
				if weights[otherbar] == 0 then
					finalColor = colorFilter.threatBordersColor
				elseif adapt == otherbar then
					finalColor = otherBorders.color
				else
					finalColor = otherBorders.highlight.borders.classBarBorderColors
				end
			elseif weights[statusbar] == 0 then
				finalColor = colorFilter.threatBordersColor
			end
        end

		if frame.ClassBar == 'Runes' then
			-- it's never colored with threat, though
			for _, rune in ipairs(frame.Runes) do
				rune.backdrop:SetBackdropBorderColor(unpack(finalColor))
			end
		else
			classBar.backdrop:SetBackdropBorderColor(unpack(finalColor))
		end
    end
end

function mod:UpdateMentions(bar)
	for _, mentionInfo in pairs(bar.mentions) do
		local frame, statusbar, unit =  _G[mentionInfo.frame], mentionInfo.statusbar, mentionInfo.unit
		local tabs, tabIndex = mentionInfo.tabs, mentionInfo.tabIndex
		local targetBar = frame.colorFilter[statusbar]
		if (bar.appliedColorTabIndex == tabIndex
		 or (bar.appliedColorTabIndex ~= tabIndex and targetBar.appliedColorTabIndex == tabIndex)
		  or not targetBar.appliedColorTabIndex) then
			self:ParseTabs(frame, statusbar, unit, tabs, nil, true)

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

function mod:UpdateThreat(unit, status)
	local frame = self:GetParent()

	if (frame.unit ~= unit) or not unit then return end

	local db = frame.db
	if not db then return end

	local colorFilter = frame.colorFilter
	if not colorFilter then return end

	local unitframeType, threatStyle = frame.unitframeType, db.threatStyle
	if threatStyle == 'BORDERS' or threatStyle == 'HEALTHBORDER' or threatStyle == 'INFOPANELBORDER' then
		if status then
			colorFilter.threatBordersColor = {1}
			colorFilter.threatBordersActive = threatStyle

			-- revert to the filter colors
			if threatStyle == 'INFOPANELBORDER' then
				if frame.USE_INFO_PANEL then
					for _, tabInfo in pairs(colorFilter.appliedBordersColors) do
						if tabInfo.applied then
							frame.InfoPanel.backdrop:SetBackdropBorderColor(unpack(frame.InfoPanel.lastColor))
							return
						end
					end
				end
				return
			else
				for statusbar, tabInfo in pairs(colorFilter.appliedBordersColors) do
					if tabInfo.override and statusbar ~= 'Castbar' then
						colorFilter.appliedBordersColors[statusbar].applied = false
						mod:UpdateBorders(frame, tabInfo.color, statusbar, unit, true, tabInfo.highlight)
					end
				end
			end
		else
			colorFilter.threatBordersActive = false
			-- roll parser again, cause the conditions have changed by the time threat goes down
			if metaTable.statusbars[unitframeType] then
				for statusbar, bar in pairs(metaTable.statusbars[unitframeType]) do
					local targetBar = colorFilter[statusbar]
					local parentBar = frame[statusbar]
					if parentBar and parentBar:IsShown() then
						mod:ParseTabs(frame, statusbar, unit, bar.tabs)

						if not targetBar.colorApplied then
							parentBar:ForceUpdate()
							local flashTexture = targetBar.flashTexture
							if flashTexture:IsShown() then
								flashTexture.anim:Stop()
								flashTexture:Hide()
							end
						end
					end
				end
			end
		end
	end
end


function mod:LoadConditions(frame, statusbar, unit, tab)
    local conditions = tab.conditions or tab
    conditions = conditions:gsub('@unit', "'"..unit.."'")

    -- check tabs state
    local tabsStateBlock = match(conditions, '@@%[.-%]@@')
    if tabsStateBlock then
        conditions = self:SortTabsState(frame, conditions, unit, statusbar)
    end

    local luaFunction, errorMsg = loadstring(conditions)
    if not luaFunction then
        core:print('LUA', L["Color Filter"], errorMsg)
        return
    end

    local success, result = pcall(luaFunction)
    if not success then
        core:print('FAIL', L["Color Filter"], result)
        return
    end

    local colors
    if type(result) == "table" then
        colors = result
    end

    return result, colors
end

function mod:ParseTabs(frame, statusbar, unit, tabs, isPostUpdate, skipMentions)
	local targetBar = frame.colorFilter[statusbar]
	for tabIndex, tab in ipairs(tabs) do
		-- if colored already, do not check tabs with lower priority
		if targetBar.appliedColorTabIndex and tabIndex > targetBar.appliedColorTabIndex then break end

		if tab.enabled then
			local result, colors = self:LoadConditions(frame, statusbar, unit, tab)
			if result then
				-- no retriggering please
				local flash = tab.flash
				local flashTexture = targetBar.flashTexture
				if flash.enabled and (not colors or colors.f ~= false) then
					local flashColors = flash.colors
					local r, g, b = flashColors[1], flashColors[2], flashColors[3]
					if colors then
						r, g, b = colors.fR and colors.fR or r, colors.fG and colors.fG or g, colors.fB and colors.fB or b
					end
					flashTexture:SetVertexColor(r, g, b)
					flashTexture:Show()

					local anim = flashTexture.anim
					local IsPlaying = anim and anim:IsPlaying()
					if (not anim or not IsPlaying) then
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
					if not colors or colors.m ~= false then
						frame[statusbar]:SetStatusBarColor(r, g, b)
					elseif not isPostUpdate then
						frame[statusbar]:ForceUpdate()
					end
				end

				-- store the current tab index
				targetBar.colorApplied = true
				targetBar.appliedColorTabIndex = tabIndex
				targetBar.lastUpdate = GetTime()

				local highlight = tab.highlight
				if highlight.glow.enabled then
					self:UpdateGlow(frame, colors, statusbar, unit, true, highlight)
				end
				if highlight.borders.enabled then
					self:UpdateBorders(frame, colors, statusbar, unit, true, highlight)
				end

				if not skipMentions and targetBar.mentions then
					self:UpdateMentions(targetBar)
				end
			elseif targetBar.appliedColorTabIndex and tabIndex == targetBar.appliedColorTabIndex then
				-- conditions from the tab currently coloring the bar are no longer true, revert
				targetBar.colorApplied = false
				targetBar.appliedColorTabIndex = nil

				local highlight = tab.highlight
				if highlight.glow.enabled then
					self:UpdateGlow(frame, nil, statusbar, unit, false)
				end
				if highlight.borders.enabled then
					self:UpdateBorders(frame, nil, statusbar, unit, false)
				end

				if not skipMentions and targetBar.mentions then
					self:UpdateMentions(targetBar)
				end
			end
		end
	end
	targetBar.lastUpdate = GetTime()
end


function mod:Configure_Castbar()
	-- updating ALL of it for the icon, hurray
	mod:InitAndUpdateColorFilter()
end

function mod:PostUpdateHealthColor()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not colorFilter then return end

	local unit = frame.unitframeType

	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Health and frame:IsShown() then
		mod:ParseTabs(frame, 'Health', frame.unit, unitInfo.Health.tabs, true)

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
		mod:ParseTabs(frame, 'Power', frame.unit, unitInfo.Power.tabs, true)

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

function mod:CastOnupdate()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	local unit = frame.unitframeType

	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Castbar and frame:IsShown() then
		mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs, true)

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
end

function mod:PostCastStart()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	local unit = frame.unitframeType

	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Castbar and frame:IsShown() then
		mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs, true)

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

function mod:PostCastStop()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	local unit = frame.unitframeType
	colorFilter = colorFilter.Castbar

	local unitInfo = metaTable.statusbars[unit]
	if unitInfo and unitInfo.Castbar then
		if colorFilter.mentions then
			colorFilter.appliedColorTabIndex = nil
			mod:UpdateMentions(colorFilter)
		end
	end
end

function mod:Construct_PowerBar(frame)
	mod:ConstructHighlight(frame)
end

function mod:Construct_Castbar(frame)
	mod:ConstructHighlight(frame)
end


function mod:InitAndUpdateColorFilter()
	if not updatePending then
		updatePending = true
		E_Delay(nil, 0.1, function()
			local db = E.db.Extras.unitframes[modName]

			self:SetupUnits()

			for _, unitsCluster in pairs(metaTable.units) do
				for _, frame in ipairs(unitsCluster) do
					self:ConstructHighlight(frame)
				end
			end

			for unit, unitsCluster in pairs(metaTable.units) do
				if not metaFrame[unit] then
					metaFrame[unit] = CreateFrame("Frame")
				end
				for _, frame in ipairs(unitsCluster) do
					for statusbar, bar in pairs(db.units[unit].statusbars) do
						local targetBar = frame.colorFilter[statusbar]
						local unitInfo = metaTable.statusbars[unit][statusbar]
						if bar.enabled and targetBar then
							if not unitInfo then
								metaTable.statusbars[unit][statusbar] = bar

								if find(bar.events, '%S+') then
									self:SortEvents(bar, statusbar, unit)
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
					for statusbar in pairs(metaTable.statusbars[unit]) do
						local tabs = metaTable.statusbars[unit][statusbar].tabs
						for i = 1, #tabs do
							local tab = tabs[i]
							if tab.enabled and find(tab.conditions, '%S+') then
								local tabsStateBlock = match(tab.conditions, '@@%[.-%]@@')

								if tabsStateBlock then
									self:SortMentions(db, frame, tab.conditions, unit, statusbar, i)
								end
							end
						end

						if InCombatLockdown() then
							local db = E.db.unitframe.units[frame.unitframeType]
							if db and (db.threatStyle == 'BORDERS' or db.threatStyle == 'HEALTHBORDER'
										or db.threatStyle == 'INFOPANELBORDER') then
								local colorFilter = frame.colorFilter
								colorFilter.threatBordersColor = {1}
								colorFilter.threatBordersActive = db.threatStyle
								frame[statusbar]:ForceUpdate()
							end
						end

						local eventsInfo = metaTable.events[unit]
						local unitInfo = metaTable.units[unit]
						if eventsInfo and not metaFrame[unit]:GetScript('OnEvent') then
							metaFrame[unit]:SetScript('OnEvent', function()
								for _, frame in ipairs(unitInfo) do
									if frame:IsShown() and (not frame.id
															or (frame.isForced
																or (GetNumPartyMembers() >= 1 or GetNumRaidMembers() >= 1))) then
										for statusbar in pairs(eventsInfo) do
											local frameBar = frame[statusbar]
											if frameBar:IsShown() then
												frameBar:ForceUpdate()
											end
										end
									end
								end
							end)
						end

						local barInfo = metaTable.statusbars[unit][statusbar]
						local targetBar = frame.colorFilter[statusbar]
						if barInfo and barInfo.frequentUpdates and statusbar ~= 'Castbar' then
							local updateThrottle = barInfo.updateThrottle or 0

							targetBar.lastUpdate = GetTime()
							targetBar:SetScript('OnUpdate', function(self)
								if GetTime() - self.lastUpdate < updateThrottle then return end

								for _, frame in ipairs(unitInfo) do
									if frame:IsShown() and (not frame.id
																or (frame.isForced
																	or (GetNumPartyMembers() >= 1 or GetNumRaidMembers() >= 1))) then
										local frameBar = frame[statusbar]
										if frameBar:IsShown() then
											frameBar:ForceUpdate()
										end
									end
								end
							end)
						end
					end
				end
			end
			updatePending = false
		end)
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
