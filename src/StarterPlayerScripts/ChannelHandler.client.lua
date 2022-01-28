---
-- ChannelHandler.client.lua - Clientside handler for channel transmission
--

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SoundPool = require(ReplicatedStorage.Common.Sound.SoundPool)
local ClientUtils = require(ReplicatedStorage.Common.ClientUtils)
local KeyboardUtils = require(ReplicatedStorage.Common.KeyboardUtils)

local soundPools = {}
local queues = {}

local offsets = {}
local keyboards = {}

-- { time, noteid }

ReplicatedStorage.Instrument.InstrumentRx.OnClientEvent:Connect(function(auth, root, packets)
	if not soundPools[root] then
		local transmitter = root
		local srcValue = root:FindFirstChild("SoundSource")
		if srcValue then
			transmitter = srcValue.Value
		end

		soundPools[root] = SoundPool.new("Piano", nil, 10, transmitter)

		local kbdValue = root:FindFirstChild("Keyboard")
		if kbdValue then
			KeyboardUtils.load(kbdValue.Value)
			keyboards[root] = kbdValue.Value
		end
	end

	if not queues[root] then
		queues[root] = packets
	else
		local q = queues[root]

		for _, packet in pairs(packets) do
			q[#q + 1] = packet
		end
	end

	if not offsets[root] or offsets[root].Authority ~= auth then
		local minTime = packets[1][1]
		for _, packet in pairs(packets) do
			if packet[1] < minTime then
				minTime = packet[1]
			end
		end

		offsets[root] = { Authority = auth, Time = minTime, PlaybackStart = tick() }
	end
end)

RunService.Stepped:Connect(function()
	for root, queue in pairs(queues) do
		local pool = soundPools[root]
		local offset = offsets[root]
		local kbd = keyboards[root]

		for idx, item in ipairs(queue) do
			if tick() - offset.PlaybackStart >= item[1] - offset.Time + 1 then
				table.remove(queue, idx)
				ClientUtils.playNoteSample(pool, item[2])

				if kbd then
					KeyboardUtils.pressNote(kbd, item[2])
				end
			end
		end
	end
end)
