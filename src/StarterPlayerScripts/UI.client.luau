local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local Remotes = ReplicatedStorage:FindFirstChild('Remotes')

local CreateStar = Remotes:FindFirstChild('CreateStar')
local OrbitEvent = Remotes:FindFirstChild('Orbit')

local PlayerGui = player:WaitForChild('PlayerGui')
local Buttons = PlayerGui:WaitForChild('Buttons')
local Spawn = Buttons:WaitForChild('Spawn')

Spawn.Activated:Connect(function()
    CreateStar:FireServer()
end)