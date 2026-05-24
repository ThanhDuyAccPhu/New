local _version = "1.6.64-fix"

-- Safe load WindUI with error handling
local WindUI
local loadSuccess, loadErr = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/download/" .. _version .. "/main.lua"))()
end)
if not loadSuccess or not WindUI then
    pcall(function()
        WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"))()
    end)
end
if not WindUI then
    -- Create simple GUI if WindUI fails
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YumeXHub_Fallback"
    screenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 200)
    frame.Position = UDim2.new(0.5, -150, 0.5, -100)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "YumeX Hub"
    title.TextColor3 = Color3.fromRGB(255, 105, 180)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 60)
    msg.Position = UDim2.new(0, 0, 0, 50)
    msg.Text = "WindUI failed to load\nBut scripts are still running!"
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.Font = Enum.Font.GothamMedium
    msg.TextSize = 14
    msg.TextWrapped = true
    msg.BackgroundTransparency = 1
    msg.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
    closeBtn.Text = "OK"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Camera = Workspace.CurrentCamera
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local PINK = Color3.fromRGB(255, 105, 180)

-- Safe clipboard function
local function CopyToClipboard(text)
    local success = false
    pcall(function()
        if setclipboard then
            setclipboard(text)
            success = true
        elseif toclipboard then
            toclipboard(text)
            success = true
        elseif game:GetService("GuiService") and game:GetService("GuiService").SetClipboard then
            game:GetService("GuiService"):SetClipboard(text)
            success = true
        end
    end)
    return success
end

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
        pcall(function()
            for _, inst in ipairs(getnilinstances()) do
                if inst.ClassName == className and inst.Name == name then
                    return inst
                end
            end
        end)
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
-- LOOP DASH CONFIG & LOGIC
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
        if animId and animId:find(LoopDashConfig.loopReworkAnimDetectId) then
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
-- INSTANT LETHAL CONFIG & LOGIC
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
        if InstantLethalConfig.Enabled and anim.Animation and anim.Animation.AnimationId == InstantLethalConfig.AnimationId then
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
-- AUTO KYOTO CONFIG & LOGIC
-- ============================================
local AutoKyotoConfig = {
    Enabled = false,
    Speed = 22.5,
    AnimationDelay = 1.5,
    ExecutionDelay = 0.6,
    AnimationId = "rbxassetid://12273188754",
    Connection = nil,
    LastExecution = 0,
}

local function ExecuteKyotoMovement()
    local currentTime = os.clock()
    if currentTime - AutoKyotoConfig.LastExecution >= AutoKyotoConfig.ExecutionDelay then
        AutoKyotoConfig.LastExecution = currentTime
        local char = LocalPlayer.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = root.CFrame + root.CFrame.LookVector * AutoKyotoConfig.Speed
                pcall(function()
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                end)
            end
        end
    end
end

local function SetupKyotoListener(humanoid)
    if AutoKyotoConfig.Connection then AutoKyotoConfig.Connection:Disconnect() end
    if humanoid then
        AutoKyotoConfig.Connection = humanoid.AnimationPlayed:Connect(function(animTrack)
            if AutoKyotoConfig.Enabled then
                local success, animId = pcall(function()
                    return animTrack and (animTrack.Animation and tostring(animTrack.Animation.AnimationId)) or ""
                end)
                if success and animId == AutoKyotoConfig.AnimationId then
                    task.delay(AutoKyotoConfig.AnimationDelay, function()
                        if AutoKyotoConfig.Enabled then
                            ExecuteKyotoMovement()
                        end
                    end)
                end
            end
        end)
    end
end

local function OnKyotoCharacterSpawn(character)
    local hum = character:FindFirstChildOfClass("Humanoid")
    if hum then
        SetupKyotoListener(hum)
    end
end

-- ============================================
-- LETHAL DASH CONFIG & LOGIC
-- ============================================
local LethalDashConfig = {
    Enabled = false,
    AnimDetectId = "12296113986",
    WaitTime = 1.5,
    SnapDuration = 0.38,
    JumpPower = 64,
    LockDistance = 15,
    LerpStartAlpha = 0.32,
    LerpEndAlpha = 1,
    Connection = nil,
    Busy = false,
    LerpConnection = nil,
    LastExecution = 0,
    Cooldown = 0.4,
}

local function LethalDashFindTarget()
    local liveFolder = Workspace:FindFirstChild("Live")
    if not liveFolder then return nil end
    
    local _, _, myRoot = GetCharacterData()
    if not myRoot then return nil end
    
    local closestTarget = nil
    local closestDist = LethalDashConfig.LockDistance
    
    for _, model in ipairs(liveFolder:GetChildren()) do
        if model:IsA("Model") and model ~= LocalPlayer.Character then
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            local targetHum = model:FindFirstChildOfClass("Humanoid")
            if targetRoot and targetHum and targetHum.Health > 0 then
                local dist = (targetRoot.Position - myRoot.Position).Magnitude
                if dist <= LethalDashConfig.LockDistance and dist < closestDist then
                    closestDist = dist
                    closestTarget = targetRoot
                end
            end
        end
    end
    return closestTarget
end

local function LethalDashDoJump()
    local _, _, root = GetCharacterData()
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0, LethalDashConfig.JumpPower, 0)
    end
end

local function LethalDashLockOntoTarget(target)
    if LethalDashConfig.LerpConnection then
        LethalDashConfig.LerpConnection:Disconnect()
        LethalDashConfig.LerpConnection = nil
    end
    
    local _, hum, root = GetCharacterData()
    if not (target and target.Parent and root and hum) then return end
    
    local startTime = tick()
    LethalDashConfig.LerpConnection = RunService.RenderStepped:Connect(function()
        if not LethalDashConfig.Enabled or (tick() - startTime) >= LethalDashConfig.SnapDuration or not target or not target.Parent or not root or not root.Parent then
            if hum then hum.AutoRotate = true end
            if LethalDashConfig.LerpConnection then
                LethalDashConfig.LerpConnection:Disconnect()
                LethalDashConfig.LerpConnection = nil
            end
            return
        end
        
        if hum then hum.AutoRotate = false end
        
        local myPos = root.Position
        local targetPos = target.Position
        local flatTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
        local targetCF = CFrame.new(myPos, flatTarget)
        
        local progress = math.clamp((tick() - startTime) / LethalDashConfig.SnapDuration, LethalDashConfig.LerpStartAlpha, LethalDashConfig.LerpEndAlpha)
        local smooth = progress * progress * (3 - 2 * progress)
        
        root.CFrame = root.CFrame:Lerp(targetCF, smooth)
    end)
end

local function LethalDashExecute()
    if LethalDashConfig.Busy or not LethalDashConfig.Enabled then return end
    LethalDashConfig.Busy = true
    
    task.wait(LethalDashConfig.WaitTime)
    
    if not LethalDashConfig.Enabled then LethalDashConfig.Busy = false return end
    
    local _, hum, root = GetCharacterData()
    if hum and root then
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
        task.wait(0.1)
        LethalDashDoJump()
        
        FireDashQW()
        
        local target = LethalDashFindTarget()
        if target then
            LethalDashLockOntoTarget(target)
        end
    end
    
    task.wait(LethalDashConfig.Cooldown)
    LethalDashConfig.Busy = false
end

local function LethalDashOnAnimation(animTrack)
    if not LethalDashConfig.Enabled then return end
    local success, animId = pcall(function()
        return animTrack and animTrack.Animation and tostring(animTrack.Animation.AnimationId) or ""
    end)
    if success and animId and animId:find(LethalDashConfig.AnimDetectId) then
        task.spawn(LethalDashExecute)
    end
end

local function ConnectLethalDash()
    if LethalDashConfig.Connection then LethalDashConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    LethalDashConfig.Connection = hum.AnimationPlayed:Connect(LethalDashOnAnimation)
end

-- ============================================
-- LIX TECH CONFIG & LOGIC
-- ============================================
local LixTechConfig = {
    Enabled = false,
    Delay = 0.3,
    AnimDetectIds = {"13379003796", "10503381238"},
    Connection = nil,
    Busy = false,
}

local function LixTechExecute()
    if LixTechConfig.Busy or not LixTechConfig.Enabled then return end
    LixTechConfig.Busy = true
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        local originalSettings = {
            WalkSpeed = hum.WalkSpeed,
            JumpPower = hum.JumpPower,
            PlatformStand = hum.PlatformStand,
            AutoRotate = hum.AutoRotate
        }
        
        task.wait(LixTechConfig.Delay)
        
        if not LixTechConfig.Enabled then LixTechConfig.Busy = false return end
        
        FireDashQW()
        
        DeleteBodyVelocity()
        
        task.wait(0.3)
        
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
        end
        
        task.wait(0.4)
        
        if root then
            root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(180), 0)
        end
        
        task.wait(0.5)
        if hum then
            hum.WalkSpeed = originalSettings.WalkSpeed or 16
            hum.JumpPower = originalSettings.JumpPower or 50
            hum.PlatformStand = originalSettings.PlatformStand or false
            hum.AutoRotate = originalSettings.AutoRotate or true
        end
    end
    
    LixTechConfig.Busy = false
end

local function LixTechOnAnimation(animTrack)
    if not LixTechConfig.Enabled then return end
    local success, animId = pcall(function()
        return animTrack and animTrack.Animation and tostring(animTrack.Animation.AnimationId) or ""
    end)
    if success and animId then
        for _, id in ipairs(LixTechConfig.AnimDetectIds) do
            if animId:find(id) then
                task.spawn(LixTechExecute)
                break
            end
        end
    end
end

local function ConnectLixTech()
    if LixTechConfig.Connection then LixTechConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    LixTechConfig.Connection = hum.AnimationPlayed:Connect(LixTechOnAnimation)
end

-- ============================================
-- SUPATECH -- ============================================
local SupaLegitConfig = {
    Enabled = false,
    DashDuration = 0.15,
    FollowOffset = 2.5,
    AngleTilt = 55,
    StickRange = 18,
    AnimDetectIds = {"10503381238", "13379003796"},
    CooldownTime = 4,
    Connection = nil,
    CharConnection = nil,
    Busy = false,
    InCooldown = false,
}

local function SupaLegitFindClosestTarget()
    local _, _, myRoot = GetCharacterData()
    if not myRoot then return nil end
    
    local closestModel = nil
    local smallestDistance = SupaLegitConfig.StickRange
    
    for _, model in ipairs(Workspace:GetDescendants()) do
        if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= LocalPlayer.Character then
            local targetRoot = model:FindFirstChild("HumanoidRootPart")
            if targetRoot then
                local success, distance = pcall(function()
                    return (myRoot.Position - targetRoot.Position).Magnitude
                end)
                if success and distance and distance < smallestDistance then
                    closestModel = model
                    smallestDistance = distance
                end
            end
        end
    end
    return closestModel
end

local function SupaLegitSendDashAndRemoveVelocity()
    FireDashQW()
    
    pcall(function()
        local function findNilInstanceByNameClass(name, className)
            if type(getnilinstances) ~= "function" then return nil end
            pcall(function()
                for _, inst in ipairs(getnilinstances()) do
                    if inst.ClassName == className and inst.Name == name then
                        return inst
                    end
                end
            end)
            return nil
        end
        
        local bv = findNilInstanceByNameClass("moveme", "BodyVelocity")
        if bv then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Communicate") then
                char.Communicate:FireServer({Goal = "delete bv", BV = bv})
            end
            pcall(function() bv.Parent = nil end)
        end
    end)
end

local function SupaLegitPerformStickDash()
    local char, hum, root = GetCharacterData()
    if not (char and hum and root) then return end
    
    local targetModel = SupaLegitFindClosestTarget()
    if not targetModel then return end
    
    local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    
    local savedSettings = {
        WalkSpeed = hum.WalkSpeed,
        JumpPower = hum.JumpPower,
        PlatformStand = hum.PlatformStand,
        AutoRotate = hum.AutoRotate
    }
    
    local angleTiltRad = math.rad(SupaLegitConfig.AngleTilt)
    
    local heartbeatConnection = RunService.Heartbeat:Connect(function()
        if root then root.AssemblyLinearVelocity = Vector3.zero end
        if hum then hum.WalkSpeed = 0 end
    end)
    
    pcall(SupaLegitSendDashAndRemoveVelocity)
    
    task.wait(0.2)
    pcall(function() hum:ChangeState(Enum.HumanoidStateType.Physics) end)
    
    if root then
        root.CFrame = root.CFrame * CFrame.Angles(angleTiltRad, 0, 0)
    end
    
    local startTime = tick()
    local followConnection = RunService.Heartbeat:Connect(function()
        if SupaLegitConfig.DashDuration > (tick() - startTime) then
            if targetRoot and targetRoot.Parent and root and root.Parent then
                local dir = (targetRoot.Position - root.Position).Unit
                local newPos = targetRoot.Position - dir * SupaLegitConfig.FollowOffset
                root.CFrame = CFrame.new(newPos) * CFrame.Angles(angleTiltRad, 0, 0)
            end
        end
    end)
    
    task.wait(SupaLegitConfig.DashDuration)
    
    heartbeatConnection:Disconnect()
    followConnection:Disconnect()
    
    pcall(function()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
        hum.WalkSpeed = savedSettings.WalkSpeed or 16
        hum.JumpPower = savedSettings.JumpPower or 50
        hum.AutoRotate = savedSettings.AutoRotate or true
    end)
end

local function SupaLegitOnAnimation(animTrack)
    if not SupaLegitConfig.Enabled or SupaLegitConfig.Busy or SupaLegitConfig.InCooldown then return end
    
    local success, animId = pcall(function()
        return animTrack and animTrack.Animation and tostring(animTrack.Animation.AnimationId) or ""
    end)
    
    if success and animId then
        for _, id in ipairs(SupaLegitConfig.AnimDetectIds) do
            if animId:find(id) then
                SupaLegitConfig.InCooldown = true
                SupaLegitConfig.Busy = true
                
                task.spawn(function()
                    SupaLegitPerformStickDash()
                    SupaLegitConfig.Busy = false
                    task.wait(SupaLegitConfig.CooldownTime)
                    SupaLegitConfig.InCooldown = false
                end)
                break
            end
        end
    end
end

local function ConnectSupaLegit()
    if SupaLegitConfig.Connection then
        SupaLegitConfig.Connection:Disconnect()
        SupaLegitConfig.Connection = nil
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    SupaLegitConfig.Connection = hum.AnimationPlayed:Connect(SupaLegitOnAnimation)
end

-- ============================================
-- OREO TECH CONFIG & LOGIC (Renamed from Hexed)
-- ============================================
local OreoTechConfig = {
    Enabled = false,
    AnimDetectIds = {"10503381238", "13379003796"},
    CooldownTime = 5,
    Connection = nil,
    CanTrigger = true,
    CharConnection = nil,
}

local function OreoTechGetRootPart()
    local char = LocalPlayer.Character
    if char then
        return char:FindFirstChild("HumanoidRootPart")
    end
    return nil
end

local function OreoTechFixCameraBehind()
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum and rootPart then
        hum.AutoRotate = false
        
        local reversedCFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
        rootPart.CFrame = reversedCFrame
        
        local distance = (Camera.CFrame.Position - reversedCFrame.Position).Magnitude
        Camera.CFrame = CFrame.new(reversedCFrame.Position - reversedCFrame.LookVector * distance + Vector3.new(0, 2), reversedCFrame.Position)
    end
end

local function OreoTechJumpBoost()
    local rootPart = OreoTechGetRootPart()
    if rootPart then
        rootPart.AssemblyLinearVelocity = Vector3.new(0, 57, 0)
    end
end

local function OreoTechForwardDash()
    local rootPart = OreoTechGetRootPart()
    if rootPart then
        local forwardDirection = rootPart.CFrame.LookVector.Unit
        rootPart.CFrame = rootPart.CFrame + forwardDirection * 3.5
    end
end

local function OreoTechExecute()
    if not OreoTechConfig.Enabled or not OreoTechConfig.CanTrigger then return end
    
    OreoTechConfig.CanTrigger = false
    
    task.spawn(function()
        task.wait(0.421)
        OreoTechJumpBoost()
        
        task.wait(0.13)
        
        FireDashQW()
        
        OreoTechFixCameraBehind()
        task.wait(0.16)
        OreoTechFixCameraBehind()
        
        OreoTechForwardDash()
    end)
    
    task.delay(OreoTechConfig.CooldownTime, function()
        OreoTechConfig.CanTrigger = true
    end)
end

local function OreoTechOnAnimation(animTrack)
    if not OreoTechConfig.Enabled then return end
    
    local success, animId = pcall(function()
        return animTrack and animTrack.Animation and tostring(animTrack.Animation.AnimationId) or ""
    end)
    
    if success and animId then
        for _, id in ipairs(OreoTechConfig.AnimDetectIds) do
            if animId:find(id) then
                OreoTechExecute()
                break
            end
        end
    end
end

local function ConnectOreoTech()
    if OreoTechConfig.Connection then
        pcall(function() OreoTechConfig.Connection:Disconnect() end)
        OreoTechConfig.Connection = nil
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    
    OreoTechConfig.Connection = hum.AnimationPlayed:Connect(OreoTechOnAnimation)
end

-- ============================================
-- TWISTED REVAMP CONFIG & LOGIC
-- ============================================
local TwistedConfig = {
    Enabled = false,
    AnimDetectIds = {"13294471966", "134775406437626"},
    Connection = nil,
    Busy = false,
    AutoRotateConnection = nil,
}

local function TwistedExecute()
    if TwistedConfig.Busy or not TwistedConfig.Enabled then return end
    TwistedConfig.Busy = true
    
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        if TwistedConfig.AutoRotateConnection then
            TwistedConfig.AutoRotateConnection:Disconnect()
        end
        
        TwistedConfig.AutoRotateConnection = RunService.RenderStepped:Connect(function()
            if TwistedConfig.Enabled and hum then
                hum.AutoRotate = false
            end
        end)
        
        local rotatedCF1 = root.CFrame * CFrame.Angles(0, math.rad(-135), 0)
        local rotatedCF2 = root.CFrame * CFrame.Angles(0, math.rad(0), 0)
        
        task.wait(0.39)
        
        if not TwistedConfig.Enabled then
            if TwistedConfig.AutoRotateConnection then TwistedConfig.AutoRotateConnection:Disconnect() end
            TwistedConfig.Busy = false
            return
        end
        
        FireDashQW()
        
        if root then root.CFrame = rotatedCF1 end
        task.wait(0.125)
        if root then root.CFrame = rotatedCF2 end
        task.wait(0.8)
        
        if TwistedConfig.AutoRotateConnection then
            TwistedConfig.AutoRotateConnection:Disconnect()
            TwistedConfig.AutoRotateConnection = nil
        end
        
        if hum then hum.AutoRotate = true end
    end
    
    TwistedConfig.Busy = false
end

local function TwistedOnAnimation(animTrack)
    if not TwistedConfig.Enabled then return end
    local success, animId = pcall(function()
        return animTrack and animTrack.Animation and tostring(animTrack.Animation.AnimationId) or ""
    end)
    if success and animId then
        for _, id in ipairs(TwistedConfig.AnimDetectIds) do
            if animId:find(id) then
                task.spawn(TwistedExecute)
                break
            end
        end
    end
end

local function ConnectTwisted()
    if TwistedConfig.Connection then TwistedConfig.Connection:Disconnect() end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    TwistedConfig.Connection = hum.AnimationPlayed:Connect(TwistedOnAnimation)
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

local function KittyTechFindNearestEnemy(distance)
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
    local target = KittyTechFindNearestEnemy()
    
    if target then
        local startTime = tick()
        local spinDuration = KittyTechConfig.SpinDuration
        
        while tick() - startTime < spinDuration and KittyTechConfig.Enabled and root and root.Parent do
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
        if animId and animId:find("10503381238") then
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
-- ANTI SHAKE CONFIG & LOGIC (CHỐNG RUNG CAMERA)
-- ============================================
local AntiShakeConfig = {
    Enabled = false,
    Connection = nil,
    OriginalCFrame = nil,
}

local function StopCameraShake()
    pcall(function()
        local cameraShake = Camera:FindFirstChild("CameraShake")
        if cameraShake then
            cameraShake:Destroy()
        end
        
        for _, v in ipairs(Camera:GetDescendants()) do
            if v:IsA("LocalScript") or v:IsA("ModuleScript") then
                if v.Name:lower():find("shake") or v.Name:lower():find("camera") then
                    pcall(function() v:Disable() end)
                end
            end
        end
    end)
end

local function OnCharacterHit()
    if not AntiShakeConfig.Enabled then return end
    
    local char = LocalPlayer.Character
    if not char then return end
    
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    AntiShakeConfig.OriginalCFrame = Camera.CFrame
    
    task.spawn(function()
        local startTime = tick()
        local duration = 0.3
        
        while tick() - startTime < duration and AntiShakeConfig.Enabled do
            if AntiShakeConfig.OriginalCFrame then
                pcall(function()
                    if Camera.CFrame ~= AntiShakeConfig.OriginalCFrame then
                        Camera.CFrame = AntiShakeConfig.OriginalCFrame
                    end
                end)
            end
            StopCameraShake()
            task.wait()
        end
    end)
end

local function SetupAntiShake()
    if AntiShakeConfig.Connection then
        AntiShakeConfig.Connection:Disconnect()
        AntiShakeConfig.Connection = nil
    end
    
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    
    if humanoid then
        local lastHealth = humanoid.Health
        AntiShakeConfig.Connection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
            if AntiShakeConfig.Enabled then
                local newHealth = humanoid.Health
                if newHealth < lastHealth then
                    OnCharacterHit()
                end
                lastHealth = newHealth
            end
        end)
    end
end

-- ============================================
-- AUTO BLOCK CONFIG & LOGIC
-- ============================================
local AutoBlockConfig = {
    Enabled = false,
    M1AfterBlock = false,
    AutoCounter = false,
    BlockSpin = false,
    NormalRange = 15,
}

local DetectIDs = {
    ["10469493270"]=true,["10469630950"]=true,["10469639222"]=true,["10469643643"]=true,
    ["13532562418"]=true,["13532600125"]=true,["13532604085"]=true,["13294471966"]=true,
    ["13491635433"]=true,["13296577783"]=true,["13295919399"]=true,["13295936866"]=true,
    ["13370310513"]=true,["13390230973"]=true,["13378751717"]=true,["13378708199"]=true,
    ["14004222985"]=true,["13997092940"]=true,["14001963401"]=true,["14136436157"]=true,
    ["15271263467"]=true,["15240216931"]=true,["15240176873"]=true,["15162694192"]=true,
    ["16515503507"]=true,["16515520431"]=true,["16515448089"]=true,["16552234590"]=true,
    ["17889458563"]=true,["17889461810"]=true,["17889471098"]=true,["17889290569"]=true,
    ["123005629431309"]=true,["100059874351664"]=true,["104895379416342"]=true,["134775406437626"]=true,["15259161390"]=true
}

local SkillSpecialConfig = {
    ["10479335397"] = {range = 50, delay = 0.79},
    ["13380255751"] = {range = 50, delay = 0.79},
    ["10468665991"] = {range = 50, delay = 0.7},
    ["10466974800"] = {range = 18, delay = 1.29},
    ["12272894215"] = {range = 12, delay = 0.55},
    ["12296882427"] = {range = 12, delay = 0.55},
    ["12509505723"] = {range = 30, delay = 0.7},
    ["12534735382"] = {range = 18, delay = 1.29},
    ["12684390285"] = {range = 50, delay = 1.8},
    ["13294790250"] = {range = 50, delay = 0.55},
    ["13376869471"] = {range = 50, delay = 0.8},
    ["13376962659"] = {range = 70, delay = 2.5},
    ["14046756619"] = {range = 50, delay = 0.5},
    ["15290930205"] = {range = 25, delay = 1.27},
    ["15295895753"] = {range = 20, delay = 0.8},
    ["15295336270"] = {range = 30, delay = 1},
    ["16139108718"] = {range = 60, delay = 0.8},
    ["16515850153"] = {range = 30, delay = 3},
    ["16431491215"] = {range = 25, delay = 1.7},
    ["17799224866"] = {range = 15, delay = 1.25},
    ["17857788598"] = {range = 17, delay = 1.1},
    ["18179181663"] = {range = 10, delay = 0.66},
    ["77509627104305"] = {range = 50, delay = 3},
    ["131820095363270"] = {range = 100, delay = 2},
}

local CounterDetectIDs = {
    ["10479335397"] = true,
    ["13380255751"] = true,
    ["13813955149"] = true
}

local AutoBlockState = {
    detecting = false,
    shortRange = false,
    connection = nil,
    lastDetected = {},
    LastVelocity = {},
    LastPredict = {},
    autoCounter = false,
    spinToggle = false,
}

local CounterTracking = {}
local CounterDetectRange = 35
local CounterUseRange = 15
local PredictThreshold = 35
local PredictCooldown = 0.01

local function AutoBlockAction(distance, delayTime)
    local char = LocalPlayer.Character
    if not char then return end
    
    local comm = char:FindFirstChild("Communicate")
    if not comm then return end
    
    local args1 = {{Goal="KeyPress", Key=Enum.KeyCode.F}}
    comm:FireServer(unpack(args1))
    task.wait(delayTime)
    local args2 = {{Goal="KeyRelease", Key=Enum.KeyCode.F}}
    comm:FireServer(unpack(args2))

    if AutoBlockConfig.M1AfterBlock and distance <= 15 then
        local args3 = {{Goal="LeftClick", Mobile=true}}
        comm:FireServer(unpack(args3))
        task.wait(0.3)
        local args4 = {{Goal="LeftClickRelease", Mobile=true}}
        comm:FireServer(unpack(args4))
    end
end

local function AutoBlockSpamReleases()
    local char = LocalPlayer.Character
    if not char then return end
    
    local comm = char:FindFirstChild("Communicate")
    if not comm then return end
    
    for i = 1, 5 do
        comm:FireServer({{Goal="KeyRelease",Key=Enum.KeyCode.F}})
        comm:FireServer({{Goal="LeftClickRelease",Mobile=true}})
        task.wait(0.01)
    end
end

local function AutoBlockIsInFront(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local root = char.HumanoidRootPart
    return root.CFrame.LookVector:Dot((targetPos - root.Position).Unit) > 0
end

local function AutoBlockPredictIncoming(model, distance)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local now = tick()
    if AutoBlockState.LastPredict[model] and now - AutoBlockState.LastPredict[model] < PredictCooldown then
        return false
    end

    local lastV = AutoBlockState.LastVelocity[model]
    local currentV = hrp.Velocity.Magnitude
    AutoBlockState.LastVelocity[model] = currentV

    if lastV and (currentV - lastV) >= PredictThreshold then
        AutoBlockState.LastPredict[model] = now
        return true
    end

    local char = LocalPlayer.Character
    if model.PrimaryPart and char and char:FindFirstChild("HumanoidRootPart") then
        local dot = model.PrimaryPart.CFrame.LookVector:Dot(
            (char.HumanoidRootPart.Position - model.PrimaryPart.Position).Unit
        )
        if dot > 0.75 and distance <= 55 then
            AutoBlockState.LastPredict[model] = now
            return true
        end
    end

    return false
end

local function AutoBlockUsePreyPeril()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local tool = backpack:FindFirstChild("Prey's Peril")
    if not tool then return end

    local args = {{
        Tool = tool,
        Goal = "Console Move"
    }}

    local char = LocalPlayer.Character
    if char then
        local comm = char:FindFirstChild("Communicate")
        if comm then
            comm:FireServer(unpack(args))
        end
    end
end

local function AutoBlockUseSplitSecondCounter()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    local tool = backpack:FindFirstChild("Split Second Counter")
    if not tool then return end

    local args = {{
        Tool = tool,
        Goal = "Console Move"
    }}

    local char = LocalPlayer.Character
    if char then
        local comm = char:FindFirstChild("Communicate")
        if comm then
            comm:FireServer(unpack(args))
        end
    end
end

local function AutoBlockPredictCounter(model)
    local hrp = model:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end

    local lastV = AutoBlockState.LastVelocity[model] or 0
    local curV = hrp.Velocity.Magnitude
    AutoBlockState.LastVelocity[model] = curV
    if (curV - lastV) > 30 then
        return true
    end

    local char = LocalPlayer.Character
    if model.PrimaryPart and char and char:FindFirstChild("HumanoidRootPart") then
        local dot = model.PrimaryPart.CFrame.LookVector:Dot(
            (char.HumanoidRootPart.Position - model.PrimaryPart.Position).Unit
        )
        if dot > 0.9 then
            return true
        end
    end

    return false
end

local function AutoBlockStartDetect()
    if AutoBlockState.connection then
        AutoBlockState.connection:Disconnect()
    end
    
    AutoBlockState.connection = RunService.RenderStepped:Connect(function()
        if not AutoBlockConfig.Enabled then return end
        
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end
        local rootPos = char.HumanoidRootPart.Position
        local liveFolder = Workspace:FindFirstChild("Live")
        if not liveFolder then return end

        for _, model in pairs(liveFolder:GetChildren()) do
            if model:IsA("Model") and model ~= char then
                local humanoid = model:FindFirstChildOfClass("Humanoid")
                local hrp = model:FindFirstChild("HumanoidRootPart")
                if humanoid and hrp and humanoid:FindFirstChild("Animator") then
                    local distance = (hrp.Position - rootPos).Magnitude
                    local tracks = humanoid.Animator:GetPlayingAnimationTracks()
                    local foundAnim = false
                    
                    for _, track in pairs(tracks) do
                        local animId = track.Animation.AnimationId:match("%d+")
                        if animId then
                            if AutoBlockConfig.AutoCounter
                            and AutoBlockConfig.Enabled
                            and CounterDetectIDs[animId]
                            and distance <= CounterDetectRange then
                                CounterTracking[model] = true
                            end
                            if AutoBlockConfig.AutoCounter
                            and AutoBlockConfig.Enabled
                            and CounterTracking[model]
                            and distance <= CounterUseRange then
                                if AutoBlockPredictCounter(model) or track.TimePosition <= 0.15 then
                                    AutoBlockUsePreyPeril()
                                    task.wait(0.05)
                                    AutoBlockUseSplitSecondCounter()
                                    CounterTracking[model] = nil
                                end
                            end
                            
                            local predicted = AutoBlockPredictIncoming(model, distance)
                            if DetectIDs[animId]
                            and distance <= AutoBlockConfig.NormalRange
                            and (track.TimePosition <= 0.08 or predicted) then
                                AutoBlockAction(distance, 0.2)
                                foundAnim = true
                                break
                            end
                            
                            local cfg = SkillSpecialConfig[animId]
                            if cfg
                            and distance <= cfg.range
                            and (track.TimePosition <= 0.08 or predicted) then
                                AutoBlockAction(distance, cfg.delay)
                                foundAnim = true
                                break
                            end
                        end
                    end

                    if not foundAnim and AutoBlockState.lastDetected[model] then
                        AutoBlockSpamReleases()
                        AutoBlockState.lastDetected[model] = nil
                    elseif foundAnim then
                        AutoBlockState.lastDetected[model] = true
                    end
                end
            end
        end
    end)
end

local function AutoBlockStopDetect()
    if AutoBlockState.connection then
        AutoBlockState.connection:Disconnect()
        AutoBlockState.connection = nil
    end
end

local BlockSpinAnimId = "10470389827"
local BlockSpinConnection = nil

local function IsBlockSpinAnimPlaying()
    local char = LocalPlayer.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid or not humanoid.Animator then return false end
    
    for _, track in pairs(humanoid.Animator:GetPlayingAnimationTracks()) do
        if track.Animation and track.Animation.AnimationId == "rbxassetid://" .. BlockSpinAnimId then
            return true
        end
    end
    return false
end

local function SetupBlockSpin()
    if BlockSpinConnection then
        BlockSpinConnection:Disconnect()
        BlockSpinConnection = nil
    end
    
    BlockSpinConnection = RunService.RenderStepped:Connect(function(dt)
        if not AutoBlockConfig.BlockSpin or not AutoBlockConfig.Enabled then 
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum.AutoRotate = true end
            end
            return 
        end
        
        local char = LocalPlayer.Character
        if not char then return end
        
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChildOfClass("Humanoid")
        
        if not hrp or not hum then return end

        if IsBlockSpinAnimPlaying() then
            hum.AutoRotate = false
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, dt * 4 * math.pi, 0)
        else
            hum.AutoRotate = true
        end
    end)
end

-- ============================================
-- NO COOLDOWN DASH (Misc and Visual Tab)
-- ============================================
local NoCooldownDashConfig = {
    Enabled = false
}

local function SetupNoCooldownDash()
    if NoCooldownDashConfig.Enabled then
        workspace:SetAttribute('EffectAffects', 1)
        workspace:SetAttribute('NoDashCooldown', 0)
    else
        workspace:SetAttribute('EffectAffects', 0)
        workspace:SetAttribute('NoDashCooldown', 1)
    end
end

-- ============================================
-- EMOTE LIMITED FUNCTIONS (From file 2 and file 3)
-- ============================================

-- Eternal Seal Emote (from file 3)
local function PlayEternalSeal()
    task.spawn(function()
        local _LocalPlayer3 = game:GetService('Players').LocalPlayer
        local v252 = _LocalPlayer3.Character or _LocalPlayer3.CharacterAdded:Wait()
        local _Humanoid3 = v252:WaitForChild('Humanoid')
        local _Animation11 = Instance.new('Animation')

        _Animation11.AnimationId = 'rbxassetid://100255267749203'

        _Humanoid3:LoadAnimation(_Animation11):Play()

        local _Sound9 = Instance.new('Sound')

        _Sound9.SoundId = 'rbxassetid://79605009444651'
        _Sound9.Volume = 0
        _Sound9.Parent = v252:FindFirstChild('HumanoidRootPart') or v252.PrimaryPart

        _Sound9:Play()

        local _Folder8 = Instance.new('Folder')

        _Folder8.Name = 'RuthlessBind'
        _Folder8.Parent = v252

        _Folder8:SetAttribute('EmoteProperty', true)
        require(game.ReplicatedStorage.Emotes.VFX):MainFunction({
            Character = v252,
            vfxName = 'Eternal Seal',
            SpecificModule = game.ReplicatedStorage.Emotes.VFX,
            AnimSent = 100255267749203,
            RealBind = _Folder8,
        })
    end)

    local _LocalPlayer4 = game.Players.LocalPlayer
    local _HumanoidRootPart = (_LocalPlayer4.Character or _LocalPlayer4.CharacterAdded:Wait()):WaitForChild('HumanoidRootPart')
    local v259 = {
        SoundId = 'rbxassetid://79605009444651',
        ParentTorso = true,
        Volume = 2,
    }
    local _Sound10 = Instance.new('Sound')

    _Sound10.SoundId = v259.SoundId
    _Sound10.Volume = v259.Volume
    _Sound10.Parent = v259.ParentTorso and _HumanoidRootPart and _HumanoidRootPart or workspace

    _Sound10:Play()

    local _TweenService3 = game:GetService('TweenService')
    local _CollectionService2 = game:GetService('CollectionService')
    local _ReplicatedStorage5 = game:GetService('ReplicatedStorage')
    local _Players6 = game:GetService('Players')
    local _Workspace2 = game:GetService('Workspace')
    local _LocalPlayer5 = _Players6.LocalPlayer
    local u267 = _LocalPlayer5.Character or _LocalPlayer5.CharacterAdded:Wait()
    local u268 = _Workspace2:FindFirstChild('Thrown') or Instance.new('Folder', _Workspace2)

    u268.Name = 'Thrown'

    local u269 = {}

    local function v271(p270)
        p270:SetAttribute('EmoteProperty', true)
        table.insert(u269, p270)
        _CollectionService2:AddTag(p270, 'emoteendstuff' .. u267.Name)

        p270.Parent = u268
    end

    local u272 = _ReplicatedStorage5.Emotes.PrisonRealmRig:Clone()
    local u273 = _ReplicatedStorage5.Emotes.RealmPrism:Clone()
    local v274 = _ReplicatedStorage5.Emotes.Strings:Clone()

    v271(u272)
    v271(u273)
    v271(v274)

    local v275, v276, v277 = pairs({
        u272,
        u273,
        unpack(v274:GetChildren()),
    })
    local u278 = u269

    while true do
        local v279

        v277, v279 = v275(v276, v277)

        if v277 == nil then
            break
        end

        v279.PrimaryPart.Anchored = false

        local _Weld5 = Instance.new('Weld')

        _Weld5.Part0 = u267.PrimaryPart
        _Weld5.Part1 = v279.PrimaryPart
        _Weld5.C0 = v279:GetAttribute('Offset')
        _Weld5.Parent = v279.PrimaryPart
    end

    local _Sound11 = Instance.new('Sound')

    _Sound11.SoundId = 'rbxassetid://116434570262349'
    _Sound11.Volume = 2
    _Sound11.Parent = u272:FindFirstChild('Bone_L', true)

    _Sound11:Play()

    local function v286(p282, p283)
        local _Animation12 = Instance.new('Animation')

        _Animation12.AnimationId = 'rbxassetid://' .. p283

        local v285 = p282:FindFirstChild('AnimationController') and p282.AnimationController:LoadAnimation(_Animation12) or p282:FindFirstChildOfClass('Humanoid'):LoadAnimation(_Animation12)

        v285:Play()
        table.insert(u278, v285)
    end

    v286(u272, 132931842051377)
    v286(u273, 73313263538976)

    local v287, v288, v289 = pairs({
        115400109213203,
        129152881643120,
        116148929833466,
        106613129685108,
        85535076926939,
        136688312702757,
    })

    while true do
        local v290

        v289, v290 = v287(v288, v289)

        if v289 == nil then
            break
        end

        v286(v274['String' .. v289], v290)
    end

    local v291 = {
        u272.Cube_2,
        u272.Cube_finals,
        u272.OPEN,
        u272.CIRCLE_001,
        u272.Sphere_001,
        u273.RealmPrismPart,
        v274.String4.Eye_014,
        v274.String2.Cube_001,
        v274.String6.Cube_001,
        v274.String6.Eye_014,
        v274.String1.Eye_014,
        v274.String3.Cube_001,
        v274.String1.Cube_001,
        v274.String2.Eye_014,
        v274.String3.Eye_014,
        v274.String4.Cube_001,
        v274.String5.Cube_001,
        v274.String5.Eye_014,
        u272.Talismanmesh,
    }
    local v292, v293, v294 = pairs(v291)

    while true do
        local v295, v296 = v292(v293, v294)

        if v295 == nil then
            break
        end

        v294 = v295

        if v296 then
            v296.Transparency = 1

            if v296:IsA('BasePart') then
                v296.Size = Vector3.new(0.01, 0.01, 0.01)
            end
        end
    end

    task.delay(3.667, function()
        if u272.Parent then
            u272.RootPart.PrismRootPart.Talisman.ParticleEmitter:Emit(1)
        end
    end)

    local function u300(p297, p298, p299)
        _TweenService3:Create(p297, p299 or TweenInfo.new(0.016, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), p298):Play()
    end

    task.delay(9.15, function()
        u300(u273.RealmPrismPart, {Transparency = 0})
    end)
    task.delay(9.166, function()
        u300(u273.RealmPrismPart, {
            Size = Vector3.new(3.34, 3.31, 3.32),
        })
    end)
    task.delay(9.183, function()
        u300(u273.RealmPrismPart, {
            Size = Vector3.new(1.67, 1.66, 1.66),
        }, TweenInfo.new(0.05))
    end)
    task.delay(9.233, function()
        u300(u273.RealmPrismPart, {
            Size = Vector3.new(1.06, 2, 1.057),
        }, TweenInfo.new(0.116))
    end)
    task.delay(9.35, function()
        u300(u273.RealmPrismPart, {
            Size = Vector3.new(0.5, 0.5, 0.5),
        }, TweenInfo.new(0.283))
    end)
    task.delay(9.633, function()
        u300(u273.RealmPrismPart, {Transparency = 0}, TweenInfo.new(3.65))
    end)
    task.delay(13.283, function()
        u300(u273.RealmPrismPart, {Transparency = 1})
    end)

    local v301 = {
        v274.String1.Eye_014,
        v274.String2.Cube_001,
        v274.String3.Eye_014,
        v274.String6.Cube_001,
        v274.String5.Eye_014,
        v274.String5.Cube_001,
        v274.String4.Eye_014,
        v274.String1.Cube_001,
        v274.String2.Eye_014,
        v274.String3.Cube_001,
        v274.String4.Cube_001,
        v274.String6.Eye_014,
    }
    local v302, v303, v304 = pairs(v301)
    local u305 = u300

    while true do
        local u306

        v304, u306 = v302(v303, v304)

        if v304 == nil then
            break
        end

        task.delay(6.85, function()
            u305(u306, {
                Transparency = 0,
                Size = Vector3.new(0.01, 0.01, 0.01),
            })
        end)
        task.delay(6.866, function()
            u305(u306, {
                Size = Vector3.new(1.71, 1.69, 1.69),
            }, TweenInfo.new(0.316))
        end)
        task.delay(7.183, function()
            u305(u306, {
                Size = Vector3.new(1.71, 1.69, 1.69),
            }, TweenInfo.new(1.916))
        end)
        task.delay(9.1, function()
            u305(u306, {Transparency = 0}, TweenInfo.new(0.116))
        end)
        task.delay(9.216, function()
            u305(u306, {
                Transparency = 1,
                Size = Vector3.new(0.01, 0.01, 0.01),
            })
        end)
    end

    local u307 = {
        u272.OPEN,
        u272.Cube_finals,
        u272.Cube_2,
        u272.Sphere_001,
        u272.CIRCLE_001,
    }

    task.delay(0.4, function()
        local v308, v309, v310 = pairs(u307)

        while true do
            local v311

            v310, v311 = v308(v309, v310)

            if v310 == nil then
                break
            end

            u305(v311, {Transparency = 0})
        end
    end)
    task.delay(0.416, function()
        u305(u272.OPEN, {
            Size = Vector3.new(1.176, 1.181, 0.518),
        }, TweenInfo.new(4.133))
        u305(u272.Cube_finals, {
            Size = Vector3.new(1.568, 1.568, 0.41),
        }, TweenInfo.new(4.133))
        u305(u272.Cube_2, {
            Size = Vector3.new(1.568, 1.568, 0.661),
        }, TweenInfo.new(4.133))
        u305(u272.Sphere_001, {
            Size = Vector3.new(0.549, 0.549, 0.549),
        }, TweenInfo.new(4.133))
        u305(u272.CIRCLE_001, {
            Size = Vector3.new(0.489, 0.439, 0.201),
        }, TweenInfo.new(4.133))
    end)
    task.delay(4.55, function()
        u305(u272.Talismanmesh, {Transparency = 1})
        u305(u272.OPEN, {
            Size = Vector3.new(7.461, 7.494, 2.774),
        }, TweenInfo.new(0.316))
        u305(u272.Cube_finals, {
            Size = Vector3.new(10.256, 10.256, 2),
        }, TweenInfo.new(0.316))
        u305(u272.Cube_2, {
            Size = Vector3.new(10.256, 10.256, 3.788),
        }, TweenInfo.new(0.316))
        u305(u272.Sphere_001, {
            Size = Vector3.new(2.997, 2.997, 2.997),
        }, TweenInfo.new(0.316))
        u305(u272.CIRCLE_001, {
            Size = Vector3.new(2.565, 2.211, 0.513),
        }, TweenInfo.new(0.316))
        wait(2.2)
        u272:Destroy()
    end)

    local _Players7 = game:GetService('Players')
    local _RunService = game:GetService('RunService')
    local _LocalPlayer6 = _Players7.LocalPlayer
    local u315 = _LocalPlayer6.Character or _LocalPlayer6.CharacterAdded:Wait()

    local function u321(p316)
        local v317, v318, v319 = pairs(p316:GetDescendants())

        while true do
            local v320

            v319, v320 = v317(v318, v319)

            if v319 == nil then
                break
            end
            if v320:IsA('BasePart') and v320.Anchored then
                v320.Anchored = false
            end
        end
    end

    _RunService.RenderStepped:Connect(function()
        if u315 and u315.Parent then
            u321(u315)
        end
    end)
end

-- Other Emotes
local function PlayFinalStand()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://113876851900426"
    local track = humanoid:LoadAnimation(anim)
    track:Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 100000)
        acc.Parent = character
        acc:SetAttribute("EmoteProperty", true)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Final Stand",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 113876851900426,
                RealBind = acc,
            })
        end)
    end)

    task.delay(9, function()
        if not character or not character.Parent then return end
        
        local soundIds = {"112446641141594", "98080224862986"}
        for _, id in ipairs(soundIds) do
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. id
            s.Volume = 1
            s.Looped = true
            s.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
            if s.Parent then
                s:Play()
                Debris:AddItem(s, 60)
            end
        end

        local auraClone = ReplicatedStorage:FindFirstChild("Emotes") and 
                         ReplicatedStorage.Emotes:FindFirstChild("VFX") and
                         ReplicatedStorage.Emotes.VFX:FindFirstChild("VfxMods") and
                         ReplicatedStorage.Emotes.VFX.VfxMods:FindFirstChild("FS") and
                         ReplicatedStorage.Emotes.VFX.VfxMods.FS:FindFirstChild("vfx") and
                         ReplicatedStorage.Emotes.VFX.VfxMods.FS.vfx:FindFirstChild("Aura")
        
        if auraClone then
            auraClone = auraClone:Clone()
            for _, part in pairs(auraClone:GetChildren()) do
                local targetPart = character:FindFirstChild(part.Name)
                if not targetPart and part.Name == "HumanoidRootPart" then
                    targetPart = character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
                end
                
                if targetPart then
                    for _, fx in pairs(part:GetChildren()) do
                        if fx:IsA("ParticleEmitter") then
                            fx.LockedToPart = true
                            fx.Parent = targetPart
                            fx:SetAttribute("LimitedAura", true)
                            Debris:AddItem(fx, 65)
                        end
                    end
                end
            end
            auraClone:Destroy()
        end
    end)
end

local function PlayInnerRage()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local color = Color3.fromRGB(math.random(100, 255), math.random(50, 150), math.random(50, 150))

    local anim1 = Instance.new("Animation")
    anim1.AnimationId = "rbxassetid://96993907314948"
    local track1 = humanoid:LoadAnimation(anim1)
    track1:Play()

    track1.Stopped:Connect(function()
        local anim2 = Instance.new("Animation")
        anim2.AnimationId = "rbxassetid://127234845846317"
        humanoid:LoadAnimation(anim2):Play()
    end)

    local holder = Instance.new("Accessory")
    holder.Name = "#EmoteHolder_" .. math.random(1, 100000)
    holder.Parent = character
    CollectionService:AddTag(holder, "emoteendstuff" .. character.Name)

    task.delay(0.1, function()
        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Energy Explosion",
                AnimSent = 96993907314948,
                RealBind = holder,
                NoInsertion = true,
                Colour = color,
            })
        end)
    end)

    task.delay(5.3, function()
        if not holder.Parent then return end
        
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation.AnimationId == "rbxassetid://127234845846317" then
                track:Stop()
                local anim3 = Instance.new("Animation")
                anim3.AnimationId = "rbxassetid://117177504280717"
                humanoid:LoadAnimation(anim3):Play()
            end
        end
    end)
end

local function PlayShadowEruption()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://117425361961655"
    sound.Volume = 1
    sound.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
    if sound.Parent then
        sound:Play()
        Debris:AddItem(sound, 10)
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://121032789756540"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 100000)
        acc.Parent = character
        acc:SetAttribute("EmoteProperty", true)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Shadow Eruption",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 121032789756540,
                RealBind = acc,
            })
        end)
    end)

    task.delay(8.1, function()
        if not character or not character.Parent then return end
        
        local loopSound = Instance.new("Sound")
        loopSound.SoundId = "rbxassetid://128082194939921"
        loopSound.Looped = true
        loopSound.Volume = 1
        loopSound.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
        if loopSound.Parent then
            loopSound:Play()
            Debris:AddItem(loopSound, 60)
        end
    end)
end

local function PlayDivineForm()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://116187503451999"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 100000)
        acc.Parent = character
        acc:SetAttribute("EmoteProperty", true)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Divine Form",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 116187503451999,
                RealBind = acc,
            })
        end)
    end)
end

local function PlayTheStrongest()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local soundData = {
        {id = "117787451950766", delay = 0, volume = 2},
        {id = "97998065677521", delay = 0.01, volume = 1.85},
        {id = "99535007576182", delay = 2.29, volume = 2, looped = true},
    }

    for _, data in ipairs(soundData) do
        task.delay(data.delay, function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. data.id
            sound.Volume = data.volume
            sound.Looped = data.looped or false
            sound.Parent = workspace
            sound:Play()
            if not data.looped then
                Debris:AddItem(sound, 10)
            end
        end)
    end

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://86505219150915"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local bind = Instance.new("Folder")
        bind.Name = "PrideBind"
        bind.Parent = character
        bind:SetAttribute("EmoteProperty", true)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Boss Raid",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 86505219150915,
                RealBind = bind,
            })
        end)
    end)
end

local function PlayBoundlessRage()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://107649573628906"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 100000)
        acc.Parent = character
        acc:SetAttribute("EmoteProperty", true)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Boundless Rage",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 107649573628906,
                RealBind = acc,
            })
        end)
    end)

    task.delay(4, function()
        if not character or not character.Parent then return end
        
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://81055990581650"
        sound.Looped = true
        sound.Volume = 1
        sound.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        if sound.Parent then
            sound:Play()
            Debris:AddItem(sound, 60)
        end
    end)
end

local function PlayTheFallen()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://133818134745501"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        if not character or not character.Parent then return end

        local old = character:FindFirstChild("DismantleEffect")
        if old then old:Destroy() end

        local acc = Instance.new("Accessory")
        acc.Name = "DismantleEffect"
        acc.Parent = character
        acc:SetAttribute("EmoteEffect", true)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Pride",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 133818134745501,
                RealBind = acc,
                CanRotate = true,
            })
        end)

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://93369149563360"
        sound.Volume = 2
        sound.Parent = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")
        if sound.Parent then
            sound:Play()
            Debris:AddItem(sound, 10)
        end
    end)
end

local function PlayTrueAura()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://103668868712897"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        if not character or not character.Parent then return end

        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 100000)
        acc.Parent = character
        CollectionService:AddTag(acc, "emoteendstuff" .. character.Name)

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "True Aura",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 103668868712897,
                RealBind = acc,
            })
        end)

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://83049960731792"
        sound.Volume = 3
        sound.Parent = character:FindFirstChild("Torso") or character:FindFirstChild("HumanoidRootPart")
        if sound.Parent then
            sound:Play()
            Debris:AddItem(sound, 10)
        end
    end)
end

local function PlayWorldCuttingSlash()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://120001337057214"
    local track = humanoid:LoadAnimation(anim)
    track:Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 99999)
        acc:SetAttribute("EmoteProperty", true)
        acc.Parent = character

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "HugeSlash",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 120001337057214,
                RealBind = acc,
                CanRotate = true,
            })
        end)

        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://103835306879590"
        sound.Volume = 3
        sound.Parent = character:FindFirstChild("Torso") or character.PrimaryPart
        if sound.Parent then
            sound:Play()
            Debris:AddItem(sound, 10)
        end
    end)
end

local function PlayMyBrother()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

    local Replication = ReplicatedStorage:FindFirstChild("Replication")
    if not Replication then
        warn("Replication not found")
        return
    end

    local function GetRandomFriend()
        local success, pages = pcall(function()
            return Players:GetFriendsAsync(LocalPlayer.UserId)
        end)

        if not success or not pages then
            warn("Failed to fetch friends list")
            return nil
        end

        local allFriends = {}

        repeat
            for _, friend in ipairs(pages:GetCurrentPage()) do
                table.insert(allFriends, friend)
            end

            if pages.IsFinished then
                break
            end

            pages:AdvanceToNextPageAsync()
        until false

        if #allFriends == 0 then
            warn("No friends found!")
            return nil
        end

        local randomFriend = allFriends[math.random(1, #allFriends)]
        return randomFriend.Id
    end

    local targetId = GetRandomFriend()
    if not targetId then
        return
    end

    local RockTemplate = ReplicatedStorage:FindFirstChild("Emotes") and
                         ReplicatedStorage.Emotes:FindFirstChild("RockThrow")

    if not RockTemplate then
        warn("RockThrow not found")
        return
    end

    local Rock = RockTemplate:Clone()
    Rock:SetAttribute("EmoteProperty", true)
    Rock.Name = "Rock"
    Rock.Parent = character

    local weld = Rock:WaitForChild("Rock", 2)
    if weld and character.PrimaryPart then
        weld:SetAttribute("EmoteProperty", true)
        weld.Part0 = character.PrimaryPart
        weld.Part1 = Rock
        weld.Parent = character.PrimaryPart
    end

    task.delay(0.573,function()
        if Rock and Rock.Parent then
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://91571189388577"
            sound.Volume = 1
            sound.RollOffMaxDistance = 100
            sound.Parent = Rock
            sound:Play()
        end
    end)

    local Humanoid = character:FindFirstChildOfClass("Humanoid")
    if Humanoid then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://123464270068243"
        Humanoid:LoadAnimation(anim):Play()
    end

    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        local s1 = Instance.new("Sound")
        s1.SoundId = "rbxassetid://104813362309681"
        s1.Volume = 1
        s1.Parent = torso
        s1:Play()

        task.delay(0.01,function()
            local s2 = Instance.new("Sound")
            s2.SoundId = "rbxassetid://103206475338370"
            s2.Volume = 0.8
            s2.Parent = torso
            s2:Play()
        end)
    end

    task.wait(2.4)

    for _,conn in pairs(getconnections(Replication.OnClientEvent)) do
        if conn.Function then
            pcall(function()
                conn.Function({
                    Effect = "Best Brother",
                    char = character,
                    Id = targetId,
                })
            end)
        end
    end

    if Rock then
        Rock.Transparency = 1
    end
end

local function PlayFinalSpark()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://129361308786827"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 99999)
        acc:SetAttribute("EmoteProperty", true)
        acc.Parent = character

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Final Spark",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 129361308786827,
                RealBind = acc,
            })
        end)
    end)
end

local function PlayLastWill()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://113450724032380"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 99999)
        acc:SetAttribute("EmoteProperty", true)
        acc.Parent = character

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "Last Will",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 113450724032380,
                RealBind = acc,
            })
        end)
    end)
end

local function PlayTheFallenFinisher()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    local torso = character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if torso then
        local sound1 = Instance.new("Sound")
        sound1.SoundId = "rbxassetid://113267998039039"
        sound1.Volume = 1.65
        sound1.Parent = torso
        sound1:Play()
        Debris:AddItem(sound1, 10)
    end

    local sound2 = Instance.new("Sound")
    sound2.SoundId = "rbxassetid://87401852788032"
    sound2.Volume = 1
    sound2.Parent = workspace
    sound2:Play()
    Debris:AddItem(sound2, 10)

    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://95171537920426"
    humanoid:LoadAnimation(anim):Play()

    task.delay(0.1, function()
        local acc = Instance.new("Accessory")
        acc.Name = "#EmoteHolder_" .. math.random(1, 99999)
        acc:SetAttribute("EmoteProperty", true)
        acc.Parent = character

        pcall(function()
            require(ReplicatedStorage.Emotes.VFX):MainFunction({
                Character = character,
                vfxName = "slice combo",
                SpecificModule = ReplicatedStorage.Emotes.VFX,
                AnimSent = 95171537920426,
                RealBind = acc,
            })
        end)
    end)
end


-- ============================================
-- WINDUI WINDOW SETUP
-- ============================================
if not WindUI then
    -- Create simple GUI if WindUI fails
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YumeXHub_Fallback"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 350, 0, 500)
    frame.Position = UDim2.new(0.5, -175, 0.5, -250)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    frame.BorderSizePixel = 0
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
    frame.Parent = screenGui
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.Text = "YumeX Hub"
    title.TextColor3 = Color3.fromRGB(255, 105, 180)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 20
    title.BackgroundTransparency = 1
    title.Parent = frame
    
    local msg = Instance.new("TextLabel")
    msg.Size = UDim2.new(1, 0, 0, 60)
    msg.Position = UDim2.new(0, 0, 0, 50)
    msg.Text = "WindUI failed to load\nBut scripts are still running!"
    msg.TextColor3 = Color3.fromRGB(255, 255, 255)
    msg.Font = Enum.Font.GothamMedium
    msg.TextSize = 14
    msg.TextWrapped = true
    msg.BackgroundTransparency = 1
    msg.Parent = frame
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 100, 0, 30)
    closeBtn.Position = UDim2.new(0.5, -50, 1, -45)
    closeBtn.Text = "OK"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 105, 180)
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
else
    local Window = WindUI:CreateWindow({
        Title = "YumeX Hub",
        Author = "By ThanhDuy",
        Icon = "rbxassetid://82479272894058",
        Icon_Color = PINK,
        Folder = "YumeXHubScripts",
        Size = UDim2.fromOffset(520, 420),
        MinSize = Vector2.new(480, 380),
        MaxSize = Vector2.new(720, 560),
        Resizable = true,
    })
    
    -- ============================================
    -- ANTI SHAKE TAB (FIRST TAB)
    -- ============================================
    local AntiShakeTab = Window:Tab({
        Title = "Anti Shake",
        Icon = "shield",
        IconColor = PINK,
    })
    
    AntiShakeTab:Section({
        Title = "Anti Shake Settings",
        Icon = "settings",
    })
    
    AntiShakeTab:Paragraph({
        Title = "Thông Tin",
        Content = "Chống rung camera khi bị đánh trúng. Giúp bạn giữ tầm nhìn ổn định.",
    })
    
    AntiShakeTab:Toggle({
        Title = "Enable Anti Shake",
        Value = false,
        Icon = "power",
        Color = PINK,
        Callback = function(state)
            if AntiShakeConfig.Enabled == state then return end
            AntiShakeConfig.Enabled = state
            if state then
                SetupAntiShake()
            else
                if AntiShakeConfig.Connection then
                    AntiShakeConfig.Connection:Disconnect()
                    AntiShakeConfig.Connection = nil
                end
            end
        end
    })
    
    -- ============================================
    -- AUTO BLOCK TAB
    -- ============================================
    local AutoBlockTab = Window:Tab({
        Title = "Auto Block",
        Icon = "shield",
        IconColor = PINK,
    })
    
    AutoBlockTab:Section({
        Title = "Auto Block Settings",
        Icon = "settings",
    })
    
    AutoBlockTab:Toggle({
        Title = "Enable Auto Block",
        Value = false,
        Icon = "power",
        Color = PINK,
        Callback = function(state)
            AutoBlockConfig.Enabled = state
            if state then
                AutoBlockStartDetect()
                if AutoBlockConfig.BlockSpin then
                    SetupBlockSpin()
                end
            else
                AutoBlockStopDetect()
                if BlockSpinConnection then
                    BlockSpinConnection:Disconnect()
                    BlockSpinConnection = nil
                end
                local _, hum = GetCharacterData()
                if hum then hum.AutoRotate = true end
            end
        end
    })
    
    AutoBlockTab:Toggle({
        Title = "M1 After Block",
        Value = false,
        Icon = "sword",
        Color = PINK,
        Callback = function(state)
            AutoBlockConfig.M1AfterBlock = state
        end
    })
    
    AutoBlockTab:Toggle({
        Title = "Auto Counter (Dash/Trash)",
        Value = false,
        Icon = "refresh-cw",
        Color = PINK,
        Callback = function(state)
            AutoBlockConfig.AutoCounter = state
        end
    })
    
    AutoBlockTab:Toggle({
        Title = "Block Spin",
        Value = false,
        Icon = "rotate-cw",
        Color = PINK,
        Callback = function(state)
            AutoBlockConfig.BlockSpin = state
            if AutoBlockConfig.Enabled then
                if state then
                    SetupBlockSpin()
                else
                    if BlockSpinConnection then
                        BlockSpinConnection:Disconnect()
                        BlockSpinConnection = nil
                    end
                    local _, hum = GetCharacterData()
                    if hum then hum.AutoRotate = true end
                end
            end
        end
    })
    
    AutoBlockTab:Slider({
        Title = "Block Range",
        Value = {Min = 5, Max = 50, Default = 15},
        Step = 1,
        Callback = function(value)
            AutoBlockConfig.NormalRange = value
        end
    })
    
    AutoBlockTab:Button({
        Title = "Reset Range to Default (15)",
        Icon = "refresh-cw",
        Color = PINK,
        Callback = function()
            AutoBlockConfig.NormalRange = 15
            WindUI:Notify({
                Title = "Reset",
                Content = "Block range reset to 15",
                Icon = "check-circle",
                Duration = 2,
            })
        end
    })
    
    -- ============================================
    -- INFO TAB
    -- ============================================
    local InfoTab = Window:Tab({
        Title = "Info",
        Icon = "info",
        IconColor = PINK,
    })
    
    InfoTab:Section({
        Title = "Thông Tin / Information",
        Icon = "info",
    })
    
    InfoTab:Button({
        Title = "📋 Copy Discord Link",
        Description = "https://discord.gg/W8vpy5zH5",
        Icon = "copy",
        Color = PINK,
        Callback = function()
            local success = CopyToClipboard("https://discord.gg/W8vpy5zH5")
            if success then
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord link copied to clipboard",
                    Icon = "check-circle",
                    Duration = 3,
                })
            else
                WindUI:Notify({
                    Title = "Error!",
                    Content = "Your executor doesn't support clipboard copy",
                    Icon = "alert-circle",
                    Duration = 3,
                })
            end
        end
    })
    
    InfoTab:Button({
        Title = "📱 Copy TikTok Link",
        Description = "https://www.tiktok.com/@usertd1609",
        Icon = "copy",
        Color = PINK,
        Callback = function()
            local success = CopyToClipboard("https://www.tiktok.com/@usertd1609?_r=1&_t=ZS-96c7SgM2dj3")
            if success then
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "TikTok link copied to clipboard",
                    Icon = "check-circle",
                    Duration = 3,
                })
            else
                WindUI:Notify({
                    Title = "Error!",
                    Content = "Your executor doesn't support clipboard copy",
                    Icon = "alert-circle",
                    Duration = 3,
                })
            end
        end
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
    local KyotoTab = Window:Tab({
        Title = "Auto Kyoto",
        Icon = "activity",
        IconColor = PINK,
    })
    
    KyotoTab:Section({
        Title = "Auto Kyoto Settings",
        Icon = "settings",
    })
    
    KyotoTab:Toggle({
        Title = "Enable Auto Kyoto",
        Value = false,
        Icon = "power",
        Color = PINK,
        Callback = function(state)
            if AutoKyotoConfig.Enabled == state then return end
            AutoKyotoConfig.Enabled = state
            if state then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    SetupKyotoListener(hum)
                end
            else
                if AutoKyotoConfig.Connection then
                    AutoKyotoConfig.Connection:Disconnect()
                    AutoKyotoConfig.Connection = nil
                end
            end
        end
    })
    
    KyotoTab:Slider({
        Title = "Speed",
        Value = {Min = 5, Max = 50, Default = 22.5},
        Step = 0.5,
        Callback = function(value)
            AutoKyotoConfig.Speed = value
        end
    })
    
    KyotoTab:Slider({
        Title = "Animation Delay",
        Value = {Min = 0.1, Max = 5, Default = 1.5},
        Step = 0.1,
        Callback = function(value)
            AutoKyotoConfig.AnimationDelay = value
        end
    })
    
    KyotoTab:Slider({
        Title = "Execution Delay",
        Value = {Min = 0.1, Max = 2, Default = 0.6},
        Step = 0.05,
        Callback = function(value)
            AutoKyotoConfig.ExecutionDelay = value
        end
    })
    
    -- ============================================
    -- LETHAL DASH TAB
    -- ============================================
    local DashLethalTab = Window:Tab({
        Title = "Lethal Dash",
        Icon = "arrow-right",
        IconColor = PINK,
    })
    
    DashLethalTab:Section({
        Title = "Lethal Dash Settings",
        Icon = "settings",
    })
    
    DashLethalTab:Toggle({
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
                if LethalDashConfig.LerpConnection then
                    LethalDashConfig.LerpConnection:Disconnect()
                    LethalDashConfig.LerpConnection = nil
                end
                LethalDashConfig.Busy = false
                local _, hum = GetCharacterData()
                if hum then hum.AutoRotate = true end
            end
        end
    })
    
    DashLethalTab:Slider({
        Title = "Wait Time",
        Value = {Min = 0.5, Max = 3, Default = 1.5},
        Step = 0.05,
        Callback = function(value)
            LethalDashConfig.WaitTime = value
        end
    })
    
    DashLethalTab:Slider({
        Title = "Snap Duration",
        Value = {Min = 0.1, Max = 1, Default = 0.38},
        Step = 0.02,
        Callback = function(value)
            LethalDashConfig.SnapDuration = value
        end
    })
    
    DashLethalTab:Slider({
        Title = "Lock Distance",
        Value = {Min = 5, Max = 50, Default = 15},
        Step = 1,
        Callback = function(value)
            LethalDashConfig.LockDistance = value
        end
    })
    
    -- ============================================
    -- LIX TECH TAB (WITH WARNING MESSAGE)
    -- ============================================
    local LixTab = Window:Tab({
        Title = "Lix Tech",
        Icon = "zap-2",
        IconColor = PINK,
    })
    
    LixTab:Section({
        Title = "⚠️ Important Notice",
        Icon = "alert-triangle",
    })
    
    LixTab:Paragraph({
        Title = "English",
        Content = "Turn off Shift Lock before using Lix Tech!",
    })
    
    LixTab:Paragraph({
        Title = "Tiếng Việt",
        Content = "Tắt Shiftlock trước khi dùng Lix Tech!",
    })
    
    LixTab:Section({
        Title = "Lix Tech Settings",
        Icon = "settings",
    })
    
    LixTab:Toggle({
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
                local _, hum = GetCharacterData()
                if hum then hum.AutoRotate = true end
            end
        end
    })
    
    LixTab:Slider({
        Title = "Delay",
        Value = {Min = 0.1, Max = 2, Default = 0.3},
        Step = 0.05,
        Callback = function(value)
            LixTechConfig.Delay = value
        end
    })
    
    -- ============================================
    -- SUPATECH TAB
    -- ============================================
    local SupaLegitTab = Window:Tab({
        Title = "Supa Tech",
        Icon = "zap",
        IconColor = PINK,
    })
    
    SupaLegitTab:Section({
        Title = "Supa Tech Settings",
        Icon = "settings",
    })
    
    SupaLegitTab:Toggle({
        Title = "Enable Supa Tech",
        Value = false,
        Icon = "power",
        Color = PINK,
        Callback = function(state)
            if SupaLegitConfig.Enabled == state then return end
            SupaLegitConfig.Enabled = state
            if state then
                ConnectSupaLegit()
                if not SupaLegitConfig.CharConnection then
                    SupaLegitConfig.CharConnection = LocalPlayer.CharacterAdded:Connect(function()
                        if SupaLegitConfig.Enabled then
                            task.wait(0.5)
                            ConnectSupaLegit()
                        end
                    end)
                end
            else
                if SupaLegitConfig.Connection then
                    SupaLegitConfig.Connection:Disconnect()
                    SupaLegitConfig.Connection = nil
                end
                if SupaLegitConfig.CharConnection then
                    SupaLegitConfig.CharConnection:Disconnect()
                    SupaLegitConfig.CharConnection = nil
                end
                SupaLegitConfig.Busy = false
                SupaLegitConfig.InCooldown = false
                local _, hum = GetCharacterData()
                if hum then hum.AutoRotate = true end
            end
        end
    })
    
    SupaLegitTab:Slider({
        Title = "Dash Duration",
        Value = {Min = 0.05, Max = 0.5, Default = 0.15},
        Step = 0.01,
        Callback = function(value)
            SupaLegitConfig.DashDuration = value
        end
    })
    
    SupaLegitTab:Slider({
        Title = "Follow Offset",
        Value = {Min = 0.5, Max = 6, Default = 2.5},
        Step = 0.1,
        Callback = function(value)
            SupaLegitConfig.FollowOffset = value
        end
    })
    
    SupaLegitTab:Slider({
        Title = "Angle Tilt (Degrees)",
        Value = {Min = 10, Max = 90, Default = 55},
        Step = 1,
        Callback = function(value)
            SupaLegitConfig.AngleTilt = value
        end
    })
    
    SupaLegitTab:Slider({
        Title = "Stick Range",
        Value = {Min = 5, Max = 35, Default = 18},
        Step = 1,
        Callback = function(value)
            SupaLegitConfig.StickRange = value
        end
    })
    
    SupaLegitTab:Slider({
        Title = "Cooldown Time",
        Value = {Min = 1, Max = 10, Default = 4},
        Step = 0.5,
        Callback = function(value)
            SupaLegitConfig.CooldownTime = value
        end
    })
    
    -- ============================================
    -- OREO TECH TAB
    -- ============================================
    local OreoTechTab = Window:Tab({
        Title = "Oreo Tech",
        Icon = "hexagon",
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
                if not OreoTechConfig.CharConnection then
                    OreoTechConfig.CharConnection = LocalPlayer.CharacterAdded:Connect(function()
                        if OreoTechConfig.Enabled then
                            task.wait(0.5)
                            ConnectOreoTech()
                        end
                    end)
                end
            else
                if OreoTechConfig.Connection then
                    OreoTechConfig.Connection:Disconnect()
                    OreoTechConfig.Connection = nil
                end
                if OreoTechConfig.CharConnection then
                    OreoTechConfig.CharConnection:Disconnect()
                    OreoTechConfig.CharConnection = nil
                end
                OreoTechConfig.CanTrigger = true
                local _, hum = GetCharacterData()
                if hum then hum.AutoRotate = true end
            end
        end
    })
    
    OreoTechTab:Slider({
        Title = "Cooldown Time",
        Value = {Min = 1, Max = 10, Default = 5},
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
    -- MISC AND VISUAL TAB (NEW)
    -- ============================================
    local MiscVisualTab = Window:Tab({
        Title = "Misc & Visual",
        Icon = "settings",
        IconColor = PINK,
    })
    
    local GeneralSection = MiscVisualTab:Section({
        Title = "General Settings",
        Icon = "settings",
    })
    
    -- Support Section (No Cooldown Dash)
    GeneralSection:Button({
        Title = "Support",
        Description = "Support Discord",
        Icon = "heart",
        Color = PINK,
        Callback = function()
            local success = CopyToClipboard("https://discord.gg/W8vpy5zH5")
            if success then
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord support link copied!",
                    Icon = "check-circle",
                    Duration = 3,
                })
            else
                WindUI:Notify({
                    Title = "Error!",
                    Content = "Cannot copy link",
                    Icon = "alert-circle",
                    Duration = 3,
                })
            end
        end
    })
    
    -- No Cooldown Dash Toggle
    GeneralSection:Toggle({
        Title = "No Cooldown Dash",
        Description = "Remove dash cooldown (experimental)",
        Value = false,
        Icon = "zap",
        Color = PINK,
        Callback = function(state)
            NoCooldownDashConfig.Enabled = state
            SetupNoCooldownDash()
            if state then
                WindUI:Notify({
                    Title = "No Cooldown Dash",
                    Content = "Enabled! (May not work on all servers)",
                    Icon = "zap",
                    Duration = 3,
                })
            else
                WindUI:Notify({
                    Title = "No Cooldown Dash",
                    Content = "Disabled!",
                    Icon = "power",
                    Duration = 2,
                })
            end
        end
    })
    
    -- Emote Limited Section
    local EmoteSection = MiscVisualTab:Section({
        Title = "Emote Limited",
        Icon = "smile",
    })
    
    EmoteSection:Button({
        Title = "Final Stand",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayFinalStand
    })
    
    EmoteSection:Button({
        Title = "Inner Rage",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayInnerRage
    })
    
    EmoteSection:Button({
        Title = "Shadow Eruption",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayShadowEruption
    })
    
    EmoteSection:Button({
        Title = "Divine Form",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayDivineForm
    })
    
    EmoteSection:Button({
        Title = "The Strongest",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayTheStrongest
    })
    
    EmoteSection:Button({
        Title = "Boundless Rage",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayBoundlessRage
    })
    
    EmoteSection:Button({
        Title = "The Fallen",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayTheFallen
    })
    
    EmoteSection:Button({
        Title = "True Aura",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayTrueAura
    })
    
    EmoteSection:Button({
        Title = "Eternal Seal (New)",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayEternalSeal
    })
    
    EmoteSection:Button({
        Title = "World Cutting Slash",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayWorldCuttingSlash
    })
    
    EmoteSection:Button({
        Title = "My Brother",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayMyBrother
    })
    
    EmoteSection:Button({
        Title = "Final Spark",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayFinalSpark
    })
    
    EmoteSection:Button({
        Title = "Last Will",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayLastWill
    })
    
    EmoteSection:Button({
        Title = "The Fallen Finisher",
        Icon = "mouse-pointer-click",
        Color = PINK,
        Callback = PlayTheFallenFinisher
    })
    
    -- ============================================
    -- STARTUP NOTIFICATION
    -- ============================================
    WindUI:Notify({
        Title = "YumeX Hub Ready",
        Content = "Loaded successfully!",
        Icon = "check-circle",
        Duration = 5,
    })
end

-- ============================================
-- CHARACTER SPAWN HANDLING
-- ============================================
local function OnCharacterAdded(character)
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
    
    if SupaLegitConfig.Enabled then
        task.wait(0.5)
        ConnectSupaLegit()
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
    
    if AntiShakeConfig.Enabled then
        task.wait(0.5)
        SetupAntiShake()
    end
    
    if AutoBlockConfig.Enabled then
        task.wait(0.5)
        AutoBlockStartDetect()
        if AutoBlockConfig.BlockSpin then
            SetupBlockSpin()
        end
    end
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Setup initial character
task.wait(0.5)
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end