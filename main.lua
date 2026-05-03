--[[
    Script: MG Hub para Delta Executor (Level 8+)
    Autor: Especialista Roblox
    Descrição: Fornece uma GUI com botão arrastável "MG" que abre um menu com categorias e opções funcionais.
    Compatível com jogos comuns como Arsenal, Jailbreak, etc.
]]

-- Serviços e variáveis globais
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- Estado do menu (aberto/fechado)
local menuOpen = false
local mainGui = nil
local menuWindow = nil

-- Estados das funcionalidades
local state = {
    aimbotEnabled = false,
    smooth = 0.5,
    headshot = false,
    range = 200,
    espBox = false,
    espName = false,
    espColor = Color3.fromRGB(255, 0, 0),
    chams = false,
    speed = 16,
    jumpPower = 50,
    noclip = false,
    fly = false,
    clickTp = false,
    antiAfk = false
}

-- Variáveis de loop
local espConnections = {}
local flyConnection = nil
local noclipConnection = nil
local antiAfkConnection = nil
local aimbotConnection = nil
local clickTpConnection = nil

-- Funções auxiliares
local function makeDraggable(frame, dragHandle)
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- 🔹 Criar GUI principal (botão MG)
local function createMainButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MGGui"
    screenGui.Parent = game.CoreGui
    
    local button = Instance.new("TextButton")
    button.Name = "MGButton"
    button.Size = UDim2.new(0, 40, 0, 40)
    button.Position = UDim2.new(0, 100, 0, 100)
    button.Text = "MG"
    button.TextColor3 = Color3.fromRGB(255, 0, 0)
    button.TextScaled = true
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Font = Enum.Font.GothamBold
    button.Parent = screenGui
    
    -- Efeito de brilho (neon)
    local glow = Instance.new("UIGradient")
    glow.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(100, 0, 0))
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    button.BackgroundTransparency = 0.5
    button.BorderSizePixel = 1
    button.BorderColor3 = Color3.fromRGB(255, 0, 0)
    
    -- Arrastável
    makeDraggable(button, button)
    
    button.MouseButton1Click:Connect(function()
        menuOpen = not menuOpen
        if menuOpen then
            if menuWindow then menuWindow.Visible = true else createMenu() end
        else
            if menuWindow then menuWindow.Visible = false end
        end
    end)
    
    mainGui = screenGui
    return button
end

-- 🔹 Criar painel secundário (menu)
local function createMenu()
    local window = Instance.new("Frame")
    window.Name = "MGWindow"
    window.Size = UDim2.new(0, 450, 0, 350)
    window.Position = UDim2.new(0.5, -225, 0.5, -175)
    window.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    window.BackgroundTransparency = 0.1
    window.BorderSizePixel = 2
    window.BorderColor3 = Color3.fromRGB(255, 0, 0)
    window.ClipsDescendants = true
    window.Parent = mainGui
    window.Visible = true
    
    -- Barra de título arrastável
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 30)
    titleBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    titleBar.BackgroundTransparency = 0.2
    titleBar.BorderSizePixel = 0
    titleBar.Parent = window
    makeDraggable(window, titleBar)
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -30, 1, 0)
    title.Position = UDim2.new(0, 5, 0, 0)
    title.Text = "MG MENU"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = titleBar
    
    -- Botão fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -28, 0, 2)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    closeBtn.BorderSizePixel = 0
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14
    closeBtn.Parent = titleBar
    closeBtn.MouseButton1Click:Connect(function()
        menuOpen = false
        window.Visible = false
    end)
    
    -- Abas (categorias lado esquerdo)
    local tabsFrame = Instance.new("Frame")
    tabsFrame.Size = UDim2.new(0, 100, 1, -30)
    tabsFrame.Position = UDim2.new(0, 0, 0, 30)
    tabsFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
    tabsFrame.BorderSizePixel = 0
    tabsFrame.Parent = window
    
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -100, 1, -30)
    contentFrame.Position = UDim2.new(0, 100, 0, 30)
    contentFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    contentFrame.BorderSizePixel = 0
    contentFrame.Parent = window
    
    -- Lista de categorias
    local categories = {"Aimbot", "Visuals", "Player", "Misc"}
    local activeCategory = nil
    
    local function clearContent()
        for _, child in ipairs(contentFrame:GetChildren()) do
            if child:IsA("GuiObject") then child:Destroy() end
        end
    end
    
    -- Criar botão de categoria
    for i, cat in ipairs(categories) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 35)
        btn.Position = UDim2.new(0, 0, 0, (i-1)*35)
        btn.Text = cat
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 12
        btn.Parent = tabsFrame
        
        btn.MouseButton1Click:Connect(function()
            activeCategory = cat
            clearContent()
            -- Chamar função de carregamento da categoria
            if cat == "Aimbot" then loadAimbotContent(contentFrame)
            elseif cat == "Visuals" then loadVisualsContent(contentFrame)
            elseif cat == "Player" then loadPlayerContent(contentFrame)
            elseif cat == "Misc" then loadMiscContent(contentFrame)
            end
        end)
        
        if i == 1 then btn.MouseButton1Click:Fire() end
    end
    
    menuWindow = window
end

-- 🔹 Conteúdo das categorias

function loadAimbotContent(parent)
    local y = 10
    -- Checkbox Ativar Aimbot
    local aimbotCheck = createCheckbox(parent, "Ativar Aimbot", state.aimbotEnabled, 10, y)
    aimbotCheck.OnToggle = function(val) state.aimbotEnabled = val end
    
    y = y + 35
    -- Slider Smooth
    createSlider(parent, "Smooth", 0, 1, state.smooth, function(val) state.smooth = val end, 10, y)
    
    y = y + 55
    -- Checkbox Mira na Cabeça
    local headCheck = createCheckbox(parent, "Mira na Cabeça", state.headshot, 10, y)
    headCheck.OnToggle = function(val) state.headshot = val end
    
    y = y + 35
    -- Slider Alcance
    createSlider(parent, "Alcance", 50, 300, state.range, function(val) state.range = val end, 10, y)
end

function loadVisualsContent(parent)
    local y = 10
    local espBoxCheck = createCheckbox(parent, "ESP Caixa", state.espBox, 10, y)
    espBoxCheck.OnToggle = function(val) 
        state.espBox = val
        if val then startESP() else stopESP() end
    end
    
    y = y + 35
    local espNameCheck = createCheckbox(parent, "ESP Nome", state.espName, 10, y)
    espNameCheck.OnToggle = function(val)
        state.espName = val
        if val then startESP() else stopESP() end
    end
    
    y = y + 35
    -- Seletor de cor (simples com botões)
    local colorLabel = Instance.new("TextLabel")
    colorLabel.Size = UDim2.new(0, 80, 0, 20)
    colorLabel.Position = UDim2.new(0, 10, 0, y)
    colorLabel.Text = "Cor ESP:"
    colorLabel.TextColor3 = Color3.fromRGB(255,255,255)
    colorLabel.BackgroundTransparency = 1
    colorLabel.Font = Enum.Font.Gotham
    colorLabel.TextSize = 12
    colorLabel.Parent = parent
    
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 50, 0, 20)
    colorBtn.Position = UDim2.new(0, 100, 0, y)
    colorBtn.Text = "Vermelho"
    colorBtn.TextColor3 = Color3.fromRGB(255,255,255)
    colorBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
    colorBtn.BorderSizePixel = 0
    colorBtn.Parent = parent
    colorBtn.MouseButton1Click:Connect(function()
        -- Ciclo simples de cores
        if state.espColor == Color3.fromRGB(255,0,0) then
            state.espColor = Color3.fromRGB(0,255,0)
            colorBtn.Text = "Verde"
            colorBtn.BackgroundColor3 = Color3.fromRGB(0,255,0)
        elseif state.espColor == Color3.fromRGB(0,255,0) then
            state.espColor = Color3.fromRGB(0,0,255)
            colorBtn.Text = "Azul"
            colorBtn.BackgroundColor3 = Color3.fromRGB(0,0,255)
        else
            state.espColor = Color3.fromRGB(255,0,0)
            colorBtn.Text = "Vermelho"
            colorBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
        end
        if state.espBox or state.espName then startESP() end -- atualiza cores
    end)
    
    y = y + 30
    local chamsCheck = createCheckbox(parent, "Chams", state.chams, 10, y)
    chamsCheck.OnToggle = function(val)
        state.chams = val
        if val then startChams() else stopChams() end
    end
end

function loadPlayerContent(parent)
    local y = 10
    createSlider(parent, "Speed", 16, 200, state.speed, function(val) 
        state.speed = val
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = val
        end
    end, 10, y)
    
    y = y + 55
    createSlider(parent, "Jump Power", 50, 200, state.jumpPower, function(val)
        state.jumpPower = val
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = val
        end
    end, 10, y)
    
    y = y + 55
    local noclipCheck = createCheckbox(parent, "No Clip", state.noclip, 10, y)
    noclipCheck.OnToggle = function(val)
        state.noclip = val
        if val then startNoclip() else stopNoclip() end
    end
    
    y = y + 35
    local flyToggle = createToggleButton(parent, "Fly", state.fly, 10, y)
    flyToggle.OnToggle = function(val)
        state.fly = val
        if val then startFly() else stopFly() end
    end
end

function loadMiscContent(parent)
    local y = 10
    local clickTpCheck = createCheckbox(parent, "Click TP", state.clickTp, 10, y)
    clickTpCheck.OnToggle = function(val)
        state.clickTp = val
        if val then startClickTP() else stopClickTP() end
    end
    
    y = y + 35
    local iyBtn = Instance.new("TextButton")
    iyBtn.Size = UDim2.new(0, 150, 0, 30)
    iyBtn.Position = UDim2.new(0, 10, 0, y)
    iyBtn.Text = "Infinite Yield"
    iyBtn.TextColor3 = Color3.fromRGB(255,255,255)
    iyBtn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    iyBtn.BorderSizePixel = 0
    iyBtn.Font = Enum.Font.GothamBold
    iyBtn.Parent = parent
    iyBtn.MouseButton1Click:Connect(function()
        -- Carrega Infinite Yield (se o executor permitir loadstring)
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
        end)
        if not success then
            warn("Falha ao carregar Infinite Yield: " .. tostring(err))
        end
    end)
    
    y = y + 40
    local antiAfkCheck = createCheckbox(parent, "Anti-AFK", state.antiAfk, 10, y)
    antiAfkCheck.OnToggle = function(val)
        state.antiAfk = val
        if val then startAntiAFK() else stopAntiAFK() end
    end
end

-- 🔹 Funções de criação de elementos UI

function createCheckbox(parent, text, defaultValue, x, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 180, 0, 25)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 120, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = frame
    
    local box = Instance.new("TextButton")
    box.Size = UDim2.new(0, 16, 0, 16)
    box.Position = UDim2.new(0, 0, 0.5, -8)
    box.Text = defaultValue and "✓" or ""
    box.TextColor3 = Color3.fromRGB(0,255,0)
    box.BackgroundColor3 = Color3.fromRGB(40,40,40)
    box.BorderSizePixel = 1
    box.BorderColor3 = Color3.fromRGB(255,0,0)
    box.Font = Enum.Font.Gotham
    box.TextSize = 12
    box.Parent = frame
    
    local toggled = defaultValue
    box.MouseButton1Click:Connect(function()
        toggled = not toggled
        box.Text = toggled and "✓" or ""
        if frame.OnToggle then frame.OnToggle(toggled) end
    end)
    
    frame.OnToggle = nil
    local result = {}
    function result.OnToggle(func) frame.OnToggle = func end
    return result
end

function createSlider(parent, text, minVal, maxVal, defaultValue, callback, x, y)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 280, 0, 45)
    frame.Position = UDim2.new(0, x, 0, y)
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 100, 0, 20)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Text = text .. ": " .. string.format("%.1f", defaultValue)
    label.TextColor3 = Color3.fromRGB(255,255,255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.Parent = frame
    
    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(1, 0, 0, 4)
    slider.Position = UDim2.new(0, 0, 0, 25)
    slider.BackgroundColor3 = Color3.fromRGB(80,80,80)
    slider.BorderSizePixel = 0
    slider.Parent = frame
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((defaultValue - minVal)/(maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(255,0,0)
    fill.BorderSizePixel = 0
    fill.Parent = slider
    
    local knob = Instance.new("TextButton")
    knob.Size = UDim2.new(0, 10, 0, 16)
    knob.Position = UDim2.new((defaultValue - minVal)/(maxVal - minVal), -5, 0, -6)
    knob.Text = ""
    knob.BackgroundColor3 = Color3.fromRGB(255,0,0)
    knob.BorderSizePixel = 0
    knob.Parent = slider
    
    local dragging = false
    knob.MouseButton1Down:Connect(function()
        dragging = true
        local moveConn
        moveConn = UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
                local pos = input.Position.X - slider.AbsolutePosition.X
                local newX = math.clamp(pos / slider.AbsoluteSize.X, 0, 1)
                fill.Size = UDim2.new(newX, 0, 1, 0)
                knob.Position = UDim2.new(newX, -5, 0, -6)
                local value = minVal + newX * (maxVal - minVal)
                label.Text = text .. ": " .. string.format("%.1f", value)
                callback(value)
            end
        end)
        local releaseConn
        releaseConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                moveConn:Disconnect()
                releaseConn:Disconnect()
            end
        end)
    end)
end

function createToggleButton(parent, text, defaultValue, x, y)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 100, 0, 30)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.Text = text .. ": OFF"
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.BackgroundColor3 = Color3.fromRGB(50,50,50)
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(255,0,0)
    btn.Font = Enum.Font.GothamBold
    btn.Parent = parent
    
    local toggled = defaultValue
    btn.MouseButton1Click:Connect(function()
        toggled = not toggled
        btn.Text = text .. ": " .. (toggled and "ON" or "OFF")
        btn.BackgroundColor3 = toggled and Color3.fromRGB(0,100,0) or Color3.fromRGB(50,50,50)
        if btn.OnToggle then btn.OnToggle(toggled) end
    end)
    btn.OnToggle = nil
    local result = {}
    function result.OnToggle(func) btn.OnToggle = func end
    return result
end

-- 🔹 Implementações das funcionalidades

-- ESP (Highlight + NameTags)
local espObjects = {}

function startESP()
    stopESP()
    if not (state.espBox or state.espName) then return end
    
    local function updateESP()
        for _, player in ipairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            local char = player.Character
            if not char or not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then
                if espObjects[player] then
                    if espObjects[player].highlight then espObjects[player].highlight:Destroy() end
                    if espObjects[player].nameTag then espObjects[player].nameTag:Destroy() end
                    espObjects[player] = nil
                end
                continue
            end
            
            if not espObjects[player] then espObjects[player] = {} end
            
            if state.espBox and not espObjects[player].highlight then
                local hl = Instance.new("Highlight")
                hl.Adornee = char
                hl.FillTransparency = 1
                hl.OutlineColor = state.espColor
                hl.OutlineTransparency = 0
                hl.Parent = char
                espObjects[player].highlight = hl
            elseif state.espBox and espObjects[player].highlight then
                espObjects[player].highlight.OutlineColor = state.espColor
            elseif not state.espBox and espObjects[player].highlight then
                espObjects[player].highlight:Destroy()
                espObjects[player].highlight = nil
            end
            
            if state.espName and not espObjects[player].nameTag then
                local tag = Instance.new("BillboardGui")
                tag.Size = UDim2.new(0, 100, 0, 30)
                tag.AlwaysOnTop = true
                tag.Parent = char:FindFirstChild("Head") or char
                local text = Instance.new("TextLabel")
                text.Size = UDim2.new(1,0,1,0)
                text.BackgroundTransparency = 1
                text.TextColor3 = state.espColor
                text.TextStrokeTransparency = 0.5
                text.Text = player.Name
                text.Font = Enum.Font.GothamBold
                text.TextSize = 14
                text.Parent = tag
                espObjects[player].nameTag = tag
            elseif state.espName and espObjects[player].nameTag then
             
