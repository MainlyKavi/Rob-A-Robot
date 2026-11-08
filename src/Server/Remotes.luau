--!strict
-- The one place that creates remotes (ReplicatedStorage.Remotes).
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function remote(name: string): RemoteEvent
	local event = Instance.new("RemoteEvent")
	event.Name = name
	return event
end

local Remotes = {
	RequestSteal = remote("RequestSteal"), -- C->S slotId: string
	SlotChanged = remote("SlotChanged"), -- S->C slotId: string, robotId: string?
	Notify = remote("Notify"), -- S->C kind: string, data: { [string]: any }?
}

function Remotes.init()
	local folder = Instance.new("Folder")
	folder.Name = "Remotes"
	Remotes.RequestSteal.Parent = folder
	Remotes.SlotChanged.Parent = folder
	Remotes.Notify.Parent = folder
	folder.Parent = ReplicatedStorage
end

return Remotes
