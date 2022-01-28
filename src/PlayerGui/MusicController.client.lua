---
-- MusicController.client.lua - Handling for music controller UI
--

local controller = script.Parent.Parent.MainGui.MusicController

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Slider = require(ReplicatedStorage.Common.UI.Slider)

local kAnchorVisible = Vector2.new(0, 1)
local kAnchorInvisible = Vector2.new(1, 1)

local popupOverride = true

local isVisible = controller.AnchorPoint == kAnchorVisible

local function setVisible(visible)
	local tweenInfo
	local goal

	if visible then
		tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		goal = { AnchorPoint = kAnchorVisible }
	else
		tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		goal = { AnchorPoint = kAnchorInvisible }
	end

	local tween = TweenService:Create(controller, tweenInfo, goal)
	tween:Play()

	isVisible = visible
end

local popupVisibleTime = 0
local currentSong
local currentSound

local marqueeFrame = controller.Marquee
local marqueeText = marqueeFrame.Text

local marqueeTween
local marqueeSignal

local function updateSong(song, sound)
	currentSong = song
	currentSound = sound

	if marqueeTween then
		marqueeSignal:Disconnect()
		marqueeTween:Cancel()
	end

	marqueeText.Text = "Now Playing: " .. currentSong.Name

	if marqueeText.AbsoluteSize.X > marqueeFrame.AbsoluteSize.X then
		local tweenInfo = TweenInfo.new(
			5 * string.len(marqueeText.Text) / 25,
			Enum.EasingStyle.Linear,
			Enum.EasingDirection.In
		)

		local function tweenMarquee()
			marqueeText.Position = UDim2.fromScale(1, 0)
			local tween = TweenService:Create(
				marqueeText,
				tweenInfo,
				{ Position = UDim2.fromOffset(-marqueeText.AbsoluteSize.X, 0) }
			)
			tween:Play()

			marqueeSignal = tween.Completed:Connect(function()
				tween:Destroy()
				tweenMarquee()
			end)

			marqueeTween = tween
		end

		tweenMarquee()
	else
		marqueeText.Position = UDim2.fromScale(0, 0)
	end

	if not isVisible then
		popupOverride = false
		setVisible(true)
	end

	if popupVisibleTime == 0 then
		popupVisibleTime = 5

		coroutine.wrap(function()
			while popupVisibleTime > 0 and not popupOverride do
				popupVisibleTime = popupVisibleTime - 1
				wait(1)
			end

			if not popupOverride then
				setVisible(false)
			end

			popupVisibleTime = 0
		end)()
	else
		popupVisibleTime = 5
	end
end

ReplicatedStorage.UIEvents.SongChanged.Event:Connect(updateSong)

local song, sound = ReplicatedStorage.UIEvents.GetSong:Invoke()
updateSong(song, sound)

controller.ImageButton.MouseButton1Click:Connect(function()
	setVisible(not isVisible)
	popupOverride = true
end)

-- Controls

local controlsFrame = controller.Controls

controlsFrame.Play.MouseButton1Click:Connect(function()
	ReplicatedStorage.UIEvents.SetPaused:Fire()
	popupOverride = true
end)

controlsFrame.Prev.MouseButton1Click:Connect(function()
	ReplicatedStorage.UIEvents.AdvancePlaylist:Fire(-1)
	popupOverride = true
end)

controlsFrame.Next.MouseButton1Click:Connect(function()
	ReplicatedStorage.UIEvents.AdvancePlaylist:Fire(1)
	popupOverride = true
end)

local progressBarFrame = controller.Progress
local slider = Slider.new(progressBarFrame, nil, true)

slider.HandleInput = function()
	currentSound.TimePosition = slider.Position * currentSound.TimeLength
end

RunService.Stepped:Connect(function()
	if currentSound then
		slider:setPosition(currentSound.TimePosition / currentSound.TimeLength)
	else
		slider:setPosition(0)
	end
end)
