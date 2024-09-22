local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "frFR")

L["Hits the 'Confirm' button automatically."] = "Appuie automatiquement sur le bouton 'Confirmer'."
L["Picks up quest items and money automatically."] = "Ramasse automatiquement les objets de quête et l'argent."
L["Fills 'DELETE' field automatically."] = "Remplit automatiquement le champ 'SUPPRIMER'."
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nCareful with important event triggers, there's no fail-safe mechanism."] = "Sélectionne la première option de dialogue si c'est la seule disponible, sauf si un modificateur est maintenu.\nAttention aux déclencheurs d'événements importants, il n'y a pas de mécanisme de sécurité."
L["Accepts and turns in quests automatically while holding a modifier."] = "Accepte et rend les quêtes automatiquement en maintenant un modificateur."
L["Loot info wiped."] = "Informations de butin effacées."
L["/lootinfo slash command to get a quick rundown of the recent lootings.\n\nUsage: /lootinfo Apple 60\n'Apple' - item/player name \n(search @self to get player loot)\n'60' - \ntime limit (<60 seconds ago), optional,\n/lootinfo !wipe - purge loot cache."] = "Commande /lootinfo pour obtenir un résumé rapide des butins récents.\n\nUtilisation: /lootinfo Pomme 60\n'Pomme' - nom de l'objet/joueur \n(rechercher @self pour obtenir le butin du joueur)\n'60' - \nlimite de temps (<60 secondes), optionnel,\n/lootinfo !wipe - purger le cache de butin."
L["Colors online friends' and guildmates' names in some of the messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = "Colore les noms des amis en ligne et des membres de la guilde dans certains messages et stylise les jets.\nLes bulles de discussion déjà traitées ne seront pas stylisées avant un /reload."
L["Colors loot roll messages for you and other players."] = "Colore les messages de jets de butin pour vous et les autres joueurs."
L["Loot rolls icon size."] = "Taille de l'icône des jets de butin."
L["Restyles loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = "Restyler les barres de butin.\nNécessite que 'Jet de butin' (Général -> Améliorations BlizzUI -> Jet de butin) soit activé (activer ce module l'active automatiquement)."
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
L["Toggles the display of the actionbars backdrop."] = "Active/désactive l'affichage de l'arrière-plan des barres d'action."
L["The frame won't show unless you mouse over it."] = "Le cadre ne s'affichera que lorsque vous passez la souris dessus."
L["Inherit the global fade, mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = "Hérite du fondu global, passer la souris dessus, cibler, définir le focus, perdre de la santé, entrer en combat supprimera la transparence. Sinon, il utilisera le niveau de transparence dans les paramètres généraux de la barre d'action pour le fondu global alpha."
L["The first button anchors itself to this point on the bar."] = "Le premier bouton s'ancre à ce point sur la barre."
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = "Faites un clic droit sur l'objet tout en maintenant le modificateur pour le mettre sur liste noire. Les objets sur liste noire n'apparaîtront pas sur la barre.\nUtilisez /questbarRestore pour purger la liste noire."
L["The amount of buttons to display."] = "Le nombre de boutons à afficher."
L["The amount of buttons to display per row."] = "Le nombre de boutons à afficher par ligne."
L["The size of the action buttons."] = "La taille des boutons d'action."
L["The spacing between buttons."] = "L'espacement entre les boutons."
L["The spacing between the backdrop and the buttons."] = "L'espacement entre l'arrière-plan et les boutons."
L["Multiply the backdrops height or width by this value. This is usefull if you wish to have more than one bar behind a backdrop."] = "Multiplie la hauteur ou la largeur de l'arrière-plan par cette valeur. C'est utile si vous souhaitez avoir plus d'une barre derrière un arrière-plan."
L["This works like a macro, you can run different situations to get the actionbar to show/hide differently.\n Example: '[combat] showhide'"] = "Cela fonctionne comme une macro, vous pouvez exécuter différentes situations pour faire apparaître/disparaître la barre d'action différemment.\n Exemple : '[combat] showhide'"
L["Adds anchoring options to movers' nudges."] = "Ajoute des options d'ancrage aux déplacements des mouveurs."
L["Mod-clicking an item suggest a skill/item to process it."] = "Cliquer avec le modificateur sur un objet suggère une compétence/objet pour le traiter."
L["Holding %s while left-clicking a stack splits it in two; to combine available copies, right-click instead.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] =
	"Maintenir %s tout en faisant un clic gauche sur une pile la divise en deux; pour combiner les copies disponibles, faites un clic droit à la place."..
    "\n\nModifie également le SplitStackFrame pour utiliser une zone de saisie au lieu de flèches."
L["Extends the bags functionality."] = "Étend la fonctionnalité des sacs."
L["Handles automated repositioning of the newly received items."] = "Gère le repositionnement automatique des objets nouvellement reçus."
L["Default method: type > inventoryslotid > ilvl > name."] = "Méthode par défaut : type > id d'emplacement d'inventaire > niveau d'objet > nom."
L["Listed ItemIDs will not get sorted."] = "Les ID d'objets listés ne seront pas triés."
L["Double-click the title text to minimize the section."] = "Double-cliquez sur le texte du titre pour minimiser la section."
L["Minimized section's line color."] = "Couleur de ligne de la section minimisée."
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = "Ex. Interface\\Icons\\INV_Misc_QuestionMark"
L["Invalid condition format: "] = "Format de condition invalide : "
L["The generated custom sorting method did not return a function."] = "La méthode de tri personnalisée générée n'a pas retourné de fonction."
L["The loaded custom sorting method did not return a function."] = "La méthode de tri personnalisée chargée n'a pas retourné de fonction."
L["Item received: "] = "Objet reçu : "
L[" added."] = " ajouté."
L[" removed."] = " supprimé."
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
		"Gère le repositionnement automatique des objets nouvellement reçus."..
		"\nSyntaxe: filtre@valeur\n\n"..
		"Filtres disponibles:\n"..
		"id@nombre - correspond à l'ID de l'objet,\n"..
		"name@chaîne - correspond au nom,\n"..
		"subtype@chaîne - correspond au sous-type,\n"..
		"ilvl@nombre - correspond au niveau d'objet,\n"..
		"uselevel@nombre - correspond au niveau d'équipement,\n"..
		"quality@nombre - correspond à la qualité,\n"..
		"equipslot@nombre - correspond à l'ID d'emplacement d'inventaire,\n"..
		"maxstack@nombre - correspond à la limite de pile,\n"..
		"price@nombre - correspond au prix de vente,\n\n"..
		"tooltip@chaîne - correspond au texte de l'infobulle,\n\n"..
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
		"\n[5~=UnitName('player')]"..
		"\n[14=false]@@@"..
		"\nPlaySound('LEVELUPSOUND', 'master')@@@"..
		"\n\nCOMBAT_LOG_EVENT_"..
		"\nUNFILTERED"..
		"\n[5=UnitName('arena1')]"..
		"\n[5=UnitName('arena2')]@@@"..
		"\nfor i = 1, 2 do"..
		"\nif UnitDebuff('party'..i, 'Mauvais sort')"..
		"\nthen print(UnitName('party'..i)..' est affecté!')"..
		"\nend end@@@"..
		"\n\nCe module analyse les chaînes, donc essayez de faire suivre strictement la syntaxe à votre code, sinon il pourrait ne pas fonctionner."
L["Highlights auras."] = "Met en surbrillance les auras."
L["E.g. 42292"] = "Par exemple, 42292"
L["Aplies highlights to all auras passing the selected filter."] = "Met en surbrillance toutes les auras passant le filtre sélectionné."
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
L["Quest Items and Money"] = "Objets de quête et argent"
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
L["Section Length"] = "Longueur de la section"
L["Select Section"] = "Sélectionner la section"
L["Section Priority"] = "Priorité de la section"
L["Section Spacing"] = "Espacement des sections"
L["Collection Method"] = "Méthode de collecte"
L["Sorting Method"] = "Méthode de tri"
L["Ignore Item (by ID)"] = "Ignorer l'objet (par ID)"
L["Remove Ignored"] = "Supprimer les ignorés"
L["Minimize"] = "Réduire"
L["Line Color"] = "Couleur de ligne"
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
L["Add Spell (by ID)"] = "Ajouter un Sort (par ID)"
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
L["Hold this while using /addOccupation command to clear the list of the current target/mouseover occupation.\nDon't forget to unbind the modifier+key bind!"] =
	"Maintenez ceci tout en utilisant la commande /addOccupation pour effacer la liste de l'occupation actuelle de la cible/survol.\nN'oubliez pas de délier la combinaison modificateur+touche !"
L["Color based on reaction type."] = "Couleur basée sur le type de réaction."
L["Nameplates"] = "Barres d'informations"
L["Unitframes"] = "Cadres d'unité"
L["An icon similar to the minimap search.\n\nTooltip scanning, might not be precise.\n\nFor consistency reasons, no keywards are added by defult, use /addOccupation command to mark the appropriate ones yourself (only need to do it once per unique occupation text)."] =
	"Une icône similaire à la recherche sur la minicarte.\n\nAnalyse des infobulles, peut ne pas être précise.\n\nPour des raisons de cohérence, aucun mot-clé n'est ajouté par défaut, utilisez la commande /addOccupation pour marquer vous-même les appropriés (à faire une seule fois par texte d'occupation unique)."
L["Displays player guild text."] = "Affiche le texte de guilde du joueur."
L["Displays NPC occupation text."] = "Affiche le texte d'occupation du PNJ."
L["Strata"] = "Strate"
L["Mark"] = "Marquer"
L["Mark the target/mouseover plate."] = "Marque la barre d'informations de la cible/survol."
L["Unmark"] = "Démarquer"
L["Unmark the target/mouseover plate."] = "Démarque la barre d'informations de la cible/survol."
L["FRIENDLY_PLAYER"] = "Joueur allié"
L["FRIENDLY_NPC"] = "PNJ allié"
L["ENEMY_PLAYER"] = "Joueur ennemi"
L["ENEMY_NPC"] = "PNJ ennemi"
L["Handles positioning and color."] = "Gère le positionnement et la couleur."
L["Selected Type"] = "Type sélectionné"
L["Reaction based coloring for non-cached characters."] = "Coloration basée sur la réaction pour les personnages non mis en cache."
L["Apply Custom Color"] = "Appliquer une couleur personnalisée"
L["Class Color"] = "Couleur de classe"
L["Use class colors."] = "Utiliser les couleurs de classe."
L["Unmark All"] = "Tout démarquer"
L["Unmark all plates."] = "Démarque toutes les barres d'informations."
L["Usage: '/qmark' macro bound to a key of your choice.\n\nDon't forget to also unbind your modifier keybinds!"] =
	"Utilisation : macro '/qmark' liée à une touche de votre choix.\n\nN'oubliez pas de délier également vos raccourcis de modificateur !"
L["Use Backdrop"] = "Utiliser l'arrière-plan"
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
		"Utilisation :\n%%d=%%s\n\n%%d - index de la liste ci-dessous\n%%s - mots-clés à rechercher\n\nIndices des icônes :"..
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
			"\n\n\nÉgalement disponible en tant que commande '/addOccupation %%d' où %%d est un indice d'icône facultatif."..
			"Si aucun indice n'est fourni, cette commande parcourra toutes les icônes disponibles. Fonctionne sur TARGET ou MOUSEOVER, en priorisant ce dernier."
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
L["Colors (School)"] = "Couleurs (École)"
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
L["Color enemy npc icon based on the unit type."] = "Colorer l'icône du PNJ ennemi en fonction du type d'unité."
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
L["No Cooldown Numbers"] = "Pas de Nombres de Temps de Recharge"
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
L["Toggle color flash for the current tab."] = "Basculer le flash de couleur pour l'onglet actuel."
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
L["Copies color of the selected bar."] = "Copie la couleur de la barre sélectionnée."
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
		"Exemple d'utilisation :"..
			"\n\nif UnitBuff('player', 'Stealth') or @@[player, Power, 3]@@ then"..
			"\nlocal r, g, b = ElvUF_Target.Health:GetStatusBarColor() return true, {mR = r, mG = g, mB = b} end"..
			"\nif UnitIsUnit(@unit, 'target') then return true end"..
			"\n\n@@[raid, Health, 2, >5]@@ - renvoie vrai/faux selon que l'onglet en question (dans l'exemple ci-dessus : 'player' - unité cible ; 'Power' - barre d'état cible ; '3' - onglet cible) est actif ou non (la mention de la même unité/groupe est désactivée ; n'est pas récursif)"..
			"\n(>/>=/<=/</~= num) - (optionnel, unités de groupe uniquement) correspond à un nombre particulier de cadres déclenchés dans le groupe (plus de 5 dans l'exemple ci-dessus)"..
			"\n\n'return {bR=1,f=false}' - vous pouvez colorer dynamiquement les cadres en renvoyant les couleurs dans un format de table :"..
			"\n  pour appliquer à la barre d'état, attribuez vos valeurs rvb à mR, mG et mB respectivement"..
			"\n  pour appliquer la lueur - à gR, gG, gB, gA (alpha)"..
			"\n  pour les bordures - bR, bG, bB"..
			"\n  et pour le flash - fR, fG, fB, fA"..
			"\n  pour empêcher le style des éléments, renvoyez {m = false, g = false, b = false, f = false}"..
			"\n\nN'hésitez pas à utiliser '@unit' pour enregistrer l'unité actuelle comme ceci : UnitBuff(@unit, 'player')."..
			"\n\nCe module analyse les chaînes de caractères, alors essayez de faire suivre strictement la syntaxe à votre code, sinon il pourrait ne pas fonctionner."
L["Unless holding a modifier, hovering units, items, and spells draws no tooltip.\nModifies cursor tooltips only."] = "À moins de maintenir un modificateur, survoler des unités, objets et sorts n'affiche aucun tooltip.\nModifie uniquement les tooltips du curseur."
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
