local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local ToolData = require(ReplicatedStorage:WaitForChild("Settings").ToolData) :: ModuleScript
local RemoteEvents = ReplicatedStorage:WaitForChild("Events")

local stockMemoryKey = "GLOBAL_SHOP_STOCK"
local timeMemoryKey = "GLOBAL_RESTOCK_TIME"
local restockInterval = 300

local Service = {
	RestockInterval = restockInterval,
	LastRestockTime = os.time()
}

local function FormatTime(seconds)
	local minutes = math.floor(seconds / 60)
	local remainder = seconds % 60
	return string.format("%d:%02d", minutes, remainder)
end

local function GenerateStock()
	local SETTINGS = {
		STOCK_RANGE = {
			Common = { Min = 15, Max = 25 },
			Uncommon = { Min = 10, Max = 20 },
			Rare = { Min = 5, Max = 15 },
			Legendary = { Min = 1, Max = 3 },
			Mythical = { Min = 1, Max = 2 },
			Divine = { Min = 1, Max = 1 },
			Prismatic = { Min = 1, Max = 1 },
		},
		CHANCE_BASED_RARITIES = {
			Legendary = 5,
			Mythical = 2,
			Divine = 0.5,
			Prismatic = 0.1,
		}
	}

	local toolStock = {}

	for _, toolName in ipairs(ToolData.getToolOrder()) do
		local tool = ToolData.getData(toolName)
		if tool then
			local rarity = tool:FindFirstChild("Rarity") and tool.Rarity.Value or "Common"
			local range = SETTINGS.STOCK_RANGE[rarity] or { Min = 2, Max = 4 }
			local guaranteed = not SETTINGS.CHANCE_BASED_RARITIES[rarity]
			local available = guaranteed or (math.random() * 100 <= SETTINGS.CHANCE_BASED_RARITIES[rarity])

			toolStock[toolName] = {
				Name = tool:FindFirstChild("Name") and tool.Name.Value or toolName,
				Price = tool:FindFirstChild("Price") and tool.Price.Value or 10,
				Rarity = rarity,
				StockAmount = available and math.random(range.Min, range.Max) or 0,
				IsInStock = available,
				LayoutOrder = tool:FindFirstChild("LayoutOrder") and tool.LayoutOrder.Value or 0,
				DevProduct = tool:FindFirstChild("DevProduct") and tool.DevProduct.Value or 0
			}
		end
	end

	return { Tools = toolStock }
end

function Service:GetCurrentStock()
	local memoryStore = MemoryStoreService:GetSortedMap("GLOBAL_SHOP")
	local success, raw = pcall(function()
		return memoryStore:GetAsync(stockMemoryKey)
	end)
	if success and raw then
		return HttpService:JSONDecode(raw)
	end
	return nil
end

function Service:GetTimeUntilRestock()
	local memoryStore = MemoryStoreService:GetSortedMap("GLOBAL_SHOP")
	local success, timestamp = pcall(function()
		return memoryStore:GetAsync(timeMemoryKey)
	end)
	if success and timestamp then
		self.LastRestockTime = timestamp
	end
	local elapsed = os.time() - self.LastRestockTime
	return math.max(0, restockInterval - elapsed)
end

function Service:SaveStockToMemoryStore(stockData)
	local memoryStore = MemoryStoreService:GetSortedMap("GLOBAL_SHOP")
	local jsonData = HttpService:JSONEncode(stockData)
	pcall(function()
		memoryStore:SetAsync(stockMemoryKey, jsonData, restockInterval + 60)
	end)
end

function Service:SaveRestockTime()
	local memoryStore = MemoryStoreService:GetSortedMap("GLOBAL_SHOP")
	pcall(function()
		memoryStore:SetAsync(timeMemoryKey, os.time(), restockInterval + 60)
	end)
end

function Service:BroadcastRestock()
	local stock = GenerateStock()
	self:SaveStockToMemoryStore(stock)
	self:SaveRestockTime()
	MessagingService:PublishAsync("GlobalShopRestock", true)
end

local function OnRestockMessage()
	local stock = Service:GetCurrentStock()
	if stock then
		RemoteEvents.ResetGearShop:FireAllClients(stock.Tools)
	end
end

function Service.init()
	MessagingService:SubscribeAsync("GlobalShopRestock", OnRestockMessage)

	task.spawn(function()
		while true do
			local remaining = Service:GetTimeUntilRestock()
			while remaining > 0 do
				RemoteEvents.GearShopTimer:FireAllClients(FormatTime(remaining))
				task.wait(1)
				remaining -= 1
			end
			Service:BroadcastRestock()
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		task.spawn(function()
			for _ = 1, 10 do
				local stock = Service:GetCurrentStock()
				if stock then
					RemoteEvents.ResetGearShop:FireClient(player, stock.Tools)
					return
				end
				task.wait(1)
			end
		end)
	end)

	RemoteEvents.BuyGear.OnServerEvent:Connect(function(player, gearName)
		local stock = Service:GetCurrentStock()
		if not stock then return end
		local gear = stock.Tools[gearName]
		if not gear or gear.StockAmount <= 0 then return end
		gear.StockAmount -= 1
		Service:SaveStockToMemoryStore(stock)
		RemoteEvents.ResetGearShop:FireAllClients(stock.Tools)
	end)
end

return Service
