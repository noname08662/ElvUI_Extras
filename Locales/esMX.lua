local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "esMX")

L["Hits the 'Confirm' button automatically."] = "Presiona el botón 'Confirmar' automáticamente."
L["Picks up quest items and money automatically."] = "Recoge automáticamente los objetos de misión y el dinero."
L["Fills 'DELETE' field automatically."] = "Rellena el campo 'BORRAR' automáticamente."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nCareful with important event triggers, there's no fail-safe mechanism."] = "Selecciona la primera opción de diálogo si es la única disponible a menos que se mantenga presionado un modificador.\nCuidado con los desencadenantes de eventos importantes, no hay un mecanismo a prueba de fallos."
L["Accepts and turns in quests automatically while holding a modifier."] = "Acepta y entrega misiones automáticamente mientras se mantiene presionado un modificador."
L["Loot info wiped."] = "Información de botín borrada."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "Comando /lootinfo para obtener un resumen rápido de los saqueos recientes.\n\nUso: /lootinfo Manzana 60\n'Manzana' - nombre del objeto/jugador \n(buscar @self para obtener el botín del jugador)\n'60' - \nlímite de tiempo (<60 segundos), opcional,\n/lootinfo !wipe - purgar el caché de botín."
L["Colors online friends' and guildmates' names in some of the messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "Colorea los nombres de amigos en línea y compañeros de hermandad en algunos mensajes y estiliza las tiradas.\nLas burbujas de chat ya manejadas no se estilizarán hasta que hagas /reload."
L["Colors loot roll messages for you and other players."] = "Colorea los mensajes de tiradas de botín para ti y otros jugadores."
L["Loot rolls icon size."] = "Tamaño del icono de tiradas de botín."
L["Restyles loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "Rediseña las barras de botín.\nRequiere que 'Tirada de botín' (General -> Mejoras de BlizzUI -> Tirada de botín) esté habilitado (activar este módulo lo habilita automáticamente)."
L["Displays the name of the player pinging the minimap."] = "Muestra el nombre del jugador que marca el minimapa."
L["Displays the currently held currency amount next to the item prices."] = "Muestra la cantidad de moneda actualmente poseída junto a los precios de los objetos."
L["Narrows down the World(..Frame)."] = "Reduce el World(..Frame)."
L["'Out of mana', 'Ability is not ready yet', etc."] = "'Sin maná', 'La habilidad aún no está lista', etc."
L["Re-enable quest updates."] = "Reactivar actualizaciones de misiones."
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - amarillo de Blizzard."
L["Text to display upon entering combat."] = "Texto para mostrar al entrar en combate."
L["Text to display upon leaving combat."] = "Texto para mostrar al salir del combate."
L["REQUIRES RELOAD."] = "REQUIERE RECARGA."
L["Icon to the left or right of the item link."] = "Ícono a la izquierda o derecha del enlace del artículo."
L["The size of the icon in the chat frame."] = "El tamaño del ícono en el marco del chat."
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "Añade sombras a todos los marcos.\nNo hace nada a menos que reemplaces tu ElvUI/Core/Toolkit.lua con el archivo relevante de la carpeta de Opcionales de este plugin."
L["Combat state notification alerts."] = "Alertas de notificación de estado de combate."
L["Custom editbox position and size."] = "Posición y tamaño personalizados del cuadro de edición."
L["Usage:"..
	"\n/tnote list - returns all eixting notes"..
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
			"\n/tnote list - devuelve todas las notas existentes"..
			"\n/tnote wipe - borra todas las notas existentes"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - igual que set (excepto para la parte de lua)"..
			"\n/tnote 1 get - igual que set, devuelve las notas existentes"..
			"\n/tnote 1 set TuNotaAquí - añade una nota al índice designado de la lista "..
			"o al texto del tooltip actualmente mostrado si se omite el segundo argumento (1 en este caso), "..
			"admite funciones y coloración "..
			"(proporcionar ningún texto borra la nota);"..
			"\npara romper las líneas, usa ::"..
			"\n\nEjemplo:"..
			"\n\n/tnote 3 set fuego pre-bis::fuente: Elba Jinón"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(color por defecto)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "Añade un icono junto a los hipervínculos del chat."
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "Una nueva barra de acción que recolecta objetos de misión utilizables de tu bolsa.\n\nDebido al límite de acciones de estado, este módulo anula la barra 10 creada por ElvUI Extra Action Bars."
L["Toggles the display of the actionbars backdrop."] = "Alterna la visualización del fondo de las barras de acción."
L["The frame won't show unless you mouse over it."] = "El marco no se mostrará a menos que pases el ratón por encima."
L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "Hereda el desvanecimiento global, pasar el ratón por encima, seleccionar objetivo, establecer foco, perder salud, entrar en combate eliminará la transparencia. De lo contrario, usará el nivel de transparencia en la configuración general de la barra de acción para el desvanecimiento global alfa."
L["The first button anchors itself to this point on the bar."] = "El primer botón se ancla a este punto en la barra."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "Haz clic derecho en el objeto mientras mantienes presionado el modificador para añadirlo a la lista negra. Los objetos en la lista negra no aparecerán en la barra.\nUsa /questbarRestore para purgar la lista negra."
L["The amount of buttons to display."] = "La cantidad de botones a mostrar."
L["The amount of buttons to display per row."] = "La cantidad de botones a mostrar por fila."
L["The size of the action buttons."] = "El tamaño de los botones de acción."
L["The spacing between buttons."] = "El espacio entre botones."
L["The spacing between the backdrop and the buttons."] = "El espacio entre el fondo y los botones."
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "Multiplica la altura o el ancho del fondo por este valor. Esto es útil si deseas tener más de una barra detrás de un fondo."
L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] showhide'"] = "Esto funciona como una macro, puedes ejecutar diferentes situaciones para hacer que la barra de acción se muestre/oculte de manera diferente.\n Ejemplo: '[combat] showhide'"
L["Adds anchoring options to movers' nudges."] = "Agrega opciones de anclaje a los empujones de los movedores."
L["Mod-clicking an item suggest a skill/item to process it."] = "Hacer clic con el modificador en un objeto sugiere una habilidad/objeto para procesarlo."
L["Holding %s while left-clicking a stack splits it in two; to combine available copies, right-click instead.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"Mantener presionado %s mientras se hace clic izquierdo en una pila la divide en dos; para combinar copias disponibles, haz clic derecho en su lugar."..
    "\n\nTambién modifica el SplitStackFrame para usar un cuadro de edición en lugar de flechas."
L["Extends the bags functionality."] = "Extiende la funcionalidad de las bolsas."
L["Handles automated repositioning of the newly received items."] = "Maneja el reposicionamiento automático de los objetos recién recibidos."
L["Default method: type > inventoryslotid > ilvl > name."] = "Método predeterminado: tipo > id de ranura de inventario > nivel de objeto > nombre."
L["Listed ItemIDs will not get sorted."] = "Los ID de objetos listados no se ordenarán."
L["Double-click the title text to minimize the section."] = "Haz doble clic en el texto del título para minimizar la sección."
L["Minimized section's line color."] = "Color de línea de la sección minimizada."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Ej. Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "Formato de condición inválido: "
L["The generated custom sorting method did not return a function."] = "El método de ordenación personalizado generado no devolvió una función."
L["The loaded custom sorting method did not return a function."] = "El método de ordenación personalizado cargado no devolvió una función."
L["Item received: "] = "Objeto recibido: "
L[" added."] = " agregado."
L[" removed."] = " eliminado."
L["Handles automated repositioning of the newly received items."..
	"\nSyntax: filter@value\n\n"..
	"Available filters:\n"..
	"id@number - matches itemID,\n"..
	"name@string - matches name,\n"..
	"subtype@string - matches subtype,\n"..
	"ilvl@number - matches ilvl,\n"..
	"uselevel@number - matches equip level,\n"..
	"quality@number - matches quality,\n"..
	"equipslot@number - matches nventorySlotID,\n"..
	"maxstack@number - matches stack limit,\n"..
	"price@number - matches sell price,\n\n"..
	"tooltip@string - matches tooltip text,\n\n"..
	"All string matches are not case sensitive and match only the alphanumeric symbols. Standart lua logic applies. "..
	"Look up GetItemInfo API for more info on filters. "..
	"Use GetAuctionItemClasses and GetAuctionItemSubClasses (same as on the AH) to get the localized types and subtypes values.\n\n"..
	"Example usage (priest t8 or Shadowmourne):\n"..
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
	"Accepts custom functions (bagID, slotID, itemID are exposed)\n"..
	"The below one notifies of the newly aquired items.\n\n"..
	"local icon = GetContainerItemInfo(bagID, slotID)\n"..
	"local _, link = GetItemInfo(itemID)\n"..
	"icon = gsub(icon, '\\124', '\\124\\124')\n"..
	"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
	"print('Item received: ' .. string)"] =
		"Maneja el reposicionamiento automático de los objetos recién recibidos."..
		"\nSintaxis: filtro@valor\n\n"..
		"Filtros disponibles:\n"..
		"id@número - coincide con el ID del objeto,\n"..
		"name@cadena - coincide con el nombre,\n"..
		"subtype@cadena - coincide con el subtipo,\n"..
		"ilvl@número - coincide con el nivel de objeto,\n"..
		"uselevel@número - coincide con el nivel de equipo,\n"..
		"quality@número - coincide con la calidad,\n"..
		"equipslot@número - coincide con el ID de ranura de inventario,\n"..
		"maxstack@número - coincide con el límite de apilamiento,\n"..
		"price@número - coincide con el precio de venta,\n\n"..
		"tooltip@cadena - coincide con el texto del tooltip,\n\n"..
		"Todas las coincidencias de cadena no distinguen entre mayúsculas y minúsculas y solo coinciden con los símbolos alfanuméricos. Se aplica la lógica estándar de Lua. "..
		"Consulte la API GetItemInfo para obtener más información sobre los filtros. "..
		"Use GetAuctionItemClasses y GetAuctionItemSubClasses (igual que en la Casa de Subastas) para obtener los valores localizados de tipos y subtipos.\n\n"..
		"Ejemplo de uso (sacerdote t8 o Shadowmourne):\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@deSantificación) or name@shadowmourne.\n\n"..
		"Acepta funciones personalizadas (bagID, slotID, itemID están expuestos)\n"..
		"El siguiente ejemplo notifica sobre los objetos recién adquiridos.\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\\124', '\\124\\124')\n"..
		"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
		"print('Objeto recibido: ' .. string)"
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] =
		"Método predeterminado: tipo > ID de ranura de inventario > nivel de objeto > nombre.\n\n"..
		"Acepta funciones personalizadas (bagID y slotID están disponibles en a/b.bagID/slotID).\n\n"..
		"function(a,b)\n"..
		"--tu lógica de ordenamiento aquí\n"..
		"end\n\n"..
		"Deja en blanco para usar el método predeterminado."
L["Event and OnUpdate handler."] = "Manejador de eventos y OnUpdate."
L["Minimal time gap between two consecutive executions."] = "Intervalo de tiempo mínimo entre dos ejecuciones consecutivas."
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - script 'OnUpdate'"
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = "UNIT_AURA CHAT_MSG_WHISPER etc."
L["Syntax:"..
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
	"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."] =
		"Sintaxis:"..
		"\n\nEVENTO[n~=nil]"..
		"\n[n~=valor]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@comandos@@@"..
		"\n\n'EVENTO' - Evento de la sección de eventos anterior"..
		"\n'n, m, k' - índices de los argumentos de carga útil deseados (número)"..
		"\n'nil/valor/booleano/código lua' - salida deseada del argumento n"..
		"\n'@@' - bandera de argumento lua, debe ir antes del código lua dentro de la sección de valor de los argumentos"..
		"\n'~' - bandera de negación, agregar antes del signo igual para que el código se ejecute si n/m/k no coincide con el valor establecido"..
		"\n'@@@ @@@' - paréntesis que contienen los comandos."..
		"\nPuede acceder a la carga útil (...) como de costumbre."..
		"\n\nEjemplo:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(el jugador ha ganado/perdido un aura)@@@"..
		"\n\nCHAT_MSG_WHISPER"..
		"\n[5~=UnitName('player')]"..
		"\n[14=false]@@@"..
		"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
		"\n\nCOMBAT_LOG_EVENT_"..
		"\nUNFILTERED"..
		"\n[5=UnitName('arena1')]"..
		"\n[5=UnitName('arena2')]@@@"..
		"\nfor i = 1, 2 do"..
		"\nif UnitDebuff('party'..i, 'Hechizo malo')"..
		"\nthen print(UnitName('party'..i)..' está afectado!')"..
		"\nend end@@@"..
		"\n\nEste módulo analiza cadenas, así que trate de que su código siga estrictamente la sintaxis, o de lo contrario podría no funcionar."
L["Highlights auras."] = "Destaca auras."
L["E.g. 42292"] = "Por ejemplo, 42292"
L["Aplies highlights to all auras passing the selected filter."] = "Destaca todas las auras que pasan el filtro seleccionado."
L["Priority: spell, filter, curable/stealable."] = "Prioridad: hechizo, filtro, curable/robable."
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "Si se activa, se usarán los valores GLOBAL de Hechizo o Filtro."
L["Makes auras grow sideswise."] = "Hace que las auras crezcan lateralmente."
L["Turns off texture fill."] = "Desactiva el relleno de textura."
L["Makes auras flicker right before fading out."] = "Hace que las auras parpadeen justo antes de desvanecerse."
L["Disables border coloring."] = "Desactiva el coloreado del borde."
L["Click Cancel"] = "Cancelar al hacer clic"
L["Right-click a player buff to cancel it."] = "Haz clic derecho en un buff del jugador para cancelarlo."
L["Disables debuffs desaturation."] = "Desactiva la desaturación de los debuffs."
L["Saturated Debuffs"] = "Debuffs Saturados"
L["Confirm Rolls"] = "Confirmar tiradas"
L["Quest Items and Money"] = "Objetos de misión y dinero"
L["Fill Delete"] = "Rellenar borrado"
L["Gossip"] = "Diálogo"
L["Accept Quest"] = "Aceptar misión"
L["Loot Info"] = "Información de botín"
L["Styled Messages"] = "Mensajes con estilo"
L["Indicator Color"] = "Color del indicador"
L["Select Status"] = "Seleccionar estado"
L["Select Indicator"] = "Seleccionar indicador"
L["Styled Loot Messages"] = "Mensajes de botín con estilo"
L["Icon Size"] = "Tamaño del icono"
L["Loot Bars"] = "Barras de botín"
L["Bar Height"] = "Altura de la barra"
L["Bar Width"] = "Ancho de la barra"
L["Player Pings"] = "Pings de jugadores"
L["Held Currency"] = "Moneda en posesión"
L["LetterBox"] = "Letterbox"
L["Left"] = "Izquierda"
L["Right"] = "Derecha"
L["Top"] = "Arriba"
L["Bottom"] = "Abajo"
L["Hide Errors"] = "Ocultar errores"
L["Show quest updates"] = "Mostrar actualizaciones de misiones"
L["Less Tooltips"] = "Menos tooltips"
L["Misc."] = "Misc."
L["Loot&Style"] = "Botín y estilo"
L["Automation"] = "Automatización"
L["Bags"] = "Bolsas"
L["Easier Processing"] = "Procesamiento más fácil"
L["Modifier"] = "Modificador"
L["Split Stack"] = "Dividir pila"
L["Bags Extended"] = "Bolsas extendidas"
L["Select Container Type"] = "Seleccionar tipo de contenedor"
L["Settings"] = "Configuración"
L["Add Section"] = "Añadir sección"
L["Delete Section"] = "Eliminar sección"
L["Section Length"] = "Longitud de sección"
L["Select Section"] = "Seleccionar sección"
L["Section Priority"] = "Prioridad de sección"
L["Section Spacing"] = "Espaciado de sección"
L["Collection Method"] = "Método de colección"
L["Sorting Method"] = "Método de ordenación"
L["Ignore Item (by ID)"] = "Ignorar objeto (por ID)"
L["Remove Ignored"] = "Eliminar ignorados"
L["Minimize"] = "Minimizar"
L["Line Color"] = "Color de línea"
L["Title"] = "Título"
L["Color"] = "Color"
L["Attach to Icon"] = "Adjuntar al icono"
L["Text"] = "Texto"
L["Font Size"] = "Tamaño de fuente"
L["Font"] = "Fuente"
L["Font Flags"] = "Banderas de fuente"
L["Point"] = "Punto"
L["Relative Point"] = "Punto relativo"
L["X Offset"] = "Desplazamiento X"
L["Y Offset"] = "Desplazamiento Y"
L["Icon"] = "Icono"
L["Attach to Text"] = "Adjuntar al texto"
L["Texture"] = "Textura"
L["Size"] = "Tamaño"
L["MoversPlus"] = "MovedoresPlus"
L["Movers Plus"] = "Movedores Plus"
L["CustomCommands"] = "Comandos personalizados"
L["Custom Commands"] = "Comandos personalizados"
L["QuestBar"] = "Barra de misiones"
L["Quest Bar"] = "Barra de misiones"
L["Settings"] = "Configuración"
L["Backdrop"] = "Fondo"
L["Show Empty Buttons"] = "Mostrar botones vacíos"
L["Mouse Over"] = "Al pasar el ratón"
L["Inherit Global Fade"] = "Heredar desvanecimiento global"
L["Anchor Point"] = "Punto de anclaje"
L["Modifier"] = "Modificador"
L["Buttons"] = "Botones"
L["Buttons Per Row"] = "Botones por fila"
L["Button Size"] = "Tamaño del botón"
L["Button Spacing"] = "Espaciado de botones"
L["Backdrop Spacing"] = "Espaciado del fondo"
L["Height Multiplier"] = "Multiplicador de altura"
L["Width Multiplier"] = "Multiplicador de ancho"
L["Alpha"] = "Alfa"
L["Visibility State"] = "Estado de visibilidad"
L["Enable Tab"] = "Habilitar pestaña"
L["Throttle Time"] = "Tiempo de limitación"
L["Select Tab"] = "Seleccionar pestaña"
L["Select Event"] = "Seleccionar evento"
L["Rename Tab"] = "Renombrar pestaña"
L["Add Tab"] = "Agregar pestaña"
L["Delete Tab"] = "Eliminar pestaña"
L["Open Edit Frame"] = "Abrir marco de edición"
L["Events"] = "Eventos"
L["Commands to execute"] = "Comandos a ejecutar"
L["Sub-Section"] = "Subsección"
L["Select"] = "Seleccionar"
L["Icon Orientation"] = "Orientación del icono"
L["Icon Size"] = "Tamaño del icono"
L["Height Offset"] = "Desplazamiento de altura"
L["Width Offset"] = "Desplazamiento de ancho"
L["Text Color"] = "Color del texto"
L["Entering combat"] = "Entrando en combate"
L["Leaving combat"] = "Saliendo del combate"
L["Font"] = "Fuente"
L["Font Outline"] = "Contorno de fuente"
L["Font Size"] = "Tamaño de fuente"
L["Texture Width"] = "Ancho de textura"
L["Texture Height"] = "Alto de textura"
L["Custom Texture"] = "Textura personalizada"
L["ItemIcons"] = "Iconos de objetos"
L["TooltipNotes"] = "Notas de información sobre herramientas"
L["ChatEditBox"] = "Cuadro de edición de chat"
L["EnterCombatAlert"] = "Alerta de entrada en combate"
L["GlobalShadow"] = "Sombra global"
L["Any"] = "Cualquiera"
L["Guildmate"] = "Compañero de hermandad"
L["Friend"] = "Amigo"
L["Self"] = "Yo"
L["New Tab"] = "Nueva pestaña"
L["None"] = "Ninguno"
L["Version: "] = "Versión: "
L["Color A"] = "Color A"
L["Chat messages, etc."] = "Mensajes de chat, etc."
L["Color B"] = "Color B"
L["Plugin Color"] = "Color del Plugin"
L["Icons Browser"] = "Navegador de Íconos"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "Obtén https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html para íconos más limpios y recortados."
L["Add Texture"] = "Agregar Textura"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Añade texturas a la lista de texturas generales.\nEj. Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "Eliminar Textura"
L["Highlights"] = "Destacar"
L["Select Type"] = "Seleccionar Tipo"
L["Highlights Settings"] = "Configuraciones de Destacar"
L["Add Spell (by ID)"] = "Agregar Hechizo (por ID)"
L["Add Filter"] = "Agregar Filtro"
L["Remove Selected"] = "Eliminar Seleccionado"
L["Select Spell or Filter"] = "Seleccionar Hechizo o Filtro"
L["Use Global Settings"] = "Usar Configuración Global"
L["Selected Spell or Filter Values"] = "Valores de Hechizo o Filtro Seleccionado"
L["Enable Shadow"] = "Habilitar Sombra"
L["Size"] = "Tamaño"
L["Shadow Color"] = "Color de Sombra"
L["Enable Border"] = "Habilitar Borde"
L["Border Color"] = "Color de Borde"
L["Centered Auras"] = "Auras Centrada"
L["Cooldown Disable"] = "Desactivar Tiempo de Recarga"
L["Animate Fade-Out"] = "Animar Desvanecimiento"
L["Type Borders"] = "Bordes de Tipo"
L[" filter added."] = " filtro añadido."
L[" filter removed."] = " filtro eliminado."
L["GLOBAL"] = "GLOBAL"
L["CURABLE"] = "Curable"
L["STEALABLE"] = "Robable"
L["--Filters--"] = "--Filtros--"
L["--Spells--"] = "--Hechizos--"
L["FRIENDLY"] = "Amistoso"
L["ENEMY"] = "Enemigo"
L["AuraBars"] = "Barras de Aura"
L["Auras"] = "Auras"
L["ClassificationIndicator"] = "Indicador de Clasificación"
L["ClassificationIcons"] = "Íconos de Clasificación"
L["ColorFilter"] = "Filtro de Color"
L["Cooldowns"] = "Cooldowns"
L["DRTracker"] = "Rastreador de DR"
L["Guilds&Titles"] = "Guildas y Títulos"
L["Name&Level"] = "Nombre y Nivel"
L["QuestIcons"] = "Íconos de Misiones"
L["StyleFilter"] = "Filtro de Estilo"
L["Search:"] = "Buscar:"
L["Click to select."] = "Haz clic para seleccionar."
L["Hover again to see the changes."] = "Pasa el cursor nuevamente para ver los cambios."
L["Note set for "] = "Nota establecida para "
L["Note cleared for "] = "Nota borrada para "
L["No note to clear for "] = "No hay nota para borrar para "
L["Added icon to the note for "] = "Icono añadido a la nota para "
L["Note icon cleared for "] = "Icono de nota borrado para "
L["No note icon to clear for "] = "No hay icono de nota para borrar para "
L["Current note for "] = "Nota actual para "
L["No note found for this tooltip."] = "No se encontró nota para este tooltip."
L["Notes: "] = "Notas: "
L["No notes are set."] = "No hay notas establecidas."
L["No tooltip is currently shown or unsupported tooltip type."] = "No se muestra ningún tooltip actualmente o es un tipo de tooltip no soportado."
L["All notes have been cleared."] = "Todas las notas han sido borradas."
L["Accept"] = "Aceptar"
L["Cancel"] = "Cancelar"
L["Purge Cache"] = "Purgar caché"
L["Guilds"] = "Hermandades"
L["Separator"] = "Separador"
L["X Offset"] = "Desplazamiento X"
L["Y Offset"] = "Desplazamiento Y"
L["Level"] = "Nivel"
L["Visibility State"] = "Estado de visibilidad"
L["City (Resting)"] = "Ciudad (Descansando)"
L["PvP"] = "JcJ"
L["Arena"] = "Arena"
L["Party"] = "Grupo"
L["Raid"] = "Banda"
L["Colors"] = "Colores"
L["Guild"] = "Hermandad"
L["All"] = "Todo"
L["Occupation Icon"] = "Icono de ocupación"
L["OccupationIcon"] = "Icono de ocupación"
L["Size"] = "Tamaño"
L["Anchor"] = "Anclaje"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "Eliminar ocupación"
L["Modifier"] = "Modificador"
L["Add Texture Path"] = "Agregar ruta de textura"
L["Remove Selected Texture"] = "Eliminar textura seleccionada"
L["Titles"] = "Títulos"
L["Reaction Color"] = "Color de reacción"
L["Hold this while using /addOccupation command to clear the list of the current target/mouseover occupation.\nDon't forget to unbind the modifier+key bind!"] =
	"Mantén presionado esto mientras usas el comando /addOccupation para borrar la lista de la ocupación actual del objetivo/ratón sobre.\n¡No olvides desvincular la combinación de modificador+tecla!"
L["Color based on reaction type."] = "Color basado en el tipo de reacción."
L["Nameplates"] = "Placas de nombre"
L["Unitframes"] = "Marcos de unidad"
L["An icon similar to the minimap search.\n\nTooltip scanning, might not be precise.\n\nFor consistency reasons, no keywards are added by defult, use /addOccupation command to mark the appropriate ones yourself (only need to do it once per unique occupation text)."] =
	"Un icono similar a la búsqueda del minimapa.\n\nEscaneo de tooltips, puede no ser preciso.\n\nPor razones de consistencia, no se agregan palabras clave por defecto, usa el comando /addOccupation para marcar las apropiadas tú mismo (solo necesitas hacerlo una vez por texto de ocupación único)."
L["Displays player guild text."] = "Muestra el texto de la hermandad del jugador."
L["Displays NPC occupation text."] = "Muestra el texto de ocupación del PNJ."
L["Strata"] = "Estrato"
L["Mark"] = "Marcar"
L["Mark the target/mouseover plate."] = "Marca la placa del objetivo/mouseover."
L["Unmark"] = "Desmarcar"
L["Unmark the target/mouseover plate."] = "Desmarca la placa del objetivo/mouseover."
L["FRIENDLY_PLAYER"] = "Jugador amistoso"
L["FRIENDLY_NPC"] = "PNJ amistoso"
L["ENEMY_PLAYER"] = "Jugador enemigo"
L["ENEMY_NPC"] = "PNJ enemigo"
L["Handles positioning and color."] = "Maneja el posicionamiento y el color."
L["Selected Type"] = "Tipo seleccionado"
L["Reaction based coloring for non-cached characters."] = "Coloración basada en reacción para personajes no almacenados en caché."
L["Apply Custom Color"] = "Aplicar color personalizado"
L["Class Color"] = "Color de clase"
L["Use class colors."] = "Usa colores de clase."
L["Unmark All"] = "Desmarcar todo"
L["Unmark all plates."] = "Desmarca todas las placas."
L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"] =
	"Uso: macro '/qmark' vinculada a una tecla de tu elección.\n\n¡No olvides desvincular también tus atajos de modificador!"
L["Use Backdrop"] = "Usar fondo"
L["Usage:\n%%d=%%s\n\n%%d - index from the list below\n%%s - keywords to look for\n\nIndexes of icons:"..
	"\n1 - %s"..
	"\n2 - %s"..
	"\n3 - %s"..
	"\n4 - %s"..
	"\n5 - %s"..
	"\n6 - %s"..
	"\n7 - %s"..
	"\n8 - %s"..
	"\n9 - %s"..
	"\n10 - %s"..
	"\n11 - %s"..
	"\n12 - %s"..
	"\n13 - %s"..
	"\n14 - %s"..
	"\n\n\nAlso available as a '/addOccupation %%d' slash command where %%d is an optional icon index. "..
	"If no index is provided, this command will cycle through all of the available icons. Works on either TARGET or MOUSEOVER, prioritising the latter."] =
		"Uso:\n%%d=%%s\n\n%%d - índice de la lista a continuación\n%%s - palabras clave para buscar\n\nÍndices de iconos:"..
			"\n1 - %s"..
			"\n2 - %s"..
			"\n3 - %s"..
			"\n4 - %s"..
			"\n5 - %s"..
			"\n6 - %s"..
			"\n7 - %s"..
			"\n8 - %s"..
			"\n9 - %s"..
			"\n10 - %s"..
			"\n11 - %s"..
			"\n12 - %s"..
			"\n13 - %s"..
			"\n14 - %s"..
			"\n\n\nTambién disponible como un comando '/addOccupation %%d' donde %%d es un índice de icono opcional. "..
			"Si no se proporciona un índice, este comando recorrerá todos los iconos disponibles. Funciona en TARGET o MOUSEOVER, priorizando este último."
L["Linked Style Filter Triggers"] = "Disparadores de Filtro de Estilo Vinculado"
L["Select Link"] = "Seleccionar Enlace"
L["New Link"] = "Nuevo Enlace"
L["Delete Link"] = "Eliminar Enlace"
L["Target Filter"] = "Filtro de Objetivo"
L["Select a filter to trigger the styling."] = "Selecciona un filtro para activar el estilo."
L["Apply Filter"] = "Aplicar Filtro"
L["Select a filter to style the frames not passing the target filter triggers."] = "Selecciona un filtro para diseñar los marcos que no pasen los disparadores del filtro de objetivo."
L["Cache purged."] = "Caché purgado."
L["Test Mode"] = "Modo de prueba"
L["Draws player cooldowns."] = "Muestra los tiempos de reutilización del jugador."
L["Show Everywhere"] = "Mostrar en todas partes"
L["Show in Cities"] = "Mostrar en ciudades"
L["Show in Battlegrounds"] = "Mostrar en campos de batalla"
L["Show in Arenas"] = "Mostrar en arenas"
L["Show in Instances"] = "Mostrar en instancias"
L["Show in the World"] = "Mostrar en el mundo"
L["Header"] = "Encabezado"
L["Icons"] = "Iconos"
L["OnUpdate Throttle"] = "Limitador de actualización"
L["Trinket First"] = "Abalorio primero"
L["Animate Fade Out"] = "Animación de desvanecimiento"
L["Border Color"] = "Color del borde"
L["Growth Direction"] = "Dirección de crecimiento"
L["Sort Method"] = "Método de ordenación"
L["Icon Size"] = "Tamaño del icono"
L["Icon Spacing"] = "Espaciado de iconos"
L["Per Row"] = "Por fila"
L["Max Rows"] = "Filas máximas"
L["CD Text"] = "Texto de tiempo de reutilización"
L["Show"] = "Mostrar"
L["Cooldown Fill"] = "Relleno de tiempo de reutilización"
L["Reverse"] = "Invertir"
L["Direction"] = "Dirección"
L["Spells"] = "Hechizos"
L["Add Spell (by ID)"] = "Añadir hechizo (por ID)"
L["Remove Selected Spell"] = "Eliminar hechizo seleccionado"
L["Select Spell"] = "Seleccionar hechizo"
L["Shadow"] = "Sombra"
L["Pet Ability"] = "Habilidad de mascota"
L["Shadow Size"] = "Tamaño de sombra"
L["Shadow Color"] = "Color de sombra"
L["Sets update speed threshold."] = "Establece el umbral de velocidad de actualización."
L["Makes PvP trinkets and human racial always get positioned first."] = "Hace que los abalorios de JcJ y la racial humana siempre se posicionen primero."
L["Makes icons flash when the cooldown's about to end."] = "Hace que los iconos parpadeen cuando el tiempo de reutilización está a punto de terminar."
L["Any value apart from black (0,0,0) would override borders by time left."] = "Cualquier valor que no sea negro (0,0,0) anulará los bordes por tiempo restante."
L["Colors borders by time left."] = "Colorea los bordes por tiempo restante."
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "Formato: 'ID del hechizo tiempo de reutilización', ej. 42292 120"
L["For the important stuff."] = "Para las cosas importantes."
L["Pet casts require some special treatment."] = "Los lanzamientos de mascotas requieren un tratamiento especial."
L["Color by Type"] = "Color por tipo"
L["Flip Icon"] = "Voltear icono"
L["Texture List"] = "Lista de texturas"
L["Keep Icon"] = "Mantener icono"
L["Texture"] = "Textura"
L["Texture Coordinates"] = "Coordenadas de textura"
L["Select Affiliation"] = "Seleccionar afiliación"
L["Width"] = "Ancho"
L["Height"] = "Alto"
L["Select Class"] = "Seleccionar clase"
L["Points"] = "Puntos"
L["Colors the icon based on the unit type."] = "Colorea el icono según el tipo de unidad."
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "Voltea el icono horizontalmente. No es compatible con las coordenadas de textura."
L["Keep the original icon texture."] = "Mantener la textura original del icono."
L["NPCs"] = "PNJs"
L["Players"] = "Jugadores"
L["By duration, ascending."] = "Por duración, ascendente."
L["By duration, descending."] = "Por duración, descendente."
L["By time used, ascending."] = "Por tiempo usado, ascendente."
L["By time used, descending."] = "Por tiempo usado, descendente."
L["Additional settings for the Elite Icon."] = "Configuraciones adicionales para el Icono de Élite."
L["Player class icons."] = "Iconos de clase del jugador."
L["Class Icons"] = "Iconos de Clase"
L["Vector Class Icons"] = "Iconos de Clase Vectoriales"
L["Class Crests"] = "Emblemas de Clase"
L["Floating Combat Feedback"] = "Retroalimentación de Combate Flotante"
L["Select Unit"] = "Seleccionar Unidad"
L["player"] = "jugador (player)"
L["target"] = "objetivo (target)"
L["targettarget"] = "objetivo del objetivo (targettarget)"
L["targettargettarget"] = "objetivo del objetivo del objetivo (targettargettarget)"
L["focus"] = "foco (focus)"
L["focustarget"] = "objetivo del foco (focustarget)"
L["pet"] = "mascota (pet)"
L["pettarget"] = "objetivo de la mascota (pettarget)"
L["raid"] = "banda (raid)"
L["raid40"] = "banda de 40 (raid40)"
L["raidpet"] = "mascota de banda (raidpet)"
L["party"] = "grupo (party)"
L["partypet"] = "mascota del grupo (partypet)"
L["partytarget"] = "objetivo del grupo (partytarget)"
L["boss"] = "jefe (boss)"
L["arena"] = "arena (arena)"
L["assist"] = "asistente (assist)"
L["assisttarget"] = "objetivo del asistente (assisttarget)"
L["tank"] = "tanque (tank)"
L["tanktarget"] = "objetivo del tanque (tanktarget)"
L["Scroll Time"] = "Tiempo de Desplazamiento"
L["Event Settings"] = "Configuración de Eventos"
L["Event"] = "Evento"
L["Disable Event"] = "Deshabilitar Evento"
L["School"] = "Escuela"
L["Use School Colors"] = "Usar Colores de Escuela"
L["Colors"] = "Colores"
L["Colors (School)"] = "Colores (Escuela)"
L["Animation Type"] = "Tipo de Animación"
L["Custom Animation"] = "Animación Personalizada"
L["Flag Settings"] = "Configuración de Banderas"
L["Flag"] = "Bandera"
L["Font Size Multiplier"] = "Multiplicador de Tamaño de Fuente"
L["Animation by Flag"] = "Animación por Bandera"
L["Icon Settings"] = "Configuración de Iconos"
L["Show Icon"] = "Mostrar Icono"
L["Icon Position"] = "Posición del Icono"
L["Bounce"] = "Rebotar"
L["Blacklist"] = "Lista Negra"
L["Appends floating combat feedback fontstrings to frames."] = "Añade cadenas de texto de retroalimentación de combate flotante a los marcos."
L["There seems to be a font size limit?"] = "¿Parece haber un límite de tamaño de fuente?"
L["Not every event is eligible for this. But some are."] = "No todos los eventos son elegibles para esto. Pero algunos sí."
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "Define tu animación personalizada como una función lua.\n\nEjemplo:\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "Activa para que esta sección maneje las animaciones de banderas en su lugar.\n\nNo todos los eventos tienen banderas."
L["Flip position left-right."] = "Voltear posición de izquierda a derecha."
L["E.g. 42292"] = "Ej. 42292"
L["Loaded custom animation did not return a function."] = "La animación personalizada cargada no devolvió una función."
L["Before Text"] = "Texto Anterior"
L["After Text"] = "Texto Posterior"
L["Remove Spell"] = "Eliminar Hechizo"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"Define tu animación personalizada como una función lua.\n\nEjemplo:\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "ABSORBER"
L["BLOCK"] = "BLOQUEAR"
L["CRITICAL"] = "CRÍTICO"
L["CRUSHING"] = "APLASTANTE"
L["GLANCING"] = "DE REFILÓN"
L["RESIST"] = "RESISTIR"
L["Diagonal"] = "Diagonal"
L["Fountain"] = "Fuente"
L["Horizontal"] = "Horizontal"
L["Random"] = "Aleatorio"
L["Static"] = "Estático"
L["Vertical"] = "Vertical"
L["DEFLECT"] = "DESVIAR"
L["DODGE"] = "ESQUIVAR"
L["ENERGIZE"] = "ENERGIZAR"
L["EVADE"] = "EVADIR"
L["HEAL"] = "CURAR"
L["IMMUNE"] = "INMUNE"
L["INTERRUPT"] = "INTERRUMPIR"
L["MISS"] = "FALLAR"
L["PARRY"] = "PARAR"
L["REFLECT"] = "REFLEJAR"
L["WOUND"] = "HERIR"
L["Debuff applied/faded/refreshed"] = "Perjuicio aplicado/desvanecido/renovado"
L["Buff applied/faded/refreshed"] = "Beneficio aplicado/desvanecido/renovado"
L["Physical"] = "Físico"
L["Holy"] = "Sagrado"
L["Fire"] = "Fuego"
L["Nature"] = "Naturaleza"
L["Frost"] = "Escarcha"
L["Shadow"] = "Sombra"
L["Arcane"] = "Arcano"
L["Astral"] = "Astral"
L["Chaos"] = "Caos"
L["Elemental"] = "Elemental"
L["Magic"] = "Magia"
L["Plague"] = "Plaga"
L["Radiant"] = "Radiante"
L["Shadowflame"] = "Llama de las Sombras"
L["Shadowfrost"] = "Escarcha de las Sombras"
L["Up"] = "Arriba"
L["Down"] = "Abajo"
L["Classic Style"] = "Estilo Clásico"
L["If enabled, default cooldown style will be used."] = "Si está habilitado, se utilizará el estilo de tiempo de reutilización predeterminado."
L["Classification Indicator"] = "Indicador de Clasificación"
L["Copy Unit Settings"] = "Copiar Configuración de Unidad"
L["Enable Player Class Icons"] = "Activar Iconos de Clase de Jugador"
L["Enable NPC Classification Icons"] = "Activar Iconos de Clasificación de NPC"
L["Type"] = "Tipo"
L["Select unit type."] = "Seleccionar tipo de unidad."
L["World Boss"] = "Jefe del Mundo"
L["Elite"] = "Élite"
L["Rare"] = "Raro"
L["Rare Elite"] = "Élite Raro"
L["Class Spec Icons"] = "Iconos de Especialización de Clase"
L["Classification Textures"] = "Texturas de Clasificación"
L["Use Nameplates' Icons"] = "Usar Iconos de Placas de Nombre"
L["Color enemy npc icon based on the unit type."] = "Colorear icono de NPC enemigo basado en el tipo de unidad."
L["Strata and Level"] = "Estrato y Nivel"
L["Warrior"] = "Guerrero"
L["Warlock"] = "Brujo"
L["Priest"] = "Sacerdote"
L["Paladin"] = "Paladín"
L["Druid"] = "Druida"
L["Rogue"] = "Pícaro"
L["Mage"] = "Mago"
L["Hunter"] = "Cazador"
L["Shaman"] = "Chamán"
L["Deathknight"] = "Caballero de la Muerte"
L["Aura Bars"] = "Barras de Aura"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "Agrega opciones de configuración extra para barras de aura.\n\n Para opciones como tamaño y separación, ¡usa los Movedores de Barras de Aura de ElvUI!"
L["Hide"] = "Ocultar"
L["Spell Name"] = "Nombre del Hechizo"
L["Spell Time"] = "Tiempo del Hechizo"
L["Bounce Icon Points"] = "Puntos de Rebote de Icono"
L["Set icon to the opposite side of the bar each new bar."] = "Colocar icono en el lado opuesto de la barra en cada nueva barra."
L["Flip Starting Position"] = "Voltear Posición Inicial"
L["0 to disable."] = "0 para desactivar."
L["Detach All"] = "Separar Todo"
L["Detach Power"] = "Separar Poder"
L["Detaches power for the currently selected group."] = "Separa el poder para el grupo actualmente seleccionado."
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "Acorta los nombres de manera similar a como se acortan en las placas de nombre. Configura 'Posición del Texto' en la configuración de nombre a IZQUIERDA."
L["Anchor to Health"] = "Anclar a Salud"
L["Adjusts the shortening based on the 'Health' text position."] = "Ajusta el acortamiento basado en la posición del texto de 'Salud'."
L["Name Auto-Shorten"] = "Auto-Acortar Nombre"
L["Appends a diminishing returns tracker to frames."] = "Añade un rastreador de rendimientos decrecientes a los marcos."
L["DR Time"] = "Tiempo DR"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "El tiempo DR controla cuánto tardan los iconos en reiniciarse. Varios factores pueden afectar cómo se reinicia DR. Si experimentas problemas constantes con la precisión del reinicio de DR, puedes cambiar este valor."
L["Test"] = "Prueba"
L["Players Only"] = "Solo Jugadores"
L["Ignore NPCs when setting up icons."] = "Ignorar NPCs al configurar iconos."
L["No Cooldown Numbers"] = "Sin Números de Enfriamiento"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "Ve a 'Texto de Enfriamiento' > 'Global' para configurar."
L["Color Borders"] = "Bordes de Color"
L["Spacing"] = "Espaciado"
L["DR Strength Indicator: Text"] = "Indicador de Fuerza DR: Texto"
L["DR Strength Indicator: Box"] = "Indicador de Fuerza DR: Caja"
L["Good"] = "Bueno"
L["50% DR for hostiles, 100% DR for the player."] = "50% DR para hostiles, 100% DR para el jugador."
L["Neutral"] = "Neutral"
L["75% DR for all."] = "75% DR para todos."
L["Bad"] = "Malo"
L["100% DR for hostiles, 50% DR for the player."] = "100% DR para hostiles, 50% DR para el jugador."
L["Category Border"] = "Borde de Categoría"
L["Select Category"] = "Seleccionar Categoría"
L["Categories"] = "Categorías"
L["Add Category"] = "Añadir Categoría"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "Formato: 'categoría IDHechizo', ej. fear 10890.\nLa lista de todas las categorías está disponible en la sección 'colores'."
L["Remove Category"] = "Eliminar Categoría"
L["Category \"%s\" already exists, updating icon."] = "La categoría \"%s\" ya existe, actualizando icono."
L["Category \"%s\" added with %s icon."] = "Categoría \"%s\" añadida con icono %s."
L["Invalid category."] = "Categoría inválida."
L["Category \"%s\" removed."] = "Categoría \"%s\" eliminada."
L["DetachPower"] = "DesprenderPoder"
L["NameAutoShorten"] = "NombreAcortarAuto"
L["Color Filter"] = "Filtro de Color"
L["Enables color filter for the selected unit."] = "Activa el filtro de color para la unidad seleccionada."
L["Toggle for the currently selected statusbar."] = "Alternar para la barra de estado actualmente seleccionada."
L["Select Statusbar"] = "Seleccionar Barra de Estado"
L["Health"] = "Salud"
L["Castbar"] = "Barra de Lanzamiento"
L["Power"] = "Poder"
L["Tab Section"] = "Sección de Pestañas"
L["Toggle current tab."] = "Alternar pestaña actual."
L["Tab Priority"] = "Prioridad de Pestaña"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "Al cumplir múltiples condiciones, se aplicarán los colores de la pestaña con la prioridad más alta."
L["Copy Tab"] = "Copiar Pestaña"
L["Select a tab to copy its settings onto the current tab."] = "Selecciona una pestaña para copiar sus ajustes en la pestaña actual."
L["Flash"] = "Destello"
L["Toggle color flash for the current tab."] = "Alternar destello de color para la pestaña actual."
L["Speed"] = "Velocidad"
L["Glow"] = "Resplandor"
L["Determines which glow to apply when statusbars are not detached from frame."] = "Determina qué resplandor aplicar cuando las barras de estado no están separadas del marco."
L["Priority"] = "Prioridad"
L["When handling castbar, also manage its icon."] = "Al manejar la barra de lanzamiento, también gestionar su icono."
L["CastBar Icon Glow Color"] = "Color de Resplandor del Icono de Barra de Lanzamiento"
L["CastBar Icon Glow Size"] = "Tamaño de Resplandor del Icono de Barra de Lanzamiento"
L["Borders"] = "Bordes"
L["CastBar Icon Color"] = "Color del Icono de Barra de Lanzamiento"
L["Toggle classbar borders."] = "Alternar bordes de barra de clase."
L["Toggle infopanel borders."] = "Alternar bordes del panel de información."
L["ClassBar Color"] = "Color de Barra de Clase"
L["Disabled unless classbar is enabled."] = "Desactivado a menos que la barra de clase esté habilitada."
L["InfoPanel Color"] = "Color del Panel de Información"
L["Disabled unless infopanel is enabled."] = "Desactivado a menos que el panel de información esté habilitado."
L["ClassBar Adapt To"] = "Adaptar Barra de Clase A"
L["Copies color of the selected bar."] = "Copia el color de la barra seleccionada."
L["InfoPanel Adapt To"] = "Adaptar Panel de Información A"
L["Override Mode"] = "Modo de Anulación"
L["'None' - threat borders highlight will be prioritized over this one"..
    "\n'Threat' - this highlight will be prioritized."] =
		"'Ninguno' - el resaltado de bordes de amenaza tendrá prioridad sobre este"..
		"\n'Amenaza' - este resaltado tendrá prioridad."
L["Threat"] = "Amenaza"
L["Determines which borders to apply when statusbars are not detached from frame."] = "Determina qué bordes aplicar cuando las barras de estado no están separadas del marco."
L["Bar-specific"] = "Específico de la barra"
L["Lua Section"] = "Sección Lua"
L["Conditions"] = "Condiciones"
L["Font Settings"] = "Configuración de Fuente"
L["Player Only"] = "Solo jugador"
L["Handle only player combat log events."] = "Solo manejar eventos del registro de combate del jugador."
L["Rotate Icon"] = "Rotar icono"
L["Usage example:"..
	"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
	"\nlocal r, g, b = ElvUF_Target.Health:GetStatusBarColor() return true, {mR = r, mG = g, mB = b} end"..
	"\nif UnitIsUnit(@unit, 'target') then return true end"..
	"\n\n@@[raid, Health, 2, >5]@@ - returns true/false based on whether the tab in question (in the example above: 'player' - target unit; 'Power' - target statusbar; '3' - target tab) is active or not (mentioning the same unit/group is disabled; isn't recursive)"..
	"\n(>/>=/<=/</~= num) - (optional, group units only) match against a particular count of triggered frames within the group (more than 5 in the example above)"..
	"\n\n'return {bR=1,f=false}' - you can dynamically color the frames by returning the colors in a table format:"..
	"\n  to apply to the statusbar, assign your rgb values to mR, mG and mB respectively"..
	"\n  to apply the glow - to gR, gG, gB, gA (alpha)"..
	"\n  for borders - bR, bG, bB"..
	"\n  and for the flash - fR, fG, fB, fA"..
	"\n  to prevent the elements styling, return {m = false, g = false, b = false, f = false}"..
	"\n\nFeel free to use '@unit' to register current unit like this: UnitBuff(@unit, 'player')."..
	"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."] =
		"Ejemplo de uso:"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\nlocal r, g, b = ElvUF_Target.Health:GetStatusBarColor() return true, {mR = r, mG = g, mB = b} end"..
			"\nif UnitIsUnit(@unit, 'target') then return true end"..
			"\n\n@@[raid, Health, 2, >5]@@ - devuelve verdadero/falso basado en si la pestaña en cuestión (en el ejemplo anterior: 'player' - unidad objetivo; 'Power' - barra de estado objetivo; '3' - pestaña objetivo) está activa o no (mencionar la misma unidad/grupo está desactivado; no es recursivo)"..
			"\n(>/>=/<=/</~= num) - (opcional, solo unidades de grupo) comparar contra un conteo particular de marcos activados dentro del grupo (más de 5 en el ejemplo anterior)"..
			"\n\n'return {bR=1,f=false}' - puedes colorear dinámicamente los marcos devolviendo los colores en formato de tabla:"..
			"\n  para aplicar a la barra de estado, asigna tus valores rgb a mR, mG y mB respectivamente"..
			"\n  para aplicar el brillo - a gR, gG, gB, gA (alfa)"..
			"\n  para bordes - bR, bG, bB"..
			"\n  y para el destello - fR, fG, fB, fA"..
			"\n  para prevenir el estilo de los elementos, devuelve {m = false, g = false, b = false, f = false}"..
			"\n\nSiéntete libre de usar '@unit' para registrar la unidad actual así: UnitBuff(@unit, 'player')."..
			"\n\nEste módulo analiza cadenas, así que trata de que tu código siga estrictamente la sintaxis, o de lo contrario podría no funcionar."
L["Unless holding a modifier, hovering units, items, and spells draws no tooltip.\nModifies cursor tooltips only."] = "A menos que mantengas presionado un modificador, pasar el cursor sobre unidades, objetos y hechizos no mostrará ningún tooltip.\nSolo modifica los tooltips del cursor."
L["Pick a..."] = "Elige un..."
L["...mover to anchor to."] = "...elemento para anclar."
L["...mover to anchor."] = "...elemento para anclar."
L["Point:"] = "Punto:"
L["Relative:"] = "Relativo:"
L["Open Editor"] = "Abrir editor"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "A menos que se mantenga presionado un modificador, pasar el cursor sobre las unidades no mostrará ningún tooltip.\nSolo tooltips del cursor."
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "Ancla todos los marcos de chat antes de activar.\nShift-clic en el botón del administrador para acceder a la configuración de pestañas."
L["Mouseover"] = "Pasar el cursor"
L["Manager button visibility."] = "Visibilidad del botón del administrador."
L["Manager point."] = "Punto del administrador."
L["Top Offset"] = "Desplazamiento superior"
L["Bottom Offset"] = "Desplazamiento inferior"
L["Left Offset"] = "Desplazamiento izquierdo"
L["Right Offset"] = "Desplazamiento derecho"
L["Chat Search and Filter"] = "Búsqueda y filtro de chat"
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
		"Utilidad de búsqueda y filtrado para los marcos de chat."..
			"\n\nSintaxis:"..
			"\n  :: - declaración 'and'"..
			"\n  ( ; ) - declaración 'or'"..
			"\n  ! ! - declaración 'not'"..
			"\n  [ ] - sensible a mayúsculas y minúsculas"..
			"\n  @ @ - patrón lua"..
			"\n\nMensajes de ejemplo:"..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\nConsultas de búsqueda y resultados:"..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - vacío"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\nTab/Shift-Tab para navegar por los indicadores."..
			"\nClic derecho en el botón de búsqueda para acceder a consultas recientes."..
			"\nShift-Clic derecho para acceder a la configuración de búsqueda."..
			"\nAlt-Clic derecho para mensajes bloqueados."..
			"\nCtrl-Clic derecho para purgar la caché de mensajes filtrados."..
			"\n\nLos nombres de canales y las marcas de tiempo no se analizan."
L["Search button visibility."] = "Visibilidad del botón de búsqueda."
L["Search button point."] = "Punto del botón de búsqueda."
L["Config Tooltips"] = "Tooltips de configuración"
L["Highlight Color"] = "Color de resaltado"
L["Match highlight color."] = "Color de resaltado de coincidencia."
L["Filter Type"] = "Tipo de filtro"
L["Rule Terms"] = "Términos de regla"
L["Same logic as with the search."] = "La misma lógica que con la búsqueda."
L["Select Chat Types"] = "Seleccionar tipos de chat"
L["Say"] = "Decir"
L["Yell"] = "Gritar"
L["Party"] = "Grupo"
L["Raid"] = "Banda"
L["Guild"] = "Hermandad"
L["Battleground"] = "Campo de batalla"
L["Whisper"] = "Susurro"
L["Channel"] = "Canal"
L["Other"] = "Otro"
L["Select Rule"] = "Seleccionar regla"
L["Select Chat Frame"] = "Seleccionar marco de chat"
L["Add Rule"] = "Agregar regla"
L["Delete Rule"] = "Eliminar regla"
L["Compact Chat"] = "Chat compacto"
L["Move left"] = "Mover a la izquierda"
L["Move right"] = "Mover a la derecha"
L["Mouseover: Left"] = "Mouseover: Izquierda"
L["Mouseover: Right"] = "Mouseover: Derecha"
L["Automatic Onset"] = "Inicio automático"
L["Scans tooltip texts and sets icons automatically."] = "Escanea los textos de los tooltips y establece los íconos automáticamente."
L["Icon (Default)"] = "Ícono (Predeterminado)"
L["Icon (Kill)"] = "Ícono (Matar)"
L["Icon (Chat)"] = "Ícono (Chat)"
L["Icon (Item)"] = "Ícono (Objeto)"
L["Show Text"] = "Mostrar texto"
L["Display progress status."] = "Mostrar el estado de progreso."
L["Name"] = "Nombre"
L["Frequent Updates"] = "Actualizaciones Frecuentes"
L["Events (optional)"] = "Eventos (opcional)"
