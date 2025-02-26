local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("ClassificationIcons", "AceHook-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()
local isAwesome = C_NamePlate

mod.initialized = false

local ipairs, pairs, print, select = ipairs, pairs, print, select
local upper, gsub, format = string.upper, string.gsub, string.format
local CopyTable, UnitClass = CopyTable, UnitClass

local classMap = {}

local function updateVisibilityState(db, areaType)
	local isShown = false
	for _, unitType in ipairs({'FRIENDLY_PLAYER', 'ENEMY_PLAYER'}) do
		local data = db[unitType]
		isShown = isShown or data['showAll'] or data[areaType]
		data.isShown = data['showAll'] or data[areaType]
	end
	return isShown
end


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
				["frameLevel"] = 0,
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

function mod:LoadConfig(db)
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
						set = function(_, value)
							db[selectedSubSection()].enabled = value
							if value and not isAwesome then
								E:StaticPopup_Show("PRIVATE_RL")
							else
								self:Toggle(db)
							end
						end,
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
			visibility = {
				order = 2,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return selectedPlayersData()[info[#info]] end,
				set = function(info, value)
					local data = selectedPlayersData()
					data[info[#info]] = value
					local enabled = false
					for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
						if data[showType] then
							enabled = true
							break
						end
					end
					if not enabled then data['showAll'] = true end
					self:Toggle(db, true)
				end,
				hidden = function() return selectedSubSection() == 'NPCs' end,
				args = {
					showAll = {
						order = 1,
						type = "toggle",
						name = L["Show Everywhere"],
						desc = "",
						set = function(info, value)
							local data = selectedPlayersData()
							data[info[#info]] = value
							if not value then
								for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
									data[showType] = true
								end
							end
							self:Toggle(db, true)
						end,
					},
					showCity = {
						order = 2,
						type = "toggle",
						name = L["Show in Cities"],
						desc = "",
						hidden = function() return selectedPlayersData().showAll end,
					},
					showBG = {
						order = 3,
						type = "toggle",
						name = L["Show in Battlegrounds"],
						desc = "",
						hidden = function() return selectedPlayersData().showAll end,
					},
					showArena = {
						order = 4,
						type = "toggle",
						name = L["Show in Arenas"],
						desc = "",
						hidden = function() return selectedPlayersData().showAll end,
					},
					showInstance = {
						order = 5,
						type = "toggle",
						name = L["Show in Instances"],
						desc = "",
						hidden = function() return selectedPlayersData().showAll end,
					},
					showWorld = {
						order = 6,
						type = "toggle",
						name = L["Show in the World"],
						desc = "",
						hidden = function() return selectedPlayersData().showAll end,
					},
				},
			},
			NPCs = {
				order = 3,
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
						set = function(_, value) selectedNPCsData().colorByType = value NP:ForEachVisiblePlate("UpdateAllFrame", nil, true) end,
					},
					flipIcon = {
						order = 2,
						type = "toggle",
						name = L["Flip Icon"],
						desc = L["Flits the icon horizontally. Not compatible with Texture Coordinates."],
						get = function() return selectedNPCsData().flipIcon end,
						set = function(_, value) selectedNPCsData().flipIcon = value NP:ForEachVisiblePlate("UpdateAllFrame", nil, true) end,
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
						set = function(_, value) selectedNPCsData().keepOrigTex = value NP:ForEachVisiblePlate("UpdateAllFrame", nil, true) end,
					},
					texture = {
						order = 6,
						type = "select",
						name = L["Texture"],
						desc = "",
						get = function() return selectedNPCsData().texture end,
						set = function(_, value) selectedNPCsData().texture = value NP:ForEachVisiblePlate("UpdateAllFrame", nil, true) end,
						hidden = function() return selectedSubSection() ~= 'NPCs' or selectedNPCsData().keepOrigTex end,
						values = function()
							local type = db.NPCs.selectedTexList
							local list = type == 'CLASSIFICATION' and 'texClassificaion' or 'texGeneral'
							return core:GetIconList(E.db.Extras[list])
						end,
					},
				},
			},
			texCoords = {
				order = 4,
				type = "group",
				name = L["Texture Coordinates"],
				guiInline = true,
				get = function(info) return selectedNPCsData().texCoords[info[#info]] end,
				set = function(info, value) selectedNPCsData().texCoords[info[#info]] = value NP:ForEachVisiblePlate("UpdateAllFrame", nil, true) end,
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
				order = 3,
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
						min = -5, max = 50, step = 1,
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
						set = function(_, value) selectedPlayersData().classes[db.Players.selectedClass].texture = value NP:ForEachVisiblePlate("UpdateAllFrame", nil, true) end,
						values = function()
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
				order = 4,
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


function mod:Update_Elite(frame, db)
	local icon = frame.Elite
	if icon and icon:IsShown() then
		local elite, boss = frame.EliteIcon:IsShown(), frame.BossIcon:IsShown()
		local r, g, b, tex, texCoords

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
		icon:SetTexture(tex or E.Media.Textures.Nameplates)
	end
end


function mod:Construct_ClassIcon(frame)
	local ClassIcon = CreateFrame("Frame", nil, frame)
	local Texture = ClassIcon:CreateTexture(nil, "OVERLAY")
	Texture:SetAllPoints(ClassIcon)
	ClassIcon:CreateBackdrop("Transparent")
	ClassIcon.texture = Texture
	ClassIcon:Hide()

	frame.ClassIcon = ClassIcon
end

function mod:ShowIcon(frame, texture, db)
	local classIcon = frame.ClassIcon
	local level = frame.Health:GetFrameLevel() + db.frameLevel

	if texture then
		classIcon.texture:SetTexture(texture)
	end

	if db.backdrop then
		classIcon.backdrop:Show()
		classIcon.backdrop:SetFrameLevel(level)
	else
		classIcon.backdrop:Hide()
	end

	classIcon:SetFrameLevel(level)
	classIcon:Size(db.width, db.height)

	db = db.points
	classIcon:ClearAllPoints()
	classIcon:Point(db.point, frame.Health:IsShown() and frame.Health or frame.Name, db.relativeTo, db.xOffset, db.yOffset)
	classIcon:Show()
end

function mod:UpdateClassIcon(frame, db, classList)
	local unitName = frame.UnitName
	if unitName == 'Empty' then return end

	local unitClass = frame.UnitClass
	if not unitClass then
		if classMap[unitName] then
			self:ShowIcon(frame, classMap[unitName], db)
		else
			frame.ClassIcon:Hide()
		end
		return
	end

	local classes = db.classes[unitClass]
	local classIconPath = classes and classes.texture
	if classIconPath then
		self:ShowIcon(frame, classIconPath, db)
		if not classMap[unitName] or classList[unitName] ~= classes.texture then
			classList[unitName] = classIconPath
			classMap[unitName] = classIconPath
		end
	else
		frame.ClassIcon:Hide()
	end
end

function mod:AwesomeUpdateClassIcon(frame, db, unit)
	local class = select(2,UnitClass(unit))
	local classIconPath = db.classes[class] and db.classes[class].texture
	if classIconPath then
		self:ShowIcon(frame, classIconPath, db)
	else
		frame.ClassIcon:Hide()
	end
end

function mod:UpdateAllClassIcons(db)
	for plate in pairs(NP.CreatedPlates) do
		local frame = plate.UnitFrame
		local unitType = frame.UnitType
		if frame.ClassIcon and (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") then
			self:ShowIcon(frame, nil, db.Players.affiliations[unitType], NP.db.units[unitType].health.enable)
		end
	end
end

function mod:OnShow()
end


function mod:Toggle(db, visibilityUpdate)
	local affiliations = db.Players.affiliations
	if not visibilityUpdate then
		if db.Players.enabled then
			core:RegisterNPElement("ClassIcon", function(unitType, frame, element)
				if frame.ClassIcon then
					if unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER" then
						local points = affiliations[unitType].points
						frame.ClassIcon:ClearAllPoints()
						frame.ClassIcon:Point(points.point, element, points.relativeTo, points.xOffset, points.yOffset)
					end
				end
			end)
		else
			core:RegisterNPElement("ClassIcon")
		end
		if db.NPCs.enabled then
			if not self:IsHooked(NP, "Update_Elite") then
				self:SecureHook(NP, "Update_Elite", function(_, frame)
					self:Update_Elite(frame, db.NPCs)
				end)
			end
		elseif self:IsHooked(NP, "Update_Elite") then
			db.NPCs.types.Elite.keepOrigTex = true
			db.NPCs.types.Boss.keepOrigTex = true
			self:Unhook(NP, "Update_Elite")
		end
	end
	if db.Players.enabled then
		local handleAreaUpdate = false
		for _, unitType in ipairs({'ENEMY_PLAYER', 'FRIENDLY_PLAYER'}) do
			if not affiliations[unitType]['showAll'] then
				core:RegisterAreaUpdate(modName, function() self:Toggle(db, true) end)
				handleAreaUpdate = true
				break
			end
		end
		if not handleAreaUpdate then core:RegisterAreaUpdate(modName) end
		if not isAwesome and not self:IsHooked(NP, "OnShow") then
			self:SecureHook(NP, "OnShow")
		end
		if updateVisibilityState(affiliations, core:GetCurrentAreaType()) then
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame and not frame.ClassIcon then
					self:Construct_ClassIcon(frame)
				end
			end
			if not self:IsHooked(NP, "Construct_HealthBar") then
				self:SecureHook(NP, "Construct_HealthBar", self.Construct_ClassIcon)
			end
			if isAwesome then
				if not self:IsHooked(NP, "OnShow") then
					self:SecureHook(NP, "OnShow", function(self)
						if not self.unit then return end
						local frame = self.UnitFrame
						local unitType = frame.UnitType
						local data = affiliations[unitType]
						if (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") and data.isShown then
							mod:AwesomeUpdateClassIcon(frame, data, self.unit)
						elseif frame.ClassIcon then
							frame.ClassIcon:Hide()
						end
					end)
				end
			else
				self.OnShow = function(_, plate)
					local frame = plate.UnitFrame
					local unitType = frame.UnitType
					local data = affiliations[unitType]
					if (unitType == "FRIENDLY_PLAYER" or unitType == "ENEMY_PLAYER") and data.isShown then
						mod:UpdateClassIcon(frame, data, db.classList)
					elseif frame.ClassIcon then
						frame.ClassIcon:Hide()
					end
				end
			end
		else
			if self:IsHooked(NP, "Construct_HealthBar") then self:Unhook(NP, "Construct_HealthBar") end
			if self:IsHooked(NP, "OnShow") then
				if isAwesome then
					self:Unhook(NP, "OnShow")
				else
					self.OnShow = function() end
				end
			end
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame and frame.ClassIcon then
					frame.ClassIcon:Hide()
				end
			end
		end
		self.initialized = true
	elseif self.initialized then
		core:RegisterAreaUpdate(modName)
		if self:IsHooked(NP, "Construct_HealthBar") then self:Unhook(NP, "Construct_HealthBar") end
		if isAwesome or not core.reload then
			if self:IsHooked(NP, "OnShow") then self:Unhook(NP, "OnShow") end
		else
			self.OnShow = function() end
		end
		for plate in pairs(NP.CreatedPlates) do
			local frame = plate.UnitFrame
			if frame and frame.ClassIcon then
				frame.ClassIcon:Hide()
			end
		end
	end
	if self.initialized and not core.reload then
		NP:ForEachVisiblePlate("UpdateAllFrame", nil, true)
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(core.reload and {NPCs = {types = {Elite = {}, Boss = {}}}, Players = {}} or db)
end

core.modules[modName] = mod.InitializeCallback