local Blocks = game:GetService("Workspace"):WaitForChild("Blocks")
local BaseTeleport = Blocks:WaitForChild("BaseTeleport")
local BaseTrigger = Blocks.Base:FindFirstChild("ProximityPrompt", true)
local PlayerEvent = game.ReplicatedStorage.Events:WaitForChild("PlayerEvent")

BaseTrigger.Triggered:Connect(function(player)
    print("Base Triggered by: " .. player.Name)
    PlayerEvent:FireClient(player, "CutScene", "Base")
    player.Character.HumanoidRootPart.CFrame = BaseTeleport.CFrame

end)
