local MAJOR, MINOR = 'LibProcessable', 2
assert(LibStub, MAJOR .. ' requires LibStub')

local lib = LibStub:NewLibrary(MAJOR, MINOR)
if(not lib) then
	return
end

local data
local inscriptionSkill, jewelcraftingSkill, enchantingSkill, blacksmithingSkill

local GetItemInfo, GetItemCount = GetItemInfo, GetItemCount
local GetNumSkillLines, GetSkillLineInfo = GetNumSkillLines, GetSkillLineInfo
local IsSpellKnown, IsEquippableItem = IsSpellKnown, IsEquippableItem
local UnitLevel = UnitLevel

-- modified to work with 3.3.5 api
local ProfessionNames = {
	enUS = {
		[164] = "Blacksmithing",
		[165] = "Leatherworking",
		[171] = "Alchemy",
		[182] = "Herbalism",
		[185] = "Cooking",
		[186] = "Mining",
		[197] = "Tailoring",
		[202] = "Engineering",
		[333] = "Enchanting",
		[356] = "Fishing",
		[393] = "Skinning",
		[755] = "Jewelcrafting",
		[773] = "Inscription",
	},
	enGB = {
		[164] = "Blacksmithing",
		[165] = "Leatherworking",
		[171] = "Alchemy",
		[182] = "Herbalism",
		[185] = "Cooking",
		[186] = "Mining",
		[197] = "Tailoring",
		[202] = "Engineering",
		[333] = "Enchanting",
		[356] = "Fishing",
		[393] = "Skinning",
		[755] = "Jewelcrafting",
		[773] = "Inscription",
	},
	deDE = {
		[164] = "Schmiedekunst",
		[165] = "Lederverarbeitung",
		[171] = "Alchemie",
		[182] = "Kräuterkunde",
		[185] = "Kochkunst",
		[186] = "Bergbau",
		[197] = "Schneiderei",
		[202] = "Ingenieurskunst",
		[333] = "Verzauberkunst",
		[356] = "Angeln",
		[393] = "Kürschnerei",
		[755] = "Juwelierskunst",
		[773] = "Inschriftenkunde",
	},
	frFR = {
		[164] = "Forge",
		[165] = "Travail du cuir",
		[171] = "Alchimie",
		[182] = "Herboristerie",
		[185] = "Cuisine",
		[186] = "Minage",
		[197] = "Couture",
		[202] = "Ingénierie",
		[333] = "Enchantement",
		[356] = "Pêche",
		[393] = "Dépeçage",
		[755] = "Joaillerie",
		[773] = "Calligraphie",
	},
	esMX = {
		[164] = "Herrería",
		[165] = "Peletería",
		[171] = "Alquimia",
		[182] = "Herboristería",
		[185] = "Cocina",
		[186] = "Minería",
		[197] = "Sastrería",
		[202] = "Ingeniería",
		[333] = "Encantamiento",
		[356] = "Pesca",
		[393] = "Desuello",
		[755] = "Joyería",
		[773] = "Inscripción",
	},
	esES = {
		[164] = "Herrería",
		[165] = "Peletería",
		[171] = "Alquimia",
		[182] = "Herboristería",
		[185] = "Cocina",
		[186] = "Minería",
		[197] = "Sastrería",
		[202] = "Ingeniería",
		[333] = "Encantamiento",
		[356] = "Pesca",
		[393] = "Desuello",
		[755] = "Joyería",
		[773] = "Inscripción",
	},
	ptBR = {
		[164] = "Ferraria",
		[165] = "Couraria",
		[171] = "Alquimia",
		[182] = "Herborismo",
		[185] = "Culinária",
		[186] = "Mineração",
		[197] = "Alfaiataria",
		[202] = "Engenharia",
		[333] = "Encantamento",
		[356] = "Pesca",
		[393] = "Esfolamento",
		[755] = "Joalheria",
		[773] = "Escrivania",
	},
	ruRU = {
		[164] = "Кузнечное дело",
		[165] = "Кожевничество",
		[171] = "Алхимия",
		[182] = "Травничество",
		[185] = "Кулинария",
		[186] = "Горное дело",
		[197] = "Портняжное дело",
		[202] = "Инженерное дело",
		[333] = "Наложение чар",
		[356] = "Рыбная ловля",
		[393] = "Снятие шкур",
		[755] = "Ювелирное дело",
		[773] = "Начертание",
	},
	zhCN = {
		[164] = "锻造",
		[165] = "制皮",
		[171] = "炼金术",
		[182] = "草药学",
		[185] = "烹饪",
		[186] = "采矿",
		[197] = "裁缝",
		[202] = "工程学",
		[333] = "附魔",
		[356] = "钓鱼",
		[393] = "剥皮",
		[755] = "珠宝加工",
		[773] = "铭文",
	},
	zhTW = {
		[164] = "鍛造",
		[165] = "製皮",
		[171] = "鍊金術",
		[182] = "草藥學",
		[185] = "烹飪",
		[186] = "採礦",
		[197] = "裁縫",
		[202] = "工程學",
		[333] = "附魔",
		[356] = "釣魚",
		[393] = "剝皮",
		[755] = "珠寶設計",
		[773] = "銘文學",
	},
	koKR = {
		[164] = "대장기술",
		[165] = "가죽세공",
		[171] = "연금술",
		[182] = "약초채집",
		[185] = "요리",
		[186] = "채광",
		[197] = "재봉술",
		[202] = "기계공학",
		[333] = "마법부여",
		[356] = "낚시",
		[393] = "무두질",
		[755] = "보석세공",
		[773] = "주문각인",
	},
}

local profNames = ProfessionNames[GetLocale()]
assert(profNames, 'Locale not supported.')
--

local MILLING = 51005
function lib:IsMillable(itemID)
	assert(tonumber(itemID), 'itemID needs to be a number or convertable to a number')
	itemID = tonumber(itemID)

	if(IsSpellKnown(MILLING)) then
		local skillRequired = data.herbs[itemID]
		return skillRequired and skillRequired <= inscriptionSkill
	end
end

local PROSPECTING = 31252
function lib:IsProspectable(itemID)
	assert(tonumber(itemID), 'itemID needs to be a number or convertable to a number')
	itemID = tonumber(itemID)

	if(IsSpellKnown(PROSPECTING)) then
		local skillRequired = data.ores[itemID]
		return skillRequired and skillRequired <= jewelcraftingSkill
	end
end

local function GetSkillRequired(quality, level)
	if(quality == 2) then
		if(level <= 20) then
			return 1
		elseif(level <= 25) then
			return 25
		elseif(level <= 30) then
			return 50
		elseif(level <= 35) then
			return 75
		elseif(level <= 40) then
			return 100
		elseif(level <= 45) then
			return 125
		elseif(level <= 50) then
			return 150
		elseif(level <= 55) then
			return 175
		elseif(level <= 60) then
			return 200
		elseif(level <= 99) then
			return 225
		elseif(level <= 120) then
			return 275
		elseif(level <= 151) then
			return 325
		elseif(level <= 187) then
			return 350
		elseif(level <= 333) then
			return 425
		else
			return 475
		end
	elseif(quality == 3) then
		if(level <= 25) then
			return 25
		elseif(level <= 30) then
			return 50
		elseif(level <= 35) then
			return 75
		elseif(level <= 40) then
			return 100
		elseif(level <= 45) then
			return 125
		elseif(level <= 50) then
			return 150
		elseif(level <= 55) then
			return 175
		elseif(level <= 60) then
			return 200
		elseif(level <= 97) then
			return 225
		elseif(level <= 115) then
			return 275
		elseif(level <= 200) then
			return 325
		elseif(level <= 377) then
			return 450
		elseif(level <= 424) then
			return 525
		else
			return 550
		end
	elseif(quality == 4) then
		if(level <= 20) then
			return 25
		elseif(level <= 40) then
			return 100
		elseif(level <= 45) then
			return 125
		elseif(level <= 50) then
			return 150
		elseif(level <= 55) then
			return 175
		elseif(level <= 60) then
			return 200
		elseif(level <= 95) then
			return 225
		elseif(level <= 190) then
			return 300
		elseif(level <= 284) then
			return 375
		elseif(level <= 416) then
			return 475
		else
			return 575
		end
	end
end

local DISENCHANTING = 13262
function lib:IsDisenchantable(itemID)
	assert(tonumber(itemID), 'itemID needs to be a number or convertable to a number')
	itemID = tonumber(itemID)

	if(IsSpellKnown(DISENCHANTING)) then
		local _, _, quality, level = GetItemInfo(itemID)
		if(IsEquippableItem(itemID) and quality and level) then
			local skillRequired = GetSkillRequired(quality, level)
			return skillRequired and skillRequired <= enchantingSkill
		end
	end
end

-- http://www.wowhead.com/items?filter=na=key;cr=86;crs=2;crv=0
local function GetSkeletonKey(pickLevel)
	if(pickLevel <= 25) then
		return 15869, 100 -- Silver Skeleton Key
	elseif(pickLevel <= 125) then
		return 15870, 150 -- Golden Skeleton Key
	elseif(pickLevel <= 200) then
		return 15871, 200 -- Truesilver Skeleton Key
	elseif(pickLevel <= 300) then
		return 15872, 275 -- Arcanite Skeleton Key
	elseif(pickLevel <= 375) then
		return 43854, 350 -- Cobalt Skeleton Key
	elseif(pickLevel <= 400) then
		return 43853, 430 -- Titanium Skeleton Key
	elseif(pickLevel <= 425) then
		return 55053, 475 -- Obsidium Skeleton Key
	elseif(pickLevel <= 450) then
		return 82960, 500 -- Ghostly Skeleton Key
	end
end

local LOCKPICKING = 1804
local BLACKSMITH = 2018
function lib:IsOpenable(itemID)
	assert(tonumber(itemID), 'itemID needs to be a number or convertable to a number')
	itemID = tonumber(itemID)

	local pickLevel = data.containers[itemID]
	if(IsSpellKnown(LOCKPICKING)) then
		return pickLevel and (pickLevel / 5) <= UnitLevel('player')
	elseif(IsSpellKnown(BLACKSMITH) and pickLevel) then
		local itemID, skillRequired = GetSkeletonKey(pickLevel)
		if(GetItemCount(itemID) > 0 and skillRequired <= blacksmithingSkill) then
			return true, itemID
		end
	end
end

-- modified to work with 3.3.5 api
local Handler = CreateFrame('Frame')
Handler:RegisterEvent('SKILL_LINES_CHANGED')
Handler:SetScript('OnEvent', function()
    for i = 1, GetNumSkillLines() do
        local professionName, _, isHeader, skillLevel = GetSkillLineInfo(i)
        if not isHeader then
            if profNames[773] == professionName then -- Inscription
                inscriptionSkill = skillLevel
            elseif profNames[755] == professionName then -- Jewelcrafting
                jewelcraftingSkill = skillLevel
            elseif profNames[333] == professionName then -- Enchanting
                enchantingSkill = skillLevel
            elseif profNames[164] == professionName then -- Blacksmithing
                blacksmithingSkill = skillLevel
            end
        end
    end
end)

data = {
	herbs = { -- http://www.wowhead.com/items?filter=cr=159:161:128;crs=1:1:1
		[765] = 1, -- Silverleaf
		[785] = 1, -- Mageroyal
		[2447] = 1, -- Peacebloom
		[2449] = 1, -- Earthroot
		[2450] = 25, -- Briarthorn
		[2452] = 25, -- Swiftthistle
		[2453] = 25, -- Bruiseweed
		[3820] = 25, -- Stranglekelp
		[3355] = 75, -- Wild Steelbloom
		[3356] = 75, -- Kingsblood
		[3357] = 75, -- Liferoot
		[3369] = 75, -- Grave Moss
		[3358] = 125, -- Khadgar''s Whisker
		[3818] = 125, -- Fadeleaf
		[3819] = 125, -- Dragon''s Teeth
		[3821] = 125, -- Goldthorn
		[4625] = 175, -- Firebloom
		[8831] = 175, -- Purple Lotus
		[8836] = 175, -- Arthas'' Tears
		[8838] = 175, -- Sungrass
		[8839] = 175, -- Blindweed
		[8845] = 175, -- Ghost Mushroom
		[8846] = 175, -- Gromsblood
		[13467] = 200, -- Icecap
		[13463] = 225, -- Dreamfoil
		[13464] = 225, -- Golden Sansam
		[13465] = 225, -- Mountain Silversage
		[13466] = 225, -- Sorrowmoss
		[22785] = 275, -- Felweed
		[22786] = 275, -- Dreaming Glory
		[22787] = 275, -- Ragveil
		[22789] = 275, -- Terocone
		[22790] = 275, -- Ancient Lichen
		[22791] = 275, -- Netherbloom
		[22792] = 275, -- Nightmare Vine
		[22793] = 275, -- Mana Thistle
		[36901] = 325, -- Goldclover
		[36903] = 325, -- Adder''s Tongue
		[36904] = 325, -- Tiger Lily
		[36905] = 325, -- Lichbloom
		[36906] = 325, -- Icethorn
		[36907] = 325, -- Talandra''s Rose
		[37921] = 325, -- Deadnettle
		[39970] = 325, -- Fire Leaf
		[52983] = 425, -- Cinderbloom
		[52984] = 425, -- Stormvine
		[52985] = 450, -- Azshara''s Veil
		[52986] = 450, -- Heartblossom
		[52987] = 475, -- Twilight Jasmine
		[52988] = 475, -- Whiptail
		[72234] = 500, -- Green Tea Leaf
		[72235] = 500, -- Silkweed
		[72237] = 500, -- Rain Poppy
		[79010] = 500, -- Snow Lily
		[79011] = 500, -- Fool''s Cap
		[89639] = 500, -- Desecrated Herb
		[109124] = 1, -- Frostweed
		[109125] = 1, -- Fireweed
		[109126] = 1, -- Gorgrond Flytrap
		[109127] = 1, -- Starflower
		[109128] = 1, -- Nagrand Arrowbloom
		[109129] = 1, -- Talador Orchid
		[109130] = 1, -- Chameleon Lotus
	},
	ores = { -- http://www.wowhead.com/items?filter=cr=89:161:128;crs=1:1:1
		[2770] = 1, -- Copper Ore
		[2771] = 50, -- Tin Ore
		[2772] = 125, -- Iron Ore
		[3858] = 175, -- Mithril Ore
		[10620] = 250, -- Thorium Ore
		[23424] = 275, -- Fel Iron Ore
		[23425] = 325, -- Adamantite Ore
		[36909] = 350, -- Cobalt Ore
		[36912] = 400, -- Saronite Ore
		[53038] = 425, -- Obsidium Ore
		[36910] = 450, -- Titanium Ore
		[52185] = 475, -- Elementium Ore
		[52183] = 500, -- Pyrite Ore
		[72092] = 500, -- Ghost Iron Ore
		[72093] = 550, -- Kyparite
		[72094] = 600, -- Black Trillium Ore
		[72103] = 600, -- White Trillium Ore
		[109119] = 500, -- True Iron Ore
	},
	containers = { -- http://www.wowhead.com/items?filter=cr=10:161:128;crs=1:1:1
		[4632] = 1, -- Ornate Bronze Lockbox
		[6354] = 1, -- Small Locked Chest
		[16882] = 1, -- Battered Junkbox
		[4633] = 25, -- Heavy Bronze Lockbox
		[4634] = 70, -- Iron Lockbox
		[6355] = 70, -- Sturdy Locked Chest
		[16883] = 70, -- Worn Junkbox
		[4636] = 125, -- Strong Iron Lockbox
		[4637] = 175, -- Steel Lockbox
		[13875] = 175, -- Ironbound Locked Chest
		[16884] = 175, -- Sturdy Junkbox
		[4638] = 225, -- Reinforced Steel Lockbox
		[5758] = 225, -- Mithril Lockbox
		[5759] = 225, -- Thorium Lockbox
		[5760] = 225, -- Eternium Lockbox
		[13918] = 250, -- Reinforced Locked Chest
		[16885] = 250, -- Heavy Junkbox
		[12033] = 275, -- Thaurissan Family Jewels
		[29569] = 300, -- Strong Junkbox
		[31952] = 325, -- Khorium Lockbox
		[43575] = 350, -- Reinforced Junkbox
		[43622] = 375, -- Froststeel Lockbox
		[43624] = 400, -- Titanium Lockbox
		[45986] = 400, -- Tiny Titanium Lockbox
		[63349] = 400, -- Flame-Scarred Junkbox
		[68729] = 425, -- Elementium Lockbox
		[88567] = 450, -- Ghost Iron Lockbox
		[88165] = 450, -- Vine-Cracked Junkbox
		[106895] = 450, -- Iron-Bound Junkbox
		[116920] = 450, -- True Steel Lockbox
	}
}
