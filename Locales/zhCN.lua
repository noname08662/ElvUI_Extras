local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "zhCN")

L["Hits the 'Confirm' button automatically."] = "自动点击'确认'按钮。"
L["Picks up items and money automatically."] = "自动拾取物品和金钱。"
L["Automatically fills the 'DELETE' field."] = "自动填写'删除'字段。"
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "如果只有一个对话选项可用，则自动选择第一个选项，除非按住修饰键。\n对于重要的事件触发要小心，没有故障保护机制。"
L["Accepts and turns in quests automatically while holding a modifier."] = "按住修饰键时自动接受和提交任务。"
L["Loot info wiped."] = "拾取信息已清除。"
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "/lootinfo 命令用于快速查看最近的战利品。\n\n用法: /lootinfo 苹果 60\n'苹果' - 物品/玩家名字 \n(搜索 @self 获取玩家的战利品)\n'60' - \n时间限制（<60秒前），可选，\n/lootinfo !wipe - 清除战利品缓存。"
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "在某些消息中为在线好友和公会成员的名字着色，并为掷骰添加样式。\n已处理的聊天气泡在你使用 /reload 之前不会被重新设置样式。"
L["Colors loot roll messages for you and other players."] = "为你和其他玩家的拾取掷骰消息着色。"
L["Loot rolls icon size."] = "拾取掷骰图标大小。"
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "重新设置拾取条样式。\n需要启用'拾取掷骰'（常规 -> BlizzUI改进 -> 拾取掷骰）（切换此模块会自动启用它）。"
L["Displays the name of the player pinging the minimap."] = "显示在小地图上发出标记的玩家名称。"
L["Displays the currently held currency amount next to the item prices."] = "在物品价格旁显示当前持有的货币数量。"
L["Narrows down the World(..Frame)."] = "缩小World(..Frame)。"
L["'Out of mana', 'Ability is not ready yet', etc."] = "'法力不足'，'技能尚未就绪'等。"
L["Re-enable quest updates."] = "重新启用任务更新。"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "除非按住修饰键，否则悬停在单位上不会显示提示框。\n仅显示鼠标指针提示。"
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - 暴雪的黃色。"
L["Text to display upon entering combat."] = "进入战斗时显示的文字。"
L["Text to display upon leaving combat."] = "离开战斗时显示的文字。"
L["REQUIRES RELOAD."] = "需要重新加载。"
L["Icon to the left or right of the item link."] = "物品链接左侧或右侧的图标。"
L["The size of the icon in the chat frame."] = "聊天框中的图标大小。"
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "为所有框架添加阴影。\n除非你用这个插件的Optionals文件夹中的相关文件替换你的ElvUI/Core/Toolkit.lua，否则无效。"
L["Combat state notification alerts."] = "战斗状态通知警报。"
L["Custom editbox position and size."] = "自定义编辑框位置和大小。"
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
			"\n/tnote list - 返回所有现有的注释"..
			"\n/tnote wipe - 清除所有现有的注释"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - 与set相同（除了lua部分）"..
			"\n/tnote 1 get - 与set相同，返回现有的注释"..
			"\n/tnote 1 set 您的注释在这里 - 将注释添加到指定的列表索引 "..
			"或者如果省略第二个参数（在这种情况下为1），则添加到当前显示的工具提示文本， "..
			"支持函数和着色 "..
			"（不提供文本则清除注释）;"..
			"\n要换行，请使用 ::"..
			"\n\n示例："..
			"\n\n/tnote 3 set 火焰 前最佳::来源：王大明"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(默认颜色)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "在聊天超链接旁添加一个图标。"
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "一个新的动作条，用于收集背包中可用的任务物品。\n\n由于状态动作限制，该模块会覆盖ElvUI额外动作条创建的bar10。"
L["Toggles the display of the actionbar's backdrop."] = "切换动作条背景的显示。"
L["The frame will not be displayed unless hovered over."] = "除非鼠标悬停，否则框架不会显示。"
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "继承全局淡出效果，鼠标悬停、选择目标、设置焦点、失去生命值、进入战斗将移除透明度。否则，它将使用一般动作条设置中的透明度级别作为全局淡出的透明度。"
L["The first button anchors itself to this point on the bar."] = "第一个按钮固定在动作条上的这个点。"
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "按住修饰键的同时右键点击物品将其加入黑名单。黑名单中的物品不会在动作条上显示。\n使用 /questbarRestore 清除黑名单。"
L["The number of buttons to display."] = "要显示的按钮数量。"
L["The number of buttons to display per row."] = "每行显示的按钮数量。"
L["The size of the action buttons."] = "动作按钮的大小。"
L["Spacing between the buttons."] = "按钮之间的间距。"
L["Spacing between the backdrop and the buttons."] = "背景和按钮之间的间距。"
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "将背景的高度或宽度乘以此值。如果你希望在一个背景后面有多个动作条，这很有用。"
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "这就像一个宏，你可以运行不同的情况来让动作条以不同方式显示/隐藏。\n 例如：'[combat] showhide'"
L["Adds anchoring options to the movers' nudges."] = "为移动器的微调添加锚点选项。"
L["Mod-clicking an item suggests a skill/item to process it."] = "按住修饰键点击物品会建议处理它的技能/物品。"
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"按住%s的同时左键点击堆叠可将其分为两半；要合并可用副本，请右键点击。\n\n还修改了SplitStackFrame，使用编辑框而不是箭头。"
L["Extends the bags functionality."] = "扩展背包功能。"
L["Default method: type > inventory slot ID > item level > name."] = "默认方法：类型 > 物品栏位ID > 物品等级 > 名称。"
L["Listed ItemIDs will not get sorted."] = "列出的物品ID不会被排序。"
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "例如：Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "无效的条件格式："
L["The generated custom sorting method did not return a function."] = "生成的自定义排序方法没有返回函数。"
L["The loaded custom sorting method did not return a function."] = "加载的自定义排序方法没有返回函数。"
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
		"处理新获得物品的自动重新定位。"..
		"\n语法: 过滤器@值\n\n"..
		"可用过滤器:\n"..
		" id@数字 - 匹配物品ID,\n"..
		" name@字符串 - 匹配名称,\n"..
		" subtype@字符串 - 匹配子类型,\n"..
		" ilvl@数字 - 匹配物品等级,\n"..
		" uselevel@数字 - 匹配装备等级,\n"..
		" quality@数字 - 匹配品质,\n"..
		" equipslot@数字 - 匹配库存栏位ID,\n"..
		" maxstack@数字 - 匹配堆叠上限,\n"..
		" price@数字 - 匹配售价,\n\n"..
		" tooltip@字符串 - 匹配提示文本,\n\n"..
		"所有字符串匹配不区分大小写，仅匹配字母数字符号。适用标准lua逻辑。"..
		"查看GetItemInfo API以获取更多关于过滤器的信息。"..
		"使用GetAuctionItemClasses和GetAuctionItemSubClasses（与拍卖行相同）获取本地化的类型和子类型值。\n\n"..
		"使用示例（牧师T8或暗影之殇）:\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@布甲 and name@圣化) or name@暗影之殇.\n\n"..
		"接受自定义函数（bagID, slotID, itemID可用）\n"..
		"以下函数通知新获得的物品。\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\124', '\124\124')\n"..
		"local string = '\124T' .. icon .. ':16:16\124t' .. link\n"..
		"print('获得物品: ' .. string)"
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
		"语法：过滤器@值\n\n"..
			"可用过滤器：\n"..
			" id@数字 - 匹配物品ID，\n"..
			" name@字符串 - 匹配名称，\n"..
			" type@字符串 - 匹配类型，\n"..
			" subtype@字符串 - 匹配子类型，\n"..
			" ilvl@数字 - 匹配物品等级，\n"..
			" uselevel@数字 - 匹配装备等级，\n"..
			" quality@数字 - 匹配品质，\n"..
			" equipslot@数字 - 匹配背包栏位ID，\n"..
			" maxstack@数字 - 匹配堆叠上限，\n"..
			" price@数字 - 匹配售价，\n"..
			" tooltip@字符串 - 匹配提示文本。\n\n"..
			"所有字符串匹配不区分大小写，且仅匹配字母数字符号。\n"..
			"适用标准lua分支逻辑（与/或/括号等）。\n\n"..
			"使用示例（牧师t8或暗影之哀伤）：\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "可用物品类型"
L["Lists all available item subtypes for each available item type."] =
	"列出每个可用物品类型的所有可用物品子类型。"
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"与商人互动时按住此键会购买所有符合自动购买设置的物品。\n"..
			"在购买列表条目上进行模组点击，无视'@数量'规则，只购买一个符合条件的物品。"
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] =
		"默认方法: 类型 > 库存栏位ID > 物品等级 > 名称。\n\n"..
		"接受自定义函数（a/b.bagID/slotID可用）。\n\n"..
		"function(a,b)\n"..
		"--在此处添加您的排序逻辑\n"..
		"end\n\n"..
		"留空则使用默认设置。"
L["Event and OnUpdate handler."] = "事件和OnUpdate处理程序。"
L["Minimal time gap between two consecutive executions."] = "两次连续执行之间的最小时间间隔。"
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER 等。\nONUPDATE - 'OnUpdate' 脚本"
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
		"语法:"..
		"\n\nEVENT[n~=nil]"..
		"\n[n~=value]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@commands@@@"..
		"\n\n'EVENT' - 上面事件部分中的事件"..
		"\n'n, m, k' - 所需有效载荷参数的索引（数字）"..
		"\n'nil/value/boolean/lua代码' - n参数的期望输出"..
		"\n'@@' - lua参数标志，必须在参数值部分的lua代码前使用"..
		"\n'~' - 否定标志，在等号前添加，如果n/m/k不匹配设定值则执行代码"..
		"\n'@@@ @@@' - 包含命令的括号。"..
		"\n你可以像往常一样访问有效载荷（...）。"..
		"\n\n示例:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(玩家获得/失去了一个光环)@@@"..
		"\n\nCHAT_MSG_WHISPER"..
		"\n[5~=@@UnitName('player')]"..
		"\n[14=false]@@@"..
		"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
		"\n\nCOMBAT_LOG_EVENT_"..
		"\nUNFILTERED"..
		"\n[5=@@UnitName('arena1')]"..
		"\n[5=@@UnitName('arena2')]@@@"..
		"\nfor i = 1, 2 do"..
		"\nif UnitDebuff('party'..i, '不良法术')"..
		"\nthen print(UnitName('party'..i)..'受到了影响！')"..
		"\nend end@@@"..
		"\n\n此模块解析字符串，所以尽量严格遵循语法，否则可能无法正常工作。"
L["Highlights auras."] = "高亮光环。"
L["E.g. 42292"] = "例如 42292"
L["Applies highlights to all auras passing the selected filter."] = "高亮所有通过选定过滤器的光环。"
L["Priority: spell, filter, curable/stealable."] = "优先级：法术、过滤器、可治疗/可偷取。"
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "如果切换，将使用全局法术或过滤器条目值。"
L["Makes auras grow sideswise."] = "使光环向两侧扩展。"
L["Turns off texture fill."] = "关闭纹理填充。"
L["Makes auras flicker right before fading out."] = "使光环在淡出之前闪烁。"
L["Disables border coloring."] = "禁用边框着色。"
L["Click Cancel"] = "点击取消"
L["Right-click a player buff to cancel it."] = "右键点击玩家增益效果以取消。"
L["Disables debuffs desaturation."] = "禁用 debuff 去饱和度。"
L["Saturated Debuffs"] = "饱和 debuffs"
L["Confirm Rolls"] = "确认掷骰"
L["Auto Pickup"] = "自動拾取"
L["Swift Buy"] = "快速购买"
L["Buys out items automatically."] = "自动购买物品。"
L["Failsafe"] = "故障保护"
L["Enables popup confirmation dialog."] = "启用弹出确认对话框。"
L["Add Set"] = "添加套装"
L["Delete Set"] = "删除套装"
L["Select Set"] = "选择套装"
L["Auto Buy"] = "自动购买"
L["Fill Delete"] = "填写删除"
L["Gossip"] = "对话"
L["Accept Quest"] = "接受任务"
L["Loot Info"] = "拾取信息"
L["Styled Messages"] = "样式化消息"
L["Indicator Color"] = "指示器颜色"
L["Select Status"] = "选择状态"
L["Select Indicator"] = "选择指示器"
L["Styled Loot Messages"] = "样式化拾取消息"
L["Icon Size"] = "图标大小"
L["Loot Bars"] = "拾取条"
L["Bar Height"] = "条高"
L["Bar Width"] = "条宽"
L["Player Pings"] = "玩家标记"
L["Held Currency"] = "持有货币"
L["LetterBox"] = "信箱"
L["Left"] = "左"
L["Right"] = "右"
L["Top"] = "上"
L["Bottom"] = "下"
L["Hide Errors"] = "隐藏错误"
L["Show quest updates"] = "显示任务更新"
L["Less Tooltips"] = "减少提示"
L["Misc."] = "杂项"
L["Loot&Style"] = "拾取与样式"
L["Automation"] = "自动化"
L["Bags"] = "背包"
L["Easier Processing"] = "简化处理"
L["Modifier"] = "修饰键"
L["Split Stack"] = "分割堆叠"
L["Bags Extended"] = "扩展背包"
L["Select Container Type"] = "选择容器类型"
L["Settings"] = "设置"
L["Add Section"] = "添加部分"
L["Delete Section"] = "删除部分"
L["Select Section"] = "选择部分"
L["Section Priority"] = "部分优先级"
L["Section Spacing"] = "部分间距"
L["Collection Method"] = "收集方法"
L["Sorting Method"] = "排序方法"
L["Ignore Item (by ID)"] = "忽略物品（按ID）"
L["Remove Ignored"] = "移除已忽略"
L["Title"] = "标题"
L["Color"] = "颜色"
L["Attach to Icon"] = "附加到图标"
L["Text"] = "文本"
L["Font Size"] = "字体大小"
L["Font"] = "字体"
L["Font Flags"] = "字体标记"
L["Point"] = "锚点"
L["Relative Point"] = "相对锚点"
L["X Offset"] = "X偏移"
L["Y Offset"] = "Y偏移"
L["Icon"] = "图标"
L["Attach to Text"] = "附加到文本"
L["Texture"] = "材质"
L["Size"] = "大小"
L["MoversPlus"] = "移动增强"
L["Movers Plus"] = "移动增强"
L["CustomCommands"] = "自定义命令"
L["Custom Commands"] = "自定义命令"
L["QuestBar"] = "任务栏"
L["Quest Bar"] = "任务栏"
L["Settings"] = "设置"
L["Backdrop"] = "背景"
L["Show Empty Buttons"] = "显示空按钮"
L["Mouse Over"] = "鼠标悬停"
L["Inherit Global Fade"] = "继承全局淡出"
L["Anchor Point"] = "锚点"
L["Modifier"] = "修饰键"
L["Buttons"] = "按钮"
L["Buttons Per Row"] = "每行按钮数"
L["Button Size"] = "按钮大小"
L["Button Spacing"] = "按钮间距"
L["Backdrop Spacing"] = "背景间距"
L["Height Multiplier"] = "高度倍数"
L["Width Multiplier"] = "宽度倍数"
L["Alpha"] = "透明度"
L["Visibility State"] = "可见状态"
L["Enable Tab"] = "启用标签"
L["Throttle Time"] = "限制时间"
L["Select Tab"] = "选择标签"
L["Select Event"] = "选择事件"
L["Rename Tab"] = "重命名标签"
L["Add Tab"] = "添加标签"
L["Delete Tab"] = "删除标签"
L["Open Edit Frame"] = "打开编辑框架"
L["Events"] = "事件"
L["Commands to execute"] = "要执行的命令"
L["Sub-Section"] = "子部分"
L["Select"] = "选择"
L["Icon Orientation"] = "图标方向"
L["Icon Size"] = "图标大小"
L["Height Offset"] = "高度偏移"
L["Width Offset"] = "宽度偏移"
L["Text Color"] = "文本颜色"
L["Entering combat"] = "进入战斗"
L["Leaving combat"] = "离开战斗"
L["Font"] = "字体"
L["Font Outline"] = "字体轮廓"
L["Font Size"] = "字体大小"
L["Texture Width"] = "纹理宽度"
L["Texture Height"] = "纹理高度"
L["Custom Texture"] = "自定义纹理"
L["ItemIcons"] = "物品图标"
L["TooltipNotes"] = "工具提示"
L["ChatEditBox"] = "聊天编辑框"
L["EnterCombatAlert"] = "进入战斗警报"
L["GlobalShadow"] = "全局阴影"
L["Any"] = "任何"
L["Guildmate"] = "公会成员"
L["Friend"] = "朋友"
L["Self"] = "玩家"
L["New Tab"] = "新标签"
L["None"] = "无"
L["Version: "] = "版本:"
L["Color A"] = "颜色A"
L["Chat messages, etc."] = "聊天消息等。"
L["Color B"] = "颜色B"
L["Plugin Color"] = "插件颜色"
L["Icons Browser"] = "图标浏览器"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "获取 https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html 以获取更清晰、裁剪过的图标。"
L["Add Texture"] = "添加纹理"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "将纹理添加到通用纹理列表中。\n例如:Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "移除纹理"
L["Highlights"] = "高亮"
L["Select Type"] = "选择类型"
L["Highlights Settings"] = "高亮设置"
L["Add Spell (by ID)"] = "添加法术（按ID）"
L["Add Filter"] = "添加过滤器"
L["Remove Selected"] = "移除选中"
L["Select Spell or Filter"] = "选择法术或过滤器"
L["Use Global Settings"] = "使用全局设置"
L["Selected Spell or Filter Values"] = "选中的法术或过滤器值"
L["Enable Shadow"] = "启用阴影"
L["Size"] = "大小"
L["Shadow Color"] = "阴影颜色"
L["Enable Border"] = "启用边框"
L["Border Color"] = "边框颜色"
L["Centered Auras"] = "居中光环"
L["Cooldown Disable"] = "禁用冷却"
L["Animate Fade-Out"] = "动画淡出"
L["Type Borders"] = "类型边框"
L[" filter added."] = "过滤器已添加。"
L[" filter removed."] = "过滤器已移除。"
L["GLOBAL"] = "全局"
L["CURABLE"] = "可治疗"
L["STEALABLE"] = "可偷窃"
L["--Filters--"] = "--过滤器--"
L["--Spells--"] = "--法术--"
L["FRIENDLY"] = "友善"
L["ENEMY"] = "敌人"
L["AuraBars"] = "光环条"
L["Auras"] = "光环"
L["ClassificationIndicator"] = "分类指示器"
L["ClassificationIcons"] = "分类图标"
L["ColorFilter"] = "颜色过滤器"
L["Cooldowns"] = "冷却时间"
L["DRTracker"] = "DR追踪器"
L["Guilds&Titles"] = "公会与头衔"
L["Name&Level"] = "名称与等级"
L["QuestIcons"] = "任务图标"
L["StyleFilter"] = "样式过滤器"
L["Search:"] = "搜索:"
L["Click to select."] = "点击选择。"
L["Click to select."] = "点击选择。"
L["Hover again to see the changes."] = "再次悬停查看更改。"
L["Note set for "] = "为以下对象设置备注："
L["Note cleared for "] = "为以下对象清除备注："
L["No note to clear for "] = "没有备注可清除："
L["Added icon to the note for "] = "为以下对象的备注添加图标："
L["Note icon cleared for "] = "为以下对象清除备注图标："
L["No note icon to clear for "] = "没有备注图标可清除："
L["Current note for "] = "当前备注："
L["No note found for this tooltip."] = "未找到此工具提示的备注。"
L["Notes: "] = "备注："
L["No notes are set."] = "未设置任何备注。"
L["No tooltip is currently shown or unsupported tooltip type."] = "当前未显示工具提示或不支持的工具提示类型。"
L["All notes have been cleared."] = "所有备注已清除。"
L["Accept"] = "接受"
L["Cancel"] = "取消"
L["Purge Cache"] = "清除缓存"
L["Guilds"] = "公会"
L["Separator"] = "分隔符"
L["X Offset"] = "X偏移"
L["Y Offset"] = "Y偏移"
L["Level"] = "等级"
L["Visibility State"] = "可见性状态"
L["City (Resting)"] = "城市（休息）"
L["PvP"] = "PvP"
L["Arena"] = "竞技场"
L["Party"] = "小队"
L["Raid"] = "团队"
L["Colors"] = "颜色"
L["Guild"] = "公会"
L["All"] = "全部"
L["Occupation Icon"] = "职业图标"
L["OccupationIcon"] = "职业图标"
L["Size"] = "大小"
L["Anchor"] = "锚点"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "移除职业"
L["Modifier"] = "修饰键"
L["Add Texture Path"] = "添加材质路径"
L["Remove Selected Texture"] = "移除所选材质"
L["Titles"] = "头衔"
L["Reaction Color"] = "反应颜色"
L["Color based on reaction type."] = "根据反应类型着色。"
L["Nameplates"] = "姓名板"
L["Unitframes"] = "单位框架"
L["An icon similar to the minimap search."] = "类似于小地图搜索的图标。"
L["Displays player guild text."] = "显示玩家的公会文本。"
L["Displays NPC occupation text."] = "显示NPC的职业文本。"
L["Strata"] = "层级"
L["Mark"] = "标记"
L["Mark the target/mouseover plate."] = "标记目标/鼠标悬停的姓名板。"
L["Unmark"] = "取消标记"
L["Unmark the target/mouseover plate."] = "取消标记目标/鼠标悬停的姓名板。"
L["Selected Type"] = "选择的类型"
L["Reaction based coloring for non-cached characters."] = "基于反应的非缓存角色的着色。"
L["Apply Custom Color"] = "应用自定义颜色"
L["Class Color"] = "职业颜色"
L["Use class colors."] = "使用职业颜色。"
L["Unmark All"] = "取消所有标记"
L["Unmark all plates."] = "取消所有姓名板的标记。"
L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"] =
	"用法：将 '/qmark' 宏绑定到您选择的按键。\n\n不要忘记解除您的修饰键绑定！"
L["Use Backdrop"] = "使用背景"
L["Linked Style Filter Triggers"] = "链接的样式过滤器触发器"
L["Select Link"] = "选择链接"
L["New Link"] = "新链接"
L["Delete Link"] = "删除链接"
L["Target Filter"] = "目标过滤器"
L["Select a filter to trigger the styling."] = "选择一个过滤器以触发样式。"
L["Apply Filter"] = "应用过滤器"
L["Select a filter to style the frames not passing the target filter triggers."] = "选择一个过滤器以样式化未通过目标过滤器触发的框架。"
L["Cache purged."] = "缓存已清除。"
L["Test Mode"] = "测试模式"
L["Draws player cooldowns."] = "显示玩家冷却时间。"
L["Show Everywhere"] = "在所有地方显示"
L["Show in Cities"] = "在城市中显示"
L["Show in Battlegrounds"] = "在战场中显示"
L["Show in Arenas"] = "在竞技场中显示"
L["Show in Instances"] = "在副本中显示"
L["Show in the World"] = "在世界中显示"
L["Header"] = "标题"
L["Icons"] = "图标"
L["OnUpdate Throttle"] = "更新节流"
L["Trinket First"] = "饰品优先"
L["Animate Fade Out"] = "淡出动画"
L["Border Color"] = "边框颜色"
L["Growth Direction"] = "增长方向"
L["Sort Method"] = "排序方法"
L["Icon Size"] = "图标大小"
L["Icon Spacing"] = "图标间距"
L["Per Row"] = "每行"
L["Max Rows"] = "最大行数"
L["CD Text"] = "冷却文字"
L["Show"] = "显示"
L["Cooldown Fill"] = "冷却填充"
L["Reverse"] = "反向"
L["Direction"] = "方向"
L["Spells"] = "法术"
L["Add Spell (by ID)"] = "添加法术（按ID）"
L["Remove Selected Spell"] = "移除选定的法术"
L["Select Spell"] = "选择法术"
L["Shadow"] = "阴影"
L["Pet Ability"] = "宠物技能"
L["Shadow Size"] = "阴影大小"
L["Shadow Color"] = "阴影颜色"
L["Sets update speed threshold."] = "设置更新速度阈值。"
L["Makes PvP trinkets and human racial always get positioned first."] = "使PvP饰品和人类种族特长始终排在首位。"
L["Makes icons flash when the cooldown's about to end."] = "当冷却即将结束时使图标闪烁。"
L["Any value apart from black (0,0,0) would override borders by time left."] = "除黑色(0,0,0)以外的任何值都会根据剩余时间覆盖边框。"
L["Colors borders by time left."] = "根据剩余时间为边框着色。"
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "格式：'法术ID 冷却时间'，例如 42292 120"
L["For the important stuff."] = "用于重要的事物。"
L["Pet casts require some special treatment."] = "宠物施法需要一些特殊处理。"
L["Color by Type"] = "按类型着色"
L["Flip Icon"] = "翻转图标"
L["Texture List"] = "材质列表"
L["Keep Icon"] = "保留图标"
L["Texture"] = "材质"
L["Texture Coordinates"] = "材质坐标"
L["Select Affiliation"] = "选择阵营"
L["Width"] = "宽度"
L["Height"] = "高度"
L["Select Class"] = "选择职业"
L["Points"] = "点数"
L["Colors the icon based on the unit type."] = "根据单位类型为图标着色。"
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "水平翻转图标。不兼容于材质坐标。"
L["Keep the original icon texture."] = "保留原始图标材质。"
L["NPCs"] = "NPC"
L["Players"] = "玩家"
L["By duration, ascending."] = "按持续时间升序。"
L["By duration, descending."] = "按持续时间降序。"
L["By time used, ascending."] = "按使用时间升序。"
L["By time used, descending."] = "按使用时间降序。"
L["Additional settings for the Elite Icon."] = "精英图标的额外设置。"
L["Player class icons."] = "玩家职业图标。"
L["Class Icons"] = "职业图标"
L["Vector Class Icons"] = "矢量职业图标"
L["Class Crests"] = "职业纹章"
L["Floating Combat Feedback"] = "浮动战斗反馈"
L["Select Unit"] = "选择单位"
L["player"] = "玩家 (player)"
L["target"] = "目标 (target)"
L["targettarget"] = "目标的目标 (targettarget)"
L["targettargettarget"] = "目标的目标的目标 (targettargettarget)"
L["focus"] = "焦点 (focus)"
L["focustarget"] = "焦点目标 (focustarget)"
L["pet"] = "宠物 (pet)"
L["pettarget"] = "宠物目标 (pettarget)"
L["raid"] = "团队 (raid)"
L["raid40"] = "40人团队 (raid40)"
L["raidpet"] = "团队宠物 (raidpet)"
L["party"] = "小队 (party)"
L["partypet"] = "小队宠物 (partypet)"
L["partytarget"] = "小队目标 (partytarget)"
L["boss"] = "首领 (boss)"
L["arena"] = "竞技场 (arena)"
L["assist"] = "助手 (assist)"
L["assisttarget"] = "助手目标 (assisttarget)"
L["tank"] = "坦克 (tank)"
L["tanktarget"] = "坦克目标 (tanktarget)"
L["Scroll Time"] = "滚动时间"
L["Event Settings"] = "事件设置"
L["Event"] = "事件"
L["Disable Event"] = "禁用事件"
L["School"] = "学派"
L["Use School Colors"] = "使用学派颜色"
L["Colors"] = "颜色"
L["Color (School)"] = "颜色（系别）"
L["Animation Type"] = "动画类型"
L["Custom Animation"] = "自定义动画"
L["Flag Settings"] = "标志设置"
L["Flag"] = "标志"
L["Font Size Multiplier"] = "字体大小乘数"
L["Animation by Flag"] = "按标志动画"
L["Icon Settings"] = "图标设置"
L["Show Icon"] = "显示图标"
L["Icon Position"] = "图标位置"
L["Bounce"] = "弹跳"
L["Blacklist"] = "黑名单"
L["Appends floating combat feedback fontstrings to frames."] = "将浮动战斗反馈字符串附加到框架。"
L["There seems to be a font size limit?"] = "似乎有字体大小限制？"
L["Not every event is eligible for this. But some are."] = "不是每个事件都适用于此。但有些是。"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "将您的自定义动画定义为lua函数。\n\n示例：\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "切换以使此部分处理标志动画。\n\n并非每个事件都有标志。"
L["Flip position left-right."] = "左右翻转位置。"
L["E.g. 42292"] = "例如 42292"
L["Loaded custom animation did not return a function."] = "加载的自定义动画没有返回函数。"
L["Before Text"] = "前置文本"
L["After Text"] = "后置文本"
L["Remove Spell"] = "移除法术"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"将您的自定义动画定义为lua函数。\n\n示例：\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "吸收"
L["BLOCK"] = "格挡"
L["CRITICAL"] = "暴击"
L["CRUSHING"] = "碾压"
L["GLANCING"] = "偏斜"
L["RESIST"] = "抵抗"
L["Diagonal"] = "对角"
L["Fountain"] = "喷泉"
L["Horizontal"] = "水平"
L["Random"] = "随机"
L["Static"] = "静态"
L["Vertical"] = "垂直"
L["DEFLECT"] = "偏转"
L["DODGE"] = "闪避"
L["ENERGIZE"] = "能量获得"
L["EVADE"] = "闪避"
L["HEAL"] = "治疗"
L["IMMUNE"] = "免疫"
L["INTERRUPT"] = "打断"
L["MISS"] = "未命中"
L["PARRY"] = "招架"
L["REFLECT"] = "反射"
L["WOUND"] = "伤害"
L["Debuff applied/faded/refreshed"] = "减益效果应用/消失/刷新"
L["Buff applied/faded/refreshed"] = "增益效果应用/消失/刷新"
L["Physical"] = "物理"
L["Holy"] = "神圣"
L["Fire"] = "火焰"
L["Nature"] = "自然"
L["Frost"] = "冰霜"
L["Shadow"] = "暗影"
L["Arcane"] = "奥术"
L["Astral"] = "星界"
L["Chaos"] = "混乱"
L["Elemental"] = "元素"
L["Magic"] = "魔法"
L["Plague"] = "疾病"
L["Radiant"] = "光辉"
L["Shadowflame"] = "暗影烈焰"
L["Shadowfrost"] = "暗影冰霜"
L["Up"] = "上"
L["Down"] = "下"
L["Classic Style"] = "经典样式"
L["If enabled, default cooldown style will be used."] = "如果启用，将使用默认的冷却样式。"
L["Classification Indicator"] = "分类指示器"
L["Copy Unit Settings"] = "复制单位设置"
L["Enable Player Class Icons"] = "启用玩家职业图标"
L["Enable NPC Classification Icons"] = "启用NPC分类图标"
L["Type"] = "类型"
L["Select unit type."] = "选择单位类型。"
L["World Boss"] = "世界首领"
L["Elite"] = "精英"
L["Rare"] = "稀有"
L["Rare Elite"] = "稀有精英"
L["Class Spec Icons"] = "职业专精图标"
L["Classification Textures"] = "分类材质"
L["Use Nameplates' Icons"] = "使用姓名板图标"
L["Color enemy NPC icon based on the unit type."] = "根据单位类型为敌对NPC图标着色。"
L["Strata and Level"] = "层级和等级"
L["Warrior"] = "战士"
L["Warlock"] = "术士"
L["Priest"] = "牧师"
L["Paladin"] = "圣骑士"
L["Druid"] = "德鲁伊"
L["Rogue"] = "潜行者"
L["Mage"] = "法师"
L["Hunter"] = "猎人"
L["Shaman"] = "萨满祭司"
L["Deathknight"] = "死亡骑士"
L["Aura Bars"] = "光环条"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "为光环条添加额外的配置选项。\n\n 对于大小和分离等选项，请使用ElvUI光环条移动器！"
L["Hide"] = "隐藏"
L["Spell Name"] = "法术名称"
L["Spell Time"] = "法术时间"
L["Bounce Icon Points"] = "弹跳图标点"
L["Set icon to the opposite side of the bar each new bar."] = "每个新条将图标设置在条的相对侧。"
L["Flip Starting Position"] = "翻转起始位置"
L["0 to disable."] = "0以禁用。"
L["Detach All"] = "全部分离"
L["Detach Power"] = "分离能量"
L["Detaches power for the currently selected group."] = "分离当前选择群组的能量。"
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "以类似姓名板上缩短名称的方式缩短名称。在名称设置中将'文本位置'设为左侧。"
L["Anchor to Health"] = "锚定到生命值"
L["Adjusts the shortening based on the 'Health' text position."] = "根据'生命值'文本位置调整缩短。"
L["Name Auto-Shorten"] = "名称自动缩短"
L["Appends a diminishing returns tracker to frames."] = "在框架中添加递减效果追踪器。"
L["DR Time"] = "DR 时间"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "DR 时间控制图标重置所需的时间。多个因素可能影响 DR 重置。如果您持续遇到 DR 重置精确度问题，可以更改此值。"
L["Test"] = "测试"
L["Players Only"] = "仅玩家"
L["Ignore NPCs when setting up icons."] = "设置图标时忽略 NPC。"
L["No Cooldown Numbers"] = "无冷却数字"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "前往'冷却文本' > '全局'进行设置。"
L["Color Borders"] = "颜色边框"
L["Spacing"] = "间距"
L["DR Strength Indicator: Text"] = "DR 强度指示器：文本"
L["DR Strength Indicator: Box"] = "DR 强度指示器：方框"
L["Good"] = "良好"
L["50% DR for hostiles, 100% DR for the player."] = "敌对目标 50% DR，玩家 100% DR。"
L["Neutral"] = "中性"
L["75% DR for all."] = "所有目标 75% DR。"
L["Bad"] = "不良"
L["100% DR for hostiles, 50% DR for the player."] = "敌对目标 100% DR，玩家 50% DR。"
L["Category Border"] = "类别边框"
L["Select Category"] = "选择类别"
L["Categories"] = "类别"
L["Add Category"] = "添加类别"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "格式：'类别 法术ID'，例如 fear 10890。\n所有类别列表可在'颜色'部分找到。"
L["Remove Category"] = "移除类别"
L["Category \"%s\" already exists, updating icon."] = "类别 \"%s\" 已存在，正在更新图标。"
L["Category \"%s\" added with %s icon."] = "已添加类别 \"%s\"，使用 %s 图标。"
L["Invalid category."] = "无效的类别。"
L["Category \"%s\" removed."] = "类别 \"%s\" 已移除。"
L["DetachPower"] = "分离能量"
L["NameAutoShorten"] = "名称自动缩短"
L["Color Filter"] = "颜色过滤器"
L["Enables color filter for the selected unit."] = "为选定的单位启用颜色过滤器。"
L["Toggle for the currently selected statusbar."] = "切换当前选定的状态条。"
L["Select Statusbar"] = "选择状态条"
L["Health"] = "生命值"
L["Castbar"] = "施法条"
L["Power"] = "能量"
L["Tab Section"] = "标签部分"
L["Toggle current tab."] = "切换当前标签。"
L["Tab Priority"] = "标签优先级"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "当符合多个条件时，将应用优先级最高的标签的颜色。"
L["Copy Tab"] = "复制标签"
L["Select a tab to copy its settings onto the current tab."] = "选择一个标签将其设置复制到当前标签。"
L["Flash"] = "闪烁"
L["Speed"] = "速度"
L["Glow"] = "发光"
L["Determines which glow to apply when statusbars are not detached from frame."] = "决定当状态条未从框架分离时应用哪种发光效果。"
L["Priority"] = "优先级"
L["When handling castbar, also manage its icon."] = "处理施法条时，同时管理其图标。"
L["CastBar Icon Glow Color"] = "施法条图标发光颜色"
L["CastBar Icon Glow Size"] = "施法条图标发光大小"
L["Borders"] = "边框"
L["CastBar Icon Color"] = "施法条图标颜色"
L["Toggle classbar borders."] = "切换职业条边框。"
L["Toggle infopanel borders."] = "切换信息面板边框。"
L["ClassBar Color"] = "职业条颜色"
L["Disabled unless classbar is enabled."] = "除非启用职业条，否则禁用。"
L["InfoPanel Color"] = "信息面板颜色"
L["Disabled unless infopanel is enabled."] = "除非启用信息面板，否则禁用。"
L["ClassBar Adapt To"] = "职业条适应于"
L["Copies the color of the selected bar."] = "复制所选条的颜色。"
L["InfoPanel Adapt To"] = "信息面板适应于"
L["Override Mode"] = "覆盖模式"
L["'None' - threat borders highlight will be prioritized over this one".. "\n'Threat' - this highlight will be prioritized."] = "'无' - 威胁边框高亮将优先于此高亮".. "\n'威胁' - 此高亮将优先。"
L["Threat"] = "威胁"
L["Determines which borders to apply when statusbars are not detached from frame."] = "决定当状态条未从框架分离时应用哪些边框。"
L["Bar-specific"] = "特定于条的"
L["Lua Section"] = "Lua 部分"
L["Conditions"] = "条件"
L["Font Settings"] = "字体设置"
L["Player Only"] = "仅玩家"
L["Handle only player combat log events."] = "仅处理玩家战斗日志事件。"
L["Rotate Icon"] = "旋转图标"
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
			"\n\n@@[raid, Health, 2, >5]@@ - 根据相关标签（在上面的例子中：'player' - 目标单位；'Power' - 目标状态条；'3' - 目标标签）是否处于活动状态来返回 true/false"..
			"\n(>/>=/<=/</~= num) - （可选，仅适用于群组单位）匹配群组内触发框架的特定数量（上面例子中大于 5）"..
			"\n\n'return true, {bR=1,f=false}' - 你可以通过以表格格式返回颜色来动态为框架上色："..
			"\n  要应用于状态条，请将你的 rgb 值分别指派给 mR、mG 和 mB"..
			"\n  要应用发光效果 - 指派给 gR、gG、gB、gA（透明度）"..
			"\n  边框颜色 - bR、bG、bB"..
			"\n  闪光效果 - fR、fG、fB、fA"..
			"\n  要防止元素样式，返回 {m = false, g = false, b = false, f = false}"..
			"\n\nFrame和unitID可在'frame'和'unit'中获得：UnitBuff(unit, 'player')/frame.Health:IsVisible().。"..
			"\n\n此模块解析字符串，所以请尝试让你的代码严格遵循语法，否则可能无法正常工作。"
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "除非按住修饰键，否则悬停在单位、物品和法术上不会显示工具提示。\n仅修改光标工具提示。"
L["Pick a..."] = "选择一个..."
L["...mover to anchor to."] = "...要锚定的移动器。"
L["...mover to anchor."] = "...锚定移动器。"
L["Point:"] = "点:"
L["Relative:"] = "相对:"
L["Open Editor"] = "打开编辑器"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "除非按住修饰键，否则鼠标悬停在单位上不会显示提示。\n仅显示光标提示。"
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "启用前请先停靠所有聊天框。\nShift-点击管理按钮以访问标签设置。"
L["Mouseover"] = "鼠标悬停"
L["Manager button visibility."] = "管理按钮可见性。"
L["Manager point."] = "管理点。"
L["Top Offset"] = "顶部偏移"
L["Bottom Offset"] = "底部偏移"
L["Left Offset"] = "左侧偏移"
L["Right Offset"] = "右侧偏移"
L["Chat Search and Filter"] = "聊天搜索和过滤"
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
		"聊天框的搜索和过滤工具。"..
			"\n\n语法："..
			"\n  :: - 'and' 语句"..
			"\n  ( ; ) - 'or' 语句"..
			"\n  ! ! - 'not' 语句"..
			"\n  [ ] - 区分大小写"..
			"\n  @ @ - lua 模式"..
			"\n\n示例消息："..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\n搜索查询和结果："..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - 空"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\n使用 Tab/Shift-Tab 在提示间导航。"..
			"\n右键点击搜索按钮以访问最近的查询。"..
			"\nShift-右键点击以访问搜索配置。"..
			"\nAlt-右键点击以查看被阻止的消息。"..
			"\nCtrl-右键点击以清除已过滤消息的缓存。"..
			"\n\n频道名称和时间戳不会被解析。"
L["Search button visibility."] = "搜索按钮可见性。"
L["Search button point."] = "搜索按钮点。"
L["Config Tooltips"] = "配置提示"
L["Highlight Color"] = "高亮颜色"
L["Match highlight color."] = "匹配高亮颜色。"
L["Filter Type"] = "过滤类型"
L["Rule Terms"] = "规则条款"
L["Same logic as with the search."] = "与搜索相同的逻辑。"
L["Select Chat Types"] = "选择聊天类型"
L["Say"] = "说"
L["Yell"] = "大喊"
L["Party"] = "队伍"
L["Raid"] = "团队"
L["Guild"] = "公会"
L["Battleground"] = "战场"
L["Whisper"] = "密语"
L["Channel"] = "频道"
L["Other"] = "其他"
L["Select Rule"] = "选择规则"
L["Select Chat Frame"] = "选择聊天框"
L["Add Rule"] = "添加规则"
L["Delete Rule"] = "删除规则"
L["Compact Chat"] = "简洁聊天"
L["Move left"] = "向左移动"
L["Move right"] = "向右移动"
L["Mouseover: Left"] = "鼠标悬停: 左侧"
L["Mouseover: Right"] = "鼠标悬停: 右侧"
L["Automatic Onset"] = "自动开始"
L["Scans tooltip texts and sets icons automatically."] = "扫描提示文本并自动设置图标。"
L["Icon (Default)"] = "图标 (默认)"
L["Icon (Kill)"] = "图标 (击杀)"
L["Icon (Chat)"] = "图标 (聊天)"
L["Icon (Item)"] = "图标 (物品)"
L["Show Text"] = "显示文本"
L["Display progress status."] = "显示进度状态。"
L["Name"] = "名称"
L["Frequent Updates"] = "频繁更新"
L["Events (optional)"] = "事件 (可选)"
L["InternalCooldowns"] = "内部冷却"
L["Displays internal cooldowns on trinket tooltips."] = "在饰品提示上显示内部冷却时间。"
L["Shortening X Offset"] = "缩短 X 偏移"
L["To Level"] = "到等级"
L["Names will be shortened based on level text position."] = "名称将根据等级文字的位置缩短。"
L["Add Item (by ID)"] = "添加物品（通过ID）"
L["Remove Item"] = "移除物品"
L["Pre-Load"] = "预加载"
L["Executes commands during the addon's initialization process."] = "在插件初始化过程中执行命令。"
L["Justify"] = "对齐"
L["Alt-Click: free bag slots, if possible."] = "Alt-点击：释放背包栏位（如果可能）。"
L["Click: toggle layout mode."] = "点击：切换布局模式。"
L["Alt-Click: re-evaluate all items."] = "Alt-点击：重新评估所有物品。"
L["Drag-and-Drop: evaluate and position the cursor item."] = "拖放：评估并定位光标上的物品。"
L["Shift-Alt-Click: toggle these hints."] = "Shift-Alt-点击：切换这些提示。"
L["Mouse-Wheel: navigate between special and normal bags."] = "鼠标滚轮：切换特殊与普通背包。"
L["This button accepts cursor item drops."] = "此按钮接受光标拖放的物品。"
L["Setup Sections"] = "设置分区"
L["Adds default sections set to the currently selected container."] = "将默认分区添加到当前选择的容器。"
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
		"处理自动物品定位。\n"..
			"语法：filter@value\n\n"..
			"可用过滤器：\n"..
			" id@number - 匹配 itemID，\n"..
			" name@string - 匹配名称，\n"..
			" type@string - 匹配类型，\n"..
			" subtype@string - 匹配子类型，\n"..
			" ilvl@number - 匹配物品等级，\n"..
			" uselevel@number - 匹配装备等级，\n"..
			" quality@number - 匹配品质，\n"..
			" equipslot@number - 匹配 InventorySlotID，\n"..
			" maxstack@number - 匹配堆叠上限，\n"..
			" price@number - 匹配售价，\n"..
			" tooltip@string - 匹配提示文字，\n"..
			" set@setName - 匹配装备套装物品。\n\n"..
			"所有字符串匹配不区分大小写，仅匹配字母数字符号。\n"..
			"标准 Lua 逻辑（and/or/括号等）适用。\n\n"..
			"使用示例（牧师 t8 或 Shadowmourne）：\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne。\n\n"..
			"支持自定义函数（bagID、slotID、itemID 可用）。\n"..
			"以下示例通知新获取的物品。\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('获得物品：' .. string)"
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
		"语法：filter@value@amount\n\n"..
			"可用过滤器：\n"..
			" id@number@amount(+)/+ - 匹配 itemID，\n"..
			" name@string@amount(+)/+ - 匹配名称，\n"..
			" type@string@amount(+)/+ - 匹配类型，\n"..
			" subtype@string@amount(+)/+ - 匹配子类型，\n"..
			" ilvl@number@amount(+)/+ - 匹配物品等级，\n"..
			" uselevel@number@amount(+)/+ - 匹配装备等级，\n"..
			" quality@number@amount(+)/+ - 匹配品质，\n"..
			" equipslot@number@amount(+)/+ - 匹配 InventorySlotID，\n"..
			" maxstack@number@amount(+)/+ - 匹配堆叠上限，\n"..
			" price@number@amount(+)/+ - 匹配售价，\n"..
			" tooltip@string@amount(+)/+ - 匹配提示文字。\n\n"..
			"可选的 'amount' 部分可以是：\n"..
			" 一个数字 - 购买固定数量，\n"..
			" + 符号 - 补充现有部分堆叠或购买新的，\n"..
			" 两者（例如 5+） - 购买足够的物品以达到指定总数（此例中为 5），\n"..
			" 省略 - 默认值为 1。\n\n"..
			"所有字符串匹配不区分大小写，仅匹配字母数字符号。\n"..
			"标准 Lua 逻辑（and/or/括号等）适用。\n\n"..
			"使用示例（牧师 t8 或 Shadowmourne）：\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne。"
L["PERIODIC"] = "周期性"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "在使用 /addOccupation 命令时按住此键以清除当前目标/鼠标悬停 NPC 的列表."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "在目标/鼠标悬停在 NPC 上时使用 /addOccupation 斜杠命令将其添加到列表中。再次使用以循环."
L["Style Filter Icons"] = "样式过滤器图标"
L["Custom icons for the style filter."] = "样式过滤器的自定义图标."
L["Whitelist"] = "白名单"
L["X Direction"] = "X方向"
L["Y Direction"] = "Y方向"
L["Create Icon"] = "创建图标"
L["Delete Icon"] = "删除图标"
L["0 to match frame width."] = "0 以匹配框架宽度。"
L["Remove a NPC"] = "移除 NPC"
L["Change a NPC's Occupation"] = "更改 NPC 的职业"
L["...to the currently selected one."] = "...为当前选择的职业。"
L["Select Occupation"] = "选择职业"
L["Sell"] = "出售"
L["Action Type"] = "操作类型"
L["Style Filter Additional Triggers"] = "样式过滤器额外触发器"
L["Triggers"] = "触发器"
L["Example usage:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"] =
    "示例用法:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == '史莱克'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == '菲奥娜')"
L["Abbreviate Name"] = "缩写名称"
L["Highlight Self"] = "突出自己"
L["Highlight Others"] = "突出他人"
L["Self Inherit Name Color"] = "继承自己的名字颜色"
L["Self Texture"] = "自己的材质"
L["Whitespace to disable, empty to default."] = "空格禁用，默认为空。"
L["Self Color"] = "自己的颜色"
L["Self Scale"] = "自己的比例"
L["Others Inherit Name Color"] = "继承他人的名字颜色"
L["Others Texture"] = "他人的材质"
L["Others Color"] = "他人的颜色"
L["Others Scale"] = "他人的比例"
L["Targets"] = "目标"