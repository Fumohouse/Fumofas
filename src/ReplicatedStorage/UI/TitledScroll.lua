---
-- TitledScroll.lua - ScrollingFrame with title and pinned label
--

local Utils = require(script.Parent.Utils)

local TitledScroll = {}
TitledScroll.__index = TitledScroll

local kTitleSize = 36
local kDescSize = 15

function TitledScroll.new(parent, title, desc)
	local self = setmetatable({}, TitledScroll)

	local root = Instance.new("Frame")
	Utils.disableBg(root)
	root.Size = UDim2.fromScale(1, 1)
	root.Parent = parent

	local header = Instance.new("Frame")
	Utils.disableBg(header)
	header.Size = UDim2.fromScale(1, 0)
	header.AutomaticSize = Enum.AutomaticSize.Y
	header.Parent = root

	local listLayout = Instance.new("UIListLayout")
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 5)
	listLayout.Parent = header

	local padding = Instance.new("UIPadding")
    local kPaddingVertical = UDim.new(0, 2)
	local kPadding = UDim.new(0, 10)
    padding.PaddingTop = kPaddingVertical
	padding.PaddingBottom = kPaddingVertical
	padding.PaddingLeft = kPadding
	padding.PaddingRight = kPadding
	padding.Parent = header

	local titleL = Utils.createText(Enum.Font.GothamSemibold)
	titleL.Name = "Title"
	titleL.Text = title
	titleL.TextXAlignment = Enum.TextXAlignment.Left
	titleL.TextYAlignment = Enum.TextYAlignment.Bottom
	titleL.Parent = header

	local descL
    if desc and string.len(desc) > 0 then
        descL = Utils.createText()
        descL.Name = "Description"
        descL.TextXAlignment = Enum.TextXAlignment.Left
        descL.TextYAlignment = Enum.TextYAlignment.Bottom
        descL.Text = desc
        descL.AutomaticSize = Enum.AutomaticSize.Y
        descL.Parent = header
    end

	local frame = Utils.createVerticalScroll()
	frame.AnchorPoint = Vector2.new(0, 1)
	frame.Position = UDim2.fromScale(0, 1)
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = root

	self.Root = root
	self.Scroll = frame

	self.Header = header
	self.Title = titleL
	self.Desc = descL

	self:_updateSize()

	frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		self:_updateSize()
	end)

	return self
end

function TitledScroll:_updateSize()
	local position = self.Scroll.CanvasPosition.Y / math.max(self.Scroll.AbsoluteCanvasSize.Y, 0.01)
	local prog = math.min(position / 0.1, 1)

	self.Title.Size = UDim2.new(1, 0, 0, kTitleSize):Lerp(UDim2.new(1, 0, 0, 20), prog)
	self.Title.TextSize = Utils.lerpNumber(kTitleSize * 0.8, 20, prog)

    if self.Desc then
        self.Desc.Visible = prog ~= 1

        self.Desc.Size = UDim2.new(1, 0, 0, kDescSize):Lerp(UDim2.fromScale(0, 0), prog)
        self.Desc.TextSize = Utils.lerpNumber(kDescSize, 0, prog)
    end

	self.Scroll.Size = UDim2.new(UDim.new(1, 0), UDim.new(1, -self.Header.AbsoluteSize.Y))
end

return TitledScroll
