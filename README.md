ElvUI Plugin: ElvUI_Extras

If you're using https://github.com/FrostAtom/awesome_wotlk, make sure to replace your existing AwesomeWotlkLib.dll file with the one provided in the Optionals folder (a small fix for nameplates changing owners silently).

What's inside:
```
[General]:
	(Bags) - section-based container akin to AdiBags;
		 processing spell click-button popup;
		 auto-splitting and auto-stacking;
	(Chat) - flexible search and filter utilities;
		 compact chat condensing tabs functionality into a single button;
		 editbox position and size;
	(CustomCommands) - fairly basic event and onupdate script handlers;
	(MoversPlus) - anchoring options for the frame movers;
	(QuestBar) - self-explanatory;
	(Misc) - item icons for the chat;
		 global shadow for all of the skinned frames:
		 combat state alerts;
		 arbitrary tooltip notes for most of the in-game tooltips;
		 internal cds at trinket tooltips;
[Blizzard]:
	(Automation) - auto-gossip;
		       auto-fill "DELETE";
		       auto-confirm the rolls;
		       auto-pickup;
		       auto-accept quests;
		       auto-purchase;
	(LootStyle) - /lootinfo slash command displaying recent lootings;
		      restyled lootbars;
		      styled player names and rolls;
		      styled loot messages;
	(Misc) - letterbox;
		 held currency amount next to the prices;
		 no cursor tooltips unless holding a modifier;
		 minimap pings player names;
		 red text errors hiding (no mana, etc.);
[Nameplates]:
	Integrated https://github.com/FrostAtom/awesome_wotlk
	
	(Auras) - flexible aura highlighting;
		  fade-out animations;
		  no fill textures;
		  no coloring the aura borders;
		  centered auras (that is, growing side-wise);
	(Classification) - configurable class and classification textures;
	(Cooldowns) - icicle and alike;
	(GuildsTitles) - self-explanatory;
			 occupation icons for any npc;
	(NameLevel) - color and positioning for the name and level texts;
	(QuestIcons) - self-explanatory;
	(StyleFilter) - filter linking, arbitrary icons;
[Unitframes]:
	(AuraBars) - texts, icon;
	(Auras) - flexible aura highlighting;
		  click-cancel;
		  saturated debuffs at arenas;
		  no borders;
		  centered auras;
	(Classification) - same as above;
	(ColorFilter) - flexible coloring style filter;
	(Cooldowns) - same as above;
	(DRTracker) - self-explanatory;
	(FCF, floating combat feedback) - frame-bound combat texts;
	(Misc) - 'detach power' for group units;
		 length-based name auto-shortening;
```

Feel free to delete any module.lua you don't feel like using to cut some milliseconds off of the loading time.
