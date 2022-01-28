---
-- Clock.client.lua - Clientside tracking of time
--

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local kStartSeconds = 420 -- 7AM
local localOffset = 0

local offset = ReplicatedStorage.UIRemotes.GetServerTime:InvokeServer() - tick() -- timezones
local serverStartTime = ReplicatedStorage.UIRemotes.GetServerStartTime:InvokeServer()

local advanceTime = true

-- get the current server time
local function getTime()
	return tick() - serverStartTime + offset + kStartSeconds
end

local function updateTime()
	Lighting:SetMinutesAfterMidnight(getTime() + localOffset)
end

RunService.Stepped:Connect(function()
	if advanceTime then
		updateTime()
	end
end)

local events = ReplicatedStorage.UIEvents.Clock

events.SetTime.Event:Connect(function(t)
	if t < 0 then
		localOffset = 0
		advanceTime = true

		return
	end

	localOffset = t - getTime()
	updateTime()
end)

events.SetTimeFrozen.Event:Connect(function(frozen)
	if frozen == nil then
		frozen = advanceTime
	end

	advanceTime = not frozen

	if not advanceTime then
		localOffset = Lighting.ClockTime * 60 - getTime()
	end
end)
