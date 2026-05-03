local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")

local CreateStar = Remotes:WaitForChild("CreateStar")
local AddStarToClient = Remotes:WaitForChild("AddStarToClient")

local Configs = require(ReplicatedStorage.Modules.StarConfig)
local Folder = workspace:WaitForChild("CelestialBodies")

local starId = 0

local function createStar()
    starId += 1

    local part = Instance.new("Part")
    part.Shape = Enum.PartType.Ball
    part.Material = Enum.Material.SmoothPlastic
    part.Color = Color3.new(1,1,1)

    part.Size = Vector3.new(8, 8, 8)
    part.Anchored = true
    part.CanCollide = false

    part.Position = Vector3.new(
        math.random(-25, 25),
        4,
        math.random(-25, 25)
    )

    part.Name = "Star_" .. starId
    part.Parent = Folder
    
    -- massa proporcional ao tamanho
    local mass = part.Size.X * Configs.BaseMass

    part:SetAttribute('Mass', mass)

    -- enviar para TODOS (para multiplayer real)
    AddStarToClient:FireAllClients(
        starId,
        part.Name,
        mass
    )
end

CreateStar.OnServerEvent:Connect(function(player)
    createStar()
end)