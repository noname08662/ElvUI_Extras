local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("DepthOfField", "AceHook-3.0", "AceEvent-3.0")
local NP = E:GetModule("NamePlates")

local modName = mod:GetName()

local screenWidth, screenHeight
local minOpacity, falloffRate, mouseFalloffRate, centerCurve, mouseCurve, pivotY
local centerX, centerY

local f = CreateFrame("Frame")
f:Hide()
f.lastUpdate = 0

mod.f = f
mod.initialized = false
mod.mouselooktimer = 1

local format = string.format
local abs, sqrt, exp, min, max = math.abs, math.sqrt, math.exp, math.min, math.max
local pairs, ipairs, loadstring, setfenv = pairs, ipairs, loadstring, setfenv
local GetCursorPosition, IsMouselooking = GetCursorPosition, IsMouselooking

hooksecurefunc(f, "Hide", function()
	for frame in pairs(NP.VisiblePlates) do
		if not frame.isTarget then
			NP:PlateFade(frame, 1, frame:GetAlpha(), frame.endAlpha or 1)
		end
	end
end)

hooksecurefunc(f, "Show", function()
	for frame in pairs(NP.VisiblePlates) do
		if not frame.isTarget then
			NP:PlateFade(frame, 1, frame:GetAlpha(), frame.endAlpha or 1)
		end
	end
end)


local function updateScreenDimensions()
	screenWidth, screenHeight = UIParent:GetSize()
    centerX = screenWidth / 2
    centerY = screenHeight * pivotY
end


P["Extras"]["nameplates"][modName] = {
	["enabled"] 			= false,
	["enableMouse"]			= true,
	["disableCombat"]		= true,
	["ignoreTarget"]		= true,
	["ignoreStyled"]		= true,
	["showAll"]				= true,
    ["minOpacity"]			= 0,
    ["falloffRate"] 		= 1,
    ["throttle"] 			= 0,
    ["mouseFalloffRate"]	= 8,
    ["centerCurve"]			= 1,
    ["mouseCurve"]			= 1,
    ["pivotY"]				= 0.6,
}

function mod:LoadConfig(db)
	core.nameplates.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value self:Toggle(db) end,
		args = {
			[modName] = {
				order = 1,
				type = "group",
				name = L[modName],
				guiInline = true,
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Fades nameplates based on distance to screen center and cursor."],
					},
				},
			},
			visibility = {
				order = 2,
				type = "group",
				name = L["Visibility State"],
				guiInline = true,
				get = function(info) return db[info[#info]] end,
				set = function(info, value)
					db[info[#info]] = value
					local enabled = false
					for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
						if db[showType] then
							enabled = true
							break
						end
					end
					if not enabled then db['showAll'] = true end
					self:Toggle(db)
				end,
				disabled = function() return not db.enabled end,
				args = {
					showAll = {
						order = 1,
						type = "toggle",
						name = L["Show Everywhere"],
						desc = "",
						set = function(info, value)
							db[info[#info]] = value
							if not value then
								for _, showType in ipairs({'showCity', 'showBG', 'showInstance', 'showArena', 'showWorld'}) do
									db[showType] = true
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
						hidden = function() return db.showAll end,
					},
					showBG = {
						order = 3,
						type = "toggle",
						name = L["Show in Battlegrounds"],
						desc = "",
						hidden = function() return db.showAll end,
					},
					showArena = {
						order = 4,
						type = "toggle",
						name = L["Show in Arenas"],
						desc = "",
						hidden = function() return db.showAll end,
					},
					showInstance = {
						order = 5,
						type = "toggle",
						name = L["Show in Instances"],
						desc = "",
						hidden = function() return db.showAll end,
					},
					showWorld = {
						order = 6,
						type = "toggle",
						name = L["Show in the World"],
						desc = "",
						hidden = function() return db.showAll end,
					},
				},
			},
			settings = {
				order = 3,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function() return not db.enabled end,
				args = {
					ignoreTarget = {
						order = 1,
						type = "toggle",
						name = L["Ignore Target"],
						desc = "",
					},
					ignoreStyled = {
						order = 2,
						type = "toggle",
						name = L["Ignore Styled"],
						desc = "",
					},
					disableCombat = {
						order = 3,
						type = "toggle",
						name = L["Disable in Combat"],
						desc = "",
					},
					pivotY = {
						order = 4,
						type = "range",
						name = L["Y Axis Pivot"],
						desc = L["Most opaque spot relative to screen center."],
						min = 0.1, max = 0.9, step = 0.01,
					},
					minOpacity = {
						order = 5,
						type = "range",
						name = L["Min Opacity"],
						desc = "",
						min = 0, max = 0.9, step = 0.01,
					},
					throttle = {
						order = 6,
						type = "range",
						name = L["OnUpdate Throttle"],
						desc = "",
						min = 0, max = 0.5, step = 0.01,
					},
					falloffRate = {
						order = 7,
						type = "range",
						name = L["Falloff Rate"],
						desc = L["Base multiplier."],
						min = 0.1, max = 20, step = 0.1,
					},
					centerCurve = {
						order = 8,
						type = "range",
						name = L["Effect Curve"],
						desc = L["Higher values result in steeper falloff."],
						min = 0.1, max = 10, step = 0.1,
					},
					enableMouse = {
						order = 9,
						type = "toggle",
						width = "full",
						name = L["Enable Mouse"],
						desc = L["Also calculate cursor proximity."],
					},
					mouseFalloffRate = {
						order = 10,
						type = "range",
						name = L["Mouse Falloff Rate"],
						desc = L["Base multiplier."],
						min = 0.1, max = 20, step = 0.1,
						hidden = function() return not db.enableMouse end,
					},
					mouseCurve = {
						order = 11,
						type = "range",
						name = L["Mouse Effect Curve"],
						desc = L["Higher values result in steeper falloff."],
						min = 0.1, max = 20, step = 0.1,
						hidden = function() return not db.enableMouse end,
					},
				},
			},
		},
	}
end


function mod:PlateFade(frame, timeToFade, endAlpha)
	local frameX, frameY = frame:GetCenter()
	self.hooks[NP].PlateFade(NP, frame, timeToFade, frame:GetAlpha(),
		endAlpha *
		max(
			min(exp(-sqrt((abs(frameX - centerX)/centerX)^2 + (abs(frameY - centerY)/centerY)^2)^centerCurve * falloffRate), 1),
			minOpacity
		)
	)
end

function mod:PlateFadeMouse(frame, timeToFade, endAlpha)
	local frameX, frameY = frame:GetCenter()
	self.hooks[NP].PlateFade(NP, frame, timeToFade, frame:GetAlpha(),
		endAlpha *
		max(
			min(
				exp(-sqrt((abs(frameX - centerX)/centerX)^2 + (abs(frameY - centerY)/centerY)^2)^centerCurve * falloffRate)
					+ exp(-sqrt(((self.mouseX - frameX)/screenWidth)^2 + ((self.mouseY - frameY)/screenHeight)^2)^mouseCurve * mouseFalloffRate),
				1
			),
			minOpacity
		)
	)
end


local function buildOnUpdateFunc(db)
    local luaFunction = loadstring(
        format(
            [[
                %s
                %s
                    %s
                    for frame in pairs(NP.VisiblePlates) do
                        %s
                    end
                %s
            ]],
            (db.throttle > 0 or db.enableMouse) and [[
				local self, elapsed = ...
			]] or "",
            db.throttle > 0 and [[
				self.lastUpdate = self.lastUpdate + elapsed
				if self.lastUpdate >= self.throttle then
			]] or "",
            db.enableMouse and [[
				if IsMouselooking() then
					mod.mouseX = mod.mouseX + (centerX - mod.mouseX) * (elapsed * 5)
					mod.mouseY = mod.mouseY + (centerY - mod.mouseY) * (elapsed * 5)
					mod.mouselooktimer = 0.01
				elseif mod.mouselooktimer >= 1 then
					mod.mouseX, mod.mouseY = GetCursorPosition()
				else
					local targetX, targetY = GetCursorPosition()
					mod.mouseX = mod.mouseX + (targetX - mod.mouseX) * (elapsed * 20)
					mod.mouseY = mod.mouseY + (targetY - mod.mouseY) * (elapsed * 20)
					mod.mouselooktimer = mod.mouselooktimer + mod.mouselooktimer * (elapsed * 20)
				end
			]] or "",
            (db.ignoreTarget and db.ignoreStyled) and
                format([[
                    if not (frame.isTarget or frame.AlphaChanged) then
                        mod:%s(frame, frame.timeToFade or 0, frame.endAlpha or 1)
                    end
                ]], db.enableMouse and "PlateFadeMouse" or "PlateFade")
            or db.ignoreTarget and
                format([[
                    if not frame.isTarget then
                        mod:%s(frame, frame.timeToFade or 0, frame.endAlpha or 1)
                    end
                ]], db.enableMouse and "PlateFadeMouse" or "PlateFade")
            or db.ignoreStyled and
                format([[
                    if not frame.AlphaChanged then
                        mod:%s(frame, frame.timeToFade or 0, frame.endAlpha or 1)
                    end
                ]], db.enableMouse and "PlateFadeMouse" or "PlateFade")
            or
                format([[
                    mod:%s(frame, frame.timeToFade or 0, frame.endAlpha or 1)
                ]], db.enableMouse and "PlateFadeMouse" or "PlateFade"),
            db.throttle > 0 and "self.lastUpdate = 0 end" or ""
        )
    )
    setfenv(luaFunction, {
        NP = NP,
        mod = mod,
        GetCursorPosition = GetCursorPosition,
		IsMouselooking = IsMouselooking,
		centerX = centerX,
		centerY = centerY,
        pairs = pairs,
    })
    return luaFunction
end


function mod:Toggle(db, visibilityUpdate)
	if self:IsHooked(NP, "PlateFade") then self:Unhook(NP, "PlateFade") end
	if self:IsHooked(NP, "OnCreated") then self:Unhook(NP, "OnCreated") end
	if not core.reload and db.enabled then
		if not visibilityUpdate then
			if db['showAll'] then
				core:RegisterAreaUpdate(modName)
			else
				core:RegisterAreaUpdate(modName, function() self:Toggle(db, true) end)
			end
		end
		if db['showAll'] or db[core:GetCurrentAreaType()] then
			falloffRate, mouseFalloffRate, minOpacity = db.falloffRate, db.mouseFalloffRate, db.minOpacity
			centerCurve, mouseCurve = db.centerCurve, db.mouseCurve
			pivotY = db.pivotY

			updateScreenDimensions()

			if db.enableMouse then
				self:SecureHook(NP, "OnCreated", function(_, plate)
					local frame = plate.UnitFrame
					local frameX, frameY = frame:GetCenter()
					frame:SetAlpha(
						max(
							min(
								exp(-sqrt((abs(frameX - centerX)/centerX)^2 + (abs(frameY - centerY)/centerY)^2)^centerCurve * falloffRate)
									+ exp(-sqrt(((self.mouseX - frameX)/screenWidth)^2 + ((self.mouseY - frameY)/screenHeight)^2)^mouseCurve * mouseFalloffRate),
								1
							),
							minOpacity
						)
					)
				end)
			else
				self:SecureHook(NP, "OnCreated", function(_, plate)
					local frame = plate.UnitFrame
					local frameX, frameY = frame:GetCenter()
					frame:SetAlpha(
						max(
							min(exp(-sqrt((abs(frameX - centerX)/centerX)^2 + (abs(frameY - centerY)/centerY)^2)^centerCurve * falloffRate), 1),
							minOpacity
						)
					)
				end)
			end

			if db.ignoreTarget then
				if db.ignoreStyled then
					if db.enableMouse then
						self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
							frame.endAlpha = endAlpha
							frame.timeToFade = timeToFade
							if frame.isTarget or frame.AlphaChanged then
								mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
							else
								mod:PlateFadeMouse(frame, timeToFade, endAlpha)
							end
						end)
					else
						self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
							frame.endAlpha = endAlpha
							frame.timeToFade = timeToFade
							if frame.isTarget or frame.AlphaChanged then
								mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
							else
								mod:PlateFade(frame, timeToFade, endAlpha)
							end
						end)
					end
				elseif db.enableMouse then
					self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
						frame.endAlpha = endAlpha
						frame.timeToFade = timeToFade
						if frame.isTarget then
							mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
						else
							mod:PlateFadeMouse(frame, timeToFade, endAlpha)
						end
					end)
				else
					self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
						frame.endAlpha = endAlpha
						frame.timeToFade = timeToFade
						if frame.isTarget then
							mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
						else
							mod:PlateFade(frame, timeToFade, endAlpha)
						end
					end)
				end
			elseif db.ignoreStyled then
				if db.enableMouse then
					self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
						frame.endAlpha = endAlpha
						frame.timeToFade = timeToFade
						if frame.AlphaChanged then
							mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
						else
							mod:PlateFadeMouse(frame, timeToFade, endAlpha)
						end
					end)
				else
					self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
						frame.endAlpha = endAlpha
						frame.timeToFade = timeToFade
						if frame.AlphaChanged then
							mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
						else
							mod:PlateFade(frame, timeToFade, endAlpha)
						end
					end)
				end
			elseif db.enableMouse then
				self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, _, endAlpha)
					frame.endAlpha = endAlpha
					frame.timeToFade = timeToFade
					mod:PlateFadeMouse(frame, timeToFade, endAlpha)
				end)
			else
				self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, _, endAlpha)
					frame.endAlpha = endAlpha
					frame.timeToFade = timeToFade
					mod:PlateFade(frame, timeToFade, endAlpha)
				end)
			end

			f.throttle = db.throttle
			f:SetScript("OnUpdate", buildOnUpdateFunc(db))

			if db.disableCombat then
				self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
					if self:IsHooked(NP, "PlateFade") then self:Unhook(NP, "PlateFade") end
					f:Hide()
				end)
				self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
					if not self:IsHooked(NP, "PlateFade") then
						self:RawHook(NP, "PlateFade", function(self, frame, timeToFade, startAlpha, endAlpha)
							frame.endAlpha = endAlpha
							frame.timeToFade = timeToFade
							if frame.isTarget then
								mod.hooks[NP].PlateFade(self, frame, timeToFade, startAlpha, endAlpha)
							else
								mod:PlateFade(frame, timeToFade, endAlpha)
							end
						end)
					end
					f:Show()
				end)
			else
				self:UnregisterEvent("PLAYER_REGEN_DISABLED")
				self:UnregisterEvent("PLAYER_REGEN_ENABLED")
			end
			self:RegisterEvent("DISPLAY_SIZE_CHANGED", updateScreenDimensions)

			f:Show()
		else
			self:UnregisterAllEvents()
			f:SetScript("OnUpdate", nil)
			f:Hide()
		end
		self.initialized = true
	elseif self.initialized then
		self:UnregisterAllEvents()
		f:SetScript("OnUpdate", nil)
		f:Hide()
	end
end

function mod:InitializeCallback()
	if not E.private.nameplates.enable then return end
	local db = E.db.Extras.nameplates[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback