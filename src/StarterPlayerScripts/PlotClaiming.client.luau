local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

local PlotClaim = Events:WaitForChild("PlotClaim")
local SavePlot = Events:WaitForChild("SavePlot")
local PlotAssigned = Events:WaitForChild("PlotAssigned")

PlotAssigned.OnClientEvent:Connect(function(ownerValue)

	PlotClaim:FireServer(ownerValue)
	
	SavePlot:FireServer()
end)
