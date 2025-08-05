local PlayerEvent = game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerEvent")

PlayerEvent.OnServerEvent:Connect(function(player,action, arg)
     PlayerEvent:FireClient(player, action, arg)
end)