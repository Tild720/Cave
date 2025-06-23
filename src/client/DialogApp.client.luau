local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Packages.roact)
local Hooks = require(ReplicatedStorage.Packages.RoactHooks)
local hookComponent = Hooks.new(Roact)

local ClickToDisappear = hookComponent(function(props, hooks)
	local visible, setVisible = hooks.useState(true)

	if not visible then
		return nil
	end

	return Roact.createElement("ScreenGui", {
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, {
		TextButton = Roact.createElement("TextButton", {
			Size = UDim2.new(0, 200, 0, 50),
			Position = UDim2.new(0.5, -100, 0.5, -25),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Text = "클릭하면 사라짐 맨",
			TextScaled = true,
			BackgroundColor3 = Color3.fromRGB(255, 150, 150),

			[Roact.Event.Activated] = function()
				setVisible(false)
			end,
		}, {
			
			UIStroke = Roact.createElement("UIStroke", {
				Thickness = 3,
				Color = Color3.new(0, 0, 0),
			}),
		}),
	})
end)

-- 📦 mount
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

Roact.mount(Roact.createElement(ClickToDisappear), playerGui, "DisappearingButton")
