local NumberSpinner = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("NumberSpin"))
local player = game.Players.LocalPlayer
local TextLabel = player.PlayerGui:WaitForChild("MainUI"):WaitForChild("MoneyLabel")


NumberSpinner.fromGuiObject(TextLabel)

while wait(0.5) do
	TextLabel.Text = math.random(100000)/1000
end