local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local PlotsFolder = workspace:WaitForChild("Plots")
local Players = game:GetService("Players")

local PlotClaim = Events:WaitForChild("PlotClaim")
local SavePlot = Events:WaitForChild("SavePlot")
local PlotAssigned = Events:WaitForChild("PlotAssigned")

Players.PlayerAdded:Connect(function(player)
	local plots = PlotsFolder:GetChildren()
	if #plots == 0 then
		warn("플롯이 없습니다.")
		return
	end

	print(plots[1].Name .. " is being claimed.")
	PlotClaim:FireServer(plots[1]:WaitForChild("Owner"))
	SavePlot:FireServer()
	PlotAssigned:FireServer(plots[1]:WaitForChild("Owner"))
end)
