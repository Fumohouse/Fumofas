---
-- ModelSizes.lua - All valid sizes for models, and their properties
--

return {
	Normal = {
		Scale = 1,
		CustomPhysicalProperties = PhysicalProperties.new(3.2, 0.3, 0.5, 1, 1), -- density friction elasticity frictionweight elasticityweight
	},
	Shinmy = {
		Scale = 0.71462287977761,
		CustomPhysicalProperties = PhysicalProperties.new(9, 0.3, 0.5, 1, 1),
	},
	Doll = {
		Scale = 0.5,
		CustomPhysicalProperties = PhysicalProperties.new(14, 0.3, 0.5, 1, 1),
	},
	Large = {
		Scale = 3,
		CustomPhysicalProperties = PhysicalProperties.new(2, 0.3, 0.5, 1, 1),
	},
}
