local enhanceModule = require(game.ServerStorage.Modules.EnchanceModule)
local getWeaponAttributeRemote = game.ReplicatedStorage.Events.Function.GetWeaponAttribute

local weaponFolder = game.ServerStorage.Weapons

local invokedPlayer = {}

local ObjectFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Objects")

local anvilPrompt = ObjectFolder:FindFirstChild("AnvilPrompt")
local beamPart = ObjectFolder:FindFirstChild("BeamPart")

local anvilFolder = workspace:FindFirstChild("모루")
task.wait(1) --로딩 시간


for _, anvil in ipairs(anvilFolder:GetChildren()) do
	anvilPrompt:Clone().Parent = anvil
	
	local beamPartClone = beamPart:Clone()
	beamPartClone.Position = anvil.Position + Vector3.new(0, -3, 0)
	beamPartClone.Parent = anvil
end


getWeaponAttributeRemote.OnServerInvoke = function(player, weaponName : string)
	if table.find(invokedPlayer, player) then return end
	task.spawn(function()
		table.insert(invokedPlayer, player)
		
		task.wait(1) -- 쿨타임 (클라이언트에서 받는 리모트이기 때문)
		table.remove(invokedPlayer, table.find(invokedPlayer, player))
	end)
	return enhanceModule.stats(weaponName)
end

