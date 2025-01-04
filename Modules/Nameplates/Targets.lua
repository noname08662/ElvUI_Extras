local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Targets", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")
local LSM = E.Libs.LSM

local modName = mod:GetName()
local isAwesome = C_NamePlate

mod.initialized = false
mod.frames = {
	['FRIENDLY_NPC'] = {},
	['FRIENDLY_PLAYER'] = {},
	['ENEMY_NPC'] = {},
	['ENEMY_PLAYER'] = {}
}

local myname = E.myname
local funcs, values = {}, {}
local frames = mod.frames

local _G, pairs, ipairs, loadstring, setfenv, unpack, next = _G, pairs, ipairs, loadstring, setfenv, unpack, next
local find, format, gsub, match, gmatch = string.find, string.format, string.gsub, string.match, string.gmatch
local utf8lower, utf8sub, utf8len = string.utf8lower, string.utf8sub, string.utf8len
local twipe = table.wipe
local UnitName, UnitClass, UnitReaction, UnitExists, UnitGUID, UnitIsPlayer = UnitName, UnitClass, UnitReaction, UnitExists, UnitGUID, UnitIsPlayer
local RAID_CLASS_COLORS, UNKNOWN, NONE = RAID_CLASS_COLORS, UNKNOWN, NONE
local GetNamePlateForUnit = isAwesome and C_NamePlate.GetNamePlateForUnit

local separatorMap = {
	NONE = "%s",
	ARROW = ">%s<",
	ARROW1 = "> %s <",
	ARROW2 = "<%s>",
	ARROW3 = "< %s >",
	BOX = "[%s]",
	BOX1 = "[ %s ]",
	CURLY = "{%s}",
	CURLY1 = "{ %s }",
	CURVE = "(%s)",
	CURVE1 = "( %s )"
}

local function generateUpdateFunction(config)
    local highlightCode, colorCode, textDisplayCode
	local separator = separatorMap[config.separator]

    if config.highlightSelf or config.highlightOthers then
        highlightCode = "targetName.isPlayerName = name == myname"
    end

    if config.reactionColor and config.classColor then
        colorCode = [[
            if UnitIsPlayer(unitTarget) then
				local _, class = UnitClass(unitTarget)
				if class then
					local color = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or {}
					targetName:SetTextColor(color.r or targetName.r or 1, color.g or targetName.g or 1, color.b or targetName.b or 1)
				else
					local reactionType = UnitReaction(unitTarget, 'player')
					if reactionType == 4 then
						local cols = targetName.reactions.neutral
						targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
					elseif reactionType and reactionType > 4 then
						if UnitIsPlayer(unitTarget) then
							local cols = targetName.reactions.friendlyPlayer
							targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
						else
							local cols = targetName.reactions.good
							targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
						end
					else
						local cols = targetName.reactions.bad
						targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
					end
				end
			else
				local reactionType = UnitReaction(unitTarget, 'player')
				if reactionType == 4 then
					local cols = targetName.reactions.neutral
					targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
				elseif reactionType and reactionType > 4 then
					if UnitIsPlayer(unitTarget) then
						local cols = targetName.reactions.friendlyPlayer
						targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
					else
						local cols = targetName.reactions.good
						targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
					end
				else
					local cols = targetName.reactions.bad
					targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
				end
            end
        ]]
	elseif config.reactionColor then
        colorCode = [[
			local reactionType = UnitReaction(unitTarget, 'player')
			if reactionType == 4 then
				local cols = targetName.reactions.neutral
				targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
			elseif reactionType and reactionType > 4 then
				if UnitIsPlayer(unitTarget) then
					local cols = targetName.reactions.friendlyPlayer
					targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
				else
					local cols = targetName.reactions.good
					targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
				end
			else
				local cols = targetName.reactions.bad
				targetName:SetTextColor(cols.r or targetName.r or 1, cols.g or targetName.g or 1, cols.b or targetName.b or 1)
			end
        ]]
	elseif config.classColor then
        colorCode = [[
            if UnitIsPlayer(unitTarget) then
				local _, class = UnitClass(unitTarget)
				if class then
					local color = _G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class] or {}
					targetName:SetTextColor(color.r or targetName.r or 1, color.g or targetName.g or 1, color.b or targetName.b or 1)
				else
					targetName:SetTextColor(targetName.r or 1, targetName.g or 1, targetName.b or 1)
				end
			else
				targetName:SetTextColor(targetName.r or 1, targetName.g or 1, targetName.b or 1)
            end
        ]]
	else
        colorCode = "targetName:SetTextColor(targetName.r or 1, targetName.g or 1, targetName.b or 1)"
    end

	if config.separator ~= NONE then
		if config.abbreviateName then
			if config.maxLength > 0 then
				textDisplayCode = format([[
					local letters, lastWord = "", match(name, ".+%%s(.+)$")
					local maxLength = %d

					if lastWord then
						for word in gmatch(name, ".-%%s") do
							local firstLetter = utf8sub(gsub(word, "^[%%s%%p]*", ""), 1, 1)
							if firstLetter ~= utf8lower(firstLetter) then
								letters = format("%%s%%s. ", letters, firstLetter)
							end
						end
						local formattedName = format("%%s%%s", letters, lastWord)
						if utf8len(formattedName) > maxLength then
							targetName:SetFormattedText('%s', utf8sub(formattedName, 1, %d) .. "...")
						else
							targetName:SetFormattedText('%s', formattedName)
						end
					elseif utf8len(name) > maxLength then
						targetName:SetFormattedText('%s', utf8sub(name, 1, %d) .. "...")
					else
						targetName:SetFormattedText('%s', name)
					end
				]], config.maxLength, separator, config.maxLength - 3, separator, separator, config.maxLength - 3, separator)
			else
				textDisplayCode = format([[
					local letters, lastWord = "", match(name, ".+%%s(.+)$")

					if lastWord then
						for word in gmatch(name, ".-%%s") do
							local firstLetter = utf8sub(gsub(word, "^[%%s%%p]*", ""), 1, 1)
							if firstLetter ~= utf8lower(firstLetter) then
								letters = format("%%s%%s. ", letters, firstLetter)
							end
						end
						targetName:SetFormattedText('%s', format("%%s%%s", letters, lastWord))
					else
						targetName:SetFormattedText('%s', name)
					end
				]], separator, separator)
			end
		elseif config.maxLength > 0 then
			textDisplayCode = format([[
				local maxLength = %d
				if utf8len(name) > maxLength then
					targetName:SetFormattedText('%s', utf8sub(name, 1, %d) .. "...")
				else
					targetName:SetFormattedText('%s', name)
				end
			]], config.maxLength, separator, config.maxLength - 3, separator)
		else
			textDisplayCode = format("targetName:SetFormattedText('%s', name)", separator)
		end
	elseif config.abbreviateName then
		if config.maxLength > 0 then
			textDisplayCode = format([[
				local letters, lastWord = "", match(name, ".+%%s(.+)$")
				local maxLength = %d

				if lastWord then
					for word in gmatch(name, ".-%%s") do
						local firstLetter = utf8sub(gsub(word, "^[%%s%%p]*", ""), 1, 1)
						if firstLetter ~= utf8lower(firstLetter) then
							letters = format("%%s%%s. ", letters, firstLetter)
						end
					end
					local formattedName = format("%%s%%s", letters, lastWord)
					if utf8len(formattedName) > maxLength then
						targetName:SetText(utf8sub(formattedName, 1, %d) .. "...")
					else
						targetName:SetText(formattedName)
					end
				elseif utf8len(name) > maxLength then
					targetName:SetText(utf8sub(name, 1, %d) .. "...")
				else
					targetName:SetText(name)
				end
			]], config.maxLength, config.maxLength - 3, config.maxLength - 3)
		else
			textDisplayCode = [[
				local letters, lastWord = "", match(name, ".+%%s(.+)$")

				if lastWord then
					for word in gmatch(name, ".-%%s") do
						local firstLetter = utf8sub(gsub(word, "^[%%s%%p]*", ""), 1, 1)
						if firstLetter ~= utf8lower(firstLetter) then
							letters = format("%%s%%s. ", letters, firstLetter)
						end
					end
					targetName:SetText(format("%%s%%s", letters, lastWord))
				else
					targetName:SetText(name)
				end
			]]
		end
	elseif config.maxLength > 0 then
		textDisplayCode = format([[
			local maxLength = %d
			if utf8len(name) > maxLength then
				targetName:SetText(utf8sub(name, 1, %d) .. "...")
			else
				targetName:SetText(name)
			end
		]], config.maxLength, config.maxLength - 3)
	else
		textDisplayCode = "targetName:SetText(name)"
	end

    local functionBody = format([[
		local frame, targetName, unit = ...

        if unit then
			local unitTarget = unit..'target'
            local name = UnitName(unitTarget)

            if name and name ~= UNKNOWN then
				if targetName.lastName ~= name then
					targetName.lastName = name

					%s
					%s
					%s

					targetName:Show()
				end
			elseif targetName.lastName then
				targetName.lastName = nil
				targetName:Hide()
            end
        elseif targetName.lastName then
			targetName.lastName = nil
            targetName:Hide()
        end
    ]], highlightCode or "", colorCode, textDisplayCode)

    local luaFunction, errorMsg = loadstring(functionBody)

    if not luaFunction then
        core:print('LUA', L["Targets"], errorMsg)
        return function() end
    end

	setfenv(luaFunction, {
		_G = _G,
		UnitName = UnitName,
		UnitClass = UnitClass,
		UnitReaction = UnitReaction,
		UnitIsPlayer = UnitIsPlayer,
		RAID_CLASS_COLORS = RAID_CLASS_COLORS,
		UNKNOWN = UNKNOWN,
		match = match,
		gmatch = gmatch,
		format = format,
		gsub = gsub,
		utf8sub = utf8sub,
		utf8lower = utf8lower,
		utf8len = utf8len,
		myname = myname,
	})

    return luaFunction
end


local function updateVisibilityState(db, areaType)
	local isShown = false
	for _, unitType in ipairs({'FRIENDLY_NPC', 'FRIENDLY_PLAYER', 'ENEMY_NPC', 'ENEMY_PLAYER'}) do
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

local function updateValues(db)
	twipe(funcs)
	twipe(values)
	for _, unitType in ipairs({'FRIENDLY_NPC', 'FRIENDLY_PLAYER', 'ENEMY_NPC', 'ENEMY_PLAYER'}) do
		local data = db[unitType]
		if data.enabled then
			values[unitType] =	{
									["font"] = LSM:Fetch("font", data.font),
									["fontSize"] = data.fontSize,
									["fontOutline"] = data.fontOutline,
									["point"] = data.point,
									["relativeTo"] = data.relativeTo,
									["xOffset"] = data.xOffset,
									["yOffset"] = data.yOffset,
									["level"] = data.level,
									["maxLength"] = data.maxLength,
									["abbreviateName"] = data.abbreviateName,
									["r"] = data.color[1],
									["g"] = data.color[2],
									["b"] = data.color[3],
									["reactionColor"] = data.reactionColor,
									["classColor"] = data.classColor,
									["highlightSelf"] = data.highlightSelf,
									["highlightSelfR"] = data.highlightSelfColor[1],
									["highlightSelfG"] = data.highlightSelfColor[2],
									["highlightSelfB"] = data.highlightSelfColor[3],
									["highlightSelfScale"] = data.highlightSelfScale,
									["highlightSelfInheritColor"] = data.highlightSelfInheritColor,
									["highlightSelfTexture"] = data.highlightSelfTexture ~= "" and data.highlightSelfTexture
																								or E.Media.Textures.Highlight,
									["highlightOthers"] = data.highlightOthers,
									["highlightOthersR"] = data.highlightOthersColor[1],
									["highlightOthersG"] = data.highlightOthersColor[2],
									["highlightOthersB"] = data.highlightOthersColor[3],
									["highlightOthersScale"] = data.highlightOthersScale,
									["highlightOthersInheritColor"] = data.highlightOthersInheritColor,
									["highlightOthersTexture"] = data.highlightOthersTexture ~= "" and data.highlightOthersTexture
																								or E.Media.Textures.Highlight,
									["separator"] = data.separator,
									["separatorFormat"] = separatorMap[data.separator],
									["isShown"] = data.isShown,
								}
			funcs[unitType] = 	generateUpdateFunction(values[unitType])
		elseif mod[unitType] then
			mod[unitType]:Hide()
			mod[unitType] = nil
		end
	end
end


P["Extras"]["nameplates"][modName] = {
	["selectedType"] = "ENEMY_NPC",
	["ENEMY_NPC"] = {
		["enabled"] = false,
		["throttle"] = 0.2,
		["font"] = "Expressway",
		["fontSize"] = 10,
		["fontOutline"] = "OUTLINE",
		["separator"] = "CURVE",
		["point"] = "TOPLEFT",
		["relativeTo"] = "BOTTOM",
		["xOffset"] = 0,
		["yOffset"] = -2,
		["level"] = 15,
		["maxLength"] = 0,
		["abbreviateName"] = false,
		["color"] = {1, 1, 1},
		["reactionColor"] = true,
		["classColor"] = true,
		["showAll"] = true,
		["showCity"] = false,
		["showBG"] = false,
		["showArena"] = false,
		["showInstance"] = false,
		["showWorld"] = false,
		["highlightSelf"] = true,
		["highlightSelfInheritColor"] = true,
		["highlightSelfTexture"] = E.Media.Textures.Highlight,
		["highlightSelfColor"] = {0.9, 0.9, 0.3},
		["highlightSelfScale"] = 1,
		["highlightOthers"] = false,
		["highlightOthersTexture"] = E.Media.Textures.Highlight,
		["highlightOthersInheritColor"] = true,
		["highlightOthersColor"] = {0.3, 0.9, 0.9},
		["highlightOthersScale"] = 1,
	},
}

function mod:LoadConfig(db)
	local function selectedType() return db.selectedType or "ENEMY_NPC" end
	local function selectedTypeData()
		return core:getSelected("nameplates", modName, format("[%s]", selectedType() or ""), "ENEMY_NPC")
	end
	core.nameplates.args[modName] = {
		type = "group",
		name = L["Targets"],
		args = {
			Targets = {
				order = 1,
				type = "group",
				name = L["Targets"],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						width = isAwesome and "full" or "normal",
						name = core.pluginColor..L["Enable"],
						desc = "",
						get = function() return selectedTypeData().enabled end,
						set = function(_, value) selectedTypeData().enabled = value self:Toggle(db) end,
					},
					selectedType = {
						order = 3,
						type = "select",
						name = L["Select Type"],
						desc = "",
						get = function(info) return db[info[#info]] end,
						set = function(info, value) db[info[#info]] = value end,
						values = {
							["ENEMY_PLAYER"] = L["ENEMY_PLAYER"],
							["FRIENDLY_PLAYER"] = L["FRIENDLY_PLAYER"],
							["ENEMY_NPC"] = L["ENEMY_NPC"],
							["FRIENDLY_NPC"] = L["FRIENDLY_NPC"],
						},
					},
					throttle = {
						order = 4,
						type = "range",
						min = 0.05, max = 5, step = 0.05,
						name = L["Throttle Time"],
						desc = L["Minimal time gap between two consecutive executions."],
						get = function(info) return selectedTypeData()[info[#info]] end,
						set = function(info, value)
							selectedTypeData()[info[#info]] = value
							for _, unitType in ipairs({'FRIENDLY_NPC', 'FRIENDLY_PLAYER', 'ENEMY_NPC', 'ENEMY_PLAYER'}) do
								local handler = self[unitType]
								if handler then
									self:SetScripts(handler, unitType)
								end
							end
						end,
						hidden = not isAwesome,
					},
				},
			},
			visibility = {
				order = 2,
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
					self:Toggle(db, true)
				end,
				disabled = function() return not selectedTypeData().enabled or not selectedTypeData().enabled end,
				hidden = function() return not selectedTypeData().enabled end,
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
							self:Toggle(db, true)
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
			fontSettings = {
				order = 3,
				type = "group",
				name = L["Font Settings"],
				guiInline = true,
				get = function(info) return selectedTypeData()[info[#info]] end,
				set = function(info, value)
					selectedTypeData()[info[#info]] = value
					updateValues(db)
					self:UpdateAllFrames(db, true)
				end,
				disabled = function() return not selectedTypeData().enabled end,
				hidden = function() return not selectedTypeData().enabled end,
				args = {
					font = {
						order = 1,
						type = "select",
						dialogControl = "LSM30_Font",
						name = L["Font"],
						desc = "",
						values = function() return AceGUIWidgetLSMlists.font end
					},
					fontSize = {
						order = 2,
						type = "range",
						name = L["Font Size"],
						desc = "",
						min = 4, max = 33, step = 1
					},
					fontOutline = {
						order = 3,
						type = "select",
						name = L["Font Outline"],
						desc = "",
						values = {
							["NONE"] = L["None"],
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
					},
					separator = {
						order = 4,
						type = "select",
						name = L["Separator"],
						desc = "",
						values = {
							NONE = L["None"],
							ARROW = "><",
							ARROW1 = ">  <",
							ARROW2 = "<>",
							ARROW3 = "<  >",
							BOX = "[]",
							BOX1 = "[  ]",
							CURLY = "{}",
							CURLY1 = "{  }",
							CURVE = "()",
							CURVE1 = "(  )"
						},
						set = function(info, value)
							selectedTypeData()[info[#info]] = value
							updateValues(db)
							self:UpdateAllFrames(db, true)
							for _, unitType in ipairs({'FRIENDLY_NPC', 'FRIENDLY_PLAYER', 'ENEMY_NPC', 'ENEMY_PLAYER'}) do
								local handler = self[unitType]
								if handler then
									self:SetScripts(handler, db[unitType], unitType)
								end
							end
						end,
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
					xOffset = {
						order = 7,
						type = "range",
						name = L["X Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					yOffset = {
						order = 8,
						type = "range",
						name = L["Y Offset"],
						desc = "",
						min = -100, max = 100, step = 1
					},
					level = {
						order = 9,
						type = "range",
						name = L["Level"],
						desc = "",
						min = -5, max = 50, step = 1
					},
					maxLength = {
						order = 10,
						type = "range",
						name = L["Max Length"],
						desc = L["0 to disable."],
						min = 0, max = 50, step = 1
					},
					abbreviateName = {
                        order = 11,
                        type = "toggle",
                        name = L["Abbreviate Name"],
                        desc = "",
                    },
					color = {
						order = 12,
						type = "color",
						name = L["Color"],
						desc = "",
						get = function(info) return unpack(selectedTypeData()[info[#info]] or {}) end,
						set = function(info, r, g, b)
							selectedTypeData()[info[#info]] = {r, g, b}
							updateValues(db)
							self:UpdateAllFrames(db, true)
						end,
					},
					reactionColor = {
						order = 13,
						type = "toggle",
						name = L["Reaction Color"],
						desc = "",
					},
					classColor = {
						order = 14,
						type = "toggle",
						name = L["Class Color"],
						desc = "",
					},
					highlightSelf = {
						order = 15,
						type = "toggle",
						name = L["Highlight Self"],
						desc = "",
					},
					highlightOthers = {
						order = 16,
						type = "toggle",
						name = L["Highlight Others"],
						desc = "",
					},
					highlightSelfInheritColor = {
						order = 17,
						type = "toggle",
						name = L["Self Inherit Name Color"],
						desc = "",
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightSelf end,
					},
					highlightSelfTexture = {
						order = 18,
						type = "input",
						name = L["Self Texture"],
						desc = L["Whitespace to disable, empty to default."],
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightSelf end,
					},
					highlightSelfColor = {
						order = 19,
						type = "color",
						name = L["Self Color"],
						desc = "",
						get = function(info) return unpack(selectedTypeData()[info[#info]] or {}) end,
						set = function(info, r, g, b)
							selectedTypeData()[info[#info]] = {r, g, b}
							updateValues(db)
							self:UpdateAllFrames(db, true)
						end,
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightSelf end,
						disabled = function() return not selectedTypeData().enabled or selectedTypeData().highlightSelfInheritColor end,
					},
					highlightSelfScale = {
						order = 20,
						type = "range",
						min = 0, max = 4, step = 0.05,
						name = L["Self Scale"],
						desc = "",
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightSelf end,
					},
					highlightOthersInheritColor = {
						order = 21,
						type = "toggle",
						name = L["Others Inherit Name Color"],
						desc = "",
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightOthers end,
					},
					highlightOthersTexture = {
						order = 22,
						type = "input",
						name = L["Others Texture"],
						desc = L["Whitespace to disable, empty to default."],
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightOthers end,
					},
					highlightOthersColor = {
						order = 23,
						type = "color",
						name = L["Others Color"],
						desc = "",
						get = function(info) return unpack(selectedTypeData()[info[#info]] or {}) end,
						set = function(info, r, g, b)
							selectedTypeData()[info[#info]] = {r, g, b}
							updateValues(db)
							self:UpdateAllFrames(db, true)
						end,
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightOthers end,
						disabled = function() return not selectedTypeData().enabled or selectedTypeData().highlightOthersInheritColor end,
					},
					highlightOthersScale = {
						order = 24,
						type = "range",
						min = 0, max = 4, step = 0.05,
						name = L["Others Scale"],
						desc = "",
						hidden = function() return not selectedTypeData().enabled or not selectedTypeData().highlightOthers end,
					},
				},
			},
		},
	}
	if not db['FRIENDLY_NPC'] then
		db['FRIENDLY_NPC'] = CopyTable(db['ENEMY_NPC'])
		db['FRIENDLY_PLAYER'] = CopyTable(db['ENEMY_NPC'])
		db['ENEMY_PLAYER'] = CopyTable(db['ENEMY_NPC'])
	end
end


function mod:UpdateAllFrames(db, enable, visibilityUpdate)
	if isAwesome then
		for _, unitType in ipairs({'FRIENDLY_NPC', 'FRIENDLY_PLAYER', 'ENEMY_NPC', 'ENEMY_PLAYER'}) do
			twipe(frames[unitType])
			local data = db[unitType]
			local handler = self[unitType]
			if enable and data.enabled then
				if not handler then
					self[unitType] = CreateFrame("Frame")
					handler = self[unitType]
				end
				if data.isShown then
					self:SetScripts(handler, data, unitType)
				else
					handler:SetScript("OnUpdate", nil)
					handler:Hide()
					self[unitType] = nil
				end
			elseif handler then
				handler:SetScript("OnUpdate", nil)
				handler:Hide()
				self[unitType] = nil
			end
		end
	end
	if enable then
		if visibilityUpdate then
			if isAwesome then
				for frame in pairs(NP.VisiblePlates) do
					local unitType = frame.UnitType
					if unitType and self[unitType] then
						self:AwesomeUpdateName(frame, unitType, true)
					else
						for _, targetName in pairs(frame.targetNames) do
							targetName:Hide()
							targetName.lastName = nil
						end
					end
				end
			else
				for plate in pairs(NP.CreatedPlates) do
					local frame = plate.UnitFrame
					if frame then
						for unitType, targetName in pairs(frame.targetNames) do
							targetName:Hide()
							targetName.lastName = nil
							targetName.isShown = db[unitType].isShown
						end
						self:UpdateName(frame, frame.UnitType, true)
					end
				end
			end
		elseif isAwesome then
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame then
					local unitType = frame.UnitType
					if frame.targetNames then
						for unitType in pairs(frame.targetNames) do
							if not values[unitType] then
								frame.targetNames[unitType]:Hide()
							end
						end
					end
					if unitType and frame:IsShown() then
						frames[unitType][frame] = true
					end
					self:SetupFrame(frame)
					self:AwesomeUpdateName(frame, unitType, true)
				end
			end
		else
			for plate in pairs(NP.CreatedPlates) do
				local frame = plate.UnitFrame
				if frame then
					if frame.targetNames then
						for unitType, targetName in pairs(frame.targetNames) do
							if not values[unitType] then
								targetName:Hide()
								frame.targetNames[unitType] = nil
							end
							targetName:Hide()
							targetName.lastName = nil
						end
					end
					self:SetupFrame(frame)
					self:UpdateName(frame, frame.UnitType, true)
				end
			end
		end
	else
		for plate in pairs(NP.CreatedPlates) do
			local frame = plate.UnitFrame
			if frame and frame.targetNames then
				for unitType, targetName in pairs(frame.targetNames) do
					targetName:Hide()
					frame.targetNames[unitType] = nil
				end
				if frame.targetNameHighlightSelf then
					frame.targetNameHighlightSelf:Hide()
					frame.targetNameHighlightSelf = nil
				end
				if frame.targetNameHighlightOthers then
					frame.targetNameHighlightOthers:Hide()
					frame.targetNameHighlightOthers = nil
				end
				if frame.targetNamesHolder then
					frame.targetNamesHolder:Hide()
					frame.targetNamesHolder = nil
				end
			end
		end
	end
end

function mod:AwesomeUpdateName(frame, unitType, isUpdate)
	if self[unitType] then
		if not next(frames[unitType]) then
			self[unitType]:Show()
		end
		frames[unitType][frame] = true
		if isUpdate then
			local data = values[unitType]
			local holder = frame.targetNamesHolder
			holder:SetFrameLevel(frame:GetFrameLevel() + data.level)
			holder:ClearAllPoints()
			holder:Point(data.point, frame.Health:IsShown() and frame.Health or frame.Name,
													data.relativeTo, data.xOffset, data.yOffset)
		end
		funcs[unitType](frame, frame.targetNames[unitType], frame.unit)
	end
end

function mod:UpdateName(frame, unitType, isUpdate, unit)
	local targetName = frame.targetNames[unitType]
	if targetName and targetName.isShown then
		if isUpdate then
			local data = values[unitType]
			local holder = frame.targetNamesHolder
			holder:SetFrameLevel(frame:GetFrameLevel() + data.level)
			holder:ClearAllPoints()
			holder:Point(data.point, frame.Health:IsShown() and frame.Health or frame.Name,
													data.relativeTo, data.xOffset, data.yOffset)
		end
		funcs[unitType](frame, targetName, unit or frame.unit or NP[unitType][frame.UnitName] or NP.UnitByName[frame.UnitName])
	end
end

function mod:SetupHighlight(f, holder, data)
	if data.highlightSelf or data.highlightOthers then
		f.highlightSelfScale = data.highlightSelfScale
		f.highlightSelfR = data.highlightSelfR
		f.highlightSelfG = data.highlightSelfG
		f.highlightSelfB = data.highlightSelfB
		f.highlightSelfTexture = data.highlightSelfTexture
		f.highlightOthersScale = data.highlightOthersScale
		f.highlightOthersR = data.highlightOthersR
		f.highlightOthersG = data.highlightOthersG
		f.highlightOthersB = data.highlightOthersB
		f.highlightOthersTexture = data.highlightOthersTexture
		if not f.highlight then
			f.highlight = holder:CreateTexture(nil, "BACKGROUND")
			f.highlight:SetAllPoints(f)
		end
	end
	for _, func in ipairs({"SetText", "SetFormattedText"}) do
		if self:IsHooked(f, func) then self:Unhook(f, func) end
		if data.highlightOthers and data.highlightSelf then
			if data.highlightOthersInheritColor and data.highlightSelfInheritColor then
				if find(f.highlightSelfTexture, "%S+") and find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightSelfTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				else
					f.highlight:SetTexture(nil)
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				end
			elseif data.highlightOthersInheritColor then
				if find(f.highlightSelfTexture, "%S+") and find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightSelfTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				else
					f.highlight:SetTexture(nil)
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				end
			elseif data.highlightSelfInheritColor then
				if find(f.highlightSelfTexture, "%S+") and find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightSelfTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				else
					f.highlight:SetTexture(nil)
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				end
			else
				if find(f.highlightSelfTexture, "%S+") and find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightSelfTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				elseif find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							fs.highlight:SetTexture(nil)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				else
					f.highlight:SetTexture(nil)
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
							holder:SetScale(fs.highlightOthersScale)
						end
						fs.highlight:Show()
					end)
				end
			end
		elseif data.highlightSelf then
			if data.highlightSelfInheritColor then
				self:SecureHook(f, func, function(fs)
					if find(f.highlightSelfTexture, "%S+") then
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightSelfTexture)
							fs.highlight:Show()
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:Hide()
							holder:SetScale(1)
						end
					else
						fs.highlight:SetTexture(nil)
						if fs.isPlayerName then
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:Show()
							holder:SetScale(fs.highlightSelfScale)
						else
							fs.highlight:Hide()
							holder:SetScale(1)
						end
					end
				end)
			elseif find(f.highlightSelfTexture, "%S+") then
				self:SecureHook(f, func, function(fs)
					if fs.isPlayerName then
						fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
						fs.highlight:SetTexture(fs.highlightSelfTexture)
						fs.highlight:Show()
						holder:SetScale(fs.highlightSelfScale)
					else
						fs.highlight:Hide()
						holder:SetScale(1)
					end
				end)
			else
				f.highlight:SetTexture(nil)
				self:SecureHook(f, func, function(fs)
					if fs.isPlayerName then
						fs.highlight:SetVertexColor(fs.highlightSelfR, fs.highlightSelfG, fs.highlightSelfB)
						fs.highlight:Show()
						holder:SetScale(fs.highlightSelfScale)
					else
						fs.highlight:Hide()
						holder:SetScale(1)
					end
				end)
			end
		elseif data.highlightOthers then
			if data.highlightOthersInheritColor then
				if find(f.highlightOthersTexture, "%S+") then
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:Hide()
							holder:SetScale(1)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:SetTexture(fs.highlightOthersTexture)
							fs.highlight:Show()
							holder:SetScale(fs.highlightOthersScale)
						end
					end)
				else
					f.highlight:SetTexture(nil)
					self:SecureHook(f, func, function(fs)
						if fs.isPlayerName then
							fs.highlight:Hide()
							holder:SetScale(1)
						else
							fs.highlight:SetVertexColor(fs:GetTextColor())
							fs.highlight:Show()
							holder:SetScale(fs.highlightOthersScale)
						end
					end)
				end
			elseif find(f.highlightOthersTexture, "%S+") then
				self:SecureHook(f, func, function(fs)
					if fs.isPlayerName then
						fs.highlight:Hide()
						holder:SetScale(1)
					else
						fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
						fs.highlight:SetTexture(fs.highlightOthersTexture)
						fs.highlight:Show()
						holder:SetScale(fs.highlightOthersScale)
					end
				end)
			else
				f.highlight:SetTexture(nil)
				self:SecureHook(f, func, function(fs)
					if fs.isPlayerName then
						fs.highlight:Hide()
						holder:SetScale(1)
					else
						fs.highlight:SetVertexColor(fs.highlightOthersR, fs.highlightOthersG, fs.highlightOthersB)
						fs.highlight:Show()
						holder:SetScale(fs.highlightOthersScale)
					end
				end)
			end
		elseif f.highlight then
			f.highlight:Hide()
			f.highlightSelfScale = nil
			f.highlightSelfR = nil
			f.highlightSelfG = nil
			f.highlightSelfB = nil
			f.highlightOthersScale = nil
			f.highlightOthersR = nil
			f.highlightOthersG = nil
			f.highlightOthersB = nil
			break
		end
	end
	if self:IsHooked(f, "Hide") then self:Unhook(f, "Hide") end
	if data.highlightSelf or data.highlightOthers then
		self:SecureHook(f, "Hide", function(fs)
			fs.highlight:Hide()
		end)
	end
end

function mod:SetupFrame(frame)
	if not frame.targetNames then
		frame.targetNames = {}
	end

	if not frame.targetNamesHolder then
		frame.targetNamesHolder = CreateFrame("Frame", nil, frame)
		frame.targetNamesHolder:Size(1)
	end

	for unitType in pairs(values) do
		local data = values[unitType]
		local f = frame.targetNames[unitType]

		if not f then
			f = frame.targetNamesHolder:CreateFontString(nil, "OVERLAY")
			f:SetJustifyV("BOTTOM")
			f:SetJustifyH("LEFT")
			f:SetWordWrap(false)
		end

		f:SetFont(data.font, data.fontSize, data.fontOutline)
		f:ClearAllPoints()
		f:Point(data.point, frame.targetNamesHolder, data.point)

		f.isShown = data.isShown
		f.r = data.r
		f.g = data.g
		f.b = data.b
		f.reactions = NP.db.colors.reactions
		f.lastName = nil

		self:SetupHighlight(f, frame.targetNamesHolder, data)

		f:Hide()

		frame.targetNames[unitType] = f
	end
end

function mod:SetScripts(handler, data, unitType)
	local timeElapsed, throttle = 0, data.throttle
	local func = funcs[unitType]
	local plates = frames[unitType]

	handler:SetScript("OnUpdate", function(_, elapsed)
		timeElapsed = timeElapsed + elapsed
		if timeElapsed > throttle then
			timeElapsed = 0
			for frame in pairs(plates) do
				func(frame, frame.targetNames[unitType], frame.unit)
			end
		end
	end)
	handler:Show()
end


function mod:OnHide()
end


function mod:Toggle(db, visibilityUpdate)
	updateValues(db)
	if visibilityUpdate then
		updateVisibilityState(db, core:GetCurrentAreaType())
		self:UpdateAllFrames(db, true, true)
		return
	end
	if not core.reload and next(values) then
		core:RegisterAreaUpdate(modName, function()
			self:Toggle(db, true)
		end)
		if updateVisibilityState(db, core:GetCurrentAreaType()) then
			if isAwesome then
				self:UpdateAllFrames(db, true)
				self:RegisterEvent("UNIT_TARGET", function(_, unit)
					if unit ~= "player" and not find(unit, "nameplate", 1, true) then
						local plate = GetNamePlateForUnit(unit)
						if plate then
							local frame = plate.UnitFrame
							self:AwesomeUpdateName(frame, frame.UnitType)
						end
					end
				end)
				if not self:IsHooked(NP, "OnShow") then
					self:SecureHook(NP, "OnShow", function(self)
						if self.unit then
							local frame = self.UnitFrame
							mod:AwesomeUpdateName(frame, frame.UnitType, true)
						end
					end)
				end
				self.OnHide = function(_, self, ...)
					local frame = self.UnitFrame
					local unitType = frame.UnitType
					if mod[unitType] then
						frames[unitType][frame] = nil
						if not next(frames[unitType]) then
							mod[unitType]:Hide()
						end
					end
					for _, targetName in pairs(frame.targetNames) do
						targetName:Hide()
						targetName.lastName = nil
					end
					return mod.hooks[NP].OnHide(self, ...)
				end
			else
				self.OnHide = function(_, self)
					for _, targetName in pairs(self.UnitFrame.targetNames) do
						targetName:Hide()
						targetName.lastName = nil
					end
				end
				self:UpdateAllFrames(db, true)
				if not self:IsHooked(NP, "CacheGroupUnits") then
					self:SecureHook(NP, "CacheGroupUnits", function()
						for frame in pairs(NP.VisiblePlates) do
							self:UpdateName(frame, frame.UnitType, true)
						end
					end)
				end
				if not self:IsHooked(NP, "Update_CPoints") then
					self:SecureHook(NP, "Update_CPoints", function(_, frame)
						self:UpdateName(frame, frame.UnitType, true)
					end)
				end
				if not self:IsHooked(NP, "UpdateElement_All") then
					self:SecureHook(NP, "UpdateElement_All", function(_, frame)
						if frame.unit ~= "mouseover" then
							self:UpdateName(frame, frame.UnitType, true)
						end
					end)
				end
				if not self:IsHooked(NP, "UPDATE_MOUSEOVER_UNIT") then
					local function setMouseoverHook()
						if not self:IsHooked(NP, "SetMouseoverFrame") then
							self:SecureHook(NP, "SetMouseoverFrame", function(_, frame)
								if frame.isMouseover then
									self:Unhook(NP, "SetMouseoverFrame")
									local unitType = frame.UnitType
									local targetName = frame.targetNames[unitType]
									if targetName then
										self:UpdateName(frame, unitType, nil, "mouseover")
										self:SecureHook(NP, "SetMouseoverFrame", function(_, f)
											if f == frame then
												if not frame.isMouseover then
													self:Unhook(NP, "SetMouseoverFrame")
													self:UpdateName(frame, unitType)
													if UnitExists("mouseover") then
														setMouseoverHook()
													end
												elseif targetName.lastName ~= UnitName("mouseovertarget") then
													self:UpdateName(frame, unitType, nil, "mouseover")
												end
											end
										end)
									end
								end
							end)
						end
					end
					self:SecureHook(NP, "UPDATE_MOUSEOVER_UNIT", setMouseoverHook)
				end
				self:RegisterEvent("UNIT_TARGET", function(_, unit)
					if unit ~= "player" then
						local frame = NP:SearchNameplateByGUID(UnitGUID(unit))
						if frame then
							self:UpdateName(frame, frame.UnitType, nil, unit)
						end
					end
				end)
			end
			if not self:IsHooked(NP, "OnHide") then
				if isAwesome then
					self:RawHook(NP, "OnHide")
				else
					self:SecureHook(NP, "OnHide")
				end
			end
			if not self:IsHooked(NP, "Construct_Name") then
				self:SecureHook(NP, "Construct_Name", function(_, frame)
					self:SetupFrame(frame)
				end)
			end
			core:RegisterNPElement('targetNamesHolder', function(unitType, frame, element)
				local points = values[unitType]
				if points and frame.targetNamesHolder then
					frame.targetNamesHolder:ClearAllPoints()
					frame.targetNamesHolder:Point(points.point, element, points.relativeTo, points.xOffset, points.yOffset)
				end
			end)
		else
			self:UnregisterEvent("UNIT_TARGET")
			for _, func in ipairs({"UPDATE_MOUSEOVER_UNIT", "SetMouseoverFrame", "Construct_Name",
									"CacheGroupUnits", "OnShow", "Update_CPoints", "UpdateElement_All"}) do
				if self:IsHooked(NP, func) then self:Unhook(NP, func) end
			end
			if self:IsHooked(NP, "OnHide") then
				if isAwesome then
					self:Unhook(NP, "OnHide")
				else
					self.OnHide = function() end
				end
			end
			self:UpdateAllFrames(db)
			core:RegisterNPElement('targetNamesHolder')
		end
		self.initialized = true
	elseif self.initialized then
		for _, func in ipairs({"Construct_Name", "CacheGroupUnits", "OnShow", "OnHide", "Update_CPoints", "UpdateElement_All"}) do
			if self:IsHooked(NP, func) then self:Unhook(NP, func) end
		end
		self:UnregisterAllEvents()
		self:UpdateAllFrames(db)
		core:RegisterNPElement('targetNamesHolder')
		core:RegisterAreaUpdate(modName)
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end

	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback