local module = {}
local attributeDictionary = { -- [<string>] = {prob = n′(%), price = n″(원), aft = <string′>} # 속성표는 이전무기를 기준으로 기재함(aft = "none"은 더 이상 강화 불가능)
	
	-- ingredient: {key[재료이름] = 필요개수} 식으로 작성
	["Rusty Pickaxe"] = {prob = 90, price = 100, aft = "Stone Pickaxe", value = 100},  --100
	["Stone Pickaxe"] = {prob = 80, price = 500, aft = "Iron Pickaxe", value = 150, }, --500
	["Iron Pickaxe"] = {prob = 75, price = 1500, aft = "Gold Pickaxe", value = 900},--1500
	["Gold Pickaxe"] = {prob = 70, price = 3000, aft = "Diamond Pickaxe", value = 2700,ingredient = {["숲의 돌"] = 1,}}, -- 3900
	["Diamond Pickaxe"] = {prob = 60, price = 5000, aft = "Ruby Pickaxe", value =  6000,ingredient = {["힘의 돌"] = 3,}}, -- 9500 
	["Ruby Pickaxe"] = {prob = 50, price = 6000, aft = "Emerald Pickaxe", value = 25000,ingredient = {["독 가시"] = 5,["독의 돌"] = 1}}, --16500
	["Emerald Pickaxe"] = {prob = 40, price =8000, aft = "Fire Pickaxe", value = 35000,ingredient = {["얼음의 돌"] = 3}}, -- 17000
	["Fire Pickaxe"] = {prob = 30, price = 12000, aft = "Ice Pickaxe", value = 70000,ingredient = {["과냉각된 얼음의 돌"] = 3,["얼음의 돌"] = 5}}, 
	["Ice Pickaxe"] = {prob = 25, price = 33333, aft = "Void Pickaxe", value = 150000,ingredient = {["고대의 화염 구슬"] = 3,["지옥의 돌"] = 1}},
	["Void Pickaxe"] = {prob = 20, price = 50000, aft = "지옥의 분노 검", value = 666666,ingredient = {["분노의 구슬"] = 3,["지옥의 돌"] = 3}}, 

  

}
local enhancingPlayers = {}
local announceProb = 30 -- % 이하 강화에 성공할 경우 서버 내에 공지됨

setmetatable(attributeDictionary, {
	__index = function(_, key)
		warn(key, "은/는 속성 목록에 존재하지 않습니다.")
		return {prob = 0, price = 0, aft = "none", value = 0, ingredient = nil} -- 기본값 반환
	end
})

local weaponFolder = game.ServerStorage.Weapons
local uiShowRemote = game.ReplicatedStorage.Events.UIShow
local effectShowRemote = game.ReplicatedStorage.Events.EffectShow
local playSoundRemote = game.ReplicatedStorage.Events.PlaySound
local anvilSound = game.ReplicatedStorage.Objects.Sounds.AnvilSound
local successSound = game.ReplicatedStorage.Objects.Sounds.SuccessSound
local failSounds = game.ReplicatedStorage.Objects.Sounds.FailSounds

local function random(prob) -- return <boolean>
	if prob > 100 then prob = 100; prob = math.round(prob) end
	
	local randint = math.random(1, 100)
	if randint <= prob then
		return true
	else
		return false
	end
end

local function soundFire(player : Player, sound : Sound)
	local soundid = sound.SoundId
	local volume = sound.Volume
	local timelength = sound.TimeLength
	playSoundRemote:FireClient(player, soundid, volume, timelength)
end

local announcing = false
local announceTime = 5
local waitingList = {}
local function announceServer(player : Player, befWeapon : string, aftWeapon : string, prob : number)
	if announcing then
		table.insert(waitingList, {player, befWeapon, aftWeapon, prob})
		return
	end
	announcing = true
	uiShowRemote:FireAllClients("EnhanceAnnounce", true, string.format("%s(@%s)님이 %d%%의 확률을 뚫고 %s 강화에 성공해 %s를 획득하셨습니다", player.DisplayName, player.Name, prob, befWeapon, aftWeapon), announceTime)
	task.wait(announceTime)
	
	announcing = false
	if waitingList[1] then
		task.spawn(function()
			announceServer(waitingList[1][1], waitingList[1][2], waitingList[1][3], waitingList[1][4])
		end)
		table.remove(waitingList, 1)
	else
		uiShowRemote:FireAllClients("EnhanceAnnounce", false)
	end
end

function module.stats(weaponName : string)
	local canEnhance = true
	local attribute = attributeDictionary[weaponName]
	
	if attribute.aft == "none" then canEnhance = false end
	return {canEnhance, attribute.aft, attribute.price, attribute.prob, attribute.value, attribute.ingredient}
end

function module.enhance(player : Player, befWeapon : Model, anvilPos : Vector3) -- anvilPos는 파티클을 실행시키기 위해 받음
	
	if table.find(enhancingPlayers, player) then return end -- 복사 버그 방지
	local character = player.Character
	local leaderstats = player:FindFirstChild("leaderstats")
	local CurrentWeapon = player:FindFirstChild("CurrentWeapon")
	local humanoid = character:FindFirstChild("Humanoid")

	if not befWeapon then warn("잘못된 입력을 받았습니다.",player, befWeapon) return end
	if not anvilPos then warn("모루 위치를 받지 못하였습니다.", player) return end
	if not player.Character or not player.Character:FindFirstChild("Humanoid") or humanoid.Health <= 0 then return end
	local attribute = attributeDictionary[befWeapon.Name]
	if not typeof(attribute.prob) or not typeof(attribute.price) then warn(befWeapon, attribute, "속성 값에 오류가 있습니다.", player) return end
	if not typeof(attribute.aft) or attribute.aft == "none" then print("더 이상 강화할 수 없습니다.", player) return end	
	
	if not weaponFolder:FindFirstChild(attribute.aft) then warn(weaponFolder, "폴더에 무기가 존재하지 않습니다.", attribute.aft, player) return end
	if leaderstats.Money.Value < attribute.price then print("돈이 부족합니다.", player) return end
	local has = true
	if attribute.ingredient then
		local has = true
		local toolsCount = {}

		local backpack = player:FindFirstChild("Backpack")
		if not backpack then
			warn("Backpack 없음") -- wha
			return
		end

		-- 백팩 안 Tool 수량 세기
		for _, tool in ipairs(backpack:GetChildren()) do
			if tool:IsA("Tool") then
				local name = tool.Name
				toolsCount[name] = (toolsCount[name] or 0) + 1
			end
		end

		-- 재료 충족 여부 확인
		for itemname, amount in pairs(attribute.ingredient) do
			if (toolsCount[itemname] or 0) < amount then
				print("재료 부족")
				return
			end
		end

		-- 재료 충분 → 해당 Tool 삭제
		for itemname, amount in pairs(attribute.ingredient) do
			local removed = 0
			for _, tool in ipairs(backpack:GetChildren()) do
				if tool:IsA("Tool") and tool.Name == itemname then
					tool:Destroy()
					removed += 1
					if removed >= amount then
						break
					end
				end
			end
		end
	end

	
	--print("강화 중...")
	soundFire(player, anvilSound)
	leaderstats.Money.Value -= attribute.price

	table.insert(enhancingPlayers, player)
	task.delay(3, function()
		if random(attribute.prob) then
			pcall(function()
				CurrentWeapon.Value = attribute.aft
			end)
			
			print(player, "강화 성공")
			uiShowRemote:FireClient(player, "EnhanceResult", true, befWeapon.Name, attribute.aft)
			soundFire(player, successSound)
			if attribute.prob <= announceProb then
				effectShowRemote:FireClient(player, "UltraSuccess", anvilPos + Vector3.new(0, 8, 0))
				task.spawn(function()
					announceServer(player, befWeapon.Name, attribute.aft, attribute.prob)
				end)
			else
				effectShowRemote:FireClient(player, "Success", anvilPos + Vector3.new(0, 8, 0))
			end
			
			befWeapon:Destroy()
			
			local newWeapon = weaponFolder:FindFirstChild(attribute.aft):Clone()
		
			newWeapon.Parent = humanoid
			humanoid:EquipTool(newWeapon)
		else
			pcall(function()
				CurrentWeapon.Value = "Rusty Pickaxe"
			end)
			print(player, "강화 실패")
			effectShowRemote:FireClient(player, "Fail", anvilPos + Vector3.new(0, 8, 0))
			uiShowRemote:FireClient(player, "EnhanceResult", false, befWeapon.Name, "Rusty Pickaxe")
			soundFire(player, failSounds[math.random(1, 3)])
			befWeapon:Destroy()
			
			local newWoodenSword = weaponFolder:FindFirstChild("Rusty Pickaxe")
			if not newWoodenSword then return end
			newWoodenSword = newWoodenSword:Clone()
			newWoodenSword.Parent = humanoid
			humanoid:EquipTool(newWoodenSword)
		end
		
		table.remove(enhancingPlayers, table.find(enhancingPlayers, player))
	end)
end

return module