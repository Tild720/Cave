local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain

local IceFolder = workspace:WaitForChild("RoadBlocks") 

RunService.Heartbeat:Connect(function()
	for _, part in pairs(IceFolder:GetChildren()) do
		if part:IsA("BasePart") then
			Terrain:FillBlock(part.CFrame, part.Size, Enum.Material.Ice)
		end
	end
end)
