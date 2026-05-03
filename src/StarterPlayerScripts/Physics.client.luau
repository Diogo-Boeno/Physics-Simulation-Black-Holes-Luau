--Physics.client.luau
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config            = require(ReplicatedStorage.Modules.StarConfig)
local Remotes           = ReplicatedStorage.Remotes
local AddStarToClient   = Remotes.AddStarToClient
local Folder            = workspace:WaitForChild("CelestialBodies")

-- ── Config ────────────────────────────────────────────────
local G        = Config.G
local c        = Config.C
local c2       = c * c
local c4       = c2 * c2
local c5       = c4 * c
local minR     = Config.MinR
local GW_SCALE = Config.GW_Scale

local stars = {}

-- ── Acelerações ───────────────────────────────────────────
local function computeAccelerations()
    local n      = #stars
    local accels = table.create(n, Vector3.zero)
    for i = 1, n do accels[i] = Vector3.zero end

    for i = 1, n do
        local A    = stars[i]
        local mA   = A.Mass
        local posA = A.Part.Position
        local vA   = A.Vel

        for j = i + 1, n do
            local B    = stars[j]
            local mB   = B.Mass
            local posB = B.Part.Position
            local vB   = B.Vel

            local rVec = posB - posA
            local r    = math.max(rVec.Magnitude, minR)
            local dir  = rVec / r
            local r2   = r * r
            local r4   = r2 * r2

            -- Newton
            local GMaGMb = G * mA * mB
            local F0     = GMaGMb / r2

            -- EIH 1PN
            local phiA = -G * mA / r
            local phiB = -G * mB / r
            local vA2  = vA:Dot(vA)
            local vB2  = vB:Dot(vB)
            local vAvB = vA:Dot(vB)
            local nVA  = dir:Dot(vA)
            local nVB  = dir:Dot(vB)

            local s_A = 1 + (1/c2) * (vA2 + 2*vB2 - 4*vAvB - (3/2)*nVB*nVB - 4*phiB + phiA)
            local s_B = 1 + (1/c2) * (vB2 + 2*vA2 - 4*vAvB - (3/2)*nVA*nVA - 4*phiA + phiB)

            local aA_mag = (F0 * s_A) / mA
            local aB_mag = (F0 * s_B) / mB

            local vec_A = (vA - vB) * (nVA - 2*nVB) * (1/c2)
            local vec_B = (vB - vA) * (nVB - 2*nVA) * (1/c2)

            local accel_A = dir * aA_mag + vec_A * (G * mB / r2)
            local accel_B = -dir * aB_mag + vec_B * (G * mA / r2)

            -- Ondas gravitacionais
            local mTot  = mA + mB
            local mu    = (mA * mB) / mTot
            local G4    = G * G * G * G
            local dEdt  = -(32/5) * (G4/c5) * (mA*mA) * (mB*mB) * mTot / r4 * GW_SCALE

            local vRel    = vB - vA
            local vRelMag = vRel.Magnitude
            if vRelMag > 0.001 then
                local dragMag = math.abs(dEdt) / (mu * vRelMag)
                local dragDir = -vRel.Unit
                accel_A = accel_A + dragDir * dragMag * (mB / mTot) / mA
                accel_B = accel_B - dragDir * dragMag * (mA / mTot) / mB
            end

            accels[i] += accel_A
            accels[j] += accel_B
        end
    end

    -- ── Confinamento ──────────────────────────────────────────
    local confRadius = Config.ConfinementRadius
    local confForce  = Config.ConfinementForce

    for i, star in ipairs(stars) do
        -- Só considera X e Z (não prende verticalmente)
        local pos  = star.Part.Position
        local flat = Vector3.new(pos.X, 0, pos.Z)
        local dist = flat.Magnitude

        if dist > confRadius then
            -- Força proporcional ao quanto passou do limite
            local excess    = dist - confRadius
            local direction = -flat.Unit  -- aponta para o centro
            accels[i]      += direction * confForce * excess
        end
    end

    return accels
end

-- ── Leapfrog ──────────────────────────────────────────────
local function leapfrogStep(dt)
    local half   = dt * 0.5
    local accels = computeAccelerations()

    for i, star in ipairs(stars) do
        star.HalfVel = star.Vel + accels[i] * half
    end

    for _, star in ipairs(stars) do
        local newPos = star.Part.Position + star.HalfVel * dt
        star.Part.CFrame = CFrame.new(newPos)
    end

    accels = computeAccelerations()
    for i, star in ipairs(stars) do
        star.Vel = star.HalfVel + accels[i] * half

        local speed = star.Vel.Magnitude
        if speed > c * 0.99 then
            star.Vel = star.Vel.Unit * (c * 0.99)
        end
    end
end

-- ── Velocidade orbital inicial ────────────────────────────
local function circularOrbitVelocity(newPos, newMass)
    if #stars == 0 then return Vector3.zero end

    local totalMass = 0
    local com       = Vector3.zero
    for _, s in ipairs(stars) do
        totalMass += s.Mass
        com       += s.Part.Position * s.Mass
    end
    com /= totalMass

    local rVec = newPos - com
    local r    = rVec.Magnitude
    if r < minR then return Vector3.zero end

    local speed = math.sqrt(G * (totalMass + newMass) / r)
    local perp  = Vector3.new(-rVec.Z, 0, rVec.X)
    if perp.Magnitude < 0.001 then perp = Vector3.new(0, 0, 1) end

    return perp.Unit * speed
end

-- ── Receber estrela ───────────────────────────────────────
AddStarToClient.OnClientEvent:Connect(function(id, partName, mass, bodyType, initVel)
    local part = Folder:WaitForChild(partName, 5)
    if not part then
        warn("[Física] Part não encontrado:", partName)
        return
    end

    local vel
    if initVel and initVel.Magnitude > 0.01 then
        -- Static (zero) ou Custom (valor do usuário)
        vel = initVel
    else
        -- Orbital → calcula velocidade circular
        vel = circularOrbitVelocity(part.Position, mass)
    end

    table.insert(stars, {
        Id       = id,
        Part     = part,
        Mass     = mass,
        BodyType = bodyType or "Star",
        Vel      = vel,
        HalfVel  = vel,
    })
end)

-- ── Loop principal ────────────────────────────────────────
RunService.Heartbeat:Connect(function(dt)
    if #stars < 2 then return end
    leapfrogStep(dt)
end)