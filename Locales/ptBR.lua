local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "ptBR")

L["Hits the 'Confirm' button automatically."] = "Clica automaticamente no botão 'Confirmar'."
L["Picks up items and money automatically."] = "Coleta itens e dinheiro automaticamente."
L["Automatically fills the 'DELETE' field."] = "Preenche automaticamente o campo 'EXCLUIR'."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "Seleciona a primeira opção de diálogo se for a única disponível, a menos que uma tecla modificadora esteja pressionada.\nCuidado com gatilhos de eventos importantes, não há mecanismo de segurança."
L["Accepts and turns in quests automatically while holding a modifier."] = "Aceita e entrega missões automaticamente enquanto uma tecla modificadora está pressionada."
L["Loot info wiped."] = "Informações de saque apagadas."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "Comando /lootinfo para obter um resumo rápido dos saques recentes.\n\nUso: /lootinfo Maçã 60\n'Maçã' - nome do item/jogador \n(pesquise @self para obter o saque do jogador)\n'60' - \nlimite de tempo (<60 segundos atrás), opcional,\n/lootinfo !wipe - limpar cache de saque."
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "Colore os nomes de amigos online e membros da guilda em algumas mensagens e estiliza as rolagens.\nBalões de chat já processados não serão estilizados antes de você usar /reload."
L["Colors loot roll messages for you and other players."] = "Colore as mensagens de rolagem de saque para você e outros jogadores."
L["Loot rolls icon size."] = "Tamanho do ícone das rolagens de saque."
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "Reestiliza as barras de saque.\nRequer que 'Rolagem de Saque' (Geral -> Melhorias BlizzUI -> Rolagem de Saque) esteja ativado (alternar este módulo o ativa automaticamente)."
L["Displays the name of the player pinging the minimap."] = "Exibe o nome do jogador que está pingando o minimapa."
L["Displays the currently held currency amount next to the item prices."] = "Exibe a quantidade de moeda atualmente possuída ao lado dos preços dos itens."
L["Narrows down the World(..Frame)."] = "Reduz o World(..Frame)."
L["'Out of mana', 'Ability is not ready yet', etc."] = "'Sem mana', 'Habilidade ainda não está pronta', etc."
L["Re-enable quest updates."] = "Reativar atualizações de missões."
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - amarelo da Blizzard."
L["Text to display upon entering combat."] = "Texto a ser exibido ao entrar em combate."
L["Text to display upon leaving combat."] = "Texto a ser exibido ao sair do combate."
L["REQUIRES RELOAD."] = "RECARREGAMENTO NECESSÁRIO."
L["Icon to the left or right of the item link."] = "Ícone à esquerda ou à direita do link do item."
L["The size of the icon in the chat frame."] = "O tamanho do ícone na moldura do chat."
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "Adiciona sombras a todas as molduras.\nNão faz nada a menos que você substitua seu ElvUI/Core/Toolkit.lua pelo arquivo relevante da pasta Opcionais deste plugin."
L["Combat state notification alerts."] = "Alertas de notificação de estado de combate."
L["Custom editbox position and size."] = "Posição e tamanho personalizados da caixa de edição."
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
		"Uso:"..
			"\n/tnote list - retorna todas as notas existentes"..
			"\n/tnote wipe - limpa todas as notas existentes"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - o mesmo que set (exceto para a parte lua)"..
			"\n/tnote 1 get - o mesmo que set, retorna as notas existentes"..
			"\n/tnote 1 set SuaNotaAqui - adiciona uma nota ao índice designado da lista "..
			"ou ao texto da dica de ferramenta atualmente exibida se o segundo argumento (1 neste caso) for omitido, "..
			"suporta funções e coloração "..
			"(fornecer nenhum texto limpa a nota);"..
			"\npara quebrar as linhas, use ::"..
			"\n\nExemplo:"..
			"\n\n/tnote 3 set fogo pré-bis::fonte: João da Silva"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(cor padrão)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "Adiciona um ícone ao lado dos hyperlinks do chat."
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "Uma nova barra de ação que coleta itens de missão utilizáveis da sua bolsa.\n\nDevido ao limite de ações de estado, este módulo substitui a barra10 criada pelo ElvUI Extra Action Bars."
L["Toggles the display of the actionbar's backdrop."] = "Alterna a exibição do plano de fundo das barras de ação."
L["The frame will not be displayed unless hovered over."] = "O quadro não será exibido a menos que você passe o mouse sobre ele."
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "Herda o esmaecimento global, passar o mouse, selecionar alvo, definir foco, perder saúde, entrar em combate removerá a transparência. Caso contrário, usará o nível de transparência nas configurações gerais da barra de ação para o alfa de esmaecimento global."
L["The first button anchors itself to this point on the bar."] = "O primeiro botão se ancora a este ponto na barra."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "Clique com o botão direito no item enquanto segura o modificador para colocá-lo na lista negra. Itens na lista negra não aparecerão na barra.\nUse /questbarRestore para limpar a lista negra."
L["The number of buttons to display."] = "A quantidade de botões a serem exibidos."
L["The number of buttons to display per row."] = "A quantidade de botões a serem exibidos por linha."
L["The size of the action buttons."] = "O tamanho dos botões de ação."
L["Spacing between the buttons."] = "O espaçamento entre os botões."
L["Spacing between the backdrop and the buttons."] = "O espaçamento entre o plano de fundo e os botões."
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "Multiplica a altura ou largura do plano de fundo por este valor. Isso é útil se você deseja ter mais de uma barra atrás de um plano de fundo."
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "Isso funciona como uma macro, você pode executar diferentes situações para fazer a barra de ação aparecer/desaparecer de maneira diferente.\n Exemplo: '[combat] showhide'"
L["Adds anchoring options to the movers' nudges."] = "Adiciona opções de ancoragem aos empurrões dos movimentadores."
L["Mod-clicking an item suggests a skill/item to process it."] = "Clicar com o modificador em um item sugere uma habilidade/item para processá-lo."
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"Segurando %s enquanto clica com o botão esquerdo em uma pilha a divide em duas; para combinar cópias disponíveis, clique com o botão direito."..
    "\n\nTambém modifica o SplitStackFrame para usar caixa de edição em vez de setas."
L["Extends the bags functionality."] = "Estende a funcionalidade das bolsas."
L["Default method: type > inventory slot ID > item level > name."] = "Método padrão: tipo > id do slot de inventário > nível do item > nome."
L["Listed ItemIDs will not get sorted."] = "IDs de itens listados não serão ordenados."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Ex: Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "Formato de condição inválido: "
L["The generated custom sorting method did not return a function."] = "O método de ordenação personalizado gerado não retornou uma função."
L["The loaded custom sorting method did not return a function."] = "O método de ordenação personalizado carregado não retornou uma função."
L["Item received: "] = "Item recebido: "
L[" added."] = " adicionado."
L[" removed."] = " removido."
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
		"Lida com o reposicionamento automático dos itens recém-recebidos."..
		"\nSintaxe: filtro@valor\n\n"..
		"Filtros disponíveis:\n"..
		" id@número - corresponde ao ID do item,\n"..
		" name@string - corresponde ao nome,\n"..
		" subtype@string - corresponde ao subtipo,\n"..
		" ilvl@número - corresponde ao nível do item,\n"..
		" uselevel@número - corresponde ao nível de equipamento,\n"..
		" quality@número - corresponde à qualidade,\n"..
		" equipslot@número - corresponde ao ID do slot de inventário,\n"..
		" maxstack@número - corresponde ao limite de pilha,\n"..
		" price@número - corresponde ao preço de venda,\n\n"..
		" tooltip@string - corresponde ao texto da dica,\n\n"..
		"Todas as correspondências de string não diferenciam maiúsculas de minúsculas e correspondem apenas aos símbolos alfanuméricos. A lógica padrão de Lua se aplica. "..
		"Consulte a API GetItemInfo para mais informações sobre filtros. "..
		"Use GetAuctionItemClasses e GetAuctionItemSubClasses (igual à Casa de Leilões) para obter os valores localizados de tipos e subtipos.\n\n"..
		"Exemplo de uso (sacerdote t8 ou Shadowmourne):\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@deSantificação) or name@shadowmourne.\n\n"..
		"Aceita funções personalizadas (bagID, slotID, itemID estão expostos)\n"..
		"O exemplo abaixo notifica sobre os itens recém-adquiridos.\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\\124', '\\124\\124')\n"..
		"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
		"print('Item recebido: ' .. string)"
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
		"Sintaxe: filtro@valor\n\n"..
			"Filtros disponíveis:\n"..
			" id@número - corresponde ao ID do item,\n"..
			" name@texto - corresponde ao nome,\n"..
			" type@texto - corresponde ao tipo,\n"..
			" subtype@texto - corresponde ao subtipo,\n"..
			" ilvl@número - corresponde ao nível do item,\n"..
			" uselevel@número - corresponde ao nível de equipamento,\n"..
			" quality@número - corresponde à qualidade,\n"..
			" equipslot@número - corresponde ao ID do slot do inventário,\n"..
			" maxstack@número - corresponde ao limite de pilha,\n"..
			" price@número - corresponde ao preço de venda,\n"..
			" tooltip@texto - corresponde ao texto da dica.\n\n"..
			"Todas as correspondências de texto não diferenciam maiúsculas de minúsculas e correspondem apenas a símbolos alfanuméricos.\n"..
			"A lógica lua padrão para ramificação (e/ou/parênteses/etc.) se aplica.\n\n"..
			"Exemplo de uso (sacerdote t8 ou Shadowmourne):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "Tipos de Item Disponíveis"
L["Lists all available item subtypes for each available item type."] =
	"Lista todos os subtipos de item disponíveis para cada tipo de item disponível."
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"Segurar esta tecla enquanto interage com um comerciante compra todos os itens que atendem ao método de Compra Automática.\n"..
			"Mod-clique na entrada da lista de compra para adquirir apenas um dos itens, independentemente da regra '@quantidade'."
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
    "Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
    "function(a,b)\n"..
    "--your sorting logic here\n"..
    "end\n\n"..
    "Leave blank to go default."] =
		"Método padrão: tipo > id do slot de inventário > nível do item > nome.\n\n"..
		"Aceita funções personalizadas (bagID e slotID estão disponíveis em a/b.bagID/slotID).\n\n"..
		"function(a,b)\n"..
		"--sua lógica de ordenação aqui\n"..
		"end\n\n"..
		"Deixe em branco para usar o padrão."
L["Event and OnUpdate handler."] = "Manipulador de eventos e OnUpdate."
L["Minimal time gap between two consecutive executions."] = "Intervalo mínimo de tempo entre duas execuções consecutivas."
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - Script 'OnUpdate'"
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = "UNIT_AURA CHAT_MSG_WHISPER etc."
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
		"Sintaxe:"..
		"\n\nEVENT[n~=nil]"..
		"\n[n~=value]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@commands@@@"..
		"\n\n'EVENT' - Evento da seção de eventos acima"..
		"\n'n, m, k' - índices dos argumentos desejados do payload (número)"..
		"\n'nil/value/boolean/lua code' - saída desejada do argumento n"..
		"\n'@@' - flag de argumento lua, deve vir antes do código lua dentro da seção de valor dos argumentos"..
		"\n'~' - flag de negação, adicione antes do sinal de igual para que o código seja executado se n/m/k não corresponder ao valor definido"..
		"\n'@@@ @@@' - colchetes contendo os comandos."..
		"\nVocê pode acessar o payload (...) como de costume."..
		"\n\nExemplo:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(jogador ganhou/perdeu uma aura)@@@"..
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
		"\nthen print(UnitName('party'..i)..' está afetado!')"..
		"\nend end@@@"..
		"\n\nEste módulo analisa strings, então tente fazer com que seu código siga a sintaxe estritamente, caso contrário, pode não funcionar."
L["Highlights auras."] = "Destaca auras."
L["E.g. 42292"] = "Ex.: 42292"
L["Applies highlights to all auras passing the selected filter."] = "Destaca todas as auras que passam pelo filtro selecionado."
L["Priority: spell, filter, curable/stealable."] = "Prioridade: feitiço, filtro, curável/roubável."
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "Se ativado, serão usados os valores de Feitiço ou Filtro GLOBAL."
L["Makes auras grow sideswise."] = "Faz com que as auras cresçam lateralmente."
L["Turns off texture fill."] = "Desativa o preenchimento de textura."
L["Makes auras flicker right before fading out."] = "Faz com que as auras pisquem antes de desvanecer."
L["Disables border coloring."] = "Desativa a coloração da borda."
L["Click Cancel"] = "Cancelar ao clicar"
L["Right-click a player buff to cancel it."] = "Clique com o botão direito em um buff do jogador para cancelá-lo."
L["Disables debuffs desaturation."] = "Desativa a dessaturação de debuffs."
L["Saturated Debuffs"] = "Debuffs Saturados"
L["Confirm Rolls"] = "Confirmar rolagens"
L["Auto Pickup"] = "Coleta automática"
L["Swift Buy"] = "Compra rápida"
L["Buys out items automatically."] = "Compra itens automaticamente."
L["Failsafe"] = "Sistema de segurança"
L["Enables popup confirmation dialog."] = "Ativa o diálogo de confirmação."
L["Add Set"] = "Adicionar conjunto"
L["Delete Set"] = "Excluir conjunto"
L["Select Set"] = "Selecionar conjunto"
L["Auto Buy"] = "Compra automática"
L["Fill Delete"] = "Preencher exclusão"
L["Gossip"] = "Diálogo"
L["Accept Quest"] = "Aceitar missão"
L["Loot Info"] = "Informações de saque"
L["Styled Messages"] = "Mensagens estilizadas"
L["Indicator Color"] = "Cor do indicador"
L["Select Status"] = "Selecionar status"
L["Select Indicator"] = "Selecionar indicador"
L["Styled Loot Messages"] = "Mensagens de saque estilizadas"
L["Icon Size"] = "Tamanho do ícone"
L["Loot Bars"] = "Barras de saque"
L["Bar Height"] = "Altura da barra"
L["Bar Width"] = "Largura da barra"
L["Player Pings"] = "Pings de jogadores"
L["Held Currency"] = "Moeda retida"
L["LetterBox"] = "Letterbox"
L["Left"] = "Esquerda"
L["Right"] = "Direita"
L["Top"] = "Topo"
L["Bottom"] = "Fundo"
L["Hide Errors"] = "Ocultar erros"
L["Show quest updates"] = "Mostrar atualizações de missões"
L["Less Tooltips"] = "Menos dicas"
L["Misc."] = "Diversos"
L["Loot&Style"] = "Saque e Estilo"
L["Automation"] = "Automação"
L["Bags"] = "Bolsas"
L["Easier Processing"] = "Processamento facilitado"
L["Modifier"] = "Modificador"
L["Split Stack"] = "Dividir pilha"
L["Bags Extended"] = "Bolsas estendidas"
L["Select Container Type"] = "Selecionar tipo de contêiner"
L["Settings"] = "Configurações"
L["Add Section"] = "Adicionar seção"
L["Delete Section"] = "Excluir seção"
L["Select Section"] = "Selecionar seção"
L["Section Priority"] = "Prioridade da seção"
L["Section Spacing"] = "Espaçamento da seção"
L["Collection Method"] = "Método de coleta"
L["Sorting Method"] = "Método de ordenação"
L["Ignore Item (by ID)"] = "Ignorar item (por ID)"
L["Remove Ignored"] = "Remover ignorados"
L["Title"] = "Título"
L["Color"] = "Cor"
L["Attach to Icon"] = "Anexar ao ícone"
L["Text"] = "Texto"
L["Font Size"] = "Tamanho da fonte"
L["Font"] = "Fonte"
L["Font Flags"] = "Flags da fonte"
L["Point"] = "Ponto"
L["Relative Point"] = "Ponto relativo"
L["X Offset"] = "Deslocamento X"
L["Y Offset"] = "Deslocamento Y"
L["Icon"] = "Ícone"
L["Attach to Text"] = "Anexar ao texto"
L["Texture"] = "Textura"
L["Size"] = "Tamanho"
L["MoversPlus"] = "MovedoresPlus"
L["Movers Plus"] = "MovedoresPlus"
L["CustomCommands"] = "Comandos personalizados"
L["Custom Commands"] = "Comandos personalizados"
L["QuestBar"] = "Barra de missões"
L["Quest Bar"] = "Barra de missões"
L["Settings"] = "Configurações"
L["Backdrop"] = "Pano de fundo"
L["Show Empty Buttons"] = "Mostrar botões vazios"
L["Mouse Over"] = "Ao passar o mouse"
L["Inherit Global Fade"] = "Herdar fade global"
L["Anchor Point"] = "Ponto de ancoragem"
L["Modifier"] = "Modificador"
L["Buttons"] = "Botões"
L["Buttons Per Row"] = "Botões por linha"
L["Button Size"] = "Tamanho do botão"
L["Button Spacing"] = "Espaçamento entre botões"
L["Backdrop Spacing"] = "Espaçamento do pano de fundo"
L["Height Multiplier"] = "Multiplicador de altura"
L["Width Multiplier"] = "Multiplicador de largura"
L["Alpha"] = "Alfa"
L["Visibility State"] = "Estado de visibilidade"
L["Enable Tab"] = "Habilitar Aba"
L["Throttle Time"] = "Tempo de Limitação"
L["Select Tab"] = "Selecionar Aba"
L["Select Event"] = "Selecionar Evento"
L["Rename Tab"] = "Renomear Aba"
L["Add Tab"] = "Adicionar Aba"
L["Delete Tab"] = "Excluir Aba"
L["Open Edit Frame"] = "Abrir Quadro de Edição"
L["Events"] = "Eventos"
L["Commands to execute"] = "Comandos para executar"
L["Sub-Section"] = "Subseção"
L["Select"] = "Selecionar"
L["Icon Orientation"] = "Orientação do Ícone"
L["Icon Size"] = "Tamanho do Ícone"
L["Height Offset"] = "Deslocamento de Altura"
L["Width Offset"] = "Deslocamento de Largura"
L["Text Color"] = "Cor do Texto"
L["Entering combat"] = "Entrando em combate"
L["Leaving combat"] = "Saindo do combate"
L["Font"] = "Fonte"
L["Font Outline"] = "Contorno da Fonte"
L["Font Size"] = "Tamanho da Fonte"
L["Texture Width"] = "Largura da Textura"
L["Texture Height"] = "Altura da Textura"
L["Custom Texture"] = "Textura Personalizada"
L["ItemIcons"] = "Ícones de itens"
L["TooltipNotes"] = "Notas de dicas"
L["ChatEditBox"] = "Caixa de edição de bate-papo"
L["EnterCombatAlert"] = "Alerta de entrada em combate"
L["GlobalShadow"] = "Sombra global"
L["Any"] = "Qualquer"
L["Guildmate"] = "Companheiro de guilda"
L["Friend"] = "Amigo"
L["Self"] = "Jogador"
L["New Tab"] = "Nova aba"
L["None"] = "Nenhum"
L["Version: "] = "Versão: "
L["Color A"] = "Cor A"
L["Chat messages, etc."] = "Mensagens de chat, etc."
L["Color B"] = "Cor B"
L["Plugin Color"] = "Cor do Plugin"
L["Icons Browser"] = "Navegador de Ícones"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "Obtenha https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html para ícones mais limpos e recortados."
L["Add Texture"] = "Adicionar Textura"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Adiciona texturas à lista geral de texturas.\nEx.: Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "Remover Textura"
L["Highlights"] = "Destaques"
L["Select Type"] = "Selecionar Tipo"
L["Highlights Settings"] = "Configurações de Destaques"
L["Add Filter"] = "Adicionar Filtro"
L["Remove Selected"] = "Remover Selecionado"
L["Select Spell or Filter"] = "Selecionar Feitiço ou Filtro"
L["Use Global Settings"] = "Usar Configurações Globais"
L["Selected Spell or Filter Values"] = "Valores de Feitiço ou Filtro Selecionado"
L["Enable Shadow"] = "Habilitar Sombra"
L["Size"] = "Tamanho"
L["Shadow Color"] = "Cor da Sombra"
L["Enable Border"] = "Habilitar Borda"
L["Border Color"] = "Cor da Borda"
L["Centered Auras"] = "Auras Centralizadas"
L["Cooldown Disable"] = "Desativar Tempo de Recarga"
L["Animate Fade-Out"] = "Animar Desvanecimento"
L["Type Borders"] = "Bordas de Tipo"
L[" filter added."] = " filtro adicionado."
L[" filter removed."] = " filtro removido."
L["GLOBAL"] = "GLOBAL"
L["CURABLE"] = "Curável"
L["STEALABLE"] = "Roubável"
L["--Filters--"] = "--Filtros--"
L["--Spells--"] = "--Feitiços--"
L["FRIENDLY"] = "Amigável"
L["ENEMY"] = "Inimigo"
L["AuraBars"] = "Barras de Aura"
L["Auras"] = "Auras"
L["ClassificationIndicator"] = "Indicador de Classificação"
L["ClassificationIcons"] = "Ícones de Classificação"
L["ColorFilter"] = "Filtro de Cor"
L["Cooldowns"] = "Cooldowns"
L["DRTracker"] = "Rastreamento de DR"
L["Guilds&Titles"] = "Guildas e Títulos"
L["Name&Level"] = "Nome e Nível"
L["QuestIcons"] = "Ícones de Missão"
L["StyleFilter"] = "Filtro de Estilo"
L["Search:"] = "Buscar:"
L["Click to select."] = "Clique para selecionar."
L["Click to select."] = "Clique para selecionar."
L["Hover again to see the changes."] = "Passe o mouse novamente para ver as mudanças."
L["Note set for "] = "Nota definida para "
L["Note cleared for "] = "Nota apagada para "
L["No note to clear for "] = "Nenhuma nota para apagar para "
L["Added icon to the note for "] = "Ícone adicionado à nota para "
L["Note icon cleared for "] = "Ícone da nota apagado para "
L["No note icon to clear for "] = "Nenhum ícone de nota para apagar para "
L["Current note for "] = "Nota atual para "
L["No note found for this tooltip."] = "Nota não encontrada para esta dica."
L["Notes: "] = "Notas: "
L["No notes are set."] = "Nenhuma nota definida."
L["No tooltip is currently shown or unsupported tooltip type."] = "Nenhuma dica está sendo exibida atualmente ou tipo de dica não suportado."
L["All notes have been cleared."] = "Todas as notas foram apagadas."
L["Accept"] = "Aceitar"
L["Cancel"] = "Cancelar"
L["Purge Cache"] = "Limpar Cache"
L["Guilds"] = "Guildas"
L["Separator"] = "Separador"
L["X Offset"] = "Deslocamento X"
L["Y Offset"] = "Deslocamento Y"
L["Level"] = "Nível"
L["Visibility State"] = "Estado de Visibilidade"
L["City (Resting)"] = "Cidade (Descansando)"
L["PvP"] = "JxJ"
L["Arena"] = "Arena"
L["Party"] = "Grupo"
L["Raid"] = "Raide"
L["Colors"] = "Cores"
L["Guild"] = "Guilda"
L["All"] = "Todos"
L["Occupation Icon"] = "Ícone de Ocupação"
L["OccupationIcon"] = "Ícone de Ocupação"
L["Size"] = "Tamanho"
L["Anchor"] = "Âncora"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "Remover ocupação"
L["Modifier"] = "Modificador"
L["Add Texture Path"] = "Adicionar Caminho de Textura"
L["Remove Selected Texture"] = "Remover Textura Selecionada"
L["Titles"] = "Títulos"
L["Reaction Color"] = "Cor de Reação"
L["Color based on reaction type."] = "Cor baseada no tipo de reação."
L["Nameplates"] = "Placas de identificação"
L["Unitframes"] = "Quadros de unidade"
L["An icon similar to the minimap search."] = "Um ícone semelhante à busca do minimapa."
L["Displays player guild text."] = "Exibe o texto da guilda do jogador."
L["Displays NPC occupation text."] = "Exibe o texto de ocupação do PNJ."
L["Strata"] = "Camada"
L["Selected Type"] = "Tipo selecionado"
L["Reaction based coloring for non-cached characters."] = "Coloração baseada em reação para personagens não armazenados em cache."
L["Apply Custom Color"] = "Aplicar cor personalizada"
L["Class Color"] = "Cor da classe"
L["Use class colors."] = "Usar cores de classe."
L["Use Backdrop"] = "Usar plano de fundo"
L["Linked Style Filter Triggers"] = "Gatilhos de Filtro de Estilo Vinculado"
L["Select Link"] = "Selecionar Link"
L["New Link"] = "Novo Link"
L["Delete Link"] = "Excluir Link"
L["Target Filter"] = "Filtro de Alvo"
L["Select a filter to trigger the styling."] = "Selecione um filtro para acionar o estilo."
L["Apply Filter"] = "Aplicar Filtro"
L["Select a filter to style the frames not passing the target filter triggers."] = "Selecione um filtro para estilizar os quadros que não passam nos gatilhos do filtro de alvo."
L["Cache purged."] = "Cache limpo."
L["Test Mode"] = "Modo de Teste"
L["Draws player cooldowns."] = "Mostra os tempos de recarga do jogador."
L["Show Everywhere"] = "Mostrar em Todo Lugar"
L["Show in Cities"] = "Mostrar nas Cidades"
L["Show in Battlegrounds"] = "Mostrar nos Campos de Batalha"
L["Show in Arenas"] = "Mostrar nas Arenas"
L["Show in Instances"] = "Mostrar nas Instâncias"
L["Show in the World"] = "Mostrar no Mundo"
L["Header"] = "Cabeçalho"
L["Icons"] = "Ícones"
L["OnUpdate Throttle"] = "Limitador de Atualização"
L["Trinket First"] = "Berloque Primeiro"
L["Animate Fade Out"] = "Animar Desaparecimento"
L["Border Color"] = "Cor da Borda"
L["Growth Direction"] = "Direção de Crescimento"
L["Sort Method"] = "Método de Ordenação"
L["Icon Size"] = "Tamanho do Ícone"
L["Icon Spacing"] = "Espaçamento entre Ícones"
L["Per Row"] = "Por Linha"
L["Max Rows"] = "Máximo de Linhas"
L["CD Text"] = "Texto do Tempo de Recarga"
L["Show"] = "Mostrar"
L["Cooldown Fill"] = "Preenchimento do Tempo de Recarga"
L["Reverse"] = "Inverter"
L["Direction"] = "Direção"
L["Spells"] = "Feitiços"
L["Add Spell (by ID)"] = "Adicionar Feitiço (por ID)"
L["Remove Selected Spell"] = "Remover Feitiço Selecionado"
L["Select Spell"] = "Selecionar Feitiço"
L["Shadow"] = "Sombra"
L["Pet Ability"] = "Habilidade do Mascote"
L["Shadow Size"] = "Tamanho da Sombra"
L["Shadow Color"] = "Cor da Sombra"
L["Sets update speed threshold."] = "Define o limite de velocidade de atualização."
L["Makes PvP trinkets and human racial always get positioned first."] = "Faz com que berloques de JxJ e o racial humano sempre sejam posicionados primeiro."
L["Makes icons flash when the cooldown's about to end."] = "Faz os ícones piscarem quando o tempo de recarga está prestes a terminar."
L["Any value apart from black (0,0,0) would override borders by time left."] = "Qualquer valor diferente de preto (0,0,0) substituirá as bordas pelo tempo restante."
L["Colors borders by time left."] = "Colore as bordas pelo tempo restante."
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "Formato: 'ID do feitiço tempo de recarga', ex. 42292 120"
L["For the important stuff."] = "Para as coisas importantes."
L["Pet casts require some special treatment."] = "Lançamentos de mascotes requerem um tratamento especial."
L["Color by Type"] = "Cor por Tipo"
L["Flip Icon"] = "Virar Ícone"
L["Texture List"] = "Lista de Texturas"
L["Keep Icon"] = "Manter Ícone"
L["Texture"] = "Textura"
L["Texture Coordinates"] = "Coordenadas de Textura"
L["Select Affiliation"] = "Selecionar Afiliação"
L["Width"] = "Largura"
L["Height"] = "Altura"
L["Select Class"] = "Selecionar Classe"
L["Points"] = "Pontos"
L["Colors the icon based on the unit type."] = "Colore o ícone com base no tipo de unidade."
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "Vira o ícone horizontalmente. Não é compatível com Coordenadas de Textura."
L["Keep the original icon texture."] = "Manter a textura original do ícone."
L["NPCs"] = "NPCs"
L["Players"] = "Jogadores"
L["By duration, ascending."] = "Por duração, crescente."
L["By duration, descending."] = "Por duração, decrescente."
L["By time used, ascending."] = "Por tempo usado, crescente."
L["By time used, descending."] = "Por tempo usado, decrescente."
L["Additional settings for the Elite Icon."] = "Configurações adicionais para o Ícone de Elite."
L["Player class icons."] = "Ícones de classe do jogador."
L["Class Icons"] = "Ícones de Classe"
L["Vector Class Icons"] = "Ícones de Classe Vetoriais"
L["Class Crests"] = "Brasões de Classe"
L["Floating Combat Feedback"] = "Feedback de Combate Flutuante"
L["Select Unit"] = "Selecionar Unidade"
L["player"] = "jogador (player)"
L["target"] = "alvo (target)"
L["targettarget"] = "alvo do alvo (targettarget)"
L["targettargettarget"] = "alvo do alvo do alvo (targettargettarget)"
L["focus"] = "foco (focus)"
L["focustarget"] = "alvo do foco (focustarget)"
L["pet"] = "mascote (pet)"
L["pettarget"] = "alvo do mascote (pettarget)"
L["raid"] = "raide (raid)"
L["raid40"] = "raide 40 (raid40)"
L["raidpet"] = "mascote de raide (raidpet)"
L["party"] = "grupo (party)"
L["partypet"] = "mascote do grupo (partypet)"
L["partytarget"] = "alvo do grupo (partytarget)"
L["boss"] = "chefe (boss)"
L["arena"] = "arena (arena)"
L["assist"] = "assistente (assist)"
L["assisttarget"] = "alvo do assistente (assisttarget)"
L["tank"] = "tanque (tank)"
L["tanktarget"] = "alvo do tanque (tanktarget)"
L["Scroll Time"] = "Tempo de Rolagem"
L["Event Settings"] = "Configurações de Evento"
L["Event"] = "Evento"
L["Disable Event"] = "Desativar Evento"
L["School"] = "Escola"
L["Use School Colors"] = "Usar Cores da Escola"
L["Colors"] = "Cores"
L["Color (School)"] = "Cor (Escola)"
L["Animation Type"] = "Tipo de Animação"
L["Custom Animation"] = "Animação Personalizada"
L["Flag Settings"] = "Configurações de Bandeira"
L["Flag"] = "Bandeira"
L["Font Size Multiplier"] = "Multiplicador de Tamanho da Fonte"
L["Animation by Flag"] = "Animação por Bandeira"
L["Icon Settings"] = "Configurações de Ícone"
L["Show Icon"] = "Mostrar Ícone"
L["Icon Position"] = "Posição do Ícone"
L["Bounce"] = "Saltar"
L["Blacklist"] = "Lista Negra"
L["Appends floating combat feedback fontstrings to frames."] = "Adiciona strings de fonte de feedback de combate flutuante aos quadros."
L["There seems to be a font size limit?"] = "Parece haver um limite de tamanho de fonte?"
L["Not every event is eligible for this. But some are."] = "Nem todos os eventos são elegíveis para isso. Mas alguns são."
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "Defina sua animação personalizada como uma função lua.\n\nExemplo:\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "Alterne para que esta seção lide com animações de bandeira em vez disso.\n\nNem todo evento tem bandeiras."
L["Flip position left-right."] = "Inverter posição esquerda-direita."
L["E.g. 42292"] = "Ex: 42292"
L["Loaded custom animation did not return a function."] = "A animação personalizada carregada não retornou uma função."
L["Before Text"] = "Texto Anterior"
L["After Text"] = "Texto Posterior"
L["Remove Spell"] = "Remover Feitiço"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"Defina sua animação personalizada como uma função lua.\n\nExemplo:\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "ABSORVER"
L["BLOCK"] = "BLOQUEAR"
L["CRITICAL"] = "CRÍTICO"
L["CRUSHING"] = "ESMAGADOR"
L["GLANCING"] = "DE RASPÃO"
L["RESIST"] = "RESISTIR"
L["Diagonal"] = "Diagonal"
L["Fountain"] = "Fonte"
L["Horizontal"] = "Horizontal"
L["Random"] = "Aleatório"
L["Static"] = "Estático"
L["Vertical"] = "Vertical"
L["DEFLECT"] = "DESVIAR"
L["DODGE"] = "ESQUIVAR"
L["ENERGIZE"] = "ENERGIZAR"
L["EVADE"] = "EVADIR"
L["HEAL"] = "CURAR"
L["IMMUNE"] = "IMUNE"
L["INTERRUPT"] = "INTERROMPER"
L["MISS"] = "ERRAR"
L["PARRY"] = "APARAR"
L["REFLECT"] = "REFLETIR"
L["WOUND"] = "FERIR"
L["Debuff applied/faded/refreshed"] = "Debuff aplicado/desaparecido/renovado"
L["Buff applied/faded/refreshed"] = "Buff aplicado/desaparecido/renovado"
L["Physical"] = "Físico"
L["Holy"] = "Sagrado"
L["Fire"] = "Fogo"
L["Nature"] = "Natureza"
L["Frost"] = "Gelo"
L["Shadow"] = "Sombra"
L["Arcane"] = "Arcano"
L["Astral"] = "Astral"
L["Chaos"] = "Caos"
L["Elemental"] = "Elemental"
L["Magic"] = "Magia"
L["Plague"] = "Praga"
L["Radiant"] = "Radiante"
L["Shadowflame"] = "Chama Sombria"
L["Shadowfrost"] = "Gelo Sombrio"
L["Up"] = "Cima"
L["Down"] = "Baixo"
L["Classic Style"] = "Estilo Clássico"
L["If enabled, default cooldown style will be used."] = "Se ativado, o estilo de recarga padrão será usado."
L["Classification Indicator"] = "Indicador de Classificação"
L["Copy Unit Settings"] = "Copiar Configurações da Unidade"
L["Enable Player Class Icons"] = "Ativar Ícones de Classe do Jogador"
L["Enable NPC Classification Icons"] = "Ativar Ícones de Classificação de NPC"
L["Type"] = "Tipo"
L["Select unit type."] = "Selecione o tipo de unidade."
L["World Boss"] = "Chefe Mundial"
L["Elite"] = "Elite"
L["Rare"] = "Raro"
L["Rare Elite"] = "Elite Raro"
L["Class Spec Icons"] = "Ícones de Especialização de Classe"
L["Classification Textures"] = "Texturas de Classificação"
L["Use Nameplates' Icons"] = "Usar Ícones das Placas de Nome"
L["Color enemy NPC icon based on the unit type."] = "Colorir ícone de NPC inimigo com base no tipo de unidade."
L["Strata and Level"] = "Camada e Nível"
L["Warrior"] = "Guerreiro"
L["Warlock"] = "Bruxo"
L["Priest"] = "Sacerdote"
L["Paladin"] = "Paladino"
L["Druid"] = "Druida"
L["Rogue"] = "Ladino"
L["Mage"] = "Mago"
L["Hunter"] = "Caçador"
L["Shaman"] = "Xamã"
L["Deathknight"] = "Cavaleiro da Morte"
L["Aura Bars"] = "Barras de Aura"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "Adiciona opções extras de configuração para barras de aura.\n\n Para opções como tamanho e desvinculação, use os Movedores de Barras de Aura do ElvUI!"
L["Hide"] = "Ocultar"
L["Spell Name"] = "Nome do Feitiço"
L["Spell Time"] = "Tempo do Feitiço"
L["Bounce Icon Points"] = "Pontos de Salto do Ícone"
L["Set icon to the opposite side of the bar each new bar."] = "Definir ícone para o lado oposto da barra a cada nova barra."
L["Flip Starting Position"] = "Inverter Posição Inicial"
L["0 to disable."] = "0 para desativar."
L["Detach All"] = "Separar Tudo"
L["Detach Power"] = "Separar Poder"
L["Detaches power for the currently selected group."] = "Separa o poder para o grupo atualmente selecionado."
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "Encurta os nomes de forma semelhante a como são encurtados nas placas de identificação. Defina 'Posição do Texto' na configuração de nome para ESQUERDA."
L["Anchor to Health"] = "Ancorar à Saúde"
L["Adjusts the shortening based on the 'Health' text position."] = "Ajusta o encurtamento com base na posição do texto 'Saúde'."
L["Name Auto-Shorten"] = "Auto-Encurtar Nome"
L["Appends a diminishing returns tracker to frames."] = "Adiciona um rastreador de retornos decrescentes aos quadros."
L["DR Time"] = "Tempo DR"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "O tempo DR controla quanto tempo leva para os ícones serem redefinidos. Vários fatores podem afetar como o DR é redefinido. Se você estiver experimentando problemas constantes com a precisão da redefinição do DR, você pode alterar este valor."
L["Test"] = "Teste"
L["Players Only"] = "Apenas Jogadores"
L["Ignore NPCs when setting up icons."] = "Ignorar NPCs ao configurar ícones."
L["Setup Categories"] = "Configurar categorias"
L["Disable Cooldown"] = "Desativar recarga"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "Vá para 'Texto de Recarga' > 'Global' para configurar."
L["Color Borders"] = "Bordas Coloridas"
L["Spacing"] = "Espaçamento"
L["DR Strength Indicator: Text"] = "Indicador de Força DR: Texto"
L["DR Strength Indicator: Box"] = "Indicador de Força DR: Caixa"
L["Good"] = "Bom"
L["50% DR for hostiles, 100% DR for the player."] = "50% DR para hostis, 100% DR para o jogador."
L["Neutral"] = "Neutro"
L["75% DR for all."] = "75% DR para todos."
L["Bad"] = "Ruim"
L["100% DR for hostiles, 50% DR for the player."] = "100% DR para hostis, 50% DR para o jogador."
L["Category Border"] = "Borda da Categoria"
L["Select Category"] = "Selecionar Categoria"
L["Categories"] = "Categorias"
L["Add Category"] = "Adicionar Categoria"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "Formato: 'categoria IDFeitiço', ex. fear 10890.\nA lista de todas as categorias está disponível na seção 'cores'."
L["Remove Category"] = "Remover Categoria"
L["Category \"%s\" already exists, updating icon."] = "A categoria \"%s\" já existe, atualizando o ícone."
L["Category \"%s\" added with %s icon."] = "Categoria \"%s\" adicionada com o ícone %s."
L["Invalid category."] = "Categoria inválida."
L["Category \"%s\" removed."] = "Categoria \"%s\" removida."
L["DetachPower"] = "DesconectarPoder"
L["NameAutoShorten"] = "NomeEncurtarAuto"
L["Color Filter"] = "Filtro de Cor"
L["Enables color filter for the selected unit."] = "Ativa o filtro de cor para a unidade selecionada."
L["Toggle for the currently selected statusbar."] = "Alterna para a barra de status atualmente selecionada."
L["Select Statusbar"] = "Selecionar Barra de Status"
L["Health"] = "Saúde"
L["Castbar"] = "Barra de Lançamento"
L["Power"] = "Poder"
L["Tab Section"] = "Seção de Abas"
L["Toggle current tab."] = "Alternar aba atual."
L["Tab Priority"] = "Prioridade de Aba"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "Ao atender múltiplas condições, as cores da aba com maior prioridade serão aplicadas."
L["Copy Tab"] = "Copiar Aba"
L["Select a tab to copy its settings onto the current tab."] = "Selecione uma aba para copiar suas configurações para a aba atual."
L["Flash"] = "Piscar"
L["Speed"] = "Velocidade"
L["Glow"] = "Brilho"
L["Determines which glow to apply when statusbars are not detached from frame."] = "Determina qual brilho aplicar quando as barras de status não estão desanexadas do quadro."
L["Priority"] = "Prioridade"
L["When handling castbar, also manage its icon."] = "Ao manipular a barra de lançamento, também gerenciar seu ícone."
L["CastBar Icon Glow Color"] = "Cor do Brilho do Ícone da Barra de Lançamento"
L["CastBar Icon Glow Size"] = "Tamanho do Brilho do Ícone da Barra de Lançamento"
L["Borders"] = "Bordas"
L["CastBar Icon Color"] = "Cor do Ícone da Barra de Lançamento"
L["Toggle classbar borders."] = "Alternar bordas da barra de classe."
L["Toggle infopanel borders."] = "Alternar bordas do painel de informações."
L["ClassBar Color"] = "Cor da Barra de Classe"
L["Disabled unless classbar is enabled."] = "Desativado a menos que a barra de classe esteja ativada."
L["InfoPanel Color"] = "Cor do Painel de Informações"
L["Disabled unless infopanel is enabled."] = "Desativado a menos que o painel de informações esteja ativado."
L["ClassBar Adapt To"] = "Adaptar Barra de Classe Para"
L["Copies the color of the selected bar."] = "Copia a cor da barra selecionada."
L["InfoPanel Adapt To"] = "Adaptar Painel de Informações Para"
L["Override Mode"] = "Modo de Substituição"
L["'None' - threat borders highlight will be prioritized over this one".. "\n'Threat' - this highlight will be prioritized."] = "'Nenhum' - o destaque das bordas de ameaça terá prioridade sobre este".. "\n'Ameaça' - este destaque terá prioridade."
L["Threat"] = "Ameaça"
L["Determines which borders to apply when statusbars are not detached from frame."] = "Determina quais bordas aplicar quando as barras de status não estão desanexadas do quadro."
L["Bar-specific"] = "Específico da barra"
L["Lua Section"] = "Seção Lua"
L["Conditions"] = "Condições"
L["Font Settings"] = "Configurações de Fonte"
L["Player Only"] = "Apenas jogador"
L["Handle only player combat log events."] = "Lidar apenas com eventos do registro de combate do jogador."
L["Rotate Icon"] = "Girar ícone"
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
		"Exemplo de uso:"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
			"\n    return true, {mR = r, mG = g, mB = b}"..
			"\nelseif UnitIsUnit(unit, 'target') then"..
			"\n    return true"..
			"\nend"..
			"\n\n@@[raid, Health, 2, >5]@@ - retorna verdadeiro/falso com base em se a aba em questão "..
			"(no exemplo acima: 'player' - unidade alvo; 'Power' - barra de status alvo; '3' - aba alvo) está ativa ou não"..
			"\n(>/>=/<=/</~= num) - (opcional, apenas unidades de grupo) "..
			"corresponde a uma contagem específica de quadros acionados dentro do grupo (mais de 5 no exemplo acima)"..
			"\n\n'return true, {bR=1,f=false}' - você pode colorir dinamicamente os quadros retornando as cores em um formato de tabela:"..
			"\n  para aplicar à barra de status, atribua seus valores rgb a mR, mG e mB respectivamente"..
			"\n  para aplicar o brilho - a gR, gG, gB, gA (alfa)"..
			"\n  para bordas - bR, bG, bB"..
			"\n  e para o flash - fR, fG, fB, fA"..
			"\n  para evitar a estilização dos elementos, retorne {m = false, g = false, b = false, f = false}"..
			"\n\n'frame' e 'unit' estão disponíveis como 'frame' e 'unit' respectivamente: UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
			"\n\nEste módulo analisa strings, então tente fazer com que seu código siga a sintaxe estritamente, caso contrário, pode não funcionar."
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "A menos que esteja segurando um modificador, passar o cursor sobre unidades, itens e feitiços não exibe nenhum tooltip.\nModifica apenas os tooltips do cursor."
L["Pick a..."] = "Escolha um..."
L["...mover to anchor to."] = "...mover para ancorar."
L["...mover to anchor."] = "...mover para ancorar."
L["Point:"] = "Ponto:"
L["Relative:"] = "Relativo:"
L["Open Editor"] = "Abrir editor"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "A menos que segure um modificador, passar o mouse sobre unidades não exibe dica.\nApenas dicas no cursor."
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "Ancore todas as janelas de bate-papo antes de ativar.\nShift-clique no botão do gerenciador para acessar as configurações de abas."
L["Mouseover"] = "Passar o mouse"
L["Manager button visibility."] = "Visibilidade do botão do gerenciador."
L["Manager point."] = "Ponto do gerenciador."
L["Top Offset"] = "Deslocamento superior"
L["Bottom Offset"] = "Deslocamento inferior"
L["Left Offset"] = "Deslocamento esquerdo"
L["Right Offset"] = "Deslocamento direito"
L["Chat Search and Filter"] = "Pesquisa e Filtro de Bate-papo"
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
		"Utilitário de pesquisa e filtro para as janelas de bate-papo."..
			"\n\nSintaxe:"..
			"\n  :: - declaração 'e'"..
			"\n  ( ; ) - declaração 'ou'"..
			"\n  ! ! - declaração 'não'"..
			"\n  [ ] - sensível a maiúsculas e minúsculas"..
			"\n  @ @ - padrão lua"..
			"\n\nMensagens de exemplo:"..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\nConsultas de pesquisa e resultados:"..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - vazio"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\nTab/Shift-Tab para navegar pelos prompts."..
			"\nClique direito no botão de pesquisa para acessar consultas recentes."..
			"\nShift-Clique direito para acessar a configuração de pesquisa."..
			"\nAlt-Clique direito para mensagens bloqueadas."..
			"\nCtrl-Clique direito para limpar o cache de mensagens filtradas."..
			"\n\nNomes de canais e carimbos de data/hora não são analisados."
L["Search button visibility."] = "Visibilidade do botão de pesquisa."
L["Search button point."] = "Ponto do botão de pesquisa."
L["Config Tooltips"] = "Dicas de configuração"
L["Highlight Color"] = "Cor de destaque"
L["Match highlight color."] = "Cor de destaque de correspondência."
L["Filter Type"] = "Tipo de filtro"
L["Rule Terms"] = "Termos da regra"
L["Same logic as with the search."] = "Mesma lógica da pesquisa."
L["Select Chat Types"] = "Selecionar tipos de bate-papo"
L["Say"] = "Dizer"
L["Yell"] = "Gritar"
L["Party"] = "Grupo"
L["Raid"] = "Raide"
L["Guild"] = "Guilda"
L["Battleground"] = "Campo de batalha"
L["Whisper"] = "Sussurro"
L["Channel"] = "Canal"
L["Other"] = "Outro"
L["Select Rule"] = "Selecionar regra"
L["Select Chat Frame"] = "Selecionar janela de bate-papo"
L["Add Rule"] = "Adicionar regra"
L["Delete Rule"] = "Excluir regra"
L["Compact Chat"] = "Chat compacto"
L["Move left"] = "Mover para a esquerda"
L["Move right"] = "Mover para a direita"
L["Mouseover: Left"] = "Mouseover: Esquerda"
L["Mouseover: Right"] = "Mouseover: Direita"
L["Automatic Onset"] = "Início automático"
L["Scans tooltip texts and sets icons automatically."] = "Escaneia os textos das dicas e define os ícones automaticamente."
L["Icon (Default)"] = "Ícone (Padrão)"
L["Icon (Kill)"] = "Ícone (Matar)"
L["Icon (Chat)"] = "Ícone (Chat)"
L["Icon (Item)"] = "Ícone (Item)"
L["Show Text"] = "Mostrar texto"
L["Display progress status."] = "Mostrar status de progresso."
L["Name"] = "Nome"
L["Frequent Updates"] = "Atualizações Frequentes"
L["Events (optional)"] = "Eventos (opcional)"
L["InternalCooldowns"] = "Recargas Internas"
L["Displays internal cooldowns on trinket tooltips."] = "Exibe as recargas internas nas dicas de interface dos berloque."
L["Shortening X Offset"] = "Redução do Deslocamento X"
L["To Level"] = "Para Nível"
L["Names will be shortened based on level text position."] = "Os nomes serão encurtados com base na posição do texto de nível."
L["Add Item (by ID)"] = "Adicionar item (por ID)"
L["Remove Item"] = "Remover item"
L["Pre-Load"] = "Pré-carregamento"
L["Executes commands during the addon's initialization process."] = "Executa comandos durante o processo de inicialização do addon."
L["Justify"] = "Justificar"
L["Alt-Click: free bag slots, if possible."] = "Alt-Clique: liberar slots da bolsa, se possível."
L["Click: toggle layout mode."] = "Clique: alternar modo de layout."
L["Alt-Click: re-evaluate all items."] = "Alt-Clique: reavaliar todos os itens."
L["Drag-and-Drop: evaluate and position the cursor item."] = "Arraste e solte: avaliar e posicionar o item do cursor."
L["Shift-Alt-Click: toggle these hints."] = "Shift-Alt-Clique: alternar estas dicas."
L["Mouse-Wheel: navigate between special and normal bags."] = "Roda do Mouse: navegar entre bolsas especiais e normais."
L["This button accepts cursor item drops."] = "Este botão aceita itens soltos pelo cursor."
L["Setup Sections"] = "Configurar Seções"
L["Adds default sections set to the currently selected container."] = "Adiciona seções padrão ao recipiente atualmente selecionado."
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
		"Gerencia o posicionamento automático dos itens.\n"..
			"Sintaxe: filter@value\n\n"..
			"Filtros disponíveis:\n"..
			" id@number - corresponde ao itemID,\n"..
			" name@string - corresponde ao nome,\n"..
			" type@string - corresponde ao tipo,\n"..
			" subtype@string - corresponde ao subtipo,\n"..
			" ilvl@number - corresponde ao ilvl,\n"..
			" uselevel@number - corresponde ao nível de uso,\n"..
			" quality@number - corresponde à qualidade,\n"..
			" equipslot@number - corresponde ao InventorySlotID,\n"..
			" maxstack@number - corresponde ao limite da pilha,\n"..
			" price@number - corresponde ao preço de venda,\n"..
			" tooltip@string - corresponde ao texto da dica,\n"..
			" set@setName - corresponde aos itens do conjunto de equipamentos.\n\n"..
			"Todas as correspondências de string não diferenciam maiúsculas de minúsculas e correspondem apenas a símbolos alfanuméricos.\n"..
			"A lógica padrão do Lua para ramificação (and/or/parênteses/etc.) aplica-se.\n\n"..
			"Exemplo de uso (sacerdote t8 ou Shadowmourne):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
			"Aceita funções personalizadas (bagID, slotID, itemID são expostos).\n"..
			"O exemplo abaixo notifica sobre os itens recém-adquiridos.\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('Item adquirido: ' .. string)"
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
		"Sintaxe: filter@value@amount\n\n"..
			"Filtros disponíveis:\n"..
			" id@number@amount(+)/+ - corresponde ao itemID,\n"..
			" name@string@amount(+)/+ - corresponde ao nome,\n"..
			" type@string@amount(+)/+ - corresponde ao tipo,\n"..
			" subtype@string@amount(+)/+ - corresponde ao subtipo,\n"..
			" ilvl@number@amount(+)/+ - corresponde ao ilvl,\n"..
			" uselevel@number@amount(+)/+ - corresponde ao nível de uso,\n"..
			" quality@number@amount(+)/+ - corresponde à qualidade,\n"..
			" equipslot@number@amount(+)/+ - corresponde ao InventorySlotID,\n"..
			" maxstack@number@amount(+)/+ - corresponde ao limite da pilha,\n"..
			" price@number@amount(+)/+ - corresponde ao preço de venda,\n"..
			" tooltip@string@amount(+)/+ - corresponde ao texto da dica.\n\n"..
			"A parte opcional 'amount' pode ser:\n"..
			" um número - para comprar uma quantidade fixa,\n"..
			" um sinal de + - para reabastecer a pilha parcial existente ou comprar uma nova,\n"..
			" ambos (ex.: 5+) - para comprar itens suficientes para alcançar um total especificado (neste caso, 5),\n"..
			" omitido - padrão é 1.\n\n"..
			"Todas as correspondências de string não diferenciam maiúsculas de minúsculas e correspondem apenas a símbolos alfanuméricos.\n"..
			"A lógica padrão do Lua para ramificação (and/or/parênteses/etc.) aplica-se.\n\n"..
			"Exemplo de uso (sacerdote t8 ou Shadowmourne):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["PERIODIC"] = "PERIÓDICO"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "Segure esta tecla enquanto usa o comando /addOccupation para limpar a lista do NPC atual (alvo/sobre o qual o mouse está)."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "Use o comando /addOccupation enquanto estiver mirando ou passando o mouse sobre um NPC para adicioná-lo à lista. Use novamente para alternar."
L["Style Filter Icons"] = "Ícones de Filtro de Estilo"
L["Custom icons for the style filter."] = "Ícones personalizados para o filtro de estilo."
L["Whitelist"] = "Lista Branca"
L["X Direction"] = "Direção X"
L["Y Direction"] = "Direção Y"
L["Create Icon"] = "Criar ícone"
L["Delete Icon"] = "Excluir ícone"
L["0 to match frame width."] = "0 para corresponder à largura do quadro."
L["Remove a NPC"] = "Remover um NPC"
L["Change a NPC's Occupation"] = "Mudar a ocupação de um NPC"
L["...to the currently selected one."] = "...para o atualmente selecionado."
L["Select Occupation"] = "Selecionar Ocupação"
L["Sell"] = "Vender"
L["Action Type"] = "Tipo de ação"
L["Style Filter Additional Triggers"] = "Gatilhos Adicionais de Filtros de Estilo"
L["Triggers"] = "Gatilhos"
L["Example usage:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"] =
    "Exemplo de uso:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"
L["Abbreviate Name"] = "Abreviar Nome"
L["Highlight Self"] = "Destacar a si mesmo"
L["Highlight Others"] = "Destacar outros"
L["Self Inherit Name Color"] = "Herdar cor do nome próprio"
L["Self Texture"] = "Textura própria"
L["Whitespace to disable, empty to default."] = "Espaço em branco para desativar, vazio para padrão."
L["Self Color"] = "Cor própria"
L["Self Scale"] = "Escala própria"
L["Others Inherit Name Color"] = "Herdar cor do nome de outros"
L["Others Texture"] = "Textura dos outros"
L["Others Color"] = "Cor dos outros"
L["Others Scale"] = "Escala dos outros"
L["Targets"] = "Alvos"
L["Random dungeon finder queue status frame."] = "Quadro de status da fila do Localizador de masmorras aleatórias."
L["Queue Time"] = "Tempo de fila"
L["RDFQueueTracker"] = "RastreadorFilaRDF"
L["Abbreviate Numbers"] = "Abreviar números"
L["DEFAULTS"] = "PADRÕES"
L["INTERRUPT"] = "INTERROMPER"
L["CONTROL"] = "CONTROLE"
L["Copy List"] = "Copiar lista"
L["DepthOfField"] = "Profundidade de Campo"
L["Fades nameplates based on distance to screen center and cursor."] =
	"Desvanece as placas de nome baseado na distância ao centro da tela e ao cursor."
L["Disable in Combat"] = "Desativar em Combate"
L["Y Axis Pivot"] = "Pivô do Eixo Y"
L["Most opaque spot relative to screen center."] = "Ponto mais opaco relativo ao centro da tela."
L["Min Opacity"] = "Opacidade Mínima"
L["Falloff Rate"] = "Taxa de Queda"
L["Mouse Falloff Rate"] = "Taxa de Queda do Mouse"
L["Base multiplier."] = "Multiplicador base."
L["Effect Curve"] = "Curva de Efeito"
L["Mouse Effect Curve"] = "Curva de Efeito do Mouse"
L["Higher values result in steeper falloff."] = "Valores mais altos resultam em queda mais acentuada."
L["Enable Mouse"] = "Ativar mouse"
L["Also calculate cursor proximity."] = "Calcular também a proximidade do cursor."
L["Ignore Styled"] = "Ignorar estilizados"
L["Ignore Target"] = "Ignorar alvo"
L["Spells outside the selected whitelist filters will not be displayed."] =
	"Feitiços fora dos filtros de lista branca selecionados não serão exibidos."
L["Enables tooltips to display which set an item belongs to."] = "Habilita tooltips para exibir a qual conjunto um item pertence."
L["TierText"] = "Texto de nível"
L["Select Item"] = "Selecionar item"
L["Add Item (ID)"] = "Adicionar item (ID)"
L["Item Text"] = "Texto do item"
L["Sort by Filter"] = "Ordenar por filtro"
L["Makes aura sorting abide filter priorities."] = "Faz com que a organização de auras siga as prioridades do filtro."
L["Add Spell"] = "Adicionar feitiço"
L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"] =
	"Formato: 'IDFeitiço tempo de recarga',\nex: 42292 120\nou\nNomeFeitiço 20"
L["Fixes and Tweaks (requires reload)"] = "Correções e Ajustes (requer recarga)"
L["Restore Raid Controls"] = "Restaurar Controles de Raide"
L["Brings back 'Promote to Leader/Assist' controls in raid members' dropdown menus."] =
	"Restaura os controles de 'Promover a Líder/Ajudante' nos menus suspensos dos membros do raide."
L["World Map Quests"] = "Missões do Mapa-Múndi"
L["Allows Ctrl+Click on the world map quest list to open the quest log."] =
	"Permite usar Ctrl+Clique na lista de missões do mapa-múndi para abrir o diário de missões."
L["Unit Hostility Status"] = "Estado de Hostilidade da Unidade"
L["Forces a nameplate update when a unit changes factions or hostility status (e.g. mind control)."] =
	"Força a atualização da placa de identificação quando uma unidade muda de facção ou status de hostilidade (ex.: controle mental)."
L["Style Filter Name-Only"] = "Filtro de Estilo Somente Nome"
L["Fixes an issue where the style filter fails to update the nameplate on aura events after hiding its health."] =
	"Corrige um problema onde o filtro de estilo não atualiza a placa de identificação em eventos de aura após ocultar a vida."
L["Use Default Handling"] = "Usar manipulação padrão"
L["Show Group Members"] = "Mostrar membros do grupo"
L["Hide Group Members"] = "Ocultar membros do grupo"
L["Select 'Enemy Player' to configure."] = "Selecione 'Jogador inimigo' para configurar."
L["Capture Bar"] = "Barra de Captura"
L["Capture Bar Mover"] = "Movimentador da Barra de Captura"
L["Capture Bar Height"] = "Altura da Barra de Captura"
L["Also might fix capture bar related issues like progress marker not showing."] =
	"Também pode corrigir problemas relacionados à barra de captura, como o marcador de progresso não aparecendo."
L["Max Length"] = "Comprimento Máximo"
L["Copy button visibility."] = "Visibilidade do botão de copiar."
L["Mouseover: Channel Button"] = "Mouseover: Botão de Canal"
L["Mouseover: Copy Button"] = "Mouseover: Botão de Copiar"
L["Plugin version mismatch! Please, download appropriate plugin version at"] = "Incompatibilidade de versão do plugin! Baixe a versão correta em"
L["Questie Coherence"] = "Coerência com Questie"
L["Makes, once again, itemID tooltip line added by ElvUI to get positioned last on unit and item tooltips."] =
	"Faz com que a linha de itemID adicionada pelo ElvUI volte a aparecer por último nos tooltips de unidades e itens."
L["Attempts to extend font outline options across all of ElvUI."] =
	"Tenta expandir as opções de contorno de fonte por todo o ElvUI."
