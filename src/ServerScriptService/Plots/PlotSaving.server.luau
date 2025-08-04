local DataStoreService = game:GetService("DataStoreService")
local PlotDataStore = DataStoreService:GetDataStore("MyPlotSaving")
local SavePlot = game.ReplicatedStorage.Events.SavePlot

local PlotsFolder = game.Workspace:WaitForChild("Plots")
local Plots = PlotsFolder:GetChildren()

repeat
	task.wait()
	Plots = PlotsFolder:GetChildren()
until #Plots == game.ReplicatedStorage.NumberOfPlots.Value

-- Find the plot assigned to a player
local function findPlayerPlot(player)
	for _, plot in pairs(Plots) do
		local owner = plot:FindFirstChild("Owner")
		if owner and owner.Value == tostring(player.UserId) then
			return plot
		end
	end
	return nil
end

-- Save a player's plot data
local function savePlayerData(player)
	local playerPlot = findPlayerPlot(player)
	if not playerPlot then return end

	local data = {}
	local itemHolder = playerPlot:FindFirstChild("ItemHolder")
	if not itemHolder then return end

	local plotCFrame = playerPlot.CFrame
	for _, item in pairs(itemHolder:GetChildren()) do
		if item:IsA("Model") and item.PrimaryPart then
			-- Save relative CFrame (position + rotation)
			local relativeCFrame = plotCFrame:Inverse() * item.PrimaryPart.CFrame
			table.insert(data, {
				name = item.Name,
				cframe = {relativeCFrame:components()}
			})
		end
	end

	-- Save to DataStore
	local key = "Player_" .. player.UserId
	local success, errorMessage = pcall(function()
		PlotDataStore:SetAsync(key, data)
	end)

	if success then
		print("Data saved successfully for", player.Name)
	else
		warn("Failed to save data for", player.Name, ":", errorMessage)
	end
end

-- Load a player's plot data
SavePlot.OnServerEvent:Connect(function(player)
	local key = "Player_" .. player.UserId
	local success, data = pcall(function()
		return PlotDataStore:GetAsync(key)
	end)

	if success and data then
		print("Data loaded successfully for", player.Name)
		local playerPlot = findPlayerPlot(player)
		if not playerPlot then return end

		local itemHolder = playerPlot:FindFirstChild("ItemHolder")
		if not itemHolder then return end

		local prefabs = game.ReplicatedStorage.Objects.Furniture
		local plotCFrame = playerPlot.CFrame

		for _, itemData in pairs(data) do
			local prefab = prefabs:FindFirstChild(itemData.name)
			if prefab then
				local clone = prefab:Clone()
				-- Convert relative CFrame back to world CFrame
				local relativeCFrame = CFrame.new(unpack(itemData.cframe))
				clone:PivotTo(plotCFrame * relativeCFrame)
				clone.Parent = itemHolder
			end
		end
	elseif not data then
		print("No saved data for", player.Name)
	else
		warn("Failed to load data for", player.Name, ":", data)
	end
end)

-- Save player data when they leave the game
game.Players.PlayerRemoving:Connect(function(player)
	savePlayerData(player)
end)

-- Auto-save data every 5 minutes
task.spawn(function()
	while true do
		task.wait(300) -- Wait 5 minutes (300 seconds)
		for _, player in pairs(game.Players:GetPlayers()) do
			savePlayerData(player)
		end
		print("Auto-save completed.")
	end
end)
