---
-- Piano.client.lua - Piano GUI
--

local pianoWin = script.Parent.Parent.MainGui.Piano

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = game.Players.LocalPlayer

local ClientUtils = require(ReplicatedStorage.Common.ClientUtils)
local KeyboardUtils = require(ReplicatedStorage.Common.KeyboardUtils)
local CollectionSubscriber = require(ReplicatedStorage.Common.CollectionSubscriber)
local Piano = require(ReplicatedStorage.Common.UI.Piano)
local SoundPool = require(ReplicatedStorage.Common.Sound.SoundPool)

local piano = Piano.new(pianoWin)

local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local currentTween

local function updateVis(isVisible)
	if currentTween and currentTween.PlaybackState ~= Enum.PlaybackState.Completed then
		currentTween.Completed:Wait()
	end

	local goal = {}

	if isVisible then
		goal.AnchorPoint = Vector2.new(0.5, 1)
		pianoWin.Visible = true
		piano:bindAction()
	else
		goal.AnchorPoint = Vector2.new(0.5, 0)
		piano:unbindAction()
	end

	local tween = TweenService:Create(pianoWin, tweenInfo, goal)
	tween:Play()
	currentTween = tween

	if not isVisible then
		tween.Completed:Wait()
		pianoWin.Visible = false
	end
end

local txStart = tick()
local keyboard
local channel
local seatSubscriber = CollectionSubscriber.new("PianoSeat")
seatSubscriber.HandleItem = function(item)
	local lastOccupant = item.Occupant

	item:GetPropertyChangedSignal("Occupant"):Connect(function()
		local char = LocalPlayer.Character
		if not char then
			return
		end

		local hum = char:FindFirstChildOfClass("Humanoid")

		if item.Occupant and item.Occupant == hum then
			updateVis(true)
			channel = item:GetAttribute("Channel")
		elseif lastOccupant and lastOccupant == hum then
			updateVis(false)
		end

		local kbdValue = item:FindFirstChild("Keyboard")
		if kbdValue then
			KeyboardUtils.load(kbdValue.Value)
			keyboard = kbdValue.Value
		end

		lastOccupant = item.Occupant
	end)
end

seatSubscriber:init()

local soundPool = SoundPool.new("Piano", nil, 10)
local rxQueue = {}

piano.KeyPressed.Event:Connect(function(code)
	ClientUtils.playNoteSample(soundPool, code)
	rxQueue[#rxQueue + 1] = {
		tick() - txStart,
		code,
	}

	KeyboardUtils.pressNote(keyboard, code)
end)

coroutine.wrap(function()
	while true do
		if #rxQueue > 0 then
			ReplicatedStorage.Instrument.InstrumentTx:FireServer(channel, rxQueue)
			rxQueue = {}
		end

		wait(0.25)
	end
end)()
