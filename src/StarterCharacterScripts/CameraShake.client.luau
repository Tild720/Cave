while task.wait(.025) do
	if script.Parent:WaitForChild("CamShake").Value then
		local Char = game.Players.LocalPlayer.Character
		if Char then
			local H = Char:FindFirstChildOfClass("Humanoid")

			if H then
				game:GetService("TweenService"):Create(H,TweenInfo.new(.025,Enum.EasingStyle.Linear),{CameraOffset = Vector3.new(math.random(-10,10)/10,math.random(-10,10)/10,math.random(-10,10)/10)}):Play()
			end
		end
	else
		local Char = game.Players.LocalPlayer.Character
		if Char then
			local H = Char:FindFirstChildOfClass("Humanoid")

			if H then
				game:GetService("TweenService"):Create(H,TweenInfo.new(.05),{CameraOffset = Vector3.new()}):Play()
			end
		end
	end
end