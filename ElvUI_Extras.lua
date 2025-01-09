local E, L, _, P = unpack(ElvUI)
local core = E:NewModule("Extras", "AceHook-3.0", "AceEvent-3.0")
local UF = E:GetModule("UnitFrames")
local NP = E:GetModule("NamePlates")
local S = E:GetModule("Skins")
local EP = E.Libs.EP
local LSM = E.Libs.LSM
local ElvUF = E.oUF
local LAI = E.Libs.LAI

core.modules = {}
core.nameUpdates = {}
core.areaUpdates = {}
core.frameUpdates = {}
core.taggedFrames = {}
core.healthEnabled = {}
core.plateAnchoring = {
	["Elite"] = function(unitType, frame, element)
		if unitType == "ENEMY_NPC" or unitType == "FRIENDLY_NPC" then
			local points = NP.db.units[unitType].eliteIcon
			frame.Elite:ClearAllPoints()
			frame.Elite:Point(points.position, element, points.xOffset, points.yOffset)
		end
	end
}

core.PurgeList = {
	MAGE = true,
	PRIEST = true,
	SHAMAN = true,
	WARLOCK = true,
}

core.DispellList = {
	PRIEST = {Magic = true, Disease = true},
	SHAMAN = {Poison = true, Disease = true, Curse = false},
	PALADIN = {Poison = true, Magic = true, Disease = true},
	MAGE = {Curse = true},
	DRUID = {Curse = true, Poison = true},
	WARLOCK = {Magic = true},
}

core.SpellLists = {
	["DEFAULTS"] = {
		-- Misc
		[11732] = 120,	-- Healthstone
		[26297] = 180,	-- Berserking
		[20594] = 120,	-- Stoneform
		[58984] = 120,	-- Shadowmeld
		[20589] = 105,	-- Escape Artist
		[59752] = 120,	-- Every Man for Himself
		[7744] 	= 120,	-- Will of the Forsaken
		[50613] = 120,	-- Arcane Torrent
		[20549] = 120,	-- War Stomp
		[42292] = 120,	-- PvP Trinket
		[61685] = 25,	-- Charge
		[50519] = 60,	-- Sonic Blast
		[50245] = 40,	-- Pin
		[50433] = 10,	-- Ankle Crack
		[26090] = 30,	-- Pummel
		[50541] = 60, 	-- Clench
		[54706] = 40,	-- Vemom Web Spray
		[4167] 	= 40,	-- Web
		[50274] = 12,	-- Spore Cloud
		[50271] = 10, 	-- Tendon Rip
		[50318] = 60,	-- Serenity Dust
		[50285] = 40, 	-- Dust Cloud
		[55709] = 480,	-- Heart of the Phoenix
		[53426] = 180,	-- Lick Your Wounds
		[53476] = 30,	-- Intervene
		[53480] = 60,	-- Roar of Sacrifice
		[53478] = 360,	-- Last Stand
		[53517] = 180,	-- Roar of Recovery

		-- Pets(Warlock)
		[19647] = 24,	-- Spell Lock
		[47986] = 60,	-- Sacrifice

		-- Pets(Mage)
		[33395] = 25,	-- Freeze

		-- Death Knight
		[49039] = 120,	-- Lichborne
		[47476] = 60,	-- Strangulate
		[48707] = 45,	-- Anti-Magic Shell
		[49576] = 25,	-- Death Grip
		[47528] = 10,	-- Mind Freeze
		[51052] = 120,	-- Anti-Magic Zone
		[49203] = 60,	-- Hungering Cold
		[49028] = 90, 	-- Dancing Rune Weapon
		[49206] = 180,	-- Summon Gargoyle
		[48792] = 180,	-- Icebound Fortitude
		[48743] = 120,	-- Death Pact
		[42650] = 600,	-- Army of the Dead

		-- Druid
		[22812] = 60,	-- Barkskin
		[17116] = 180,	-- Nature's Swiftness
		[16979] = 15,	-- Feral Charge - Bear
		[49376] = 30,	-- Feral Charge - Cat
		[61336] = 180,	-- Survival Instincts
		[50334] = 180,	-- Berserk
		[50516] = 17,	-- Typhoon
		[33831] = 180,	-- Force of Nature
		[53201] = 60,	-- Starfall
		[8983] 	= 50,	-- Bash
		[29166] = 180,	-- Innervate
		-- [22570] = 10,	-- Maim
		-- [18562] = 15,	-- Swiftmend
		-- [22842] = 180,	-- Frenzied Regeneration
		-- [53312] = 60, 	-- Nature's Grasp
		-- [740] = 480,		-- Tranquility

		-- Hunter
		[49012] = 54,	-- Wyvern Sting
		[3045] 	= 180,	-- Rapid Fire
		[53351] = 10,	-- Kill Shot
		[53271] = 35, 	-- Master's Call
		[19263] = 120,	-- Deterrence
		[19503] = 30,	-- Scatter Shot
		[23989] = 180,	-- Readiness
		[34490] = 20,	-- Silencing Shot
		[19574] = 90,	-- Bestial Wrath
		[14311]	= 30,	-- Freezing Trap
		[60202] = 30,   -- Freezing Arrow
		[50518] = 40,	-- Ravage
		[50479] = 40,	-- Nether Shock

		-- Mage
		[2139] 	= 24,	-- Counterspell
		[44572] = 30,	-- Deep Freeze
		[11958] = 384,	-- Cold Snap
		[45438] = 300,	-- Ice Block
		[12042] = 106,	-- Arcane Power
		[12051] = 240,	-- Evocation
		[12472] = 144,	-- Icy Veins
		[66]	= 132,	-- Invisibility
		[42945] = 30, 	-- Blast Wave
		[12043] = 90,	-- Presence of Mind
		[11129] = 120,	-- Combustion
		[42950] = 20,	-- Dragon's Breath
		-- [122] = 25,		-- Frost Nova
		-- [42917] = 25,	-- Frost Nova
		-- [11426] = 24,	-- Ice Barrier
		-- [55342] = 180,	-- Mirror Image

		-- Paladin
		[1044] 	= 25,	-- Hand of Freedom
		[31884] = 180,	-- Avenging Wrath
		[10308] = 40,	-- Hammer of Justice
		[48827] = 30,	-- Avenger's Shield
		[633] 	= 420,	-- Lay on Hands
		[10278] = 180,	-- Hand of Protection
		[498] 	= 180,	-- Divine Protection
		[54428] = 60,	-- Divine Plea
		[642] 	= 240,	-- Divine Shield
		[6940] 	= 120,	-- Hand of Sacrifice
		[31821] = 120,	-- Aura Mastery
		[20066] = 60,	-- Repentance
		-- [31842] = 180,	-- Divine Favor
		-- [31850] = 180,	-- Ardent Defender

		-- Priest
		[64044] = 120,	-- Psychic Horror
		[10890] = 23,	-- Psychic Scream
		[15487] = 45,	-- Silence
		[47585] = 120,	-- Dispersion
		[33206] = 180,	-- Pain Suppression
		[10060] = 120,	-- Power Infusion
		[48158] = 12,	-- Shadow Word: Death
		-- [586] = 15,		-- Fade
		-- [6346] = 180,	-- Fear Ward
		-- [64901] = 360,	-- Hymn of Hope
		-- [64843] = 480,	-- Divine Hymn
		-- [19236] = 120,	-- Desperate Prayer
		-- [724] = 180,		-- Lightwell

		-- Rogue
		[2094] 	= 180,	-- Blind
		[1766] 	= 10,	-- Kick
		[11305]	= 180,	-- Sprint
		[14185] = 300,	-- Preparation
		[31224] = 90,	-- Cloak of Shadows
		[26889]	= 180,	-- Vanish
		[36554] = 30,	-- Shadowstep
		[26669]	= 180,	-- Evasion
		[51722] = 60,	-- Dismantle
		[51690] = 75,	-- Killing Spree
		[51713] = 60, 	-- Shadow Dance
		[8643] 	= 20,	-- Kidney Shot
		-- [14177] = 120,	-- Cold Blood

		-- Shaman
		[8177] 	= 13,	-- Grounding Totem
		[57994] = 5,	-- Wind Shear
		[32182] = 300,	-- Heroism
		[2825] 	= 300,	-- Bloodlust
		[51533] = 180,	-- Feral Spirit
		[16190] = 240,	-- Mana Tide Totem
		[30823] = 60,	-- Shamanistic Rage
		[59159] = 35,	-- Thunderstorm
		[5730] 	= 20,	-- Stoneclaw Totem
		[51514] = 45,	-- Hex
		[16166] = 180,	-- Elemental Mastery
		[16188] = 120,	-- Nature's Swiftness

		-- Warlock
		[47860]	= 120,	-- Death Coil
		[17928]	= 32,	-- Howl of Terror
		[54785] = 45,	-- Demon Leap
		[48020] = 26,	-- Demonic Circle: Teleport
		[47847] = 20,   -- Shadowfury
		-- [17962] = 8,		-- Conflagrate
		-- [74434] = 45,	-- Soulburn
		-- [6229] = 30,		-- Shadow Ward

		-- Warrior
		[11578]	= 15,	-- Charge
		[6552] 	= 10,	-- Pummel
		[72] 	= 12,	-- Shield Bash
		[23920] = 9,	-- Spell Reflection
		[676] 	= 60,	-- Disarm
		[5246] 	= 120,	-- Intimidation Shout
		[871] 	= 120,	-- Shield Wall
		[20252] = 20,	-- Intercept
		[64382] = 240,	-- Shattering Throw
		[12809] = 30,	-- Concussion Blow
		[12975] = 180,	-- Last Stand
		[60970] = 30,	-- Heroic Fury
		[46924] = 75,	-- Bladestorm
		[46968] = 17,	-- Shockwave
		-- [2565] = 30,		-- Shield Block
		-- [6544] = 40,		-- Heroic Leap
		-- [12328] = 60,	-- Sweeping Strikes
		-- [20230] = 300,	-- Retaliation
		-- [1719] = 240,	-- Recklessness
		-- [3411] = 30,		-- Intervene
		-- [12292] = 144, 	-- Death Wish
	},
	["INTERRUPT"] = {
		[6552] 	= 10,	-- Pummel
		[72] 	= 12,	-- Shield Bash
		[1766] 	= 10,	-- Kick
		[57994] = 5,	-- Wind Shear
		[2139] 	= 24,	-- Counterspell
		[19647] = 24,   -- Spell Lock (Felhunter)
		[47528] = 10,   -- Mind Freeze
		[47476] = 120,	-- Strangulate
		[34490] = 20,   -- Silencing Shot
		[26090] = 30,   -- Pummel (Gorilla Pet)
		[50479] = 40,	-- Nether Shock (Nether Ray Pet)
		[15487] = 45,   -- Silence
		[8983] 	= 60,   -- Bash
		[48827] = 30,   -- Avenger's Shield
	},
	["CONTROL"] = {
		[47476] = 120,	-- Strangulate
		[51209] = 60,   -- Hungering Cold
		[8983] 	= 50,   -- Bash
		[22570] = 10,   -- Maim
		[16979] = 15,   -- Feral Charge
		[1513] 	= 15,	-- Scare Beast
		[14311]	= 30,	-- Freezing Trap
		[49012] = 54,   -- Wyvern Sting
		[19503] = 30,   -- Scatter Shot
		[24394] = 60,   -- Intimidation
		[34490] = 20,   -- Silencing Shot
		[50245] = 40,   -- Pin
		[50519] = 60,   -- Sonic Blast
		[50541] = 60,   -- Snatch
		[54706] = 40,   -- Venom Web Spray
		[50518] = 40,	-- Ravage
		[56626] = 10,   -- Sting
		[50479] = 40,	-- Nether Shock
		[60202] = 30,   -- Freezing Arrow
		[122] 	= 25,	-- Frost Nova
		[42917]	= 20,	-- Frost Nova
		[42950] = 20,   -- Dragon's Breath
		[33395] = 25,   -- Freeze
		[44572] = 30,   -- Deep Freeze
		[2139] 	= 24,	-- Counterspell
		[10308]	= 40,	-- Hammer of Justice
		[20066] = 60,   -- Repentance
		[48827] = 30,   -- Avenger's Shield
		[10890]	= 23,	-- Psychic Scream
		[15487] = 45,   -- Silence
		[64044] = 120,	-- Psychic Horror
		[8643] 	= 20,	-- Kidney Shot
		[1776] 	= 10,	-- Gouge
		[2094] 	= 180,	-- Blind
		[1766] 	= 10,	-- Kick
		[51722] = 60,   -- Dismantle
		[51514] = 45,   -- Hex
		[47860]	= 120,	-- Death Coil
		[17928] = 32,   -- Howl of Terror
		[19647] = 24,   -- Spell Lock
		[47847] = 20,   -- Shadowfury
		[676] 	= 60,	-- Disarm
		[72] 	= 12,   -- Shield Bash
		[5246] 	= 120,  -- Intimidating Shout
		[50613] = 120,  -- Arcane Torrent
		[20549] = 120,  -- War Stomp
	},
}


local AddOnName = ...
local isAwesome = C_NamePlate and E.private.nameplates.enable
local printing = false

local nameUpdates = core.nameUpdates
local frameUpdates = core.frameUpdates
local healthEnabled = core.healthEnabled
local plateAnchoring = core.plateAnchoring
local taggedFrames = core.taggedFrames
local areaUpdates = core.areaUpdates

local _G, unpack, pairs, ipairs, select, tonumber, print = _G, unpack, pairs, ipairs, select, tonumber, print
local gsub, find, sub, lower, upper = string.gsub, string.find, string.sub, string.lower, string.upper
local format, match, gmatch = string.format, string.match, string.gmatch
local max, ceil, floor = math.max, math.ceil, math.floor
local tinsert, twipe, tsort = table.insert, table.wipe, table.sort
local UnitGUID, UnitClass, UnitExists, UnitAura = UnitGUID, UnitClass, UnitExists, UnitAura
local UnitReaction, UnitIsPlayer, UnitCanAttack, UnitThreatSituation = UnitReaction, UnitIsPlayer, UnitCanAttack, UnitThreatSituation
local GetNumMacroIcons, GetMacroIconInfo, GameTooltip = GetNumMacroIcons, GetMacroIconInfo, GameTooltip
local UnitPopupMenus, UnitPopupShown = UnitPopupMenus, UnitPopupShown
local GetRaidRosterInfo, IsPartyLeader, IsRaidOfficer = GetRaidRosterInfo, IsPartyLeader, IsRaidOfficer
local InCombatLockdown, IsControlKeyDown = InCombatLockdown, IsControlKeyDown
local IsInInstance, IsResting = IsInInstance, IsResting
local LUA_ERROR, FORMATTING, ERROR_CAPS = LUA_ERROR, FORMATTING, ERROR_CAPS

local function colorConvert(r, g, b)
	if tonumber(r) then
        return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	else
		local hex = gsub(r, "|c%w%w", "")

		r = tonumber(sub(hex, 1, 2), 16) / 255
		g = tonumber(sub(hex, 3, 4), 16) / 255
		b = tonumber(sub(hex, 5, 6), 16) / 255

		return r, g, b
	end
end

local function getEntry(tbl, path)
    for key in gmatch(path, "[^%.]+") do
		local index = tonumber(key)
        if type(tbl) ~= "table" or (tbl[index] == nil and tbl[key] == nil) then
            return nil
        end
        tbl = tbl[index or key]
    end
    return tbl
end


-- make worlmap quests open quest log on ctrl-click
core:SecureHook("WorldMapQuestFrame_OnMouseUp", function(self)
	if InCombatLockdown() then
		return
	elseif IsControlKeyDown() then
		if not QuestLogFrame:IsShown() then
			ShowUIPanel(QuestLogFrame)
		end

		QuestLog_SetSelection(self.questLogIndex)
		QuestLog_Update()
	end
end)


-- restored raid controls
local stateHandler = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
stateHandler:SetAttribute("_onstate-combatstate", [[
	local t, a = self:GetFrameRef("maintank"), self:GetFrameRef("mainassist")
	if t and a then
		t:ClearAllPoints()
		t:Hide()
		a:ClearAllPoints()
		a:Hide()
	end
]])
RegisterStateDriver(stateHandler, "combatstate", "[combat] hide; show")

local function createSecurePromoteButton(name, role)
    local button = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate", "SecureHandlerStateTemplate")
    button:SetFrameStrata("TOOLTIP")
    button:Hide()

    button:SetAttribute("type", role)
    button:SetAttribute("unit", "target")
    button:SetAttribute("action", "toggle")

	button:RegisterEvent("PLAYER_REGEN_DISABLED")

	stateHandler:SetFrameRef(role, button)

    return button
end

local function setButton(unit, button, newButton)
	newButton:SetAllPoints(button)
	newButton:SetAttribute("unit", unit or "target")
	newButton:SetScript("OnEnter", function()
		button:GetScript("OnEnter")(button)
	end)
	newButton:SetScript("OnLeave", function()
		button:GetScript("OnLeave")(button)
	end)
	newButton:SetScript("OnMouseDown", function()
		button:SetButtonState("PUSHED")
	end)
	newButton:SetScript("OnMouseUp", function()
		button:SetButtonState("NORMAL")
	end)
	newButton:SetScript("PostClick", function()
		CloseDropDownMenus()
	end)
	newButton:SetScript("OnEvent", function(self)
		if self:IsShown() then CloseDropDownMenus() end
	end)
	newButton:Show()
end

local secureTankButton = createSecurePromoteButton("ElvUI_SecureTankButton", "maintank")
local secureAssistButton = createSecurePromoteButton("ElvUI_SecureAssistButton", "mainassist")

core:SecureHook("UnitPopup_ShowMenu", function(_, _, unit)
	if UIDROPDOWNMENU_MENU_LEVEL ~= 1 or InCombatLockdown() then return end

	for i = 1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList1Button"..i]
		if button and button:IsShown() then
			if button.value == "RAID_MAINTANK" then
				setButton(unit, button, secureTankButton)
			elseif button.value == "RAID_MAINASSIST" then
				setButton(unit, button, secureAssistButton)
			end
		end
	end
end)

core:SecureHook("UnitPopup_HideButtons", function()
	local dropdownMenu = UIDROPDOWNMENU_INIT_MENU
	local isAuthority = IsPartyLeader() or IsRaidOfficer()

	if dropdownMenu.which ~= "RAID" or not isAuthority or InCombatLockdown() then return end

	for index, value in ipairs(UnitPopupMenus[dropdownMenu.which]) do
		if value == "RAID_MAINTANK" then
			local role = select(10,GetRaidRosterInfo(dropdownMenu.userData))
			if role ~= "MAINTANK" or not dropdownMenu.name then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 1
			end
		elseif value == "RAID_MAINASSIST" then
			local role = select(10,GetRaidRosterInfo(dropdownMenu.userData))
			if role ~= "MAINASSIST" or not dropdownMenu.name then
				UnitPopupShown[UIDROPDOWNMENU_MENU_LEVEL][index] = 1
			end
		end
	end
end)

core:SecureHookScript(DropDownList1, "OnHide", function()
	if InCombatLockdown() then return end
	secureTankButton:ClearAllPoints()
	secureAssistButton:ClearAllPoints()
	secureTankButton:Hide()
	secureAssistButton:Hide()
end)


function core:getAllFrameTypes()
	return {
		["player"] = true,
		["target"] = true,
		["targettarget"] = true,
		["targettargettarget"] = true,
		["focus"] = true,
		["focustarget"] = true,
		["pet"] = true,
		["pettarget"] = true,
		["raid"] = true,
		["raid40"] = true,
		["raidpet"] = true,
		["party"] = true,
		["partypet"] = true,
		["partytarget"] = true,
		["boss"] = true,
		["arena"] = true,
		["assist"] = true,
		["assisttarget"] = true,
		["tank"] = true,
		["tanktarget"] = true,
	}
end

function core:getSelected(cat, modName, path, fallback)
    local base, selected = match(path, "(.-)%[(.-)%]")
    local baseTable = getEntry(E.db.Extras[cat][modName], base)

    if not baseTable then
        E.db.Extras[cat][modName] = E:CopyTable({}, P.Extras[cat][modName])
        if not printing then
            printing = true
            E:Delay(0.1, function()
                printing = false
                print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
                            self.customColorBeta.." %s"..self.customColorAlpha..":|r %s", modName, self.customColorBad..ERROR_CAPS))
                print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
                            self.customColorBeta.." %s"..self.customColorAlpha..":|r ??? -> %s.%s.%s", modName, cat, modName, path))
            end)
        end
        return
    end

    if baseTable[tonumber(selected) or selected] then
        return baseTable[tonumber(selected) or selected]
    else
		if not printing then
			printing = true
			E:Delay(0.1, function()
				printing = false
				print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
							self.customColorBeta.." %s"..self.customColorAlpha..":|r %s", modName, self.customColorBad..ERROR_CAPS))
				print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
							self.customColorBeta.." %s"..self.customColorAlpha..":|r ??? -> %s.%s.%s", modName, cat, modName, path))
			end)
		end
		if not baseTable[fallback] then
			baseTable[fallback] = E:CopyTable({}, getEntry(P.Extras[cat][modName], base)[fallback])
		end
		return baseTable[fallback]
	end
end

function core:print(type, ...)
	if type == 'LUA' then
		print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
					self.customColorBeta.." %s "..self.customColorBad..LUA_ERROR..self.customColorAlpha..":|r %s", ...))
	elseif type == 'FORMATTING' then
		print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
					self.customColorBeta.." %s"..self.customColorAlpha..":|r "..self.customColorBad..FORMATTING.." "..ERROR_CAPS, ...))
	elseif type == 'FAIL' then
		print(format(self.customColorAlpha.."ElvUI "..self.pluginColor.."Extras"..self.customColorAlpha..","..
					self.customColorBeta.." %s"..self.customColorAlpha..":|r %s", ...))
	elseif type == 'ADDED' then
		print(format(self.customColorAlpha.."%s"..self.customColorBeta..(select(2,...) and "%s" or L[" added."]), ...))
	elseif type == 'REMOVED' then
		print(format(self.customColorAlpha.."%s"..self.customColorBeta..(select(2,...) and "%s" or L[" removed."]), ...))
	end
end


-- Awesome WOTLK
if isAwesome then
	local target = CreateFrame("Frame")
	local mouseover = CreateFrame("Frame")
	local GetNamePlates = C_NamePlate.GetNamePlates
	local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

	core.plateList = {}

	core:RegisterEvent("PLAYER_TARGET_CHANGED", function()
		local exists = UnitExists("target")
		if target.exists then
			if not exists then
				target.exists = false
				target:SetScript("OnUpdate", nil)
			end
		elseif exists then
			target.exists = true
			target:SetScript("OnUpdate", function()
				for _, np in ipairs(GetNamePlates()) do
					np:SetAlpha(1)
				end
			end)
		end
		for _, np in ipairs(GetNamePlates()) do
			NP:SetTargetFrame(np.UnitFrame)
		end
	end)

	core:RegisterEvent("UPDATE_MOUSEOVER_UNIT", function()
		for _, np in ipairs(GetNamePlates()) do
			local unitframe = np.UnitFrame
			if unitframe then
				NP:SetMouseoverFrame(unitframe)
			end
		end
		local plate = GetNamePlateForUnit("mouseover")
		local mouseOverFrame = plate and plate.UnitFrame
		if mouseOverFrame then
			mouseOverFrame.isMouseover = true
			NP:Update_Highlight(mouseOverFrame)
			mouseover:SetScript("OnUpdate", function()
				if not UnitExists("mouseover") then
					mouseOverFrame.isMouseover = nil
					NP:Update_Highlight(mouseOverFrame)
					mouseover:SetScript("OnUpdate", nil)
				end
			end)
		end
	end)

	core:RegisterEvent("UNIT_THREAT_LIST_UPDATE", function(_, unit)
		if not unit or not find(unit, "nameplate", 1, true) then return end
		local plate = GetNamePlateForUnit(unit)
		if plate then
			local frame = plate.UnitFrame
			if frame then
				local status = UnitThreatSituation("player", unit)
				if frame.ThreatStatus ~= status then
					frame.ThreatStatus = status
					NP:Update_HealthColor(frame)
				end
			end
		end
	end)

	core:RegisterEvent("NAME_PLATE_CREATED", function(_, plate)
		local onShow, onHide = plate:GetScript("OnShow"), plate:GetScript("OnHide")
		NP:OnCreated(plate)
		plate:SetScript("OnShow", onShow)
		plate:SetScript("OnHide", onHide)
	end)

	core:RegisterEvent("NAME_PLATE_OWNER_CHANGED", function(_, unit)
		local plate = GetNamePlateForUnit(unit)
		local frame = plate.UnitFrame
		core.plateList[frame.guid or ""] = nil
		core.plateList[UnitGUID(unit)] = plate
		frame.ThreatStatus = UnitThreatSituation("player", unit)
		NP.OnHide(plate, nil, true)
		NP.OnShow(plate, nil, true)
	end)

	core:RegisterEvent("NAME_PLATE_UNIT_REMOVED", function(_, unit)
		local plate = GetNamePlateForUnit(unit)
		plate.unit = nil
		core.plateList[UnitGUID(unit)] = nil
		NP.OnHide(plate, nil, true)
	end)

	core:RegisterEvent("NAME_PLATE_UNIT_ADDED", function(_, unit)
		local plate = GetNamePlateForUnit(unit)
		local frame = plate.UnitFrame
		plate.unit = unit
		core.plateList[UnitGUID(unit)] = plate
		frame.ThreatStatus = UnitThreatSituation("player", unit)
		NP.OnShow(plate, nil, true)
	end)

	function core:SetTargetFrame(_, frame)
		local parent = frame:GetParent()
		local unit = parent.unit
		if not unit then return end

		local isTargetUnit = UnitGUID(unit) == UnitGUID("target")
		if isTargetUnit then
			if not frame.isTarget then
				frame.isTarget = true
				if NP.db.useTargetScale then
					NP:SetFrameScale(frame, (frame.ThreatScale or 1) * NP.db.targetScale)
				end
				if not healthEnabled[frame.UnitType] and NP.db.alwaysShowTargetHealth then
					frame.Health.r, frame.Health.g, frame.Health.b = nil, nil, nil
					NP:Configure_HealthBar(frame)
					NP:Configure_CastBar(frame)
					NP:Configure_Elite(frame)
					NP:Configure_CPoints(frame)
					NP:RegisterEvents(frame)
					NP:UpdateElement_All(frame, true)
				end
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), 1)
				NP:Update_Highlight(frame)
				NP:Update_CPoints(frame)
				NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
				NP:ResetNameplateFrameLevel(frame)
			end
		else
			if frame.isTarget then
				frame.isTarget = nil
				if NP.db.useTargetScale then
					NP:SetFrameScale(frame, (frame.ThreatScale or 1))
				end
				if not healthEnabled[frame.UnitType] then
					NP:UpdateAllFrame(frame, nil, true)
				end
				NP:Update_CPoints(frame)
				frame:SetFrameLevel(parent:GetFrameLevel() + 1)
			end
			if not frame.AlphaChanged then
				NP:PlateFade(frame, NP.db.fadeIn and 1 or 0, frame:GetAlpha(), target.exists and NP.db.nonTargetTransparency or 1)
			end
			NP:StyleFilterUpdate(frame, "PLAYER_TARGET_CHANGED")
			NP:ResetNameplateFrameLevel(frame)
		end
		NP:Configure_Glow(frame)
		NP:Update_Glow(frame)
	end

	function core:SetMouseoverFrame(_, frame)
		if GetNamePlateForUnit("mouseover") == frame:GetParent() then
			if not frame.isMouseover then
				frame.isMouseover = true
				NP:Update_Highlight(frame)
			end
		elseif frame.isMouseover then
			frame.isMouseover = nil
			NP:Update_Highlight(frame)
		end
	end

	function core:GetUnitByName(self, frame, ...)
		local plate = frame:GetParent()
		if plate.unit then
			return plate.unit
		else
			return core.hooks[NP].GetUnitByName(self, frame, ...)
		end
	end

	function core:UnitClass(self, frame, ...)
		local plate = frame:GetParent()
		if plate.unit then
			return select(2,UnitClass(plate.unit))
		else
			return core.hooks[NP].UnitClass(self, frame, ...)
		end
	end

	function core:GetUnitInfo(self, frame, ...)
		local plate = frame:GetParent()
		local unit = plate.unit
		if unit then
			local reaction = UnitReaction(unit, "player")
			local isPlayer = UnitIsPlayer(unit)
			local unitType

			if reaction and reaction >= 5 then
				if isPlayer then
					unitType = "FRIENDLY_PLAYER"
				else
					unitType = "FRIENDLY_NPC"
				end
				reaction = 5
			elseif reaction == 4 then
				if UnitCanAttack("player", unit) then
					unitType = "ENEMY_NPC"
				else
					unitType = "FRIENDLY_NPC"
				end
			elseif not isPlayer then
				unitType = "ENEMY_NPC"
			else
				unitType = "ENEMY_PLAYER"
			end
			return reaction, unitType
		end
		return core.hooks[NP].GetUnitInfo(self, frame, ...)
	end

	function core:UnitDetailedThreatSituation(self, frame, ...)
		local plate = frame:GetParent()
		if plate.unit then
			return UnitThreatSituation("player", plate.unit)
		else
			return core.hooks[NP].UnitDetailedThreatSituation(self, frame, ...)
		end
	end

	function core:ResetNameplateFrameLevel(_, frame)
		if frame.FrameLevelChanged then
			--calculate Style Filter FrameLevelChanged leveling
			--level method: (10*(40*2)) max 800 + max 80 (40*2) = max 880
			--highest possible should be level 880 and we add 1 to all so 881
			--local leveledCount = NP.CollectedFrameLevelCount or 1
			--level = (frame.FrameLevelChanged*(40*NP.levelStep)) + (leveledCount*NP.levelStep)
			local level = (frame:GetParent():GetFrameLevel() + 1) + frame.FrameLevelChanged * 10

			frame:SetFrameLevel(level)
			frame.Shadow:SetFrameLevel(level-1)
			frame.Buffs:SetFrameLevel(level)
			frame.Debuffs:SetFrameLevel(level)
			frame.LevelHandled = true

			local targetPlate = GetNamePlateForUnit("target")
			local plate = targetPlate and targetPlate.UnitFrame

			if plate and frame ~= plate and level > plate:GetFrameLevel() then
				plate:SetFrameLevel(level + 10)
			end
		elseif frame.LevelHandled then
			local level = frame:GetParent():GetFrameLevel() + 1
			frame:SetFrameLevel(level)
			frame.Shadow:SetFrameLevel(level-1)
			frame.Buffs:SetFrameLevel(level)
			frame.Debuffs:SetFrameLevel(level)
			frame.LevelHandled = false
		end
	end

	function core:GUIDAura(self, guid, index, filter, ...)
		local plate = core.plateList[guid]
		if plate then
			local name, _, texture, count, debuffType, duration, expiration, caster, _, _, spellId = UnitAura(plate.unit, index, filter)
			if name then
				return true, name, texture, count, debuffType, duration, expiration, caster and UnitGUID(caster), spellId
			end
		end
		return core.hooks[LAI].GUIDAura(self, guid, index, filter, ...)
	end

	core.SPELL_AURA_APPLIED = true
	core.SPELL_AURA_REMOVED = true
	core.SPELL_AURA_REFRESH = true

	core:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, _, eventType, _, _, _, dstGUID)
		if core[eventType] then
			local frame = NP:SearchNameplateByGUID(dstGUID)
			if frame then
				NP:UpdateElement_Auras(frame)
			end
		end
	end)

	core:RawHook(NP, "OnUpdate", function(self) self:SetScript("OnUpdate", nil) end)
end
--

function core:RegisterNPElement(element, func)
	if func then
		plateAnchoring[element] = func
	else
		plateAnchoring[element] = nil
	end
end

function core:OnShowHide(frame, health)
	local unitType = frame.UnitType or select(2,NP:GetUnitInfo(frame))

	if unitType and not healthEnabled[unitType] then
		local name = frame.Name
		for _, func in pairs(plateAnchoring) do
			func(unitType, frame, health or name)
		end
	end
end


core:SecureHook(NP, "OnCreated", function(_, plate)
	local frame = plate.UnitFrame
	local health = frame.Health
	core:SecureHookScript(health, "OnShow", function(self)
		core:OnShowHide(frame, self)
	end)
	core:SecureHookScript(health, "OnHide", function()
		if frame:IsVisible() then
			core:OnShowHide(frame)
		end
	end)
end)

core:SecureHook(NP, "Configure_Elite", function(_, frame)
	local unitType = frame.UnitType
	local db = unitType and NP.db.units[unitType].eliteIcon

	if db then
		local icon = frame.Elite
		icon:ClearAllPoints()
		icon:Point(db.position, healthEnabled[unitType] and frame.Health or frame.Name, db.xOffset, db.yOffset)
	end
end)


function core:AggregateUnitFrames()
    local units = {}
	for _, frame in ipairs(ElvUF.objects) do
		tinsert(units, frame)
	end
	return units
end

function core:GetUnitDropdownOptions(db)
	local options = {}
	for option in pairs(db) do
		options[option] = L[option] and L[option] or option
	end
	return options
end

function core:GetIconList(texList)
    local list = {}
    local sortedKeys = {}

    for path, info in pairs(texList) do
        tinsert(sortedKeys, {path = path, label = info.label, ["icon"] = info.icon})
    end
    tsort(sortedKeys, function(a, b)
        return a.label < b.label
    end)
    for _, item in ipairs(sortedKeys) do
        list[item.path] = item.label..' |T'..item.icon..':16:16|t'
    end
    return list
end

function core:OpenEditor(title, text, acceptFunc)
	if not self.EditFrame then
		self.EditFrame = CreateFrame("Frame", "ElvUI_Extras_Editor", UIParent)
		self.EditFrame:Size(600, 400)
		self.EditFrame:SetPoint("CENTER")
		self.EditFrame:SetMovable(true)
		self.EditFrame:SetTemplate('Transparent')
		self.EditFrame:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		self.EditFrame:SetScript("OnKeyDown", function(_, key)
			if key == "ESCAPE" then
				self.EditFrame:Hide()
				E:ToggleOptionsUI()
			end
		end)

		self.EditFrame.header = CreateFrame("Button", nil, self.EditFrame)
		self.EditFrame.header:SetTemplate(nil, true)
		self.EditFrame.header:Size(100, 25)
		self.EditFrame.header:Point("CENTER", self.EditFrame, "TOP")
		self.EditFrame.header:SetFrameLevel(self.EditFrame.header:GetFrameLevel() + 2)
		self.EditFrame.header:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		self.EditFrame.header:SetScript("OnShow", E.MoverNudgeOnShow)
		self.EditFrame.header:EnableMouse(true)
		self.EditFrame.header:RegisterForClicks("AnyUp", "AnyDown")

		self.EditFrame.header:SetScript("OnMouseDown", function()
			self.EditFrame:StartMoving()
		end)

		self.EditFrame.header:SetScript("OnMouseUp", function()
			self.EditFrame:StopMovingOrSizing()
		end)

		self.EditFrame.title = self.EditFrame.header:CreateFontString("OVERLAY")
		self.EditFrame.title:FontTemplate()
		self.EditFrame.title:Point("CENTER", self.EditFrame.header, "CENTER")
		self.EditFrame.title:SetText(title)
		self.EditFrame.title:SetTextColor(1, 0.82, 0)

		self.EditFrame.header:Width(self.EditFrame.title:GetStringWidth() + 16)

		self.EditFrame.scrollFrame = CreateFrame("ScrollFrame", "ElvUI_Extras_EditorScrollFrame", self.EditFrame, "UIPanelScrollFrameTemplate")
		self.EditFrame.scrollFrame:Point("TOP", self.EditFrame.title, "BOTTOM", 0, -16)
		self.EditFrame.scrollFrame:Size(540, 330)

		local scrollBar = _G['ElvUI_Extras_EditorScrollFrameScrollBar']
		scrollBar:SetAlpha(0)

		self.EditFrame.editBox = CreateFrame("EditBox", "ElvUI_Extras_EditorEditBox", self.EditFrame.scrollFrame)
		self.EditFrame.editBox:SetMultiLine(true)
		self.EditFrame.editBox:SetFontObject(ChatFontNormal)

		self.EditFrame.editBox:Size(540, 330)
		self.EditFrame.editBox:SetAutoFocus(false)
		self.EditFrame.editBox:SetFrameLevel(self.EditFrame:GetFrameLevel() + 10)
		self.EditFrame.editBox:SetText(text)
		self.EditFrame.editBox:SetTextColor(1,0.82,0)
		self.EditFrame.editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)

		self.EditFrame.editBox:SetScript("OnTabPressed", function(self)
			self:Insert("    ")
		end)

		self.EditFrame.scrollFrame:SetScrollChild(self.EditFrame.editBox)

		self.EditFrame.acceptButton = CreateFrame("Button", "ElvUI_Extras_EditorAccept", self.EditFrame, "UIPanelButtonTemplate")
		self.EditFrame.acceptButton:Size(80, 22)
		self.EditFrame.acceptButton:Point("BOTTOMLEFT", self.EditFrame, "BOTTOMLEFT", 20, 20)
		self.EditFrame.acceptButton:SetText(L["Accept"])
		self.EditFrame.acceptButton:SetScript("OnClick", function()
			acceptFunc()
			E:ToggleOptionsUI()
			self.EditFrame:Hide()
		end)

		self.EditFrame.cancelButton = CreateFrame("Button", "ElvUI_Extras_EditorCancel", self.EditFrame, "UIPanelButtonTemplate")
		self.EditFrame.cancelButton:Size(80, 22)
		self.EditFrame.cancelButton:Point("BOTTOMRIGHT", self.EditFrame, "BOTTOMRIGHT", -20, 20)
		self.EditFrame.cancelButton:SetText(L["Cancel"])
		self.EditFrame.cancelButton:SetScript("OnClick", function()
			self.EditFrame:Hide()
			E:ToggleOptionsUI()
		end)

		S:HandleScrollBar(scrollBar)
		S:HandleButton(self.EditFrame.acceptButton)
		S:HandleButton(self.EditFrame.cancelButton)

		tinsert(UISpecialFrames, 'ElvUI_Extras_Editor')
	else
		self.EditFrame:Show()
		self.EditFrame.title:SetText(title)
		self.EditFrame.header:Width(self.EditFrame.title:GetStringWidth() + 16)
		self.EditFrame.editBox:SetText(text)
		self.EditFrame.acceptButton:SetScript("OnClick", function()
			acceptFunc()
			E:ToggleOptionsUI()
			self.EditFrame:Hide()
		end)
	end

	E:ToggleOptionsUI()
end


function core:Tag(name, tagfunc, updatefunc)
	nameUpdates[name] = tagfunc

	if updatefunc and not next(frameUpdates) then
		local wrongEvents = {
			['DisableElement'] = true,
			['ForceUpdate'] = true,
		}
		for _, frame in ipairs(self:AggregateUnitFrames()) do
			local frameType = frame.unitframeType
			local type_db = E.db.unitframe.units[frameType]
			if not taggedFrames[frame] and type_db and type_db.enable and not (match(frameType, '%w+target') or match(frameType, 'boss%d?$')) then
				self:SecureHook(frame, "UpdateAllElements", function(frame, event)
					if not wrongEvents[event] and frame.unit then
						for _, updateFunc in pairs(nameUpdates) do
							updateFunc(_, frame, frame.unit)
						end
					end
				end)
				if frameType == 'target' or frameType == 'focus' then
					frame:RegisterEvent(format("PLAYER_%s_CHANGED", upper(frameType)), frame.UpdateAllElements)
				end
				taggedFrames[frame] = true
			end
		end
		for frameType in pairs(self:getAllFrameTypes()) do
			local type_db = E.db.unitframe.units[frameType]
			if type_db and type_db.enable then
				local frameTypeCapital = gsub(gsub(frameType, "target", "Target"), "^(.)", function(firstLetter) return upper(firstLetter) end)
				local func = "Update_"..frameTypeCapital.."Frame"
				local groupFunc = "Update_"..frameTypeCapital.."Frames"
				if (UF[func] or UF[groupFunc]) and not self:IsHooked(UF, UF[func] and func or groupFunc) then
					self:SecureHook(UF, UF[func] and func or groupFunc, function(self, frame, ...)
						local unitframeType = frame.unitframeType
						if not taggedFrames[frame] and not (match(unitframeType, '%w+target') or match(unitframeType, 'boss%d?$')) then
							core:SecureHook(frame, "UpdateAllElements", function(frame, event)
								if not wrongEvents[event] and frame.unit then
									for _, updateFunc in pairs(nameUpdates) do
										updateFunc(_, frame, frame.unit)
									end
								end
							end)
							if unitframeType == 'target' or unitframeType == 'focus' then
								frame:RegisterEvent(format("PLAYER_%s_CHANGED", upper(frameType)), frame.UpdateAllElements)
							end
							taggedFrames[frame] = true
						end
						for _, updateFunc in pairs(frameUpdates) do
							updateFunc(self, frame, ...)
						end
					end)
				end
			end
		end
	end
	frameUpdates[name] = updatefunc
end


function core:Untag(name)
	nameUpdates[name] = nil
	frameUpdates[name] = nil

	if not next(frameUpdates) then
		for _, frame in ipairs({self:AggregateUnitFrames()}) do
			if taggedFrames[frame] then
				self:Unhook(frame, "UpdateAllElements")

				taggedFrames[frame] = nil
			end
		end
		for frameType in pairs(self:getAllFrameTypes()) do
			if E.db.unitframe.units[frameType] then
				local frameTypeCapital = gsub(gsub(frameType, "target", "Target"), "^(.)", function(firstLetter) return upper(firstLetter) end)
				local func = "Update_"..frameTypeCapital.."Frame"
				local groupFunc = "Update_"..frameTypeCapital.."Frames"
				if (UF[func] or UF[groupFunc]) and self:IsHooked(UF, UF[func] and func or groupFunc) then
					self:Unhook(UF, UF[func] and func or groupFunc)
				end
			end
		end
	end
end


function core:RegisterAreaUpdate(name, func)
	if func then
		if not next(areaUpdates) then
			for _, event in ipairs({"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"}) do
				self:RegisterEvent(event, function(...)
					for _, f in pairs(areaUpdates) do
						f(...)
					end
				end)
			end
		end
		areaUpdates[name] = func
	else
		areaUpdates[name] = nil
		if not next(areaUpdates) then
			for _, event in ipairs({"PLAYER_UPDATE_RESTING", "ZONE_CHANGED_NEW_AREA"}) do
				self:UnregisterEvent(event)
			end
		end
	end
end

function core:GetCurrentAreaType()
	local areaType
	if IsResting() then
		areaType = "showCity"
	else
		local _, instanceType = IsInInstance()
		if instanceType == "pvp" then
			areaType = "showBG"
		elseif instanceType == "arena" then
			areaType = "showArena"
		elseif instanceType == "party" or instanceType == "raid" then
			areaType = "showInstance"
		else
			areaType = "showWorld"
		end
	end
	return areaType
end


P["Extras"] = {
	["pluginColor"] = '|cffaf73cd',
	["customColorBad"] = '|cffce1a1a',
	["customColorAlpha"] = '|cff9999ff',
	["customColorBeta"] = '|cffff8c00',
	["classList"] = {
		["WARRIOR"] = L['Warrior'],
		["WARLOCK"] = L['Warlock'],
		["PRIEST"] = L['Priest'],
		["PALADIN"] = L['Paladin'],
		["DRUID"] = L['Druid'],
		["ROGUE"] = L['Rogue'],
		["MAGE"] = L['Mage'],
		["HUNTER"] = L['Hunter'],
		["SHAMAN"] = L['Shaman'],
		["DEATHKNIGHT"] = L['Deathknight']
	},
	["modifiers"] = {
		["ANY"] = L['Any'],
		["Alt"] = 'ALT',
		["Shift"] = 'SHIFT',
		["Control"] = 'CTRL',
	},
	["frameStrata"] = {
		["BACKGROUND"] = 'BACKGROUND',
		["LOW"] = 'LOW',
		["MEDIUM"] = 'MEDIUM',
		["HIGH"] = 'HIGH',
		["DIALOG"] = 'DIALOG',
		["FULLSCREEN"] = 'FULLSCREEN',
		["FULLSCREEN_DIALOG"] = 'FULLSCREEN_DIALOG',
		["TOOLTIP"] = 'TOOLTIP',
	},
	["pointOptions"] = {
		["TOP"] = 'TOP',
		["BOTTOM"] = 'BOTTOM',
		["LEFT"] = 'LEFT',
		["RIGHT"] = 'RIGHT',
		["CENTER"] = 'CENTER',
		["TOPLEFT"] = 'TOPLEFT',
		["TOPRIGHT"] = 'TOPRIGHT',
		["BOTTOMLEFT"] = 'BOTTOMLEFT',
		["BOTTOMRIGHT"] = 'BOTTOMRIGHT',
	},
	["texClass"] = {
		["Interface\\Icons\\spell_deathknight_classicon"] = {
			["icon"] = 'Interface\\Icons\\spell_deathknight_classicon',
			["label"] = 'Death Knight',
		},
		["Interface\\Icons\\inv_misc_monsterclaw_04"] = {
			["icon"] = 'Interface\\Icons\\inv_misc_monsterclaw_04',
			["label"] = 'Druid',
		},
		["Interface\\Icons\\inv_weapon_bow_07"] = {
			["icon"] = 'Interface\\Icons\\inv_weapon_bow_07',
			["label"] = 'Hunter',
		},
		["Interface\\Icons\\inv_staff_13"] = {
			["icon"] = 'Interface\\Icons\\inv_staff_13',
			["label"] = 'Mage',
		},
		["Interface\\Icons\\inv_hammer_01"] = {
			["icon"] = 'Interface\\Icons\\inv_hammer_01',
			["label"] = 'Paladin',
		},
		["Interface\\Icons\\inv_staff_30"] = {
			["icon"] = 'Interface\\Icons\\inv_staff_30',
			["label"] = 'Priest',
		},
		["Interface\\Icons\\inv_throwingknife_04"] = {
			["icon"] = 'Interface\\Icons\\inv_throwingknife_04',
			["label"] = 'Rogue',
		},
		["Interface\\Icons\\inv_jewelry_talisman_04"] = {
			["icon"] = 'Interface\\Icons\\inv_jewelry_talisman_04',
			["label"] = 'Shaman',
		},
		["Interface\\Icons\\spell_nature_drowsy"] = {
			["icon"] = 'Interface\\Icons\\spell_nature_drowsy',
			["label"] = 'Warlock',
		},
		["Interface\\Icons\\inv_sword_27"] = {
			["icon"] = 'Interface\\Icons\\inv_sword_27',
			["label"] = 'Warrior',
		},
	},
	["texClassVector"] = {
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_deathknight"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_deathknight',
			["label"] = 'Death Knight',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_druid"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_druid',
			["label"] = 'Druid',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_hunter"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_hunter',
			["label"] = 'Hunter',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_mage"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_mage',
			["label"] = 'Mage',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_paladin"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_paladin',
			["label"] = 'Paladin',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_priest"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_priest',
			["label"] = 'Priest',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_rogue"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_rogue',
			["label"] = 'Rogue',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_shaman"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_shaman',
			["label"] = 'Shaman',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warlock"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warlock',
			["label"] = 'Warlock',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warrior"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\Class\\wow_flat_warrior',
			["label"] = 'Warrior',
		},
	},
	["texClassCrest"] = {
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\DeathKnight"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\DeathKnight',
			["label"] = 'Death Knight',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Druid"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Druid',
			["label"] = 'Druid',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Hunter"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Hunter',
			["label"] = 'Hunter',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Mage"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Mage',
			["label"] = 'Mage',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Paladin"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Paladin',
			["label"] = 'Paladin',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Priest"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Priest',
			["label"] = 'Priest',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Rogue"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Rogue',
			["label"] = 'Rogue',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Shaman"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Shaman',
			["label"] = 'Shaman',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warlock"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warlock',
			["label"] = 'Warlock',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warrior"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassCrest\\Warrior',
			["label"] = 'Warrior',
		},
	},
	["texSpec"] = {
		["Interface\\Icons\\Spell_Deathknight_BloodPresence"] = {
			["icon"] = 'Interface\\Icons\\Spell_Deathknight_BloodPresence',
			["label"] = 'Death Knight - Blood',
		},
		["Interface\\Icons\\Spell_Deathknight_FrostPresence"] = {
			["icon"] = 'Interface\\Icons\\Spell_Deathknight_FrostPresence',
			["label"] = 'Death Knight - Frost',
		},
		["Interface\\Icons\\Spell_Deathknight_UnholyPresence"] = {
			["icon"] = 'Interface\\Icons\\Spell_Deathknight_UnholyPresence',
			["label"] = 'Death Knight - Unholy',
		},
		["Interface\\Icons\\Spell_Nature_StarFall"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_StarFall',
			["label"] = 'Druid - Balance',
		},
		["Interface\\Icons\\Ability_Druid_CatForm"] = {
			["icon"] = 'Interface\\Icons\\Ability_Druid_CatForm',
			["label"] = 'Druid - Feral',
		},
		["Interface\\Icons\\Spell_Nature_HealingTouch"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_HealingTouch',
			["label"] = 'Druid - Restoration',
		},
		["Interface\\Icons\\Ability_Hunter_BeastTaming"] = {
			["icon"] = 'Interface\\Icons\\Ability_Hunter_BeastTaming',
			["label"] = 'Hunter - Beast Mastery',
		},
		["Interface\\Icons\\Ability_Hunter_FocusedAim"] = {
			["icon"] = 'Interface\\Icons\\Ability_Hunter_FocusedAim',
			["label"] = 'Hunter - Marksmanship',
		},
		["Interface\\Icons\\Ability_Hunter_SwiftStrike"] = {
			["icon"] = 'Interface\\Icons\\Ability_Hunter_SwiftStrike',
			["label"] = 'Hunter - Survival',
		},
		["Interface\\Icons\\Spell_Holy_MagicalSentry"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_MagicalSentry',
			["label"] = 'Mage - Arcane',
		},
		["Interface\\Icons\\Spell_Fire_FireBolt02"] = {
			["icon"] = 'Interface\\Icons\\Spell_Fire_FireBolt02',
			["label"] = 'Mage - Fire',
		},
		["Interface\\Icons\\Spell_Frost_FrostBolt02"] = {
			["icon"] = 'Interface\\Icons\\Spell_Frost_FrostBolt02',
			["label"] = 'Mage - Frost',
		},
		["Interface\\Icons\\Spell_Holy_HolyBolt"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_HolyBolt',
			["label"] = 'Paladin - Holy',
		},
		["Interface\\Icons\\Ability_Paladin_ShieldoftheTemplar"] = {
			["icon"] = 'Interface\\Icons\\Ability_Paladin_ShieldoftheTemplar',
			["label"] = 'Paladin - Protection',
		},
		["Interface\\Icons\\Spell_Holy_AuraOfLight"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_AuraOfLight',
			["label"] = 'Paladin - Retribution',
		},
		["Interface\\Icons\\Spell_Holy_PowerWordShield"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_PowerWordShield',
			["label"] = 'Priest - Discipline',
		},
		["Interface\\Icons\\Spell_Holy_GuardianSpirit"] = {
			["icon"] = 'Interface\\Icons\\Spell_Holy_GuardianSpirit',
			["label"] = 'Priest - Holy',
		},
		["Interface\\Icons\\Spell_Shadow_ShadowWordPain"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_ShadowWordPain',
			["label"] = 'Priest - Shadow',
		},
		["Interface\\Icons\\Ability_Rogue_Eviscerate"] = {
			["icon"] = 'Interface\\Icons\\Ability_Rogue_Eviscerate',
			["label"] = 'Rogue - Assassination',
		},
		["Interface\\Icons\\Ability_BackStab"] = {
			["icon"] = 'Interface\\Icons\\Ability_BackStab',
			["label"] = 'Rogue - Combat',
		},
		["Interface\\Icons\\Ability_Stealth"] = {
			["icon"] = 'Interface\\Icons\\Ability_Stealth',
			["label"] = 'Rogue - Subtlety',
		},
		["Interface\\Icons\\Spell_Nature_Lightning"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_Lightning',
			["label"] = 'Shaman - Elemental',
		},
		["Interface\\Icons\\Spell_Shaman_ImprovedStormstrike"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shaman_ImprovedStormstrike',
			["label"] = 'Shaman - Enhancement',
		},
		["Interface\\Icons\\Spell_Nature_MagicImmunity"] = {
			["icon"] = 'Interface\\Icons\\Spell_Nature_MagicImmunity',
			["label"] = 'Shaman - Restoration',
		},
		["Interface\\Icons\\Spell_Shadow_DeathCoil"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_DeathCoil',
			["label"] = 'Warlock - Affliction',
		},
		["Interface\\Icons\\Spell_Shadow_Metamorphosis"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_Metamorphosis',
			["label"] = 'Warlock - Demonology',
		},
		["Interface\\Icons\\Spell_Shadow_RainOfFire"] = {
			["icon"] = 'Interface\\Icons\\Spell_Shadow_RainOfFire',
			["label"] = 'Warlock - Destruction',
		},
		["Interface\\Icons\\Ability_Warrior_SavageBlow"] = {
			["icon"] = 'Interface\\Icons\\Ability_Warrior_SavageBlow',
			["label"] = 'Warrior - Arms',
		},
		["Interface\\Icons\\Ability_Warrior_InnerRage"] = {
			["icon"] = 'Interface\\Icons\\Ability_Warrior_InnerRage',
			["label"] = 'Warrior - Fury',
		},
		["Interface\\Icons\\Ability_Warrior_DefensiveStance"] = {
			["icon"] = 'Interface\\Icons\\Ability_Warrior_DefensiveStance',
			["label"] = 'Warrior - Protection',
		},
	},
	["texClassificaion"] = {
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicBoss"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicBoss',
			["label"] = 'ClassicBoss',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicElite',
			["label"] = 'ClassicElite',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRare"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRare',
			["label"] = 'ClassicRare',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRareElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationClassic\\ClassicRareElite',
			["label"] = 'ClassicRareElite',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticBoss"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticBoss',
			["label"] = 'MinimalisticBoss',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRare"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRare',
			["label"] = 'MinimalisticRare',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRareElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticRareElite',
			["label"] = 'MinimalisticRareElite',
		},
		["Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticElite"] = {
			["icon"] = 'Interface\\AddOns\\ElvUI_Extras\\Media\\ClassificationMinimal\\MinimalisticElite',
			["label"] = 'MinimalisticElite',
		},
		["Interface\\WorldMap\\GlowSkull_64"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64',
			["label"] = 'GlowSkull',
		},
		["Interface\\WorldMap\\GlowSkull_64Grey"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Grey',
			["label"] = 'GlowSkullGrey',
		},
		["Interface\\WorldMap\\GlowSkull_64Red"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Red',
			["label"] = 'GlowSkullRed',
		},
		["Interface\\WorldMap\\GlowSkull_64Green"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Green',
			["label"] = 'GlowSkullGreen',
		},
		["Interface\\WorldMap\\GlowSkull_64Blue"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Blue',
			["label"] = 'GlowSkullBlue',
		},
		["Interface\\WorldMap\\GlowSkull_64Purple"] = {
			["icon"] = 'Interface\\WorldMap\\GlowSkull_64Purple',
			["label"] = 'GlowSkullPurple',
		},
		["Interface\\WorldMap\\Skull_64"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64',
			["label"] = 'Skull',
		},
		["Interface\\WorldMap\\Skull_64Grey"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Grey',
			["label"] = 'SkullGrey',
		},
		["Interface\\WorldMap\\Skull_64Red"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Red',
			["label"] = 'SkullRed',
		},
		["Interface\\WorldMap\\Skull_64Green"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Green',
			["label"] = 'SkullGreen',
		},
		["Interface\\WorldMap\\Skull_64Blue"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Blue',
			["label"] = 'SkullBlue',
		},
		["Interface\\WorldMap\\Skull_64Purple"] = {
			["icon"] = 'Interface\\WorldMap\\Skull_64Purple',
			["label"] = 'SkullPurple',
		},
	},
	["texGeneral"] = {
		["Interface\\GossipFrame\\AvailableQuestIcon"] = {
			["icon"] = 'Interface\\GossipFrame\\AvailableQuestIcon',
			["label"] = 'Quest Mark',
		},
		["Interface\\Icons\\ABILITY_DualWield"] = {
			["icon"] = 'Interface\\Icons\\ABILITY_DualWield',
			["label"] = 'Kill Mark',
		},
		["Interface\\Icons\\INV_Misc_Note_01"] = {
			["icon"] = 'Interface\\Icons\\INV_Misc_Note_01',
			["label"] = 'Chat Mark',
		},
		["Interface\\Icons\\INV_Misc_Bag_08"] = {
			["icon"] = 'Interface\\Icons\\INV_Misc_Bag_08',
			["label"] = 'Pickup Mark',
		},
		["Interface\\Icons\\ability_hunter_markedfordeath"] = {
			["icon"] = 'Interface\\Icons\\ability_hunter_markedfordeath',
			["label"] = "Hunter's Mark",
		},
    },

	["general"] = {},
	["blizzard"] = {},
	["nameplates"] = {},
	["unitframes"] = {},
}

core.general = { type = "group", name = L["General"], args = {} }
core.blizzard = { type = "group", name = "Blizzard", args = {} }
core.nameplates = { type = "group", name = L["Nameplates"], disabled = function() return not E.private.nameplates.enable end, args = {} }
core.unitframes = { type = "group", name = L["Unitframes"], disabled = function() return not E.private.unitframe.enable end, args = {} }

function core:GetOptions()
	local iconsBrowser, selectedButton
	local ICONS_PER_PAGE, currentPage = 100, 1
	local filteredIcons, allIcons, iconButtons = {}, {}, {}
	local lastSelected = ""

	local function getAllIcons()
		for i = 1, GetNumMacroIcons() do
			local texture = GetMacroIconInfo(i)
			tinsert(allIcons, texture)
		end
		tsort(allIcons)
	end

	local function filterIcons(searchText)
		twipe(filteredIcons)
		searchText = searchText:lower()
		for _, icon in ipairs(allIcons) do
			if find(lower(icon), searchText, 1, true) then
				tinsert(filteredIcons, icon)
			end
		end
	end

	local function highlightButton(button, highlight)
		if highlight then
			button:SetBackdropBorderColor(1, 210/255, 0, 1)
		else
			button:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end
	end

	local function updateIconDisplay(frame)
		local iconContainer = frame.iconContainer
		local pathEditBox = frame.pathEditBox

		local startIndex = (currentPage - 1) * ICONS_PER_PAGE + 1

		for i = 1, ICONS_PER_PAGE do
			local button = iconButtons[i]
			if not button then
				button = CreateFrame("Button", nil, iconContainer)
				button.texture = button:CreateTexture(nil, "ARTWORK")
				button.texture:SetInside(button, E.mult, E.mult)
				button:Size(30)
				S:HandleButton(button)
				button:SetTemplate("Transparent")
				button:StyleButton()

				button:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
					GameTooltip:AddLine(self.iconPath)
					GameTooltip:AddLine(" ")
					GameTooltip:AddLine(L["Click to select."])
					GameTooltip:Show()
				end)

				button:SetScript("OnLeave", function() GameTooltip:Hide() end)

				button:SetScript("OnClick", function(self)
					if selectedButton then
						highlightButton(selectedButton, false)
					end
					selectedButton = self
					highlightButton(self, true)
					lastSelected = self.iconPath
					pathEditBox:SetText(self.iconPath)
					pathEditBox:HighlightText()
					pathEditBox:SetFocus()
				end)

				local col = (i - 1) % 10
				local row = floor((i - 1) / 10)
				button:Point("TOPLEFT", iconContainer, "TOPLEFT", col * 32, -row * 32)

				iconButtons[i] = button
			end

			local iconIndex = startIndex + i - 1
			if iconIndex <= #filteredIcons then
				button.iconPath = filteredIcons[iconIndex]
				button.texture:SetTexture(button.iconPath)
				button:Show()
				if button.iconPath == lastSelected then
					highlightButton(button, true)
					selectedButton = button
				else
					highlightButton(button, false)
				end
			else
				button:Hide()
			end
		end
	end

	local function createIconsBrowser()
		if iconsBrowser then
			if iconsBrowser:IsShown() then
				iconsBrowser:Hide()
			else
				iconsBrowser:Show()
			end
			return
		end

		iconsBrowser = CreateFrame("Frame", "iconsBrowser", UIParent)
		iconsBrowser:SetFrameStrata("FULLSCREEN_DIALOG")
		iconsBrowser:SetFrameLevel(999)
		iconsBrowser:Size(360, 440)
		iconsBrowser:SetClampedToScreen(true)
		iconsBrowser:CreateBackdrop("Transparent")

		iconsBrowser:Point("CENTER", UIParent, "CENTER", 0, 0)

		iconsBrowser:SetMovable(true)
		iconsBrowser:EnableMouse(true)
		iconsBrowser:EnableMouseWheel(1)
		iconsBrowser:RegisterForDrag("LeftButton")
		iconsBrowser:SetScript("OnDragStart", function(self) self:StartMoving() end)
		iconsBrowser:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		iconsBrowser:SetScript("OnMouseWheel", function(self, dir)
			if dir == -1 then
				self.nextButton:GetScript("OnClick")()
			else
				self.prevButton:GetScript("OnClick")()
			end
		end)
		iconsBrowser:SetScript("OnMouseDown", function(self)
			self:SetFrameLevel(999)
			local level = self:GetFrameLevel()
			for _, child in ipairs({self:GetChildren()}) do
				child:SetFrameLevel(level+2)
			end
			self.searchBox.backdrop:SetFrameLevel(level+1)
			self.pathEditBox.backdrop:SetFrameLevel(level+1)
		end)

		local labelHolder = CreateFrame("Frame", "iconsBrowserLabel", iconsBrowser)
		labelHolder:Point("TOP", iconsBrowser, "TOP", 0, -8)
		labelHolder:Size(96, 24)
		local label = labelHolder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		label:SetAllPoints()
		label:SetText(L["Icons Browser"])

		local closeButton = CreateFrame("Button", "iconsBrowserClose", iconsBrowser, "UIPanelCloseButton")
		closeButton:Point("TOPRIGHT", iconsBrowser, "TOPRIGHT")
		closeButton:SetScript("OnClick", function() iconsBrowser:Hide() end)
		S:HandleCloseButton(closeButton)

		local iconContainer = CreateFrame("Frame", "iconsBrowserContainer", iconsBrowser)
		iconContainer:Size(320, 300)
		iconContainer:Point("CENTER", iconsBrowser, "CENTER", 0, -8)
		iconContainer:CreateBackdrop()

		local pathEditBox = CreateFrame("EditBox", "iconsBrowserPath", iconsBrowser, "InputBoxTemplate")
		pathEditBox:Point("TOPLEFT", iconContainer, "TOPLEFT", 0, 24)
		pathEditBox:Point("BOTTOMRIGHT", iconContainer, "TOPRIGHT", 0, 8)
		pathEditBox:SetAutoFocus(false)
		S:HandleEditBox(pathEditBox)

		pathEditBox:SetScript("OnChar", function()
			pathEditBox:SetText(lastSelected)
			pathEditBox:HighlightText()
		end)

		local searchBox = CreateFrame("EditBox", "iconsBrowserSearch", iconsBrowser, "InputBoxTemplate")
		searchBox:Point("TOPLEFT", pathEditBox, "TOPLEFT", 42, 20)
		searchBox:Point("BOTTOMRIGHT", pathEditBox, "TOPRIGHT", 0, 4)
		searchBox:SetAutoFocus(false)
		S:HandleEditBox(searchBox)

		local searchLabelHolder = CreateFrame("Frame", "iconsBrowserSearchLabel", iconsBrowser)
		searchLabelHolder:Point("TOPLEFT", searchBox, "TOPLEFT", -42, 0)
		searchLabelHolder:Point("BOTTOMRIGHT", searchBox, "BOTTOMLEFT", -4, 0)
		local searchLabel = searchLabelHolder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		searchLabel:SetAllPoints()
		searchLabel:SetText(L["Search:"])

		searchBox:SetScript("OnTextChanged", function(self)
			filterIcons(self:GetText())
			currentPage = 1
			updateIconDisplay(iconsBrowser)
			iconsBrowser.pageText:SetText(format("%d/%d", currentPage, max(1, ceil(#filteredIcons / ICONS_PER_PAGE))))
		end)

		local prevButton = CreateFrame("Button", "iconsBrowserPrev", iconsBrowser, "UIPanelButtonTemplate")
		prevButton:Size(24, 16)
		prevButton:Point("TOPLEFT", iconContainer, "BOTTOMLEFT", 0, -32)
		prevButton:SetText("<")
		S:HandleButton(prevButton)

		local nextButton = CreateFrame("Button", "iconsBrowserNext", iconsBrowser, "UIPanelButtonTemplate")
		nextButton:Size(24, 16)
		nextButton:Point("TOPRIGHT", iconContainer, "BOTTOMRIGHT", 0, -32)
		nextButton:SetText(">")
		S:HandleButton(nextButton)

		local pageTextHolder = CreateFrame("Frame", "iconsBrowserPageText", iconsBrowser)
		pageTextHolder:Point("TOPLEFT", prevButton, "TOPRIGHT", 0, 0)
		pageTextHolder:Point("BOTTOMRIGHT", nextButton, "BOTTOMLEFT", 0, 0)
		local pageText = pageTextHolder:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		pageText:SetAllPoints()
		pageText:SetText("1/1")

		prevButton:SetScript("OnClick", function()
			if currentPage == 1 then
				currentPage = ceil(#filteredIcons / ICONS_PER_PAGE)
			else
				currentPage = currentPage - 1
			end
			updateIconDisplay(iconsBrowser)
			pageText:SetText(format("%d/%d", currentPage, max(1, ceil(#filteredIcons / ICONS_PER_PAGE))))
		end)

		nextButton:SetScript("OnClick", function()
			if currentPage == ceil(#filteredIcons / ICONS_PER_PAGE) then
				currentPage = 1
			else
				currentPage = currentPage + 1
			end
			updateIconDisplay(iconsBrowser)
			pageText:SetText(format("%d/%d", currentPage, max(1, ceil(#filteredIcons / ICONS_PER_PAGE))))
		end)

		iconsBrowser.searchBox = searchBox
		iconsBrowser.pathEditBox = pathEditBox
		iconsBrowser.iconContainer = iconContainer
		iconsBrowser.nextButton = nextButton
		iconsBrowser.prevButton = prevButton
		iconsBrowser.pageText = pageText

		getAllIcons()
		filterIcons("")
		updateIconDisplay(iconsBrowser)

		iconsBrowser:Show()
		iconsBrowser:GetScript("OnMouseDown")(iconsBrowser)

		tinsert(UISpecialFrames, "iconsBrowser")
	end

	E.Options.args.Extras = {
		type = "group",
		childGroups = "tab",
		name = core.pluginColor.."Extras",
		args = {
			general = core.general,
			blizzard = core.blizzard,
			nameplates = core.nameplates,
			unitframes = core.unitframes,
			plugin = {
				type = "group",
				name = L["Plugin"],
				args = {
					colors = {
						type = "group",
						name = L["Version: "].."1.08",
						guiInline = true,
						get = function(info) return colorConvert(E.db.Extras[info[#info]]) end,
						set = function(info, r, g, b)
							local color = colorConvert(r, g, b)
							E.db.Extras[info[#info]] = color core[info[#info]] = color
							E:RefreshGUI()
						end,
						args = {
							customColorAlpha = {
								order = 1,
								type = "color",
								name = L["Color A"],
								desc = L["Chat messages, etc."],
							},
							customColorBeta = {
								order = 2,
								type = "color",
								name = L["Color B"],
								desc = L["Chat messages, etc."],
							},
							pluginColor = {
								order = 3,
								type = "color",
								name = L["Plugin Color"],
								desc = "",
							},
							iconsBrowser = {
								order = 4,
								type = "execute",
								name = L["Icons Browser"],
								desc = L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."],
								func = createIconsBrowser,
							},
							addTexture = {
								order = 5,
								type = "input",
								width = "double",
								name = L["Add Texture"],
								desc = L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"],
								get = function() return "" end,
								set = function(_, value)
									if value and value ~= "" then
										local texInfo = {
											icon = value,
											label = gsub(value, ".*\\", ""),
										}
										E.db.Extras.texGeneral[value] = texInfo
										local string = '\124T' .. value .. ':16:16\124t'
										print(core.customColorAlpha .. string .. core.customColorBeta .. L[" added."])
									end
								end,
							},
							removeTexture = {
								order = 6,
								type = "select",
								width = "double",
								name = L["Remove Texture"],
								desc = "",
								get = function() return "" end,
								set = function(_, value)
									for icon in pairs(E.db.Extras.texGeneral) do
										if icon == value then
											E.db.Extras.texGeneral[icon] = nil
											local string = '\124T' .. value .. ':16:16\124t'
											print(core.customColorAlpha .. string .. core.customColorBeta .. L[" removed."])
											break
										end
									end
								end,
								values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
							},
						},
					},
				},
			},
		}
	}
	E.Options.args.Extras.args.general.order = 1
	E.Options.args.Extras.args.blizzard.order = 2
	E.Options.args.Extras.args.nameplates.order = 3
	E.Options.args.Extras.args.unitframes.order = 4
	E.Options.args.Extras.args.plugin.order = 99
end


function core:Initialize()
	self.pluginColor = E.db.Extras.pluginColor
	self.customColorBad = E.db.Extras.customColorBad
	self.customColorAlpha = E.db.Extras.customColorAlpha
	self.customColorBeta = E.db.Extras.customColorBeta

	-- update new elements
	core:SecureHook(E, "ToggleOptionsUI", function()
		local tagGroup = E.Options.args.tagGroup
		if tagGroup and tagGroup.args.Miscellaneous.args.updateshandler then
			tagGroup.args.Miscellaneous.args.updateshandler.hidden = true
		end
		if E.Options.args.nameplate then
			for unitType, unitGroup in pairs({["FRIENDLY_PLAYER"] = 'friendlyPlayerGroup', ["FRIENDLY_NPC"] = 'friendlyNPCGroup',
											["ENEMY_PLAYER"] = 'enemyPlayerGroup', ["ENEMY_NPC"] = 'enemyNPCGroup'}) do
				if not self:IsHooked(E.Options.args.nameplate.args[unitGroup].args.healthGroup, "set") then
					self:SecureHook(E.Options.args.nameplate.args[unitGroup].args.healthGroup, "set", function()
						local oldValue = healthEnabled[unitType]
						healthEnabled[unitType] = NP.db.units[unitType].health.enable

						if oldValue ~= healthEnabled[unitType] then
							for frame in pairs(NP.VisiblePlates) do
								self:OnShowHide(frame, frame.Health and frame.Health:IsVisible())
							end
						end
					end)
				end
			end
		end
	end)

	healthEnabled["FRIENDLY_PLAYER"] = NP.db.units["FRIENDLY_PLAYER"].health.enable
	healthEnabled["FRIENDLY_NPC"] = NP.db.units["FRIENDLY_NPC"].health.enable
	healthEnabled["ENEMY_PLAYER"] = NP.db.units["ENEMY_PLAYER"].health.enable
	healthEnabled["ENEMY_NPC"] = NP.db.units["ENEMY_NPC"].health.enable

	if isAwesome then
		if E.private.nameplates.enable then
			NP:UnregisterEvent("PLAYER_TARGET_CHANGED")
			NP:UnregisterEvent("PLAYER_FOCUS_CHANGED")
			NP:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			NP:UnregisterEvent("ARENA_OPPONENT_UPDATE")
			NP:UnregisterEvent("PARTY_MEMBERS_CHANGED")
			NP:UnregisterEvent("RAID_ROSTER_UPDATE")
			NP:UnregisterEvent("UNIT_NAME_UPDATE")

			for _, func in pairs({'UnitClass', 'GetUnitInfo', 'GetUnitByName', 'SetMouseoverFrame', 'SetTargetFrame',
									'ResetNameplateFrameLevel', 'UnitDetailedThreatSituation'}) do
				self:RawHook(NP, func)
			end
			self:RawHook(LAI, "GUIDAura")
			LAI.UnregisterAllCallbacks(NP)
		else
			self:UnregisterAllEvents()
		end
	end

	EP:RegisterPlugin(AddOnName, self.GetOptions)

	for _, module in pairs(self.modules) do
        module()
    end

	self:SecureHook(E, "SetMoversClampedToScreen", function(_, toggle)
		self.reload = not toggle
		self.plateAnchoring = {
			["Elite"] = function(unitType)
				if unitType == "ENEMY_NPC" or unitType == "FRIENDLY_NPC" then
					return NP.db.units[unitType].eliteIcon
				end
			end
		}
		for _, module in pairs(self.modules) do
			module()
		end
	end)

	local shadow_db = E.globalShadow
	if shadow_db then
		local M = E:GetModule("Misc")
		local chatBubbles = E.private.general.chatBubbles
		local createShadow = E.CreateGlobalShadow
		local size = shadow_db.size
		local r, g, b, a = unpack(shadow_db.color)

		createShadow(nil, _G["Minimap"], size, r, g, b, a)

		for _, frame in ipairs({WorldFrame:GetChildren()}) do
			if frame.isSkinnedElvUI then
				createShadow(nil, frame, size, r, g, b, a)
				if chatBubbles == "backdrop_noborder" then
					frame.globalShadow:SetOutside(frame.backdrop, size, size)
				elseif frame.globalShadow and chatBubbles == "nobackdrop" then
					frame.globalShadow:Hide()
				end
			end
		end

		if E.pendingShadowUpdate then
			for frame in pairs(E.pendingShadowUpdate) do
				createShadow(nil, frame, size, r, g, b, a)
			end
		end

		if not self:IsHooked(M, "SkinBubble") then
			self:SecureHook(M, "SkinBubble", function(_, frame)
				createShadow(nil, frame, size, r, g, b, a)
				if chatBubbles == "backdrop_noborder" then
					frame.globalShadow:SetOutside(frame.backdrop, size, size)
				elseif frame.globalShadow and chatBubbles == "nobackdrop" then
					frame.globalShadow:Hide()
				end
			end)
		end

		if not self:IsHooked(NP, "StyleFrame") then
			self:SecureHook(NP, "StyleFrame", function(_, frame)
				createShadow(nil, frame, size, r, g, b, a)
			end)
		end

		if not self:IsHooked(M, "SkinBubble") then
			self:SecureHook(M, "SkinBubble", function(_, frame)
				createShadow(nil, frame, size, r, g, b, a)
			end)
		end

		tinsert(self.frameUpdates, function()
			for _, frame in ipairs(self:AggregateUnitFrames()) do
				local healthBackdrop = frame.Health.backdrop
				local powerBackdrop = (frame.USE_POWERBAR and frame.Power) and frame.Power.backdrop
				local infoPanelBackdrop = (frame.USE_INFO_PANEL and frame.InfoPanel) and frame.InfoPanel.backdrop

				if healthBackdrop.globalShadow and powerBackdrop and powerBackdrop.globalShadow then
					healthBackdrop.globalShadow:SetOutside(frame, size, size)

					if frame.POWERBAR_DETACHED then
						powerBackdrop.globalShadow:Show()
					else
						powerBackdrop.globalShadow:Hide()
					end
				end

				if infoPanelBackdrop and infoPanelBackdrop.globalShadow then
					infoPanelBackdrop.globalShadow:Hide()
				end
			end

			local target = _G["ElvUF_Target"]
			if target and target.USE_CLASSBAR then
				for _, comboPoint in ipairs(target.ComboPoints) do
					local backdrop = comboPoint.backdrop

					if backdrop and backdrop.globalShadow then
						if not target.USE_MINI_CLASSBAR then
							backdrop.globalShadow:Hide()
						else
							backdrop.globalShadow:Show()
						end
					end
				end

				local backdrop = target.ComboPoints and target.ComboPoints.backdrop

				if backdrop and backdrop.globalShadow then
					if not target.CLASSBAR_DETACHED then
						backdrop.globalShadow:Hide()
					else
						backdrop.globalShadow:Show()
					end
				end
			end
		end)
	end
	E.pendingShadowUpdate = nil
end

local function InitializeCallback()
	core:Initialize()
end

LSM:Register("font", "Extras_Favourite (Montserrat)", "Interface\\AddOns\\ElvUI_Extras\\Media\\Favourite.ttf")
LSM:Register("font", "Invisible", "Interface\\AddOns\\ElvUI_Extras\\Media\\Invisible.ttf")

E:RegisterModule(core:GetName(), InitializeCallback)