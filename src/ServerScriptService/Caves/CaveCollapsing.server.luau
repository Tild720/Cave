local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Collapsing = workspace:WaitForChild("Collapsing")
local CaveRopes = Collapsing:WaitForChild("CaveRopes")
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

local function turnLights(bool)
	for _, rope in ipairs(CaveRopes:GetChildren()) do
		if rope.Name == "Light Rope" then
			local lightPart = rope:FindFirstChild("LightPart")
			local spotLight = lightPart and lightPart:FindFirstChildOfClass("SpotLight")
			if spotLight then
				spotLight.Enabled = bool
				if bool then
					lightPart.Material = Enum.Material.Neon
					print("Light ON:", rope.Name, lightPart.Name)
				else
					lightPart.Material = Enum.Material.Plastic
					print("Light OFF:", rope.Name, lightPart.Name)
				end
			else
				print("SpotLight missing in", lightPart and lightPart.Name or "nil")
			end
		end
	end
end

local function camShakePlayers(strong, duration)
	for _, part in ipairs(Fog:GetTouchingParts()) do
		local char = part.Parent
		local player = Players:GetPlayerFromCharacter(char)
		if player and char:FindFirstChild("CamShake") then
			print("CamShake ON for", player.Name)
			char.CamShake.Value = true
			task.delay(duration or 0.5, function()
				if char and char:FindFirstChild("CamShake") then
					char.CamShake.Value = false
					print("CamShake OFF for", player.Name)
				end
			end)
		end
	end
end

local function killPlayersInFog()
	print("Killing players inside Fog...")
	for _, part in ipairs(Fog:GetTouchingParts()) do
		local char = part.Parent
		local hum = char:FindFirstChildOfClass("Humanoid")
		local player = Players:GetPlayerFromCharacter(char)
		if hum then
			if player then
				print("Killing player:", player.Name)
			else
				print("Killing NPC:", char.Name)
			end
			hum.Health = 0
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
	print("Collapse Event Started")
	PlayerEvent:FireAllClients("Alert", "After 60 seconds, the cave collapses.")
	task.wait(10)
	PlayerEvent:FireAllClients("Alert", "Evacuate to the lobby.")
	task.wait(30)

	local caveShakingSound = Collapsing:FindFirstChild("CaveShaking")
	if caveShakingSound then 
		caveShakingSound:Play() 
		print("CaveShaking sound played")
	end
    Fog.ParticleEmitter.Enabled = true
	task.spawn(function()
		local startTime = tick()
		while tick() - startTime < 30 do
			shakeRopes(2)
			camShakePlayers(false, 0.5)
			task.wait(5)
		end
	end)

	task.wait(10)
	local CaveShaking2 = Collapsing:FindFirstChild("CaveShaking2")
	if CaveShaking2 then CaveShaking2:Play() end

	PlayerEvent:FireAllClients("Alert", "Closing Safety Door")
	print("Closing Door Tween Start")
	doorTweenClose:Play()

	task.spawn(function()
		local startTime = tick()
		while tick() - startTime < 5 do
			shakeRopes(13)
			camShakePlayers(true, 0.5)
			task.wait(0.3)
		end
		print("Turning off all lights")
		local caveShakingSound3 = Collapsing:FindFirstChild("CaveShaking3")
		if caveShakingSound3 then caveShakingSound3:Play() end
		turnLights(false)
	end)

	task.wait(5)
	killPlayersInFog()
	if caveShakingSound then caveShakingSound:Stop() end 
     Fog.ParticleEmitter.Enabled = false

	task.wait(2)
	fillBasaltFromBlocks()
	print("Filled Basalt from FillBlockws")
    turnLights(true)    
	SpawnOre:Fire()
	print("SpawnOre function invoked")
    
	task.wait(3)
	print("Opening Door Tween Start")
	doorTweenOpen:Play()
 
end

while true do
    wait(5)
       SpawnOre:Fire()
	--collapseEvent()
	task.wait(600)
end
