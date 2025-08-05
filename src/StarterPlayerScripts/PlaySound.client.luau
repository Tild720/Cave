local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("PlayerEvent")

playerEvent.OnClientEvent:Connect(function(action, soundName)
	if action == "PlaySound" then
		local sound = SoundService:FindFirstChild(soundName)
		if sound then
			local clonedSound = sound:Clone()
			clonedSound.Parent = workspace
			clonedSound:Play()
			clonedSound.Ended:Connect(function()
				clonedSound:Destroy()
			end)
		end
	end
end)
