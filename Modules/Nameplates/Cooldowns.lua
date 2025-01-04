local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("CooldownsNP2", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI

local modName = mod:GetName()
local activeCooldowns, petSpells, testing = {}, {}, false
local highlightedSpells = {["ENEMY_PLAYER"] = {}, ["FRIENDLY_PLAYER"] = {}}
local edgeFile = LSM:Fetch("border", "ElvUI GlowBorder")
local isAwesome = C_NamePlate

local band = bit.band
local _G, pairs, ipairs, select, unpack, tonumber, next = _G, pairs, ipairs, select, unpack, tonumber, next
local gsub, upper, match, find, format = string.gsub, string.upper, string.match, string.find, string.format
local random, floor, min, ceil, abs = math.random, math.floor, math.min, math.ceil, math.abs
local tinsert, tremove, tsort, twipe = table.insert, table.remove, table.sort, table.wipe
local GetSpellInfo, GetSpellLink, GetTime = GetSpellInfo, GetSpellLink, GetTime
local UnitIsPlayer, UnitExists, UnitName = UnitIsPlayer, UnitExists, UnitName
local COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER
local UNITNAME_SUMMON_TITLES = {gsub(format(UNITNAME_SUMMON_TITLE1, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE3, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE5, 1), '[%d%p%s]+', '')}

mod.initialized = false
mod.iconPositions = {["FRIENDLY_PLAYER"] = {}, ["ENEMY_PLAYER"] = {}}

local allSpells = {}
local compareFuncs = {}
local borderCustomColor = {}
local borderColor = {}
local fills = {}

local iconPositions = mod.iconPositions
local scanTool = CreateFrame("GameTooltip", "ScanTooltipNP", nil, "GameTooltipTemplate")
scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")

local function updateVisibilityState(db, areaType)
	local isShown = false
	for _, unitType in ipairs({'ENEMY_PLAYER', 'FRIENDLY_PLAYER'}) do
		local data = db[unitType]
		if data.enabled then
			isShown = isShown or data['showAll'] or data[areaType]
			data.isShown = data['showAll'] or data[areaType]
		else
			data.isShown = false
		end
	end
	return isShown
end

local function getPetOwner(unit)
	scanTool:ClearLines()
	scanTool:SetUnit(unit)
	local scanText = _G["ScanTooltipNPTextLeft2"]
	local ownerText = scanText:GetText()
	if ownerText then
		for _, string in ipairs(UNITNAME_SUMMON_TITLES) do
			if find(ownerText, string) then
				return gsub(ownerText, string..'[%s]+', '')
			end
		end
	end
end


local trinkets = {
	[42292] = true,
	[59752] = true,
}

local oppositeDirections = {
    ["TOP"] = "BOTTOM",
    ["BOTTOM"] = "TOP",
    ["LEFT"] = "RIGHT",
    ["RIGHT"] = "LEFT",
    ["TOPLEFT"] = "BOTTOMRIGHT",
    ["TOPRIGHT"] = "BOTTOMLEFT",
    ["BOTTOMLEFT"] = "TOPRIGHT",
    ["BOTTOMRIGHT"] = "TOPLEFT",
}

local directionProperties = {
    ["TOP"] = {isCentered = true, isVertical = false, isReverseY = true, isReverseX = false},
    ["BOTTOM"] = {isCentered = true, isVertical = false, isReverseY = false, isReverseX = false},
    ["LEFT"] = {isCentered = true, isVertical = true, isReverseY = false, isReverseX = false},
    ["RIGHT"] = {isCentered = true, isVertical = true, isReverseY = false, isReverseX = true},
    ["TOPLEFT"] = {isCentered = false, isVertical = true, isReverseY = true, isReverseX = false},
    ["TOPRIGHT"] = {isCentered = false, isVertical = true, isReverseY = true, isReverseX = true},
    ["BOTTOMLEFT"] = {isCentered = false, isVertical = true, isReverseY = false, isReverseX = false},
    ["BOTTOMRIGHT"] = {isCentered = false, isVertical = true, isReverseY = false, isReverseX = true}
}

local fallbackSpells = {
    [47875] = 8,    -- Death Coil
    [47540] = 12,   -- Penance
    [48181] = 8,    -- Haunt
    [47860] = 10,   -- Shadowflame
    [49222] = 20,   -- Bone Shield
    [49005] = 15,   -- Mark of Blood
    [57934] = 30,   -- Tricks of the Trade
    [57933] = 30,   -- Tricks of the Trade (talent proc)
    [55342] = 180,  -- Mirror Image
    [53271] = 60    -- Master's Call
}

local resetCooldowns = {
    [11958] = {	[12472] = true, [42931] = true, [45438] = true,
				[42917] = true, [31687] = true, [44572] = true,
				[11426] = true, [43012] = true,						}, -- Coldsnap
    [23989] = {	[19503] = true, [19263] = true, [781]	= true,
				[60192] = true, [14311] = true, [13809] = true,
				[34600] = true, [34490] = true,	[19386] = true,
				[53271] = true, [19577] = true						}, -- Readiness
    [14185] = {	[26669] = true, [11305] = true, [26889] = true,
				[14177] = true, [36554] = true,						}, -- Preparation
}


local function testMode(db)
	local data = db[db.selectedType]
	if not data.isShown then return end

	twipe(activeCooldowns)
	for plate in pairs(NP.VisiblePlates) do
		if plate.CDTracker then plate.CDTracker:Hide() end
	end
	if not testing then return end

    local spellList = data.spellList
    local testSpells = {}

	if not next(spellList) then
        for id, duration in pairs(fallbackSpells) do
            spellList[id] = duration
        end
    end

    for spellID, duration in pairs(spellList) do
        local startTime = GetTime() - random(0, duration/2)
        tinsert(testSpells, {
						spellID = spellID,
						startTime = startTime,
						endTime = startTime + duration,
						icon = select(3, GetSpellInfo(spellID)),
						isTrinket = trinkets[spellID]
					})
    end

	tinsert(testSpells, {
					spellID = 59752,
					startTime = GetTime() - random(0, 120/2),
					endTime = GetTime() - random(0, 120/2) + 120,
					icon = select(3, GetSpellInfo(59752)),
					isTrinket = true,
				})

	for plate in pairs(NP.VisiblePlates) do
		local unitType = plate.UnitType
		if unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
			activeCooldowns[plate.UnitName] = testSpells
			mod:AttachCooldownsToPlate(db[unitType], plate, activeCooldowns[plate.UnitName], unitType)
		end
	end
end


local function createCompareFunction(sorting, prioritizeTrinkets)
    if prioritizeTrinkets then
        if sorting == "durationAsc" then
            return function(a, b)
                if a.isTrinket and not b.isTrinket then
                    return true
                elseif not a.isTrinket and b.isTrinket then
                    return false
                end
                return a.endTime < b.endTime
            end
        elseif sorting == "durationDesc" then
            return function(a, b)
                if a.isTrinket and not b.isTrinket then
                    return true
                elseif not a.isTrinket and b.isTrinket then
                    return false
                end
                return a.endTime > b.endTime
            end
        elseif sorting == "timeUsedDesc" then
            return function(a, b)
                if a.isTrinket and not b.isTrinket then
                    return true
                elseif not a.isTrinket and b.isTrinket then
                    return false
                end
                return a.startTime > b.startTime
            end
        else
            return function(a, b)
                if a.isTrinket and not b.isTrinket then
                    return true
                elseif not a.isTrinket and b.isTrinket then
                    return false
                end
                return a.startTime < b.startTime
            end
        end
    else
        if sorting == "durationAsc" then
            return function(a, b)
                return a.endTime < b.endTime
            end
        elseif sorting == "durationDesc" then
            return function(a, b)
                return a.endTime > b.endTime
            end
        elseif sorting == "timeUsedDesc" then
            return function(a, b)
                return a.startTime > b.startTime
            end
        else
            return function(a, b)
                return a.startTime < b.startTime
            end
        end
    end
end

local function createFillFunction(db_cooldownFill, db_icons)
    local border = E.mult or 0
	local size = db_icons.size
    local isReversed = db_cooldownFill.reversed
    local direction = db_cooldownFill.direction

    if direction == "LEFT" then
        if isReversed then
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:Point("TOPLEFT", cooldown, "TOPLEFT", border, -border)
                fill:Point("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", (remainingTime * size) - size - border, border)
            end
        else
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:Point("TOPRIGHT", cooldown, "TOPRIGHT", -border, -border)
                fill:Point("BOTTOMLEFT", cooldown, "BOTTOMLEFT", (remainingTime * size) + border, border)
            end
        end
    elseif direction == "RIGHT" then
        if isReversed then
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:Point("TOPRIGHT", cooldown, "TOPRIGHT", -border, -border)
                fill:Point("BOTTOMLEFT", cooldown, "BOTTOMLEFT", size - (remainingTime * size) + border, border)
            end
        else
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:Point("TOPLEFT", cooldown, "TOPLEFT", border, -border)
                fill:Point("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", -(remainingTime * size) - border, border)
            end
        end
    elseif direction == "TOP" then
        if isReversed then
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:SetPoint("TOPLEFT", cooldown, "TOPLEFT", border, -border)
                fill:SetPoint("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", -border, (remainingTime * size) - border)
            end
        else
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:Point("BOTTOMLEFT", cooldown, "BOTTOMLEFT", border, border)
                fill:Point("TOPRIGHT", cooldown, "TOPRIGHT", -border, -(remainingTime * size) - border)
            end
        end
    else
        if isReversed then
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:SetPoint("BOTTOMLEFT", cooldown, "BOTTOMLEFT", border, border)
                fill:SetPoint("TOPRIGHT", cooldown, "TOPRIGHT", -border, -(size - (remainingTime * size)) + border)
            end
        else
            return function(cooldown, remainingTime)
                local fill = cooldown.fill
                fill:ClearAllPoints()
                fill:Point("TOPLEFT", cooldown, "TOPLEFT", border, -border)
                fill:Point("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", -border, (remainingTime * size))
            end
        end
    end
end


local function getColorByTimeFriend(_, remainingTime, totalTime)
    local percentage = remainingTime / totalTime
    return percentage, 1 - percentage
end

local function getColorByTimeEnemy(_, remainingTime, totalTime)
    local percentage = remainingTime / totalTime
    return 1 - percentage, percentage
end


local function cache(db, visibilityUpdate)
	twipe(allSpells)
	if not visibilityUpdate then
		twipe(petSpells)
		for spellID in pairs(db.petSpells) do
			petSpells[spellID] = true
		end
	end
    for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
		local type_db = db[unitType]

		if type_db.enabled and type_db.isShown then
			for id, cdTime in pairs(type_db.spellList) do
				allSpells[id] = cdTime
			end

			if not visibilityUpdate then
				twipe(highlightedSpells[unitType])
				for spellID, info in pairs(type_db.highlightedSpells) do
					highlightedSpells[unitType][spellID] = info
				end

				local icons = type_db.icons
				local perRow, spacing, direction, size = icons.perRow, icons.spacing, icons.direction, icons.size
				local offset = size + spacing
				local point = oppositeDirections[direction]
				local dirProps = directionProperties[direction]
				local isCentered, isVertical, isReverseX, isReverseY = dirProps.isCentered, dirProps.isVertical, dirProps.isReverseX, dirProps.isReverseY

				twipe(iconPositions[unitType])

				for shown = 1, icons.maxRows * perRow do
					local numRows = ceil(shown / perRow)
					local numCols = min(shown, perRow)
					local trackerWidth = isVertical and (numRows * offset - spacing) or (numCols * offset - spacing)
					local trackerHeight = isVertical and (numCols * offset - spacing) or (numRows * offset - spacing)

					iconPositions[unitType][shown] = {
						positions = {},
						trackerWidth = trackerWidth,
						trackerHeight = trackerHeight
					}

					for i = 1, shown do
						local row = floor((i - 1) / perRow)
						local col = (i - 1) % perRow

						local xOffset, yOffset
						if isCentered then
							local itemsInThisRow = min(perRow, shown - row * perRow)
							local rowSize = itemsInThisRow * size + (itemsInThisRow - 1) * spacing
							if isVertical then
								yOffset = -rowSize / 2 + col * offset + size / 2
								xOffset = isReverseX and (row * offset) or (-row * offset)
							else
								xOffset = -rowSize / 2 + col * offset + size / 2
								yOffset = isReverseY and (row * offset) or (-row * offset)
							end
						else
							if isVertical then
								xOffset = isReverseX and (row * offset) or (-row * offset)
								yOffset = isReverseY and (col * offset) or (-col * offset)
							else
								xOffset = col * offset
								yOffset = isReverseY and (-row * offset) or (row * offset)
							end
						end
						iconPositions[unitType][shown].positions[i] = {point = point, xOffset = xOffset, yOffset = yOffset}
					end
				end
				compareFuncs[unitType] = createCompareFunction(icons.sorting, icons.trinketOnTop)
				borderCustomColor[unitType] = icons.borderCustomColor[1] > 0 or icons.borderCustomColor[2] > 0 or icons.borderCustomColor[3] > 0
				borderColor[unitType] = unitType == 'ENEMY_PLAYER' and getColorByTimeEnemy or getColorByTimeFriend
				fills[unitType] = createFillFunction(type_db.cooldownFill, icons)
			end
		end
    end
	for frame in pairs(NP.CreatedPlates) do
		local plate = frame.UnitFrame
		if plate then
			local tracker = plate.CDTracker
			if not tracker then
				plate.CDTracker = CreateFrame("Frame", '$parentCDTracker', plate)
				tracker = plate.CDTracker
				tracker.cooldowns = {}
				tracker:Hide()
			end
			for i = #tracker.cooldowns, 1, -1 do
				tracker.cooldowns[i]:Hide()
				tracker.cooldowns[i] = nil
			end
		end
	end
end


P["Extras"]["nameplates"][modName] = {
	["petSpells"] = {},
	["FRIENDLY_PLAYER"] = {
		["enabled"] = false,
		["showAll"] = true,
		["showCity"] = false,
		["showBG"] = false,
		["showArena"] = false,
		["showInstance"] = false,
		["showWorld"] = false,
		["highlightedSpells"] = {},
		["spellList"] = {},
		["header"] = {
			["point"] = "RIGHT",
			["relativeTo"] = "LEFT",
			["xOffset"] = -4,
			["yOffset"] = 0,
			["level"] = 35,
		},
		["icons"] = {
			["size"] = 26,
			["spacing"] = 4,
			["perRow"] = 3,
			["maxRows"] = 2,
			["direction"] = "TOP",
			["sorting"] = "durationAsc",
			["throttle"] = 0.05,
			["borderColor"] = false,
			["trinketOnTop"] = false,
			["animateFadeOut"] = false,
			["borderCustomColor"] = { 0, 0, 0 },
		},
		["text"] = {
			["enabled"] = false,
			["font"] = "Expressway",
			["size"] = 12,
			["flag"] = "OUTLINE",
			["xOffset"] = 0,
			["yOffset"] = 0,
		},
		["cooldownFill"] = {
			["enabled"] = false,
			["direction"] = "LEFT",
			["reversed"] = false,
		},
	},
	["selectedType"] = 'FRIENDLY_PLAYER',
}

function mod:LoadConfig(db)
	local function selectedType() return db.selectedType end
	local function selectedSpell() return selectedType() and tonumber(db[selectedType()].selectedSpell) or "" end
	local function selectedTypeData()
		return core:getSelected("nameplates", modName, format("[%s]", selectedType() or ""), "FRIENDLY_PLAYER")
	end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Cooldowns"],
		args = {
			Cooldowns = {
				order = 0,
				type = "group",
				name = L["Cooldowns"],
				guiInline = true,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						width = "full",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Draws player cooldowns."],
						get = function(info) return selectedTypeData()[info[#info]] end,
						set = function(info, value)
							selectedTypeData()[info[#info]] = value
							if not value and testing then
								testing = false
								testMode(db)
							end
							if value and not isAwesome then
								E:StaticPopup_Show("PRIVATE_RL")
							else
								self:Toggle(db)
							end
						end,
					},
					testMode = {
						order = 1,
						type = "execute",
						name = L["Test Mode"],
						desc = "",
						func = function() testing = not testing testMode(db) end,
					},
					selectedType = {
						order = 2,
						type = "select",
						disabled = false,
						name = L["Select Type"],
						desc = "",
						values = function()
							local list = {}
							for type in pairs(db) do
								if upper(type) == type then list[type] = L[type] end
							end
							return list
						end,
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value if testing then testMode(db) else self:Toggle(db) end end,
					},
				},
			},
			visibility = {
				order = 1,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info]] end,
				set = function(info, value)
					local data = selectedTypeData()
					data[info[#info]] = value
					local enabled = false
					for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
						if data[showType] then
							enabled = true
							break
						end
					end
					if not enabled then data['showAll'] = true end
					self:Toggle(db)
				end,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					showAll = {
						order = 1,
						type = "toggle",
						name = L["Show Everywhere"],
						desc = "",
						set = function(info, value)
							local data = selectedTypeData()
							data[info[#info]] = value
							if not value then
								for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
									data[showType] = true
								end
							end
							self:Toggle(db)
						end,
					},
					showCity = {
						order = 2,
						type = "toggle",
						name = L["Show in Cities"],
						desc = "",
						hidden = function() return selectedTypeData().showAll end,
					},
					showBG = {
						order = 3,
						type = "toggle",
						name = L["Show in Battlegrounds"],
						desc = "",
						hidden = function() return selectedTypeData().showAll end,
					},
					showArena = {
						order = 4,
						type = "toggle",
						name = L["Show in Arenas"],
						desc = "",
						hidden = function() return selectedTypeData().showAll end,
					},
					showInstance = {
						order = 5,
						type = "toggle",
						name = L["Show in Instances"],
						desc = "",
						hidden = function() return selectedTypeData().showAll end,
					},
					showWorld = {
						order = 6,
						type = "toggle",
						name = L["Show in the World"],
						desc = "",
						hidden = function() return selectedTypeData().showAll end,
					},
				},
			},
			header = {
				type = "group",
				name = L["Header"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info-1]][info[#info]] end,
				set = function(info, value)
					selectedTypeData()[info[#info-1]][info[#info]] = value
					cache(db)
					NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
				end,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					level = {
						order = 1,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -5, max = 50, step = 1
					},
					spacer = {
						order = 2,
						type = "description",
						name = "",
					},
					xOffset = {
						order = 3,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 4,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					point = {
						order = 5,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 6,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
				},
			},
			icons = {
				type = "group",
				name = L["Icons"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info-1]][info[#info]] end,
				set = function(info, value)
					selectedTypeData()[info[#info-1]][info[#info]] = value
					cache(db)
					NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
				end,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					throttle = {
						order = 0,
						type = "range",
						name = L["OnUpdate Throttle"],
						desc = L["Sets update speed threshold."],
						min = 0, max = 0.5, step = 0.01,
					},
					spacer = {
						order = 1,
						type = "description",
						name = "",
					},
					trinketOnTop = {
						order = 2,
						type = "toggle",
						name = L["Trinket First"],
						desc = L["Makes PvP trinkets and human racial always get positioned first."],
					},
					animateFadeOut = {
						order = 3,
						type = "toggle",
						name = L["Animate Fade Out"],
						desc = L["Makes icons flash when the cooldown's about to end."],
					},
					borderCustomColor = {
						order = 4,
						type = "color",
						name = L["Border Color"],
						desc = L["Any value apart from black (0,0,0) would override borders by time left."],
						get = function(info) return unpack(selectedTypeData()[info[#info-1]].borderCustomColor) end,
						set = function(info, r, g, b) selectedTypeData()[info[#info-1]].borderCustomColor = { r, g, b } self:Toggle(db) end,
					},
					borderColor = {
						order = 5,
						type = "toggle",
						name = L["Border Color"],
						desc = L["Colors borders by time left."],
					},
					direction = {
						order = 6,
						type = "select",
						name = L["Growth Direction"],
						desc = "",
						values = function()
							local points = {}
							for point in pairs(E.db.Extras.pointOptions) do
								points[point] = point
							end
							points['CENTER'] = nil
							return points
						end,
					},
					sorting = {
						order = 7,
						type = "select",
						name = L["Sort Method"],
						desc = "",
						values = {
							["durationAsc"] = L["By duration, ascending."],
							["durationDesc"] = L["By duration, descending."],
							["timeUsedAsc"] = L["By time used, ascending."],
							["timeUsedDesc"] = L["By time used, descending."],
						},
					},
					size = {
						order = 8,
						type = "range",
						name = L["Icon Size"],
						desc = "",
						min = 10, max = 60, step = 1,
					},
					spacing = {
						order = 9,
						type = "range",
						name = L["Icon Spacing"],
						desc = "",
						min = 1, max = 12, step = 1,
					},
					perRow = {
						order = 10,
						type = "range",
						name = L["Per Row"],
						desc = "",
						min = 1, max = 12, step = 1,
					},
					maxRows = {
						order = 11,
						type = "range",
						name = L["Max Rows"],
						desc = "",
						min = 1, max = 6, step = 1,
					},
				},
			},
			text = {
				type = "group",
				name = L["CD Text"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info-1]][info[#info]] end,
				set = function(info, value)
					selectedTypeData()[info[#info-1]][info[#info]] = value
					NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
				end,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = L["Show"],
						desc = "",
					},
					size = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1
					},
					font = {
						order = 3,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end
					},
					flag = {
						order = 4,
						type = "select",
						name = L["Font Outline"],
						desc = "",
						values = {
							["NONE"] = L["NONE"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
					},
					xOffset = {
						order = 5,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -24, max = 24, step = 1
					},
					yOffset = {
						order = 6,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -24, max = 24, step = 1
					},
				},
			},
			cooldownFill = {
				type = "group",
				name = L["Cooldown Fill"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info-1]][info[#info]] end,
				set = function(info, value)
					selectedTypeData()[info[#info-1]][info[#info]] = value
					cache(db)
					NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
				end,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Show"],
						desc = "",
					},
					reversed = {
						order = 2,
						type = "toggle",
						name = L["Reverse"],
						desc = "",
					},
					direction = {
						order = 3,
						type = "select",
						name = L["Direction"],
						desc = "",
						values = {
							["RIGHT"] = L["Right"],
							["LEFT"] = L["Left"],
							["TOP"] = L["Up"],
							["BOTTOM"] = L["Down"],
						},
					},
				},
			},
			spells = {
				type = "group",
				name = L["Spells"],
				guiInline = true,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					addSpell = {
						order = 1,
						type = "input",
						name = L["Add Spell (by ID)"],
						desc = L["Format: 'spellID cooldown time', e.g. 42292 120"],
						get = function() return "" end,
						set = function(_, value)
							local spellID, cooldownTime = match(value, '%D*(%d+)%D*(%d*)')
							if spellID and GetSpellInfo(spellID) then
								cooldownTime = tonumber(cooldownTime) or LAI.spellDuration[spellID]
								if not cooldownTime then return end
								selectedTypeData().spellList[tonumber(spellID)] = cooldownTime
								allSpells[tonumber(spellID)] = cooldownTime
								local _, _, icon = GetSpellInfo(spellID)
								local string = '\124T' .. gsub(icon, '\124', '\124\124') .. ':16:16\124t' .. GetSpellLink(spellID)
								core:print('ADDED', string)
								NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
							end
						end,
					},
					removeSpell = {
						order = 2,
						type = "execute",
						name = L["Remove Selected Spell"],
						desc = "",
						func = function()
							local spellID = selectedSpell()
							selectedTypeData().spellList[spellID] = nil
							allSpells[spellID] = nil
							local _, _, icon = GetSpellInfo(spellID)
							local string = '\124T' .. gsub(icon, '\124', '\124\124') .. ':16:16\124t' .. GetSpellLink(spellID)
							core:print('REMOVED', string)
							NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
						end,
						disabled = function() return not selectedTypeData().spellList[selectedSpell()] end,
					},
					copyList = {
						order = 3,
						type = "select",
						width = "double",
						name = L["Copy List"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							selectedTypeData().spellList = CopyTable(core.SpellLists[value] or db[value].spellList)
							cache(db)
							NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
						end,
						values = function()
							local values = {
								["DEFAULTS"] = L["DEFAULTS"],
								["INTERRUPT"] = L["INTERRUPT"],
								["CONTROL"] = L["CONTROL"],
							}
							if selectedType() == "FRIENDLY_PLAYER" then
								values["ENEMY_PLAYER"] = L["Enemy"]
							else
								values["FRIENDLY_PLAYER"] = L["Friendly"]
							end
							return values
						end,
						sorting = function()
							local sortedValues = {"DEFAULTS", "INTERRUPT", "CONTROL"}
							tinsert(sortedValues, selectedType() == "FRIENDLY_PLAYER" and "ENEMY_PLAYER" or "FRIENDLY_PLAYER")
							tsort(sortedValues, function(a, b)
								if a == "DEFAULTS" then
									return true
								elseif b == "DEFAULTS" then
									return false
								else
									local hasLowerA = match(a, "PLAYER")
									local hasLowerB = match(b, "PLAYER")

									if hasLowerA and not hasLowerB then
										return false
									elseif not hasLowerA and hasLowerB then
										return true
									else
										return a < b
									end
								end
							end)
							return sortedValues
						end,
					},
					selectedSpell = {
						order = 4,
						type = "select",
						width = "double",
						name = L["Select Spell"],
						desc = "",
						get = function(info) return selectedTypeData()[info[#info]] end,
						set = function(info, value)
							selectedTypeData()[info[#info]] = value
							if not selectedTypeData().highlightedSpells[selectedSpell()] then
								selectedTypeData().highlightedSpells[selectedSpell()] = {
									["enabled"] = false, ["size"] = 1, ["color"] = {0,0,0,1}
								}
							end
						end,
						values = function()
							local values = {}
							for id in pairs(selectedTypeData().spellList) do
								local name = GetSpellInfo(id) or ""
								local icon = select(3, GetSpellInfo(id))
								values[id] = format("%s %s (%s)", icon and "|T"..icon..":0|t" or "", name, id)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {}
							for id in pairs(selectedTypeData().spellList) do
								tinsert(sortedKeys, id)
							end
							tsort(sortedKeys, function(a, b)
								return (GetSpellInfo(a) or "") < (GetSpellInfo(b) or "")
							end)
							return sortedKeys
						end,
					},
					shadow = {
						order = 5,
						type = "toggle",
						name = L["Shadow"],
						desc = L["For the important stuff."],
						get = function()
							return selectedTypeData().highlightedSpells[selectedSpell()]
								and selectedTypeData().highlightedSpells[selectedSpell()].enabled
						end,
						set = function(_, value)
							selectedTypeData().highlightedSpells[selectedSpell()].enabled = value
							NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
						end,
						disabled = function() return not (selectedTypeData().enabled and selectedSpell()) end,
					},
					petSpell = {
						order = 6,
						type = "toggle",
						name = L["Pet Ability"],
						desc = L["Pet casts require some special treatment."],
						get = function() return db.petSpells[selectedSpell()] end,
						set = function(_, value) db.petSpells[selectedSpell()] = value end,
						disabled = function() return not (selectedTypeData().enabled and selectedSpell()) end,
					},
					shadowSize = {
						order = 7,
						type = "range",
						name = L["Shadow Size"],
						desc = "",
						min = 1, max = 12, step = 1,
						get = function()
							return selectedTypeData().highlightedSpells[selectedSpell()]
								and selectedTypeData().highlightedSpells[selectedSpell()].size or 0
						end,
						set = function(_, value)
							selectedTypeData().highlightedSpells[selectedSpell()].size = value
							NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
						end,
						disabled = function()
							return not selectedTypeData().enabled
								or not selectedTypeData().highlightedSpells[selectedSpell()]
								or not selectedTypeData().highlightedSpells[selectedSpell()].enabled end,
					},
					shadowColor = {
						order = 8,
						type = "color",
						hasAlpha = true,
						name = L["Shadow Color"],
						desc = "",
						get = function()
							return unpack(selectedTypeData().highlightedSpells[selectedSpell()]
								and selectedTypeData().highlightedSpells[selectedSpell()].color or {})
						end,
						set = function(_, r, g, b, a)
							selectedTypeData().highlightedSpells[selectedSpell()].color = { r, g, b, a }
							NP:ForEachVisiblePlate("UpdateAllFrame", true, true)
						end,
						disabled = function()
							return not selectedTypeData().enabled
								or not selectedTypeData().highlightedSpells[selectedSpell()]
								or not selectedTypeData().highlightedSpells[selectedSpell()].enabled end,
					},
				},
			},
		},
	}
	if not next(db['FRIENDLY_PLAYER'].spellList) then
		db['FRIENDLY_PLAYER'].spellList = CopyTable(core.SpellLists["DEFAULTS"])
	end
	if not next(db.petSpells) then
		db.petSpells = CopyTable(core.SpellLists["PETS"])
	end
	if not db['ENEMY_PLAYER'] then
		db['ENEMY_PLAYER'] = CopyTable(db['FRIENDLY_PLAYER'])
	end
end


local function combatLogEvent(db, _, ...)
    local _, eventType, _, sourceName, sourceFlags, _, _, _, spellID = ...

    if eventType == "SPELL_CAST_SUCCESS" and sourceName then
		local cdTime = allSpells[spellID]
		if cdTime and ((band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER
									or band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER)) then
			local startTime = GetTime()
			mod:UpdateCooldowns(db, match(sourceName, '%P+'), spellID, startTime, startTime + cdTime)
		end
    end
end


function mod:UpdateCooldowns(db, playerName, spellID, startTime, endTime)
    local remaining = endTime - GetTime()
    if remaining <= 0 then return end

	local activeCds = activeCooldowns[playerName]
    local resetSpell = resetCooldowns[spellID]

	if not activeCds then
		activeCooldowns[playerName] = {}
		activeCds = activeCooldowns[playerName]
	elseif resetSpell then
		for i = #activeCds, 1, -1 do
			if resetSpell[activeCds[i].spellID] then
				tremove(activeCds, i)
			end
		end
	end
    tinsert(activeCds, {
						spellID = spellID,
						startTime = startTime,
						endTime = endTime,
						icon = select(3, GetSpellInfo(spellID)),
						isTrinket = trinkets[spellID]
					})
    self:UpdatePlates(db, playerName)
end

function mod:HandlePets(db, plate, petName, unit)
	local ownerName = getPetOwner(plate.unit or plate:GetParent().unit or unit or petName)
	if ownerName then
		activeCooldowns[ownerName] = activeCooldowns[ownerName] or {}
		if petName ~= ownerName then
			for _, spellInfo in ipairs(activeCooldowns[petName]) do
				tinsert(activeCooldowns[ownerName], spellInfo)
			end
			activeCooldowns[petName] = nil
		end
		for plate in pairs(NP.VisiblePlates) do
			local unitName, unitType = plate.UnitName, plate.UnitType
			if unitName == ownerName and (unitType == 'ENEMY_PLAYER' or unitType == 'FRIENDLY_PLAYER') then
				self:AttachCooldownsToPlate(db[unitType], plate, activeCooldowns[ownerName], unitType)
				return
			end
		end
	end
end

function mod:UpdatePlates(db, playerName)
	for plate in pairs(NP.VisiblePlates) do
		if plate.UnitName == playerName then
			local cooldowns = activeCooldowns[playerName]
			if cooldowns and next(cooldowns) then
				local unitType = plate.UnitType
				if unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
					self:AttachCooldownsToPlate(db[unitType], plate, cooldowns, unitType)
				elseif unitType then
					self:HandlePets(db, plate, playerName)
				end
			elseif plate.CDTracker then
				plate.CDTracker:Hide()
			end
			return
		end
	end
end

function mod:AttachCooldownsToPlate(db, plate, cooldowns, unitType)
	local tracker = plate.CDTracker

	if not db.enabled or not tracker or not db.isShown then return end

	local db_header = db.header
	local db_icons = db.icons
	local db_text = db.text
	local db_spellList = db.spellList

	local health = plate.Health
	local level = plate:GetFrameLevel() + db_header.level
	tracker:ClearAllPoints()
	tracker:Point(db_header.point, (health and health:IsShown()) and health or plate.Name,
							db_header.relativeTo, db_header.xOffset, db_header.yOffset)
	tracker:SetFrameLevel(level)

	tsort(cooldowns, compareFuncs[unitType])

	local shown = 0
	local maxShown = db_icons.perRow * db_icons.maxRows

    for _, cd in ipairs(cooldowns) do
		if db_spellList[cd.spellID] then
			if shown >= maxShown then break end

			local cdFrame = tracker.cooldowns[shown+1]

			local endTime = cd.endTime
			local startTime = cd.startTime

			if not cdFrame then
				cdFrame = CreateFrame("Frame", nil, tracker)
				cdFrame:Size(db_icons.size)
				cdFrame:SetTemplate()
				cdFrame.texture = cdFrame:CreateTexture(nil, "ARTWORK")
				cdFrame.texture:SetInside(cdFrame, E.mult, E.mult)
				cdFrame.fill = cdFrame:CreateTexture(nil, "OVERLAY")
				cdFrame.fill:SetTexture(0, 0, 0, 0.8)
				cdFrame.text = cdFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
				cdFrame.text:SetFont(LSM:Fetch("font", db_text.font), db_text.size, db_text.flag)
				cdFrame.text:Point("CENTER", cdFrame, "CENTER", db_text.xOffset, db_text.yOffset)
				cdFrame:SetTemplate()
				cdFrame.shadow = CreateFrame("Frame", nil, cdFrame)
				cdFrame.shadow:SetFrameLevel(level - 1)
				tinsert(tracker.cooldowns, cdFrame)
			end

			if db.cooldownFill.enabled then
				cdFrame.fillOn = fills[unitType]
				cdFrame.fillOn(cdFrame, ((endTime - GetTime()) / (endTime - startTime)))
			end

			if db_text.enabled then
				cdFrame.text:SetText(ceil(endTime - GetTime()))
				cdFrame.textOn = true
			end

			if borderCustomColor[unitType] then
				cdFrame:SetBackdropBorderColor(unpack(db_icons.borderCustomColor))
			elseif db_icons.borderColor then
				cdFrame.col = borderColor[unitType]
				cdFrame:SetBackdropBorderColor(cdFrame:col(endTime - GetTime(), endTime - startTime))
			end

			cdFrame.texture:SetTexture(cd.icon)

			cdFrame.endTime = endTime
			cdFrame.startTime = startTime
			cdFrame.spellID = cd.spellID
			cdFrame.throttle = db_icons.throttle
			cdFrame.animateFadeOut = db_icons.animateFadeOut

			cdFrame:SetScript("OnUpdate", function(self, elapsed)
				mod:OnUpdateCooldown(self, elapsed, cooldowns, db, tracker, unitType)
			end)

			shown = shown + 1
		end
    end

	if shown == 0 then
		tracker:Hide()
	else
		for i = shown+1, #tracker.cooldowns do
			tracker.cooldowns[i]:Hide()
		end
		self:RepositionIcons(tracker, shown, unitType)
	end
end

function mod:RepositionIcons(tracker, shown, unitType)
	local highlights = highlightedSpells[unitType]
	local info = iconPositions[unitType][shown]
	local iconPos = info.positions
	local cooldowns = tracker.cooldowns

    for i = 1, shown do
        local cdFrame = cooldowns[i]
        cdFrame:ClearAllPoints()

		local position = iconPos[i]
		cdFrame:Point(position.point, tracker, position.point, position.xOffset, position.yOffset)

        local highlight = highlights[cdFrame.spellID]
        if highlight and highlight.enabled then
            cdFrame.shadow:SetOutside(cdFrame, highlight.size, highlight.size)
            cdFrame.shadow:SetBackdrop({edgeFile = edgeFile, edgeSize = E:Scale(highlight.size)})
            cdFrame.shadow:SetBackdropBorderColor(unpack(highlight.color))
            cdFrame.shadow:Show()
        else
            cdFrame.shadow:Hide()
        end
        cdFrame:Show()
    end
    tracker:Size(info.trackerWidth, info.trackerHeight)
	tracker:Show()
end

function mod:OnUpdateCooldown(cooldown, elapsed, cooldowns, db, tracker, unitType)
    cooldown.timeElapsed = (cooldown.timeElapsed or 0) + elapsed

    if cooldown.timeElapsed > cooldown.throttle then
        cooldown.timeElapsed = 0

		local endTime = cooldown.endTime
		local startTime = cooldown.startTime
        local remaining = endTime - GetTime()

        if cooldown.textOn then
            cooldown.text:SetText(ceil(remaining))
        end

        if cooldown.fillOn then
			cooldown.fillOn(cooldown, (remaining / (endTime - startTime)))
        end

        if cooldown.col then
			cooldown:SetBackdropBorderColor(cooldown:col(remaining, endTime - startTime))
        end

		if cooldown.animateFadeOut then
			local progress = remaining / (cooldown.endTime - cooldown.startTime)
			if progress < 0.25 and remaining < 6 then
				local f = abs(0.5 - GetTime() % 1) * 3
				cooldown:SetAlpha(f)
			else
				cooldown:SetAlpha(1)
			end
		end

		if remaining > 0 then return end

		cooldown:Hide()

		for i = #cooldowns, 1, -1 do
			if cooldowns[i].endTime < GetTime() then
				tremove(cooldowns, i)
			end
		end

		if tracker:IsShown() then
			mod:AttachCooldownsToPlate(db, tracker:GetParent(), cooldowns, unitType)
		end
    end
end

function mod:OnShow()
end


function mod:Toggle(db, visibilityUpdate)
	if not core.reload and (db['FRIENDLY_PLAYER'].enabled or db['ENEMY_PLAYER'].enabled) then
		if not self:IsHooked(E, "ToggleOptionsUI") then
			self:SecureHook(E, "ToggleOptionsUI", function()
				if testing and ElvUIGUIFrame and not ElvUIGUIFrame:IsShown() then
					testing = false
					testMode(db)
				end
			end)
		end
		core:RegisterAreaUpdate(modName, function()
			if core:GetCurrentAreaType() == "showArena" then
				twipe(activeCooldowns)
			end
			scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")
			self:Toggle(db, true)
		end)
		if updateVisibilityState(db, core:GetCurrentAreaType()) then
			cache(db, visibilityUpdate)
			for plate in pairs(NP.VisiblePlates) do
				local tracker = plate.CDTracker
				local unitType = plate.UnitType
				local data = db[unitType]
				if data and data.isShown then
					local cooldowns = activeCooldowns[plate.UnitName]
					if cooldowns and next(cooldowns) then
						if unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
							self:AttachCooldownsToPlate(data, plate, cooldowns, unitType)
						elseif unitType then
							self:HandlePets(db, plate, plate.UnitName)
						end
					else
						tracker:Hide()
					end
				else
					tracker:Hide()
				end
			end
			if not self:IsHooked(NP, "Construct_HealthBar") then
				self:SecureHook(NP, "Construct_HealthBar", function(_, plate)
					plate.CDTracker = CreateFrame("Frame", '$parentCDTracker', plate)
					plate.CDTracker.cooldowns = {}
					plate.CDTracker:Hide()
				end)
			end
			if not isAwesome then
				for event, unit in pairs({["UPDATE_MOUSEOVER_UNIT"] = 'mouseover', ["PLAYER_FOCUS_CHANGED"] = 'focus'}) do
					if not self:IsHooked(NP, event) then
						self:SecureHook(NP, event, function()
							if UnitExists(unit) then
								local name = UnitName(unit)
								if activeCooldowns[name] and not UnitIsPlayer(unit) then
									for frame in pairs(NP.VisiblePlates) do
										local unitType = frame.UnitType
										if frame.UnitName == name and (unitType == "FRIENDLY_NPC" or unitType == "ENEMY_NPC") then
											mod:HandlePets(db, frame, name, unit)
										end
									end
								end
							end
						end)
					end
				end
				self:RegisterEvent("PLAYER_TARGET_CHANGED", function()
					if UnitExists('target') then
						local name = UnitName('target')
						if activeCooldowns[name] and not UnitIsPlayer('target') then
							for frame in pairs(NP.VisiblePlates) do
								if frame:GetParent():GetAlpha() == 1 then
									mod:HandlePets(db, frame, name, 'target')
								end
							end
						end
					end
				end)
			end
			self.OnShow = function(_, self)
				local plate = self.UnitFrame
				local tracker = plate.CDTracker
				local unitType = plate.UnitType
				local data = db[unitType]

				if data and data.isShown then
					local playerName = plate.UnitName
					local activeCds = activeCooldowns[playerName]
					if activeCds then
						for i = #activeCds, 1, -1 do
							if activeCds[i].endTime < GetTime() then
								tremove(activeCds, i)
							end
						end
						if next(activeCds) then
							if (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
								mod:AttachCooldownsToPlate(data, plate, activeCds, unitType)
							elseif unitType then
								tracker:Hide()
								mod:HandlePets(db, plate, playerName)
							end
						else
							tracker:Hide()
						end
					else
						tracker:Hide()
					end
				else
					tracker:Hide()
				end
			end
			if not self:IsHooked(NP, "OnShow") then self:SecureHook(NP, "OnShow") end
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(...) combatLogEvent(db, ...) end)
			core:RegisterNPElement('CDTracker', function(unitType, frame, element)
				if frame.CDTracker and (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
					local points = db[unitType].header
					frame.CDTracker:ClearAllPoints()
					frame.CDTracker:Point(points.point, element, points.relativeTo, points.xOffset, points.yOffset)
				end
			end)
		else
			core:RegisterNPElement('CDTracker')
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			self:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			self:UnregisterEvent("PLAYER_TARGET_CHANGED")
			self:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			if self:IsHooked(NP, "OnShow") then
				if isAwesome then
					self:Unhook(NP, "OnShow")
				else
					self.OnShow = function() end
				end
			end
			for frame in pairs(NP.CreatedPlates) do
				local plate = frame.UnitFrame
				if plate and plate.CDTracker then
					plate.CDTracker:Hide()
				end
			end
		end
		self.initialized = true
	elseif self.initialized then
		core:RegisterAreaUpdate(modName)
		core:RegisterNPElement('CDTracker')
		self:UnregisterAllEvents()
		if self:IsHooked(E, "ToggleOptionsUI") then self:Unhook(E, "ToggleOptionsUI") end
		if self:IsHooked(NP, "Construct_HealthBar") then self:Unhook(NP, "Construct_HealthBar") end
		if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		for frame in pairs(NP.CreatedPlates) do
			local plate = frame.UnitFrame
			if plate and plate.CDTracker then
				plate.CDTracker:Hide()
				plate.CDTracker = nil
			end
		end
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback