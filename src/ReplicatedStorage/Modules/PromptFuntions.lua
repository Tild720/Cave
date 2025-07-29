--!nocheck

local Players = game:GetService("Players")
local player = Players.LocalPlayer :: Player

local module = {}
module.newHighlight = function(adornee: Instance, fillColor: Color3?, fillTransparency: number?): Highlight
	if not adornee then
		warn("Adornee hasn't been assigned.")
		return 
	end
	
	local newHighlight = Instance.new("Highlight")
	newHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
	newHighlight.FillColor = fillColor or Color3.fromRGB(230, 230, 230)
	newHighlight.FillTransparency = fillTransparency or 0.75
	newHighlight.Adornee = adornee
	newHighlight.Parent = player:WaitForChild("PlayerGui")
	
	return newHighlight
end


function module.Default(promptinstance: ProximityPrompt, adornee: Instance)
	if adornee:IsA("BasePart") and adornee.Transparency == 1 then
		return
	end

	local newHighlight = module.newHighlight(adornee)
	promptinstance.PromptHidden:Once(function()
		newHighlight:Destroy()
	end)
end

function module.Npc(promptinstance: ProximityPrompt, adornee: Instance)
	local character = (adornee.Parent:IsA("Model") and adornee.Parent:FindFirstChildOfClass("Humanoid")) and adornee.Parent or adornee
	
	local newHighlight = module.newHighlight(character)
	promptinstance.PromptHidden:Once(function()
		newHighlight:Destroy()
	end)
end

function module.ModelFirst(promptinstance: ProximityPrompt, adornee: Instance)
	local adornee = adornee:IsA("Model") and adornee or adornee:FindFirstAncestorOfClass("Model")

	local newHighlight = module.newHighlight(adornee)
	promptinstance.PromptHidden:Once(function()
		newHighlight:Destroy()
	end)
end

return module
