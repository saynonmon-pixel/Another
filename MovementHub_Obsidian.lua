--[[
    Movement Hub - Obsidian UI
    Roblox Studio LocalScript
    Place in: StarterPlayer > StarterPlayerScripts

    Features:
      • Fly
      • Noclip
      • Teleport to mouse
      • Teleport forward
      • Reverse controls
      • Fly speed

    Uses the Obsidian UI library by deividcomsono.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()

-- Load Obsidian
local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/deividcomsono/Obsidian/refs/heads/main/Library.lua"
))()

local Window = Library:CreateWindow({
    Title = "Movement Hub",
    Footer = "Fly • Noclip • Teleport",
    Size = UDim2.fromOffset(1050, 470),
    Center = true,
    AutoShow = true,
    ToggleKeybind = Enum.KeyCode.RightControl
})

local MovementTab = Window:AddTab("Movement", "move-3d")
local TeleportTab = Window:AddTab("Teleport", "map-pin")

local Character
local Humanoid
local Root

local Flying = false
local Noclip = false
local Reverse = false
local FlySpeed = 60

local FlyConnection
local NoclipConnection

local function SetupCharacter(CharacterModel)
    Character = CharacterModel
    Humanoid = Character:WaitForChild("Humanoid")
    Root = Character:WaitForChild("HumanoidRootPart")
end

SetupCharacter(Player.Character or Player.CharacterAdded:Wait())

Player.CharacterAdded:Connect(function(NewCharacter)
    Flying = false
    Noclip = false
    SetupCharacter(NewCharacter)
end)

--==================================================
-- FLY
--==================================================

local function SetFly(State)
    Flying = State

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if not Flying then
        if Humanoid then
            Humanoid.PlatformStand = false
        end

        if Root then
            Root.AssemblyLinearVelocity = Vector3.zero
        end

        return
    end

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Character or not Humanoid or not Root then
            return
        end

        local Camera = workspace.CurrentCamera
        local Direction = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            Direction += Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            Direction -= Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            Direction += Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            Direction -= Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            Direction += Vector3.yAxis
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
            Direction -= Vector3.yAxis
        end

        if Reverse then
            Direction = -Direction
        end

        if Direction.Magnitude > 0 then
            Direction = Direction.Unit
        end

        Humanoid.PlatformStand = true
        Root.AssemblyLinearVelocity = Direction * FlySpeed
    end)
end

--==================================================
-- NOCLIP
--==================================================

local function SetNoclip(State)
    Noclip = State

    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    if not Noclip then
        if Character then
            for _, Part in ipairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = true
                end
            end
        end

        return
    end

    NoclipConnection = RunService.Stepped:Connect(function()
        if Character then
            for _, Part in ipairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then
                    Part.CanCollide = false
                end
            end
        end
    end)
end

--==================================================
-- MOVEMENT TAB
--==================================================

local MovementBox = MovementTab:AddLeftGroupbox("Movement")

MovementBox:AddToggle("Fly", {
    Text = "Fly",
    Default = false,
    Callback = SetFly
})

MovementBox:AddSlider("FlySpeed", {
    Text = "Fly Speed",
    Default = 60,
    Min = 1,
    Max = 500,
    Rounding = 0,
    Compact = false,
    Callback = function(Value)
        FlySpeed = Value
    end
})

MovementBox:AddToggle("Noclip", {
    Text = "Noclip",
    Default = false,
    Callback = SetNoclip
})

MovementBox:AddToggle("Reverse", {
    Text = "Reverse Controls",
    Default = false,
    Callback = function(Value)
        Reverse = Value
    end
})

local InfoBox = MovementTab:AddRightGroupbox("Controls")

InfoBox:AddLabel("W / A / S / D  -  Fly")
InfoBox:AddLabel("Space  -  Up")
InfoBox:AddLabel("Left Ctrl  -  Down")
InfoBox:AddLabel("Right Ctrl  -  Show / Hide UI")

--==================================================
-- TELEPORT TAB
--==================================================

local TeleportBox = TeleportTab:AddLeftGroupbox("Teleport")

TeleportBox:AddButton({
    Text = "Teleport To Mouse",
    Func = function()
        if Root and Mouse.Hit then
            Root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
        end
    end
})

TeleportBox:AddButton({
    Text = "Teleport Forward",
    Func = function()
        if Root then
            Root.CFrame = Root.CFrame + Root.CFrame.LookVector * 20
        end
    end
})

TeleportBox:AddButton({
    Text = "Teleport To Spawn",
    Func = function()
        local Spawn = workspace:FindFirstChildWhichIsA("SpawnLocation", true)

        if Spawn and Root then
            Root.CFrame = Spawn.CFrame + Vector3.new(0, 4, 0)
        end
    end
})

--==================================================
-- CLEANUP
--==================================================

Library:OnUnload(function()
    Flying = false
    Noclip = false

    if FlyConnection then
        FlyConnection:Disconnect()
        FlyConnection = nil
    end

    if NoclipConnection then
        NoclipConnection:Disconnect()
        NoclipConnection = nil
    end

    if Humanoid then
        Humanoid.PlatformStand = false
    end

    if Character then
        for _, Part in ipairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then
                Part.CanCollide = true
            end
        end
    end
end)

print("Movement Hub loaded with Obsidian UI.")
