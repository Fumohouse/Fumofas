---
-- TimeOfDay.server.lua - Serverside tracking of time
--

local serverStart = tick()

game.ReplicatedStorage.UIRemotes.GetServerTime.OnServerInvoke = function(player)
	return tick()
end

game.ReplicatedStorage.UIRemotes.GetServerStartTime.OnServerInvoke = function(player)
	return serverStart
end
