local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ClassificationIcons", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local hooked = {}
local isAwesome = C_NamePlate
local healthEnabled = {["FRIENDLY_PLAYER"] = false, ["ENEMY_PLAYER"] = false,}

mod:SecureHook(NP, "UpdateAllFrame", function() 
	healthEnabled["FRIENDLY_PLAYER"] = NP.db.units["FRIENDLY_PLAYER"].health.enable
	healthEnabled["ENEMY_PLAYER"] = NP.db.units["ENEMY_PLAYER"].health.enable
end) 

local pairs, print, select = pairs, print, select
local upper, gsub = string.upper, string.gsub
local CopyTable, UnitClass, UnitIsPlayer, UnitReaction, UnitType = CopyTable, UnitClass, UnitIsPlayer, UnitReaction, UnitType

local classMap = {}


P["Extras"]["nameplates"][modName] = {
	["selectedSubSection"] = 'NPCs',
	["NPCs"] = {
		["enabled"] = false,
		["desc"] = L["Additional settings for the Elite Icon."],
		["flipIcon"] = false,
		["colorByType"] = false,
		["selected"] = 'Boss',
		["selectedTexList"] = 'CLASSIFICATION',
		["types"] = {
			["Boss"] = {
				["texture"] = 'Interface\\WorldMap\\Skull_64Red',
				["texCoords"] = { left = 0, right = 1, top = 0, bottom = 1 },
				["keepOrigTex"] = false,
			},
			["Elite"] = {
				["texture"] = 'Interface\\WorldMap\\Skull_64',
				["texCoords"] = { left = 0, right = 0.5, top = 0.5, bottom = 1 },
				["keepOrigTex"] = false,
			},
		},
	},
	["Players"] = {
		["enabled"] = false,
		["desc"] = L["Player class icons."],
		["selectedClass"] = 'DEATHKNIGHT',
		["selectedAffiliation"] = 'FRIENDLY_PLAYER',
		["affiliations"] = {
			["FRIENDLY_PLAYER"] = {
				["classes"] = {
					["DEATHKNIGHT"] = {
						["texture"] = 'Interface\\Icons\\spell_deathknight_classicon',
					},
				},
				["backdrop"] = false,
				["width"] = 24,
				["height"] = 24,
				["frameLevel"] = 100,
				["points"] = {
					["point"] = 'LEFT',
					["parent"] = 'ElvUF_Target',
					["relativeTo"] = 'RIGHT',
					["xOffset"] = -12,
					["yOffset"] = 0,
				},
			},
		},
	},
}

function mod:LoadConfig()
	local function populateClassMap()
		if isAwesome then return end
		if E.db.Extras.nameplates[modName].classList then
			for player, texture in pairs(E.db.Extras.nameplates[modName].classList) do
				classMap[player] = texture
			end
		else
			E.db.Extras.nameplates[modName].classList = {}
		end
	end
	
	local function getTexList(type)
		if type == 'NPCs' then
			return {
				["CLASSIFICATION"] = L["Classification Textures"],
				["GENERAL"] = L["General"],
			}
		else
			return {
				["CLASS"] = L["Class Icons"],
				["VECTOR"] = L["Vector Class Icons"],
				["CREST"] = L["Class Crests"],
				["GENERAL"] = L["General"],
			}
		end
	end
	
	local function selectedSubSection() return E.db.Extras.nameplates[modName].selectedSubSection end
	local function selectedNPCs() return E.db.Extras.nameplates[modName].NPCs.selected end
	local function selectedPlayers() return E.db.Extras.nameplates[modName].Players.selectedAffiliation end
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] end,
		set = function(info, value) E.db.Extras.nameplates[modName][selectedSubSection()][info[#info]] = value mod:Toggle() end,
		args = {
			SubSection = {
				order = 1,
				type = "group",
				name = L["Sub-Section"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = function() return E.db.Extras.nameplates[modName][selectedSubSection()].desc end,
						get = function(info) return E.db.Extras.nameplates[modName][selectedSubSection()].enabled end,
						set = function(info, value) E.db.Extras.nameplates[modName][selectedSubSection()].enabled = value mod:Toggle() end,
					},
					selectedSubSection = {
						order = 2,
						type = "select",
						name = L["Select"],
						desc = "",
						get = function(info) return E.db.Extras.nameplates[modName].selectedSubSection end,
						set = function(info, value) E.db.Extras.nameplates[modName].selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(E.db.Extras.nameplates[modName]) do
								if section == 'NPCs' or section == 'Players' then
									dropdownValues[section] = L[section]
								end
							end
							return dropdownValues
						end,
					},
				},
			},
			NPCs = {
				order = 2,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function(info) return not E.db.Extras.nameplates[modName].NPCs.enabled end,
				hidden = function(info) return selectedSubSection() ~= 'NPCs' end,
				args = {
					colorByType = {
						order = 1,
						type = "toggle",
						name = L["Color by Type"],
						desc = L["Colors the icon based on the unit type."],
						get = function(info) return E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].colorByType end,
						set = function(info, value) E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].colorByType = value NP:ConfigureAll() end,
					},	
					flipIcon = {
						order = 2,
						type = "toggle",
						name = L["Flip Icon"],
						desc = L["Flits the icon horizontally. Not compatible with Texture Coordinates."],
						get = function(info) return E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].flipIcon end,
						set = function(info, value) E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].flipIcon = value NP:ConfigureAll() end,
					},
					selected = {
						order = 3,
						type = "select",
						name = L["Select Type"],
						desc = "",
						values = core:GetUnitDropdownOptions(E.db.Extras.nameplates[modName].NPCs.types),
					},	
					selectedTexList = {
						order = 4,
						type = "select",
						name = L["Texture List"],
						desc = "",
						values = function() return getTexList('NPCs') end,
						hidden = function(info) return selectedSubSection() ~= 'NPCs' or E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].keepOrigTex end,
					},	
					keepOrigTex = {
						order = 5,
						type = "toggle",
						name = L["Keep Icon"],
						desc = L["Keep the original icon texture."],
						get = function(info) return E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].keepOrigTex end,
						set = function(info, value) E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].keepOrigTex = value NP:ConfigureAll() end,
					},	
					texture = {
						order = 6,
						type = "select",
						name = L["Texture"],
						desc = "",
						get = function(info) return E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].texture end,
						set = function(info, value) E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].texture = value NP:ConfigureAll() end, 
						hidden = function(info) return selectedSubSection() ~= 'NPCs' or E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].keepOrigTex end,
						values = function(info)
							local type = E.db.Extras.nameplates[modName][info[#info-1]].selectedTexList
							local list = type == 'CLASSIFICATION' and 'texClassificaion' or 'texGeneral'
							return core:GetIconList(E.db.Extras[list])
						end,
					},
				},
			},
			texCoords = {
				order = 3,
				type = "group",
				name = L["Texture Coordinates"],
				guiInline = true,
				get = function(info) return E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].texCoords[info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].texCoords[info[#info]] = value NP:ConfigureAll() end,
				disabled = function(info) return not E.db.Extras.nameplates[modName].NPCs.enabled end,
				hidden = function(info) return selectedSubSection() ~= 'NPCs' or E.db.Extras.nameplates[modName].NPCs.types[selectedNPCs()].keepOrigTex end,
				args = {
					left = {
						order = 1,
						type = "range",
						name = L["Left"],
						desc = "",
						min = 0, max = 1,step = 0.01,
					},
					right = {
						order = 2,
						type = "range",
						name = L["Right"],
						desc = "",
						min = 0, max = 1, step = 0.01,
					},
					top = {
						order = 3,
						type = "range",
						name = L["Top"],
						desc = "",
						min = 0, max = 1, step = 0.01,
					},
					bottom = {
						order = 4,
						type = "range",
						name = L["Bottom"],
						desc = "",
						min = 0, max = 1, step = 0.01,
					},
				},
			},
			Players = {
				order = 2,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				get = function(info) return E.db.Extras.nameplates[modName].Players.affiliations[selectedPlayers()][info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName].Players.affiliations[selectedPlayers()][info[#info]] = value mod:UpdateAllClassIcons() end,
				disabled = function(info) return not E.db.Extras.nameplates[modName].Players.enabled end,
				hidden = function(info) return selectedSubSection() ~= 'Players' end,
				args = {
					selectedAffiliation = {
						order = 0,
						type = "select",
						name = L["Select Affiliation"],
						values = {
							["FRIENDLY_PLAYER"] = L["FRIENDLY"],
							["ENEMY_PLAYER"] = L["ENEMY"],
						},
					},
					backdrop = {
						order = 1,
						type = "toggle",
						name = L["Use Backdrop"],
						desc = "",
					},
					frameLevel = {
						order = 2,
						type = "range",
						min = 0, max = 200, step = 1,
						name = L["Level"],
						desc = "",
					},
					width = {
						order = 3,
						type = "range",
						min = 4, max = 100, step = 1,
						name = L["Width"],
						desc = "",
					},
					height = {
						order = 4,
						type = "range",
						min = 4, max = 100, step = 1,
						name = L["Height"],
						desc = "",
					},
					selectedClass = {
						order = 5,
						type = "select",
						name = L["Select Class"],
						desc = "",
						values = E.db.Extras.classList,
					},	
					selectedTexList = {
						order = 6,
						type = "select",
						name = L["Texture List"],
						desc = "",
						values = function() return getTexList() end,
					},		
					texture = {
						order = 7,
						type = "select",
						name = L["Texture"],
						desc = "",
						get = function(info) return E.db.Extras.nameplates[modName].Players.affiliations[selectedPlayers()].classes[E.db.Extras.nameplates[modName].Players.selectedClass].texture end,
						set = function(info, value) E.db.Extras.nameplates[modName].Players.affiliations[selectedPlayers()].classes[E.db.Extras.nameplates[modName].Players.selectedClass].texture = value NP:ConfigureAll() end, 
						values = function(info)
							local type = E.db.Extras.nameplates[modName][info[#info-1]].selectedTexList
							local list = type == 'CLASS' and 'texClass' or type == 'VECTOR' and 'texClassVector' or type == 'CREST' and 'texClassCrest' or type == 'SPEC'  and 'texSpec' or 'texGeneral'
							return core:GetIconList(E.db.Extras[list])
						end,
					},
					purgeCache = {
						order = 8,
						type = "execute",
						width = "double",
						name = L["Purge Cache"],
						desc = "",
						func = function() E.db.Extras.nameplates[modName].classList = {} print(core.customColorBeta .. L["Cache purged."]) end,
					},
				},
			},
			points = {
				order = 3,
				type = "group",
				name = L["Points"],
				guiInline = true,
				get = function(info) return E.db.Extras.nameplates[modName].Players.affiliations[selectedPlayers()].points[info[#info]] end,
				set = function(info, value) E.db.Extras.nameplates[modName].Players.affiliations[selectedPlayers()].points[info[#info]] = value mod:UpdateAllClassIcons() end,
				disabled = function(info) return not E.db.Extras.nameplates[modName].Players.enabled end,
				hidden = function(info) return selectedSubSection() ~= 'Players' end,
				args = {
					point = {
						order = 1,
						type = "select",
						name = L["Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					relativeTo = {
						order = 2,
						type = "select",
						name = L["Relative Point"],
						desc = "",
						values = E.db.Extras.pointOptions,
					},
					xOffset = {
						order = 3,
						type = "range",
						min = -100, max = 100, step = 1,
						name = L["X Offset"],
						desc = "",
					},
					yOffset = {
						order = 4,
						type = "range",
						min = -100, max = 100, step = 1,
						name = L["Y Offset"],
						desc = "",
					},
				},
			},
		},
	}
	if not E.db.Extras.nameplates[modName].Players.affiliations[E.db.Extras.nameplates[modName].Players.selectedAffiliation].classes.SHAMAN then
		local db = E.db.Extras.nameplates[modName].Players.affiliations[E.db.Extras.nameplates[modName].Players.selectedAffiliation].classes
		for class in pairs(E.db.Extras.classList) do
			if class ~= 'DEATHKNIGHT' then
				db[class] = CopyTable(db.DEATHKNIGHT)
				for _, info in pairs(E.db.Extras.texClass) do
					if upper(gsub(info.label, '%A+', '')) == class then
						db[class].texture = info.icon
					end
				end
			end
		end
		E.db.Extras.nameplates[modName].Players.affiliations.ENEMY_PLAYER = CopyTable(E.db.Extras.nameplates[modName].Players.affiliations.FRIENDLY_PLAYER)
	end
	
	populateClassMap()
end


function mod:Update_Elite(frame)
	local db = NP.db.units[frame.UnitType].eliteIcon
	if not db then return end
	
	local icon = frame.Elite
	
	if db.enable then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
		local r, g, b, tex
		local texCoords = {1,0,1,0}
		local db = E.db.Extras.nameplates[modName].NPCs

		if boss then
			db = db.types.Boss
			r, g, b = 1, 0.5, 1
			icon:Show()
			tex = not db.keepOrigTex and db.texture
			texCoords = not db.keepOrigTex and db.texCoords or (db.flipIcon and {left = 0.15, right = 0, top = 0.62, bottom = 0.94} or {left = 0, right = 0.15, top = 0.62, bottom = 0.94})
		elseif elite then
			db = db.types.Elite
			r, g, b = 1, 1, 0
			icon:Show()
			tex = not db.keepOrigTex and db.texture
			texCoords = not db.keepOrigTex and db.texCoords or (db.flipIcon and {left = 0.15, right = 0, top = 0.35, bottom = 0.63} or {left = 0, right = 0.15, top = 0.35, bottom = 0.63})
		else
			icon:Hide()
			return
		end
		
		icon:SetTexture(tex and tex or E.Media.Textures.Nameplates)
		
		if icon:IsShown() then 
			if db.colorByType then
				icon:SetVertexColor(r, g, b)
			else
				icon:SetVertexColor(1, 1, 1)
			end
			if db.flipIcon and not db.keepOrigTex then
				icon:SetTexCoord(1, 0, 0, 1)
			else
				icon:SetTexCoord(texCoords.left, texCoords.right, texCoords.top, texCoords.bottom)
			end
		end
	else
		icon:Hide()
	end
end

local function manageClassIcon(frame, unitType, db)
	if frame.ClassIcon then frame.ClassIcon:Hide() return end
	local db = db or E.db.Extras.nameplates[modName].Players.affiliations[unitType]
	if not db then return end
	local ClassIcon = CreateFrame("Frame", nil, frame)
	local Texture = ClassIcon:CreateTexture(nil, "ARTWORK")
	Texture:SetAllPoints(ClassIcon)
	ClassIcon:CreateBackdrop()
	ClassIcon.texture = Texture
	
	frame.ClassIcon = ClassIcon
	frame.ClassIcon:Hide()
end

local function showIcon(frame, texture, db, healthEnabled)
	local classIcon = frame.ClassIcon
	local classIconTex = classIcon.texture
	local classIconBackdrop = classIcon.backdrop
	
	if texture then classIconTex:SetTexture(texture) end
	
	if db.backdrop then
		classIconBackdrop:Show()
	else
		classIconBackdrop:Hide()
	end
	
	classIcon:SetFrameLevel(db.frameLevel)
	classIcon:Size(db.width, db.height)
	
	db = db.points
	classIcon:ClearAllPoints()
	classIcon:Point(db.point, healthEnabled and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)

	if not healthEnabled and not hooked[frame] then
		frame.Health:HookScript("OnShow", function()
			local classIcon = frame.ClassIcon
			if classIcon then
				classIcon:ClearAllPoints()
				classIcon:Point(db.point, frame.Health, db.relativeTo, db.xOffset, db.yOffset)
			end
		end)
		hooked[frame] = true
	end
	classIcon:Show()
end

function mod:UpdateClassIcon(frame, unitType)
	local unitName = frame.UnitName
	if unitName == 'Empty' then return end
	
	local db = E.db.Extras.nameplates[modName].Players.affiliations[unitType]
	
	local unitClass = frame.UnitClass
	if not unitClass then
		if classMap[unitName] then
			showIcon(frame, classMap[unitName], db, healthEnabled[unitType])
		end
		return
	end

	local classIconPath = db.classes[unitClass] and db.classes[unitClass].texture
	if classIconPath then
		showIcon(frame, classIconPath, db, healthEnabled[unitType])
		if not classMap[unitName] or E.db.Extras.nameplates[modName].classList[unitName] ~= db.classes[unitClass].texture then
			E.db.Extras.nameplates[modName].classList[unitName] = classIconPath
			classMap[unitName] = classIconPath
		end
	end
end

function mod:AwesomeUpdateClassIcon(frame, unitType, unit)
	local db = E.db.Extras.nameplates[modName].Players.affiliations[unitType]
	local classFile = select(2,UnitClass(unit))
	local classIconPath = db.classes[classFile] and db.classes[classFile].texture
	if classIconPath then
		showIcon(frame, classIconPath, db, healthEnabled[unitType])
	end
end
	
function mod:UpdateAllClassIcons()
	for frame in pairs(NP.CreatedPlates) do
		local frame = frame.UnitFrame
		if frame.ClassIcon and (frame.UnitType == "FRIENDLY_PLAYER" or frame.UnitType == "ENEMY_PLAYER") then
			local db = E.db.Extras.nameplates[modName].Players.affiliations[frame.UnitType]
			showIcon(frame, nil, db, NP.db.units[frame.UnitType].health.enable)
		end
	end
end		


function mod:Toggle()
	local db = E.db.Extras.nameplates[modName]
	
	if db.NPCs.enabled then
		if not self:IsHooked(NP, "Update_Elite") then self:SecureHook(NP, "Update_Elite", self.Update_Elite) end
	elseif self:IsHooked(NP, "Update_Elite") then
		db.NPCs.types.Elite.keepOrigTex = true
		db.NPCs.types.Boss.keepOrigTex = true
		self:Unhook(NP, "Update_Elite")
	end
	
	if db.Players.enabled then
		if isAwesome then 
			if not self:IsHooked(NP, "OnShow") then
				self:SecureHook(NP, "OnShow", function(self)
					if not self.unit then return end
					local frame = self.UnitFrame
					local unitType = frame.UnitType
					manageClassIcon(frame, unitType)
					if unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER" then
						mod:AwesomeUpdateClassIcon(frame, unitType, self.unit)
					end
				end)
			end
		elseif not self:IsHooked(NP, "OnShow") then 
			self:SecureHook(NP, "OnShow", function(self)
				local frame = self.UnitFrame
				local unitType = frame.UnitType
				manageClassIcon(frame, unitType)
				if unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER" then
					mod:UpdateClassIcon(frame, unitType)
				end
			end) 
		end
	else
		if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		for frame in pairs(NP.VisiblePlates) do
			local unitType = frame.UnitType
			if unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER" then
				if frame.ClassIcon then
					frame.ClassIcon:Hide()
					frame.ClassIcon = nil
				end
			end
		end
	end
	
	NP:ConfigureAll()
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	
	mod:LoadConfig()
	mod:Toggle()
end

core.modules[modName] = mod.InitializeCallback