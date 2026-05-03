local Formulas = {}

function BlackHoleFormula(r:number, s:number)
    local c = (3*(10^8))
end

local function getOppositeCFrame(cf: CFrame, flip: boolean)
    if not flip then return cf end
    local p = cf.Position
    return CFrame.new(-p.X, p.Y, p.Z)
end

return Formulas