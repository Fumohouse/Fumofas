---
-- LabeledFrame.lua - Frame with label
--

local Utils = require(script.Parent.Utils)

local LabeledFrame = {}
LabeledFrame.__index = LabeledFrame

local kHeaderSize = 36

function LabeledFrame.new(title, parent, inset)
	local frame = Instance.new("Frame")
	Utils.disableBg(frame)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	frame.Size = UDim2.fromScale(1, 0)
	frame.Parent = parent

	local header = Utils.createText()
	header.TextSize = kHeaderSize / 2
	header.Size = UDim2.new(1, 0, 0, kHeaderSize)
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.TextYAlignment = Enum.TextYAlignment.Bottom
	header.Text = title
	header.Parent = frame

	local kPadding = UDim.new(0, 20)

	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingBottom = UDim.new(0, 5)
	headerPadding.PaddingLeft = kPadding
	headerPadding.Parent = header

	local internalFrame = Instance.new("Frame")
	Utils.disableBg(internalFrame)
	internalFrame.AutomaticSize = Enum.AutomaticSize.Y
	internalFrame.Position = UDim2.fromOffset(0, kHeaderSize)
	internalFrame.Size = UDim2.fromScale(1, 0)
	internalFrame.Parent = frame

	if inset then
		local padding = Instance.new("UIPadding")
		padding.PaddingLeft = kPadding
		padding.Parent = internalFrame
	end

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	listLayout.SortOrder = Enum.SortOrder.Name
	listLayout.Parent = internalFrame

	-- TODO: https://devforum.roblox.com/t/automaticsize-not-updating-when-object-is-set-to-be-visible/1164512/37
	-- Delete when issue is resolved. AutomaticSize/UIListLayout does not update. Updating it manually here:
	internalFrame.AutomaticSize = Enum.AutomaticSize.None
	frame.AutomaticSize = Enum.AutomaticSize.None
	local function updateSize()
		local contentSize = listLayout.AbsoluteContentSize
		local internalSize = UDim2.new(1, 0, 0, contentSize.Y)
		internalFrame.Size = internalSize
		frame.Size = internalSize + UDim2.fromOffset(0, kHeaderSize)
	end

	updateSize()

	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSize)
	-- ////////////////////////////// --

	return internalFrame, frame, listLayout
end

return LabeledFrame
