local Star = {}
Star.__index = Star

function Star.new(model, mass)
    local self = setmetatable({}, Star)

    self.Model = model
    self.Mass = mass
    self.Vel = Vector3.zero

    return self
end

function Star:ApplyGravity(other, dt)
    if not self.Model or not other.Model then return end

    local p1 = self.Model.Position
    local p2 = other.Model.Position

    local r = p2 - p1
    local dist = r.Magnitude
    if dist < 1 then return end

    local dir = r.Unit
    local G = 1

    local force = G * (self.Mass * other.Mass) / (dist * dist)
    local accel = dir * (force / self.Mass)

    self.Vel += accel * dt
end

function Star:Update(dt)
    if not self.Model then return end
    self.Model.CFrame = self.Model.CFrame + (self.Vel * dt)
    print("Movendo estrela", self.Model.Position)
end

return Star