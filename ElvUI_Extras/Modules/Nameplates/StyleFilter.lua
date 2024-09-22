local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("StyleFilter", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local activeFilters, links = {}, {}

local ipairs, pairs, next = ipairs, pairs, next
local tremove, twipe = table.remove, table.wipe
local format = string.format

local function shallowCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = v
    end
    return copy
end

P["Extras"]["nameplates"][modName] = {
	["enabled"] = false,
    ["links"] = {},
    ["selectedLink"] = 1,
}

function mod:LoadConfig()
	local db = E.db.Extras.nameplates[modName]
	local function selectedLink() return db.selectedLink end
	local function selectedLinkData()
		return core:getSelected("nameplates", modName, format("links[%s]", selectedLink() or ""), 1)
	end
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		args = {
			StyleFilter = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L["Linked Style Filter Triggers"],
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value self:Toggle(value) end,
					},
                    selectLink = {
                        order = 1,
                        type = 'select',
                        name = L["Select Link"],
						desc = "",
                        values = function()
                            local values = {}
                            for i, link in ipairs(db.links) do
                                values[i] = format("%s -> %s", link.target, link.apply)
                            end
                            return values
                        end,
                        get = function() return selectedLink() end,
                        set = function(_, value) db.selectedLink = value end,
						disabled = function() return not db.enabled or #db.links == 0 end,
                    },
				},
			},
			settings = {
				type = "group",
				guiInline = true,
				name = L["Settings"],
				get = function(info) return db[info[#info]] end,
				set = function(info, value) db[info[#info]] = value self:Toggle(true) end,
				disabled = function() return not db.enabled end,
				args = {
					newLink = {
						order = 1,
                        type = "execute",
						name = L["New Link"],
						desc = "",
						func = function()
							local id = #db.links + 1
							db.links[id] = {target = '', apply = ''}
							db.selectedLink = id
						end,
					},
                    deleteLink = {
                        order = 2,
                        type = "execute",
                        name = L["Delete Link"],
						desc = "",
                        func = function()
                            tremove(db.links, selectedLink())
                            db.selectedLink = 1
                            self:Toggle(true)
                        end,
						disabled = function() return not db.enabled or #db.links == 0 end,
                    },
                    targetFilter = {
                        order = 3,
                        type = "select",
                        name = L["Target Filter"],
						desc = L["Select a filter to trigger the styling."],
						values = function()
							local allFilters = core:GetUnitDropdownOptions(E.global.nameplates.filters)
							local usedTargets = {}
							for i, link in pairs(db.links) do
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
							if not db.links[selectedLink()] then
								db.selectedLink = #db.links
							end
							return db.links[selectedLink()] and db.links[selectedLink()].target or ""
						end,
                        set = function(_, value)
                            db.links[selectedLink()].target = value
                            self:Toggle(true)
                        end,
						hidden = function() return #db.links == 0 end,
                    },
                    applyFilter = {
                        order = 4,
                        type = "select",
                        name = L["Apply Filter"],
						desc = L["Select a filter to style the frames not passing the target filter triggers."],
						values = function()
							local allFilters = core:GetUnitDropdownOptions(E.global.nameplates.filters)
							local usedTargets = {}
							for _, link in pairs(db.links) do
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
							if not db.links[selectedLink()] then
								db.selectedLink = #db.links
							end
							return db.links[selectedLink()] and db.links[selectedLink()].apply or ""
						end,
                        set = function(_, value)
                            db.links[selectedLink()].apply = value
                            self:Toggle(true)
                        end,
						hidden = function() return #db.links == 0 end,
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

function mod:StyleFilterPass(self, frame, actions, pass)
    if pass then return end

	local filters = E.global.nameplates.filters

	for link in pairs(links) do
		if filters[link.target].actions == actions then
			local apply = link.apply

			frame.filteringOthers = frame.filteringOthers or {}
			frame.filteringOthers[apply] = link.target

			activeFilters[apply] = activeFilters[apply] or { count = 0, frames = {} }
			if not activeFilters[apply].frames[frame] then
				activeFilters[apply].frames[frame] = true
				activeFilters[apply].count = activeFilters[apply].count + 1
			end

			frame.trigger = frame.trigger or (activeFilters[apply].count == 1)
		end
	end
end

function mod:StyleFilterClear(self, frame, pass)
	if pass then return end

    if frame.filteringOthers then
        for apply in pairs(frame.filteringOthers) do
            if activeFilters[apply] and activeFilters[apply].frames[frame] then
                frame.filteringOthers[apply] = nil

                activeFilters[apply].frames[frame] = nil
                activeFilters[apply].count = activeFilters[apply].count - 1

				frame.untrigger = frame.untrigger or (activeFilters[apply].count == 0)
            end
        end

		if not next(frame.filteringOthers) then frame.filteringOthers = nil end
    end
end

function mod:StyleFilterUpdate(self, frame, event)
	if frame.OnShowHold then return end

	local filteringOthers, triggerState = frame.filteringOthers

	if filteringOthers then
		frame.StyleFilterWaitTime = nil
		triggerState = shallowCopy(filteringOthers)
	end

	mod.hooks[NP].StyleFilterUpdate(self, frame, event)

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

function mod:OnShow(self, isConfig, dontHideHighlight)
	local frame = self.UnitFrame

	frame.OnShowHold = true

	mod.hooks[NP].OnShow(self, isConfig, dontHideHighlight)

	frame.OnShowHold = false

	NP:StyleFilterUpdate(frame, "NAME_PLATE_UNIT_ADDED")
end

function mod:OnHide(self)
	local frame = self.UnitFrame

	if frame.untrigger or frame.trigger then
		recheckAllPlates()
		frame.untrigger = false
		frame.trigger = false
	end

	frame.filteringOthers = nil
end

function mod:Toggle(enable)
	twipe(links)
	twipe(activeFilters)

	for plate in pairs(NP.VisiblePlates) do
		plate.filteringOthers = nil
	end

    if enable then
		if not self:IsHooked(NP, 'OnShow') then self:RawHook(NP, 'OnShow') end
		if not self:IsHooked(NP, 'OnHide') then self:SecureHook(NP, 'OnHide') end
		if not self:IsHooked(NP, 'StyleFilterPass') then self:SecureHook(NP, 'StyleFilterPass') end
		if not self:IsHooked(NP, 'StyleFilterClear') then self:SecureHook(NP, 'StyleFilterClear') end
		if not self:IsHooked(NP, 'StyleFilterUpdate') then self:RawHook(NP, 'StyleFilterUpdate') end
		if not self:IsHooked(NP, 'StyleFilterConfigure') then self:RawHook(NP, 'StyleFilterConfigure', function()
				twipe(links)
				twipe(activeFilters)

				for i, link in ipairs(E.db.Extras.nameplates[modName].links) do
					if not E.global.nameplates.filters[link.target] or not E.global.nameplates.filters[link.apply] then
						tremove(E.db.Extras.nameplates[modName].links, i)
					elseif E.global.nameplates.filters[link.target].triggers and E.global.nameplates.filters[link.apply].actions then
						links[link] = true
					end
				end

				mod.hooks[NP].StyleFilterConfigure()
			end)
		end

		for _, link in pairs(E.db.Extras.nameplates[modName].links) do
			if E.global.nameplates.filters[link.target] and E.global.nameplates.filters[link.apply]
			 and E.global.nameplates.filters[link.target].triggers and E.global.nameplates.filters[link.apply].actions then
				links[link] = true
			end
		end
	else
		for _, func in pairs({'StyleFilterPass', 'StyleFilterClear', 'StyleFilterConfigure', 'OnShow', 'StyleFilterUpdate'}) do
			if self:IsHooked(NP, func) then self:Unhook(NP, func) end
		end
    end

	recheckAllPlates()
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	mod:LoadConfig()
	mod:Toggle(E.db.Extras.nameplates[modName].enabled)
end

core.modules[modName] = mod.InitializeCallback