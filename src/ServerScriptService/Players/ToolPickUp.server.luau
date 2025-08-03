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

				local oreWeight = part:GetAttribute("Weight")
				if oreWeight then
					local handle = clone:FindFirstChild("Handle")
					if handle then
						handle.Size *= 1 + math.min(oreWeight / 10, 9)
					end
					if not clone:GetAttribute("Weight") then
						clone:SetAttribute("Weight", oreWeight)
					end
				end

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

				local oreWeight = part:GetAttribute("Weight")
				if oresWeight then
					local handle = clone:FindFirstChild("Handle")
					if handle then
						handle.Size *= 1 + math.min(oreWeight / 10, 9)
					end
					if not clone:GetAttribute("Weight") then
						clone:SetAttribute("Weight", oreWeight)
					end
				end

				part:Destroy()
			end)
		end
	end
end)
