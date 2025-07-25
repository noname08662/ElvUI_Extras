ElvUI Plugin: ElvUI_Extras

If you're using [Awesome WotLK](https://github.com/FrostAtom/awesome_wotlk), make sure to replace your existing AwesomeWotlkLib.dll file with either the one provided in the Optionals folder or the one from [this fork](https://github.com/someweirdhuman/awesome_wotlk), which has all the changes included (a small fix for nameplates changing owners silently).

[ElvUI 6.09](https://github.com/ElvUI-WotLK/ElvUI) version: [download plugin](https://github.com/noname08662/ElvUI_Extras/releases/download/1.10/ElvUI_Extras.ElvUI.6.09.zip)<br>
[ElvUI 7.XX](https://github.com/Crumdidlyumshis/ElvUI) version: [download plugin](https://github.com/noname08662/ElvUI_Extras/releases/download/1.10/ElvUI_Extras.ElvUI.7.zip)

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
		 rdf queue tracker;
		 tier information as greentext at item tooltips;
[Blizzard]:
	(Automation) - auto-gossip;
		       auto-fill "DELETE";
		       auto-confirm the rolls;
		       auto-pickup;
		       auto-accept quests;
		       auto-purchase and auto-sell;
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
		  aura sorting options;
	(Classification) - configurable class and classification textures;
	(Cooldowns) - icicle and alike;
	(GuildsTitles) - self-explanatory;
			 occupation icons for any npc;
	(NameLevel) - color and positioning for the name and level texts;
	(QuestIcons) - self-explanatory;
	(StyleFilter) - filter linking, arbitrary icons, additional triggers (Lua);
	(Targets) - target names with optional highlights;
	(DepthOfField) - pseudo DoF alpha fading effect;
	(Misc) - healer icon size and positioning;
		 zone-based health bar visibility;
[Unitframes]:
	(AuraBars) - texts, icon;
	(Auras) - flexible aura highlighting;
		  click-cancel;
		  saturated debuffs at arenas;
		  no borders;
		  centered auras;
		  filters order based aura sorting;
	(Classification) - same as above;
	(ColorFilter) - flexible coloring style filter;
	(Cooldowns) - same as above;
	(DRTracker) - self-explanatory;
	(FCF, floating combat feedback) - frame-bound combat texts;
	(Misc) - 'detach power' for group units;
		 length-based name auto-shortening;
```

Feel free to delete any module.lua you don't feel like using to cut some milliseconds off of the loading time.
