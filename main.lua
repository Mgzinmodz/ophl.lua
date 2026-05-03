-- // MGZ MODS - UI FUTURISTA (LEVEL GOD)

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer

-- GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "MGZ_MODS_V2"

-- BOTÃO FLUTUANTE
local float = Instance.new("TextButton", gui)
float.Size = UDim2.new(0,60,0,60)
float.Position = UDim2.new(0,20,0.5,-30)
float.Text = "MG"
float.BackgroundColor3 = Color3.fromRGB(0,170,255)
float.TextColor3 = Color3.new(1,1,1)
float.Font = Enum.Font.GothamBold
float.TextSize = 18

Instance.new("UICorner", float).CornerRadius = UDim.new(1,0)

-- MAIN FRAME
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,600,0,350)
main.Position = UDim2.new(0.5,-300,0.5,-175)
main.BackgroundColor3 = Color3.fromRGB(15,15,25)
main.Visible = false

Instance.new("UICorner", main).CornerRadius = UDim.new(0,10)

-- GLOW EFFECT
local stroke = Instance.new("UIStroke", main)
stroke.Color = Color3.fromRGB(0,170,255)
stroke.Thickness = 2

-- TOP BAR
local top = Instance.new("Frame", main)
top.Size = UDim2.new(1,0,0,40)
top.BackgroundTransparency = 1

local title = Instance.new("TextLabel", top)
title.Size = UDim2.new(1,0,1,0)
title.Text = "MGZ MODS"
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.BackgroundTransparency = 1

-- DRAG
local dragging, dragInput, startPos, startFrame

top.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		startPos = input.Position
		startFrame = main.Position
	end
end)

UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - startPos
		main.Position = UDim2.new(
			startFrame.X.Scale,
			startFrame.X.Offset + delta.X,
			startFrame.Y.Scale,
			startFrame.Y.Offset + delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)

-- SIDEBAR
local side = Instance.new("Frame", main)
side.Size = UDim2.new(0,140,1,-40)
side.Position = UDim2.new(0,0,0,40)
side.BackgroundColor3 = Color3.fromRGB(20,20,30)

Instance.new("UICorner", side).CornerRadius = UDim.new(0,10)

-- CONTENT
local content = Instance.new("Frame", main)
content.Size = UDim2.new(1,-150,1,-50)
content.Position = UDim2.new(0,150,0,45)
content.BackgroundTransparency = 1

-- TABS
local pages = {}

local function createTab(name, y)
	local btn = Instance.new("TextButton", side)
	btn.Size = UDim2.new(1,-10,0,40)
	btn.Position = UDim2.new(0,5,0,y)
	btn.Text = name
	btn.BackgroundColor3 = Color3.fromRGB(30,30,45)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

	local page = Instance.new("Frame", content)
	page.Size = UDim2.new(1,0,1,0)
	page.Visible = false
	page.BackgroundTransparency = 1

	btn.MouseButton1Click:Connect(function()
		for _,p in pairs(pages) do
			p.Visible = false
		end
		page.Visible = true
	end)

	pages[name] = page
	return page
end

-- CRIAR ABAS
local aimbot = createTab("Aimbot",10)
local visual = createTab("Visual",60)
local misc = createTab("Misc",110)
local mainTab = createTab("Main",160)
local info = createTab("Info",210)

aimbot.Visible = true

-- TOGGLE BONITO
local function createToggle(parent, text, y)
	local btn = Instance.new("TextButton", parent)
	btn.Size = UDim2.new(0,220,0,35)
	btn.Position = UDim2.new(0,10,0,y)
	btn.BackgroundColor3 = Color3.fromRGB(35,35,50)
	btn.Text = text
	btn.TextColor3 = Color3.new(1,1,1)
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 14

	local circle = Instance.new("Frame", btn)
	circle.Size = UDim2.new(0,20,0,20)
	circle.Position = UDim2.new(1,-30,0.5,-10)
	circle.BackgroundColor3 = Color3.fromRGB(80,80,100)

	Instance.new("UICorner", circle).CornerRadius = UDim.new(1,0)

	local state = false

	btn.MouseButton1Click:Connect(function()
		state = not state
		TweenService:Create(circle, TweenInfo.new(0.2), {
			BackgroundColor3 = state and Color3.fromRGB(0,170,255) or Color3.fromRGB(80,80,100)
		}):Play()
	end)
end

-- SLIDER BONITO
local function createSlider(parent, text, y)
	local label = Instance.new("TextLabel", parent)
	label.Position = UDim2.new(0,10,0,y)
	label.Size = UDim2.new(0,220,0,20)
	label.Text = text.." : 0"
	label.TextColor3 = Color3.new(1,1,1)
	label.BackgroundTransparency = 1

	local bar = Instance.new("Frame", parent)
	bar.Position = UDim2.new(0,10,0,y+20)
	bar.Size = UDim2.new(0,220,0,8)
	bar.BackgroundColor3 = Color3.fromRGB(50,50,70)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new(0,0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(0,170,255)

	bar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local move
			move = UIS.InputChanged:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseMovement then
					local size = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
					fill.Size = UDim2.new(size,0,1,0)
					label.Text = text.." : "..math.floor(size*100)
				end
			end)
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					move:Disconnect()
				end
			end)
		end
	end)
end

-- EXEMPLO
createToggle(aimbot,"Enable Aimbot",10)
createToggle(aimbot,"Team Check",55)
createSlider(aimbot,"FOV",100)

-- ABRIR
float.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)end)
