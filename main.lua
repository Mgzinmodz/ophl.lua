-- MGZMODZ PREMIUM (KEY SYSTEM + UI)

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")

-- GUI
local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))

-- ================= LOGIN =================
local login = Instance.new("Frame", gui)
login.Size = UDim2.new(0,300,0,180)
login.Position = UDim2.new(0.5,-150,0.5,-90)
login.BackgroundColor3 = Color3.fromRGB(25,25,35)

local title = Instance.new("TextLabel", login)
title.Size = UDim2.new(1,0,0,40)
title.Text = "MGZMODZ LOGIN"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1,1,1)

local keyBox = Instance.new("TextBox", login)
keyBox.Size = UDim2.new(0.8,0,0,35)
keyBox.Position = UDim2.new(0.1,0,0.4,0)
keyBox.PlaceholderText = "Digite a Key..."
keyBox.Text = ""

local enterBtn = Instance.new("TextButton", login)
enterBtn.Size = UDim2.new(0.6,0,0,35)
enterBtn.Position = UDim2.new(0.2,0,0.7,0)
enterBtn.Text = "ENTRAR"
enterBtn.BackgroundColor3 = Color3.fromRGB(0,170,255)

-- NOTIFICAÇÃO
local function notify(msg)
	local n = Instance.new("TextLabel", gui)
	n.Size = UDim2.new(0,250,0,40)
	n.Position = UDim2.new(0.5,-125,0.8,0)
	n.Text = msg
	n.BackgroundColor3 = Color3.fromRGB(40,40,50)
	n.TextColor3 = Color3.new(1,1,1)
	task.delay(2,function() n:Destroy() end)
end

-- ================= MAIN HUB =================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,500,0,400)
main.Position = UDim2.new(0.5,-250,0.5,-200)
main.BackgroundColor3 = Color3.fromRGB(25,25,35)
main.Visible = false

-- DRAG
local dragging, dragStart, startPos
main.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = input.Position
		startPos = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
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
		dragging = false
	end
end)

-- TOPO
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,35)
top.BackgroundColor3 = Color3.fromRGB(0,170,255)

local title2 = Instance.new("TextLabel", top)
title2.Size = UDim2.new(1,-80,1,0)
title2.Text = "MGZMODZ HUB"
title2.BackgroundTransparency = 1
title2.TextColor3 = Color3.new(1,1,1)

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
content.Size = UDim2.new(1,0,1,-70)
content.Position = UDim2.new(0,0,0,70)
content.BackgroundTransparency = 1

local function clear()
	for _,v in pairs(content:GetChildren()) do
		v:Destroy()
	end
end

local function option(text,y)
	local btn = Instance.new("TextButton", content)
	btn.Size = UDim2.new(0.9,0,0,30)
	btn.Position = UDim2.new(0.05,0,0,y)
	btn.Text = text.." : OFF"
	btn.BackgroundColor3 = Color3.fromRGB(40,40,50)
	btn.MouseButton1Click:Connect(function()
		btn.Text = text.." : ON"
	end)
end

-- PÁGINAS
local function aimbot()
	clear()
	local y=5
	for _,v in ipairs({"Aimbot","FOV","Silent Aim","Team Check","No Recoil","Lock"}) do
		option(v,y)
		y+=35
	end
end

local function visual()
	clear()
	local y=5
	for _,v in ipairs({"ESP","ESP Name","ESP Box","ESP Line","ESP Health","ESP Skeleton"}) do
		option(v,y)
		y+=35
	end
end

local function misc()
	clear()
	local y=5
	for _,v in ipairs({"Speed","Fly","Spin","Teleport","Auto Farm","Anti AFK"}) do
		option(v,y)
		y+=35
	end
end

local function mainTab()
	clear()
	local y=5
	for _,v in ipairs({"Invisible","X-Ray","Full Bright","No Fog","FPS Boost","Reset UI"}) do
		option(v,y)
		y+=35
	end
end

-- ABAS
local function tab(name,x,func)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(0.25,0,0,35)
	b.Position = UDim2.new(x,0,0,35)
	b.Text = name
	b.MouseButton1Click:Connect(func)
end

tab("Aimbot",0,aimbot)
tab("Visual",0.25,visual)
tab("Misc",0.5,misc)
tab("Main",0.75,mainTab)

aimbot()

-- CONTROLES
local minimized = false
mini.MouseButton1Click:Connect(function()
	minimized = not minimized
	main.Size = minimized and UDim2.new(0,200,0,35) or UDim2.new(0,500,0,400)
	content.Visible = not minimized
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- ================= LOGIN LOGIC =================
enterBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == "MGZ" then
		login:Destroy()
		main.Visible = true
	else
		notify("Key errada!")
	end
end)
