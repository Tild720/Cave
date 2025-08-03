local NumberSpinner = require(game.ReplicatedStorage:WaitForChild("Modules"):WaitForChild("NumberSpin"))
local player = game.Players.LocalPlayer
local TextLabel = player.PlayerGui:WaitForChild("MainUI"):WaitForChild("MoneyLabel")


-- local Number = NumberSpinner.fromGuiObject(TextLabel)
-- Number.Decimals = 3
-- Number.Duration = 0.25
-- Number.Size = 0.5
function formatNumberWithCommas(number)
  local formattedNumber = string.format("%d", number)
  local left, num, right = string.match(formattedNumber, '^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

while wait(0.5) do
	--TextLabel.Text = math.random(100000)/1000
   -- Number.Value = math.random(100000)/1000

    local money = player:WaitForChild("leaderstats"):WaitForChild("Money")
    TextLabel.Text = "$"..string.format(formatNumberWithCommas(money.Value), 0)
end