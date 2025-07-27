-- @XReydil
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local uiShowRemote = game.ReplicatedStorage.Events:WaitForChild("UIShow")

local player = game.Players.LocalPlayer

local enhanceResultFrame = player.PlayerGui:WaitForChild("MainUI"):WaitForChild("EnhanceResult")
enhanceResultFrame.Visible = false
local mainLabel = enhanceResultFrame:WaitForChild("MainLabel")
local subLabel = enhanceResultFrame:WaitForChild("SubLabel")
local TextButton = player.PlayerGui:WaitForChild("MainUI"):WaitForChild("TextButton")
local enhanceAnnounceLabel = player.PlayerGui.MainUI:WaitForChild("EnhanceAnnounce")
local currentWeaponLabel = player.PlayerGui.MainUI:WaitForChild("CurrentWeapon")
local currentPassiveLael = player.PlayerGui.MainUI:WaitForChild("CurrentPassive")
local currentWeaponBox = player.PlayerGui.MainUI:WaitForChild("CurrentWeaponBox")

local dtt = 0.3 -- default tween time

uiShowRemote.OnClientEvent:Connect(function(showType, val1, val2, val3, val4)
	print("UIShowRemote: ", showType, val1, val2, val3, val4)
	if showType == "EnhanceResult" then
		if val1 == nil or val2 == nil or val3 == nil then return end
		local isSuccess = val1 -- boolean
		if isSuccess then isSuccess = [[<font color="#00ff00">Successful</font>]] else isSuccess = [[<font color="#ff0000">Failed</font>]] end

		local befWeapon = val2 -- string
		local aftWeapon = val3 -- string

		local stroke = [[<stroke color = "#000000" joins = "Round" thickness = "%d" transparency = "0.87">%s</stroke>]] --%d과 %s에 들어가야 함
		local mainText = "<i>Upgrade  %s</i>"
		local subText = string.format("%s > %s", befWeapon, aftWeapon)
		mainText = string.format(stroke, 2.7, mainText)
		mainText = string.format(mainText, isSuccess)
		
		local newFrame = enhanceResultFrame:Clone()
		local fbY = enhanceResultFrame.Position.Y.Scale
		print(newFrame.MainLabel, newFrame.SubLabel, mainText, subText)
		newFrame.Parent = player.PlayerGui.MainUI
		newFrame.MainLabel.Text = mainText
		newFrame.MainLabel.RichText = true
		newFrame.SubLabel.Text = subText
		
		newFrame.Position = UDim2.fromScale(0.5,-0.1)
		newFrame.Visible = true
		tweenService:Create(newFrame, TweenInfo.new(dtt, Enum.EasingStyle.Quart), {Position = UDim2.fromScale(0.5,0.1)}):Play()
		task.wait(2)
		debris:AddItem(newFrame, dtt)
		tweenService:Create(newFrame, TweenInfo.new(dtt,Enum.EasingStyle.Quart), {Position = UDim2.fromScale(0.5,-0.1)}):Play()
		--tweenService:Create(newFrame.MainLabel, TweenInfo.new(dtt), {TextTransparency = 1}):Play()
	elseif showType == "EnhanceAnnounce" then
		if val1 == nil then return end
		
		if not val1 then
			tweenService:Create(enhanceAnnounceLabel, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
			task.wait(0.5)
			return
		end
		
		if val2 == nil or val3 == nil then return end
		enhanceAnnounceLabel.Position = UDim2.fromScale(1.5, 0.05)
		enhanceAnnounceLabel.Text = val2
		enhanceAnnounceLabel.BackgroundTransparency = 0.6
		enhanceAnnounceLabel.Visible = true
		
		tweenService:Create(enhanceAnnounceLabel, TweenInfo.new(val3, Enum.EasingStyle.Linear), {Position = UDim2.fromScale(-0.5, 0.05), BackgroundTransparency = 0.6}):Play()
	end
end)

local playTime = 0.2
local enter = false

currentWeaponBox.MouseEnter:Connect(function()
	enter = true
	tweenService:Create(currentWeaponLabel, TweenInfo.new(playTime), {Position = UDim2.fromScale(0.009, 0.877)}):Play()
	tweenService:Create(TextButton, TweenInfo.new(playTime), {Position = UDim2.fromScale(0.009,0.843)}):Play()
	task.wait(playTime)
	if enter then currentPassiveLael.Visible = true end
end)

currentWeaponBox.MouseLeave:Connect(function()
	enter = false
	tweenService:Create(currentWeaponLabel, TweenInfo.new(playTime), {Position = UDim2.fromScale(0.009, 0.904)}):Play()
	tweenService:Create(TextButton, TweenInfo.new(playTime), {Position = UDim2.fromScale(0.009,0.875)}):Play()
	currentPassiveLael.Visible = false
end)
