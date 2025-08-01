local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ToolsFolder = ServerStorage:WaitForChild("Tools")

for _, part in pairs(CollectionService:GetTagged("Tool")) do
	if part:IsA("BasePart") then
		local prompt = part:WaitForChild("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(player)
				local toolName = part:GetAttribute("Name")
				if not toolName then return end

				local tool = ToolsFolder:WaitForChild(toolName)
				if not tool then return end

				local clone = tool:Clone()
				clone.Parent = player:WaitForChild("Backpack")

				part:Destroy()
			end)
		end
	end
end

CollectionService:GetInstanceAddedSignal("Tool"):Connect(function(part)
	if part:IsA("BasePart") then
		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt.Triggered:Connect(function(player)
				local toolName = part:GetAttribute("Name")
				if not toolName then return end

				local tool = ToolsFolder:WaitForChild(toolName)
				if not tool then return end

				local clone = tool:Clone()
				clone.Parent = player:WaitForChild("Backpack")

				part:Destroy()
			end)
		end
	end
end)
