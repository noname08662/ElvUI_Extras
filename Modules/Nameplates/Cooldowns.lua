local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("CooldownsNP2", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI

local modName = mod:GetName()
local activeCooldowns, testing = {}, false
local highlightedSpells = {["ENEMY_PLAYER"] = {}, ["FRIENDLY_PLAYER"] = {}}
local edgeFile = LSM:Fetch("border", "ElvUI GlowBorder")
local isAwesome = C_NamePlate

local band = bit.band
local _G, pairs, ipairs, select, unpack, next = _G, pairs, ipairs, select, unpack, next
local tonumber, tostring, loadstring, setfenv = tonumber, tostring, loadstring, setfenv
local gsub, upper, match, find, format = string.gsub, string.upper, string.match, string.find, string.format
local random, floor, min, ceil, abs = math.random, math.floor, math.min, math.ceil, math.abs
local tinsert, tremove, tsort, twipe = table.insert, table.remove, table.sort, table.wipe
local GetSpellInfo, GetSpellLink, GetTime = GetSpellInfo, GetSpellLink, GetTime
local UnitIsPlayer, UnitExists, UnitName = UnitIsPlayer, UnitExists, UnitName
local COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER
local UNITNAME_SUMMON_TITLES = {gsub(format(UNITNAME_SUMMON_TITLE1, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE3, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE5, 1), '[%d%p%s]+', '')}

mod.initialized = false
mod.activeCooldowns = activeCooldowns
mod.iconPositions = {["FRIENDLY_PLAYER"] = {}, ["ENEMY_PLAYER"] = {}}

local allSpells = {}
local compareFuncs = {}
local borderCustomColor = {}
local onUpdates = {}
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

local function findOwner(unit)
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

local UnitOwner = UnitOwner and function(unit)
	return UnitOwner(unit) or findOwner(unit)
end or findOwner

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
	twipe(activeCooldowns)
	for plate in pairs(NP.VisiblePlates) do
		for _, f in pairs(plate.CDTracker or {}) do
			f:Hide()
		end
	end
	if not testing then return end

    local spellList = db[db.selectedType].spellList
	if not next(spellList) then return end

    local testSpells = {}
	local hasTrinket = false

    for spellID, duration in pairs(spellList) do
		local startTime = GetTime() - random(0, duration/2)
		tinsert(testSpells, {
						spellID = spellID,
						startTime = startTime,
						endTime = startTime + duration,
						icon = select(3, GetSpellInfo(spellID)) or "Interface\\Icons\\INV_Misc_QuestionMark",
						isTrinket = trinkets[spellID]
					})
		hasTrinket = hasTrinket or trinkets[spellID]
    end

	if not hasTrinket then
		tinsert(testSpells, {
						spellID = 59752,
						startTime = GetTime() - random(0, 120/2),
						endTime = GetTime() - random(0, 120/2) + 120,
						icon = select(3, GetSpellInfo(59752)),
						isTrinket = true,
					})
	end

	for plate in pairs(NP.VisiblePlates) do
		local unitType = plate.UnitType
		if unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
			activeCooldowns[plate.UnitName..'true'] = testSpells
			mod:AttachCooldowns(plate, testSpells, unitType)
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

local function createOnUpdateFunction(db, unitType)
	local luaFunction = loadstring(
		format(
			[[
				local self, elapsed = ...
				self.timeElapsed = (self.timeElapsed or 0) + elapsed

				if self.timeElapsed > %f then
					self.timeElapsed = 0

					local endTime = self.endTime
					local remaining = endTime - GetTime()

					if remaining <= 0 then
						self:Hide()

						local plate = self:GetParent():GetParent()
						local cooldowns = self.cooldowns
						for i = #cooldowns, 1, -1 do
							if cooldowns[i].endTime < GetTime() then
								tremove(cooldowns, i)
							end
						end
						if next(cooldowns) then
							mod:AttachCooldowns(plate, cooldowns, plate.UnitType)
						end
						return
					end

					%s
					%s

					%s
					%s
					%s
					%s
				end
			]],
			(db.icons.throttle),
			(db.text.enabled or db.cooldownFill.enabled or db.icons.borderColor) and "local startTime = self.startTime" or "",
			(db.cooldownFill.enabled or db.icons.animateFadeOut or db.icons.borderColor) and [[
				local progress = remaining / (self.endTime - self.startTime)
			]] or "",
			(db.text.enabled) and "self.text:SetText(ceil(remaining))" or "",
			(db.cooldownFill.enabled) and "self:fillOn(progress)" or "",
			(db.icons.borderColor) and format(
				"self:SetBackdropBorderColor(%s)", unitType == 'ENEMY_PLAYER' and "1 - progress, progress" or "progress, 1 - progress"
			) or "",
			(db.icons.animateFadeOut) and [[
				if progress < 0.25 and remaining < 6 then
					local f = abs(0.5 - GetTime() % 1) * 3
					self:SetAlpha(f)
				else
					self:SetAlpha(1)
				end
			]] or ""
		)
	)

	setfenv(luaFunction, {
		mod = mod,
		GetTime = GetTime,
		next = next,
		ceil = ceil,
		abs = abs,
		tremove = tremove,
	})

	return luaFunction
end


local function cache(db, visibilityUpdate)
	twipe(allSpells)
    for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
		local type_db = db[unitType]

		if type_db.enabled then
			if type_db.isShown then
				for id, cdTime in pairs(type_db.spellList) do
					allSpells[id] = cdTime
				end
			end

			if not visibilityUpdate then
				twipe(highlightedSpells[unitType])
				for spellID, info in pairs(type_db.highlightedSpells) do
					if info.enabled then
						highlightedSpells[unitType][spellID] = info
					end
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
				borderCustomColor[unitType] =
					not icons.borderColor and (icons.borderCustomColor[1] > 0 or icons.borderCustomColor[2] > 0 or icons.borderCustomColor[3] > 0)
				fills[unitType] = createFillFunction(type_db.cooldownFill, icons)
				onUpdates[unitType] = createOnUpdateFunction(type_db, unitType)
			end
		end
    end
	if not visibilityUpdate then
		for frame in pairs(NP.CreatedPlates) do
			local plate = frame.UnitFrame
			if plate then
				plate.CDTracker = mod:ConstructCDTracker(db, plate)
				for unitType, f in pairs(plate.CDTracker) do
					local cooldowns = f.cooldowns
					for i = #cooldowns, 1, -1 do
						cooldowns[i]:Hide()
					end
					twipe(cooldowns)
					f:SetFrameLevel(plate.Health:GetFrameLevel() + db[unitType].header.level)
				end
			end
		end
		for plate in pairs(NP.VisiblePlates) do
			local unitType = plate.UnitType
			local data = db[unitType]
			local tracker = plate.CDTracker[unitType]

			if data and data.isShown then
				local cooldowns = activeCooldowns[
									plate.UnitName..(plate.isPlayerString or tostring(unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER'))]
				if cooldowns and next(cooldowns) then
					if plate.isPlayerString == 'true' then
						mod:AttachCooldowns(plate, cooldowns, unitType)
					else
						mod:HandlePets(plate, plate.UnitName)
					end
				else
					tracker:Hide()
				end
			elseif tracker then
				tracker:Hide()
			end
		end
	end
end


P["Extras"]["nameplates"][modName] = {
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
	local function selectedSpell() return selectedType() and tonumber(db[selectedType()].selectedSpell) or db[selectedType()].selectedSpell or "" end
	local function selectedTypeData()
		return core:getSelected("nameplates", modName, format("[%s]", selectedType() or ""), "FRIENDLY_PLAYER")
	end
	local function highlightedSpellsData()
		return core:getSelected("nameplates", modName, format("%s.highlightedSpells[%s]", selectedType(), selectedSpell()), "")
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
					cache(db)
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
				end,
				disabled = function() return not selectedTypeData().enabled end,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
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
					alpha = {
						order = 4,
						type = "range",
						name = L["Alpha"],
						desc = "",
						min = 0.1, max = 1, step = 0.01,
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
						name = L["Add Spell"],
						desc = L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"],
						get = function() return "" end,
						set = function(_, value)
							local spellID, cooldownTime = match(value, '(.*)%s+(%d*)')
							if spellID then
								cooldownTime = tonumber(cooldownTime) or LAI.spellDuration[spellID]
								if not cooldownTime then return end
								selectedTypeData().spellList[tonumber(spellID) or spellID] = cooldownTime
								allSpells[tonumber(spellID) or spellID] = cooldownTime
								local string
								local _, _, icon = GetSpellInfo(spellID)
								if icon then
									icon = gsub(icon or "", '\124', '\124\124')
									string = '\124T' .. icon .. ':16:16\124t' .. GetSpellLink(spellID)
								else
									string = format("[%s]", spellID)
								end
								core:print('ADDED', string)
								NP:ForEachVisiblePlate("UpdateAllFrame", nil, true)
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
							db[selectedType()].selectedSpell = ""
							allSpells[spellID] = nil
							local string
							local _, _, icon = GetSpellInfo(spellID)
							if icon then
								icon = gsub(icon or "", '\124', '\124\124')
								string = '\124T' .. icon .. ':16:16\124t' .. GetSpellLink(spellID)
							else
								string = format("[%s]", spellID)
							end
							core:print('REMOVED', string)
							NP:ForEachVisiblePlate("UpdateAllFrame", nil, true)
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
							local list = selectedTypeData().spellList
							twipe(list)
							for id, cdTime in pairs(core.SpellLists[value] or db[value].spellList) do
								list[id == 47860 and id or GetSpellInfo(id)] = cdTime
							end
							cache(db)
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
						get = function() return selectedSpell() end,
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
								if type(id) == 'number' then
									local name = GetSpellInfo(id) or ""
									local icon = select(3, GetSpellInfo(id))
									icon = icon and "|T"..icon..":0|t" or ""
									values[id] = format("%s %s (%s)", icon, name, id)
								else
									local icon = select(3, GetSpellInfo(id))
									icon = icon and "|T"..icon..":0|t" or ""
									values[id] = format("%s %s", icon, id)
								end
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {}
							for id in pairs(selectedTypeData().spellList) do
								tinsert(sortedKeys, id)
							end
							tsort(sortedKeys, function(a, b)
								local nameA = GetSpellInfo(a)
								local nameB = GetSpellInfo(b)
								if not nameA and not nameB then
									return a < b
								elseif not nameB then
									return true
								elseif not nameA then
									return false
								else
									return nameA < nameB
								end
							end)
							return sortedKeys
						end,
					},
					shadow = {
						order = 5,
						type = "toggle",
						width = "full",
						name = L["Shadow"],
						desc = L["For the important stuff."],
						get = function() return selectedSpell() ~= "" and highlightedSpellsData().enabled end,
						set = function(_, value)
							highlightedSpellsData().enabled = value
							NP:ForEachVisiblePlate("UpdateAllFrame", nil, true)
						end,
						disabled = function() return not selectedTypeData().enabled or selectedSpell() == "" end,
					},
					shadowSize = {
						order = 6,
						type = "range",
						name = L["Shadow Size"],
						desc = "",
						min = 1, max = 12, step = 1,
						get = function() return selectedSpell() ~= "" and highlightedSpellsData().size or 0 end,
						set = function(_, value)
							highlightedSpellsData().size = value
							NP:ForEachVisiblePlate("UpdateAllFrame", nil, true)
						end,
						hidden = function()
							return not selectedTypeData().enabled or selectedSpell() == "" or not highlightedSpellsData().enabled
						end,
					},
					shadowColor = {
						order = 7,
						type = "color",
						hasAlpha = true,
						name = L["Shadow Color"],
						desc = "",
						get = function() return unpack(selectedSpell() ~= "" and highlightedSpellsData().color or {}) end,
						set = function(_, r, g, b, a)
							highlightedSpellsData().color = {r, g, b, a}
							NP:ForEachVisiblePlate("UpdateAllFrame", nil, true)
						end,
						hidden = function()
							return not selectedTypeData().enabled or selectedSpell() == "" or not highlightedSpellsData().enabled
						end,
					},
				},
			},
		},
	}
	if not next(db['FRIENDLY_PLAYER'].spellList) then
		for id, cdTime in pairs(core.SpellLists["DEFAULTS"]) do
			db['FRIENDLY_PLAYER'].spellList[id == 47860 and id or GetSpellInfo(id)] = cdTime
		end
	end
	if not db['ENEMY_PLAYER'] then
		db['ENEMY_PLAYER'] = CopyTable(db['FRIENDLY_PLAYER'])
	end
end


local combatLogEvent = UnitOwner and function(_, _, eventType, sourceGuid, sourceName, sourceFlags, _, _, _, spellID)
    if eventType == "SPELL_CAST_SUCCESS" and sourceName then
		local cdTime = allSpells[spellID] or allSpells[GetSpellInfo(spellID)]
		local isPlayer = band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER
		if cdTime and (isPlayer or band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER) then
			local startTime = GetTime()
			if not isPlayer then
				local ownerName = UnitOwner(sourceGuid)
				if ownerName then
					mod:UpdateCooldowns(ownerName, spellID, startTime, startTime + cdTime, true)
				else
					mod:UpdateCooldowns(match(sourceName, '%P+'), spellID, startTime, startTime + cdTime)
				end
			else
				mod:UpdateCooldowns(match(sourceName, '%P+'), spellID, startTime, startTime + cdTime, true)
			end
		end
    end
end or function(_, _, eventType, _, sourceName, sourceFlags, _, _, _, spellID)
    if eventType == "SPELL_CAST_SUCCESS" and sourceName then
		local cdTime = allSpells[spellID] or allSpells[GetSpellInfo(spellID)]
		local isPlayer = band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER
		if cdTime and (isPlayer or band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER) then
			local startTime = GetTime()
			mod:UpdateCooldowns(match(sourceName, '%P+'), spellID, startTime, startTime + cdTime, isPlayer)
		end
    end
end


function mod:UpdateCooldowns(playerName, spellID, startTime, endTime, isPlayer)
    local remaining = endTime - GetTime()
    if remaining <= 0 then return end

	local hash = playerName..tostring(isPlayer)
	local activeCds = activeCooldowns[hash]
    local resetSpell = resetCooldowns[spellID]

	if not activeCds then
		activeCooldowns[hash] = {}
		activeCds = activeCooldowns[hash]
	elseif resetSpell then
		for i = #activeCds, 1, -1 do
			if resetSpell[activeCds[i].spellID] then
				tremove(activeCds, i)
			end
		end
	end
	local name, _, icon = GetSpellInfo(spellID)

    tinsert(activeCds, {
						spellID = spellID,
						spellName = name,
						startTime = startTime,
						endTime = endTime,
						icon = icon,
						isTrinket = trinkets[spellID]
					})
    self:UpdatePlates(playerName, isPlayer, hash)
end

function mod:HandlePets(plate, petName, unit)
	local ownerName = UnitOwner(plate.unit or plate:GetParent().unit or unit or petName)
	if ownerName then
		local hash = ownerName..'true'
		local cooldowns = activeCooldowns[hash]
		local petCooldowns = activeCooldowns[petName..'false']
		if not cooldowns then
			activeCooldowns[hash] = {}
			cooldowns = activeCooldowns[hash]
		end
		for _, spellInfo in ipairs(petCooldowns) do
			tinsert(cooldowns, spellInfo)
		end
		twipe(petCooldowns)
		for plate in pairs(NP.VisiblePlates) do
			local unitType = plate.UnitType
			if plate.UnitName == ownerName and (unitType == 'ENEMY_PLAYER' or unitType == 'FRIENDLY_PLAYER') then
				self:AttachCooldowns(plate, cooldowns, unitType)
				return
			end
		end
	end
end

function mod:UpdatePlates(playerName, isPlayer, hash)
	for plate in pairs(NP.VisiblePlates) do
		if plate.UnitName == playerName then
			local cooldowns = activeCooldowns[hash]
			if cooldowns and next(cooldowns) then
				if isPlayer then
					self:AttachCooldowns(plate, cooldowns, plate.UnitType)
				else
					self:HandlePets(plate, playerName)
				end
				return
			end
		end
	end
end

function mod:AttachCooldowns(plate, cooldowns, unitType)
	local tracker = (plate.CDTracker or {})[unitType]

	if not tracker or not tracker.db.isShown then
		return
	end

	local db = tracker.db
	local db_header = db.header
	local db_icons = db.icons
	local db_text = db.text
	local db_spellList = db.spellList
	local health = plate.Health

	tracker:ClearAllPoints()
	tracker:Point(db_header.point, health:IsShown() and health or plate.Name,
				db_header.relativeTo, db_header.xOffset, db_header.yOffset)

	tsort(cooldowns, compareFuncs[unitType])

	local shown = 0
	local maxShown = db_icons.perRow * db_icons.maxRows

    for _, cd in ipairs(cooldowns) do
		if db_spellList[cd.spellID] or db_spellList[cd.spellName] then
			if shown >= maxShown then break end

			local cdFrame = tracker.cooldowns[shown+1]

			local endTime = cd.endTime
			local startTime = cd.startTime
			local progress = (endTime - GetTime()) / (endTime - startTime)

			if not cdFrame then
				cdFrame = CreateFrame("Frame", nil, tracker)
				cdFrame:Size(db_icons.size)
				cdFrame:SetTemplate(nil, nil, nil, E.PixelMode)
				cdFrame.texture = cdFrame:CreateTexture(nil, "ARTWORK")
				cdFrame.texture:SetInside(cdFrame, E.mult, E.mult)
				cdFrame.shadow = CreateFrame("Frame", nil, cdFrame)
				cdFrame.shadow:SetFrameLevel(plate.Health:GetFrameLevel() + db.header.level)
				if db.cooldownFill.enabled then
					cdFrame.fill = cdFrame:CreateTexture(nil, "OVERLAY")
					cdFrame.fill:SetTexture(0, 0, 0, db.cooldownFill.alpha or 0.8)
					cdFrame.fillOn = fills[unitType]
					cdFrame:fillOn(progress)
				end
				if db_text.enabled then
					cdFrame.text = cdFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
					cdFrame.text:SetFont(LSM:Fetch("font", db_text.font), db_text.size, db_text.flag)
					cdFrame.text:Point("CENTER", cdFrame, "CENTER", db_text.xOffset, db_text.yOffset)
					cdFrame.text:SetText(ceil(endTime - GetTime()))
				end
				if borderCustomColor[unitType] then
					cdFrame:SetBackdropBorderColor(unpack(db_icons.borderCustomColor))
				elseif db_icons.borderColor then
					if unitType == 'ENEMY_PLAYER' then
						cdFrame:SetBackdropBorderColor(1 - progress, progress)
					else
						cdFrame:SetBackdropBorderColor(progress, 1 - progress)
					end
				end
				tinsert(tracker.cooldowns, cdFrame)
			else
				if db.cooldownFill.enabled then
					cdFrame:fillOn(progress)
				end
				if db_text.enabled then
					cdFrame.text:SetText(ceil(cd.endTime - GetTime()))
				end
				if db_icons.borderColor then
					if unitType == 'ENEMY_PLAYER' then
						cdFrame:SetBackdropBorderColor(1 - progress, progress)
					else
						cdFrame:SetBackdropBorderColor(progress, 1 - progress)
					end
				end
			end
			local highlights = highlightedSpells[unitType]
			cdFrame.endTime = endTime
			cdFrame.startTime = startTime
			cdFrame.cooldowns = cooldowns
			cdFrame.highlight = highlights[cd.spellID] and highlights[cd.spellID] or highlights[cd.spellName]

			cdFrame.texture:SetTexture(cd.icon)
			cdFrame:SetScript("OnUpdate", onUpdates[unitType])

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
	local info = iconPositions[unitType][shown]
	local iconPos = info.positions
	local cooldowns = tracker.cooldowns

    for i = 1, shown do
        local cdFrame = cooldowns[i]
        cdFrame:ClearAllPoints()

		local position = iconPos[i]
		cdFrame:Point(position.point, tracker, position.point, position.xOffset, position.yOffset)

		local highlight = cdFrame.highlight
        if highlight then
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

function mod:ConstructCDTracker(db, plate)
	local tracker = plate.CDTracker
	if tracker then
		for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
			local data = db[unitType]
			if data.enabled then
				local typeFrame = (plate.CDTracker or {})[unitType]
				if not typeFrame then
					typeFrame = CreateFrame("Frame", nil, plate)
					typeFrame:SetFrameLevel(plate.Health:GetFrameLevel() + data.header.level)
					typeFrame:Hide()

					typeFrame.cooldowns = {}
					typeFrame.db = data
				end
				tracker[unitType] = typeFrame
			elseif (plate.CDTracker or {})[unitType] then
				plate.CDTracker[unitType]:Hide()
				plate.CDTracker[unitType] = nil
			end
		end
	else
		tracker = {}
		for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
			local data = db[unitType]
			if data.enabled then
				local typeFrame = CreateFrame("Frame", nil, plate)
				typeFrame:SetFrameLevel(plate.Health:GetFrameLevel() + data.header.level)
				typeFrame:Hide()

				typeFrame.cooldowns = {}
				typeFrame.db = data

				tracker[unitType] = typeFrame
			end
		end
	end
	return tracker
end

function mod:OnShow()
end


function mod:Toggle(db, visibilityUpdate)
	if not core.reload and (db['FRIENDLY_PLAYER'].enabled or db['ENEMY_PLAYER'].enabled) then
		if (not ElvUIGUIFrame or not self:IsHooked(ElvUIGUIFrame, "OnHide")) and not self:IsHooked(E, "ToggleOptionsUI") then
			self:SecureHook(E, "ToggleOptionsUI", function()
				if ElvUIGUIFrame and not self:IsHooked(ElvUIGUIFrame, "OnHide") then
					self:SecureHookScript(ElvUIGUIFrame, "OnHide", function()
						if testing then
							testing = false
							testMode(db)
						end
					end)
					self:Unhook(E, "ToggleOptionsUI")
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
			if not self:IsHooked(NP, "Construct_Highlight") then
				self:SecureHook(NP, "Construct_Highlight", function(_, plate)
					plate.CDTracker = mod:ConstructCDTracker(db, plate)
				end)
			end
			if not isAwesome then
				for event, unit in pairs({["UPDATE_MOUSEOVER_UNIT"] = 'mouseover', ["PLAYER_FOCUS_CHANGED"] = 'focus'}) do
					if not self:IsHooked(NP, event) then
						self:SecureHook(NP, event, function()
							if UnitExists(unit) then
								if not UnitIsPlayer(unit) then
									local name = UnitName(unit)
									local hash = (name or "")..'false'
									if activeCooldowns[hash] then
										for frame in pairs(NP.VisiblePlates) do
											local unitType = frame.UnitType
											if frame.UnitName == name and (unitType == "FRIENDLY_NPC" or unitType == "ENEMY_NPC") then
												mod:HandlePets(frame, name, unit)
											end
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
						if activeCooldowns[(name or "")..'false'] then
							for frame in pairs(NP.VisiblePlates) do
								if frame:GetParent():GetAlpha() == 1 then
									mod:HandlePets(frame, name, 'target')
								end
							end
						end
					end
				end)
			end
			self.OnShow = function(_, self)
				local plate = self.UnitFrame
				local playerName = plate.UnitName
				local unitType = plate.UnitType
				local isPlayer = unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER'

				plate.isPlayerString = tostring(isPlayer)

				for _, f in pairs(plate.CDTracker) do
					f:Hide()
				end

				local activeCds = activeCooldowns[playerName..plate.isPlayerString]
				if activeCds then
					for i = #activeCds, 1, -1 do
						if activeCds[i].endTime < GetTime() then
							tremove(activeCds, i)
						end
					end
					if next(activeCds) then
						if isPlayer then
							mod:AttachCooldowns(plate, activeCds, unitType)
						else
							mod:HandlePets(plate, playerName)
						end
					end
				end
			end
			if not self:IsHooked(NP, "OnShow") then self:SecureHook(NP, "OnShow") end
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLogEvent)
			core:RegisterNPElement('CDTracker', function(unitType, plate, element)
				if plate.CDTracker and (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
					for _, f in pairs(plate.CDTracker) do
						local points = db[unitType].header
						f:ClearAllPoints()
						f:Point(points.point, element, points.relativeTo, points.xOffset, points.yOffset)
					end
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
		testing = false
		core:RegisterAreaUpdate(modName)
		core:RegisterNPElement('CDTracker')
		self:UnregisterAllEvents()
		if ElvUIGUIFrame and self:IsHooked(ElvUIGUIFrame, "OnHide") then self:Unhook(ElvUIGUIFrame, "OnHide") end
		if self:IsHooked(E, "ToggleOptionsUI") then self:Unhook(E, "ToggleOptionsUI") end
		if self:IsHooked(NP, "Construct_Highlight") then self:Unhook(NP, "Construct_Highlight") end
		if self:IsHooked(NP, "OnShow") then
			if isAwesome or not core.reload then
				self:Unhook(NP, "OnShow")
			else
				self.OnShow = function() end
			end
		end
		for frame in pairs(NP.CreatedPlates) do
			local plate = frame.UnitFrame
			if plate and plate.CDTracker then
				for _, f in pairs(plate.CDTracker) do
					f:Hide()
				end
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