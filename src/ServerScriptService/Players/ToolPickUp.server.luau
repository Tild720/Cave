local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ToolsFolder = ServerStorage:WaitForChild("Tools")
local PlayerEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerEvent")

local function setupToolPart(part)
	if not part:IsA("BasePart") then return end

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then return end

	if prompt:GetAttribute("Connected") then
		return
	end
	prompt:SetAttribute("Connected", true)

	prompt.Triggered:Connect(function(player)
		local toolName = part:GetAttribute("Name")
		local oreWeight = part:GetAttribute("Weight")

		if not toolName or typeof(toolName) ~= "string" then return end
		if not oreWeight or typeof(oreWeight) ~= "number" then return end

		local tool = ToolsFolder:FindFirstChild(toolName)
		if not tool then return end

		local clone = tool:Clone()
		local handle = clone:FindFirstChild("Handle")

		if handle then
			local multiplier = 1 + math.min(oreWeight / 10, 9)
			handle.Size *= multiplier
		end

		clone:SetAttribute("Weight", oreWeight)
		clone.Parent = player:WaitForChild("Backpack")
		PlayerEvent:FireClient(player, "PlaySound", "ToolPickUp")
		PlayerEvent:FireClient(player, "Alert", "You picked up a " .. toolName .. " [" .. oreWeight .. "KG]")

		prompt.Enabled = false
		part.Transparency = 1

		task.delay(5, function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
	end)
end

local function resetConnectedAttributes()
	for _, part in pairs(CollectionService:GetTagged("Tool")) do
		local prompt = part:FindFirstChildOfClass("ProximityPrompt")
		if prompt then
			prompt:SetAttribute("Connected", false)
		end
	end
end

local function setupAllTaggedParts()
	resetConnectedAttributes()
	for _, part in pairs(CollectionService:GetTagged("Tool")) do
		setupToolPart(part)
	end
end

for _, part in pairs(CollectionService:GetTagged("Tool")) do
	setupToolPart(part)
end

CollectionService:GetInstanceAddedSignal("Tool"):Connect(function(part)
	setupToolPart(part)
end)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SpawnOreBindable = ReplicatedStorage:WaitForChild("Events").Function:WaitForChild("SpawnOre")

SpawnOreBindable.Event:Connect(function()
	wait(1)
	setupAllTaggedParts()
end)
