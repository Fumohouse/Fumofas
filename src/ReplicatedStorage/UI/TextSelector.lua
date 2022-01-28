---
-- TextSelector.lua - Legacy style text button selector
--

local SelectorBase = require(script.Parent.Base.SelectorBase)
local Button = require(script.Parent.Button)
local Utils = require(script.Parent.Utils)

local TextSelector = setmetatable({}, { __index = SelectorBase })
TextSelector.__index = TextSelector

function TextSelector.new(parent, items, allowNone, allowMultiple)
    local self = setmetatable(SelectorBase.new(parent, items, allowNone, allowMultiple), TextSelector)

    self.Root.Size = UDim2.fromScale(1, 0)
    self.Root.AutomaticSize = Enum.AutomaticSize.Y

    local list = Utils.listLayout(self.Root)
    list.SortOrder = Enum.SortOrder.Name

    self.Buttons = {}

    return self
end

-- override SelectorBase
function TextSelector:updateItem(item, isActive)
    self.Buttons[item]:SetActive(isActive, true)
end

function TextSelector:loadItems()
    for _, item in pairs(self.Items) do
        local label = item

        if self.GetItemLabel then
            label = self.GetItemLabel(item)
        end

        local button = Button.new(self.Root, label)

        button.Button.MouseButton1Click:Connect(function()
            if button.IsActive then
                self:deselectItem(item)
            else
                self:selectItem(item)
            end
        end)

        self.Buttons[item] = button
    end
end

return TextSelector