local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Events = ReplicatedStorage:WaitForChild("Events")
local PlotsFolder = workspace:WaitForChild("Plots")
local Players = game:GetService("Players")

local PlotClaim = Events:WaitForChild("PlotClaim")
local SavePlot = Events:WaitForChild("SavePlot")
local PlotAssigned = Events:WaitForChild("PlotAssigned")

local player = Players.LocalPlayer
local claimed = false

local function waitForPlots(timeout)
    timeout = timeout or 10
    local startTime = os.clock()
    while #PlotsFolder:GetChildren() == 0 do
        if os.clock() - startTime > timeout then
            warn("플롯이 지정된 시간 내에 생성되지 않았습니다.")
            return false
        end
        task.wait(0.5)
    end
    return true
end

local function claimPlot()
    if claimed then return end
    local plots = PlotsFolder:GetChildren()
    if #plots == 0 then
        warn("플롯이 없습니다.")
        return
    end

    print(player.Name .. " → " .. plots[1].Name .. " is being claimed.")
    PlotClaim:FireServer(plots[1]:WaitForChild("Owner"))
    SavePlot:FireServer()
    PlotAssigned:FireServer(plots[1]:WaitForChild("Owner"))

    claimed = true
end

local function setup()
    local baseValue = player:WaitForChild("Base", 10)
    if not baseValue then return end

    local plotsReady = waitForPlots(10)
    if not plotsReady then
        return
    end

    if baseValue.Value == true then
        claimPlot()
    end

    baseValue:GetPropertyChangedSignal("Value"):Connect(function()
        if baseValue.Value == true then
            claimPlot()
        end
    end)
end

setup()
