local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ColorFilter", "AceHook-3.0", "AceEvent-3.0")
local UF = E:GetModule("UnitFrames")
local LSM = E.Libs.LSM

local modName = mod:GetName()
local metaFrame = CreateFrame("Frame")
local metaTable = { units = {}, statusbars = {}, events = {} }
local conditionsFuncs = {}

mod.metaTable = metaTable
mod.metaFrame = metaFrame
mod.updatePending = false
mod.initialized = false

local pairs, ipairs, tonumber, tostring, unpack, loadstring, type = pairs, ipairs, tonumber, tostring, unpack, loadstring, type
local find, gsub, match, gmatch, upper, lower, format = string.find, string.gsub, string.match, string.gmatch, string.upper, string.lower, string.format
local tinsert, twipe, tremove = table.insert, table.wipe, table.remove
local InCombatLockdown, GetTime, CopyTable = InCombatLockdown, GetTime, CopyTable


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
	colorFilter.flashTexture:SetAllPoints(bar)
	colorFilter.flashTexture:SetTexture(E.media.blankTex)
	colorFilter.flashTexture:Hide()

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

local function statusCheck(unit, statusbar, tabIndex)
	for _, frame in pairs(metaTable.units[unit] or {}) do
		if frame.colorFilter[statusbar].appliedColorTabIndex == tabIndex then
			return true
		end
	end
end

local function countCheck(unit, statusbar, tabIndex)
	local count = 0
	for _, frame in pairs(metaTable.units[unit] or {}) do
		if frame.colorFilter[statusbar].appliedColorTabIndex == tabIndex then
			count = count + 1
		end
	end
	return count
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
							["texture"] = "",
							["enableTexture"] = false,
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

function mod:LoadConfig(db)
	local customFrames = { ['tanktarget'] = 'target', ['assisttarget'] = 'target', ['partypet'] = 'pet', ['partytarget'] = 'target' }
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
	local function selectedUFData() return units[selectedUnit()] or {} end
	local function unitEnabled() return selectedUnitData().enabled end
	local function barEnabled() return selectedBarData().enabled end
	local function UFUnitEnabled()
		local custom = customFrames[selectedUnit()] or ""
		local data = selectedUFData()
		return not custom
				and (not data or data.enable)
				or (units[gsub(selectedUnit(), custom, '')] and units[gsub(selectedUnit(), custom,'')].enable)
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
						set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle(db) end,
					},
					enabledBar = {
						order = 2,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle for the currently selected statusbar."],
						disabled = function() return not unitEnabled() or not UFUnitEnabled() end,
						get = function() return selectedBarData().enabled end,
						set = function(_, value) selectedBarData().enabled = value self:Toggle(db) end,
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
						get = function(info) return selectedBarData()[info[#info]] end,
						set = function(info, value) selectedBarData()[info[#info]] = value self:Toggle(db) end,
						disabled = function()
							return greyed() or selectedBar() == 'Castbar' or match(selectedUnit(), '%w+target') or match(selectedUnit(), 'boss%d?$')
						end,
						hidden = function()
							return selectedBar() == 'Castbar' or match(selectedUnit(), '%w+target') or match(selectedUnit(), 'boss%d?$')
						end,
					},
					updateThrottle = {
						order = 6,
						type = "range",
						min = 0, max = 10, step = 0.1,
						name = L["Throttle Time"],
						desc = "",
						get = function(info) return selectedBarData()[info[#info]] end,
						set = function(info, value) selectedBarData()[info[#info]] = value self:Toggle(db) end,
						disabled = function()
							return greyed() or not selectedBarData().frequentUpdates or selectedBar() == 'Castbar'
									or match(selectedUnit(), '%w+target') or match(selectedUnit(), 'boss%d?$')
						end,
						hidden = function()
							return selectedBar() == 'Castbar' or match(selectedUnit(), '%w+target') or match(selectedUnit(), 'boss%d?$')
						end,
					},
					events = {
						order = 7,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Events (optional)"],
						desc = L["UNIT_AURA CHAT_MSG_WHISPER etc."],
						get = function() return selectedBarData().events or "" end,
						set = function(_, value) selectedBarData().events = value self:Toggle(db) end,
						disabled = function()
							return greyed() or selectedBar() == 'Castbar' or match(selectedUnit(), '%w+target') or match(selectedUnit(), 'boss%d?$')
						end,
						hidden = function()
							return selectedBar() == 'Castbar' or match(selectedUnit(), '%w+target') or match(selectedUnit(), 'boss%d?$')
						end,
					},
				},
			},
			tabSection = {
				order = 2,
				type = "group",
				name = L["Tab Section"],
				guiInline = true,
				get = function(info) return selectedTabData()[info[#info]] end,
				set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle(db) end,
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
							self:Toggle(db)
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
							self:Toggle(db)
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
				set = function(info, value) selectedTabData().flash[info[#info]] = value self:Toggle(db) end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "double",
						disabled = function() return greyed() end,
						name = core.pluginColor..L["Enable"],
						desc = "",
					},
					colors = {
						order = 2,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedTabData().flash.colors) end,
						set = function(_, r, g, b) selectedTabData().flash.colors = { r, g, b } self:Toggle(db) end,
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
				set = function(info, value) selectedTabData().highlight.glow[info[#info]] = value self:Toggle(db) end,
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
						set = function(_, value) selectedUnitData().glowPriority = value self:Toggle(db) end,
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
						set = function(_, r, g, b, a) selectedTabData().highlight.glow.colors = { r, g, b, a } self:Toggle(db) end,
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
						set = function(_, r, g, b, a) selectedTabData().highlight.glow.castbarIconColors = {r, g, b, a} self:Toggle(db) end,
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
				set = function(info, value) selectedTabData().highlight.borders[info[#info]] = value self:Toggle(db) end,
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
						set = function(_, r, g, b) selectedTabData().highlight.borders.colors = {r, g, b} self:Toggle(db) end,
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
						set = function(_, r, g, b) selectedTabData().highlight.borders.castbarIconColors = {r, g, b} self:Toggle(db) end,
						hidden = function() return selectedBar() ~= 'Castbar' or not selectedTabData().highlight.borders.enabled end,
						disabled = function() return greyed() or not selectedTabData().highlight.borders.castbarIcon end,
					},
					classBarBorderEnabled = {
						order = 4,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Toggle classbar borders."],
						hidden = function()
							return selectedBar() == 'Castbar' or customFrames[selectedUnit()]
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
							return selectedBar() == 'Castbar' or customFrames[selectedUnit()]
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
						set = function(_, r, g, b) selectedTabData().highlight.borders.classBarBorderColors = {r, g, b} self:Toggle(db) end,
						hidden = function()
							return selectedBar() == 'Castbar' or customFrames[selectedUnit()]
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
						set = function(_, r, g, b) selectedTabData().highlight.borders.infoPanelBorderColors = {r, g, b} self:Toggle(db) end,
						hidden = function()
							return selectedBar() == 'Castbar' or customFrames[selectedUnit()]
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
						desc = L["Copies the color of the selected bar."],
						get = function() return selectedUnitData().classBarBorderAdapt end,
						set = function(_, value) selectedUnitData().classBarBorderAdapt = value self:Toggle(db) end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["None"],
						},
						hidden = function()
							return selectedBar() == 'Castbar'
								or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable)
								or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed()
								or not (selectedUFData().classbar and selectedUFData().classbar.enable) end,
					},
					infoPanelBorderAdapt = {
						order = 8,
						type = "select",
						name = L["InfoPanel Adapt To"],
						desc = L["Copies the color of the selected bar."],
						get = function() return selectedUnitData().infoPanelBorderAdapt end,
						set = function(_, value) selectedUnitData().infoPanelBorderAdapt = value self:Toggle(db) end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["None"],
						},
						hidden = function()
							return selectedBar() == 'Castbar'
								or not (selectedUFData().infoPanel and selectedUFData().infoPanel.enable)
								or not selectedTabData().highlight.borders.enabled end,
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
							return selectedBar() == 'Castbar'
								or customFrames[selectedUnit()] or not selectedTabData().highlight.borders.enabled end,
					},
					bordersPriority = {
						order = 11,
						type = "select",
						name = L["Priority"],
						desc = L["Determines which borders to apply when statusbars are not detached from frame."],
						get = function() return selectedUnitData().bordersPriority end,
						set = function(_, value) selectedUnitData().bordersPriority = value self:Toggle(db) end,
						values = {
							["Health"] = L["Health"],
							["Power"] = L["Power"],
							["NONE"] = L["Bar-specific"],
						},
						hidden = function()
							return selectedBar() == 'Castbar'
								or customFrames[selectedUnit()] or not selectedTabData().highlight.borders.enabled end,
						disabled = function()
							return greyed()
								or find(selectedUnit(),'assist') or find(selectedUnit(),'tank')
								or (selectedUFData().power and selectedUFData().power.detachFromFrame) end,
					},
				},
			},
			colors = {
				order = 10,
				type = "group",
				name = L["Color"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle(db) end,
				disabled = function() return greyed() end,
				args = {
					enableColors = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function(info) return selectedTabData()[info[#info]] end,
						set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle(db) end,
					},
					colors = {
						order = 2,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function() return unpack(selectedTabData().colors) end,
						set = function(_, r, g, b) selectedTabData().colors = {r, g, b} self:Toggle(db) end,
						disabled = function() return greyed() or not selectedTabData().enableColors end,
					},
				},
			},
			texture = {
				order = 11,
				type = "group",
				name = L["Texture"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info]] = value self:Toggle(db) end,
				disabled = function() return greyed() end,
				args = {
					enableTexture = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function(info) return selectedTabData()[info[#info]] end,
						set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle(db) end,
					},
					texture = {
						order = 2,
						type = "select",
						name = L["Texture"],
						desc = "",
						dialogControl = "LSM30_Statusbar",
						get = function(info) return selectedTabData()[info[#info]] end,
						set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle(db) end,
						values = function() return AceGUIWidgetLSMlists.statusbar end,
						disabled = function() return greyed() or not selectedTabData().enableTexture end,
					},
				},
			},
			luaSection = {
				order = 12,
				type = "group",
				name = L["Lua Section"],
				guiInline = true,
				get = function(info) return selectedTabData()[info[#info]] or "" end,
				set = function(info, value) selectedTabData()[info[#info]] = value self:Toggle(db) end,
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
									self:UpdateAll(db)
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
						"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
						"\n    return true, {mR = r, mG = g, mB = b}"..
						"\nelseif UnitIsUnit(unit, 'target') then"..
						"\n    return true"..
						"\nend"..
						"\n\n@@[raid, Health, 2, >5]@@ - returns true/false based on whether the tab in question "..
						"(in the example above: 'player' - target unit; 'Power' - target statusbar; '3' - target tab) is active or not"..
						"\n(>/>=/<=/</~= num) - (optional, group units only) match against a particular count of triggered frames within the group "..
						"(more than 5 in the example above)"..
						"\n\n'return true, {bR=1,f=false}' - you can dynamically color the frames by returning the colors in a table format:"..
						"\n  to apply to the statusbar, assign your rgb values to mR, mG and mB respectively"..
						"\n  to apply the glow - to gR, gG, gB, gA (alpha)"..
						"\n  for borders - bR, bG, bB"..
						"\n  and for the flash - fR, fG, fB, fA"..
						"\n  to prevent the elements styling, return {m = false, g = false, b = false, f = false}"..
						"\n\nFrame and unitID are available at 'frame' and 'unit' respectively: UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
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


function mod:ConstructHighlight(frame)
	if not frame.colorFilter then
		local colorFilter = CreateFrame("Frame", nil, frame)
		colorFilter.appliedGlowColors = { Power = {applied = false}, Castbar = {applied = false} }
		colorFilter.appliedBordersColors = { Power = {applied = false, override = false}, Castbar = {applied = false} }

		colorFilter.Health = CreateFrame("Frame", nil, frame.Health)
		colorFilter.Health:CreateShadow(nil, true)
		colorFilter.Health:SetAllPoints(frame)

		colorFilter.Health.shadow:SetFrameLevel(colorFilter.Health:GetFrameLevel()+15)

		colorFilter.appliedGlowColors.Health = { applied = false }
		colorFilter.appliedBordersColors.Health = { applied = false, override = false }

		constructAnimation(frame.Health, colorFilter.Health)

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

		constructAnimation(power, colorFilter.Power)

		colorFilter.Power.shadow:Hide()
	end

	if frame.Castbar and not frame.colorFilter.Castbar then
		local colorFilter = frame.colorFilter
		local castbar = frame.Castbar
		colorFilter.Castbar = CreateFrame("Frame", nil, castbar)
		colorFilter.Castbar:CreateShadow(nil, true)
		colorFilter.Castbar:SetAllPoints(castbar)

		colorFilter.Castbar.shadow:SetFrameLevel(colorFilter.Castbar:GetFrameLevel()+15)

		constructAnimation(castbar, colorFilter.Castbar)

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

function mod:SortMentions(conditions, mentionedByUnit, statusbarToUpd, targetTabIndex)
	for tabsStateCondition in gmatch(conditions, '@@%[(.-)%]@@') do
		local _, endPos, unit, statusbar, tabIndex = find(tabsStateCondition, '([^,%s]+),%s*([^,%s]+),%s*([%d]+)')
		local _, _, operator, triggerCount = find(tabsStateCondition, ',%s*([~=<>]*)%s*([%d]+)', endPos)

		if unit and statusbar and tabIndex then
			unit = lower(unit)
			statusbar = gsub(statusbar, "(%a)([%w_']*)", function(first, rest)
				return upper(first) .. lower(rest)
			end)
			tabIndex = tonumber(tabIndex)

			for _, mentionedFrame in pairs(metaTable.units[unit] or {}) do
				mentionedFrame.colorFilter[statusbar].mentions = mentionedFrame.colorFilter[statusbar].mentions or {}

				for _, f in pairs(metaTable.units[mentionedByUnit] or {}) do
					mentionedFrame.colorFilter[statusbar].mentions[f:GetName()..statusbarToUpd] = {
						frame = f,
						statusbar = statusbarToUpd,
						unit = mentionedByUnit,
						tabIndex = tabIndex,
						targetTabIndex = targetTabIndex,
					}
				end
			end
			conditions = gsub(conditions, '@@%[.-%]@@',
								triggerCount and format('(countCheck("%s", "%s", %d) %s %d)', unit, statusbar, tabIndex, operator, triggerCount)
												or format('statusCheck("%s", "%s", %d)', unit, statusbar, tabIndex), 1)
		else
			core:print('FORMATTING', L["Color Filter"])
			return
		end
	end
	return conditions
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
			else
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
			elseif statusbar == 'Power' and not appliedGlowColors.Health.applied then
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
                frame.Castbar.ButtonIcon.bg:SetBackdropBorderColor(r, g, b)
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
			local otherbar = statusbar == 'Health' and 'Power' or 'Health'
			local otherBorders = appliedBorders[otherbar]

			if otherBorders and not otherBorders.applied then
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
			elseif weights[otherbar] then
				if weights[statusbar] > weights[otherbar] then
					if power then
						power.backdrop:SetBackdropBorderColor(r, g, b)
					end
					if weights[statusbar] == 1 then
						health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
					else
						health.backdrop:SetBackdropBorderColor(r, g, b)
					end
				elseif weights[statusbar] < weights[otherbar] then
					if weights[statusbar] == 1 then
						if power then
							if db.bordersPriority == statusbar then
								power.backdrop:SetBackdropBorderColor(r, g, b)
							else
								power.backdrop:SetBackdropBorderColor(unpack(otherBorders.color))
							end
						end
						health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
					else
						if power then
							power.backdrop:SetBackdropBorderColor(unpack(otherBorders.color))
						end
						health.backdrop:SetBackdropBorderColor(unpack(otherBorders.color))
					end
				elseif weights[statusbar] == 0 then
					if power then
						power.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
					end
					health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
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
				frame.Castbar.ButtonIcon.bg:SetBackdropBorderColor(r, g, b)
			end
		else
			local weights = calculateWeight(appliedBorders.Health.override,
											power and appliedBorders.Power.override,
											db.bordersPriority, threatBorders)

			if not detached and db.bordersPriority ~= 'NONE' then
				local otherbar = statusbar == 'Health' and 'Power' or 'Health'
				local otherBorders = appliedBorders[otherbar]

				if otherBorders and otherBorders.applied then
					if weights[otherbar] < 2 then
						if power then
							if weights[otherbar] == 1 then
								power.backdrop:SetBackdropBorderColor(unpack(otherBorders.color))
							else
								power.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
							end
						end
						health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
					else
						if power then
							power.backdrop:SetBackdropBorderColor(unpack(otherBorders.color))
						end
						if weights[statusbar] == 1 and not appliedBorders.Power.override then
							health.backdrop:SetBackdropBorderColor(unpack(colorFilter.threatBordersColor))
						else
							health.backdrop:SetBackdropBorderColor(unpack(otherBorders.color))
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

        if showBorders and appliedBorders[statusbar].highlight.borders.infoPanelBorderEnabled then
			if adapt ~= 'NONE' then
				local appliedBordersAdapt = appliedBorders[adapt]

				if appliedBordersAdapt.applied and weights[adapt] ~= 0 then
					finalColor = appliedBordersAdapt.color
				elseif adapt == statusbar then
					local otherbar = statusbar == 'Health' and 'Power' or 'Health'
					local otherBorders = appliedBorders[otherbar]
					if otherBorders and otherBorders.applied and weights[otherbar] ~= 0 then
						finalColor = otherBorders.highlight.borders.infoPanelBorderColors
					elseif weights[statusbar] == 0 then
						finalColor = colorFilter.threatBordersColor
					end
				elseif weights[statusbar] == 0 then
					finalColor = colorFilter.threatBordersColor
				else
					finalColor = highlight.borders.infoPanelBorderColors
				end
            elseif weights[statusbar] == 0 then
				local otherbar = statusbar == 'Health' and 'Power' or 'Health'
				local otherBorders = appliedBorders[otherbar]
				if otherBorders and otherBorders.applied and weights[otherbar] ~= 0 then
					finalColor = otherBorders.highlight.borders.infoPanelBorderColors
				else
					finalColor = colorFilter.threatBordersColor
				end
			else
				finalColor = highlight.borders.infoPanelBorderColors
            end
		else
			local otherbar = statusbar == 'Health' and 'Power' or 'Health'
			local otherBorders = appliedBorders[otherbar]
			if otherBorders and otherBorders.applied and otherBorders.highlight.borders.infoPanelBorderEnabled then
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

        if showBorders and appliedBorders[statusbar].highlight.borders.classBarBorderEnabled then
            if adapt ~= 'NONE' then
                local appliedBordersAdapt = appliedBorders[adapt]
                if appliedBordersAdapt.applied and weights[adapt] ~= 0 then
					finalColor = appliedBordersAdapt.color
				elseif adapt == statusbar then
					local otherbar = statusbar == 'Health' and 'Power' or 'Health'
					local otherBorders = appliedBorders[otherbar]
					if otherBorders and otherBorders.applied and weights[otherbar] ~= 0 then
						finalColor = otherBorders.highlight.borders.classBarBorderColors
					elseif weights[statusbar] == 0 then
						finalColor = colorFilter.threatBordersColor
					end
				elseif weights[statusbar] == 0 then
					finalColor = colorFilter.threatBordersColor
				else
                    finalColor = highlight.borders.classBarBorderColors
                end
            elseif weights[statusbar] == 0 then
				local otherbar = statusbar == 'Health' and 'Power' or 'Health'
				local otherBorders = appliedBorders[otherbar]
				if otherBorders and otherBorders.applied and weights[otherbar] ~= 0 then
					finalColor = otherBorders.highlight.borders.classBarBorderColors
				else
					finalColor = colorFilter.threatBordersColor
				end
			else
                finalColor = highlight.borders.classBarBorderColors
            end
		else
			local otherbar = statusbar == 'Health' and 'Power' or 'Health'
			local otherBorders = appliedBorders[otherbar]
			if otherBorders and otherBorders.applied and otherBorders.highlight.borders.classBarBorderEnabled then
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
	for _, info in pairs(bar.mentions) do
		local frame, statusbar, tabIndex, targetTabIndex = info.frame, info.statusbar, info.tabIndex, info.targetTabIndex
		local targetBar = frame.colorFilter[statusbar]

		if (bar.appliedColorTabIndex == tabIndex and targetBar.appliedColorTabIndex ~= targetTabIndex)
									or (bar.appliedColorTabIndex ~= tabIndex and targetBar.appliedColorTabIndex == targetTabIndex) then
			frame[statusbar]:ForceUpdate()
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
						mod:UpdateBorders(frame, tabInfo.color, statusbar, unitframeType, true, tabInfo.highlight)
					end
				end
			end
		else
			colorFilter.threatBordersActive = false
			-- roll parser again, cause the conditions have changed by the time threat goes down
			if metaTable.statusbars[unitframeType] then
				for statusbar in pairs(metaTable.statusbars[unitframeType]) do
					local parentBar = frame[statusbar]
					if parentBar then
						parentBar:ForceUpdate()
					end
				end
			end
		end
	end
end


function mod:ParseTabs(frame, statusbar, unit, tabs)
	local targetBar = frame.colorFilter[statusbar]

	for tabIndex, tab in ipairs(tabs) do
		-- if colored already, do not check tabs with lower priority
		if targetBar.appliedColorTabIndex and tabIndex > targetBar.appliedColorTabIndex then break end

		local result, colors = conditionsFuncs[tab](frame, unit, statusCheck, countCheck)
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
				anim.fadein:SetDuration(flash.speed)
				anim.fadeout:SetDuration(flash.speed)
				anim:Play()
			else
				flashTexture.anim:Stop()
				flashTexture:Hide()
			end

			local tabColors = tab.colors
			local r, g, b = tabColors[1], tabColors[2], tabColors[3]

			if colors then
				r, g, b = colors.mR and colors.mR or r, colors.mG and colors.mG or g, colors.mB and colors.mB or b
			end

			if tab.enableColors and (not colors or colors.m ~= false) then
				frame[statusbar]:SetStatusBarColor(r, g, b)
			end

			if tab.enableTexture then
				if not colors then
					frame[statusbar]:SetStatusBarTexture(tab.fetchedTexture)
				elseif colors.mT then
					frame[statusbar]:SetStatusBarTexture(colors.mT)
				end
			end

			-- store the current tab index
			targetBar.colorApplied = true
			targetBar.appliedColorTabIndex = tabIndex
			targetBar.lastUpdate = GetTime()

			local highlight = tab.highlight
			if highlight.glow.enabled then
				self:UpdateGlow(frame, colors, statusbar, frame.unitframeType, true, highlight)
			end
			if highlight.borders.enabled then
				self:UpdateBorders(frame, colors, statusbar, frame.unitframeType, true, highlight)
			end

			if targetBar.mentions then
				self:UpdateMentions(targetBar)
			end
		elseif targetBar.appliedColorTabIndex and tabIndex == targetBar.appliedColorTabIndex then
			-- conditions from the tab currently coloring the bar are no longer true, revert
			targetBar.colorApplied = false
			targetBar.appliedColorTabIndex = nil

			local highlight = tab.highlight
			if highlight.glow.enabled then
				self:UpdateGlow(frame, nil, statusbar, frame.unitframeType, false)
			end
			if highlight.borders.enabled then
				self:UpdateBorders(frame, nil, statusbar, frame.unitframeType, false)
			end

			if targetBar.mentions then
				self:UpdateMentions(targetBar)
			end

			if tab.enableTexture then
				frame[statusbar]:SetStatusBarTexture(LSM:Fetch("statusbar", UF.db.statusbar))
			end

			local flashTexture = targetBar.flashTexture
			flashTexture.anim:Stop()
			flashTexture:Hide()
		end
	end
	targetBar.lastUpdate = GetTime()
end


function mod:PostUpdateHealthColor()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not colorFilter then return end

	local unitInfo = metaTable.statusbars[frame.unitframeType]
	if unitInfo and unitInfo.Health then
		mod:ParseTabs(frame, 'Health', frame.unit, unitInfo.Health.tabs)
	end
end

function mod:PostUpdatePowerColor()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Power) then return end

	local unitInfo = metaTable.statusbars[(self.origParent or frame).unitframeType]
	if unitInfo and unitInfo.Power then
		mod:ParseTabs(frame, 'Power', frame.unit, unitInfo.Power.tabs)
	end
end

function mod:CastOnupdate()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	local unitInfo = metaTable.statusbars[frame.unitframeType]
	if unitInfo and unitInfo.Castbar then
		mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs)
	end
end

function mod:PostCastStart()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	local unitInfo = metaTable.statusbars[frame.unitframeType]
	if unitInfo and unitInfo.Castbar then
		mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs)
	end
end

function mod:PostCastStop()
	local frame = self:GetParent()
	local colorFilter = frame.colorFilter
	if not (colorFilter and colorFilter.Castbar) then return end

	local unitInfo = metaTable.statusbars[frame.unitframeType]
	if unitInfo and unitInfo.Castbar then
		colorFilter = colorFilter.Castbar
		if colorFilter.mentions then
			mod:ParseTabs(frame, 'Castbar', frame.unit, unitInfo.Castbar.tabs)
		end
	end
end

function mod:Construct_PowerBar(frame)
	mod:ConstructHighlight(frame)
end

function mod:Construct_Castbar(frame)
	mod:ConstructHighlight(frame)
end

function mod:UpdateAll(db)
	-- shutdown the highlights
	for unit, unitsCluster in pairs(metaTable.units) do
		for _, frame in pairs(unitsCluster) do
			if frame.colorFilter then
				local colorFilter = frame.colorFilter
				for statusbar in pairs(metaTable.statusbars[unit]) do
					self:UpdateGlow(frame, nil, statusbar, unit, false)
					self:UpdateBorders(frame, nil, statusbar, unit, false)
					local targetBar = colorFilter[statusbar]
					if targetBar.flashTexture then
						targetBar.flashTexture:Hide()
						targetBar.flashTexture = nil
					end
					targetBar:SetScript('OnUpdate', nil)
					if metaTable.events[unit] then
						metaFrame[unit]:UnregisterAllEvents()
						metaFrame[unit]:SetScript('OnEvent', nil)
					end
					if frame[statusbar] then
						updateHooks(frame, false, statusbar)
						frame[statusbar]:ForceUpdate()
						frame[statusbar]:SetStatusBarTexture(LSM:Fetch("statusbar", UF.db.statusbar))
					end
				end
				for k, v in pairs(frame.colorFilter) do
					if type(v) == 'table' and v.Hide then
						v:Hide()
						frame.colorFilter[k] = nil
					end
				end
				frame.colorFilter:Hide()
				frame.colorFilter = nil
			end
		end
	end
	twipe(metaTable.units)
	twipe(metaTable.events)
	twipe(metaTable.statusbars)
	twipe(conditionsFuncs)

	if core.reload then return end

	local enabled = {frames = {}, tabs = {}}

	for _, frame in ipairs(core:AggregateUnitFrames()) do
		local unit = frame.unitframeType
		if db.units[unit].enabled then
			if not metaTable.units[unit] then
				metaTable.units[unit] = {}
				metaTable.events[unit] = {}
				metaTable.statusbars[unit] = {}
				metaFrame[unit] = metaFrame[unit] or CreateFrame("Frame")
			end
			tinsert(metaTable.units[unit], frame)

			self:ConstructHighlight(frame)

			for statusbar, bar in pairs(db.units[unit].statusbars) do
				local targetBar = frame.colorFilter[statusbar]
				if targetBar and bar.enabled then
					enabled[statusbar] = true

					local barInfo = metaTable.statusbars[unit][statusbar]
					if not barInfo then
						metaTable.statusbars[unit][statusbar] = CopyTable(bar)
						barInfo = metaTable.statusbars[unit][statusbar]

						local unitInfo = metaTable.units[unit]
						if find(bar.events, '%S+') then
							tinsert(metaTable.events[unit], statusbar)
							for event in gmatch(bar.events, "[%u_]+") do
								metaFrame[unit]:RegisterEvent(event)
							end
							local eventsInfo = metaTable.events[unit]
							if not metaFrame[unit]:GetScript('OnEvent') then
								metaFrame[unit]:SetScript('OnEvent', function()
									for _, frame in ipairs(unitInfo) do
										for _, statusbar in ipairs(eventsInfo) do
											frame[statusbar]:ForceUpdate()
										end
									end
								end)
							end
						end
						if barInfo.frequentUpdates and statusbar ~= 'Castbar' then
							local updateThrottle = barInfo.updateThrottle or 0
							targetBar.lastUpdate = GetTime()
							targetBar:SetScript('OnUpdate', function(self)
								if GetTime() - self.lastUpdate < updateThrottle then return end

								for _, frame in ipairs(unitInfo) do
									frame[statusbar]:ForceUpdate()
								end
							end)
						end
						for i = #metaTable.statusbars[unit][statusbar].tabs, 1, -1 do
							local tab = metaTable.statusbars[unit][statusbar].tabs[i]
							if tab.enabled and find(tab.conditions, '%S+') then
								tinsert(enabled.tabs, {
									tab = tab,
									unit = unit,
									statusbar = statusbar,
									targetTabIndex = i,
								})
							else
								tremove(metaTable.statusbars[unit][statusbar].tabs, i)
							end
						end
						if InCombatLockdown() then
							local db = E.db.unitframe.units[frame.unitframeType]
							if db and (db.threatStyle == 'BORDERS' or db.threatStyle == 'HEALTHBORDER'
										or db.threatStyle == 'INFOPANELBORDER') then
								local colorFilter = frame.colorFilter
								colorFilter.threatBordersColor = {1}
								colorFilter.threatBordersActive = db.threatStyle
							end
						end
					end
				end
				if frame[statusbar] then
                    tinsert(enabled.frames, {
                        frame = frame,
                        statusbar = statusbar,
                    })
				end
			end
		end
	end
	for _, data in ipairs(enabled.tabs) do
		local tab, unit, statusbar, targetTabIndex = data.tab, data.unit, data.statusbar, data.targetTabIndex
		local conditions = self:SortMentions(tab.conditions, unit, statusbar, targetTabIndex)
		if conditions then
			local luaFunction, errorMsg = loadstring(format([[
				local frame, unit, statusCheck, countCheck = ...
				%s
			]], conditions))
			if not luaFunction then
				core:print('LUA', L["Color Filter"], errorMsg)
				conditionsFuncs[tab] = function() return end
			else
				conditionsFuncs[tab] = luaFunction
			end
			tab.fetchedTexture = LSM:Fetch("statusbar", tab.texture)
		else
			return
		end
	end
    for _, info in ipairs(enabled.frames) do
        local frame = info.frame
        local statusbar = info.statusbar
		updateHooks(frame, enabled[statusbar], statusbar)
		frame[statusbar]:ForceUpdate()
    end
end


function mod:Toggle(db)
	local enable
	if not core.reload then
		for _, info in pairs(db.units) do
			if info.enabled then enable = true break end
		end
	end
	if enable then
		for _, func in ipairs({'Construct_Castbar', 'Construct_PowerBar', 'UpdateThreat'}) do
			if not self:IsHooked(UF, func) then self:SecureHook(UF, func, self[func]) end
		end
		core:Tag("colorfilter", nil, function()
			if not self.updatePending then
				self.updatePending = E:ScheduleTimer(function() self:UpdateAll(db) self.updatePending = false end, 0.1)
			else
				E:CancelTimer(self.updatePending)
				self.updatePending = E:ScheduleTimer(function() self:UpdateAll(db) self.updatePending = false end, 0.1)
			end
		end)
		self.initialized = true
	elseif self.initialized then
		for _, func in ipairs({'Construct_Castbar', 'Construct_PowerBar', 'UpdateThreat'}) do
			if self:IsHooked(UF, func) then self:Unhook(UF, func) end
		end
		core:Untag("colorfilter")
	end

	self:UpdateAll(db)
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback