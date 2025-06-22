local Roact = require(game.ReplicatedStorage.Packages.Roact)
local Hooks = require(game.ReplicatedStorage.Packages.RoactHooks)
local hookComponent = Hooks.new(Roact)

local ClickToDisappear = hookComponent(function(props, hooks)
    local visible, setVisible = hooks.useState(true)

    if not visible then
        return nil  -- 화면에서 사라짐
    end

    return Roact.createElement("TextButton", {
        Size = UDim2.new(0, 200, 0, 50),
        Position = UDim2.new(0.5, -100, 0.5, -25),
        Text = "클릭하면 사라져요!",
        BackgroundColor3 = Color3.fromRGB(100, 149, 237),

        [Roact.Event.Activated] = function()
            setVisible(false) 
        end
    })
end)
