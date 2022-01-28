---
-- RegionHandler.client.lua - Handling for region changed popup
--

local popup = script.Parent.Parent.MainGui.RegionPopup

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local currentTween

ReplicatedStorage.UIEvents.RegionChanged.Event:Connect(function(rg)
	if currentTween then
		currentTween:Cancel()
	end

	popup.AnchorPoint = Vector2.new(0.5, 1)
	popup.Text.Text = "Region Changed: " .. rg.Name
	popup.Visible = true

	currentTween = TweenService:Create(popup, tweenInfo, { AnchorPoint = Vector2.new(0.5, 0) })
	currentTween:Play()
	currentTween.Completed:Wait()

	local tween2 = TweenService:Create(popup, tweenInfo, { AnchorPoint = Vector2.new(0.5, 1) })
	currentTween = tween2
	wait(2)

	if currentTween ~= tween2 then
		return
	end

	tween2:Play()
	if tween2.Completed:Wait() == Enum.PlaybackState.Completed then
		popup.Visible = false
	end
end)
