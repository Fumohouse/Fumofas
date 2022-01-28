---
-- Mug.client.lua - Mug liquid level handling
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local CollectionService = game:GetService("CollectionService")
local LocalPlayer = game.Players.LocalPlayer

local CollectionSubscriber = require(ReplicatedStorage.Common.CollectionSubscriber)
local ClientUtils = require(ReplicatedStorage.Common.ClientUtils)
local subscriber = CollectionSubscriber.new("ItemMug")

local coasterSubscriber = CollectionSubscriber.new("Coaster")
local coasters = {}

coasterSubscriber.HandleItem = function(coaster)
	coasters[#coasters + 1] = coaster.Parent
end

coasterSubscriber:init()

local levels = {}

subscriber.HandleItem = function(mug)
	if mug:GetAttribute("Owner") == LocalPlayer.UserId then
		-- REMOTES
		-- Drink: To server - requests to drink; To client - plays animation
		-- Drank: To server - reduces liquid level; To client - stops animation

		local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

		local anim = humanoid.Animator:LoadAnimation(mug:WaitForChild("CoffeeHold"))
		local animDrink = humanoid.Animator:LoadAnimation(mug:WaitForChild("CoffeeDrink"))

		local coffeeLevel = mug:WaitForChild("CoffeeLevel")
		local drinkEvent = mug:WaitForChild("Drink")
		local drankEvent = mug:WaitForChild("Drank")

		animDrink.KeyframeReached:Connect(function(name)
			if name == "Drank" then
				drankEvent:FireServer()
			end
		end)

		local function handleAction(name, state, input)
			if name ~= "MugDrink" or state ~= Enum.UserInputState.Begin then
				return Enum.ContextActionResult.Pass
			end

			-- WHY
			local raycastParams = RaycastParams.new()
			raycastParams.FilterDescendantsInstances = coasters
			raycastParams.FilterType = Enum.RaycastFilterType.Whitelist

			local result = ClientUtils.raycast(input.Position, raycastParams)

			if result and result.Instance and CollectionService:HasTag(result.Instance, "Coaster") then
				return Enum.ContextActionResult.Pass
			end

			if mug:GetAttribute("Equipped") and coffeeLevel.Value > 0 then
				drinkEvent:FireServer()
				return Enum.ContextActionResult.Sink
			end

			return Enum.ContextActionResult.Pass
		end

		mug.AttributeChanged:Connect(function(attribute)
			if attribute == "Equipped" then
				local equipped = mug:GetAttribute("Equipped")

				if equipped then
					if coffeeLevel.Value > 0 then
						anim:Play()
					end

					ContextActionService:BindAction(
						"MugDrink",
						handleAction,
						false,
						Enum.UserInputType.MouseButton1,
						Enum.UserInputType.Touch
					)
				else
					anim:Stop()
					animDrink:Stop()

					ContextActionService:UnbindAction("MugDrink")
				end
			end
		end)

		mug.Drink.OnClientEvent:Connect(function()
			animDrink:Play()
		end)

		mug.Drank.OnClientEvent:Connect(function()
			anim:Stop()
		end)
	end

	local model = mug:WaitForChild("Coffee")
	local liquid = model:WaitForChild("Liquid")
	local liquidTex = liquid.Texture
	local liquidMotor = model.Cup.Liquid
	local steam = liquid.Steam.ParticleEmitter

	local function updateLevel()
		local level = mug.CoffeeLevel.Value / 100

		if level == 0 then
			liquid.Transparency = 1
			liquidTex.Transparency = 1
			steam.Enabled = false
		else
			liquid.Transparency = 0
			liquidTex.Transparency = 0
			steam.Enabled = true

			local motorOffset = liquidMotor.C0 * liquidMotor.C1:Inverse()
			local maxHeight = 0.95 * model.Cup.Size.X + motorOffset.Position.X

			levels[mug] = CFrame.new(maxHeight * level, 0, 0)
		end
	end

	mug:WaitForChild("CoffeeLevel").Changed:Connect(updateLevel)

	-- update order matters, so fire on all 3 of them
	model.Cup:GetPropertyChangedSignal("Size"):Connect(updateLevel)
	liquidMotor:GetPropertyChangedSignal("C0"):Connect(updateLevel)
	liquidMotor:GetPropertyChangedSignal("C1"):Connect(updateLevel)

	updateLevel()
end

subscriber.HandleItemRemoved = function(mug)
	levels[mug] = nil
end

subscriber:init()

RunService.Stepped:Connect(function()
	for _, inst in pairs(subscriber:get()) do
		if levels[inst] then
			pcall(function() -- the check for liquid may fail after reset (when all joints are destroyed)
				local liquidMotor = inst.Coffee.Cup.Liquid
				liquidMotor.Transform = levels[inst]
			end)
		end
	end
end)
