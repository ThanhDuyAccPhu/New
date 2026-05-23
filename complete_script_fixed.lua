local _version = "1.6.64-fix"
local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PINK = Color3.fromRGB(255, 105, 180)

-- ============================================
-- HELPER FUNCTIONS
-- ============================================
local function GetCharacterData()
    local char = LocalPlayer.Character
    if char then
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if humanoid and root then
            return char, humanoid, root
        end
    end
    return nil
end

local function FireDashQW()
    local char = LocalPlayer.Character
    if char then
        local comm = char:FindFirstChild("Communicate")
        if comm then
            local dashData = {{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}
            pcall(function() comm:FireServer(unpack(dashData)) end)
        end
    end
end

local function DeleteBodyVelocity()
    local function findNilInstance(name, className)
        if type(getnilinstances) ~= "function" then return nil end
        for _, inst in ipairs(getnilinstances()) do
            if inst.ClassName == className and inst.Name == name then
                return inst
            end
        end
        return nil
    end
    
    pcall(function()
        local bv = findNilInstance("moveme", "BodyVelocity")
        if bv then
            local comm = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Communicate")
            if comm then
                comm:FireServer({Goal = "delete bv", BV = bv})
            end
            bv.Parent = nil
        end
    end)
end

-- ============================================
-- LOOP DASH CONFIG & LOGIC (Original)
-- ============================================
local LoopDashConfig = {
    Enabled = false,
    loopReworkAnimDetectId = "10503381238",
    loopReworkWaitDetect = 3,
    loopReworkWaitJump = 0,
    loopReworkWaitRemote = 1,
    loopReworkLockDuration = 15,
    loopReworkTargetRadius = 50,
    loopReworkCooldown = 50,
    loopReworkResponsiveness = 483,
    ForceJumpUpwardVelocity = 62,
    loopReworkDebounce = false,
    AnimConnection = nil,
    CharacterConnection = nil,
}

local function LoopDashFindBestTarget(radius)
    local radius = radius or LoopDashConfig.loopReworkTargetRadius
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return nil end
    
    local _, _, myRoot = GetCharacterData()
    if not myRoot then return nil end
    
    local bestTarget = nil
    for _, model in ipairs(liveFolder:GetChildren()) do
        if model and model:IsA("Model") and model ~= LocalPlayer.Character then
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            local targetHum = model:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local distance = (targetRoot.Position - myRoot.Position).Magnitude
                if distance <= radius then bestTarget = targetRoot; radius = distance end
            end
        end
    end
    return bestTarget
end

local function StartHorizontalLockLerp(target, duration, responsiveness)
    if not (target and target.Parent) then return nil end
    local _, humanoid, myRoot = GetCharacterData()
    if not (myRoot and humanoid) then return nil end
    
    responsiveness = math.clamp(responsiveness or LoopDashConfig.loopReworkResponsiveness, 1, 10000)
    local startTime = tick()
    local connection
    
    connection = RunService.RenderStepped:Connect(function(deltaTime)
        if target and target.Parent and myRoot and myRoot.Parent then
            local targetPos = target.Position
            local alignedPos = Vector3.new(myRoot.Position.X, targetPos.Y, myRoot.Position.Z)
            
            if (alignedPos - myRoot.Position).Magnitude >= 0.001 then
                local lookCFrame = CFrame.new(myRoot.Position, alignedPos)
                local alpha = math.clamp(1 - math.exp(-0.02 * responsiveness * deltaTime), 0, 1)
                local newCFrame = myRoot.CFrame:Lerp(lookCFrame, alpha)
                myRoot.CFrame = CFrame.new(myRoot.Position) * CFrame.fromMatrix(Vector3.new(), newCFrame.RightVector, newCFrame.UpVector)
            end
            
            if tick() - startTime >= duration then
                connection:Disconnect()
            end
        else
            connection:Disconnect()
        end
    end)
    
    return function()
        if connection then pcall(function() connection:Disconnect() end) end
    end
end

local LoopDashLerpCleaner = nil

local function LoopDashRunSequence()
    if LoopDashConfig.loopReworkDebounce or not LoopDashConfig.Enabled then return end
    LoopDashConfig.loopReworkDebounce = true
    
    task.wait(LoopDashConfig.loopReworkWaitDetect / 10)
    local char, hum, root = GetCharacterData()
    if hum and root then
        hum.AutoRotate = false
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, LoopDashConfig.ForceJumpUpwardVelocity, root.AssemblyLinearVelocity.Z)
        
        task.wait(LoopDashConfig.loopReworkWaitJump / 10)
        FireDashQW()
        
        task.wait(LoopDashConfig.loopReworkWaitRemote / 10)
        local target = LoopDashFindBestTarget()
        if target then
            if LoopDashLerpCleaner then LoopDashLerpCleaner() end
            LoopDashLerpCleaner = StartHorizontalLockLerp(target, LoopDashConfig.loopReworkLockDuration / 10, LoopDashConfig.loopReworkResponsiveness)
        end
        
        local endTime = tick() + (LoopDashConfig.loopReworkLockDuration / 10)
        task.spawn(function()
            while tick() < endTime and LoopDashConfig.Enabled do
                hum.AutoRotate = false
                RunService.Heartbeat:Wait()
            end
            if hum then hum.AutoRotate = true end
        end)
    end
    
    task.wait(LoopDashConfig.loopReworkCooldown / 10)
    LoopDashConfig.loopReworkDebounce = false
end

local function LoopDashOnAnimationPlayed(anim)
    if LoopDashConfig.Enabled and not LoopDashConfig.loopReworkDebounce then
        local animId = tostring(anim.Animation.AnimationId)
        if animId:find(LoopDashConfig.loopReworkAnimDetectId) then
            task.spawn(LoopDashRunSequence)
        end
    end
end

local function ConnectLoopDashCharacter()
    if LoopDashConfig.AnimConnection then LoopDashConfig.AnimConnection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    LoopDashConfig.AnimConnection = hum.AnimationPlayed:Connect(LoopDashOnAnimationPlayed)
end

-- ============================================
-- INSTANT LETHAL CONFIG & LOGIC (Original)
-- ============================================
local InstantLethalConfig = {
    Enabled = false,
    AnimationId = "rbxassetid://12296113986",
    Connection = nil,
    Smoothness = 0.22,
}

local function DoFlick()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum then
        root.CFrame = root.CFrame * CFrame.Angles(0, math.pi, 0)
        local x, y, z = Camera.CFrame:ToEulerAnglesYXZ()
        Camera.CFrame = CFrame.new(Camera.CFrame.Position) * CFrame.fromEulerAnglesYXZ(x, y + math.pi, z)
        hum.AutoRotate = false
        task.delay(0.4, function() if hum then hum.AutoRotate = true end end)
    end
end

local function DoJump()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity = Vector3.new(0, 64, 0) end
end

local function ConnectInstantLethal()
    if InstantLethalConfig.Connection then InstantLethalConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    InstantLethalConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if InstantLethalConfig.Enabled and anim.Animation.AnimationId == InstantLethalConfig.AnimationId then
            task.wait(1.72)
            DoJump()
            DoFlick()
            local char = LocalPlayer.Character
            if char then
                if char:FindFirstChild("Communicate") then
                    char.Communicate:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                end
            end
            task.wait(InstantLethalConfig.Smoothness)
            DoFlick()
        end
    end)
end

-- ============================================
-- AUTO KYOTO CONFIG & LOGIC (Original)
-- ============================================
local AutoKyotoConfig = {
    Enabled = false,
    Speed = 22.5,
    AnimationDelay = 1.5,
    ExecutionDelay = 0.6,
    AnimationId = "rbxassetid://12273188754",
    Connection = nil,
    Active = false,
    TargetEnemy = nil,
}

local function OnKyotoCharacterSpawn(character)
    task.wait(0.3)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.WalkSpeed = AutoKyotoConfig.Speed
    end
end

local function ConnectAutoKyoto()
    if AutoKyotoConfig.Connection then AutoKyotoConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    AutoKyotoConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if AutoKyotoConfig.Enabled and anim.Animation.AnimationId == AutoKyotoConfig.AnimationId then
            AutoKyotoConfig.Active = true
            task.wait(AutoKyotoConfig.AnimationDelay)
            
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.WalkSpeed = AutoKyotoConfig.Speed
                end
                local comm = char:FindFirstChild("Communicate")
                if comm then
                    pcall(function()
                        comm:FireServer({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}})
                    end)
                end
            end
            
            task.wait(AutoKyotoConfig.ExecutionDelay)
            AutoKyotoConfig.Active = false
        end
    end)
end

-- ============================================
-- LETHAL DASH CONFIG & LOGIC (Original)
-- ============================================
local LethalDashConfig = {
    Enabled = false,
    Speed = 35,
    AnimationId = "rbxassetid://12296113986",
    Connection = nil,
}

local function ConnectLethalDash()
    if LethalDashConfig.Connection then LethalDashConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    LethalDashConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if LethalDashConfig.Enabled and anim.Animation.AnimationId == LethalDashConfig.AnimationId then
            task.wait(0.2)
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, LethalDashConfig.Speed, root.AssemblyLinearVelocity.Z)
                end
            end
        end
    end)
end

-- ============================================
-- LIX TECH CONFIG & LOGIC (Original)
-- ============================================
local LixTechConfig = {
    Enabled = false,
    Speed = 50,
    AnimationId = "rbxassetid://12296113986",
    Delay = 0.1,
    Connection = nil,
    CharConnection = nil,
    Busy = false,
}

local function ConnectLixTech()
    if LixTechConfig.Connection then LixTechConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    LixTechConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if LixTechConfig.Enabled and not LixTechConfig.Busy and anim.Animation.AnimationId == LixTechConfig.AnimationId then
            LixTechConfig.Busy = true
            task.wait(LixTechConfig.Delay)
            
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, LixTechConfig.Speed, root.AssemblyLinearVelocity.Z)
                end
            end
            
            task.wait(0.5)
            LixTechConfig.Busy = false
        end
    end)
end

-- ============================================
-- OMINE CONFIG & LOGIC (Original)
-- ============================================
local OmineConfig = {
    Enabled = false,
    Speed = 45,
    AnimationId = "rbxassetid://12273188754",
    Cooldown = 2,
    Connection = nil,
    LastTime = 0,
}

local function ConnectOmine()
    if OmineConfig.Connection then OmineConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    OmineConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if OmineConfig.Enabled and anim.Animation.AnimationId == OmineConfig.AnimationId then
            local currentTime = tick()
            if currentTime - OmineConfig.LastTime >= OmineConfig.Cooldown then
                OmineConfig.LastTime = currentTime
                
                local char = LocalPlayer.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, OmineConfig.Speed, root.AssemblyLinearVelocity.Z)
                    end
                end
            end
        end
    end)
end

-- ============================================
-- OREO TECH CONFIG & LOGIC (Renamed from Hexed)
-- ============================================
local OreoTechConfig = {
    Enabled = false,
    AnimationId = "rbxassetid://12296113986",
    Speed = 55,
    Duration = 1.2,
    Cooldown = 3,
    Connection = nil,
    LastExecution = 0,
    CooldownTime = 3,
}

local function ExecuteOreoTech()
    local char = LocalPlayer.Character
    if not char then return end
    
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    
    if root and hum then
        hum.AutoRotate = false
        root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, OreoTechConfig.Speed, root.AssemblyLinearVelocity.Z)
        
        task.wait(OreoTechConfig.Duration)
        
        hum.AutoRotate = true
        
        task.wait(OreoTechConfig.Cooldown)
    end
end

local function ConnectOreoTech()
    if OreoTechConfig.Connection then OreoTechConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    OreoTechConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if OreoTechConfig.Enabled and anim.Animation.AnimationId == OreoTechConfig.AnimationId then
            local currentTime = tick()
            if currentTime - OreoTechConfig.LastExecution >= OreoTechConfig.CooldownTime then
                OreoTechConfig.LastExecution = currentTime
                task.spawn(ExecuteOreoTech)
            end
        end
    end)
end

-- ============================================
-- TWISTED REVAMP CONFIG & LOGIC (Original)
-- ============================================
local TwistedConfig = {
    Enabled = false,
    Speed = 40,
    AnimationId = "rbxassetid://12296113986",
    Connection = nil,
    AutoRotateConnection = nil,
    Busy = false,
}

local function ConnectTwisted()
    if TwistedConfig.Connection then TwistedConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    TwistedConfig.Connection = hum.AnimationPlayed:Connect(function(anim)
        if TwistedConfig.Enabled and not TwistedConfig.Busy and anim.Animation.AnimationId == TwistedConfig.AnimationId then
            TwistedConfig.Busy = true
            
            local char = LocalPlayer.Character
            if char then
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, TwistedConfig.Speed, root.AssemblyLinearVelocity.Z)
                end
            end
            
            task.wait(0.5)
            TwistedConfig.Busy = false
        end
    end)
    
    if TwistedConfig.AutoRotateConnection then TwistedConfig.AutoRotateConnection:Disconnect() end
    TwistedConfig.AutoRotateConnection = RunService.RenderStepped:Connect(function()
        if TwistedConfig.Enabled then
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.AutoRotate = false
                end
            end
        end
    end)
end

-- ============================================
-- KITTY TECH CONFIG & LOGIC
-- ============================================
local KittyTechConfig = {
    Enabled = false,
    DashDelay = 0.01,
    PostDashWait = 0.078,
    CooldownTime = 4.8,
    OrbitRadius = 3,
    OrbitHeight = 1,
    SpinDuration = 0.6,
    TargetDistance = 12,
    AttachmentDuration = 0.5,
    PingSetting = 60,
    Busy = false,
    Connection = nil,
    CharConnection = nil,
}

local function FindNearestEnemyKitty(distance)
    distance = distance or KittyTechConfig.TargetDistance
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return nil end
    
    local _, _, myRoot = GetCharacterData()
    if not myRoot then return nil end
    
    local bestTarget = nil
    local closestDistance = distance
    
    for _, model in ipairs(liveFolder:GetChildren()) do
        if model and model:IsA("Model") and model ~= LocalPlayer.Character then
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            local targetHum = model:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                if dist <= closestDistance then
                    bestTarget = targetRoot
                    closestDistance = dist
                end
            end
        end
    end
    
    return bestTarget
end

local function KittyTechExecute()
    if KittyTechConfig.Busy or not KittyTechConfig.Enabled then return end
    KittyTechConfig.Busy = true
    
    local char, hum, root = GetCharacterData()
    if not (char and hum and root) then
        KittyTechConfig.Busy = false
        return
    end
    
    hum.AutoRotate = false
    
    task.wait(KittyTechConfig.DashDelay)
    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 50, root.AssemblyLinearVelocity.Z)
    
    task.wait(KittyTechConfig.DashDelay)
    FireDashQW()
    
    task.wait(KittyTechConfig.PostDashWait)
    local target = FindNearestEnemyKitty()
    
    if target then
        local startTime = tick()
        local spinDuration = KittyTechConfig.SpinDuration
        
        while tick() - startTime < spinDuration and KittyTechConfig.Enabled and root and root.Parent do
            local targetPos = target.Position
            local direction = (targetPos - root.Position).Unit
            local spinCFrame = CFrame.new(root.Position) * CFrame.fromAxisAngle(Vector3.new(0, 1, 0), (tick() - startTime) * math.pi * 2 / spinDuration)
            root.CFrame = spinCFrame
            RunService.Heartbeat:Wait()
        end
        
        task.wait(KittyTechConfig.AttachmentDuration)
    end
    
    if hum then
        hum.AutoRotate = true
    end
    
    task.wait(KittyTechConfig.CooldownTime)
    KittyTechConfig.Busy = false
end

local function KittyTechOnAnimationPlayed(anim)
    if KittyTechConfig.Enabled and not KittyTechConfig.Busy then
        local animId = tostring(anim.Animation.AnimationId)
        if animId:find("10503381238") then
            task.spawn(KittyTechExecute)
        end
    end
end

local function ConnectKittyTech()
    if KittyTechConfig.Connection then 
        KittyTechConfig.Connection:Disconnect() 
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    KittyTechConfig.Connection = hum.AnimationPlayed:Connect(KittyTechOnAnimationPlayed)
end

-- ============================================
-- WINDUI WINDOW SETUP
-- ============================================
local Window = WindUI:CreateWindow({
    Title = "YumeX Hub",
    Author = "YumeX",
    Icon = "rbxassetid://0",
    Icon_Color = PINK,
    Folder = "YumeXHubScripts",
})

-- ============================================
-- LOOP DASH TAB
-- ============================================
local LoopDashTab = Window:Tab({
    Title = "Loop Dash",
    Icon = "zap",
    IconColor = PINK,
})

LoopDashTab:Section({
    Title = "Loop Dash Settings",
    Icon = "settings",
})

LoopDashTab:Toggle({
    Title = "Enable Loop Dash",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if LoopDashConfig.Enabled == state then return end
        LoopDashConfig.Enabled = state
        if state then
            ConnectLoopDashCharacter()
        else
            if LoopDashConfig.AnimConnection then
                LoopDashConfig.AnimConnection:Disconnect()
                LoopDashConfig.AnimConnection = nil
            end
        end
    end
})

LoopDashTab:Slider({
    Title = "Wait Detect",
    Value = {Min = 0, Max = 10, Default = 3},
    Step = 0.1,
    Callback = function(value)
        LoopDashConfig.loopReworkWaitDetect = value
    end
})

LoopDashTab:Slider({
    Title = "Target Radius",
    Value = {Min = 10, Max = 100, Default = 50},
    Step = 5,
    Callback = function(value)
        LoopDashConfig.loopReworkTargetRadius = value
    end
})

-- ============================================
-- INSTANT LETHAL TAB
-- ============================================
local InstantLethalTab = Window:Tab({
    Title = "Instant Lethal",
    Icon = "target",
    IconColor = PINK,
})

InstantLethalTab:Section({
    Title = "Instant Lethal Settings",
    Icon = "settings",
})

InstantLethalTab:Toggle({
    Title = "Enable Instant Lethal",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if InstantLethalConfig.Enabled == state then return end
        InstantLethalConfig.Enabled = state
        if state then
            ConnectInstantLethal()
        else
            if InstantLethalConfig.Connection then
                InstantLethalConfig.Connection:Disconnect()
                InstantLethalConfig.Connection = nil
            end
        end
    end
})

InstantLethalTab:Slider({
    Title = "Smoothness",
    Value = {Min = 0.1, Max = 1, Default = 0.22},
    Step = 0.01,
    Callback = function(value)
        InstantLethalConfig.Smoothness = value
    end
})

-- ============================================
-- AUTO KYOTO TAB
-- ============================================
local AutoKyotoTab = Window:Tab({
    Title = "Auto Kyoto",
    Icon = "activity",
    IconColor = PINK,
})

AutoKyotoTab:Section({
    Title = "Auto Kyoto Settings",
    Icon = "settings",
})

AutoKyotoTab:Toggle({
    Title = "Enable Auto Kyoto",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if AutoKyotoConfig.Enabled == state then return end
        AutoKyotoConfig.Enabled = state
        if state then
            ConnectAutoKyoto()
        else
            if AutoKyotoConfig.Connection then
                AutoKyotoConfig.Connection:Disconnect()
                AutoKyotoConfig.Connection = nil
            end
        end
    end
})

AutoKyotoTab:Slider({
    Title = "Speed",
    Value = {Min = 5, Max = 50, Default = 22.5},
    Step = 0.5,
    Callback = function(value)
        AutoKyotoConfig.Speed = value
    end
})

-- ============================================
-- LETHAL DASH TAB
-- ============================================
local LethalDashTab = Window:Tab({
    Title = "Lethal Dash",
    Icon = "zap",
    IconColor = PINK,
})

LethalDashTab:Section({
    Title = "Lethal Dash Settings",
    Icon = "settings",
})

LethalDashTab:Toggle({
    Title = "Enable Lethal Dash",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if LethalDashConfig.Enabled == state then return end
        LethalDashConfig.Enabled = state
        if state then
            ConnectLethalDash()
        else
            if LethalDashConfig.Connection then
                LethalDashConfig.Connection:Disconnect()
                LethalDashConfig.Connection = nil
            end
        end
    end
})

LethalDashTab:Slider({
    Title = "Jump Speed",
    Value = {Min = 10, Max = 100, Default = 35},
    Step = 5,
    Callback = function(value)
        LethalDashConfig.Speed = value
    end
})

-- ============================================
-- LIX TECH TAB
-- ============================================
local LixTechTab = Window:Tab({
    Title = "Lix Tech",
    Icon = "zap",
    IconColor = PINK,
})

LixTechTab:Section({
    Title = "Lix Tech Settings",
    Icon = "settings",
})

LixTechTab:Toggle({
    Title = "Enable Lix Tech",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if LixTechConfig.Enabled == state then return end
        LixTechConfig.Enabled = state
        if state then
            ConnectLixTech()
        else
            if LixTechConfig.Connection then
                LixTechConfig.Connection:Disconnect()
                LixTechConfig.Connection = nil
            end
            LixTechConfig.Busy = false
        end
    end
})

LixTechTab:Slider({
    Title = "Jump Speed",
    Value = {Min = 10, Max = 100, Default = 50},
    Step = 5,
    Callback = function(value)
        LixTechConfig.Speed = value
    end
})

LixTechTab:Slider({
    Title = "Delay",
    Value = {Min = 0, Max = 0.5, Default = 0.1},
    Step = 0.01,
    Callback = function(value)
        LixTechConfig.Delay = value
    end
})

-- ============================================
-- OMINE TAB
-- ============================================
local OmineTab = Window:Tab({
    Title = "Omine",
    Icon = "zap",
    IconColor = PINK,
})

OmineTab:Section({
    Title = "Omine Settings",
    Icon = "settings",
})

OmineTab:Toggle({
    Title = "Enable Omine",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if OmineConfig.Enabled == state then return end
        OmineConfig.Enabled = state
        if state then
            ConnectOmine()
        else
            if OmineConfig.Connection then
                OmineConfig.Connection:Disconnect()
                OmineConfig.Connection = nil
            end
        end
    end
})

OmineTab:Slider({
    Title = "Jump Speed",
    Value = {Min = 10, Max = 100, Default = 45},
    Step = 5,
    Callback = function(value)
        OmineConfig.Speed = value
    end
})

OmineTab:Slider({
    Title = "Cooldown",
    Value = {Min = 0.5, Max = 5, Default = 2},
    Step = 0.1,
    Callback = function(value)
        OmineConfig.Cooldown = value
    end
})

-- ============================================
-- OREO TECH TAB (Renamed from Hexed)
-- ============================================
local OreoTechTab = Window:Tab({
    Title = "Oreo Tech",
    Icon = "zap",
    IconColor = PINK,
})

OreoTechTab:Section({
    Title = "Oreo Tech Settings",
    Icon = "settings",
})

OreoTechTab:Toggle({
    Title = "Enable Oreo Tech",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if OreoTechConfig.Enabled == state then return end
        OreoTechConfig.Enabled = state
        if state then
            ConnectOreoTech()
        else
            if OreoTechConfig.Connection then
                OreoTechConfig.Connection:Disconnect()
                OreoTechConfig.Connection = nil
            end
        end
    end
})

OreoTechTab:Slider({
    Title = "Jump Speed",
    Value = {Min = 10, Max = 100, Default = 55},
    Step = 5,
    Callback = function(value)
        OreoTechConfig.Speed = value
    end
})

OreoTechTab:Slider({
    Title = "Duration",
    Value = {Min = 0.5, Max = 3, Default = 1.2},
    Step = 0.1,
    Callback = function(value)
        OreoTechConfig.Duration = value
    end
})

OreoTechTab:Slider({
    Title = "Cooldown Time",
    Value = {Min = 0.5, Max = 10, Default = 3},
    Step = 0.5,
    Callback = function(value)
        OreoTechConfig.CooldownTime = value
    end
})

-- ============================================
-- TWISTED REVAMP TAB
-- ============================================
local TwistedTab = Window:Tab({
    Title = "Twisted",
    Icon = "repeat",
    IconColor = PINK,
})

TwistedTab:Section({
    Title = "Twisted Revamp Settings",
    Icon = "settings",
})

TwistedTab:Toggle({
    Title = "Enable Twisted",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if TwistedConfig.Enabled == state then return end
        TwistedConfig.Enabled = state
        if state then
            ConnectTwisted()
        else
            if TwistedConfig.Connection then
                TwistedConfig.Connection:Disconnect()
                TwistedConfig.Connection = nil
            end
            if TwistedConfig.AutoRotateConnection then
                TwistedConfig.AutoRotateConnection:Disconnect()
                TwistedConfig.AutoRotateConnection = nil
            end
            TwistedConfig.Busy = false
            local _, hum = GetCharacterData()
            if hum then hum.AutoRotate = true end
        end
    end
})

-- ============================================
-- KITTY TECH TAB
-- ============================================
local KittyTechTab = Window:Tab({
    Title = "Kitty Tech",
    Icon = "cat",
    IconColor = PINK,
})

KittyTechTab:Section({
    Title = "Kitty Tech Settings",
    Icon = "settings",
})

KittyTechTab:Toggle({
    Title = "Enable Kitty Tech",
    Value = false,
    Icon = "power",
    Color = PINK,
    Callback = function(state)
        if KittyTechConfig.Enabled == state then return end
        KittyTechConfig.Enabled = state
        if state then
            ConnectKittyTech()
            if not KittyTechConfig.CharConnection then
                KittyTechConfig.CharConnection = LocalPlayer.CharacterAdded:Connect(function()
                    if KittyTechConfig.Enabled then
                        task.wait(0.5)
                        ConnectKittyTech()
                    end
                end)
            end
        else
            if KittyTechConfig.Connection then
                KittyTechConfig.Connection:Disconnect()
                KittyTechConfig.Connection = nil
            end
            if KittyTechConfig.CharConnection then
                KittyTechConfig.CharConnection:Disconnect()
                KittyTechConfig.CharConnection = nil
            end
            KittyTechConfig.Busy = false
            local _, hum = GetCharacterData()
            if hum then
                hum.AutoRotate = true
                hum.WalkSpeed = 16
                hum.JumpPower = 50
                hum.PlatformStand = false
            end
        end
    end
})

KittyTechTab:Slider({
    Title = "Dash Delay",
    Value = {Min = 0.001, Max = 0.5, Default = 0.01},
    Step = 0.001,
    Callback = function(value)
        KittyTechConfig.DashDelay = value
    end
})

KittyTechTab:Slider({
    Title = "Post Dash Wait",
    Value = {Min = 0.01, Max = 0.5, Default = 0.078},
    Step = 0.001,
    Callback = function(value)
        KittyTechConfig.PostDashWait = value
    end
})

KittyTechTab:Slider({
    Title = "Cooldown Time",
    Value = {Min = 0.5, Max = 10, Default = 4.8},
    Step = 0.1,
    Callback = function(value)
        KittyTechConfig.CooldownTime = value
    end
})

KittyTechTab:Slider({
    Title = "Orbit Radius",
    Value = {Min = 0.5, Max = 10, Default = 3},
    Step = 0.5,
    Callback = function(value)
        KittyTechConfig.OrbitRadius = value
    end
})

KittyTechTab:Slider({
    Title = "Orbit Height",
    Value = {Min = 0, Max = 5, Default = 1},
    Step = 0.5,
    Callback = function(value)
        KittyTechConfig.OrbitHeight = value
    end
})

KittyTechTab:Slider({
    Title = "Spin Duration",
    Value = {Min = 0.1, Max = 2, Default = 0.6},
    Step = 0.05,
    Callback = function(value)
        KittyTechConfig.SpinDuration = value
    end
})

KittyTechTab:Slider({
    Title = "Target Distance",
    Value = {Min = 5, Max = 30, Default = 12},
    Step = 1,
    Callback = function(value)
        KittyTechConfig.TargetDistance = value
    end
})

KittyTechTab:Slider({
    Title = "Attachment Duration",
    Value = {Min = 0.1, Max = 1.5, Default = 0.5},
    Step = 0.05,
    Callback = function(value)
        KittyTechConfig.AttachmentDuration = value
    end
})

KittyTechTab:Slider({
    Title = "Ping Setting",
    Value = {Min = 20, Max = 200, Default = 60},
    Step = 5,
    Callback = function(value)
        KittyTechConfig.PingSetting = value
    end
})

-- ============================================
-- CHARACTER SPAWN HANDLING
-- ============================================
LocalPlayer.CharacterAdded:Connect(function(character)
    task.wait(0.1)
    
    if AutoKyotoConfig.Enabled then
        OnKyotoCharacterSpawn(character)
    end
    
    if InstantLethalConfig.Enabled then
        task.wait(0.5)
        ConnectInstantLethal()
    end
    
    if LoopDashConfig.Enabled then
        ConnectLoopDashCharacter()
    end
    
    if LethalDashConfig.Enabled then
        ConnectLethalDash()
    end
    
    if LixTechConfig.Enabled then
        ConnectLixTech()
    end
    
    if OmineConfig.Enabled then
        ConnectOmine()
    end
    
    if OreoTechConfig.Enabled then
        task.wait(0.5)
        ConnectOreoTech()
    end
    
    if TwistedConfig.Enabled then
        ConnectTwisted()
    end
    
    if KittyTechConfig.Enabled then
        task.wait(0.5)
        ConnectKittyTech()
    end
end)

-- Setup initial character
task.wait(0.5)
if LocalPlayer.Character then
    if LoopDashConfig.Enabled then ConnectLoopDashCharacter() end
    if LethalDashConfig.Enabled then ConnectLethalDash() end
    if LixTechConfig.Enabled then ConnectLixTech() end
    if OmineConfig.Enabled then ConnectOmine() end
    if OreoTechConfig.Enabled then ConnectOreoTech() end
    if TwistedConfig.Enabled then ConnectTwisted() end
    if KittyTechConfig.Enabled then ConnectKittyTech() end
    if AutoKyotoConfig.Enabled then OnKyotoCharacterSpawn(LocalPlayer.Character) end
    if InstantLethalConfig.Enabled then ConnectInstantLethal() end
end

-- ============================================
-- STARTUP NOTIFICATION
-- ============================================
WindUI:Notify({
    Title = "YumeX Hub Ready",
    Content = "All systems loaded successfully",
    Icon = "check-circle",
    Duration = 10,
})
