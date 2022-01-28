---
-- Piano.lua - Piano keyboard component
--

local ContextActionService = game:GetService("ContextActionService")
local UserInput = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Utils = require(script.Parent.Utils)

local Piano = {}
Piano.__index = Piano

-- C2 -> C7
-- MIDI range 36 -> 96
-- 61 Keys
local kNaturalCount = 36
local kSharpCount = 25
local kKeyCount = kNaturalCount + kSharpCount

-- http://www.rwgiangiulio.com/construction/manual/layout.jpg
local kNaturalAspectRatio = 22.15 / 126.27 -- width to height, white keys
local kSharpHeight = 80 / 126.27 -- height to height, white to black
local kSharpRatio = 11 / 22.15 -- width to width, black to white

local function isBlackKey(idx)
	return idx == 1 or idx == 3 or idx == 6 or idx == 8 or idx == 10
end

local tweenInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true)

local function flashKey(button)
	local goal = {}
	local guiObj = button.Button

	if button.IsSharp then
		guiObj.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		goal.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
	else
		goal.BackgroundColor3 = Color3.fromRGB(170, 170, 170)
		guiObj.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	end

	local tween = TweenService:Create(guiObj, tweenInfo, goal)
	tween:Play()
end

-- https://www.roblox.com/library/254415530/Piano-Bundle-v1-1
-- KeyCodes: 48 -> 57 numeral 97 -> 122 alpha
local kKeys = "1!2@34$5%6^78*9(0qQwWeErtTyYuiIoOpPasSdDfgGhHjJklLzZxcCvVbBnm"
local kNumCaps = ")!@#$%^&*("

function Piano.new(parent)
	local self = setmetatable({}, Piano)

	local root = Instance.new("Frame")
	Utils.disableBg(root)
	root.Size = UDim2.fromScale(1, 0)
	root.Parent = parent

	self.Root = root

	self.Root.Parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		self:_updateSize()
	end)

	self:_updateSize()

	local natIdx = 0

	local evt = Instance.new("BindableEvent")
	evt.Parent = root

	self.KeyPressed = evt
	self.Buttons = {}

	for i = 0, kKeyCount - 1 do
		local keyIdx = i % 12

		local button
		local isSharp = false

		if isBlackKey(keyIdx) then
			button = self:_createSharpKey(natIdx / kNaturalCount)
			isSharp = true
		else
			button = self:_createNaturalKey(natIdx / kNaturalCount)
			natIdx = natIdx + 1
		end

		local label = Utils.createText(Enum.Font.ArialBold)
		label.Text = string.sub(kKeys, i + 1, i + 1)
		label.TextXAlignment = Enum.TextXAlignment.Center
		label.TextYAlignment = Enum.TextYAlignment.Center
		label.Size = UDim2.fromScale(1, 0.1)
		label.Position = UDim2.fromScale(0.5, 0.85)
		label.AnchorPoint = Vector2.new(0.5, 0)
		label.TextScaled = true
		if not isSharp then
			label.TextColor3 = Color3.fromRGB(0, 0, 0)
		end

		label.Parent = button

		-- TODO: This is a hack.
		local inputSink = Instance.new("TextButton")
		inputSink.Text = ""
		Utils.disableBg(inputSink)
		inputSink.Size = UDim2.fromScale(1, 1)
		inputSink.Parent = button

		local buttonInfo = {
			Button = button,
			IsSharp = isSharp,
		}

		inputSink.MouseButton1Click:Connect(function()
			flashKey(buttonInfo)
			self.KeyPressed:Fire(i + 1)
		end)

		self.Buttons[i + 1] = buttonInfo
	end

	return self
end

function Piano:_updateSize()
	local x = self.Root.Parent.AbsoluteSize.X
	self.Root.Size = UDim2.fromOffset(x, x * (1 / (kNaturalAspectRatio * kNaturalCount)))
end

function Piano:bindAction()
	ContextActionService:BindAction("PianoKeys", function(_, state, input)
		if state == Enum.UserInputState.Begin then
			local code = input.KeyCode.Value
			local shift = UserInput:IsKeyDown(Enum.KeyCode.LeftShift) or UserInput:IsKeyDown(Enum.KeyCode.RightShift)

			local letter

			if code >= 48 and code <= 57 then -- numeral
				local str = string.char(code)
				local value = tonumber(str)

				if shift then
					letter = string.sub(kNumCaps, value + 1, value + 1)
				else
					letter = str
				end
			elseif code >= 97 and code <= 122 then -- alpha
				if shift then
					letter = input.KeyCode.Name
				else
					letter = input.KeyCode.Name:lower()
				end
			else
				return Enum.ContextActionResult.Pass
			end

			local note = string.find(kKeys, letter, 1, true)

			if note then
				flashKey(self.Buttons[note])
				self.KeyPressed:Fire(note)
				return Enum.ContextActionResult.Sink
			end
		end

		return Enum.ContextActionResult.Pass
	end, false, Enum.UserInputType.Keyboard)
end

function Piano:unbindAction()
	ContextActionService:UnbindAction("PianoKeys")
end

function Piano:_createNaturalKey(pos)
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.Size = UDim2.fromScale(1 / kNaturalCount, 1)
	frame.Position = UDim2.fromScale(pos, 0)
	frame.BorderMode = Enum.BorderMode.Inset
	frame.Parent = self.Root

	return frame
end

function Piano:_createSharpKey(pos)
	local frame = Instance.new("Frame")
	frame.BorderSizePixel = 0
	frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	frame.Size = UDim2.fromScale(1 / kNaturalCount * kSharpRatio, kSharpHeight)
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = UDim2.fromScale(pos, 0)
	frame.ZIndex = 2
	frame.Parent = self.Root

	return frame
end

return Piano
