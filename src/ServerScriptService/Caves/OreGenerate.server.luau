local OreFolder = game.Workspace:WaitForChild("OreFolder")
local OrePrefabs = game.ServerStorage:WaitForChild("Ores")
local CaveSetting = require(game.ReplicatedStorage:WaitForChild("Settings"):WaitForChild("Cave"))
local OrePoses = game.Workspace:WaitForChild("OrePoses")

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
		totalWeight += data.chance
	end

	local rand = math.random() * totalWeight
	local cumulative = 0

	for oreName, data in pairs(oreTable) do
		cumulative += data.chance
		if rand <= cumulative then
			return oreName
		end
	end
end

local function spawnOres(regionName, regionData, regionParts)
	local usedPositionsPerPart = {}
	local oreCounts = {}

	for i, part in ipairs(regionParts) do
		usedPositionsPerPart[i] = {}
	end

	local spawnPerPart = math.floor(regionData.SpawnCount / #regionParts)

	for i = 1, regionData.SpawnCount do
		local partIndex = ((i - 1) % #regionParts) + 1
		local part = regionParts[partIndex]
		local usedPositions = usedPositionsPerPart[partIndex]

		local partSize = part.Size
		local partCenter = part.Position

		local selectedOre = weightedRandom(regionData.Ores)

		if not selectedOre then continue end

		-- max 초과 시 스킵
		oreCounts[selectedOre] = (oreCounts[selectedOre] or 0) + 1
		if oreCounts[selectedOre] > regionData.Ores[selectedOre].max then
			oreCounts[selectedOre] -= 1
			continue
		end

		local Template = OrePrefabs:FindFirstChild(selectedOre)
		if not Template then continue end

		local maxAttempts = 20
		for _ = 1, maxAttempts do
			local randX = math.random(-partSize.X/2, partSize.X/2)
			local randY = math.random(-partSize.Y/2, partSize.Y/2)
			local randZ = math.random(-partSize.Z/2, partSize.Z/2)

			local pos = roundVector3(Vector3.new(randX, randY, randZ) + partCenter)

			if not isUsed(pos, usedPositions) then
				local clone = Template:Clone()
				clone.Position = pos
				clone.Parent = OreFolder:FindFirstChild(regionName)
				table.insert(usedPositions, pos)
				break
			end
		end
	end
end

for regionName, regionData in pairs(CaveSetting.DepthRegions) do
	local regionFolder = OrePoses:FindFirstChild(regionName)
	if regionFolder then
		local parts = regionFolder:GetChildren()
		spawnOres(regionName, regionData, parts)
	end
end
