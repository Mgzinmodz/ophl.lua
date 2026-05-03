-- MGZMODZ ELITE UI (APENAS INTERFACE PERFEITA)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "MGZMODZ_UI"

-- CONFIG DE ESTADO (NÃO RESETAR)
local states = {}

-- MAIN
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,520,0,420)
main.Position = UDim2.new(0.5,-260,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(20,20,30)

-- DRAG
local drag, dragInput, start, startPos

main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = true
		start = input.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - start
		main.Position = UDim2.new(
			startPos.X.Scale,
			startPos.X.Offset + delta.X,
			startPos.Y.Scale,
			startPos.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		drag = false
	end
end)

-- TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,40)
top.BackgroundColor3 = Color3.fromRGB(0,170,255)

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,-100,1,0)
title.Text = "MGZMODZ HUB"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0,40,1,0)
close.Position = UDim2.new(1,-40,0,0)
close.Text = "X"

local mini = Instance.new("TextButton", top)
mini.Size = UDim2.new(0,40,1,0)
mini.Position = UDim2.new(1,-80,0,0)
mini.Text = "-"

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,1,-80)
content.Position = UDim2.new(0,0,0,80)
content.BackgroundTransparency = 1

-- CLEAR
local function clear()
	for _,v in pairs(content:GetChildren()) do
		v:Destroy()
	end
end

-- BOTÃO (COM SALVAR ESTADO)
local function toggle(name,y)
	if states[name] == nil then states[name] = false end
	
	local btn = Instance.new("TextButton", content)
	btn.Size = UDim2.new(0.9,0,0,32)
	btn.Position = UDim2.new(0.05,0,0,y)
	btn.Font = Enum.Font.Gotham
	
	local function update()
		btn.Text = name.." : "..(states[name] and "ON" or "OFF")
		btn.BackgroundColor3 = states[name] and Color3.fromRGB(0,170,255) or Color3.fromRGB(40,40,55)
	end
	
	update()
	
	btn.MouseButton1Click:Connect(function()
		states[name] = not states[name]
		update()
	end)
end

-- ABAS
local function createTab(name,x,func)
	local tab = Instance.new("TextButton", main)
	tab.Size = UDim2.new(0.25,0,0,40)
	tab.Position = UDim2.new(x,0,0,40)
	tab.Text = name
	tab.BackgroundColor3 = Color3.fromRGB(30,30,45)
	tab.Font = Enum.Font.Gotham
	
	tab.MouseButton1Click:Connect(func)
end

-- PÁGINAS
local function Aimbot()
	clear()
	local y = 5
	for _,v in ipairs({
		"Aimbot","FOV Circle","Silent Aim","Team Check","No Recoil","Aim Lock"
	}) do
		toggle(v,y)
		y+=35
	end
end

local function Visual()
	clear()
	local y = 5
	for _,v in ipairs({
		"ESP","ESP Name","ESP Box","ESP Line","ESP Health","ESP Skeleton"
	}) do
		toggle(v,y)
		y+=35
	end
end

local function Misc()
	clear()
	local y = 5
	for _,v in ipairs({
		"Speed","Fly","Spin","Teleport","Auto Farm","Anti AFK"
	}) do
		toggle(v,y)
		y+=35
	end
end

local function MainTab()
	clear()
	local y = 5
	for _,v in ipairs({
		"Invisible","X-Ray","Full Bright","No Fog","FPS Boost","Reset UI"
	}) do
		toggle(v,y)
		y+=35
	end
end

-- CREATE TABS
createTab("Aimbot",0,Aimbot)
createTab("Visual",0.25,Visual)
createTab("Misc",0.5,Misc)
createTab("Main",0.75,MainTab)

Aimbot()

-- MINIMIZAR REAL
local minimized = false
mini.MouseButton1Click:Connect(function()
	minimized = not minimized
	
	if minimized then
		content.Visible = false
		for _,v in pairs(main:GetChildren()) do
			if v ~= top then v.Visible = false end
		end
		main.Size = UDim2.new(0,220,0,40)
	else
		content.Visible = true
		for _,v in pairs(main:GetChildren()) do
			v.Visible = true
		end
		main.Size = UDim2.new(0,520,0,420)
	end
end)

-- FECHAR
close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)
