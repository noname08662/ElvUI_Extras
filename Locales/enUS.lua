local E = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local L = E.Libs.ACL:NewLocale("ElvUI", "enUS", true)

L["Hits the 'Confirm' button automatically."] = true
L["Picks up items and money automatically."] = true
L["Automatically fills the 'DELETE' field."] = true
L["Selects the first gossip option if it's the only one available unless holding a modifier.\nBe careful with important event triggers; there is no fail-safe mechanism."] = true
L["Accepts and turns in quests automatically while holding a modifier."] = true
L["Loot info wiped."] = true
L["/lootinfo slash command to get a quick rundown of the recent lootings."] = true
L["Colors the names of online friends and guildmates in some messages and styles the rolls.\nAlready handled chat bubbles will not get styled before you /reload."] = true
L["Colors loot roll messages for you and other players."] = true
L["Loot rolls icon size."] = true
L["Restyles the loot bars.\nRequires 'Loot Roll' (General -> BlizzUI Improvements -> Loot Roll) to be enabled (toggling this module enables it automatically)."] = true
L["Displays the name of the player pinging the minimap."] = true
L["Displays the currently held currency amount next to the item prices."] = true
L["Narrows down the World(..Frame)."] = true
L["'Out of mana', 'Ability is not ready yet', etc."] = true
L["Re-enable quest updates."] = true
L["Tooltips will not display when hovering over units, items, and spells unless a modifier is held.\nModifies cursor tooltips only."] = true
L["255, 210, 0 - Blizzard's yellow."] = true
L["Text to display upon entering combat."] = true
L["Text to display upon leaving combat."] = true
L["REQUIRES RELOAD."] = true
L["Icon to the left or right of the item link."] = true
L["The size of the icon in the chat frame."] = true
L["Adds shadows to all of the frames.\nDoes nothing unless you replace your ElvUI/Core/Toolkit.lua with the relevant file from the Optionals folder of this plugin."] = true
L["Combat state notification alerts."] = true
L["Custom editbox position and size."] = true
L["Usage:"..
	"\n/tnote list - returns all existing notes"..
	"\n/tnote wipe - clears all existing notes"..
	"\n/tnote 1 icon Interface\\Path\\ToYourIcon - same as set (except for the lua part)"..
	"\n/tnote 1 get - same as set, returns existing notes"..
	"\n/tnote 1 set YourNoteHere - adds a note to the designated index from the list "..
	"or to a currently shown tooltip text if the second argument (1 in this case) is omitted, "..
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
	"\n  (1-percentage)*255, percentage*255)"] = true
L["Adds an icon next to chat hyperlinks."] = true
L["Toggles the display of the actionbar's backdrop."] = true
L["The frame will not be displayed unless hovered over."] = true
L["Inherit the global fade; mousing over, targetting, setting focus, losing health, entering combat will set the remove transparency. Otherwise it will use the transparency level in the general actionbar settings for global fade alpha."] = true
L["The first button anchors itself to this point on the bar."] = true
L["Right-click the item while holding the modifier to blacklist it. Blacklisted items will not show up on the bar.\nUse /questbarRestore to purge the blacklist."] = true
L["The number of buttons to display."] = true
L["The number of buttons to display per row."] = true
L["The size of the action buttons."] = true
L["Spacing between the buttons."] = true
L["Spacing between the backdrop and the buttons."] = true
L["Multiply the backdrop's height or width by this value. This is useful if you wish to have more than one bar behind a backdrop."] = true
L["This works like a macro; you can run different conditions to show or hide the action bar.\n Example: '[combat] showhide'"] = true
L["Adds anchoring options to the movers' nudges."] = true
L["Mod-clicking an item suggests a skill/item to process it."] = true
L["Holding %s while left-clicking a stack will split it in two; right-click instead to combine available copies.\n\nAlso modifies the SplitStackFrame to use editbox instead of arrows."] = true
L["Extends the bags functionality."] = true
L["Default method: type > inventory slot ID > item level > name."] = true
L["Listed ItemIDs will not get sorted."] = true
L["E.g. Interface\\Icons\\INV_Misc_QuestionMark"] = true
L["Invalid condition format: "] = true
L["The generated custom sorting method did not return a function."] = true
L["The loaded custom sorting method did not return a function."] = true
L["Item received: "] = true
L[" added."] = true
L[" removed."] = true
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
	"print('Item received: ' .. string)"] = true
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
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."] = true
L["Available Item Types"] = true
L["Lists all available item subtypes for each available item type."] = true
L["Holding this key while interacting with a merchant buys all items that pass the Auto Buy set method.\n"..
	"Hold the modifier key and click the buyout list entry to purchase a single item, regardless of the '@amount' rule."] = true
L["Default method: type > inventoryslotid > ilvl > name.\n\n"..
	"Accepts custom functions (bagID and slotID are available at the a/b.bagID/slotID).\n\n"..
	"function(a,b)\n"..
	"--your sorting logic here\n"..
	"end\n\n"..
	"Leave blank to go default."] = true
L["Event and OnUpdate handler."] = true
L["Minimal time gap between two consecutive executions."] = true
L["UNIT_AURA CHAT_MSG_WHISPER etc.\nONUPDATE - 'OnUpdate' script"] = true
L["UNIT_AURA CHAT_MSG_WHISPER etc."] = true
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
	"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."] = true
L["Highlights auras."] = true
L["E.g. 42292"] = true
L["Applies highlights to all auras passing the selected filter."] = true
L["Priority: spell, filter, curable/stealable."] = true
L["If toggled, the GLOBAL Spell or Filter entry values would be used."] = true
L["Makes auras grow sideswise."] = true
L["Turns off texture fill."] = true
L["Makes auras flicker right before fading out."] = true
L["Disables border coloring."] = true
L["Confirm Rolls"] = true
L["Auto Pickup"] = true
L["Swift Buy"] = true
L["Buys out items automatically."] = true
L["Failsafe"] = true
L["Enables popup confirmation dialog."] = true
L["Add Set"] = true
L["Delete Set"] = true
L["Select Set"] = true
L["Auto Buy"] = true
L["Fill Delete"] = true
L["Gossip"] = true
L["Accept Quest"] = true
L["Loot Info"] = true
L["Styled Messages"] = true
L["Indicator Color"] = true
L["Select Status"] = true
L["Select Indicator"] = true
L["Styled Loot Messages"] = true
L["Icon Size"] = true
L["Loot Bars"] = true
L["Bar Height"] = true
L["Bar Width"] = true
L["Player Pings"] = true
L["Held Currency"] = true
L["LetterBox"] = true
L["Left"] = true
L["Right"] = true
L["Top"] = true
L["Bottom"] = true
L["Hide Errors"] = true
L["Show quest updates"] = true
L["Less Tooltips"] = true
L["Misc."] = true
L["Loot&Style"] = true
L["Automation"] = true
L["Bags"] = true
L["Easier Processing"] = true
L["Modifier"] = true
L["Split Stack"] = true
L["Bags Extended"] = true
L["Select Container Type"] = true
L["Settings"] = true
L["Add Section"] = true
L["Delete Section"] = true
L["Select Section"] = true
L["Section Priority"] = true
L["Section Spacing"] = true
L["Collection Method"] = true
L["Sorting Method"] = true
L["Ignore Item (by ID)"] = true
L["Remove Ignored"] = true
L["Title"] = true
L["Color"] = true
L["Attach to Icon"] = true
L["Text"] = true
L["Font Size"] = true
L["Font"] = true
L["Font Flags"] = true
L["Point"] = true
L["Relative Point"] = true
L["X Offset"] = true
L["Y Offset"] = true
L["Icon"] = true
L["Attach to Text"] = true
L["Texture"] = true
L["Size"] = true
L["Movers Plus"] = true
L["Custom Commands"] = true
L["Quest Bar"] = true
L["Backdrop"] = true
L["Show Empty Buttons"] = true
L["Mouse Over"] = true
L["Inherit Global Fade"] = true
L["Anchor Point"] = true
L["Modifier"] = true
L["Buttons"] = true
L["Buttons Per Row"] = true
L["Button Size"] = true
L["Button Spacing"] = true
L["Backdrop Spacing"] = true
L["Height Multiplier"] = true
L["Width Multiplier"] = true
L["Alpha"] = true
L["Visibility State"] = true
L["Enable Tab"] = true
L["Throttle Time"] = true
L["Select Tab"] = true
L["Select Event"] = true
L["Rename Tab"] = true
L["Add Tab"] = true
L["Delete Tab"] = true
L["Open Edit Frame"] = true
L["Events"] = true
L["Commands to execute"] = true
L["Sub-Section"] = true
L["Select"] = true
L["Icon Orientation"] = true
L["Icon Size"] = true
L["Height Offset"] = true
L["Width Offset"] = true
L["Text Color"] = true
L["Entering combat"] = true
L["Leaving combat"] = true
L["Font"] = true
L["Font Outline"] = true
L["Font Size"] = true
L["Texture Width"] = true
L["Texture Height"] = true
L["Custom Texture"] = true
L["ItemIcons"] = true
L["TooltipNotes"] = true
L["ChatEditBox"] = true
L["EnterCombatAlert"] = true
L["GlobalShadow"] = true
L["Any"] = true
L["Guildmate"] = true
L["Friend"] = true
L["Self"] = true
L["New Tab"] = true
L["None"] = true
L["Version: "] = true
L["Color A"] = true
L["Chat messages, etc."] = true
L["Color B"] = true
L["Plugin Color"] = true
L["Icons Browser"] = true
L["Get https://www.wowinterface.com/downloads/info19844-CleanIcons-Thin.html for cleaner, cropped icons."] = true
L["Add Texture"] = true
L["Adds textures to General texture list.\nE.g. Interface\\Icons\\INV_Misc_QuestionMark"] = true
L["Remove Texture"] = true
L["Highlights"] = true
L["Select Type"] = true
L["Highlights Settings"] = true
L["Add Filter"] = true
L["Remove Selected"] = true
L["Select Spell or Filter"] = true
L["Use Global Settings"] = true
L["Selected Spell or Filter Values"] = true
L["Enable Shadow"] = true
L["Shadow Color"] = true
L["Enable Border"] = true
L["Border Color"] = true
L["Centered Auras"] = true
L["Cooldown Disable"] = true
L["Animate Fade-Out"] = true
L["Type Borders"] = true
L[" filter added."] = true
L[" filter removed."] = true
L["GLOBAL"] = true
L["CURABLE"] = true
L["STEALABLE"] = true
L["--Filters--"] = true
L["--Spells--"] = true
L["FRIENDLY"] = true
L["ENEMY"] = true
L["AuraBars"] = true
L["Auras"] = true
L["ClassificationIndicator"] = true
L["ClassificationIcons"] = true
L["ColorFilter"] = true
L["Cooldowns"] = true
L["DRTracker"] = true
L["Guilds&Titles"] = true
L["Name&Level"] = true
L["QuestIcons"] = true
L["StyleFilter"] = true
L["Hover again to see the changes."] = true
L["Note set for "] = true
L["Note cleared for "] = true
L["No note to clear for "] = true
L["Added icon to the note for "] = true
L["Note icon cleared for "] = true
L["No note icon to clear for "] = true
L["Current note for "] = true
L["No note found for this tooltip."] = true
L["Notes: "] = true
L["No notes are set."] = true
L["No tooltip is currently shown or unsupported tooltip type."] = true
L["All notes have been cleared."] = true
L["Accept"] = true
L["Cancel"] = true
L["Purge Cache"] = true
L["Guilds"] = true
L["Separator"] = true
L["Level"] = true
L["Visibility State"] = true
L["City (Resting)"] = true
L["PvP"] = true
L["Arena"] = true
L["Party"] = true
L["Raid"] = true
L["Colors"] = true
L["Guild"] = true
L["All"] = true
L["Occupation Icon"] = true
L["OccupationIcon"] = true
L["Size"] = true
L["Anchor"] = true
L["/addOccupation"] = true
L["Remove occupation"] = true
L["Modifier"] = true
L["Add Texture Path"] = true
L["Remove Selected Texture"] = true
L["Titles"] = true
L["Reaction Color"] = true
L["Color based on reaction type."] = true
L["Nameplates"] = true
L["Unitframes"] = true
L["An icon similar to the minimap search."] = true
L["Displays player guild text."] = true
L["Displays NPC occupation text."] = true
L["Strata"] = true
L["Selected Type"] = true
L["Reaction based coloring for non-cached characters."] = true
L["Apply Custom Color"] = true
L["Class Color"] = true
L["Use class colors."] = true
L["Use Backdrop"] = true
L["Linked Style Filter Triggers"] = true
L["Select Link"] = true
L["New Link"] = true
L["Delete Link"] = true
L["Target Filter"] = true
L["Select a filter to trigger the styling."] = true
L["Apply Filter"] = true
L["Select a filter to style the frames not passing the target filter triggers."] = true
L["Cache purged."] = true
L["Test Mode"] = true
L["Draws player cooldowns."] = true
L["Show Everywhere"] = true
L["Show in Cities"] = true
L["Show in Battlegrounds"] = true
L["Show in Arenas"] = true
L["Show in Instances"] = true
L["Show in the World"] = true
L["Header"] = true
L["Icons"] = true
L["OnUpdate Throttle"] = true
L["Trinket First"] = true
L["Animate Fade Out"] = true
L["Border Color"] = true
L["Growth Direction"] = true
L["Sort Method"] = true
L["Icon Size"] = true
L["Icon Spacing"] = true
L["Per Row"] = true
L["Max Rows"] = true
L["CD Text"] = true
L["Show"] = true
L["Cooldown Fill"] = true
L["Reverse"] = true
L["Direction"] = true
L["Spells"] = true
L["Add Spell (by ID)"] = true
L["Remove Selected Spell"] = true
L["Select Spell"] = true
L["Shadow"] = true
L["Pet Ability"] = true
L["Shadow Size"] = true
L["Shadow Color"] = true
L["Sets update speed threshold."] = true
L["Makes PvP trinkets and human racial always get positioned first."] = true
L["Makes icons flash when the cooldown's about to end."] = true
L["Any value apart from black (0,0,0) would override borders by time left."] = true
L["Colors borders by time left."] = true
L["Format: 'spellID cooldown time', e.g. 42292 120"] = true
L["For the important stuff."] = true
L["Pet casts require some special treatment."] = true
L["Color by Type"] = true
L["Flip Icon"] = true
L["Texture List"] = true
L["Keep Icon"] = true
L["Texture"] = true
L["Texture Coordinates"] = true
L["Select Affiliation"] = true
L["Width"] = true
L["Height"] = true
L["Select Class"] = true
L["Points"] = true
L["Colors the icon based on the unit type."] = true
L["Flits the icon horizontally. Not compatible with Texture Coordinates."] = true
L["Keep the original icon texture."] = true
L["NPCs"] = true
L["Players"] = true
L["By duration, ascending."] = true
L["By duration, descending."] = true
L["By time used, ascending."] = true
L["By time used, descending."] = true
L["Additional settings for the Elite Icon."] = true
L["Player class icons."] = true
L["Class Icons"] = true
L["Vector Class Icons"] = true
L["Class Crests"] = true
L["DEATHKNIGHT"] = true
L["DRUID"] = true
L["HUNTER"] = true
L["MAGE"] = true
L["PALADIN"] = true
L["PRIEST"] = true
L["ROGUE"] = true
L["SHAMAN"] = true
L["WARLOCK"] = true
L["WARRIOR"] = true
L["Floating Combat Feedback"] = true
L["Select Unit"] = true
L["player"] = true
L["target"] = true
L["targettarget"] = true
L["targettargettarget"] = true
L["focus"] = true
L["focustarget"] = true
L["pet"] = true
L["pettarget"] = true
L["raid"] = true
L["raid40"] = true
L["raidpet"] = true
L["party"] = true
L["partypet"] = true
L["partytarget"] = true
L["boss"] = true
L["arena"] = true
L["assist"] = true
L["assisttarget"] = true
L["tank"] = true
L["tanktarget"] = true
L["Scroll Time"] = true
L["Event Settings"] = true
L["Event"] = true
L["Disable Event"] = true
L["School"] = true
L["Use School Colors"] = true
L["Colors"] = true
L["Color (School)"] = true
L["Animation Type"] = true
L["Custom Animation"] = true
L["Flag Settings"] = true
L["Flag"] = true
L["Font Size Multiplier"] = true
L["Animation by Flag"] = true
L["Icon Settings"] = true
L["Show Icon"] = true
L["Icon Position"] = true
L["Bounce"] = true
L["Blacklist"] = true
L["Appends floating combat feedback fontstrings to frames."] = true
L["There seems to be a font size limit?"] = true
L["Not every event is eligible for this. But some are."] = true
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"] = true
L["Toggle to have this section handle flag animations instead.\n\nNot every event has flags."] = true
L["Flip position left-right."] = true
L["Loaded custom animation did not return a function."] = true
L["Before Text"] = true
L["After Text"] = true
L["Remove Spell"] = true
L["Define your custom animation as a lua function.\n\nExample:\nfunction(self)"..
	"\nreturn self.x + self.xDirection * self.radius * (1 - m_cos(m_pi / 2 * self.progress)),"..
	"\nself.y + self.yDirection * self.radius * m_sin(m_pi / 2 * self.progress) end"] = true
L["ABSORB"] = true
L["BLOCK"] = true
L["CRITICAL"] = true
L["CRUSHING"] = true
L["GLANCING"] = true
L["RESIST"] = true
L["Diagonal"] = true
L["Fountain"] = true
L["Horizontal"] = true
L["Random"] = true
L["Static"] = true
L["Vertical"] = true
L["DEFLECT"] = true
L["DODGE"] = true
L["ENERGIZE"] = true
L["EVADE"] = true
L["HEAL"] = true
L["IMMUNE"] = true
L["INTERRUPT"] = true
L["MISS"] = true
L["PARRY"] = true
L["REFLECT"] = true
L["WOUND"] = true
L["Debuff applied/faded/refreshed"] = true
L["Buff applied/faded/refreshed"] = true
L["Physical"] = true
L["Holy"] = true
L["Fire"] = true
L["Nature"] = true
L["Frost"] = true
L["Shadow"] = true
L["Arcane"] = true
L["Astral"] = true
L["Chaos"] = true
L["Elemental"] = true
L["Magic"] = true
L["Plague"] = true
L["Radiant"] = true
L["Shadowflame"] = true
L["Shadowfrost"] = true
L["TOP"] = true
L["BOTTOM"] = true
L["Classic Style"] = true
L["If enabled, default cooldown style will be used."] = true
L["Classification Indicator"] = true
L["Copy Unit Settings"] = true
L["Enable Player Class Icons"] = true
L["Enable NPC Classification Icons"] = true
L["Type"] = true
L["Select unit type."] = true
L["World Boss"] = true
L["Elite"] = true
L["Rare"] = true
L["Rare Elite"] = true
L["Class Spec Icons"] = true
L["Classification Textures"] = true
L["Use Nameplates' Icons"] = true
L["Color enemy NPC icon based on the unit type."] = true
L["Strata and Level"] = true
L["Warrior"] = true
L["Warlock"] = true
L["Priest"] = true
L["Paladin"] = true
L["Druid"] = true
L["Rogue"] = true
L["Mage"] = true
L["Hunter"] = true
L["Shaman"] = true
L["Deathknight"] = true
L["Aura Bars"] = true
L["Adds extra configuration options for aura bars.\n\n For options like size and detachment, use ElvUI Aura Bars Movers!"] = true
L["Hide"] = true
L["Spell Name"] = true
L["Spell Time"] = true
L["Bounce Icon Points"] = true
L["Set icon to the opposite side of the bar each new bar."] = true
L["Flip Starting Position"] = true
L["0 to disable."] = true
L["Detach All"] = true
L["Detach Power"] = true
L["Detaches power for the currently selected group."] = true
L["Shortens names similarly to how they're shortened on nameplates. Set 'Text Position' in name configuration to LEFT."] = true
L["Anchor to Health"] = true
L["Adjusts the shortening based on the 'Health' text position."] = true
L["Name Auto-Shorten"] = true
L["Appends a diminishing returns tracker to frames."] = true
L["DR Time"] = true
L["DRtime controls how long it takes for the icons to reset. Several factors can affect how DR resets. If you are experiencing constant problems with DR reset accuracy, you can change this value."] = true
L["Test"] = true
L["Players Only"] = true
L["Ignore NPCs when setting up icons."] = true
L["Setup Categories"] = true
L["Disable Cooldown"] = true
L["Go to 'Cooldown Text' > 'Global' to configure."] = true
L["Color Borders"] = true
L["Spacing"] = true
L["DR Strength Indicator: Text"] = true
L["DR Strength Indicator: Box"] = true
L["Good"] = true
L["50% DR for hostiles, 100% DR for the player."] = true
L["Neutral"] = true
L["75% DR for all."] = true
L["Bad"] = true
L["100% DR for hostiles, 50% DR for the player."] = true
L["Category Border"] = true
L["Select Category"] = true
L["Categories"] = true
L["Add Category"] = true
L["Format: 'category spellID', e.g. fear 10890.\nList of all categories is available at the 'colors' section."] = true
L["Remove Category"] = true
L["Category \"%s\" already exists, updating icon."] = true
L["Category \"%s\" added with %s icon."] = true
L["Invalid category."] = true
L["Category \"%s\" removed."] = true
L["DetachPower"] = true
L["NameAutoShorten"] = true
L["Color Filter"] = true
L["Enables color filter for the selected unit."] = true
L["Toggle for the currently selected statusbar."] = true
L["Select Statusbar"] = true
L["Health"] = true
L["Castbar"] = true
L["Power"] = true
L["Tab Section"] = true
L["Toggle current tab."] = true
L["Tab Priority"] = true
L["On meeting multiple conditions, colors from the tab with the highest priority will be applied."] = true
L["Copy Tab"] = true
L["Select a tab to copy its settings onto the current tab."] = true
L["Flash"] = true
L["Speed"] = true
L["Glow"] = true
L["Determines which glow to apply when statusbars are not detached from frame."] = true
L["Priority"] = true
L["When handling castbar, also manage its icon."] = true
L["CastBar Icon Glow Color"] = true
L["CastBar Icon Glow Size"] = true
L["Borders"] = true
L["CastBar Icon Color"] = true
L["Toggle classbar borders."] = true
L["Toggle infopanel borders."] = true
L["ClassBar Color"] = true
L["Disabled unless classbar is enabled."] = true
L["InfoPanel Color"] = true
L["Disabled unless infopanel is enabled."] = true
L["ClassBar Adapt To"] = true
L["Copies the color of the selected bar."] = true
L["InfoPanel Adapt To"] = true
L["Override Mode"] = true
L["'None' - threat borders highlight will be prioritized over this one".. "\n'Threat' - this highlight will be prioritized."] = true
L["Threat"] = true
L["Determines which borders to apply when statusbars are not detached from frame."] = true
L["Bar-specific"] = true
L["Lua Section"] = true
L["Conditions"] = true
L["Font Settings"] = true
L["Player Only"] = true
L["Handle only player combat log events."] = true
L["Rotate Icon"] = true
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
	"\n\nThis module parses strings, so try to have your code follow the syntax strictly, or else it might not work."] = true
L["Pick a..."] = true
L["...mover to anchor to."] = true
L["...mover to anchor."] = true
L["Point:"] = true
L["Relative:"] = true
L["Open Editor"] = true
L["Dock all chat frames before enabling.\nShift-click the manager button to access tab settings."] = true
L["Mouseover"] = true
L["Manager button visibility."] = true
L["Manager point."] = true
L["Top Offset"] = true
L["Bottom Offset"] = true
L["Left Offset"] = true
L["Right Offset"] = true
L["Chat Search and Filter"] = true
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
	"\n\nChannel names and timestamps are not parsed."] = true
L["Search button visibility."] = true
L["Search button point."] = true
L["Config Tooltips"] = true
L["Highlight Color"] = true
L["Match highlight color."] = true
L["Filter Type"] = true
L["Rule Terms"] = true
L["Same logic as with the search."] = true
L["Select Chat Types"] = true
L["Say"] = true
L["Yell"] = true
L["Party"] = true
L["Raid"] = true
L["Guild"] = true
L["Battleground"] = true
L["Whisper"] = true
L["Channel"] = true
L["Other"] = true
L["Select Rule"] = true
L["Select Chat Frame"] = true
L["Add Rule"] = true
L["Delete Rule"] = true
L["Compact Chat"] = true
L["Move left"] = true
L["Move right"] = true
L["Mouseover: Left"] = true
L["Mouseover: Right"] = true
L["Automatic Onset"] = true
L["Scans tooltip texts and sets icons automatically."] = true
L["Icon (Default)"] = true
L["Icon (Kill)"] = true
L["Icon (Chat)"] = true
L["Icon (Item)"] = true
L["Show Text"] = true
L["Display progress status."] = true
L["Name"] = true
L["Frequent Updates"] = true
L["Events (optional)"] = true
L["InternalCooldowns"] = true
L["Displays internal cooldowns on trinket tooltips."] = true
L["Shortening X Offset"] = true
L["To Level"] = true
L["Names will be shortened based on level text position."] = true
L["Add Item (by ID)"] = true
L["Remove Item"] = true
L["Pre-Load"] = true
L["Executes commands during the addon's initialization process."] = true
L["Justify"] = true
L["Alt-Click: free bag slots, if possible."] = true
L["Click: toggle layout mode."] = true
L["Alt-Click: re-evaluate all items."] = true
L["Drag-and-Drop: evaluate and position the cursor item."] = true
L["Shift-Alt-Click: toggle these hints."] = true
L["Mouse-Wheel: navigate between special and normal bags."] = true
L["This button accepts cursor item drops."] = true
L["Setup Sections"] = true
L["Adds default sections set to the currently selected container."] = true
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
	"print('Item received: ' .. string)"] = true
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
	"(quality@4 and ilvl@>=219 and ilvl@<=245 and subtype@cloth and name@ofSanctification) or name@shadowmourne."] = true
L["PERIODIC"] = true
L["Hold this key while using /addOccupation command to clear the list of the current target/mouseover NPC."] = true
L["Use /addOccupation slash command while targeting/hovering over a NPC to add it to the list. Use again to cycle."] = true
L["Style Filter Icons"] = true
L["Custom icons for the style filter."] = true
L["Whitelist"] = true
L["X Direction"] = true
L["Y Direction"] = true
L["Create Icon"] = true
L["Delete Icon"] = true
L["0 to match frame width."] = true
L["Remove a NPC"] = true
L["Change a NPC's Occupation"] = true
L["...to the currently selected one."] = true
L["Select Occupation"] = true
L["Sell"] = true
L["Action Type"] = true
L["Style Filter Additional Triggers"] = true
L["Triggers"] = true
L["Example usage:"..
	"\n local frame, filter, trigger = ..."..
	"\n return frame.UnitName == 'Shrek'"..
	"\n         oder (frame.unit"..
	"\n             und UnitName(frame.unit) == 'Fiona')"] = true
L["Abbreviate Name"] = true
L["Highlight Self"] = true
L["Highlight Others"] = true
L["Self Inherit Name Color"] = true
L["Self Texture"] = true
L["Whitespace to disable, empty to default."] = true
L["Self Color"] = true
L["Self Scale"] = true
L["Others Inherit Name Color"] = true
L["Others Texture"] = true
L["Others Color"] = true
L["Others Scale"] = true
L["Targets"] = true
L["Random dungeon finder queue status frame."] = true
L["Queue Time"] = true
L["RDFQueueTracker"] = true
L["Abbreviate Numbers"] = true
L["DEFAULTS"] = true
L["INTERRUPT"] = true
L["CONTROL"] = true
L["Copy List"] = true
L["DepthOfField"] = true
L["Fades nameplates based on distance to screen center and cursor."] = true
L["Disable in Combat"] = true
L["Y Axis Pivot"] = true
L["Most opaque spot relative to screen center."] = true
L["Min Opacity"] = true
L["Falloff Rate"] = true
L["Mouse Falloff Rate"] = true
L["Base multiplier."] = true
L["Effect Curve"] = true
L["Mouse Effect Curve"] = true
L["Higher values result in steeper falloff."] = true
L["Enable Mouse"] = true
L["Also calculate cursor proximity."] = true
L["Ignore Styled"] = true
L["Ignore Target"] = true
L["Spells outside the selected whitelist filters will not be displayed."] = true
L["Enables tooltips to display which set an item belongs to."] = true
L["TierText"] = true
L["Select Item"] = true
L["Add Item (ID)"] = true
L["Item Text"] = true
L["Sort by Filter"] = true
L["Makes aura sorting abide filter priorities."] = true
L["Add Spell"] = true
L["Format: 'spellID cooldown time',\ne.g. 42292 120\nor\nSpellName 20"] = true
L["Fixes and Tweaks (requires reload)"] = true
L["Restore Raid Controls"] = true
L["Brings back 'Promote to Leader/Assist' controls in raid members' dropdown menus."] = true
L["World Map Quests"] = true
L["Allows Ctrl+Click on the world map quest list to open the quest log."] = true
L["Unit Hostility Status"] = true
L["Forces a nameplate update when a unit changes factions or hostility status (e.g. mind control)."] = true
L["Style Filter Name-Only"] = true
L["Fixes an issue where the style filter fails to update the nameplate on aura events after hiding its health."] = true
L["Use Default Handling"] = true
L["Show Group Members"] = true
L["Hide Group Members"] = true
L["Select 'Enemy Player' to configure."] = true
L["Capture Bar"] = true
L["Capture Bar Mover"] = true
L["Capture Bar Height"] = true
L["Also might fix capture bar related issues like progress marker not showing."] = true
L["Max Length"] = true
L["Mouseover: Channel Button"] = true
L["Mouseover: Copy Button"] = true
L["Copy button visibility."] = true
L["Plugin version mismatch! Please, download appropriate plugin version at"] = true
L["Questie Coherence"] = true
L["Makes, once again, itemID tooltip line added by ElvUI to get positioned last on unit and item tooltips."] = true
L["Attempts to extend font outline options across all of ElvUI."] = true
