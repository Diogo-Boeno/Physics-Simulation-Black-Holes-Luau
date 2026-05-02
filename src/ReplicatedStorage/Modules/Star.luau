local Star = {}
Star.__index = Star

local Properties = {
    Path = workspace,
    Name = 'Star',
    PartType = Enum.PartType.Ball,

    Anchored = true,

    Color = BrickColor.new('White'),
    Size = Vector3.new(10, 10, 10),
    CFrame = CFrame.new(10, 10, 0),
    Material = Enum.Material.SmoothPlastic
}

function Star.new()
    local self = setmetatable({}, Star)
    local p = Properties

    self.Model = Instance.new('Part')
    self.Model.Parent = p.Path
    self.Model.Name = p.Name
    self.Model.Shape = p.PartType
    self.Model.Size = p.Size
    self.Model.CFrame = p.CFrame
    self.Model.BrickColor = p.Color
    self.Model.Anchored = p.Anchored
    self.Model.Material = p.Material

    return self
end

return Star