local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Collapsing = workspace:WaitForChild("Collapsing")
local CaveRopes = Collapsing:WaitForChild("CaveRopes")
local Sparks = Collapsing:WaitForChild("Sparks")
local Fog = Collapsing:WaitForChild("Fog")
local Door = Collapsing:WaitForChild("Door")
local DoorBase = Door:WaitForChild("Base")
local FillBlocks = Collapsing:WaitForChild("Fillblocks")

local PlayerEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerEvent")
local SpawnOre = ReplicatedStorage:WaitForChild("Events"):WaitForChild("Function"):WaitForChild("SpawnOre")

local doorTweenOpen = TweenService:Create(DoorBase, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = Vector3.new(-243.63, 76.471, -41.836)})
local doorTweenClose = TweenService:Create(DoorBase, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Position = Vector3.new(-243.63, 61.832, -41.836)})

local function shakeRopes(strength)
	for _, rope in ipairs(CaveRopes:GetChildren()) do
		if rope.Name == "Light Rope" then
			local lightPart = rope:FindFirstChild("LightPart")
			if lightPart and lightPart:IsA("BasePart") then
				local dir = Vector3.new(math.random(-10,10), math.random(-5,5), math.random(-10,10)).Unit
				lightPart.AssemblyLinearVelocity = dir * strength
			end
		end
	end
end
local function RandomSpark(count)
    for _, spark in ipairs(Sparks:GetChildren()) do
        
        if math.random(1, 10) < count then
            spark:FindFirstChild("Sparks").Enabled = true
            task.delay(0.5, function()
                spark:FindFirstChild("Sparks").Enabled = false
            end)
        end
        
    end
end

local function turnLights(bool)
	for _, rope in ipairs(CaveRopes:GetChildren()) do
		if rope.Name == "Light Rope" then
			local lightPart = rope:FindFirstChild("LightPart")
			local spotLight = lightPart and lightPart:FindFirstChildOfClass("SpotLight")
			if spotLight then
				spotLight.Enabled = bool
				if bool then
					lightPart.Material = Enum.Material.Neon
				
                    
				else
					lightPart.Material = Enum.Material.Plastic
				
				end
		
				
			end
		end
	end
end

local function isPointInPart(point, part)
    local size = part.Size
    local pos = part.Position
    local min = pos - (size / 2)
    local max = pos + (size / 2)

    return (point.X >= min.X and point.X <= max.X) and
           (point.Y >= min.Y and point.Y <= max.Y) and
           (point.Z >= min.Z and point.Z <= max.Z)
end
local function camShakePlayers(strong, duration)
    for _, player in pairs(Players:GetPlayers()) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local camShakeValue = char and char:FindFirstChild("CamShake")
        if hrp and camShakeValue and isPointInPart(hrp.Position, Fog) then
            camShakeValue.Value = true
            task.delay(duration or 0.5, function()
                if camShakeValue and camShakeValue.Parent then
                    camShakeValue.Value = false
                end
            end)
        end
    end
end

local function killPlayersInFog()

for _, player in pairs(Players:GetPlayers()) do
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        if isPointInPart(hrp.Position, Fog) then
          
            hum.Health = 0
            PlayerEvent:FireClient(player,"Fade",true, "Crushed to death by a stone.")
            wait(3)
            PlayerEvent:FireClient(player,"Fade",false, "")
        end
    end
end


end

local function fillBasaltFromBlocks()
	for _, block in ipairs(FillBlocks:GetChildren()) do
		if block:IsA("BasePart") then
			local region = Region3.new(
				block.Position - (block.Size / 2),
				block.Position + (block.Size / 2)
			)
			region = region:ExpandToGrid(4) 
			workspace.Terrain:FillRegion(region, 4, Enum.Material.Basalt)
		end
	end
end


local function collapseEvent()
    wait(3)
	
	PlayerEvent:FireAllClients("Alert", "After 60 seconds, the cave collapses.")
	task.wait(10)
	PlayerEvent:FireAllClients("Alert", "Evacuate to the lobby.")
	task.wait(5)    

	local caveShakingSound = Collapsing:FindFirstChild("CaveShaking")
	if caveShakingSound then 
		caveShakingSound:Play() 

	end
    Fog.ParticleEmitter.Enabled = true
	task.spawn(function()
		local startTime = tick()
		while tick() - startTime < 30 do
			shakeRopes(2)
            RandomSpark(7)
			camShakePlayers(false, 0.1)
			task.wait(1)
            
		end
	end)

	task.wait(10)
	

	PlayerEvent:FireAllClients("Alert", "Closing Safety Door")
	
	doorTweenClose:Play()
     local CaveShaking2 = Collapsing:FindFirstChild("CaveShaking2")
	if CaveShaking2 then CaveShaking2:Play() end

	task.spawn(function()
		local startTime = tick()
		while tick() - startTime < 5 do
			shakeRopes(13)
			camShakePlayers(true, 0.5)
            RandomSpark(9)
			task.wait(0.3)
		end
	
		local caveShakingSound3 = Collapsing:FindFirstChild("CaveShaking3")
		if caveShakingSound3 then caveShakingSound3:Play() end
		
	end)
     Fog.ParticleEmitter.Enabled = false
     	task.wait(3)
    
      local CaveShaking4= Collapsing:FindFirstChild("CaveShaking4")
	if CaveShaking4 then CaveShaking4:Play() end
    turnLights(false)
	killPlayersInFog()

	if caveShakingSound then caveShakingSound:Stop() end 
    

	task.wait(3)
    SpawnOre:Fire()
	fillBasaltFromBlocks()
	
    turnLights(true) 
	

    
	task.wait(3)

	doorTweenOpen:Play()
 
end

while true do

	collapseEvent()
	task.wait(600)
end
