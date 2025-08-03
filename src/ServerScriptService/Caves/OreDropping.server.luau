local RunService = game:GetService("RunService")
local Terrain = workspace.Terrain
local Players = game:GetService("Players")
local OreFolder = workspace:WaitForChild("OreFolder")

local CHECK_RADIUS = 25
local CHECK_INTERVAL = 0.2
local timePassed = 0

local function isAirAtPosition(pos)
	local region = Region3.new(pos - Vector3.new(1, 1, 1), pos + Vector3.new(1, 1, 1)):ExpandToGrid(4)


	local materials, occupancy = Terrain:ReadVoxels(region, 4)
	local mat = materials[1][1][1]
	local occ = occupancy[1][1][1]



	return mat == Enum.Material.Air and occ < 0.1
end


RunService.Heartbeat:Connect(function(dt)
	timePassed += dt
	if timePassed < CHECK_INTERVAL then return end
	timePassed = 0

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character and character:FindFirstChild("HumanoidRootPart") then
			local rootPos = character.HumanoidRootPart.Position

			for _, ore in ipairs(OreFolder:FindFirstChild("Mouth"):GetChildren()) do
				if ore:IsA("BasePart") and (ore.Position - rootPos).Magnitude <= CHECK_RADIUS then
        
					local shouldFall = isAirAtPosition(ore.Position)
					ore.Anchored = not shouldFall
                
                        ore.Anchored = not isAirAtPosition(ore.Position)
                
				end
			end 
		end
	end


end)