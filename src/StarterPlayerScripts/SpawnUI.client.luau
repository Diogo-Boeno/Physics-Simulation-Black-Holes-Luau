local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService  = game:GetService("UserInputService")
local Config = require(ReplicatedStorage.Modules.StarConfig)

local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local SpawnBody = ReplicatedStorage.Remotes:WaitForChild("SpawnBody")

-- ── Referências da UI ──────────────────────────────────────
local screenGui   = PlayerGui:WaitForChild("SpawnUI")
local spawnerBg   = screenGui:WaitForChild("SpawnerBg")

-- Botões de Tipo v
local typeButtons = {
    BlackHole = spawnerBg:WaitForChild("BlackHole"),
    Star = spawnerBg:WaitForChild("Star"),
    NeutronStar = spawnerBg:WaitForChild("NeutronStar")
}

-- Botões de Movimento
local movButtons = {
    Orbital = spawnerBg:WaitForChild("OrbitalMovement"),
    Still = spawnerBg:WaitForChild("StillMovement"),
    Custom = spawnerBg:WaitForChild("CustomMovement")
}

local customPanel = spawnerBg:WaitForChild("CustomMovementAdjuster")
local spawnBtn = spawnerBg:WaitForChild("Spawn")

-- Estado Atual  
local state = {
    bodyType = "BlackHole",
    size = 4,
    mass = 150000,
    movement = "Orbital",
}

-- ── Lógica de Sliders Reutilizável ──────────────────────────
local function setupSlider(sliderFrame, labelName, minVal, maxVal, default, onChange)
    local track = sliderFrame:WaitForChild("Track")
    local knob = track:WaitForChild("Knob")
    local fill = track:WaitForChild("Fill")
    local title = sliderFrame:WaitForChild("Label")

    local dragging = false
    local function update(absX)
        local t = math.clamp((absX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + t * (maxVal - minVal))
        
        knob.Position = UDim2.new(t, -knob.Size.X.Offset/2, 0.5, -knob.Size.Y.Offset/2)
        fill.Size = UDim2.new(t, 0, 1, 0)
        title.Text = labelName .. ": " .. tostring(value)
        onChange(value)
    end

    knob.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    
    -- Inicializar
    update(track.AbsolutePosition.X + (track.AbsoluteSize.X * ((default - minVal)/(maxVal - minVal))))
end

-- Configuração de Sliders 
setupSlider(spawnerBg.SizeAdjustBg, "Size", 2, 20, state.size, function(v)
    state.size = v
end)

setupSlider(spawnerBg.MassAdjustBg, "Mass (k)", 1, 500, 150, function(v)
    state.mass = v * 1000
end)

-- Seleção de Tipo e Movimento  
local function updateSelectionVisuals(group, selectedId)
    for id, btn in pairs(group) do
        local isSelected = (id == selectedId)
        -- Ajuste as cores de seleção aqui
        btn.BackgroundColor3 = isSelected and Color3.fromRGB(80, 100, 200) or Color3.fromRGB(35, 35, 55)
    end
end

-- Eventos de Tipo
for id, btn in pairs(typeButtons) do
    btn.MouseButton1Click:Connect(function()
        state.bodyType = id
        updateSelectionVisuals(typeButtons, id)
        
        -- Ajuste automático de massa/tamanho baseado no Config
        local tc = Config.Types[id]
        if tc then
            -- evento para resetar os sliders
        end
    end)
end

-- Eventos de Movimento
for id, btn in pairs(movButtons) do
    btn.MouseButton1Click:Connect(function()
        state.movement = id
        updateSelectionVisuals(movButtons, id)
        customPanel.Visible = (id == "Custom")
    end)
end

-- Spawn
spawnBtn.MouseButton1Click:Connect(function()
    local vel = Vector3.zero

    if state.movement == "Custom" then
        vel = Vector3.new(
            tonumber(customPanel:WaitForChild("X").Text) or 0,
            tonumber(customPanel:WaitForChild("Y").Text) or 0,
            tonumber(customPanel:WaitForChild("Z").Text) or 0
        )
    end

    SpawnBody:FireServer({
        bodyType = state.bodyType,
        size     = state.size,
        mass     = state.mass,
        velocity = vel,
        movement = state.movement,
    })

    local originalText = spawnBtn.Text
    spawnBtn.Text = "✔ Spawnado!"
    task.delay(1.2, function()
        spawnBtn.Text = originalText
    end)
end)

updateSelectionVisuals(typeButtons, state.bodyType)
updateSelectionVisuals(movButtons, state.movement)