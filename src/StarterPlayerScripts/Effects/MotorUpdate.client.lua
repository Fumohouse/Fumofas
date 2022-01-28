---
-- MotorUpdate.client.lua - Clientside handling for tweening motors
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local tweens = {}

ReplicatedStorage.MotorUpdate.OnClientEvent:Connect(function(motor, transform)
	if tweens[motor] then
		tweens[motor]:Cancel()
	end

	local tween = TweenService:Create(motor, tweenInfo, { Transform = transform })
	tweens[motor] = tween
	tween:Play()
end)
