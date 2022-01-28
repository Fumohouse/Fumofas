---
-- ChatV2.client.lua - Chat listeners
--

local TWEEN = game:GetService("TweenService")
local REPLICATED = game:GetService("ReplicatedStorage")
local CHAT = game:GetService("Chat")
local LocalPlayer = game.Players.LocalPlayer

local ChatObjs = REPLICATED.ChatObjs
local ChatBubble = ChatObjs.ChatBubble
local BubbleTemp = ChatObjs.BubbleTemp

local SpecialDialogues = require(script.Parent:WaitForChild("SpecialDialogues"))

local ChatEvents = REPLICATED:WaitForChild("DefaultChatSystemChatEvents")

local Silent = { "?", "!", ".", "~", ",", "'", " " }
local ExclaimTweenInfo = TweenInfo.new(2.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local BubbleLimit = 5

local function runBubble(bubbleTemp, chatBubble, character)
	local chatText = bubbleTemp.Text.Value

	-- Find dialogues
	local dialogueSV = character:FindFirstChild("Dialogue")
	local dialogueName
	if dialogueSV then
		dialogueName = dialogueSV.Value
	end

	-- Limit of 5 bubbles
	if #chatBubble:GetChildren() >= BubbleLimit then
		chatBubble:FindFirstChild("BubbleTemp"):Destroy()
	end

	-- Exclamation
	local exclaim = string.sub(chatText, -1) == "!"
	local spacing = 0.05
	if exclaim then
		bubbleTemp.BubbleText.TextColor3 = Color3.new(1, 0, 0)

		local goal = {}
		goal.TextColor3 = Color3.new(1, 1, 1)

		TWEEN:Create(bubbleTemp.BubbleText, ExclaimTweenInfo, goal):Play()
		spacing = 0.07
	end

	-- Text properties
	bubbleTemp.BubbleText.Text = chatText
	bubbleTemp.Size = bubbleTemp.Size + UDim2.fromScale(0, #chatText / 12 * 0.1)

	-- Special dialogue
	local hadDialogue = false
	if SpecialDialogues:CheckDialogue(dialogueName) then
		hadDialogue = SpecialDialogues:SpecialDialogue(character, chatText, exclaim, dialogueName)
	end

	-- Sounds
	for i = 1, #chatText, 1 do
		local char = string.sub(chatText, i, i)

		local bubbleText = bubbleTemp:FindFirstChild("BubbleText")
		if not bubbleText then
			return
		end

		bubbleText.Text = string.sub(bubbleTemp.Text.Value, 1, i)

		local silent = table.find(Silent, char)
		if not silent and not hadDialogue then
			SpecialDialogues:doSound(character, char, exclaim)
		end

		wait(spacing)
	end

	local v122 = 1 + #bubbleTemp.Text.Value * 0.1
	wait(v122)
	while true do
		wait(1)
		if chatBubble:FindFirstChild("BubbleTemp") == bubbleTemp then
			break
		end
	end
	bubbleTemp:Destroy()
end

local function doBubble(speaker, chatText)
	local character = speaker.Character
	if character then
		local chatBubble = character.Head.Head:FindFirstChild("ChatBubble")
		if not chatBubble then
			return
		end

		local bubbleTemp = BubbleTemp:Clone()
		if not chatText then
			bubbleTemp.Text.Value = "#ERROR#"
		else
			bubbleTemp.Text.Value = chatText
		end

		bubbleTemp.Parent = chatBubble
		runBubble(bubbleTemp, chatBubble, character)
	end
end

local function addChatBB(character)
	coroutine.wrap(function()
		local head = character:WaitForChild("Head")
		if head then
			local nameTag = head.Head:WaitForChild("NameTag", 5)
			if not nameTag then
				return
			end

			local chatBubble = ChatBubble:Clone()

			local function updateOffset()
				chatBubble.StudsOffset = head.Head.NameTag.StudsOffset + Vector3.new(0, 3, 0)
			end

			updateOffset()
			head.Head.NameTag:GetPropertyChangedSignal("StudsOffset"):Connect(updateOffset)

			chatBubble.Parent = head.Head
		end
	end)()
end

-- Adding chat box to characters
local function listenPlayer(player)
	local character = player.Character
	if character then
		addChatBB(character)
	end

	player.CharacterAdded:Connect(function(c)
		addChatBB(c)
	end)
end

for k, player in pairs(game.Players:GetPlayers()) do
	listenPlayer(player)
end

game.Players.PlayerAdded:Connect(function(player)
	wait(3.5)
	listenPlayer(player)
end)

local function checkClientSettings()
	local ccm = CHAT:FindFirstChild("ClientChatModules")
	if ccm then
		local chatSettings = ccm:FindFirstChild("ChatSettings")
		if not chatSettings then
			return require(chatSettings).ShowUserOwnFilteredMessage
		end
	end

	return false
end

ChatEvents:WaitForChild("OnNewMessage").OnClientEvent:connect(function(event, p2)
	local speaker = event.FromSpeaker
	local player = game.Players:FindFirstChild(speaker)
	if not player then
		return
	end

	if not event.IsFiltered and speaker == LocalPlayer.Name and checkClientSettings() then
		doBubble(player, event.Message, nil)
	end
end)

ChatEvents:WaitForChild("OnMessageDoneFiltering").OnClientEvent:connect(function(event, p2)
	local speaker = event.FromSpeaker
	local player = game.Players:FindFirstChild(speaker)
	if not player then
		return
	end

	if speaker == LocalPlayer.Name and checkClientSettings() then
		return
	end

	doBubble(player, event.Message, nil)
end)
