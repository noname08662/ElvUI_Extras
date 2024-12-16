local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("StyleFilter", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local activeFilters, links = {}, {}

mod.initialized = false

local ipairs, pairs, next, unpack, loadstring = ipairs, pairs, next, unpack, loadstring
local tremove, twipe = table.remove, table.wipe
local format, find = string.format, string.find
local max = math.max

local E_UIFrameFadeIn, E_UIFrameFadeOut = E.UIFrameFadeIn, E.UIFrameFadeOut

local function shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

local function updateAllIcons(db, enabled)
	if enabled then
		for filterName, iconData in pairs(db.StyleFilterIcons.iconsData) do
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				local icons = frame.styleIcons
				if icons then
					local icon = icons[filterName]
					if not icon then
						icons[filterName] = CreateFrame("Frame", nil, frame)
						icon = icons[filterName]
						if iconData.backdrop then
							icon:CreateBackdrop('Transparent')
						end
						icon.tex = icon:CreateTexture(nil, "ARTWORK")
						icon.tex:SetAllPoints()
						icon.tex:SetTexCoord(unpack(E.TexCoords))
						mod:SecureHook(icon, "SetAlpha", function(f, alpha) if alpha == 0 then f:Hide() end end)
					end
					icon:ClearAllPoints()
					icon:Size(iconData.size)
					icon:Point(iconData.point, frame.Health:IsShown() and frame.Health or frame.Name, iconData.relativeTo,
								iconData.xOffset, iconData.yOffset)
					icon:SetFrameLevel(max(1,frame:GetFrameLevel() + iconData.level))
					icon.tex:SetTexture(iconData.tex)
					icon.level = iconData.level
					icon.point = iconData.point
					icon.relativeTo = iconData.relativeTo
					icon.xOffset = iconData.xOffset
					icon.yOffset = iconData.yOffset
					if icon.backdrop then
						if not iconData.backdrop then
							icon.backdrop:Hide()
						else
							icon.backdrop:Show()
						end
					elseif iconData.backdrop then
						icon:CreateBackdrop('Transparent')
					end
				end
			end
		end
	else
		for plate in pairs(NP.CreatedPlates) do
			local frame = plate.UnitFrame
			local icons = frame.styleIcons
			if icons then
				for filterName, icon in pairs(icons) do
					icon:Hide()
					icons[filterName] = nil
				end
			end
		end
	end
end


P["Extras"]["nameplates"][modName] = {
	["StyleFilterLinks"] = {
		["enabled"] = false,
		["links"] = {},
		["selectedLink"] = 1,
	},
	["StyleFilterIcons"] = {
		["enabled"] = false,
		["selectedForIcon"] = "",
		["iconsData"] = {},
	},
	["StyleFilterTriggers"] = {
		["enabled"] = false,
		["selected"] = "",
		["filtersData"] = {},
	},
}

function mod:LoadConfig(db)
	local function selectedLink() return db.StyleFilterLinks.selectedLink end
	local function selectedForIcon() return db.StyleFilterIcons.selectedForIcon end
	local function selected() return db.StyleFilterTriggers.selected end
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			StyleFilterLinks = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L["Linked Style Filter Triggers"],
				get = function(info) return db.StyleFilterLinks[info[#info]] end,
				set = function(info, value) db.StyleFilterLinks[info[#info]] = value self:Toggle(db) end,
				disabled = function() return not db.StyleFilterLinks.enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function(info) return db.StyleFilterLinks[info[#info]] end,
						set = function(info, value) db.StyleFilterLinks[info[#info]] = value self:Toggle(db) end,
						disabled = false,
					},
                    selectLink = {
                        order = 1,
                        type = "select",
                        name = L["Select Link"],
						desc = "",
                        values = function()
                            local values = {}
                            for i, link in ipairs(db.StyleFilterLinks.links) do
                                values[i] = format("%s -> %s", link.target, link.apply)
                            end
                            return values
                        end,
                        get = function() return selectedLink() end,
                        set = function(_, value) db.StyleFilterLinks.selectedLink = value end,
						disabled = function() return not db.StyleFilterLinks.enabled or #db.StyleFilterLinks.links == 0 end,
                    },
					newLink = {
						order = 3,
                        type = "execute",
						name = L["New Link"],
						desc = "",
						func = function()
							local id = #db.StyleFilterLinks.links + 1
							db.StyleFilterLinks.links[id] = {target = '', apply = ''}
							db.StyleFilterLinks.selectedLink = id
						end,
					},
                    deleteLink = {
                        order = 4,
                        type = "execute",
                        name = L["Delete Link"],
						desc = "",
                        func = function()
                            tremove(db.StyleFilterLinks.links, selectedLink())
                            db.StyleFilterLinks.selectedLink = 1
                            self:Toggle(db)
                        end,
						disabled = function() return not db.StyleFilterLinks.enabled or #db.StyleFilterLinks.links == 0 end,
                    },
                    targetFilter = {
                        order = 5,
                        type = "select",
                        name = L["Target Filter"],
						desc = L["Select a filter to trigger the styling."],
						values = function()
							local allFilters = core:GetUnitDropdownOptions(E.global.nameplates.filters)
							local usedTargets = {}
							for i, link in pairs(db.StyleFilterLinks.links) do
								if i ~= selectedLink() then
									usedTargets[link.target] = true
								end
								usedTargets[link.apply] = true
							end
							local availableFilters = {}
							for filterName, filterValue in pairs(allFilters) do
								if not usedTargets[filterName] then
									availableFilters[filterName] = filterValue
								end
							end
							return availableFilters
						end,
                        get = function()
							if not db.StyleFilterLinks.links[selectedLink()] then
								db.StyleFilterLinks.selectedLink = #db.StyleFilterLinks.links
							end
							return db.StyleFilterLinks.links[selectedLink()] and db.StyleFilterLinks.links[selectedLink()].target or ""
						end,
                        set = function(_, value)
                            db.StyleFilterLinks.links[selectedLink()].target = value
                            self:Toggle(db)
                        end,
						hidden = function() return #db.StyleFilterLinks.links == 0 end,
                    },
                    applyFilter = {
                        order = 6,
                        type = "select",
                        name = L["Apply Filter"],
						desc = L["Select a filter to style the frames not passing the target filter triggers."],
						values = function()
							local allFilters = core:GetUnitDropdownOptions(E.global.nameplates.filters)
							local usedTargets = {}
							for _, link in pairs(db.StyleFilterLinks.links) do
								usedTargets[link.target] = true
							end
							local availableFilters = {}
							for filterName, filterValue in pairs(allFilters) do
								if not usedTargets[filterName] then
									availableFilters[filterName] = filterValue
								end
							end
							return availableFilters
						end,
                        get = function()
							if not db.StyleFilterLinks.links[selectedLink()] then
								db.StyleFilterLinks.selectedLink = #db.StyleFilterLinks.links
							end
							return db.StyleFilterLinks.links[selectedLink()] and db.StyleFilterLinks.links[selectedLink()].apply or ""
						end,
                        set = function(_, value)
                            db.StyleFilterLinks.links[selectedLink()].apply = value
                            self:Toggle(db)
                        end,
						hidden = function() return #db.StyleFilterLinks.links == 0 end,
                    },
				},
			},
			StyleFilterIcons = {
				order = 2,
				type = "group",
				guiInline = true,
				name = L["Style Filter Icons"],
				desc = L["Custom icons for the style filter."],
				get = function(info)
					local data = db.StyleFilterIcons.iconsData[selectedForIcon()]
					return data and data[info[#info]]
				end,
				set = function(info, value)
					local data = db.StyleFilterIcons.iconsData[selectedForIcon()]
					if data then
						data[info[#info]] = value
						updateAllIcons(db, true)
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function(info) return db.StyleFilterIcons[info[#info]] end,
						set = function(info, value) db.StyleFilterIcons[info[#info]] = value self:Toggle(db) end,
					},
                    selectedForIcon = {
                        order = 2,
                        type = "select",
                        name = L["Target Filter"],
						desc = L["Select a filter to trigger the styling."],
						values = function()
							local list = {}
							for filterName in pairs(core:GetUnitDropdownOptions(E.global.nameplates.filters)) do
								list[filterName] = filterName
							end
							return list
						end,
                        get = function(info) return db.StyleFilterIcons[info[#info]] end,
                        set = function(info, value) db.StyleFilterIcons[info[#info]] = value end,
						disabled = function() return not db.StyleFilterIcons.enabled end,
                    },
					createIcon = {
						order = 3,
                        type = "execute",
						name = L["Create Icon"],
						desc = "",
						func = function()
							db.StyleFilterIcons.iconsData[selectedForIcon()] = {
								tex = "Interface\\Icons\\INV_Misc_QuestionMark",
								size = 30, level = 15,
								point = "BOTTOM", relativeTo = "TOP",
								xOffset = 0, yOffset = 45,
							}
                            self:Toggle(db)
						end,
						disabled = function()
							return not E.global.nameplates.filters[selectedForIcon()]
									or db.StyleFilterIcons.iconsData[selectedForIcon()] end,
						hidden = function() return not db.StyleFilterIcons.enabled end,
					},
                    deleteIcon = {
                        order = 4,
                        type = "execute",
                        name = L["Delete Icon"],
						desc = "",
                        func = function()
                            db.StyleFilterIcons.iconsData[selectedForIcon()] = false
							db.StyleFilterIcons.selectedForIcon = ""
                            self:Toggle(db)
                        end,
						disabled = function()
							return not (E.global.nameplates.filters[selectedForIcon()]
									and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
						hidden = function() return not db.StyleFilterIcons.enabled end,
                    },
					backdrop = {
						order = 5,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					tex = {
						order = 6,
						type = "input",
						name = L["Texture"],
						desc = L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"],
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					point = {
						order = 7,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					relativeTo = {
						order = 8,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					size = {
						order = 9,
						type = "range",
						name = L["Size"],
						desc = "",
						min = 4, max = 48, step = 1,
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					xOffset = {
						order = 10,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1,
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					yOffset = {
						order = 11,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1,
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
					level = {
						order = 12,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -5, max = 50, step = 1,
						hidden = function() return not (db.StyleFilterIcons.enabled and db.StyleFilterIcons.iconsData[selectedForIcon()]) end,
					},
				},
			},
			StyleFilterTriggers = {
				order = 3,
				type = "group",
				guiInline = true,
				name = L["Style Filter Additional Triggers"],
				desc = "",
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function(info) return db.StyleFilterTriggers[info[#info]] end,
						set = function(info, value) db.StyleFilterTriggers[info[#info]] = value self:Toggle(db) end,
					},
                    selected = {
                        order = 2,
                        type = "select",
                        name = L["Target Filter"],
						desc = L["Select a filter to trigger the styling."],
						values = function()
							local list = {}
							for filterName in pairs(core:GetUnitDropdownOptions(E.global.nameplates.filters)) do
								list[filterName] = filterName
							end
							return list
						end,
                        get = function(info) return db.StyleFilterTriggers[info[#info]] end,
                        set = function(info, value)
							db.StyleFilterTriggers[info[#info]] = value
							if not db.StyleFilterTriggers.filtersData[selected()] then
								db.StyleFilterTriggers.filtersData[selected()] = {}
							end
						end,
						disabled = function() return not db.StyleFilterTriggers.enabled end,
                    },
					openEditFrame = {
						order = 3,
						type = "execute",
						width = "double",
						name = L["Open Edit Frame"],
						desc = "",
						func = function()
							local data = db.StyleFilterTriggers.filtersData[selected()]
							core:OpenEditor(L[modName],
											data.triggersString or "",
											function() data.triggersString = core.EditFrame.editBox:GetText() self:Toggle(db) end)
						end,
						disabled = function() return not E.global.nameplates.filters[selected()] end,
						hidden = function() return not db.StyleFilterTriggers.enabled end,
					},
					triggersString = {
						order = 4,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Triggers"],
						desc = L["Example usage:"..
								"\n local frame, filter, trigger = ..."..
								"\n return frame.UnitName == 'Shrek'"..
								"\n         or (frame.unit"..
								"\n             and UnitName(frame.unit) == 'Fiona')"],
						get = function(info)
							local data = db.StyleFilterTriggers.filtersData[selected()]
							return data and data[info[#info]]
						end,
						set = function(info, value)
							local data = db.StyleFilterTriggers.filtersData[selected()]
							if data then
								data[info[#info]] = value
								self:Toggle(db)
								for plate in pairs(NP.VisiblePlates) do
									NP:StyleFilterClear(plate)

									for filterNum in ipairs(NP.StyleFilterTriggerList) do
										local filter = E.global.nameplates.filters[NP.StyleFilterTriggerList[filterNum][1]]
										if filter then
											NP:StyleFilterConditionCheck(plate, filter, filter.triggers)
										end
									end
								end
							end
						end,
						disabled = function() return not E.global.nameplates.filters[selected()] end,
						hidden = function() return not db.StyleFilterTriggers.enabled end,
					},
				},
			},
		},
	}
end


local function recheckAllPlates()
	local filters = E.global.nameplates.filters
	local StyleFilterTriggerList = NP.StyleFilterTriggerList
	local VisiblePlates = NP.VisiblePlates

	for plate in pairs(VisiblePlates) do
		NP:StyleFilterClear(plate, true)

		for filterNum in ipairs(StyleFilterTriggerList) do
			local filter = filters[StyleFilterTriggerList[filterNum][1]]

			if filter then
				NP:StyleFilterConditionCheck(plate, filter, filter.triggers)
			end
		end
	end

	for plate in pairs(VisiblePlates) do
		for apply, info in pairs(activeFilters) do
			if info.count > 0 and not info.frames[plate] then
				NP:StyleFilterPass(plate, filters[apply].actions, true)
			end
		end
	end
end


function mod:StyleFilterPassLinks(frame, actions, pass)
    if pass then return end

	local filters = E.global.nameplates.filters

	for target, info in pairs(links) do
		if filters[target].actions == actions then
			local apply = info.apply

			frame.filteringOthers = frame.filteringOthers or {}
			frame.filteringOthers[apply] = target

			activeFilters[apply] = activeFilters[apply] or { count = 0, frames = {} }
			if not activeFilters[apply].frames[frame] then
				activeFilters[apply].frames[frame] = true
				activeFilters[apply].count = activeFilters[apply].count + 1
			end

			frame.trigger = frame.trigger or (activeFilters[apply].count == 1)
		end
	end
end

function mod:StyleFilterPassIcons(frame, actions)
	local filters = E.global.nameplates.filters

	for target, info in pairs(links) do
		if filters[target].actions == actions then
			local icon = frame.styleIcons[target]
			if info.iconData.backdrop then
				local color = actions.color.border and actions.color.borderColor
				if color then
					icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
				else
					icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
				end
			end
			icon:Show()
			E_UIFrameFadeIn(nil, icon, 0.1, icon:GetAlpha(), 1)
		end
	end
end

function mod:StyleFilterPass(_, frame, actions, pass)
	local filters = E.global.nameplates.filters
    if pass then
		for target, info in pairs(links) do
			local iconData = info.iconData
			if iconData and filters[target].actions == actions then
				local icon = frame.styleIcons[target]
				if iconData.backdrop then
					local color = actions.color.border and actions.color.borderColor
					if color then
						icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
					else
						icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
					end
				end
				icon:Show()
				E_UIFrameFadeIn(nil, icon, 0.1, icon:GetAlpha(), 1)
			end
		end
	else
		for target, info in pairs(links) do
			if filters[target].actions == actions then
				if info.link then
					local apply = info.apply

					frame.filteringOthers = frame.filteringOthers or {}
					frame.filteringOthers[apply] = target

					activeFilters[apply] = activeFilters[apply] or { count = 0, frames = {} }
					if not activeFilters[apply].frames[frame] then
						activeFilters[apply].frames[frame] = true
						activeFilters[apply].count = activeFilters[apply].count + 1
					end

					frame.trigger = frame.trigger or (activeFilters[apply].count == 1)
				end
				local iconData = info.iconData
				if iconData then
					local icon = frame.styleIcons[target]
					if iconData.backdrop then
						local color = actions.color.border and actions.color.borderColor
						if color then
							icon.backdrop:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
						else
							icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor))
						end
					end
					icon:Show()
					E_UIFrameFadeIn(nil, icon, 0.1, icon:GetAlpha(), 1)
				end
			end
		end
	end
end


function mod:StyleFilterClearLinks(frame, pass)
	if pass then return end

    if frame.filteringOthers then
        for apply in pairs(frame.filteringOthers) do
			local applyFilter = activeFilters[apply]
			if applyFilter and applyFilter.frames[frame] then
				frame.filteringOthers[apply] = nil

				applyFilter.frames[frame] = nil
				applyFilter.count = applyFilter.count - 1

				frame.untrigger = frame.untrigger or (applyFilter.count == 0)
			end
        end
		if not next(frame.filteringOthers) then frame.filteringOthers = nil end
    end
end

function mod:StyleFilterClearIcons(frame)
	for _, icon in pairs(frame.styleIcons or {}) do
		if icon:IsShown() then
			E_UIFrameFadeOut(nil, icon, 0.1, icon:GetAlpha(), 0)
		end
	end
end

function mod:StyleFilterClear(_, frame, pass)
	if not pass then
		if frame.filteringOthers then
			for apply in pairs(frame.filteringOthers) do
				local applyFilter = activeFilters[apply]
				if applyFilter and applyFilter.frames[frame] then
					frame.filteringOthers[apply] = nil

					applyFilter.frames[frame] = nil
					applyFilter.count = applyFilter.count - 1

					frame.untrigger = frame.untrigger or (applyFilter.count == 0)
				end
			end
			if not next(frame.filteringOthers) then frame.filteringOthers = nil end
		end
	end
	for _, icon in pairs(frame.styleIcons or {}) do
		if icon:IsShown() then
			E_UIFrameFadeOut(nil, icon, 0.1, icon:GetAlpha(), 0)
		end
	end
end


function mod:StyleFilterUpdate(self, frame, ...)
	if frame.OnShowHold then return end

	local filteringOthers, triggerState = frame.filteringOthers

	if filteringOthers then
		frame.StyleFilterWaitTime = nil
		triggerState = shallowCopy(filteringOthers)
	end

	mod.hooks[NP].StyleFilterUpdate(self, frame, ...)

	if frame.trigger or frame.untrigger then
		local changed

		if not (triggerState and frame.trigger) or (triggerState and not frame.filteringOthers) then
			changed = true
		else
			for apply, target in pairs(frame.filteringOthers) do
				if triggerState[apply] ~= target then
					changed = true
					break
				end
			end

			for apply in pairs(triggerState) do
				if not frame.filteringOthers[apply] then
					changed = true
					break
				end
			end
		end

		if changed then
			frame.trigger = false
			frame.untrigger = false
			recheckAllPlates()
		end
	end
	local filters = E.global.nameplates.filters

	for apply, info in pairs(activeFilters) do
		if info.count > 0 and not info.frames[frame] then
			NP:StyleFilterPass(frame, filters[apply].actions, true)
		end
	end
end


function mod:Construct_HealthBar(_, frame)
	frame.styleIcons = {}
	local icons = frame.styleIcons
	for filterName, info in pairs(links) do
		local iconData = info.iconData
		if iconData then
			icons[filterName] = CreateFrame("Frame", nil, frame)
			local icon = icons[filterName]
			if iconData.backdrop then
				icon:CreateBackdrop('Transparent')
			end
			icon:Hide()
			icon:Size(iconData.size)
			icon.tex = icon:CreateTexture(nil, "ARTWORK")
			icon.tex:SetTexture(iconData.tex)
			icon.tex:SetAllPoints()
			icon.tex:SetTexCoord(unpack(E.TexCoords))
			icon.level = iconData.level
			icon.point = iconData.point
			icon.relativeTo = iconData.relativeTo
			icon.xOffset = iconData.xOffset
			icon.yOffset = iconData.yOffset
			mod:SecureHook(icon, "SetAlpha", function(f, alpha) if alpha == 0 then f:Hide() end end)
		end
	end
end


function mod:OnShowLinks(self, ...)
	local frame = self.UnitFrame

	frame.OnShowHold = true

	mod.hooks[NP].OnShow(self, ...)

	frame.OnShowHold = false

	NP:StyleFilterUpdate(frame, "NAME_PLATE_UNIT_ADDED")
end

function mod:OnShowIcons()
	local frame = self.UnitFrame
	for _, icon in pairs(frame.styleIcons or {}) do
		icon:ClearAllPoints()
		icon:Point(icon.point, frame.Health:IsShown() and frame.Health or frame.Name, icon.relativeTo, icon.xOffset, icon.yOffset)
	end
end

function mod:OnShow(self, ...)
	local frame = self.UnitFrame

	frame.OnShowHold = true

	mod.hooks[NP].OnShow(self, ...)

	frame.OnShowHold = false

	NP:StyleFilterUpdate(frame, "NAME_PLATE_UNIT_ADDED")

	for _, icon in pairs(frame.styleIcons or {}) do
		icon:ClearAllPoints()
		icon:Point(icon.point, frame.Health:IsShown() and frame.Health or frame.Name, icon.relativeTo, icon.xOffset, icon.yOffset)
	end
end

function mod:OnHide(self)
	local frame = self.UnitFrame

	if frame.untrigger or frame.trigger then
		recheckAllPlates()
		frame.untrigger = false
		frame.trigger = false
	end

	frame.filteringOthers = nil

	for _, icon in pairs(frame.styleIcons or {}) do
		icon:Hide()
		icon:SetAlpha(0)
	end
end


function mod:Toggle(db)
	twipe(links)
	twipe(activeFilters)

	for plate in pairs(NP.VisiblePlates) do
		plate.filteringOthers = nil
	end

	local linksEnabled, iconsEnabled, triggersEnabled = db.StyleFilterLinks.enabled, db.StyleFilterIcons.enabled, db.StyleFilterTriggers.enabled
    if not core.reload and (linksEnabled or iconsEnabled or triggersEnabled) then
		local filters = E.global.nameplates.filters

		if self:IsHooked(NP, 'StyleFilterPass') then self:Unhook(NP, 'StyleFilterPass') end
		if self:IsHooked(NP, 'StyleFilterClear') then self:Unhook(NP, 'StyleFilterClear') end
		if self:IsHooked(NP, 'OnShow') then self:Unhook(NP, 'OnShow') end
		if not self:IsHooked(NP, 'StyleFilterConfigure') then self:RawHook(NP, 'StyleFilterConfigure', function()
				twipe(links)
				twipe(activeFilters)

				filters = E.global.nameplates.filters

				if db.StyleFilterLinks.enabled then
					for i = #db.StyleFilterLinks.links, 1, -1 do
						local link = db.StyleFilterLinks.links[i]
						if link then
							local target, apply = link.target, link.apply
							if not filters[target] or not filters[apply] then
								tremove(db.StyleFilterLinks.links, i)
							elseif filters[target].triggers and filters[apply].actions then
								links[target] = { link = link, apply = apply }
							end
						end
					end
				end
				if db.StyleFilterIcons.enabled then
					local removed = {}

					for filterName, iconData in pairs(db.StyleFilterIcons.iconsData) do
						if not filters[filterName] then
							removed[filterName] = false
							for plate in pairs(NP.CreatedPlates) do
								local frame = plate.UnitFrame
								local icons = frame.styleIcons
								if icons and icons[filterName] then
									icons[filterName]:Hide()
									icons[filterName] = nil
								end
							end
						else
							removed[filterName] = iconData
							for plate in pairs(NP.CreatedPlates) do
								local frame = plate.UnitFrame
								local icons = frame.styleIcons
								if not icons then
									frame.styleIcons = {}
									icons = frame.styleIcons
								end
								local icon = icons[filterName]
								if not icon then
									icons[filterName] = CreateFrame("Frame", nil, frame)
									icon = icons[filterName]
									if iconData.backdrop then
										icon:CreateBackdrop('Transparent')
									end
									icon:Size(iconData.size)
									icon:SetFrameLevel(max(1,frame:GetFrameLevel() + iconData.level))
									icon.tex = icon:CreateTexture(nil, "ARTWORK")
									icon.tex:SetTexture(iconData.tex)
									icon.tex:SetTexCoord(unpack(E.TexCoords))
									icon.tex:SetAllPoints()
									icon.level = iconData.level
									icon.point = iconData.point
									icon.relativeTo = iconData.relativeTo
									icon.xOffset = iconData.xOffset
									icon.yOffset = iconData.yOffset
									mod:SecureHook(icon, "SetAlpha", function(f, alpha) if alpha == 0 then f:Hide() end end)
								end
								icon:Hide()
							end
						end
					end
					for filterName, iconData in pairs(removed) do
						if not iconData then
							db.StyleFilterIcons.iconsData[filterName] = nil
							if links[filterName] and not links[filterName].link then
								links[filterName] = nil
							end
						elseif not links[filterName] then
							links[filterName] = { iconData = iconData }
						else
							links[filterName].iconData = iconData
						end
					end
				end
				if db.StyleFilterTriggers.enabled then
					for filterName in pairs(db.StyleFilterTriggers.filtersData) do
						if not filters[filterName] then
							db.StyleFilterTriggers.filtersData[filterName] = nil
							NP.StyleFilterCustomChecks[filterName.."_Extras"] = nil
						end
					end
				end
				return mod.hooks[NP].StyleFilterConfigure()
			end)
		end
		if triggersEnabled then
			NP.StyleFilterCustomChecks = NP.StyleFilterCustomChecks or {}
			for filterName, info in pairs(db.StyleFilterTriggers.filtersData) do
				if find(info.triggersString or "", "%S+") then
					local luaFunction = loadstring(info.triggersString)
					if luaFunction then
						NP.StyleFilterCustomChecks[filterName.."_Extras"] = luaFunction
					else
						NP.StyleFilterCustomChecks[filterName.."_Extras"] = nil
						core:print('LUA', L[modName], L["The generated custom looting method did not return a function."])
					end
				else
					NP.StyleFilterCustomChecks[filterName.."_Extras"] = nil
				end
			end
		elseif NP.StyleFilterCustomChecks then
			for filterName in pairs(db.StyleFilterTriggers.filtersData) do
				NP.StyleFilterCustomChecks[filterName.."_Extras"] = nil
			end
		end
		if linksEnabled then
			for _, link in pairs(db.StyleFilterLinks.links) do
				local target, apply = link.target, link.apply
				if filters[target] and filters[apply]
				 and filters[target].triggers and filters[apply].actions then
					links[target] = { link = link, apply = apply }
				end
			end
			if not self:IsHooked(NP, 'OnHide') then self:SecureHook(NP, 'OnHide') end
			if not self:IsHooked(NP, 'StyleFilterUpdate') then self:RawHook(NP, 'StyleFilterUpdate') end
			if iconsEnabled then
				self:SecureHook(NP, 'StyleFilterPass')
				self:SecureHook(NP, 'StyleFilterClear')
				self:RawHook(NP, 'OnShow')
			else
				self:SecureHook(NP, 'StyleFilterPass', self.StyleFilterPassLinks)
				self:SecureHook(NP, 'StyleFilterClear', self.StyleFilterClearLinks)
				self:RawHook(NP, 'OnShow', function(...) self:OnShowLinks(...) end)
			end
		end
		if iconsEnabled then
			local removed = {}
			for filterName, iconData in pairs(db.StyleFilterIcons.iconsData) do
				if not iconData then
					removed[filterName] = false
					for plate in pairs(NP.CreatedPlates) do
						local frame = plate.UnitFrame
						local icons = frame.styleIcons
						if icons and icons[filterName] then
							icons[filterName]:Hide()
							icons[filterName] = nil
						end
					end
				else
					removed[filterName] = iconData
					for plate in pairs(NP.CreatedPlates) do
						local frame = plate.UnitFrame
						local icons = frame.styleIcons
						if not icons then
							frame.styleIcons = {}
							icons = frame.styleIcons
						end
						local icon = icons[filterName]
						if not icon then
							icons[filterName] = CreateFrame("Frame", nil, frame)
							icon = icons[filterName]
							if iconData.backdrop then
								icon:CreateBackdrop('Transparent')
							end
							icon:Size(iconData.size)
							icon:SetFrameLevel(max(1,frame:GetFrameLevel() + iconData.level))
							icon.tex = icon:CreateTexture(nil, "ARTWORK")
							icon.tex:SetTexture(iconData.tex)
							icon.tex:SetAllPoints()
							icon.tex:SetTexCoord(unpack(E.TexCoords))
							mod:SecureHook(icon, "SetAlpha", function(f, alpha) if alpha == 0 then f:Hide() end end)
						end
						icon.level = iconData.level
						icon.point = iconData.point
						icon.relativeTo = iconData.relativeTo
						icon.xOffset = iconData.xOffset
						icon.yOffset = iconData.yOffset
						icon:Hide()
					end
				end
			end
			for filterName, iconData in pairs(removed) do
				if not iconData then
					db.StyleFilterIcons.iconsData[filterName] = nil
					if links[filterName] and not links[filterName].link then
						links[filterName] = nil
					end
				elseif not links[filterName] then
					links[filterName] = { iconData = iconData }
				else
					links[filterName].iconData = iconData
				end
			end
			if not self:IsHooked(NP, 'Construct_HealthBar') then self:SecureHook(NP, 'Construct_HealthBar') end
			if not self:IsHooked(NP, 'ResetNameplateFrameLevel') then self:SecureHook(NP, 'ResetNameplateFrameLevel', function(self, frame)
					if frame.styleIcons then
						for _, icon in pairs(frame.styleIcons) do
							icon:SetFrameLevel(max(1,frame:GetFrameLevel() + icon.level))
						end
					end
				end)
			end
			if not linksEnabled then
				self:SecureHook(NP, 'StyleFilterPass', self.StyleFilterPassIcons)
				self:SecureHook(NP, 'StyleFilterClear', self.StyleFilterClearIcons)
				self:SecureHook(NP, 'OnShow', self.OnShowIcons)
			end
			core:RegisterNPElement('styleIcons', function(_, frame, element)
				for _, icon in pairs(frame.styleIcons or {}) do
					icon:ClearAllPoints()
					icon:Point(icon.point, element, icon.relativeTo, icon.xOffset, icon.yOffset)
				end
			end)
			updateAllIcons(db, true)
		else
			core:RegisterNPElement('styleIcons')
			updateAllIcons(db, false)
		end
		recheckAllPlates()
		self.initialized = true
	elseif self.initialized then
		for _, func in pairs({'StyleFilterPass', 'StyleFilterClear', 'StyleFilterConfigure',
								'OnShow', 'StyleFilterUpdate', 'Construct_HealthBar', 'ResetNameplateFrameLevel'}) do
			if self:IsHooked(NP, func) then self:Unhook(NP, func) end
		end
		if NP.StyleFilterCustomChecks then
			for filterName in pairs(db.StyleFilterTriggers.filtersData) do
				NP.StyleFilterCustomChecks[filterName.."_Extras"] = nil
			end
		end
		updateAllIcons(db, false)
		recheckAllPlates()
    end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback