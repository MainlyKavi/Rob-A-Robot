--!strict
-- Plot assignment, spawning at the plot, and pad visuals.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local EconomyConfig = require(ReplicatedStorage.Shared.Config.Economy)
local PlayerData = require(script.Parent.PlayerData)
local Types = require(ReplicatedStorage.Shared.Types)

local playerPlots: { [Player]: Model } = {}
local plotOwners: { [Model]: Player } = {}

local Bases = {}

local function plotsFolder(): Instance
	return workspace:WaitForChild("Map"):WaitForChild("Plots")
end

local function setSign(plot: Model, text: string)
	local sign = plot:FindFirstChild("Sign")
	local label = if sign ~= nil then sign:FindFirstChildWhichIsA("TextLabel", true) else nil
	if label ~= nil then
		label.Text = text
	end
end

-- Shows the first padCount pads and puts a server-built robot model on each filled pad.
local function drawPads(plot: Model, padCount: number, robots: { Types.RobotEntry })
	local pads = plot:FindFirstChild("Pads")
	if pads == nil then
		return
	end
	local models = ReplicatedStorage:FindFirstChild("RobotModels")
	for index = 1, EconomyConfig.maxPads do
		local pad = pads:FindFirstChild(`Pad{index}`)
		if pad == nil or not pad:IsA("BasePart") then
			continue
		end
		local shown = index <= padCount
		pad.Transparency = if shown then 0 else 1
		pad.CanCollide = shown

		local entry = robots[index]
		local existing = pad:FindFirstChild("Robot")
		if existing ~= nil and (entry == nil or existing:GetAttribute("RobotId") ~= entry.id) then
			existing:Destroy()
			existing = nil
		end
		local template = if entry ~= nil and models ~= nil then models:FindFirstChild(entry.id) else nil
		if existing == nil and entry ~= nil and template ~= nil and template:IsA("Model") then
			local model = template:Clone()
			model.Name = "Robot"
			model:SetAttribute("RobotId", entry.id)
			for _, part in model:GetDescendants() do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end
			-- Robot models pivot at their feet.
			model:PivotTo(pad.CFrame * CFrame.new(0, pad.Size.Y / 2, 0))
			model.Parent = pad
		end
	end
end

local function resetPlot(plot: Model)
	drawPads(plot, EconomyConfig.startPads, {})
	setSign(plot, "Free plot")
end

function Bases.getPlot(player: Player): Model?
	return playerPlots[player]
end

function Bases.refreshPads(player: Player)
	local plot = playerPlots[player]
	local data = PlayerData.get(player)
	if plot ~= nil and data ~= nil then
		drawPads(plot, data.padCount, data.robots)
	end
end

local function freePlot(): Model?
	local plots = plotsFolder()
	for index = 1, 8 do
		local plot = plots:FindFirstChild(`Plot{index}`)
		if plot ~= nil and plot:IsA("Model") and plotOwners[plot] == nil then
			return plot
		end
	end
	return nil
end

local function assign(player: Player)
	local plot = freePlot()
	if plot == nil then
		player:Kick("Server full, please rejoin.")
		return
	end
	playerPlots[player] = plot
	plotOwners[plot] = player
	player:SetAttribute("Plot", plot.Name)
	local spawn = plot:FindFirstChild("Spawn")
	if spawn ~= nil and spawn:IsA("SpawnLocation") then
		player.RespawnLocation = spawn
	end
	setSign(plot, player.DisplayName)
	Bases.refreshPads(player)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid") :: Humanoid
		humanoid.Died:Connect(function()
			task.wait(Players.RespawnTime)
			if player.Parent ~= nil and playerPlots[player] == plot then
				player:LoadCharacter()
			end
		end)
	end)
	player:LoadCharacter()
end

function Bases.start()
	Players.CharacterAutoLoads = false
	for _, plot in plotsFolder():GetChildren() do
		if plot:IsA("Model") then
			resetPlot(plot)
		end
	end
	PlayerData.onLoaded(assign)
	PlayerData.onRemoving(function(player)
		local plot = playerPlots[player]
		if plot == nil then
			return
		end
		playerPlots[player] = nil
		plotOwners[plot] = nil
		resetPlot(plot)
	end)
end

return Bases
