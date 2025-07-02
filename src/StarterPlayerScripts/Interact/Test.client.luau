repeat task.wait() until game:IsLoaded()

local ReplicatedStorage = game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("TextModule")
local Players = game:GetService("Players")

-- Require text module
-- For more configuration, read the text module.
local Text = require(ReplicatedStorage.Text)

-- Create the text gui that the text must be parented to.
local TextGUI = Text.GetTextGUI(1)

-- Parent the text gui
TextGUI.Parent = Players.LocalPlayer.PlayerGui

-- Let's create a testing text.
local text = Text.new("November", true)
--[[
	@param [font_name: string] The name of the font to use. Found in the "Fonts" folder under the text module.
	@param [automatic_update: bool] Whether or not to automatically update the text every render step.
	If you choose not to update the text automatically, you will need to manually call text:Update(delta_time) whenever necessary.
	
	@returns [text: Text]
]]

-- Parent the text to the text gui
text.Parent = TextGUI.TextParent

-- Position the text in the center.
text.Position = Text.GetVirtualResolution() / 2

-- Center the text.
text.TextCentered = true

-- Set the text size. This is a factor of scale.
text.TextSize = 2.3

-- Display some text.
text.Text = "Hello World!"