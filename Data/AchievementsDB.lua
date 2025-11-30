local addonName, TC = ...

TC.AchievementsDB = {
    
    -- ============================================================
    -- CATEGORY: ELITE (The Proving Grounds)
    -- ============================================================
    
    -- ALLIANCE
    {
        achId = "Hogger", title = "Scourge of Elwynn", category = "ELITE", levelCap = 12, 
        description = "Slay the Elite Gnoll Warlord Hogger",
        icon = 134163, rewardTokens = 1, requiredQuestId = 176, faction = "Alliance", zone = "Elwynn Forest"
    },
    {
        achId = "Vagash", title = "Snowblind Terror", category = "ELITE", levelCap = 11,
        description = "Hunt down the Elite Yeti Vagash",
        icon = 132189, rewardTokens = 1, requiredQuestId = 314, faction = "Alliance", zone = "Dun Morogh"
    },
    {
        achId = "LordMelenas", title = "Corruptor of the Woods", category = "ELITE", levelCap = 10,
        description = "Defeat the Satyr Lord Melenas",
        icon = 135934, rewardTokens = 1, requiredQuestId = 2039, faction = "Alliance", zone = "Teldrassil"
    },
    
    -- HORDE
    {
        achId = "Zalazane", title = "Voodoo Master", category = "ELITE", levelCap = 12,
        description = "Bring the head of Zalazane from the Echo Isles",
        icon = 132090, rewardTokens = 1, requiredQuestId = 826, faction = "Horde", zone = "Durotar"
    },
    {
        achId = "Gazzuz", title = "Shadows of Skull Rock", category = "ELITE", levelCap = 14,
        description = "Defeat the Warlock Gazz'uz and recover the Eye",
        icon = 134085, rewardTokens = 1, requiredQuestId = 832, faction = "Horde", zone = "Durotar"
    },
    {
        achId = "Dargol", title = "Restless Bones", category = "ELITE", levelCap = 12,
        description = "Kill Captain Dargol in the Agamand Crypts",
        icon = 236458, rewardTokens = 1, requiredQuestId = 408, faction = "Horde", zone = "Tirisfal"
    },
    
    -- NEUTRAL / HIGH LEVEL ELITES
    {
        achId = "Nesingwary", title = "The Apex Predator", category = "ELITE", levelCap = 43,
        description = "Hunt down King Bangalash in Stranglethorn",
        icon = 132202, rewardTokens = 1, requiredQuestId = 208, faction = "Both", zone = "Stranglethorn"
    },

    -- ============================================================
    -- CATEGORY: DUNGEON (Instanzen)
    -- ============================================================

    -- PHASE 1
    {
        achId = "Deadmines", title = "Brotherhood's Fall", category = "DUNGEON", levelCap = 24,
        description = "Defeat Edwin VanCleef in the Deadmines",
        icon = 136120, rewardTokens = 1, 
        targetNpcId = 639, -- Kill ID (funktioniert für Ally & Horde)
        faction = "Both", 
        zone = "Westfall"
    },
    {
        achId = "RFC", title = "Beneath the City", category = "DUNGEON", levelCap = 18,
        description = "Slay Taragaman the Hungerer in Ragefire Chasm",
        icon = 132327, rewardTokens = 1, requiredQuestId = 5728, faction = "Horde", zone = "Orgrimmar"
    },
    {
        achId = "WC", title = "Waking the Dreamer", category = "DUNGEON", levelCap = 25,
        description = "Clear the Wailing Caverns (Leaders of the Fang)",
        icon = 132387, rewardTokens = 1, requiredQuestId = 868, faction = "Horde", zone = "Barrens"
    },

    -- PHASE 2
    {
        achId = "Stockades", title = "Prison Break Suppressed", category = "DUNGEON", levelCap = 30,
        description = "Quell the riots in The Stockade (Bazil Thredd)",
        icon = 132094, rewardTokens = 1, requiredQuestId = 168, faction = "Alliance", zone = "Stormwind"
    },
    {
        achId = "SFK", title = "Curse of the Worgen", category = "DUNGEON", levelCap = 30,
        description = "Slay Archmage Arugal in Shadowfang Keep",
        icon = 132096, rewardTokens = 1, requiredQuestId = 1014, faction = "Horde", zone = "Silverpine"
    },
    {
        achId = "BFD", title = "Secrets of the Deep", category = "DUNGEON", levelCap = 32,
        description = "Defeat Aku'mai in Blackfathom Deeps",
        icon = 135146, rewardTokens = 1, requiredQuestId = 1275, faction = "Both", zone = "Ashenvale"
    },
    {
        achId = "Gnomeregan", title = "Reclaiming the City", category = "DUNGEON", levelCap = 40,
        description = "Defeat Mekgineer Thermaplugg",
        icon = 133337, rewardTokens = 1, requiredQuestId = 2945, faction = "Alliance", zone = "Dun Morogh"
    },
    {
        achId = "RigWars", title = "Rig Wars Victor", category = "DUNGEON", levelCap = 40,
        description = "Defeat Mekgineer Thermaplugg",
        icon = 133337, rewardTokens = 1, requiredQuestId = 2841, faction = "Horde", zone = "Dun Morogh"
    },
    {
        achId = "SM_Whitemane", title = "Crimson Crusade", category = "DUNGEON", levelCap = 45,
        description = "Defeat High Inquisitor Whitemane",
        icon = 132360, rewardTokens = 1, requiredQuestId = 1053, faction = "Alliance", zone = "Tirisfal"
    },
    {
        achId = "SM_Whitemane_H", title = "End of the Crusade", category = "DUNGEON", levelCap = 45,
        description = "Defeat High Inquisitor Whitemane",
        icon = 132360, rewardTokens = 1, requiredQuestId = 1048, faction = "Horde", zone = "Tirisfal"
    },
    {
        achId = "RFD", title = "Lich Slayer", category = "DUNGEON", levelCap = 46,
        description = "Defeat Amnennar the Coldbringer",
        icon = 132352, rewardTokens = 1, requiredQuestId = 1107, faction = "Alliance", zone = "Barrens"
    },
    {
        achId = "RFD_H", title = "Coldbringer's Demise", category = "DUNGEON", levelCap = 46,
        description = "Defeat Amnennar the Coldbringer",
        icon = 132352, rewardTokens = 1, requiredQuestId = 1103, faction = "Horde", zone = "Barrens"
    },

    -- PHASE 3
    {
        achId = "Uldaman", title = "Titan's Legacy", category = "DUNGEON", levelCap = 50,
        description = "Defeat Archaedas in Uldaman",
        icon = 133343, rewardTokens = 1, requiredQuestId = 2278, faction = "Alliance", zone = "Badlands"
    },
    {
        achId = "Uldaman_H", title = "Secrets of the Earth", category = "DUNGEON", levelCap = 50,
        description = "Defeat Archaedas in Uldaman",
        icon = 133343, rewardTokens = 1, requiredQuestId = 2279, faction = "Horde", zone = "Badlands"
    },
    {
        achId = "ZF_Mallet", title = "Hydromancer", category = "DUNGEON", levelCap = 52,
        description = "Summon and defeat Gahz'rilla in Zul'Farrak",
        icon = 132278, rewardTokens = 1, requiredQuestId = 2770, faction = "Both", zone = "Tanaris"
    },
    {
        achId = "Maraudon", title = "Corruption Cleansed", category = "DUNGEON", levelCap = 55,
        description = "Defeat Princess Theradras in Maraudon",
        icon = 135163, rewardTokens = 1, requiredQuestId = 7046, faction = "Alliance", zone = "Desolace"
    },
    {
        achId = "Maraudon_H", title = "Corruption Cleansed", category = "DUNGEON", levelCap = 55,
        description = "Defeat Princess Theradras in Maraudon",
        icon = 135163, rewardTokens = 1, requiredQuestId = 7044, faction = "Horde", zone = "Desolace"
    },
    {
        achId = "SunkenTemple", title = "Dragon of Nightmares", category = "DUNGEON", levelCap = 58,
        description = "Defeat Eranikus in the Sunken Temple",
        icon = 136107, rewardTokens = 1, requiredQuestId = 1446, faction = "Alliance", zone = "Swamp of Sorrows"
    },
    {
        achId = "SunkenTemple_H", title = "Dragon of Nightmares", category = "DUNGEON", levelCap = 58,
        description = "Defeat Eranikus in the Sunken Temple",
        icon = 136107, rewardTokens = 1, requiredQuestId = 1445, faction = "Horde", zone = "Swamp of Sorrows"
    },

    -- PHASE 4 (ENDGAME)
    {
        achId = "BRD_Emp", title = "Ruler of Blackrock", category = "DUNGEON", levelCap = 60,
        description = "Kill Emperor Dagran Thaurissan",
        icon = 132093, rewardTokens = 1, requiredQuestId = 4322, faction = "Alliance", zone = "Blackrock Mountain"
    },
    {
        achId = "BRD_Emp_H", title = "Ruler of Blackrock", category = "DUNGEON", levelCap = 60,
        description = "Kill Emperor Dagran Thaurissan",
        icon = 132093, rewardTokens = 1, requiredQuestId = 4123, faction = "Horde", zone = "Blackrock Mountain"
    },
    {
        achId = "Strat_Live", title = "The Scarlet Crusade Falls", category = "DUNGEON", levelCap = 60,
        description = "Defeat Grand Crusader Dathrohan (Balnazzar)",
        icon = 136050, rewardTokens = 1, requiredQuestId = 5264, faction = "Both", zone = "Plaguelands"
    },
    {
        achId = "Strat_Undead", title = "The Baron's End", category = "DUNGEON", levelCap = 60,
        description = "Slay Baron Rivendare in Stratholme",
        icon = 135923, rewardTokens = 1, requiredQuestId = 5211, faction = "Both", zone = "Plaguelands"
    },
    {
        achId = "Scholo", title = "School's Out", category = "DUNGEON", levelCap = 60,
        description = "Defeat Darkmaster Gandling in Scholomance",
        icon = 136189, rewardTokens = 1, requiredQuestId = 5384, faction = "Alliance", zone = "Plaguelands"
    },
    {
        achId = "Scholo_H", title = "School's Out", category = "DUNGEON", levelCap = 60,
        description = "Defeat Darkmaster Gandling in Scholomance",
        icon = 136189, rewardTokens = 1, requiredQuestId = 5382, faction = "Horde", zone = "Plaguelands"
    },
    {
        achId = "UBRS", title = "Lord of the Spire", category = "DUNGEON", levelCap = 60,
        description = "Slay General Drakkisath (10-Man Raid)",
        icon = 132266, rewardTokens = 1, requiredQuestId = 5088, faction = "Both", zone = "Blackrock Mountain"
    },

    -- ============================================================
    -- CATEGORY: SLAYER (Kill Counts)
    -- ============================================================
    {
        achId = "SlayerMurloc", title = "Murloc Tide", category = "SLAYER",
        description = "Kill 50 Murlocs (XP yielding)",
        icon = 132205, rewardTokens = 1, 
        type = "SLAYER", slayerName = "Murloc", slayerCount = 50,
        faction = "Both", zone = "Any"
    },
    {
        achId = "SlayerGnoll", title = "Gnoll Basher", category = "SLAYER",
        description = "Kill 30 Gnolls (XP yielding)",
        icon = 132187, rewardTokens = 1,
        type = "SLAYER", slayerName = "Gnoll", slayerCount = 30,
        faction = "Both", zone = "Any"
    },
    {
        achId = "SlayerUndead", title = "The Walking Dead", category = "SLAYER",
        description = "Put 50 Undead to rest (XP yielding)",
        icon = 236458, rewardTokens = 1,
        type = "SLAYER", slayerCreatureType = "Undead", slayerCount = 50,
        faction = "Both", zone = "Any"
    },
    {
        achId = "SlayerBeast", title = "Big Game Hunter", category = "SLAYER",
        description = "Hunt 100 Beasts (XP yielding)",
        icon = 132189, rewardTokens = 1,
        type = "SLAYER", slayerCreatureType = "Beast", slayerCount = 100,
        faction = "Both", zone = "Any"
    },

    -- ============================================================
    -- CATEGORY: MISC (Challenges & Survival)
    -- ============================================================
    {
        achId = "Level10", title = "Survivor: Level 10", category = "MISC", 
        description = "Reach Level 10 without dying", icon = 136042, 
        rewardTokens = 1, customCheck = function() return UnitLevel("player") >= 10 end, faction = "Both", zone = "Any"
    },
    {
        achId = "Level20", title = "Survivor: Level 20", category = "MISC",
        description = "Reach Level 20 without dying", icon = 136042, 
        rewardTokens = 1, customCheck = function() return UnitLevel("player") >= 20 end, faction = "Both", zone = "Any"
    },
    {
        achId = "Level30", title = "Survivor: Level 30", category = "MISC",
        description = "Reach Level 30 without dying", icon = 136042, 
        rewardTokens = 1, customCheck = function() return UnitLevel("player") >= 30 end, faction = "Both", zone = "Any"
    },
    {
        achId = "Level40", title = "Survivor: Level 40", category = "MISC",
        description = "Reach Level 40 without dying", icon = 136042, 
        rewardTokens = 1, customCheck = function() return UnitLevel("player") >= 40 end, faction = "Both", zone = "Any"
    },
    {
        achId = "Level50", title = "Survivor: Level 50", category = "MISC",
        description = "Reach Level 50 without dying", icon = 136042, 
        rewardTokens = 1, customCheck = function() return UnitLevel("player") >= 50 end, faction = "Both", zone = "Any"
    },
    {
        achId = "Level60", title = "Immortal Legend", category = "MISC", levelCap = nil,
        description = "Reach Level 60! The ultimate challenge.", icon = 135943, 
        rewardTokens = 1, customCheck = function() return UnitLevel("player") >= 60 end, faction = "Both", zone = "Any"
    }
}