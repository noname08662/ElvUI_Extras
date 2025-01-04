local E, L, _, P = unpack(ElvUI)
local core = E:GetModule("Extras")
local mod = core:NewModule("Custom Commands", "AceHook-3.0")

local modName = mod:GetName()
local handler = CreateFrame("Frame")

mod.initialized = false

local tostring, tonumber = tostring, tonumber
local pairs, ipairs, loadstring, pcall, print, select = pairs, ipairs, loadstring, pcall, print, select
local tinsert, tremove, twipe = table.insert, table.remove, table.wipe
local sub, find, upper, match, gmatch = string.sub, string.find, string.upper, string.match, string.gmatch
local GetTime = GetTime

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
	["tabs"] = {{ name = L["New Tab"], events = "", commands = "", throttleEvents = {}, selectedEvent = '', enabled = true, preLoad = false }},
	["conditions"] = {},
	["commands"] = {},
}

function mod:LoadConfig(db)
	core.general.args[modName] = {
		type = "group",
		name = L[modName],
		get = function(info) return db[info[#info]] end,
		set = function(info, value) db[info[#info]] = value self:Toggle(db) end,
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
				disabled = function() return not db.enabled end,
				args = {
					enableTab = {
						order = 1,
						type = "toggle",
						width = "full",
						name = L["Enable Tab"],
						desc = "",
						get = function() return db.tabs[db.selected].enabled end,
						set = function(_, value) db.tabs[db.selected].enabled = value self:SetupHandler(db) end,
					},
					preLoad = {
						order = 2,
						type = "toggle",
						name = L["Pre-Load"],
						desc = L["Executes commands during the addon's initialization process."],
						get = function() return db.tabs[db.selected].preLoad end,
						set = function(_, value) db.tabs[db.selected].preLoad = value self:Toggle(db) end,
					},
					throttleTime = {
						order = 3,
						type = "range",
						min = 0, max = 600, step = 0.1,
						name = L["Throttle Time"],
						desc = L["Minimal time gap between two consecutive executions."],
						get = function() return db.tabs[db.selected].throttleEvents[db.tabs[db.selected].selectedEvent] or 0.3 end,
						set = function(_, value) db.tabs[db.selected].throttleEvents[db.tabs[db.selected].selectedEvent] = value self:Toggle(db) end,
						disabled = function() return not db.enabled or db.tabs[db.selected].selectedEvent == '' or db.tabs[db.selected].preLoad end,
					},
					tabSelection = {
						order = 4,
						type = "select",
						name = L["Select Tab"],
						desc = "",
						get = function() return tostring(db.selected) end,
						set = function(_, value) db.selected = tonumber(value) end,
						values = function()
							local dropdownValues = {}
							for i, tab in ipairs(db.tabs) do
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
						get = function() return db.tabs[db.selected].selectedEvent end,
						set = function(_, value) db.tabs[db.selected].selectedEvent = value end,
						values = function()
							local dropdownValues = {}
							for event in pairs(db.tabs[db.selected].throttleEvents) do
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
								db.tabs[db.selected].name = value
							end
						end,
					},
					addTab = {
						order = 7,
						type = "execute",
						name = L["Add Tab"],
						desc = "",
						func = function()
							local newTab = {
								name = L["New Tab"],
								events = "",
								commands = "",
								throttleTime = 0.3,
								throttleEvents = {},
								selectedEvent = '',
								enabled = true,
								preLoad = false,
							}
							tinsert(db.tabs, newTab)
							db.selected = #db.tabs
						end,
					},
					deleteTab = {
						order = 8,
						type = "execute",
						name = L["Delete Tab"],
						desc = "",
						func = function() tremove(db.tabs, db.selected) db.selected = 1 end,
						disabled = function() return #db.tabs <= 1 or not db.enabled end,
					},
					openEditFrame = {
						order = 9,
						type = "execute",
						width = "double",
						name = L["Open Edit Frame"],
						desc = "",
						func = function()
							local tab_db = db.tabs[db.selected]
							core:OpenEditor(L["Custom Commands"],
											tab_db.commands,
											function() tab_db.commands = core.EditFrame.editBox:GetText() mod:SetupHandler(db) end)
						end,
						disabled = function() return not db.tabs[db.selected].enabled or not db.enabled end,
					},
					eventsEditbox = {
						order = 10,
						type = "input",
						multiline = true,
						width = "double",
						name = L["Events"],
						desc = L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"],
						get = function() return db.tabs[db.selected].events and db.tabs[db.selected].events or "" end,
						set = function(_, value) db.tabs[db.selected].events = value self:SetupHandler(db) end,
						disabled = function() return not db.tabs[db.selected].enabled or not db.enabled end,
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
							"\n'n, m, k' - indexes of the desired payload args (number)"..
							"\n'nil/value/boolean/lua code' - desired output of n arg"..
							"\n'@@' - lua arg flag, must go before the lua code within the args' value section"..
							"\n'~' - negate flag, add before the equals sign to have the code executed if n/m/k is not mathing the set value instead"..
							"\n'@@@ @@@' - brackets holding the commands."..
							"\nYou may access the payload (...) as per usual."..
							"\n\nExample:"..
							"\n\nUNIT_AURA[1=player]@@@"..
							"\nprint(player has gained/lost an aura)@@@"..
							"\n\nCHAT_MSG_WHISPER"..
							"\n[5~=@@UnitName('player')]"..
							"\n[14=false]@@@"..
							"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
							"\n\nCOMBAT_LOG_EVENT_"..
							"\nUNFILTERED"..
							"\n[5=@@UnitName('arena1')]"..
							"\n[5=@@UnitName('arena2')]@@@"..
							"\nfor i = 1, 2 do"..
							"\nif UnitDebuff('party'..i, 'Bad Spell')"..
							"\nthen print(UnitName('party'..i)..' is afflicted!')"..
							"\nend end@@@"..
							"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."],
						width = "double",
						get = function()
							local storedValue = db.tabs[db.selected].commands ~= "" and db.tabs[db.selected].commands
							return storedValue
						end,
						set = function(_, value) db.tabs[db.selected].commands = value mod:SetupHandler(db) end,
						disabled = function() return not db.tabs[db.selected].enabled or not db.enabled end,
					},
				},
			},
		},
	}
end


function mod:CheckArgs(tab, ...)
    for _, argTab in ipairs(tab.args) do
        local eventArg = select(argTab.index, ...)
        if argTab.argIsLua then
            -- Check the lua arg using the cached function
            local result = argTab.argFunc() == eventArg

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

function mod:SortArgs(db, commandsString, argsBlockStartIndex)
    while sub(commandsString, argsBlockStartIndex, argsBlockStartIndex) == '[' do
        local argsBlockEndIndex = find(commandsString, "]", argsBlockStartIndex + 1)
        local arguments = sub(commandsString, argsBlockStartIndex + 1, argsBlockEndIndex - 1)

        local argIndex, negate, argValue = match(arguments, "(%w+)(~?)=([^%]]+)")

        if argValue then
            local argIsLua = sub(argValue, 1, 2) == '@@'
            local argFunc

            if argIsLua then
                argValue = sub(argValue, 3, #argValue)
                local luaFunction, errorMsg = loadstring('return '..argValue)
                if luaFunction then
                    local success, fn = pcall(luaFunction)
                    if not success then
                        core:print('FAIL', L["CustomCommands"], fn)
                        argFunc = function() return false end
                    else
                        argFunc = luaFunction
                    end
                else
                    core:print('LUA', L["CustomCommands"], errorMsg)
                    argFunc = function() return false end
                end
            else
                argValue = convertToValue(argValue)
                argFunc = function() return false end
            end

            -- Store args info
            tinsert(db.args, { index = argIndex, argIsLua = argIsLua, arg = argValue, argFunc = argFunc, negate = negate == '~' })
        end
        argsBlockStartIndex = argsBlockEndIndex + 1
    end
end

function mod:SortEvents(db)
    local eventsString, commandsString = db.events, db.commands
    db.args = {}
    db.eventCommandsPairs = {}
    handler.OnUpdateEvent = false

    for event in gmatch(eventsString, "[%u_]+") do
        -- Check the args
        local commandsBlockStart, eventNameEnd = find(commandsString, event, 1, true)
        if commandsBlockStart ~= nil then
            -- Sort and store args
            self:SortArgs(db, commandsString, eventNameEnd + 1)

            -- Compile and cache the function
            local luaFunction, errorMsg = loadstring("return function(...) "..(match(commandsString, "@@@(.-)@@@", eventNameEnd) or "").." end")
            if luaFunction then
                local success, fn = pcall(luaFunction)
                if not success then
                    core:print('FAIL', L["CustomCommands"], fn)
                    fn = function() end
                end
                db.eventCommandsPairs[event] = fn
				if upper(event) == 'ONUPDATE' then
					handler.OnUpdateEvent = true
				else
					handler:RegisterEvent(event)
				end
				if not db.throttleEvents[event] then
					db.throttleEvents[event] = 0.3
				end
            else
                core:print('LUA', L["CustomCommands"], errorMsg)
                db.eventCommandsPairs[event] = function() end
            end
			db.lastEventTime = db.lastEventTime or {}
			db.lastEventTime[event] = 0
        end
    end
end

function mod:SetupHandler(db)
    handler:UnregisterAllEvents()

    local onUpdTabs = {}
    local eventTabs = {}

    for _, tab in ipairs(db.tabs) do
        if tab.enabled and not tab.preLoad and tab.commands and tab.commands ~= "" and tab.events and tab.events ~= "" then
            self:SortEvents(tab)
            tinsert(eventTabs, CopyTable(tab))
            if find(tab.events, 'ONUPDATE') then
                tinsert(onUpdTabs, {throttleTime = tab.throttleEvents.ONUPDATE, func = tab.eventCommandsPairs.ONUPDATE})
            end
			twipe(tab.eventCommandsPairs)
        end
    end

    if handler.OnUpdateEvent then
        local lastTime = GetTime()
        handler:SetScript('OnUpdate', function()
            for _, tab in ipairs(onUpdTabs) do
                if GetTime() > lastTime + tab.throttleTime then
                    tab.func()
                    lastTime = GetTime()
                end
            end
        end)
    end

    handler:SetScript('OnEvent', function(_, event, ...)
        for _, tab in ipairs(eventTabs) do
            if find(tab.events, event) and (GetTime() >= tab.lastEventTime[event] + (tab.throttleEvents[event] or 0)) then
                local failedTheArgs
                if ... and #tab.args > 0 then
                    failedTheArgs = self:CheckArgs(tab, ...)
                end
                if not failedTheArgs then
                    tab.eventCommandsPairs[event](...)
                    tab.lastEventTime[event] = GetTime()
                end
            end
        end
    end)
end

local data = (E.db.Extras and E.db.Extras.general) and E.db.Extras.general[modName]
if data and data.enabled then
	for _, tab in pairs(data.tabs or {}) do
		if tab.preLoad and tab.commands then
			local luaFunction, errorMsg = loadstring("return function(...) "..tab.commands.." end")
			if luaFunction then
				local luaFunction, fn = pcall(luaFunction)
				if not luaFunction then
					print(L["CustomCommands"], fn)
					return
				end

				local success, result = pcall(fn, ...)
				if not success then
					print(L["CustomCommands"], result)
				end
			else
				print(L["CustomCommands"], errorMsg)
			end
		end
	end
end


function mod:Toggle(db)
	if not core.reload and db and db.enabled then
		self:SetupHandler(db)
		self.initialized = true
	elseif self.initialized then
		handler:UnregisterAllEvents()
		handler:SetScript("OnUpdate", nil)
		handler:SetScript("OnEvent", nil)
	end
end

function mod:InitializeCallback()
	local db = E.db.Extras.general[modName]
	mod:LoadConfig(db)
	mod:Toggle(db)
end

core.modules[modName] = mod.InitializeCallback