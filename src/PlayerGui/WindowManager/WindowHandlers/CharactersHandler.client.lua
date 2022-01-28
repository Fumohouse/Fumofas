---
-- CharactersHandler.lua - Handler for character selector
--

local WMModule = require(script.Parent.Parent.WMModule)
local characters = WMModule:getWindow("Characters")

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Create = ReplicatedStorage.Common.Create

local UI = ReplicatedStorage.Common.UI
local Button = require(UI.Button)
local Utils = require(UI.Utils)
local TabControl = require(UI.TabControl)

local kPages = {
    "Preset",
    "Custom"
}

local contentFrame = Instance.new("Frame")
Utils.disableBg(contentFrame)
contentFrame.Size = UDim2.new(1, 0, 1, -Button.kHeight - 5)
contentFrame.Position = UDim2.fromScale(0, 1)
contentFrame.AnchorPoint = Vector2.new(0, 1)
contentFrame.Parent = characters

local pageLayout = Instance.new("UIPageLayout")
pageLayout.Animated = false
pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
pageLayout.FillDirection = Enum.FillDirection.Horizontal
pageLayout.Parent = contentFrame

local pageFrames = {}
for _, pageName in ipairs(kPages) do
    local scroll = Utils.createVerticalScroll()
    scroll.Parent = contentFrame

    local list = Utils.listLayout(scroll)
    list.SortOrder = Enum.SortOrder.Name

    pageFrames[pageName] = scroll
end

local tabControl = TabControl.new(characters, kPages, false, false)

tabControl.ItemSelected.Event:Connect(function(item)
    pageLayout:JumpTo(pageFrames[item])
end)

tabControl:loadItems()
tabControl:setSelection({ kPages[1] })

local characterButtons = {}

local function addCharacterButton(category, name, id, isPreset)
	local buttonInfo = Button.new(pageFrames[category], name)
	local button = buttonInfo.Button
	button.MouseButton1Click:Connect(function()
		WMModule:switchWindow("Editor", false, {
			Name = name,
			Id = id,
			Preset = isPreset,
		})
	end)

	characterButtons[id] = button
end

local saveEvt = script.Parent.Events.CharSaved
saveEvt.Event:Connect(function(id)
    if not characterButtons[id] then
        addCharacterButton("Custom", "Custom "..id, id)
    end
end)

Create.Events.LoadPresets.OnClientEvent:Connect(function(presets)
	for name, id in pairs(presets) do
		addCharacterButton("Preset", name, id, true)
	end
end)
