local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer
local AlertGui = LocalPlayer.PlayerGui:WaitForChild("Alert")
local alert = AlertGui:WaitForChild("Alert")
local alertStroke = alert:WaitForChild("UIStroke")

local alert2 = AlertGui:WaitForChild("Alert2")
local alert2Stroke = alert2:WaitForChild("UIStroke")

local PlayerEvent = ReplicatedStorage.Events:WaitForChild("PlayerEvent")

local isAlertPlaying = false

local function tweenTransparency(instance, property, toTransparency, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(instance, tweenInfo, {[property] = toTransparency})
	tween:Play()
end

local function tweenPosition(ui, targetPos, duration)
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local tween = TweenService:Create(ui, tweenInfo, {Position = targetPos})
	tween:Play()
end

local function playTextAlert(ui, stroke, message)
	ui.Text = message
	ui.TextTransparency = 1
	stroke.Transparency = 1
	tweenTransparency(ui, "TextTransparency", 0, 0.3)
	tweenTransparency(stroke, "Transparency", 0, 0.3)

	task.delay(1.5, function()
		tweenTransparency(ui, "TextTransparency", 1, 0.5)
		tweenTransparency(stroke, "Transparency", 1, 0.5)
	end)
end

PlayerEvent.OnClientEvent:Connect(function(action,message)
	if not (action == "Alert") then return end
	if isAlertPlaying then
		tweenPosition(alert, UDim2.new(0, 0, 0.26, 0), 0.2)
		playTextAlert(alert2, alert2Stroke, message)
	else
		isAlertPlaying = true
		alert.Position = UDim2.new(0, 0, 0.3, 0)
		playTextAlert(alert, alertStroke, message)

		task.delay(2.2, function()
			isAlertPlaying = false
		end)
	end
end)
