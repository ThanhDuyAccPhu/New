local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

_G.KibaEnabled = false
_G.KibaEarlyFire = 0.65
_G.KibaCooldownStart = nil
_G.KibaSettings = {
    DashRange = 13.5,
    AbilityCooldown = 5,
    AnimationID = "10503381238",
    SmoothDash = true,
    ShowEffects = true,
    AutoTarget = true,
    TargetPriority = "Closest"
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
MainCorner.CornerRadius = UDim.new(1, 0)
MainCorner.Parent = MainFrame

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 14, 35)),
    ColorSequenceKeypoint.new(0.3, Color3.fromRGB(25, 35, 80)),
    ColorSequenceKeypoint.new(0.7, Color3.fromRGB(15, 22, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 12, 30))
})
MainGradient.Rotation = 135
MainGradient.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 140, 255)
MainStroke.Thickness = 1.8
MainStroke.Transparency = 0.3
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Parent = MainFrame

local InnerGlow = Instance.new("Frame")
InnerGlow.Size = UDim2.new(1, -4, 1, -4)
InnerGlow.Position = UDim2.new(0, 2, 0, 2)
InnerGlow.BackgroundColor3 = Color3.fromRGB(40, 80, 180)
InnerGlow.BackgroundTransparency = 0.85
InnerGlow.BorderSizePixel = 0
InnerGlow.ZIndex = 0
InnerGlow.Parent = MainFrame

local InnerGlowCorner = Instance.new("UICorner")
InnerGlowCorner.CornerRadius = UDim.new(1, 0)
InnerGlowCorner.Parent = InnerGlow

local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 1, 0)
TitleBar.BackgroundTransparency = 1
TitleBar.ZIndex = 4
TitleBar.Parent = MainFrame

local IconDot = Instance.new("Frame")
IconDot.Size = UDim2.new(0, 10, 0, 10)
IconDot.Position = UDim2.new(0, 12, 0.5, -5)
IconDot.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
IconDot.BorderSizePixel = 0
IconDot.ZIndex = 5
IconDot.Parent = MainFrame

local IconDotCorner = Instance.new("UICorner")
IconDotCorner.CornerRadius = UDim.new(1, 0)
IconDotCorner.Parent = IconDot

local IconGlow = Instance.new("Frame")
IconGlow.Size = UDim2.new(0, 10, 0, 10)
IconGlow.Position = UDim2.new(0, 12, 0.5, -5)
IconGlow.BackgroundColor3 = Color3.fromRGB(80, 150, 255)
IconGlow.BackgroundTransparency = 0.7
IconGlow.BorderSizePixel = 0
IconGlow.ZIndex = 3
IconGlow.Parent = MainFrame

local IconGlowCorner = Instance.new("UICorner")
IconGlowCorner.CornerRadius = UDim.new(1, 0)
IconGlowCorner.Parent = IconGlow

task.spawn(function()
    while true do
        TweenService:Create(IconGlow, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(0, 7, 0.5, -10), BackgroundTransparency = 1 }):Play()
        task.wait(0.8)
        IconGlow.Size = UDim2.new(0, 10, 0, 10)
        IconGlow.Position = UDim2.new(0, 12, 0.5, -5)
        IconGlow.BackgroundTransparency = 0.7
        task.wait(0.1)
    end
end)

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text = "KibaX | TECH"
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextSize = 11
TitleLabel.TextColor3 = Color3.fromRGB(210, 225, 255)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Size = UDim2.new(0, 95, 1, 0)
TitleLabel.Position = UDim2.new(0, 28, 0, 0)
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
        TweenService:Create(TitleLabel, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(130, 180, 255) }):Play()
        task.wait(1.5)
    end
end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(0, 1, 0, 28)
Divider.Position = UDim2.new(0, 130, 0.5, -14)
Divider.BackgroundColor3 = Color3.fromRGB(80, 120, 220)
Divider.BackgroundTransparency = 0.5
Divider.BorderSizePixel = 0
Divider.ZIndex = 5
Divider.Parent = MainFrame

local ToggleTrack = Instance.new("Frame")
ToggleTrack.Name = "ToggleTrack"
ToggleTrack.Size = UDim2.new(0, 50, 0, 24)
ToggleTrack.Position = UDim2.new(0, 138, 0.5, -12)
ToggleTrack.BackgroundColor3 = Color3.fromRGB(15, 18, 45)
ToggleTrack.BorderSizePixel = 0
ToggleTrack.ClipsDescendants = true
ToggleTrack.ZIndex = 5
ToggleTrack.Parent = MainFrame

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(1, 0)
ToggleCorner.Parent = ToggleTrack

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(60, 100, 200)
ToggleStroke.Thickness = 1.2
ToggleStroke.Parent = ToggleTrack

local ToggleText = Instance.new("TextLabel")
ToggleText.Text = "OFF"
ToggleText.Font = Enum.Font.GothamBold
ToggleText.TextSize = 9
ToggleText.TextColor3 = Color3.fromRGB(120, 150, 210)
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
ToggleButtonStroke.Color = Color3.fromRGB(100, 150, 240)
ToggleButtonStroke.Thickness = 1.2
ToggleButtonStroke.Parent = ToggleButton

local ButtonGradient = Instance.new("UIGradient")
ButtonGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 50, 70)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 140, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 40, 60))
})
ButtonGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.3),
    NumberSequenceKeypoint.new(0.5, 0.6),
    NumberSequenceKeypoint.new(1, 0.3)
})
ButtonGradient.Rotation = 0
ButtonGradient.Parent = ToggleButton

task.spawn(function()
    while true do
        TweenService:Create(ButtonGradient, TweenInfo.new(8, Enum.EasingStyle.Linear), { Rotation = 360 }):Play()
        task.wait(8)
        ButtonGradient.Rotation = 0
    end
end)

local isActive = false

local function ToggleState(state)
    isActive = state
    _G.KibaEnabled = state
    
    local slideWidth = 50 - 18 - 5
    local buttonPos = state and UDim2.new(0, slideWidth, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    local trackColor = state and Color3.fromRGB(30, 60, 150) or Color3.fromRGB(18, 22, 50)
    local buttonColor = state and Color3.fromRGB(160, 220, 255) or Color3.fromRGB(90, 120, 200)
    local strokeColor = state and Color3.fromRGB(120, 200, 255) or Color3.fromRGB(60, 100, 200)
    local buttonStrokeColor = state and Color3.fromRGB(140, 220, 255) or Color3.fromRGB(100, 150, 240)
    local textColor = state and Color3.fromRGB(200, 240, 255) or Color3.fromRGB(120, 150, 210)
    local mainStrokeColor = state and Color3.fromRGB(150, 220, 255) or Color3.fromRGB(80, 140, 255)
    local dotColor = state and Color3.fromRGB(80, 255, 150) or Color3.fromRGB(80, 150, 255)
    
    TweenService:Create(ToggleButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { Position = buttonPos, BackgroundColor3 = buttonColor }):Play()
    TweenService:Create(ToggleTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad), { BackgroundColor3 = trackColor }):Play()
    TweenService:Create(ToggleStroke, TweenInfo.new(0.18), { Color = strokeColor }):Play()
    TweenService:Create(ToggleButtonStroke, TweenInfo.new(0.18), { Color = buttonStrokeColor }):Play()
    TweenService:Create(ToggleText, TweenInfo.new(0.18), { TextColor3 = textColor }):Play()
    TweenService:Create(MainStroke, TweenInfo.new(0.15), { Color = mainStrokeColor, Transparency = 0.2 }):Play()
    TweenService:Create(IconDot, TweenInfo.new(0.2), { BackgroundColor3 = dotColor }):Play()
    TweenService:Create(IconGlow, TweenInfo.new(0.2), { BackgroundColor3 = dotColor }):Play()
    
    ToggleText.Text = state and "ON" or "OFF"
    
    if state then
        TweenService:Create(InnerGlow, TweenInfo.new(0.3), { BackgroundTransparency = 0.75 }):Play()
    else
        TweenService:Create(InnerGlow, TweenInfo.new(0.3), { BackgroundTransparency = 0.85 }):Play()
    end
    
    task.delay(0.25, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.4), { Color = Color3.fromRGB(80, 140, 255), Transparency = 0.3 }):Play()
    end)
end

ToggleTrack.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        ToggleState(not isActive)
    end
end)

local Watermark = Instance.new("TextLabel")
Watermark.Name = "Watermark"
Watermark.Text = "KibaX | ThanhDuy"
Watermark.Font = Enum.Font.GothamBold
Watermark.TextSize = 9
Watermark.TextColor3 = Color3.fromRGB(180, 210, 255)
Watermark.TextTransparency = 0.6
Watermark.BackgroundTransparency = 1
Watermark.Size = UDim2.new(0, 150, 0, 18)
Watermark.AnchorPoint = Vector2.new(1, 1)
Watermark.Position = UDim2.new(1, -8, 1, -4)
Watermark.TextXAlignment = Enum.TextXAlignment.Right
Watermark.ZIndex = 20
Watermark.Parent = ScreenGui

task.spawn(function()
    while true do
        TweenService:Create(Watermark, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.4 }):Play()
        task.wait(2.5)
        TweenService:Create(Watermark, TweenInfo.new(2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.75 }):Play()
        task.wait(2.5)
    end
end)

local BillboardGui = Instance.new("BillboardGui")
BillboardGui.Name = "KibaCooldownUI"
BillboardGui.Size = UDim2.new(0, 80, 0, 28)
BillboardGui.StudsOffset = Vector3.new(0, 2.8, 0)
BillboardGui.AlwaysOnTop = true
BillboardGui.Enabled = false
BillboardGui.ResetOnSpawn = false
BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local CooldownFrame = Instance.new("Frame")
CooldownFrame.Name = "CooldownFrame"
CooldownFrame.Size = UDim2.new(1, 0, 1, 0)
CooldownFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
CooldownFrame.BackgroundTransparency = 0.25
CooldownFrame.BorderSizePixel = 0
CooldownFrame.ZIndex = 10
CooldownFrame.Parent = BillboardGui

local CooldownCorner = Instance.new("UICorner")
CooldownCorner.CornerRadius = UDim.new(0, 6)
CooldownCorner.Parent = CooldownFrame

local CooldownStroke = Instance.new("UIStroke")
CooldownStroke.Color = Color3.fromRGB(60, 130, 255)
CooldownStroke.Thickness = 1
CooldownStroke.Transparency = 0.8
CooldownStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
CooldownStroke.Parent = CooldownFrame

local CooldownText = Instance.new("TextLabel")
CooldownText.Text = "⚡"
CooldownText.Font = Enum.Font.GothamBold
CooldownText.TextSize = 8
CooldownText.TextColor3 = Color3.fromRGB(180, 220, 255)
CooldownText.TextTransparency = 0.2
CooldownText.BackgroundTransparency = 1
CooldownText.Size = UDim2.new(1, 0, 0, 12)
CooldownText.Position = UDim2.new(0, 0, 0, 2)
CooldownText.TextXAlignment = Enum.TextXAlignment.Center
CooldownText.ZIndex = 11
CooldownText.Parent = CooldownFrame

local CooldownBarBg = Instance.new("Frame")
CooldownBarBg.Size = UDim2.new(0.8, 0, 0, 2.5)
CooldownBarBg.Position = UDim2.new(0.1, 0, 0, 16)
CooldownBarBg.BackgroundColor3 = Color3.fromRGB(30, 35, 70)
CooldownBarBg.BackgroundTransparency = 0.3
CooldownBarBg.BorderSizePixel = 0
CooldownBarBg.ZIndex = 11
CooldownBarBg.Parent = CooldownFrame

local CooldownBarBgCorner = Instance.new("UICorner")
CooldownBarBgCorner.CornerRadius = UDim.new(1, 0)
CooldownBarBgCorner.Parent = CooldownBarBg

local CooldownBar = Instance.new("Frame")
CooldownBar.Size = UDim2.new(1, 0, 1, 0)
CooldownBar.BackgroundColor3 = Color3.fromRGB(80, 200, 255)
CooldownBar.BorderSizePixel = 0
CooldownBar.ZIndex = 12
CooldownBar.Parent = CooldownBarBg

local CooldownBarCorner = Instance.new("UICorner")
CooldownBarCorner.CornerRadius = UDim.new(1, 0)
CooldownBarCorner.Parent = CooldownBar

local BarGlow = Instance.new("Frame")
BarGlow.Size = UDim2.new(1, 0, 1, 0)
BarGlow.BackgroundColor3 = Color3.fromRGB(130, 230, 255)
BarGlow.BackgroundTransparency = 0.5
BarGlow.BorderSizePixel = 0
BarGlow.ZIndex = 13
BarGlow.Parent = CooldownBar

local function AttachBillboard()
    local char = LocalPlayer.Character
    if not char then
        LocalPlayer.CharacterAdded:Wait()
        char = LocalPlayer.Character
    end
    local head = char:FindFirstChild("Head")
    if head then
        BillboardGui.Adornee = head
        BillboardGui.Parent = head
    end
end

local function OnCharacterAdded()
    task.wait(0.3)
    AttachBillboard()
end

AttachBillboard()
LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

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

    TweenService:Create(CooldownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { BackgroundTransparency = 0.2 }):Play()
    TweenService:Create(CooldownText, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    TweenService:Create(CooldownStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Transparency = 0.6 }):Play()
end

local function HideCooldown()
    if isCooldownHiding then return end
    isCooldownHiding = true

    TweenService:Create(CooldownFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
    TweenService:Create(CooldownText, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    TweenService:Create(CooldownStroke, TweenInfo.new(0.15, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()

    task.delay(0.25, function()
        if BillboardGui then
            BillboardGui.Enabled = false
        end
        isCooldownVisible = false
        isCooldownHiding = false
    end)
end

local CooldownMax = _G.KibaSettings.AbilityCooldown
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
        if remaining >= 1 then
            CooldownText.Text = "⚡ " .. string.format("%.1f", remaining) .. "s"
        else
            CooldownText.Text = "⚡ " .. string.format("%.1f", remaining) .. "s"
        end
        CooldownBar.Size = UDim2.new(math.clamp(remaining / CooldownMax, 0, 1), 0, 1, 0)
        local hue = 0.55 + (remaining / CooldownMax) * 0.2
        CooldownBar.BackgroundColor3 = Color3.fromHSV(hue, 1, 0.8)
        CooldownStroke.Color = Color3.fromHSV(0.58, 0.9, 0.7 + math.sin(tick() * 8) * 0.1)
    else
        if not wasInCooldown then
            wasInCooldown = true
            CooldownText.Text = "⚡ Ready"
            CooldownBar.Size = UDim2.new(0, 0, 1, 0)
            _G.KibaCooldownStart = nil
            task.delay(0.6, HideCooldown)
        end
    end
end)

local function CreateBeamEffect(startPos, endPos)
    if not _G.KibaSettings.ShowEffects then return end
    
    local beam = Instance.new("Frame")
    beam.Size = UDim2.new(0, 0, 0, 2)
    beam.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    beam.BackgroundTransparency = 0.3
    beam.BorderSizePixel = 0
    beam.ZIndex = 100
    beam.Parent = ScreenGui
    
    local beamCorner = Instance.new("UICorner")
    beamCorner.CornerRadius = UDim.new(1, 0)
    beamCorner.Parent = beam
    
    local beamGlow = Instance.new("UIStroke")
    beamGlow.Color = Color3.fromRGB(150, 220, 255)
    beamGlow.Thickness = 2
    beamGlow.Transparency = 0.5
    beamGlow.Parent = beam
    
    TweenService:Create(beam, TweenInfo.new(0.15, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 30, 0, 2), BackgroundTransparency = 1 }):Play()
    Debris:AddItem(beam, 0.2)
end

local function FireSplashEffect()
    if not _G.KibaSettings.ShowEffects then return end
    
    local flash = Instance.new("Frame")
    flash.Size = UDim2.new(1, 0, 1, 0)
    flash.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
    flash.BackgroundTransparency = 0.8
    flash.BorderSizePixel = 0
    flash.ZIndex = 50
    flash.Parent = ScreenGui
    TweenService:Create(flash, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { BackgroundTransparency = 1 }):Play()
    Debris:AddItem(flash, 0.3)
    
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
            ringStroke.Color = Color3.fromRGB(100 + i * 30, 180 + i * 15, 255)
            ringStroke.Thickness = 2.5 - i * 0.4
            ringStroke.Transparency = 0
            ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            ringStroke.Parent = ring
            local sizeVal = 180 + i * 60
            TweenService:Create(ring, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, sizeVal, 0, sizeVal) }):Play()
            TweenService:Create(ringStroke, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
            Debris:AddItem(ring, 0.45)
        end)
    end
    
    local glow = Instance.new("Frame")
    glow.Size = UDim2.new(0, 20, 0, 20)
    glow.AnchorPoint = Vector2.new(0.5, 0.5)
    glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    glow.BackgroundColor3 = Color3.fromRGB(150, 210, 255)
    glow.BackgroundTransparency = 0.3
    glow.BorderSizePixel = 0
    glow.ZIndex = 46
    glow.Parent = ScreenGui
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(1, 0)
    glowCorner.Parent = glow
    TweenService:Create(glow, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Size = UDim2.new(0, 120, 0, 120), BackgroundTransparency = 1 }):Play()
    Debris:AddItem(glow, 0.3)
    
    TweenService:Create(MainStroke, TweenInfo.new(0.06), { Color = Color3.fromRGB(255, 255, 255), Thickness = 4, Transparency = 0 }):Play()
    task.delay(0.1, function()
        TweenService:Create(MainStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Color = Color3.fromRGB(80, 140, 255), Thickness = 1.8, Transparency = 0.3 }):Play()
    end)
    
    TweenService:Create(IconDot, TweenInfo.new(0.1), { Size = UDim2.new(0, 14, 0, 14), Position = UDim2.new(0, 10, 0.5, -7) }):Play()
    task.delay(0.15, function()
        TweenService:Create(IconDot, TweenInfo.new(0.2), { Size = UDim2.new(0, 10, 0, 10), Position = UDim2.new(0, 12, 0.5, -5) }):Play()
    end)
end

_G.KibaFireSplash = FireSplashEffect

local function PulseBorder()
    local direction = 1
    while true do
        for i = 1, 40 do
            local thickness = MainStroke.Thickness + (direction * 0.015)
            local transparency = MainStroke.Transparency - (direction * 0.008)
            if thickness >= 2.2 then direction = -1 end
            if thickness <= 1.5 then direction = 1 end
            MainStroke.Thickness = thickness
            MainStroke.Transparency = math.clamp(transparency, 0.2, 0.45)
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
            TweenService:Create(MainFrame, TweenInfo.new(0.12), { BackgroundTransparency = 0.05 }):Play()
        end
    end
end)

TweenService:Create(MainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -210, 0.5, -24) }):Play()

local function WaitForCharacter()
    local character = LocalPlayer.Character
    if not character or not character.Parent then
        character = LocalPlayer.CharacterAdded:Wait()
    end
    return character
end

local Character = WaitForCharacter()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Animator = Humanoid:WaitForChild("Animator")
local Communicate = Character:FindFirstChild("Communicate")

if not Communicate then
    Communicate = Instance.new("RemoteEvent")
    Communicate.Name = "Communicate"
    Communicate.Parent = Character
end

local AnimationID = _G.KibaSettings.AnimationID
local DashRange = _G.KibaSettings.DashRange
local AbilityCooldown = _G.KibaSettings.AbilityCooldown

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
    pcall(function()
        Humanoid:ChangeState(Enum.HumanoidStateType.Running)
        Humanoid.AutoRotate = true
    end)
end

local function FindNearestTarget()
    local closest = nil
    local closestDist = DashRange
    local lowestHealth = math.huge
    local highestHealth = 0
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local targetRoot = player.Character:FindFirstChild("HumanoidRootPart")
            local targetHumanoid = player.Character:FindFirstChild("Humanoid")
            if targetRoot and targetHumanoid and targetHumanoid.Health > 0 then
                local dist = (targetRoot.Position - RootPart.Position).Magnitude
                if dist < DashRange then
                    if _G.KibaSettings.TargetPriority == "Closest" then
                        if dist < closestDist then
                            closestDist = dist
                            closest = targetRoot
                        end
                    elseif _G.KibaSettings.TargetPriority == "LowestHealth" then
                        if targetHumanoid.Health < lowestHealth then
                            lowestHealth = targetHumanoid.Health
                            closest = targetRoot
                        end
                    elseif _G.KibaSettings.TargetPriority == "HighestHealth" then
                        if targetHumanoid.Health > highestHealth then
                            highestHealth = targetHumanoid.Health
                            closest = targetRoot
                        end
                    else
                        if dist < closestDist then
                            closestDist = dist
                            closest = targetRoot
                        end
                    end
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
                    if dist < closestDist and dist < DashRange then
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
    if not Animator then return false, nil end
    for _, track in ipairs(Animator:GetPlayingAnimationTracks()) do
        local animId = track.Animation.AnimationId
        if animId then
            local id = tostring(animId):match("%d+$")
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
    
    pcall(function()
        if Communicate then
            Communicate:FireServer(unpack({ { Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" } }))
        end
    end)
    
    if target and target.Parent and RootPart and Humanoid then
        local lookVec = RootPart.CFrame.LookVector
        local angle = math.atan2(-lookVec.X, -lookVec.Z)
        local targetPos = target.Position
        local dashPos = Vector3.new(targetPos.X, targetPos.Y - 2.5, targetPos.Z)
        local dashCFrame = CFrame.new(dashPos) * CFrame.fromEulerAnglesYXZ(math.pi / 2, angle, 0)
        
        pcall(function()
            Humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            Humanoid.AutoRotate = false
            RootPart.CFrame = dashCFrame
            RootPart.AssemblyLinearVelocity = Vector3.zero
            RootPart.AssemblyAngularVelocity = Vector3.zero
        end)
        
        local relativeCFrame = dashCFrame - dashCFrame.Position
        if heartbeatConnection then heartbeatConnection:Disconnect() end
        
        local elapsed = 0
        local duration = 0.5
        
        heartbeatConnection = RunService.Heartbeat:Connect(function(dt)
            elapsed = elapsed + dt
            if elapsed >= duration then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
                return
            end
            if not target or not target.Parent or not RootPart then
                heartbeatConnection:Disconnect()
                heartbeatConnection = nil
                return
            end
            
            pcall(function()
                local currentTargetPos = target.Position
                local targetDashPos = Vector3.new(currentTargetPos.X, currentTargetPos.Y - 2.5, currentTargetPos.Z)
                local progress = elapsed / duration
                local verticalVelocity = math.sin(progress * math.pi) * 35
                local deltaX = targetDashPos.X - RootPart.Position.X
                local deltaZ = targetDashPos.Z - RootPart.Position.Z
                local speed = 30
                
                if _G.KibaSettings.SmoothDash then
                    speed = 25 + progress * 15
                end
                
                RootPart.AssemblyLinearVelocity = Vector3.new(deltaX * speed, verticalVelocity, deltaZ * speed)
                RootPart.AssemblyAngularVelocity = Vector3.zero
                RootPart.CFrame = CFrame.new(RootPart.Position) * relativeCFrame
            end)
        end)
    end
    
    task.wait(0.52)
    ResetMovement()
    hasTriggered = false
    isDashing = false
    targetPart = nil
end

RunService.Heartbeat:Connect(function()
    local isEnabled = _G.KibaEnabled == true
    local earlyFire = tonumber(_G.KibaEarlyFire) or 0.65
    
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
    
    local success, isPlaying, currentTrack = pcall(IsAnimationPlaying)
    if not success then return end
    
    if isPlaying and not isAnimating then
        isAnimating = true
        isDashing = false
        hasTriggered = false
        if _G.KibaSettings.AutoTarget then
            targetPart = FindNearestTarget()
        end
    elseif isPlaying and isAnimating then
        if not isDashing and not hasTriggered and targetPart then
            if currentTrack and currentTrack.Length and currentTrack.Length > 0.01 then
                local timeLeft = currentTrack.Length - currentTrack.TimePosition
                if timeLeft <= earlyFire and timeLeft > 0 then
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
        if isAnimating then
            ResetState()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    Character = newChar
    Humanoid = Character:WaitForChild("Humanoid")
    RootPart = Character:WaitForChild("HumanoidRootPart")
    Animator = Humanoid:WaitForChild("Animator")
    Communicate = Character:FindFirstChild("Communicate")
    
    if not Communicate then
        Communicate = Instance.new("RemoteEvent")
        Communicate.Name = "Communicate"
        Communicate.Parent = Character
    end
    
    ResetState()
    ResetMovement()
    lastUsed = tick() - AbilityCooldown - 1
    
    AttachBillboard()
end)

print("KibaX Tech - Loaded Successfully")
print("Open Source | Legit Edition")