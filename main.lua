-- MGZMODZ SYNAPSE STYLE UI

local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
gui.Name = "MGZMODZ_SYN"

local states = {}

-- FUNÇÃO DRAG
local function dragify(frame)
	local dragToggle, dragStart, startPos
	
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragToggle = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragToggle and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragToggle = false
		end
	end)
end

-- NOTIFICAÇÃO BONITA
local function notify(txt)
	local f = Instance.new("Frame", gui)
	f.Size = UDim2.new(0,260,0,45)
	f.Position = UDim2.new(0.5,-130,1,0)
	f.BackgroundColor3 = Color3.fromRGB(15,15,25)

	local stroke = Instance.new("UIStroke", f)
	stroke.Color = Color3.fromRGB(0,170,255)

	local t = Instance.new("TextLabel", f)
	t.Size = UDim2.new(1,0,1,0)
	t.BackgroundTransparency = 1
	t.Text = txt
	t.TextColor3 = Color3.new(1,1,1)

	TweenService:Create(f, TweenInfo.new(0.3), {
		Position = UDim2.new(0.5,-130,0.85,0)
	}):Play()

	task.delay(2,function()
		f:Destroy()
	end)
end

-- ================= LOGIN =================
local login = Instance.new("Frame", gui)
login.Size = UDim2.new(0,320,0,200)
login.Position = UDim2.new(0.5,-160,0.5,-100)
login.BackgroundColor3 = Color3.fromRGB(12,12,18)

dragify(login)

Instance.new("UIStroke", login).Color = Color3.fromRGB(0,170,255)

local title = Instance.new("TextLabel", login)
title.Size = UDim2.new(1,0,0,40)
title.Text = "MGZMODZ ACCESS"
title.BackgroundTransparency = 1
title.TextColor3 = Color3.fromRGB(0,170,255)
title.Font = Enum.Font.GothamBold

local box = Instance.new("TextBox", login)
box.Size = UDim2.new(0.8,0,0,35)
box.Position = UDim2.new(0.1,0,0.4,0)
box.PlaceholderText = "Enter Key..."
box.BackgroundColor3 = Color3.fromRGB(20,20,30)
box.TextColor3 = Color3.new(1,1,1)

local enter = Instance.new("TextButton", login)
enter.Size = UDim2.new(0.6,0,0,35)
enter.Position = UDim2.new(0.2,0,0.7,0)
enter.Text = "UNLOCK"
enter.BackgroundColor3 = Color3.fromRGB(0,170,255)

-- ================= MAIN =================
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,540,0,430)
main.Position = UDim2.new(0.5,-270,0.5,-215)
main.BackgroundColor3 = Color3.fromRGB(15,15,25)
main.Visible = false

dragify(main)

local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,170,255)

local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,45)
top.BackgroundColor3 = Color3.fromRGB(0,170,255)

local title2 = Instance.new("TextLabel", top)
title2.Size = UDim2.new(1,-90,1,0)
title2.Text = "MGZMODZ HUB"
title2.BackgroundTransparency = 1
title2.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", top)
close.Size = UDim2.new(0,45,1,0)
close.Position = UDim2.new(1,-45,0,0)
close.Text = "X"

local mini = Instance.new("TextButton", top)
mini.Size = UDim2.new(0,45,1,0)
mini.Position = UDim2.new(1,-90,0,0)
mini.Text = "-"

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,0,1,-90)
content.Position = UDim2.new(0,0,0,90)
content.BackgroundTransparency = 1

local function clear()
	for _,v in pairs(content:GetChildren()) do
		v:Destroy()
	end
end

-- BOTÃO ESTILO PREMIUM
local function toggle(name,y)
	if states[name]==nil then states[name]=false end
	
	local b = Instance.new("TextButton", content)
	b.Size = UDim2.new(0.9,0,0,35)
	b.Position = UDim2.new(0.05,0,0,y)
	b.Font = Enum.Font.Gotham
	
	local function update()
		b.Text = name.." : "..(states[name] and "ON" or "OFF")
		b.BackgroundColor3 = states[name] and Color3.fromRGB(0,170,255) or Color3.fromRGB(30,30,45)
	end
	
	update()
	
	b.MouseButton1Click:Connect(function()
		states[name]=not states[name]
		update()
	end)
	
	b.MouseEnter:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.2), {
			BackgroundColor3 = Color3.fromRGB(50,50,70)
		}):Play()
	end)
	
	b.MouseLeave:Connect(function()
		update()
	end)
end

-- ABAS
local function tab(name,x,func)
	local t = Instance.new("TextButton", main)
	t.Size = UDim2.new(0.25,0,0,45)
	t.Position = UDim2.new(x,0,0,45)
	t.Text = name
	t.BackgroundColor3 = Color3.fromRGB(20,20,30)
	t.MouseButton1Click:Connect(func)
end

-- PÁGINAS
local function Aimbot()
	clear()
	local y=5
	for _,v in ipairs({"Aimbot","FOV","Silent","Team","Recoil","Lock"}) do
		toggle(v,y)
		y+=40
	end
end

local function Visual()
	clear()
	local y=5
	for _,v in ipairs({"ESP","Name","Box","Line","Health","Skeleton"}) do
		toggle(v,y)
		y+=40
	end
end

local function Misc()
	clear()
	local y=5
	for _,v in ipairs({"Speed","Fly","Spin","TP","Farm","AFK"}) do
		toggle(v,y)
		y+=40
	end
end

local function MainTab()
	clear()
	local y=5
	for _,v in ipairs({"Invisible","XRay","FullBright","NoFog","FPSBoost","Reset"}) do
		toggle(v,y)
		y+=40
	end
end

tab("Aimbot",0,Aimbot)
tab("Visual",0.25,Visual)
tab("Misc",0.5,Misc)
tab("Main",0.75,MainTab)

Aimbot()

-- MINIMIZAR
local minimized=false
mini.MouseButton1Click:Connect(function()
	minimized=not minimized
	content.Visible=not minimized
	main.Size=minimized and UDim2.new(0,240,0,45) or UDim2.new(0,540,0,430)
end)

close.MouseButton1Click:Connect(function()
	gui:Destroy()
end)

-- LOGIN
enter.MouseButton1Click:Connect(function()
	if box.Text=="MGZ" then
		login:Destroy()
		main.Visible=true
	else
		notify("Key errada!")
	end
end)
