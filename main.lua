-- // MG HUB UI - VISUAL FFH4X STYLE (CLEAN)
-- // Com opções de Aimbot, ESP, Player e Misc

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- // Configurações dos recursos
local settings = {
    -- Aimbot
    aimbotEnabled = false,
    fovCircleEnabled = false,
    fovRadius = 150,
    -- ESP
    espLine = false,
    espBox = false,
    espHealth = false,
    espName = false,
    espDistance = false,
    -- Player
    speedEnabled = false,
    speedValue = 50,
    flyEnabled = false,
    noclipEnabled = false,
    spinEnabled = false
}

-- // Funções auxiliares para criar elementos UI dentro da aba de conteúdo
local function createToggle(parent, text, yPos, settingName)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 40)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    frame.BackgroundTransparency = 0.5
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(0, 60, 0, 25)
    btn.Position = UDim2.new(1, -70, 0.5, -12.5)
    btn.Text = "OFF"
    btn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.GothamBold
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 4)

    local function updateButton()
        if settings[settingName] then
            btn.Text = "ON"
            btn.BackgroundColor3 = Color3.fromRGB(0,200,0)
        else
            btn.Text = "OFF"
            btn.BackgroundColor3 = Color3.fromRGB(255,0,0)
        end
    end
    updateButton()

    btn.MouseButton1Click:Connect(function()
        settings[settingName] = not settings[settingName]
        updateButton()
        -- Call specific handlers quando necessário
        if settingName == "flyEnabled" then
            if settings.flyEnabled then
                startFly()
            else
                stopFly()
            end
        elseif settingName == "noclipEnabled" then
            toggleNoclip()
        elseif settingName == "speedEnabled" then
            updateSpeed()
        elseif settingName == "spinEnabled" then
            if settings.spinEnabled then
                startSpin()
            else
                stopSpin()
            end
        end
    end)

    return frame
end

local function createSlider(parent, text, yPos, settingName, minVal, maxVal, defaultVal)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, yPos)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    frame.BackgroundTransparency = 0.5
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 5)

    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.7, 0, 0.5, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 14

    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0.3, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.7, 0, 0, 0)
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.new(1,1,1)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 14

    local slider = Instance.new("TextButton", frame)
    slider.Size = UDim2.new(1, -20, 0, 8)
    slider.Position = UDim2.new(0, 10, 0.6, 0)
    slider.BackgroundColor3 = Color3.fromRGB(50,50,55)
    slider.AutoButtonColor = false
    local sliderCorner = Instance.new("UICorner", slider)
    sliderCorner.CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame", slider)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 4)

    local draggingSlider = false
    slider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = true
        end
    end)
    slider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingSlider = false
        end
    end)
    slider.MouseMoved:Connect(function()
        if draggingSlider then
            local mousePos = UIS:GetMouseLocation()
            local sliderPos = slider.AbsolutePosition
            local width = slider.AbsoluteSize.X
            local percent = math.clamp((mousePos.X - sliderPos.X) / width, 0, 1)
            local newVal = minVal + (maxVal - minVal) * percent
            settings[settingName] = newVal
            valueLabel.Text = string.format("%.0f", newVal)
            fill.Size = UDim2.new(percent, 0, 1, 0)

            if settingName == "fovRadius" and settings.fovCircleEnabled then
                updateFOVCircle()
            elseif settingName == "speedValue" and settings.speedEnabled then
                updateSpeed()
            end
        end
    end)

    return frame
end

-- // Desenho do círculo FOV
local fovCircle = nil
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    fovCircle = Drawing.new("Circle")
    fovCircle.Visible = settings.fovCircleEnabled
    fovCircle.Radius = settings.fovRadius
    fovCircle.Thickness = 2
    fovCircle.Color = Color3.fromRGB(255,0,0)
    fovCircle.Filled = false
    fovCircle.NumSides = 64
end

local function updateFOVCircle()
    if fovCircle then
        fovCircle.Radius = settings.fovRadius
        fovCircle.Visible = settings.fovCircleEnabled
    else
        createFOVCircle()
    end
end

-- // Atualização do círculo na tela
RunService.RenderStepped:Connect(function()
    if fovCircle then
        local mousePos = UIS:GetMouseLocation()
        fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
    end
end)

-- // Aimbot simples (altera o mouse para mirar no inimigo mais próximo dentro do FOV)
local function getClosestPlayerInFOV()
    local maxDist = settings.fovRadius
    local closest = nil
    local closestScreenDist = maxDist
    local mousePos = UIS:GetMouseLocation()

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
            local head = otherPlayer.Character:FindFirstChild("Head")
            if head then
                local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local screenDist = (Vector2.new(vector.X, vector.Y) - mousePos).Magnitude
                    if screenDist < closestScreenDist then
                        closest = otherPlayer
                        closestScreenDist = screenDist
                    end
                end
            end
        end
    end
    return closest, closestScreenDist
end

UIS.InputBegan:Connect(function(input)
    if settings.aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then -- botão direito do mouse
        local target, dist = getClosestPlayerInFOV()
        if target and dist <= settings.fovRadius then
            local head = target.Character.Head
            local targetPos = head.Position
            -- Move o mouse para a cabeça do alvo (simula mira)
            local screenPos, onScreen = Camera:WorldToViewportPoint(targetPos)
            if onScreen then
                mousemoveabs(screenPos.X, screenPos.Y) -- função comum em executors
            end
        end
    end
end)

-- // ESP com desenhos (Drawing)
local espObjects = {}
local function updateESP()
    for _, obj in pairs(espObjects) do
        obj:Remove()
    end
    espObjects = {}

    if not (settings.espLine or settings.espBox or settings.espHealth or settings.espName or settings.espDistance) then
        return
    end

    for _, otherPlayer in ipairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("Humanoid") and otherPlayer.Character.Humanoid.Health > 0 then
            local rootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart") or otherPlayer.Character:FindFirstChild("Torso")
            if rootPart then
                local pos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)
                if onScreen then
                    local espData = {}
                    if settings.espLine then
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(pos.X, pos.Y)
                        line.Color = Color3.fromRGB(255,255,255)
                        line.Thickness = 1
                        line.Visible = true
                        table.insert(espObjects, line)
                        espData.line = line
                    end
                    if settings.espBox then
                        local box = Drawing.new("Square")
                        local size = 60
                        box.Position = Vector2.new(pos.X - size/2, pos.Y - size)
                        box.Size = Vector2.new(size, size)
                        box.Color = Color3.fromRGB(255,0,0)
                        box.Thickness = 2
                        box.Filled = false
                        box.Visible = true
                        table.insert(espObjects, box)
                        espData.box = box
                    end
                    if settings.espName then
                        local nameText = Drawing.new("Text")
                        nameText.Text = otherPlayer.Name
                        nameText.Position = Vector2.new(pos.X - 30, pos.Y - 70)
                        nameText.Size = 14
                        nameText.Color = Color3.fromRGB(255,255,255)
                        nameText.Center = true
                        nameText.Visible = true
                        table.insert(espObjects, nameText)
                        espData.name = nameText
                    end
                    if settings.espDistance then
                        local dist = (Camera.CFrame.Position - rootPart.Position).Magnitude
                        local distText = Drawing.new("Text")
                        distText.Text = string.format("%.0fm", dist)
                        distText.Position = Vector2.new(pos.X - 20, pos.Y - 55)
                        distText.Size = 12
                        distText.Color = Color3.fromRGB(200,200,200)
                        distText.Center = true
                        distText.Visible = true
                        table.insert(espObjects, distText)
                        espData.distance = distText
                    end
                    if settings.espHealth then
                        local health = otherPlayer.Character.Humanoid.Health
                        local healthPercent = health / otherPlayer.Character.Humanoid.MaxHealth
                        local healthBar = Drawing.new("Line")
                        healthBar.From = Vector2.new(pos.X - 30, pos.Y - 50)
                        healthBar.To = Vector2.new(pos.X - 30, pos.Y - 50 + (40 * healthPercent))
                        healthBar.Color = Color3.fromRGB(0,255,0)
                        healthBar.Thickness = 5
                        healthBar.Visible = true
                        table.insert(espObjects, healthBar)
                        espData.health = healthBar
                    end
                end
            end
        end
    end
end

-- // Atualiza ESP a cada frame
RunService.RenderStepped:Connect(updateESP)

-- // Player: Speed
local function updateSpeed()
    if settings.speedEnabled and humanoid then
        humanoid.WalkSpeed = settings.speedValue
    elseif humanoid and not settings.speedEnabled then
        humanoid.WalkSpeed = 16
    end
end

-- // Player: Fly
local flyBodyVelocity = nil
local function startFly()
    if not character or not humanoid then return end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    humanoid.PlatformStand = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(10000, 10000, 10000)
    flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    flyBodyVelocity.Parent = character:WaitForChild("HumanoidRootPart")
    
    local flySpeed = 50
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not settings.flyEnabled then return end
        if input.KeyCode == Enum.KeyCode.W then
            flyBodyVelocity.Velocity = Camera.CFrame.LookVector * flySpeed
        elseif input.KeyCode == Enum.KeyCode.S then
            flyBodyVelocity.Velocity = -Camera.CFrame.LookVector * flySpeed
        elseif input.KeyCode == Enum.KeyCode.A then
            flyBodyVelocity.Velocity = -Camera.CFrame.RightVector * flySpeed
        elseif input.KeyCode == Enum.KeyCode.D then
            flyBodyVelocity.Velocity = Camera.CFrame.RightVector * flySpeed
        elseif input.KeyCode == Enum.KeyCode.Space then
            flyBodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
        elseif input.KeyCode == Enum.KeyCode.LeftShift then
            flyBodyVelocity.Velocity = Vector3.new(0, -flySpeed, 0)
        end
    end)
end

local function stopFly()
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if humanoid then humanoid.PlatformStand = false end
end

-- // Player: Noclip
local function toggleNoclip()
    if settings.noclipEnabled then
        local na = character:FindFirstChild("HumanoidRootPart")
        if na then
            na.CanCollide = false
        end
    else
        local na = character:FindFirstChild("HumanoidRootPart")
        if na then
            na.CanCollide = true
        end
    end
end

-- // Player: Spin (gira o personagem)
local spinConnection = nil
local function startSpin()
    if spinConnection then spinConnection:Disconnect() end
    spinConnection = RunService.RenderStepped:Connect(function()
        if settings.spinEnabled and character and character:FindFirstChild("HumanoidRootPart") then
            local hrp = character.HumanoidRootPart
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(10), 0)
        end
    end)
end

local function stopSpin()
    if spinConnection then spinConnection:Disconnect() end
end

-- // Criar abas e seus conteúdos
-- ... (código original do GUI até a criação das abas)
-- Vou reaproveitar a estrutura de criação de abas do usuário, mas substituir o conteúdo de cada uma

local categories = {"Aimbot","Visuals","Player","Misc"}
local tabButtons = {}

for i, v in ipairs(categories) do
    local btn = Instance.new("TextButton", tabs)
    btn.Size = UDim2.new(1,0,0,40)
    btn.Position = UDim2.new(0,0,0,(i-1)*40)
    btn.Text = v
    btn.BackgroundColor3 = Color3.fromRGB(25,25,30)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    tabButtons[v] = btn

    btn.MouseButton1Click:Connect(function()
        for _,child in pairs(content:GetChildren()) do
            child:Destroy()
        end
        
        if v == "Aimbot" then
            createToggle(content, "Aimbot (Botão Direito)", 10, "aimbotEnabled")
            createToggle(content, "Exibir Círculo FOV", 60, "fovCircleEnabled")
            createSlider(content, "Raio do FOV", 110, "fovRadius", 50, 300, 150)
            -- Inicializa o círculo se ativado
            createFOVCircle()
        elseif v == "Visuals" then
            createToggle(content, "ESP Linha", 10, "espLine")
            createToggle(content, "ESP Caixa", 60, "espBox")
            createToggle(content, "ESP Vida", 110, "espHealth")
            createToggle(content, "ESP Nome", 160, "espName")
            createToggle(content, "ESP Distância", 210, "espDistance")
        elseif v == "Player" then
            local speedToggle = createToggle(content, "Speed", 10, "speedEnabled")
            createSlider(content, "Velocidade", 60, "speedValue", 16, 200, 50)
            createToggle(content, "Fly", 110, "flyEnabled")
            createToggle(content, "Noclip", 160, "noclipEnabled")
            createToggle(content, "Spin (Girar)", 210, "spinEnabled")
        elseif v == "Misc" then
            local cred = Instance.new("TextLabel", content)
            cred.Size = UDim2.new(1,0,1,0)
            cred.Text = "Criado por: MGCHEATS_OFC"
            cred.TextColor3 = Color3.new(1,1,1)
            cred.BackgroundTransparency = 1
            cred.Font = Enum.Font.GothamBold
            cred.TextSize = 20
        end
    end)
end

-- Abrir primeira aba por padrão
tabButtons["Aimbot"].MouseButton1Click:Fire()

-- // O resto do código de drag, botão MG, etc, permanece igual
-- (Manter a criação do botão MG, frame, top bar, close, minimize, drag do menu)
