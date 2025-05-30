local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "zhTW")

L["Hits the 'Confirm' button automatically."] = "自動點擊'確認'按鈕。"
L["Picks up items and money automatically."] = "自動拾取物品和金錢。"
L["Automatically fills the 'DELETE' field."] = "自動填寫'刪除'欄位。"
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "如果只有一個對話選項可用，則自動選擇第一個選項，除非按住修飾鍵。\n對於重要的事件觸發要小心，沒有故障保護機制。"
L["Accepts and turns in quests automatically while holding a modifier."] = "按住修飾鍵時自動接受和提交任務。"
L["Loot info wiped."] = "拾取資訊已清除。"
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "/lootinfo 命令以快速查看最近的戰利品。\n\n用法: /lootinfo 蘋果 60\n'蘋果' - 物品/玩家名稱 \n(搜尋 @self 以獲取玩家的戰利品)\n'60' - \n時間限制（<60秒前），可選，\n/lootinfo !wipe - 清除戰利品快取。"
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "在某些訊息中為線上好友和公會成員的名字著色，並為擲骰添加樣式。\n已處理的聊天氣泡在你使用 /reload 之前不會被重新設置樣式。"
L["Colors loot roll messages for you and other players."] = "為你和其他玩家的拾取擲骰訊息著色。"
L["Loot rolls icon size."] = "拾取擲骰圖示大小。"
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "重新設置拾取條樣式。\n需要啟用'拾取擲骰'（一般 -> BlizzUI改進 -> 拾取擲骰）（切換此模組會自動啟用它）。"
L["Displays the name of the player pinging the minimap."] = "顯示在小地圖上發出標記的玩家名稱。"
L["Displays the currently held currency amount next to the item prices."] = "在物品價格旁顯示當前持有的貨幣數量。"
L["Narrows down the World(..Frame)."] = "縮小World(..Frame)。"
L["'Out of mana', 'Ability is not ready yet', etc."] = "'法力不足'，'技能尚未就緒'等。"
L["Re-enable quest updates."] = "重新啟用任務更新。"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "除非按住修飾鍵，否則懸停在單位上不會顯示提示框。\n僅顯示滑鼠指針提示。"
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - 暴雪的黃色。"
L["Text to display upon entering combat."] = "進入戰鬥時顯示的文字。"
L["Text to display upon leaving combat."] = "離開戰鬥時顯示的文字。"
L["REQUIRES RELOAD."] = "需要重新加載。"
L["Icon to the left or right of the item link."] = "物品鏈接的左側或右側的圖標。"
L["The size of the icon in the chat frame."] = "聊天框中的圖標大小。"
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "為所有框架添加陰影。\n除非您用此插件的Optionals文件夾中的相關文件替換您的ElvUI/Core/Toolkit.lua，否則無效。"
L["Combat state notification alerts."] = "戰鬥狀態通知警報。"
L["Custom editbox position and size."] = "自訂編輯框位置和大小。"
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
		 "用法："..
			"\n/tnote list - 返回所有現有的註釋"..
			"\n/tnote wipe - 清除所有現有的註釋"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - 與set相同（除了lua部分）"..
			"\n/tnote 1 get - 與set相同，返回現有的註釋"..
			"\n/tnote 1 set 您的註釋在這裡 - 將註釋添加到指定的列表索引 "..
			"或者如果省略第二個參數（在這種情況下為1），則添加到當前顯示的工具提示文本， "..
			"支持函數和著色 "..
			"（不提供文本則清除註釋）;"..
			"\n要換行，請使用 ::"..
			"\n\n示例："..
			"\n\n/tnote 3 set 火焰 前最佳::來源：王大明"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(預設顏色)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "在聊天超連結旁添加一個圖標。"
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "一個新的動作條，用於收集背包中可用的任務物品。\n\n由於狀態動作限制，該模組會覆蓋ElvUI額外動作條創建的bar10。"
L["Toggles the display of the actionbar's backdrop."] = "切換動作條背景的顯示。"
L["The frame will not be displayed unless hovered over."] = "除非滑鼠懸停，否則框架不會顯示。"
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "繼承全局淡出效果，滑鼠懸停、選擇目標、設置焦點、失去生命值、進入戰鬥將移除透明度。否則，它將使用一般動作條設置中的透明度級別作為全局淡出的透明度。"
L["The first button anchors itself to this point on the bar."] = "第一個按鈕固定在動作條上的這個點。"
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "按住修飾鍵的同時右鍵點擊物品將其加入黑名單。黑名單中的物品不會在動作條上顯示。\n使用 /questbarRestore 清除黑名單。"
L["The number of buttons to display."] = "要顯示的按鈕數量。"
L["The number of buttons to display per row."] = "每行顯示的按鈕數量。"
L["The size of the action buttons."] = "動作按鈕的大小。"
L["Spacing between the buttons."] = "按鈕之間的間距。"
L["Spacing between the backdrop and the buttons."] = "背景和按鈕之間的間距。"
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "將背景的高度或寬度乘以此值。如果你希望在一個背景後面有多個動作條，這很有用。"
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "這就像一個巨集，你可以運行不同的情況來讓動作條以不同方式顯示/隱藏。\n 例如：'[combat] showhide'"
L["Adds anchoring options to the movers' nudges."] = "為移動器的微調添加錨點選項。"
L["Mod-clicking an item suggests a skill/item to process it."] = "按住 Mod 鍵點擊物品會建議處理該物品的技能/物品。"
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"按住%s的同時左鍵點擊堆疊可將其分為兩半；要合併可用副本，請右鍵點擊。\n\n還修改了SplitStackFrame，使用編輯框而不是箭頭。"
L["Extends the bags functionality."] = "擴展背包功能。"
L["Default method: type > inventory slot ID > item level > name."] = "預設方法：類型 > 背包欄位ID > 物品等級 > 名稱。"
L["Listed ItemIDs will not get sorted."] = "列出的物品ID不會被排序。"
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "例如：Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "無效的條件格式："
L["The generated custom sorting method did not return a function."] = "生成的自定義排序方法未返回函數。"
L["The loaded custom sorting method did not return a function."] = "載入的自定義排序方法未返回函數。"
L["Item received: "] = "收到物品："
L[" added."] = " 已添加。"
L[" removed."] = " 已移除。"
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
		"處理新獲得物品的自動重新定位。"..
		"\n語法: 過濾器@值\n\n"..
		"可用過濾器:\n"..
		" id@數字 - 匹配物品ID,\n"..
		" name@字串 - 匹配名稱,\n"..
		" subtype@字串 - 匹配子類型,\n"..
		" ilvl@數字 - 匹配物品等級,\n"..
		" uselevel@數字 - 匹配裝備等級,\n"..
		" quality@數字 - 匹配品質,\n"..
		" equipslot@數字 - 匹配庫存欄位ID,\n"..
		" maxstack@數字 - 匹配堆疊上限,\n"..
		" price@數字 - 匹配售價,\n\n"..
		" tooltip@字串 - 匹配提示文字,\n\n"..
		"所有字串匹配不區分大小寫，僅匹配字母數字符號。適用標準lua邏輯。"..
		"查看GetItemInfo API以獲取更多關於過濾器的資訊。"..
		"使用GetAuctionItemClasses和GetAuctionItemSubClasses（與拍賣行相同）獲取本地化的類型和子類型值。\n\n"..
		"使用示例（牧師T8或暗影之殤）:\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@布甲 and name@聖化) or name@暗影之殤.\n\n"..
		"接受自定義函數（bagID, slotID, itemID可用）\n"..
		"以下函數通知新獲得的物品。\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\124', '\124\124')\n"..
		"local string = '\124T' .. icon .. ':16:16\124t' .. link\n"..
		"print('獲得物品: ' .. string)"
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
		"語法：過濾器@值\n\n"..
			"可用過濾器：\n"..
			" id@數字 - 匹配物品ID，\n"..
			" name@字串 - 匹配名稱，\n"..
			" type@字串 - 匹配類型，\n"..
			" subtype@字串 - 匹配子類型，\n"..
			" ilvl@數字 - 匹配物品等級，\n"..
			" uselevel@數字 - 匹配裝備等級，\n"..
			" quality@數字 - 匹配品質，\n"..
			" equipslot@數字 - 匹配背包欄位ID，\n"..
			" maxstack@數字 - 匹配堆疊上限，\n"..
			" price@數字 - 匹配售價，\n"..
			" tooltip@字串 - 匹配提示文字。\n\n"..
			"所有字串匹配不區分大小寫，且僅匹配字母數字符號。\n"..
			"適用標準lua分支邏輯（和/或/括號等）。\n\n"..
			"使用範例（牧師t8或暗影之悲）：\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "可用物品類型"
L["Lists all available item subtypes for each available item type."] =
	"列出每個可用物品類型的所有可用物品子類型。"
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"與商人互動時按住此鍵會購買所有符合自動購買設定的物品。\n"..
			"在購買清單條目上進行模組點擊，即可無視'@數量'規則，只購買一件符合條件的物品。"
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] =
		"預設方法: 類型 > 庫存欄位ID > 物品等級 > 名稱。\n\n"..
		"接受自定義函數（a/b.bagID/slotID可用）。\n\n"..
		"function(a,b)\n"..
		"--在此處添加您的排序邏輯\n"..
		"end\n\n"..
		"留空則使用預設設置。"
L["Event and OnUpdate handler."] = "事件和OnUpdate處理程序。"
L["Minimal time gap between two consecutive executions."] = "兩次連續執行之間的最小時間間隔。"
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER 等。\nONUPDATE - 'OnUpdate' 腳本"
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = "UNIT_AURA CHAT_MSG_WHISPER 等。"
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
		"語法:"..
		"\n\nEVENT[n~=nil]"..
		"\n[n~=value]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@commands@@@"..
		"\n\n'EVENT' - 上面事件部分中的事件"..
		"\n'n, m, k' - 所需有效載荷參數的索引（數字）"..
		"\n'nil/value/boolean/lua代碼' - n參數的期望輸出"..
		"\n'@@' - lua參數標誌，必須在參數值部分的lua代碼前使用"..
		"\n'~' - 否定標誌，在等號前添加，如果n/m/k不匹配設定值則執行代碼"..
		"\n'@@@ @@@' - 包含命令的括號。"..
		"\n你可以像往常一樣訪問有效載荷（...）。"..
		"\n\n示例:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(玩家獲得/失去了一個光環)@@@"..
		"\n\nCHAT_MSG_WHISPER"..
		"\n[5~=@@UnitName('player')]"..
		"\n[14=false]@@@"..
		"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
		"\n\nCOMBAT_LOG_EVENT_"..
		"\nUNFILTERED"..
		"\n[5=@@UnitName('arena1')]"..
		"\n[5=@@UnitName('arena2')]@@@"..
		"\nfor i = 1, 2 do"..
		"\nif UnitDebuff('party'..i, '不良法術')"..
		"\nthen print(UnitName('party'..i)..'受到了影響！')"..
		"\nend end@@@"..
		"\n\n此模組解析字符串，所以盡量嚴格遵循語法，否則可能無法正常工作。"
L["Highlights auras."] = "突出顯示光環。"
L["E.g. 42292"] = "例如 42292"
L["Applies highlights to all auras passing the selected filter."] = "突出顯示所有通過選擇過濾器的光環。"
L["Priority: spell, filter, curable/stealable."] = "優先級：法術、過濾器、可治療/可偷竊。"
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "如果切換，將使用全局法術或過濾器條目值。"
L["Makes auras grow sideswise."] = "使光環向兩側擴展。"
L["Turns off texture fill."] = "關閉紋理填充。"
L["Makes auras flicker right before fading out."] = "使光環在淡出之前閃爍。"
L["Disables border coloring."] = "禁用邊框著色。"
L["Click Cancel"] = "點擊取消"
L["Right-click a player buff to cancel it."] = "右鍵點擊玩家的增益效果以取消。"
L["Disables debuffs desaturation."] = "禁用減少 debuff 飽和度。"
L["Saturated Debuffs"] = "飽和 debuffs"
L["Confirm Rolls"] = "確認擲骰"
L["Auto Pickup"] = "自動拾取"
L["Swift Buy"] = "快速購買"
L["Buys out items automatically."] = "自動購買物品。"
L["Failsafe"] = "故障保護"
L["Enables popup confirmation dialog."] = "啟用彈出確認對話框。"
L["Add Set"] = "新增套裝"
L["Delete Set"] = "刪除套裝"
L["Select Set"] = "選擇套裝"
L["Auto Buy"] = "自動購買"
L["Fill Delete"] = "填寫刪除"
L["Gossip"] = "對話"
L["Accept Quest"] = "接受任務"
L["Loot Info"] = "拾取信息"
L["Styled Messages"] = "樣式化訊息"
L["Indicator Color"] = "指示器顏色"
L["Select Status"] = "選擇狀態"
L["Select Indicator"] = "選擇指示器"
L["Styled Loot Messages"] = "樣式化拾取訊息"
L["Icon Size"] = "圖示大小"
L["Loot Bars"] = "拾取條"
L["Bar Height"] = "條高"
L["Bar Width"] = "條寬"
L["Player Pings"] = "玩家標記"
L["Held Currency"] = "持有貨幣"
L["LetterBox"] = "信箱"
L["Left"] = "左"
L["Right"] = "右"
L["Top"] = "上"
L["Bottom"] = "下"
L["Hide Errors"] = "隱藏錯誤"
L["Show quest updates"] = "顯示任務更新"
L["Less Tooltips"] = "減少提示"
L["Misc."] = "雜項"
L["Loot&Style"] = "拾取與樣式"
L["Automation"] = "自動化"
L["Bags"] = "背包"
L["Easier Processing"] = "簡化處理"
L["Modifier"] = "修飾鍵"
L["Split Stack"] = "分割堆疊"
L["Bags Extended"] = "擴展背包"
L["Select Container Type"] = "選擇容器類型"
L["Settings"] = "設置"
L["Add Section"] = "添加部分"
L["Delete Section"] = "刪除部分"
L["Select Section"] = "選擇部分"
L["Section Priority"] = "部分優先級"
L["Section Spacing"] = "部分間距"
L["Collection Method"] = "收集方法"
L["Sorting Method"] = "排序方法"
L["Ignore Item (by ID)"] = "忽略物品（按ID）"
L["Remove Ignored"] = "移除已忽略"
L["Title"] = "標題"
L["Color"] = "顏色"
L["Attach to Icon"] = "附加到圖示"
L["Text"] = "文字"
L["Font Size"] = "字體大小"
L["Font"] = "字體"
L["Font Flags"] = "字體標記"
L["Point"] = "錨點"
L["Relative Point"] = "相對錨點"
L["X Offset"] = "X偏移"
L["Y Offset"] = "Y偏移"
L["Icon"] = "圖示"
L["Attach to Text"] = "附加到文字"
L["Texture"] = "材質"
L["Size"] = "大小"
L["MoversPlus"] = "移動增強"
L["Movers Plus"] = "移動增強"
L["CustomCommands"] = "自定義命令"
L["Custom Commands"] = "自定義命令"
L["QuestBar"] = "任務欄"
L["Quest Bar"] = "任務欄"
L["Settings"] = "設置"
L["Backdrop"] = "背景"
L["Show Empty Buttons"] = "顯示空按鈕"
L["Mouse Over"] = "滑鼠懸停"
L["Inherit Global Fade"] = "繼承全局淡出"
L["Anchor Point"] = "錨點"
L["Modifier"] = "修飾鍵"
L["Buttons"] = "按鈕"
L["Buttons Per Row"] = "每行按鈕數"
L["Button Size"] = "按鈕大小"
L["Button Spacing"] = "按鈕間距"
L["Backdrop Spacing"] = "背景間距"
L["Height Multiplier"] = "高度倍數"
L["Width Multiplier"] = "寬度倍數"
L["Alpha"] = "透明度"
L["Visibility State"] = "可見狀態"
L["Enable Tab"] = "啟用標籤"
L["Throttle Time"] = "限制時間"
L["Select Tab"] = "選擇標籤"
L["Select Event"] = "選擇事件"
L["Rename Tab"] = "重命名標籤"
L["Add Tab"] = "添加標籤"
L["Delete Tab"] = "刪除標籤"
L["Open Edit Frame"] = "打開編輯框架"
L["Events"] = "事件"
L["Commands to execute"] = "要執行的命令"
L["Sub-Section"] = "子部分"
L["Select"] = "選擇"
L["Icon Orientation"] = "圖示方向"
L["Icon Size"] = "圖示大小"
L["Height Offset"] = "高度偏移"
L["Width Offset"] = "寬度偏移"
L["Text Color"] = "文字顏色"
L["Entering combat"] = "進入戰鬥"
L["Leaving combat"] = "離開戰鬥"
L["Font"] = "字體"
L["Font Outline"] = "字體輪廓"
L["Font Size"] = "字體大小"
L["Texture Width"] = "紋理寬度"
L["Texture Height"] = "紋理高度"
L["Custom Texture"] = "自定義紋理"
L["ItemIcons"] = "物品圖標"
L["TooltipNotes"] = "工具提示"
L["ChatEditBox"] = "聊天編輯框"
L["EnterCombatAlert"] = "進入戰鬥警告"
L["GlobalShadow"] = "全局陰影"
L["Any"] = "任何"
L["Guildmate"] = "公會成員"
L["Friend"] = "朋友"
L["Self"] = "玩家"
L["New Tab"] = "新標籤"
L["None"] = "無"
L["Version: "] = "版本:"
L["Color A"] = "顏色A"
L["Chat messages, etc."] = "聊天訊息等。"
L["Color B"] = "顏色B"
L["Plugin Color"] = "插件顏色"
L["Icons Browser"] = "圖示瀏覽器"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "請參閱 https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html 以獲取更乾淨、裁剪過的圖示。"
L["Add Texture"] = "添加材質"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "將材質添加到通用材質列表中。\n例如:Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "移除材質"
L["Highlights"] = "重點"
L["Select Type"] = "選擇類型"
L["Highlights Settings"] = "重點設置"
L["Add Filter"] = "添加過濾器"
L["Remove Selected"] = "移除選擇"
L["Select Spell or Filter"] = "選擇法術或過濾器"
L["Use Global Settings"] = "使用全局設置"
L["Selected Spell or Filter Values"] = "選擇的法術或過濾器值"
L["Enable Shadow"] = "啟用陰影"
L["Size"] = "大小"
L["Shadow Color"] = "陰影顏色"
L["Enable Border"] = "啟用邊框"
L["Border Color"] = "邊框顏色"
L["Centered Auras"] = "居中光環"
L["Cooldown Disable"] = "禁用冷卻"
L["Animate Fade-Out"] = "動畫淡出"
L["Type Borders"] = "類型邊框"
L[" filter added."] = "過濾器已添加。"
L[" filter removed."] = "過濾器已移除。"
L["GLOBAL"] = "全局"
L["CURABLE"] = "可治療"
L["STEALABLE"] = "可偷竊"
L["--Filters--"] = "--過濾器--"
L["--Spells--"] = "--法術--"
L["FRIENDLY"] = "友善"
L["ENEMY"] = "敵人"
L["AuraBars"] = "光環條"
L["Auras"] = "光環"
L["ClassificationIndicator"] = "分類指示器"
L["ClassificationIcons"] = "分類圖示"
L["ColorFilter"] = "顏色過濾器"
L["Cooldowns"] = "冷卻時間"
L["DRTracker"] = "DR追蹤器"
L["Guilds&Titles"] = "公會與頭銜"
L["Name&Level"] = "名字與等級"
L["QuestIcons"] = "任務圖示"
L["StyleFilter"] = "樣式過濾器"
L["Search:"] = "搜尋:"
L["Click to select."] = "點擊以選擇。"
L["Click to select."] = "點擊以選擇。"
L["Hover again to see the changes."] = "再次懸停以查看更改。"
L["Note set for "] = "為以下對象設置註記："
L["Note cleared for "] = "為以下對象清除註記："
L["No note to clear for "] = "沒有註記可清除："
L["Added icon to the note for "] = "為以下對象的註記添加圖標："
L["Note icon cleared for "] = "為以下對象清除註記圖標："
L["No note icon to clear for "] = "沒有註記圖標可清除："
L["Current note for "] = "當前註記："
L["No note found for this tooltip."] = "未找到此工具提示的註記。"
L["Notes: "] = "註記："
L["No notes are set."] = "未設置任何註記。"
L["No tooltip is currently shown or unsupported tooltip type."] = "當前未顯示工具提示或不支援的工具提示類型。"
L["All notes have been cleared."] = "所有註記已清除。"
L["Accept"] = "接受"
L["Cancel"] = "取消"
L["Purge Cache"] = "清除快取"
L["Guilds"] = "公會"
L["Separator"] = "分隔符"
L["X Offset"] = "X偏移"
L["Y Offset"] = "Y偏移"
L["Level"] = "等級"
L["Visibility State"] = "可見性狀態"
L["City (Resting)"] = "城市（休息）"
L["PvP"] = "PvP"
L["Arena"] = "競技場"
L["Party"] = "隊伍"
L["Raid"] = "團隊"
L["Colors"] = "顏色"
L["Guild"] = "公會"
L["All"] = "全部"
L["Occupation Icon"] = "職業圖標"
L["OccupationIcon"] = "職業圖標"
L["Size"] = "尺寸"
L["Anchor"] = "錨點"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "移除職業"
L["Modifier"] = "修飾鍵"
L["Add Texture Path"] = "添加材質路徑"
L["Remove Selected Texture"] = "移除所選材質"
L["Titles"] = "頭銜"
L["Reaction Color"] = "反應顏色"
L["Color based on reaction type."] = "根據反應類型著色。"
L["Nameplates"] = "名條"
L["Unitframes"] = "單位框架"
L["An icon similar to the minimap search."] = "類似於小地圖搜索的圖標。"
L["Displays player guild text."] = "顯示玩家的公會文本。"
L["Displays NPC occupation text."] = "顯示NPC的職業文本。"
L["Strata"] = "層級"
L["Mark"] = "標記"
L["Mark the target/mouseover plate."] = "標記目標/滑鼠懸停的姓名板。"
L["Unmark"] = "取消標記"
L["Unmark the target/mouseover plate."] = "取消標記目標/滑鼠懸停的姓名板。"
L["Selected Type"] = "選擇的類型"
L["Reaction based coloring for non-cached characters."] = "基於反應的非緩存角色的著色。"
L["Apply Custom Color"] = "應用自定義顏色"
L["Class Color"] = "職業顏色"
L["Use class colors."] = "使用職業顏色。"
L["Unmark All"] = "取消所有標記"
L["Unmark all plates."] = "取消所有姓名板的標記。"
L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"] =
	"用法：將 '/qmark' 宏綁定到您選擇的按鍵。\n\n不要忘記解除您的修飾鍵綁定！"
L["Use Backdrop"] = "使用背景"
L["Linked Style Filter Triggers"] = "連結的樣式過濾器觸發器"
L["Select Link"] = "選擇連結"
L["New Link"] = "新連結"
L["Delete Link"] = "刪除連結"
L["Target Filter"] = "目標過濾器"
L["Select a filter to trigger the styling."] = "選擇一個過濾器來觸發樣式。"
L["Apply Filter"] = "應用過濾器"
L["Select a filter to style the frames not passing the target filter triggers."] = "選擇一個過濾器來樣式化未通過目標過濾器觸發的框架。"
L["Cache purged."] = "快取已清除。"
L["Test Mode"] = "測試模式"
L["Draws player cooldowns."] = "顯示玩家冷卻時間。"
L["Show Everywhere"] = "在所有地方顯示"
L["Show in Cities"] = "在城市中顯示"
L["Show in Battlegrounds"] = "在戰場中顯示"
L["Show in Arenas"] = "在競技場中顯示"
L["Show in Instances"] = "在副本中顯示"
L["Show in the World"] = "在世界中顯示"
L["Header"] = "標題"
L["Icons"] = "圖示"
L["OnUpdate Throttle"] = "更新節流"
L["Trinket First"] = "飾品優先"
L["Animate Fade Out"] = "淡出動畫"
L["Border Color"] = "邊框顏色"
L["Growth Direction"] = "成長方向"
L["Sort Method"] = "排序方法"
L["Icon Size"] = "圖示大小"
L["Icon Spacing"] = "圖示間距"
L["Per Row"] = "每行"
L["Max Rows"] = "最大行數"
L["CD Text"] = "冷卻文字"
L["Show"] = "顯示"
L["Cooldown Fill"] = "冷卻填充"
L["Reverse"] = "反向"
L["Direction"] = "方向"
L["Spells"] = "法術"
L["Add Spell (by ID)"] = "添加法術（按ID）"
L["Remove Selected Spell"] = "移除選定的法術"
L["Select Spell"] = "選擇法術"
L["Shadow"] = "陰影"
L["Pet Ability"] = "寵物技能"
L["Shadow Size"] = "陰影大小"
L["Shadow Color"] = "陰影顏色"
L["Sets update speed threshold."] = "設置更新速度閾值。"
L["Makes PvP trinkets and human racial always get positioned first."] = "使PvP飾品和人類種族特長始終排在首位。"
L["Makes icons flash when the cooldown's about to end."] = "當冷卻即將結束時使圖示閃爍。"
L["Any value apart from black (0,0,0) would override borders by time left."] = "除黑色(0,0,0)以外的任何值都會根據剩餘時間覆蓋邊框。"
L["Colors borders by time left."] = "根據剩餘時間為邊框著色。"
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "格式：'法術ID 冷卻時間'，例如 42292 120"
L["For the important stuff."] = "用於重要的事物。"
L["Pet casts require some special treatment."] = "寵物施法需要一些特殊處理。"
L["Color by Type"] = "按類型著色"
L["Flip Icon"] = "翻轉圖示"
L["Texture List"] = "材質列表"
L["Keep Icon"] = "保留圖示"
L["Texture"] = "材質"
L["Texture Coordinates"] = "材質座標"
L["Select Affiliation"] = "選擇陣營"
L["Width"] = "寬度"
L["Height"] = "高度"
L["Select Class"] = "選擇職業"
L["Points"] = "點數"
L["Colors the icon based on the unit type."] = "根據單位類型為圖示著色。"
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "水平翻轉圖示。不相容於材質座標。"
L["Keep the original icon texture."] = "保留原始圖示材質。"
L["NPCs"] = "NPC"
L["Players"] = "玩家"
L["By duration, ascending."] = "按持續時間，升序。"
L["By duration, descending."] = "按持續時間，降序。"
L["By time used, ascending."] = "按使用時間，升序。"
L["By time used, descending."] = "按使用時間，降序。"
L["Additional settings for the Elite Icon."] = "精英圖示的額外設定。"
L["Player class icons."] = "玩家職業圖示。"
L["Class Icons"] = "職業圖示"
L["Vector Class Icons"] = "向量職業圖示"
L["Class Crests"] = "職業徽章"
L["Floating Combat Feedback"] = "浮動戰鬥回饋"
L["Select Unit"] = "選擇單位"
L["player"] = "玩家 (player)"
L["target"] = "目標 (target)"
L["targettarget"] = "目標的目標 (targettarget)"
L["targettargettarget"] = "目標的目標的目標 (targettargettarget)"
L["focus"] = "焦點 (focus)"
L["focustarget"] = "焦點目標 (focustarget)"
L["pet"] = "寵物 (pet)"
L["pettarget"] = "寵物目標 (pettarget)"
L["raid"] = "團隊 (raid)"
L["raid40"] = "40人團隊 (raid40)"
L["raidpet"] = "團隊寵物 (raidpet)"
L["party"] = "小隊 (party)"
L["partypet"] = "小隊寵物 (partypet)"
L["partytarget"] = "小隊目標 (partytarget)"
L["boss"] = "首領 (boss)"
L["arena"] = "競技場 (arena)"
L["assist"] = "協助 (assist)"
L["assisttarget"] = "協助目標 (assisttarget)"
L["tank"] = "坦克 (tank)"
L["tanktarget"] = "坦克目標 (tanktarget)"
L["Scroll Time"] = "滾動時間"
L["Event Settings"] = "事件設定"
L["Event"] = "事件"
L["Disable Event"] = "禁用事件"
L["School"] = "學派"
L["Use School Colors"] = "使用學派顏色"
L["Colors"] = "顏色"
L["Color (School)"] = "顏色（系別）"
L["Animation Type"] = "動畫類型"
L["Custom Animation"] = "自定義動畫"
L["Flag Settings"] = "標誌設定"
L["Flag"] = "標誌"
L["Font Size Multiplier"] = "字體大小倍數"
L["Animation by Flag"] = "按標誌動畫"
L["Icon Settings"] = "圖示設定"
L["Show Icon"] = "顯示圖示"
L["Icon Position"] = "圖示位置"
L["Bounce"] = "彈跳"
L["Blacklist"] = "黑名單"
L["Appends floating combat feedback fontstrings to frames."] = "將浮動戰鬥回饋字串附加到框架。"
L["There seems to be a font size limit?"] = "似乎有字體大小限制？"
L["Not every event is eligible for this. But some are."] = "並非每個事件都適用於此。但有些是。"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "將您的自定義動畫定義為lua函數。\n\n範例：\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "切換以讓此部分處理標誌動畫。\n\n並非每個事件都有標誌。"
L["Flip position left-right."] = "左右翻轉位置。"
L["E.g. 42292"] = "例如 42292"
L["Loaded custom animation did not return a function."] = "載入的自定義動畫未返回函數。"
L["Before Text"] = "前置文字"
L["After Text"] = "後置文字"
L["Remove Spell"] = "移除法術"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"將您的自定義動畫定義為lua函數。\n\n範例：\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "吸收"
L["BLOCK"] = "格擋"
L["CRITICAL"] = "爆擊"
L["CRUSHING"] = "碾壓"
L["GLANCING"] = "偏斜"
L["RESIST"] = "抵抗"
L["Diagonal"] = "對角"
L["Fountain"] = "噴泉"
L["Horizontal"] = "水平"
L["Random"] = "隨機"
L["Static"] = "靜態"
L["Vertical"] = "垂直"
L["DEFLECT"] = "偏斜"
L["DODGE"] = "閃避"
L["ENERGIZE"] = "能量獲得"
L["EVADE"] = "閃避"
L["HEAL"] = "治療"
L["IMMUNE"] = "免疫"
L["INTERRUPT"] = "打斷"
L["MISS"] = "未命中"
L["PARRY"] = "招架"
L["REFLECT"] = "反射"
L["WOUND"] = "傷害"
L["Debuff applied/faded/refreshed"] = "減益效果套用/消失/刷新"
L["Buff applied/faded/refreshed"] = "增益效果套用/消失/刷新"
L["Physical"] = "物理"
L["Holy"] = "神聖"
L["Fire"] = "火焰"
L["Nature"] = "自然"
L["Frost"] = "冰霜"
L["Shadow"] = "暗影"
L["Arcane"] = "祕法"
L["Astral"] = "星界"
L["Chaos"] = "混沌"
L["Elemental"] = "元素"
L["Magic"] = "魔法"
L["Plague"] = "疾病"
L["Radiant"] = "光輝"
L["Shadowflame"] = "暗影烈焰"
L["Shadowfrost"] = "暗影冰霜"
L["Up"] = "上"
L["Down"] = "下"
L["Classic Style"] = "經典樣式"
L["If enabled, default cooldown style will be used."] = "如果啟用，將使用默認的冷卻樣式。"
L["Classification Indicator"] = "分類指示器"
L["Copy Unit Settings"] = "複製單位設定"
L["Enable Player Class Icons"] = "啟用玩家職業圖示"
L["Enable NPC Classification Icons"] = "啟用NPC分類圖示"
L["Type"] = "類型"
L["Select unit type."] = "選擇單位類型。"
L["World Boss"] = "世界首領"
L["Elite"] = "精英"
L["Rare"] = "稀有"
L["Rare Elite"] = "稀有精英"
L["Class Spec Icons"] = "職業專精圖示"
L["Classification Textures"] = "分類材質"
L["Use Nameplates' Icons"] = "使用姓名板圖示"
L["Color enemy NPC icon based on the unit type."] = "根據單位類型為敵對NPC圖示著色。"
L["Strata and Level"] = "層級和等級"
L["Warrior"] = "戰士"
L["Warlock"] = "術士"
L["Priest"] = "牧師"
L["Paladin"] = "聖騎士"
L["Druid"] = "德魯伊"
L["Rogue"] = "盜賊"
L["Mage"] = "法師"
L["Hunter"] = "獵人"
L["Shaman"] = "薩滿"
L["Deathknight"] = "死亡騎士"
L["Aura Bars"] = "光環條"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "為光環條添加額外的配置選項。\n\n 對於大小和分離等選項，請使用ElvUI光環條移動器！"
L["Hide"] = "隱藏"
L["Spell Name"] = "法術名稱"
L["Spell Time"] = "法術時間"
L["Bounce Icon Points"] = "彈跳圖示點"
L["Set icon to the opposite side of the bar each new bar."] = "每個新條將圖示設置在條的相對側。"
L["Flip Starting Position"] = "翻轉起始位置"
L["0 to disable."] = "0以禁用。"
L["Detach All"] = "全部分離"
L["Detach Power"] = "分離能量"
L["Detaches power for the currently selected group."] = "分離當前選擇群組的能量。"
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "以類似名條上縮短名稱的方式縮短名稱。在名稱設定中將'文字位置'設為左側。"
L["Anchor to Health"] = "錨定到生命值"
L["Adjusts the shortening based on the 'Health' text position."] = "根據'生命值'文字位置調整縮短。"
L["Name Auto-Shorten"] = "名稱自動縮短"
L["Appends a diminishing returns tracker to frames."] = "在框架中添加遞減效果追蹤器。"
L["DR Time"] = "DR 時間"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "DR 時間控制圖標重置所需的時間。多個因素可能影響 DR 重置。如果您持續遇到 DR 重置精確度問題，可以更改此值。"
L["Test"] = "測試"
L["Players Only"] = "僅玩家"
L["Ignore NPCs when setting up icons."] = "設置圖標時忽略 NPC。"
L["Setup Categories"] = "設置類別"
L["Disable Cooldown"] = "停用冷卻"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "前往'冷卻文字' > '全局'進行設置。"
L["Color Borders"] = "顏色邊框"
L["Spacing"] = "間距"
L["DR Strength Indicator: Text"] = "DR 強度指示器：文字"
L["DR Strength Indicator: Box"] = "DR 強度指示器：方框"
L["Good"] = "良好"
L["50% DR for hostiles, 100% DR for the player."] = "敵對目標 50% DR，玩家 100% DR。"
L["Neutral"] = "中性"
L["75% DR for all."] = "所有目標 75% DR。"
L["Bad"] = "不良"
L["100% DR for hostiles, 50% DR for the player."] = "敵對目標 100% DR，玩家 50% DR。"
L["Category Border"] = "類別邊框"
L["Select Category"] = "選擇類別"
L["Categories"] = "類別"
L["Add Category"] = "添加類別"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "格式：'類別 法術ID'，例如 fear 10890。\n所有類別列表可在'顏色'部分找到。"
L["Remove Category"] = "移除類別"
L["Category \"%s\" already exists, updating icon."] = "類別 \"%s\" 已存在，正在更新圖標。"
L["Category \"%s\" added with %s icon."] = "已添加類別 \"%s\"，使用 %s 圖標。"
L["Invalid category."] = "無效的類別。"
L["Category \"%s\" removed."] = "類別 \"%s\" 已移除。"
L["DetachPower"] = "分離能量"
L["NameAutoShorten"] = "名稱自動縮短"
L["Color Filter"] = "顏色過濾器"
L["Enables color filter for the selected unit."] = "為選定的單位啟用顏色過濾器。"
L["Toggle for the currently selected statusbar."] = "切換當前選定的狀態條。"
L["Select Statusbar"] = "選擇狀態條"
L["Health"] = "生命值"
L["Castbar"] = "施法條"
L["Power"] = "能量"
L["Tab Section"] = "標籤部分"
L["Toggle current tab."] = "切換當前標籤。"
L["Tab Priority"] = "標籤優先級"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "當符合多個條件時，將應用優先級最高的標籤的顏色。"
L["Copy Tab"] = "複製標籤"
L["Select a tab to copy its settings onto the current tab."] = "選擇一個標籤將其設置複製到當前標籤。"
L["Flash"] = "閃爍"
L["Speed"] = "速度"
L["Glow"] = "發光"
L["Determines which glow to apply when statusbars are not detached from frame."] = "決定當狀態條未從框架分離時應用哪種發光效果。"
L["Priority"] = "優先級"
L["When handling castbar, also manage its icon."] = "處理施法條時，同時管理其圖標。"
L["CastBar Icon Glow Color"] = "施法條圖標發光顏色"
L["CastBar Icon Glow Size"] = "施法條圖標發光大小"
L["Borders"] = "邊框"
L["CastBar Icon Color"] = "施法條圖標顏色"
L["Toggle classbar borders."] = "切換職業條邊框。"
L["Toggle infopanel borders."] = "切換信息面板邊框。"
L["ClassBar Color"] = "職業條顏色"
L["Disabled unless classbar is enabled."] = "除非啟用職業條，否則禁用。"
L["InfoPanel Color"] = "信息面板顏色"
L["Disabled unless infopanel is enabled."] = "除非啟用信息面板，否則禁用。"
L["ClassBar Adapt To"] = "職業條適應於"
L["Copies the color of the selected bar."] = "複製所選條的顏色。"
L["InfoPanel Adapt To"] = "信息面板適應於"
L["Override Mode"] = "覆蓋模式"
L["'None' - threat borders highlight will be prioritized over this one".. "\n'Threat' - this highlight will be prioritized."] = "'無' - 威脅邊框高亮將優先於此高亮".. "\n'威脅' - 此高亮將優先。"
L["Threat"] = "威脅"
L["Determines which borders to apply when statusbars are not detached from frame."] = "決定當狀態條未從框架分離時應用哪些邊框。"
L["Bar-specific"] = "特定於條的"
L["Lua Section"] = "Lua 部分"
L["Conditions"] = "條件"
L["Font Settings"] = "字體設置"
L["Player Only"] = "僅玩家"
L["Handle only player combat log events."] = "僅處理玩家戰鬥日誌事件。"
L["Rotate Icon"] = "旋轉圖示"
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
		"使用示例："..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
			"\n    return true, {mR = r, mG = g, mB = b}"..
			"\nelseif UnitIsUnit(unit, 'target') then"..
			"\n    return true"..
			"\nend"..
			"\n\n@@[raid, Health, 2, >5]@@ - 根據相關標籤（在上面的例子中：'player' - 目標單位；'Power' - 目標狀態條；'3' - 目標標籤）是否處於活動狀態來返回 true/false"..
			"\n(>/>=/<=/</~= num) - （可選，僅適用於群組單位）匹配群組內觸發框架的特定數量（上面例子中大於 5）"..
			"\n\n'return true, {bR=1,f=false}' - 你可以通過以表格格式返回顏色來動態為框架上色："..
			"\n  要應用於狀態條，請將你的 rgb 值分別指派給 mR、mG 和 mB"..
			"\n  要應用發光效果 - 指派給 gR、gG、gB、gA（透明度）"..
			"\n  邊框顏色 - bR、bG、bB"..
			"\n  閃光效果 - fR、fG、fB、fA"..
			"\n  要防止元素樣式，返回 {m = false, g = false, b = false, f = false}"..
			"\n\nFrame和unitID可在'frame'和'unit'中獲得：UnitBuff(unit, 'player')/frame.Health:IsVisible()。"..
			"\n\n此模組解析字符串，所以請嘗試讓你的代碼嚴格遵循語法，否則可能無法正常工作。"
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "除非按住修飾鍵，否則懸停單位、物品和法術不會顯示工具提示。\n僅修改游標工具提示。"
L["Pick a..."] = "選擇一個..."
L["...mover to anchor to."] = "...要錨定的移動器。"
L["...mover to anchor."] = "...錨定移動器。"
L["Point:"] = "點:"
L["Relative:"] = "相對:"
L["Open Editor"] = "打開編輯器"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "除非按住修飾鍵，否則滑鼠懸停在單位上不會顯示提示。\n只顯示游標提示。"
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "啟用前請先停靠所有聊天框。\nShift-點擊管理按鈕以存取標籤設定。"
L["Mouseover"] = "滑鼠懸停"
L["Manager button visibility."] = "管理按鈕可見性。"
L["Manager point."] = "管理點。"
L["Top Offset"] = "頂部偏移"
L["Bottom Offset"] = "底部偏移"
L["Left Offset"] = "左側偏移"
L["Right Offset"] = "右側偏移"
L["Chat Search and Filter"] = "聊天搜索和過濾"
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
		"聊天框的搜索和過濾工具。"..
			"\n\n語法："..
			"\n  :: - 'and' 語句"..
			"\n  ( ; ) - 'or' 語句"..
			"\n  ! ! - 'not' 語句"..
			"\n  [ ] - 區分大小寫"..
			"\n  @ @ - lua 模式"..
			"\n\n範例訊息："..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\n搜索查詢和結果："..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - 空"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\n使用 Tab/Shift-Tab 在提示間導航。"..
			"\n右鍵點擊搜索按鈕以存取最近的查詢。"..
			"\nShift-右鍵點擊以存取搜索配置。"..
			"\nAlt-右鍵點擊以查看被阻擋的訊息。"..
			"\nCtrl-右鍵點擊以清除已過濾訊息的緩存。"..
			"\n\n頻道名稱和時間戳不會被解析。"
L["Search button visibility."] = "搜索按鈕可見性。"
L["Search button point."] = "搜索按鈕點。"
L["Config Tooltips"] = "配置提示"
L["Highlight Color"] = "高亮顏色"
L["Match highlight color."] = "匹配高亮顏色。"
L["Filter Type"] = "過濾類型"
L["Rule Terms"] = "規則條款"
L["Same logic as with the search."] = "與搜索相同的邏輯。"
L["Select Chat Types"] = "選擇聊天類型"
L["Say"] = "說"
L["Yell"] = "大喊"
L["Party"] = "隊伍"
L["Raid"] = "團隊"
L["Guild"] = "公會"
L["Battleground"] = "戰場"
L["Whisper"] = "密語"
L["Channel"] = "頻道"
L["Other"] = "其他"
L["Select Rule"] = "選擇規則"
L["Select Chat Frame"] = "選擇聊天框"
L["Add Rule"] = "新增規則"
L["Delete Rule"] = "刪除規則"
L["Compact Chat"] = "精簡聊天"
L["Move left"] = "向左移動"
L["Move right"] = "向右移動"
L["Mouseover: Left"] = "滑鼠懸停: 左側"
L["Mouseover: Right"] = "滑鼠懸停: 右側"
L["Automatic Onset"] = "自動開始"
L["Scans tooltip texts and sets icons automatically."] = "掃描提示文字並自動設置圖標。"
L["Icon (Default)"] = "圖標 (預設)"
L["Icon (Kill)"] = "圖標 (擊殺)"
L["Icon (Chat)"] = "圖標 (聊天)"
L["Icon (Item)"] = "圖標 (物品)"
L["Show Text"] = "顯示文本"
L["Display progress status."] = "顯示進度狀態。"
L["Name"] = "名稱"
L["Frequent Updates"] = "頻繁更新"
L["Events (optional)"] = "事件 (可選)"
L["InternalCooldowns"] = "內部冷卻"
L["Displays internal cooldowns on trinket tooltips."] = "在飾品提示上顯示內部冷卻時間。"
L["Shortening X Offset"] = "縮短 X 偏移"
L["To Level"] = "至等級"
L["Names will be shortened based on level text position."] = "名稱將根據等級文字的位置縮短。"
L["Add Item (by ID)"] = "添加物品 (通過ID)"
L["Remove Item"] = "移除物品"
L["Pre-Load"] = "預載入"
L["Executes commands during the addon's initialization process."] = "在插件初始化過程中執行命令。"
L["Justify"] = "對齊"
L["Alt-Click: free bag slots, if possible."] = "Alt-點擊：釋放背包欄位（如果可能）。"
L["Click: toggle layout mode."] = "點擊：切換佈局模式。"
L["Alt-Click: re-evaluate all items."] = "Alt-點擊：重新評估所有物品。"
L["Drag-and-Drop: evaluate and position the cursor item."] = "拖放：評估並定位游標上的物品。"
L["Shift-Alt-Click: toggle these hints."] = "Shift-Alt-點擊：切換這些提示。"
L["Mouse-Wheel: navigate between special and normal bags."] = "滑鼠滾輪：切換特殊與普通背包。"
L["This button accepts cursor item drops."] = "此按鈕接受游標拖放的物品。"
L["Setup Sections"] = "設置分區"
L["Adds default sections set to the currently selected container."] = "將預設分區添加到當前選定的容器。"
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
		"處理自動物品定位。\n"..
			"語法：filter@value\n\n"..
			"可用過濾器：\n"..
			" id@number - 匹配 itemID，\n"..
			" name@string - 匹配名稱，\n"..
			" type@string - 匹配類型，\n"..
			" subtype@string - 匹配子類型，\n"..
			" ilvl@number - 匹配物品等級，\n"..
			" uselevel@number - 匹配裝備等級，\n"..
			" quality@number - 匹配品質，\n"..
			" equipslot@number - 匹配 InventorySlotID，\n"..
			" maxstack@number - 匹配堆疊上限，\n"..
			" price@number - 匹配售價，\n"..
			" tooltip@string - 匹配提示文字，\n"..
			" set@setName - 匹配裝備套裝物品。\n\n"..
			"所有字串匹配不區分大小寫，僅匹配字母數字符號。\n"..
			"標準 Lua 邏輯（and/or/括號等）適用。\n\n"..
			"使用範例（牧師 t8 或 Shadowmourne）：\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne。\n\n"..
			"接受自定義函數（bagID、slotID、itemID 可用）。\n"..
			"以下範例通知新獲得的物品。\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('獲得物品：' .. string)"
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
		"語法：filter@value@amount\n\n"..
			"可用過濾器：\n"..
			" id@number@amount(+)/+ - 匹配 itemID，\n"..
			" name@string@amount(+)/+ - 匹配名稱，\n"..
			" type@string@amount(+)/+ - 匹配類型，\n"..
			" subtype@string@amount(+)/+ - 匹配子類型，\n"..
			" ilvl@number@amount(+)/+ - 匹配物品等級，\n"..
			" uselevel@number@amount(+)/+ - 匹配裝備等級，\n"..
			" quality@number@amount(+)/+ - 匹配品質，\n"..
			" equipslot@number@amount(+)/+ - 匹配 InventorySlotID，\n"..
			" maxstack@number@amount(+)/+ - 匹配堆疊上限，\n"..
			" price@number@amount(+)/+ - 匹配售價，\n"..
			" tooltip@string@amount(+)/+ - 匹配提示文字。\n\n"..
			"可選的 'amount' 部分可以是：\n"..
			" 一個數字 - 購買固定數量，\n"..
			" + 符號 - 補充現有部分堆疊或購買新堆疊，\n"..
			" 兩者（例如 5+） - 購買足夠的物品以達到指定總數（此例中為 5），\n"..
			" 省略 - 默認為 1。\n\n"..
			"所有字串匹配不區分大小寫，僅匹配字母數字符號。\n"..
			"標準 Lua 邏輯（and/or/括號等）適用。\n\n"..
			"使用範例（牧師 t8 或 Shadowmourne）：\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne。"
L["PERIODIC"] = "週期性"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "在使用 /addOccupation 命令時按住此鍵以清除當前目標/滑鼠懸停 NPC 的列表."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "在目標/滑鼠懸停在 NPC 上時使用 /addOccupation 斜線命令將其添加到列表中。再次使用以循環."
L["Style Filter Icons"] = "樣式過濾器圖示"
L["Custom icons for the style filter."] = "樣式過濾器的自定義圖示."
L["Whitelist"] = "白名單"
L["X Direction"] = "X方向"
L["Y Direction"] = "Y方向"
L["Create Icon"] = "建立圖標"
L["Delete Icon"] = "刪除圖標"
L["0 to match frame width."] = "0 以匹配框架寬度。"
L["Remove a NPC"] = "移除 NPC"
L["Change a NPC's Occupation"] = "更改 NPC 的職業"
L["...to the currently selected one."] = "...為當前選擇的職業。"
L["Select Occupation"] = "選擇職業"
L["Sell"] = "出售"
L["Action Type"] = "操作類型"
L["Style Filter Additional Triggers"] = "樣式過濾器額外觸發器"
L["Triggers"] = "觸發器"
L["Example usage:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"] =
    "範例用法:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == '史瑞克'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == '菲歐娜')"
L["Abbreviate Name"] = "縮寫名稱"
L["Highlight Self"] = "突出自己"
L["Highlight Others"] = "突出他人"
L["Self Inherit Name Color"] = "繼承自己的名字顏色"
L["Self Texture"] = "自己的材質"
L["Whitespace to disable, empty to default."] = "空白以禁用，默認為空。"
L["Self Color"] = "自己的顏色"
L["Self Scale"] = "自己的比例"
L["Others Inherit Name Color"] = "繼承他人的名字顏色"
L["Others Texture"] = "他人的材質"
L["Others Color"] = "他人的顏色"
L["Others Scale"] = "他人的比例"
L["Targets"] = "目標"
L["Random dungeon finder queue status frame."] = "隨機地城搜尋佇列狀態框架。"
L["Queue Time"] = "排隊時間"
L["RDFQueueTracker"] = "隨機地城隊列追蹤器"
L["Abbreviate Numbers"] = "縮短數字"
L["DEFAULTS"] = "預設"
L["INTERRUPT"] = "中斷"
L["CONTROL"] = "控制"
L["Copy List"] = "複製清單"
L["DepthOfField"] = "景深"
L["Fades nameplates based on distance to screen center and cursor."] = "根據到螢幕中心和游標的距離淡化姓名板。"
L["Disable in Combat"] = "戰鬥中停用"
L["Y Axis Pivot"] = "Y軸樞紐"
L["Most opaque spot relative to screen center."] = "相對於螢幕中心最不透明的點。"
L["Min Opacity"] = "最小不透明度"
L["Falloff Rate"] = "衰減率"
L["Mouse Falloff Rate"] = "滑鼠衰減率"
L["Base multiplier."] = "基礎乘數。"
L["Effect Curve"] = "效果曲線"
L["Mouse Effect Curve"] = "滑鼠效果曲線"
L["Higher values result in steeper falloff."] = "較高的值會導致更陡峭的衰減。"
L["Enable Mouse"] = "啟用滑鼠"
L["Also calculate cursor proximity."] = "同時計算游標距離。"
L["Ignore Styled"] = "忽略已設樣式"
L["Ignore Target"] = "忽略目標"
L["Spells outside the selected whitelist filters will not be displayed."] =
	"選定白名單過濾器以外的法術將不會顯示。"
L["Enables tooltips to display which set an item belongs to."] = "啟用工具提示以顯示物品屬於哪個套裝。"
L["TierText"] = "階級文字"
L["Select Item"] = "選擇物品"
L["Add Item (ID)"] = "添加物品 (ID)"
L["Item Text"] = "物品文字"
L["Sort by Filter"] = "依過濾條件排序"
L["Makes aura sorting abide filter priorities."] = "使光環排序遵循過濾條件的優先順序。"
L["Add Spell"] = "添加法術"
L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"] =
	"格式: '法術ID 冷卻時間',\n例如 42292 120\n或\n法術名稱 20"
L["Fixes and Tweaks (requires reload)"] = "修正與調整 (需要重新載入)"
L["Restore Raid Controls"] = "恢復團隊控制"
L["Brings back 'Promote to Leader/Assist' controls in raid members' dropdown menus."] =
	"恢復團隊成員下拉選單中的『晉升為隊長/助理』選項。"
L["World Map Quests"] = "世界地圖任務"
L["Allows Ctrl+Click on the world map quest list to open the quest log."] =
	"允許在世界地圖任務列表中按 Ctrl+點擊以開啟任務日誌。"
L["Unit Hostility Status"] = "單位敵對狀態"
L["Forces a nameplate update when a unit changes factions or hostility status (e.g. mind control)."] =
	"當單位更換陣營或敵對狀態（例如：心靈控制）時，強制更新名條。"
L["Style Filter Name-Only"] = "樣式篩選器 (僅顯示名稱)"
L["Fixes an issue where the style filter fails to update the nameplate on aura events after hiding its health."] =
	"修正了在隱藏血條後，樣式篩選器在光環事件中未能更新名條的問題。"
L["Use Default Handling"] = "使用預設處理"
L["Show Group Members"] = "顯示隊伍成員"
L["Hide Group Members"] = "隱藏隊伍成員"
L["Select 'Enemy Player' to configure."] = "選擇「敵對玩家」進行設置。"
L["Capture Bar"] = "佔領條"
L["Capture Bar Mover"] = "移動佔領條"
L["Capture Bar Height"] = "佔領條高度"
L["Also might fix capture bar related issues like progress marker not showing."] =
	"也可能修復佔領條相關問題，例如進度標記未顯示。"
L["Max Length"] = "最大長度"
L["Copy button visibility."] = "複製按鈕的可見性。"
L["Mouseover: Channel Button"] = "滑鼠懸停: 頻道按鈕"
L["Mouseover: Copy Button"] = "滑鼠懸停: 複製按鈕"
L["Plugin version mismatch! Please, download appropriate plugin version at"] = "插件版本不符！請至以下位置下載對應版本："
L["Questie Coherence"] = "Questie 相容性"
L["Makes, once again, itemID tooltip line added by ElvUI to get positioned last on unit and item tooltips."] =
	"讓 ElvUI 所加的 itemID 再次顯示於單位和物品提示的最後一行。"
L["Attempts to extend font outline options across all of ElvUI."] = "嘗試在整個 ElvUI 中擴展字體外框選項。"
