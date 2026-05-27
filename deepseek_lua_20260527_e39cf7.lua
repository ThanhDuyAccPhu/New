local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.KibaEnabled = false
_G.KibaEarlyFire = 0.6
_G.KibaCooldownStart = nil

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
MainFrame.Size = UDim2.new(0, 180, 0, 44)
MainFrame.Position = UDim2.new(1, 10, 0.5, -22)
MainFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 22)
MainFrame.BackgroundTransparency = 0.08
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = false
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(1, 0)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 16, 38)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(18, 24, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 14, 32))
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 120, 255)
MainStroke.Thickness = 1.5
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 1, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 4
TitleBar.Parent = MainFrame

local IconDot = Instance.new("Frame")
IconDot.Size = UDim2.new(0, 8, 0, 8)
IconDot.Position = UDim2.new(0, 14, 0.5, -4)
IconDot.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
IconDot.BorderSizePixel = 0
IconDot.ZIndex = 5
IconDot.Parent = MainFrame

local IconDotCorner = Instance.new("UICorner")
IconDotCorner.CornerRadius = UDim.new(1, 0)
IconDotCorner.Parent = IconDot

local IconGlow = Instance.new("Frame")
IconGlow.Size = UDim2.new(0, 8, 0, 8)
IconGlow.Position = UDim2.new(0, 14, 0.5, -4)
IconGlow.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
IconGlow.BackgroundTransparency = 0.6
IconGlow.BorderSizePixel = 0
IconGlow.ZIndex = 4
IconGlow.Parent = MainFrame

local IconGlowCorner = Instance.new("UICorner")
IconGlowCorner.CornerRadius = UDim.new(1, 0)
IconGlowCorner.Parent = IconGlow

task.spawn(function()
    while true do
        TweenService:Create(IconGlow, TweenInfo.new(0.9, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 16, 0, 16), Position = UDim2.new(0, 9, 0.5, -8), BackgroundTransparency = 1 }):Play()
        task.wait(0.9)
        IconGlow.Size = UDim2.new(0, 8, 0, 8)
        IconGlow.Position = UDim2.new(0, 14, 0.5, -4)
        IconGlow.BackgroundTransparency = 0.6
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "KibaX Tech"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextColor3 = Color3.fromRGB(200, 220, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0, 88, 1, 0)
TitleLabel.Position = UDim2.new(0, 28, 0, 0)
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 5
TitleLabel.Parent = MainFrame

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color = Color3.fromRGB(80, 140, 255)
TitleStroke.Thickness = 0.5
TitleStroke.Parent = TitleLabel

task.spawn(function()
    while true do
        TweenService:Create(TitleLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(230, 245, 255) }):Play()
        task.wait(1.2)
        TweenService:Create(TitleLabel, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(120, 170, 255) }):Play()
        task.wait(1.2)
    end
end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 0, 24)
Divider.Position = UDim2.new(0, 118, 0.5, -12)
Divider.BackgroundColor3 = Color3.fromRGB(60, 90, 180)
Divider.BackgroundTransparency = 0.4
Divider.BorderSizePixel = 0
Divider.ZIndex = 5
Divider.Parent = MainFrame

local ToggleTrack = Instance.new("Frame")
ToggleTrack.Name = "ToggleTrack"
ToggleTrack.Size = UDim2.new(0, 46, 0, 22)
ToggleTrack.Position = UDim2.new(0, 124, 0.5, -11)
ToggleTrack.BackgroundColor3 = Color3.fromRGB(18, 22, 52)
ToggleTrack.BorderSizePixel = 0
ToggleTrack.ClipsDescendants = true
ToggleTrack.ZIndex = 5
ToggleTrack.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleTrack

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(45, 85, 185)
ToggleStroke.Thickness = 1.2
ToggleStroke.Parent = ToggleTrack

local ToggleText = Instance.new("TextLabel")
ToggleText.Text = "OFF"
ToggleText.Font = Enum.Font.GothamBold
ToggleText.TextSize = 9
ToggleText.TextColor3 = Color3.fromRGB(100, 130, 190)
ToggleText.BackgroundTransparency = 1
ToggleText.Size = UDim2.new(1, 0, 1, 0)
ToggleText.TextXAlignment = Enum.TextXAlignment.Center
ToggleText.ZIndex = 6
ToggleText.Parent = ToggleTrack

local ToggleButton = Instance.new("Frame")
ToggleButton.Size = UDim2.new(0, 16, 0, 16)
ToggleButton.Position = UDim2.new(0, 3, 0.5, -8)
ToggleButton.BackgroundColor3 = Color3.fromRGB(80, 110, 185)
ToggleButton.BorderSizePixel = 0
ToggleButton.ZIndex = 7
ToggleButton.Parent = ToggleTrack

local ToggleButtonCorner = Instance.new("UICorner")
ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
ToggleButtonCorner.Parent = ToggleButton

local ToggleButtonStroke = Instance.new("UIStroke")
ToggleButtonStroke.Color = Color3.fromRGB(70, 130, 230)
ToggleButtonStroke.Thickness = 1.2
ToggleButtonStroke.Parent = ToggleButton

local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 30, 30)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(70, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 20))
})
ButtonGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.2),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(1, 0.2)
})
ButtonGradient.Rotation = 0
ButtonGradient.Parent = ToggleButton

task.spawn(function()
    while true do
        TweenService:Create(ButtonGradient, TweenInfo.new(6, Enum.EasingStyle.Linear), { Rotation = 360 }):Play()
        task.wait(6)
        ButtonGradient.Rotation = 0
    end
end)

local isActive = false

local function ToggleState(state)
    isActive = state
    _G.KibaEnabled = state
    
    local slideWidth = 46 - 16 - 5
    local buttonPos = state and UDim2.new(0, slideWidth, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    local trackColor = state and Color3.fromRGB(25, 50, 140) or Color3.fromRGB(20, 25, 55)
    local buttonColor = state and Color3.fromRGB(150, 210, 255) or Color3.fromRGB(80, 110, 185)
    local strokeColor = state and Color3.fromRGB(100, 180, 255) or Color3.fromRGB(45, 85, 185)
    local buttonStrokeColor = state and Color3.fromRGB(130, 210, 255) or Color3.fromRGB(70, 130, 230)
    local textColor = state and Color3.fromRGB(180, 230, 255) or Color3.fromRGB(100, 130, 190)
    local mainStrokeColor = state and Color3.fromRGB(130, 200, 255) or Color3.fromRGB(60, 120, 255)
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Position = buttonPos, BackgroundColor3 = buttonColor }):Play()
    TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = trackColor }):Play()
    TweenService:Create(ToggleStroke, TweenInfo.new(0.18), { Color = strokeColor }):Play()
    TweenService:Create(ToggleButtonStroke, TweenInfo.new(0.18), { Color = buttonStrokeColor }):Play()
    TweenService:Create(ToggleText, TweenInfo.new(0.18), { TextColor3 = textColor }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.15), { Color = mainStrokeColor }):Play()
    TweenService:Create(IconDot, TweenInfo.new(0.2), { BackgroundColor3 = state and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(80, 150, 255) }):Play()
    TweenService:Create(IconGlow, TweenInfo.new(0.2), { BackgroundColor3 = state and Color3.fromRGB(80, 220, 140) or Color3.fromRGB(80, 150, 255) }):Play()
    
    ToggleText.Text = state and "ON" or "OFF"
    
    task.delay(0.2, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.3), { Color = Color3.fromRGB(60, 120, 255) }):Play()
    end)
end

ToggleTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ToggleState(not isActive)
    end
end)

local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.Text = "By ThanhDuy"
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 10
Watermark.TextColor3 = Color3.fromRGB(170, 200, 255)
Watermark.TextTransparency = 0.7
Watermark.BackgroundTransparency = 1
Watermark.Size = UDim2.new(0, 140, 0, 20)
Watermark.AnchorPoint = Vector2.new(1, 1)
Watermark.Position = UDim2.new(1, -8, 1, -6)
Watermark.TextXAlignment = Enum.TextXAlignment.Right
Watermark.ZIndex = 20
Watermark.Parent = ScreenGui

task.spawn(function()
    while true do
        TweenService:Create(Watermark, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.5 }):Play()
        task.wait(2)
        TweenService:Create(Watermark, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.8 }):Play()
        task.wait(2)
    end
end)

local BillboardGui = Instance.new("BillboardGui")
BillboardGui.Name = "KibaCooldownBill"
BillboardGui.Size = UDim2.new(0, 100, 0, 36)
BillboardGui.StudsOffset = Vector3.new(0, 3.2, 0)
BillboardGui.AlwaysOnTop = true
BillboardGui.Enabled = false
BillboardGui.ResetOnSpawn = false
BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local CooldownFrame = Instance.new("Frame")
CooldownFrame.Name = "CooldownFrame"
CooldownFrame.Size = UDim2.new(1, 0, 1, 0)
CooldownFrame.BackgroundColor3 = Color3.fromRGB(8, 10, 24)
CooldownFrame.BackgroundTransparency = 1
CooldownFrame.BorderSizePixel = 0
CooldownFrame.ZIndex = 10
CooldownFrame.Parent = BillboardGui

local CooldownCorner = Instance.new("UICorner")
CooldownCorner.CornerRadius = UDim.new(0, 10)
CooldownCorner.Parent = CooldownFrame

local CooldownStroke = Instance.new("UIStroke")
CooldownStroke.Color = Color3.fromRGB(50, 110, 255)
CooldownStroke.Thickness = 1.2
CooldownStroke.Transparency = 1
CooldownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CooldownStroke.Parent = CooldownFrame

local CooldownGradient = Instance.new("UIGradient")
CooldownGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 12, 35)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 35, 80)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 35))
})
CooldownGradient.Rotation = 135
CooldownGradient.Parent = CooldownFrame

local CooldownText = Instance.new("TextLabel")
CooldownText.Text = "🤡Cooldown: 5.0s"
CooldownText.Font = Enum.Font.GothamBold
CooldownText.TextSize = 10
CooldownText.TextColor3 = Color3.fromRGB(150, 200, 255)
CooldownText.TextTransparency = 1
CooldownText.BackgroundTransparency = 1
CooldownText.Size = UDim2.new(1, 0, 0, 22)
CooldownText.Position = UDim2.new(0, 0, 0, 2)
CooldownText.TextXAlignment = Enum.TextXAlignment.Center
CooldownText.ZIndex = 11
CooldownText.Parent = CooldownFrame

local CooldownBarBg = Instance.new("Frame")
CooldownBarBg.Size = UDim2.new(0.82, 0, 0, 3)
CooldownBarBg.Position = UDim2.new(0.09, 0, 0, 26)
CooldownBarBg.BackgroundColor3 = Color3.fromRGB(20, 25, 65)
CooldownBarBg.BackgroundTransparency = 0.4
CooldownBarBg.BorderSizePixel = 0
CooldownBarBg.ZIndex = 11
CooldownBarBg.Parent = CooldownFrame

local CooldownBarBgCorner = Instance.new("UICorner")
CooldownBarBgCorner.CornerRadius = UDim.new(1, 0)
CooldownBarBgCorner.Parent = CooldownBarBg

local CooldownBar = Instance.new("Frame")
CooldownBar.Size = UDim2.new(1, 0, 1, 0)
CooldownBar.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
CooldownBar.BorderSizePixel = 0
CooldownBar.ZIndex = 12
CooldownBar.Parent = CooldownBarBg

local CooldownBarCorner = Instance.new("UICorner")
CooldownBarCorner.CornerRadius = UDim.new(1, 0)
CooldownBarCorner.Parent = CooldownBar

local BarGradient = Instance.new("UIGradient")
BarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 130, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 200, 255))
})
BarGradient.Parent = CooldownBar

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
    task.wait(0.5)
    AttachBillboard()
end)

local function UpdateCooldownPosition()
end

UpdateCooldownPosition()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    task.wait()
    UpdateCooldownPosition()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateCooldownPosition)
    end
end)

local isCooldownVisible = false
local isCooldownHiding = false

local function ShowCooldown()
    if isCooldownVisible then return end
    isCooldownVisible = true
    isCooldownHiding = false

    BillboardGui.Enabled = true
    CooldownFrame.BackgroundTransparency = 1
    CooldownText.TextTransparency = 1
    CooldownStroke.Transparency = 1

    TweenService:Create(CooldownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0.15 }):Play()
    TweenService:Create(CooldownText, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    TweenService:Create(CooldownStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Transparency = 0 }):Play()
end

local function HideCooldown()
    if isCooldownHiding then return end
    isCooldownHiding = true

    TweenService:Create(CooldownFrame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(CooldownText, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    TweenService:Create(CooldownStroke, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()

    task.delay(0.28, function()
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
        CooldownText.Text = "🤡 " .. string.format("%.1f", remaining) .. "s"
        CooldownBar.Size = UDim2.new(math.clamp(remaining / CooldownMax, 0, 1), 0, 1, 0)
        CooldownStroke.Color = Color3.fromHSV(0.58, 0.8, 0.6 + math.sin(tick() * 5) * 0.15)
    else
        if not wasInCooldown then
            wasInCooldown = true
            CooldownText.Text = "🤡 Cooldown: 0.0s"
            CooldownBar.Size = UDim2.new(0, 0, 1, 0)
            _G.KibaCooldownStart = nil
            task.delay(0.5, HideCooldown)
        end
    end
end)

local function FireSplashEffect()
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    flash.BackgroundTransparency = 0.75
    flash.BorderSizePixel = 0
    flash.ZIndex = 50
    flash.Parent = ScreenGui
    TweenService:Create(flash, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    task.delay(0.35, function() flash:Destroy() end)
    
    for i = 1, 3 do
        task.delay((i - 1) * 0.06, function()
            local ring = Instance.new("Frame")
            ring.Size = UDim2.new(0, 12, 0, 12)
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
            ringStroke.Color = Color3.fromRGB(100 + i * 25, 180 + i * 10, 255)
            ringStroke.Thickness = 3 - i * 0.5
            ringStroke.Transparency = 0
            ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ringStroke.Parent = ring
            local sizeVal = 240 + i * 70
            TweenService:Create(ring, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, sizeVal, 0, sizeVal) }):Play()
            TweenService:Create(ringStroke, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
            task.delay(0.55, function() ring:Destroy() end)
        end)
    end
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(0, 24, 0, 24)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.BackgroundColor3 = Color3.fromRGB(130, 200, 255)
    glow.BackgroundTransparency = 0.2
    glow.BorderSizePixel = 0
    glow.ZIndex = 46
    glow.Parent = ScreenGui
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    TweenService:Create(glow, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 160, 0, 160), BackgroundTransparency = 1 }):Play()
    task.delay(0.35, function() glow:Destroy() end)
    
    TweenService:Create(MainStroke, TweenInfo.new(0.08), { Color = Color3.fromRGB(200, 240, 255), Thickness = 3.5 }):Play()
    task.delay(0.12, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.28, Enum.EasingStyle.Quad), { Color = Color3.fromRGB(60, 120, 255), Thickness = 1.5 }):Play()
    end)
end

_G.KibaFireSplash = FireSplashEffect

local function PulseBorder()
    local direction = 1
    while true do
        for i = 1, 30 do
            local thickness = MainStroke.Thickness + (direction * 0.025)
            if thickness >= 2.2 then direction = -1 end
            if thickness <= 1.2 then direction = 1 end
            MainStroke.Thickness = thickness
            task.wait(0.03)
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
        TweenService:Create(MainFrame, TweenInfo.new(0.08), { BackgroundTransparency = 0.05 }):Play()
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
            TweenService:Create(MainFrame, TweenInfo.new(0.1), { BackgroundTransparency = 0.15 }):Play()
        end
    end
end)

TweenService:Create(MainFrame, TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -190, 0.5, -22) }):Play()

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")
local Communicate = Character:WaitForChild("Communicate")

local AnimationID = "10503381238"
local DashRange = 12.7
local AbilityCooldown = 5

local isAnimating = false
local isDashing = false
local hasTriggered = false
local targetPart = nil
local heartbeatConnection = nil
local lastUsed = 0

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
    Humanoid:ChangeState(Enum.HumanoidStateType.Running)
    Humanoid.AutoRotate = true
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
    
    for _, obj in ipairs(workspace:GetDescendants()) do
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
    for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
        local id = tostring(track.Animation.AnimationId):match("%d+$")
        if id == AnimationID then
            return true, track
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
    
    pcall(function()
        Communicate:FireServer(unpack({ { Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" } }))
    end)
    
    if target and target.Parent then
        local lookVec = RootPart.CFrame.LookVector
        local angle = math.atan2(-lookVec.X, -lookVec.Z)
        local targetPos = target.Position
        local dashPos = Vector3.new(targetPos.X, targetPos.Y - 2.8, targetPos.Z)
        local dashCFrame = CFrame.new(dashPos) * CFrame.fromEulerAnglesYXZ(math.pi / 2, angle, 0)
        
        Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        Humanoid.AutoRotate = false
        RootPart.CFrame = dashCFrame
        RootPart.AssemblyLinearVelocity = Vector3.zero
        RootPart.AssemblyAngularVelocity = Vector3.zero
        
        local relativeCFrame = dashCFrame - dashCFrame.Position
        if heartbeatConnection then heartbeatConnection:Disconnect() end
        
        local elapsed = 0
        local duration = 0.55
        
        heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed >= duration then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
                return
            end
            if not target or not target.Parent then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
                return
            end
            
            local currentTargetPos = target.Position
            local targetDashPos = Vector3.new(currentTargetPos.X, currentTargetPos.Y - 2.8, currentTargetPos.Z)
            local progress = elapsed / duration
            local verticalVelocity = math.sin(progress * math.pi) * 38
            local deltaX = targetDashPos.X - RootPart.Position.X
            local deltaZ = targetDashPos.Z - RootPart.Position.Z
            
            RootPart.AssemblyLinearVelocity = Vector3.new(deltaX * 28, verticalVelocity, deltaZ * 28)
            RootPart.AssemblyAngularVelocity = Vector3.zero
            RootPart.CFrame = CFrame.new(RootPart.Position) * relativeCFrame
        end)
    end
    
    task.wait(0.55)
    ResetMovement()
    hasTriggered = false
    isDashing = false
    targetPart = nil
end

RunService.Heartbeat:Connect(function()
    local isEnabled = _G.KibaEnabled == true
    local earlyFire = tonumber(_G.KibaEarlyFire) or 0.6
    
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
        if not isDashing and not hasTriggered and targetPart then
            if currentTrack and currentTrack.Length and currentTrack.Length > 0.01 then
                local timeLeft = currentTrack.Length - currentTrack.TimePosition
                if timeLeft <= earlyFire then
                    isDashing = true
                    hasTriggered = true
                    local target = targetPart
                    task.spawn(function() ExecuteDash(target) end)
                end
            end
        end
    elseif not isPlaying and isAnimating then
        isAnimating = false
        if not isDashing and not hasTriggered and targetPart then
            isDashing = true
            hasTriggered = true
            local target = targetPart
            task.spawn(function() ExecuteDash(target) end)
        else
            ResetState()
        end
    else
        ResetState()
    end
end)

print("Open Soucre")