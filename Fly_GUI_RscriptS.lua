-- Fly GUI RscriptS
-- Normal Roblox gravity
-- Swimming state kept
-- Water/swimming sounds muted only
-- X = complete shutdown

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer

local speeds = 1
local nowe = false
local tpwalking = false
local scriptRunning = true

local tis = nil
local dis = nil
local soundConnection = nil
local flyConnections = {}
local bodyMovers = {}

-- Normal Roblox gravity is untouched.

local DARK_BLUE = Color3.fromRGB(18, 29, 78)
local WHITE = Color3.fromRGB(245, 245, 245)
local LIGHT_GRAY = Color3.fromRGB(210, 210, 210)
local BORDER_GRAY = Color3.fromRGB(125, 125, 125)
local RED = Color3.fromRGB(255, 35, 35)
local BLACK = Color3.fromRGB(20, 20, 20)

local main = Instance.new("ScreenGui")
main.Name = "FlyGUI_RscriptS"
main.Parent = player:WaitForChild("PlayerGui")
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Name = "Frame"
Frame.Parent = main
Frame.BackgroundColor3 = WHITE
Frame.BorderColor3 = BORDER_GRAY
Frame.BorderSizePixel = 2
Frame.Position = UDim2.new(0.1, 0, 0.38, 0)
Frame.Size = UDim2.new(0, 500, 0, 125)
Frame.Active = true
Frame.Draggable = true

local TitleBar = Instance.new("Frame")
TitleBar.Parent = Frame
TitleBar.BackgroundColor3 = DARK_BLUE
TitleBar.BorderSizePixel = 0
TitleBar.Size = UDim2.new(1, 0, 0, 45)

local TextLabel = Instance.new("TextLabel")
TextLabel.Parent = TitleBar
TextLabel.BackgroundTransparency = 1
TextLabel.Position = UDim2.new(0, 140, 0, 0)
TextLabel.Size = UDim2.new(1, -210, 1, 0)
TextLabel.Font = Enum.Font.SciFi
TextLabel.Text = "Fly GUI RscriptS"
TextLabel.TextColor3 = WHITE
TextLabel.TextSize = 20
TextLabel.TextXAlignment = Enum.TextXAlignment.Center

local closebutton = Instance.new("TextButton")
closebutton.Parent = TitleBar
closebutton.BackgroundColor3 = RED
closebutton.BorderColor3 = BORDER_GRAY
closebutton.Size = UDim2.new(0, 70, 1, 0)
closebutton.Font = Enum.Font.SciFi
closebutton.Text = "X"
closebutton.TextColor3 = BLACK
closebutton.TextSize = 28

local mini = Instance.new("TextButton")
mini.Parent = TitleBar
mini.BackgroundColor3 = LIGHT_GRAY
mini.BorderColor3 = BORDER_GRAY
mini.Position = UDim2.new(0, 70, 0, 0)
mini.Size = UDim2.new(0, 70, 1, 0)
mini.Font = Enum.Font.SciFi
mini.Text = "-"
mini.TextColor3 = BLACK
mini.TextSize = 28

local mini2 = Instance.new("TextButton")
mini2.Parent = main
mini2.BackgroundColor3 = LIGHT_GRAY
mini2.BorderColor3 = BORDER_GRAY
mini2.Position = UDim2.new(0.1, 70, 0.38, 0)
mini2.Size = UDim2.new(0, 70, 0, 45)
mini2.Font = Enum.Font.SciFi
mini2.Text = "+"
mini2.TextColor3 = BLACK
mini2.TextSize = 28
mini2.Visible = false

local function makeButton(name, text, position)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Parent = Frame
	b.BackgroundColor3 = WHITE
	b.BorderColor3 = BORDER_GRAY
	b.BorderSizePixel = 1
	b.Position = position
	b.Size = UDim2.new(0, 100, 0, 40)
	b.Font = Enum.Font.SciFi
	b.Text = text
	b.TextColor3 = BLACK
	b.TextSize = 22
	return b
end

local up = makeButton("up", "↑", UDim2.new(0, 0, 0, 45))
local down = makeButton("down", "↓", UDim2.new(0, 0, 0, 85))
local plus = makeButton("plus", "+", UDim2.new(0, 100, 0, 45))
local mine = makeButton("mine", "-", UDim2.new(0, 100, 0, 85))

local speed = Instance.new("TextLabel")
speed.Parent = Frame
speed.BackgroundColor3 = WHITE
speed.BorderColor3 = BORDER_GRAY
speed.Position = UDim2.new(0, 200, 0, 85)
speed.Size = UDim2.new(0, 100, 0, 40)
speed.Font = Enum.Font.SciFi
speed.Text = "1"
speed.TextColor3 = BLACK
speed.TextSize = 22

local modeLabel = Instance.new("TextLabel")
modeLabel.Parent = Frame
modeLabel.BackgroundColor3 = WHITE
modeLabel.BorderColor3 = BORDER_GRAY
modeLabel.Position = UDim2.new(0, 200, 0, 45)
modeLabel.Size = UDim2.new(0, 200, 0, 40)
modeLabel.Font = Enum.Font.SciFi
modeLabel.Text = "Fly gui modded"
modeLabel.TextColor3 = BLACK
modeLabel.TextSize = 18

local onof = makeButton("onof", "FLY", UDim2.new(0, 300, 0, 85))
onof.TextSize = 18

-- Sound only: mute water/swimming/splash sounds without changing movement.
local function muteWaterSounds()
	if not scriptRunning then return end
	local character = player.Character
	if not character then return end

	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("Sound") then
			local name = obj.Name:lower()
			if name:find("swim") or name:find("water") or name:find("splash") then
				obj.Volume = 0
				obj:Stop()
			end
		end
	end
end

soundConnection = RunService.Heartbeat:Connect(muteWaterSounds)

local function stopFly()
	nowe = false
	tpwalking = false

	for _, connection in ipairs(flyConnections) do
		if connection then connection:Disconnect() end
	end
	table.clear(flyConnections)

	for _, mover in ipairs(bodyMovers) do
		if mover and mover.Parent then mover:Destroy() end
	end
	table.clear(bodyMovers)

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")

	if humanoid then
		humanoid.PlatformStand = false

		for _, state in ipairs({
			Enum.HumanoidStateType.Climbing,
			Enum.HumanoidStateType.FallingDown,
			Enum.HumanoidStateType.Flying,
			Enum.HumanoidStateType.Freefall,
			Enum.HumanoidStateType.GettingUp,
			Enum.HumanoidStateType.Jumping,
			Enum.HumanoidStateType.Landed,
			Enum.HumanoidStateType.Physics,
			Enum.HumanoidStateType.PlatformStanding,
			Enum.HumanoidStateType.Ragdoll,
			Enum.HumanoidStateType.Running,
			Enum.HumanoidStateType.RunningNoPhysics,
			Enum.HumanoidStateType.Seated,
			Enum.HumanoidStateType.StrafingNoPhysics,
			Enum.HumanoidStateType.Swimming
		}) do
			humanoid:SetStateEnabled(state, true)
		end

		humanoid:ChangeState(Enum.HumanoidStateType.Running)
	end

	if character then
		local animate = character:FindFirstChild("Animate")
		if animate then animate.Disabled = false end
	end

	onof.Text = "FLY"
end

local function shutdown()
	if not scriptRunning then return end
	scriptRunning = false

	stopFly()

	if tis then tis:Disconnect(); tis = nil end
	if dis then dis:Disconnect(); dis = nil end
	if soundConnection then soundConnection:Disconnect(); soundConnection = nil end

	if main then main:Destroy() end
end

pcall(function()
	StarterGui:SetCore("SendNotification", {
		Title = "Fly GUI RscriptS",
		Text = "BY RscriptS",
		Duration = 5
	})
end)

onof.MouseButton1Click:Connect(function()
	if not scriptRunning then return end

	if nowe then
		stopFly()
		return
	end

	local character = player.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not character or not humanoid then return end

	nowe = true
	onof.Text = "UNFLY"

	local animate = character:FindFirstChild("Animate")
	if animate then animate.Disabled = true end

	for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
		track:AdjustSpeed(0)
	end

	-- Keep the Roblox Swimming state.
	humanoid:SetStateEnabled(Enum.HumanoidStateType.Swimming, true)
	humanoid:ChangeState(Enum.HumanoidStateType.Swimming)

	tpwalking = true

	for i = 1, speeds do
		task.spawn(function()
			while tpwalking and nowe and scriptRunning do
				RunService.Heartbeat:Wait()
				local char = player.Character
				local hum = char and char:FindFirstChildOfClass("Humanoid")
				if char and hum and hum.Parent and hum.MoveDirection.Magnitude > 0 then
					char:TranslateBy(hum.MoveDirection)
				end
			end
		end)
	end

	local root = character:FindFirstChild("HumanoidRootPart")
		or character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")

	if not root then
		stopFly()
		return
	end

	local bodyGyro = Instance.new("BodyGyro")
	bodyGyro.Parent = root
	bodyGyro.P = 90000
	bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	bodyGyro.CFrame = root.CFrame

	local bodyVelocity = Instance.new("BodyVelocity")
	bodyVelocity.Parent = root
	bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	bodyVelocity.Velocity = Vector3.zero

	table.insert(bodyMovers, bodyGyro)
	table.insert(bodyMovers, bodyVelocity)

	humanoid.PlatformStand = true

	local currentSpeed = 0
	local maxSpeed = 50
	local lastDirection = Vector3.zero

	local connection = RunService.RenderStepped:Connect(function()
		if not scriptRunning or not nowe then return end

		if not root.Parent or humanoid.Health <= 0 then
			stopFly()
			return
		end

		local camera = workspace.CurrentCamera
		local direction = humanoid.MoveDirection

		if direction.Magnitude > 0 then
			currentSpeed = math.min(currentSpeed + 0.5, maxSpeed)
			lastDirection = direction
		else
			currentSpeed = math.max(currentSpeed - 1, 0)
		end

		if direction.Magnitude > 0 then
			bodyVelocity.Velocity = direction * currentSpeed
		elseif currentSpeed > 0 then
			bodyVelocity.Velocity = lastDirection * currentSpeed
		else
			bodyVelocity.Velocity = Vector3.zero
		end

		bodyGyro.CFrame = camera.CFrame
	end)

	table.insert(flyConnections, connection)
end)

up.MouseButton1Down:Connect(function()
	if not scriptRunning then return end
	if tis then tis:Disconnect() end

	tis = RunService.Heartbeat:Connect(function()
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = root.CFrame * CFrame.new(0, 1, 0) end
	end)
end)

up.MouseButton1Up:Connect(function()
	if tis then tis:Disconnect(); tis = nil end
end)

up.MouseLeave:Connect(function()
	if tis then tis:Disconnect(); tis = nil end
end)

down.MouseButton1Down:Connect(function()
	if not scriptRunning then return end
	if dis then dis:Disconnect() end

	dis = RunService.Heartbeat:Connect(function()
		local character = player.Character
		local root = character and character:FindFirstChild("HumanoidRootPart")
		if root then root.CFrame = root.CFrame * CFrame.new(0, -1, 0) end
	end)
end)

down.MouseButton1Up:Connect(function()
	if dis then dis:Disconnect(); dis = nil end
end)

down.MouseLeave:Connect(function()
	if dis then dis:Disconnect(); dis = nil end
end)

plus.MouseButton1Click:Connect(function()
	if not scriptRunning then return end
	speeds += 1
	speed.Text = tostring(speeds)
end)

mine.MouseButton1Click:Connect(function()
	if not scriptRunning then return end

	if speeds <= 1 then
		speed.Text = "MIN 1"
		task.delay(1, function()
			if scriptRunning then speed.Text = tostring(speeds) end
		end)
		return
	end

	speeds -= 1
	speed.Text = tostring(speeds)
end)

player.CharacterAdded:Connect(function()
	if not scriptRunning then return end
	task.wait(0.7)
	stopFly()
end)

closebutton.MouseButton1Click:Connect(shutdown)

mini.MouseButton1Click:Connect(function()
	if not scriptRunning then return end
	Frame.Visible = false
	mini2.Visible = true
end)

mini2.MouseButton1Click:Connect(function()
	if not scriptRunning then return end
	Frame.Visible = true
	mini2.Visible = false
end)
