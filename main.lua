-- // MG HUB UI - VISUAL FFH4X STYLE (CORRIGIDO E FUNCIONAL)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- // Verifica se o executor suporta desenhos (ESP)
local hasDrawing = pcall(function() return Drawing.new("Circle") end)

-- // Configurações
local settings = {
    aimbotEnabled = false,
    fovCircleEnabled = false,
    fovRadius = 150,
    espLine = false,
    espBox = false,
    espHealth = false,
    espName = false,
    espDistance = false,
    speedEnabled = false,
    speedValue = 50,
    flyEnabled = false,
    noclipEnabled = false,
    spinEnabled = false
}

-- // Variáveis para Fly
local flyBodyVelocity = nil
local flyKeys = { W = false, A = false, S = false, D = false, Space = false, Shift = false }

-- // Variáveis para Spin
local spinConnection = nil

-- // Criar GUI (mantido igual)
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MG_UI"

local button = Instance.new("TextButton")
button.Size = UDim2.new(0,50,0,50)
button.Position = UDim2.new(0,100,0,100)
button.Text = "MG"
button.Parent = gui
button.BackgroundColor3 = Color3.fromRGB(20,20,20)
button.TextColor3 = Color3.fromRGB(255,0,0)
button.Font = Enum.Font.GothamBold
button.TextScaled = true

local stroke = Instance.new("UIStroke", button)
stroke.Color = Color3.fromRGB(255,0,0)
stroke.Thickness = 2

local corner = Instance.new("UICorner", button)

-- Drag do botão MG
local dragging, dragInput, startPos, startInput
button.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        startInput = input.Position
        startPos = button.Position
    end
end)
button.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)
UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - startInput
        button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-- Menu principal
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,500,0,350)
frame.Position = UDim2.new(0.5,-250,0.5,-175)
frame.BackgroundColor3 = Color3.fromRGB(15,15,20)
frame.Visible = false
frame.Parent = gui

local stroke2 = Instance.new("UIStroke", frame)
stroke2.Color = Color3.fromRGB(255,0,0)
stroke2.Thickness = 2

local corner2 = Instance.new("UICorner", frame)

-- Top bar
local top = Instance.new("Frame", frame)
top.Size = UDim2.new(1,0,0,30)
top.BackgroundColor3 = Color3.fromRGB(25,25,30)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-60,1,0)
title.Text = "MG HUB"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0,30,1,0)
close.Position = UDim2.new(1,-30,0,0)
close.Text = "X"
close.BackgroundColor3 = Color3.fromRGB(255,0,0)

local mini = Instance.new("TextButton", top)
mini.Size = UDim2.new(0,30,1,0)
mini.Position = UDim2.new(1,-60,0,0)
mini.Text = "-"
mini.BackgroundColor3 = Color3.fromRGB(80,80,80)

-- Animações menu
local function openMenu()
    frame.Visible = true
    frame.Size = UDim2.new(0,0,0,0)
    TweenService:Create(frame, TweenInfo.new(0.3), { Size = UDim2.new(0,500,0,350) }):Play()
end
local function closeMenu()
    local tween = TweenService:Create(frame, TweenInfo.new(0.3), { Size = UDim2.new(0,0,0,0) })
    tween:Play()
    tween.Completed:Wait()
    frame.Visible = false
end
button.MouseButton1Click:Connect(function()
    if frame.Visible then closeMenu() else openMenu() end
end)
close.MouseButton1Click:Connect(closeMenu)
mini.MouseButton1Click:Connect(function() frame.Visible = false end)

-- Drag do menu
local dragging2 = false
top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging2 = true end
end)
top.InputEnded:Connect(function() dragging2 = false end)
UIS.InputChanged:Connect(function(input)
    if dragging2 then
        frame.Position = UDim2.new(0, input.Position.X - 250, 0, input.Position.Y - 15)
    end
end)

-- Abas
local tabs = Instance.new("Frame", frame)
tabs.Size = UDim2.new(0,120,1,-30)
tabs.Position = UDim2.new(0,0,0,30)
tabs.BackgroundColor3 = Color3.fromRGB(10,10,15)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1,-120,1,-30)
content.Position = UDim2.new(0,120,0,30)
content.BackgroundColor3 = Color3.fromRGB(20,20,25)

-- ========== FUNÇÕES DE RECURSOS ==========

-- // Círculo FOV (Drawing)
local fovCircle = nil
local function createFOVCircle()
    if not hasDrawing then return end
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
    if not hasDrawing then return end
    if fovCircle then
        fovCircle.Radius = settings.fovRadius
        fovCircle.Visible = settings.fovCircleEnabled
    else
        createFOVCircle()
    end
end
-- Atualizar posição do círculo a cada frame
if hasDrawing then
    RunService.RenderStepped:Connect(function()
        if fovCircle and settings.fovCircleEnabled then
            local mousePos = UIS:GetMouseLocation()
            fovCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        end
    end)
end

-- // Aimbot (mira suave via CFrame)
local function getClosestPlayerInFOV()
    if not settings.aimbotEnabled then return nil end
    local mousePos = UIS:GetMouseLocation()
    local closest = nil
    local closestDist = settings.fovRadius
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("Humanoid") and other.Character.Humanoid.Health > 0 then
            local head = other.Character:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < closestDist then
                        closest = other
                        closestDist = dist
                    end
                end
            end
        end
    end
    return closest
end
UIS.InputBegan:Connect(function(input)
    if settings.aimbotEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local target = getClosestPlayerInFOV()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local headPos = target.Character.Head.Position
            -- Move a câmera suavemente (opcional: usar tween)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, headPos)
        end
    end
end)

-- // ESP com Drawing (recria a cada frame)
local espObjects = {}
local function updateESP()
    if not hasDrawing then return end
    for _, obj in pairs(espObjects) do obj:Remove() end
    espObjects = {}
    if not (settings.espLine or settings.espBox or settings.espHealth or settings.espName or settings.espDistance) then return end
    for _, other in ipairs(Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("Humanoid") and other.Character.Humanoid.Health > 0 then
            local root = other.Character:FindFirstChild("HumanoidRootPart") or other.Character:FindFirstChild("Torso")
            if root then
                local pos, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local yOffset = 0
                    if settings.espLine then
                        local line = Drawing.new("Line")
                        line.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        line.To = Vector2.new(pos.X, pos.Y)
                        line.Color = Color3.fromRGB(255,255,255)
                        line.Thickness = 1
                        table.insert(espObjects, line)
                    end
                    if settings.espBox then
                        local box = Drawing.new("Square")
                        box.Position = Vector2.new(pos.X - 30, pos.Y - 60)
                        box.Size = Vector2.new(60, 60)
                        box.Color = Color3.fromRGB(255,0,0)
                        box.Thickness = 2
                        box.Filled = false
                        table.insert(espObjects, box)
                    end
                    if settings.espName then
                        local txt = Drawing.new("Text")
                        txt.Text = other.Name
                        txt.Position = Vector2.new(pos.X, pos.Y - 70)
                        txt.Size = 14
                        txt.Color = Color3.fromRGB(255,255,255)
                        txt.Center = true
                        table.insert(espObjects, txt)
                    end
                    if settings.espDistance then
                        local dist = (Camera.CFrame.Position - root.Position).Magnitude
                        local txt = Drawing.new("Text")
                        txt.Text = string.format("%.0fm", dist)
                        txt.Position = Vector2.new(pos.X, pos.Y - 55)
                        txt.Size = 12
                        txt.Color = Color3.fromRGB(200,200,200)
                        txt.Center = true
                        table.insert(espObjects, txt)
                    end
                    if settings.espHealth then
                        local health = other.Character.Humanoid.Health
                        local maxHealth = other.Character.Humanoid.MaxHealth
                        local percent = math.clamp(health / maxHealth, 0, 1)
                        local bar = Drawing.new("Line")
                        bar.From = Vector2.new(pos.X - 35, pos.Y - 50)
                        bar.To = Vector2.new(pos.X - 35, pos.Y - 50 + (40 * percent))
                        bar.Color = Color3.fromRGB(0,255,0)
                        bar.Thickness = 4
                        table.insert(espObjects, bar)
                    end
                end
            end
        end
    end
end
RunService.RenderStepped:Connect(updateESP)

-- // Speed
local function updateSpeed()
    if humanoid then
        humanoid.WalkSpeed = settings.speedEnabled and settings.speedValue or 16
    end
end

-- // Fly (contínuo)
local function updateFlyVelocity()
    if not settings.flyEnabled or not flyBodyVelocity then return end
    local vel = Vector3.new(0,0,0)
    local speed = 50
    if flyKeys.W then vel = vel + Camera.CFrame.LookVector * speed end
    if flyKeys.S then vel = vel - Camera.CFrame.LookVector * speed end
    if flyKeys.D then vel = vel + Camera.CFrame.RightVector * speed end
    if flyKeys.A then vel = vel - Camera.CFrame.RightVector * speed end
    if flyKeys.Space then vel = vel + Vector3.new(0, speed, 0) end
    if flyKeys.Shift then vel = vel - Vector3.new(0, speed, 0) end
    flyBodyVelocity.Velocity = vel
end
local function startFly()
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    humanoid.PlatformStand = true
    flyBodyVelocity = Instance.new("BodyVelocity")
    flyBodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBodyVelocity.Parent = hrp
    -- Conectar atualização contínua
    RunService.RenderStepped:Connect(function()
        if settings.flyEnabled and flyBodyVelocity then updateFlyVelocity() end
    end)
end
local function stopFly()
    if flyBodyVelocity then flyBodyVelocity:Destroy() end
    if humanoid then humanoid.PlatformStand = false end
end
-- Teclas para fly
UIS.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyKeys.W = true
    elseif key == Enum.KeyCode.A then flyKeys.A = true
    elseif key == Enum.KeyCode.S then flyKeys.S = true
    elseif key == Enum.KeyCode.D then flyKeys.D = true
    elseif key == Enum.KeyCode.Space then flyKeys.Space = true
    elseif key == Enum.KeyCode.LeftShift then flyKeys.Shift = true
    end
end)
UIS.InputEnded:Connect(function(input)
    local key = input.KeyCode
    if key == Enum.KeyCode.W then flyKeys.W = false
    elseif key == Enum.KeyCode.A then flyKeys.A = false
    elseif key == Enum.KeyCode.S then flyKeys.S = false
    elseif key == Enum.KeyCode.D then flyKeys.D = false
    elseif key == Enum.KeyCode.Space then flyKeys.Space = false
    elseif key == Enum.KeyCode.LeftShift then flyKeys.Shift = false
    end
end)

-- // Noclip (reaplica ao ressurgir)
local function applyNoclip()
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CanCollide = not settings.noclipEnabled
    end
end
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = character:WaitForChild("Humanoid")
    applyNoclip()
    if settings.speedEnabled then updateSpeed() end
    if settings.flyEnabled then startFly() else stopFly() end
    if settings.spinEnabled then startSpin() else stopSpin() end
end)
local function toggleNoclip()
    applyNoclip()
end

-- // Spin
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

-- ========== CRIAÇÃO DAS ABAS COM OPÇÕES ==========

local function createToggle(parent, text, y, settingName)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    local corner = Instance.new("UICorner", btn)
    corner.CornerRadius = UDim.new(0, 5)
    
    local function update()
        if settings[settingName] then
            btn.Text = text .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(0,150,0)
        else
            btn.Text = text .. ": OFF"
            btn.BackgroundColor3 = Color3.fromRGB(30,30,35)
        end
        -- ações específicas
        if settingName == "flyEnabled" then
            if settings.flyEnabled then startFly() else stopFly() end
        elseif settingName == "noclipEnabled" then
            toggleNoclip()
        elseif settingName == "speedEnabled" then
            updateSpeed()
        elseif settingName == "spinEnabled" then
            if settings.spinEnabled then startSpin() else stopSpin() end
        elseif settingName == "fovCircleEnabled" then
            updateFOVCircle()
        end
    end
    
    btn.MouseButton1Click:Connect(function()
        settings[settingName] = not settings[settingName]
        update()
    end)
    update()
    return btn
end

local function createSlider(parent, text, y, settingName, minVal, maxVal, defaultVal)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -20, 0, 50)
    frame.Position = UDim2.new(0, 10, 0, y)
    frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
    frame.BackgroundTransparency = 0.3
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 5)
    
    local label = Instance.new("TextLabel", frame)
    label.Size = UDim2.new(0.6, 0, 0.5, 0)
    label.Text = text
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    
    local valueLabel = Instance.new("TextLabel", frame)
    valueLabel.Size = UDim2.new(0.4, 0, 0.5, 0)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.Text = tostring(defaultVal)
    valueLabel.TextColor3 = Color3.new(1,1,1)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local sliderBtn = Instance.new("TextButton", frame)
    sliderBtn.Size = UDim2.new(1, -20, 0, 8)
    sliderBtn.Position = UDim2.new(0, 10, 0.7, 0)
    sliderBtn.BackgroundColor3 = Color3.fromRGB(60,60,65)
    sliderBtn.AutoButtonColor = false
    local sliderCorner = Instance.new("UICorner", sliderBtn)
    sliderCorner.CornerRadius = UDim.new(0, 4)
    
    local fill = Instance.new("Frame", sliderBtn)
    fill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    local fillCorner = Instance.new("UICorner", fill)
    fillCorner.CornerRadius = UDim.new(0, 4)
    
    local draggingSlider = false
    sliderBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end
    end)
    sliderBtn.InputEnded:Connect(function() draggingSlider = false end)
    
    local function updateSlider(inputPos)
        if not draggingSlider then return end
        local sliderPos = sliderBtn.AbsolutePosition.X
        local width = sliderBtn.AbsoluteSize.X
        local percent = math.clamp((inputPos.X - sliderPos) / width, 0, 1)
        local newVal = minVal + (maxVal - minVal) * percent
        settings[settingName] = newVal
        valueLabel.Text = string.format("%.0f", newVal)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        if settingName == "fovRadius" then updateFOVCircle() end
        if settingName == "speedValue" and settings.speedEnabled then updateSpeed() end
    end
    
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position)
        end
    end)
    return frame
end

local categoriesList = {"Aimbot", "Visuals", "Player", "Misc"}
local currentContent = nil
for i, cat in ipairs(categoriesList) do
    local tabBtn = Instance.new("TextButton", tabs)
    tabBtn.Size = UDim2.new(1,0,0,40)
    tabBtn.Position = UDim2.new(0,0,0,(i-1)*40)
    tabBtn.Text = cat
    tabBtn.BackgroundColor3 = Color3.fromRGB(25,25,30)
    tabBtn.TextColor3 = Color3.new(1,1,1)
    tabBtn.Font = Enum.Font.Gotham
    tabBtn.MouseButton1Click:Connect(function()
        for _, child in pairs(content:GetChildren()) do child:Destroy() end
        if cat == "Aimbot" then
            createToggle(content, "Aimbot (botão direito)", 10, "aimbotEnabled")
            createToggle(content, "Exibir círculo FOV", 50, "fovCircleEnabled")
            createSlider(content, "Raio do FOV", 90, "fovRadius", 50, 300, 150)
            createFOVCircle()
        elseif cat == "Visuals" then
            createToggle(content, "ESP Linha", 10, "espLine")
            createToggle(content, "ESP Caixa", 50, "espBox")
            createToggle(content, "ESP Vida", 90, "espHealth")
            createToggle(con
