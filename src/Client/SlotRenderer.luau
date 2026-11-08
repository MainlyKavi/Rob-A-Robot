--!strict
-- Draws this player's facility robots (client-only models) and their Steal prompts.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RobotConfigs = require(ReplicatedStorage.Shared.Config.Robots)

local models: { [string]: Model } = {} -- slotId -> model

local SlotRenderer = {}

function SlotRenderer.start()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local requestSteal = remotes:WaitForChild("RequestSteal") :: RemoteEvent
	local slotChanged = remotes:WaitForChild("SlotChanged") :: RemoteEvent
	local robotModels = ReplicatedStorage:WaitForChild("RobotModels")
	local facilities = workspace:WaitForChild("Map"):WaitForChild("Facilities")

	local folder = Instance.new("Folder")
	folder.Name = "ClientRobots"
	folder.Parent = workspace

	slotChanged.OnClientEvent:Connect(function(slotId: string, robotId: string?)
		local old = models[slotId]
		if old ~= nil then
			old:Destroy()
			models[slotId] = nil
		end
		if robotId == nil then
			return
		end
		local facilityName, partName = string.match(slotId, "^([^/]+)/(.+)$")
		local facility = if facilityName ~= nil then facilities:WaitForChild(facilityName, 10) else nil
		local slotFolder = if facility ~= nil then facility:WaitForChild("Slots", 10) else nil
		local slotPart = if slotFolder ~= nil and partName ~= nil then slotFolder:WaitForChild(partName, 10) else nil
		local template = robotModels:FindFirstChild(robotId)
		if slotPart == nil or not slotPart:IsA("BasePart") or template == nil or not template:IsA("Model") then
			return
		end
		if models[slotId] ~= nil then
			return -- a newer SlotChanged for this slot arrived while we waited
		end

		local model = template:Clone()
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				part.Anchored = true
			end
		end
		-- Robot models pivot at their feet.
		model:PivotTo(slotPart.CFrame * CFrame.new(0, slotPart.Size.Y / 2, 0))

		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Steal"
		prompt.ObjectText = RobotConfigs[robotId].name
		prompt.HoldDuration = 1
		prompt.MaxActivationDistance = 8
		prompt.RequiresLineOfSight = false
		prompt.Triggered:Connect(function()
			requestSteal:FireServer(slotId)
		end)
		prompt.Parent = model.PrimaryPart

		model.Parent = folder
		models[slotId] = model
	end)
end

return SlotRenderer
