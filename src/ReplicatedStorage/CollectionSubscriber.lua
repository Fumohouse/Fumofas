---
-- CollectionSubscriber.lua - Interface to CollectionService
--

local CollectionService = game:GetService("CollectionService")

local CollectionSubscriber = {}
CollectionSubscriber.__index = CollectionSubscriber

function CollectionSubscriber.new(name)
	local self = setmetatable({}, CollectionSubscriber)

	self.Collection = name

	return self
end

function CollectionSubscriber:init()
	if self.HandleItem then
		for _, inst in pairs(self:get()) do
			self.HandleItem(inst)
		end

		CollectionService:GetInstanceAddedSignal(self.Collection):Connect(self.HandleItem)
	end

	if self.HandleItemRemoved then
		CollectionService:GetInstanceRemovedSignal(self.Collection):Connect(self.HandleItemRemoved)
	end
end

function CollectionSubscriber:get()
	return CollectionService:GetTagged(self.Collection)
end

return CollectionSubscriber
