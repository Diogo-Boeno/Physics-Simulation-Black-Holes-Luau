local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config            = require(ReplicatedStorage.Modules.StarConfig)
local Folder            = workspace:WaitForChild("CelestialBodies")

local G         = Config.G
local GRID_COUNT = Config.GridCount
local GRID_STEP  = Config.GridStep
local BASE_Y     = Config.BaseY
local MAX_DIP    = Config.MaxDip
local DIP_SCALE  = Config.DipScale

local gridFolder  = Instance.new("Folder")
gridFolder.Name   = "SpacetimeGrid"
gridFolder.Parent = workspace

local gridPoints = {}
local half = math.floor(GRID_COUNT / 2)

for xi = -half, half do
    for zi = -half, half do
        local p          = Instance.new("Part")
        p.Size           = Vector3.new(0.4, 0.4, 0.4)
        p.Shape          = Enum.PartType.Ball
        p.Material       = Enum.Material.Neon
        p.Color          = Color3.fromHSV(0.58, 0.85, 1)
        p.Anchored       = true
        p.CanCollide     = false
        p.CastShadow     = false
        p.Position       = Vector3.new(xi * GRID_STEP, BASE_Y, zi * GRID_STEP)
        p.Parent         = gridFolder

        table.insert(gridPoints, {
            Part  = p,
            BaseX = xi * GRID_STEP,
            BaseZ = zi * GRID_STEP,
        })
    end
end

RunService.Heartbeat:Connect(function()
    local bodies = Folder:GetChildren()

    for _, gp in ipairs(gridPoints) do
        local phi = 0

        for _, body in ipairs(bodies) do
            if not body:IsA("BasePart") then continue end

            local mass = body:GetAttribute("Mass")
            if not mass or mass == 0 then continue end

            local dx = body.Position.X - gp.BaseX
            local dz = body.Position.Z - gp.BaseZ
            local r  = math.sqrt(dx*dx + dz*dz)

            if r > 0.5 then
                phi += -G * mass / r
            end
        end

        local dip  = math.clamp(phi * DIP_SCALE, -MAX_DIP, 0)
        local t    = math.abs(dip) / MAX_DIP

        gp.Part.Color    = Color3.fromHSV(0.58 - t * 0.45, 0.9, 1)
        local curY       = gp.Part.Position.Y
        local newY       = BASE_Y + dip
        gp.Part.Position = Vector3.new(gp.BaseX, curY + (newY - curY) * 0.15, gp.BaseZ)
    end
end)