---
-- WMScript.client.lua - Window manager initializer script
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game:GetService("Players").LocalPlayer

local WMModule = require(script.Parent.WMModule)

WMModule:init({
	"Credits",
	"Characters",
	"Editor",
})

local sitButton = WMModule:addButton("rbxassetid://6034418528")

sitButton.MouseButton1Click:Connect(function()
	local char = LocalPlayer.Character

	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")

		if hum then
			hum.Sit = not hum.Sit
		end
	end
end)

local collButton, indicator = WMModule:createToggle("rbxassetid://6023426928")

local collEnabled = true

local function updateColl()
	if collEnabled then
		indicator.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	else
		indicator.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	end
end

updateColl()

collButton.MouseButton1Click:Connect(function()
	collEnabled = not collEnabled

	ReplicatedStorage.UIRemotes.SetColl:FireServer(collEnabled)
	updateColl()
end)
