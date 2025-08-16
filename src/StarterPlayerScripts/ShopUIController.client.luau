local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("Events")

RemoteEvents.ResetToolShop.OnClientEvent:Connect(function(tools)
	print(tools) -- 테이블 자체를 찍음
	for toolName, data in pairs(tools) do
		print(toolName, data.StockAmount, data.Rarity)
	end
end)
