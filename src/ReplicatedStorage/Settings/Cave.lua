local Cave = {
    DepthRegions = {
        Mouth = {

            SpawnCount = 70,
            Ores = {
                Stone = { chance = 0.5, max = 70 },
                Coal = { chance = 0.4, max = 30 },
                Copper = { chance = 0.1, max = 10 },
                Iron = { chance = 0.05, max = 5},
                Diamond = { chance = 0.04, max = 10},
                Emerald = { chance = 0.01, max = 1},
            }
        },
        Hollow = { -- 다이아몬드 곡괭이부터
            SpawnCount = 70,
             Ores = {
                Coal = { chance = 0.3, max = 70},
                Copper = { chance = 0.2, max = 70},
                Iron = { chance = 0.4, max = 70},
                Diamond = { chance = 0.1, max = 10},
                Emerald = { chance = 0.045, max = 10},
                Ruby = { chance = 0.04, max = 3},
                Thunder = { chance = 0.01, max = 3},
            }
        },
        Chamber = { -- 루비 곡괭이부터
            SpawnCount = 70,
            Ores = {
                Iron = { chance = 0.15, max = 40},
                Diamond = { chance = 0.4, max = 70},
                Emerald = { chance = 0.2, max = 30},
                Ruby = { chance = 0.2, max = 10},
                CarvedRuby = { chance = 0.04, max = 3},
                Thunder = { chance = 0.01, max = 1},
            }
        },
        Abyss = { -- 불 곡괭이부터
            SpawnCount = 70,
             Ores = {
                Diamond = { chance = 0.1, max = 70},
                Emerald = { chance = 0.3, max = 30},
                Ruby = { chance = 0.3, max = 40},
                CarvedRuby = { chance = 0.1, max = 3},
                Crystal = { chance = 0.01, max = 1},
                Volcanic = { chance = 0.04, max = 3 },
                Thunder = { chance = 0.15, max = 10 },
                
            }
        },
        Core = { -- 공허 곡괭이부터
            SpawnCount = 70,
            Ores = {
              
            }
        }
    }
    
}

return Cave

