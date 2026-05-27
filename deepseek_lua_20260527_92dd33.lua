local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.KibaEnabled = false
_G.KibaEarlyFire = 0.55
_G.KibaCooldownStart = nil
_G.KibaSettings = {
    Smoothness = 0.85,
    VerticalBoost = 45,
    HorizontalSpeed = 32,
    DashDuration = 0.48,
    WallCheck = true
}

if PlayerGui:FindFirstChild("KibaXTech") then
    PlayerGui:FindFirstChild("KibaXTech"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KibaXTech"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 48)
MainFrame.Position = UDim2.new(1, 10, 0.5, -24)
MainFrame.BackgroundColor3 = Color3.fromRGB(6, 8, 18)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 12, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(25, 30, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 10, 25))
})
MainGradient.Rotation = 135
MainGradient.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 140, 255)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.2
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local Shadow = Instance.new("UIShadow")
Shadow.Color = Color3.fromRGB(0, 0, 0)
Shadow.Offset = Vector2.new(3, 3)
Shadow.Size = 8
Shadow.Transparency = 0.6
Shadow.Parent = MainFrame

local GlowFrame = Instance.new("Frame")
GlowFrame.Size = UDim2.new(1, 8, 1, 8)
GlowFrame.Position = UDim2.new(0, -4, 0, -4)
GlowFrame.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
GlowFrame.BackgroundTransparency = 0.85
GlowFrame.BorderSizePixel = 0
GlowFrame.ZIndex = 0
GlowFrame.Parent = MainFrame

local GlowCorner = Instance.new("UICorner")
GlowCorner.CornerRadius = UDim.new(0, 20)
GlowCorner.Parent = GlowFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 1, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 4
TitleBar.Parent = MainFrame

local IconDot = Instance.new("Frame")
IconDot.Size = UDim2.new(0, 8, 0, 8)
IconDot.Position = UDim2.new(0, 12, 0.5, -4)
IconDot.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
IconDot.BorderSizePixel = 0
IconDot.ZIndex = 5
IconDot.Parent = MainFrame

local IconDotCorner = Instance.new("UICorner")
IconDotCorner.CornerRadius = UDim.new(1, 0)
IconDotCorner.Parent = IconDot

local IconGlow = Instance.new("Frame")
IconGlow.Size = UDim2.new(0, 8, 0, 8)
IconGlow.Position = UDim2.new(0, 12, 0.5, -4)
IconGlow.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
IconGlow.BackgroundTransparency = 0.5
IconGlow.BorderSizePixel = 0
IconGlow.ZIndex = 4
IconGlow.Parent = MainFrame

local IconGlowCorner = Instance.new("UICorner")
IconGlowCorner.CornerRadius = UDim.new(1, 0)
IconGlowCorner.Parent = IconGlow

task.spawn(function()
    while true do
        TweenService:Create(IconGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(0, 7, 0.5, -9), BackgroundTransparency = 0.9 }):Play()
        task.wait(0.8)
        IconGlow.Size = UDim2.new(0, 8, 0, 8)
        IconGlow.Position = UDim2.new(0, 12, 0.5, -4)
        IconGlow.BackgroundTransparency = 0.5
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "⚡ KIBA X TECH ⚡"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0, 100, 1, 0)
TitleLabel.Position = UDim2.new(0, 26, 0, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 5
TitleLabel.Parent = MainFrame

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Color3.fromRGB(100, 160, 255)
TitleStroke.Thickness = 0.5
TitleStroke.Transparency = 0.5
TitleStroke.Parent = TitleLabel

task.spawn(function()
    while true do
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
        task.wait(1.5)
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(130, 170, 255) }):Play()
        task.wait(1.5)
    end
end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 0, 28)
Divider.Position = UDim2.new(0, 132, 0.5, -14)
Divider.BackgroundColor3 = Color3.fromRGB(80, 110, 200)
Divider.BackgroundTransparency = 0.3
Divider.BorderSizePixel = 0
Divider.ZIndex = 5
Divider.Parent = MainFrame

local ToggleTrack = Instance.new("Frame")
ToggleTrack.Name = "ToggleTrack"
ToggleTrack.Size = UDim2.new(0, 52, 0, 24)
ToggleTrack.Position = UDim2.new(0, 140, 0.5, -12)
ToggleTrack.BackgroundColor3 = Color3.fromRGB(20, 25, 55)
ToggleTrack.BorderSizePixel = 0
ToggleTrack.ClipsDescendants = true
ToggleTrack.ZIndex = 5
ToggleTrack.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleTrack

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 100, 200)
ToggleStroke.Thickness = 1
ToggleStroke.Parent = ToggleTrack

local ToggleText = Instance.new("TextLabel")
ToggleText.Text = "OFF"
ToggleText.Font = Enum.Font.GothamBold
ToggleText.TextSize = 9
ToggleText.TextColor3 = Color3.fromRGB(120, 140, 200)
ToggleText.BackgroundTransparency = 1
ToggleText.Size = UDim2.new(1, 0, 1, 0)
ToggleText.TextXAlignment = Enum.TextXAlignment.Center
ToggleText.ZIndex = 6
ToggleText.Parent = ToggleTrack

local ToggleButton = Instance.new("Frame")
ToggleButton.Size = UDim2.new(0, 18, 0, 18)
ToggleButton.Position = UDim2.new(0, 3, 0.5, -9)
ToggleButton.BackgroundColor3 = Color3.fromRGB(90, 120, 200)
ToggleButton.BorderSizePixel = 0
ToggleButton.ZIndex = 7
ToggleButton.Parent = ToggleTrack

local ToggleButtonCorner = Instance.new("UICorner")
ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
ToggleButtonCorner.Parent = ToggleButton

local ToggleButtonStroke = Instance.new("UIStroke")
ToggleButtonStroke.Color = Color3.fromRGB(100, 150, 250)
ToggleButtonStroke.Thickness = 1
ToggleButtonStroke.Parent = ToggleButton

local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(90, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45))
})
ButtonGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(0.5, 0.4),
    NumberSequenceKeypoint.new(1, 0.1)
})
ButtonGradient.Rotation = 0
ButtonGradient.Parent = ToggleButton

task.spawn(function()
    while true do
        TweenService:Create(ButtonGradient, TweenInfo.new(5, Enum.EasingStyle.Linear), { Rotation = 360 }):Play()
        task.wait(5)
        ButtonGradient.Rotation = 0
    end
end)

local isActive = false

local function ToggleState(state)
    isActive = state
    _G.KibaEnabled = state
    
    local slideWidth = 52 - 18 - 6
    local buttonPos = state and UDim2.new(0, slideWidth, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    local trackColor = state and Color3.fromRGB(30, 60, 150) or Color3.fromRGB(20, 25, 55)
    local buttonColor = state and Color3.fromRGB(160, 210, 255) or Color3.fromRGB(90, 120, 200)
    local strokeColor = state and Color3.fromRGB(120, 190, 255) or Color3.fromRGB(60, 100, 200)
    local buttonStrokeColor = state and Color3.fromRGB(150, 220, 255) or Color3.fromRGB(100, 150, 250)
    local textColor = state and Color3.fromRGB(200, 240, 255) or Color3.fromRGB(120, 140, 200)
    local mainStrokeColor = state and Color3.fromRGB(150, 210, 255) or Color3.fromRGB(80, 140, 255)
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Position = buttonPos, BackgroundColor3 = buttonColor }):Play()
    TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = trackColor }):Play()
    TweenService:Create(ToggleStroke, TweenInfo.new(0.18), { Color = strokeColor }):Play()
    TweenService:Create(ToggleButtonStroke, TweenInfo.new(0.18), { Color = buttonStrokeColor }):Play()
    TweenService:Create(ToggleText, TweenInfo.new(0.18), { TextColor3 = textColor }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.15), { Color = mainStrokeColor, Transparency = 0 }):Play()
    TweenService:Create(IconDot, TweenInfo.new(0.2), { BackgroundColor3 = state and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(100, 180, 255) }):Play()
    TweenService:Create(IconGlow, TweenInfo.new(0.2), { BackgroundColor3 = state and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(100, 180, 255) }):Play()
    
    ToggleText.Text = state and "ON" or "OFF"
    
    if state then
        TweenService:Create(GlowFrame, TweenInfo.new(0.3), { BackgroundTransparency = 0.75 }):Play()
    else
        TweenService:Create(GlowFrame, TweenInfo.new(0.3), { BackgroundTransparency = 0.85 }):Play()
    end
    
    task.delay(0.2, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(80, 140, 255), Transparency = 0.2 }):Play()
    end)
end

ToggleTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ToggleState(not isActive)
    end
end)

local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.Text = "⚡ KIBA X TECH ⚡ | By ThanhDuy"
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 10
Watermark.TextColor3 = Color3.fromRGB(170, 200, 255)
Watermark.TextTransparency = 0.6
Watermark.BackgroundTransparency = 1
Watermark.Size = UDim2.new(0, 200, 0, 18)
Watermark.AnchorPoint = Vector2.new(1, 1)
Watermark.Position = UDim2.new(1, -8, 1, -6)
Watermark.TextXAlignment = Enum.TextXAlignment.Right
Watermark.ZIndex = 20
Watermark.Parent = ScreenGui

task.spawn(function()
    while true do
        TweenService:Create(Watermark, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.4 }):Play()
        task.wait(2.5)
        TweenService:Create(Watermark, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.7 }):Play()
        task.wait(2.5)
    end
end)

local BillboardGui = Instance.new("BillboardGui")
BillboardGui.Name = "KibaCooldownBill"
BillboardGui.Size = UDim2.new(0, 70, 0, 24)
BillboardGui.StudsOffset = Vector3.new(0, 3, 0)
BillboardGui.AlwaysOnTop = true
BillboardGui.Enabled = false
BillboardGui.ResetOnSpawn = false
BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local CooldownFrame = Instance.new("Frame")
CooldownFrame.Name = "CooldownFrame"
CooldownFrame.Size = UDim2.new(1, 0, 1, 0)
CooldownFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CooldownFrame.BackgroundTransparency = 0.3
CooldownFrame.BorderSizePixel = 0
CooldownFrame.ZIndex = 10
CooldownFrame.Parent = BillboardGui

local CooldownCorner = Instance.new("UICorner")
CooldownCorner.CornerRadius = UDim.new(0, 8)
CooldownCorner.Parent = CooldownFrame

local CooldownStroke = Instance.new("UIStroke")
CooldownStroke.Color = Color3.fromRGB(80, 140, 255)
CooldownStroke.Thickness = 1
CooldownStroke.Transparency = 0.5
CooldownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CooldownStroke.Parent = CooldownFrame

local CooldownText = Instance.new("TextLabel")
CooldownText.Text = ""
CooldownText.Font = Enum.Font.GothamBold
CooldownText.TextSize = 9
CooldownText.TextColor3 = Color3.fromRGB(200, 220, 255)
CooldownText.BackgroundTransparency = 1
CooldownText.Size = UDim2.new(1, 0, 1, 0)
CooldownText.TextXAlignment = Enum.TextXAlignment.Center
CooldownText.ZIndex = 11
CooldownText.Parent = CooldownFrame

local function AttachBillboard()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local head = char:WaitForChild("Head", 5)
    if head then
        BillboardGui.Adornee = head
        BillboardGui.Parent = head
    end
end

task.spawn(AttachBillboard)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.3)
    AttachBillboard()
    if _G.KibaEnabled then
        task.wait(0.2)
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end)
    end
end)

local isCooldownVisible = false
local isCooldownHiding = false

local function ShowCooldown()
    if isCooldownVisible then return end
    isCooldownVisible = true
    isCooldownHiding = false
    
    BillboardGui.Enabled = true
    CooldownFrame.BackgroundTransparency = 0.5
    CooldownText.TextTransparency = 1
    CooldownStroke.Transparency = 0.8
    
    TweenService:Create(CooldownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.2 }):Play()
    TweenService:Create(CooldownText, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    TweenService:Create(CooldownStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Transparency = 0.3 }):Play()
end

local function HideCooldown()
    if isCooldownHiding then return end
    isCooldownHiding = true
    
    TweenService:Create(CooldownFrame, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundTransparency = 0.5 }):Play()
    TweenService:Create(CooldownText, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    TweenService:Create(CooldownStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Transparency = 0.8 }):Play()
    
    task.delay(0.2, function()
        BillboardGui.Enabled = false
        isCooldownVisible = false
        isCooldownHiding = false
    end)
end

local CooldownMax = 5
local wasInCooldown = false

RunService.Heartbeat:Connect(function()
    local startTime = _G.KibaCooldownStart
    if startTime == nil then
        wasInCooldown = false
        return
    end
    
    local remaining = CooldownMax - (tick() - startTime)
    
    if remaining > 0 then
        ShowCooldown()
        CooldownText.Text = string.format("%.1fs", remaining)
        local alpha = 0.3 + (math.sin(tick() * 8) * 0.15)
        CooldownStroke.Color = Color3.fromHSV(0.57, 0.9, 0.5 + alpha * 0.3)
    else
        if not wasInCooldown then
            wasInCooldown = true
            CooldownText.Text = "0.0s"
            _G.KibaCooldownStart = nil
            task.delay(0.4, HideCooldown)
        end
    end
end)

local function FireSplashEffect()
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    flash.BackgroundTransparency = 0.7
    flash.BorderSizePixel = 0
    flash.ZIndex = 50
    flash.Parent = ScreenGui
    TweenService:Create(flash, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    task.delay(0.3, function() flash:Destroy() end)
    
    for i = 1, 4 do
        task.delay((i - 1) * 0.04, function()
            local ring = Instance.new("Frame")
            ring.Size = UDim2.new(0, 8, 0, 8)
            ring.AnchorPoint = Vector2.new(0.5, 0.5)
            ring.Position = UDim2.new(0.5, 0, 0.5, 0)
            ring.BackgroundTransparency = 1
            ring.BorderSizePixel = 0
            ring.ZIndex = 48
            ring.Parent = ScreenGui
            local ringCorner = Instance.new("UICorner")
            ringCorner.CornerRadius = UDim.new(1, 0)
            ringCorner.Parent = ring
            local ringStroke = Instance.new("UIStroke")
            ringStroke.Color = Color3.fromRGB(120 + i * 20, 180 + i * 15, 255)
            ringStroke.Thickness = 2.5 - i * 0.4
            ringStroke.Transparency = 0
            ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ringStroke.Parent = ring
            local sizeVal = 180 + i * 50
            TweenService:Create(ring, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, sizeVal, 0, sizeVal) }):Play()
            TweenService:Create(ringStroke, TweenInfo.new(0.45, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
            task.delay(0.5, function() ring:Destroy() end)
        end)
    end
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(0, 20, 0, 20)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.BackgroundColor3 = Color3.fromRGB(150, 200, 255)
    glow.BackgroundTransparency = 0.15
    glow.BorderSizePixel = 0
    glow.ZIndex = 46
    glow.Parent = ScreenGui
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    TweenService:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 120, 0, 120), BackgroundTransparency = 1 }):Play()
    task.delay(0.3, function() glow:Destroy() end)
    
    TweenService:Create(MainStroke, TweenInfo.new(0.06), { Color = Color3.fromRGB(220, 240, 255), Thickness = 3, Transparency = 0 }):Play()
    task.delay(0.1, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Color = Color3.fromRGB(80, 140, 255), Thickness = 1.5, Transparency = 0.2 }):Play()
    end)
end

_G.KibaFireSplash = FireSplashEffect

local function PulseBorder()
    while true do
        for i = 1, 25 do
            local trans = 0.2 + math.sin(tick() * 8) * 0.1
            MainStroke.Transparency = trans
            task.wait(0.025)
        end
    end
end

task.spawn(PulseBorder)

local dragging = false
local dragStart = nil
local startPos = nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        TweenService:Create(MainFrame, TweenInfo.new(0.08), { BackgroundTransparency = 0.02 }):Play()
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if dragging then
            dragging = false
            TweenService:Create(MainFrame, TweenInfo.new(0.1), { BackgroundTransparency = 0.05 }):Play()
        end
    end
end)

TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -210, 0.5, -24) }):Play()

local function WaitForCharacter()
    local char = LocalPlayer.Character
    if not char or not char.Parent then
        char = LocalPlayer.CharacterAdded:Wait()
    end
    return char
end

local Character = WaitForCharacter()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")

local Communicate = nil
local RemoteEvent = nil

for _, item in ipairs(Character:GetDescendants()) do
    if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") or item.Name == "Communicate" or item.Name == "Remote" then
        Communicate = item
        break
    end
end

if not Communicate then
    pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if remotes then
            Communicate = remotes:FindFirstChild("Communicate")
        end
    end)
end

local AnimationID = "10503381238"
local DashRange = 14.5
local AbilityCooldown = 5

local isAnimating = false
local isDashing = false
local hasTriggered = false
local targetPart = nil
local heartbeatConnection = nil
local lastUsed = 0
local deathConnection = nil
local respawnConnection = nil

local function ResetState()
    isAnimating = false
    isDashing = false
    hasTriggered = false
    targetPart = nil
end

local function ResetMovement()
    if heartbeatConnection then
        heartbeatConnection:Disconnect()
        heartbeatConnection = nil
    end
    pcall(function()
        if Humanoid and Humanoid.Parent then
            Humanoid:ChangeState(Enum.HumanoidStateType.Running)
            Humanoid.AutoRotate = true
        end
    end)
end

local function FindNearestTarget()
    local closest = nil
    local closestDist = DashRange
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local dist = (targetRoot.Position - RootPart.Position).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = targetRoot
                end
            end
        end
    end
    
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") and obj ~= Character then
            local targetRoot = obj:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = obj:FindFirstChild("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local isPlayer = false
                for _, player in ipairs(Players:GetPlayers()) do
                    if player.Character == obj then
                        isPlayer = true
                        break
                    end
                end
                if not isPlayer then
                    local dist = (targetRoot.Position - RootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = targetRoot
                    end
                end
            end
        end
    end
    
    return closest
end

local function IsAnimationPlaying()
    if not Animator or not Animator.Parent then return false, nil end
    for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
        local animId = track.Animation.AnimationId
        if animId and type(animId) == "string" then
            local id = animId:match("%d+$")
            if id == AnimationID then
                return true, track
            end
        end
    end
    return false, nil
end

local function ExecuteDash(target)
    lastUsed = tick()
    _G.KibaCooldownStart = lastUsed
    
    if type(_G.KibaFireSplash) == "function" then
        pcall(_G.KibaFireSplash)
    end
    
    if Communicate then
        pcall(function()
            if Communicate:IsA("RemoteEvent") then
                Communicate:FireServer({ Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" })
            elseif Communicate:IsA("RemoteFunction") then
                Communicate:InvokeServer({ Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" })
            else
                Communicate:FireServer(unpack({ { Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" } }))
            end
        end)
    end
    
    local success = false
    if target and target.Parent then
        pcall(function()
            local targetPos = target.Position
            local dashPos = Vector3.new(targetPos.X, targetPos.Y - 2.5, targetPos.Z)
            
            if _G.KibaSettings.WallCheck then
                local rayParams = RaycastParams.new()
                rayParams.FilterType = Enum.RaycastFilterType.Blacklist
                rayParams.FilterDescendantsInstances = {Character}
                local ray = Workspace:Raycast(RootPart.Position, (dashPos - RootPart.Position).Unit * 15, rayParams)
                if ray and ray.Instance then
                    dashPos = ray.Position + (ray.Normal * 2)
                end
            end
            
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            Humanoid.AutoRotate = false
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
            
            local duration = _G.KibaSettings.DashDuration
            local elapsed = 0
            
            if heartbeatConnection then heartbeatConnection:Disconnect() end
            
            heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                if elapsed >= duration then
                    heartbeatConnection:Disconnect()
                    heartbeatConnection = nil
                    success = true
                    return
                end
                
                if not target or not target.Parent then
                    heartbeatConnection:Disconnect()
                    heartbeatConnection = nil
                    success = true
                    return
                end
                
                local currentTargetPos = target.Position
                local targetDashPos = Vector3.new(currentTargetPos.X, currentTargetPos.Y - 2.5, currentTargetPos.Z)
                local progress = elapsed / duration
                local verticalBoost = _G.KibaSettings.VerticalBoost
                local horizontalSpeed = _G.KibaSettings.HorizontalSpeed
                local smoothness = _G.KibaSettings.Smoothness
                
                local verticalVelocity = math.sin(progress * math.pi) * verticalBoost
                local deltaX = (targetDashPos.X - RootPart.Position.X) * horizontalSpeed
                local deltaZ = (targetDashPos.Z - RootPart.Position.Z) * horizontalSpeed
                
                RootPart.AssemblyLinearVelocity = Vector3.new(deltaX, verticalVelocity, deltaZ)
                RootPart.AssemblyAngularVelocity = Vector3.zero
                
                local targetCFrame = CFrame.new(RootPart.Position, Vector3.new(targetDashPos.X, RootPart.Position.Y, targetDashPos.Z))
                RootPart.CFrame = RootPart.CFrame:Lerp(targetCFrame, smoothness)
            end)
        end)
    end
    
    task.wait(0.55)
    ResetMovement()
    hasTriggered = false
    isDashing = false
    targetPart = nil
end

local function ReattachAfterRespawn()
    task.wait(0.5)
    Character = LocalPlayer.Character
    if Character then
        Humanoid = Character:FindFirstChild("Humanoid")
        RootPart = Character:FindFirstChild("HumanoidRootPart")
        Animator = Humanoid and Humanoid:FindFirstChild("Animator")
        
        if Character:FindFirstChild("Communicate") then
            Communicate = Character.Communicate
        end
        
        if Humanoid then            Humanoid.AutoRotate = true
        end
        
        ResetState()
        ResetMovement()
        
        AttachBillboard()
    end
end

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.3)
    Character = newChar
    Humanoid = newChar:WaitForChild("Humanoid", 5)
    RootPart = newChar:WaitForChild("HumanoidRootPart", 5)
    Animator = Humanoid and Humanoid:WaitForChild("Animator", 5)
    
    if newChar:FindFirstChild("Communicate") then
        Communicate = newChar.Communicate
    end
    
    Humanoid.AutoRotate = true
    ResetState()
    ResetMovement()
    AttachBillboard()
    
    if isActive then
        task.wait(0.2)
    end
end)

RunService.Heartbeat:Connect(function()
    local isEnabled = _G.KibaEnabled == true
    local earlyFire = tonumber(_G.KibaEarlyFire) or 0.55
    
    if not Character or not Humanoid or not Humanoid.Parent then
        return
    end
    
    if not isEnabled then
        if isAnimating then
            ResetState()
            pcall(ResetMovement)
        end
        return
    end
    
    if (tick() - lastUsed) < AbilityCooldown then
        return
    end
    
    local isPlaying, currentTrack = IsAnimationPlaying()
    
    if isPlaying and not isAnimating then
        isAnimating = true
        isDashing = false
        hasTriggered = false
        targetPart = FindNearestTarget()
    elseif isPlaying and isAnimating then
        if not isDashing and not hasTriggered and targetPart and targetPart.Parent then
            if currentTrack and currentTrack.Length and currentTrack.Length > 0.01 then
                local timeLeft = currentTrack.Length - currentTrack.TimePosition
                if timeLeft <= earlyFire then
                    isDashing = true
                    hasTriggered = true
                    local target = targetPart
                    task.spawn(function() 
                        pcall(function() ExecuteDash(target) end)
                    end)
                end
            end
        end
    elseif not isPlaying and isAnimating then
        isAnimating = false
        if not isDashing and not hasTriggered and targetPart and targetPart.Parent then
            isDashing = true
            hasTriggered = true
            local target = targetPart
            task.spawn(function() 
                pcall(function() ExecuteDash(target) end)
            end)
        else
            ResetState()
        end
    else
        if isAnimating then
            ResetState()
        end
    end
end)

local function ForceDashOnTarget()
    if not _G.KibaEnabled then return end
    if (tick() - lastUsed) < AbilityCooldown then return end
    
    local target = FindNearestTarget()
    if target and target.Parent then
        isAnimating = true
        isDashing = true
        hasTriggered = true
        task.spawn(function()
            pcall(function() ExecuteDash(target) end)
        end)
    end
end

_G.KibaForceDash = ForceDashOnTarget

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if _G.KibaEnabled and input.KeyCode == Enum.KeyCode.Q then
        ForceDashOnTarget()
    end
end)

print("⚡ KIBA X TECH LOADED SUCCESSFULLY ⚡")
print("Status: Ready | Mode: Legit Premium")