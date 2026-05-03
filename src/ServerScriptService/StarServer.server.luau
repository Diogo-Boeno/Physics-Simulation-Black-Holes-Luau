--StarServer.server.luau
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes           = ReplicatedStorage:WaitForChild("Remotes")
local SpawnBody         = Remotes:WaitForChild("SpawnBody")
local AddStarToClient   = Remotes:WaitForChild("AddStarToClient")
local Configs           = require(ReplicatedStorage.Modules.StarConfig)
local Folder            = workspace:WaitForChild("CelestialBodies")

local bodyId = 0

local function createBody(params)
    -- params = {
    --   bodyType  : "BlackHole" | "Star" | "NeutronStar"
    --   size      : number
    --   mass      : number
    --   position  : Vector3 (opcional)
    --   velocity  : Vector3 (opcional, para movimento inicial)
    -- }

    bodyId += 1

    local typeConfig = Configs.Types[params.bodyType] or Configs.Types.Star

    local part          = Instance.new("Part")
    part.Shape          = Enum.PartType.Ball
    part.Material       = typeConfig.Material
    part.Color          = typeConfig.Color
    part.Size           = Vector3.one * params.size
    part.Anchored       = true
    part.CanCollide     = false
    part.Name           = params.bodyType .. "_" .. bodyId
    part.Position       = params.position or Vector3.new(
        math.random(-40, 40), 12, math.random(-40, 40)
    )
    part.Parent         = Folder

    -- Guarda todos os dados como Attributes
    part:SetAttribute("Mass",         params.mass)
    part:SetAttribute("BodyType",     params.bodyType)
    part:SetAttribute("InitVelocityX", params.velocity and params.velocity.X or 0)
    part:SetAttribute("InitVelocityY", params.velocity and params.velocity.Y or 0)
    part:SetAttribute("InitVelocityZ", params.velocity and params.velocity.Z or 0)

    task.wait(0.1)

    AddStarToClient:FireAllClients(
        bodyId,
        part.Name,
        params.mass,
        params.bodyType,
        params.velocity or Vector3.zero
    )
end

SpawnBody.OnServerEvent:Connect(function(player, params)
    -- Validação básica
    local bodyType = params.bodyType
    if not Configs.Types[bodyType] then return end

    local typeConfig = Configs.Types[bodyType]
    local size = math.clamp(params.size, typeConfig.MinSize, typeConfig.MaxSize)
    local mass = math.clamp(params.mass, typeConfig.MinMass, typeConfig.MaxMass)

    createBody({
        bodyType = bodyType,
        size     = size,
        mass     = mass,
        position = params.position,
        velocity = params.velocity,
    })
end)