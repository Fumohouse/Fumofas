---
-- Button.lua - Button component w/ toggle
--

local TweenService = game:GetService("TweenService")

local Button = {
	kHeight = 30
}
Button.__index = Button

local kButtonColor = Color3.fromRGB(49, 49, 49)

function Button.new(parent, label)
	local self = setmetatable({}, Button)

	local button = Instance.new("TextButton")
	button.Name = label
	button.Text = label
	button.Size = UDim2.new(1, 0, 0, Button.kHeight)
	button.AnchorPoint = Vector2.new(0.5, 0)
	button.TextTruncate = Enum.TextTruncate.AtEnd
	button.Font = Enum.Font.Ubuntu
	button.TextSize = 24
	button.BackgroundColor3 = kButtonColor
	button.BorderColor3 = Color3.fromRGB(18, 18, 18)
	button.BorderSizePixel = 1
	button.BorderMode = Enum.BorderMode.Inset
	button.TextColor3 = Color3.fromRGB(255, 255, 255)
	button.Parent = parent

	self.Button = button

	self.IsActive = false
	self.tween = nil

	return self
end

function Button:SetActive(active, tween)
	if active == self.IsActive then
		return
	end

	local tweenInfo = TweenInfo.new(0.2)
	local goal = {}

	if active then
		goal.BackgroundColor3 = Color3.fromRGB(0, 193, 64)
	else
		goal.BackgroundColor3 = kButtonColor
	end

	if self.tween then
		self.tween:Cancel()
		self.tween:Destroy()
	end

	if tween then
		self.tween = TweenService:Create(self.Button, tweenInfo, goal)
		self.tween:Play()
	else
		self.Button.BackgroundColor3 = goal.BackgroundColor3
	end

	self.IsActive = active
end

return Button
