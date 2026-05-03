-- local RunService = game:GetService("RunService")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local Remotes = ReplicatedStorage.Remotes

-- local AddStarToClient = Remotes.AddStarToClient

-- -- Constantes fundamentais
-- local G = 0.06        -- gravidade do seu universo
-- local c = 120         -- "velocidade da luz" local (ajustável)
-- local vMax = c * 0.95 -- limite de velocidade para estabilizar
-- local minR = 2        -- distância mínima entre estrelas (evita NaN)

-- local stars = {}

-- -----------------------------------------------------------
-- -- RECEBER ESTRELAS DO SERVIDOR
-- -----------------------------------------------------------
-- local Folder = workspace:WaitForChild("CelestialBodies")

-- AddStarToClient.OnClientEvent:Connect(function(id, partName, mass)
--     -- buscar a instância real pelo nome
--     local part = Folder:WaitForChild(partName, 5)
--     if not part then
--         warn("Parte não encontrada:", partName)
--         return
--     end

--     table.insert(stars, {
--         Id   = id,
--         Part = part,
--         Mass = mass,
--         Vel  = Vector3.zero,
--     })
-- end)

-- -----------------------------------------------------------
-- -- FÍSICA RELATIVÍSTICA – LOOP
-- -----------------------------------------------------------
-- RunService.Heartbeat:Connect(function(dt)
--     if #stars < 2 then return end

--     -------------------------------------------------------
--     -- 1) GRAVITAÇÃO + CORREÇÕES RELATIVÍSTICAS
--     -------------------------------------------------------
--     for i = 1, #stars do
--         local A = stars[i]
--         local posA = A.Part.Position

--         for j = i + 1, #stars do
--             local B = stars[j]
--             local posB = B.Part.Position

--             local rVec = posB - posA
--             local r = rVec.Magnitude

--             -- Proteção contra valores perigosamente pequenos
--             if r < minR then
--                 r = minR
--             end

--             local dir = rVec.Unit

--             ---------------------------------------------------
--             -- (1) Gravidade clássica
--             ---------------------------------------------------
--             local F_classic = (G * A.Mass * B.Mass) / (r * r)

--             ---------------------------------------------------
--             -- (2) Correção relativística (1ª ordem GR)
--             --     termo:   3 * G * M * L² / (c² * m * r⁴)
--             ---------------------------------------------------

--             -- momento angular L = m * |r × v|
--             local L2_A = (rVec:Cross(A.Vel)).Magnitude^2 * (A.Mass * A.Mass)
--             local L2_B = (rVec:Cross(B.Vel)).Magnitude^2 * (B.Mass * B.Mass)

--             -- termo relativístico
--             local F_rel_A = (3 * G * B.Mass * L2_A) / ((c*c) * A.Mass * (r^4))
--             local F_rel_B = (3 * G * A.Mass * L2_B) / ((c*c) * B.Mass * (r^4))

--             ---------------------------------------------------
--             -- (3) Força total
--             ---------------------------------------------------
--             local F_total_A = F_classic + F_rel_A
--             local F_total_B = F_classic + F_rel_B

--             -- acelerações
--             local accelA =  dir * (F_total_A / A.Mass)
--             local accelB = -dir * (F_total_B / B.Mass)

--             -- aplica aceleração
--             A.Vel += accelA * dt
--             B.Vel += accelB * dt

--             ---------------------------------------------------
--             -- (4) LIMITAR VELOCIDADE → evita explosões
--             ---------------------------------------------------
--             if A.Vel.Magnitude > vMax then
--                 A.Vel = A.Vel.Unit * vMax
--             end
--             if B.Vel.Magnitude > vMax then
--                 B.Vel = B.Vel.Unit * vMax
--             end
--         end
--     end

--     -------------------------------------------------------
--     -- 2) ATUALIZAÇÃO DE POSIÇÃO (ANCORADO, MAS MÓVEL)
--     -------------------------------------------------------
--     for _, star in ipairs(stars) do
--         local newPos = star.Part.Position + star.Vel * dt
--         star.Part.CFrame = CFrame.new(newPos)
--     end
-- end)