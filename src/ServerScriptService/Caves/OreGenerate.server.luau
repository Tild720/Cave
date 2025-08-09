local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local OreFolder = workspace:WaitForChild("OreFolder")
local OrePrefabs = game.ServerStorage:WaitForChild("Ores")
local CaveSetting = require(ReplicatedStorage:WaitForChild("Settings"):WaitForChild("Cave"))
local OrePoses = workspace:WaitForChild("OrePoses")

local RNG = Random.new()

local function roundVector3(v)
	return Vector3.new(math.floor(v.X), math.floor(v.Y), math.floor(v.Z))
end

local function isUsed(position, usedPositions)
	for _, pos in pairs(usedPositions) do
		if (pos - position).Magnitude < 1 then
			return true
		end
	end
	return false
end

local function weightedRandom(oreTable)
	local totalWeight = 0
	for _, data in pairs(oreTable) do
		totalWeight += data.chance or 0
	end
	if totalWeight <= 0 then return nil end

	local rand = math.random() * totalWeight
	local cumulative = 0
	for oreName, data in pairs(oreTable) do
		cumulative += data.chance or 0
		if rand <= cumulative then
			return oreName
		end
	end
	return nil
end

local function spawnOres(regionName, regionData, regionParts)
	if not regionData or #regionParts == 0 then return end

	-- 기존 광물 제거 (폴더는 유지)
	local regionFolder = OreFolder:FindFirstChild(regionName)
	if not regionFolder then
		regionFolder = Instance.new("Folder")
		regionFolder.Name = regionName
		regionFolder.Parent = OreFolder
	else
		for _, obj in ipairs(regionFolder:GetChildren()) do
			obj:Destroy()
		end
	end

	local usedPositionsPerPart = {}
	local oreCounts = {}

	for i, _ in ipairs(regionParts) do
		usedPositionsPerPart[i] = {}
	end

	for i = 1, regionData.SpawnCount or 0 do
		local partIndex = ((i - 1) % #regionParts) + 1
		local part = regionParts[partIndex]
		local usedPositions = usedPositionsPerPart[partIndex]

		if not part or not part:IsA("BasePart") then continue end

		local partSize = part.Size
		local partCenter = part.Position

		local selectedOre = weightedRandom(regionData.Ores)
		if not selectedOre then continue end

		oreCounts[selectedOre] = (oreCounts[selectedOre] or 0) + 1
		local oreMax = (regionData.Ores[selectedOre] and regionData.Ores[selectedOre].max) or math.huge
		if oreCounts[selectedOre] > oreMax then
			oreCounts[selectedOre] -= 1
			continue
		end

		local Template = OrePrefabs:FindFirstChild(selectedOre)
		if not Template then
			oreCounts[selectedOre] -= 1
			continue
		end

		local placed = false
		for _ = 1, 20 do
			local randX = math.random(-partSize.X/2, partSize.X/2)
			local randY = math.random(-partSize.Y/2, partSize.Y/2)
			local randZ = math.random(-partSize.Z/2, partSize.Z/2)

			local candidate = roundVector3(Vector3.new(randX, randY, randZ) + partCenter)

			if not isUsed(candidate, usedPositions) then
				local clone = Template:Clone()

				if clone:IsA("Model") then
					if clone.PrimaryPart then
						clone:SetPrimaryPartCFrame(CFrame.new(candidate))
					elseif clone:FindFirstChildWhichIsA("BasePart") then
						clone:FindFirstChildWhichIsA("BasePart").CFrame = CFrame.new(candidate)
					end
				elseif clone:IsA("BasePart") then
					clone.CFrame = CFrame.new(candidate)
				end

				clone.Parent = regionFolder
				table.insert(usedPositions, candidate)

				if CollectionService:HasTag(clone, "Tool") then
					local function getRandomWeight()
						local roll = RNG:NextNumber(0, 100)
						if roll <= 0.1 then
							return RNG:NextNumber(0.5, 100)
						elseif roll <= 0.5 then
							return RNG:NextNumber(0.5, 65)
						elseif roll <= 5 then
							return RNG:NextNumber(0.5, 20)
						elseif roll <= 10 then
							return RNG:NextNumber(0.5, 10)
						elseif roll <= 30 then
							return RNG:NextNumber(0.5, 5)
						else
							return RNG:NextNumber(0.5, 1)
						end
					end

					local weight = math.round(getRandomWeight() * 100) / 100
					clone:SetAttribute("Weight", weight)

					local scaleMultiplier = 1 + math.min(weight / 10, 9)
					if clone:IsA("Model") and clone.PrimaryPart then
						for _, sub in ipairs(clone:GetDescendants()) do
							if sub:IsA("BasePart") then
								sub.Size *= scaleMultiplier
							end
						end
					elseif clone:IsA("BasePart") then
						clone.Size *= scaleMultiplier
					end
				end

				placed = true
				break
			end
		end

		if not placed then
			oreCounts[selectedOre] -= 1
		end
	end
end

local spawnOreEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Function"):WaitForChild("SpawnOre")

spawnOreEvent.Event:Connect(function()
	for regionName, regionData in pairs(CaveSetting.DepthRegions) do
		local regionFolder = OrePoses:FindFirstChild(regionName)
		if regionFolder then
			spawnOres(regionName, regionData, regionFolder:GetChildren())
		end
	end
end)

