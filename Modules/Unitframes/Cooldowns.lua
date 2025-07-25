local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("CooldownsUF2", "AceHook-3.0", "AceEvent-3.0")
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI

local modName = mod:GetName()
local activeCooldowns, framelist, testing = {}, {}, false
local thinBorders = E:GetModule("UnitFrames").thinBorders
local edgeFile = LSM:Fetch("border", "ElvUI GlowBorder")

local allSpells = {}
local highlightedSpells = {
	["FRIENDLY_PLAYER"] = {},
	["ENEMY_PLAYER"] = {},
}
local compareFuncs = {
	["FRIENDLY_PLAYER"] = {},
	["ENEMY_PLAYER"] = {},
}
local borderCustomColor = {
	["FRIENDLY_PLAYER"] = {},
	["ENEMY_PLAYER"] = {},
}
local fills = {
	["FRIENDLY_PLAYER"] = {},
	["ENEMY_PLAYER"] = {},
}
local onUpdates = {
	["FRIENDLY_PLAYER"] = {},
	["ENEMY_PLAYER"] = {},
}

local typeList = {
	['player'] 	= true,
	['target'] 	= true,
	['focus'] 	= true,
	['arena'] 	= true,
	['party'] 	= true,
	['raid'] 	= true,
	['raid40'] 	= true,
}

local petList = {
	["player"] = 'pet',
	["target"] = 'target',
	["focus"] = 'focus',
}

mod.initialized = false
mod.activeCooldowns = activeCooldowns
mod.updatePending = false
mod.iconPositions = {
	["FRIENDLY_PLAYER"] = {},
	["ENEMY_PLAYER"] = {},
}
local scanTool = CreateFrame("GameTooltip", "ScanTooltipUF", nil, "GameTooltipTemplate")
scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")

local band = bit.band
local _G, pairs, ipairs, select, unpack, next = _G, pairs, ipairs, select, unpack, next
local tonumber, tostring, loadstring, setfenv = tonumber, tostring, loadstring, setfenv
local gsub, upper, match, find, format, trim = string.gsub, string.upper, string.match, string.find, string.format, string.trim
local random, floor, min, ceil, abs = math.random, math.floor, math.min, math.ceil, math.abs
local tinsert, tremove, tsort, twipe, tcontains = table.insert, table.remove, table.sort, table.wipe, tContains
local GetTime, CooldownFrame_SetTimer = GetTime, CooldownFrame_SetTimer
local GetSpellInfo, GetSpellLink = GetSpellInfo, GetSpellLink
local UnitName, UnitCanAttack, UnitIsPlayer, UnitExists = UnitName, UnitCanAttack, UnitIsPlayer, UnitExists
local COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER
local UNITNAME_SUMMON_TITLES = {gsub(format(UNITNAME_SUMMON_TITLE1, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE3, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE5, 1), '[%d%p%s]+', '')}

local iconPositions = mod.iconPositions

local function findOwner(unit)
	scanTool:ClearLines()
	scanTool:SetUnit(unit)
	local scanText = _G["ScanTooltipUFTextLeft2"]
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

for frameType, number in pairs({['arena'] = 5, ['party'] = 5, ['raid'] = 40}) do
	for i = 1, number do
		petList[frameType..i] = format("%s%s%s", frameType, i, 'pet')
	end
end


function mod:tagFunc(frame, unit)
	if tcontains(framelist, frame) then
		if frame.CDTracker then
			for _, f in pairs(frame.CDTracker) do
				f:Hide()
			end
		end
		local name = UnitName(unit)
		if name then
			if UnitIsPlayer(unit) then
				local cooldowns = activeCooldowns[name..'true']
				if frame.unitframeType ~= 'target' and frame.unitframeType ~= 'focus' then
					local petCooldowns = activeCooldowns[(UnitName(unit..'pet') or "")..'false']
					if petCooldowns and next(petCooldowns) then
						if not cooldowns then
							local hash = name..'true'
							activeCooldowns[hash] = {}
							cooldowns = activeCooldowns[hash]
						end
						for _, spellInfo in ipairs(petCooldowns) do
							tinsert(cooldowns, spellInfo)
						end
						twipe(petCooldowns)
					end
				end
				if cooldowns and next(cooldowns) then
					for i = #cooldowns, 1, -1 do
						if cooldowns[i].endTime < GetTime() then
							tremove(cooldowns, i)
						end
					end
					mod:AttachCooldowns(frame, cooldowns)
				end
			else
				local petCooldowns = activeCooldowns[name..'false']
				if petCooldowns and next(petCooldowns) then
					local ownerName = UnitOwner(unit)
					if ownerName then
						local hash = ownerName..'true'
						local cooldowns = activeCooldowns[hash]
						if not cooldowns then
							activeCooldowns[hash] = {}
							cooldowns = activeCooldowns[hash]
						end
						for _, spellInfo in ipairs(petCooldowns) do
							tinsert(cooldowns, spellInfo)
						end
						twipe(petCooldowns)
						for _, frame in ipairs(framelist) do
							if frame.unit and UnitName(frame.unit) == ownerName then
								mod:AttachCooldowns(frame, cooldowns)
							end
						end
					end
				end
			end
		end
	end
end


local function updateVisibilityState(db, areaType)
	local isShown = false
	for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
		for _, frameType in ipairs({'target', 'player', 'focus', 'raid', 'raid40', 'party', 'arena'}) do
			local data = db[unitType].units[frameType]
			if data then
				if data.enabled then
					isShown = isShown or data['showAll'] or data[areaType]
					data.isShown = data['showAll'] or data[areaType]
				else
					data.isShown = false
				end
			end
		end
	end
	return isShown
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

	for _, frame in ipairs(framelist) do
		if frame.CDTracker then
			for _, f in pairs(frame.CDTracker) do
				f:Hide()
			end
		end
	end
	if not testing then return end

    local spellList = {}
    local testSpells = {}

	for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
		for _, data in pairs(db[unitType].units) do
			for id, cdTime in pairs(data.spellList) do
				spellList[id] = cdTime
			end
		end
	end
    if not next(spellList) then return end

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

	for _, frame in ipairs(framelist) do
		local unit = frame.unit
		local data = db[db.selectedType].units[frame.unitframeType]
		local name = UnitName(unit)
		if data and data.enabled and unit and name and UnitIsPlayer(unit) then
			activeCooldowns[name..'true'] = testSpells
			mod:AttachCooldowns(frame, testSpells)
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

						local frame = self:GetParent():GetParent()
						local cooldowns = self.cooldowns
						for i = #cooldowns, 1, -1 do
							if cooldowns[i].endTime < GetTime() then
								tremove(cooldowns, i)
							end
						end
						if next(cooldowns) then
							mod:AttachCooldowns(frame, cooldowns)
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
			(db.cooldownFill.enabled and not db.cooldownFill.classic) and "self:fillOn(progress)" or "",
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


local function cache(db, frameType, visibilityUpdate)
	for unitType in pairs(iconPositions) do
		local data = db[unitType].units[frameType]
		if data then
			if data.isShown then
				for id, cdTime in pairs(data.spellList) do
					allSpells[id] = cdTime
				end
			end

			if not visibilityUpdate then
				local icons = data.icons
				local perRow, spacing, direction, size = icons.perRow, icons.spacing, icons.direction, icons.size
				local offset = size + spacing
				local point = oppositeDirections[direction]
				local dirProps = directionProperties[direction]
				local isCentered, isVertical, isReverseX, isReverseY = dirProps.isCentered, dirProps.isVertical, dirProps.isReverseX, dirProps.isReverseY
				local t = iconPositions[unitType][frameType]

				if t then
					twipe(t)
				else
					iconPositions[unitType][frameType] = {}
					t = iconPositions[unitType][frameType]
				end

				for shown = 1, icons.maxRows * perRow do
					local numRows = ceil(shown / perRow)
					local numCols = min(shown, perRow)
					local trackerWidth = isVertical and (numRows * offset - spacing) or (numCols * offset - spacing)
					local trackerHeight = isVertical and (numCols * offset - spacing) or (numRows * offset - spacing)

					t[shown] = {
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
						t[shown].positions[i] = {point = point, xOffset = xOffset, yOffset = yOffset}
					end
				end
				compareFuncs[unitType][frameType] = createCompareFunction(icons.sorting, icons.trinketOnTop)
				borderCustomColor[unitType][frameType] =
					not icons.borderColor and (icons.borderCustomColor[1] > 0 or icons.borderCustomColor[2] > 0 or icons.borderCustomColor[3] > 0)
				fills[unitType][frameType] = createFillFunction(data.cooldownFill, icons)
				onUpdates[unitType][frameType] = createOnUpdateFunction(data, unitType)
			end
		end
	end
end


P["Extras"]["unitframes"][modName] = {
	["selectedUnit"] = 'target',
	["selectedType"] = 'FRIENDLY_PLAYER',
	["FRIENDLY_PLAYER"] = {
		["selectedSpell"] = '',
		["highlightedSpells"] = {},
		["units"] = {
			["target"] = {
				["enabled"] = false,
				["spellList"] = {},
				["header"] = {
					["point"] = "RIGHT",
					["relativeTo"] = "LEFT",
					["xOffset"] = -4,
					["yOffset"] = 0,
					["level"] = 35,
					["strata"] = 'LOW',
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
					["classic"] = false,
					["direction"] = "LEFT",
					["reversed"] = false,
				},
			},
		},
	},
}

function mod:LoadConfig(db)
	local function selectedUnit() return db.selectedUnit end
	local function selectedType() return db.selectedType end
	local function selectedSpell() return selectedType() and tonumber(db[selectedType()].selectedSpell) or db[selectedType()].selectedSpell or "" end
	local function selectedTypeData()
		return core:getSelected("unitframes", modName, format("[%s]", selectedType() or ""), "FRIENDLY_PLAYER")
	end
	local function selectedUnitData()
		return core:getSelected("unitframes", modName, format("%s.units[%s]", selectedType(), selectedUnit() or ""), "target")
	end
	local function highlightedSpellsData()
		return core:getSelected("unitframes", modName, format("%s.highlightedSpells[%s]", selectedType(), selectedSpell()), "")
	end
	core.unitframes.args[modName] = {
		type = "group",
		name = L["Cooldowns"],
		args = {
			Cooldowns = {
				order = 0,
				type = "group",
				name = L["Cooldowns"],
				guiInline = true,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Draws player cooldowns."],
						get = function(info) return selectedUnitData()[info[#info]] end,
						set = function(info, value)
							selectedUnitData()[info[#info]] = value
							if not value and testing then
								testing = false
								testMode(db)
							end
							self:Toggle(db)
						end,
						disabled = false,
					},
					testMode = {
						order = 1,
						type = "execute",
						name = L["Test Mode"],
						desc = "",
						func = function() self:Toggle(db)
							if testing then
								testing = false
							else
								testing = db.selectedType
							end
							testMode(db)
						end,
					},
					selectedUnit = {
						order = 3,
						type = "select",
						disabled = false,
						name = L["Select Unit"],
						desc = "",
						values = function() return core:GetUnitDropdownOptions(db[selectedType()].units) end,
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value end,
					},
					selectedType = {
						order = 4,
						type = "select",
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
						set = function(info, value)
							db[info[#info]] = value
							db.selectedUnit = 'target'
							if testing then
								self:Toggle(db)
								testMode(db)
							end
						end,
						disabled = false,
					},
				},
			},
			visibility = {
				order = 1,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info]] end,
				set = function(info, value)
					local data = selectedUnitData()
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
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					showAll = {
						order = 1,
						type = "toggle",
						name = L["Show Everywhere"],
						desc = "",
						set = function(info, value)
							local data = selectedUnitData()
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
						hidden = function() return selectedUnitData().showAll end,
					},
					showBG = {
						order = 3,
						type = "toggle",
						name = L["Show in Battlegrounds"],
						desc = "",
						hidden = function() return selectedUnitData().showAll end,
					},
					showArena = {
						order = 4,
						type = "toggle",
						name = L["Show in Arenas"],
						desc = "",
						hidden = function() return selectedUnitData().showAll end,
					},
					showInstance = {
						order = 5,
						type = "toggle",
						name = L["Show in Instances"],
						desc = "",
						hidden = function() return selectedUnitData().showAll end,
					},
					showWorld = {
						order = 6,
						type = "toggle",
						name = L["Show in the World"],
						desc = "",
						hidden = function() return selectedUnitData().showAll end,
					},
				},
			},
			header = {
				type = "group",
				name = L["Header"],
				guiInline = true,
				get = function(info) return selectedUnitData()[info[#info-1]][info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info-1]][info[#info]] = value self:Toggle(db) end,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					level = {
						order = 0,
						type = "range",
						name = L["Level"],
						desc = "",
						min = 1, max = 200, step = 1
					},
					strata = {
						order = 1,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
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
				get = function(info) return selectedUnitData()[info[#info-1]][info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info-1]][info[#info]] = value self:Toggle(db) end,
				disabled = function() return not selectedUnitData().enabled end,
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
						get = function(info) return unpack(selectedUnitData()[info[#info-1]].borderCustomColor) end,
						set = function(info, r, g, b) selectedUnitData()[info[#info-1]].borderCustomColor = {r, g, b} self:Toggle(db) end,
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
				get = function(info) return selectedUnitData()[info[#info-1]][info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info-1]][info[#info]] = value self:Toggle(db) end,
				disabled = function() return not selectedUnitData().enabled end,
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
				get = function(info) return selectedUnitData()[info[#info-1]][info[#info]] end,
				set = function(info, value) selectedUnitData()[info[#info-1]][info[#info]] = value self:Toggle(db) end,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						width = "full",
						name = L["Show"],
						desc = "",
					},
					classic = {
						order = 1,
						type = "toggle",
						name = L["Classic Style"],
						desc = L["If enabled, default cooldown style will be used."],
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
						disabled = function() return not selectedUnitData().enabled or selectedUnitData().cooldownFill.classic end,
					},
				},
			},
			spells = {
				type = "group",
				name = L["Spells"],
				guiInline = true,
				disabled = function() return not selectedUnitData().enabled end,
				args = {
					addSpell = {
						order = 1,
						type = "input",
						name = L["Add Spell"],
						desc = L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"],
						get = function() return "" end,
						set = function(_, value)
							local spellID, cooldownTime = trim(match(value, '(.*)%s+(%d*)'))
							if spellID then
								cooldownTime = tonumber(cooldownTime) or LAI.spellDuration[spellID]
								if not cooldownTime then return end
								selectedUnitData().spellList[tonumber(spellID) or spellID] = cooldownTime
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
							selectedUnitData().spellList[spellID] = nil
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
						end,
						disabled = function() return not selectedUnitData().spellList[selectedSpell()] end,
					},
					copyList = {
						order = 3,
						type = "select",
						width = "double",
						name = L["Copy List"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							if core.SpellLists[value] then
								local list = selectedUnitData().spellList
								twipe(list)
								for id, cdTime in pairs(core.SpellLists[value]) do
									list[id == 47860 and id or GetSpellInfo(id)] = cdTime
								end
							else
								local unit, unitType = match(value, "(%l+)(.+)")
								selectedUnitData().spellList = CopyTable(db[unitType].units[unit].spellList)
							end
							self:Toggle(db)
						end,
						values = function()
							local values = {}
							for listType in pairs(core.SpellLists) do
								values[listType] = L[listType]
							end
							for unitType, typeName in pairs({["FRIENDLY_PLAYER"] = "Friendly", ["ENEMY_PLAYER"] = "Enemy"}) do
								for unit in pairs(db[unitType].units) do
									values[unit..unitType] = format("%s (%s)", L[unit], L[typeName])
								end
							end
							values[selectedUnit()..tostring(selectedType())] = nil
							return values
						end,
						sorting = function()
							local sortedValues = {}
							local currUnit, currType = selectedUnit(), selectedType()
							for listType in pairs(core.SpellLists) do
								if listType ~= "PETS" then
									tinsert(sortedValues, listType)
								end
							end
							for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
								for unit in pairs(db[unitType].units) do
									if currUnit ~= unit or currType ~= unitType then
										tinsert(sortedValues, unit..unitType)
									end
								end
							end
							tsort(sortedValues, function(a,b)
								if a == "DEFAULTS" then
									return true
								elseif b == "DEFAULTS" then
									return false
								else
									local hasLowerA = match(a, "%l")
									local hasLowerB = match(b, "%l")

									if not hasLowerA and hasLowerB then
										return true
									elseif hasLowerA and not hasLowerB then
										return false
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
								selectedTypeData().highlightedSpells[selectedSpell()] = { ["enabled"] = false, ["size"] = 1, ["color"] = {0,0,0,1} }
							end
						end,
						values = function()
							local values = {}
							for id in pairs(selectedUnitData().spellList) do
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
							for id in pairs(selectedUnitData().spellList) do
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
						set = function(_, value) highlightedSpellsData().enabled = value self:Toggle(db) end,
						disabled = function() return not selectedUnitData().enabled or selectedSpell() == "" end,
					},
					shadowSize = {
						order = 6,
						type = "range",
						name = L["Shadow Size"],
						desc = "",
						min = 1, max = 12, step = 1,
						get = function() return selectedSpell() ~= "" and highlightedSpellsData().size or 0 end,
						set = function(_, value) highlightedSpellsData().size = value self:Toggle(db) end,
						hidden = function()
							return not selectedUnitData().enabled or selectedSpell() == "" or not highlightedSpellsData().enabled
						end,
					},
					shadowColor = {
						order = 7,
						type = "color",
						hasAlpha = true,
						name = L["Shadow Color"],
						desc = "",
						get = function() return unpack(selectedSpell() ~= "" and highlightedSpellsData().color or {}) end,
						set = function(_, r, g, b, a) highlightedSpellsData().color = {r, g, b, a} self:Toggle(db) end,
						hidden = function()
							return not selectedUnitData().enabled or selectedSpell() == "" or not highlightedSpellsData().enabled
						end,
					},
				},
			},
		},
	}
	if not next(db['FRIENDLY_PLAYER'].units.target.spellList) then
		for id, cdTime in pairs(core.SpellLists["DEFAULTS"]) do
			db['FRIENDLY_PLAYER'].units.target.spellList[id == 47860 and id or GetSpellInfo(id)] = cdTime
		end
	end
	if not db['FRIENDLY_PLAYER'].units.player then
		for _, unitframeType in ipairs({'player', 'focus', 'raid', 'raid40', 'party'}) do
			db['FRIENDLY_PLAYER'].units[unitframeType] = CopyTable(db['FRIENDLY_PLAYER'].units.target)
		end
	end
	if not db['ENEMY_PLAYER'] then
		db['ENEMY_PLAYER'] = CopyTable(db['FRIENDLY_PLAYER'])
		for _, unitframeType in ipairs({'player', 'raid', 'raid40', 'party'}) do
			db['ENEMY_PLAYER'].units[unitframeType] = nil
		end
		db['ENEMY_PLAYER'].units['arena'] = CopyTable(db['FRIENDLY_PLAYER'].units.target)
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
    self:UpdateFrames(playerName, isPlayer, hash)
end

function mod:HandlePets(petName)
	for ownerID, petID in pairs(petList) do
		if UnitName(petID) == petName then
			local isTargetOrFocus = ownerID == 'target' or ownerID == 'focus'
			local ownerName
			if not isTargetOrFocus then
				ownerName = UnitName(ownerID)
			else
				ownerName = UnitOwner(ownerID)
			end
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
				if isTargetOrFocus then
					for _, frame in ipairs(framelist) do
						if frame.unit and UnitName(frame.unit) == ownerName
								and (ownerID ~= 'target' or frame.unit ~= 'target') and (ownerID ~= 'focus' or frame.unit ~= 'focus') then
							self:AttachCooldowns(frame, cooldowns)
						end
					end
				else
					for _, frame in ipairs(framelist) do
						if frame.unit and UnitName(frame.unit) == ownerName then
							self:AttachCooldowns(frame, cooldowns)
						end
					end
				end
				return
			end
		end
	end
end

function mod:UpdateFrames(playerName, isPlayer, hash)
	if not isPlayer then
		self:HandlePets(playerName)
	else
		for _, frame in ipairs(framelist) do
			local unit = frame.unit
			if unit and UnitName(unit) == playerName then
				local cooldowns = activeCooldowns[hash]
				if cooldowns and next(cooldowns) then
					self:AttachCooldowns(frame, cooldowns)
				end
			end
		end
	end
end

function mod:AttachCooldowns(frame, cooldowns)
	local unitType = testing or (frame.unit and (UnitCanAttack('player', frame.unit) and "ENEMY_PLAYER" or "FRIENDLY_PLAYER"))
	local tracker = frame.CDTracker[unitType]

	if not tracker or not tracker.db.isShown then return end

	local db = tracker.db
	local frameType = frame.unitframeType
	local db_icons = db.icons
	local db_text = db.text
	local db_cooldownFill = db.cooldownFill
	local db_spellList = db.spellList

	tsort(cooldowns, compareFuncs[unitType][frameType])

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
				cdFrame:Size(db_icons.size, db_icons.size)
				cdFrame:SetTemplate(nil, nil, nil, thinBorders, true)
				cdFrame.texture = cdFrame:CreateTexture(nil, "ARTWORK")
				cdFrame.texture:SetInside(cdFrame, E.mult, E.mult)
				cdFrame.shadow = CreateFrame("Frame", nil, cdFrame)
				cdFrame.shadow:SetFrameLevel(db.header.level - 1)
				if db_cooldownFill.enabled then
					if db_cooldownFill.classic then
						cdFrame.cooldown = CreateFrame("Cooldown", "$parentCD", cdFrame, "CooldownFrameTemplate")
						cdFrame.cooldown:SetAllPoints(cdFrame.texture)
						if db_cooldownFill.reversed then
							cdFrame.cooldown:SetReverse(true)
						else
							cdFrame.cooldown:SetReverse(false)
						end
						CooldownFrame_SetTimer(cdFrame.cooldown, startTime, endTime - startTime, 1)
						cdFrame.classicTimer = true
					else
						cdFrame.fill = cdFrame:CreateTexture(nil, "OVERLAY")
						cdFrame.fill:SetTexture(0, 0, 0, db_cooldownFill.alpha or 0.8)
						cdFrame.fillOn = fills[unitType][frameType]
						cdFrame:fillOn(progress)
					end
				end
				if db_text.enabled then
					cdFrame.text = ((db_cooldownFill.enabled and db_cooldownFill.classic) and cdFrame.cooldown
									or cdFrame):CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
					cdFrame.text:SetFont(LSM:Fetch("font", db_text.font), db_text.size, db_text.flag)
					cdFrame.text:Point("CENTER", cdFrame, "CENTER", db_text.xOffset, db_text.yOffset)
					cdFrame.text:SetText(ceil(cd.endTime - GetTime()))
				end
				if borderCustomColor[unitType][frameType] then
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
				if cdFrame.classicTimer then
					CooldownFrame_SetTimer(cdFrame.cooldown, startTime, endTime - startTime, 1)
				elseif db_cooldownFill.enabled then
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
			cdFrame:SetScript("OnUpdate", onUpdates[unitType][frameType])

			shown = shown + 1
		end
    end

	if shown == 0 then
		tracker:Hide()
	else
		for i = shown+1, #tracker.cooldowns do
			tracker.cooldowns[i]:Hide()
		end
		self:RepositionIcons(tracker, shown, unitType, frameType)
	end
end

function mod:RepositionIcons(tracker, shown, unitType, frameType)
	local info = iconPositions[unitType][frameType][shown]
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

function mod:SetupCDTracker(db, frame, frameType)
	local tracker = frame.CDTracker
	if tracker then
		for _, f in pairs(tracker) do
			for i = #f.cooldowns, 1, -1 do
				f.cooldowns[i]:Hide()
				f.cooldowns[i] = nil
			end
			f:Hide()
		end
		twipe(tracker)
	else
		tracker = {}
	end

	if frameType == 'target' or frameType == 'focus' then
		for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
			local db_type = db[unitType].units[frameType]
			if db_type.enabled then
				local typeFrame = CreateFrame("Frame", nil, frame)

				local db_header = db_type.header
				typeFrame:ClearAllPoints()
				typeFrame:Point(db_header.point, frame, db_header.relativeTo, db_header.xOffset, db_header.yOffset)
				typeFrame:SetFrameLevel(db_header.level)
				typeFrame:SetFrameStrata(db_header.strata)

				typeFrame:Hide()

				typeFrame.cooldowns = {}
				typeFrame.db = db_type

				tracker[unitType] = typeFrame

				if not tcontains(framelist, frame) then
					tinsert(framelist, frame)
				end
			end
		end
	else
		local unitType = frameType == 'arena' and "ENEMY_PLAYER" or "FRIENDLY_PLAYER"
		local db_type = db[unitType].units[frameType]
		if db_type and db_type.enabled then
			local typeFrame = CreateFrame("Frame", nil, frame)

			local db_header = db_type.header
			typeFrame:ClearAllPoints()
			typeFrame:Point(db_header.point, frame, db_header.relativeTo, db_header.xOffset, db_header.yOffset)
			typeFrame:SetFrameLevel(db_header.level)
			typeFrame:SetFrameStrata(db_header.strata)

			typeFrame:Hide()

			typeFrame.cooldowns = {}
			typeFrame.db = db_type

			tracker[unitType] = typeFrame

			tinsert(framelist, frame)
		end
	end
	return tracker
end


function mod:SetupCooldowns(db, visibilityUpdate)
	if not visibilityUpdate then
		twipe(highlightedSpells["FRIENDLY_PLAYER"])
		twipe(highlightedSpells["ENEMY_PLAYER"])

		for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
			for spellID, info in pairs(db[unitType].highlightedSpells or {}) do
				if info.enabled then
					highlightedSpells[unitType][spellID] = info
				end
			end
		end
		twipe(framelist)
		twipe(iconPositions["FRIENDLY_PLAYER"])
		twipe(iconPositions["ENEMY_PLAYER"])
	end
	twipe(allSpells)

	for _, frame in ipairs(core:AggregateUnitFrames()) do
		local frameType = frame.unitframeType
		if typeList[frameType] then
			cache(db, frameType, visibilityUpdate)

			if not visibilityUpdate then
				frame.CDTracker = self:SetupCDTracker(db, frame, frameType)

				local unit = frame.unit
				if unit then
					local db_type = db[testing or (UnitCanAttack('player', unit) and "ENEMY_PLAYER" or "FRIENDLY_PLAYER")].units[frameType]

					if db_type and db_type.enabled and db_type.isShown then
						local cooldowns = activeCooldowns[(UnitName(unit) or "")..'true']
						if UnitExists(unit) then
							if UnitIsPlayer(unit) and cooldowns and next(cooldowns) then
								self:AttachCooldowns(frame, cooldowns)
							end
						end
					elseif frame.CDTracker then
						for _, f in pairs(frame.CDTracker) do
							f:Hide()
						end
					end
				end
			end
		end
	end
end

function mod:Toggle(db)
	local enabled = false

	if not core.reload then
		for _, unitType in ipairs({"FRIENDLY_PLAYER", "ENEMY_PLAYER"}) do
			for _, info in pairs(db[unitType].units) do
				if info.enabled then
					enabled = true
					break
				end
			end
		end
	end

	if enabled then
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
			scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")
			local currentArea = core:GetCurrentAreaType()
			if currentArea == "showArena" then
				twipe(activeCooldowns)
			end
			if updateVisibilityState(db, currentArea) then
				self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLogEvent)
			else
				self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			end
			self:SetupCooldowns(db, true)
		end)
		if updateVisibilityState(db, core:GetCurrentAreaType()) then
			self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", combatLogEvent)
		else
			self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		self:SetupCooldowns(db)
		core:Tag("cooldowns", self.tagFunc, function()
			if not self.updatePending then
				self.updatePending = E:ScheduleTimer(function() self:SetupCooldowns(db) self.updatePending = false end, 0.1)
			else
				E:CancelTimer(self.updatePending)
				self.updatePending = E:ScheduleTimer(function() self:SetupCooldowns(db) self.updatePending = false end, 0.1)
			end
		end)
		self.initialized = true
	elseif self.initialized then
		testing = false
		if ElvUIGUIFrame and self:IsHooked(ElvUIGUIFrame, "OnHide") then self:Unhook(ElvUIGUIFrame, "OnHide") end
		if self:IsHooked(E, "ToggleOptionsUI") then self:Unhook(E, "ToggleOptionsUI") end
		self:UnregisterAllEvents()
		core:RegisterAreaUpdate(modName)
		for _, frame in ipairs(framelist) do
			if frame.CDTracker then
				for _, f in pairs(frame.CDTracker) do
					f:Hide()
				end
				frame.CDTracker = nil
			end
		end
		core:Untag("cooldowns")
	end
end

function mod:InitializeCallback()
	if not E.private.unitframe.enable then return end

	local db = E.db.Extras.unitframes[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback