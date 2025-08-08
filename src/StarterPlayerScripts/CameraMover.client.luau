local PlayerEvent = game:GetService("ReplicatedStorage").Events:WaitForChild("PlayerEvent")
local TweenService = game:GetService("TweenService")
local Blocks = game:GetService("Workspace"):WaitForChild("Blocks")
local Camera = game.Workspace.CurrentCamera

PlayerEvent.OnClientEvent:Connect(function(action, arg)
    print("Action received: " .. action,arg)
 
    if action == "CutScene" then
        if arg == "Base" then
            print("Cutscene for Base triggered")
            Camera.CameraType = Enum.CameraType.Scriptable
           for i = 1, 3 do

            TweenService:Create(Camera, TweenInfo.new(2), {CFrame = Blocks.CameraParts.Base:FindFirstChild(i).CFrame}):Play()
                wait(1.3)
            
        
           end
           Camera.CameraType = Enum.CameraType.Custom
        end
    end
end)