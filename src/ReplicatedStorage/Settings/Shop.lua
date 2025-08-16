local Items = 
{
    -- 재료
    Resources = {
        ["Stone Ore"] = {
            Price = 100,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Common",
            Description = "A basic pickaxe for mining ores.",
        },
        ["Iron Ore"] = {
            Price = 500,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Uncommon",
            Description = "An iron ore for crafting stronger tools.",
        },
        ["Gold Ore"] = {
            Price = 1000,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Rare",
            Description = "A gold ore for crafting high-value items.",
        },
        ["Diamond Ore"] = {
            Price = 5000,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Epic",
            Description = "A diamond ore for crafting the best tools.",
        },
       

    },
    -- 레이더
    Radar = {
        ["Basic Radar"] = {
            Price = 1000,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Common",
            Description = "A basic radar for detecting nearby ores. (5 uses)",
        },
        ["Advanced Radar"] = {
            Price = 5000,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Uncommon",
            Description = "An advanced radar with better detection range. (5 uses)",
        },
        ["Elite Radar"] = {
            Price = 10000,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Rare",
            Description = "An elite radar with the best detection capabilities. (5 uses)",
        },

        ["Pro Radar"] = {
            Price = 10000,
            StockAmount = { min = 10, max = 20 },
            Rarity = "Super Rare",
            Description = "An elite radar with the best detection capabilities. (5 uses)",
        },
    },
}
return Items