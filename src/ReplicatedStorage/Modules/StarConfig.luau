return {
    -- Física
    G         = 0.06,
    C         = 120,
    MinR      = 2,
    GW_Scale  = 1e-10,   -- escala das ondas gravitacionais

    -- Estrelas
    BaseMass  = 5000,
    StarSize  = 8,

    -- Grid espaço-tempo
    GridCount = 30,
    GridStep  = 6,
    BaseY     = 0,
    MaxDip    = 20,
    DipScale  = 0.15,    -- era 0.0003, pequeno demais
}