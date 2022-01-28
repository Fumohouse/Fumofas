---
-- ClockHandler.client.lua - Handling for clock UI
--

local clock = script.Parent.Parent.MainGui.Clock

local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local clockEvents = ReplicatedStorage.UIEvents.Clock

local kDayLength = 24 * 60 - 1

local Slider = require(ReplicatedStorage.Common.UI.Slider)
local slider = Slider.new(clock.SliderFrame)

Lighting:GetPropertyChangedSignal("TimeOfDay"):Connect(function()
	local amPm = "AM"
	if Lighting.ClockTime >= 12 then
		amPm = "PM"
	end

	local hour = math.floor(Lighting.ClockTime)
	local minute = math.floor((Lighting.ClockTime - hour) * 60)

	hour = hour % 12
	if hour == 0 then
		hour = 12
	end

	clock.Time.Text = string.format("%d:%02d %s", hour, minute, amPm)
	slider:setPosition(Lighting.ClockTime * 60 / kDayLength)
end)

function slider:HandleInput()
	clockEvents.SetTime:Fire(self.Position * kDayLength)
end

local controls = clock.Controls

controls.Pause.MouseButton1Click:Connect(function()
	clockEvents.SetTimeFrozen:Fire()
end)

controls.Sync.MouseButton1Click:Connect(function()
	clockEvents.SetTime:Fire(-1)
end)
