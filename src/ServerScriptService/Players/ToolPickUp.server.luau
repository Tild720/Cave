local CollectionService = game:GetService("CollectionService")
local ServerStorage = game:GetService("ServerStorage")
local ToolsFolder = ServerStorage:WaitForChild("Tools")

-- 파트 처리 함수
local function setupToolPart(part)
	if not part:IsA("BasePart") then return end

	local prompt = part:FindFirstChildOfClass("ProximityPrompt")
	if not prompt then
		warn("No ProximityPrompt in:", part:GetFullName())
		return
	end

	if prompt:GetAttribute("Connected") then return end -- 중복 연결 방지
	prompt:SetAttribute("Connected", true)

	prompt.Triggered:Connect(function(player)
		local toolName = part:GetAttribute("Name")
		local oreWeight = part:GetAttribute("Weight")

		print("Triggered by:", player.Name)
		print("toolName:", toolName, "oreWeight:", oreWeight, "type:", typeof(oreWeight))

		if not toolName or typeof(toolName) ~= "string" then
			warn("Missing or invalid toolName on part:", part.Name)
			return
		end

		if not oreWeight or typeof(oreWeight) ~= "number" then
			warn("Missing or invalid oreWeight on part:", part.Name)
			return
		end

		local tool = ToolsFolder:FindFirstChild(toolName)
		if not tool then
			warn("Tool not found in ToolsFolder:", toolName)
			return
		end

		local clone = tool:Clone()
		local handle = clone:FindFirstChild("Handle")

		if handle then
			local multiplier = 1 + math.min(oreWeight / 10, 9)
			handle.Size *= multiplier
			print("Handle size scaled with multiplier:", multiplier)
		else
			warn("Cloned tool has no Handle:", toolName)
		end

		clone:SetAttribute("Weight", oreWeight)
		clone.Parent = player:WaitForChild("Backpack")

		-- 시각적 효과 및 파괴
		prompt.Enabled = false
		part.Transparency = 1

		task.delay(5, function()
			if part and part.Parent then
				part:Destroy()
			end
		end)
	end)
end

-- 기존 파트 처리
for _, part in pairs(CollectionService:GetTagged("Tool")) do
	setupToolPart(part)
end

-- 새 파트 추가 시 처리
CollectionService:GetInstanceAddedSignal("Tool"):Connect(function(part)
	setupToolPart(part)
end)
