local debris = game:GetService("Debris")
local playSoundRemote = game.ReplicatedStorage.Events:WaitForChild("PlaySound")
local effectShowRemote = game.ReplicatedStorage.Events:WaitForChild("EffectShow")
local effects = game.ReplicatedStorage:WaitForChild("Objects"):WaitForChild("Effects")
local enhanceEffects = effects:WaitForChild("EnhanceEffects")
local parryEffects = effects:WaitForChild("ParryEffects")
local MineHit = effects:WaitForChild("MineHit")
local success = enhanceEffects:WaitForChild("Success")
local ultraSuccess = enhanceEffects:WaitForChild("UltraSuccess")
local fail = enhanceEffects:WaitForChild("Fail")
local parry = parryEffects:WaitForChild("Parry")
local stun = parryEffects:WaitForChild("Stun")

local function emitParticles(attachment : Attachment, defaultEmitCount : int)
	for _, particle in ipairs(attachment:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			local getEmitCount = particle:GetAttribute("EmitCount")
			local emitCount = defaultEmitCount
			if typeof(getEmitCount) == "number" then emitCount = getEmitCount end
			
			particle:Emit(emitCount)
		end
	end
end

local function enableParticles(attachment : Attachment, duration)
	for _, particle in ipairs(attachment:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = true
		end
	end
	
	task.wait(duration)
	for _, particle in ipairs(attachment:GetChildren()) do
		if particle:IsA("ParticleEmitter") then
			particle.Enabled = false
		end
	end
end

local befSound : Sound?

playSoundRemote.OnClientEvent:Connect(function(soundid, volume, timelength)
	if befSound and befSound.SoundId == "rbxassetid://4958430453" then befSound:Stop(); befSound:Destroy() end -- swing sound 지우기
	  print(soundid, volume, timelength)
	local sound = Instance.new("Sound", game.SoundService)
	debris:AddItem(sound, timelength)
	
	sound.SoundId = soundid
	sound.Volume = volume
	sound:Play()
	befSound = sound
end)

effectShowRemote.OnClientEvent:Connect(function(key, pos)
    print(key, pos)
	if not key or not pos then return end
	if key == "Success" then
		local newSuccess = success:Clone()
		newSuccess.Parent = workspace.Effects
		newSuccess.Position = pos
		emitParticles(newSuccess.Attachment, 1)
		debris:AddItem(newSuccess, 1)
		
	elseif key == "UltraSuccess" then
		local newUSuccess = ultraSuccess:Clone()
		newUSuccess.Parent = workspace.Effects
		newUSuccess.Position = pos
		emitParticles(newUSuccess.Attachment, 1)
		debris:AddItem(newUSuccess, 1)
		
	elseif key == "Fail" then
		local newFail = fail:Clone()
		newFail.Parent = workspace.Effects
		newFail.Position = pos
		emitParticles(newFail.Attachment, 1)
		debris:AddItem(newFail, 1)
	elseif key == "MineHit" then
		local newHit = MineHit:Clone()
		newHit.Parent = workspace.Effects
		newHit.Position = pos
		emitParticles(newHit.Attachment, 1)
		debris:AddItem(newHit, 1)
			
		
	elseif key == "Parry" then
		-- pos -> player
		local newParry = parry:Clone()
		newParry.Parent = workspace.Effects
		newParry.Position = pos.Character.PrimaryPart.Position - Vector3.new(0, 2, 0)
		emitParticles(newParry.Attachment, 1)
		debris:AddItem(newParry, 1)
		
	elseif key == "Stun" then
		-- pos -> player
		local newStun = stun:Clone()
		newStun.Parent = workspace.Effects
		newStun.Position = pos.Character.Head.Position
		enableParticles(newStun.Attachment, 1.5)
		debris:AddItem(newStun, 2)
	end
end)