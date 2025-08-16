local Players = game.Players
local Plots = game.Workspace.Plots
local PlotUIRemote = game.ReplicatedStorage.Events.PlotUI
local PlotClaim = game.ReplicatedStorage.Events.PlotClaim

Players.PlayerAdded:Connect(function(plr)
	local DestroyMode = Instance.new("BoolValue")
	DestroyMode.Parent = plr
	DestroyMode.Name = "DestroyMode"
	DestroyMode.Value = false
	
	local PlotClaimed = Instance.new("BoolValue")
	PlotClaimed.Parent = plr
	PlotClaimed.Name = "PlotClaimed"
	PlotClaimed.Value = false
	
	local BuildMode = Instance.new("BoolValue")
	BuildMode.Parent = plr
	BuildMode.Name = "BuildMode"
	BuildMode.Value = false
	
	local Plot = Instance.new("BoolValue")
	Plot.Parent = plr
	Plot.Name = "Plot"
	Plot.Value = false
	PlotUIRemote:FireClient(plr, plr.UserId)
end)

PlotClaim.OnServerEvent:Connect(function(plr, owner)
	owner.Value = plr.UserId
	plr:FindFirstChild("Plot").Value = true
end)