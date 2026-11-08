--!strict
-- Sounds for server notifications and the carried robot's panic face.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

-- Built-in Studio/client sounds only (AGENTS.md rule 10).
local SOUND_IDS = {
	stolen = { id = "rbxasset://sounds/action_get_up.mp3", volume = 0.8 },
	deposited = { id = "rbxasset://sounds/action_jump_land.mp3", volume = 1 },
	scrapped = { id = "rbxasset://sounds/impact_explosion_03.mp3", volume = 0.3 },
	collected = { id = "rbxasset://sounds/volume_slider.ogg", volume = 1 },
}

local sounds: { [string]: Sound } = {}

local Feedback = {}

local function play(name: string)
	local sound = sounds[name]
	if sound ~= nil then
		sound:Play()
	end
end

local function panicFace()
	local character = Players.LocalPlayer.Character
	local carried = if character ~= nil then character:WaitForChild("CarriedRobot", 2) else nil
	local face = if carried ~= nil then carried:FindFirstChild("Face") else nil
	local label = if face ~= nil then face:FindFirstChildWhichIsA("TextLabel", true) else nil
	if label ~= nil then
		label.Text = "😱"
	end
end

function Feedback.start()
	for name, info in SOUND_IDS do
		local sound = Instance.new("Sound")
		sound.Name = `Feedback_{name}`
		sound.SoundId = info.id
		sound.Volume = info.volume
		sound.Parent = SoundService
		sounds[name] = sound
	end

	local notify = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("Notify") :: RemoteEvent
	notify.OnClientEvent:Connect(function(kind: string, data: { [string]: unknown }?)
		if kind == "stolen" then
			play("stolen")
			task.spawn(panicFace)
		elseif kind == "deposited" then
			play(if data ~= nil and data.result == "scrap" then "scrapped" else "deposited")
		elseif kind == "collected" then
			play("collected")
		end
	end)
end

return Feedback
