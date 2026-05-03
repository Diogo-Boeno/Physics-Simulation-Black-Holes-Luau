-- --SpawnUI.client.luau
-- local Players           = game:GetService("Players")
-- local ReplicatedStorage = game:GetService("ReplicatedStorage")
-- local TweenService      = game:GetService("TweenService")
-- local Config            = require(ReplicatedStorage.Modules.StarConfig)

-- local player    = Players.LocalPlayer
-- local PlayerGui = player:WaitForChild("PlayerGui")
-- local SpawnBody = ReplicatedStorage.Remotes:WaitForChild("SpawnBody")

-- -- ── Estado atual da UI ─────────────────────────────────────
-- local state = {
--     bodyType   = "BlackHole",
--     size       = 4,
--     mass       = 150000,
--     movement   = "Orbital",    -- "Orbital" | "Static" | "Custom"
--     customVelX = 0,
--     customVelY = 0,
--     customVelZ = 0,
-- }

-- -- ── Helpers de UI ──────────────────────────────────────────
-- local function makeFrame(parent, size, pos, color, radius)
--     local f               = Instance.new("Frame")
--     f.Size                = size
--     f.Position            = pos
--     f.BackgroundColor3    = color or Color3.fromRGB(20, 20, 30)
--     f.BorderSizePixel     = 0
--     f.Parent              = parent
--     if radius then
--         local c           = Instance.new("UICorner")
--         c.CornerRadius    = UDim.new(0, radius)
--         c.Parent          = f
--     end
--     return f
-- end

-- local function makeLabel(parent, text, size, pos, color, fontSize)
--     local l               = Instance.new("TextLabel")
--     l.Size                = size
--     l.Position            = pos
--     l.Text                = text
--     l.TextColor3          = color or Color3.new(1, 1, 1)
--     l.BackgroundTransparency = 1
--     l.TextScaled          = true
--     l.Font                = Enum.Font.GothamBold
--     l.Parent              = parent
--     return l
-- end

-- local function makeButton(parent, text, size, pos, bg, callback)
--     local b               = Instance.new("TextButton")
--     b.Size                = size
--     b.Position            = pos
--     b.Text                = text
--     b.TextColor3          = Color3.new(1, 1, 1)
--     b.BackgroundColor3    = bg or Color3.fromRGB(60, 60, 80)
--     b.BorderSizePixel     = 0
--     b.TextScaled          = true
--     b.Font                = Enum.Font.GothamBold
--     b.Parent              = parent

--     local c               = Instance.new("UICorner")
--     c.CornerRadius        = UDim.new(0, 8)
--     c.Parent              = b

--     b.MouseButton1Click:Connect(callback)
--     return b
-- end

-- local function makeSlider(parent, label, minVal, maxVal, default, pos, onChange)
--     local container = makeFrame(parent,
--         UDim2.new(1, -20, 0, 55),
--         pos,
--         Color3.fromRGB(30, 30, 45), 8
--     )

--     local title = makeLabel(container, label .. ": " .. tostring(default),
--         UDim2.new(1, -10, 0, 20), UDim2.new(0, 10, 0, 5),
--         Color3.fromRGB(200, 200, 220)
--     )

--     local track = makeFrame(container,
--         UDim2.new(1, -20, 0, 8),
--         UDim2.new(0, 10, 0, 32),
--         Color3.fromRGB(50, 50, 70), 4
--     )

--     local fill = makeFrame(track,
--         UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0),
--         UDim2.new(0, 0, 0, 0),
--         Color3.fromRGB(100, 150, 255), 4
--     )

--     local knob = makeFrame(track,
--         UDim2.new(0, 16, 0, 16),
--         UDim2.new((default - minVal) / (maxVal - minVal), -8, 0.5, -8),
--         Color3.fromRGB(180, 210, 255), 8
--     )

--     local dragging = false
--     local value    = default

--     local function updateFromX(absX)
--         local trackAbsPos  = track.AbsolutePosition.X
--         local trackAbsSize = track.AbsoluteSize.X
--         local t = math.clamp((absX - trackAbsPos) / trackAbsSize, 0, 1)
--         value   = math.floor(minVal + t * (maxVal - minVal))
--         fill.Size     = UDim2.new(t, 0, 1, 0)
--         knob.Position = UDim2.new(t, -8, 0.5, -8)
--         title.Text    = label .. ": " .. tostring(value)
--         onChange(value)
--     end

--     knob.InputBegan:Connect(function(input)
--         if input.UserInputType == Enum.UserInputType.MouseButton1 then
--             dragging = true
--         end
--     end)

--     game:GetService("UserInputService").InputChanged:Connect(function(input)
--         if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
--             updateFromX(input.Position.X)
--         end
--     end)

--     game:GetService("UserInputService").InputEnded:Connect(function(input)
--         if input.UserInputType == Enum.UserInputType.MouseButton1 then
--             dragging = false
--         end
--     end)

--     track.InputBegan:Connect(function(input)
--         if input.UserInputType == Enum.UserInputType.MouseButton1 then
--             updateFromX(input.Position.X)
--         end
--     end)

--     return container
-- end

-- -- ── Construir UI ───────────────────────────────────────────
-- local screenGui           = Instance.new("ScreenGui")
-- screenGui.Name            = "SpawnUI"
-- screenGui.ResetOnSpawn    = false
-- screenGui.Parent          = PlayerGui

-- -- Painel principal
-- local panel = makeFrame(screenGui,
--     UDim2.new(0, 280, 0, 520),
--     UDim2.new(0, 20, 0.5, -260),
--     Color3.fromRGB(15, 15, 25), 12
-- )

-- -- Stroke
-- local stroke             = Instance.new("UIStroke")
-- stroke.Color             = Color3.fromRGB(80, 100, 200)
-- stroke.Thickness         = 1.5
-- stroke.Parent            = panel

-- makeLabel(panel, "☰  SPAWN CONFIGURATOR",
--     UDim2.new(1, 0, 0, 35),
--     UDim2.new(0, 0, 0, 10),
--     Color3.fromRGB(150, 180, 255)
-- )

-- -- ── Tipo de corpo ──────────────────────────────────────────
-- makeLabel(panel, "TIPO",
--     UDim2.new(1, -20, 0, 18),
--     UDim2.new(0, 10, 0, 50),
--     Color3.fromRGB(120, 140, 200)
-- )

-- local typeButtons = {}
-- local typeOptions = {
--     { id = "BlackHole",   label = "⚫ Buraco Negro" },
--     { id = "Star",        label = "⭐ Estrela"      },
--     { id = "NeutronStar", label = "💠 Estrela Nêutron" },
-- }

-- local function updateTypeButtons()
--     for _, btn in ipairs(typeButtons) do
--         local isSelected = btn.Id == state.bodyType
--         btn.Button.BackgroundColor3 = isSelected
--             and Color3.fromRGB(80, 100, 200)
--             or  Color3.fromRGB(35, 35, 55)
--     end
-- end

-- for i, opt in ipairs(typeOptions) do
--     local btn = makeButton(panel, opt.label,
--         UDim2.new(1, -20, 0, 30),
--         UDim2.new(0, 10, 0, 65 + (i - 1) * 36),
--         Color3.fromRGB(35, 35, 55),
--         function()
--             state.bodyType = opt.id
--             local tc = Config.Types[opt.id]
--             state.size = math.floor((tc.MinSize + tc.MaxSize) / 2)
--             state.mass = math.floor((tc.MinMass + tc.MaxMass) / 2)
--             updateTypeButtons()
--         end
--     )
--     table.insert(typeButtons, { Id = opt.id, Button = btn })
-- end

-- updateTypeButtons()

-- -- ── Sliders de tamanho e massa ─────────────────────────────
-- local sliderSize = makeSlider(panel, "Tamanho", 2, 20, state.size,
--     UDim2.new(0, 10, 0, 185),
--     function(v) state.size = v end
-- )

-- local sliderMass = makeSlider(panel, "Massa (k)", 1, 500, math.floor(state.mass / 1000),
--     UDim2.new(0, 10, 0, 248),
--     function(v) state.mass = v * 1000 end
-- )

-- -- ── Movimento ──────────────────────────────────────────────
-- makeLabel(panel, "MOVIMENTO",
--     UDim2.new(1, -20, 0, 18),
--     UDim2.new(0, 10, 0, 312),
--     Color3.fromRGB(120, 140, 200)
-- )

-- local movButtons = {}
-- local movOptions = {
--     { id = "Orbital", label = "🔄 Orbital" },
--     { id = "Static",  label = "⏸ Parado"  },
--     { id = "Custom",  label = "✏ Customizado" },
-- }

-- local customPanel = makeFrame(panel,
--     UDim2.new(1, -20, 0, 80),
--     UDim2.new(0, 10, 0, 395),
--     Color3.fromRGB(25, 25, 40), 8
-- )
-- customPanel.Visible = false

-- -- Campos de velocidade customizada
-- local velFields = {}
-- for i, axis in ipairs({"X", "Y", "Z"}) do
--     makeLabel(customPanel, "Vel " .. axis,
--         UDim2.new(0, 30, 0, 22),
--         UDim2.new(0, 5 + (i-1) * 85, 0, 5),
--         Color3.fromRGB(180, 200, 255)
--     )
--     local box                    = Instance.new("TextBox")
--     box.Size                     = UDim2.new(0, 75, 0, 26)
--     box.Position                 = UDim2.new(0, 5 + (i-1) * 85, 0, 28)
--     box.Text                     = "0"
--     box.TextColor3               = Color3.new(1, 1, 1)
--     box.BackgroundColor3         = Color3.fromRGB(40, 40, 60)
--     box.BorderSizePixel          = 0
--     box.TextScaled               = true
--     box.Font                     = Enum.Font.Gotham
--     box.Parent                   = customPanel

--     local c                      = Instance.new("UICorner")
--     c.CornerRadius               = UDim.new(0, 6)
--     c.Parent                     = box

--     velFields[axis] = box
-- end

-- local function updateMovButtons()
--     for _, btn in ipairs(movButtons) do
--         local isSelected = btn.Id == state.movement
--         btn.Button.BackgroundColor3 = isSelected
--             and Color3.fromRGB(80, 100, 200)
--             or  Color3.fromRGB(35, 35, 55)
--     end
--     customPanel.Visible = state.movement == "Custom"
-- end

-- for i, opt in ipairs(movOptions) do
--     local btn = makeButton(panel, opt.label,
--         UDim2.new(0, 82, 0, 28),
--         UDim2.new(0, 10 + (i-1) * 88, 0, 330),
--         Color3.fromRGB(35, 35, 55),
--         function()
--             state.movement = opt.id
--             updateMovButtons()
--         end
--     )
--     table.insert(movButtons, { Id = opt.id, Button = btn })
-- end

-- updateMovButtons()

-- -- ── Botão Spawn ────────────────────────────────────────────
-- local spawnBtn  -- declara nil primeiro

-- spawnBtn = makeButton(panel, "SPAWNAR",
--     UDim2.new(1, -20, 0, 40),
--     UDim2.new(0, 10, 1, -50),
--     Color3.fromRGB(60, 100, 220),
--     function()
--         local vel = Vector3.zero

--         if state.movement == "Static" then
--             vel = Vector3.zero
--         elseif state.movement == "Custom" then
--             vel = Vector3.new(
--                 tonumber(velFields.X.Text) or 0,
--                 tonumber(velFields.Y.Text) or 0,
--                 tonumber(velFields.Z.Text) or 0
--             )
--         end

--         SpawnBody:FireServer({
--             bodyType = state.bodyType,
--             size     = state.size,
--             mass     = state.mass,
--             velocity = vel,
--             movement = state.movement,
--         })

--         spawnBtn.Text = "✔ Spawnado!"
--         task.delay(1.2, function()
--             spawnBtn.Text = "✦  SPAWNAR"
--         end)
--     end
-- )