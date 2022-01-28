---
-- GuiInit.client.lua - Clientside initialization of GUI
--

local StarterGui = game:GetService("StarterGui")
local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
--StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)

local retries = 0

while true do
	local success = pcall(function()
		local resetEvent = Instance.new("BindableEvent")
		resetEvent.Event:Connect(function()
			ReplicatedStorage.Common.Create.Events.ResetChar:FireServer()
		end)

		StarterGui:SetCore("ResetButtonCallback", resetEvent)
	end)

	if success then
		break
	else
		retries = retries + 1
	end

	if retries > 10 then
		warn("ResetButtonCallback is taking a long time to register!")
	end

	wait(0.5)
end

local playerGui = game:GetService("Players").LocalPlayer.PlayerGui

local guis = { playerGui:WaitForChild("MainGui"), playerGui:WaitForChild("WindowManager") }

local guisEnabled = true

UserInput.InputBegan:Connect(function(input, gameHandled)
	if
		not gameHandled
		and input.UserInputType == Enum.UserInputType.Keyboard
		and not UserInput:GetFocusedTextBox()
		and input.KeyCode == Enum.KeyCode.Zero
	then
		guisEnabled = not guisEnabled

		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, guisEnabled)
		StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, guisEnabled)

		for k, v in pairs(guis) do
			v.Enabled = guisEnabled
		end
	end
end)
