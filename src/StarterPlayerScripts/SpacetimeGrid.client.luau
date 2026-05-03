local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config = require(ReplicatedStorage.Modules.StarConfig)
local Folder = workspace:WaitForChild("CelestialBodies")

local GRID_COUNT = Config.GridCount
local GRID_STEP = Config.GridStep
local BASE_Y = Config.BaseY
local G = Config.G

local gridFolder = Instance.new("Folder")
gridFolder.Name = "SpacetimeGrid"
gridFolder.Parent = workspace

local gridPoints = {}
local half = math.floor(GRID_COUNT / 2)

for xi = -half, half do
    for zi = -half, half do
        local p = Instance.new("Part")
        p.Size = Vector3.new(0.4, 0.4, 0.4)
        p.Shape = Enum.PartType.Ball
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromHSV(0.58, 0.85, 1)
        p.Anchored = true
        p.CanCollide = false
        p.CastShadow = false
        p.Position = Vector3.new(xi * GRID_STEP, BASE_Y, zi * GRID_STEP)
        p.Parent = gridFolder

        table.insert(gridPoints, {
            Part = p,
            BaseX = xi * GRID_STEP,
            BaseZ = zi * GRID_STEP,
            CurrentY = BASE_Y,
        })
    end
end

RunService.Heartbeat:Connect(function()
    local bodies = Folder:GetChildren()

    for _, gp in ipairs(gridPoints) do
        local totalDip = 0

        for _, body in ipairs(bodies) do
            if not body:IsA("BasePart") then continue end

            local mass = body:GetAttribute("Mass")
            local bodyType = body:GetAttribute("BodyType") or "Star"
            if not mass or mass == 0 then continue end

            local def = Config.GridDeformation[bodyType]
            if not def then continue end

            local dx = body.Position.X - gp.BaseX
            local dz = body.Position.Z - gp.BaseZ
            local r = math.sqrt(dx*dx + dz*dz)
            if r < 0.5 then r = 0.5 end

            -- Forma de funil: phi ∝ -1/r^falloff
            -- Falloff alto = mais íngreme perto do centro (buraco negro)
            -- Falloff baixo = curva suave (estrela)
            local phi = -G * mass / (r ^ def.Falloff)
            local dip = math.clamp(phi * def.DipScale, -def.MaxDip, 0)

            totalDip += dip
        end

        -- Clamp total para não ultrapassar o maior MaxDip
        totalDip = math.clamp(totalDip, -Config.GridDeformation.BlackHole.MaxDip, 0)

        -- Cor: azul - violeta - vermelho conforme deformação
        local t = math.abs(totalDip) / Config.GridDeformation.BlackHole.MaxDip
        gp.Part.Color = Color3.fromHSV(
            0.58 - t * 0.58, -- azul - vermelho
            0.7 + t * 0.3,
            1
        )

        -- Atualiza Y suavemente
        local targetY = BASE_Y + totalDip
        gp.CurrentY = gp.CurrentY + (targetY - gp.CurrentY) * 0.12
        gp.Part.Position = Vector3.new(gp.BaseX, gp.CurrentY, gp.BaseZ)
    end
end)