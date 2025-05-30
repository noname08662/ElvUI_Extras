local _, ns = ...
-- modified
local E = unpack(ElvUI)
local oUF = E.oUF or ns.oUF
assert(oUF, "oUF FloatingCombatFeedback was unable to locate oUF install")

local _G = getfenv(0)
local b_and = _G.bit.band
local m_cos = _G.math.cos
local m_pi = _G.math.pi
local m_random = _G.math.random
local m_sin = _G.math.sin
local next = _G.next
local select = _G.select
local tostring = _G.tostring
local t_insert = _G.table.insert
local t_remove = _G.table.remove
local t_wipe = _G.table.wipe
local type = _G.type
local gsub, format = string.gsub, string.format

local UnitGUID = _G.UnitGUID
local GetSpellInfo = _G.GetSpellInfo

-- modified
local function AbbreviateNumbers(value)
    local retString = value

    if value >= 1e9 then
        retString = format("%.1fB", value / 1e9)
    elseif value >= 1e6 then
        retString = format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        retString = format("%.1fK", value / 1e3)
    end

    -- Ensure there is no trailing '.0'
    retString = gsub(retString, "%.0([BKM])", "%1")

    return retString
end

-- modified
local function BreakUpLargeNumbers(num)
    local formatted = tostring(num)
    local k
    while true do
        formatted, k = gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

local function copyTable(src, dst)
	if type(dst) ~= "table" then
		dst = {}
	end

	for k, v in next, src do
		if type(v) == "table" then
			dst[k] = copyTable(v, dst[k])
		else
			if dst[k] == nil then
				dst[k] = v
			end
		end
	end

	return dst
end

local function clamp(v)
	if v > 1 then
		return 1
	elseif v < 0 then
		return 0
	end

	return v
end

-- sourced from FrameXML/Constants.lua
local SCHOOL_MASK_NONE = _G.SCHOOL_MASK_NONE or 0x00
local SCHOOL_MASK_PHYSICAL = _G.SCHOOL_MASK_PHYSICAL or 0x01
local SCHOOL_MASK_HOLY = _G.SCHOOL_MASK_HOLY or 0x02
local SCHOOL_MASK_FIRE = _G.SCHOOL_MASK_FIRE or 0x04
local SCHOOL_MASK_NATURE = _G.SCHOOL_MASK_NATURE or 0x08
local SCHOOL_MASK_FROST = _G.SCHOOL_MASK_FROST or 0x10
local SCHOOL_MASK_SHADOW = _G.SCHOOL_MASK_SHADOW or 0x20
local SCHOOL_MASK_ARCANE = _G.SCHOOL_MASK_ARCANE or 0x40

-- multi-schools
local SCHOOL_MASK_ASTRAL = SCHOOL_MASK_ARCANE + SCHOOL_MASK_NATURE
local SCHOOL_MASK_CHAOS = SCHOOL_MASK_ARCANE + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY + SCHOOL_MASK_NATURE + SCHOOL_MASK_PHYSICAL + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_ELEMENTAL = SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_NATURE
local SCHOOL_MASK_MAGIC =  SCHOOL_MASK_ARCANE + SCHOOL_MASK_FIRE + SCHOOL_MASK_FROST + SCHOOL_MASK_HOLY + SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_PLAGUE = SCHOOL_MASK_NATURE + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_RADIANT = SCHOOL_MASK_FIRE + SCHOOL_MASK_HOLY
local SCHOOL_MASK_SHADOWFLAME = SCHOOL_MASK_FIRE + SCHOOL_MASK_SHADOW
local SCHOOL_MASK_SHADOWFROST = SCHOOL_MASK_FROST + SCHOOL_MASK_SHADOW

local function rgb(r, g, b)
	return {r = r / 255, g = g / 255, b = b /255}
end

local colors = {
	["ABSORB"   ] = rgb(255, 255, 255),
	["BLOCK"    ] = rgb(255, 255, 255),
	["DEFLECT"  ] = rgb(255, 255, 255),
	["DODGE"    ] = rgb(255, 255, 255),
	["ENERGIZE" ] = rgb(105, 204, 240),
	["EVADE"    ] = rgb(255, 255, 255),
	["HEAL"     ] = rgb(26, 204, 26),
	["IMMUNE"   ] = rgb(255, 255, 255),
	["INTERRUPT"] = rgb(255, 255, 255),
	["MISS"     ] = rgb(255, 255, 255),
	["PARRY"    ] = rgb(255, 255, 255),
	["REFLECT"  ] = rgb(255, 255, 255),
	["RESIST"   ] = rgb(255, 255, 255),
	["WOUND"    ] = rgb(179, 26, 26),
	["AURA"    	] = rgb(255, 255, 255),
}

local schoolColors = {
	[SCHOOL_MASK_ARCANE     ] = rgb(255, 128, 255),
	[SCHOOL_MASK_FIRE       ] = rgb(255, 128, 000),
	[SCHOOL_MASK_FROST      ] = rgb(128, 255, 255),
	[SCHOOL_MASK_HOLY       ] = rgb(255, 230, 128),
	[SCHOOL_MASK_NATURE     ] = rgb(77, 255, 77),
	[SCHOOL_MASK_NONE       ] = rgb(255, 255, 255),
	[SCHOOL_MASK_PHYSICAL   ] = rgb(179, 26, 26),
	[SCHOOL_MASK_SHADOW     ] = rgb(128, 128, 255),
	-- multi-schools
	[SCHOOL_MASK_ASTRAL     ] = rgb(166, 192, 166),
	[SCHOOL_MASK_CHAOS      ] = rgb(182, 164, 142),
	[SCHOOL_MASK_ELEMENTAL  ] = rgb(153, 212, 111),
	[SCHOOL_MASK_MAGIC      ] = rgb(183, 187, 162),
	[SCHOOL_MASK_PLAGUE     ] = rgb(103, 192, 166),
	[SCHOOL_MASK_RADIANT    ] = rgb(255, 178, 64),
	[SCHOOL_MASK_SHADOWFLAME] = rgb(192, 128, 128),
	[SCHOOL_MASK_SHADOWFROST] = rgb(128, 192, 255),
}

local tryToColorBySchool = {
	["ABSORB"   ] = false,
	["BLOCK"    ] = false,
	["DEFLECT"  ] = false,
	["DODGE"    ] = false,
	["ENERGIZE" ] = false,
	["EVADE"    ] = false,
	["HEAL"     ] = false,
	["IMMUNE"   ] = false,
	["INTERRUPT"] = false,
	["MISS"     ] = false,
	["PARRY"    ] = false,
	["REFLECT"  ] = false,
	["RESIST"   ] = false,
	["WOUND"    ] = true,
	["AURA"    	] = false,
}

local animations = {
	["fountain"] = function(self)
		return self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),
			self.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress)
	end,
	["vertical"] = function(self)
		return self.x,
			self.y + self.yDirection * self.radius * self.progress
	end,
	["horizontal"] = function(self)
		return self.x + self.xDirection * self.radius * self.progress,
			self.y
	end,
	["diagonal"] = function(self)
		return self.x + self.xDirection * self.radius * self.progress,
			self.y + self.yDirection * self.radius * self.progress
	end,
	["static"] = function(self)
		return self.x, self.y
	end,
	["random"] = function(self)
		if self.elapsed == 0 then
			self.x, self.y = m_random(-self.radius * 0.66, self.radius * 0.66), m_random(-self.radius * 0.66, self.radius * 0.66)
		end

		return self.x, self.y
	end,
}

local animationsByEvent = {
	["ABSORB"   ] = {"fountain", true, true},
	["BLOCK"    ] = {"fountain", true, true},
	["DEFLECT"  ] = {"fountain", true, true},
	["DODGE"    ] = {"fountain", true, true},
	["ENERGIZE" ] = {"fountain", true, true},
	["EVADE"    ] = {"fountain", true, true},
	["HEAL"     ] = {"fountain", true, true},
	["IMMUNE"   ] = {"fountain", true, true},
	["INTERRUPT"] = {"fountain", true, true},
	["MISS"     ] = {"fountain", true, true},
	["PARRY"    ] = {"fountain", true, true},
	["REFLECT"  ] = {"fountain", true, true},
	["RESIST"   ] = {"fountain", true, true},
	["WOUND"    ] = {"fountain", true, true},
	["AURA"    	] = {"fountain", true, true},
}

local animationsByFlag = {
	["ABSORB"  		] = {false, false, false},
	["BLOCK"   		] = {false, false, false},
	["CRITICAL"		] = {false, false, false},
	["CRUSHING"		] = {false, false, false},
	["GLANCING"		] = {false, false, false},
	["RESIST"  		] = {false, false, false},
	["PERIODICWOUND"] = {false, false, false},
	["NOFLAGWOUND"  ] = {false, false, false},
	["PERIODICHEAL" ] = {false, false, false},
	["NOFLAGHEAL"   ] = {false, false, false},
}

local multipliersByFlag = {
	[""       		] = 1,
	["ABSORB"  		] = 0.75,
	["BLOCK"  		] = 0.75,
	["CRITICAL"		] = 1.25,
	["CRUSHING"		] = 1.25,
	["GLANCING"		] = 0.75,
	["RESIST"  		] = 0.75,
	["PERIODICWOUND"] = 0.75,
	["NOFLAGWOUND"  ] = 1,
	["PERIODICHEAL" ] = 0.75,
	["NOFLAGHEAL"   ] = 1,
}

local xOffsetsByAnimation = {
	["diagonal"  ] = 24,
	["fountain"  ] = 24,
	["horizontal"] = 8,
	["random"    ] = 0,
	["static"    ] = 0,
	["vertical"  ] = 8,
}

local yOffsetsByAnimation = {
	["diagonal"  ] = 8,
	["fountain"  ] = 8,
	["horizontal"] = 8,
	["random"    ] = 0,
	["static"    ] = 0,
	["vertical"  ] = 8,
}

local function removeString(self, i, string)
	t_remove(self.FeedbackToAnimate, i)
	string:SetText(nil)
	string:SetAlpha(0)
	string:Hide()

	return string
end

local function getString(self)
	for i = 1, #self do
		if not self[i]:IsShown() then
			return self[i]
		end
	end

	return removeString(self, 1, self.FeedbackToAnimate[1])
end

local function onUpdate(self, elapsed)
	for index, string in next, self.FeedbackToAnimate do
		if string.elapsed >= string.scrollTime then
			removeString(self, index, string)
		else
			string.progress = string.elapsed / string.scrollTime
			local x, y = string:GetXY()
			string:SetPoint(string.point, self, string.relativeTo, x + string.fontX, y + string.fontY)

			string.elapsed = string.elapsed + elapsed
			string:SetAlpha(clamp(1 - (string.elapsed - string.fadeTime) / (string.scrollTime - string.fadeTime)))
		end
	end

	if #self.FeedbackToAnimate == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

local function flush(self)
	t_wipe(self.FeedbackToAnimate)

	for i = 1, #self do
		self[i]:SetText(nil)
		self[i]:SetAlpha(0)
		self[i]:Hide()
	end
end

local function Update(self, _, unit, isPlayer, event, flag, amount, school, texture, spellId)
	if self.unit ~= unit then return end
	local element = self.FloatingCombatFeedback

	if event ~= "BUFF" and event ~= "DEBUFF" then
		if (flag and not element.multipliersByFlag[flag])
			or (element.playerOnlyEvents[event] and not isPlayer) then return end
	elseif next(element.filterAuras[event]) and not (element.filterAuras[event][spellId] or element.filterAuras[event][GetSpellInfo(spellId)]) then
		return
	end

	local animation, fontData = element.animationsByEvent[event], element.fontData[event]
	if not animation or not fontData then return end

	local color = element.tryToColorBySchool[event] and element.schoolColors[school] or element.colors[event]
	local text

	if event == "WOUND" then
		if amount ~= 0 then
			text = element.abbreviateNumbers and AbbreviateNumbers(amount) or BreakUpLargeNumbers(amount)
		elseif flag ~= "" and flag ~= "CRITICAL" and flag ~= "CRUSHING" and flag ~= "GLANCING" then
			text = _G[flag]
		end
	else
		if amount ~= 0 then
			text = element.abbreviateNumbers and AbbreviateNumbers(amount) or BreakUpLargeNumbers(amount)
		else
			text = _G[event] or flag
		end
	end

	if text then
		local string = getString(element)
		local flagAnimation = element.animationsByFlag[flag]
		local xDirection, yDirection

		if flagAnimation then
			xDirection, yDirection = flagAnimation[2], flagAnimation[3]
			if flagAnimation[4] then
				flagAnimation[2] = flagAnimation[2] * -1
			end
			if flagAnimation[5] then
				flagAnimation[3] = flagAnimation[3] * -1
			end
			animation = flagAnimation[1]
		else
			xDirection, yDirection = animation[2], animation[3]
			if animation[4] then
				animation[2] = animation[2] * -1
			end
			if animation[5] then
				animation[3] = animation[3] * -1
			end
			animation = animation[1]
		end

		string.elapsed = 0
		string.point = fontData.point
		string.relativeTo = fontData.relativeTo
		string.fontX = fontData.x
		string.fontY = fontData.y
		string.scrollTime = fontData.scrollTime
		string.fadeTime = fontData.scrollTime / 3
		string.GetXY = element.animations[animation]
		string.radius = element.radius
		string.xDirection = xDirection
		string.yDirection = yDirection
		string.x = string.xDirection * element.xOffsetsByAnimation[animation]
		string.y = string.yDirection * element.yOffsetsByAnimation[animation]

		-- modified
		element.bounce[event] = not element.bounce[event]

		string:SetFont(fontData.font, fontData.fontSize * (element.multipliersByFlag[flag] or element.multipliersByFlag[""]), fontData.fontFlags)
		string:SetFormattedText(element.iconBounce[event] and (element.bounce[event] and element.iconFormats[event][1] or element.iconFormats[event][2])
								or element.formats[event] or "%1$s", text, texture or "")
		string:SetTextColor(color.r, color.g, color.b)
		string:ClearAllPoints()
		string:Point(fontData.point, element, fontData.relativeTo, fontData.x + string.x, fontData.y + string.y)
		string:SetAlpha(0)
		string:Show()

		t_insert(element.FeedbackToAnimate, string)

		if not element:GetScript("OnUpdate") then
			element:SetScript("OnUpdate", onUpdate)
		end
	end
end

local function Path(self, ...)
	(self.FloatingCombatFeedback.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local iconOverrides = {
	[136243] = "",
	["Interface\\Icons\\Trade_Engineering"] = "",
}

local iconCache = {}

-- modified
local function getTexture(spellID)
	if spellID and not iconCache[spellID] then
		local texture = select(3,GetSpellInfo(spellID))
		iconCache[spellID] = iconOverrides[texture] or texture
	end

	return iconCache[spellID]
end

local function getEventFlag(resisted, blocked, absorbed, critical, glancing, crushing)
	return (resisted and resisted > 0) and "RESIST"
		or (blocked and blocked > 0) and "BLOCK"
		or (absorbed and absorbed > 0) and "ABSORB"
		or critical and "CRITICAL"
		or glancing and "GLANCING"
		or crushing and "CRUSHING"
		or nil
end

-- modified
local function prep(event, _, ...)
    local spellId, flag, amount, school, texture, spellName, auraType, _

	if event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH" or event == "SPELL_AURA_REMOVED" then
		spellId, spellName, _, auraType = ...
		texture = getTexture(spellId)
		flag = (event == "SPELL_AURA_APPLIED" or event == "SPELL_AURA_REFRESH") and "+"..spellName or "-"..spellName
		event = auraType
	elseif event == "ENVIRONMENTAL_DAMAGE" then
		_, amount, _, school = ...
		flag = getEventFlag(select(4, ...)) or "NOFLAGWOUND"
		event = "WOUND"
	elseif event == "RANGE_DAMAGE" or event == "SPELL_DAMAGE" or event == "SPELL_PERIODIC_DAMAGE" then
		spellId, _, _, amount, _, school = ...
		flag = event == "SPELL_PERIODIC_DAMAGE" and "PERIODICWOUND" or getEventFlag(select(7, ...)) or "NOFLAGWOUND"
		texture = getTexture(spellId)
		event = "WOUND"
    elseif event == "SWING_DAMAGE" then
		amount, _, school = ...
		flag = getEventFlag(select(4, ...)) or "NOFLAGWOUND"
		event = "WOUND"
    elseif event == "SPELL_HEAL" or event == "SPELL_PERIODIC_HEAL" then
		spellId, _, school, amount = ...
		flag = event == "SPELL_PERIODIC_HEAL" and "PERIODICHEAL" or getEventFlag(nil, nil, select(6, ...)) or "NOFLAGHEAL"
		texture = getTexture(spellId)
		event = "HEAL"
    elseif event == "RANGE_MISSED" or event == "SPELL_MISSED" or event == "SPELL_PERIODIC_MISSED" then
		_, _, school, event = ...
		texture = getTexture(...)
    elseif event == "SWING_MISSED" then
		event = ...
    elseif event == "SPELL_INTERRUPT" then
		spellId, _, _, _, _, school = ...
		texture = getTexture(spellId)
		event = "INTERRUPT"
    end

    return event, flag, amount or 0, school or SCHOOL_MASK_NONE, texture, spellId
end

local playerGUID = UnitGUID("player")
local COMBATLOG_OBJECT_AFFILIATION_MINE = _G.COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001

local frameToGUID = {}
local guidToFrame = {}

local CLEUEvents = {
	-- modified
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
	["SPELL_AURA_REMOVED"] = true,
	-- damage
	["ENVIRONMENTAL_DAMAGE" ] = true, -- environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
	["RANGE_DAMAGE"         ] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SPELL_BUILDING_DAMAGE"] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SPELL_DAMAGE"         ] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SPELL_PERIODIC_DAMAGE"] = true, -- spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	-- miss
	["RANGE_MISSED"         ] = true, -- spellId, spellName, spellSchool, missType, isOffHand, amountMissed = ...
	["SPELL_MISSED"         ] = true, -- spellId, spellName, spellSchool, missType, isOffHand, amountMissed = ...
	["SPELL_PERIODIC_MISSED"] = true, -- spellId, spellName, spellSchool, missType, isOffHand, amountMissed = ...
	-- heal
	["SPELL_BUILDING_HEAL"  ] = true, -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...
	["SPELL_HEAL"           ] = true, -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...
	["SPELL_PERIODIC_HEAL"  ] = true, -- spellId, spellName, spellSchool, amount, overhealing, absorbed, critical = ...
	-- swing
	["SWING_DAMAGE"         ] = true, -- amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = ...
	["SWING_MISSED"         ] = true, -- missType, isOffHand, amountMissed = ...
	-- interrupt
	["SPELL_INTERRUPT"      ] = true, -- spellId, spellName, spellSchool, extraSpellId, extraSpellName, extraSpellSchool = ...
}

local function hasFlag(flags, flag)
	return b_and(flags, flag) > 0
end

-- modified
local function filter(self, _, event, sourceGUID, _, sourceFlags, destGUID, _, _, ...)
    if CLEUEvents[event] then
        if guidToFrame[destGUID] then
			for frame in next, guidToFrame[destGUID] do
				if not frame.FloatingCombatFeedback.blacklist[...] then
					Path(	frame, "COMBAT_LOG_EVENT_UNFILTERED", frame.unit,
							destGUID == playerGUID or (sourceGUID == playerGUID or hasFlag(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE)),
							prep(event, _, ...)
						)
                end
            end
        end
    end
end

-- modified
oUF.CLEUDispatcher = CreateFrame("Frame")
oUF.CLEUDispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
oUF.CLEUDispatcher:SetScript("OnEvent", function(_, ...)
    filter(...)
end)

local function unGUIDe(frame)
	local guid = frameToGUID[frame]
	if guid then
		frameToGUID[frame] = nil

		if guidToFrame[guid] then
			guidToFrame[guid][frame] = nil
		end
	end
end

local function GUIDe(frame, unit)
	if unit then
		local guid = UnitGUID(unit)
		if guid then
			local oldGUID = frameToGUID[frame]
			if oldGUID then
				if guidToFrame[oldGUID] then
					guidToFrame[oldGUID][frame] = nil
				end
			end

			frameToGUID[frame] = guid

			if not guidToFrame[guid] then
				guidToFrame[guid] = {}
			end

			guidToFrame[guid][frame] = true
			return
		end
	end

	unGUIDe(frame)
end

local cleuElements = {}

function oUF:uaeHook(event)
	if event ~= "OnUpdate" and next(cleuElements) then
		GUIDe(self, self.unit)
	end
end

local function EnableCLEU(element, state, force)
	if element.useCLEU ~= state or force then
		local frame = element.__owner

		element.useCLEU = state
		if element.useCLEU then
			frame:UnregisterEvent("UNIT_COMBAT", Path)
			oUF.CLEUDispatcher:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			GUIDe(frame, frame.unit)

			cleuElements[element] = true
		else
			frame:RegisterEvent("UNIT_COMBAT", Path)

			unGUIDe(frame)

			cleuElements[element] = nil
			if not next(cleuElements) then
				oUF.CLEUDispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			end
		end
	end
end

local function Enable(self)
	local element = self.FloatingCombatFeedback
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		element.EnableCLEU = EnableCLEU
		element.FeedbackToAnimate = {}

		element.formats = {}
		element.iconFormats = {}
		element.bounce = {}
		element.iconBounce = {}
		element.fontData = {}
		element.playerOnlyEvents = {}
		element.filterAuras = {["BUFF"] = {}, ["DEBUFF"] = {}}

		element.radius = element.radius or 65

		for i = 1, #element do
			element[i]:SetFont("Fonts\\FRIZQT__.TTF", 18, "")
			element[i]:Hide()
		end

		element.colors = copyTable(colors, element.colors)
		element.schoolColors = copyTable(schoolColors, element.schoolColors)
		element.tryToColorBySchool = copyTable(tryToColorBySchool, element.tryToColorBySchool)
		element.animations = copyTable(animations, element.animations)
		element.animationsByEvent = copyTable(animationsByEvent, element.animationsByEvent)
		element.animationsByFlag = copyTable(animationsByFlag, element.animationsByFlag)
		element.multipliersByFlag = copyTable(multipliersByFlag, element.multipliersByFlag)
		element.xOffsetsByAnimation = copyTable(xOffsetsByAnimation, element.xOffsetsByAnimation)
		element.yOffsetsByAnimation = copyTable(yOffsetsByAnimation, element.yOffsetsByAnimation)

		element:SetScript("OnHide", flush)
		element:SetScript("OnShow", flush)
		element:EnableCLEU(element.useCLEU, true)

		return true
	end
end

local function Disable(self)
	local element = self.FloatingCombatFeedback
	if element then
		element:SetScript("OnHide", nil)
		element:SetScript("OnShow", nil)
		element:SetScript("OnUpdate", nil)

		flush(element)

		self:UnregisterEvent("UNIT_COMBAT", Path)

		unGUIDe(self)

		cleuElements[element] = nil
		if not next(cleuElements) then
			oUF.CLEUDispatcher:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end
end

oUF:AddElement("FloatingCombatFeedback", Path, Enable, Disable)