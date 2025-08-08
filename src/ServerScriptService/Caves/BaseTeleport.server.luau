local Blocks = game:GetService("Workspace"):WaitForChild("Blocks")
local PlotFolder = workspace:WaitForChild("Plots")
local Plots = PlotFolder:GetChildren()
local BaseTrigger = Blocks.Base:FindFirstChild("ProximityPrompt", true)
local PlayerEvent = game.ReplicatedStorage.Events:WaitForChild("PlayerEvent")

local PlotPart = nil
BaseTrigger.Triggered:Connect(function(player)
    print("Base Triggered by: " .. player.Name)
    PlayerEvent:FireClient(player, "CutScene", "Base")

    local PlotPart = nil
    for i = 1, #Plots do
        local plot = Plots[i]
        local ownerValue = plot:FindFirstChild("Owner")
      if ownerValue and tonumber(ownerValue.Value) == player.UserId then
        print("Plot found for player:", player.Name, "Plot:", plot.Name)
        PlotPart = plot
        break
        end     


    end

    if not PlotPart then
        warn("플레이어에 해당하는 플롯 파트가 없습니다.")
        return
    end

    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)

    if humanoidRootPart then
        humanoidRootPart.CFrame = PlotPart.CFrame * CFrame.new(1, 5, 1)
    else
        warn("HumanoidRootPart가 준비되지 않았습니다.")
    end
end)
