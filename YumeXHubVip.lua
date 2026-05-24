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
    -- Fallback: create simple notification
    warn("Failed to load WindUI, some features may not work")
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local Camera = Workspace.CurrentCamera

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
-- ANTI-SHAKE CONFIG & LOGIC
-- ============================================
local AntiShakeConfig = {
    Enabled = false,
    Strength = 0.8,
    Smoothness = 0.15,
    UpdateRate = 1,
}

local AntiShakeState = {
    LastCFrame = nil,
    TargetCFrame = nil,
    Connection = nil,
    LastUpdate = 0,
}

local function ApplyAntiShake()
    if not AntiShakeConfig.Enabled then return end
    
    local currentTime = tick()
    if currentTime - AntiShakeState.LastUpdate < AntiShakeConfig.UpdateRate then
        return
    end
    AntiShakeState.LastUpdate = currentTime
    
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    if AntiShakeState.LastCFrame == nil then
        AntiShakeState.LastCFrame = root.CFrame
        AntiShakeState.TargetCFrame = root.CFrame
        return
    end
    
    local currentCFrame = root.CFrame
    local positionDelta = (currentCFrame.Position - AntiShakeState.LastCFrame.Position).Magnitude
    
    if positionDelta < 0.1 then
        local smoothedPos = AntiShakeState.LastCFrame.Position:Lerp(
            currentCFrame.Position, 
            AntiShakeConfig.Smoothness
        )
        AntiShakeState.TargetCFrame = CFrame.new(smoothedPos) * currentCFrame:ToObjectSpace(CFrame.new(currentCFrame.Position))
        root.CFrame = AntiShakeState.TargetCFrame
    else
        AntiShakeState.LastCFrame = currentCFrame
    end
    
    AntiShakeState.LastCFrame = root.CFrame
end

local function StartAntiShake()
    if AntiShakeState.Connection then
        AntiShakeState.Connection:Disconnect()
    end
    AntiShakeState.Connection = RunService.RenderStepped:Connect(ApplyAntiShake)
end

local function StopAntiShake()
    if AntiShakeState.Connection then
        AntiShakeState.Connection:Disconnect()
        AntiShakeState.Connection = nil
    end
    AntiShakeState.LastCFrame = nil
    AntiShakeState.TargetCFrame = nil
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
-- WINDUI WINDOW SETUP (with fallback)
-- ============================================
if not WindUI then
    -- Create simple GUI if WindUI fails
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "YumeXHub_Fallback"
    screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    
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
else
    local Window = WindUI:CreateWindow({
        Title = "YumeX Hub",
        Author = "By ThanhDuy",
        Icon = "rbxassetid://17044989894",
        Icon_Color = PINK,
        Folder = "YumeXHubScripts",
    })
    
    -- ============================================
    -- INFO TAB (TAB)
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
    -- ANTI-SHAKE TAB
    -- ============================================
    local AntiShakeTab = Window:Tab({
        Title = "Anti-Shake",
        Icon = "zap",
        IconColor = PINK,
    })
    
    AntiShakeTab:Section({
        Title = "Anti-Shake Settings",
        Icon = "settings",
    })
    
    AntiShakeTab:Toggle({
        Title = "Enable Anti-Shake",
        Value = false,
        Icon = "power",
        Color = PINK,
        Callback = function(state)
            AntiShakeConfig.Enabled = state
            if state then
                StartAntiShake()
            else
                StopAntiShake()
            end
        end
    })
    
    AntiShakeTab:Slider({
        Title = "Smoothness",
        Value = {Min = 0.01, Max = 1, Default = 0.15},
        Step = 0.01,
        Callback = function(value)
            AntiShakeConfig.Smoothness = value
        end
    })
    
    AntiShakeTab:Slider({
        Title = "Strength",
        Value = {Min = 0, Max = 1, Default = 0.8},
        Step = 0.05,
        Callback = function(value)
            AntiShakeConfig.Strength = value
        end
    })
    
    AntiShakeTab:Slider({
        Title = "Update Rate",
        Value = {Min = 0.001, Max = 0.1, Default = 0.01},
        Step = 0.001,
        Callback = function(value)
            AntiShakeConfig.UpdateRate = value
        end
    })
    
    -- ============================================
    -- STARTUP NOTIFICATION
    -- ============================================
    WindUI:Notify({
        Title = "YumeX Hub Ready",
        Content = "All systems loaded successfully",
        Icon = "check-circle",
        Duration = 10,
    })
end

-- ============================================
-- CHARACTER SPAWN HANDLING
-- ============================================
local function OnCharacterAdded(character)
    task.wait(0.1)
    
    -- Reset Anti-Shake state on new character
    AntiShakeState.LastCFrame = nil
    AntiShakeState.TargetCFrame = nil
    if AntiShakeConfig.Enabled then
        StartAntiShake()
    end
    
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
end

LocalPlayer.CharacterAdded:Connect(OnCharacterAdded)

-- Setup initial character
task.wait(0.5)
if LocalPlayer.Character then
    OnCharacterAdded(LocalPlayer.Character)
end