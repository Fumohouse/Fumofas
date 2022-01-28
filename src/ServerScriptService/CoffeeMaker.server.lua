---
-- CoffeeMaker.server.lua - Serverside handler for coffee maker
--

local coffeeMaker = workspace["LeFumo Cafe"].Furniture["Coffee Maker"]

local MugSurface = require(script.Parent.MugSurface)

local TweenService = game:GetService("TweenService")

local brewSound = coffeeMaker.Base.Brew

local surface = MugSurface.new(coffeeMaker.Base.Attachment)

local isBrewing = false
local timeInserted

function surface:reset(destroyMug)
	MugSurface.reset(surface, destroyMug)

	isBrewing = false
	timeInserted = nil
	brewSound:Stop()
end

local brewEffect = coffeeMaker.Spout.Beam

local buttonDet = coffeeMaker.Button.ClickDetector

local kBrewDuration = 5
local tweenInfo = TweenInfo.new(kBrewDuration)

buttonDet.MouseClick:Connect(function()
	if isBrewing then
		return
	end

	local level = surface.CurrentMug.CoffeeLevel.Value
	if level > 0 then
		return
	end

	isBrewing = true
	brewEffect.Enabled = true
	brewSound:Play()

	local tween = TweenService:Create(surface.CurrentMug.CoffeeLevel, tweenInfo, { Value = 100 })
	tween:Play()
	wait(kBrewDuration)

	timeInserted = tick()
	brewEffect.Enabled = false
	isBrewing = false
end)

local baseDet = coffeeMaker.BaseClickBox.ClickDetector

baseDet.MouseClick:Connect(function(player)
	if surface.CurrentMug and not isBrewing then
		surface:detach()
		return
	end

	local char = player.Character
	if not char or not char.Parent then
		return
	end

	local mug = char:FindFirstChild("Mug")
	if not mug then
		return
	end

	local level = mug.CoffeeLevel.Value
	if level > 0 then
		return
	end

	if mug and mug:IsA("Tool") then
		surface:attach(player, mug)
		timeInserted = tick()
	end
end)

coroutine.wrap(function()
	while true do
		if not isBrewing and timeInserted and tick() - timeInserted >= 10 then
			surface:detach()
		end

		wait(1)
	end
end)()
