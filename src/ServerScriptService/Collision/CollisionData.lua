---
-- CollisionData.lua - Management and storage of per-player collision data
--

local Physics = game:GetService("PhysicsService")

local CollisionData = {
	collisionData = {},
}

function CollisionData.updateCollision(player, part)
	if CollisionData.collisionData[player] then
		Physics:SetPartCollisionGroup(part, "CollEnabled")
	else
		Physics:SetPartCollisionGroup(part, "CollDisabled")
	end
end

return CollisionData
