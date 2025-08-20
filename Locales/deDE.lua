local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "deDE")

L["Hits the 'Confirm' button automatically."] = "Klickt automatisch auf die 'Bestätigen'-Schaltfläche."
L["Picks up items and money automatically."] = "Hebt automatisch Gegenstände und Geld auf."
L["Automatically fills the 'DELETE' field."] = "Füllt das 'LÖSCHEN'-Feld automatisch aus."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "Wählt die erste Gesprächsoption aus, wenn sie die einzige verfügbare ist, es sei denn, eine Modifier-Taste wird gedrückt.\nVorsicht bei wichtigen Ereignisauslösern, es gibt keinen Sicherheitsmechanismus."
L["Accepts and turns in quests automatically while holding a modifier."] = "Nimmt Quests an und gibt sie automatisch ab, während eine Modifier-Taste gedrückt wird."
L["Loot info wiped."] = "Beuteinformationen gelöscht."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "/lootinfo Befehl, um eine schnelle Übersicht über die kürzlichen Beutezüge zu erhalten.\n\nVerwendung: /lootinfo Apfel 60\n'Apfel' - Name des Items/Spielers \n(suche @self, um die Beute des Spielers zu erhalten)\n'60' - \nZeitlimit (<60 Sekunden), optional,\n/lootinfo !wipe - Beutekapazität leeren."
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "Färbt die Namen von Online-Freunden und Gildenmitgliedern in einigen Nachrichten und gestaltet die Würfe.\nBereits verarbeitete Chatblasen werden erst nach einem /reload neu gestaltet."
L["Colors loot roll messages for you and other players."] = "Färbt Beutewürfelnachrichten für Sie und andere Spieler."
L["Loot rolls icon size."] = "Größe der Beutewürfel-Symbole."
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "Gestaltet Beuteleisten neu.\nErfordert, dass 'Beutewurf' (Allgemein -> BlizzUI-Verbesserungen -> Beutewurf) aktiviert ist (das Umschalten dieses Moduls aktiviert es automatisch)."
L["Displays the name of the player pinging the minimap."] = "Zeigt den Namen des Spielers an, der die Minikarte anpingt."
L["Displays the currently held currency amount next to the item prices."] = "Zeigt den aktuell gehaltenen Währungsbetrag neben den Gegenstandspreisen an."
L["Narrows down the World(..Frame)."] = "Verkleinert das Welt(..Frame)."
L["'Out of mana', 'Ability is not ready yet', etc."] = "'Kein Mana', 'Fähigkeit ist noch nicht bereit', usw."
L["Re-enable quest updates."] = "Quest-Aktualisierungen wieder aktivieren."
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - Blizzards Gelb."
L["Text to display upon entering combat."] = "Text, der beim Betreten des Kampfes angezeigt wird."
L["Text to display upon leaving combat."] = "Text, der beim Verlassen des Kampfes angezeigt wird."
L["REQUIRES RELOAD."] = "ERFORDERT NEULADEN."
L["Icon to the left or right of the item link."] = "Symbol links oder rechts vom Gegenstandslink."
L["The size of the icon in the chat frame."] = "Die Größe des Symbols im Chat-Fenster."
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "Fügt allen Rahmen Schatten hinzu.\nFunktioniert nur, wenn Sie Ihre ElvUI/Core/Toolkit.lua mit der entsprechenden Datei aus dem Optionals-Ordner dieses Plugins ersetzen."
L["Combat state notification alerts."] = "Kampfalarmmeldungen."
L["Custom editbox position and size."] = "Benutzerdefinierte Position und Größe des Bearbeitungsfelds."
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
		"Verwendung:"..
			"\n/tnote list - gibt alle vorhandenen Notizen zurück"..
			"\n/tnote wipe - löscht alle vorhandenen Notizen"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - wie set (außer für den Lua-Teil)"..
			"\n/tnote 1 get - wie set, gibt vorhandene Notizen zurück"..
			"\n/tnote 1 set IhreNotizHier - fügt eine Notiz zum angegebenen Index aus der Liste hinzu "..
			"oder zum aktuell angezeigten Tooltip-Text, wenn das zweite Argument (in diesem Fall 1) weggelassen wird, "..
			"unterstützt Funktionen und Färbung "..
			"(ohne Text wird die Notiz gelöscht);"..
			"\num Zeilen zu umbrechen, verwenden Sie ::"..
			"\n\nBeispiel:"..
			"\n\n/tnote 3 set Feuer pre-bis::Quelle: Mutter Teresa"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(Standardfarbe)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "Fügt neben Chat-Hyperlinks ein Symbol hinzu."
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "Eine neue Aktionsleiste, die verwendbare Questgegenstände aus deiner Tasche sammelt.\n\nAufgrund der Begrenzung der Zustandsaktionen überschreibt dieses Modul die von ElvUI Extra Action Bars erstellte Leiste 10."
L["Toggles the display of the actionbar's backdrop."] = "Schaltet die Anzeige des Aktionsleisten-Hintergrunds um."
L["The frame will not be displayed unless hovered over."] = "Der Rahmen wird nur angezeigt, wenn du mit der Maus darüber fährst."
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "Übernimmt das globale Verblassen. Maus darüber bewegen, Ziel auswählen, Fokus setzen, Gesundheit verlieren, Kampf beginnen wird die Transparenz entfernen. Andernfalls wird der Transparenzwert in den allgemeinen Aktionsleisteneinstellungen für globales Verblassen verwendet."
L["The first button anchors itself to this point on the bar."] = "Der erste Button verankert sich an diesem Punkt auf der Leiste."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "Rechtsklicke auf den Gegenstand, während du den Modifikator hältst, um ihn auf die schwarze Liste zu setzen. Gegenstände auf der schwarzen Liste werden nicht auf der Leiste angezeigt.\nVerwende /questbarRestore, um die schwarze Liste zu löschen."
L["The number of buttons to display."] = "Die Anzahl der anzuzeigenden Buttons."
L["The number of buttons to display per row."] = "Die Anzahl der Buttons, die pro Reihe angezeigt werden sollen."
L["The size of the action buttons."] = "Die Größe der Aktionsbuttons."
L["Spacing between the buttons."] = "Der Abstand zwischen den Buttons."
L["Spacing between the backdrop and the buttons."] = "Der Abstand zwischen dem Hintergrund und den Buttons."
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "Multipliziere die Höhe oder Breite des Hintergrunds mit diesem Wert. Dies ist nützlich, wenn du mehr als eine Leiste hinter einem Hintergrund haben möchtest."
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "Dies funktioniert wie ein Makro. Du kannst verschiedene Situationen ausführen, um die Aktionsleiste unterschiedlich ein-/auszublenden.\n Beispiel: '[combat] showhide'"
L["Adds anchoring options to the movers' nudges."] = "Fügt Verankerungsoptionen zu den Verschiebungen der Mover hinzu."
L["Mod-clicking an item suggests a skill/item to process it."] = "Mod-Klick auf einen Gegenstand schlägt eine Fertigkeit/einen Gegenstand zur Verarbeitung vor."
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"Halten Sie %s gedrückt, während Sie mit der linken Maustaste auf einen Stapel klicken, um ihn in zwei Teile zu teilen; um verfügbare Kopien zu kombinieren, klicken Sie stattdessen mit der rechten Maustaste.\n\nModifiziert auch den SplitStackFrame, um ein Eingabefeld anstelle von Pfeilen zu verwenden."
L["Extends the bags functionality."] = "Erweitert die Funktionalität der Taschen."
L["Default method: type > inventory slot ID > item level > name."] = "Standardmethode: Typ > Inventarplatz-ID > Gegenstandsstufe > Name."
L["Listed ItemIDs will not get sorted."] = "Aufgelistete Gegenstands-IDs werden nicht sortiert."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Z.B. Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "Ungültiges Bedingungsformat: "
L["The generated custom sorting method did not return a function."] = "Generierte benutzerdefinierte Sortiermethode hat keine Funktion zurückgegeben."
L["The loaded custom sorting method did not return a function."] = "Geladene benutzerdefinierte Sortiermethode hat keine Funktion zurückgegeben."
L["Item received: "] = "Gegenstand erhalten: "
L[" added."] = " hinzugefügt."
L[" removed."] = " entfernt."
L["Handles the automated repositioning of the newly received items."..
	"\nSyntax: filter@value\n\n"..
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
		"Verarbeitet die automatische Neupositionierung von neu erhaltenen Gegenständen."..
		"\nSyntax: filter@wert\n\n"..
		"Verfügbare Filter:\n"..
		" id@zahl - entspricht der GegenstandsID,\n"..
		" name@string - entspricht dem Namen,\n"..
		" type@string - stimmt mit Typ überein,\n"..
		" subtype@string - entspricht dem Untertyp,\n"..
		" ilvl@zahl - entspricht dem Gegenstandslevel,\n"..
		" uselevel@zahl - entspricht dem Ausrüstungslevel,\n"..
		" quality@zahl - entspricht der Qualität,\n"..
		" equipslot@zahl - entspricht der InventarPlatzID,\n"..
		" maxstack@zahl - entspricht dem Stapellimit,\n"..
		" price@zahl - entspricht dem Verkaufspreis,\n"..
		" tooltip@string - entspricht dem Tooltip-Text,\n\n"..
		"Alle String-Übereinstimmungen sind nicht case-sensitive und entsprechen nur den alphanumerischen Symbolen. Standard-Lua-Logik wird angewendet. "..
		"Siehe GetItemInfo API für weitere Informationen zu Filtern. "..
		"Verwenden Sie GetAuctionItemClasses und GetAuctionItemSubClasses (wie im AH), um die lokalisierten Werte für Typen und Untertypen zu erhalten.\n\n"..
		"Beispiel (Priester T8 oder Schattengram):\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@derHeiligung) or name@schattengram.\n\n"..
		"Akzeptiert benutzerdefinierte Funktionen (bagID, slotID, itemID sind verfügbar)\n"..
		"Das folgende Beispiel benachrichtigt über neu erhaltene Gegenstände.\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\\124', '\\124\\124')\n"..
		"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
		"print('Gegenstand erhalten: ' .. string)"
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
		"Syntax: filter@wert\n\n"..
			"Verfügbare Filter:\n"..
			" id@nummer - stimmt mit ItemID überein,\n"..
			" name@text - stimmt mit Namen überein,\n"..
			" type@text - stimmt mit Typ überein,\n"..
			" subtype@text - stimmt mit Subtyp überein,\n"..
			" ilvl@nummer - stimmt mit Gegenstandsstufe überein,\n"..
			" uselevel@nummer - stimmt mit Ausrüstungsstufe überein,\n"..
			" quality@nummer - stimmt mit Qualität überein,\n"..
			" equipslot@nummer - stimmt mit InventarPlatzID überein,\n"..
			" maxstack@nummer - stimmt mit Stapellimit überein,\n"..
			" price@nummer - stimmt mit Verkaufspreis überein,\n"..
			" tooltip@text - stimmt mit Tooltip-Text überein.\n\n"..
			"Alle Textübereinstimmungen sind nicht von der Groß-/Kleinschreibung abhängig und stimmen nur mit alphanumerischen Symbolen überein.\n"..
			"Standard-Lua-Logik für Verzweigungen (und/oder/Klammern/usw.) wird angewendet.\n\n"..
			"Beispiel (Priester t8 oder Schattengram):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "Verfügbare Gegenstandstypen"
L["Lists all available item subtypes for each available item type."] =
	"Listet alle verfügbaren Gegenstandssubtypen für jeden verfügbaren Gegenstandstyp auf."
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"Hält man diese Taste beim Interagieren mit einem Händler gedrückt, werden alle Artikel gekauft, die die Auto-Kauf-Einstellungen erfüllen.\n"..
			"Mit einem Mod-Klick auf den Eintrag in der Kaufliste wird nur ein Artikel gekauft, unabhängig von der '@menge'-Regel."
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] =
		"Standardmethode: Typ > InventarplatzID > Gegenstandslevel > Name.\n\n"..
		"Akzeptiert benutzerdefinierte Funktionen (bagID und slotID sind verfügbar unter a/b.bagID/slotID).\n\n"..
		"function(a,b)\n"..
		"--Ihre Sortierlogik hier\n"..
		"end\n\n"..
		"Lassen Sie es leer, um die Standardeinstellung zu verwenden."
L["Event and OnUpdate handler."] = "Ereignis- und OnUpdate-Handler."
L["Minimal time gap between two consecutive executions."] = "Minimaler Zeitabstand zwischen zwei aufeinanderfolgenden Ausführungen."
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER usw.\nONUPDATE - 'OnUpdate'-Skript"
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = "UNIT_AURA CHAT_MSG_WHISPER usw."
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
		"Syntax:"..
		"\n\nEVENT[n~=nil]"..
		"\n[n~=Wert]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@Befehle@@@"..
		"\n\n'EVENT' - Ereignis aus dem obigen Ereignisabschnitt"..
		"\n'n, m, k' - Indizes der gewünschten Payload-Argumente (Zahl)"..
		"\n'nil/Wert/boolean/Lua-Code' - Gewünschte Ausgabe des n-Arguments"..
		"\n'@@' - Lua-Argument-Flag, muss vor dem Lua-Code im Wertebereich der Argumente stehen"..
		"\n'~' - Negierungsflag, vor dem Gleichheitszeichen hinzufügen, damit der Code ausgeführt wird, wenn n/m/k nicht mit dem gesetzten Wert übereinstimmt"..
		"\n'@@@ @@@' - Klammern, die die Befehle enthalten."..
		"\nSie können wie üblich auf die Payload (...) zugreifen."..
		"\n\nBeispiel:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(Spieler hat eine Aura gewonnen/verloren)@@@"..
		"\n\nCHAT_MSG_WHISPER"..
		"\n[5=@@UnitName('player')]"..
		"\n[14=false]@@@"..
		"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
		"\n\nCOMBAT_LOG_EVENT_"..
		"\nUNFILTERED"..
		"\n[5=@@UnitName('arena1')]"..
		"\n[5=@@UnitName('arena2')]@@@"..
		"\nfor i = 1, 2 do"..
		"\nif UnitDebuff('party'..i, 'Schlechter Zauber')"..
		"\nthen print(UnitName('party'..i)..' ist betroffen!')"..
		"\nend end@@@"..
		"\n\nDieses Modul analysiert Zeichenketten, also versuchen Sie, Ihren Code streng an die Syntax zu halten, sonst funktioniert er möglicherweise nicht."
L["Highlights auras."] = "Hebt Auren hervor."
L["E.g. 42292"] = "Z.B. 42292"
L["Applies highlights to all auras passing the selected filter."] = "Hervorhebungen für alle Auren, die den ausgewählten Filter passieren."
L["Priority: spell, filter, curable/stealable."] = "Priorität: Zauber, Filter, heilbar/stehlbar."
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "Wenn aktiviert, werden die globalen Zauber- oder Filterwerte verwendet."
L["Makes auras grow sideswise."] = "Lässt Auren seitlich wachsen."
L["Turns off texture fill."] = "Deaktiviert die Texturfüllung."
L["Makes auras flicker right before fading out."] = "Lässt Auren vor dem Verblassen flackern."
L["Disables border coloring."] = "Deaktiviert die Randfärbung."
L["Click Cancel"] = "Klicken Sie auf Abbrechen"
L["Right-click a player buff to cancel it."] = "Klicken Sie mit der rechten Maustaste auf einen Spielerbuff, um ihn zu beenden."
L["Disables debuffs desaturation."] = "Deaktiviert die Desättigung von Debuffs."
L["Saturated Debuffs"] = "Gesättigte Debuffs"
L["Confirm Rolls"] = "Würfe bestätigen"
L["Auto Pickup"] = "Automatisches Aufheben"
L["Swift Buy"] = "Schneller Kauf"
L["Buys out items automatically."] = "Kauft Artikel automatisch auf."
L["Failsafe"] = "Ausfallsicherung"
L["Enables popup confirmation dialog."] = "Aktiviert Popup-Bestätigungsdialog."
L["Add Set"] = "Set hinzufügen"
L["Delete Set"] = "Set löschen"
L["Select Set"] = "Set auswählen"
L["Auto Buy"] = "Automatischer Kauf"
L["Fill Delete"] = "Löschen ausfüllen"
L["Gossip"] = "Gespräch"
L["Accept Quest"] = "Quest annehmen"
L["Loot Info"] = "Beuteinfo"
L["Styled Messages"] = "Gestylte Nachrichten"
L["Indicator Color"] = "Indikatorfarbe"
L["Select Status"] = "Status auswählen"
L["Select Indicator"] = "Indikator auswählen"
L["Styled Loot Messages"] = "Gestylte Beutenachrichten"
L["Icon Size"] = "Symbolgröße"
L["Loot Bars"] = "Beutebalken"
L["Bar Height"] = "Balkenhöhe"
L["Bar Width"] = "Balkenbreite"
L["Player Pings"] = "Spieler-Pings"
L["Held Currency"] = "Gehaltene Währung"
L["LetterBox"] = "Letterbox"
L["Left"] = "Links"
L["Right"] = "Rechts"
L["Top"] = "Oben"
L["Bottom"] = "Unten"
L["Hide Errors"] = "Fehler ausblenden"
L["Show quest updates"] = "Questaktualisierungen anzeigen"
L["Less Tooltips"] = "Weniger Tooltips"
L["Misc."] = "Sonstiges"
L["Loot&Style"] = "Beute&Stil"
L["Automation"] = "Automatisierung"
L["Bags"] = "Taschen"
L["Easier Processing"] = "Einfachere Verarbeitung"
L["Modifier"] = "Modifikator"
L["Split Stack"] = "Stapel teilen"
L["Bags Extended"] = "Taschen erweitert"
L["Select Container Type"] = "Behältertyp auswählen"
L["Settings"] = "Einstellungen"
L["Add Section"] = "Abschnitt hinzufügen"
L["Delete Section"] = "Abschnitt löschen"
L["Select Section"] = "Abschnitt auswählen"
L["Section Priority"] = "Abschnittspriorität"
L["Section Spacing"] = "Abschnittsabstand"
L["Collection Method"] = "Sammelmethode"
L["Sorting Method"] = "Sortiermethode"
L["Ignore Item (by ID)"] = "Item ignorieren (nach ID)"
L["Remove Ignored"] = "Ignorierte entfernen"
L["Title"] = "Titel"
L["Color"] = "Farbe"
L["Attach to Icon"] = "An Symbol anheften"
L["Text"] = "Text"
L["Font Size"] = "Schriftgröße"
L["Font"] = "Schriftart"
L["Font Flags"] = "Schriftart-Flags"
L["Point"] = "Punkt"
L["Relative Point"] = "Relativer Punkt"
L["Icon"] = "Symbol"
L["Attach to Text"] = "An Text anheften"
L["Texture"] = "Textur"
L["Size"] = "Größe"
L["MoversPlus"] = "BewegerPlus"
L["Movers Plus"] = "Beweger Plus"
L["CustomCommands"] = "Benutzerdefinierte Befehle"
L["Custom Commands"] = "Benutzerdefinierte Befehle"
L["QuestBar"] = "Questleiste"
L["Quest Bar"] = "Questleiste"
L["Settings"] = "Einstellungen"
L["Backdrop"] = "Hintergrund"
L["Show Empty Buttons"] = "Leere Schaltflächen anzeigen"
L["Mouse Over"] = "Mauszeiger darüber"
L["Inherit Global Fade"] = "Globales Ausblenden übernehmen"
L["Anchor Point"] = "Ankerpunkt"
L["Modifier"] = "Modifikator"
L["Buttons"] = "Schaltflächen"
L["Buttons Per Row"] = "Schaltflächen pro Reihe"
L["Button Size"] = "Schaltflächengröße"
L["Button Spacing"] = "Schaltflächenabstand"
L["Backdrop Spacing"] = "Hintergrundabstand"
L["Height Multiplier"] = "Höhenmultiplikator"
L["Width Multiplier"] = "Breitenmultiplikator"
L["Alpha"] = "Alpha"
L["Visibility State"] = "Sichtbarkeitszustand"
L["Enable Tab"] = "Tab aktivieren"
L["Throttle Time"] = "Drosselzeit"
L["Select Tab"] = "Tab auswählen"
L["Select Event"] = "Ereignis auswählen"
L["Rename Tab"] = "Tab umbenennen"
L["Add Tab"] = "Tab hinzufügen"
L["Delete Tab"] = "Tab löschen"
L["Open Edit Frame"] = "Bearbeitungsrahmen öffnen"
L["Events"] = "Ereignisse"
L["Commands to execute"] = "Auszuführende Befehle"
L["Sub-Section"] = "Unterabschnitt"
L["Select"] = "Auswählen"
L["Icon Orientation"] = "Symbolausrichtung"
L["Icon Size"] = "Symbolgröße"
L["Height Offset"] = "Höhenversatz"
L["Width Offset"] = "Breitenversatz"
L["Text Color"] = "Textfarbe"
L["Entering combat"] = "Kampf betreten"
L["Leaving combat"] = "Kampf verlassen"
L["Font"] = "Schriftart"
L["Font Outline"] = "Schriftkontur"
L["Font Size"] = "Schriftgröße"
L["Texture Width"] = "Texturbreite"
L["Texture Height"] = "Texturhöhe"
L["Custom Texture"] = "Benutzerdefinierte Textur"
L["ItemIcons"] = "Gegenstandssymbole"
L["TooltipNotes"] = "Tooltip-Notizen"
L["ChatEditBox"] = "Chat-Bearbeitungsfeld"
L["EnterCombatAlert"] = "Kampfalarm betreten"
L["GlobalShadow"] = "Globaler Schatten"
L["Any"] = "Beliebig"
L["Guildmate"] = "Gildenmitglied"
L["Friend"] = "Freund"
L["Self"] = "Selbst"
L["New Tab"] = "Neuer Tab"
L["None"] = "Keine"
L["Version: "] = "Version: "
L["Color A"] = "Farbe A"
L["Chat messages, etc."] = "Chatnachrichten usw."
L["Color B"] = "Farbe B"
L["Plugin Color"] = "Plugin-Farbe"
L["Icons Browser"] = "Icons-Browser"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "Laden Sie https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html für sauberere, zugeschnittene Symbole herunter."
L["Add Texture"] = "Textur hinzufügen"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Fügt Texturen zur allgemeinen Texturliste hinzu.\nZ.B. Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "Textur entfernen"
L["Highlights"] = "Hervorhebungen"
L["Select Type"] = "Typ auswählen"
L["Highlights Settings"] = "Einstellungen für Hervorhebungen"
L["Add Filter"] = "Filter hinzufügen"
L["Remove Selected"] = "Ausgewählte entfernen"
L["Select Spell or Filter"] = "Zauber oder Filter auswählen"
L["Use Global Settings"] = "Globale Einstellungen verwenden"
L["Selected Spell or Filter Values"] = "Werte des ausgewählten Zaubers oder Filters"
L["Enable Shadow"] = "Schatten aktivieren"
L["Size"] = "Größe"
L["Shadow Color"] = "Schattenfarbe"
L["Enable Border"] = "Rand aktivieren"
L["Border Color"] = "Randfarbe"
L["Centered Auras"] = "Zentrierte Auren"
L["Cooldown Disable"] = "Abklingzeit deaktivieren"
L["Animate Fade-Out"] = "Verblassen animieren"
L["Type Borders"] = "Typ-Ränder"
L[" filter added."] = " Filter hinzugefügt."
L[" filter removed."] = " Filter entfernt."
L["GLOBAL"] = "GLOBAL"
L["CURABLE"] = "Heilbar"
L["STEALABLE"] = "Stohlbar"
L["--Filters--"] = "--Filter--"
L["--Spells--"] = "--Zauber--"
L["FRIENDLY"] = "Freundlich"
L["ENEMY"] = "Feindlich"
L["AuraBars"] = "Aura-Balken"
L["Auras"] = "Auren"
L["ClassificationIndicator"] = "Klassifizierungsindikator"
L["ClassificationIcons"] = "Klassifikationssymbole"
L["ColorFilter"] = "Farbfilter"
L["Cooldowns"] = "Abklingzeiten"
L["DRTracker"] = "DR-Tracker"
L["Guilds&Titles"] = "Gilden und Titel"
L["Name&Level"] = "Name und Stufe"
L["QuestIcons"] = "Quest-Symbole"
L["StyleFilter"] = "Stilfilter"
L["Search:"] = "Suche:"
L["Click to select."] = "Klicken Sie zur Auswahl."
L["Hover again to see the changes."] = "Bewegen Sie den Mauszeiger erneut darüber, um die Änderungen zu sehen."
L["Note set for "] = "Notiz gesetzt für "
L["Note cleared for "] = "Notiz gelöscht für "
L["No note to clear for "] = "Keine Notiz zum Löschen für "
L["Added icon to the note for "] = "Symbol zur Notiz hinzugefügt für "
L["Note icon cleared for "] = "Notizsymbol gelöscht für "
L["No note icon to clear for "] = "Kein Notizsymbol zum Löschen für "
L["Current note for "] = "Aktuelle Notiz für "
L["No note found for this tooltip."] = "Keine Notiz für diesen Tooltip gefunden."
L["Notes: "] = "Notizen: "
L["No notes are set."] = "Keine Notizen gesetzt."
L["No tooltip is currently shown or unsupported tooltip type."] = "Kein Tooltip wird derzeit angezeigt oder nicht unterstützter Tooltip-Typ."
L["All notes have been cleared."] = "Alle Notizen wurden gelöscht."
L["Accept"] = "Akzeptieren"
L["Cancel"] = "Abbrechen"
L["Purge Cache"] = "Cache leeren"
L["Guilds"] = "Gilden"
L["Separator"] = "Trennzeichen"
L["X Offset"] = "X-Versatz"
L["Y Offset"] = "Y-Versatz"
L["Level"] = "Ebene"
L["Visibility State"] = "Sichtbarkeitszustand"
L["City (Resting)"] = "Stadt (Ausruhen)"
L["PvP"] = "PvP"
L["Arena"] = "Arena"
L["Party"] = "Gruppe"
L["Raid"] = "Schlachtzug"
L["Colors"] = "Farben"
L["Guild"] = "Gilde"
L["All"] = "Alle"
L["Occupation Icon"] = "Berufssymbol"
L["OccupationIcon"] = "Berufssymbol"
L["Size"] = "Größe"
L["Anchor"] = "Anker"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "Beruf entfernen"
L["Modifier"] = "Modifikator"
L["Add Texture Path"] = "Texturpfad hinzufügen"
L["Remove Selected Texture"] = "Ausgewählte Textur entfernen"
L["Titles"] = "Titel"
L["Reaction Color"] = "Reaktionsfarbe"
L["Color based on reaction type."] = "Farbe basierend auf Reaktionstyp."
L["Nameplates"] = "Namensplaketten"
L["Unitframes"] = "Einheitenrahmen"
L["An icon similar to the minimap search."] = "Ein Symbol ähnlich der Minikartensuche."
L["Displays player guild text."] = "Zeigt den Gildentext des Spielers an."
L["Displays NPC occupation text."] = "Zeigt den Berufstext des NPC an."
L["Strata"] = "Schicht"
L["Selected Type"] = "Ausgewählter Typ"
L["Reaction based coloring for non-cached characters."] = "Reaktionsbasierte Färbung für nicht zwischengespeicherte Charaktere."
L["Apply Custom Color"] = "Benutzerdefinierte Farbe anwenden"
L["Class Color"] = "Klassenfarbe"
L["Use class colors."] = "Klassenfarben verwenden."
L["Use Backdrop"] = "Hintergrund verwenden"
L["Linked Style Filter Triggers"] = "Verknüpfte Stilfilterauslöser"
L["Select Link"] = "Verknüpfung auswählen"
L["New Link"] = "Neue Verknüpfung"
L["Delete Link"] = "Verknüpfung löschen"
L["Target Filter"] = "Ziel-Filter"
L["Select a filter to trigger the styling."] = "Wählen Sie einen Filter aus, um das Styling auszulösen."
L["Apply Filter"] = "Filter anwenden"
L["Select a filter to style the frames not passing the target filter triggers."] = "Wählen Sie einen Filter aus, um die Frames zu stylen, die die Ziel-Filter-Auslöser nicht bestehen."
L["Cache purged."] = "Cache geleert."
L["Test Mode"] = "Testmodus"
L["Draws player cooldowns."] = "Zeigt Spieler-Abklingzeiten an."
L["Show Everywhere"] = "Überall anzeigen"
L["Show in Cities"] = "In Städten anzeigen"
L["Show in Battlegrounds"] = "Auf Schlachtfeldern anzeigen"
L["Show in Arenas"] = "In Arenen anzeigen"
L["Show in Instances"] = "In Instanzen anzeigen"
L["Show in the World"] = "In der Welt anzeigen"
L["Header"] = "Kopfzeile"
L["Icons"] = "Symbole"
L["OnUpdate Throttle"] = "Aktualisierungsbegrenzung"
L["Trinket First"] = "Schmuckstück zuerst"
L["Animate Fade Out"] = "Ausblenden animieren"
L["Border Color"] = "Rahmenfarbe"
L["Growth Direction"] = "Wachstumsrichtung"
L["Sort Method"] = "Sortiermethode"
L["Icon Size"] = "Symbolgröße"
L["Icon Spacing"] = "Symbolabstand"
L["Per Row"] = "Pro Reihe"
L["Max Rows"] = "Maximale Reihen"
L["CD Text"] = "Abklingzeit-Text"
L["Show"] = "Anzeigen"
L["Cooldown Fill"] = "Abklingzeit-Füllung"
L["Reverse"] = "Umkehren"
L["Direction"] = "Richtung"
L["Spells"] = "Zauber"
L["Add Spell (by ID)"] = "Zauber hinzufügen (nach ID)"
L["Remove Selected Spell"] = "Ausgewählten Zauber entfernen"
L["Select Spell"] = "Zauber auswählen"
L["Shadow"] = "Schatten"
L["Pet Ability"] = "Begleiterfähigkeit"
L["Shadow Size"] = "Schattengröße"
L["Shadow Color"] = "Schattenfarbe"
L["Sets update speed threshold."] = "Legt den Schwellenwert für die Aktualisierungsgeschwindigkeit fest."
L["Makes PvP trinkets and human racial always get positioned first."] = "Positioniert PvP-Schmuckstücke und menschliche Volksfähigkeit immer zuerst."
L["Makes icons flash when the cooldown's about to end."] = "Lässt Symbole blinken, wenn die Abklingzeit fast abgelaufen ist."
L["Any value apart from black (0,0,0) would override borders by time left."] = "Jeder Wert außer Schwarz (0,0,0) überschreibt die Rahmen nach verbleibender Zeit."
L["Colors borders by time left."] = "Färbt Rahmen nach verbleibender Zeit."
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "Format: 'ZauberID Abklingzeit', z.B. 42292 120"
L["For the important stuff."] = "Für die wichtigen Dinge."
L["Pet casts require some special treatment."] = "Begleiterzauber benötigen eine besondere Behandlung."
L["Color by Type"] = "Nach Typ färben"
L["Flip Icon"] = "Symbol spiegeln"
L["Texture List"] = "Texturliste"
L["Keep Icon"] = "Symbol beibehalten"
L["Texture"] = "Textur"
L["Texture Coordinates"] = "Texturkoordinaten"
L["Select Affiliation"] = "Zugehörigkeit auswählen"
L["Width"] = "Breite"
L["Height"] = "Höhe"
L["Select Class"] = "Klasse auswählen"
L["Points"] = "Punkte"
L["Colors the icon based on the unit type."] = "Färbt das Symbol basierend auf dem Einheitentyp."
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "Spiegelt das Symbol horizontal. Nicht kompatibel mit Texturkoordinaten."
L["Keep the original icon texture."] = "Behält die ursprüngliche Symboltextur bei."
L["NPCs"] = "NSCs"
L["Players"] = "Spieler"
L["By duration, ascending."] = "Nach Dauer, aufsteigend."
L["By duration, descending."] = "Nach Dauer, absteigend."
L["By time used, ascending."] = "Nach verwendeter Zeit, aufsteigend."
L["By time used, descending."] = "Nach verwendeter Zeit, absteigend."
L["Additional settings for the Elite Icon."] = "Zusätzliche Einstellungen für das Elite-Symbol."
L["Player class icons."] = "Spielerklassen-Symbole."
L["Class Icons"] = "Klassensymbole"
L["Vector Class Icons"] = "Vektor-Klassensymbole"
L["Class Crests"] = "Klassenwappen"
L["Floating Combat Feedback"] = "Schwebende Kampfrückmeldung"
L["Select Unit"] = "Einheit auswählen"
L["player"] = "Spieler (player)"
L["target"] = "Ziel (target)"
L["targettarget"] = "Ziel des Ziels (targettarget)"
L["targettargettarget"] = "Ziel des Ziels des Ziels (targettargettarget)"
L["focus"] = "Fokus (focus)"
L["focustarget"] = "Fokusziel (focustarget)"
L["pet"] = "Begleiter (pet)"
L["pettarget"] = "Begleiterziel (pettarget)"
L["raid"] = "Schlachtzug (raid)"
L["raid40"] = "40er Schlachtzug (raid40)"
L["raidpet"] = "Schlachtzugbegleiter (raidpet)"
L["party"] = "Gruppe (party)"
L["partypet"] = "Gruppenbegleiter (partypet)"
L["partytarget"] = "Gruppenziel (partytarget)"
L["boss"] = "Boss (boss)"
L["arena"] = "Arena (arena)"
L["assist"] = "Assistent (assist)"
L["assisttarget"] = "Assistentenziel (assisttarget)"
L["tank"] = "Tank (tank)"
L["tanktarget"] = "Tankziel (tanktarget)"
L["Scroll Time"] = "Scrollzeit"
L["Event Settings"] = "Ereigniseinstellungen"
L["Event"] = "Ereignis"
L["Disable Event"] = "Ereignis deaktivieren"
L["School"] = "Schule"
L["Use School Colors"] = "Schulfarben verwenden"
L["Colors"] = "Farben"
L["Color (School)"] = "Farbe (Schule)"
L["Animation Type"] = "Animationstyp"
L["Custom Animation"] = "Benutzerdefinierte Animation"
L["Flag Settings"] = "Flaggeneinstellungen"
L["Flag"] = "Flagge"
L["Font Size Multiplier"] = "Schriftgrößenmultiplikator"
L["Animation by Flag"] = "Animation nach Flagge"
L["Icon Settings"] = "Symboleinstellungen"
L["Show Icon"] = "Symbol anzeigen"
L["Icon Position"] = "Symbolposition"
L["Bounce"] = "Springen"
L["Blacklist"] = "Schwarze Liste"
L["Appends floating combat feedback fontstrings to frames."] = "Fügt schwebende Kampfrückmeldungs-Schriftzüge zu Frames hinzu."
L["There seems to be a font size limit?"] = "Es scheint ein Schriftgrößenlimit zu geben?"
L["Not every event is eligible for this. But some are."] = "Nicht jedes Ereignis ist dafür geeignet. Aber einige sind es."
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "Definieren Sie Ihre benutzerdefinierte Animation als Lua-Funktion.\n\nBeispiel:\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "Umschalten, damit dieser Abschnitt stattdessen Flaggenanimationen behandelt.\n\nNicht jedes Ereignis hat Flaggen."
L["Flip position left-right."] = "Position links-rechts spiegeln."
L["E.g. 42292"] = "Z.B. 42292"
L["Loaded custom animation did not return a function."] = "Geladene benutzerdefinierte Animation hat keine Funktion zurückgegeben."
L["Before Text"] = "Vorheriger Text"
L["After Text"] = "Nachfolgender Text"
L["Remove Spell"] = "Zauber entfernen"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"Definiere deine benutzerdefinierte Animation als Lua-Funktion.\n\nBeispiel:\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "ABSORBIEREN"
L["BLOCK"] = "BLOCKEN"
L["CRITICAL"] = "KRITISCH"
L["CRUSHING"] = "ZERSCHMETTERND"
L["GLANCING"] = "STREIFEND"
L["RESIST"] = "WIDERSTEHEN"
L["Diagonal"] = "Diagonal"
L["Fountain"] = "Brunnen"
L["Horizontal"] = "Horizontal"
L["Random"] = "Zufällig"
L["Static"] = "Statisch"
L["Vertical"] = "Vertikal"
L["DEFLECT"] = "ABLENKEN"
L["DODGE"] = "AUSWEICHEN"
L["ENERGIZE"] = "ENERGETISIEREN"
L["EVADE"] = "ENTKOMMEN"
L["HEAL"] = "HEILEN"
L["IMMUNE"] = "IMMUN"
L["INTERRUPT"] = "UNTERBRECHEN"
L["MISS"] = "VERFEHLEN"
L["PARRY"] = "PARIEREN"
L["REFLECT"] = "REFLEKTIEREN"
L["WOUND"] = "VERWUNDEN"
L["Debuff applied/faded/refreshed"] = "Debuff angewendet/verblasst/erneuert"
L["Buff applied/faded/refreshed"] = "Buff angewendet/verblasst/erneuert"
L["Physical"] = "Physisch"
L["Holy"] = "Heilig"
L["Fire"] = "Feuer"
L["Nature"] = "Natur"
L["Frost"] = "Frost"
L["Shadow"] = "Schatten"
L["Arcane"] = "Arkan"
L["Astral"] = "Astral"
L["Chaos"] = "Chaos"
L["Elemental"] = "Elementar"
L["Magic"] = "Magie"
L["Plague"] = "Seuche"
L["Radiant"] = "Strahlend"
L["Shadowflame"] = "Schattenflamme"
L["Shadowfrost"] = "Schattenfrost"
L["Up"] = "Oben"
L["Down"] = "Unten"
L["Classic Style"] = "Klassischer Stil"
L["If enabled, default cooldown style will be used."] = "Wenn aktiviert, wird der Standard-Cooldown-Stil verwendet."
L["Classification Indicator"] = "Klassifizierungsindikator"
L["Copy Unit Settings"] = "Einheiteneinstellungen kopieren"
L["Enable Player Class Icons"] = "Spielerklassen-Symbole aktivieren"
L["Enable NPC Classification Icons"] = "NPC-Klassifizierungssymbole aktivieren"
L["Type"] = "Typ"
L["Select unit type."] = "Einheitentyp auswählen."
L["World Boss"] = "Weltboss"
L["Elite"] = "Elite"
L["Rare"] = "Selten"
L["Rare Elite"] = "Seltene Elite"
L["Class Spec Icons"] = "Klassenspezialisierungssymbole"
L["Classification Textures"] = "Klassifizierungstexturen"
L["Use Nameplates' Icons"] = "Namensplaketten-Symbole verwenden"
L["Color enemy NPC icon based on the unit type."] = "Gegnerisches NPC-Symbol basierend auf dem Einheitentyp einfärben."
L["Strata and Level"] = "Ebene und Stufe"
L["Warrior"] = "Krieger"
L["Warlock"] = "Hexenmeister"
L["Priest"] = "Priester"
L["Paladin"] = "Paladin"
L["Druid"] = "Druide"
L["Rogue"] = "Schurke"
L["Mage"] = "Magier"
L["Hunter"] = "Jäger"
L["Shaman"] = "Schamane"
L["Deathknight"] = "Todesritter"
L["Aura Bars"] = "Aura-Leisten"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "Fügt zusätzliche Konfigurationsoptionen für Aura-Leisten hinzu.\n\n Für Optionen wie Größe und Trennung verwenden Sie die ElvUI Aura-Leisten-Beweger!"
L["Hide"] = "Verstecken"
L["Spell Name"] = "Zaubername"
L["Spell Time"] = "Zauberzeit"
L["Bounce Icon Points"] = "Symbol-Punkte springen lassen"
L["Set icon to the opposite side of the bar each new bar."] = "Symbol bei jeder neuen Leiste auf die gegenüberliegende Seite setzen."
L["Flip Starting Position"] = "Startposition umkehren"
L["0 to disable."] = "0 zum Deaktivieren."
L["Detach All"] = "Alle lösen"
L["Detach Power"] = "Energie lösen"
L["Detaches power for the currently selected group."] = "Löst die Energie für die aktuell ausgewählte Gruppe."
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "Kürzt Namen ähnlich wie auf Namensplaketten. Setze 'Textposition' in der Namenskonfiguration auf LINKS."
L["Anchor to Health"] = "An Gesundheit verankern"
L["Adjusts the shortening based on the 'Health' text position."] = "Passt die Kürzung basierend auf der Position des 'Gesundheit'-Textes an."
L["Name Auto-Shorten"] = "Name automatisch kürzen"
L["Appends a diminishing returns tracker to frames."] = "Fügt den Frames einen Tracker für abnehmende Wirkungsgrade hinzu."
L["DR Time"] = "DR-Zeit"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "DR-Zeit steuert, wie lange es dauert, bis sich die Symbole zurücksetzen. Mehrere Faktoren können beeinflussen, wie DR sich zurücksetzt. Wenn Sie ständig Probleme mit der Genauigkeit der DR-Rücksetzung haben, können Sie diesen Wert ändern."
L["Test"] = "Test"
L["Players Only"] = "Nur Spieler"
L["Ignore NPCs when setting up icons."] = "Ignoriere NPCs beim Einrichten von Symbolen."
L["Setup Categories"] = "Kategorien einrichten"
L["Disable Cooldown"] = "Abklingzeit deaktivieren"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "Gehe zu 'Abklingzeittext' > 'Global' zum Konfigurieren."
L["Color Borders"] = "Farbige Ränder"
L["Spacing"] = "Abstand"
L["DR Strength Indicator: Text"] = "DR-Stärkeindikator: Text"
L["DR Strength Indicator: Box"] = "DR-Stärkeindikator: Box"
L["Good"] = "Gut"
L["50% DR for hostiles, 100% DR for the player."] = "50% DR für Feinde, 100% DR für den Spieler."
L["Neutral"] = "Neutral"
L["75% DR for all."] = "75% DR für alle."
L["Bad"] = "Schlecht"
L["100% DR for hostiles, 50% DR for the player."] = "100% DR für Feinde, 50% DR für den Spieler."
L["Category Border"] = "Kategorierand"
L["Select Category"] = "Kategorie auswählen"
L["Categories"] = "Kategorien"
L["Add Category"] = "Kategorie hinzufügen"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "Format: 'Kategorie ZauberID', z.B. fear 10890.\nEine Liste aller Kategorien ist im Abschnitt 'Farben' verfügbar."
L["Remove Category"] = "Kategorie entfernen"
L["Category \"%s\" already exists, updating icon."] = "Kategorie \"%s\" existiert bereits, Symbol wird aktualisiert."
L["Category \"%s\" added with %s icon."] = "Kategorie \"%s\" mit Symbol %s hinzugefügt."
L["Invalid category."] = "Ungültige Kategorie."
L["Category \"%s\" removed."] = "Kategorie \"%s\" entfernt."
L["DetachPower"] = "EnergieLösen"
L["NameAutoShorten"] = "NameAutomatischKürzen"
L["Color Filter"] = "Farbfilter"
L["Enables color filter for the selected unit."] = "Aktiviert den Farbfilter für die ausgewählte Einheit."
L["Toggle for the currently selected statusbar."] = "Umschalten für die aktuell ausgewählte Statusleiste."
L["Select Statusbar"] = "Statusleiste auswählen"
L["Health"] = "Gesundheit"
L["Castbar"] = "Zauberleiste"
L["Power"] = "Energie"
L["Tab Section"] = "Tab-Bereich"
L["Toggle current tab."] = "Aktuellen Tab umschalten."
L["Tab Priority"] = "Tab-Priorität"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "Wenn mehrere Bedingungen erfüllt sind, werden Farben vom Tab mit der höchsten Priorität angewendet."
L["Copy Tab"] = "Tab kopieren"
L["Select a tab to copy its settings onto the current tab."] = "Wählen Sie einen Tab aus, um dessen Einstellungen auf den aktuellen Tab zu kopieren."
L["Flash"] = "Blinken"
L["Speed"] = "Geschwindigkeit"
L["Glow"] = "Leuchten"
L["Determines which glow to apply when statusbars are not detached from frame."] = "Bestimmt, welches Leuchten angewendet wird, wenn Statusleisten nicht vom Rahmen getrennt sind."
L["Priority"] = "Priorität"
L["When handling castbar, also manage its icon."] = "Bei der Behandlung der Zauberleiste auch das zugehörige Symbol verwalten."
L["CastBar Icon Glow Color"] = "Zauberleisten-Symbol Leuchtfarbe"
L["CastBar Icon Glow Size"] = "Zauberleisten-Symbol Leuchtgröße"
L["Borders"] = "Ränder"
L["CastBar Icon Color"] = "Zauberleisten-Symbol Farbe"
L["Toggle classbar borders."] = "Klassenleisten-Ränder umschalten."
L["Toggle infopanel borders."] = "Infopanel-Ränder umschalten."
L["ClassBar Color"] = "Klassenleisten-Farbe"
L["Disabled unless classbar is enabled."] = "Deaktiviert, es sei denn, die Klassenleiste ist aktiviert."
L["InfoPanel Color"] = "Infopanel-Farbe"
L["Disabled unless infopanel is enabled."] = "Deaktiviert, es sei denn, das Infopanel ist aktiviert."
L["ClassBar Adapt To"] = "Klassenleiste anpassen an"
L["Copies the color of the selected bar."] = "Kopiert die Farbe der ausgewählten Leiste."
L["InfoPanel Adapt To"] = "Infopanel anpassen an"
L["Override Mode"] = "Überschreibungsmodus"
L["'None' - threat borders highlight will be prioritized over this one"..
    "\n'Threat' - this highlight will be prioritized."] =
		"'Keine' - Bedrohungsränder-Hervorhebung wird priorisiert"..
		"\n'Bedrohung' - diese Hervorhebung wird priorisiert."
L["Threat"] = "Bedrohung"
L["Determines which borders to apply when statusbars are not detached from frame."] = "Bestimmt, welche Ränder angewendet werden, wenn Statusleisten nicht vom Rahmen getrennt sind."
L["Bar-specific"] = "Leistenspezifisch"
L["Lua Section"] = "Lua-Bereich"
L["Conditions"] = "Bedingungen"
L["Font Settings"] = "Schriftarteinstellungen"
L["Player Only"] = "Nur Spieler"
L["Handle only player combat log events."] = "Nur Kampfprotokoll-Ereignisse des Spielers verarbeiten."
L["Rotate Icon"] = "Symbol drehen"
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
		"Verwendungsbeispiel:"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
			"\n    return true, {mR = r, mG = g, mB = b}"..
			"\nelseif UnitIsUnit(unit, 'target') then"..
			"\n    return true"..
			"\nend"..
			"\n\n@@[raid, Health, 2, >5]@@ - gibt true/false zurück, basierend darauf, ob der betreffende Tab "..
			"(im obigen Beispiel: 'player' - Zieleinheit; 'Power' - Ziel-Statusleiste; '3' - Ziel-Tab) aktiv ist oder nicht"..
			"\n(>/>=/<=/</~= num) - (optional, nur für Gruppeneinheiten) "..
			"Vergleich mit einer bestimmten Anzahl von ausgelösten Frames innerhalb der Gruppe (mehr als 5 im obigen Beispiel)"..
			"\n\n'return true, {bR=1,f=false}' - Sie können die Frames dynamisch einfärben, indem Sie die Farben in einem Tabellenformat zurückgeben:"..
			"\n  Um auf die Statusleiste anzuwenden, weisen Sie Ihre RGB-Werte jeweils mR, mG und mB zu"..
			"\n  Um das Leuchten anzuwenden - gR, gG, gB, gA (Alpha)"..
			"\n  Für Ränder - bR, bG, bB"..
			"\n  Und für den Blitz - fR, fG, fB, fA"..
			"\n  Um die Stilisierung der Elemente zu verhindern, geben Sie {m = false, g = false, b = false, f = false} zurück"..
			"\n\nFrame und unitID sind unter 'frame' und 'unit' verfügbar: UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
			"\n\nDieses Modul analysiert Zeichenketten, also versuchen Sie, Ihren Code streng nach der Syntax zu gestalten, sonst funktioniert er möglicherweise nicht."
L["Pick a..."] = "Wähle ein..."
L["...mover to anchor to."] = "...Element zum Verankern auswählen."
L["...mover to anchor."] = "...Element zum Verankern."
L["Point:"] = "Point :"
L["Relative:"] = "Relatif :"
L["Open Editor"] = "Editor öffnen"
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "Sofern keine Modifikatortaste gedrückt wird, werden beim Überfahren von Einheiten, Gegenständen und Zaubern keine Tooltips angezeigt.\nÄndert nur Cursor-Tooltips."
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "Alle Chatfenster andocken, bevor Sie aktivieren.\nShift-Klick auf den Manager-Button, um auf die Tab-Einstellungen zuzugreifen."
L["Mouseover"] = "Mouseover"
L["Manager button visibility."] = "Sichtbarkeit des Manager-Buttons."
L["Manager point."] = "Manager-Punkt."
L["Top Offset"] = "Oberer Versatz"
L["Bottom Offset"] = "Unterer Versatz"
L["Left Offset"] = "Linker Versatz"
L["Right Offset"] = "Rechter Versatz"
L["Chat Search and Filter"] = "Chat-Suche und -Filter"
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
		"Such- und Filterfunktion für die Chatfenster."..
			"\n\nSynax:"..
			"\n  :: - 'und' Anweisung"..
			"\n  ( ; ) - 'oder' Anweisung"..
			"\n  ! ! - 'nicht' Anweisung"..
			"\n  [ ] - Groß-/Kleinschreibung beachten"..
			"\n  @ @ - Lua-Muster"..
			"\n\nBeispielnachrichten:"..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\nSuchanfragen und Ergebnisse:"..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - leer"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\nTab/Umschalt-Tab zur Navigation durch die Eingabeaufforderungen."..
			"\nRechtsklick auf den Suchbutton für kürzliche Anfragen."..
			"\nUmschalt-Rechtsklick für Zugriff auf die Suchkonfiguration."..
			"\nAlt-Rechtsklick für blockierte Nachrichten."..
			"\nStrg-Rechtsklick zum Löschen des Zwischenspeichers gefilterter Nachrichten."..
			"\n\nKanalnamen und Zeitstempel werden nicht analysiert."
L["Search button visibility."] = "Sichtbarkeit des Suchbuttons."
L["Search button point."] = "Suchbutton-Punkt."
L["Config Tooltips"] = "Konfigurationstooltips"
L["Highlight Color"] = "Hervorhebungsfarbe"
L["Match highlight color."] = "Übereinstimmende Hervorhebungsfarbe."
L["Filter Type"] = "Filtertyp"
L["Rule Terms"] = "Regelbedingungen"
L["Same logic as with the search."] = "Gleiche Logik wie bei der Suche."
L["Select Chat Types"] = "Chattypen auswählen"
L["Say"] = "Sagen"
L["Yell"] = "Schreien"
L["Party"] = "Gruppe"
L["Raid"] = "Schlachtzug"
L["Guild"] = "Gilde"
L["Battleground"] = "Schlachtfeld"
L["Whisper"] = "Flüstern"
L["Channel"] = "Kanal"
L["Other"] = "Sonstige"
L["Select Rule"] = "Regel auswählen"
L["Select Chat Frame"] = "Chatfenster auswählen"
L["Add Rule"] = "Regel hinzufügen"
L["Delete Rule"] = "Regel löschen"
L["Compact Chat"] = "Kompakter Chat"
L["Move left"] = "Nach links bewegen"
L["Move right"] = "Nach rechts bewegen"
L["Mouseover: Left"] = "Mouseover: Links"
L["Mouseover: Right"] = "Mouseover: Rechts"
L["Automatic Onset"] = "Automatischer Beginn"
L["Scans tooltip texts and sets icons automatically."] = "Durchsucht Tooltip-Texte und setzt Symbole automatisch."
L["Icon (Default)"] = "Symbol (Standard)"
L["Icon (Kill)"] = "Symbol (Kill)"
L["Icon (Chat)"] = "Symbol (Chat)"
L["Icon (Item)"] = "Symbol (Gegenstand)"
L["Show Text"] = "Text anzeigen"
L["Display progress status."] = "Fortschrittsstatus anzeigen."
L["Name"] = "Name"
L["Frequent Updates"] = "Häufige Aktualisierungen"
L["Events (optional)"] = "Ereignisse (optional)"
L["InternalCooldowns"] = "Interne Abklingzeiten"
L["Displays internal cooldowns on trinket tooltips."] = "Zeigt interne Abklingzeiten in Schmuckstück-Tooltips an."
L["Shortening X Offset"] = "Verkürzung X-Versatz"
L["To Level"] = "Bis Level"
L["Names will be shortened based on level text position."] = "Namen werden basierend auf der Position des Leveltextes verkürzt."
L["Add Item (by ID)"] = "Gegenstand hinzufügen (per ID)"
L["Remove Item"] = "Gegenstand entfernen"
L["Pre-Load"] = "Vor-Laden"
L["Executes commands during the addon's initialization process."] = "Führt Befehle während des Initialisierungsprozesses des Addons aus."
L["Justify"] = "Rechtfertigen"
L["Alt-Click: free bag slots, if possible."] = "Alt-Klick: Freie Taschenplätze, wenn möglich."
L["Click: toggle layout mode."] = "Klicken: Layout-Modus umschalten."
L["Alt-Click: re-evaluate all items."] = "Alt-Klick: Alle Gegenstände neu bewerten."
L["Shift-Alt-Click: toggle these hints."] = "Shift-Alt-Klick: Diese Hinweise umschalten."
L["Mouse-Wheel: navigate between special and normal bags."] = "Mausrad: Zwischen speziellen und normalen Taschen navigieren."
L["This button accepts cursor item drops."] = "Dieser Button nimmt Gegenstände vom Cursor an."
L["Setup Sections"] = "Abschnitte einrichten"
L["Adds default sections set to the currently selected container."] = "Fügt Standardabschnitte zum aktuell ausgewählten Container hinzu."
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
		"Verarbeitet die automatische Positionierung von Gegenständen.\n"..
			"Syntax: filter@value\n\n"..
			"Verfügbare Filter:\n"..
			" id@number - entspricht itemID,\n"..
			" name@string - entspricht Name,\n"..
			" type@string - entspricht Typ,\n"..
			" subtype@string - entspricht Untertyp,\n"..
			" ilvl@number - entspricht ilvl,\n"..
			" uselevel@number - entspricht Ausrüstungsstufe,\n"..
			" quality@number - entspricht Qualität,\n"..
			" equipslot@number - entspricht InventorySlotID,\n"..
			" maxstack@number - entspricht Stapelgrenze,\n"..
			" price@number - entspricht Verkaufspreis,\n"..
			" tooltip@string - entspricht Tooltip-Text,\n"..
			" set@setName - entspricht Ausrüstungsset-Gegenständen.\n\n"..
			"Alle Stringübereinstimmungen sind nicht groß-/kleinschreibungsempfindlich und entsprechen nur den alphanumerischen Symbolen.\n"..
			"Standard Lua-Logik für Verzweigungen (und/oder/Elternklammern/usw.) gilt.\n\n"..
			"Beispielverwendung (Priester t8 oder Shadowmourne):\n"..
			"(quality@4 und ilvl@>=219 und ilvl@<=245 und subtype@cloth und name@ofSanctification) oder name@shadowmourne.\n\n"..
			"Akzeptiert benutzerdefinierte Funktionen (bagID, slotID, itemID sind verfügbar)\n"..
			"Der folgende benachrichtigt über die neu erworbenen Gegenstände.\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('Gegenstand erhalten: ' .. string)"
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
		"Syntax: filter@value@amount\n\n"..
			"Verfügbare Filter:\n"..
			" id@number@amount(+)/+ - entspricht itemID,\n"..
			" name@string@amount(+)/+ - entspricht Name,\n"..
			" type@string@amount(+)/+ - entspricht Typ,\n"..
			" subtype@string@amount(+)/+ - entspricht Untertyp,\n"..
			" ilvl@number@amount(+)/+ - entspricht ilvl,\n"..
			" uselevel@number@amount(+)/+ - entspricht Ausrüstungsstufe,\n"..
			" quality@number@amount(+)/+ - entspricht Qualität,\n"..
			" equipslot@number@amount(+)/+ - entspricht InventorySlotID,\n"..
			" maxstack@number@amount(+)/+ - entspricht Stapelgrenze,\n"..
			" price@number@amount(+)/+ - entspricht Verkaufspreis,\n"..
			" tooltip@string@amount(+)/+ - entspricht Tooltip-Text.\n\n"..
			"Der optionale 'amount'-Teil könnte sein:\n"..
			" eine Zahl - um eine feste Menge zu kaufen,\n"..
			" ein + Zeichen - um den bestehenden Teilstapel aufzufüllen oder einen neuen zu kaufen,\n"..
			" beides (z.B. 5+) - um genug Gegenstände zu kaufen, um eine bestimmte Gesamtmenge zu erreichen (in diesem Fall 5),\n"..
			" weggelassen - standardmäßig 1.\n\n"..
			"Alle Stringübereinstimmungen sind nicht groß-/kleinschreibungsempfindlich und entsprechen nur den alphanumerischen Symbolen.\n"..
			"Standard Lua-Logik für Verzweigungen (und/oder/Elternklammern/usw.) gilt.\n\n"..
			"Beispielverwendung (Priester t8 oder Shadowmourne):\n"..
			"(quality@4 und ilvl@>=219 und ilvl@<=245 und subtype@cloth und name@ofSanctification) oder name@shadowmourne."
L["PERIODIC"] = "PERIODISCH"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "Halten Sie diese Taste gedrückt, während Sie den Befehl /addOccupation verwenden, um die Liste des aktuellen Ziels/Mauszeiger-NPC zu löschen."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "Verwenden Sie den Befehl /addOccupation, während Sie auf ein NPC zielen/überfahren, um es zur Liste hinzuzufügen. Verwenden Sie ihn erneut, um zu wechseln."
L["Style Filter Icons"] = "Stilfilter-Symbole"
L["Custom icons for the style filter."] = "Benutzerdefinierte Symbole für den Stilfilter."
L["Whitelist"] = "Whitelist"
L["X Direction"] = "X-Richtung"
L["Y Direction"] = "Y-Richtung"
L["Create Icon"] = "Icon erstellen"
L["Delete Icon"] = "Icon löschen"
L["0 to match frame width."] = "0 um die Rahmenbreite anzupassen."
L["Remove a NPC"] = "Einen NPC entfernen"
L["Change a NPC's Occupation"] = "Beruf eines NPC ändern"
L["...to the currently selected one."] = "...zum aktuell ausgewählten."
L["Select Occupation"] = "Beruf auswählen"
L["Sell"] = "Verkaufen"
L["Action Type"] = "Aktionstyp"
L["Style Filter Additional Triggers"] = "Stilfilter Zusätzliche Auslöser"
L["Triggers"] = "Auslöser"
L["Example usage:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"] =
		"Beispielnutzung:"..
			"\n local frame, filter, trigger = ..."..
			"\n return frame.UnitName == 'Shrek'"..
			"\n         or (frame.unit"..
			"\n             and UnitName(frame.unit) == 'Fiona')"
L["Abbreviate Name"] = "Abgekürzter Name"
L["Highlight Self"] = "Sich selbst hervorheben"
L["Highlight Others"] = "Andere hervorheben"
L["Self Inherit Name Color"] = "Eigene Namensfarbe übernehmen"
L["Self Texture"] = "Eigene Textur"
L["Whitespace to disable, empty to default."] = "Leerzeichen zum Deaktivieren, leer für Standard."
L["Self Color"] = "Eigene Farbe"
L["Self Scale"] = "Eigener Maßstab"
L["Others Inherit Name Color"] = "Andere Namensfarbe übernehmen"
L["Others Texture"] = "Andere Textur"
L["Others Color"] = "Andere Farbe"
L["Others Scale"] = "Anderer Maßstab"
L["Targets"] = "Ziele"
L["Random dungeon finder queue status frame."] = "Statusfenster für Dungeonbrowser-Warteschlange."
L["Queue Time"] = "Wartezeit"
L["RDFQueueTracker"] = "RDFWarteschlangenTracker"
L["Abbreviate Numbers"] = "Zahlen abkürzen"
L["DEFAULTS"] = "STANDARDS"
L["INTERRUPT"] = "UNTERBRECHEN"
L["CONTROL"] = "KONTROLLE"
L["Copy List"] = "Liste kopieren"
L["DepthOfField"] = "Tiefenschärfe"
L["Fades nameplates based on distance to screen center and cursor."] =
	"Blendet Namensplaketten basierend auf der Entfernung zur Bildschirmmitte und zum Cursor aus."
L["Disable in Combat"] = "Im Kampf deaktivieren"
L["Y Axis Pivot"] = "Y-Achsen-Drehpunkt"
L["Most opaque spot relative to screen center."] = "Undurchsichtigster Punkt relativ zur Bildschirmmitte."
L["Min Opacity"] = "Minimale Deckkraft"
L["Falloff Rate"] = "Abklingrate"
L["Mouse Falloff Rate"] = "Maus-Abklingrate"
L["Base multiplier."] = "Basis-Multiplikator."
L["Effect Curve"] = "Effektkurve"
L["Mouse Effect Curve"] = "Maus-Effektkurve"
L["Higher values result in steeper falloff."] = "Höhere Werte führen zu steilerem Abfall."
L["Enable Mouse"] = "Maus aktivieren"
L["Also calculate cursor proximity."] = "Auch Cursorproximität berechnen."
L["Ignore Styled"] = "Formatierte ignorieren"
L["Ignore Target"] = "Ziel ignorieren"
L["Spells outside the selected whitelist filters will not be displayed."] =
	"Zauber außerhalb der ausgewählten Whitelist-Filter werden nicht angezeigt."
L["Enables tooltips to display which set an item belongs to."] = "Aktiviert Tooltips, die anzeigen, zu welchem Set ein Gegenstand gehört."
L["TierText"] = "Stufentext"
L["Select Item"] = "Artikel auswählen"
L["Add Item (ID)"] = "Artikel hinzufügen (ID)"
L["Item Text"] = "Artikeltext"
L["Sort by Filter"] = "Nach Filter sortieren"
L["Makes aura sorting abide filter priorities."] = "Sortiert Auren gemäß der Filterprioritäten."
L["Add Spell"] = "Zauber hinzufügen"
L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"] =
	"Format: 'ZauberID Abklingzeit',\nz. B. 42292 120\noder\nZauberName 20"
L["Fixes and Tweaks (requires reload)"] = "Fehlerbehebungen und Anpassungen (erfordert Neustart)"
L["Restore Raid Controls"] = "Schlachtzugskontrollen wiederherstellen"
L["Brings back 'Promote to Leader/Assist' controls in raid members' dropdown menus."] =
	"Stellt die Option 'Zum Anführer/Assistenten befördern' im Dropdown-Menü der Schlachtzugsmitglieder wieder her."
L["World Map Quests"] = "Weltkarten-Quests"
L["Allows Ctrl+Click on the world map quest list to open the quest log."] =
	"Ermöglicht das Öffnen des Questlogs durch Strg+Klick auf die Weltkarten-Questliste."
L["Unit Hostility Status"] = "Einheiten-Feindlichkeitsstatus"
L["Forces a nameplate update when a unit changes factions or hostility status (e.g. mind control)."] =
	"Erzwingt eine Namensplaketten-Aktualisierung, wenn eine Einheit ihre Fraktion oder ihren Feindlichkeitsstatus ändert (z. B. Gedankenkontrolle)."
L["Style Filter Name-Only"] = "Namensanzeige-Stilfilter"
L["Fixes an issue where the style filter fails to update the nameplate on aura events after hiding its health."] =
	"Behebt ein Problem, bei dem der Stilfilter die Namensplakette nach dem Verbergen der Lebensanzeige bei Aura-Ereignissen nicht aktualisiert."
L["Use Default Handling"] = "Standardverarbeitung verwenden"
L["Show Group Members"] = "Gruppenmitglieder anzeigen"
L["Hide Group Members"] = "Gruppenmitglieder ausblenden"
L["Select 'Enemy Player' to configure."] = "Wähle 'Feindlicher Spieler' zur Konfiguration."
L["Capture Bar"] = "Eroberungsleiste"
L["Capture Bar Mover"] = "Eroberungsleisten-Verschieber"
L["Capture Bar Height"] = "Höhe der Eroberungsleiste"
L["Also might fix capture bar related issues like progress marker not showing."] =
	"Kann auch Probleme mit der Eroberungsleiste beheben, wie z. B. das Nichtanzeigen des Fortschrittsmarkers."
L["Max Length"] = "Maximale Länge"
L["Copy button visibility."] = "Sichtbarkeit der Kopierschaltfläche."
L["Mouseover: Channel Button"] = "Mouseover: Kanal-Schaltfläche"
L["Mouseover: Copy Button"] = "Mouseover: Kopieren-Schaltfläche"
L["Plugin version mismatch! Please, download appropriate plugin version at"] =
	"Plugin-Version stimmt nicht überein! Bitte lade die passende Version herunter unter"
L["Questie Coherence"] = "Questie-Kompatibilität"
L["Makes, once again, itemID tooltip line added by ElvUI to get positioned last on unit and item tooltips."] =
	"Sorgt erneut dafür, dass die von ElvUI hinzugefügte itemID-Zeile im Tooltip zuletzt angezeigt wird (Einheiten & Gegenstände)."
L["Attempts to extend font outline options across all of ElvUI."] =
	"Versucht, die Schriftumriss-Optionen überall in ElvUI zu erweitern."
