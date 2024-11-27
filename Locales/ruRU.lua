local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "ruRU")

L["Hits the 'Confirm' button automatically."] = "Автоматически нажимает кнопку 'Подтвердить'."
L["Picks up items and money automatically."] = "Автоматически подбирает предметы и деньги."
L["Automatically fills the 'DELETE' field."] = "Автоматически заполняет поле 'DELETE'."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "Выбирает первый вариант диалога, если он единственный доступный, если не удерживается модификатор.\nОсторожно с важными событиями, здесь нет механизма защиты от ошибок."
L["Accepts and turns in quests automatically while holding a modifier."] = "Автоматически принимает и сдает задания при удержании модификатора."
L["Loot info wiped."] = "Информация о добыче очищена."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "Команда /lootinfo для получения краткого обзора недавней добычи.\n\nИспользование: /lootinfo Яблоко 60\n'Яблоко' - название предмета/имя игрока \n(используйте @self для получения добычи игрока)\n'60' - \nвременной лимит (<60 секунд назад), необязательно,\n/lootinfo !wipe - очистить кэш добычи."
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "Окрашивает имена онлайн-друзей и согильдийцев в некоторых сообщениях и стилизует броски.\nУже обработанные облачка чата не будут стилизованы до /reload."
L["Colors loot roll messages for you and other players."] = "Окрашивает сообщения о бросках на добычу для вас и других игроков."
L["Loot rolls icon size."] = "Размер иконки бросков на добычу."
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "Изменяет стиль полос добычи.\nТребуется включение 'Броска на добычу' (Общее -> Улучшения BlizzUI -> Бросок на добычу) (включение этого модуля активирует его автоматически)."
L["Displays the name of the player pinging the minimap."] = "Отображает имя игрока, пингующего миникарту."
L["Displays the currently held currency amount next to the item prices."] = "Отображает текущее количество валюты рядом с ценами на предметы."
L["Narrows down the World(..Frame)."] = "Сужает World(..Frame)."
L["'Out of mana', 'Ability is not ready yet', etc."] = "'Нет маны', 'Способность еще не готова' и т.д."
L["Re-enable quest updates."] = "Повторно включить обновления заданий."
L["Adds anchoring options to the movers' nudges."] = "Добавляет параметры привязки к подвижкам мувера."
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - желтый цвет Blizzard."
L["Text to display upon entering combat."] = "Текст, отображаемый при входе в бой."
L["Text to display upon leaving combat."] = "Текст, отображаемый при выходе из боя."
L["REQUIRES RELOAD."] = "ТРЕБУЕТ ПЕРЕЗАГРУЗКИ."
L["Icon to the left or right of the item link."] = "Иконка слева или справа от ссылки на предмет."
L["The size of the icon in the chat frame."] = "Размер иконки в окне чата."
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "Добавляет тени ко всем рамкам.\nНичего не делает, если вы не замените ваш ElvUI/Core/Toolkit.lua соответствующим файлом из папки Optionals этого плагина."
L["Combat state notification alerts."] = "Оповещения о состоянии боя."
L["Custom editbox position and size."] = "Пользовательская позиция и размер поля редактирования."
L["Usage:"..
	"\n/tnote list - returns all existing notes"..
	"\n/tnote wipe - clears all existing notes"..
	"\n/tnote 1 icon Interface\\Path\\ToYourIcon - same as set (except for the lua part)"..
	"\n/tnote 1 get - same as set, returns existing notes"..
	"\n/tnote 1 set YourNoteHere - adds a note to the designated index from the list "..
	"or to a currently shown tooltip text if the second argument (1 in this case) is ommitted, "..
	"supports functions and coloring "..
	"(providing no text clears the note);"..
	"\nto break the lines, use ::"..
	"\n\nExample:"..
	"\n\n/tnote 3 set fire pre-bis::source: Joseph Mama"..
	"\n\n/tnote set local percentage ="..
	"\n  UnitHealth('mouseover') / "..
	"\n  UnitHealthMax('mouseover')"..
	"\nreturn string.format('\124\124cffffd100(default color)'"..
	"\n  ..UnitName('mouseover')"..
	"\n  ..': \124\124cff%02x%02x00'"..
	"\n  ..UnitHealth('mouseover'), "..
	"\n  (1-percentage)*255, percentage*255)"] =
		"Использование:"..
			"\n/tnote list - возвращает все существующие заметки"..
			"\n/tnote wipe - удаляет все существующие заметки"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - то же, что и set (кроме lua части)"..
			"\n/tnote 1 get - то же, что и set, возвращает существующие заметки"..
			"\n/tnote 1 set ВашаЗаметкаЗдесь - добавляет заметку к указанному индексу из списка "..
			"или к текущему отображаемому тексту подсказки, если второй аргумент (1 в данном случае) опущен, "..
			"поддерживает функции и окрашивание "..
			"(предоставление пустого текста удаляет заметку);"..
			"\nдля разрыва строк используйте ::"..
			"\n\nПример:"..
			"\n\n/tnote 3 set огонь пре-бис::источник: Головач Лена"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(цвет по умолчанию)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "Добавляет значок рядом с гиперссылками в чате."
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "Новая панель действий, которая собирает используемые предметы для заданий из вашей сумки.\n\nИз-за ограничения действий состояния, этот модуль переопределяет bar10, созданную ElvUI Extra Action Bars."
L["Toggles the display of the actionbar's backdrop."] = "Переключает отображение фона панелей действий."
L["The frame will not be displayed unless hovered over."] = "Рамка не будет показываться, пока вы не наведете на нее курсор."
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "Наследует глобальное затухание, наведение мыши, выбор цели, установка фокуса, потеря здоровья, вступление в бой уберут прозрачность. В противном случае будет использоваться уровень прозрачности в общих настройках панели действий для альфа-канала глобального затухания."
L["The first button anchors itself to this point on the bar."] = "Первая кнопка привязывается к этой точке на панели."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "Щелкните правой кнопкой мыши по предмету, удерживая модификатор, чтобы добавить его в черный список. Предметы из черного списка не будут отображаться на панели.\nИспользуйте /questbarRestore для очистки черного списка."
L["The number of buttons to display."] = "Количество отображаемых кнопок."
L["The number of buttons to display per row."] = "Количество кнопок для отображения в ряду."
L["The size of the action buttons."] = "Размер кнопок действий."
L["Spacing between the buttons."] = "Расстояние между кнопками."
L["Spacing between the backdrop and the buttons."] = "Расстояние между фоном и кнопками."
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "Умножьте высоту или ширину фона на это значение. Это полезно, если вы хотите иметь более одной панели за фоном."
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "Это работает как макрос, вы можете запускать различные ситуации, чтобы панель действий отображалась/скрывалась по-разному.\n Пример: '[combat] showhide'"
L["Mod-clicking an item suggests a skill/item to process it."] = "Клик с модификатором по предмету предлагает навык/предмет для его обработки."
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"Удерживание %s при левом клике на стопку разделяет ее на две части; для объединения доступных копий используйте правый клик."..
    "\n\nТакже изменяет SplitStackFrame, используя поле ввода вместо стрелок."
L["Extends the bags functionality."] = "Расширяет функциональность сумок."
L["Default method: type > inventory slot ID > item level > name."] = "Метод по умолчанию: тип > ID слота инвентаря > уровень предмета > название."
L["Listed ItemIDs will not get sorted."] = "Перечисленные ID предметов не будут отсортированы."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Например, Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "Неверный формат условия: "
L["The generated custom sorting method did not return a function."] = "Сгенерированный пользовательский метод сортировки не вернул функцию."
L["The loaded custom sorting method did not return a function."] = "Загруженный пользовательский метод сортировки не вернул функцию."
L["Item received: "] = "Получен предмет: "
L[" added."] = " добавлено."
L[" removed."] = " удалено."
L["Handles the automated repositioning of the newly received items."..
	"\nSyntax: filter@value\n\n"..
	"Available filters:\n"..
	" id@number - matches itemID,\n"..
	" name@string - matches name,\n"..
	" subtype@string - matches subtype,\n"..
	" ilvl@number - matches ilvl,\n"..
	" uselevel@number - matches equip level,\n"..
	" quality@number - matches quality,\n"..
	" equipslot@number - matches inventorySlotID,\n"..
	" maxstack@number - matches stack limit,\n"..
	" price@number - matches sell price,\n\n"..
	" tooltip@string - matches tooltip text,\n\n"..
	"All string matches are case-insensitive and match only alphanumeric symbols. Standard Lua logic applies. "..
	"Look up GetItemInfo API for more info on filters. "..
	"Use GetAuctionItemClasses and GetAuctionItemSubClasses (same as on the AH) to get the localized types and subtypes values.\n\n"..
	"Example usage (priest t8 or Shadowmourne):\n"..
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
	"Accepts custom functions (bagID, slotID, itemID are exposed)\n"..
	"The below one notifies of the newly acquired items.\n\n"..
	"local icon = GetContainerItemInfo(bagID, slotID)\n"..
	"local _, link = GetItemInfo(itemID)\n"..
	"icon = gsub(icon, '\\124', '\\124\\124')\n"..
	"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
	"print('Item received: ' .. string)"] =
		"Обрабатывает автоматическое перемещение новых полученных предметов."..
		"\nСинтаксис: фильтр@значение\n\n"..
		"Доступные фильтры:\n"..
		" id@число - соответствует ID предмета,\n"..
		" name@строка - соответствует названию,\n"..
		" subtype@строка - соответствует подтипу,\n"..
		" ilvl@число - соответствует уровню предмета,\n"..
		" uselevel@число - соответствует уровню экипировки,\n"..
		" quality@число - соответствует качеству,\n"..
		" equipslot@число - соответствует ID слота инвентаря,\n"..
		" maxstack@число - соответствует лимиту стака,\n"..
		" price@число - соответствует цене продажи,\n\n"..
		" tooltip@строка - соответствует тексту всплывающей подсказки,\n\n"..
		"Все строковые совпадения не чувствительны к регистру и соответствуют только буквенно-цифровым символам. Применяется стандартная логика lua. "..
		"Посмотрите API GetItemInfo для получения дополнительной информации о фильтрах. "..
		"Используйте GetAuctionItemClasses и GetAuctionItemSubClasses (как в аукционном доме) для получения локализованных значений типов и подтипов.\n\n"..
		"Пример использования (жрец t8 или Shadowmourne):\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@освящения) or name@shadowmourne.\n\n"..
		"Принимает пользовательские функции (доступны bagID, slotID, itemID)\n"..
		"Приведенный ниже пример уведомляет о новых полученных предметах.\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\\124', '\\124\\124')\n"..
		"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
		"print('Получен предмет: ' .. string)"
L["Syntax: filter@value\n\n"..
	"Available filters:\n"..
	" id@number - matches itemID,\n"..
	" name@string - matches name,\n"..
	" type@string - matches type,\n"..
	" subtype@string - matches subtype,\n"..
	" ilvl@number - matches ilvl,\n"..
	" uselevel@number - matches equip level,\n"..
	" quality@number - matches quality,\n"..
	" equipslot@number - matches inventorySlotID,\n"..
	" maxstack@number - matches stack limit,\n"..
	" price@number - matches sell price,\n"..
	" tooltip@string - matches tooltip text.\n\n"..
	"All string matches are case-insensitive and match only alphanumeric symbols.\n"..
	"Standard Lua logic for branching (and/or/parenthesis/etc.) applies.\n\n"..
	"Example usage (priest t8 or Shadowmourne):\n"..
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."] =
		"Синтаксис: фильтр@значение\n\n"..
			"Доступные фильтры:\n"..
			" id@число - соответствует ID предмета,\n"..
			" name@строка - соответствует названию,\n"..
			" type@строка - соответствует типу,\n"..
			" subtype@строка - соответствует подтипу,\n"..
			" ilvl@число - соответствует уровню предмета,\n"..
			" uselevel@число - соответствует требуемому уровню,\n"..
			" quality@число - соответствует качеству,\n"..
			" equipslot@число - соответствует ID слота инвентаря,\n"..
			" maxstack@число - соответствует пределу стопки,\n"..
			" price@число - соответствует цене продажи,\n"..
			" tooltip@строка - соответствует тексту подсказки.\n\n"..
			"Все строковые соответствия нечувствительны к регистру и соответствуют только буквенно-цифровым символам.\n"..
			"Применяется стандартная логика lua для ветвления (и/или/скобки/и т.д.).\n\n"..
			"Пример использования (жрец t8 или Шадоумурн):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "Доступные типы предметов"
L["Lists all available item subtypes for each available item type."] =
	"Показывает все доступные подтипы предметов для каждого доступного типа предметов."
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"Удерживание этой клавиши при взаимодействии с торговцем покупает все предметы, соответствующие методу Автопокупки.\n"..
			"Модифицированный клик по элементу списка покупок покупает только один предмет, независимо от правила '@количество'."
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
    "Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
    "function(a,b)\n"..
    "--your sorting logic here\n"..
    "end\n\n"..
    "Leave blank to go default."] =
		"Метод по умолчанию: тип > ID слота инвентаря > уровень предмета > название.\n\n"..
		"Принимает пользовательские функции (bagID и slotID доступны в a/b.bagID/slotID).\n\n"..
		"function(a,b)\n"..
		"--ваша логика сортировки здесь\n"..
		"end\n\n"..
		"Оставьте пустым для использования по умолчанию."

L["Event and OnUpdate handler."] = "Обработчик событий и OnUpdate."
L["Minimal time gap between two consecutive executions."] = "Минимальный временной интервал между двумя последовательными выполнениями."
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER и т.д.\nONUPDATE - скрипт 'OnUpdate'"
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = "UNIT_AURA CHAT_MSG_WHISPER и т.д."
L["Syntax:"..
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
	"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."] =
		"Синтаксис:"..
		"\n\nEVENT[n~=nil]"..
		"\n[n~=value]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@commands@@@"..
		"\n\n'EVENT' - Событие из раздела событий выше"..
		"\n'n, m, k' - индексы желаемых аргументов полезной нагрузки (число)"..
		"\n'nil/value/boolean/lua code' - желаемый вывод аргумента n"..
		"\n'@@' - флаг аргумента lua, должен идти перед lua-кодом в разделе значения аргументов"..
		"\n'~' - флаг отрицания, добавьте перед знаком равенства, чтобы код выполнялся, если n/m/k не соответствует установленному значению"..
		"\n'@@@ @@@' - скобки, содержащие команды."..
		"\nВы можете получить доступ к полезной нагрузке (...) как обычно."..
		"\n\nПример:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(игрок получил/потерял ауру)@@@"..
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
		"\nthen print(UnitName('party'..i)..' подвержен воздействию!')"..
		"\nend end@@@"..
		"\n\nЭтот модуль анализирует строки, поэтому постарайтесь, чтобы ваш код строго следовал синтаксису, иначе он может не работать."
L["Highlights auras."] = "Подсвечивает ауры."
L["E.g. 42292"] = "Например, 42292"
L["Applies highlights to all auras passing the selected filter."] = "Подсвечивает все ауры, проходящие выбранный фильтр."
L["Priority: spell, filter, curable/stealable."] = "Приоритет: заклинание, фильтр, излечимый/воруемый."
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "Если включено, будут использоваться глобальные значения Заклинания или Фильтра."
L["Makes auras grow sideswise."] = "Заставляет ауры расти в стороны."
L["Turns off texture fill."] = "Выключает заполнение текстуры."
L["Makes auras flicker right before fading out."] = "Заставляет ауры мигать перед исчезновением."
L["Disables border coloring."] = "Отключает окрашивание рамки."
L["Click Cancel"] = "Отмена по клику"
L["Right-click a player buff to cancel it."] = "Щелкните правой кнопкой мыши на бафе игрока, чтобы отменить его."
L["Disables debuffs desaturation."] = "Отключает десатурацию дебафов."
L["Saturated Debuffs"] = "Сатурированные Дебафы"
L["Confirm Rolls"] = "Подтверждать броски"
L["Auto Pickup"] = "Автоподбор"
L["Swift Buy"] = "Быстрая покупка"
L["Buys out items automatically."] = "Автоматически выкупает предметы."
L["Failsafe"] = "Защита от сбоев"
L["Enables popup confirmation dialog."] = "Включает всплывающее окно подтверждения."
L["Add Set"] = "Добавить набор"
L["Delete Set"] = "Удалить набор"
L["Select Set"] = "Выбрать набор"
L["Auto Buy"] = "Автопокупка"
L["Fill Delete"] = "Заполнить поле удаления"
L["Gossip"] = "Диалог"
L["Accept Quest"] = "Принять задание"
L["Loot Info"] = "Информация о добыче"
L["Styled Messages"] = "Стилизованные сообщения"
L["Indicator Color"] = "Цвет индикатора"
L["Select Status"] = "Выбрать статус"
L["Select Indicator"] = "Выбрать индикатор"
L["Styled Loot Messages"] = "Стилизованные сообщения о добыче"
L["Icon Size"] = "Размер иконки"
L["Loot Bars"] = "Полосы добычи"
L["Bar Height"] = "Высота полосы"
L["Bar Width"] = "Ширина полосы"
L["Player Pings"] = "Пинги игроков"
L["Held Currency"] = "Имеющаяся валюта"
L["LetterBox"] = "Letterbox"
L["Left"] = "Слева"
L["Right"] = "Справа"
L["Top"] = "Сверху"
L["Bottom"] = "Снизу"
L["Hide Errors"] = "Скрыть ошибки"
L["Show quest updates"] = "Показывать обновления заданий"
L["Less Tooltips"] = "Меньше подсказок"
L["Misc."] = "Разное"
L["Loot&Style"] = "Добыча и стиль"
L["Automation"] = "Автоматизация"
L["Bags"] = "Сумки"
L["Easier Processing"] = "Упрощенная обработка"
L["Modifier"] = "Модификатор"
L["Split Stack"] = "Разделить стопку"
L["Bags Extended"] = "Расширенные сумки"
L["Select Container Type"] = "Выбрать тип контейнера"
L["Settings"] = "Настройки"
L["Add Section"] = "Добавить раздел"
L["Delete Section"] = "Удалить раздел"
L["Select Section"] = "Выбрать раздел"
L["Section Priority"] = "Приоритет раздела"
L["Section Spacing"] = "Интервал между разделами"
L["Collection Method"] = "Метод сбора"
L["Sorting Method"] = "Метод сортировки"
L["Ignore Item (by ID)"] = "Игнорировать предмет (по ID)"
L["Remove Ignored"] = "Удалить игнорируемые"
L["Title"] = "Заголовок"
L["Color"] = "Цвет"
L["Attach to Icon"] = "Прикрепить к иконке"
L["Text"] = "Текст"
L["Font Size"] = "Размер шрифта"
L["Font"] = "Шрифт"
L["Font Flags"] = "Флаги шрифта"
L["Point"] = "Точка"
L["Relative Point"] = "Относительная точка"
L["X Offset"] = "Смещение по X"
L["Y Offset"] = "Смещение по Y"
L["Icon"] = "Иконка"
L["Attach to Text"] = "Прикрепить к тексту"
L["Texture"] = "Текстура"
L["Size"] = "Размер"
L["MoversPlus"] = "ДвижкиПлюс"
L["Movers Plus"] = "ДвижкиПлюс"
L["CustomCommands"] = "Пользовательские команды"
L["Custom Commands"] = "Пользовательские команды"
L["QuestBar"] = "Панель заданий"
L["Quest Bar"] = "Панель заданий"
L["Settings"] = "Настройки"
L["Backdrop"] = "Фон"
L["Show Empty Buttons"] = "Показывать пустые кнопки"
L["Mouse Over"] = "При наведении мыши"
L["Inherit Global Fade"] = "Наследовать глобальное затухание"
L["Anchor Point"] = "Точка привязки"
L["Modifier"] = "Модификатор"
L["Buttons"] = "Кнопки"
L["Buttons Per Row"] = "Кнопок в ряду"
L["Button Size"] = "Размер кнопки"
L["Button Spacing"] = "Расстояние между кнопками"
L["Backdrop Spacing"] = "Расстояние от фона"
L["Height Multiplier"] = "Множитель высоты"
L["Width Multiplier"] = "Множитель ширины"
L["Alpha"] = "Прозрачность"
L["Visibility State"] = "Состояние видимости"
L["Enable Tab"] = "Включить вкладку"
L["Throttle Time"] = "Время задержки"
L["Select Tab"] = "Выбрать вкладку"
L["Select Event"] = "Выбрать событие"
L["Rename Tab"] = "Переименовать вкладку"
L["Add Tab"] = "Добавить вкладку"
L["Delete Tab"] = "Удалить вкладку"
L["Open Edit Frame"] = "Открыть окно редактирования"
L["Events"] = "События"
L["Commands to execute"] = "Команды для выполнения"
L["Sub-Section"] = "Подраздел"
L["Select"] = "Выбрать"
L["Icon Orientation"] = "Ориентация значка"
L["Icon Size"] = "Размер значка"
L["Height Offset"] = "Смещение по высоте"
L["Width Offset"] = "Смещение по ширине"
L["Text Color"] = "Цвет текста"
L["Entering combat"] = "Вступление в бой"
L["Leaving combat"] = "Выход из боя"
L["Font"] = "Шрифт"
L["Font Outline"] = "Контур шрифта"
L["Font Size"] = "Размер шрифта"
L["Texture Width"] = "Ширина текстуры"
L["Texture Height"] = "Высота текстуры"
L["Custom Texture"] = "Пользовательская текстура"
L["ItemIcons"] = "Иконки предметов"
L["TooltipNotes"] = "Заметки всплывающих подсказок"
L["ChatEditBox"] = "Поле редактирования чата"
L["EnterCombatAlert"] = "Оповещение о вступлении в бой"
L["GlobalShadow"] = "Глобальная тень"
L["Any"] = "Любой"
L["Guildmate"] = "Член гильдии"
L["Friend"] = "Друг"
L["Self"] = "Игрок"
L["New Tab"] = "Новая вкладка"
L["None"] = "Нет"
L["Version: "] = "Версия: "
L["Color A"] = "Цвет A"
L["Chat messages, etc."] = "Сообщения в чате и т.д."
L["Color B"] = "Цвет B"
L["Plugin Color"] = "Цвет плагина"
L["Icons Browser"] = "Браузер иконок"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "Установите https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html для более чистых и обрезанных иконок."
L["Add Texture"] = "Добавить текстуру"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Добавляет текстуры в общий список текстур.\nНапример: Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "Удалить текстуру"
L["Highlights"] = "Подсветка"
L["Select Type"] = "Выбрать Тип"
L["Highlights Settings"] = "Настройки Подсветки"
L["Add Spell (by ID)"] = "Добавить Заклинание (по ID)"
L["Add Filter"] = "Добавить Фильтр"
L["Remove Selected"] = "Удалить Выбранное"
L["Select Spell or Filter"] = "Выбрать Заклинание или Фильтр"
L["Use Global Settings"] = "Использовать Глобальные Настройки"
L["Selected Spell or Filter Values"] = "Значения Выбранного Заклинания или Фильтра"
L["Enable Shadow"] = "Включить Тень"
L["Size"] = "Размер"
L["Shadow Color"] = "Цвет Тени"
L["Enable Border"] = "Включить Рамку"
L["Border Color"] = "Цвет Рамки"
L["Centered Auras"] = "Центрированные Ауры"
L["Cooldown Disable"] = "Отключить Время Перезарядки"
L["Animate Fade-Out"] = "Анимация Исчезновения"
L["Type Borders"] = "Тип Рамок"
L[" filter added."] = " фильтр добавлен."
L[" filter removed."] = " фильтр удален."
L["GLOBAL"] = "ГЛОБАЛЬНЫЙ"
L["CURABLE"] = "Излечимый"
L["STEALABLE"] = "Можно украсть"
L["--Filters--"] = "--Фильтры--"
L["--Spells--"] = "--Заклинания--"
L["FRIENDLY"] = "Дружелюбный"
L["ENEMY"] = "Враг"
L["AuraBars"] = "Полосы Аур"
L["Auras"] = "Ауры"
L["ClassificationIndicator"] = "Индикатор Классификации"
L["ClassificationIcons"] = "Иконки Классификации"
L["ColorFilter"] = "Цветовой Фильтр"
L["Cooldowns"] = "Кулдауны"
L["DRTracker"] = "Трекер DR"
L["Guilds&Titles"] = "Гильдии и Звания"
L["Name&Level"] = "Имя и Уровень"
L["QuestIcons"] = "Иконки Квестов"
L["StyleFilter"] = "Фильтр Стиля"
L["Search:"] = "Поиск:"
L["Click to select."] = "Щелкните для выбора."
L["Click to select."] = "Нажмите, чтобы выбрать."
L["Hover again to see the changes."] = "Наведите снова, чтобы увидеть изменения."
L["Note set for "] = "Заметка установлена для "
L["Note cleared for "] = "Заметка удалена для "
L["No note to clear for "] = "Нет заметки для удаления для "
L["Added icon to the note for "] = "Добавлена иконка к заметке для "
L["Note icon cleared for "] = "Иконка заметки удалена для "
L["No note icon to clear for "] = "Нет иконки заметки для удаления для "
L["Current note for "] = "Текущая заметка для "
L["No note found for this tooltip."] = "Заметка не найдена для этой подсказки."
L["Notes: "] = "Заметки: "
L["No notes are set."] = "Заметки не установлены."
L["No tooltip is currently shown or unsupported tooltip type."] = "В данный момент не отображается подсказка или неподдерживаемый тип подсказки."
L["All notes have been cleared."] = "Все заметки были удалены."
L["Accept"] = "Принять"
L["Cancel"] = "Отмена"
L["Purge Cache"] = "Очистить кэш"
L["Guilds"] = "Гильдии"
L["Separator"] = "Разделитель"
L["X Offset"] = "Смещение по X"
L["Y Offset"] = "Смещение по Y"
L["Level"] = "Уровень"
L["Visibility State"] = "Состояние видимости"
L["City (Resting)"] = "Город (Отдых)"
L["PvP"] = "PvP"
L["Arena"] = "Арена"
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Colors"] = "Цвета"
L["Guild"] = "Гильдия"
L["All"] = "Все"
L["Occupation Icon"] = "Иконка профессии"
L["OccupationIcon"] = "Иконка профессии"
L["Size"] = "Размер"
L["Anchor"] = "Привязка"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "Удалить профессию"
L["Modifier"] = "Модификатор"
L["Add Texture Path"] = "Добавить путь текстуры"
L["Remove Selected Texture"] = "Удалить выбранную текстуру"
L["Titles"] = "Титулы"
L["Reaction Color"] = "Цвет реакции"
L["Color based on reaction type."] = "Цвет на основе типа реакции."
L["Nameplates"] = "Неймплейты"
L["Unitframes"] = "Фреймы юнитов"
L["An icon similar to the minimap search."] = "Значок, похожий на поиск на миникарте."
L["Displays player guild text."] = "Отображает текст гильдии игрока."
L["Displays NPC occupation text."] = "Отображает текст профессии NPC."
L["Strata"] = "Слой"
L["Mark"] = "Отметить"
L["Mark the target/mouseover plate."] = "Отмечает неймплейт цели/под курсором."
L["Unmark"] = "Снять отметку"
L["Unmark the target/mouseover plate."] = "Снимает отметку с неймплейта цели/под курсором."
L["FRIENDLY_PLAYER"] = "Дружественный игрок"
L["FRIENDLY_NPC"] = "Дружественный NPC"
L["ENEMY_PLAYER"] = "Вражеский игрок"
L["ENEMY_NPC"] = "Вражеский NPC"
L["Handles positioning and color."] = "Управляет позиционированием и цветом."
L["Selected Type"] = "Выбранный тип"
L["Reaction based coloring for non-cached characters."] = "Окраска на основе реакции для персонажей, не сохраненных в кэше."
L["Apply Custom Color"] = "Применить пользовательский цвет"
L["Class Color"] = "Цвет класса"
L["Use class colors."] = "Использовать цвета классов."
L["Unmark All"] = "Снять все отметки"
L["Unmark all plates."] = "Снимает отметки со всех неймплейтов."
L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"] =
	"Использование: макрос '/qmark', привязанный к клавише по вашему выбору.\n\nНе забудьте также отвязать ваши модификаторы клавиш!"
L["Use Backdrop"] = "Использовать фон"
L["Linked Style Filter Triggers"] = "Связанные триггеры фильтра стилей"
L["Select Link"] = "Выбрать ссылку"
L["New Link"] = "Новая ссылка"
L["Delete Link"] = "Удалить ссылку"
L["Target Filter"] = "Целевой фильтр"
L["Select a filter to trigger the styling."] = "Выберите фильтр для запуска стиля."
L["Apply Filter"] = "Применить фильтр"
L["Select a filter to style the frames not passing the target filter triggers."] = "Выберите фильтр для оформления кадров, не прошедших триггеры целевого фильтра."
L["Cache purged."] = "Кэш очищен."
L["Test Mode"] = "Тестовый режим"
L["Draws player cooldowns."] = "Отображает перезарядки игрока."
L["Show Everywhere"] = "Показывать везде"
L["Show in Cities"] = "Показывать в городах"
L["Show in Battlegrounds"] = "Показывать на полях боя"
L["Show in Arenas"] = "Показывать на аренах"
L["Show in Instances"] = "Показывать в подземельях"
L["Show in the World"] = "Показывать в мире"
L["Header"] = "Заголовок"
L["Icons"] = "Иконки"
L["OnUpdate Throttle"] = "Ограничение обновления"
L["Trinket First"] = "Аксессуар первым"
L["Animate Fade Out"] = "Анимация исчезновения"
L["Border Color"] = "Цвет границы"
L["Growth Direction"] = "Направление роста"
L["Sort Method"] = "Метод сортировки"
L["Icon Size"] = "Размер иконки"
L["Icon Spacing"] = "Расстояние между иконками"
L["Per Row"] = "В ряду"
L["Max Rows"] = "Максимум рядов"
L["CD Text"] = "Текст перезарядки"
L["Show"] = "Показать"
L["Cooldown Fill"] = "Заполнение перезарядки"
L["Reverse"] = "Обратный порядок"
L["Direction"] = "Направление"
L["Spells"] = "Заклинания"
L["Add Spell (by ID)"] = "Добавить заклинание (по ID)"
L["Remove Selected Spell"] = "Удалить выбранное заклинание"
L["Select Spell"] = "Выбрать заклинание"
L["Shadow"] = "Тень"
L["Pet Ability"] = "Способность питомца"
L["Shadow Size"] = "Размер тени"
L["Shadow Color"] = "Цвет тени"
L["Sets update speed threshold."] = "Устанавливает порог скорости обновления."
L["Makes PvP trinkets and human racial always get positioned first."] = "Размещает PvP аксессуары и расовую способность людей всегда первыми."
L["Makes icons flash when the cooldown's about to end."] = "Заставляет иконки мигать, когда перезарядка близка к завершению."
L["Any value apart from black (0,0,0) would override borders by time left."] = "Любое значение, кроме черного (0,0,0), переопределит границы по оставшемуся времени."
L["Colors borders by time left."] = "Окрашивает границы по оставшемуся времени."
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "Формат: 'ID заклинания время перезарядки', например 42292 120"
L["For the important stuff."] = "Для важных вещей."
L["Pet casts require some special treatment."] = "Заклинания питомцев требуют особого обращения."
L["Color by Type"] = "Цвет по типу"
L["Flip Icon"] = "Перевернуть иконку"
L["Texture List"] = "Список текстур"
L["Keep Icon"] = "Сохранить иконку"
L["Texture"] = "Текстура"
L["Texture Coordinates"] = "Координаты текстуры"
L["Select Affiliation"] = "Выбрать принадлежность"
L["Width"] = "Ширина"
L["Height"] = "Высота"
L["Select Class"] = "Выбрать класс"
L["Points"] = "Точки"
L["Colors the icon based on the unit type."] = "Окрашивает иконку в зависимости от типа юнита."
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "Переворачивает иконку по горизонтали. Несовместимо с координатами текстуры."
L["Keep the original icon texture."] = "Сохранить оригинальную текстуру иконки."
L["NPCs"] = "НИПы"
L["Players"] = "Игроки"
L["By duration, ascending."] = "По длительности, по возрастанию."
L["By duration, descending."] = "По длительности, по убыванию."
L["By time used, ascending."] = "По времени использования, по возрастанию."
L["By time used, descending."] = "По времени использования, по убыванию."
L["Additional settings for the Elite Icon."] = "Дополнительные настройки для значка элиты."
L["Player class icons."] = "Значки классов игроков."
L["Class Icons"] = "Значки классов"
L["Vector Class Icons"] = "Векторные значки классов"
L["Class Crests"] = "Гербы классов"
L["Floating Combat Feedback"] = "Плавающий боевой фидбэк"
L["Select Unit"] = "Выбрать юнита"
L["player"] = "игрок (player)"
L["target"] = "цель (target)"
L["targettarget"] = "цель цели (targettarget)"
L["targettargettarget"] = "цель цели цели (targettargettarget)"
L["focus"] = "фокус (focus)"
L["focustarget"] = "цель фокуса (focustarget)"
L["pet"] = "питомец (pet)"
L["pettarget"] = "цель питомца (pettarget)"
L["raid"] = "рейд (raid)"
L["raid40"] = "рейд 40 (raid40)"
L["raidpet"] = "питомец рейда (raidpet)"
L["party"] = "группа (party)"
L["partypet"] = "питомец группы (partypet)"
L["partytarget"] = "цель группы (partytarget)"
L["boss"] = "босс (boss)"
L["arena"] = "арена (arena)"
L["assist"] = "помощник (assist)"
L["assisttarget"] = "цель помощника (assisttarget)"
L["tank"] = "танк (tank)"
L["tanktarget"] = "цель танка (tanktarget)"
L["Scroll Time"] = "Время прокрутки"
L["Event Settings"] = "Настройки событий"
L["Event"] = "Событие"
L["Disable Event"] = "Отключить событие"
L["School"] = "Школа"
L["Use School Colors"] = "Использовать цвета школ"
L["Colors"] = "Цвета"
L["Color (School)"] = "Цвет (Школа)"
L["Animation Type"] = "Тип анимации"
L["Custom Animation"] = "Пользовательская анимация"
L["Flag Settings"] = "Настройки флага"
L["Flag"] = "Флаг"
L["Font Size Multiplier"] = "Множитель размера шрифта"
L["Animation by Flag"] = "Анимация по флагу"
L["Icon Settings"] = "Настройки значка"
L["Show Icon"] = "Показать значок"
L["Icon Position"] = "Позиция значка"
L["Bounce"] = "Отскок"
L["Blacklist"] = "Черный список"
L["Appends floating combat feedback fontstrings to frames."] = "Добавляет плавающие строки боевого фидбэка к фреймам."
L["There seems to be a font size limit?"] = "Похоже, есть ограничение на размер шрифта?"
L["Not every event is eligible for this. But some are."] = "Не каждое событие подходит для этого. Но некоторые подходят."
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "Определите вашу пользовательскую анимацию как функцию lua.\n\nПример:\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "Переключите, чтобы этот раздел обрабатывал анимации флагов вместо этого.\n\nНе у каждого события есть флаги."
L["Flip position left-right."] = "Переворот позиции слева направо."
L["E.g. 42292"] = "Например, 42292"
L["Loaded custom animation did not return a function."] = "Загруженная пользовательская анимация не вернула функцию."
L["Before Text"] = "Текст до"
L["After Text"] = "Текст после"
L["Remove Spell"] = "Удалить заклинание"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"Определите свою пользовательскую анимацию как функцию lua.\n\nПример:\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "ПОГЛОЩЕНИЕ"
L["BLOCK"] = "БЛОК"
L["CRITICAL"] = "КРИТИЧЕСКИЙ"
L["CRUSHING"] = "СОКРУШИТЕЛЬНЫЙ"
L["GLANCING"] = "СКОЛЬЗЯЩИЙ"
L["RESIST"] = "СОПРОТИВЛЕНИЕ"
L["Diagonal"] = "Диагональ"
L["Fountain"] = "Фонтан"
L["Horizontal"] = "Горизонталь"
L["Random"] = "Случайно"
L["Static"] = "Статично"
L["Vertical"] = "Вертикаль"
L["DEFLECT"] = "ОТКЛОНЕНИЕ"
L["DODGE"] = "УКЛОНЕНИЕ"
L["ENERGIZE"] = "ВОСПОЛНЕНИЕ"
L["EVADE"] = "ИЗБЕГАНИЕ"
L["HEAL"] = "ИСЦЕЛЕНИЕ"
L["IMMUNE"] = "НЕВОСПРИИМЧИВОСТЬ"
L["INTERRUPT"] = "ПРЕРЫВАНИЕ"
L["MISS"] = "ПРОМАХ"
L["PARRY"] = "ПАРИРОВАНИЕ"
L["REFLECT"] = "ОТРАЖЕНИЕ"
L["WOUND"] = "РАНЕНИЕ"
L["Debuff applied/faded/refreshed"] = "Дебафф применен/спал/обновлен"
L["Buff applied/faded/refreshed"] = "Бафф применен/спал/обновлен"
L["Physical"] = "Физический"
L["Holy"] = "Святой"
L["Fire"] = "Огонь"
L["Nature"] = "Природа"
L["Frost"] = "Лед"
L["Shadow"] = "Тьма"
L["Arcane"] = "Тайная магия"
L["Astral"] = "Астральный"
L["Chaos"] = "Хаос"
L["Elemental"] = "Стихийный"
L["Magic"] = "Магия"
L["Plague"] = "Чума"
L["Radiant"] = "Сияющий"
L["Shadowflame"] = "Теневое пламя"
L["Shadowfrost"] = "Теневой лед"
L["Up"] = "Вверх"
L["Down"] = "Вниз"
L["Classic Style"] = "Классический стиль"
L["If enabled, default cooldown style will be used."] = "Если включено, будет использоваться стиль перезарядки по умолчанию."
L["Classification Indicator"] = "Индикатор классификации"
L["Copy Unit Settings"] = "Копировать настройки юнита"
L["Enable Player Class Icons"] = "Включить иконки классов игроков"
L["Enable NPC Classification Icons"] = "Включить иконки классификации NPC"
L["Type"] = "Тип"
L["Select unit type."] = "Выберите тип юнита."
L["World Boss"] = "Мировой босс"
L["Elite"] = "Элитный"
L["Rare"] = "Редкий"
L["Rare Elite"] = "Редкий элитный"
L["Class Spec Icons"] = "Иконки специализаций классов"
L["Classification Textures"] = "Текстуры классификации"
L["Use Nameplates' Icons"] = "Использовать иконки намплейтов"
L["Color enemy NPC icon based on the unit type."] = "Окрашивать иконку вражеского NPC в зависимости от типа юнита."
L["Strata and Level"] = "Слой и уровень"
L["Warrior"] = "Воин"
L["Warlock"] = "Чернокнижник"
L["Priest"] = "Жрец"
L["Paladin"] = "Паладин"
L["Druid"] = "Друид"
L["Rogue"] = "Разбойник"
L["Mage"] = "Маг"
L["Hunter"] = "Охотник"
L["Shaman"] = "Шаман"
L["Deathknight"] = "Рыцарь смерти"
L["Aura Bars"] = "Полосы аур"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "Добавляет дополнительные параметры конфигурации для полос аур.\n\n Для таких опций, как размер и отсоединение, используйте Движки полос аур ElvUI!"
L["Hide"] = "Скрыть"
L["Spell Name"] = "Название заклинания"
L["Spell Time"] = "Время заклинания"
L["Bounce Icon Points"] = "Точки отскока иконки"
L["Set icon to the opposite side of the bar each new bar."] = "Устанавливать иконку на противоположной стороне каждой новой полосы."
L["Flip Starting Position"] = "Перевернуть начальную позицию"
L["0 to disable."] = "0 для отключения."
L["Detach All"] = "Отсоединить все"
L["Detach Power"] = "Отсоединить энергию"
L["Detaches power for the currently selected group."] = "Отсоединяет энергию для текущей выбранной группы."
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "Сокращает имена аналогично тому, как они сокращаются на индикаторах здоровья. Установите 'Позицию текста' в настройках имени на ЛЕВУЮ."
L["Anchor to Health"] = "Привязать к здоровью"
L["Adjusts the shortening based on the 'Health' text position."] = "Регулирует сокращение на основе позиции текста 'Здоровье'."
L["Name Auto-Shorten"] = "Автосокращение имени"
L["Appends a diminishing returns tracker to frames."] = "Добавляет трекер убывающей эффективности к фреймам."
L["DR Time"] = "Время DR"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "Время DR контролирует, сколько времени требуется для сброса иконок. Несколько факторов могут влиять на сброс DR. Если у вас постоянно возникают проблемы с точностью сброса DR, вы можете изменить это значение."
L["Test"] = "Тест"
L["Players Only"] = "Только игроки"
L["Ignore NPCs when setting up icons."] = "Игнорировать NPC при настройке иконок."
L["No Cooldown Numbers"] = "Без чисел перезарядки"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "Перейдите в 'Текст перезарядки' > 'Глобальные' для настройки."
L["Color Borders"] = "Цветные границы"
L["Spacing"] = "Интервал"
L["DR Strength Indicator: Text"] = "Индикатор силы DR: Текст"
L["DR Strength Indicator: Box"] = "Индикатор силы DR: Рамка"
L["Good"] = "Хорошо"
L["50% DR for hostiles, 100% DR for the player."] = "50% DR для врагов, 100% DR для игрока."
L["Neutral"] = "Нейтрально"
L["75% DR for all."] = "75% DR для всех."
L["Bad"] = "Плохо"
L["100% DR for hostiles, 50% DR for the player."] = "100% DR для врагов, 50% DR для игрока."
L["Category Border"] = "Граница категории"
L["Select Category"] = "Выбрать категорию"
L["Categories"] = "Категории"
L["Add Category"] = "Добавить категорию"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "Формат: 'категория IDЗаклинания', например, fear 10890.\nСписок всех категорий доступен в разделе 'цвета'."
L["Remove Category"] = "Удалить категорию"
L["Category \"%s\" already exists, updating icon."] = "Категория \"%s\" уже существует, обновление иконки."
L["Category \"%s\" added with %s icon."] = "Категория \"%s\" добавлена с иконкой %s."
L["Invalid category."] = "Недействительная категория."
L["Category \"%s\" removed."] = "Категория \"%s\" удалена."
L["DetachPower"] = "ОтсоединитьЭнергию"
L["NameAutoShorten"] = "АвтоСокращениеИмени"
L["Color Filter"] = "Цветовой фильтр"
L["Enables color filter for the selected unit."] = "Включает цветовой фильтр для выбранного юнита."
L["Toggle for the currently selected statusbar."] = "Переключить для текущей выбранной полосы состояния."
L["Select Statusbar"] = "Выбрать полосу состояния"
L["Health"] = "Здоровье"
L["Castbar"] = "Полоса заклинания"
L["Power"] = "Энергия"
L["Tab Section"] = "Раздел вкладок"
L["Toggle current tab."] = "Переключить текущую вкладку."
L["Tab Priority"] = "Приоритет вкладки"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "При выполнении нескольких условий будут применены цвета из вкладки с наивысшим приоритетом."
L["Copy Tab"] = "Копировать вкладку"
L["Select a tab to copy its settings onto the current tab."] = "Выберите вкладку, чтобы скопировать ее настройки на текущую вкладку."
L["Flash"] = "Вспышка"
L["Speed"] = "Скорость"
L["Glow"] = "Свечение"
L["Determines which glow to apply when statusbars are not detached from frame."] = "Определяет, какое свечение применять, когда полосы состояния не отсоединены от фрейма."
L["Priority"] = "Приоритет"
L["When handling castbar, also manage its icon."] = "При управлении полосой заклинания также управлять ее иконкой."
L["CastBar Icon Glow Color"] = "Цвет свечения иконки полосы заклинания"
L["CastBar Icon Glow Size"] = "Размер свечения иконки полосы заклинания"
L["Borders"] = "Границы"
L["CastBar Icon Color"] = "Цвет иконки полосы заклинания"
L["Toggle classbar borders."] = "Переключить границы полосы класса."
L["Toggle infopanel borders."] = "Переключить границы инфопанели."
L["ClassBar Color"] = "Цвет полосы класса"
L["Disabled unless classbar is enabled."] = "Отключено, если полоса класса не включена."
L["InfoPanel Color"] = "Цвет инфопанели"
L["Disabled unless infopanel is enabled."] = "Отключено, если инфопанель не включена."
L["ClassBar Adapt To"] = "Адаптировать полосу класса к"
L["Copies the color of the selected bar."] = "Копирует цвет выбранной полосы."
L["InfoPanel Adapt To"] = "Адаптировать инфопанель к"
L["Override Mode"] = "Режим переопределения"
L["'None' - threat borders highlight will be prioritized over this one".. "\n'Threat' - this highlight will be prioritized."] = "'Нет' - подсветка границ угрозы будет иметь приоритет над этой".. "\n'Угроза' - эта подсветка будет иметь приоритет."
L["Threat"] = "Угроза"
L["Determines which borders to apply when statusbars are not detached from frame."] = "Определяет, какие границы применять, когда полосы состояния не отсоединены от фрейма."
L["Bar-specific"] = "Специфично для полосы"
L["Lua Section"] = "Раздел Lua"
L["Conditions"] = "Условия"
L["Font Settings"] = "Настройки шрифта"
L["Player Only"] = "Только игрок"
L["Handle only player combat log events."] = "Обрабатывать только события журнала боя игрока."
L["Rotate Icon"] = "Повернуть иконку"
L["Usage example:"..
	"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
	"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
	"\n    return true, {mR = r, mG = g, mB = b}"..
	"\nelseif UnitIsUnit(unit, 'target') then"..
	"\n    return true"..
	"\nend"..
	"\n\n@@[raid, Health, 2, >5]@@ - returns true/false based on whether the tab in question "..
	"(in the example above: 'player' - target unit; 'Power' - target statusbar; '3' - target tab) is active or not"..
	"\n(>/>=/<=/</~= num) - (optional, group units only) match against a particular count of triggered frames within the group "..
	"(more than 5 in the example above)"..
	"\n\n'return true, {bR=1,f=false}' - you can dynamically color the frames by returning the colors in a table format:"..
	"\n  to apply to the statusbar, assign your rgb values to mR, mG and mB respectively"..
	"\n  to apply the glow - to gR, gG, gB, gA (alpha)"..
	"\n  for borders - bR, bG, bB"..
	"\n  and for the flash - fR, fG, fB, fA"..
	"\n  to prevent the elements styling, return {m = false, g = false, b = false, f = false}"..
	"\n\nFrame and unitID are available at 'frame' and 'unit' respectively: UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
	"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."] =
		"Пример использования:"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
			"\n    return true, {mR = r, mG = g, mB = b}"..
			"\nelseif UnitIsUnit(unit, 'target') then"..
			"\n    return true"..
			"\nend"..
			"\n\n@@[raid, Health, 2, >5]@@ - возвращает true/false в зависимости от того, активна ли рассматриваемая вкладка "..
			"(в приведенном выше примере: 'player' - целевая единица; 'Power' - целевая строка состояния; '3' - целевая вкладка) или нет"..
			"\n(>/>=/<=/</~= num) - (необязательно, только для групповых единиц) "..
			"соответствует определенному количеству активированных фреймов в группе (более 5 в приведенном выше примере)"..
			"\n\n'return true, {bR=1,f=false}' - вы можете динамически окрашивать фреймы, возвращая цвета в формате таблицы:"..
			"\n  чтобы применить к строке состояния, присвойте свои значения rgb соответственно mR, mG и mB"..
			"\n  чтобы применить свечение - gR, gG, gB, gA (альфа)"..
			"\n  для границ - bR, bG, bB"..
			"\n  и для вспышки - fR, fG, fB, fA"..
			"\n  чтобы предотвратить стилизацию элементов, верните {m = false, g = false, b = false, f = false}"..
			"\n\n'frame' и 'unit' доступны как 'frame' и 'unit' соответственно: UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
			"\n\nЭтот модуль анализирует строки, поэтому постарайтесь, чтобы ваш код строго следовал синтаксису, иначе он может не работать."
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "Wenn keine Modifier-Taste gedrückt wird, werden beim Überfahren von Einheiten keine Tooltips angezeigt.\nNur Mauszeiger-Tooltips."
L["Pick a..."] = "Выберите..."
L["...mover to anchor to."] = "...перемещаемый элемент для привязки."
L["...mover to anchor."] = "...перемещаемый элемент для привязки."
L["Point:"] = "Точка:"
L["Relative:"] = "Относительно:"
L["Open Editor"] = "Открыть редактор"
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "Если не удерживается модификатор, при наведении на юниты, предметы и заклинания, всплывающая подсказка не отображается.\nИзменяет только всплывающие подсказки курсора."
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "Закрепите все окна чата перед активацией.\nShift-клик на кнопке менеджера для доступа к настройкам вкладок."
L["Mouseover"] = "При наведении"
L["Manager button visibility."] = "Видимость кнопки менеджера."
L["Manager point."] = "Точка менеджера."
L["Top Offset"] = "Верхнее смещение"
L["Bottom Offset"] = "Нижнее смещение"
L["Left Offset"] = "Левое смещение"
L["Right Offset"] = "Правое смещение"
L["Chat Search and Filter"] = "Поиск и фильтр чата"
L["Search and filter utility for the chat frames."..
	"\n\nSynax:"..
	"\n  :: - 'and' statement"..
	"\n  ( ; ) - 'or' statement"..
	"\n  ! ! - 'not' statement"..
	"\n  [ ] - case sensitive"..
	"\n  @ @ - lua pattern"..
	"\n\nSample messages:"..
	"\n  1. [4][Bigguy]: lfg yo moms place"..
	"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
	"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
	"\n  4. [W][Noobkillaz]: delete game bro"..
	"\n  5. SYSTEM: You should buy gold at our website NOW!"..
	"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
	"\n\nSearch queries and results:"..
	"\n  yo - 1,2,3,5,6"..
	"\n  !yo! - 4"..
	"\n  !yo!::!delete! - empty"..
	"\n  [dElete];crab - 6"..
	"\n  (@LF%d*M@;lfg)::mom - 1,2"..
	"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
	"\n\nTab/Shift-Tab to navigate the prompts."..
	"\nRight-Click the search button to access recent queries."..
	"\nShift-Right-Click it to access the search config."..
	"\nAlt-Right-Click for the blocked messages."..
	"\nCtrl-Right-Click to purge filtered messages cache."..
	"\n\nChannel names and timestamps are not parsed."] =
		"Утилита поиска и фильтрации для окон чата."..
			"\n\nСинтаксис:"..
			"\n  :: - оператор 'и'"..
			"\n  ( ; ) - оператор 'или'"..
			"\n  ! ! - оператор 'не'"..
			"\n  [ ] - с учетом регистра"..
			"\n  @ @ - шаблон lua"..
			"\n\nПримеры сообщений:"..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\nЗапросы поиска и результаты:"..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - пусто"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\nTab/Shift-Tab для навигации по подсказкам."..
			"\nПравый клик на кнопке поиска для доступа к недавним запросам."..
			"\nShift-Правый клик для доступа к настройкам поиска."..
			"\nAlt-Правый клик для заблокированных сообщений."..
			"\nCtrl-Правый клик для очистки кэша отфильтрованных сообщений."..
			"\n\nИмена каналов и временные метки не анализируются."
L["Search button visibility."] = "Видимость кнопки поиска."
L["Search button point."] = "Точка кнопки поиска."
L["Config Tooltips"] = "Подсказки конфигурации"
L["Highlight Color"] = "Цвет выделения"
L["Match highlight color."] = "Цвет выделения совпадений."
L["Filter Type"] = "Тип фильтра"
L["Rule Terms"] = "Условия правила"
L["Same logic as with the search."] = "Та же логика, что и при поиске."
L["Select Chat Types"] = "Выбрать типы чата"
L["Say"] = "Сказать"
L["Yell"] = "Крикнуть"
L["Party"] = "Группа"
L["Raid"] = "Рейд"
L["Guild"] = "Гильдия"
L["Battleground"] = "Поле боя"
L["Whisper"] = "Шепот"
L["Channel"] = "Канал"
L["Other"] = "Другое"
L["Select Rule"] = "Выбрать правило"
L["Select Chat Frame"] = "Выбрать окно чата"
L["Add Rule"] = "Добавить правило"
L["Delete Rule"] = "Удалить правило"
L["Compact Chat"] = "Компактный чат"
L["Move left"] = "Переместить влево"
L["Move right"] = "Переместить вправо"
L["Mouseover: Left"] = "Наведение: Лево"
L["Mouseover: Right"] = "Наведение: Право"
L["Automatic Onset"] = "Автоматическое начало"
L["Scans tooltip texts and sets icons automatically."] = "Сканирует текст подсказок и автоматически устанавливает иконки."
L["Icon (Default)"] = "Иконка (По умолчанию)"
L["Icon (Kill)"] = "Иконка (Убийство)"
L["Icon (Chat)"] = "Иконка (Чат)"
L["Icon (Item)"] = "Иконка (Предмет)"
L["Show Text"] = "Показать текст"
L["Display progress status."] = "Отображать статус прогресса."
L["Name"] = "Имя"
L["Frequent Updates"] = "Частые обновления"
L["Events (optional)"] = "События (опционально)"
L["InternalCooldowns"] = "Внутренние перезарядки"
L["Displays internal cooldowns on trinket tooltips."] = "Отображает внутренние перезарядки на всплывающих подсказках аксессуаров."
L["Shortening X Offset"] = "Сокращение смещения X"
L["To Level"] = "До уровня"
L["Names will be shortened based on level text position."] = "Имена будут сокращены в зависимости от позиции текста уровня."
L["Add Item (by ID)"] = "Добавить предмет (по ID)"
L["Remove Item"] = "Удалить предмет"
L["Pre-Load"] = "Предзагрузка"
L["Executes commands during the addon's initialization process."] = "Выполняет команды во время процесса инициализации аддона."
L["Justify"] = "Выравнивание"
L["Alt-Click: free bag slots, if possible."] = "Alt-Клик: освободить слоты в сумке, если возможно."
L["Click: toggle layout mode."] = "Клик: переключить режим компоновки."
L["Alt-Click: re-evaluate all items."] = "Alt-Клик: переоценить все предметы."
L["Drag-and-Drop: evaluate and position the cursor item."] = "Перетащить: оценить и расположить предмет под курсором."
L["Shift-Alt-Click: toggle these hints."] = "Shift-Alt-Клик: включить/выключить эти подсказки."
L["Mouse-Wheel: navigate between special and normal bags."] = "Колесо мыши: переключение между специальными и обычными сумками."
L["This button accepts cursor item drops."] = "Эта кнопка принимает предметы, сброшенные с курсора."
L["Setup Sections"] = "Настройка разделов"
L["Adds default sections set to the currently selected container."] = "Добавляет разделы по умолчанию в выбранный контейнер."
L["Handles the automated repositioning of the newly received items."..
	"\nSyntax: filter@value\n\n"..
	"Available filters:\n"..
	" id@number - matches itemID,\n"..
	" name@string - matches name,\n"..
	" subtype@string - matches subtype,\n"..
	" ilvl@number - matches ilvl,\n"..
	" uselevel@number - matches equip level,\n"..
	" quality@number - matches quality,\n"..
	" equipslot@number - matches inventorySlotID,\n"..
	" maxstack@number - matches stack limit,\n"..
	" price@number - matches sell price,\n\n"..
	" tooltip@string - matches tooltip text,\n\n"..
	"All string matches are case-insensitive and match only alphanumeric symbols. Standard Lua logic applies. "..
	"Look up GetItemInfo API for more info on filters. "..
	"Use GetAuctionItemClasses and GetAuctionItemSubClasses (same as on the AH) to get the localized types and subtypes values.\n\n"..
	"Example usage (priest t8 or Shadowmourne):\n"..
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
	"Accepts custom functions (bagID, slotID, itemID are exposed)\n"..
	"The below one notifies of the newly acquired items.\n\n"..
	"local icon = GetContainerItemInfo(bagID, slotID)\n"..
	"local _, link = GetItemInfo(itemID)\n"..
	"icon = gsub(icon, '\\124', '\\124\\124')\n"..
	"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
	"print('Item received: ' .. string)"] =
		"Обрабатывает автоматическое размещение предметов.\n"..
			"Синтаксис: filter@value\n\n"..
			"Доступные фильтры:\n"..
			" id@number - соответствует itemID,\n"..
			" name@string - соответствует имени,\n"..
			" type@string - соответствует типу,\n"..
			" subtype@string - соответствует подтипу,\n"..
			" ilvl@number - соответствует уровню предмета,\n"..
			" uselevel@number - соответствует уровню использования,\n"..
			" quality@number - соответствует качеству,\n"..
			" equipslot@number - соответствует InventorySlotID,\n"..
			" maxstack@number - соответствует максимальному количеству в стопке,\n"..
			" price@number - соответствует цене продажи,\n"..
			" tooltip@string - соответствует тексту подсказки,\n"..
			" set@setName - соответствует предметам из набора экипировки.\n\n"..
			"Все строки не чувствительны к регистру и соответствуют только алфавитно-цифровым символам.\n"..
			"Применяются стандартные логические операторы Lua (and/or/скобки и т. д.).\n\n"..
			"Пример использования (жрец t8 или Shadowmourne):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
			"Поддерживаются пользовательские функции (bagID, slotID, itemID доступны).\n"..
			"Пример ниже уведомляет о новых полученных предметах.\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('Получен предмет: ' .. string)"
L["Syntax: filter@value@amount\n\n"..
	"Available filters:\n"..
	" id@number@amount(+)/+ - matches itemID,\n"..
	" name@string@amount(+)/+ - matches name,\n"..
	" type@string@amount(+)/+ - matches type,\n"..
	" subtype@string@amount(+)/+ - matches subtype,\n"..
	" ilvl@number@amount(+)/+ - matches ilvl,\n"..
	" uselevel@number@amount(+)/+ - matches equip level,\n"..
	" quality@number@amount(+)/+ - matches quality,\n"..
	" equipslot@number@amount(+)/+ - matches inventorySlotID,\n"..
	" maxstack@number@amount(+)/+ - matches stack limit,\n"..
	" price@number@amount(+)/+ - matches sell price,\n"..
	" tooltip@string@amount(+)/+ - matches tooltip text.\n\n"..
	"The optional 'amount' part could be:\n"..
	"  a number - to purchase a static amount,\n"..
	"  a + sign - to replenish the existing partial stack or purchase a new one,\n"..
	"  both (e.g. 5+) - to purchase enough items to reach a specified total (in this case, 5),\n"..
	"  ommited - defaults to 1.\n\n"..
	"All string matches are case-insensitive and match only alphanumeric symbols.\n"..
	"Standard Lua logic for branching (and/or/parenthesis/etc.) applies.\n\n"..
	"Example usage (priest t8 or Shadowmourne):\n"..
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."] =
		"Синтаксис: filter@value@amount\n\n"..
			"Доступные фильтры:\n"..
			" id@number@amount(+)/+ - соответствует itemID,\n"..
			" name@string@amount(+)/+ - соответствует имени,\n"..
			" type@string@amount(+)/+ - соответствует типу,\n"..
			" subtype@string@amount(+)/+ - соответствует подтипу,\n"..
			" ilvl@number@amount(+)/+ - соответствует уровню предмета,\n"..
			" uselevel@number@amount(+)/+ - соответствует уровню использования,\n"..
			" quality@number@amount(+)/+ - соответствует качеству,\n"..
			" equipslot@number@amount(+)/+ - соответствует InventorySlotID,\n"..
			" maxstack@number@amount(+)/+ - соответствует максимальному количеству в стопке,\n"..
			" price@number@amount(+)/+ - соответствует цене продажи,\n"..
			" tooltip@string@amount(+)/+ - соответствует тексту подсказки.\n\n"..
			"Опциональная часть 'amount':\n"..
			" число - покупка фиксированного количества,\n"..
			" знак + - пополнение текущей частичной стопки или покупка новой,\n"..
			" оба (например, 5+) - покупка достаточного количества, чтобы достичь заданного количества (в этом случае 5),\n"..
			" пропущено - по умолчанию 1.\n\n"..
			"Все строки не чувствительны к регистру и соответствуют только алфавитно-цифровым символам.\n"..
			"Применяются стандартные логические операторы Lua (and/or/скобки и т. д.).\n\n"..
			"Пример использования (жрец t8 или Shadowmourne):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["PERIODIC"] = "ПЕРИОДИЧЕСКИ"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "Удерживайте эту клавишу, используя команду /addOccupation, чтобы очистить список текущей цели/подсвеченного NPC."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "Используйте команду /addOccupation, наводя курсор на NPC или выбирая его как цель, чтобы добавить в список. Повторное использование для переключения."
L["Style Filter Icons"] = "Иконки фильтра стилей"
L["Custom icons for the style filter."] = "Пользовательские иконки для фильтра стилей."
L["Whitelist"] = "Белый список"
L["X Direction"] = "X направление"
L["Y Direction"] = "Y направление"
L["Create Icon"] = "Создать значок"
L["Delete Icon"] = "Удалить значок"
L["0 to match frame width."] = "0 для соответствия ширине рамки."
L["Remove a NPC"] = "Удалить NPC"
L["Change a NPC's Occupation"] = "Изменить профессию NPC"
L["...to the currently selected one."] = "...на текущий выбранный."
L["Select Occupation"] = "Выбрать профессию"
L["Sell"] = "Продать"
L["Action Type"] = "Тип действия"
