local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "frFR")

L["Hits the 'Confirm' button automatically."] = "Appuie automatiquement sur le bouton 'Confirmer'."
L["Picks up items and money automatically."] = "Ramasse automatiquement les objets et l'argent."
L["Automatically fills the 'DELETE' field."] = "Remplit automatiquement le champ 'SUPPRIMER'."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = "Sélectionne la première option de dialogue si c'est la seule disponible, sauf si un modificateur est maintenu.\nAttention aux déclencheurs d'événements importants, il n'y a pas de mécanisme de sécurité."
L["Accepts and turns in quests automatically while holding a modifier."] = "Accepte et rend les quêtes automatiquement en maintenant un modificateur."
L["Loot info wiped."] = "Informations de butin effacées."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "Commande /lootinfo pour obtenir un résumé rapide des butins récents.\n\nUtilisation: /lootinfo Pomme 60\n'Pomme' - nom de l'objet/joueur \n(rechercher @self pour obtenir le butin du joueur)\n'60' - \nlimite de temps (<60 secondes), optionnel,\n/lootinfo !wipe - purger le cache de butin."
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "Colore les noms des amis en ligne et des membres de la guilde dans certains messages et stylise les jets.\nLes bulles de discussion déjà traitées ne seront pas stylisées avant un /reload."
L["Colors loot roll messages for you and other players."] = "Colore les messages de jets de butin pour vous et les autres joueurs."
L["Loot rolls icon size."] = "Taille de l'icône des jets de butin."
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "Restyler les barres de butin.\nNécessite que 'Jet de butin' (Général -> Améliorations BlizzUI -> Jet de butin) soit activé (activer ce module l'active automatiquement)."
L["Displays the name of the player pinging the minimap."] = "Affiche le nom du joueur qui ping la minicarte."
L["Displays the currently held currency amount next to the item prices."] = "Affiche le montant de la monnaie actuellement détenue à côté des prix des objets."
L["Narrows down the World(..Frame)."] = "Réduit le World(..Frame)."
L["'Out of mana', 'Ability is not ready yet', etc."] = "'À court de mana', 'Capacité pas encore prête', etc."
L["Re-enable quest updates."] = "Réactiver les mises à jour de quête."
L["255, 210, 0 - Blizzard's yellow."] = "255, 210, 0 - le jaune de Blizzard."
L["Text to display upon entering combat."] = "Texte à afficher lors de l'entrée en combat."
L["Text to display upon leaving combat."] = "Texte à afficher lors de la sortie de combat."
L["REQUIRES RELOAD."] = "NÉCESSITE UN RECHARGEMENT."
L["Icon to the left or right of the item link."] = "Icône à gauche ou à droite du lien de l'objet."
L["The size of the icon in the chat frame."] = "La taille de l'icône dans la fenêtre de discussion."
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = "Ajoute des ombres à tous les cadres.\nNe fait rien à moins de remplacer votre ElvUI/Core/Toolkit.lua par le fichier pertinent du dossier Optionnels de ce plugin."
L["Combat state notification alerts."] = "Alertes de notification d'état de combat."
L["Custom editbox position and size."] = "Position et taille personnalisées de la zone de saisie."
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
		"Utilisation :"..
			"\n/tnote list - renvoie toutes les notes existantes"..
			"\n/tnote wipe - efface toutes les notes existantes"..
			"\n/tnote 1 icon Interface\\Path\\ToYourIcon - identique à set (sauf pour la partie lua)"..
			"\n/tnote 1 get - identique à set, renvoie les notes existantes"..
			"\n/tnote 1 set VotreNoteIci - ajoute une note à l'index désigné de la liste "..
			"ou au texte de l'infobulle actuellement affichée si le deuxième argument (1 dans ce cas) est omis, "..
			"prend en charge les fonctions et la coloration "..
			"(ne fournir aucun texte efface la note) ;"..
			"\npour sauter des lignes, utilisez ::"..
			"\n\nExemple :"..
			"\n\n/tnote 3 set feu pré-bis::source : Jean-Michel Pipeau"..
			"\n\n/tnote set local percentage ="..
			"\n  UnitHealth('mouseover') / "..
			"\n  UnitHealthMax('mouseover')"..
			"\nreturn string.format('\124\124cffffd100(couleur par défaut)'"..
			"\n  ..UnitName('mouseover')"..
			"\n  ..': \124\124cff%02x%02x00'"..
			"\n  ..UnitHealth('mouseover'), "..
			"\n  (1-percentage)*255, percentage*255)"
L["Adds an icon next to chat hyperlinks."] = "Ajoute une icône à côté des hyperliens du chat."
L["A new action bar that collects usable quest items from your bag.\n\nDue to state actions limit, this module overrides bar10 created by ElvUI Extra Action Bars."] = "Une nouvelle barre d'action qui collecte les objets de quête utilisables de votre sac.\n\nEn raison de la limite d'actions d'état, ce module remplace la barre 10 créée par ElvUI Extra Action Bars."
L["Toggles the display of the actionbar's backdrop."] = "Active/désactive l'affichage de l'arrière-plan des barres d'action."
L["The frame will not be displayed unless hovered over."] = "Le cadre ne s'affichera que lorsque vous passez la souris dessus."
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "Hérite du fondu global, passer la souris dessus, cibler, définir le focus, perdre de la santé, entrer en combat supprimera la transparence. Sinon, il utilisera le niveau de transparence dans les paramètres généraux de la barre d'action pour le fondu global alpha."
L["The first button anchors itself to this point on the bar."] = "Le premier bouton s'ancre à ce point sur la barre."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "Faites un clic droit sur l'objet tout en maintenant le modificateur pour le mettre sur liste noire. Les objets sur liste noire n'apparaîtront pas sur la barre.\nUtilisez /questbarRestore pour purger la liste noire."
L["The number of buttons to display."] = "Le nombre de boutons à afficher."
L["The number of buttons to display per row."] = "Le nombre de boutons à afficher par ligne."
L["The size of the action buttons."] = "La taille des boutons d'action."
L["Spacing between the buttons."] = "L'espacement entre les boutons."
L["Spacing between the backdrop and the buttons."] = "L'espacement entre l'arrière-plan et les boutons."
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = "Multiplie la hauteur ou la largeur de l'arrière-plan par cette valeur. C'est utile si vous souhaitez avoir plus d'une barre derrière un arrière-plan."
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = "Cela fonctionne comme une macro, vous pouvez exécuter différentes situations pour faire apparaître/disparaître la barre d'action différemment.\n Exemple : '[combat] showhide'"
L["Adds anchoring options to the movers' nudges."] = "Ajoute des options d'ancrage aux déplacements des mouveurs."
L["Mod-clicking an item suggests a skill/item to process it."] = "Cliquer avec le modificateur sur un objet suggère une compétence/objet pour le traiter."
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"Maintenir %s tout en faisant un clic gauche sur une pile la divise en deux; pour combiner les copies disponibles, faites un clic droit à la place."..
    "\n\nModifie également le SplitStackFrame pour utiliser une zone de saisie au lieu de flèches."
L["Extends the bags functionality."] = "Étend la fonctionnalité des sacs."
L["Default method: type > inventory slot ID > item level > name."] = "Méthode par défaut : type > id d'emplacement d'inventaire > niveau d'objet > nom."
L["Listed ItemIDs will not get sorted."] = "Les ID d'objets listés ne seront pas triés."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Ex. Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "Format de condition invalide : "
L["The generated custom sorting method did not return a function."] = "La méthode de tri personnalisée générée n'a pas retourné de fonction."
L["The loaded custom sorting method did not return a function."] = "La méthode de tri personnalisée chargée n'a pas retourné de fonction."
L["Item received: "] = "Objet reçu : "
L[" added."] = " ajouté."
L[" removed."] = " supprimé."
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
		"Gère le repositionnement automatique des objets nouvellement reçus."..
		"\nSyntaxe: filtre@valeur\n\n"..
		"Filtres disponibles:\n"..
		" id@nombre - correspond à l'ID de l'objet,\n"..
		" name@chaîne - correspond au nom,\n"..
		" subtype@chaîne - correspond au sous-type,\n"..
		" ilvl@nombre - correspond au niveau d'objet,\n"..
		" uselevel@nombre - correspond au niveau d'équipement,\n"..
		" quality@nombre - correspond à la qualité,\n"..
		" equipslot@nombre - correspond à l'ID d'emplacement d'inventaire,\n"..
		" maxstack@nombre - correspond à la limite de pile,\n"..
		" price@nombre - correspond au prix de vente,\n\n"..
		" tooltip@chaîne - correspond au texte de l'infobulle,\n\n"..
		"Toutes les correspondances de chaînes ne sont pas sensibles à la casse et ne correspondent qu'aux symboles alphanumériques. La logique Lua standard s'applique. "..
		"Consultez l'API GetItemInfo pour plus d'informations sur les filtres. "..
		"Utilisez GetAuctionItemClasses et GetAuctionItemSubClasses (comme dans l'HV) pour obtenir les valeurs localisées des types et sous-types.\n\n"..
		"Exemple d'utilisation (prêtre t8 ou Deuillegivre):\n"..
		"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@deSanctification) or name@deuillegivre.\n\n"..
		"Accepte les fonctions personnalisées (bagID, slotID, itemID sont exposés)\n"..
		"L'exemple ci-dessous notifie les objets nouvellement acquis.\n\n"..
		"local icon = GetContainerItemInfo(bagID, slotID)\n"..
		"local _, link = GetItemInfo(itemID)\n"..
		"icon = gsub(icon, '\\124', '\\124\\124')\n"..
		"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
		"print('Objet reçu: ' .. string)"
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
		"Syntaxe: filtre@valeur\n\n"..
			"Filtres disponibles:\n"..
			" id@nombre - correspond à l'ID de l'objet,\n"..
			" name@texte - correspond au nom,\n"..
			" type@texte - correspond au type,\n"..
			" subtype@texte - correspond au sous-type,\n"..
			" ilvl@nombre - correspond au niveau d'objet,\n"..
			" uselevel@nombre - correspond au niveau d'équipement,\n"..
			" quality@nombre - correspond à la qualité,\n"..
			" equipslot@nombre - correspond à l'ID d'emplacement d'inventaire,\n"..
			" maxstack@nombre - correspond à la limite de pile,\n"..
			" price@nombre - correspond au prix de vente,\n"..
			" tooltip@texte - correspond au texte de l'infobulle.\n\n"..
			"Toutes les correspondances de texte ne sont pas sensibles à la casse et ne correspondent qu'aux symboles alphanumériques.\n"..
			"La logique lua standard pour les branchements (et/ou/parenthèses/etc.) s'applique.\n\n"..
			"Exemple d'utilisation (prêtre t8 ou Deuillelombre):\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["Available Item Types"] = "Types d'objets disponibles"
L["Lists all available item subtypes for each available item type."] =
	"Liste tous les sous-types d'objets disponibles pour chaque type d'objet disponible."
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] =
		"Maintenir cette touche en interagissant avec un marchand achète tous les articles qui passent le filtre d'Achat automatique.\n"..
			"Mod-cliquez sur une entrée de la liste pour acheter un seul des articles, peu importe la règle '@quantité'."
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] =
		"Méthode par défaut: type > ID d'emplacement d'inventaire > niveau d'objet > nom.\n\n"..
		"Accepte les fonctions personnalisées (bagID et slotID sont disponibles sous a/b.bagID/slotID).\n\n"..
		"function(a,b)\n"..
		"--votre logique de tri ici\n"..
		"end\n\n"..
		"Laissez vide pour utiliser la méthode par défaut."
L["Event and OnUpdate handler."] = "Gestionnaire d'événements et OnUpdate."
L["Minimal time gap between two consecutive executions."] = "Intervalle de temps minimal entre deux exécutions consécutives."
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = "UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - script 'OnUpdate'"
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
		"Syntaxe:"..
		"\n\nEVENEMENT[n~=nil]"..
		"\n[n~=valeur]"..
		"\n[m=false]"..
		"\n[k~=@@UnitName('player')]"..
		"\n@@@commandes@@@"..
		"\n\n'EVENEMENT' - Événement de la section des événements ci-dessus"..
		"\n'n, m, k' - indices des arguments de charge utile souhaités (nombre)"..
		"\n'nil/valeur/booléen/code lua' - sortie souhaitée de l'argument n"..
		"\n'@@' - drapeau d'argument lua, doit aller avant le code lua dans la section de valeur des arguments"..
		"\n'~' - drapeau de négation, ajouter avant le signe égal pour que le code soit exécuté si n/m/k ne correspond pas à la valeur définie"..
		"\n'@@@ @@@' - crochets contenant les commandes."..
		"\nVous pouvez accéder à la charge utile (...) comme d'habitude."..
		"\n\nExemple:"..
		"\n\nUNIT_AURA[1=player]@@@"..
		"\nprint(le joueur a gagné/perdu une aura)@@@"..
		"\n\nCHAT_MSG_WHISPER"..
		"\n[5~=@@UnitName('player')]"..
		"\n[14=false]@@@"..
		"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
		"\n\nCOMBAT_LOG_EVENT_"..
		"\nUNFILTERED"..
		"\n[5=@@UnitName('arena1')]"..
		"\n[5=@@UnitName('arena2')]@@@"..
		"\nfor i = 1, 2 do"..
		"\nif UnitDebuff('party'..i, 'Mauvais sort')"..
		"\nthen print(UnitName('party'..i)..' est affecté!')"..
		"\nend end@@@"..
		"\n\nCe module analyse les chaînes, donc essayez de faire suivre strictement la syntaxe à votre code, sinon il pourrait ne pas fonctionner."
L["Highlights auras."] = "Met en surbrillance les auras."
L["E.g. 42292"] = "Par exemple, 42292"
L["Applies highlights to all auras passing the selected filter."] = "Met en surbrillance toutes les auras passant le filtre sélectionné."
L["Priority: spell, filter, curable/stealable."] = "Priorité : sort, filtre, soignable/volable."
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = "Si activé, les valeurs GLOBAL de Sort ou Filtre seront utilisées."
L["Makes auras grow sideswise."] = "Fait croître les auras latéralement."
L["Turns off texture fill."] = "Désactive le remplissage de texture."
L["Makes auras flicker right before fading out."] = "Fait clignoter les auras juste avant de disparaître."
L["Disables border coloring."] = "Désactive la coloration des bordures."
L["Click Cancel"] = "Annuler au clic"
L["Right-click a player buff to cancel it."] = "Cliquez avec le bouton droit sur un buff du joueur pour l'annuler."
L["Disables debuffs desaturation."] = "Désactive la désaturation des débuffs."
L["Saturated Debuffs"] = "Débuffs Saturés"
L["Confirm Rolls"] = "Confirmer les jets"
L["Auto Pickup"] = "Ramassage automatique"
L["Swift Buy"] = "Achat rapide"
L["Buys out items automatically."] = "Achète automatiquement des articles."
L["Failsafe"] = "Sécurité"
L["Enables popup confirmation dialog."] = "Active la boîte de dialogue de confirmation."
L["Add Set"] = "Ajouter un ensemble"
L["Delete Set"] = "Supprimer l'ensemble"
L["Select Set"] = "Sélectionner un ensemble"
L["Auto Buy"] = "Achat automatique"
L["Fill Delete"] = "Remplir suppression"
L["Gossip"] = "Dialogue"
L["Accept Quest"] = "Accepter quête"
L["Loot Info"] = "Info de butin"
L["Styled Messages"] = "Messages stylisés"
L["Indicator Color"] = "Couleur de l'indicateur"
L["Select Status"] = "Sélectionner le statut"
L["Select Indicator"] = "Sélectionner l'indicateur"
L["Styled Loot Messages"] = "Messages de butin stylisés"
L["Icon Size"] = "Taille de l'icône"
L["Loot Bars"] = "Barres de butin"
L["Bar Height"] = "Hauteur de la barre"
L["Bar Width"] = "Largeur de la barre"
L["Player Pings"] = "Pings des joueurs"
L["Held Currency"] = "Monnaie détenue"
L["LetterBox"] = "Letterbox"
L["Left"] = "Gauche"
L["Right"] = "Droite"
L["Top"] = "Haut"
L["Bottom"] = "Bas"
L["Hide Errors"] = "Masquer les erreurs"
L["Show quest updates"] = "Afficher les mises à jour de quête"
L["Less Tooltips"] = "Moins d'infobulles"
L["Misc."] = "Divers"
L["Loot&Style"] = "Butin et style"
L["Automation"] = "Automatisation"
L["Bags"] = "Sacs"
L["Easier Processing"] = "Traitement facilité"
L["Modifier"] = "Modificateur"
L["Split Stack"] = "Diviser la pile"
L["Bags Extended"] = "Sacs étendus"
L["Select Container Type"] = "Sélectionner le type de conteneur"
L["Settings"] = "Paramètres"
L["Add Section"] = "Ajouter une section"
L["Delete Section"] = "Supprimer la section"
L["Select Section"] = "Sélectionner la section"
L["Section Priority"] = "Priorité de la section"
L["Section Spacing"] = "Espacement des sections"
L["Collection Method"] = "Méthode de collecte"
L["Sorting Method"] = "Méthode de tri"
L["Ignore Item (by ID)"] = "Ignorer l'objet (par ID)"
L["Remove Ignored"] = "Supprimer les ignorés"
L["Title"] = "Titre"
L["Color"] = "Couleur"
L["Attach to Icon"] = "Attacher à l'icône"
L["Text"] = "Texte"
L["Font Size"] = "Taille de police"
L["Font"] = "Police"
L["Font Flags"] = "Drapeaux de police"
L["Point"] = "Point"
L["Relative Point"] = "Point relatif"
L["X Offset"] = "Décalage X"
L["Y Offset"] = "Décalage Y"
L["Icon"] = "Icône"
L["Attach to Text"] = "Attacher au texte"
L["Texture"] = "Texture"
L["Size"] = "Taille"
L["MoversPlus"] = "DéplaceursPlus"
L["Movers Plus"] = "Déplaceurs Plus"
L["CustomCommands"] = "Commandes personnalisées"
L["Custom Commands"] = "Commandes personnalisées"
L["QuestBar"] = "Barre de quêtes"
L["Quest Bar"] = "Barre de quêtes"
L["Settings"] = "Paramètres"
L["Backdrop"] = "Arrière-plan"
L["Show Empty Buttons"] = "Afficher les boutons vides"
L["Mouse Over"] = "Survol de la souris"
L["Inherit Global Fade"] = "Hériter du fondu global"
L["Anchor Point"] = "Point d'ancrage"
L["Modifier"] = "Modificateur"
L["Buttons"] = "Boutons"
L["Buttons Per Row"] = "Boutons par ligne"
L["Button Size"] = "Taille des boutons"
L["Button Spacing"] = "Espacement des boutons"
L["Backdrop Spacing"] = "Espacement de l'arrière-plan"
L["Height Multiplier"] = "Multiplicateur de hauteur"
L["Width Multiplier"] = "Multiplicateur de largeur"
L["Alpha"] = "Alpha"
L["Visibility State"] = "État de visibilité"
L["Enable Tab"] = "Activer l'onglet"
L["Throttle Time"] = "Temps de limitation"
L["Select Tab"] = "Sélectionner l'onglet"
L["Select Event"] = "Sélectionner l'événement"
L["Rename Tab"] = "Renommer l'onglet"
L["Add Tab"] = "Ajouter un onglet"
L["Delete Tab"] = "Supprimer l'onglet"
L["Open Edit Frame"] = "Ouvrir le cadre d'édition"
L["Events"] = "Événements"
L["Commands to execute"] = "Commandes à exécuter"
L["Sub-Section"] = "Sous-section"
L["Select"] = "Sélectionner"
L["Icon Orientation"] = "Orientation de l'icône"
L["Icon Size"] = "Taille de l'icône"
L["Height Offset"] = "Décalage de hauteur"
L["Width Offset"] = "Décalage de largeur"
L["Text Color"] = "Couleur du texte"
L["Entering combat"] = "Entrée en combat"
L["Leaving combat"] = "Sortie de combat"
L["Font"] = "Police"
L["Font Outline"] = "Contour de la police"
L["Font Size"] = "Taille de la police"
L["Texture Width"] = "Largeur de la texture"
L["Texture Height"] = "Hauteur de la texture"
L["Custom Texture"] = "Texture personnalisée"
L["ItemIcons"] = "Icônes d'objets"
L["TooltipNotes"] = "Notes d'info-bulles"
L["ChatEditBox"] = "Zone de saisie du chat"
L["EnterCombatAlert"] = "Alerte d'entrée en combat"
L["GlobalShadow"] = "Ombre globale"
L["Any"] = "Tout"
L["Guildmate"] = "Membre de guilde"
L["Friend"] = "Ami"
L["Self"] = "Joueur"
L["New Tab"] = "Nouvel onglet"
L["None"] = "Aucun"
L["Version: "] = "Version :"
L["Color A"] = "Couleur A"
L["Chat messages, etc."] = "Messages de chat, etc."
L["Color B"] = "Couleur B"
L["Plugin Color"] = "Couleur du plugin"
L["Icons Browser"] = "Navigateur d'icônes"
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = "Téléchargez https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html pour obtenir des icônes plus propres et recadrées."
L["Add Texture"] = "Ajouter une texture"
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Ajoute des textures à la liste générale des textures.\nPar exemple, Interface\\Icons\\INV_Misc_QuestionMark"
L["Remove Texture"] = "Supprimer une texture"
L["Highlights"] = "Surbrillance"
L["Select Type"] = "Sélectionner le Type"
L["Highlights Settings"] = "Paramètres de Surbrillance"
L["Add Filter"] = "Ajouter un Filtre"
L["Remove Selected"] = "Supprimer la Sélection"
L["Select Spell or Filter"] = "Sélectionner un Sort ou un Filtre"
L["Use Global Settings"] = "Utiliser les Paramètres Globaux"
L["Selected Spell or Filter Values"] = "Valeurs du Sort ou Filtre Sélectionné"
L["Enable Shadow"] = "Activer l'Ombre"
L["Size"] = "Taille"
L["Shadow Color"] = "Couleur de l'Ombre"
L["Enable Border"] = "Activer la Bordure"
L["Border Color"] = "Couleur de la Bordure"
L["Centered Auras"] = "Auras Centrées"
L["Cooldown Disable"] = "Désactiver le Temps de Rechargement"
L["Animate Fade-Out"] = "Animer le Disparition"
L["Type Borders"] = "Bordures de Type"
L[" filter added."] = " filtre ajouté."
L[" filter removed."] = " filtre supprimé."
L["GLOBAL"] = "GLOBAL"
L["CURABLE"] = "Soignable"
L["STEALABLE"] = "Volable"
L["--Filters--"] = "--Filtres--"
L["--Spells--"] = "--Sorts--"
L["FRIENDLY"] = "Amical"
L["ENEMY"] = "Ennemi"
L["AuraBars"] = "Barres d'Aura"
L["Auras"] = "Auras"
L["ClassificationIndicator"] = "Indicateur de Classification"
L["ClassificationIcons"] = "Icônes de Classification"
L["ColorFilter"] = "Filtre de Couleur"
L["Cooldowns"] = "Cooldowns"
L["DRTracker"] = "Suivi DR"
L["Guilds&Titles"] = "Guildes et Titres"
L["Name&Level"] = "Nom et Niveau"
L["QuestIcons"] = "Icônes de Quêtes"
L["StyleFilter"] = "Filtre de Style"
L["Search:"] = "Recherche :"
L["Click to select."] = "Cliquez pour sélectionner."
L["Click to select."] = "Cliquez pour sélectionner."
L["Hover again to see the changes."] = "Survolez à nouveau pour voir les changements."
L["Note set for "] = "Note définie pour "
L["Note cleared for "] = "Note effacée pour "
L["No note to clear for "] = "Aucune note à effacer pour "
L["Added icon to the note for "] = "Icône ajoutée à la note pour "
L["Note icon cleared for "] = "Icône de note effacée pour "
L["No note icon to clear for "] = "Aucune icône de note à effacer pour "
L["Current note for "] = "Note actuelle pour "
L["No note found for this tooltip."] = "Aucune note trouvée pour cette infobulle."
L["Notes: "] = "Notes : "
L["No notes are set."] = "Aucune note n'est définie."
L["No tooltip is currently shown or unsupported tooltip type."] = "Aucune infobulle n'est actuellement affichée ou type d'infobulle non pris en charge."
L["All notes have been cleared."] = "Toutes les notes ont été effacées."
L["Accept"] = "Accepter"
L["Cancel"] = "Annuler"
L["Purge Cache"] = "Purger le cache"
L["Guilds"] = "Guildes"
L["Separator"] = "Séparateur"
L["X Offset"] = "Décalage X"
L["Y Offset"] = "Décalage Y"
L["Level"] = "Niveau"
L["Visibility State"] = "État de visibilité"
L["City (Resting)"] = "Ville (Repos)"
L["PvP"] = "JcJ"
L["Arena"] = "Arène"
L["Party"] = "Groupe"
L["Raid"] = "Raid"
L["Colors"] = "Couleurs"
L["Guild"] = "Guilde"
L["All"] = "Tout"
L["Occupation Icon"] = "Icône d'occupation"
L["OccupationIcon"] = "Icône d'occupation"
L["Size"] = "Taille"
L["Anchor"] = "Ancrage"
L["/addOccupation"] = "/addOccupation"
L["Remove occupation"] = "Supprimer l'occupation"
L["Modifier"] = "Modificateur"
L["Add Texture Path"] = "Ajouter un chemin de texture"
L["Remove Selected Texture"] = "Supprimer la texture sélectionnée"
L["Titles"] = "Titres"
L["Reaction Color"] = "Couleur de réaction"
L["Color based on reaction type."] = "Couleur basée sur le type de réaction."
L["Nameplates"] = "Barres d'informations"
L["Unitframes"] = "Cadres d'unité"
L["An icon similar to the minimap search."] = "Une icône similaire à la recherche sur la minicarte."
L["Displays player guild text."] = "Affiche le texte de guilde du joueur."
L["Displays NPC occupation text."] = "Affiche le texte d'occupation du PNJ."
L["Strata"] = "Strate"
L["Selected Type"] = "Type sélectionné"
L["Reaction based coloring for non-cached characters."] = "Coloration basée sur la réaction pour les personnages non mis en cache."
L["Apply Custom Color"] = "Appliquer une couleur personnalisée"
L["Class Color"] = "Couleur de classe"
L["Use class colors."] = "Utiliser les couleurs de classe."
L["Use Backdrop"] = "Utiliser l'arrière-plan"
L["Linked Style Filter Triggers"] = "Déclencheurs de filtre de style lié"
L["Select Link"] = "Sélectionner le lien"
L["New Link"] = "Nouveau lien"
L["Delete Link"] = "Supprimer le lien"
L["Target Filter"] = "Filtre cible"
L["Select a filter to trigger the styling."] = "Sélectionnez un filtre pour déclencher le style."
L["Apply Filter"] = "Appliquer le filtre"
L["Select a filter to style the frames not passing the target filter triggers."] = "Sélectionnez un filtre pour styliser les cadres ne passant pas les déclencheurs de filtre cible."
L["Cache purged."] = "Cache purgé."
L["Test Mode"] = "Mode test"
L["Draws player cooldowns."] = "Affiche les temps de recharge du joueur."
L["Show Everywhere"] = "Afficher partout"
L["Show in Cities"] = "Afficher dans les villes"
L["Show in Battlegrounds"] = "Afficher dans les champs de bataille"
L["Show in Arenas"] = "Afficher dans les arènes"
L["Show in Instances"] = "Afficher dans les instances"
L["Show in the World"] = "Afficher dans le monde"
L["Header"] = "En-tête"
L["Icons"] = "Icônes"
L["OnUpdate Throttle"] = "Limitation de mise à jour"
L["Trinket First"] = "Bijou en premier"
L["Animate Fade Out"] = "Animer la disparition"
L["Border Color"] = "Couleur de bordure"
L["Growth Direction"] = "Direction de croissance"
L["Sort Method"] = "Méthode de tri"
L["Icon Size"] = "Taille de l'icône"
L["Icon Spacing"] = "Espacement des icônes"
L["Per Row"] = "Par ligne"
L["Max Rows"] = "Lignes maximum"
L["CD Text"] = "Texte du temps de recharge"
L["Show"] = "Afficher"
L["Cooldown Fill"] = "Remplissage du temps de recharge"
L["Reverse"] = "Inverser"
L["Direction"] = "Direction"
L["Spells"] = "Sorts"
L["Add Spell (by ID)"] = "Ajouter un sort (par ID)"
L["Remove Selected Spell"] = "Supprimer le sort sélectionné"
L["Select Spell"] = "Sélectionner un sort"
L["Shadow"] = "Ombre"
L["Pet Ability"] = "Capacité du familier"
L["Shadow Size"] = "Taille de l'ombre"
L["Shadow Color"] = "Couleur de l'ombre"
L["Sets update speed threshold."] = "Définit le seuil de vitesse de mise à jour."
L["Makes PvP trinkets and human racial always get positioned first."] = "Place toujours les bijoux JcJ et le racial humain en premier."
L["Makes icons flash when the cooldown's about to end."] = "Fait clignoter les icônes lorsque le temps de recharge est sur le point de se terminer."
L["Any value apart from black (0,0,0) would override borders by time left."] = "Toute valeur autre que noir (0,0,0) remplacera les bordures par le temps restant."
L["Colors borders by time left."] = "Colore les bordures en fonction du temps restant."
L["Format: 'spellID cooldown time', e.g. 42292 120"] = "Format : 'ID du sort temps de recharge', ex. 42292 120"
L["For the important stuff."] = "Pour les choses importantes."
L["Pet casts require some special treatment."] = "Les lancers de familiers nécessitent un traitement spécial."
L["Color by Type"] = "Couleur par type"
L["Flip Icon"] = "Retourner l'icône"
L["Texture List"] = "Liste des textures"
L["Keep Icon"] = "Conserver l'icône"
L["Texture"] = "Texture"
L["Texture Coordinates"] = "Coordonnées de texture"
L["Select Affiliation"] = "Sélectionner l'affiliation"
L["Width"] = "Largeur"
L["Height"] = "Hauteur"
L["Select Class"] = "Sélectionner la classe"
L["Points"] = "Points"
L["Colors the icon based on the unit type."] = "Colore l'icône en fonction du type d'unité."
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = "Retourne l'icône horizontalement. Non compatible avec les coordonnées de texture."
L["Keep the original icon texture."] = "Conserver la texture originale de l'icône."
L["NPCs"] = "PNJ"
L["Players"] = "Joueurs"
L["By duration, ascending."] = "Par durée, croissant."
L["By duration, descending."] = "Par durée, décroissant."
L["By time used, ascending."] = "Par temps utilisé, croissant."
L["By time used, descending."] = "Par temps utilisé, décroissant."
L["Additional settings for the Elite Icon."] = "Paramètres supplémentaires pour l'icône Élite."
L["Player class icons."] = "Icônes de classe du joueur."
L["Class Icons"] = "Icônes de classe"
L["Vector Class Icons"] = "Icônes de classe vectorielles"
L["Class Crests"] = "Emblèmes de classe"
L["Floating Combat Feedback"] = "Retour de combat flottant"
L["Select Unit"] = "Sélectionner l'unité"
L["player"] = "joueur (player)"
L["target"] = "cible (target)"
L["targettarget"] = "cible de la cible (targettarget)"
L["targettargettarget"] = "cible de la cible de la cible (targettargettarget)"
L["focus"] = "focus (focus)"
L["focustarget"] = "cible du focus (focustarget)"
L["pet"] = "familier (pet)"
L["pettarget"] = "cible du familier (pettarget)"
L["raid"] = "raid (raid)"
L["raid40"] = "raid 40 (raid40)"
L["raidpet"] = "familier de raid (raidpet)"
L["party"] = "groupe (party)"
L["partypet"] = "familier de groupe (partypet)"
L["partytarget"] = "cible de groupe (partytarget)"
L["boss"] = "boss (boss)"
L["arena"] = "arène (arena)"
L["assist"] = "assistant (assist)"
L["assisttarget"] = "cible de l'assistant (assisttarget)"
L["tank"] = "tank (tank)"
L["tanktarget"] = "cible du tank (tanktarget)"
L["Scroll Time"] = "Temps de défilement"
L["Event Settings"] = "Paramètres d'événement"
L["Event"] = "Événement"
L["Disable Event"] = "Désactiver l'événement"
L["School"] = "École"
L["Use School Colors"] = "Utiliser les couleurs d'école"
L["Colors"] = "Couleurs"
L["Color (School)"] = "Couleur (École)"
L["Animation Type"] = "Type d'animation"
L["Custom Animation"] = "Animation personnalisée"
L["Flag Settings"] = "Paramètres de drapeau"
L["Flag"] = "Drapeau"
L["Font Size Multiplier"] = "Multiplicateur de taille de police"
L["Animation by Flag"] = "Animation par drapeau"
L["Icon Settings"] = "Paramètres d'icône"
L["Show Icon"] = "Afficher l'icône"
L["Icon Position"] = "Position de l'icône"
L["Bounce"] = "Rebond"
L["Blacklist"] = "Liste noire"
L["Appends floating combat feedback fontstrings to frames."] = "Ajoute des chaînes de caractères de retour de combat flottant aux cadres."
L["There seems to be a font size limit?"] = "Il semble y avoir une limite de taille de police ?"
L["Not every event is eligible for this. But some are."] = "Tous les événements ne sont pas éligibles pour cela. Mais certains le sont."
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = "Définissez votre animation personnalisée comme une fonction lua.\n\nExemple :\nfunction(self)"
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = "Basculez pour que cette section gère les animations de drapeau à la place.\n\nTous les événements n'ont pas de drapeaux."
L["Flip position left-right."] = "Inverser la position gauche-droite."
L["E.g. 42292"] = "Ex. 42292"
L["Loaded custom animation did not return a function."] = "L'animation personnalisée chargée n'a pas renvoyé de fonction."
L["Before Text"] = "Texte Avant"
L["After Text"] = "Texte Après"
L["Remove Spell"] = "Supprimer le Sort"
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] =
		"Définissez votre animation personnalisée comme une fonction lua.\n\nExemple:\nfunction(self)"..
		"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
		"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"
L["ABSORB"] = "ABSORBER"
L["BLOCK"] = "BLOQUER"
L["CRITICAL"] = "CRITIQUE"
L["CRUSHING"] = "ÉCRASANT"
L["GLANCING"] = "ÉRAFLANT"
L["RESIST"] = "RÉSISTER"
L["Diagonal"] = "Diagonal"
L["Fountain"] = "Fontaine"
L["Horizontal"] = "Horizontal"
L["Random"] = "Aléatoire"
L["Static"] = "Statique"
L["Vertical"] = "Vertical"
L["DEFLECT"] = "DÉVIER"
L["DODGE"] = "ESQUIVER"
L["ENERGIZE"] = "ÉNERGISER"
L["EVADE"] = "ÉVADER"
L["HEAL"] = "SOIGNER"
L["IMMUNE"] = "IMMUNISÉ"
L["INTERRUPT"] = "INTERROMPRE"
L["MISS"] = "RATER"
L["PARRY"] = "PARER"
L["REFLECT"] = "REFLÉTER"
L["WOUND"] = "BLESSER"
L["Debuff applied/faded/refreshed"] = "Affaiblissement appliqué/dissipé/rafraîchi"
L["Buff applied/faded/refreshed"] = "Amélioration appliquée/dissipée/rafraîchie"
L["Physical"] = "Physique"
L["Holy"] = "Sacré"
L["Fire"] = "Feu"
L["Nature"] = "Nature"
L["Frost"] = "Givre"
L["Shadow"] = "Ombre"
L["Arcane"] = "Arcane"
L["Astral"] = "Astral"
L["Chaos"] = "Chaos"
L["Elemental"] = "Élémentaire"
L["Magic"] = "Magie"
L["Plague"] = "Peste"
L["Radiant"] = "Radiant"
L["Shadowflame"] = "Flamme d'ombre"
L["Shadowfrost"] = "Givre d'ombre"
L["Up"] = "Haut"
L["Down"] = "Bas"
L["Classic Style"] = "Style Classique"
L["If enabled, default cooldown style will be used."] = "Si activé, le style de temps de recharge par défaut sera utilisé."
L["Classification Indicator"] = "Indicateur de Classification"
L["Copy Unit Settings"] = "Copier les Paramètres d'Unité"
L["Enable Player Class Icons"] = "Activer les Icônes de Classe des Joueurs"
L["Enable NPC Classification Icons"] = "Activer les Icônes de Classification des PNJ"
L["Type"] = "Type"
L["Select unit type."] = "Sélectionner le type d'unité."
L["World Boss"] = "Boss de Monde"
L["Elite"] = "Élite"
L["Rare"] = "Rare"
L["Rare Elite"] = "Élite Rare"
L["Class Spec Icons"] = "Icônes de Spécialisation de Classe"
L["Classification Textures"] = "Textures de Classification"
L["Use Nameplates' Icons"] = "Utiliser les Icônes des Barres de Nom"
L["Color enemy NPC icon based on the unit type."] = "Colorer l'icône du PNJ ennemi en fonction du type d'unité."
L["Strata and Level"] = "Strate et Niveau"
L["Warrior"] = "Guerrier"
L["Warlock"] = "Démoniste"
L["Priest"] = "Prêtre"
L["Paladin"] = "Paladin"
L["Druid"] = "Druide"
L["Rogue"] = "Voleur"
L["Mage"] = "Mage"
L["Hunter"] = "Chasseur"
L["Shaman"] = "Chaman"
L["Deathknight"] = "Chevalier de la mort"
L["Aura Bars"] = "Barres d'Aura"
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = "Ajoute des options de configuration supplémentaires pour les barres d'aura.\n\n Pour les options comme la taille et le détachement, utilisez les Déplaceurs de Barres d'Aura d'ElvUI !"
L["Hide"] = "Cacher"
L["Spell Name"] = "Nom du Sort"
L["Spell Time"] = "Temps du Sort"
L["Bounce Icon Points"] = "Points de Rebond de l'Icône"
L["Set icon to the opposite side of the bar each new bar."] = "Placer l'icône du côté opposé de la barre pour chaque nouvelle barre."
L["Flip Starting Position"] = "Inverser la Position de Départ"
L["0 to disable."] = "0 pour désactiver."
L["Detach All"] = "Détacher Tout"
L["Detach Power"] = "Détacher la Puissance"
L["Detaches power for the currently selected group."] = "Détache la puissance pour le groupe actuellement sélectionné."
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = "Raccourcit les noms de manière similaire à leur raccourcissement sur les barres de nom. Définissez 'Position du Texte' dans la configuration du nom sur GAUCHE."
L["Anchor to Health"] = "Ancrer à la Santé"
L["Adjusts the shortening based on the 'Health' text position."] = "Ajuste le raccourcissement en fonction de la position du texte 'Santé'."
L["Name Auto-Shorten"] = "Auto-Raccourcissement du Nom"
L["Appends a diminishing returns tracker to frames."] = "Ajoute un traqueur de rendements décroissants aux cadres."
L["DR Time"] = "Temps DR"
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = "Le temps DR contrôle la durée nécessaire à la réinitialisation des icônes. Plusieurs facteurs peuvent affecter la réinitialisation du DR. Si vous rencontrez des problèmes constants avec la précision de la réinitialisation du DR, vous pouvez modifier cette valeur."
L["Test"] = "Test"
L["Players Only"] = "Joueurs Uniquement"
L["Ignore NPCs when setting up icons."] = "Ignorer les PNJ lors de la configuration des icônes."
L["Setup Categories"] = "Configurer les catégories"
L["Disable Cooldown"] = "Désactiver le temps de recharge"
L["Go to 'Cooldown Text' > 'Global' to configure."] = "Allez dans 'Texte de Temps de Recharge' > 'Global' pour configurer."
L["Color Borders"] = "Bordures Colorées"
L["Spacing"] = "Espacement"
L["DR Strength Indicator: Text"] = "Indicateur de Force DR : Texte"
L["DR Strength Indicator: Box"] = "Indicateur de Force DR : Boîte"
L["Good"] = "Bon"
L["50% DR for hostiles, 100% DR for the player."] = "50% DR pour les hostiles, 100% DR pour le joueur."
L["Neutral"] = "Neutre"
L["75% DR for all."] = "75% DR pour tous."
L["Bad"] = "Mauvais"
L["100% DR for hostiles, 50% DR for the player."] = "100% DR pour les hostiles, 50% DR pour le joueur."
L["Category Border"] = "Bordure de Catégorie"
L["Select Category"] = "Sélectionner la Catégorie"
L["Categories"] = "Catégories"
L["Add Category"] = "Ajouter une Catégorie"
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = "Format : 'catégorie IDSort', par ex. fear 10890.\nLa liste de toutes les catégories est disponible dans la section 'couleurs'."
L["Remove Category"] = "Supprimer la Catégorie"
L["Category \"%s\" already exists, updating icon."] = "La catégorie \"%s\" existe déjà, mise à jour de l'icône."
L["Category \"%s\" added with %s icon."] = "Catégorie \"%s\" ajoutée avec l'icône %s."
L["Invalid category."] = "Catégorie invalide."
L["Category \"%s\" removed."] = "Catégorie \"%s\" supprimée."
L["DetachPower"] = "DétacherPuissance"
L["NameAutoShorten"] = "NomRaccourcirAuto"
L["Color Filter"] = "Filtre de Couleur"
L["Enables color filter for the selected unit."] = "Active le filtre de couleur pour l'unité sélectionnée."
L["Toggle for the currently selected statusbar."] = "Basculer pour la barre d'état actuellement sélectionnée."
L["Select Statusbar"] = "Sélectionner la Barre d'État"
L["Health"] = "Santé"
L["Castbar"] = "Barre d'Incantation"
L["Power"] = "Puissance"
L["Tab Section"] = "Section des Onglets"
L["Toggle current tab."] = "Basculer l'onglet actuel."
L["Tab Priority"] = "Priorité des Onglets"
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = "Lorsque plusieurs conditions sont remplies, les couleurs de l'onglet avec la priorité la plus élevée seront appliquées."
L["Copy Tab"] = "Copier l'Onglet"
L["Select a tab to copy its settings onto the current tab."] = "Sélectionnez un onglet pour copier ses paramètres sur l'onglet actuel."
L["Flash"] = "Flash"
L["Speed"] = "Vitesse"
L["Glow"] = "Lueur"
L["Determines which glow to apply when statusbars are not detached from frame."] = "Détermine quelle lueur appliquer lorsque les barres d'état ne sont pas détachées du cadre."
L["Priority"] = "Priorité"
L["When handling castbar, also manage its icon."] = "Lors de la gestion de la barre d'incantation, gérer également son icône."
L["CastBar Icon Glow Color"] = "Couleur de Lueur de l'Icône de la Barre d'Incantation"
L["CastBar Icon Glow Size"] = "Taille de Lueur de l'Icône de la Barre d'Incantation"
L["Borders"] = "Bordures"
L["CastBar Icon Color"] = "Couleur de l'Icône de la Barre d'Incantation"
L["Toggle classbar borders."] = "Basculer les bordures de la barre de classe."
L["Toggle infopanel borders."] = "Basculer les bordures du panneau d'information."
L["ClassBar Color"] = "Couleur de la Barre de Classe"
L["Disabled unless classbar is enabled."] = "Désactivé sauf si la barre de classe est activée."
L["InfoPanel Color"] = "Couleur du Panneau d'Information"
L["Disabled unless infopanel is enabled."] = "Désactivé sauf si le panneau d'information est activé."
L["ClassBar Adapt To"] = "Adapter la Barre de Classe À"
L["Copies the color of the selected bar."] = "Copie la couleur de la barre sélectionnée."
L["InfoPanel Adapt To"] = "Adapter le Panneau d'Information À"
L["Override Mode"] = "Mode de Remplacement"
L["'None' - threat borders highlight will be prioritized over this one"..
    "\n'Threat' - this highlight will be prioritized."] =
		"'Aucun' - la surbrillance des bordures de menace sera prioritaire"..
		"\n'Menace' - cette surbrillance sera prioritaire."
L["Threat"] = "Menace"
L["Determines which borders to apply when statusbars are not detached from frame."] = "Détermine quelles bordures appliquer lorsque les barres d'état ne sont pas détachées du cadre."
L["Bar-specific"] = "Spécifique à la barre"
L["Lua Section"] = "Section Lua"
L["Conditions"] = "Conditions"
L["Font Settings"] = "Paramètres de Police"
L["Player Only"] = "Joueur seulement"
L["Handle only player combat log events."] = "Gérer uniquement les événements du journal de combat du joueur."
L["Rotate Icon"] = "Faire pivoter l'icône"
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
		"Exemple d'utilisation :"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\n    local r, g, b = ElvUF_Target.Health:GetStatusBarColor()"..
			"\n    return true, {mR = r, mG = g, mB = b}"..
			"\nelseif UnitIsUnit(unit, 'target') then"..
			"\n    return true"..
			"\nend"..
			"\n\n@@[raid, Health, 2, >5]@@ - renvoie vrai/faux selon que l'onglet en question "..
			"(dans l'exemple ci-dessus : 'player' - unité cible ; 'Power' - barre d'état cible ; '3' - onglet cible) est actif ou non"..
			"\n(>/>=/<=/</~= num) - (optionnel, unités de groupe uniquement) "..
			"correspond à un nombre particulier de cadres déclenchés dans le groupe (plus de 5 dans l'exemple ci-dessus)"..
			"\n\n'return true, {bR=1,f=false}' - vous pouvez colorer dynamiquement les cadres en renvoyant les couleurs dans un format de table :"..
			"\n  pour appliquer à la barre d'état, attribuez vos valeurs rvb à mR, mG et mB respectivement"..
			"\n  pour appliquer la lueur - à gR, gG, gB, gA (alpha)"..
			"\n  pour les bordures - bR, bG, bB"..
			"\n  et pour le flash - fR, fG, fB, fA"..
			"\n  pour empêcher le style des éléments, renvoyez {m = false, g = false, b = false, f = false}"..
			"\n\nLe cadre et l'ID de l'unité sont disponibles respectivement dans 'frame' et 'unit': UnitBuff(unit, 'player')/frame.Health:IsVisible()."..
			"\n\nCe module analyse les chaînes de caractères, alors essayez de faire suivre strictement la syntaxe à votre code, sinon il pourrait ne pas fonctionner."
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = "À moins de maintenir un modificateur, survoler des unités, objets et sorts n'affiche aucun tooltip.\nModifie uniquement les tooltips du curseur."
L["Pick a..."] = "Choisissez un..."
L["...mover to anchor to."] = "...élément pour ancrer."
L["...mover to anchor."] = "...élément à ancrer."
L["Point:"] = "Point :"
L["Relative:"] = "Relatif :"
L["Open Editor"] = "Ouvrir l'éditeur"
L["Unless holding a modifier, hovering units draws no tooltip.\nCursor tooltips only."] = "Sans maintenir un modificateur, survoler les unités n'affiche pas d'infobulle.\nInfobulles du curseur uniquement."
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = "Ancrez toutes les fenêtres de discussion avant d'activer.\nMaj-clic sur le bouton du gestionnaire pour accéder aux paramètres des onglets."
L["Mouseover"] = "Survol"
L["Manager button visibility."] = "Visibilité du bouton du gestionnaire."
L["Manager point."] = "Point du gestionnaire."
L["Top Offset"] = "Décalage haut"
L["Bottom Offset"] = "Décalage bas"
L["Left Offset"] = "Décalage gauche"
L["Right Offset"] = "Décalage droite"
L["Chat Search and Filter"] = "Recherche et filtre de discussion"
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
		"Utilitaire de recherche et de filtrage pour les fenêtres de discussion."..
			"\n\nSyntaxe :"..
			"\n  :: - instruction 'et'"..
			"\n  ( ; ) - instruction 'ou'"..
			"\n  ! ! - instruction 'non'"..
			"\n  [ ] - sensible à la casse"..
			"\n  @ @ - motif Lua"..
			"\n\nExemples de messages :"..
			"\n  1. [4][Bigguy]: lfg yo moms place"..
			"\n  2. [4][Hustlaqwe]: LF3M yo moms place"..
			"\n  3. [4][Elfgore]: yo girls place +3 dm fast"..
			"\n  4. [W][Noobkillaz]: delete game bro"..
			"\n  5. SYSTEM: You should buy gold at our website NOW!"..
			"\n  6. [Y][Spongebob]: YOO CRUSTY CRAB"..
			"\n\nRecherches et résultats :"..
			"\n  yo - 1,2,3,5,6"..
			"\n  !yo! - 4"..
			"\n  !yo!::!delete! - vide"..
			"\n  [dElete];crab - 6"..
			"\n  (@LF%d*M@;lfg)::mom - 1,2"..
			"\n  ((gold;@[lL][fF]%d-[gGmM]@;![YO]!)::!Someahole!);bob - 1,2,3,4,5,6"..
			"\n\nTab/Maj-Tab pour naviguer dans les invites."..
			"\nClic droit sur le bouton de recherche pour accéder aux requêtes récentes."..
			"\nMaj-clic droit pour accéder à la configuration de recherche."..
			"\nAlt-clic droit pour les messages bloqués."..
			"\nCtrl-clic droit pour purger le cache des messages filtrés."..
			"\n\nLes noms de canaux et les horodatages ne sont pas analysés."
L["Search button visibility."] = "Visibilité du bouton de recherche."
L["Search button point."] = "Point du bouton de recherche."
L["Config Tooltips"] = "Infobulles de configuration"
L["Highlight Color"] = "Couleur de surbrillance"
L["Match highlight color."] = "Couleur de surbrillance des correspondances."
L["Filter Type"] = "Type de filtre"
L["Rule Terms"] = "Termes de règle"
L["Same logic as with the search."] = "Même logique que pour la recherche."
L["Select Chat Types"] = "Sélectionner les types de discussion"
L["Say"] = "Dire"
L["Yell"] = "Crier"
L["Party"] = "Groupe"
L["Raid"] = "Raid"
L["Guild"] = "Guilde"
L["Battleground"] = "Champ de bataille"
L["Whisper"] = "Chuchoter"
L["Channel"] = "Canal"
L["Other"] = "Autre"
L["Select Rule"] = "Sélectionner la règle"
L["Select Chat Frame"] = "Sélectionner la fenêtre de discussion"
L["Add Rule"] = "Ajouter une règle"
L["Delete Rule"] = "Supprimer la règle"
L["Compact Chat"] = "Chat compact"
L["Move left"] = "Déplacer à gauche"
L["Move right"] = "Déplacer à droite"
L["Mouseover: Left"] = "Survol: Gauche"
L["Mouseover: Right"] = "Survol: Droite"
L["Automatic Onset"] = "Début automatique"
L["Scans tooltip texts and sets icons automatically."] = "Analyse les textes des infobulles et définit les icônes automatiquement."
L["Icon (Default)"] = "Icône (Par défaut)"
L["Icon (Kill)"] = "Icône (Tuer)"
L["Icon (Chat)"] = "Icône (Discussion)"
L["Icon (Item)"] = "Icône (Objet)"
L["Show Text"] = "Afficher le texte"
L["Display progress status."] = "Afficher l'état de progression."
L["Name"] = "Nom"
L["Frequent Updates"] = "Mises à jour fréquentes"
L["Events (optional)"] = "Événements (facultatif)"
L["InternalCooldowns"] = "Temps de recharge internes"
L["Displays internal cooldowns on trinket tooltips."] = "Affiche les temps de recharge internes sur les infobulles des bijoux."
L["Shortening X Offset"] = "Raccourcir Décalage X"
L["To Level"] = "Jusqu'au Niveau"
L["Names will be shortened based on level text position."] = "Les noms seront raccourcis en fonction de la position du texte de niveau."
L["Add Item (by ID)"] = "Ajouter un objet (par ID)"
L["Remove Item"] = "Retirer l'objet"
L["Pre-Load"] = "Pré-chargement"
L["Executes commands during the addon's initialization process."] = "Exécute des commandes pendant le processus d'initialisation de l'addon."
L["Justify"] = "Justifier"
L["Alt-Click: free bag slots, if possible."] = "Alt-Clic : emplacements de sac libres, si possible."
L["Click: toggle layout mode."] = "Clic : basculer le mode de mise en page."
L["Alt-Click: re-evaluate all items."] = "Alt-Clic : réévaluer tous les objets."
L["Drag-and-Drop: evaluate and position the cursor item."] = "Glisser-Déposer : évaluer et positionner l'objet du curseur."
L["Shift-Alt-Click: toggle these hints."] = "Maj-Alt-Clic : activer/désactiver ces conseils."
L["Mouse-Wheel: navigate between special and normal bags."] = "Molette de la souris : naviguer entre les sacs spéciaux et normaux."
L["This button accepts cursor item drops."] = "Ce bouton accepte les objets déposés avec le curseur."
L["Setup Sections"] = "Configurer les Sections"
L["Adds default sections set to the currently selected container."] = "Ajoute des sections par défaut au conteneur actuellement sélectionné."
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
		"Gère le positionnement automatique des objets.\n"..
			"Syntaxe : filter@value\n\n"..
			"Filtres disponibles :\n"..
			" id@number - correspond à itemID,\n"..
			" name@string - correspond au nom,\n"..
			" type@string - correspond au type,\n"..
			" subtype@string - correspond au sous-type,\n"..
			" ilvl@number - correspond à ilvl,\n"..
			" uselevel@number - correspond au niveau d'équipement,\n"..
			" quality@number - correspond à la qualité,\n"..
			" equipslot@number - correspond à InventorySlotID,\n"..
			" maxstack@number - correspond à la limite de pile,\n"..
			" price@number - correspond au prix de vente,\n"..
			" tooltip@string - correspond au texte de l'info-bulle,\n"..
			" set@setName - correspond aux objets de l'ensemble d'équipement.\n\n"..
			"Toutes les correspondances de chaînes ne sont pas sensibles à la casse et ne correspondent qu'aux symboles alphanumériques.\n"..
			"La logique standard de Lua pour les branches (et/ou/parenthèses/etc.) s'applique.\n\n"..
			"Exemple d'utilisation (prêtre t8 ou Shadowmourne) :\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne.\n\n"..
			"Accepte des fonctions personnalisées (bagID, slotID, itemID sont exposés)\n"..
			"Le suivant notifie des objets nouvellement acquis.\n\n"..
			"local icon = GetContainerItemInfo(bagID, slotID)\n"..
			"local _, link = GetItemInfo(itemID)\n"..
			"icon = gsub(icon, '\\124', '\\124\\124')\n"..
			"local string = '\\124T' .. icon .. ':16:16\\124t' .. link\n"..
			"print('Objet reçu : ' .. string)"
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
		"Syntaxe : filter@value@amount\n\n"..
			"Filtres disponibles :\n"..
			" id@number@amount(+)/+ - correspond à itemID,\n"..
			" name@string@amount(+)/+ - correspond au nom,\n"..
			" type@string@amount(+)/+ - correspond au type,\n"..
			" subtype@string@amount(+)/+ - correspond au sous-type,\n"..
			" ilvl@number@amount(+)/+ - correspond à ilvl,\n"..
			" uselevel@number@amount(+)/+ - correspond au niveau d'équipement,\n"..
			" quality@number@amount(+)/+ - correspond à la qualité,\n"..
			" equipslot@number@amount(+)/+ - correspond à InventorySlotID,\n"..
			" maxstack@number@amount(+)/+ - correspond à la limite de pile,\n"..
			" price@number@amount(+)/+ - correspond au prix de vente,\n"..
			" tooltip@string@amount(+)/+ - correspond au texte de l'info-bulle.\n\n"..
			"La partie optionnelle 'amount' peut être :\n"..
			" un nombre - pour acheter une quantité statique,\n"..
			" un signe + - pour reconstituer la pile partielle existante ou acheter une nouvelle,\n"..
			" les deux (par exemple, 5+) - pour acheter suffisamment d'objets pour atteindre un total spécifié (dans ce cas, 5),\n"..
			" omis - par défaut à 1.\n\n"..
			"Toutes les correspondances de chaînes ne sont pas sensibles à la casse et ne correspondent qu'aux symboles alphanumériques.\n"..
			"La logique standard de Lua pour les branches (et/ou/parenthèses/etc.) s'applique.\n\n"..
			"Exemple d'utilisation (prêtre t8 ou Shadowmourne) :\n"..
			"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."
L["PERIODIC"] = "PÉRIODIQUE"
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = "Maintenez cette touche enfoncée tout en utilisant la commande /addOccupation pour effacer la liste de l'NPC cible/survolé actuel."
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = "Utilisez la commande de barre oblique /addOccupation tout en ciblant/survolant un NPC pour l'ajouter à la liste. Utilisez à nouveau pour faire défiler."
L["Style Filter Icons"] = "Icônes de Filtre de Style"
L["Custom icons for the style filter."] = "Icônes personnalisées pour le filtre de style."
L["Whitelist"] = "Liste blanche"
L["X Direction"] = "Direction X"
L["Y Direction"] = "Direction Y"
L["Create Icon"] = "Créer une icône"
L["Delete Icon"] = "Supprimer l'icône"
L["0 to match frame width."] = "0 pour correspondre à la largeur du cadre."
L["Remove a NPC"] = "Supprimer un PNJ"
L["Change a NPC's Occupation"] = "Changer la profession d'un PNJ"
L["...to the currently selected one."] = "...à celui actuellement sélectionné."
L["Select Occupation"] = "Sélectionner la profession"
L["Sell"] = "Vendre"
L["Action Type"] = "Type d'action"
L["Style Filter Additional Triggers"] = "Déclencheurs Supplémentaires de Filtres de Style"
L["Triggers"] = "Déclencheurs"
L["Example usage:"..
    "\n local frame, filter, trigger = ..."..
    "\n return frame.UnitName == 'Shrek'"..
    "\n         or (frame.unit"..
    "\n             and UnitName(frame.unit) == 'Fiona')"] =
		"Exemple d'utilisation:"..
			"\n local frame, filter, trigger = ..."..
			"\n return frame.UnitName == 'Shrek'"..
			"\n         or (frame.unit"..
			"\n             and UnitName(frame.unit) == 'Fiona')"
L["Abbreviate Name"] = "Nom abrégé"
L["Highlight Self"] = "Mettre en évidence soi-même"
L["Highlight Others"] = "Mettre en évidence les autres"
L["Self Inherit Name Color"] = "Hériter de la couleur du nom de soi"
L["Self Texture"] = "Texture de soi"
L["Whitespace to disable, empty to default."] = "Espace pour désactiver, vide pour défaut."
L["Self Color"] = "Couleur de soi"
L["Self Scale"] = "Échelle de soi"
L["Others Inherit Name Color"] = "Hériter de la couleur du nom des autres"
L["Others Texture"] = "Texture des autres"
L["Others Color"] = "Couleur des autres"
L["Others Scale"] = "Échelle des autres"
L["Targets"] = "Cibles"
L["Random dungeon finder queue status frame."] = "Cadre d'état de file du Recherche de donjons aléatoire."
L["Queue Time"] = "Temps d'attente"
L["RDFQueueTracker"] = "SuiviFileRDF"
L["Abbreviate Numbers"] = "Abréger les nombres"
L["DEFAULTS"] = "DÉFAUTS"
L["INTERRUPT"] = "INTERROMPRE"
L["CONTROL"] = "CONTRÔLE"
L["Copy List"] = "Copier la liste"
L["DepthOfField"] = "Profondeur de Champ"
L["Fades nameplates based on distance to screen center and cursor."] =
	"Estompe les barres de nom en fonction de la distance au centre de l'écran et au curseur."
L["Disable in Combat"] = "Désactiver en Combat"
L["Y Axis Pivot"] = "Pivot de l'Axe Y"
L["Most opaque spot relative to screen center."] = "Point le plus opaque par rapport au centre de l'écran."
L["Min Opacity"] = "Opacité Minimale"
L["Falloff Rate"] = "Taux de Dégradé"
L["Mouse Falloff Rate"] = "Taux de Dégradé de la Souris"
L["Base multiplier."] = "Multiplicateur de base."
L["Effect Curve"] = "Courbe d'Effet"
L["Mouse Effect Curve"] = "Courbe d'Effet de la Souris"
L["Higher values result in steeper falloff."] = "Des valeurs plus élevées donnent un dégradé plus prononcé."
L["Enable Mouse"] = "Activer la souris"
L["Also calculate cursor proximity."] = "Calculer aussi la proximité du curseur."
L["Ignore Styled"] = "Ignorer stylisés"
L["Ignore Target"] = "Ignorer la cible"
L["Spells outside the selected whitelist filters will not be displayed."] =
	"Les sorts en dehors des filtres de liste blanche sélectionnés ne seront pas affichés."
L["Enables tooltips to display which set an item belongs to."] = "Active les infobulles pour afficher à quel ensemble un objet appartient."
L["TierText"] = "Texte de niveau"
L["Select Item"] = "Sélectionner un article"
L["Add Item (ID)"] = "Ajouter un article (ID)"
L["Item Text"] = "Texte de l'article"
L["Sort by Filter"] = "Trier par filtre"
L["Makes aura sorting abide filter priorities."] = "Fait en sorte que le tri des auras respecte les priorités des filtres."
L["Add Spell"] = "Ajouter un sort"
L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"] =
	"Format : 'IDSort TempsRecharge',\nex. 42292 120\nou\nNomSort 20"
L["Fixes and Tweaks (requires reload)"] = "Corrections et ajustements (nécessite un rechargement)"
L["Restore Raid Controls"] = "Restaurer les contrôles de raid"
L["Brings back 'Promote to Leader/Assist' controls in raid members' dropdown menus."] =
	"Restaure les contrôles 'Promouvoir en chef/assistant' dans les menus déroulants des membres du raid."
L["World Map Quests"] = "Quêtes de la carte du monde"
L["Allows Ctrl+Click on the world map quest list to open the quest log."] =
	"Permet d’ouvrir le journal des quêtes avec Ctrl+Clic sur la liste des quêtes de la carte du monde."
L["Unit Hostility Status"] = "Statut d'hostilité des unités"
L["Forces a nameplate update when a unit changes factions or hostility status (e.g. mind control)."] =
	"Force une mise à jour de la barre de nom lorsque l’unité change de faction ou de statut d’hostilité (ex. : contrôle mental)."
L["Style Filter Name-Only"] = "Filtre de style nom uniquement"
L["Fixes an issue where the style filter fails to update the nameplate on aura events after hiding its health."] =
	"Corrige un problème où le filtre de style ne met pas à jour la barre de nom après un événement d’aura si la santé est cachée."
