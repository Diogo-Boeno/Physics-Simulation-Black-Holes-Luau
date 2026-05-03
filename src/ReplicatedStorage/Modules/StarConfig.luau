return {
    -- Physics
    G = 0.08,
    C = 120,
    MinR = 3,
    GW_Scale = 5e-5,

    -- Grid
    GridCount = 60,
    GridStep = 6,
    BaseY = 0,
    MaxDip = 150,
    DipScale = 0.05,

    -- Confinamento
    ConfinementRadius = 80,
    ConfinementForce = 0.3,

    -- Deformação do espaço-tempo por tipo
    GridDeformation = {
        BlackHole = {
            MaxDip = 40, -- funil profundo
            DipScale = 0.08,
            Falloff = 1.8, -- quanto mais alto, mais íngreme o funil
        },
        NeutronStar = {
            MaxDip = 20,
            DipScale = 0.04,
            Falloff = 1.4,
        },
        Star = {
            MaxDip = 6,
            DipScale = 0.01,
            Falloff = 1.1,
        },
    },
    -- Tipos de corpo celeste
    Types = {
        BlackHole = {
            Color = Color3.new(0, 0, 0),
            Emission = Color3.fromRGB(255, 100, 0),
            Material = Enum.Material.Neon,
            MinSize = 3,
            MaxSize = 10,
            MinMass = 50000,
            MaxMass = 500000,
        },
        Star = {
            Color = Color3.fromRGB(255, 220, 100),
            Emission = Color3.fromRGB(255, 200, 50),
            Material = Enum.Material.Neon,
            MinSize = 6,
            MaxSize = 20,
            MinMass = 5000,
            MaxMass = 80000,
        },
        NeutronStar = {
            Color = Color3.fromRGB(150, 200, 255),
            Emission = Color3.fromRGB(100, 150, 255),
            Material = Enum.Material.Neon,
            MinSize = 2,
            MaxSize = 5,
            MinMass = 80000,
            MaxMass = 200000,
        },
    },
}