local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("CooldownsNP", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM
local LAI = E.Libs.LAI

local modName = mod:GetName()
local activeCooldowns, petSpells, highlightedSpells, testSpells, testing = {}, {}, {}, {}, false
local edgeFile = LSM:Fetch("border", "ElvUI GlowBorder")

local band = bit.band
local _G, pairs, ipairs, select, unpack, tonumber, next = _G, pairs, ipairs, select, unpack, tonumber, next
local gsub, upper, match, find, format = string.gsub, string.upper, string.match, string.find, string.format
local random, floor, min, ceil, abs = math.random, math.floor, math.min, math.ceil, math.abs
local tinsert, tremove, tsort, twipe = table.insert, table.remove, table.sort, table.wipe
local GetSpellInfo, GetSpellLink, GetTime = GetSpellInfo, GetSpellLink, GetTime
local IsInInstance, IsResting = IsInInstance, IsResting
local COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER, COMBATLOG_OBJECT_CONTROL_PLAYER
local UNITNAME_SUMMON_TITLES = {gsub(format(UNITNAME_SUMMON_TITLE1, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE3, 1), '[%d%p%s]+', ''), gsub(format(UNITNAME_SUMMON_TITLE5, 1), '[%d%p%s]+', '')}


local scanTool = CreateFrame("GameTooltip", "ScanTooltipNP", nil, "GameTooltipTemplate")
scanTool:SetOwner(WorldFrame, "ANCHOR_NONE")

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

local function testMode()
	for plate in pairs(NP.VisiblePlates) do
		if plate.CDTracker then plate.CDTracker:Hide() plate.CDTracker = nil end
		if activeCooldowns[plate.UnitName] then twipe(activeCooldowns[plate.UnitName]) end
	end
	if testing then return end

    local spellList = E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType].spellList
    local spellIDs = {}

    local index = 0
    for id in pairs(spellList) do
        index = index + 1
        if random() < 1 / index then
            tinsert(spellIDs, id)
        end
    end

    if #spellIDs == 0 then
        for id in pairs(fallbackSpells) do
            tinsert(spellIDs, id)
        end
    end

    local numSpells = random(2, 7)
    for _ = 1, numSpells do
        local spellID = spellIDs[random(#spellIDs)]
        local duration = spellList[spellID] or fallbackSpells[spellID]
        local startTime = GetTime() - random(0, duration/2)
        local endTime = startTime + duration

        local spellInfo = {
            spellID = spellID,
            startTime = startTime,
            endTime = endTime,
            icon = select(3, GetSpellInfo(spellID))
        }

        tinsert(testSpells, spellInfo)
    end

    local trinket = {
		spellID = 59752,
		startTime = GetTime() - random(0, 120/2),
		endTime = GetTime() - random(0, 120/2) + 120,
		icon = select(3, GetSpellInfo(59752))
	}
	tinsert(testSpells, random(1, #testSpells), trinket)

	for plate in pairs(NP.VisiblePlates) do
		local unitType = plate.UnitType
		if unitType and unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
			activeCooldowns[plate.UnitName] = testSpells
			mod:AttachCooldownsToPlate(plate, activeCooldowns[plate.UnitName], true)
		end
	end
end

local function updateAllPlates()
	for plate in pairs(NP.VisiblePlates) do
		if plate.CDTracker then
			plate.CDTracker:Hide()
			plate.CDTracker = nil
		end
		local unitName, unitType = plate.UnitName, plate.UnitType
		if unitName and activeCooldowns[unitName] and next(activeCooldowns[unitName]) and (unitType == 'ENEMY_PLAYER' or unitType == 'FRIENDLY_PLAYER') then
			mod:AttachCooldownsToPlate(plate, activeCooldowns[plate.UnitName], testing)
		end
	end
end

local function createCompareFunction(sorting, prioritizeTrinkets)
    return function(a, b)
        if prioritizeTrinkets then
            local aIsTrinket = trinkets[a.spellID]
            local bIsTrinket = trinkets[b.spellID]
            if aIsTrinket and not bIsTrinket then
                return true
            elseif not aIsTrinket and bIsTrinket then
                return false
            end
        end

        if sorting == "durationAsc" then
            return a.endTime < b.endTime
        elseif sorting == "durationDesc" then
            return a.endTime > b.endTime
        elseif sorting == "timeUsedDesc" then
            return a.startTime > b.startTime
        else
            return a.startTime < b.startTime
        end
    end
end


P["Extras"]["nameplates"][modName] = {
	["petSpells"] = {
		--Pets(Death Knight)
		--I haven't seen these working. Will have to look into it.
		--[91797] = true,				--"Monstrous Blow",
		--[91837] = true,				--"Putrid Bulwark",
		--[91802] = true,				--"Shambling Rush",
		--[47482] = true,				--"Leap",
		--[91809] = true,				--"Leap",
		--[91800] = true,				--"Gnaw",
		--[47481] = true,				--"Gnaw",
		--Pets(Hunter)
		--[90339] = true,				--"Harden Carapace",
		[61685] = true,				--"Charge",
		[50519] = true,				--"Sonic Blast",
		--[35290] = true,				--"Gore",
		[50245] = true,				--"Pin",
		[50433] = true,				--"Ankle Crack",
		[26090] = true,				--"Pummel",
		--[93434] = true,				--"Horn Toss",
		--[57386] = true,				--"Stampede",
		[50541] = true, 				--"Clench",
		--[26064] = true, 				--"Shell Shield",
		--[35346] = true, 				--"Time Warp",
		--[93433] = true,				--"Burrow Attack",
		--[54644] = true,				--"Frost Breath",
		--[34889] = true,				--"Fire Breath",
		--[50479] = true,				--"Nether Shock",
		--[50518] = true,				--"Ravage",
		--[35387] = true, 				--"Corrosive Spit",
		[54706] = true,				--"Vemom Web Spray",
		[4167] = true,				--"Web",
		[50274] = true,				--"Spore Cloud",
		--[24844] = true, 				--"Lightning Breath",
		--[54680] = true,				--"Monstrous Bite",
		[50271] = true, 				--"Tendon Rip",
		[50318] = true,				--"Serenity Dust",
		--[50498] = true, 				--"Tear Armor",
		[50285] = true, 				--"Dust Cloud",
		--[56626] = true,				--"Sting",
		--[24604] = true,				--"Furious Howl",
		--[90309] = true,				--"Terrifying Roar",
		--[24423] = true,				--"Demoralizing Screech",
		--[93435] = true,				--"Roar of Courage",
		--[58604] = true,				--"Lava Breath",
		--[53490] = true,				--"Bullheaded",
		--[23145] = true,				--"Dive",
		[55709] = true,				--"Heart of the Phoenix",
		[53426] = true,				--"Lick Your Wounds",
		--[53401] = true, 				--"Rabid",
		[53476] = true,				--"Intervene",
		[53480] = true,				--"Roar of Sacrifice",
		[53478] = true,				--"Last Stand",
		[53517] = true,				--"Roar of Recovery",
		--Pets(Warlock)
		[19647] = true,				--"Spell Lock",
		[7812] = true,				--"Sacrifice",
		--Pets(Mage)
		[33395] = true,
	},
	["FRIENDLY_PLAYER"] = {
		["enabled"] = false,
		["highlightedSpells"] = {},
		["spellList"] = {
-- stolen from Icicle
			--Misc
			[11732] = 120, -- healthstone
			[26297] = 180,				--"Berserking",
			[20594] = 120,				--"Stoneform",
			[58984] = 120,				--"Shadowmeld",
			[20589] = 90,				--"Escape Artist",
			[59752] = 120,				--"Every Man for Himself",
			[7744] = 120,				--"Will of the Forsaken",
			[50613] = 120,				--"Arcane Torrent",
			[11876] = 120,				--"War Stomp",
			[42292] = 120,				--"PvP Trinket",
			--Pets(Death Knight)
			--I haven't seen these working. Will have to look into it.
			--[91797] = 60,				--"Monstrous Blow",
			--[91837] = 45,				--"Putrid Bulwark",
			--[91802] = 30,				--"Shambling Rush",
			--[47482] = 30,				--"Leap",
			--[91809] = 30,				--"Leap",
			--[91800] = 60,				--"Gnaw",
			--[47481] = 60,				--"Gnaw",
			--Pets(Hunter)
			--[90339] = 60,				--"Harden Carapace",
			[61685] = 25,				--"Charge",
			[50519] = 60,				--"Sonic Blast",
			--[35290] = 10,				--"Gore",
			[50245] = 40,				--"Pin",
			[50433] = 10,				--"Ankle Crack",
			[26090] = 30,				--"Pummel",
			--[93434] = 90,				--"Horn Toss",
			--[57386] = 15,				--"Stampede",
			[50541] = 60, 				--"Clench",
			--[26064] = 60, 				--"Shell Shield",
			--[35346] = 15, 				--"Time Warp",
			--[93433] = 30,				--"Burrow Attack",
			--[54644] = 10,				--"Frost Breath",
			--[34889] = 30,				--"Fire Breath",
			--[50479] = 40,				--"Nether Shock",
			--[50518] = 15,				--"Ravage",
			--[35387] = 6, 				--"Corrosive Spit",
			[54706] = 40,				--"Vemom Web Spray",
			[4167] = 40,				--"Web",
			[50274] = 12,				--"Spore Cloud",
			--[24844] = 30, 				--"Lightning Breath",
			--[54680] = 8,				--"Monstrous Bite",
			[50271] = 10, 				--"Tendon Rip",
			[50318] = 60,				--"Serenity Dust",
			--[50498] = 6, 				--"Tear Armor",
			[50285] = 40, 				--"Dust Cloud",
			--[56626] = 45,				--"Sting",
			--[24604] = 45,				--"Furious Howl",
			--[90309] = 45,				--"Terrifying Roar",
			--[24423] = 10,				--"Demoralizing Screech",
			--[93435] = 45,				--"Roar of Courage",
			--[58604] = 8,				--"Lava Breath",
			--[53490] = 180,				--"Bullheaded",
			--[23145] = 32,				--"Dive",
			[55709] = 480,				--"Heart of the Phoenix",
			[53426] = 180,				--"Lick Your Wounds",
			--[53401] = 45, 				--"Rabid",
			[53476] = 30,				--"Intervene",
			[53480] = 60,				--"Roar of Sacrifice",
			[53478] = 360,				--"Last Stand",
			[53517] = 180,				--"Roar of Recovery",
			--Pets(Warlock)
			[19647] = 24,				--"Spell Lock",
			[7812] = 60,				--"Sacrifice",
			--Pets(Mage)
			[33395] = 25,				--"Freeze", --No way to tell which WE cast this still usefull to some degree.
			--Death Knight
			[49039] = 120,				--"Lichborne",
			[47476] = 60,				--"Strangulate",
			[48707] = 45,				--"Anti-Magic Shell",
			[49576] = 25,				--"Death Grip",
			[47528] = 10,				--"Mind Freeze",
			[49222] = 60,				--"Bone Shield",
			--[51271] = 60,				--"Pillar of Frost",
			[51052] = 120,				--"Anti-Magic Zone",
			[49203] = 60,				--"Hungering Cold",
			--[49028] = 90, 				--"Dancing Rune Weapon",
			[49206] = 180,				--"Summon Gargoyle",
			--[43265] = 30,				--"Death and Decay",
			[48792] = 180,				--"Icebound Fortitude",
			--[48743] = 120,				--"Death Pact",
			--[42650] = 600,				--"Army of the Dead",
			--Druid
			[22812] = 60,				--"Barkskin",
			--[17116] = 180,				--"Nature's Swiftness",
			--[33891] = 180,				--"Tree of Life",
			[16979] = 14,				--"Feral Charge - Bear",
			[49376] = 28,				--"Feral Charge - Cat",
			[61336] = 180,				--"Survival Instincts",
			--[50334] = 180,				--"Berserk",
			[50516] = 17,				--"Typhoon",
			[33831] = 180,				--"Force of Nature",
			--[22570] = 10,				--"Maim",
			--[18562] = 15,				--"Swiftmend",
			[48505] = 60,				--"Starfall",
			[53201] = 60,				--"Starfall"
			[5211] = 50,				--"Bash",
			--[22842] = 180,				--"Frenzied Regeneration",
			--[16689] = 60, 				--"Nature's Grasp",
			--[740] = 480,				--"Tranquility",
			--[78674] = 15,				--"Starsurge",
			[29166] = 180,				--"Innervate",
			--Hunter
			--[82726] = 120,				--"Fervor",
			[19386] = 54,				--"Wyvern Sting",
			[3045] = 180,				--"Rapid Fire",
			[53351] = 10,				--"Kill Shot",
			[53271] = 35, 				--"Master's Call",
			--[51753] = 60,				--"Camouflage",
			[19263] = 120,				--"Deterrence",
			[19503] = 30,				--"Scatter Shot",
			[23989] = 180,				--"Readiness",
			[34490] = 20,				--"Silencing Shot",
			[19574] = 90,				--"Bestial Wrath",
			--Mage
			[2139] = 24,				--"Counterspell",
			[42950] = 20,				--"Dragon's Breath",
			[44572] = 30,				--"Deep Freeze",
			[11958] = 384,				--"Cold Snap",
			[45438] = 300,				--"Ice Block",
			[12042] = 106,				--"Arcane Power",
			--[12051] = 240,				--"Evocation",
			--[122] = 20,					--"Frost Nova",
			--[11426] = 24,				--"Ice Barrier",
			[12472] = 144,				--"Icy Veins",
			--[55342] = 180,				--"Mirror Image",
			[66] = 132,					--"Invisibility",
			[11113] = 15, 				--"Blast Wave",
			[12043] = 90,				--"Presence of Mind",
			[11129] = 120,				--"Combustion",
			[31661] = 17,				--"Dragon's Breath",
			--Paladin
			[1044] = 25,				--"Hand of Freedom",
			--[31884] = 120,				--"Avenging Wrath",
			[10308] = 40,					--"Hammer of Justice",
			[31935] = 15,				--"Avenger's Shield",
			--[633] = 420,				--"Lay on Hands",
			[10278] = 180,				--"Hand of Protection",
			--[498] = 40,					--"Divine Protection",
			--[54428] = 120,			--"Divine Plea",
			[642] = 300,				--"Divine Shield",
			[6940] = 96,				--"Hand of Sacrifice",
			--[86150] = 120,				--"Guardian of Ancient Kings",
			--[31842] = 180,			--"Divine Favor",
			[31821] = 120,				--"Aura Mastery",
			--[70940] = 120,			--"Divine Guardian",
			[20066] = 60,				--"Repentance",
			--[31850] = 180,				--"Ardent Defender",
			--Priest
			[64044] = 90,				--"Psychic Horror",
			[10890] = 23,				--"Psychic Scream",
			[15487] = 45,				--"Silence",
			[47585] = 75,				--"Dispersion",
			[33206] = 180,				--"Pain Suppression",
			[10060] = 120,				--"Power Infusion",
			--[586] = 15,				--"Fade",
			[32379] = 10,				--"Shadow Word: Death",
			--[6346] = 180,				--"Fear Ward",
			--[64901] = 360,			--"Hymn of Hope",
			--[64843] = 480,			--"Divine Hymn",
			--[19236] = 120,			--"Desperate Prayer",
			--[724] = 180,				--"Lightwell",
			--[62618] = 120,			--"Power Word: Barrier",
			--Rogue
			[2094] = 120,				--"Blind",
			[1766] = 10,				--"Kick",
			[2983] = 60,				--"Sprint",
			[14185] = 300,				--"Preparation",
			[31224] = 70,				--"Cloak of Shadows",
			[1856] = 120,				--"Vanish",
			[36554] = 24,				--"Shadowstep",
			[5277] = 180,				--"Evasion",
			--[408] = 20,				--"Kidney Shot",
			[51722] = 60,				--"Dismantle",
			--[14177] = 120,			--"Cold Blood",
			--[51690] = 120,			--"Killing Spree",
			--[51713] = 60, 			--"Shadow Dance",
			--Shaman
			[8177] = 14,				--"Grounding Totem",
			[57994] = 5,				--"Wind Shear",
			[32182] = 300,				--"Heroism",
			[2825] = 300,				--"Bloodlust",
			[51533] = 120,				--"Feral Spirit",
			[16190] = 180,				--"Mana Tide Totem",
			[30823] = 60,				--"Shamanistic Rage",
			[51490] = 35,				--"Thunderstorm",
			[2484] = 15,				--"Earthbind Totem",
			[5730] = 20,				--"Stoneclaw Totem",
			[51514] = 35,				--"Hex",
			--[79206] = 120,			--"Spiritwalker's Grace",
			[16166] = 180,			--"Elemental Mastery",
			--[16188] = 120,				--"Nature's Swiftness",
			--Warlock
			[30283] = 20,				--"Shadowfury",
			[6789] = 120,				--"Death Coil",
			--[17962] = 8,				--"Conflagrate",
			--[74434] = 45,				--"Soulburn",
			--[6229] = 30,				--"Shadow Ward",
			[5484] = 32,				--"Howl of Terror",
			[54785] = 45,				--"Demon Leap",
			[48020] = 26,				--"Demonic Circle: Teleport",
			[17877] = 15,				--"Shadowburn",
			--[71521] = 12,				--"Hand of Gul'dan",
			--[91711] = 30,				--"Nether Ward",
			--Warrior
			--[12292] = 144, 				--"Death Wish",
			--[86346] = 20,				--"Colossus Smash",
			[100] = 15,					--"Charge",
			[6552] = 10,				--"Pummel",
			[72] = 12,					--"Shield Bash",
			[23920] = 9,				--"Spell Reflection",
			--[2565] = 30,				--"Shield Block",
			[676] = 60,					--"Disarm",
			--[5246] = 120,				--"Intimidation Shout",
			[871] = 120,				--"Shield Wall",
			[20252] = 20,				--"Intercept",
			--[20230] = 300,			--"Retaliation",
			--[1719] = 240,				--"Recklessness",
			--[3411] = 30,				--"Intervene",
			[64382] = 90,				--"Shattering Throw",
			--[6544] = 40,				--"Heroic Leap",
			[12809] = 30,				--"Concussion Blow",
			[12975] = 180,				--"Last Stand",
			--[12328] = 60,				--"Sweeping Strikes",
			--[85730] = 120,			--"Deadly Calm",
			[60970] = 30,				--"Heroic Fury",
			[46924] = 75,				--"Bladestorm",
			[46968] = 17,				--"Shockwave",
		},
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

function mod:LoadConfig()
	local function selectedType() return E.db.Extras.nameplates[modName].selectedType end
	local function selectedSpell() return tonumber(E.db.Extras.nameplates[modName][selectedType()].selectedSpell) end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Cooldowns"],
		args = {
			Cooldowns = {
				order = 0,
				type = "group",
				name = L["Cooldowns"],
				guiInline = true,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].enabled end,
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						width = "full",
						disabled = false,
						name = core.pluginColor..L["Enable"],
						desc = L["Draws player cooldowns."],
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
					testMode = {
						order = 1,
						type = "execute",
						name = L["Test Mode"],
						desc = "",
						func = function() testMode() testing = not testing end,
					},
					selectedType = {
						order = 2,
						type = "select",
						disabled = false,
						name = L["Select Type"],
						desc = "",
						values = function()
							local list = {}
							for type in pairs(E.db.Extras.nameplates[modName]) do
								if upper(type) == type then list[type] = L[type] end
							end
							return list
						end,
						get = function(info) return E.db.Extras.nameplates[modName][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][info[#info]] = value if testing then testMode() else self:Toggle() end end,
					},
					showAll = {
						order = 3,
						type = "toggle",
						name = L["Show Everywhere"],
						desc = "",
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
					showCity = {
						order = 4,
						type = "toggle",
						name = L["Show in Cities"],
						desc = "",
						hidden = function() return E.db.Extras.nameplates[modName][selectedType()].showAll end,
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
					showBG = {
						order = 5,
						type = "toggle",
						name = L["Show in Battlegrounds"],
						desc = "",
						hidden = function() return E.db.Extras.nameplates[modName][selectedType()].showAll end,
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
					showArena = {
						order = 6,
						type = "toggle",
						name = L["Show in Arenas"],
						desc = "",
						hidden = function() return E.db.Extras.nameplates[modName][selectedType()].showAll end,
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
					showInstance = {
						order = 7,
						type = "toggle",
						name = L["Show in Instances"],
						desc = "",
						hidden = function() return E.db.Extras.nameplates[modName][selectedType()].showAll end,
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
					showWorld = {
						order = 8,
						type = "toggle",
						name = L["Show in the World"],
						desc = "",
						hidden = function() return E.db.Extras.nameplates[modName][selectedType()].showAll end,
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value self:Toggle() end,
					},
				},
			},
			header = {
				type = "group",
				name = L["Header"],
				guiInline = true,
				get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].enabled end,
				args = {
					level = {
						order = 1,
						type = "range",
						name = L["Level"],
						desc = "",
						min = 1, max = 200, step = 1
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
				get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].enabled end,
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
						get = function(info) return unpack(E.db.Extras.nameplates[modName][selectedType()][info[#info-1]].borderCustomColor) end,
						set = function(info, r, g, b) E.db.Extras.nameplates[modName][selectedType()][info[#info-1]].borderCustomColor = { r, g, b } self:Toggle() end,
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
				get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].enabled end,
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
				get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName][selectedType()][info[#info-1]][info[#info]] = value self:Toggle() end,
				disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].enabled end,
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
				disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].enabled end,
				args = {
					addSpell = {
						order = 1,
						type = "input",
						name = L["Add Spell (by ID)"],
						desc = L["Format: 'spellID cooldown time', e.g. 42292 120"],
						get = function() return "" end,
						set = function(_, value)
							local spellID, cooldownTime = match(value, '%D*(%d+)%D*(%d+)')
							if spellID and GetSpellInfo(spellID) then
								cooldownTime = cooldownTime or LAI.spellDuration[spellID]
								if not cooldownTime then return end
								E.db.Extras.nameplates[modName][selectedType()].spellList[tonumber(spellID)] = cooldownTime
								local _, _, icon = GetSpellInfo(spellID)
								local link = GetSpellLink(spellID)
								icon = gsub(icon, '\124', '\124\124')
								local string = '\124T' .. icon .. ':16:16\124t' .. link
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
							E.db.Extras.nameplates[modName][selectedType()].spellList[spellID] = nil
							local _, _, icon = GetSpellInfo(spellID)
							local link = GetSpellLink(spellID)
							icon = gsub(icon, '\124', '\124\124')
							local string = '\124T' .. icon .. ':16:16\124t' .. link
							core:print('REMOVED', string)
						end,
						disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].spellList[selectedSpell()] end,
					},
					selectedSpell = {
						order = 3,
						type = "select",
						width = "double",
						name = L["Select Spell"],
						desc = "",
						get = function(info) return E.db.Extras.nameplates[modName][selectedType()][info[#info]] end,
						set = function(info, value)
							E.db.Extras.nameplates[modName][selectedType()][info[#info]] = value
							if not E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] then
								E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] = { ["enabled"] = false, ["size"] = 1, ["color"] = {0,0,0,1} }
							end
						end,
						values = function()
							local values = {}
							for id in pairs(E.db.Extras.nameplates[modName][selectedType()].spellList) do
								local name = GetSpellInfo(id) or ""
								local icon = select(3, GetSpellInfo(id))
								icon = icon and "|T"..icon..":0|t" or ""
								values[id] = format("%s %s (%s)", icon, name, id)
							end
							return values
						end,
						sorting = function()
							local sortedKeys = {}
							for id in pairs(E.db.Extras.nameplates[modName][selectedType()].spellList) do
								tinsert(sortedKeys, id)
							end
							tsort(sortedKeys, function(a, b)
								local nameA = GetSpellInfo(a) or ""
								local nameB = GetSpellInfo(b) or ""
								return nameA < nameB
							end)
							return sortedKeys
						end,
					},
					shadow = {
						order = 4,
						type = "toggle",
						name = L["Shadow"],
						desc = L["For the important stuff."],
						get = function() return E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] and E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].enabled or false end,
						set = function(_, value) E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].enabled = value self:Toggle() end,
						disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].selectedSpell end,
					},
					petSpell = {
						order = 5,
						type = "toggle",
						name = L["Pet Ability"],
						desc = L["Pet casts require some special treatment."],
						get = function() return E.db.Extras.nameplates[modName].petSpells[selectedSpell()] end,
						set = function(_, value) E.db.Extras.nameplates[modName].petSpells[selectedSpell()]= value and value or nil self:Toggle() end,
						disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].selectedSpell end,
					},
					shadowSize = {
						order = 6,
						type = "range",
						name = L["Shadow Size"],
						desc = "",
						min = 1, max = 12, step = 1,
						get = function() return E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] and E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].size or 0 end,
						set = function(_, value) E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].size = value self:Toggle() end,
						disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] or not E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].enabled end,
					},
					shadowColor = {
						order = 7,
						type = "color",
						hasAlpha = true,
						name = L["Shadow Color"],
						desc = "",
						get = function() return unpack(E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] and E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].color or {}) end,
						set = function(_, r, g, b, a) E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].color = { r, g, b, a } self:Toggle() end,
						disabled = function() return not E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()] or not E.db.Extras.nameplates[modName][selectedType()].highlightedSpells[selectedSpell()].enabled end,
					},
				},
			},
		},
	}
	if not E.db.Extras.nameplates[modName]['ENEMY_PLAYER'] then
		E.db.Extras.nameplates[modName]['ENEMY_PLAYER'] = CopyTable(E.db.Extras.nameplates[modName]['FRIENDLY_PLAYER'])
	end
end


local function getColorByTime(remainingTime, totalTime, unitType)
    local percentage = remainingTime / totalTime

    local r = unitType == 'ENEMY_PLAYER' and (1 - percentage) or percentage
    local g = unitType == 'ENEMY_PLAYER' and percentage or (1 - percentage)

    return r, g
end

local function setFillPoints(cooldown, fillWidth, direction)
    local border = cooldown.border
    local fill = cooldown.fill

	fill:ClearAllPoints()

    if direction == "LEFT" then
        fill:Point("TOPRIGHT", cooldown, "TOPRIGHT", -border, -border)
        fill:Point("BOTTOMLEFT", cooldown, "BOTTOMLEFT", fillWidth + border, border)
    elseif direction == "RIGHT" then
        fill:Point("TOPLEFT", cooldown, "TOPLEFT", border, -border)
        fill:Point("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", -fillWidth - border, border)
    elseif direction == "TOP" then
		fill:Point("BOTTOMLEFT", cooldown, "BOTTOMLEFT", border, border)
        fill:Point("TOPRIGHT", cooldown, "TOPRIGHT", -border, -fillWidth - border)
    elseif direction == "BOTTOM" then
        fill:Point("TOPLEFT", cooldown, "TOPLEFT", border, -border)
        fill:Point("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", -border, fillWidth)
    end
end

local function setFillPointsReversed(cooldown, fillWidth, direction)
    local border = cooldown.border
    local fill = cooldown.fill
    local size = cooldown.size

    fill:ClearAllPoints()

     if direction == "LEFT" then
        fill:Point("TOPLEFT", cooldown, "TOPLEFT", border, -border)
        fill:Point("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", fillWidth - size - border, border)
    elseif direction == "RIGHT" then
        fill:Point("TOPRIGHT", cooldown, "TOPRIGHT", -border, -border)
		fill:Point("BOTTOMLEFT", cooldown, "BOTTOMLEFT", size - fillWidth + border, border)
    elseif direction == "TOP" then
        fill:SetPoint("TOPLEFT", cooldown, "TOPLEFT", border, -border)
        fill:SetPoint("BOTTOMRIGHT", cooldown, "BOTTOMRIGHT", -border, fillWidth - border)
    elseif direction == "BOTTOM" then
        fill:SetPoint("BOTTOMLEFT", cooldown, "BOTTOMLEFT", border, border)
        fill:SetPoint("TOPRIGHT", cooldown, "TOPRIGHT", -border, -(size - fillWidth) + border)
    end
end

local function combatLogEvent(_, ...)
    local _, eventType, _, sourceName, sourceFlags, _, _, _, spellID = ...

    if eventType == "SPELL_CAST_SUCCESS" and sourceName then
		local isAnotherPlayer = (band(sourceFlags, COMBATLOG_OBJECT_TYPE_PLAYER) == COMBATLOG_OBJECT_TYPE_PLAYER or band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) == COMBATLOG_OBJECT_CONTROL_PLAYER)
		if not isAnotherPlayer then return end

		local startTime = GetTime()
		for _, type in pairs({'ENEMY_PLAYER', 'FRIENDLY_PLAYER'}) do
			if E.db.Extras.nameplates[modName][type].spellList[spellID] then
				local endTime = startTime + E.db.Extras.nameplates[modName][type].spellList[spellID]
				mod:UpdateCooldowns(match(sourceName, '%P+'), spellID, startTime, endTime)
				break
			end
		end
    end
end


function mod:UpdateCooldowns(playerName, spellID, startTime, endTime)
	local remaining = endTime - GetTime()
	if remaining <= 0 then return end

    activeCooldowns[playerName] = activeCooldowns[playerName] or {}

    local spellInfo = {
        spellID = spellID,
        startTime = startTime,
        endTime = endTime,
        icon = select(3, GetSpellInfo(spellID))
    }

    tinsert(activeCooldowns[playerName], spellInfo)
	self:UpdatePlates(playerName)
end

function mod:HandlePets(plate, petName)
	local blizzplate = plate:GetParent()
	local ownerName = getPetOwner(blizzplate.unit and blizzplate.unit or petName)
	if ownerName then
		activeCooldowns[ownerName] = activeCooldowns[ownerName] or {}
		if petName ~= ownerName then
			for _, spellInfo in ipairs(activeCooldowns[petName]) do
				tinsert(activeCooldowns[ownerName], spellInfo)
			end
			twipe(activeCooldowns[petName])
		end
		for plate in pairs(NP.VisiblePlates) do
			local unitName, unitType = plate.UnitName, plate.UnitType
			if unitName and unitName == ownerName and unitType and (unitType == 'ENEMY_PLAYER' or unitType == 'FRIENDLY_PLAYER') then
				self:AttachCooldownsToPlate(plate, activeCooldowns[ownerName])
				return
			end
		end
	end
end

function mod:UpdatePlates(playerName)
	for plate in pairs(NP.VisiblePlates) do
		if plate.UnitName and plate.UnitName == playerName then
			if activeCooldowns[playerName] and next(activeCooldowns[playerName]) then
				local unitType = plate.UnitType
				if unitType then
					if unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER' then
						self:AttachCooldownsToPlate(plate, activeCooldowns[playerName])
					else
						self:HandlePets(plate, playerName)
					end
				end
			elseif plate.CDTracker then
				plate.CDTracker:Hide()
			end
		end
	end
end

function mod:AttachCooldownsToPlate(plate, cooldowns, testMode)
	local unitType
	if not testMode then
		unitType = plate.UnitType and (find(plate.UnitType, 'ENEMY') and 'ENEMY_PLAYER' or 'FRIENDLY_PLAYER')
		if not unitType then return end
	end

    local db = testMode and E.db.Extras.nameplates[modName][E.db.Extras.nameplates[modName].selectedType] or E.db.Extras.nameplates[modName][unitType]

	if not db.enabled then return end

	local db_header = db.header
	local db_icons = db.icons
	local db_text = db.text
	local db_cooldownFill = db.cooldownFill

    if not plate.CDTracker then
        plate.CDTracker = CreateFrame("Frame", '$parentCDTracker', plate)
        plate.CDTracker.cooldowns = {}

		local health = plate.Health
		plate.CDTracker:ClearAllPoints()
		plate.CDTracker:Point(db_header.point, (health and health:IsShown()) and health or plate.Name,
								db_header.relativeTo, db_header.xOffset, db_header.yOffset)
    end

	local shown = db.showAll

	if not shown then
		if IsResting() then
			shown = db.showCity
		else
			local _, instanceType = IsInInstance()
			if instanceType == "pvp" then
				shown = db.showBG
			elseif instanceType == "arena" then
				shown = db.showArena
			elseif instanceType == "party" or instanceType == "raid" then
				shown = db.showInstance
			else
				shown = db.showWorld
			end
		end
	end

	if not shown then plate.CDTracker:Hide() return end

	plate.CDTracker:SetFrameLevel(db_header.level)
	plate.CDTracker:Show()

	local cmp = createCompareFunction(db_icons.sorting, db_icons.trinketOnTop)
	tsort(cooldowns, cmp)

    for i, cd in ipairs(cooldowns) do
		if i > db_icons.perRow * db_icons.maxRows then break end

        local cdFrame = plate.CDTracker.cooldowns[i]

		local endTime = cd.endTime
		local startTime = cd.startTime

        if not cdFrame then
            cdFrame = CreateFrame("Frame", nil, plate.CDTracker)
            cdFrame:Size(db_icons.size)
            cdFrame:SetTemplate()
            cdFrame.texture = cdFrame:CreateTexture(nil, "ARTWORK")
            cdFrame.texture:SetInside(cdFrame, E.mult, E.mult)
			cdFrame.border = E.mult or 0
			cdFrame.fill = cdFrame:CreateTexture(nil, "OVERLAY")
			cdFrame.fillDir = db_cooldownFill.direction
			cdFrame.fill:SetTexture(0, 0, 0, 0.8)
			cdFrame.text = cdFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
			cdFrame.text:SetFont(LSM:Fetch("font", db_text.font), db_text.size, db_text.flag)
			cdFrame.text:Point("CENTER", cdFrame, "CENTER", db_text.xOffset, db_text.yOffset)
            cdFrame:SetTemplate()
			cdFrame.shadow = CreateFrame("Frame", nil, cdFrame)
			cdFrame.shadow:SetFrameLevel(db_header.level - 1)
            tinsert(plate.CDTracker.cooldowns, cdFrame)
        end

		if db_cooldownFill.enabled then
			cdFrame.fillOn = db_cooldownFill.reversed and setFillPointsReversed or setFillPoints
			cdFrame.size = db_icons.size

			cdFrame.fillOn(cdFrame, ((endTime - GetTime()) / (endTime - startTime)) * db_icons.size, cdFrame.fillDir)
		end

		if db_text.enabled then
			cdFrame.text:SetText(ceil(endTime - GetTime()))
			cdFrame.textOn = true
		end

		if db_icons.borderCustomColor[1] > 0 or db_icons.borderCustomColor[2] > 0 or db_icons.borderCustomColor[3] > 0 then
			cdFrame:SetBackdropBorderColor(unpack(db_icons.borderCustomColor))
		elseif db_icons.borderColor then
			cdFrame.col = testMode and E.db.Extras.nameplates[modName].selectedType or unitType
			cdFrame:SetBackdropBorderColor(getColorByTime(endTime - GetTime(), endTime - startTime, cdFrame.col))
		end

        cdFrame.texture:SetTexture(cd.icon)

        cdFrame.endTime = endTime
        cdFrame.startTime = startTime
        cdFrame.spellID = cd.spellID
		cdFrame.throttle = db_icons.throttle
		cdFrame.animateFadeOut = db_icons.animateFadeOut

        cdFrame:SetScript("OnUpdate", function(self, elapsed)
            mod:OnUpdateCooldown(self, elapsed, cooldowns)
        end)

        cdFrame:SetScript("OnHide", function(self)
            self:SetScript("OnUpdate", nil)
        end)
    end

	local cdlen = #cooldowns

    for i = cdlen + 1, #plate.CDTracker.cooldowns do
        plate.CDTracker.cooldowns[i]:Hide()
    end

    self:RepositionIcons(db, plate.CDTracker, cdlen)
end

function mod:RepositionIcons(db, tracker, cdlen)
    local icons = db.icons
    local perRow, spacing, direction, size = icons.perRow, icons.spacing, icons.direction, icons.size
    local offset = size + spacing
    local point = oppositeDirections[direction]
    local dirProps = directionProperties[direction]
    local isCentered, isVertical, isReverseX, isReverseY = dirProps.isCentered, dirProps.isVertical, dirProps.isReverseX, dirProps.isReverseY

    local shown = min(cdlen, #tracker.cooldowns)

    if shown == 0 then
        tracker:Size(1, 1)
        return
    end

    for i = 1, shown do
        local cdFrame = tracker.cooldowns[i]
        cdFrame:ClearAllPoints()

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

        cdFrame:Point(point, tracker, point, xOffset, yOffset)

        local highlight = highlightedSpells[cdFrame.spellID]
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

    local numRows = ceil(shown / perRow)
    local numCols = min(shown, perRow)

    local trackerWidth = isVertical and (numRows * offset - spacing) or (numCols * offset - spacing)
    local trackerHeight = isVertical and (numCols * offset - spacing) or (numRows * offset - spacing)

    tracker:Size(trackerWidth, trackerHeight)
end

function mod:OnUpdateCooldown(cooldown, elapsed, cooldowns)
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
			cooldown.fillOn(cooldown, (remaining / (endTime - startTime)) * cooldown.size, cooldown.fillDir)
        end

        if cooldown.col then
			local r, g = getColorByTime(remaining, endTime - startTime, cooldown.col)
			cooldown:SetBackdropBorderColor(r, g)
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

		cooldown:SetScript("OnUpdate", nil)
		cooldown:Hide()

		for i, cd in ipairs(cooldowns) do
			if cd.endTime <= GetTime() then
				tremove(cooldowns, i)
			end
		end

		if cooldown:GetParent():IsShown() then
			mod:AttachCooldownsToPlate(cooldown:GetParent():GetParent(), cooldowns, testing)
		end
    end
end


function mod:Toggle()
	local db = E.db.Extras.nameplates[modName]

	twipe(highlightedSpells)
	twipe(petSpells)

	if db['FRIENDLY_PLAYER'].enabled or db['ENEMY_PLAYER'].enabled then
		core.plateAnchoring['CDTracker'] = function(unitType) return db[unitType].header end

		if not self:IsHooked(NP, "OnShow") then
			self:SecureHook(NP, "OnShow", function(self)
				local plate = self.UnitFrame
				local playerName = plate.UnitName
				if plate.CDTracker then plate.CDTracker:Hide() end
				if playerName and activeCooldowns[playerName] then
					for i, cooldown in ipairs(activeCooldowns[playerName]) do
						if cooldown.endTime < GetTime() then
							tremove(activeCooldowns[playerName], i)
						end
					end
					if activeCooldowns[playerName] and next(activeCooldowns[playerName]) then
						local unitType = plate.UnitType
						if unitType then
							if unitType and (unitType == 'FRIENDLY_PLAYER' or unitType == 'ENEMY_PLAYER') then
								mod:AttachCooldownsToPlate(plate, activeCooldowns[playerName])
							else
								mod:HandlePets(plate, playerName)
							end
						end
					end
				end
			end)
		end
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(self, event, ...) combatLogEvent(self, event, ...) end)
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", function()
			local _, type = IsInInstance()
			if type == 'arena' then twipe(activeCooldowns) end
			updateAllPlates()
		end)

		for spellID in pairs(db.petSpells) do
			petSpells[spellID] = true
		end

		for _, type in pairs({'ENEMY_PLAYER', 'FRIENDLY_PLAYER'}) do
			for spellID, info in pairs(db[type].highlightedSpells) do
				highlightedSpells[spellID] = info
			end
		end
	elseif not db['FRIENDLY_PLAYER'].enabled and not db['ENEMY_PLAYER'].enabled then
		core.plateAnchoring['CDTracker'] = nil
		if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		self:UnregisterAllEvents()
		twipe(activeCooldowns)
	end
	updateAllPlates()
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback