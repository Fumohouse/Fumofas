---
-- ModelData.lua - Store for information on all models
--

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModelData = {}

for _, targetFolder in pairs(ReplicatedStorage.Models.Parts:GetChildren()) do
	for _, scopeFolder in pairs(targetFolder:GetChildren()) do
		for _, model in pairs(scopeFolder:GetChildren()) do
			local modelInfo = {
				Target = targetFolder.Name,
				Scope = scopeFolder.Name,
				Model = model,
			}

			local appName = scopeFolder:FindFirstChild("AppearanceName")
			if appName then
				modelInfo.ScopeKey = appName.Value
			else
				modelInfo.ScopeKey = scopeFolder.Name
			end

			local exclVal = scopeFolder:FindFirstChild("MutuallyExclusive")
			if exclVal then
				modelInfo.MutuallyExclusive = exclVal.Value
			else
				modelInfo.MutuallyExclusive = false
			end

			local defaultOpts = scopeFolder:FindFirstChild("DefaultOptions")
			if defaultOpts and not model:GetAttribute("DisableInheritedOptions") then
				modelInfo.InheritedOptions = require(defaultOpts)
			end

			local opts = model:FindFirstChild("Options")
			if opts then
				modelInfo.Options = require(opts)
			end

			ModelData[#ModelData + 1] = modelInfo
		end
	end
end

return {
	findModelInfo = function(modelName)
		for _, info in pairs(ModelData) do
			if info.Model.Name == modelName then
				return info
			end
		end
	end,
}
