---
-- WMModule.lua - Window Manager module
--

local windowManager = script.Parent.Parent.Parent.WindowManager

local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Utils = require(ReplicatedStorage.Common.UI.Utils)

local buttonFrame = windowManager.Buttons

local windows = windowManager.Windows
local windowFrame = windowManager.WindowFrame
local contentFrame = windowFrame.Content
local titleBar = windowFrame.TitleBar

local WMModule = {
	_currentWindow = nil,
	_tween = nil,
	_windows = {},
}

WMModule.__index = WMModule

function WMModule:_cancelTween()
	if self._tween then
		self._tween:Cancel()
	end
end

function WMModule:switchWindow(windowName, toggleClose, ctx)
	local prevWindow = self._currentWindow

	local windowObj = windows:FindFirstChild(windowName)
	if toggleClose and prevWindow and windowName == prevWindow.Name then
		self:closeWindow(true)
		return
	end

	if not windowObj then
		return
	end

	local title = windowObj:GetAttribute("Title") or "??????"
	local size = windowObj:GetAttribute("RelativeSize") or Vector2.new(0.5, 0.5)

	self:closeWindow(false)
	windowFrame.Visible = true

	titleBar.Title.Text = title

	if not prevWindow then
		windowFrame.Size = UDim2.new(size.X, 0, 0, 0)
	end

	local openEvt = windowObj:FindFirstChild("Opened")
	if openEvt then
		openEvt:Fire(ctx)
	end

	self:_cancelTween()
	local goal = { Size = UDim2.new(UDim.new(size.X, 0), UDim.new(size.Y, 0) + titleBar.Size.Y) }
	local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local tween = TweenService:Create(windowFrame, tweenInfo, goal)
	tween:Play()

	self._tween = tween

	windowObj.Parent = contentFrame
	windowObj.Visible = true

	self._currentWindow = windowObj
end

function WMModule:closeWindow(shouldTween, ctx)
	local current = self._currentWindow
	if not current then
		return
	end

	local closeEvt = self._currentWindow:FindFirstChild("Closed")
	if closeEvt then
		closeEvt:Fire(ctx)
	end

	if shouldTween then
		self:_cancelTween()
		local goal = { Size = UDim2.new(windowFrame.Size.X, UDim.new(0, 0)) }
		local tweenInfo = TweenInfo.new(0.4, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
		local tween = TweenService:Create(windowFrame, tweenInfo, goal)
		tween:Play()

		self._tween = tween

		coroutine.wrap(function()
			tween.Completed:Wait()
			windowFrame.Visible = false
		end)
	end

	current.Parent = windows
	current.Visible = false

	self._currentWindow = nil
end

function WMModule:init(windowList)
	titleBar.ExitButton.MouseButton1Click:Connect(function()
		self:closeWindow(true)
	end)

	for _, windowName in ipairs(windowList) do
		local window = windows[windowName]
		local icon = window:GetAttribute("Icon") or "?"
		local createButton = window:GetAttribute("CreateButton")

		if createButton or createButton == nil then
			local button = self:addButton(icon)

			button.MouseButton1Click:Connect(function()
				self:switchWindow(window.Name, true)
			end)
		end

		self._windows[window.Name] = window
	end
end

function WMModule:getWindow(name)
	return self._windows[name]
end

function WMModule:addButton(icon)
	local button = Utils.createPaddedButton(icon, 0.2)
	button.BackgroundTransparency = 0.7
	button.BackgroundColor3 = Color3.fromRGB(39, 39, 39)
	button.BorderSizePixel = 0
	button.Size = UDim2.fromScale(1, 1)
	button.SizeConstraint = Enum.SizeConstraint.RelativeXX
	button.Parent = buttonFrame

	return button
end

function WMModule:createToggle(icon)
	local button = self:addButton(icon)
	local indicator = Utils.createIndicator(button)
	indicator.Size = UDim2.fromScale(0.25, 0.25)
	indicator.AnchorPoint = Vector2.new(0, 1)
	indicator.Position = UDim2.fromScale(1, 0)

	return button, indicator
end

return WMModule
