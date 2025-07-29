--by @XReydil
task.wait(5) -- loads

--// Services
local ProximityPromptService = game:GetService("ProximityPromptService")
local Modules = game:GetService("ReplicatedStorage"):WaitForChild("Modules")

--// Variables
local Functions = require(Modules:WaitForChild("PromptFuntions")) :: any

--[[Settings]]
local PROXIMITY_FUNCTIONS: {[string]: (promptinstance: ProximityPrompt, adornee: BasePart|Model)->()} = {
	["Default"] = Functions.Default,
	["Npc"] = Functions.Npc,
	["ModelFirst"] = Functions.ModelFirst,
	["OreBlock"] = _G.Prompt_OreBlock,
}

local function PromptShown(promptinstance: ProximityPrompt)
	local adornee = promptinstance:FindFirstAncestorWhichIsA("BasePart") or promptinstance:FindFirstAncestorWhichIsA("Model")
	
	PROXIMITY_FUNCTIONS[(promptinstance:GetAttribute("Type") or adornee:GetAttribute("Type")) or "Default"](promptinstance, adornee)
end

--// Initialize
ProximityPromptService.PromptShown:Connect(PromptShown)
_G.NewHighlight = Functions.newHighlight