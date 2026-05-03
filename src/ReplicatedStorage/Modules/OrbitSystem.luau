local Star = require(game.ReplicatedStorage.Modules.Star)

local OrbitSystem = {}
OrbitSystem.Stars = {}

function OrbitSystem.AddStar(model, mass)
    local s = Star.new(model, mass)
    table.insert(OrbitSystem.Stars, s)
    print('estrela adicionada', #OrbitSystem.Stars)
end

function OrbitSystem.Update(dt)
    local stars = OrbitSystem.Stars

    -- gravidade
    for i = 1, #stars do
        for j = 1, #stars do
            if i ~= j then
                stars[i]:ApplyGravity(stars[j], dt)
            end
        end
    end

    -- mover estrelas
    for _, s in ipairs(stars) do
        s:Update(dt)
    end
end

return OrbitSystem