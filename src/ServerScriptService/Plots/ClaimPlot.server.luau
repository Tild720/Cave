local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")

local PlotClaimEvent = Events:WaitForChild("PlotClaim")
local SavePlotEvent = Events:WaitForChild("SavePlot")
local PlotAssigned = Events:WaitForChild("PlotAssigned") 

local PlotsFolder = workspace:WaitForChild("Plots")

local function assignPlotToPlayer(player)
	for _, plot in pairs(PlotsFolder:GetChildren()) do
		local ownerValue = plot:WaitForChild("Owner")
		if ownerValue and ownerValue.Value == "" then

			
			PlotAssigned:FireClient(player, ownerValue)
			ownerValue.Value = player.UserId
			break
		end
	end
end

Players.PlayerAdded:Connect(assignPlotToPlayer)
