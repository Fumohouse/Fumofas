---
-- ChannelHandler.server.lua - Instrument channel handler
--

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionSubscriber = require(ReplicatedStorage.Common.CollectionSubscriber)
local events = ReplicatedStorage.Instrument

local Channel = {}
Channel.__index = Channel

function Channel.new(name, listenerEnabled)
	local self = setmetatable({}, Channel)

	print("Channel: Created channel", name)

	self.Name = name
	self.ListenerEnabled = listenerEnabled
	self._authority = {}
	self._listeners = {}

	return self
end

function Channel:transmit(player, packets)
	local root = self._authority[player]

	if not root then
		return
	end

	if self.ListenerEnabled then
		for _, listener in pairs(self._listeners) do
			events.InstrumentRx:FireClient(listener, player, root, packets)
		end
	else
		for _, listener in pairs(Players:GetPlayers()) do
			if listener ~= player then
				events.InstrumentRx:FireClient(listener, player, root, packets)
			end
		end
	end
end

function Channel:addAuthority(auth, root)
	print("Channel: Player", auth.Name, "joined channel", self.Name, "as authority")
	self._authority[auth] = root
end

function Channel:removeAuthority(auth)
	print("Channel: Player", auth.Name, "left channel", self.Name, "as authority")
	self._authority[auth] = nil
end

function Channel:addListener(listener)
	local idx = table.find(self._listeners, listener)

	if not idx then
		self._listeners[#self._listeners + 1] = listener
	end
end

function Channel:removeListener(listener)
	local idx = table.find(self._listeners, listener)

	if idx then
		table.remove(self._listeners, idx)
	end
end

-------

local channels = {}

local subscriber = CollectionSubscriber.new("PianoSeat")

subscriber.HandleItem = function(item)
	local chanName = item:GetAttribute("Channel")
	if not chanName then
		return
	end

	local channel = channels[chanName]

	if not channel then
		channel = Channel.new(chanName)
		channels[chanName] = channel
	end

	local currentAuth

	item:GetPropertyChangedSignal("Occupant"):Connect(function()
		if currentAuth then
			channel:removeAuthority(currentAuth)
			currentAuth = nil
		end

		local occupant = item.Occupant
		if not occupant then
			return
		end

		local player = Players:GetPlayerFromCharacter(occupant.Parent)
		if player then
			channel:addAuthority(player, item)
			currentAuth = player
		end
	end)
end

subscriber:init()

events.InstrumentTx.OnServerEvent:Connect(function(player, chanName, packets)
	local channel = channels[chanName]

	if channel then
		channel:transmit(player, packets)
	end
end)
