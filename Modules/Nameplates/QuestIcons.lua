local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("QuestIcons", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local markedUnits = {}

local _G, pairs, ipairs, unpack = _G, pairs, ipairs, unpack
local find = string.find
local twipe = table.wipe
local UnitName, UnitIsPlayer = UnitName, UnitIsPlayer

local healthEnabled = {["FRIENDLY_NPC"] = false, ["ENEMY_NPC"] = false,}


P["Extras"]["nameplates"][modName] = {
	["enabled"] = false,
	["useBackdrop"] = true,
	["iconSize"] = 16,
	["xOffset"] = -4,
	["yOffset"] = 0,
	["point"] = 'RIGHT',
	["relativeTo"] = 'LEFT',
	["icon"] = 'Interface\\GossipFrame\\AvailableQuestIcon',
	["strata"] = 'BACKGROUND',
	["modifiers"] = {
		["mark"] = 'NONE',
		["unmark"] = 'Shift',
		["unmarkall"] = 'Alt',
	},
}

function mod:LoadConfig()
	local db = E.db.Extras.nameplates[modName]
	
	local function populateModifierValues(othervala, othervalb)
		local modsList = {}
		for mod, val in pairs(E.db.Extras.modifiers) do
			if mod ~= 'ANY' and db.modifiers[othervala] ~= mod and db.modifiers[othervalb] ~= mod then
				modsList[mod] = val
			end
		end
		if db.modifiers[othervala] ~= 'NONE' and db.modifiers[othervalb] ~= 'NONE' then
			modsList['NONE'] = L["None"]
		end
		return modsList
	end
	
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value self:UpdateAllPlates() end,
		args = {
			QuestIcons = {
				order = 1,
				type = "group",
				guiInline = true,
				disabled = false,
				name = L["QuestIcons"],
				args = {
					enabled = {
						order = 0,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"],
						set = function(info, value) db[info[#info]] = value self:Toggle(value) end,
					},
					useBackdrop = {
						order = 1,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
						disabled = function(info) return not E.db.Extras.nameplates[modName].enabled end,
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value self:UpdateAllPlates() end,
					},
				},
			},
			settings = {
				type = "group",
				guiInline = true,
				name = L["Settings"],
				disabled = function(info) return not db.enabled end,
				get = function(info) return db[info[#info]] end,
				set = function(info, value) db[info[#info]] = value self:UpdateAllPlates() end,
				args = {
					icon = {
						order = 1,
						type = "select",
						name = L["Icon"],
						desc = "",
						values = function() return core:GetIconList(E.db.Extras.texGeneral) end,
					},
					iconSize = {
						order = 2,
						type = "range",
						min = 4, max = 60, step = 1,
						name = L["Icon Size"],
						desc = "",
					},
					xOffset = {
						order = 3,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 4,
						type = "range",
						min = -60, max = 60, step = 1,
						name = L["Y Offset"],
						desc = "",
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
					strata = {
						order = 7,
						type = "select",
						name = L["Strata"],
						desc = "",
						values = E.db.Extras.frameStrata,
					},
					mark = {
						order = 8,
						type = "select",
						name = L["Mark"],
						desc = L["Mark the target/mouseover plate."],
						get = function(info) return db.modifiers[info[#info]] end,
						set = function(info, value) db.modifiers[info[#info]] = value end,
						values = function() return populateModifierValues('unmark', 'unmarkall') end,
					},
					unmark = {
						order = 9,
						type = "select",
						name = L["Unmark"],
						desc = L["Unmark the target/mouseover plate."],
						get = function(info) return db.modifiers[info[#info]] end,
						set = function(info, value) db.modifiers[info[#info]] = value end,
						values = function() return populateModifierValues('mark', 'unmarkall') end,
					},
					unmarkall = {
						order = 10,
						type = "select",
						name = L["Unmark All"],
						desc = L["Unmark all plates."],
						get = function(info) return db.modifiers[info[#info]] end,
						set = function(info, value) db.modifiers[info[#info]] = value end,
						values = function() return populateModifierValues('mark', 'unmark') end,
					},
				},
			},
		},
	}
end


local function createIcon(frame)
	if not frame or frame.questIcon then return end
	
	local questIcon = CreateFrame("Frame")
	local texture = questIcon:CreateTexture(nil, "ARTWORK")
	
	texture:SetTexCoord(unpack(E.TexCoords)) 
	
	local offset = E.PixelMode and E.mult or E.Border
	texture:SetInside(questIcon, offset, offset)
	
	questIcon.texture = texture
	
	questIcon:SetParent(frame)
	questIcon:Hide()
	
	frame.questIcon = questIcon
	
	local db = E.db.Extras.nameplates[modName]
	local healthEnabled = healthEnabled[frame.UnitType]
	local frameHealth = frame.Health

	if not healthEnabled then
		if not mod:IsHooked(frameHealth, "OnShow") then
			mod:SecureHookScript(frameHealth, "OnShow", function(self)
				local questIcon = frame.questIcon
				if questIcon then
					questIcon:ClearAllPoints()
					questIcon:Point(db.point, self, db.relativeTo, db.xOffset, db.yOffset)
				end
			end)
		end
		if not mod:IsHooked(frameHealth, "OnHide") then
			mod:SecureHookScript(frameHealth, "OnHide", function(self)
				local questIcon = frame.questIcon
				if questIcon then
					questIcon:ClearAllPoints()
					questIcon:Point(db.point, frame.Name, db.relativeTo, db.xOffset, db.yOffset)
				end
			end)
		end
	else
		if mod:IsHooked(frameHealth, "OnShow") then mod:Unhook(frameHealth, "OnShow") end
		if mod:IsHooked(frameHealth, "OnHide") then mod:Unhook(frameHealth, "OnHide") end
	end
end

function mod:MarkUnmark(show, unitType, unitName)
	if show then
		markedUnits[unitType..unitName] = true
	else
		markedUnits[unitType..unitName] = nil
	end
end
	
function mod:UpdateQuestIcon(frame, questIcon, db)
	if db.useBackdrop then
		if not questIcon.backdrop then
			questIcon:CreateBackdrop('Transparent')
		end
		questIcon.backdrop:Show()
	elseif questIcon.backdrop then
		questIcon.backdrop:Hide()
	end
	
	questIcon:ClearAllPoints()
	questIcon:SetFrameStrata(db.strata)
	questIcon:Size(db.iconSize)
	questIcon:Point(db.point, frame.Health:IsShown() and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
	questIcon.texture:SetTexture(db.icon)
end

function mod:UpdateAllPlates()
	local db = E.db.Extras.nameplates[modName]
	
	for frame in pairs(NP.VisiblePlates) do
		local questIcon = frame.questIcon
		if questIcon then
			self:UpdateQuestIcon(frame, questIcon, db)
			
			if markedUnits[frame.UnitType..frame.UnitName] then
				questIcon:Show()
			else
				questIcon:Hide()
			end
		end
	end
end	
	
function mod:SlashCommandHandler(msg)
	local modifier = msg
	if not find(modifier, '%S+') then
		local db = E.db.Extras.nameplates[modName]
		
		for _, toggle in ipairs({"mark", "unmark", "unmarkall"}) do
			if db.modifiers[toggle] == 'NONE' or _G['Is'..db.modifiers[toggle]..'KeyDown']() then
				modifier = toggle
			end
		end
	end
	
	if not modifier then return end
	
	if modifier == "unmarkall" then 
		twipe(markedUnits) 
		self:UpdateAllPlates() 
		return
	else
		for _, unit in ipairs({'mouseover', 'target'}) do
			local name = UnitName(unit)
			if name and not UnitIsPlayer(unit) then
				local unitType = NP:GetUnitTypeFromUnit(unit)
				if modifier == "mark" or modifier == "unmark" then
					self:MarkUnmark(modifier == "mark" and true or false, unitType, name)
					self:UpdateAllPlates()
				end
				return
			end
		end
	end
end

function mod:OnCreated(self, plate)
	createIcon(plate.UnitFrame)
end

function mod:OnShow(self, isConfig, dontHideHighlight)
	local frame = self.UnitFrame
	local unitType, unitName = frame.UnitType, frame.UnitName
	if frame.questIcon then
		if markedUnits[unitType..unitName] then
			frame.questIcon:Show()
		else
			frame.questIcon:Hide()
		end
	end
end

function mod:OnHide(self, isConfig, dontHideHighlight)
	local frame = self.UnitFrame
	if frame.questIcon then
		frame.questIcon:Hide()
	end
end


mod:SecureHook(NP, "UpdateAllFrame", function() 
	healthEnabled["FRIENDLY_NPC"] = NP.db.units["FRIENDLY_NPC"].health.enable
	healthEnabled["ENEMY_NPC"] = NP.db.units["ENEMY_NPC"].health.enable
	
	for plate in ipairs(NP.CreatedPlates) do
		if plate:GetName() ~= "ElvNP_Test" then
			local frame = plate.UnitFrame
			local questIcon = frame and frame.questIcon
			if questIcon then
				questIcon:Hide()
				questIcon = nil
				
				createIcon(frame)
			end
		end
	end
end)

 
function mod:Toggle(enable)
    if enable then
		SLASH_QMARK1 = "/qmark"
		SlashCmdList["QMARK"] = function(msg) mod:SlashCommandHandler(msg) end
		if not self:IsHooked(NP, "OnCreated") then self:SecureHook(NP, "OnCreated") end
		if not self:IsHooked(NP, "OnHide") then self:SecureHook(NP, "OnHide") end	
		if not self:IsHooked(NP, "OnShow") then self:SecureHook(NP, "OnShow") end
		
		for plate in pairs(NP.CreatedPlates) do
			if plate:GetName() ~= "ElvNP_Test" then
				createIcon(plate.UnitFrame)
			end
		end
	else
		SLASH_QMARK1 = nil
		SlashCmdList["QMARK"] = nil
		hash_SlashCmdList["/QMARK"] = nil
		if self:IsHooked(NP, "OnCreated") then self:Unhook(NP, "OnCreated") end
		if self:IsHooked(NP, "OnHide") then self:Unhook(NP, "OnHide") end	
		if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		twipe(markedUnits)
    end
	self:UpdateAllPlates()
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	
	mod:LoadConfig()
	mod:Toggle(E.db.Extras.nameplates[modName].enabled)
end

core.modules[modName] = mod.InitializeCallback