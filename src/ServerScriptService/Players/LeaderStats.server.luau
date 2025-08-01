-- @XReydil
local runService = game:GetService("RunService")
local httpService = game:GetService("HttpService")
local dataStoreService = game:GetService("DataStoreService")
local dataStore = dataStoreService:GetDataStore("CaveAlpha?")
local datas = {}
local emergencyData = {}
local characterAddedFuncs = {}


local defaultCEM = 300
local defaultData = {
	["Money"] =	10000,
	["Weapon"] = "Rusty Pickaxe",
}

local function giveWeapon(character)
	if not character or character:FindFirstChildOfClass("Tool") then return end
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then return end
	
	local success, attempt = false, 1
	
	repeat
		local weapon = game.ServerStorage.Weapons:FindFirstChild(datas[player.UserId].Weapon)
		print(weapon)
		if weapon then
			local humanoid = character:FindFirstChild("Humanoid")
			if humanoid then
				local newWeapon = weapon:Clone()
				newWeapon.Parent = player.Backpack
				task.wait(0.3)
				if newWeapon.Parent == player.Backpack then

					success = true
				end
			end
		end
		
		attempt += 1
		if not success then
			task.wait(1)
		end
	until success or attempt >= 5
end

game.Players.PlayerAdded:Connect(function(player) -- 플레이어 들어올 경우
	player:SetAttribute("CEM", defaultCEM) -- can earn money
	local CEMtask
	player:GetAttributeChangedSignal("CEM"):Connect(function()
		if player:GetAttribute("CEM") == defaultCEM then return end
		if CEMtask then task.cancel(CEMtask); CEMtask = nil end
		
		CEMtask = task.delay(3 * 60, function()
			print("ResetCEM", player)
			player:SetAttribute("CEM", defaultCEM)
		end)
	end)
	
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	
	local money = Instance.new("IntValue", leaderstats)
	money.Name = "Money"
	
	local currentWeapon = Instance.new("StringValue", player)
	currentWeapon.Name = "CurrentWeapon"
	
	local success, playerData, attempt = nil, nil, 1
	repeat
		success, playerData = pcall(function()
			 return dataStore:GetAsync(player.UserId) -- 데이터 불러오기
		end)
		attempt += 1
		if not success then
			warn(playerData)
			task.wait(1)
		end
	until success or attempt >= 5 -- 시도 횟수
	
	local defaultClone = table.clone(defaultData)
	
	if success then
		print(player, "데이터스토어 연결 성공")
		if not playerData then
			-- 신규 유저에게는 기본값 제공
			playerData = defaultClone
		end
		
		-- datas에 새로운 데이터가 추가될 수 있음
		for k, v in pairs(defaultClone) do
			if not playerData[k] then
				playerData[k] = v
			end
		end
		---- datas에 있던 데이터가 안 쓰일 수 있음
		--for k, v in pairs(playerData) do
		--	if not defaultClone[k] then
		--		playerData[k] = nil
		--	end
		--end
		
		--print(httpService:JSONEncode(playerData))
		datas[player.UserId] = playerData
		print(datas[player.UserId])
	
		print("register")
	else
		print(player, "님의 데이터를 불러올 수 없습니다.")
		player:Kick("데이터를 불러올 수 없습니다. 후에 다시 시도하세요.")
	end
	
	money.Value = datas[player.UserId].Money
	currentWeapon.Value = datas[player.UserId].Weapon
	giveWeapon(player.Character)
	
	money:GetPropertyChangedSignal("Value"):Connect(function()
		datas[player.UserId].Money = money.Value
	end)
	currentWeapon:GetPropertyChangedSignal("Value"):Connect(function()
		datas[player.UserId].Weapon = currentWeapon.Value
	end)
	leaderstats.Parent = player
	
	characterAddedFuncs[player.UserId] = player.CharacterAdded:Connect(giveWeapon)
end)

local function saveData(player) -- 플레이어 나갈 경우
	if datas[player.UserId] then
		
		
		local success, errorMsg, attempt = nil, nil, 1

		repeat
			success, errorMsg = pcall(function()
				dataStore:SetAsync(player.UserId, datas[player.UserId]) -- 데이터 저장
				datas[player.UserId] = nil
			end)
			attempt += 1
			if not success then
				warn(errorMsg)
				task.wait(1)
			end
		until success or attempt >= 5 -- 시도 횟수

		if success then
			print(player, "님의 데이터가 성공적으로 저장되었습니다.")
		else
			print(player, "님의 데이터를 저장할 수 없습니다.")
			table.insert(emergencyData, datas[player.UserId])
			-- 비상 데이터를 디스코드로 송출
		end
		
		if characterAddedFuncs[player.UserId] then characterAddedFuncs[player.UserId]:Disconnect(); characterAddedFuncs[player.UserId] = nil end
	end
end

game.Players.PlayerRemoving:Connect(saveData)
game:BindToClose(function() -- 서버가 셧다운 될 때
	if runService:IsStudio() then return end
	
	print("서버가 셧다운 되는 중입니다.")
	for _, player in ipairs(game.Players:GetPlayers()) do
		task.spawn(function()
		--	saveData(player)
		end)
	end
end)