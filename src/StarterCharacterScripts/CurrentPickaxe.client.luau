local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local player = game.Players:GetPlayerFromCharacter(character)
local ObjectFolder = game.ReplicatedStorage:WaitForChild("Objects")
local currentWeaponUI = player.PlayerGui.MainUI.CurrentWeapon
local currentPassiveUI = player.PlayerGui.MainUI.CurrentPassive
local canFightUI = player.PlayerGui.MainUI.CanFight
local mainBillboardGui = ObjectFolder:WaitForChild("MainBillboardGui")
local getWeaponAttributeRemote = game.ReplicatedStorage.Events.Function:WaitForChild("GetWeaponAttribute")

local befWeapon = ""
local passiveDictionary = {   
    
    ["Rusty Pickaxe"] = "기본 곡괭이, 생각보다 단단하다",
    ["Stone Pickaxe"] = "가장 기본적인 재료로 만들어졌다",
    ["Iron Pickaxe"] = "튼튼하고 믿을 수 있는 금속 곡괭이",
    ["Gold Pickaxe"] = "반짝이지만 내구도는 낮다",
    ["Diamond Pickaxe"] = "강도와 효율을 겸비한 최상급 곡괭이",
    ["Ruby Pickaxe"] = "붉은 보석의 힘이 깃든 고급 곡괭이",
    ["Emerald Pickaxe"] = "녹색 보석이 깃들어 희귀함을 더한다",
    ["Fire Pickaxe"] = "타오르는 불꽃의 힘으로 무엇이든 녹인다",
    ["Ice Pickaxe"] = "차가운 기운이 감도는 신비한 곡괭이",
    ["Void Pickaxe"] = "어두운 기운이 서려 있다, 다루기 조심할 것",
    ["Ancient Pickaxe"] = "잊힌 문명의 유산, 전설이 깃든 도구",
    ["Fury Pickaxe"] = "강한 분노의 에너지가 요동친다",
    ["Ancient Fury Pickaxe"] = "고대와 분노의 힘이 융합된 파괴의 도구"




}
setmetatable(passiveDictionary, {
	__index = function()
		return "없음"
	end
})

function comma(amount)
	local formatted, k
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

local function billboardUIFunc(canEnhance, weapon, aftweapon, price, prob, ingredient)
	local anvils = workspace:FindFirstChild("모루")
	if not anvils then return end
	
	local mainFrame = mainBillboardGui.MainFrame
	local statFrame = mainFrame.StatFrame
	local costLabel = statFrame.CostLabel
	local errorLabel = statFrame.ErrorLabel
	local probLabel = statFrame.ProbabilityLabel

	local weaponLabel = statFrame.WeaponLabel
	local ingredientLabel = statFrame.IngredientLabel

	if canEnhance then
		errorLabel.Visible = false

		weaponLabel.Visible = true
	
		costLabel.Visible = true
		probLabel.Visible = true

		local weaponClean = weapon:gsub("Pickaxe", "")
        local aftweaponClean = aftweapon:gsub("Pickaxe", "")


        weaponLabel.Text = string.format("%s ▶ %s", weaponClean, aftweaponClean)
		costLabel.Text = string.format("Price : %s", comma(price))
		probLabel.Text = string.format("Chance : %d%%", prob)
		
		ingredientLabel.Visible = false
		if ingredient then
			local format = "%s"
			
			for itemname, amount in pairs(ingredient) do
				format = string.format(format, string.format(" %s %d", itemname, amount))
				if next(ingredient, itemname) then
					format = format..",%s"
				end
			end
			
			ingredientLabel.Text = format
			ingredientLabel.Visible = true
		end
	else
		errorLabel.Visible = true

		weaponLabel.Visible = false

		costLabel.Visible = false
		probLabel.Visible = false

		errorLabel.Text = "더 이상 강화할 수 없습니다."
	end
	
	for _, anvil in ipairs(anvils:GetChildren()) do
		local attachment = anvil:FindFirstChildOfClass("Attachment")
		if not attachment then continue end
		local findBillboard = attachment:FindFirstChildOfClass("BillboardGui")
		if findBillboard then findBillboard:Destroy() end
		 
		local cloneGui = mainBillboardGui:Clone()
		cloneGui.Parent = attachment
	end
end

local stroke = [[<stroke color = "#000000" joins = "Round" thickness = "%d" transparency = "0">%s</stroke>]] --%d과 %s에 들어가야 함

local function mainFunc(child)
	task.wait(0.1)
	local firstChild = nil

    
    for _, tool in ipairs(character:GetChildren()) do
        if tool:IsA("Tool") and string.find(tool.Name, "Pickaxe") then
            firstChild = tool
            break
        end
    end

 
    if not firstChild then
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, tool in ipairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and string.find(tool.Name, "Pickaxe") then
                    firstChild = tool
                    break
                end
            end
        end
    end


	if firstChild then
		if firstChild.Name == befWeapon then return end
		befWeapon = firstChild.Name
		currentWeaponUI.RichText = true
		currentWeaponUI.Text = string.format(stroke, 2, ""..firstChild.Name)
		currentPassiveUI.Text = string.format(" %s ", ""..passiveDictionary[firstChild.Name])
		local getAttribute = getWeaponAttributeRemote:InvokeServer(firstChild.Name)
		local canEnhance = getAttribute[1]
		local aftWeapon = getAttribute[2]
		local price = getAttribute[3]
		local prob = getAttribute[4]
		local ingredient = getAttribute[6]
		print(ingredient)
		
		billboardUIFunc(canEnhance, firstChild.Name, aftWeapon, price, prob, ingredient)
	else
		currentWeaponUI.Text = string.format(stroke, 2, "장착중인 무기 : 없음")
		billboardUIFunc(false)
	end
end

local function canFightUIFunc()
	local subText = if humanoid:GetAttribute("CanFight") == true then [[<font color="#00ff00">PVP ON</font>]] else [[<font color="#ff0000">PVP OFF</font>]]
	local mainText = "%s"
	mainText = string.format(mainText, subText)
	mainText = string.format(stroke, 2, mainText)

	canFightUI.RichText = true
	canFightUI.Text = mainText
end

task.wait(1)
mainFunc(character:FindFirstChildOfClass("Tool"))

character.ChildAdded:Connect(mainFunc)
character.ChildRemoved:Connect(mainFunc)

canFightUIFunc()

humanoid:GetAttributeChangedSignal("CanFight"):Connect(canFightUIFunc)