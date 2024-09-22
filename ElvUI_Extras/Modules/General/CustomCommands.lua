local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Custom Commands", "AceHook-3.0")

local modName = mod:GetName()
local errorCount, lastEventTime = 0
local handler = CreateFrame("Frame")
local initialized

local tostring, tonumber = tostring, tonumber
local pairs, ipairs, loadstring, pcall, print, select = pairs, ipairs, loadstring, pcall, print, select
local tinsert, tremove = table.insert, table.remove
local sub, find, gsub, upper, format = string.sub, string.find, string.gsub, string.upper, string.format
local GetTime = GetTime
local INTERRUPTED = INTERRUPTED

local function convertToValue(value)
	if value == 'nil' then
		return nil
	elseif value == 'true' then
		return true
	elseif value == 'false' then
		return false
	else
		return value
	end
end


P["Extras"]["general"][modName] = {
	["enabled"] = false,
	["selected"] = 1,
	["tabs"] = {{ name = L["New Tab"], events = "", commands = "", throttleEvents = {}, selectedEvent = '', enabled = true }},
	["conditions"] = {},
	["commands"] = {},
}

function mod:LoadConfig()
	core.general.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return E.db.Extras.general[modName][info[#info]] end,
		set = function(info, value) E.db.Extras.general[modName][info[#info]] = value mod:Toggle(value) end,
		args = {
			CustomCommands = {
				order = 1,
				type = "group",
				guiInline = true,
				name = L[modName],
				args = {
					enabled = {
						order = 1,
						type = "toggle",
						name = core.pluginColor..L["Enable"],
						desc = L["Event and OnUpdate handler."],
						width = "full",
					},
				},
			},
			settings = {
				order = 2,
				type = "group",
				name = L["Settings"],
				guiInline = true,
				disabled = function() return not E.db.Extras.general[modName].enabled end,
				args = {
					enableTab = {
						order = 2,
						type = "toggle",
						name = L["Enable Tab"],
						desc = "",
						get = function() return E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].enabled end,
						set = function(_, value) E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].enabled = value self:SetupHandler() end,
					},
					throttleTime = {
						order = 3,
						type = "range",
						min = 0, max = 600, step = 0.1,
						name = L["Throttle Time"],
						desc = L["Minimal time gap between two consecutive executions."],
						get = function() return E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].throttleEvents[E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].selectedEvent] or 0.3 end,
						set = function(_, value) E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].throttleEvents[E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].selectedEvent] = value end,
						disabled = function() return not E.db.Extras.general[modName].enabled or E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].selectedEvent == '' end,
					},
					tabSelection = {
						order = 4,
						type = "select",
						name = L["Select Tab"],
						desc = "",
						get = function() return tostring(E.db.Extras.general[modName].selected) end,
						set = function(_, value) E.db.Extras.general[modName].selected = tonumber(value) end,
						values = function()
							local dropdownValues = {}
							for i, tab in ipairs(E.db.Extras.general[modName].tabs) do
								dropdownValues[tostring(i)] = tab.name
							end
							return dropdownValues
						end,
					},
					eventDropdown = {
						order = 5,
						type = "select",
						name = L["Select Event"],
						desc = "",
						get = function() return E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].selectedEvent end,
						set = function(_, value) E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].selectedEvent = value end,
						values = function()
							local dropdownValues = {}
							for event in pairs(E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].throttleEvents) do
								dropdownValues[tostring(event)] = event
							end
							return dropdownValues
						end,
					},
					renameTabEditbox = {
						order = 6,
						type = "input",
						width = "double",
						name = L["Rename Tab"],
						desc = "",
						get = function() return "" end,
						set = function(_, value)
							if value and value ~= "" then
								E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].name = value
							end
						end,
					},
					addTab = {
						order = 7,
						type = "execute",
						name = L["Add Tab"],
						desc = "",
						func = function()
							local newTab = { name = L["New Tab"], events = "", commands = "", throttleTime = 0.3, throttleEvents = {}, selectedEvent = '', enabled = true }
							tinsert(E.db.Extras.general[modName].tabs, newTab)
							E.db.Extras.general[modName].selected = #E.db.Extras.general[modName].tabs
						end,
					},
					deleteTab = {
						order = 8,
						type = "execute",
						name = L["Delete Tab"],
						desc = "",
						func = function() tremove(E.db.Extras.general[modName].tabs, E.db.Extras.general[modName].selected) E.db.Extras.general[modName].selected = 1 end,
						disabled = function() return #E.db.Extras.general[modName].tabs <= 1 or not E.db.Extras.general[modName].enabled end,
					},
					openEditFrame = {
						order = 9,
						type = "execute",
						width = "double",
						name = L["Open Edit Frame"],
						desc = "",
						func = function()
							local db = E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected]
							core:OpenEditor(L["Custom Commands"], db.commands, function() db.commands = core.EditFrame.editBox:GetText() mod:SetupHandler() end)
						end,
						disabled = function() return not E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].enabled or not E.db.Extras.general[modName].enabled end,
					},
					eventsEditbox = {
						order = 10,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Events"],
						desc = L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"],
						get = function() return E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].events and E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].events or "" end,
						set = function(_, value) E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].events = value self:SetupHandler() end,
						disabled = function() return not E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].enabled or not E.db.Extras.general[modName].enabled end,
					},
					commandsEditbox = {
						order = 11,
						type = "input",
						multiline = true,
						name = L["Commands to execute"],
						desc = L["Syntax:"..
							"\n\nEVENT[n~=nil]"..
							"\n[n~=value]"..
							"\n[m=false]"..
							"\n[k~=@@UnitName('player')]"..
							"\n@@@commands@@@"..
							"\n\n'EVENT' - Event from the events section above"..
							"\n'n, m, k' - indexex of the desired payload args (number)"..
							"\n'nil/value/boolean/lua code' - desired output of n arg"..
							"\n'@@' - lua arg flag, must go before the lua code within the args' value section"..
							"\n'~' - negate flag, add before the equals sign to have the code executed if n/m/k is not mathing the set value instead"..
							"\n'@@@ @@@' - brackets holding the commands."..
							"\nYou may access the payload (...) as per usual."..
							"\n\nExample:"..
							"\n\nUNIT_AURA[1=player]@@@"..
							"\nprint(player has gained/lost an aura)@@@"..
							"\n\nCHAT_MSG_WHISPER"..
							"\n[5~=UnitName('player')]"..
							"\n[14=false]@@@"..
							"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
							"\n\nCOMBAT_LOG_EVENT_"..
							"\nUNFILTERED"..
							"\n[5=UnitName('arena1')]"..
							"\n[5=UnitName('arena2')]@@@"..
							"\nfor i = 1, 2 do"..
							"\nif UnitDebuff('party'..i, 'Bad Spell')"..
							"\nthen print(UnitName('party'..i)..' is afflicted!')"..
							"\nend end@@@"..
							"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."],
						width = "double",
						get = function() local storedValue = E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].commands ~= "" and E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].commands return storedValue end,
						set = function(_, value) E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].commands = value mod:SetupHandler() end,
						disabled = function() return not E.db.Extras.general[modName].tabs[E.db.Extras.general[modName].selected].enabled or not E.db.Extras.general[modName].enabled end,
					},
				},
			},
		},
	}
end


function mod:LoadCommands(commands, eventArg, tabArg, ...)
	if not commands then
		if errorCount >= 10 then
			mod:Toggle(false)
			return
		end
		errorCount = errorCount + 1
		core:print('FORMATTING', L["CustomCommands"], '')
		return
	end

	local luaFunction, errorMsg = loadstring("return function(...) "..commands.." end")
    if luaFunction then
        local success, fn = pcall(luaFunction)
        if not success then
			core:print('FAIL', L["CustomCommands"], fn)
            return
        end

		local result
        if tabArg then
            local wrapperFunction = function()
                local evaluatedTabArg = loadstring("return "..tabArg)()
                return pcall(fn, eventArg, evaluatedTabArg)
            end
            success, result = wrapperFunction()
            if not success then
				core:print('FAIL', L["CustomCommands"], result)
            end
            return result
        else
            success, result = pcall(fn, ...)
            if not success then
				core:print('FAIL', L["CustomCommands"], result)
            end
            return result
        end
	else
		if errorCount >= 10 then
			mod:Toggle(false)
			return
		end
		errorCount = errorCount + 1
		core:print('LUA', L["CustomCommands"], errorMsg)
	end
end

function mod:SortArgs(db, commandsString, argsBlockStartIndex)
	while sub(commandsString, argsBlockStartIndex, argsBlockStartIndex) == '[' do
		local argsBlockEndIndex = find(commandsString, "]", argsBlockStartIndex + 1)
		local arguments = sub(commandsString, argsBlockStartIndex + 1, argsBlockEndIndex - 1)

		local _, _, argIndex, negate, argValue = find(arguments, "(%w+)(~?)=([^%]]+)")

		if argValue then
			local argIsLua = sub(argValue, 1, 2) == '@@'

			if argIsLua then
				argValue = sub(argValue, 3, #argValue)
			else
				argValue = convertToValue(argValue)
			end

			-- store args info
			tinsert(db.args, { index = argIndex, argIsLua = argIsLua, arg = argValue, negate = negate == '~' })
		end

		argsBlockStartIndex = argsBlockEndIndex + 1
	end
end

function mod:SortEvents(db)
	local startIndex = 1
	local eventsString, commandsString = db.events, db.commands
	db.args = {}
	db.eventCommandsPairs = {}
	handler.OnUpdateEvent = false

	while true do
		-- check if there are any events
		local _, newStartIndex = find(eventsString, "[%u_]+", startIndex)
		if not newStartIndex then break end

		local event = sub(eventsString, startIndex, newStartIndex)
		event = gsub(event, "%s+", "")

		if upper(event) == 'ONUPDATE' then
			handler.OnUpdateEvent = true
		else
			handler:RegisterEvent(event)
		end

		if not db.throttleEvents[event] then
			db.throttleEvents[event] = 0.3
		end

		-- check the args
		local commandsBlockStart, eventNameEnd = find(commandsString, event, 1, true)
		if commandsBlockStart ~= nil then

			-- sort and store args
			local argsBlockStartIndex = eventNameEnd + 1
			mod:SortArgs(db, commandsString, argsBlockStartIndex)

			-- locate commands and cut the rest
			local _, _, eventCommands = find(commandsString, "@@@(.-)@@@", eventNameEnd)

			-- store values
			db.eventCommandsPairs[event] = eventCommands

		end
		startIndex = newStartIndex + 1
	end
end

function mod:CheckArgs(tab, ...)
	for _, argTab in ipairs(tab.args) do
		local eventArg = select(argTab.index, ...)
		if argTab.argIsLua then
			-- check the lua arg
			local result = mod:LoadCommands('if select(1, ...) == select(2, ...) then return true end', eventArg, argTab.arg)

			if (result and argTab.negate) or (not result and not argTab.negate) then
				return true
			end
		else
			if (not argTab.negate and argTab.arg ~= eventArg)
			 or (argTab.negate and argTab.arg == eventArg) then
				return true
			end
		end
	end
end

function mod:SetupHandler()
	local db = E.db.Extras.general[modName]
	handler:UnregisterAllEvents()

	for i = 1, #db.tabs do
		if db.tabs[i].enabled and db.tabs[i].commands and db.tabs[i].commands ~= "" and db.tabs[i].events and db.tabs[i].events ~= "" then
			mod:SortEvents(db.tabs[i])
		end
	end

	if handler.OnUpdateEvent then
		local lastTime = GetTime()
		handler:SetScript('OnUpdate', function()
			for _, tab in pairs(db.tabs) do
				if tab.enabled and find(tab.events, 'ONUPDATE') and GetTime() > lastTime + tab.throttleEvents.ONUPDATE then
					local commandsToLoad = tab.eventCommandsPairs.ONUPDATE
					mod:LoadCommands(commandsToLoad)
					lastTime = GetTime()
				end
			end
		end)
	end

	handler:SetScript('OnEvent', function(self, event, ...)
		for _, tab in pairs(db.tabs) do
			if tab.enabled and find(tab.events, event) and (not lastEventTime or (GetTime() > lastEventTime + (tab.throttleEvents[event] or 0))) then
				local commandsToLoad = tab.eventCommandsPairs[event]
				local failedTheArgs
				if ... and #tab.args > 0 then
					failedTheArgs = mod:CheckArgs(tab, ...)
				end
				if not failedTheArgs then
					mod:LoadCommands(commandsToLoad, nil, nil, ...)
					lastEventTime = GetTime()
				end
			end
		end
	end)
end


function mod:Toggle(enable)
	if enable then
		self:SetupHandler()
		initialized = true
	elseif initialized then
		handler:UnregisterAllEvents()
		handler:SetScript("OnUpdate", nil)
		handler:UnregisterAllEvents("OnEvent", nil)
		if errorCount >= 10 then
			print(format(core.customColorAlpha.."ElvUI "..core.pluginColor.."Extras "..core.customColorAlpha..","..core.customColorBeta.." %s "..core.customColorBad..' '..INTERRUPTED, L["CustomCommands"]))
			for _, tab in pairs(E.db.Extras.general[modName].tabs) do
				tab.enabled = false
			end
		end
		errorCount = 0
	end
end

function mod:InitializeCallback()
	mod:LoadConfig()
	mod:Toggle(E.db.Extras.general[modName].enabled)
end

core.modules[modName] = mod.InitializeCallback