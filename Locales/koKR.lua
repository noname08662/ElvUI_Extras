local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "koKR")

L["Hits the 'Confirm' button automatically."] = "'확인' 버튼을 자동으로 클릭합니다."
L["Picks up items and money automatically."] = "아이템과 돈을 자동으로 줍습니다."
L["Automatically fills the 'DELETE' field."] = "'삭제' 필드를 자동으로 채웁니다."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "수정자 키를 누르지 않는 한, 대화 옵션이 하나만 있을 경우 자동으로 선택합니다.\n중요한 이벤트 트리거에 주의하세요. 안전장치가 없습니다."
L["Accepts and turns in quests automatically while holding a modifier."] = "수정자 키를 누른 상태에서 퀘스트를 자동으로 수락하고 완료합니다."
L["Loot info wiped."] = "전리품 정보가 지워졌습니다."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "/lootinfo 명령어로 최근 획득한 아이템을 빠르게 요약해줍니다.\n\n사용법: /lootinfo 사과 60\n'사과' - 아이템/플레이어 이름 \n(플레이어의 전리품을 얻으려면 @self 검색)\n'60' - \n시간 제한 (<60초 전), 선택 사항,\n/lootinfo !wipe - 전리품 캐시 삭제."
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "일부 메시지에서 온라인 친구와 길드원의 이름에 색을 입히고 주사위 굴림을 스타일링합니다.\n이미 처리된 채팅 말풍선은 /reload 전까지 스타일이 적용되지 않습니다."
L["Colors loot roll messages for you and other players."] = "당신과 다른 플레이어의 전리품 주사위 메시지에 색을 입힙니다."
L["Loot rolls icon size."] = "전리품 주사위 아이콘 크기."
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "전리품 바의 스타일을 변경합니다.\n'전리품 주사위' (일반 -> BlizzUI 개선 -> 전리품 주사위)가 활성화되어야 합니다 (이 모듈을 토글하면 자동으로 활성화됩니다)."
L["Displays the name of the player pinging the minimap."] = "미니맵을 핑한 플레이어의 이름을 표시합니다."
L["Displays the currently held currency amount next to the item prices."] = "아이템 가격 옆에 현재 보유 중인 화폐 금액을 표시합니다."
L["Narrows down the World(..Frame)."] = "월드(..프레임)를 좁힙니다."
L["'Out of mana', 'Ability is not ready yet', etc."] = "'마나 부족', '능력이 아직 준비되지 않음' 등."
L["Re-enable quest updates."] = "퀘스트 업데이트를 다시 활성화합니다."
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - 블리자드의 노란색."
L["Text to display upon entering combat."] = "전투에 진입할 때 표시할 텍스트입니다."
L["Text to display upon leaving combat."] = "전투를 종료할 때 표시할 텍스트입니다."
L["REQUIRES RELOAD."] = "재시작 필요."
L["Icon to the left or right of the item link."] = "아이템 링크의 왼쪽 또는 오른쪽에 아이콘을 표시합니다."
L["The size of the icon in the chat frame."] = "채팅 창에 표시할 아이콘의 크기입니다."
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "모든 프레임에 그림자를 추가합니다.\n이 플러그인의 선택적 폴더에서 관련 파일로 ElvUI/Core/Toolkit.lua를 교체하지 않으면 아무것도 하지 않습니다."
L["Combat state notification alerts."] = "전투 상태 알림 경고."
L["Custom editbox position and size."] = "사용자 정의 편집 상자 위치 및 크기."
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
		"사용법:"..
			"\n/tnote list - 모든 기존 노트를 반환합니다"..
			"\n/tnote wipe - 모든 기존 노트를 지웁니다"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - set과 동일합니다 (lua 부분 제외)"..
			"\n/tnote 1 get - set과 동일하며, 기존 노트를 반환합니다"..
			"\n/tnote 1 set 여기에노트 - 지정된 인덱스의 목록에 노트를 추가하거나 "..
			"두 번째 인수(이 경우 1)가 생략된 경우 현재 표시된 툴팁 텍스트에 추가합니다. "..
			"함수와 색상 지정을 지원합니다 "..
			"(텍스트를 제공하지 않으면 노트가 지워집니다);"..
			"\n줄을 나누려면 ::를 사용하세요"..
			"\n\n예시:"..
			"\n\n/tnote 3 set 화염 프리-비스::출처: 김말자"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(기본 색상)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "채팅 하이퍼링크 옆에 아이콘을 추가합니다."
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "가방에서 사용 가능한 퀘스트 아이템을 수집하는 새로운 액션 바입니다.\n\n상태 액션 제한으로 인해 이 모듈은 ElvUI Extra Action Bars에서 생성한 bar10을 덮어씁니다."
L["Toggles the display of the actionbar's backdrop."] = "액션 바 배경 표시를 전환합니다."
L["The frame will not be displayed unless hovered over."] = "마우스를 올리지 않으면 프레임이 표시되지 않습니다."
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "전역 페이드를 상속받아 마우스 오버, 대상 지정, 주시 설정, 체력 손실, 전투 진입 시 투명도를 제거합니다. 그렇지 않으면 전역 페이드 알파에 대한 일반 액션 바 설정의 투명도 레벨을 사용합니다."
L["The first button anchors itself to this point on the bar."] = "첫 번째 버튼이 바의 이 지점에 고정됩니다."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "수정자를 누른 상태에서 아이템을 우클릭하여 블랙리스트에 추가합니다. 블랙리스트에 있는 아이템은 바에 표시되지 않습니다.\n블랙리스트를 제거하려면 /questbarRestore를 사용하세요."
L["The number of buttons to display."] = "표시할 버튼의 수입니다."
L["The number of buttons to display per row."] = "행당 표시할 버튼의 수입니다."
L["The size of the action buttons."] = "액션 버튼의 크기입니다."
L["Spacing between the buttons."] = "버튼 사이의 간격입니다."
L["Spacing between the backdrop and the buttons."] = "배경과 버튼 사이의 간격입니다."
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "배경의 높이나 너비에 이 값을 곱합니다. 배경 뒤에 여러 개의 바를 두고 싶을 때 유용합니다."
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "이것은 매크로처럼 작동하며, 다양한 상황에서 액션 바를 다르게 표시/숨길 수 있습니다.\n 예: '[combat] showhide'"
L["Adds anchoring options to the movers' nudges."] = "이동기의 미세 조정에 고정 옵션을 추가합니다."
L["Mod-clicking an item suggests a skill/item to process it."] = "수정자 키를 누른 채 아이템을 클릭하면 처리할 기술/아이템을 제안합니다."
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"%s 를 누른 상태에서 스택을 왼쪽 클릭하면 두 개로 나뉩니다; 사용 가능한 복사본을 결합하려면 대신 오른쪽 클릭하세요."..
    "\n\n또한 SplitStackFrame을 수정하여 화살표 대신 편집 상자를 사용합니다."
L["Extends the bags functionality."] = "가방 기능을 확장합니다."
L["Default method: type > inventory slot ID > item level > name."] = "기본 방식: 유형 > 인벤토리 슬롯 ID > 아이템 레벨 > 이름."
L["Listed ItemIDs will not get sorted."] = "나열된 아이템 ID는 정렬되지 않습니다."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "예: Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "잘못된 조건 형식: "
L["The generated custom sorting method did not return a function."] = "생성된 사용자 정의 정렬 방식이 함수를 반환하지 않았습니다."
L["The loaded custom sorting method did not return a function."] = "로드된 사용자 정의 정렬 방식이 함수를 반환하지 않았습니다."
L["Item received: "] = "아이템 받음: "
L[" added."] = " 추가됨."
L[" removed."] = " 제거됨."
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
		"새로 받은 아이템의 자동 재배치를 처리합니다."..
		"\n구문: 필터@값\n\n"..
		"사용 가능한 필터:\n"..
		" id@숫자 - 아이템 ID와 일치,\n"..
		" name@문자열 - 이름과 일치,\n"..
		" subtype@문자열 - 하위 유형과 일치,\n"..
		" ilvl@숫자 - 아이템 레벨과 일치,\n"..
		" uselevel@숫자 - 장비 레벨과 일치,\n"..
		" quality@숫자 - 품질과 일치,\n"..
		" equipslot@숫자 - 인벤토리 슬롯 ID와 일치,\n"..
		" maxstack@숫자 - 최대 중첩 수와 일치,\n"..
		" price@숫자 - 판매 가격과 일치,\n\n"..
		" tooltip@문자열 - 툴팁 텍스트와 일치,\n\n"..
		"모든 문자열 일치는 대소문자를 구분하지 않으며 알파벳과 숫자 기호만 일치합니다. 표준 Lua 논리가 적용됩니다. "..
		"필터에 대한 자세한 정보는 GetItemInfo API를 참조하세요. "..
		"현지화된 유형 및 하위 유형 값을 얻으려면 GetAuctionItemClasses 및 GetAuctionItemSubClasses(경매장과 동일)를 사용하세요.\n\n"..
		"사용 예시 (사제 t8 또는 섀도무어느):\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@성화의) or name@섀도무어느.\n\n"..
		"사용자 정의 함수를 허용합니다 (bagID, slotID, itemID가 노출됨)\n"..
		"아래 예시는 새로 획득한 아이템을 알립니다.\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\\124', '\\124\\124')\n"..
		"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
		"print('아이템 획득: ' .. string)"
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
		"구문: 필터@값\n\n"..
			"사용 가능한 필터:\n"..
			" id@숫자 - 아이템ID와 일치,\n"..
			" name@문자열 - 이름과 일치,\n"..
			" type@문자열 - 유형과 일치,\n"..
			" subtype@문자열 - 하위 유형과 일치,\n"..
			" ilvl@숫자 - 아이템 레벨과 일치,\n"..
			" uselevel@숫자 - 장비 레벨과 일치,\n"..
			" quality@숫자 - 품질과 일치,\n"..
			" equipslot@숫자 - 인벤토리 슬롯ID와 일치,\n"..
			" maxstack@숫자 - 최대 중첩 수와 일치,\n"..
			" price@숫자 - 판매 가격과 일치,\n"..
			" tooltip@문자열 - 툴팁 텍스트와 일치.\n\n"..
			"모든 문자열 일치는 대소문자를 구분하지 않으며 영숫자 기호만 일치합니다.\n"..
			"분기에 대한 표준 lua 로직(and/or/괄호/등)이 적용됩니다.\n\n"..
			"사용 예시 (사제 t8 또는 섀도몬):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "사용 가능한 아이템 유형"
L["Lists all available item subtypes for each available item type."] =
	"사용 가능한 각 아이템 유형에 대한 모든 하위 유형을 나열합니다."
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"이 키를 누른 상태로 상인과 상호작용하면 자동 구매 설정에 맞는 모든 아이템을 구매합니다.\n"..
			"목록 항목을 모드 클릭하면 '@수량' 규칙에 관계없이 해당 아이템 하나만 구매합니다."
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] =
		"기본 방식: 유형 > 인벤토리 슬롯 ID > 아이템 레벨 > 이름.\n\n"..
		"사용자 정의 함수를 허용합니다 (bagID와 slotID는 a/b.bagID/slotID에서 사용 가능).\n\n"..
		"function(a,b)\n"..
		"--여기에 정렬 로직 작성\n"..
		"end\n\n"..
		"기본값을 사용하려면 비워두세요."
L["Event and OnUpdate handler."] = "이벤트 및 OnUpdate 처리기."
L["Minimal time gap between two consecutive executions."] = "연속 실행 사이의 최소 시간 간격."
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER 등.\nONUPDATE - 'OnUpdate' 스크립트"
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = "UNIT_AURA CHAT_MSG_WHISPER 등."
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
		"구문:"..
		"\n\nEVENT[n~=nil]"..
		"\n[n~=value]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@commands@@@"..
		"\n\n'EVENT' - 위의 이벤트 섹션의 이벤트"..
		"\n'n, m, k' - 원하는 페이로드 인수의 인덱스 (숫자)"..
		"\n'nil/value/boolean/lua code' - n 인수의 원하는 출력"..
		"\n'@@' - lua 인수 플래그, 인수 값 섹션 내의 lua 코드 앞에 와야 함"..
		"\n'~' - 부정 플래그, 등호 앞에 추가하여 n/m/k가 설정된 값과 일치하지 않을 때 코드 실행"..
		"\n'@@@ @@@' - 명령을 포함하는 괄호"..
		"\n평소와 같이 페이로드 (...)에 액세스할 수 있습니다."..
		"\n\n예시:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(플레이어가 오라를 얻거나 잃었습니다)@@@"..
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
		"\nthen print(UnitName('party'..i)..'가 영향을 받았습니다!')"..
		"\nend end@@@"..
		"\n\n이 모듈은 문자열을 구문 분석하므로 코드가 구문을 엄격히 따르도록 하십시오. 그렇지 않으면 작동하지 않을 수 있습니다."
L["Highlights auras."] = "오라를 강조합니다."
L["E.g. 42292"] = "예: 42292"
L["Applies highlights to all auras passing the selected filter."] = "선택한 필터를 통과하는 모든 오라를 강조합니다."
L["Priority: spell, filter, curable/stealable."] = "우선순위: 주문, 필터, 치료 가능/도둑질 가능."
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "활성화되면 전역 주문 또는 필터 값이 사용됩니다."
L["Makes auras grow sideswise."] = "오라가 옆으로 성장하게 합니다."
L["Turns off texture fill."] = "텍스처 채우기를 끕니다."
L["Makes auras flicker right before fading out."] = "사라지기 직전에 오라가 깜빡입니다."
L["Disables border coloring."] = "테두리 색상을 비활성화합니다."
L["Click Cancel"] = "클릭 시 취소"
L["Right-click a player buff to cancel it."] = "플레이어의 버프를 오른쪽 클릭하여 취소합니다."
L["Disables debuffs desaturation."] = "디버프의 색상 탈색을 비활성화합니다."
L["Saturated Debuffs"] = "채도가 높은 디버프"
L["Confirm Rolls"] = "주사위 굴림 확인"
L["Auto Pickup"] = "자동 획득"
L["Swift Buy"] = "빠른 구매"
L["Buys out items automatically."] = "아이템을 자동으로 구매합니다."
L["Failsafe"] = "안전 장치"
L["Enables popup confirmation dialog."] = "팝업 확인 대화 상자를 활성화합니다."
L["Add Set"] = "세트 추가"
L["Delete Set"] = "세트 삭제"
L["Select Set"] = "세트 선택"
L["Auto Buy"] = "자동 구매"
L["Fill Delete"] = "삭제 필드 채우기"
L["Gossip"] = "대화"
L["Accept Quest"] = "퀘스트 수락"
L["Loot Info"] = "전리품 정보"
L["Styled Messages"] = "스타일된 메시지"
L["Indicator Color"] = "표시기 색상"
L["Select Status"] = "상태 선택"
L["Select Indicator"] = "표시기 선택"
L["Styled Loot Messages"] = "스타일된 전리품 메시지"
L["Icon Size"] = "아이콘 크기"
L["Loot Bars"] = "전리품 바"
L["Bar Height"] = "바 높이"
L["Bar Width"] = "바 너비"
L["Player Pings"] = "플레이어 핑"
L["Held Currency"] = "보유 통화"
L["LetterBox"] = "레터박스"
L["Left"] = "왼쪽"
L["Right"] = "오른쪽"
L["Top"] = "위"
L["Bottom"] = "아래"
L["Hide Errors"] = "오류 숨기기"
L["Show quest updates"] = "퀘스트 업데이트 표시"
L["Less Tooltips"] = "툴팁 줄이기"
L["Misc."] = "기타"
L["Loot&Style"] = "전리품 및 스타일"
L["Automation"] = "자동화"
L["Bags"] = "가방"
L["Easier Processing"] = "쉬운 처리"
L["Modifier"] = "수정자"
L["Split Stack"] = "스택 분할"
L["Bags Extended"] = "가방 확장"
L["Select Container Type"] = "컨테이너 유형 선택"
L["Settings"] = "설정"
L["Add Section"] = "섹션 추가"
L["Delete Section"] = "섹션 삭제"
L["Select Section"] = "섹션 선택"
L["Section Priority"] = "섹션 우선순위"
L["Section Spacing"] = "섹션 간격"
L["Collection Method"] = "수집 방법"
L["Sorting Method"] = "정렬 방법"
L["Ignore Item (by ID)"] = "아이템 무시 (ID별)"
L["Remove Ignored"] = "무시된 항목 제거"
L["Title"] = "제목"
L["Color"] = "색상"
L["Attach to Icon"] = "아이콘에 첨부"
L["Text"] = "텍스트"
L["Font Size"] = "글꼴 크기"
L["Font"] = "글꼴"
L["Font Flags"] = "글꼴 플래그"
L["Point"] = "포인트"
L["Relative Point"] = "상대 포인트"
L["X Offset"] = "X 오프셋"
L["Y Offset"] = "Y 오프셋"
L["Icon"] = "아이콘"
L["Attach to Text"] = "텍스트에 첨부"
L["Texture"] = "텍스처"
L["Size"] = "크기"
L["MoversPlus"] = "이동기Plus"
L["Movers Plus"] = "이동기 Plus"
L["CustomCommands"] = "사용자 정의 명령어"
L["Custom Commands"] = "사용자 정의 명령어"
L["QuestBar"] = "퀘스트 바"
L["Quest Bar"] = "퀘스트 바"
L["Settings"] = "설정"
L["Backdrop"] = "배경"
L["Show Empty Buttons"] = "빈 버튼 표시"
L["Mouse Over"] = "마우스 오버"
L["Inherit Global Fade"] = "전역 페이드 상속"
L["Anchor Point"] = "앵커 포인트"
L["Modifier"] = "수정자"
L["Buttons"] = "버튼"
L["Buttons Per Row"] = "행당 버튼 수"
L["Button Size"] = "버튼 크기"
L["Button Spacing"] = "버튼 간격"
L["Backdrop Spacing"] = "배경 간격"
L["Height Multiplier"] = "높이 배수"
L["Width Multiplier"] = "너비 배수"
L["Alpha"] = "투명도"
L["Visibility State"] = "가시성 상태"
L["Enable Tab"] = "탭 활성화"
L["Throttle Time"] = "제한 시간"
L["Select Tab"] = "탭 선택"
L["Select Event"] = "이벤트 선택"
L["Rename Tab"] = "탭 이름 변경"
L["Add Tab"] = "탭 추가"
L["Delete Tab"] = "탭 삭제"
L["Open Edit Frame"] = "편집 프레임 열기"
L["Events"] = "이벤트"
L["Commands to execute"] = "실행할 명령어"
L["Sub-Section"] = "하위 섹션"
L["Select"] = "선택"
L["Icon Orientation"] = "아이콘 방향"
L["Icon Size"] = "아이콘 크기"
L["Height Offset"] = "높이 오프셋"
L["Width Offset"] = "너비 오프셋"
L["Text Color"] = "텍스트 색상"
L["Entering combat"] = "전투 진입"
L["Leaving combat"] = "전투 종료"
L["Font"] = "글꼴"
L["Font Outline"] = "글꼴 외곽선"
L["Font Size"] = "글꼴 크기"
L["Texture Width"] = "텍스처 너비"
L["Texture Height"] = "텍스처 높이"
L["Custom Texture"] = "사용자 정의 텍스처"
L["ItemIcons"] = "아이템 아이콘"
L["TooltipNotes"] = "툴팁 노트"
L["ChatEditBox"] = "채팅 편집 상자"
L["EnterCombatAlert"] = "전투 알림 진입"
L["GlobalShadow"] = "전역 그림자"
L["Any"] = "어느"
L["Guildmate"] = "길드원"
L["Friend"] = "친구"
L["Self"] = "나"
L["New Tab"] = "새 탭"
L["None"] = "없음"
L["Version: "] = "버전: "
L["Color A"] = "색상 A"
L["Chat messages, etc."] = "채팅 메시지 등."
L["Color B"] = "색상 B"
L["Plugin Color"] = "플러그인 색상"
L["Icons Browser"] = "아이콘 브라우저"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "더 깔끔하고 잘린 아이콘을 보려면 https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html 을 받으세요."
L["Add Texture"] = "텍스처 추가"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "일반 텍스처 목록에 텍스처를 추가합니다.\n예: Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "텍스처 제거"
L["Highlights"] = "강조"
L["Select Type"] = "유형 선택"
L["Highlights Settings"] = "강조 설정"
L["Add Spell (by ID)"] = "주문 추가 (ID로)"
L["Add Filter"] = "필터 추가"
L["Remove Selected"] = "선택 항목 제거"
L["Select Spell or Filter"] = "주문 또는 필터 선택"
L["Use Global Settings"] = "전역 설정 사용"
L["Selected Spell or Filter Values"] = "선택된 주문 또는 필터 값"
L["Enable Shadow"] = "그림자 활성화"
L["Size"] = "크기"
L["Shadow Color"] = "그림자 색상"
L["Enable Border"] = "테두리 활성화"
L["Border Color"] = "테두리 색상"
L["Centered Auras"] = "중앙 정렬된 오라"
L["Cooldown Disable"] = "쿨다운 비활성화"
L["Animate Fade-Out"] = "페이드 아웃 애니메이션"
L["Type Borders"] = "유형 테두리"
L[" filter added."] = " 필터가 추가되었습니다."
L[" filter removed."] = " 필터가 제거되었습니다."
L["GLOBAL"] = "전역"
L["CURABLE"] = "치료 가능"
L["STEALABLE"] = "훔칠 수 있음"
L["--Filters--"] = "--필터--"
L["--Spells--"] = "--주문--"
L["FRIENDLY"] = "우호적"
L["ENEMY"] = "적대적"
L["AuraBars"] = "오라 바"
L["Auras"] = "오라"
L["ClassificationIndicator"] = "분류 표시기"
L["ClassificationIcons"] = "분류 아이콘"
L["ColorFilter"] = "색상 필터"
L["Cooldowns"] = "쿨다운"
L["DRTracker"] = "DR 추적기"
L["Guilds&Titles"] = "길드와 칭호"
L["Name&Level"] = "이름과 레벨"
L["QuestIcons"] = "퀘스트 아이콘"
L["StyleFilter"] = "스타일 필터"
L["Search:"] = "검색:"
L["Click to select."] = "클릭하여 선택하세요."
L["Click to select."] = "선택하려면 클릭하세요."
L["Hover again to see the changes."] = "변경 사항을 보려면 다시 마우스를 올리세요."
L["Note set for "] = "노트 설정 대상: "
L["Note cleared for "] = "노트 삭제 대상: "
L["No note to clear for "] = "삭제할 노트가 없습니다: "
L["Added icon to the note for "] = "노트에 아이콘 추가 대상: "
L["Note icon cleared for "] = "노트 아이콘 삭제 대상: "
L["No note icon to clear for "] = "삭제할 노트 아이콘이 없습니다: "
L["Current note for "] = "현재 노트 대상: "
L["No note found for this tooltip."] = "이 툴팁에 대한 노트를 찾을 수 없습니다."
L["Notes: "] = "노트: "
L["No notes are set."] = "설정된 노트가 없습니다."
L["No tooltip is currently shown or unsupported tooltip type."] = "현재 표시된 툴팁이 없거나 지원되지 않는 툴팁 유형입니다."
L["All notes have been cleared."] = "모든 노트가 삭제되었습니다."
L["Accept"] = "수락"
L["Cancel"] = "취소"
L["Purge Cache"] = "캐시 정리"
L["Guilds"] = "길드"
L["Separator"] = "구분자"
L["X Offset"] = "X 오프셋"
L["Y Offset"] = "Y 오프셋"
L["Level"] = "레벨"
L["Visibility State"] = "가시성 상태"
L["City (Resting)"] = "도시 (휴식)"
L["PvP"] = "PvP"
L["Arena"] = "투기장"
L["Party"] = "파티"
L["Raid"] = "공격대"
L["Colors"] = "색상"
L["Guild"] = "길드"
L["All"] = "모두"
L["Occupation Icon"] = "직업 아이콘"
L["OccupationIcon"] = "직업 아이콘"
L["Size"] = "크기"
L["Anchor"] = "앵커"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "직업 제거"
L["Modifier"] = "수정자"
L["Add Texture Path"] = "텍스처 경로 추가"
L["Remove Selected Texture"] = "선택한 텍스처 제거"
L["Titles"] = "칭호"
L["Reaction Color"] = "반응 색상"
L["Color based on reaction type."] = "반응 유형에 따른 색상."
L["Nameplates"] = "이름표"
L["Unitframes"] = "유닛프레임"
L["An icon similar to the minimap search."] = "미니맵 검색과 유사한 아이콘입니다."
L["Displays player guild text."] = "플레이어의 길드 텍스트를 표시합니다."
L["Displays NPC occupation text."] = "NPC의 직업 텍스트를 표시합니다."
L["Strata"] = "계층"
L["Mark"] = "표시"
L["Mark the target/mouseover plate."] = "대상/마우스오버 이름표를 표시합니다."
L["Unmark"] = "표시 해제"
L["Unmark the target/mouseover plate."] = "대상/마우스오버 이름표의 표시를 해제합니다."
L["Selected Type"] = "선택된 유형"
L["Reaction based coloring for non-cached characters."] = "캐시되지 않은 캐릭터에 대한 반응 기반 색상 지정."
L["Apply Custom Color"] = "사용자 지정 색상 적용"
L["Class Color"] = "직업 색상"
L["Use class colors."] = "직업 색상을 사용합니다."
L["Unmark All"] = "모두 표시 해제"
L["Unmark all plates."] = "모든 이름표의 표시를 해제합니다."
L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"] =
	"사용법: '/qmark' 매크로를 원하는 키에 바인딩하세요.\n\n수정자 키 바인딩도 해제하는 것을 잊지 마세요!"
L["Use Backdrop"] = "배경 사용"
L["Linked Style Filter Triggers"] = "연결된 스타일 필터 트리거"
L["Select Link"] = "링크 선택"
L["New Link"] = "새 링크"
L["Delete Link"] = "링크 삭제"
L["Target Filter"] = "대상 필터"
L["Select a filter to trigger the styling."] = "스타일을 트리거할 필터를 선택하세요."
L["Apply Filter"] = "필터 적용"
L["Select a filter to style the frames not passing the target filter triggers."] = "대상 필터 트리거를 통과하지 못한 프레임에 스타일을 적용할 필터를 선택하세요."
L["Cache purged."] = "캐시 삭제됨."
L["Test Mode"] = "테스트 모드"
L["Draws player cooldowns."] = "플레이어 재사용 대기시간을 표시합니다."
L["Show Everywhere"] = "모든 곳에 표시"
L["Show in Cities"] = "도시에서 표시"
L["Show in Battlegrounds"] = "전장에서 표시"
L["Show in Arenas"] = "투기장에서 표시"
L["Show in Instances"] = "인스턴스에서 표시"
L["Show in the World"] = "월드에서 표시"
L["Header"] = "헤더"
L["Icons"] = "아이콘"
L["OnUpdate Throttle"] = "업데이트 제한"
L["Trinket First"] = "장신구 우선"
L["Animate Fade Out"] = "페이드 아웃 애니메이션"
L["Border Color"] = "테두리 색상"
L["Growth Direction"] = "성장 방향"
L["Sort Method"] = "정렬 방식"
L["Icon Size"] = "아이콘 크기"
L["Icon Spacing"] = "아이콘 간격"
L["Per Row"] = "행당"
L["Max Rows"] = "최대 행"
L["CD Text"] = "재사용 대기시간 텍스트"
L["Show"] = "표시"
L["Cooldown Fill"] = "재사용 대기시간 채우기"
L["Reverse"] = "역순"
L["Direction"] = "방향"
L["Spells"] = "주문"
L["Add Spell (by ID)"] = "주문 추가 (ID로)"
L["Remove Selected Spell"] = "선택한 주문 제거"
L["Select Spell"] = "주문 선택"
L["Shadow"] = "그림자"
L["Pet Ability"] = "소환수 능력"
L["Shadow Size"] = "그림자 크기"
L["Shadow Color"] = "그림자 색상"
L["Sets update speed threshold."] = "업데이트 속도 임계값을 설정합니다."
L["Makes PvP trinkets and human racial always get positioned first."] = "PvP 장신구와 인간 종족 특성을 항상 먼저 배치합니다."
L["Makes icons flash when the cooldown's about to end."] = "재사용 대기시간이 거의 끝나갈 때 아이콘을 깜박이게 합니다."
L["Any value apart from black (0,0,0) would override borders by time left."] = "검정색(0,0,0)을 제외한 모든 값은 남은 시간에 따라 테두리를 덮어씁니다."
L["Colors borders by time left."] = "남은 시간에 따라 테두리 색상을 변경합니다."
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "형식: '주문ID 재사용 대기시간', 예: 42292 120"
L["For the important stuff."] = "중요한 것들을 위해."
L["Pet casts require some special treatment."] = "소환수 시전은 특별한 처리가 필요합니다."
L["Color by Type"] = "유형별 색상"
L["Flip Icon"] = "아이콘 뒤집기"
L["Texture List"] = "텍스처 목록"
L["Keep Icon"] = "아이콘 유지"
L["Texture"] = "텍스처"
L["Texture Coordinates"] = "텍스처 좌표"
L["Select Affiliation"] = "소속 선택"
L["Width"] = "너비"
L["Height"] = "높이"
L["Select Class"] = "직업 선택"
L["Points"] = "포인트"
L["Colors the icon based on the unit type."] = "유닛 유형에 따라 아이콘 색상을 지정합니다."
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "아이콘을 가로로 뒤집습니다. 텍스처 좌표와 호환되지 않습니다."
L["Keep the original icon texture."] = "원래 아이콘 텍스처를 유지합니다."
L["NPCs"] = "NPC"
L["Players"] = "플레이어"
L["By duration, ascending."] = "지속 시간별, 오름차순."
L["By duration, descending."] = "지속 시간별, 내림차순."
L["By time used, ascending."] = "사용 시간별, 오름차순."
L["By time used, descending."] = "사용 시간별, 내림차순."
L["Additional settings for the Elite Icon."] = "정예 아이콘에 대한 추가 설정."
L["Player class icons."] = "플레이어 직업 아이콘."
L["Class Icons"] = "직업 아이콘"
L["Vector Class Icons"] = "벡터 직업 아이콘"
L["Class Crests"] = "직업 문장"
L["Floating Combat Feedback"] = "부유하는 전투 피드백"
L["Select Unit"] = "유닛 선택"
L["player"] = "플레이어 (player)"
L["target"] = "대상 (target)"
L["targettarget"] = "대상의 대상 (targettarget)"
L["targettargettarget"] = "대상의 대상의 대상 (targettargettarget)"
L["focus"] = "주시 대상 (focus)"
L["focustarget"] = "주시 대상의 대상 (focustarget)"
L["pet"] = "소환수 (pet)"
L["pettarget"] = "소환수의 대상 (pettarget)"
L["raid"] = "공격대 (raid)"
L["raid40"] = "40인 공격대 (raid40)"
L["raidpet"] = "공격대 소환수 (raidpet)"
L["party"] = "파티 (party)"
L["partypet"] = "파티 소환수 (partypet)"
L["partytarget"] = "파티 대상 (partytarget)"
L["boss"] = "보스 (boss)"
L["arena"] = "투기장 (arena)"
L["assist"] = "지원 (assist)"
L["assisttarget"] = "지원 대상 (assisttarget)"
L["tank"] = "탱커 (tank)"
L["tanktarget"] = "탱커 대상 (tanktarget)"
L["Scroll Time"] = "스크롤 시간"
L["Event Settings"] = "이벤트 설정"
L["Event"] = "이벤트"
L["Disable Event"] = "이벤트 비활성화"
L["School"] = "계열"
L["Use School Colors"] = "계열 색상 사용"
L["Colors"] = "색상"
L["Color (School)"] = "색상 (계열)"
L["Animation Type"] = "애니메이션 유형"
L["Custom Animation"] = "사용자 정의 애니메이션"
L["Flag Settings"] = "플래그 설정"
L["Flag"] = "플래그"
L["Font Size Multiplier"] = "글꼴 크기 배수"
L["Animation by Flag"] = "플래그별 애니메이션"
L["Icon Settings"] = "아이콘 설정"
L["Show Icon"] = "아이콘 표시"
L["Icon Position"] = "아이콘 위치"
L["Bounce"] = "튀기기"
L["Blacklist"] = "블랙리스트"
L["Appends floating combat feedback fontstrings to frames."] = "프레임에 부유하는 전투 피드백 폰트 문자열을 추가합니다."
L["There seems to be a font size limit?"] = "글꼴 크기 제한이 있는 것 같습니다?"
L["Not every event is eligible for this. But some are."] = "모든 이벤트가 이에 적합한 것은 아닙니다. 하지만 일부는 그렇습니다."
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "사용자 정의 애니메이션을 lua 함수로 정의하세요.\n\n예:\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "대신 이 섹션에서 플래그 애니메이션을 처리하도록 전환합니다.\n\n모든 이벤트에 플래그가 있는 것은 아닙니다."
L["Flip position left-right."] = "위치를 좌우로 뒤집습니다."
L["E.g. 42292"] = "예: 42292"
L["Loaded custom animation did not return a function."] = "로드된 사용자 정의 애니메이션이 함수를 반환하지 않았습니다."
L["Before Text"] = "이전 텍스트"
L["After Text"] = "이후 텍스트"
L["Remove Spell"] = "주문 제거"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"사용자 정의 애니메이션을 lua 함수로 정의하세요.\n\n예시:\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "흡수"
L["BLOCK"] = "방어"
L["CRITICAL"] = "치명타"
L["CRUSHING"] = "강타"
L["GLANCING"] = "빗맞음"
L["RESIST"] = "저항"
L["Diagonal"] = "대각선"
L["Fountain"] = "분수"
L["Horizontal"] = "수평"
L["Random"] = "무작위"
L["Static"] = "정적"
L["Vertical"] = "수직"
L["DEFLECT"] = "빗나감"
L["DODGE"] = "회피"
L["ENERGIZE"] = "에너지 회복"
L["EVADE"] = "회피"
L["HEAL"] = "치유"
L["IMMUNE"] = "면역"
L["INTERRUPT"] = "차단"
L["MISS"] = "빗나감"
L["PARRY"] = "무기 막기"
L["REFLECT"] = "반사"
L["WOUND"] = "상처"
L["Debuff applied/faded/refreshed"] = "디버프 적용/사라짐/갱신"
L["Buff applied/faded/refreshed"] = "버프 적용/사라짐/갱신"
L["Physical"] = "물리"
L["Holy"] = "신성"
L["Fire"] = "화염"
L["Nature"] = "자연"
L["Frost"] = "냉기"
L["Shadow"] = "암흑"
L["Arcane"] = "비전"
L["Astral"] = "천상"
L["Chaos"] = "혼돈"
L["Elemental"] = "원소"
L["Magic"] = "마법"
L["Plague"] = "역병"
L["Radiant"] = "광채"
L["Shadowflame"] = "암흑불꽃"
L["Shadowfrost"] = "암흑서리"
L["Up"] = "위"
L["Down"] = "아래"
L["Classic Style"] = "클래식 스타일"
L["If enabled, default cooldown style will be used."] = "활성화하면 기본 재사용 대기시간 스타일이 사용됩니다."
L["Classification Indicator"] = "분류 지시기"
L["Copy Unit Settings"] = "유닛 설정 복사"
L["Enable Player Class Icons"] = "플레이어 클래스 아이콘 활성화"
L["Enable NPC Classification Icons"] = "NPC 분류 아이콘 활성화"
L["Type"] = "유형"
L["Select unit type."] = "유닛 유형 선택."
L["World Boss"] = "월드 보스"
L["Elite"] = "정예"
L["Rare"] = "희귀"
L["Rare Elite"] = "희귀 정예"
L["Class Spec Icons"] = "클래스 전문화 아이콘"
L["Classification Textures"] = "분류 텍스처"
L["Use Nameplates' Icons"] = "이름표 아이콘 사용"
L["Color enemy NPC icon based on the unit type."] = "유닛 유형에 따라 적 NPC 아이콘 색상 지정."
L["Strata and Level"] = "계층 및 레벨"
L["Warrior"] = "전사"
L["Warlock"] = "흑마법사"
L["Priest"] = "사제"
L["Paladin"] = "성기사"
L["Druid"] = "드루이드"
L["Rogue"] = "도적"
L["Mage"] = "마법사"
L["Hunter"] = "사냥꾼"
L["Shaman"] = "주술사"
L["Deathknight"] = "죽음의 기사"
L["Aura Bars"] = "오라 바"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "오라 바에 대한 추가 구성 옵션을 추가합니다.\n\n 크기 및 분리와 같은 옵션은 ElvUI 오라 바 이동기를 사용하세요!"
L["Hide"] = "숨기기"
L["Spell Name"] = "주문 이름"
L["Spell Time"] = "주문 시간"
L["Bounce Icon Points"] = "아이콘 포인트 바운스"
L["Set icon to the opposite side of the bar each new bar."] = "각 새 바마다 아이콘을 바의 반대쪽에 설정합니다."
L["Flip Starting Position"] = "시작 위치 뒤집기"
L["0 to disable."] = "0으로 설정하여 비활성화."
L["Detach All"] = "모두 분리"
L["Detach Power"] = "파워 분리"
L["Detaches power for the currently selected group."] = "현재 선택된 그룹의 파워를 분리합니다."
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "이름판에서 이름이 줄어드는 방식과 유사하게 이름을 줄입니다. 이름 설정에서 '텍스트 위치'를 왼쪽으로 설정하세요."
L["Anchor to Health"] = "체력에 고정"
L["Adjusts the shortening based on the 'Health' text position."] = "'체력' 텍스트 위치에 따라 줄임을 조정합니다."
L["Name Auto-Shorten"] = "이름 자동 줄이기"
L["Appends a diminishing returns tracker to frames."] = "프레임에 점감 효과 추적기를 추가합니다."
L["DR Time"] = "DR 시간"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "DR 시간은 아이콘이 재설정되는 데 걸리는 시간을 제어합니다. 여러 요인이 DR 재설정에 영향을 줄 수 있습니다. DR 재설정 정확도에 지속적인 문제가 있다면 이 값을 변경할 수 있습니다."
L["Test"] = "테스트"
L["Players Only"] = "플레이어만"
L["Ignore NPCs when setting up icons."] = "아이콘 설정 시 NPC 무시."
L["No Cooldown Numbers"] = "재사용 대기시간 숫자 없음"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "설정하려면 '재사용 대기시간 텍스트' > '전역'으로 이동하세요."
L["Color Borders"] = "테두리 색상"
L["Spacing"] = "간격"
L["DR Strength Indicator: Text"] = "DR 강도 표시기: 텍스트"
L["DR Strength Indicator: Box"] = "DR 강도 표시기: 상자"
L["Good"] = "좋음"
L["50% DR for hostiles, 100% DR for the player."] = "적대적 대상에게 50% DR, 플레이어에게 100% DR."
L["Neutral"] = "중립"
L["75% DR for all."] = "모두에게 75% DR."
L["Bad"] = "나쁨"
L["100% DR for hostiles, 50% DR for the player."] = "적대적 대상에게 100% DR, 플레이어에게 50% DR."
L["Category Border"] = "카테고리 테두리"
L["Select Category"] = "카테고리 선택"
L["Categories"] = "카테고리"
L["Add Category"] = "카테고리 추가"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "형식: '카테고리 주문ID', 예: fear 10890.\n모든 카테고리 목록은 '색상' 섹션에서 확인할 수 있습니다."
L["Remove Category"] = "카테고리 제거"
L["Category \"%s\" already exists, updating icon."] = "카테고리 \"%s\"가 이미 존재합니다. 아이콘을 업데이트합니다."
L["Category \"%s\" added with %s icon."] = "카테고리 \"%s\"가 %s 아이콘과 함께 추가되었습니다."
L["Invalid category."] = "유효하지 않은 카테고리입니다."
L["Category \"%s\" removed."] = "카테고리 \"%s\"가 제거되었습니다."
L["DetachPower"] = "파워분리"
L["NameAutoShorten"] = "이름자동단축"
L["Color Filter"] = "색상 필터"
L["Enables color filter for the selected unit."] = "선택한 유닛에 대한 색상 필터를 활성화합니다."
L["Toggle for the currently selected statusbar."] = "현재 선택된 상태 바에 대해 토글합니다."
L["Select Statusbar"] = "상태 바 선택"
L["Health"] = "생명력"
L["Castbar"] = "시전 바"
L["Power"] = "자원"
L["Tab Section"] = "탭 섹션"
L["Toggle current tab."] = "현재 탭 토글."
L["Tab Priority"] = "탭 우선순위"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "여러 조건이 충족될 때, 가장 높은 우선순위를 가진 탭의 색상이 적용됩니다."
L["Copy Tab"] = "탭 복사"
L["Select a tab to copy its settings onto the current tab."] = "현재 탭에 설정을 복사할 탭을 선택하세요."
L["Flash"] = "플래시"
L["Speed"] = "속도"
L["Glow"] = "발광"
L["Determines which glow to apply when statusbars are not detached from frame."] = "상태 바가 프레임에서 분리되지 않았을 때 적용할 발광을 결정합니다."
L["Priority"] = "우선순위"
L["When handling castbar, also manage its icon."] = "시전 바를 처리할 때 아이콘도 관리합니다."
L["CastBar Icon Glow Color"] = "시전 바 아이콘 발광 색상"
L["CastBar Icon Glow Size"] = "시전 바 아이콘 발광 크기"
L["Borders"] = "테두리"
L["CastBar Icon Color"] = "시전 바 아이콘 색상"
L["Toggle classbar borders."] = "클래스바 테두리 토글."
L["Toggle infopanel borders."] = "정보 패널 테두리 토글."
L["ClassBar Color"] = "클래스바 색상"
L["Disabled unless classbar is enabled."] = "클래스바가 활성화되지 않으면 비활성화됩니다."
L["InfoPanel Color"] = "정보 패널 색상"
L["Disabled unless infopanel is enabled."] = "정보 패널이 활성화되지 않으면 비활성화됩니다."
L["ClassBar Adapt To"] = "클래스바 적응"
L["Copies the color of the selected bar."] = "선택한 바의 색상을 복사합니다."
L["InfoPanel Adapt To"] = "정보 패널 적응"
L["Override Mode"] = "오버라이드 모드"
L["'None' - threat borders highlight will be prioritized over this one"..
    "\n'Threat' - this highlight will be prioritized."] =
		"'없음' - 위협 테두리 강조가 우선시됩니다"..
		"\n'위협' - 이 강조가 우선시됩니다."
L["Threat"] = "위협"
L["Determines which borders to apply when statusbars are not detached from frame."] = "상태 바가 프레임에서 분리되지 않았을 때 적용할 테두리를 결정합니다."
L["Bar-specific"] = "바 특정"
L["Lua Section"] = "Lua 섹션"
L["Conditions"] = "조건"
L["Font Settings"] = "글꼴 설정"
L["Player Only"] = "플레이어만"
L["Handle only player combat log events."] = "플레이어 전투 로그 이벤트만 처리합니다."
L["Rotate Icon"] = "아이콘 회전"
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
		"사용 예시:"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
			"\n    return true, {mR = r, mG = g, mB = b}"..
			"\nelseif UnitIsUnit(unit, 'target') then"..
			"\n    return true"..
			"\nend"..
			"\n\n@@[raid, Health, 2, >5]@@ - 해당 탭 (위 예시에서: 'player' - 대상 유닛; 'Power' - 대상 상태 바; '3' - 대상 탭) "..
			"이 활성화되어 있는지 여부에 따라 true/false를 반환합니다"..
			"\n(>/>=/<=/</~= num) - (선택적, 그룹 유닛만 해당) 그룹 내에서 트리거된 프레임의 특정 개수와 일치 (위 예시에서는 5개 초과)"..
			"\n\n'return true, {bR=1,f=false}' - 색상을 테이블 형식으로 반환하여 프레임을 동적으로 색칠할 수 있습니다:"..
			"\n  상태 바에 적용하려면 rgb 값을 각각 mR, mG, mB에 할당하세요"..
			"\n  발광 효과를 적용하려면 gR, gG, gB, gA(알파)에 할당하세요"..
			"\n  테두리는 bR, bG, bB에 할당하세요"..
			"\n  그리고 플래시는 fR, fG, fB, fA에 할당하세요"..
			"\n  요소 스타일링을 방지하려면 {m = false, g = false, b = false, f = false}를 반환하세요"..
			"\n\n'frame'과 'unit'에서 각각 Frame 및 unitID 사용 가능: UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
			"\n\n이 모듈은 문자열을 분석하므로 코드가 구문을 엄격히 따르도록 하세요. 그렇지 않으면 작동하지 않을 수 있습니다."
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "수정 키를 누르지 않으면 유닛, 아이템, 주문에 마우스를 올려도 툴팁이 표시되지 않습니다.\n커서 툴팁만 수정됩니다."
L["Pick a..."] = "...선택하세요"
L["...mover to anchor to."] = "...고정할 요소를 선택하세요."
L["...mover to anchor."] = "...고정할 요소."
L["Point:"] = "지점:"
L["Relative:"] = "상대적:"
L["Open Editor"] = "편집기 열기"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "수정자를 누르지 않으면 유닛에 마우스를 올려도 툴팁이 표시되지 않습니다.\n커서 툴팁만 표시됩니다."
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "활성화하기 전에 모든 채팅 창을 도킹하세요.\n관리자 버튼을 Shift-클릭하여 탭 설정에 액세스하세요."
L["Mouseover"] = "마우스오버"
L["Manager button visibility."] = "관리자 버튼 가시성."
L["Manager point."] = "관리자 포인트."
L["Top Offset"] = "상단 오프셋"
L["Bottom Offset"] = "하단 오프셋"
L["Left Offset"] = "왼쪽 오프셋"
L["Right Offset"] = "오른쪽 오프셋"
L["Chat Search and Filter"] = "채팅 검색 및 필터"
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
		"채팅 창을 위한 검색 및 필터 유틸리티."..
			"\n\n구문:"..
			"\n  :: - 'and' 문"..
			"\n  ( ; ) - 'or' 문"..
			"\n  ! ! - 'not' 문"..
			"\n  [ ] - 대소문자 구분"..
			"\n  @ @ - lua 패턴"..
			"\n\n샘플 메시지:"..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\n검색 쿼리 및 결과:"..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - 빈 결과"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\n탭/Shift-탭으로 프롬프트 탐색."..
			"\n검색 버튼 우클릭으로 최근 쿼리 액세스."..
			"\nShift-우클릭으로 검색 설정 액세스."..
			"\nAlt-우클릭으로 차단된 메시지 확인."..
			"\nCtrl-우클릭으로 필터링된 메시지 캐시 삭제."..
			"\n\n채널 이름과 타임스탬프는 파싱되지 않습니다."
L["Search button visibility."] = "검색 버튼 가시성."
L["Search button point."] = "검색 버튼 포인트."
L["Config Tooltips"] = "설정 툴팁"
L["Highlight Color"] = "강조 색상"
L["Match highlight color."] = "일치 강조 색상."
L["Filter Type"] = "필터 유형"
L["Rule Terms"] = "규칙 용어"
L["Same logic as with the search."] = "검색과 동일한 로직."
L["Select Chat Types"] = "채팅 유형 선택"
L["Say"] = "일반 대화"
L["Yell"] = "외치기"
L["Party"] = "파티"
L["Raid"] = "공격대"
L["Guild"] = "길드"
L["Battleground"] = "전장"
L["Whisper"] = "귓속말"
L["Channel"] = "채널"
L["Other"] = "기타"
L["Select Rule"] = "규칙 선택"
L["Select Chat Frame"] = "채팅 창 선택"
L["Add Rule"] = "규칙 추가"
L["Delete Rule"] = "규칙 삭제"
L["Compact Chat"] = "간결한 채팅"
L["Move left"] = "왼쪽으로 이동"
L["Move right"] = "오른쪽으로 이동"
L["Mouseover: Left"] = "마우스오버: 왼쪽"
L["Mouseover: Right"] = "마우스오버: 오른쪽"
L["Automatic Onset"] = "자동 시작"
L["Scans tooltip texts and sets icons automatically."] = "툴팁 텍스트를 스캔하고 아이콘을 자동으로 설정합니다."
L["Icon (Default)"] = "아이콘 (기본)"
L["Icon (Kill)"] = "아이콘 (처치)"
L["Icon (Chat)"] = "아이콘 (채팅)"
L["Icon (Item)"] = "아이콘 (아이템)"
L["Show Text"] = "텍스트 표시"
L["Display progress status."] = "진행 상태를 표시합니다."
L["Name"] = "이름"
L["Frequent Updates"] = "빈번한 업데이트"
L["Events (optional)"] = "이벤트 (선택 사항)"
L["InternalCooldowns"] = "내부 재사용 대기시간"
L["Displays internal cooldowns on trinket tooltips."] = "장신구 툴팁에 내부 재사용 대기시간을 표시합니다."
L["Shortening X Offset"] = "X 오프셋 축소"
L["To Level"] = "레벨까지"
L["Names will be shortened based on level text position."] = "레벨 텍스트 위치에 따라 이름이 축소됩니다."
L["Add Item (by ID)"] = "아이템 추가 (ID로)"
L["Remove Item"] = "아이템 제거"
L["Pre-Load"] = "미리 로드"
L["Executes commands during the addon's initialization process."] = "애드온 초기화 과정에서 명령을 실행합니다."
L["Justify"] = "정렬"
L["Alt-Click: free bag slots, if possible."] = "Alt-클릭: 가능한 경우 가방 슬롯 비우기."
L["Click: toggle layout mode."] = "클릭: 레이아웃 모드 전환."
L["Alt-Click: re-evaluate all items."] = "Alt-클릭: 모든 아이템 다시 평가."
L["Drag-and-Drop: evaluate and position the cursor item."] = "드래그 앤 드롭: 커서 아이템 평가 및 위치 지정."
L["Shift-Alt-Click: toggle these hints."] = "Shift-Alt-클릭: 이 힌트 전환."
L["Mouse-Wheel: navigate between special and normal bags."] = "마우스 휠: 특수 가방과 일반 가방 간 이동."
L["This button accepts cursor item drops."] = "이 버튼은 커서에서 아이템을 드롭할 수 있습니다."
L["Setup Sections"] = "섹션 설정"
L["Adds default sections set to the currently selected container."] = "현재 선택된 컨테이너에 기본 섹션을 추가합니다."
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
		"자동 아이템 배치 처리.\n"..
			"문법: filter@value\n\n"..
			"사용 가능한 필터:\n"..
			" id@number - itemID 일치,\n"..
			" name@string - 이름 일치,\n"..
			" type@string - 유형 일치,\n"..
			" subtype@string - 하위 유형 일치,\n"..
			" ilvl@number - 아이템 레벨 일치,\n"..
			" uselevel@number - 착용 레벨 일치,\n"..
			" quality@number - 품질 일치,\n"..
			" equipslot@number - 인벤토리 슬롯 ID 일치,\n"..
			" maxstack@number - 최대 스택 크기 일치,\n"..
			" price@number - 판매 가격 일치,\n"..
			" tooltip@string - 툴팁 텍스트 일치,\n"..
			" set@setName - 장비 세트 아이템 일치.\n\n"..
			"모든 문자열 일치는 대소문자를 구분하지 않으며, 영숫자 기호만 일치합니다.\n"..
			"표준 Lua 논리 연산자(and/or/괄호 등) 사용 가능합니다.\n\n"..
			"사용 예시 (사제 t8 또는 섀도우모른):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
			"사용자 지정 함수 허용 (bagID, slotID, itemID 노출됨)\n"..
			"아래 함수는 새로 획득한 아이템을 알립니다.\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('아이템 획득: ' .. string)"
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
		"문법: filter@value@amount\n\n"..
			"사용 가능한 필터:\n"..
			" id@number@amount(+)/+ - itemID 일치,\n"..
			" name@string@amount(+)/+ - 이름 일치,\n"..
			" type@string@amount(+)/+ - 유형 일치,\n"..
			" subtype@string@amount(+)/+ - 하위 유형 일치,\n"..
			" ilvl@number@amount(+)/+ - 아이템 레벨 일치,\n"..
			" uselevel@number@amount(+)/+ - 착용 레벨 일치,\n"..
			" quality@number@amount(+)/+ - 품질 일치,\n"..
			" equipslot@number@amount(+)/+ - 인벤토리 슬롯 ID 일치,\n"..
			" maxstack@number@amount(+)/+ - 최대 스택 크기 일치,\n"..
			" price@number@amount(+)/+ - 판매 가격 일치,\n"..
			" tooltip@string@amount(+)/+ - 툴팁 텍스트 일치.\n\n"..
			"선택적 'amount' 부분:\n"..
			" 숫자 - 고정된 수량 구매,\n"..
			" + 기호 - 기존 스택을 보충하거나 새로운 스택 구매,\n"..
			" 둘 다 (예: 5+) - 지정된 총 수량(이 경우 5)에 도달하도록 구매,\n"..
			" 생략 - 기본값은 1.\n\n"..
			"모든 문자열 일치는 대소문자를 구분하지 않으며, 영숫자 기호만 일치합니다.\n"..
			"표준 Lua 논리 연산자(and/or/괄호 등) 사용 가능합니다.\n\n"..
			"사용 예시 (사제 t8 또는 섀도우모른):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["PERIODIC"] = "주기적"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "/addOccupation 명령어를 사용할 때 이 키를 누르고 있으면 현재 대상/마우스오버 NPC 목록이 삭제됩니다."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "NPC를 대상으로 하거나 마우스오버 중일 때 /addOccupation 명령어를 사용하여 목록에 추가하세요. 다시 사용하면 순환합니다."
L["Style Filter Icons"] = "스타일 필터 아이콘"
L["Custom icons for the style filter."] = "스타일 필터용 사용자 정의 아이콘."
L["Whitelist"] = "허용 목록"
L["X Direction"] = "X 방향"
L["Y Direction"] = "Y 방향"
L["Create Icon"] = "아이콘 만들기"
L["Delete Icon"] = "아이콘 삭제"
L["0 to match frame width."] = "프레임 너비에 맞추기 위한 0."
L["Remove a NPC"] = "NPC 제거"
L["Change a NPC's Occupation"] = "NPC의 직업 변경"
L["...to the currently selected one."] = "...현재 선택된 것으로."
L["Select Occupation"] = "직업 선택"
L["Sell"] = "판매"
L["Action Type"] = "작업 유형"
L["Style Filter Additional Triggers"] = "스타일 필터 추가 트리거"
L["Triggers"] = "트리거"
L["Example usage:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"] =
		"사용 예:"..
			"\n local frame, filter, trigger = ..."..
			"\n return frame.UnitName == 'Shrek'"..
			"\n         or (frame.unit"..
			"\n             and UnitName(frame.unit) == 'Fiona')"
L["Abbreviate Name"] = "이름 축약"
L["Highlight Self"] = "자신 강조"
L["Highlight Others"] = "다른 사람 강조"
L["Self Inherit Name Color"] = "자신의 이름 색상 상속"
L["Self Texture"] = "자신 텍스처"
L["Whitespace to disable, empty to default."] = "비활성화하려면 공백, 기본값은 비우십시오."
L["Self Color"] = "자신의 색상"
L["Self Scale"] = "자신의 크기"
L["Others Inherit Name Color"] = "다른 사람의 이름 색상 상속"
L["Others Texture"] = "다른 사람 텍스처"
L["Others Color"] = "다른 사람 색상"
L["Others Scale"] = "다른 사람 크기"
L["Targets"] = "대상"