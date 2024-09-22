local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ClassificationIcons", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local isAwesome = C_NamePlate

local pairs, print, select = pairs, print, select
local upper, gsub, format = string.upper, string.gsub, string.format
local CopyTable, UnitClass = CopyTable, UnitClass

local classMap = {}


P["Extras"]["nameplates"][modName] = {
	["selectedSubSection"] = 'NPCs',
	["classList"] = {},
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
		["selectedTexList"] = 'CLASS',
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
	local db = E.db.Extras.nameplates[modName]
	local function populateClassMap()
		if not isAwesome then
			for player, texture in pairs(db.classList) do
				classMap[player] = texture
			end
		end
	end
	local function getTexList(npcs)
		if npcs then
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

	local function selectedSubSection() return db.selectedSubSection or "NPCs" end
	local function selectedNPCs() return db.NPCs.selected end
    local function selectedNPCsData()
		return core:getSelected("nameplates", modName, format("NPCs.types[%s]", selectedNPCs() or ""), "Boss")
	end
	local function selectedPlayers() return db.Players.selectedAffiliation end
    local function selectedPlayersData()
		return core:getSelected("nameplates", modName, format("Players.affiliations[%s]", selectedPlayers() or ""), "FRIENDLY_PLAYER")
	end
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[selectedSubSection()][info[#info]] end,
		set = function(info, value) db[selectedSubSection()][info[#info]] = value self:Toggle(db) end,
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
						desc = function() return db[selectedSubSection()].desc end,
						get = function() return db[selectedSubSection()].enabled end,
						set = function(_, value) db[selectedSubSection()].enabled = value self:Toggle(db) end,
					},
					selectedSubSection = {
						order = 2,
						type = "select",
						name = L["Select"],
						desc = "",
						get = function() return db.selectedSubSection end,
						set = function(_, value) db.selectedSubSection = value end,
						values = function()
							local dropdownValues = {}
							for section in pairs(db) do
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
				disabled = function() return not db.NPCs.enabled end,
				hidden = function() return selectedSubSection() ~= 'NPCs' end,
				args = {
					colorByType = {
						order = 1,
						type = "toggle",
						name = L["Color by Type"],
						desc = L["Colors the icon based on the unit type."],
						get = function() return selectedNPCsData().colorByType end,
						set = function(_, value) selectedNPCsData().colorByType = value NP:ConfigureAll() end,
					},
					flipIcon = {
						order = 2,
						type = "toggle",
						name = L["Flip Icon"],
						desc = L["Flits the icon horizontally. Not compatible with Texture Coordinates."],
						get = function() return selectedNPCsData().flipIcon end,
						set = function(_, value) selectedNPCsData().flipIcon = value NP:ConfigureAll() end,
					},
					selected = {
						order = 3,
						type = "select",
						name = L["Select Type"],
						desc = "",
						values = core:GetUnitDropdownOptions(db.NPCs.types),
					},
					selectedTexList = {
						order = 4,
						type = "select",
						name = L["Texture List"],
						desc = "",
						values = function() return getTexList(true) end,
						hidden = function() return selectedSubSection() ~= 'NPCs' or selectedNPCsData().keepOrigTex end,
					},
					keepOrigTex = {
						order = 5,
						type = "toggle",
						name = L["Keep Icon"],
						desc = L["Keep the original icon texture."],
						get = function() return selectedNPCsData().keepOrigTex end,
						set = function(_, value) selectedNPCsData().keepOrigTex = value NP:ConfigureAll() end,
					},
					texture = {
						order = 6,
						type = "select",
						name = L["Texture"],
						desc = "",
						get = function() return selectedNPCsData().texture end,
						set = function(_, value) selectedNPCsData().texture = value NP:ConfigureAll() end,
						hidden = function() return selectedSubSection() ~= 'NPCs' or selectedNPCsData().keepOrigTex end,
						values = function(info)
							local type = db.NPCs.selectedTexList
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
				get = function(info) return selectedNPCsData().texCoords[info[#info]] end,
				set = function(info, value) selectedNPCsData().texCoords[info[#info]] = value NP:ConfigureAll() end,
				disabled = function() return not db.NPCs.enabled end,
				hidden = function() return selectedSubSection() ~= 'NPCs' or selectedNPCsData().keepOrigTex end,
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
				get = function(info) return selectedPlayersData()[info[#info]] end,
				set = function(info, value) selectedPlayersData()[info[#info]] = value mod:UpdateAllClassIcons(db) end,
				disabled = function() return not db.Players.enabled end,
				hidden = function() return selectedSubSection() ~= 'Players' end,
				args = {
					selectedAffiliation = {
						order = 0,
						type = "select",
						name = L["Select Affiliation"],
						desc = "",
						get = function() return db.Players.selectedAffiliation end,
						set = function(_, value) db.Players.selectedAffiliation = value end,
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
						get = function() return db.Players.selectedClass end,
						set = function(_, value) db.Players.selectedClass = value end,
						values = E.db.Extras.classList,
					},
					selectedTexList = {
						order = 6,
						type = "select",
						name = L["Texture List"],
						desc = "",
						get = function() return db.Players.selectedTexList end,
						set = function(_, value) db.Players.selectedTexList = value end,
						values = function() return getTexList() end,
					},
					texture = {
						order = 7,
						type = "select",
						name = L["Texture"],
						desc = "",
						get = function() return selectedPlayersData().classes[db.Players.selectedClass].texture end,
						set = function(_, value) selectedPlayersData().classes[db.Players.selectedClass].texture = value NP:ConfigureAll() end,
						values = function(info)
							local type = db.Players.selectedTexList
							local list = (type == 'CLASS' and 'texClass')
										or (type == 'VECTOR' and 'texClassVector')
										or (type == 'CREST' and 'texClassCrest')
										or (type == 'SPEC'  and 'texSpec')
										or 'texGeneral'
							return core:GetIconList(E.db.Extras[list])
						end,
					},
					purgeCache = {
						order = 8,
						type = "execute",
						width = "double",
						name = L["Purge Cache"],
						desc = "",
						func = function() db.classList = {} print(core.customColorBeta .. L["Cache purged."]) end,
					},
				},
			},
			points = {
				order = 3,
				type = "group",
				name = L["Points"],
				guiInline = true,
				get = function(info) return selectedPlayersData().points[info[#info]] end,
				set = function(info, value) selectedPlayersData().points[info[#info]] = value mod:UpdateAllClassIcons(db) end,
				disabled = function() return not db.Players.enabled end,
				hidden = function() return selectedSubSection() ~= 'Players' end,
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
	if not db.Players.affiliations[db.Players.selectedAffiliation].classes.SHAMAN then
		local classes = db.Players.affiliations[db.Players.selectedAffiliation].classes
		for class in pairs(E.db.Extras.classList) do
			if class ~= 'DEATHKNIGHT' then
				classes[class] = CopyTable(classes.DEATHKNIGHT)
				for _, info in pairs(E.db.Extras.texClass) do
					if upper(gsub(info.label, '%A+', '')) == class then
						classes[class].texture = info.icon
					end
				end
			end
		end
		db.Players.affiliations.ENEMY_PLAYER = CopyTable(db.Players.affiliations.FRIENDLY_PLAYER)
	end
	populateClassMap()
end


function mod:Update_Elite(frame)
	local db = NP.db.units[frame.UnitType].eliteIcon
	if not db then return end

	local icon = frame.Elite
	if db.enable then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
		local r, g, b, tex, texCoords
		local db = E.db.Extras.nameplates[modName].NPCs

		if boss then
			db = db.types.Boss
			r, g, b = 1, 0.5, 1
			icon:Show()
			tex = not db.keepOrigTex and db.texture
			texCoords = not db.keepOrigTex and db.texCoords
						or (db.flipIcon and {left = 0.15, right = 0, top = 0.62, bottom = 0.94}
										or {left = 0, right = 0.15, top = 0.62, bottom = 0.94})
		elseif elite then
			db = db.types.Elite
			r, g, b = 1, 1, 0
			icon:Show()
			tex = not db.keepOrigTex and db.texture
			texCoords = not db.keepOrigTex and db.texCoords
						or (db.flipIcon and {left = 0.15, right = 0, top = 0.35, bottom = 0.63}
										or {left = 0, right = 0.15, top = 0.35, bottom = 0.63})
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
	db = db or E.db.Extras.nameplates[modName].Players.affiliations[unitType]
	if not db then return end
	local ClassIcon = CreateFrame("Frame", nil, frame)
	local Texture = ClassIcon:CreateTexture(nil, "ARTWORK")
	Texture:SetAllPoints(ClassIcon)
	ClassIcon:CreateBackdrop()
	ClassIcon.texture = Texture

	frame.ClassIcon = ClassIcon
	frame.ClassIcon:Hide()
end

local function showIcon(frame, texture, db)
	local classIcon = frame.ClassIcon

	if texture then
		classIcon.texture:SetTexture(texture)
	end

	if db.backdrop then
		classIcon.backdrop:Show()
	else
		classIcon.backdrop:Hide()
	end

	classIcon:SetFrameLevel(db.frameLevel)
	classIcon:Size(db.width, db.height)

	db = db.points
	classIcon:ClearAllPoints()
	classIcon:Point(db.point, frame.Health:IsVisible() and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
	classIcon:Show()
end

function mod:UpdateClassIcon(frame, db, classList)
	local unitName = frame.UnitName
	if unitName == 'Empty' then return end

	local unitClass = frame.UnitClass
	if not unitClass then
		if classMap[unitName] then
			showIcon(frame, classMap[unitName], db)
		end
		return
	end

	local classIconPath = db.classes[unitClass] and db.classes[unitClass].texture
	if classIconPath then
		showIcon(frame, classIconPath, db)
		if not classMap[unitName] or classList[unitName] ~= db.classes[unitClass].texture then
			classList[unitName] = classIconPath
			classMap[unitName] = classIconPath
		end
	end
end

function mod:AwesomeUpdateClassIcon(frame, db, unit)
	local classFile = select(2,UnitClass(unit))
	local classIconPath = db.classes[classFile] and db.classes[classFile].texture
	if classIconPath then
		showIcon(frame, classIconPath, db)
	end
end

function mod:UpdateAllClassIcons(db)
	for plate in pairs(NP.CreatedPlates) do
		local frame = plate.UnitFrame
		local unitType = frame.UnitType
		if frame.ClassIcon and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") then
			showIcon(frame, nil, db.Players.affiliations[unitType], NP.db.units[unitType].health.enable)
		end
	end
end


function mod:Toggle(db)
	if db.NPCs.enabled or db.Players.enabled then
		core.plateAnchoring["ClassIcon"] = function(unitType)
			if unitType == "ENEMY_NPC" or unitType == "FRIENDLY_NPC" then
				return db.NPC
			elseif unitType == "ENEMY_PLAYER" or unitType == "FRIENDLY_PLAYER" then
				return db.Players.affiliations[unitType].points
			end
		end
	else
		core.plateAnchoring["ClassIcon"] = nil
	end
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
						mod:AwesomeUpdateClassIcon(frame, db.Players.affiliations[unitType], self.unit)
					end
				end)
			end
		elseif not self:IsHooked(NP, "OnShow") then
			self:SecureHook(NP, "OnShow", function(self)
				local frame = self.UnitFrame
				local unitType = frame.UnitType
				manageClassIcon(frame, unitType)
				if unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER" then
					mod:UpdateClassIcon(frame, db.Players.affiliations[unitType], db.classList)
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
	mod:Toggle(E.db.Extras.nameplates[modName])
end

core.modules[modName] = mod.InitializeCallback