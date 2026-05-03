local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Folder = workspace:WaitForChild("CelestialBodies")

local BH_TEMPLATE = ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Black Hole")

local tracked = {}
local vfxLinks = {}  -- { part, sphere } para atualizar no loop

local function applyBlackHoleVFX(part)
    local vfx = BH_TEMPLATE:Clone()
    local sphere = vfx:WaitForChild("sphere")

    local scale  = part.Size.X / sphere.Size.X
    vfx:ScaleTo(scale)

    sphere.CFrame   = part.CFrame
    part.Transparency = 1

    vfx.Parent = workspace

    -- Registra par para seguir no loop
    table.insert(vfxLinks, { Part = part, Sphere = sphere, Model = vfx })
end

local function applyStarVFX(part)
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255, 220, 100)
    light.Brightness = 5
    light.Range = part.Size.X * 8
    light.Parent = part

    local att = Instance.new("Attachment")
    att.Parent = part

    local emit = Instance.new("ParticleEmitter")
    emit.Parent = att
    emit.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 200)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 50)),
        ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 100, 0)),
    })
    emit.LightEmission  = 1
    emit.LightInfluence = 0
    emit.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(1, 0),
    })
    emit.Speed = NumberRange.new(part.Size.X * 0.3, part.Size.X * 0.8)
    emit.Rate = 40
    emit.Lifetime = NumberRange.new(1, 2)
    emit.SpreadAngle = Vector2.new(180, 180)
end

local function applyNeutronVFX(part)
    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(150, 200, 255)
    light.Brightness = 12
    light.Range = part.Size.X * 10
    light.Parent = part
end

local function applyVFX(part)
    local bodyType = part:GetAttribute("BodyType")
    if bodyType == "BlackHole" then
        applyBlackHoleVFX(part)
    elseif bodyType == "Star" then
        applyStarVFX(part)
    elseif bodyType == "NeutronStar" then
        applyNeutronVFX(part)
    end
end

-- ── Detectar corpos ───────────────────────────────────────
Folder.ChildAdded:Connect(function(child)
    if not child:IsA("BasePart") then return end
    if tracked[child] then return end
    tracked[child] = true
    task.wait(0.15)
    applyVFX(child)
end)

for _, child in ipairs(Folder:GetChildren()) do
    if child:IsA("BasePart") and not tracked[child] then
        tracked[child] = true
        applyVFX(child)
    end
end

-- Loop: VFX segue a part + pulsar 
local time = 0
RunService.Heartbeat:Connect(function(dt)
    time += dt

    -- VFX do buraco negro segue a part
    for i = #vfxLinks, 1, -1 do
        local link = vfxLinks[i]

        -- Limpa entradas inválidas
        if not link.Part.Parent or not link.Sphere.Parent then
            link.Model:Destroy()
            table.remove(vfxLinks, i)
            continue
        end

        link.Sphere.CFrame = link.Part.CFrame
    end

    -- Pulsar NeutronStar
    for _, child in ipairs(Folder:GetChildren()) do
        if child:GetAttribute("BodyType") == "NeutronStar" then
            local light = child:FindFirstChildOfClass("PointLight")
            if light then
                light.Brightness = 8 + math.sin(time * 10) * 6
            end
        end
    end
end)