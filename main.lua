-- MGZMODZ ULTRA GOD - FULL FUNCIONAL
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local runService = game:GetService("RunService")
local lighting = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")
local userInput = game:GetService("UserInputService")
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")

-- CONFIGURAÇÃO
local config = {}
local cfgFile = "mgzmodz_config.json"
pcall(function()
    if readfile and isfile and isfile(cfgFile) then
        config = httpService:JSONDecode(readfile(cfgFile))
    end
end)

local function saveConfig()
    if writefile then
        writefile(cfgFile, httpService:JSONEncode(config))
    end
end

-- INICIALIZA DEFAULTS
local function initConfig()
    local defaults = {
        Aimbot = false, FOV = false, Silent = false, Team = false, Recoil = false, Lock = false,
        ESP = false, Nome = false, Box = false, Linha = false, Vida = false, Skeleton = false,
        Speed = false, Fly = false, Spin = false, TP = false, Farm = false, AFK = false,
        Invisible = false, XRay = false, FullBright = false, NoFog = false, FPSBoost = false
    }
    for k,v in pairs(defaults) do
        if config[k] == nil then config[k] = v end
    end
end
initConfig()
saveConfig()

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "MGZHUB"
gui.Parent = player:WaitForChild("PlayerGui")

-- BOTÃO FLUTUANTE (DRAG)
local openBtn = Instance.new("TextButton")
openBtn.Size = UDim2.new(0, 120, 0, 35)
openBtn.Position = UDim2.new(0, 20, 0.5, 0)
openBtn.Text = "MGZHUB"
openBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
openBtn.Parent = gui

local dragging = false
local dragStart, startPos
openBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = openBtn.Position
    end
end)
userInput.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        openBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
userInput.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- JANELA PRINCIPAL
local main = Instance.new("Frame")
main.Size = UDim2.new(0, 480, 0, 360)
main.Position = UDim2.new(0.5, -240, 0.5, -180)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
main.Visible = false
main.Parent = gui

-- TOPO RGB
local top = Instance.new("Frame")
top.Size = UDim2.new(1, 0, 0, 35)
top.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -90, 1, 0)
title.Text = "MGZHUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Parent = top

spawn(function()
    local hue = 0
    while true do
        hue = (hue + 0.01) % 1
        top.BackgroundColor3 = Color3.fromHSV(hue, 1, 1)
        wait(0.03)
    end
end)

local close = Instance.new("TextButton")
close.Size = UDim2.new(0, 30, 1, 0)
close.Position = UDim2.new(1, -30, 0, 0)
close.Text = "X"
close.Parent = top

local mini = Instance.new("TextButton")
mini.Size = UDim2.new(0, 30, 1, 0)
mini.Position = UDim2.new(1, -60, 0, 0)
mini.Text = "-"
mini.Parent = top

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://12221967"
clickSound.Volume = 1
clickSound.Parent = gui
local function playSound() clickSound:Play() end

-- ÁREA DE CONTEÚDO
local content = Instance.new("Frame")
content.Size = UDim2.new(1, 0, 1, -70)
content.Position = UDim2.new(0, 0, 0, 70)
content.BackgroundTransparency = 1
content.Parent = main

local function clearContent()
    for _, child in pairs(content:GetChildren()) do child:Destroy() end
end

local function toggleOption(name, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 30)
    btn.Position = UDim2.new(0.05, 0, 0, y)
    btn.Parent = content
    local function update()
        btn.Text = name .. " : " .. (config[name] and "ON" or "OFF")
        btn.BackgroundColor3 = config[name] and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(35, 35, 50)
    end
    update()
    btn.MouseButton1Click:Connect(function()
        config[name] = not config[name]
        update()
        saveConfig()
        playSound()
        -- Ativar/desativar efeitos imediatos
        if name == "Speed" then applySpeed() end
        if name == "FullBright" then setFullBright() end
        if name == "NoFog" then setNoFog() end
        if name == "FPSBoost" then setFPSBoost() end
        if name == "XRay" then setXRay() end
        if name == "Invisible" then setInvisible() end
    end)
end

local function label(text, y)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.9, 0, 0, 25)
    lbl.Position = UDim2.new(0.05, 0, 0, y)
    lbl.Text = text
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.new(1, 1, 1)
    lbl.Parent = content
end

-- ABAS
local function createTab(name, xPos, callback)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(0.25, 0, 0, 35)
    tabBtn.Position = UDim2.new(xPos, 0, 0, 35)
    tabBtn.Text = name
    tabBtn.Parent = main
    tabBtn.MouseButton1Click:Connect(function()
        playSound()
        callback()
    end)
end

-- PÁGINA Aimbot
local function pageAimbot()
    clearContent()
    local y = 5
    for _, opt in ipairs({"Aimbot", "FOV", "Silent", "Team", "Recoil", "Lock"}) do
        toggleOption(opt, y)
        y = y + 35
    end
    toggleOption("Invisible", y); y = y + 35
    toggleOption("XRay", y); y = y + 35
end

-- PÁGINA Visual
local function pageVisual()
    clearContent()
    local y = 5
    for _, opt in ipairs({"ESP", "Nome", "Box", "Linha", "Vida", "Skeleton"}) do
        toggleOption(opt, y)
        y = y + 35
    end
end

-- PÁGINA Misc
local function pageMisc()
    clearContent()
    local y = 5
    for _, opt in ipairs({"Speed", "Fly", "Spin", "TP", "Farm", "AFK", "FullBright", "NoFog", "FPSBoost"}) do
        toggleOption(opt, y)
        y = y + 35
    end
    toggleOption("ResetUI", y)
end

-- PÁGINA Info
local function pageInfo()
    clearContent()
    label("YouTube: @MGVHEATS_OFC", 20)
    label("Discord: mgzincai09", 50)
end

createTab("Aimbot", 0, pageAimbot)
createTab("Visual", 0.25, pageVisual)
createTab("Misc", 0.5, pageMisc)
createTab("Info", 0.75, pageInfo)
pageAimbot()

-- ABRIR/FECHAR
openBtn.MouseButton1Click:Connect(function()
    playSound()
    main.Visible = not main.Visible
end)
local minimized = false
mini.MouseButton1Click:Connect(function()
    playSound()
    minimized = not minimized
    main.Size = minimized and UDim2.new(0, 200, 0, 35) or UDim2.new(0, 480, 0, 360)
    content.Visible = not minimized
end)
close.MouseButton1Click:Connect(function()
    playSound()
    gui:Destroy()
end)

-- ======================== IMPLEMENTAÇÃO DAS FUNÇÕES ========================
local playerChar = player.Character or player.CharacterAdded:Wait()
local humanoid = playerChar:WaitForChild("Humanoid")
local rootPart = playerChar:WaitForChild("HumanoidRootPart")

player.CharacterAdded:Connect(function(char)
    playerChar = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    applySpeed()
    setInvisible()
end)

-- SPEED
local function applySpeed()
    if humanoid then
        humanoid.WalkSpeed = config.Speed and 50 or 16
    end
end
runService.RenderStepped:Connect(applySpeed)

-- FLY (usando BodyVelocity)
local flyBodyVel = nil
local function setFly()
    if config.Fly then
        if not flyBodyVel then
            flyBodyVel = Instance.new("BodyVelocity")
            flyBodyVel.MaxForce = Vector3.new(10000, 10000, 10000)
            flyBodyVel.Parent = rootPart
        end
        local moveDir = Vector3.new()
        if userInput:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
        if userInput:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
        if userInput:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
        if userInput:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
        if userInput:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if userInput:IsKeyDown(Enum.KeyCode.LeftControl) then moveDir = moveDir - Vector3.new(0, 1, 0) end
        flyBodyVel.Velocity = moveDir.Unit * 60
        humanoid.PlatformStand = true
    else
        if flyBodyVel then flyBodyVel:Destroy() flyBodyVel = nil end
        humanoid.PlatformStand = false
    end
end
runService.RenderStepped:Connect(setFly)

-- SPIN (girar continuamente)
local spinAngle = 0
runService.RenderStepped:Connect(function()
    if config.Spin then
        spinAngle = spinAngle + 0.1
        rootPart.CFrame = CFrame.new(rootPart.Position) * CFrame.Angles(0, spinAngle, 0)
    end
end)

-- TELEPORT (para o alvo mais próximo)
local function teleportToTarget()
    local target = nil
    local minDist = math.huge
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if dist < minDist then
                minDist = dist
                target = p.Character.HumanoidRootPart
            end
        end
    end
    if target then
        rootPart.CFrame = target.CFrame + Vector3.new(0, 3, 0)
    end
end
if config.TP then
    game:GetService("UserInputService").InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Enum.KeyCode.T and config.TP then
            teleportToTarget()
        end
    end)
end

-- AUTO FARM (exemplo: clicar automaticamente a cada 0.1s)
local farmConnection
local function startFarm()
    if farmConnection then farmConnection:Disconnect() farmConnection = nil end
    if config.Farm then
        farmConnection = runService.RenderStepped:Connect(function()
            mouse1click()
        end)
    end
end
runService.RenderStepped:Connect(function()
    if config.Farm and not farmConnection then startFarm() end
    if not config.Farm and farmConnection then farmConnection:Disconnect() farmConnection = nil end
end)

-- ANTI AFK (simular movimento do mouse)
local antiAFKConnection
local function startAntiAFK()
    if antiAFKConnection then antiAFKConnection:Disconnect() antiAFKConnection = nil end
    if config.AFK then
        antiAFKConnection = game:GetService("RunService").Stepped:Connect(function()
            mouse.Move(mouse.X + 0.1, mouse.Y)
            wait(60)
        end)
    end
end
runService.RenderStepped:Connect(function()
    if config.AFK and not antiAFKConnection then startAntiAFK() end
    if not config.AFK and antiAFKConnection then antiAFKConnection:Disconnect() antiAFKConnection = nil end
end)

-- INVISIBLE (transparente e sem colisão)
local function setInvisible()
    if playerChar then
        for _, part in pairs(playerChar:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Transparency = config.Invisible and 1 or 0
                part.CanCollide = not config.Invisible
            end
        end
    end
end
runService.RenderStepped:Connect(setInvisible)

-- X-RAY (tornar paredes transparentes)
local function setXRay()
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(playerChar) then
            if config.XRay then
                obj.LocalTransparencyModifier = 0.5
            else
                obj.LocalTransparencyModifier = 0
            end
        end
    end
end
runService.RenderStepped:Connect(setXRay)

-- FULL BRIGHT
local function setFullBright()
    if config.FullBright then
        lighting.Ambient = Color3.new(1,1,1)
        lighting.Brightness = 2
        lighting.ClockTime = 12
    else
        lighting.Ambient = Color3.new(0,0,0)
        lighting.Brightness = 0.5
    end
end

-- NO FOG
local function setNoFog()
    if config.NoFog then
        lighting.FogEnd = 100000
        lighting.FogStart = 0
    else
        lighting.FogEnd = 1000
        lighting.FogStart = 0
    end
end

-- FPS BOOST (baixar qualidade)
local function setFPSBoost()
    if config.FPSBoost then
        settings().Rendering.QualityLevel = 1
        workspace.Gravity = 196.2
    else
        settings().Rendering.QualityLevel = 10
    end
end

-- RESET UI
if config.ResetUI then
    gui:Destroy()
    wait(0.5)
    loadstring(game:HttpGet("https://raw.githubusercontent.com/seu-repo/mgzmodz/main/loader.lua"))() -- ou recarregar o próprio script
end

-- =============================== AIMBOT =====================================
local fovCircle = nil
local function createFOVCircle()
    if fovCircle then fovCircle:Remove() end
    if config.FOV then
        local circle = Drawing.new("Circle")
        circle.Thickness = 1
        circle.Color = Color3.new(1,0,0)
        circle.Filled = false
        circle.NumSides = 64
        circle.Radius = 100
        circle.Visible = true
        runService.RenderStepped:Connect(function()
            circle.Position = mouse.X, mouse.Y
        end)
        fovCircle = circle
    else
        if fovCircle then fovCircle:Remove() fovCircle = nil end
    end
end
runService.RenderStepped:Connect(createFOVCircle)

local function getClosestPlayer()
    local closest, shortest = nil, math.huge
    local mousePos = Vector2.new(mouse.X, mouse.Y)
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            if config.Team and p.Team == player.Team then continue end
            local headPos, onScreen = camera:WorldToScreenPoint(p.Character.Head.Position)
            if onScreen then
                local screenPos = Vector2.new(headPos.X, headPos.Y)
                local dist = (screenPos - mousePos).Magnitude
                if dist < shortest and (not config.FOV or dist <= 100) then
                    shortest = dist
                    closest = p
                end
            end
        end
    end
    return closest
end

local aimlockTarget = nil
local function aimbot()
    if not config.Aimbot then return end
    local target = getClosestPlayer()
    if target then
        if config.Lock then aimlockTarget = target end
        local headPos = target.Character.Head.Position
        local screenPos, onScreen = camera:WorldToScreenPoint(headPos)
        if onScreen then
            if config.Silent then
                -- Silent aim: modifica a direção dos projéteis virtualmente (simulado)
                local originalMouse = mouse
                -- Neste ambiente não é possível modificar o tiro diretamente, mas a mira será movida silenciosamente
                mousemoveabs(screenPos.X, screenPos.Y)
            else
                mousemoveabs(screenPos.X, screenPos.Y)
            end
        end
    elseif not config.Lock then
        aimlockTarget = nil
    end
end

-- No Recoil (compensar movimento da câmera)
local originalCameraCF = camera.CFrame
runService.RenderStepped:Connect(function()
    if config.Recoil and mouse.Button1Down then
        camera.CFrame = originalCameraCF
    else
        originalCameraCF = camera.CFrame
    end
end)

-- Executar aimbot quando atirar
mouse.Button1Down:Connect(function()
    while mouse.Button1Down and config.Aimbot do
        aimbot()
        wait()
    end
end)

-- =============================== ESP ========================================
local espObjects = {}
local function updateESP()
    if not config.ESP then
        for _, obj in pairs(espObjects) do obj:Remove() end
        espObjects = {}
        return
    end
    for _, p in pairs(players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            local headPos = p.Character.Head.Position
            local screenPos, onScreen = camera:WorldToScreenPoint(headPos)
            if onScreen then
                if config.Nome then
                    local text = espObjects[p.Name .. "Name"] or Drawing.new("Text")
                    text.Text = p.Name
                    text.Position = Vector2.new(screenPos.X, screenPos.Y - 20)
                    text.Size = 16
                    text.Color = Color3.new(1,1,1)
                    text.Visible = true
                    espObjects[p.Name .. "Name"] = text
                end
                if config.Vida then
                    local healthText = espObjects[p.Name .. "Health"] or Drawing.new("Text")
                    local health = p.Character.Humanoid.Health
                    healthText.Text = "❤️ " .. math.floor(health)
                    healthText.Position = Vector2.new(screenPos.X, screenPos.Y - 35)
                    healthText.Size = 12
                    healthText.Color = Color3.new(1,0,0)
                    healthText.Visible = true
                    espObjects[p.Name .. "Health"] = healthText
                end
                if config.Box then
                    -- caixa 2D simples
                    local size = 50
                    local box = espObjects[p.Name .. "Box"] or Drawing.new("Square")
                    box.Size = Vector2.new(40, 60)
                    box.Position = Vector2.new(screenPos.X - 20, screenPos.Y - 20)
                    box.Thickness = 1
                    box.Color = Color3.new(0,1,0)
                    box.Filled = false
                    box.Visible = true
                    espObjects[p.Name .. "Box"] = box
                end
                if config.Linha then
                    local line = espObjects[p.Name .. "Line"] or Drawing.new("Line")
                    line.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y)
                    line.To = Vector2.new(screenPos.X, screenPos.Y)
                    line.Thickness = 1
                    line.Color = Color3.new(1,1,1)
                    line.Visible = true
                    espObjects[p.Name .. "Line"] = line
                end
                if config.Skeleton then
                    -- simplificado: apenas linha entre cabeça e tronco
                    if p.Character:FindFirstChild("Torso") or p.Character:FindFirstChild("HumanoidRootPart") then
                        local torso = p.Character:FindFirstChild("Torso") or p.Character.HumanoidRootPart
                        local torsoPos, _ = camera:WorldToScreenPoint(torso.Position)
                        local skele = espObjects[p.Name .. "Skeleton"] or Drawing.new("Line")
                        skele.From = Vector2.new(screenPos.X, screenPos.Y)
                        skele.To = Vector2.new(torsoPos.X, torsoPos.Y)
                        skele.Thickness = 1
                        skele.Color = Color3.new(1,1,0)
                        skele.Visible = true
                        espObjects[p.Name .. "Skeleton"] = skele
                    end
                end
            end
        end
    end
    -- limpar objetos de jogadores que saíram
    for k, obj in pairs(espObjects) do
        local stillExists = false
        for _, p in pairs(players:GetPlayers()) do
            if k:find(p.Name) then stillExists = true break end
        end
        if not stillExists then
            obj:Remove()
            espObjects[k] = nil
        end
    end
end
runService.RenderStepped:Connect(updateESP)

-- Inicializa efeitos que precisam de uma vez
setFullBright()
setNoFog()
setFPSBoost()
setXRay()
