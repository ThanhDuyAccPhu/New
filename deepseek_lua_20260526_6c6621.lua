local syde = loadstring(game:HttpGet("https://raw.githubusercontent.com/essencejs/syde/refs/heads/main/source", true))()

syde:Load({
	Logo = '7488932274',
	Name = 'ThanhDuy Hub',
	Status = 'Stable',
	Accent = Color3.fromRGB(255, 51, 51),
	HitBox = Color3.fromRGB(255, 51, 51),
	AutoLoad = false,
	Socials = {
		{
			Name = 'Discord';
			Style = 'Discord';
			Size = "Large";
			CopyToClip = true
		},
		{
			Name = 'GitHub';
			Style = 'GitHub';
			Size = "Small";
			CopyToClip = true
		}
	},
	ConfigurationSaving = {
		Enabled = true,
		FolderName = 'ThanhDuyHub',
		FileName = "config"
	},
	AutoJoinDiscord = {
		Enabled = false,
		Invite = "tgK6PfbsN",
		RememberJoins = false
	}
})

local Window = syde:Init({
    Title = 'ThanhDuy Hub | TSB',
    SubText = 'by ThanhDuy'
})

-- ===== CREATE TABS =====
local TonghopTab = Window:InitTab({ Title = 'TongHop' })
local MainTab = Window:InitTab({ Title = 'Main' })
local MovesetsTab = Window:InitTab({ Title = 'Movesets' })
local TechTab = Window:InitTab({ Title = 'Tech' })
local FixLagTab = Window:InitTab({ Title = 'FixLag' })
local TsbTab = Window:InitTab({ Title = 'TSB' })
local MiscTab = Window:InitTab({ Title = 'Misc' })
local EmoteTab = Window:InitTab({ Title = 'Emote Limited' })
local InfoTab = Window:InitTab({ Title = 'Info' })
local PlayerTab = Window:InitTab({ Title = 'Player' })
local HopTab = Window:InitTab({ Title = 'Hop' })

-- ===== SERVICES =====
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local Debris = game:GetService("Debris")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

local toggles = {}

local MasterEnabled = false
local CombatEnabled = false
local CamlockEnabled = false
local CurrentTarget = nil
local CamlockTarget = nil
local LOCK_DISTANCE = 80
local CamLOCK_DISTANCE = 120
local CamPREDICTION = 0.12
local CamSMOOTHNESS = 0.18

local InstantLethalEnabled = false
local InstantLethalConnection = nil
local InstantLethalAnimConnection = nil

local FPS = 0
local lastUpdate = tick()
local frameCount = 0
local Ping = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    
    if now - lastUpdate >= 1 then
        FPS = math.floor(frameCount / (now - lastUpdate))
        frameCount = 0
        lastUpdate = now
    end
end)

task.spawn(function()
    while task.wait(2) do
        local success, pingValue = pcall(function()
            return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
        end)
        if success then
            Ping = pingValue
        end
    end
end)

function GetNearestPlayer()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local root = char.HumanoidRootPart
    local nearest, dist = nil, LOCK_DISTANCE

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < dist then
                    dist = d
                    nearest = plr
                end
            end
        end
    end
    return nearest
end

function CamFindTarget()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end

    local root = myChar.HumanoidRootPart
    local nearest, bestDist = nil, CamLOCK_DISTANCE

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                local d = (hrp.Position - root.Position).Magnitude
                if d < bestDist then
                    bestDist = d
                    nearest = plr
                end
            end
        end
    end
    return nearest
end

local function InstantLethal_DoFlick()
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

local function InstantLethal_DoJump()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then root.AssemblyLinearVelocity = Vector3.new(0, 64, 0) end
end

local function InstantLethal_ConnectLogic()
    if InstantLethalAnimConnection then 
        InstantLethalAnimConnection:Disconnect() 
    end
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    local animId = "rbxassetid://12296113986"
    local Smoothness = 0.22
    
    InstantLethalAnimConnection = hum.AnimationPlayed:Connect(function(anim)
        if InstantLethalEnabled and anim.Animation.AnimationId == animId then
            task.wait(1.72)
            InstantLethal_DoJump()
            InstantLethal_DoFlick()
            local dashData = {{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}
            if char:FindFirstChild("Communicate") then
                char.Communicate:FireServer(unpack(dashData))
            end
            task.wait(Smoothness)
            InstantLethal_DoFlick()
        end
    end)
end

local function StartInstantLethal()
    if InstantLethalConnection then 
        InstantLethalConnection:Disconnect() 
    end
    InstantLethal_ConnectLogic()
    InstantLethalConnection = LocalPlayer.CharacterAdded:Connect(function()
        if InstantLethalEnabled then 
            task.wait(0.5) 
            InstantLethal_ConnectLogic() 
        end
    end)
end

local function StopInstantLethal()
    if InstantLethalAnimConnection then
        InstantLethalAnimConnection:Disconnect()
        InstantLethalAnimConnection = nil
    end
    if InstantLethalConnection then
        InstantLethalConnection:Disconnect()
        InstantLethalConnection = nil
    end
end

local targetPlayer = nil
local killEnabled = false
local orbitEnabled = false
local nameInput = ""

local function getNearestPlayerAK()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local root = char.HumanoidRootPart
    local nearest, minDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (root.Position - hrp.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    nearest = plr
                end
            end
        end
    end
    return nearest
end

local function tapKey(key, delayTime)
    delayTime = delayTime or 0.05
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(delayTime)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end

RunService.RenderStepped:Connect(function()
    if MasterEnabled and CombatEnabled then
        local char = LocalPlayer.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then return end

        if not CurrentTarget or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChildOfClass("Humanoid") or CurrentTarget.Character.Humanoid.Health <= 0 then
            CurrentTarget = GetNearestPlayer()
            return
        end

        local targetHRP = CurrentTarget.Character:FindFirstChild("HumanoidRootPart")
        if not targetHRP then return end

        char.HumanoidRootPart.CFrame = CFrame.new(
            char.HumanoidRootPart.Position,
            Vector3.new(targetHRP.Position.X, char.HumanoidRootPart.Position.Y, targetHRP.Position.Z)
        )
    end

    if CamlockEnabled then
        if not CamlockTarget or not CamlockTarget.Character or not CamlockTarget.Character:FindFirstChild("HumanoidRootPart") then
            CamlockTarget = CamFindTarget()
            return
        end

        local hrp = CamlockTarget.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local predicted = hrp.Position + (hrp.AssemblyLinearVelocity * CamPREDICTION)
        local currentCF = Camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, predicted)
        Camera.CFrame = currentCF:Lerp(targetCF, CamSMOOTHNESS)
    end
end)

-- ===== TONGHOP TAB =====
TonghopTab:Button({
    Title = 'BaeMinhHub',
    CallBack = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/ngm2807-sudo/3bb38870095ccba814f13993813410f3/raw/32addd5af4b65ffa18a7002eac6e71b9f01076ed/BaeMinhHub.lua"))()
    end
})

TonghopTab:Button({
    Title = 'TthanhHub',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/Tthanh%20Tong%20Hop%20Tech.txt"))()
    end
})

-- ===== MAIN TAB =====
MainTab:Toggle({
    Title = 'Silent Aim',
    Value = false,
    CallBack = function(Value)
        MasterEnabled = Value
        CombatEnabled = Value
        if not Value then
            CurrentTarget = nil
        end
    end
})

MainTab:Toggle({
    Title = 'Cam Lock',
    Description = 'Lock camera on target',
    Value = false,
    CallBack = function(Value)
        CamlockEnabled = Value
        if not Value then
            CamlockTarget = nil
        end
    end
})

-- ===== AUTO TECH SECTION =====
-- Tạo các tab con cho Auto Tech (sử dụng Section trong Syde)
-- Garou Auto Tab
TonghopTab:Section('Garou Techs')

TonghopTab:Toggle({
    Title = 'Instant Lethal V2',
    Value = false,
    CallBack = function(state)
        InstantLethalEnabled = state
        if state then
            StartInstantLethal()
        else
            StopInstantLethal()
        end
    end
})

TonghopTab:Toggle({
    Title = 'Instant Lethal V1',
    Value = false,
    CallBack = function(state)
        toggles.InstantLethalV1 = state
        
        local IL_CONFIG = {
            detectAnim = "rbxassetid://12296113986",
            waitTime = 1.6,
            camlockTime = 0.5,
            targetRange = 20,
            jumpPower = 67,
            lerpSpeed = 0.73
        }
        
        local ilConnection = nil
        local charAddedConnection = nil
        local currentCamlockConnection = nil
        local isRunning = false
        
        local function getCharacter()
            return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        end
        
        local function getNearestTarget()
            local char = getCharacter()
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if not root then return nil end
            
            local liveFolder = workspace:FindFirstChild("Live")
            if not liveFolder then return nil end
            
            local nearest = nil
            local shortest = IL_CONFIG.targetRange
            
            for _, model in ipairs(liveFolder:GetChildren()) do
                if model:IsA("Model") and model ~= char then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    local hum = model:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and hum and hum.Health > 0 then
                        local isTarget = false
                        pcall(function()
                            isTarget = (model.Name == "Weakest Dummy") or (Players:GetPlayerFromCharacter(model) ~= nil)
                        end)
                        
                        if isTarget then
                            local dist = (hrp.Position - root.Position).Magnitude
                            if dist <= shortest then
                                shortest = dist
                                nearest = hrp
                            end
                        end
                    end
                end
            end
            
            return nearest
        end
        
        local function camLock(targetHRP)
            if not targetHRP or not targetHRP.Parent then return end
            
            if currentCamlockConnection then
                pcall(function() currentCamlockConnection:Disconnect() end)
                currentCamlockConnection = nil
            end
            
            local startTime = tick()
            
            currentCamlockConnection = RunService.RenderStepped:Connect(function()
                if not toggles.InstantLethalV1 then
                    if currentCamlockConnection then
                        currentCamlockConnection:Disconnect()
                        currentCamlockConnection = nil
                    end
                    return
                end
                
                if not targetHRP or not targetHRP.Parent then
                    if currentCamlockConnection then
                        currentCamlockConnection:Disconnect()
                        currentCamlockConnection = nil
                    end
                    return
                end
                
                if tick() - startTime >= IL_CONFIG.camlockTime then
                    if currentCamlockConnection then
                        currentCamlockConnection:Disconnect()
                        currentCamlockConnection = nil
                    end
                    return
                end
                
                local camCF = Camera.CFrame
                local camPos = camCF.Position
                local currentDir = camCF.LookVector
                local desiredDir = (targetHRP.Position - camPos).Unit
                
                if desiredDir.Y > 0 then
                    desiredDir = Vector3.new(desiredDir.X, 0, desiredDir.Z).Unit
                end
                
                local blendedDir = currentDir:Lerp(desiredDir, IL_CONFIG.lerpSpeed).Unit
                Camera.CFrame = CFrame.new(camPos, camPos + blendedDir)
            end)
        end
        
        local function fireDash(character)
            if not character then return end
            
            local remote = character:FindFirstChild("Communicate")
            if remote then
                pcall(function()
                    remote:FireServer(unpack({{
                        Dash = Enum.KeyCode.W,
                        Key = Enum.KeyCode.Q,
                        Goal = "KeyPress"
                    }}))
                end)
            end
        end
        
        local function executeSequence(character)
            if not toggles.InstantLethalV1 then return end
            if isRunning then return end
            
            isRunning = true
            
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if not root then 
                isRunning = false
                return 
            end
            
            local target = getNearestTarget()
            
            task.wait(IL_CONFIG.waitTime)
            
            if not toggles.InstantLethalV1 then
                isRunning = false
                return
            end
            
            fireDash(character)
            
            root.Velocity = Vector3.new(root.Velocity.X, IL_CONFIG.jumpPower, root.Velocity.Z)
            
            if target then
                camLock(target)
            end
            
            isRunning = false
        end
        
        local function onAnimationPlayed(animationTrack)
            if not toggles.InstantLethalV1 then return end
            
            local anim = animationTrack.Animation
            if anim and anim.AnimationId == IL_CONFIG.detectAnim then
                local char = getCharacter()
                task.spawn(function()
                    executeSequence(char)
                end)
            end
        end
        
        local function connectToCharacter(character)
            if not character then return end
            
            if ilConnection then
                pcall(function() ilConnection:Disconnect() end)
                ilConnection = nil
            end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            ilConnection = humanoid.AnimationPlayed:Connect(onAnimationPlayed)
        end
        
        if state then
            isRunning = false
            
            if currentCamlockConnection then
                pcall(function() currentCamlockConnection:Disconnect() end)
                currentCamlockConnection = nil
            end
            
            if LocalPlayer.Character then
                connectToCharacter(LocalPlayer.Character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.InstantLethalV1 then
                    task.wait(0.5)
                    connectToCharacter(newChar)
                end
            end)
            
            _G.InstantLethalV1Connection = ilConnection
            _G.InstantLethalV1CharConn = charAddedConnection
            
        else
            if ilConnection then
                pcall(function() ilConnection:Disconnect() end)
                ilConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            if currentCamlockConnection then
                pcall(function() currentCamlockConnection:Disconnect() end)
                currentCamlockConnection = nil
            end
            
            isRunning = false
            
            _G.InstantLethalV1Connection = nil
            _G.InstantLethalV1CharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'Lethal Dash',
    Value = false,
    CallBack = function(state)
        toggles.LethalDash = state
        
        local LD_CONFIG = {
            detectAnim = "rbxassetid://12296113986",
            waitTime = 1.5,
            snapDuration = 0.38,
            jumpPower = 64,
            lockDistance = 15,
            lerpStartAlpha = 0.32,
            lerpEndAlpha = 1,
            smoothPower = 0.15,
            smoothDuration = 2
        }
        
        local ldConnection = nil
        local charAddedConnection = nil
        local snapConnection = nil
        local isBusy = false
        local smoothEnabled = false
        local lastCF = nil
        
        local currentChar = nil
        local currentHumanoid = nil
        local currentRootPart = nil
        
        local function doJump()
            if currentRootPart then
                currentRootPart.AssemblyLinearVelocity = Vector3.new(0, LD_CONFIG.jumpPower, 0)
            end
        end
        
        local function getTarget()
            if not currentRootPart then return nil end
            
            local liveFolder = workspace:FindFirstChild("Live")
            if not liveFolder then return nil end
            
            local closestTarget = nil
            local closestDistance = LD_CONFIG.lockDistance
            
            for _, model in ipairs(liveFolder:GetChildren()) do
                if model:IsA("Model") and model ~= currentChar then
                    local hrp = model:FindFirstChild("HumanoidRootPart")
                    local humanoid = model:FindFirstChildOfClass("Humanoid")
                    
                    if hrp and humanoid and humanoid.Health > 0 then
                        local distance = (currentRootPart.Position - hrp.Position).Magnitude
                        if distance <= LD_CONFIG.lockDistance and distance < closestDistance then
                            closestDistance = distance
                            closestTarget = hrp
                        end
                    end
                end
            end
            return closestTarget
        end
        
        local function fireDashRemote()
            if currentChar then
                local remote = currentChar:FindFirstChild("Communicate")
                if remote then
                    pcall(function()
                        remote:FireServer({
                            Dash = Enum.KeyCode.W,
                            Key = Enum.KeyCode.Q,
                            Goal = "KeyPress"
                        })
                    end)
                end
            end
        end
        
        local function snapToTarget(target)
            if not target or not target.Parent then return end
            if not currentRootPart or not currentHumanoid then return end
            
            if snapConnection then
                pcall(function() snapConnection:Disconnect() end)
                snapConnection = nil
            end
            
            local startTime = tick()
            local startCF = currentRootPart.CFrame
            
            snapConnection = RunService.RenderStepped:Connect(function()
                if not toggles.LethalDash then
                    if snapConnection then snapConnection:Disconnect() end
                    if currentHumanoid then currentHumanoid.AutoRotate = true end
                    return
                end
                
                if not target or not target.Parent or not currentRootPart or not currentRootPart.Parent then
                    if currentHumanoid then currentHumanoid.AutoRotate = true end
                    if snapConnection then snapConnection:Disconnect() end
                    return
                end
                
                local elapsed = tick() - startTime
                if elapsed >= LD_CONFIG.snapDuration then
                    if currentHumanoid then currentHumanoid.AutoRotate = true end
                    if snapConnection then snapConnection:Disconnect() end
                    return
                end
                
                currentHumanoid.AutoRotate = false
                
                local myPos = currentRootPart.Position
                local targetPos = target.Position
                local flatTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
                local targetCF = CFrame.new(myPos, flatTarget)
                
                local progress = elapsed / LD_CONFIG.snapDuration
                local smoothProgress = progress * progress * (3 - 2 * progress)
                local alpha = LD_CONFIG.lerpStartAlpha + (LD_CONFIG.lerpEndAlpha - LD_CONFIG.lerpStartAlpha) * smoothProgress
                alpha = math.clamp(alpha, 0, 1)
                
                currentRootPart.CFrame = startCF:Lerp(targetCF, alpha)
            end)
        end
        
        local function enableTempSmooth()
            smoothEnabled = true
            lastCF = Camera.CFrame
            
            task.delay(LD_CONFIG.smoothDuration, function()
                if toggles.LethalDash then
                    smoothEnabled = false
                end
            end)
        end
        
        local function executeSequence()
            if not toggles.LethalDash then return end
            if isBusy then return end
            
            isBusy = true
            
            enableTempSmooth()
            
            task.wait(LD_CONFIG.waitTime)
            
            if not toggles.LethalDash then
                isBusy = false
                return
            end
            
            if currentHumanoid then
                currentHumanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
            
            task.wait(0.1)
            
            doJump()
            
            fireDashRemote()
            
            local target = getTarget()
            if target then
                task.delay(0.2, function()
                    if toggles.LethalDash and target and target.Parent then
                        snapToTarget(target)
                    end
                end)
            end
            
            isBusy = false
        end
        
        local function onAnimationPlayed(animationTrack)
            if not toggles.LethalDash then return end
            if isBusy then return end
            
            local anim = animationTrack.Animation
            if anim and anim.AnimationId == LD_CONFIG.detectAnim then
                task.spawn(executeSequence)
            end
        end
        
        local function setupCameraSmooth()
            RunService.RenderStepped:Connect(function()
                if not toggles.LethalDash then return end
                if not smoothEnabled then return end
                if not lastCF then 
                    lastCF = Camera.CFrame
                    return 
                end
                
                local currentCF = Camera.CFrame
                lastCF = lastCF:Lerp(currentCF, LD_CONFIG.smoothPower)
                Camera.CFrame = lastCF
            end)
        end
        
        local function connectToCharacter(character)
            if not character then return end
            
            if ldConnection then
                pcall(function() ldConnection:Disconnect() end)
                ldConnection = nil
            end
            
            currentChar = character
            currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            currentRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not currentHumanoid then return end
            
            ldConnection = currentHumanoid.AnimationPlayed:Connect(onAnimationPlayed)
        end
        
        setupCameraSmooth()
        
        if state then
            isBusy = false
            smoothEnabled = false
            lastCF = Camera.CFrame
            
            if LocalPlayer.Character then
                connectToCharacter(LocalPlayer.Character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.LethalDash then
                    task.wait(0.3)
                    connectToCharacter(newChar)
                end
            end)
            
            _G.LethalDashConnection = ldConnection
            _G.LethalDashCharConn = charAddedConnection
            
        else
            if ldConnection then
                pcall(function() ldConnection:Disconnect() end)
                ldConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            if snapConnection then
                pcall(function() snapConnection:Disconnect() end)
                snapConnection = nil
            end
            
            isBusy = false
            smoothEnabled = false
            
            if currentHumanoid then
                pcall(function() currentHumanoid.AutoRotate = true end)
            end
            
            _G.LethalDashConnection = nil
            _G.LethalDashCharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'Auto Kyoto',
    Value = false,
    CallBack = function(state)
        toggles.GarouAutoKyoto = state
        
        local KYOTO_CONFIG = {
            moveDistance = 22.5,
            animId = "rbxassetid://12273188754",
            delayAfterAnim = 1.5,
            stepDelay = 0.6,
            keyPressDelay = 0.05
        }
        
        local kyotoConnection = nil
        local charAddedConnection = nil
        local lastMoveTime = 0
        local isMoving = false
        
        local currentDelay = KYOTO_CONFIG.delayAfterAnim
        
        local function moveForward()
            if not toggles.GarouAutoKyoto then return end
            
            local now = tick()
            if now - lastMoveTime >= KYOTO_CONFIG.stepDelay then
                lastMoveTime = now
                
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                
                if rootPart then
                    local newCFrame = rootPart.CFrame + rootPart.CFrame.LookVector * KYOTO_CONFIG.moveDistance
                    rootPart.CFrame = newCFrame
                    
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Two, false, game)
                        task.wait(KYOTO_CONFIG.keyPressDelay)
                        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Two, false, game)
                    end)
                end
            end
        end
        
        local function onAnimationPlayed(animationTrack)
            if not toggles.GarouAutoKyoto then return end
            
            local anim = animationTrack.Animation
            if anim and anim.AnimationId == KYOTO_CONFIG.animId then
                task.delay(currentDelay, function()
                    if toggles.GarouAutoKyoto then
                        moveForward()
                    end
                end)
            end
        end
        
        local function setupCharacter(character)
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then return end
            
            if kyotoConnection then
                pcall(function() kyotoConnection:Disconnect() end)
                kyotoConnection = nil
            end
            
            kyotoConnection = humanoid.AnimationPlayed:Connect(onAnimationPlayed)
        end
        
        if state then
            lastMoveTime = 0
            isMoving = false
            
            if LocalPlayer.Character then
                setupCharacter(LocalPlayer.Character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.GarouAutoKyoto then
                    task.wait(0.3)
                    setupCharacter(newChar)
                end
            end)
            
            _G.KyotoConnection = kyotoConnection
            _G.KyotoCharConn = charAddedConnection
            
        else
            if kyotoConnection then
                pcall(function() kyotoConnection:Disconnect() end)
                kyotoConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            
            _G.KyotoConnection = nil
            _G.KyotoCharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'Twisted',
    Value = false,
    CallBack = function(state)
        print("Auto Twisted:", state)
        _G._AutoTwisted_Enabled = state

        local player = game.Players.LocalPlayer
        local cooldown = false
        local animationConnection
        local charAddedConnection
        local animationId = "rbxassetid://13294471966"
        local delayBeforeRemote = 0.23

        local function useRemote()
            if not _G._AutoTwisted_Enabled then return end
            local char = player.Character
            if char and char:FindFirstChild("Communicate") then
                local args = {
                    [1] = {
                        ["Dash"] = Enum.KeyCode.W,
                        ["Key"] = Enum.KeyCode.Q,
                        ["Goal"] = "KeyPress"
                    }
                }
                char.Communicate:FireServer(unpack(args))
            end
        end

        local function stepBack()
            if not _G._AutoTwisted_Enabled then return end
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, 3.4)
            end
        end

        local function bindAnimationDetection()
            local char = player.Character or player.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid")

            animationConnection = humanoid.AnimationPlayed:Connect(function(track)
                if not _G._AutoTwisted_Enabled then return end
                if track.Animation and track.Animation.AnimationId == animationId and not cooldown then
                    cooldown = true

                    task.delay(delayBeforeRemote, function()
                        if not _G._AutoTwisted_Enabled then return end
                        stepBack()
                        useRemote()
                    end)

                    task.delay(5, function()
                        cooldown = false
                    end)
                end
            end)
        end

        if _G._AutoTwisted_Enabled then
            bindAnimationDetection()
            charAddedConnection = player.CharacterAdded:Connect(function()
                task.wait(1)
                if _G._AutoTwisted_Enabled then
                    bindAnimationDetection()
                end
            end)
        else
            if animationConnection then
                animationConnection:Disconnect()
                animationConnection = nil
            end
            if charAddedConnection then
                charAddedConnection:Disconnect()
                charAddedConnection = nil
            end
        end
    end
})

TonghopTab:Toggle({
    Title = 'Flowing + Hunter\'s Grasp',
    Value = false,
    CallBack = function(state)
        print("Flowing + Hunter's Grasp Toggle:", state)
        _G.FlowingGraspEnabled = state

        local TweenService = game:GetService("TweenService")
        local player = game.Players.LocalPlayer
        local animationId = "rbxassetid://12273188754"
        local flowingConnection
        local isTweening = false
        local lastPlaying = false

        if _G.FlowingGraspConnection then
            _G.FlowingGraspConnection:Disconnect()
            _G.FlowingGraspConnection = nil
        end

        if not state then return end

        _G.FlowingGraspConnection = RunService.RenderStepped:Connect(function()
            local char = player.Character
            local humanoid = char and char:FindFirstChild("Humanoid")
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not humanoid or not hrp then return end

            local isPlaying = false
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId == animationId then
                    isPlaying = true
                    break
                end
            end

            if isPlaying and not isTweening and not lastPlaying then
                isTweening = true
                lastPlaying = true

                task.delay(1.8, function()
                    local forwardCFrame = hrp.CFrame + hrp.CFrame.LookVector * 24
                    local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = forwardCFrame})
                    tween:Play()
                    tween.Completed:Wait()

                    local tool = player.Backpack:FindFirstChild("Hunter's Grasp")
                    local remote = char:FindFirstChild("Communicate")
                    if tool and remote then
                        local args = {
                            [1] = {
                                ["Tool"] = tool,
                                ["Goal"] = "Console Move"
                            }
                        }
                        remote:FireServer(unpack(args))
                    end

                    isTweening = false
                end)
            elseif not isPlaying then
                lastPlaying = false
            end
        end)
    end
})

TonghopTab:Toggle({
    Title = 'Upper + Hunter\'s Grasp',
    Value = false,
    CallBack = function(state)
        print("Upper + Hunter's Grasp Toggle:", state)
        _G.UpperGraspEnabled = state

        local TweenService = game:GetService("TweenService")
        local Workspace = game:GetService("Workspace")
        local player = game.Players.LocalPlayer
        local animationId = "rbxassetid://10503381238"
        local TWEEN_HEIGHT_OFFSET = Vector3.new(0, 8, 0)
        local isTweening = false
        local lastPlaying = false
        local cooldown = false

        if _G.UpperGraspConnection then
            _G.UpperGraspConnection:Disconnect()
            _G.UpperGraspConnection = nil
        end

        if not state then return end

        _G.UpperGraspConnection = RunService.RenderStepped:Connect(function()
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChild("Humanoid")
            if not char or not hrp or not humanoid then return end

            local isPlaying = false
            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId == animationId then
                    isPlaying = true
                    break
                end
            end

            if isPlaying and not isTweening and not lastPlaying and not cooldown then
                isTweening = true
                lastPlaying = true
                cooldown = true

                task.delay(0.18, function()
                    local target
                    local shortestDist = 7
                    local live = Workspace:FindFirstChild("Live")
                    if live then
                        for _, model in ipairs(live:GetChildren()) do
                            if model:IsA("Model") and model ~= char then
                                local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
                                if torso then
                                    local dist = (hrp.Position - torso.Position).Magnitude
                                    if dist <= shortestDist then
                                        shortestDist = dist
                                        target = torso
                                    end
                                end
                            end
                        end
                    end

                    if target then
                        local targetPos = target.Position + TWEEN_HEIGHT_OFFSET
                        local tween = TweenService:Create(hrp, TweenInfo.new(0.1), {CFrame = CFrame.new(targetPos)})
                        tween:Play()
                        tween.Completed:Wait()
                    end

                    local tool = player.Backpack:FindFirstChild("Hunter's Grasp")
                    local remote = char:FindFirstChild("Communicate")
                    if tool and remote then
                        local args = {
                            [1] = {
                                ["Tool"] = tool,
                                ["Goal"] = "Console Move"
                            }
                        }
                        remote:FireServer(unpack(args))
                    end

                    isTweening = false
                    task.delay(15, function()
                        cooldown = false
                    end)
                end)
            elseif not isPlaying then
                lastPlaying = false
            end
        end)
    end
})

TonghopTab:Toggle({
    Title = 'Hunter\'s Grasp + Dash',
    Value = false,
    CallBack = function(state)
        print("Hunter's Grasp + Dash Toggle:", state)
        _G.GraspDashEnabled = state

        local player = game.Players.LocalPlayer
        local animationIdToDetect = "rbxassetid://12309835105"
        local detected = false

        if _G.GraspDashConnection then
            _G.GraspDashConnection:Disconnect()
            _G.GraspDashConnection = nil
        end

        if state then
            local Character = player.Character or player.CharacterAdded:Wait()
            local Humanoid = Character:WaitForChild("Humanoid")

            _G.GraspDashConnection = Humanoid.AnimationPlayed:Connect(function(track)
                if track.Animation.AnimationId == animationIdToDetect and not detected then
                    detected = true

                    task.delay(0.8, function()
                        local char = player.Character
                        if not char then return end

                        local root = char:FindFirstChild("HumanoidRootPart")
                        if root then
                            local backVec = -root.CFrame.LookVector * 4.5
                            root.CFrame = root.CFrame + backVec
                        end

                        local remote = char:FindFirstChild("Communicate")
                        if remote then
                            local args = {
                                {
                                    Dash = Enum.KeyCode.W,
                                    Key = Enum.KeyCode.Q,
                                    Goal = "KeyPress"
                                }
                            }
                            remote:FireServer(unpack(args))
                        end

                        task.wait(1.5)
                        detected = false
                    end)
                end
            end)
        end
    end
})

TonghopTab:Toggle({
    Title = 'Auto Surf',
    Value = false,
    CallBack = function(state)
        print("Auto Surf Toggle:", state)
        _G.AutoSurfEnabled = state

        local TweenService = game:GetService("TweenService")
        local player = game.Players.LocalPlayer
        local TARGET_ANIM_ID = "rbxassetid://12309835105"
        local isTweening = false

        if _G.AutoSurfRenderConnection then
            _G.AutoSurfRenderConnection:Disconnect()
            _G.AutoSurfRenderConnection = nil
        end
        if _G.AutoSurfCharConnection then
            _G.AutoSurfCharConnection:Disconnect()
            _G.AutoSurfCharConnection = nil
        end

        if not state then return end

        local function getCharacter()
            return player.Character or player.CharacterAdded:Wait()
        end

        local function isTargetAnimPlaying()
            local char = getCharacter()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if not humanoid then return false end

            for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                if track.Animation and track.Animation.AnimationId == TARGET_ANIM_ID then
                    return true
                end
            end
            return false
        end

        _G.AutoSurfRenderConnection = RunService.RenderStepped:Connect(function()
            if not _G.AutoSurfEnabled or isTweening then return end
            if isTargetAnimPlaying() then
                isTweening = true
                task.wait(0.6)

                local char = getCharacter()
                local root = char:FindFirstChild("HumanoidRootPart")
                if root then
                    root.Anchored = false
                    local forward = root.CFrame.LookVector.Unit
                    local tween = TweenService:Create(root, TweenInfo.new(0.78), {CFrame = root.CFrame + (forward * 50)})
                    tween:Play()
                    tween.Completed:Wait()
                end

                task.wait(1.5)
                isTweening = false
            end
        end)

        _G.AutoSurfCharConnection = player.CharacterAdded:Connect(function()
            task.wait(1)
            getCharacter()
        end)
    end
})

TonghopTab:Toggle({
    Title = 'Auto Whirlwind Dunk',
    Value = false,
    CallBack = function(isEnabled)
        print("Auto Whirlwind Dunk:", isEnabled)
        _G.WhirlwindDunkEnabled = isEnabled

        local lp = Players.LocalPlayer

        if _G.TeleportAnimConnection then
            _G.TeleportAnimConnection:Disconnect()
            _G.TeleportAnimConnection = nil
        end

        if isEnabled then
            local isTeleporting = false
            local lastTrack = nil

            _G.TeleportAnimConnection = RunService.RenderStepped:Connect(function()
                local character = lp.Character
                if not character or isTeleporting then return end

                local humanoid = character:FindFirstChildWhichIsA("Humanoid")
                local root = character:FindFirstChild("HumanoidRootPart")
                if not humanoid or not root then return end

                for _, track in ipairs(humanoid:GetPlayingAnimationTracks()) do
                    if track.Animation and track.Animation.AnimationId == "rbxassetid://12296113986" then
                        if lastTrack == track then return end
                        lastTrack = track

                        isTeleporting = true
                        task.delay(1, function()
                            if root and root.Parent then
                                root.CFrame = root.CFrame + Vector3.new(0, 70, 0)
                            end
                            isTeleporting = false
                        end)
                        break
                    end
                end

                if lastTrack and not lastTrack.IsPlaying then
                    lastTrack = nil
                end
            end)
        end
    end
})

-- Saitama Auto Tab
TonghopTab:Section('Saitama Techs')

TonghopTab:Toggle({
    Title = 'Reflex Tech',
    Value = false,
    CallBack = function(state)
        toggles.ReflexTech = state
        if state then
            task.spawn(function()
                local v1 = game.Players.LocalPlayer
                local vu5 = workspace:WaitForChild("Live"):WaitForChild(v1.Name)
                local vu6 = false
                local vu7 = {}
                local vu8 = "rbxassetid://10471336737"
                local vu9 = game:GetService("Players")
                local vu10 = game:GetService("RunService")
                local vu11 = vu9.LocalPlayer
                
                local function vu22()
                    local v12 = vu11.Character
                    if not (v12 and v12:FindFirstChild("HumanoidRootPart")) then return nil end
                    local v13 = v12.HumanoidRootPart
                    local v14 = math.huge
                    local v19 = nil
                    for _, v20 in ipairs(vu9:GetPlayers()) do
                        if v20 ~= vu11 and v20.Character and v20.Character:FindFirstChild("HumanoidRootPart") then
                            local v21 = (v13.Position - v20.Character.HumanoidRootPart.Position).Magnitude
                            if v21 < v14 then v19 = v20 v14 = v21 end
                        end
                    end
                    return v19
                end
                
                local function vu32()
                    local v23 = vu11.Character or vu11.CharacterAdded:Wait()
                    local vu24 = v23:WaitForChild("Humanoid")
                    local vu25 = v23:WaitForChild("HumanoidRootPart")
                    vu24.AutoRotate = false
                    local vu27 = vu24:GetPropertyChangedSignal("AutoRotate"):Connect(function() if vu24.AutoRotate == true then vu24.AutoRotate = false end end)
                    local vu28 = vu22()
                    if vu28 then
                        local vu29 = tick()
                        local vu30 = nil
                        vu30 = vu10.RenderStepped:Connect(function()
                            if tick() - vu29 <= 3 then
                                if vu28.Character and vu28.Character:FindFirstChild("HumanoidRootPart") then
                                    local v31 = vu28.Character.HumanoidRootPart.Position
                                    vu25.CFrame = CFrame.lookAt(vu25.Position, Vector3.new(v31.X, vu25.Position.Y, v31.Z))
                                end
                            else
                                vu30:Disconnect()
                                vu27:Disconnect()
                                vu24.AutoRotate = true
                            end
                        end)
                    end
                end
                
                local function vu38()
                    local vu33 = game:GetService("VirtualInputManager")
                    vu33:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                    task.delay(1, function() vu33:SendKeyEvent(false, Enum.KeyCode.Space, false, game) end)
                    task.wait(0.29)
                    local v35 = {{Mobile = true, Goal = "LeftClick"}}
                    game.Players.LocalPlayer.Character.Communicate:FireServer(unpack(v35))
                    task.wait(0.1)
                    task.wait(0.5)
                    local v36 = {{Goal = "LeftClickRelease", Mobile = true}}
                    game.Players.LocalPlayer.Character.Communicate:FireServer(unpack(v36))
                    vu32()
                    local v37 = {{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}
                    game.Players.LocalPlayer.Character.Communicate:FireServer(unpack(v37))
                end
                
                local function vu50()
                    local v49 = vu5:GetAttributeChangedSignal("Combo"):Connect(function()
                        if vu5:GetAttribute("Combo") == 4 then
                            local vu39 = vu11.Character or vu11.CharacterAdded:Wait()
                            local v43 = vu39:WaitForChild("Humanoid").AnimationPlayed:Connect(function(p42)
                                if p42.Animation and p42.Animation.AnimationId == vu8 then vu38(vu39) end
                            end)
                            table.insert(vu7, v43)
                            for _, v48 in ipairs(vu39:WaitForChild("Humanoid"):GetPlayingAnimationTracks()) do
                                if v48.Animation and v48.Animation.AnimationId == vu8 then vu38(vu39) break end
                            end
                        end
                    end)
                    table.insert(vu7, v49)
                end
                
                vu50()
                while toggles.ReflexTech do task.wait(1) end
                for _, v54 in ipairs(vu7) do v54:Disconnect() end
            end)
        end
    end
})

TonghopTab:Toggle({
    Title = 'Skill 4 + Dash',
    Value = false,
    CallBack = function(state)
        print("Skill 4 + Dash Toggle:", state)
        _G.UpperCutDashEnabled = state

        local player = game.Players.LocalPlayer
        local animationId = "rbxassetid://12510170988"

        local function FireDashRemote()
            local comm = player.Character and player.Character:FindFirstChild("Communicate")
            if comm then
                local args = {
                    {
                        Dash = Enum.KeyCode.W,
                        Key = Enum.KeyCode.Q,
                        Goal = "KeyPress"
                    }
                }
                comm:FireServer(unpack(args))
            end
        end

        if _G.UpperCutDashConnection then
            _G.UpperCutDashConnection:Disconnect()
            _G.UpperCutDashConnection = nil
        end

        if state then
            local Character = player.Character or player.CharacterAdded:Wait()
            local Humanoid = Character:WaitForChild("Humanoid")

            _G.UpperCutDashConnection = Humanoid.AnimationPlayed:Connect(function(track)
                if track.Animation and track.Animation.AnimationId == animationId then
                    task.delay(1, function()
                        if track.IsPlaying then
                            FireDashRemote()
                        end
                    end)
                end
            end)
        end
    end
})

-- Tatsumaki Auto Tab
TonghopTab:Section('Tatsumaki Techs')

TonghopTab:Toggle({
    Title = '3m1 + Crushing Pull',
    Value = false,
    CallBack = function(Enabled)
        print("Final Pull Tech:", Enabled)
        _G.FinalPullEnabled = Enabled

        if _G.FinalPull_Connection then
            _G.FinalPull_Connection:Disconnect()
            _G.FinalPull_Connection = nil
        end
        if _G.FinalPull_CharAdded then
            _G.FinalPull_CharAdded:Disconnect()
            _G.FinalPull_CharAdded = nil
        end

        if not Enabled then return end

        local VirtualInputManager = game:GetService("VirtualInputManager")
        local player = Players.LocalPlayer
        local FPT_Running = false

        local function HookFinalPull(character)
            local humanoid = character:WaitForChild("Humanoid")

            if _G.FinalPull_Connection then
                _G.FinalPull_Connection:Disconnect()
            end

            _G.FinalPull_Connection = humanoid.AnimationPlayed:Connect(function(track)
                if not _G.FinalPullEnabled then return end
                if FPT_Running then return end

                local id = track.Animation.AnimationId
                if id == "rbxassetid://16515448089" then
                    FPT_Running = true

                    task.wait(0.2)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Q, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Q, false, game)

                    task.wait(0.7)
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.One, false, game)
                    task.wait(0.05)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.One, false, game)

                    task.delay(5, function()
                        FPT_Running = false
                    end)

                elseif id == "rbxassetid://10479335397" then
                    FPT_Running = true
                    task.delay(5, function()
                        FPT_Running = false
                    end)
                end
            end)
        end

        if player.Character then
            HookFinalPull(player.Character)
        end

        _G.FinalPull_CharAdded = player.CharacterAdded:Connect(HookFinalPull)
    end
})

-- Misc Auto Tab (All Character)
TonghopTab:Section('All Character Techs')

TonghopTab:Toggle({
    Title = 'LoopDash Cancel',
    Value = false,
    CallBack = function(state)
        toggles.LoopDashCancel = state
        
        local HEXED_CONFIG = {
            animIds = {
                "rbxassetid://10503381238",
                "rbxassetid://13379003796"
            },
            delay1 = 0.32,
            delay2 = 0.25,
            lockDuration = 0.35
        }
        
        local LOOP_CONFIG = {
            animDetectId = "10503381238",
            waitDetect = 3,
            waitJump = 0,
            waitRemote = 1,
            lockDuration = 15,
            targetRadius = 50,
            cooldown = 50,
            responsiveness = 483,
            jumpVelocity = 62
        }
        
        local hexedConnection = nil
        local hexedHeartbeat = nil
        local hexedCharConn = nil
        local loopConnection = nil
        local loopCharConn = nil
        local loopStopLock = nil
        local currentHexedAtt = nil
        local currentHexedAlign = nil
        local loopDebounce = false
        
        local function getNearestTarget()
            local char = LocalPlayer.Character
            if not (char and char:FindFirstChild("HumanoidRootPart")) then
                return nil
            end
            local rootPos = char.HumanoidRootPart.Position
            local bestTarget = nil
            local bestDist = nil
            local live = workspace:FindFirstChild("Live")
            if live then
                for _, model in ipairs(live:GetChildren()) do
                    if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and 
                       (model.Name == "Weakest Dummy" or (Players:GetPlayerFromCharacter(model) and model ~= char)) then
                        local dist = (model.HumanoidRootPart.Position - rootPos).Magnitude
                        if not bestDist or dist < bestDist then
                            bestDist = dist
                            bestTarget = model
                        end
                    end
                end
            end
            return bestTarget
        end
        
        local function disableCollision(character)
            local descendants = character:GetDescendants()
            for _, part in ipairs(descendants) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            task.delay(1.2, function()
                if not toggles.LoopDashCancel then return end
                for _, part in ipairs(descendants) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end)
        end
        
        local function cleanupHexed()
            if hexedConnection then
                pcall(function() hexedConnection:Disconnect() end)
                hexedConnection = nil
            end
            if hexedHeartbeat then
                pcall(function() hexedHeartbeat:Disconnect() end)
                hexedHeartbeat = nil
            end
            if currentHexedAlign then
                pcall(function() currentHexedAlign:Destroy() end)
                currentHexedAlign = nil
            end
            if currentHexedAtt then
                pcall(function() currentHexedAtt:Destroy() end)
                currentHexedAtt = nil
            end
            local char = LocalPlayer.Character
            if char then
                local oldAtt = char:FindFirstChild("Hexed_Att")
                if oldAtt then pcall(function() oldAtt:Destroy() end) end
                local oldAlign = char:FindFirstChildOfClass("AlignOrientation")
                if oldAlign then pcall(function() oldAlign:Destroy() end) end
            end
        end
        
        local function startHexed()
            if hexedConnection then
                pcall(function() hexedConnection:Disconnect() end)
                hexedConnection = nil
            end
            
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local humanoid = char:WaitForChild("Humanoid")
            
            hexedConnection = humanoid.AnimationPlayed:Connect(function(animTrack)
                if not toggles.LoopDashCancel then return end
                
                local anim = animTrack.Animation
                if anim and table.find(HEXED_CONFIG.animIds, anim.AnimationId) then
                    disableCollision(char)
                    task.wait(HEXED_CONFIG.delay1)
                    
                    local remote = char:FindFirstChild("Communicate")
                    if remote then
                        remote:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                    end
                    
                    task.wait(HEXED_CONFIG.delay2)
                    
                    local rootPart = char:FindFirstChild("HumanoidRootPart")
                    if rootPart then
                        local oldAtt = rootPart:FindFirstChild("Hexed_Att")
                        if oldAtt then pcall(function() oldAtt:Destroy() end) end
                        local oldAlign = rootPart:FindFirstChildOfClass("AlignOrientation")
                        if oldAlign then pcall(function() oldAlign:Destroy() end) end
                        
                        currentHexedAtt = Instance.new("Attachment")
                        currentHexedAtt.Name = "Hexed_Att"
                        currentHexedAtt.Parent = rootPart
                        
                        currentHexedAlign = Instance.new("AlignOrientation")
                        currentHexedAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
                        currentHexedAlign.Attachment0 = currentHexedAtt
                        currentHexedAlign.MaxTorque = math.huge
                        currentHexedAlign.Responsiveness = 1000
                        currentHexedAlign.RigidityEnabled = false
                        currentHexedAlign.Parent = rootPart
                        
                        local startTime = tick()
                        hexedHeartbeat = RunService.Heartbeat:Connect(function()
                            if not toggles.LoopDashCancel then
                                if hexedHeartbeat then hexedHeartbeat:Disconnect() end
                                return
                            end
                            if HEXED_CONFIG.lockDuration >= tick() - startTime then
                                local target = getNearestTarget()
                                if target and target:FindFirstChild("HumanoidRootPart") then
                                    local targetPos = target.HumanoidRootPart.Position
                                    local newCF = CFrame.lookAt(rootPart.Position, Vector3.new(targetPos.X, rootPart.Position.Y, targetPos.Z)) * CFrame.Angles(math.rad(30), 100, -100)
                                    rootPart.CFrame = newCF
                                    if currentHexedAlign then currentHexedAlign.CFrame = newCF end
                                end
                            else
                                if hexedHeartbeat then hexedHeartbeat:Disconnect() end
                                if currentHexedAlign then currentHexedAlign:Destroy() end
                                if currentHexedAtt then currentHexedAtt:Destroy() end
                                hexedHeartbeat = nil
                                currentHexedAlign = nil
                                currentHexedAtt = nil
                            end
                        end)
                    end
                end
            end)
        end
        
        local function getCharacterParts()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root then return char, hum, root end
            end
            return nil, nil, nil
        end
        
        local function fireDashQW()
            local char = LocalPlayer.Character
            if char then
                local remote = char:FindFirstChild("Communicate")
                if remote then
                    pcall(function()
                        remote:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                    end)
                end
            end
        end
        
        local function findBestTarget(radius)
            radius = radius or LOOP_CONFIG.targetRadius
            local live = workspace:FindFirstChild("Live")
            if not live then return nil end
            
            local _, _, root = getCharacterParts()
            if not root then return nil end
            
            local bestTarget = nil
            local bestDist = radius
            
            for _, model in ipairs(live:GetChildren()) do
                if model:IsA("Model") and model ~= LocalPlayer.Character then
                    local targetRoot = model:FindFirstChild("HumanoidRootPart")
                    local targetHum = model:FindFirstChildOfClass("Humanoid")
                    if targetRoot and targetHum and targetHum.Health > 0 then
                        local dist = (targetRoot.Position - root.Position).Magnitude
                        if dist <= bestDist then
                            bestDist = dist
                            bestTarget = targetRoot
                        end
                    end
                end
            end
            return bestTarget
        end
        
        local function startHorizontalLock(target, duration, responsiveness)
            if not target or not target.Parent then return nil end
            
            local _, hum, root = getCharacterParts()
            if not root or not hum then return nil end
            
            local resp = math.clamp(responsiveness or LOOP_CONFIG.responsiveness, 1, 10000)
            local startTime = tick()
            
            local connection
            connection = RunService.RenderStepped:Connect(function(deltaTime)
                if not toggles.LoopDashCancel then
                    if connection then connection:Disconnect() end
                    return
                end
                if not target or not target.Parent or not root or not root.Parent then
                    if connection then connection:Disconnect() end
                    return
                end
                
                local currentPos = root.Position
                local targetPos = Vector3.new(target.Position.X, currentPos.Y, target.Position.Z)
                
                if (targetPos - currentPos).Magnitude >= 0.001 then
                    local targetCF = CFrame.new(currentPos, targetPos)
                    local alpha = math.clamp(1 - math.exp(-0.02 * resp * deltaTime), 0, 1)
                    local newCF = root.CFrame:Lerp(targetCF, alpha)
                    root.CFrame = CFrame.new(currentPos) * CFrame.fromMatrix(Vector3.new(), newCF.RightVector, newCF.UpVector)
                end
                
                if tick() - startTime >= duration then
                    if connection then connection:Disconnect() end
                end
            end)
            
            return function()
                if connection then pcall(function() connection:Disconnect() end) end
            end
        end
        
        local function runLoopSequence()
            if loopDebounce or not toggles.LoopDashCancel then return end
            loopDebounce = true
            
            task.wait(LOOP_CONFIG.waitDetect / 10)
            
            if not toggles.LoopDashCancel then
                loopDebounce = false
                return
            end
            
            local _, hum, root = getCharacterParts()
            if hum and root then
                local originalAutoRotate = hum.AutoRotate
                hum.AutoRotate = false
                
                root.Velocity = Vector3.new(root.Velocity.X, LOOP_CONFIG.jumpVelocity, root.Velocity.Z)
                task.wait(LOOP_CONFIG.waitJump / 10)
                
                fireDashQW()
                task.wait(LOOP_CONFIG.waitRemote / 10)
                
                local target = findBestTarget()
                if target then
                    if loopStopLock then loopStopLock() end
                    loopStopLock = startHorizontalLock(target, LOOP_CONFIG.lockDuration / 10, LOOP_CONFIG.responsiveness)
                end
                
                local endTime = tick() + (LOOP_CONFIG.lockDuration / 10)
                task.spawn(function()
                    while tick() < endTime and toggles.LoopDashCancel do
                        if hum and hum.Parent then
                            hum.AutoRotate = false
                        end
                        RunService.Heartbeat:Wait()
                    end
                    if hum and hum.Parent then
                        hum.AutoRotate = originalAutoRotate
                    end
                end)
            end
            
            local cdTime = LOOP_CONFIG.cooldown / 10
            task.wait(cdTime)
            loopDebounce = false
        end
        
        local function onLoopAnimation(animationTrack)
            if not toggles.LoopDashCancel or loopDebounce then return end
            
            local animId = tostring(animationTrack.Animation.AnimationId)
            if animId:find(LOOP_CONFIG.animDetectId) then
                task.spawn(runLoopSequence)
            end
        end
        
        local function startLoop()
            if loopConnection then
                pcall(function() loopConnection:Disconnect() end)
                loopConnection = nil
            end
            
            local char = LocalPlayer.Character
            if not char then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            
            loopConnection = hum.AnimationPlayed:Connect(onLoopAnimation)
        end
        
        local function cleanupAll()
            cleanupHexed()
            if hexedCharConn then
                pcall(function() hexedCharConn:Disconnect() end)
                hexedCharConn = nil
            end
            
            if loopConnection then
                pcall(function() loopConnection:Disconnect() end)
                loopConnection = nil
            end
            if loopCharConn then
                pcall(function() loopCharConn:Disconnect() end)
                loopCharConn = nil
            end
            if loopStopLock then
                pcall(function() loopStopLock() end)
                loopStopLock = nil
            end
            
            loopDebounce = false
            
            local _, hum = getCharacterParts()
            if hum then
                pcall(function() hum.AutoRotate = true end)
            end
        end
        
        local function startAll()
            cleanupAll()
            
            startHexed()
            hexedCharConn = LocalPlayer.CharacterAdded:Connect(function()
                if toggles.LoopDashCancel then
                    task.wait(0.5)
                    startHexed()
                end
            end)
            
            startLoop()
            loopCharConn = LocalPlayer.CharacterAdded:Connect(function()
                if toggles.LoopDashCancel then
                    task.wait(0.5)
                    startLoop()
                end
            end)
        end
        
        if state then
            startAll()
        else
            cleanupAll()
        end
    end
})

TonghopTab:Toggle({
    Title = 'Hexed Tech',
    Value = false,
    CallBack = function(state)
        toggles.HexedTech = state
        
        local vu1 = {
            "rbxassetid://10503381238",
            "rbxassetid://13379003796"
        }
        local vu2 = 0.32
        local vu3 = 0.25
        local vu4 = 0.35
        
        local vu9 = nil
        local heartbeatConn = nil
        local charAddedConn = nil
        local alignObj = nil
        local attObj = nil
        
        local vu10 = game:GetService("Players")
        local vu11 = game:GetService("RunService")
        local vu12 = vu10.LocalPlayer
        
        local function vu23()
            local v13 = vu12.Character
            if not (v13 and v13:FindFirstChild("HumanoidRootPart")) then
                return nil
            end
            local v14 = v13.HumanoidRootPart.Position
            local v15 = nil
            local v16 = nil
            local v17 = workspace:FindFirstChild("Live")
            if v17 then
                for _, v21 in ipairs(v17:GetChildren()) do
                    if v21:IsA("Model") and v21:FindFirstChild("HumanoidRootPart") and (v21.Name == "Weakest Dummy" or (vu10:GetPlayerFromCharacter(v21) and v21 ~= vu12.Character)) then
                        local v22 = (v21.HumanoidRootPart.Position - v14).Magnitude
                        if not v16 or v22 < v16 then
                            v16 = v22
                            v15 = v21
                        end
                    end
                end
            end
            return v15
        end
        
        local function vu34(p24)
            local vu25 = p24:GetDescendants()
            for _, v29 in ipairs(vu25) do
                if v29:IsA("BasePart") then
                    v29.CanCollide = false
                end
            end
            task.delay(1.2, function()
                if not toggles.HexedTech then return end
                for _, v33 in ipairs(vu25) do
                    if v33:IsA("BasePart") then
                        v33.CanCollide = true
                    end
                end
            end)
        end
        
        local function cleanup()
            if vu9 then
                pcall(function() vu9:Disconnect() end)
                vu9 = nil
            end
            if heartbeatConn then
                pcall(function() heartbeatConn:Disconnect() end)
                heartbeatConn = nil
            end
            if alignObj then
                pcall(function() alignObj:Destroy() end)
                alignObj = nil
            end
            if attObj then
                pcall(function() attObj:Destroy() end)
                attObj = nil
            end
            local char = vu12.Character
            if char then
                local oldAtt = char:FindFirstChild("Hexed_Att")
                if oldAtt then pcall(function() oldAtt:Destroy() end) end
                local oldAlign = char:FindFirstChildOfClass("AlignOrientation")
                if oldAlign then pcall(function() oldAlign:Destroy() end) end
            end
        end
        
        local function vu49()
            if vu9 then
                pcall(function() vu9:Disconnect() end)
                vu9 = nil
            end
            if heartbeatConn then
                pcall(function() heartbeatConn:Disconnect() end)
                heartbeatConn = nil
            end
            
            local vu35 = vu12.Character or vu12.CharacterAdded:Wait()
            vu9 = vu35:WaitForChild("Humanoid").AnimationPlayed:Connect(function(p37)
                if not toggles.HexedTech then return end
                
                local v38 = p37.Animation
                if v38 and table.find(vu1, v38.AnimationId) then
                    vu34(vu35)
                    task.wait(vu2)
                    
                    local v39 = {
                        {
                            Dash = Enum.KeyCode.W,
                            Key = Enum.KeyCode.Q,
                            Goal = "KeyPress"
                        }
                    }
                    local v40 = vu35:FindFirstChild("Communicate")
                    if v40 then
                        v40:FireServer(unpack(v39))
                    end
                    
                    task.wait(vu3)
                    
                    local vu41 = vu35:FindFirstChild("HumanoidRootPart")
                    if vu41 then
                        local oldAtt = vu41:FindFirstChild("Hexed_Att")
                        if oldAtt then pcall(function() oldAtt:Destroy() end) end
                        local oldAlign = vu41:FindFirstChildOfClass("AlignOrientation")
                        if oldAlign then pcall(function() oldAlign:Destroy() end) end
                        
                        attObj = Instance.new("Attachment")
                        attObj.Name = "Hexed_Att"
                        attObj.Parent = vu41
                        
                        alignObj = Instance.new("AlignOrientation")
                        alignObj.Mode = Enum.OrientationAlignmentMode.OneAttachment
                        alignObj.Attachment0 = attObj
                        alignObj.MaxTorque = math.huge
                        alignObj.Responsiveness = 1000
                        alignObj.RigidityEnabled = false
                        alignObj.Parent = vu41
                        
                        local vu44 = tick()
                        heartbeatConn = vu11.Heartbeat:Connect(function()
                            if not toggles.HexedTech then 
                                if heartbeatConn then heartbeatConn:Disconnect() end
                                return 
                            end
                            if vu4 >= tick() - vu44 then
                                local v46 = vu23()
                                if v46 and v46:FindFirstChild("HumanoidRootPart") then
                                    local v47 = v46.HumanoidRootPart.Position
                                    local v48 = CFrame.lookAt(vu41.Position, Vector3.new(v47.X, vu41.Position.Y, v47.Z)) * CFrame.Angles(math.rad(30), 100, -100)
                                    vu41.CFrame = v48
                                    if alignObj then alignObj.CFrame = v48 end
                                end
                            else
                                if heartbeatConn then heartbeatConn:Disconnect() end
                                if alignObj then alignObj:Destroy() end
                                if attObj then attObj:Destroy() end
                                heartbeatConn = nil
                                alignObj = nil
                                attObj = nil
                            end
                        end)
                    end
                end
            end)
        end
        
        if state then
            cleanup()
            vu49()
            charAddedConn = vu12.CharacterAdded:Connect(function()
                if toggles.HexedTech then
                    task.wait(0.5)
                    vu49()
                end
            end)
            _G.HexedCharAddedConn = charAddedConn
        else
            cleanup()
            if charAddedConn then
                pcall(function() charAddedConn:Disconnect() end)
                charAddedConn = nil
            end
            if _G.HexedCharAddedConn then
                _G.HexedCharAddedConn = nil
            end
            local char = vu12.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function() hum.AutoRotate = true end)
                end
            end
        end
    end
})

TonghopTab:Toggle({
    Title = 'Lix Tech',
    Value = false,
    CallBack = function(state)
        toggles.LixTech = state
        
        local LIX_CONFIG = {
            delay = 0.3,
            minDelay = 0.05,
            maxDelay = 2,
            step = 0.05
        }
        
        local ANIMATION_IDS = {
            ["13379003796"] = true,
            ["10503381238"] = true
        }
        
        local isRunning = false
        local lixConnection = nil
        local charAddedConnection = nil
        local savedStats = nil
        
        local function findMovemeBodyVelocity()
            if not getnilinstances then return nil end
            for _, inst in pairs(getnilinstances()) do
                if inst and inst.ClassName == "BodyVelocity" and inst.Name == "moveme" then
                    return inst
                end
            end
            return nil
        end
        
        local function saveCurrentStats(humanoid)
            if not humanoid then return nil end
            return {
                WalkSpeed = humanoid.WalkSpeed,
                JumpPower = humanoid.JumpPower,
                PlatformStand = humanoid.PlatformStand,
                AutoRotate = humanoid.AutoRotate
            }
        end
        
        local function restoreStats(humanoid, stats)
            if not humanoid or not stats then return end
            pcall(function()
                humanoid.WalkSpeed = stats.WalkSpeed or 16
                humanoid.JumpPower = stats.JumpPower or 50
                humanoid.PlatformStand = stats.PlatformStand or false
                humanoid.AutoRotate = stats.AutoRotate or true
            end)
        end
        
        local function handleAnimation(animationTrack, character, humanoid, rootPart)
            if not toggles.LixTech then return end
            if isRunning then return end
            
            local animId = tostring(animationTrack.Animation.AnimationId)
            local idMatch = animId:match("%d+")
            
            if idMatch and ANIMATION_IDS[idMatch] then
                isRunning = true
                
                local originalStats = saveCurrentStats(humanoid)
                
                task.wait(LIX_CONFIG.delay)
                
                local communicate = character:FindFirstChild("Communicate")
                if communicate then
                    pcall(function()
                        communicate:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                    end)
                end
                
                local movemeBV = findMovemeBodyVelocity()
                local bvParent = nil
                if movemeBV then
                    bvParent = movemeBV.Parent
                    pcall(function() movemeBV.Parent = nil end)
                end
                
                if communicate then
                    pcall(function()
                        communicate:FireServer(unpack({{Goal = "delete bv", BV = movemeBV}}))
                    end)
                end
                
                task.wait(0.3)
                
                if rootPart then
                    pcall(function()
                        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
                    end)
                end
                
                if movemeBV and bvParent then
                    pcall(function() movemeBV.Parent = bvParent end)
                end
                
                restoreStats(humanoid, originalStats)
                
                task.wait(0.4)
                
                if rootPart and rootPart.Parent then
                    pcall(function()
                        rootPart.CFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
                    end)
                end
                
                task.wait(0.15)
                isRunning = false
            end
        end
        
        local function setupCharacter(character)
            if not character then return end
            
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not humanoid then return end
            
            if lixConnection then
                pcall(function() lixConnection:Disconnect() end)
                lixConnection = nil
            end
            
            lixConnection = humanoid.AnimationPlayed:Connect(function(animationTrack)
                if toggles.LixTech then
                    handleAnimation(animationTrack, character, humanoid, rootPart)
                end
            end)
        end
        
        if state then
            local character = LocalPlayer.Character
            if character then
                setupCharacter(character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.LixTech then
                    task.wait(0.3)
                    setupCharacter(newChar)
                end
            end)
            
            _G.LixTechConnection = lixConnection
            _G.LixCharAddedConn = charAddedConnection
            
        else
            if lixConnection then
                pcall(function() lixConnection:Disconnect() end)
                lixConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            if _G.LixTechConnection then
                _G.LixTechConnection = nil
            end
            if _G.LixCharAddedConn then
                _G.LixCharAddedConn = nil
            end
            isRunning = false
        end
    end
})

TonghopTab:Toggle({
    Title = 'Oreo Tech',
    Value = false,
    CallBack = function(state)
        toggles.OreoTech = state
        
        local OREO_CONFIG = {
            cooldown = 5,
            jumpPower = 57,
            forwardDistance = 3.5,
            cameraOffset = 2,
            waitJump = 0.421,
            waitRemote = 0.13,
            waitCameraFix = 0.16,
            waitAfterJump = 0.1
        }
        
        local TARGET_ANIMATIONS = {
            "rbxassetid://10503381238",
            "rbxassetid://13379003796"
        }
        
        local oreoConnection = nil
        local charAddedConnection = nil
        local canTrigger = true
        local isRunning = false
        
        local currentChar = nil
        local currentHumanoid = nil
        local currentRootPart = nil
        
        local function getRootPart()
            local char = LocalPlayer.Character
            if char then
                return char:FindFirstChild("HumanoidRootPart")
            end
            return nil
        end
        
        local function fixCameraBehind()
            local char = LocalPlayer.Character
            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")
            local camera = workspace.CurrentCamera
            
            if not rootPart or not humanoid or not camera then return end
            
            local originalAutoRotate = humanoid.AutoRotate
            humanoid.AutoRotate = false
            
            local reversedCFrame = rootPart.CFrame * CFrame.Angles(0, math.rad(180), 0)
            rootPart.CFrame = reversedCFrame
            
            local distance = (camera.CFrame.Position - reversedCFrame.Position).Magnitude
            camera.CFrame = CFrame.new(
                reversedCFrame.Position - reversedCFrame.LookVector * distance + Vector3.new(0, OREO_CONFIG.cameraOffset),
                reversedCFrame.Position
            )
            
            task.delay(0.5, function()
                if humanoid and humanoid.Parent then
                    humanoid.AutoRotate = originalAutoRotate
                end
            end)
        end
        
        local function jumpBoost()
            local rootPart = getRootPart()
            if rootPart then
                rootPart.AssemblyLinearVelocity = Vector3.new(0, OREO_CONFIG.jumpPower, 0)
            end
        end
        
        local function fireDashRemote()
            local char = LocalPlayer.Character
            if char then
                local remote = char:FindFirstChild("Communicate")
                if remote then
                    pcall(function()
                        remote:FireServer({
                            Dash = Enum.KeyCode.W,
                            Key = Enum.KeyCode.Q,
                            Goal = "KeyPress"
                        })
                    end)
                end
            end
        end
        
        local function moveForward()
            local rootPart = getRootPart()
            if rootPart then
                local forwardDir = rootPart.CFrame.LookVector.Unit
                rootPart.CFrame = rootPart.CFrame + forwardDir * OREO_CONFIG.forwardDistance
            end
        end
        
        local function executeSequence()
            if not toggles.OreoTech then return end
            if not canTrigger or isRunning then return end
            
            isRunning = true
            canTrigger = false
            
            task.spawn(function()
                task.wait(OREO_CONFIG.waitJump)
                
                jumpBoost()
                
                task.wait(OREO_CONFIG.waitRemote)
                
                fireDashRemote()
                
                fixCameraBehind()
                
                task.wait(OREO_CONFIG.waitCameraFix)
                fixCameraBehind()
                
                moveForward()
                
                isRunning = false
            end)
            
            task.delay(OREO_CONFIG.cooldown, function()
                if toggles.OreoTech then
                    canTrigger = true
                end
            end)
        end
        
        local function onAnimationPlayed(animationTrack)
            if not toggles.OreoTech then return end
            if not canTrigger then return end
            
            local anim = animationTrack.Animation
            if anim then
                local animId = anim.AnimationId
                for _, targetId in ipairs(TARGET_ANIMATIONS) do
                    if animId == targetId then
                        executeSequence()
                        break
                    end
                end
            end
        end
        
        local function connectToCharacter(character)
            if not character then return end
            
            if oreoConnection then
                pcall(function() oreoConnection:Disconnect() end)
                oreoConnection = nil
            end
            
            currentChar = character
            currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            currentRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not currentHumanoid then return end
            
            oreoConnection = currentHumanoid.AnimationPlayed:Connect(onAnimationPlayed)
        end
        
        if state then
            canTrigger = true
            isRunning = false
            
            if LocalPlayer.Character then
                connectToCharacter(LocalPlayer.Character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.OreoTech then
                    task.wait(0.3)
                    connectToCharacter(newChar)
                end
            end)
            
            _G.OreoConnection = oreoConnection
            _G.OreoCharConn = charAddedConnection
            
        else
            if oreoConnection then
                pcall(function() oreoConnection:Disconnect() end)
                oreoConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            
            canTrigger = true
            isRunning = false
            
            if currentHumanoid then
                pcall(function()
                    currentHumanoid.AutoRotate = true
                end)
            end
            
            _G.OreoConnection = nil
            _G.OreoCharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'Kiba Tech',
    Value = false,
    CallBack = function(state)
        toggles.KibaTech = state
        
        local KIBA_CONFIG = {
            cooldown = 7,
            delayBeforeStick = 0.35,
            followDuration = 0.3,
            lockAngle = 85,
            followOffset = 0.3
        }
        
        local ANIM_DETECT_ID = "10503381238"
        
        local kibaConnection = nil
        local charAddedConnection = nil
        local animatorConnection = nil
        local descendantConnection = nil
        local heartbeatConnection = nil
        local followConnection = nil
        local lastTriggerTime = 0
        local isRunning = false
        
        local currentChar = nil
        local currentHumanoid = nil
        local currentRootPart = nil
        
        local function findNearestTarget()
            if not currentRootPart then return nil end
            
            local bestTarget = nil
            local bestDist = KIBA_CONFIG.cooldown * 2
            
            for _, model in ipairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= currentChar then
                    local targetRoot = model:FindFirstChild("HumanoidRootPart")
                    local targetHum = model:FindFirstChildOfClass("Humanoid")
                    
                    if targetRoot and targetHum and targetHum.Health > 0 then
                        local dist = (currentRootPart.Position - targetRoot.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestTarget = targetRoot
                        end
                    end
                end
            end
            return bestTarget
        end
        
        local function findMovemeBodyVelocity()
            if not getnilinstances then return nil end
            for _, inst in pairs(getnilinstances()) do
                if inst and inst.ClassName == "BodyVelocity" and inst.Name == "moveme" then
                    return inst
                end
            end
            return nil
        end
        
        local function fireDashQW()
            if currentChar and currentChar:FindFirstChild("Communicate") then
                pcall(function()
                    currentChar.Communicate:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                end)
            end
        end
        
        local function fireDeleteBV()
            if currentChar and currentChar:FindFirstChild("Communicate") then
                local bv = findMovemeBodyVelocity()
                pcall(function()
                    currentChar.Communicate:FireServer(unpack({{Goal = "delete bv", BV = bv}}))
                end)
            end
        end
        
        local function destroyBodyMotions(character)
            if not character then return end
            for _, descendant in pairs(character:GetDescendants()) do
                local className = descendant.ClassName
                if className == "BodyVelocity" or className == "BodyPosition" or 
                   className == "BodyGyro" or className == "VectorForce" or
                   className == "AlignPosition" or className == "AlignOrientation" or
                   className == "LinearVelocity" or className == "AngularVelocity" then
                    pcall(function() descendant:Destroy() end)
                end
            end
        end
        
        local function saveHumanoidStats(humanoid)
            if not humanoid then return nil end
            return {
                WalkSpeed = humanoid.WalkSpeed,
                JumpPower = humanoid.JumpPower,
                PlatformStand = humanoid.PlatformStand,
                AutoRotate = pcall(function() return humanoid.AutoRotate end) and humanoid.AutoRotate or true
            }
        end
        
        local function restoreHumanoidStats(humanoid, stats)
            if not humanoid or not stats then return end
            pcall(function()
                humanoid.WalkSpeed = stats.WalkSpeed or 16
                humanoid.JumpPower = stats.JumpPower or 50
                humanoid.PlatformStand = stats.PlatformStand or false
                if stats.AutoRotate ~= nil then
                    humanoid.AutoRotate = stats.AutoRotate
                end
            end)
        end
        
        local function performStickDash()
            if not currentChar or not currentHumanoid or not currentRootPart then return end
            if isRunning then return end
            
            local target = findNearestTarget()
            if not target then return end
            
            isRunning = true
            
            local originalStats = saveHumanoidStats(currentHumanoid)
            
            pcall(function()
                currentHumanoid.WalkSpeed = 0
                currentHumanoid.JumpPower = 0
                currentHumanoid.PlatformStand = true
                currentHumanoid.AutoRotate = false
                currentRootPart.Velocity = Vector3.new(0, 0, 0)
                currentRootPart.RotVelocity = Vector3.new(0, 0, 0)
            end)
            
            destroyBodyMotions(currentChar)
            
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if currentRootPart then
                    pcall(function()
                        currentRootPart.Velocity = Vector3.new(0, 0, 0)
                        currentRootPart.RotVelocity = Vector3.new(0, 0, 0)
                    end)
                end
                if currentHumanoid then
                    pcall(function()
                        currentHumanoid.WalkSpeed = 0
                    end)
                end
            end)
            
            pcall(function() currentHumanoid:ChangeState(Enum.HumanoidStateType.Physics) end)
            
            currentRootPart.CFrame = currentRootPart.CFrame * CFrame.Angles(math.rad(KIBA_CONFIG.lockAngle), 0, 0)
            
            local startTime = tick()
            local followDuration = KIBA_CONFIG.followDuration
            followConnection = RunService.Heartbeat:Connect(function()
                if tick() - startTime < followDuration then
                    local targetRoot = target.Parent and target:FindFirstChild("HumanoidRootPart")
                    if targetRoot and currentRootPart then
                        local targetPos = targetRoot.Position
                        local lookDir = (targetPos - currentRootPart.Position).Unit
                        local offsetPos = targetPos - lookDir * KIBA_CONFIG.followOffset
                        currentRootPart.CFrame = CFrame.new(offsetPos) * CFrame.Angles(math.rad(KIBA_CONFIG.lockAngle), 0, 0)
                    end
                end
            end)
            
            task.delay(0.18, function()
                pcall(function()
                    fireDashQW()
                    fireDeleteBV()
                end)
            end)
            
            task.delay(0.3, function()
                pcall(function() currentHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end)
            
            local restoreDelay = followDuration + 0.4
            task.delay(restoreDelay, function()
                if heartbeatConnection then heartbeatConnection:Disconnect() end
                if followConnection then followConnection:Disconnect() end
                restoreHumanoidStats(currentHumanoid, originalStats)
                isRunning = false
            end)
        end
        
        local function tryTriggerTech()
            if not toggles.KibaTech then return end
            if isRunning then return end
            
            local now = tick()
            if now - lastTriggerTime >= KIBA_CONFIG.cooldown then
                lastTriggerTime = now
                task.spawn(performStickDash)
            end
        end
        
        local function onAnimationPlayed(animationTrack)
            if not toggles.KibaTech then return end
            
            local anim = animationTrack.Animation
            if anim then
                local animId = tostring(anim.AnimationId or "")
                if string.find(animId, ANIM_DETECT_ID, 1, true) then
                    tryTriggerTech()
                end
            end
        end
        
        local function connectToCharacter(character)
            if not character then return end
            
            if kibaConnection then pcall(function() kibaConnection:Disconnect() end) end
            if animatorConnection then pcall(function() animatorConnection:Disconnect() end) end
            if descendantConnection then pcall(function() descendantConnection:Disconnect() end) end
            
            currentChar = character
            currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            currentRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not currentHumanoid or not currentRootPart then return end
            
            kibaConnection = currentHumanoid.AnimationPlayed:Connect(onAnimationPlayed)
            
            local animator = currentHumanoid:FindFirstChildOfClass("Animator")
            if animator then
                animatorConnection = animator.AnimationPlayed:Connect(onAnimationPlayed)
            end
            
            descendantConnection = character.DescendantAdded:Connect(function(desc)
                if desc:IsA("Animation") then
                    local animId = tostring(desc.AnimationId or "")
                    if string.find(animId, ANIM_DETECT_ID, 1, true) then
                        tryTriggerTech()
                    end
                end
            end)
        end
        
        if state then
            lastTriggerTime = 0
            isRunning = false
            
            if LocalPlayer.Character then
                connectToCharacter(LocalPlayer.Character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.KibaTech then
                    task.wait(0.2)
                    connectToCharacter(newChar)
                end
            end)
            
            _G.KibaConnection = kibaConnection
            _G.KibaCharConn = charAddedConnection
            
        else
            if kibaConnection then
                pcall(function() kibaConnection:Disconnect() end)
                kibaConnection = nil
            end
            if animatorConnection then
                pcall(function() animatorConnection:Disconnect() end)
                animatorConnection = nil
            end
            if descendantConnection then
                pcall(function() descendantConnection:Disconnect() end)
                descendantConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            if heartbeatConnection then
                pcall(function() heartbeatConnection:Disconnect() end)
                heartbeatConnection = nil
            end
            if followConnection then
                pcall(function() followConnection:Disconnect() end)
                followConnection = nil
            end
            
            if currentHumanoid then
                pcall(function()
                    currentHumanoid.AutoRotate = true
                    currentHumanoid.WalkSpeed = 16
                end)
            end
            
            isRunning = false
            
            _G.KibaConnection = nil
            _G.KibaCharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'LoopDash',
    Value = false,
    CallBack = function(state)
        toggles.LoopDash = state
        
        local LOOP_CONFIG = {
            loopRework = false,
            loopReworkDebounce = false,
            loopReworkBlocked = false,
            loopReworkWaitDetect = 3,
            loopReworkWaitJump = 0,
            loopReworkWaitRemote = 1,
            loopReworkLockDuration = 15,
            loopReworkTargetRadius = 50,
            loopReworkCooldown = 50,
            loopReworkResponsiveness = 483,
            ForceJumpUpwardVelocity = 62
        }
        
        local ANIM_DETECT_ID = "10503381238"
        
        local loopConnection = nil
        local charAddedConnection = nil
        local stopLockFunction = nil
        local renderConnection = nil
        local isDebounce = false
        
        local function getCharacterParts()
            local char = LocalPlayer.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local root = char:FindFirstChild("HumanoidRootPart")
                if hum and root then return char, hum, root end
            end
            return nil, nil, nil
        end
        
        local function fireDashQW()
            local char = LocalPlayer.Character
            if char then
                local remote = char:FindFirstChild("Communicate")
                if remote then
                    pcall(function()
                        remote:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                    end)
                end
            end
        end
        
        local function findBestTarget(radius)
            radius = radius or LOOP_CONFIG.loopReworkTargetRadius
            local live = workspace:FindFirstChild("Live")
            if not live then return nil end
            
            local _, _, root = getCharacterParts()
            if not root then return nil end
            
            local bestTarget = nil
            local bestDist = radius
            
            for _, model in ipairs(live:GetChildren()) do
                if model:IsA("Model") and model ~= LocalPlayer.Character then
                    local targetRoot = model:FindFirstChild("HumanoidRootPart")
                    local targetHum = model:FindFirstChildOfClass("Humanoid")
                    if targetRoot and targetHum and targetHum.Health > 0 then
                        local dist = (targetRoot.Position - root.Position).Magnitude
                        if dist <= bestDist then
                            bestDist = dist
                            bestTarget = targetRoot
                        end
                    end
                end
            end
            return bestTarget
        end
        
        local function startHorizontalLock(target, duration, responsiveness)
            if not target or not target.Parent then return nil end
            
            local _, hum, root = getCharacterParts()
            if not root or not hum then return nil end
            
            local resp = math.clamp(responsiveness or LOOP_CONFIG.loopReworkResponsiveness, 1, 10000)
            local startTime = tick()
            
            local connection
            connection = RunService.RenderStepped:Connect(function(deltaTime)
                if not LOOP_CONFIG.loopRework then
                    if connection then connection:Disconnect() end
                    return
                end
                if not target or not target.Parent or not root or not root.Parent then
                    if connection then connection:Disconnect() end
                    return
                end
                
                local currentPos = root.Position
                local targetPos = Vector3.new(target.Position.X, currentPos.Y, target.Position.Z)
                
                if (targetPos - currentPos).Magnitude >= 0.001 then
                    local targetCF = CFrame.new(currentPos, targetPos)
                    local alpha = math.clamp(1 - math.exp(-0.02 * resp * deltaTime), 0, 1)
                    local newCF = root.CFrame:Lerp(targetCF, alpha)
                    root.CFrame = CFrame.new(currentPos) * CFrame.fromMatrix(Vector3.new(), newCF.RightVector, newCF.UpVector)
                end
                
                if tick() - startTime >= duration then
                    if connection then connection:Disconnect() end
                end
            end)
            
            return function()
                if connection then pcall(function() connection:Disconnect() end) end
            end
        end
        
        local function cleanup()
            if loopConnection then
                pcall(function() loopConnection:Disconnect() end)
                loopConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            if renderConnection then
                pcall(function() renderConnection:Disconnect() end)
                renderConnection = nil
            end
            if stopLockFunction then
                pcall(function() stopLockFunction() end)
                stopLockFunction = nil
            end
            local _, hum = getCharacterParts()
            if hum then
                pcall(function() hum.AutoRotate = true end)
            end
        end
        
        local function runSequence()
            if not LOOP_CONFIG.loopRework then return end
            if LOOP_CONFIG.loopReworkDebounce then return end
            LOOP_CONFIG.loopReworkDebounce = true
            
            task.wait(LOOP_CONFIG.loopReworkWaitDetect / 10)
            
            if not LOOP_CONFIG.loopRework then 
                LOOP_CONFIG.loopReworkDebounce = false
                return 
            end
            
            local char, hum, root = getCharacterParts()
            if hum and root then
                local originalAutoRotate = hum.AutoRotate
                hum.AutoRotate = false
                
                root.Velocity = Vector3.new(root.Velocity.X, LOOP_CONFIG.ForceJumpUpwardVelocity, root.Velocity.Z)
                task.wait(LOOP_CONFIG.loopReworkWaitJump / 10)
                
                fireDashQW()
                task.wait(LOOP_CONFIG.loopReworkWaitRemote / 10)
                
                local target = findBestTarget()
                if target then
                    if stopLockFunction then stopLockFunction() end
                    stopLockFunction = startHorizontalLock(target, LOOP_CONFIG.loopReworkLockDuration / 10)
                end
                
                local endTime = tick() + (LOOP_CONFIG.loopReworkLockDuration / 10)
                task.spawn(function()
                    while tick() < endTime and LOOP_CONFIG.loopRework do
                        if hum and hum.Parent then
                            hum.AutoRotate = false
                        end
                        RunService.Heartbeat:Wait()
                    end
                    if hum and hum.Parent then
                        hum.AutoRotate = originalAutoRotate
                    end
                end)
            end
            
            local cdTime = LOOP_CONFIG.loopReworkCooldown / 10
            task.wait(cdTime)
            LOOP_CONFIG.loopReworkDebounce = false
        end
        
        local function onAnimationPlayed(animationTrack)
            if not LOOP_CONFIG.loopRework then return end
            if LOOP_CONFIG.loopReworkDebounce then return end
            
            local animId = tostring(animationTrack.Animation.AnimationId)
            if animId:find(ANIM_DETECT_ID) then
                task.spawn(runSequence)
            end
        end
        
        local function connectToCharacter()
            local char = LocalPlayer.Character
            if not char then return end
            
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not hum then return end
            
            if loopConnection then
                pcall(function() loopConnection:Disconnect() end)
                loopConnection = nil
            end
            
            loopConnection = hum.AnimationPlayed:Connect(onAnimationPlayed)
        end
        
        if state then
            cleanup()
            LOOP_CONFIG.loopRework = true
            LOOP_CONFIG.loopReworkDebounce = false
            
            connectToCharacter()
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function()
                if LOOP_CONFIG.loopRework then
                    task.wait(0.5)
                    connectToCharacter()
                end
            end)
            
            _G.LoopDashConnection = loopConnection
            _G.LoopDashCharConn = charAddedConnection
            
        else
            LOOP_CONFIG.loopRework = false
            LOOP_CONFIG.loopReworkDebounce = false
            cleanup()
            
            _G.LoopDashConnection = nil
            _G.LoopDashCharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'Merck Tech',
    Value = false,
    CallBack = function(state)
        toggles.MerckTech = state
        
        local MERCK_CONFIG = {
            cooldown = 7.2,
            delayBeforeStick = 0.35,
            followDuration = 0.3,
            lockAngle = 85,
            followOffset = 0.3,
            totalDuration = 0.7
        }
        
        local ANIM_DETECT_ID = "10503381238"
        
        local merckConnection = nil
        local charAddedConnection = nil
        local animatorConnection = nil
        local descendantConnection = nil
        local heartbeatConnection = nil
        local followConnection = nil
        local lastTriggerTime = 0
        local isRunning = false
        
        local currentChar = nil
        local currentHumanoid = nil
        local currentRootPart = nil
        
        local function findNearestTarget()
            if not currentRootPart then return nil end
            
            local bestTarget = nil
            local bestDist = MERCK_CONFIG.cooldown * 2
            
            for _, model in ipairs(workspace:GetDescendants()) do
                if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") and model ~= currentChar then
                    local targetRoot = model:FindFirstChild("HumanoidRootPart")
                    local targetHum = model:FindFirstChildOfClass("Humanoid")
                    
                    if targetRoot and targetHum and targetHum.Health > 0 then
                        local dist = (currentRootPart.Position - targetRoot.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            bestTarget = targetRoot
                        end
                    end
                end
            end
            return bestTarget
        end
        
        local function findMovemeBodyVelocity()
            if not getnilinstances then return nil end
            for _, inst in pairs(getnilinstances()) do
                if inst and inst.ClassName == "BodyVelocity" and inst.Name == "moveme" then
                    return inst
                end
            end
            return nil
        end
        
        local function fireDashQW()
            if currentChar and currentChar:FindFirstChild("Communicate") then
                pcall(function()
                    currentChar.Communicate:FireServer(unpack({{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}))
                end)
            end
        end
        
        local function fireDeleteBV()
            if currentChar and currentChar:FindFirstChild("Communicate") then
                local bv = findMovemeBodyVelocity()
                pcall(function()
                    currentChar.Communicate:FireServer(unpack({{Goal = "delete bv", BV = bv}}))
                end)
            end
        end
        
        local function destroyBodyMotions(character)
            if not character then return end
            for _, descendant in pairs(character:GetDescendants()) do
                local className = descendant.ClassName
                if className == "BodyVelocity" or className == "BodyPosition" or 
                   className == "BodyGyro" or className == "VectorForce" or
                   className == "AlignPosition" or className == "AlignOrientation" or
                   className == "LinearVelocity" or className == "AngularVelocity" then
                    pcall(function() descendant:Destroy() end)
                end
            end
        end
        
        local function saveHumanoidStats(humanoid)
            if not humanoid then return nil end
            return {
                WalkSpeed = humanoid.WalkSpeed,
                JumpPower = humanoid.JumpPower,
                PlatformStand = humanoid.PlatformStand,
                AutoRotate = pcall(function() return humanoid.AutoRotate end) and humanoid.AutoRotate or true
            }
        end
        
        local function restoreHumanoidStats(humanoid, stats)
            if not humanoid or not stats then return end
            pcall(function()
                humanoid.WalkSpeed = stats.WalkSpeed or 16
                humanoid.JumpPower = stats.JumpPower or 50
                humanoid.PlatformStand = stats.PlatformStand or false
                if stats.AutoRotate ~= nil then
                    humanoid.AutoRotate = stats.AutoRotate
                end
            end)
        end
        
        local function performStickDash()
            if not currentChar or not currentHumanoid or not currentRootPart then return end
            if isRunning then return end
            
            local target = findNearestTarget()
            if not target then return end
            
            isRunning = true
            
            local originalStats = saveHumanoidStats(currentHumanoid)
            
            pcall(function()
                currentHumanoid.WalkSpeed = 0
                currentHumanoid.JumpPower = 0
                currentHumanoid.PlatformStand = true
                currentHumanoid.AutoRotate = false
                currentRootPart.Velocity = Vector3.new(0, 0, 0)
                currentRootPart.RotVelocity = Vector3.new(0, 0, 0)
            end)
            
            destroyBodyMotions(currentChar)
            
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if currentRootPart then
                    pcall(function()
                        currentRootPart.Velocity = Vector3.new(0, 0, 0)
                        currentRootPart.RotVelocity = Vector3.new(0, 0, 0)
                    end)
                end
                if currentHumanoid then
                    pcall(function()
                        currentHumanoid.WalkSpeed = 0
                    end)
                end
            end)
            
            pcall(function() currentHumanoid:ChangeState(Enum.HumanoidStateType.Physics) end)
            
            currentRootPart.CFrame = currentRootPart.CFrame * CFrame.Angles(math.rad(MERCK_CONFIG.lockAngle), 0, 0)
            
            local startTime = tick()
            followConnection = RunService.Heartbeat:Connect(function()
                local elapsed = tick() - startTime
                if elapsed < MERCK_CONFIG.totalDuration then
                    local targetRoot = target.Parent and target:FindFirstChild("HumanoidRootPart")
                    if targetRoot and currentRootPart then
                        local targetPos = targetRoot.Position
                        local lookDir = (targetPos - currentRootPart.Position).Unit
                        local offsetPos = targetPos - lookDir * MERCK_CONFIG.followOffset
                        currentRootPart.CFrame = CFrame.new(offsetPos) * CFrame.Angles(math.rad(MERCK_CONFIG.lockAngle), 0, 0)
                    end
                else
                    if followConnection then followConnection:Disconnect() end
                end
            end)
            
            task.delay(0.18, function()
                pcall(function()
                    fireDashQW()
                    fireDeleteBV()
                end)
            end)
            
            task.delay(0.3, function()
                pcall(function() currentHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
            end)
            
            local restoreDelay = MERCK_CONFIG.totalDuration + MERCK_CONFIG.followDuration
            task.delay(restoreDelay, function()
                if heartbeatConnection then heartbeatConnection:Disconnect() end
                if followConnection then followConnection:Disconnect() end
                restoreHumanoidStats(currentHumanoid, originalStats)
                isRunning = false
            end)
        end
        
        local function tryTriggerTech()
            if not toggles.MerckTech then return end
            if isRunning then return end
            
            local now = tick()
            if now - lastTriggerTime >= MERCK_CONFIG.cooldown then
                lastTriggerTime = now
                task.spawn(performStickDash)
            end
        end
        
        local function onAnimationPlayed(animationTrack)
            if not toggles.MerckTech then return end
            
            local anim = animationTrack.Animation
            if anim then
                local animId = tostring(anim.AnimationId or "")
                if string.find(animId, ANIM_DETECT_ID, 1, true) then
                    tryTriggerTech()
                end
            end
        end
        
        local function connectToCharacter(character)
            if not character then return end
            
            if merckConnection then pcall(function() merckConnection:Disconnect() end) end
            if animatorConnection then pcall(function() animatorConnection:Disconnect() end) end
            if descendantConnection then pcall(function() descendantConnection:Disconnect() end) end
            
            currentChar = character
            currentHumanoid = character:FindFirstChildOfClass("Humanoid")
            currentRootPart = character:FindFirstChild("HumanoidRootPart")
            
            if not currentHumanoid or not currentRootPart then return end
            
            merckConnection = currentHumanoid.AnimationPlayed:Connect(onAnimationPlayed)
            
            local animator = currentHumanoid:FindFirstChildOfClass("Animator")
            if animator then
                animatorConnection = animator.AnimationPlayed:Connect(onAnimationPlayed)
            end
            
            descendantConnection = character.DescendantAdded:Connect(function(desc)
                if desc:IsA("Animation") then
                    local animId = tostring(desc.AnimationId or "")
                    if string.find(animId, ANIM_DETECT_ID, 1, true) then
                        tryTriggerTech()
                    end
                end
            end)
        end
        
        if state then
            lastTriggerTime = 0
            isRunning = false
            
            if LocalPlayer.Character then
                connectToCharacter(LocalPlayer.Character)
            end
            
            charAddedConnection = LocalPlayer.CharacterAdded:Connect(function(newChar)
                if toggles.MerckTech then
                    task.wait(0.2)
                    connectToCharacter(newChar)
                end
            end)
            
            _G.MerckConnection = merckConnection
            _G.MerckCharConn = charAddedConnection
            
        else
            if merckConnection then
                pcall(function() merckConnection:Disconnect() end)
                merckConnection = nil
            end
            if animatorConnection then
                pcall(function() animatorConnection:Disconnect() end)
                animatorConnection = nil
            end
            if descendantConnection then
                pcall(function() descendantConnection:Disconnect() end)
                descendantConnection = nil
            end
            if charAddedConnection then
                pcall(function() charAddedConnection:Disconnect() end)
                charAddedConnection = nil
            end
            if heartbeatConnection then
                pcall(function() heartbeatConnection:Disconnect() end)
                heartbeatConnection = nil
            end
            if followConnection then
                pcall(function() followConnection:Disconnect() end)
                followConnection = nil
            end
            
            if currentHumanoid then
                pcall(function()
                    currentHumanoid.AutoRotate = true
                    currentHumanoid.WalkSpeed = 16
                end)
            end
            
            isRunning = false
            
            _G.MerckConnection = nil
            _G.MerckCharConn = nil
        end
    end
})

TonghopTab:Toggle({
    Title = 'Supa Tech',
    Value = false,
    CallBack = function(Value)
        print("Supa Legit V2:", Value)
        _G.SupaLegitV2_Enabled = Value
        
        if _G.SupaLegitV2_Connections then
            for _, conn in pairs(_G.SupaLegitV2_Connections) do
                pcall(function()
                    conn:Disconnect()
                end)
            end
            _G.SupaLegitV2_Connections = nil
        end
        
        if not Value then return end
        
        local LEGIT_CONFIG = {
            DASH_DURATION = 0.15,
            FOLLOW_OFFSET = 2.5,
            ANGLE_TILT = math.rad(55),
            STICK_RANGE = 18,
            ANIMATION_IDS = {
                "10503381238",
                "13379003796"
            }
        }
        
        local currentCharacter = nil
        local currentHumanoid = nil
        local currentRootPart = nil
        
        local lastTriggerTick = 0
        local cooldownSeconds = 0.3
        local inCooldown = false
        
        local function findClosestModelWithRootPart()
            if not currentRootPart then return nil end
            local closestModel = nil
            local smallestDistance = LEGIT_CONFIG.STICK_RANGE
            for _, descendant in pairs(workspace:GetDescendants()) do
                if descendant:IsA("Model") and descendant:FindFirstChild("HumanoidRootPart") and descendant ~= currentCharacter then
                    local ok, distance = pcall(function()
                        return (currentRootPart.Position - descendant.HumanoidRootPart.Position).Magnitude
                    end)
                    if ok and distance and distance < smallestDistance then
                        closestModel = descendant
                        smallestDistance = distance
                    end
                end
            end
            return closestModel
        end
        
        local function sendDashAndRemoveVelocity()
            pcall(function()
                local payload = {{Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress"}}
                if currentCharacter and currentCharacter:FindFirstChild("Communicate") then
                    currentCharacter.Communicate:FireServer(unpack(payload))
                end
            end)
        
            local function findNilInstanceByNameClass(name, className)
                for _, inst in pairs(getnilinstances()) do
                    if inst.ClassName == className and inst.Name == name then return inst end
                end
                return nil
            end
        
            pcall(function()
                local payload = {{Goal = "delete bv", BV = findNilInstanceByNameClass("moveme", "BodyVelocity")}}
                if currentCharacter and currentCharacter:FindFirstChild("Communicate") then
                    currentCharacter.Communicate:FireServer(unpack(payload))
                end
            end)
        end
        
        local function performStickDash()
            if not currentCharacter or not currentHumanoid or not currentRootPart then return end
            local targetModel = findClosestModelWithRootPart()
            if not targetModel then return end
            local targetRoot = targetModel:FindFirstChild("HumanoidRootPart")
            if not targetRoot then return end
        
            local savedState = {
                WalkSpeed = currentHumanoid.WalkSpeed,
                JumpPower = currentHumanoid.JumpPower,
                PlatformStand = currentHumanoid.PlatformStand,
                AutoRotate = currentHumanoid.AutoRotate
            }
        
            local heartbeatConnection = RunService.Heartbeat:Connect(function()
                if currentRootPart then
                    currentRootPart.Velocity = Vector3.new(0, 0, 0)
                    currentRootPart.RotVelocity = Vector3.new(0, 0, 0)
                end
                if currentHumanoid then currentHumanoid.WalkSpeed = 0 end
            end)
        
            pcall(sendDashAndRemoveVelocity)
            task.wait(0.2)
            pcall(function() currentHumanoid:ChangeState(Enum.HumanoidStateType.Physics) end)
        
            if currentRootPart then
                currentRootPart.CFrame = currentRootPart.CFrame * CFrame.Angles(LEGIT_CONFIG.ANGLE_TILT, 0, 0)
            end
        
            local followDuration = LEGIT_CONFIG.DASH_DURATION
            local startTick = tick()
            local followConnection = RunService.Heartbeat:Connect(function()
                if followDuration > tick() - startTick then
                    local direction = (targetRoot.Position - currentRootPart.Position).Unit
                    local offsetPosition = targetRoot.Position - direction * LEGIT_CONFIG.FOLLOW_OFFSET
                    currentRootPart.CFrame = CFrame.new(offsetPosition) * CFrame.Angles(LEGIT_CONFIG.ANGLE_TILT, 0, 0)
                end
            end)
        
            task.wait(followDuration)
            if heartbeatConnection then heartbeatConnection:Disconnect() end
            if followConnection then followConnection:Disconnect() end
        
            pcall(function()
                currentHumanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
                currentHumanoid.WalkSpeed = savedState.WalkSpeed
                currentHumanoid.JumpPower = savedState.JumpPower
                currentHumanoid.PlatformStand = savedState.PlatformStand
                currentHumanoid.AutoRotate = savedState.AutoRotate
            end)
        end
        
        local function handleAnimationPlayed(animationTrack)
            if not _G.SupaLegitV2_Enabled then return end
            if animationTrack then animationTrack = animationTrack.Animation end
            if animationTrack then
                local animId = tostring(animationTrack.AnimationId or "")
                for _, id in ipairs(LEGIT_CONFIG.ANIMATION_IDS) do
                    if string.find(animId, id, 1, true) then
                        task.delay(0.3, function()
                            if inCooldown then return end
                            lastTriggerTick = tick()
                            inCooldown = true
                            task.spawn(performStickDash)
                            task.wait(4)
                            inCooldown = false
                        end)
                        return
                    end
                end
            end
        end
        
        local function onCharacterAdded(character)
            currentCharacter = character
            currentHumanoid = character:WaitForChild("Humanoid")
            currentRootPart = character:WaitForChild("HumanoidRootPart")
            currentHumanoid.AnimationPlayed:Connect(handleAnimationPlayed)
            local animator = currentHumanoid:FindFirstChildOfClass("Animator")
            if animator then animator.AnimationPlayed:Connect(handleAnimationPlayed) end
        end
        
        _G.SupaLegitV2_Connections = {}
        table.insert(_G.SupaLegitV2_Connections, LocalPlayer.CharacterAdded:Connect(onCharacterAdded))
        if LocalPlayer.Character then
            onCharacterAdded(LocalPlayer.Character)
        end
    end
})

TonghopTab:Toggle({
    Title = 'Auto DownSlam',
    Value = false,
    CallBack = function(value)
        print("Auto DownSlam:", value)
        _G.AutoDownSlamEnabled = value

        local workspace = game:GetService("Workspace")

        local validIDs = {
            ["rbxassetid://10469639222"] = true,
            ["rbxassetid://13532604085"] = true,
            ["rbxassetid://13295919399"] = true,
            ["rbxassetid://13378751717"] = true,
            ["rbxassetid://14001963401"] = true,
            ["rbxassetid://15240176873"] = true,
            ["rbxassetid://16515448089"] = true,
            ["rbxassetid://17889471098"] = true,
            ["rbxassetid://104895379416342"] = true,
        }

        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local humanoid = char:WaitForChild("Humanoid")
        local hrp = char:WaitForChild("HumanoidRootPart")

        local function isNearTarget()
            if not hrp then return false end
            for _, model in ipairs(workspace.Live:GetChildren()) do
                if model:IsA("Model") and model ~= char then
                    local root = model:FindFirstChild("HumanoidRootPart")
                    if root and (root.Position - hrp.Position).Magnitude <= 15 then
                        if Players:GetPlayerFromCharacter(model) or model.Name == "Weakest Dummy" then
                            return true
                        end
                    end
                end
            end
            return false
        end

        local function liftAndJump()
            if not hrp or not humanoid then return end
            if not isNearTarget() then return end

            local tween = TweenService:Create(
                hrp,
                TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { CFrame = hrp.CFrame + Vector3.new(0, 6, 0) }
            )
            tween:Play()

            for _, state in ipairs({
                Enum.HumanoidStateType.PlatformStanding,
                Enum.HumanoidStateType.Freefall,
                Enum.HumanoidStateType.GettingUp,
            }) do
                if humanoid:GetState() == state then
                    humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                    task.wait()
                end
            end

            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        if value then
            if _G.DownSlamAnimConnection then _G.DownSlamAnimConnection:Disconnect() end
            _G.DownSlamAnimConnection = humanoid.AnimationPlayed:Connect(function(track)
                if _G.AutoDownSlamEnabled and track.Animation and validIDs[track.Animation.AnimationId] then
                    liftAndJump()
                end
            end)
        else
            if _G.DownSlamAnimConnection then
                _G.DownSlamAnimConnection:Disconnect()
                _G.DownSlamAnimConnection = nil
            end
        end
    end
})

-- ===== MOVESETS TAB =====
MovesetsTab:Section('Character Movesets')

MovesetsTab:Button({
    Title = 'Sukuna',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/damir512/whendoesbrickdie/main/tspno.txt", true))()
    end
})

MovesetsTab:Button({
    Title = 'Gojo',
    CallBack = function()
        loadstring(game:HttpGet("https://rawscripts.net/raw/KJ-The-Strongest-Battlegrounds-battleground-gojo-script-saitama-to-gojo-26980"))()
    end
})

MovesetsTab:Button({
    Title = 'Kars',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/OfficialAposty/RBLX-Scripts/refs/heads/main/UltimateLifeForm.lua"))()
    end
})

MovesetsTab:Button({
    Title = 'Wally West',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Nova2ezz/west/refs/heads/main/Protected_4638864115822087.lua.txt"))()
    end
})

MovesetsTab:Button({
    Title = 'MAFIOSO',
    CallBack = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Lovelymoonlight/Lovelymoonlight/refs/heads/main/Baldy%20to%20mafioso'))()
    end
})

MovesetsTab:Button({
    Title = 'Beerus',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sparksnaps/Beerus-The-Destroyer/refs/heads/main/Lua"))()
    end
})

MovesetsTab:Button({
    Title = 'Madara',
    CallBack = function()
        getgenv().Cutscene = false
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LolnotaKid/SCRIPTSBYVEUX/refs/heads/main/BoombasticLol.lua.txt"))()
    end
})

MovesetsTab:Button({
    Title = 'Golden Head',
    CallBack = function()
        getgenv().stand = false
        getgenv().ken = false
        getgenv().Spawn = true
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Kenjihin69/Kenjihin69/refs/heads/main/Saitama%20to%20golden%20sigma'))()
    end
})

MovesetsTab:Button({
    Title = 'Jun',
    CallBack = function()
        loadstring(game:HttpGet("https://gist.githubusercontent.com/GoldenHeads2/f66279000c58a020e894a6db44914838/raw/62e53e1acacec0b38b43cd0f594292c32e09c39b/gistfile1.txt"))()
    end
})

MovesetsTab:Button({
    Title = 'Mahito',
    CallBack = function()
        getgenv().Swordm1 = true
        getgenv().night = false
        getgenv().plushie = false
        getgenv().blackflash = true
        getgenv().chat = false
        loadstring(game:HttpGet('https://raw.githubusercontent.com/Kenjihin69/Kenjihin69/refs/heads/main/Mahito%20v2%20sigma%20tp%20exploit'))()
    end
})

MovesetsTab:Button({
    Title = 'Naruto',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/LolnotaKid/NarutoBeatUpSasukeAss/refs/heads/main/NarutoCums"))()
    end
})

MovesetsTab:Button({
    Title = 'Gabriel',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/damir512/youinsinificants/main/insignificantFuck.txt", true))()
    end
})

MovesetsTab:Button({
    Title = 'Void Garou',
    CallBack = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Void%20Reaper%20Obfuscated.txt"))()
    end
})

MovesetsTab:Button({
    Title = 'Mastery Deku',
    CallBack = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/xKextYP5"))()
    end
})

MovesetsTab:Button({
    Title = 'SONIC.EXE',
    CallBack = function()
        loadstring(game:HttpGet("https://pastefy.app/4zLt8a2P/raw"))()
    end
})

-- ===== TECH TAB =====
TechTab:Section('Tech Scripts')

local techButtons = {
    {'Supa Tech', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/SupaLegitV2/refs/heads/main/SupaLegitV2.lua"},
    {'Instant Lethal V1', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/Instant-Lethal/refs/heads/main/InstanLethal.lua"},
    {'Instant Lethal V2', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/All-Tech/refs/heads/main/InstantLethalV2.luau"},
    {'Surfing Tech', "https://raw.githubusercontent.com/Cyborg883/GarouSurfingTech/refs/heads/main/Protected_2674673126232747.lua"},
    {'Loop Dash V2', "https://api.getpolsec.com/scripts/hosted/84e2bd29cccc0f5302267e4dc952cff6816db4af36416cbd477daaa26d60863d.lua"},
    {'Mini Supa Tech', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/All-Tech/refs/heads/main/MiniSupaTech.luau"},
    {'Auto Tech', "https://raw.githubusercontent.com/Cyborg883/NewAutoTech/refs/heads/main/Protected_6389347658054908.lua"},
    {'Instant Twisted', "https://raw.githubusercontent.com/Cyborg883/InstantTwistedRevamp/refs/heads/main/Protected_7455521176683315.lua"},
    {'Instant Lethal', "https://raw.githubusercontent.com/Cyborg883/InstantLethal/refs/heads/main/Protected_5983112998592296.lua"},
    {'Combat Gui', "https://raw.githubusercontent.com/Cyborg883/CombatGUI/refs/heads/main/TSBCombatGUI"},
    {'Kai Tech', "https://raw.githubusercontent.com/YQANTGV2/YQANTGV2/refs/heads/main/Kai"},
    {'Auto Downslam', "https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/atds"},
    {'Gojo Tech Old', "https://raw.githubusercontent.com/ngoclinh02042011-stack/Gojo-Tech/refs/heads/main/DuydepzaiGojoTech.lua"},
    {'Gojo Tech New', "https://gojotech.tsbscripts.workers.dev/"},
    {'Supa V2 Fix', "https://api.getpolsec.com/scripts/hosted/2753546c83053761e44664d36ffe5035d6e20fc8aee1d19f0eb7b933974ae537.lua"},
    {'Side Dash V1', "https://api.getpolsec.com/scripts/hosted/94a29c6b88bfe8c49ea221eaa9225398790c1b7436b0f08caf7517c3002e8782.lua"},
    {'Side Dash V2', "https://api.getpolsec.com/scripts/hosted/52b3b7317bd590bfe678009b3359e74316d9c731ec1395f3e800718d520501f1.lua"},
    {'Auto Tech V2.5', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/All-Tech/refs/heads/main/AutoTech.luau"},
    {'Lethal Dash V1', "https://api.jnkie.com/api/v1/luascripts/public/a96b9a4a030dd50b2b737088b6401b7a7500f4c90a9119c9525a940e5d05c3f7/download"},
    {'Supa Cancel', "https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/SupaCancel"},
    {'Normal Punch Tech', "https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/NormalPunchTech"},
    {'TwetiQ Tech', "https://pastefy.app/bduzr7pS/raw"},
    {'Lethal Revamp', "https://raw.githubusercontent.com/Cyborg883/InstantLethalRevamp/refs/heads/main/Protected_6977817281150270.lua"},
    {'Reflex Tech', "https://raw.githubusercontent.com/Cyborg883/ReflexTech/refs/heads/main/Protected_7459802026542834.lua"},
    {'Oreo Tech', "https://raw.githubusercontent.com/Cyborg883/OreoTech/refs/heads/main/Protected_6856895483929371.lua"},
    {'Supa V3', "https://api.getpolsec.com/scripts/hosted/ea0b7cbd8c395e01ec38271794b2559808d26501bd6e6e30c48660759a7db7b3.lua"},
    {'Kiba Tech', "https://raw.githubusercontent.com/kietsonphongthanhnghia-a11y/Uhyeah/refs/heads/main/Protected_1425045629292384.lua.txt"},
    {'Instant Twisted New', "https://raw.githubusercontent.com/Duytsb1609/Instant-Twisted-Sigma/refs/heads/main/instant_Twisted%20(1).lua"},
    {'3 in 1 Tech', "https://pastefy.app/NJfMV5ze/raw"},
    {'Solitude Tech', "https://api.jnkie.com/api/v1/luascripts/public/86e0da30855e98f4a12efbde49222668b5d711e1ef1b099db7d5eca09bba15ac/download"},
    {'CamLock V9', "https://api.jnkie.com/api/v1/luascripts/public/924afb8e0b82b94c3852bd7bdbad2183713eadf7fe084bfbee9869668add0286/download"},
    {'Kitty Tech', "https://raw.githubusercontent.com/Nhat473/Kitty-Tech/refs/heads/main/TSB"},
    {'Reflex Tech V2', "https://raw.githubusercontent.com/Cyborg883/ReflexTech/refs/heads/main/Protected_7459802026542834.lua"},
    {'KibaZ Tech', "https://raw.githubusercontent.com/gamerscripter90/Kibaz/main/kibaztech.lua.txt"},
    {'Binding Cloth Dash Tech', "https://gist.githubusercontent.com/ngm2807-sudo/aeccf3ce4aef451f61f56d6b21ade701/raw/bindingclothdash.lua"},
    {'Supa Tech ( Settings )', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/SupaLegit-Release/refs/heads/main/SupaLegit.lua"},
    {'Auto Kyoto Rework', "https://raw.githubusercontent.com/Cyborg883/KyotoTechRework/refs/heads/main/Protected_9378660372508532.lua"},
    {'Loop Dash V3', "https://api.jnkie.com/api/v1/luascripts/public/774bd154b84449a478cb0d5717df6f56eddf16d5d85a87792d84978a1f75e84a/download"},
    {'Auto Uppercut', "https://arch-http.vercel.app/files/Auto%20Uppercut.lua"},
    {'The Fish X (Dash)', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/TheFishX/refs/heads/main/obfuscated_script-1757331576860.lua.txt"},
    {'Auto Kyoto (By Mark)', "https://raw.githubusercontent.com/Mark22028/Auto-Kyoto-Combo/refs/heads/main/Skibidi%20Sigma%20Combo.txt"},
    {'Auto Kyoto Combo', "https://raw.githubusercontent.com/gamerscripter90/Thestrongesthgg-/main/Kyoto.lua.txt"},
    {'KibaZ V1', "https://raw.githubusercontent.com/gamerscripter90/KIBAZ-TECH-/main/Kibaztechv1.lua.txt"},
    {'Supa Vole Tech', "https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/SupaVeloTech.lua"},
    {'Auto Combo Kyoto (Corex Hub)', "https://raw.githubusercontent.com/gamerscripter90/Thestrongesthgg-/main/Kyoto.lua.txt"},
    {'Lethal Dash', "https://api.jnkie.com/api/v1/luascripts/public/57a4d240a2440f0450986c966469092ccfb8d4797392cb8f469fa8b6e605e64d/download"},
    {'Hex Tech', "https://raw.githubusercontent.com/DuyYeuEmNhieuLam/Hex-Tech/refs/heads/main/Hex%20Tech.lua"},
    {'Auto Combo Kyoto (Saturn Hub)', "https://raw.githubusercontent.com/sigmavexr/AUTO-KYOTO-SATURN-HUB/refs/heads/main/AUTO%20KYOTO"},
    {'Skibidi Tech v4', "https://raw.githubusercontent.com/nguyenduchunganh519-source/IL4SK-skibidi/refs/heads/main/IL4SK%20skibidi"},
    {'Dripz Tech', "https://raw.githubusercontent.com/ngoclinh02042011-stack/DripzTech/refs/heads/main/DripzTech.txt"},
    {'Auto Block V8', "https://api.jnkie.com/api/v1/luascripts/public/5659752fa0f7c10df56777eafd8f4813f15d3cde1b206f7e10f6b87af4fa9dfd/download"},
    {'Auto Block V12', "https://raw.githubusercontent.com/Cyborg883/CombatGuiNew/refs/heads/main/Auto%20Block%20V12"},
    {'Garou Tech', "https://raw.githubusercontent.com/Cyborg883/GarouTechs/refs/heads/main/Protected_9831634675356265.lua"},
    {'Auto Block V1 (Cps Network)', "https://api.luarmor.net/files/v3/loaders/6f502e252308fb97855295005faa73a0.lua"},
    {'Garou Damage (2 Garou)', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/GAROUDAME/refs/heads/main/TSB"},
    {'LoopDash V2', "https://api.jnkie.com/api/v1/luascripts/public/28513f51c0ca2c03d4d7d94f59215d13ce1a2a470bf187f0a685b58ccb4dae98/download"},
    {'Twinnie Tech', "https://raw.githubusercontent.com/Defy-cloud/The-Strongest-Battlegrounds/refs/heads/main/TwinnieTech"},
    {'Instant Lethal V2', "https://api.jnkie.com/api/v1/luascripts/public/a23acf82fb18b827dca096e149ab0272fc74ea9bb8153cd43e44555acb943c86/download"},
    {'LoopYen', "https://api.jnkie.com/api/v1/luascripts/public/dd205f0487a772434c4bcde88a7d11d52b207c2afda89351d4a4f6f8ecfce48d/download"},
    {'Oreo Tech ( Setting )', "https://raw.githubusercontent.com/Defy-cloud/The-Strongest-Battlegrounds/refs/heads/main/OreoTech"},
    {'SupaX Tech', "https://raw.githubusercontent.com/Defy-cloud/The-Strongest-Battlegrounds/refs/heads/main/SupaxTech"},
    {'Boomy Twisted', "https://raw.githubusercontent.com/Defy-cloud/The-Strongest-Battlegrounds/refs/heads/main/BoomyTwisted"},
    {'M1 Reset', "https://rawscripts.net/raw/Universal-Script-M1-RESET-57657"},
    {'Gojo Shuriken', "https://raw.githubusercontent.com/kaimm2/TSB/refs/heads/main/GojoShiruken"},
    {'Dripz Tech', "https://raw.githubusercontent.com/Defy-cloud/The-Strongest-Battlegrounds/refs/heads/main/DripzTech"},
    {'Legit M1 Reset', "https://raw.githubusercontent.com/Defy-cloud/Scripts/refs/heads/main/LegitM1Reset"},
}

for _, tech in ipairs(techButtons) do
    TechTab:Button({
        Title = tech[1],
        CallBack = function()
            loadstring(game:HttpGet(tech[2], true))()
        end
    })
end

-- ===== FIX LAG TAB =====
FixLagTab:Section('FPS Boosters & Anti-Lag')

local fixLagButtons = {
    {'Fps Booster V3 (Joshzzz)', "https://raw.githubusercontent.com/JoshzzAlteregooo/JoshzzFpsBoosterVersion3/refs/heads/main/JoshzzNewFpsBooster"},
    {'BloxStrap', "https://raw.githubusercontent.com/qwertyui-is-back/Bloxstrap/main/Initiate.lua"},
    {'Fps Boost (ItLouisPlay)', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/ItsLouisPlay-Fps-Booster/refs/heads/main/TSB"},
    {'Fps Boost (Vikichard)', "https://raw.githubusercontent.com/VikiChardd/AntiLag_TSB/main/Protect_MeowTBS1999.lua.txt"},
    {'Low GFX', "https://rawscripts.net/raw/Universal-Script-Low-GFX-38613"},
    {'Turbo Lite', "https://raw.githubusercontent.com/TurboLite/Script/main/FixLag.lua"},
    {'Turbo Lite (Blue)', "https://raw.githubusercontent.com/MeoLazy/Script/refs/heads/main/FixLag.lua"},
    {'Fps Boost', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/Fps-boost/refs/heads/main/029298383"},
    {'Fix Lag', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/Fix-Lag/refs/heads/main/Made%20By%20MinhNhat"},
    {'Remove Skill', "https://raw.githubusercontent.com/louismich4el/ItsLouisPlayz-Scripts/main/TSB%20Anti%20Lag.lua"},
    {'Kaito FixLag', "https://raw.githubusercontent.com/kaitofixlag-hub/Fixlag/refs/heads/main/fixlag.txt"},
    {'Fix lag (Mumya)', "https://pastefy.app/dhiPeX7H/raw"},
    {'Fps Boost v0.5 (Corex Hub)', "https://raw.githubusercontent.com/gamerscripter90/Fps-booster/main/Fpsbooster.lua.txt"},
}

for _, fix in ipairs(fixLagButtons) do
    FixLagTab:Button({
        Title = fix[1],
        CallBack = function()
            loadstring(game:HttpGet(fix[2]))()
        end
    })
end

-- ===== TSB TAB =====
TsbTab:Section('TSB Scripts')

local tsbButtons = {
    {'Trash Can', "https://raw.githubusercontent.com/yes1nt/yes/refs/heads/main/Trashcan%20Man"},
    {'Aimlock Universal', "https://raw.githubusercontent.com/MerebennieOfficial/Bestaimbot/refs/heafs/main/Merebennie"},
    {'Napoleon Hub', "https://raw.githubusercontent.com/raydjs/napoleonHub/refs/heads/main/src.lua"},
    {'VexonHub', "https://raw.githubusercontent.com/DiosDi/VexonHub/refs/heads/main/VexonHub"},
    {'AimLock Old', "https://raw.githubusercontent.com/Mark22028-2ndAcc/Scripts/refs/heads/main/Camlock%20OldV.lua"},
    {'TSB Script (Emerson)', "https://raw.githubusercontent.com/Emerson2-creator/Scripts-Roblox/refs/heads/main/TSBLuna.lua"},
    {'Farm Kill V1', "https://raw.githubusercontent.com/ngoclinh02042011-stack/Farm-Kill-V1/refs/heads/main/FarmKillV1.lua"},
    {'Khanh Ly Auto Farm Vip [Beta]', "https://raw.githubusercontent.com/khoavipok/ScriptkhanhlyHUB/refs/heads/main/Khanhly%20strongest%20pranium"},
    {'Phantasm Hub', "https://raw.githubusercontent.com/ATrainz/Phantasm/refs/heads/main/Games/TSB.lua"},
    {'Invinsible', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/Invisible/refs/heads/main/TSB"},
    {'Farm Kill', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/FARM-KILL/refs/heads/main/TSB"},
    {'Farm Kill V2', "https://raw.githubusercontent.com/minhnhatdepzai8-cloud/Farm-Kill-V2/refs/heads/main/TSB"},
    {'Auto Farm', "https://raw.githubusercontent.com/nullrush0/Auto-Farm/refs/heads/main/Lua"},
    {'Dovi Hub', "https://raw.githubusercontent.com/Duytsb1609/DoviHub/refs/heads/main/obfuscated_Dovi_HUB_Cracked_by_Merebennie.txt"},
}

for _, tsb in ipairs(tsbButtons) do
    TsbTab:Button({
        Title = tsb[1],
        CallBack = function()
            loadstring(game:HttpGet(tsb[2]))()
        end
    })
end

-- ===== MISC TAB =====
MiscTab:Section('Miscellaneous')

local miscButtons = {
    {'No Colldown Dash', "https://pastefy.app/RRc9D0kj/raw"},
    {'Oinan-Thickhoof-Axe', "https://raw.githubusercontent.com/Guestly-Scripts/Items-Scripts/refs/heads/main/Oinan-Thickhoof"},
    {'Erisyphia staff', "https://raw.githubusercontent.com/GuestlyTheGreatestGuest/Scripts/refs/heads/main/Erisyphia-Staff-made-by-Guestly"},
    {'M1 Cid effect', "https://raw.githubusercontent.com/Duytsb1609/M1-effect/refs/heads/main/Cid%20M1%20Effect.lua"},
    {'M1 Kars effect', "https://raw.githubusercontent.com/Duytsb1609/Kars-M1-effect/refs/heads/main/Kars%20M1%20Effect.lua"},
    {'M1 Gojo effect', "https://raw.githubusercontent.com/kaimm2/data/refs/heads/main/effectm1"},
    {'Kill Void (Garou Strategy 1)', "https://raw.githubusercontent.com/Duytsb1609/Kill-Void/refs/heads/main/Kill%20Void%20(%20Use%20Garou%20Strategy%201%20)"},
    {'Hitbox expander (Sonic)', "https://rawscripts.net/raw/The-Strongest-Battlegrounds-SION-ELTNAM-ATLASIA-61168"},
    {'Open UI Fling Player', "https://gist.githubusercontent.com/ngm2807-sudo/7155874edfab6e1d774d5017ea0b3018/raw/32e909c874a9a5192fd52fd5afe4579e1c74cdb9/flingplayer.lua"},
}

for _, misc in ipairs(miscButtons) do
    MiscTab:Button({
        Title = misc[1],
        CallBack = function()
            loadstring(game:HttpGet(misc[2]))()
        end
    })
end

MiscTab:Section('Auto Kill & Orbit')

MiscTab:TextInput({
    Title = 'Enter username to kill',
    PlaceHolder = 'Username...',
    CallBack = function(text)
        nameInput = text
    end
})

MiscTab:Toggle({
    Title = 'Auto Kill',
    Value = false,
    CallBack = function(Value)
        killEnabled = Value
    end
})

MiscTab:Toggle({
    Title = 'Orbit Target',
    Value = false,
    CallBack = function(Value)
        orbitEnabled = Value
    end
})

task.spawn(function()
    while task.wait(0.1) do
        if killEnabled then
            if nameInput ~= "" then
                targetPlayer = Players:FindFirstChild(nameInput)
            else
                targetPlayer = getNearestPlayerAK()
            end
            
            if targetPlayer and targetPlayer.Character then
                local char = LocalPlayer.Character
                local thrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                local thum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                local comm = char and char:FindFirstChild("Communicate")
                
                if char and thrp and thum and comm and thum.Health > 0 then
                    local distance = (char.HumanoidRootPart.Position - thrp.Position).Magnitude
                    if distance <= 6 then
                        comm:FireServer({ Goal = "LeftClick", Mobile = true })
                        task.wait(0.15)
                        
                        tapKey(Enum.KeyCode.Q, 0.1)
                        tapKey(Enum.KeyCode.One)
                        tapKey(Enum.KeyCode.Two)
                        tapKey(Enum.KeyCode.Three)
                        tapKey(Enum.KeyCode.Four)
                        
                        task.wait(0.15)
                        tapKey(Enum.KeyCode.G, 0.15)
                        local randomKey = ({Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four})[math.random(1,4)]
                        tapKey(randomKey)
                    end
                end
            end
        end
    end
end)

local radius = 5.5
local heightMin = -1.5
local heightMax = 2
local teleportSpeed = 2

local function randomOffset()
    local dir = Vector3.new(math.random(-100, 100), 0, math.random(-100, 100)).Unit
    local height = math.random() * (heightMax - heightMin) + heightMin
    return dir * radius + Vector3.new(0, height, 0)
end

RunService.RenderStepped:Connect(function()
    if orbitEnabled and targetPlayer and targetPlayer.Character then
        local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        if root and hum and hum.Health > 0 then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _ = 1, teleportSpeed do
                    char.HumanoidRootPart.CFrame = CFrame.new(root.Position + randomOffset(), root.Position)
                end
            end
        end
    end
end)

-- ===== EMOTE TAB =====
EmoteTab:Section('Limited Emotes')

EmoteTab:Button({
    Title = 'Free slot Emote',
    CallBack = function()
        loadstring(game:HttpGet("https://pastefy.app/kVbOxOjb/raw"))()
    end
})

-- Eternal Seal emote replaced with code from message (2).txt
EmoteTab:Button({
    Title = 'Eternal Seal',
    Description = 'Limited Emote',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Final Stand',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Inner Rage',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Shadow Eruption',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Divine Form',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'The Strongest',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Boundless Rage',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'The Fallen',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'True Aura',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'World Cutting Slash',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'My Brother',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Final Spark',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'Last Will',
    CallBack = function()
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
})

EmoteTab:Button({
    Title = 'The Fallen Finisher',
    CallBack = function()
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
})

-- ===== INFO TAB =====
InfoTab:Button({
    Title = 'Copy Discord Link',
    CallBack = function()
        if setclipboard then
            setclipboard("https://discord.gg/tgK6PfbsN")
            syde:Notify({
                Title = 'Copied!',
                Content = 'Discord link copied to clipboard',
                Duration = 3,
            })
        end
    end
})

InfoTab:Paragraph({
    Title = 'UPDATE SCRIPT:',
    Content = 'Update weekly '
})

-- ===== PLAYER TAB =====
PlayerTab:Section('Music Player')

local MusicList = {
    ["Ai la nguoi thuong em"] = "138017380471511",
}

local musicNames = {}
for name, _ in pairs(MusicList) do
    table.insert(musicNames, name)
end

local SelectedMusic = "Ai la nguoi thuong em"
local CurrentVolume = 0.5
local IsLooped = false
local Sound = nil

local function CreateSound()
    if Sound then
        pcall(function()
            Sound:Stop()
            Sound:Destroy()
        end)
    end

    Sound = Instance.new("Sound")
    Sound.Name = "BoomboxSound"
    Sound.Parent = workspace.CurrentCamera
    Sound.Volume = CurrentVolume
    Sound.Looped = IsLooped
    Sound.SoundId = "rbxassetid://" .. MusicList[SelectedMusic]
    Sound:Stop()
end

CreateSound()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    if Sound then
        Sound.Parent = workspace.CurrentCamera
    end
end)

PlayerTab:Dropdown({
    Title = 'Select Music',
    Options = musicNames,
    PlaceHolder = 'Select a song...',
    CallBack = function(selected)
        SelectedMusic = selected
        if Sound then
            Sound.SoundId = "rbxassetid://" .. MusicList[selected]
            Sound:Stop()
            Sound.TimePosition = 0
        end
    end
})

PlayerTab:Button({
    Title = 'Play',
    CallBack = function()
        if not Sound then return end
        Sound:Stop()
        Sound.TimePosition = 0
        Sound:Play()
    end
})

PlayerTab:Button({
    Title = 'Stop',
    CallBack = function()
        if Sound then
            Sound:Stop()
        end
    end
})

PlayerTab:Toggle({
    Title = 'Loop',
    Value = false,
    CallBack = function(Value)
        IsLooped = Value
        if Sound then
            Sound.Looped = Value
        end
    end
})

PlayerTab:CreateSlider({
    Title = 'Volume',
    Sliders = {
        {
            Title = 'Volume',
            Range = {0, 150},
            Increment = 5,
            StarterValue = 50,
            CallBack = function(Value)
                CurrentVolume = Value / 100
                if Sound then
                    Sound.Volume = CurrentVolume
                end
            end
        }
    }
})

PlayerTab:Section('Cosmetics & Utilities')

PlayerTab:Button({
    Title = 'Golden Shoulder',
    CallBack = function()
        local char = LocalPlayer.Character
        if not char then return end

        local old = char:FindFirstChild("GoldenShoulder")
        if old then old:Destroy() end

        local acc = Instance.new("Accessory")
        acc.Name = "GoldenShoulder"
        acc.Parent = char

        local handle = Instance.new("Part")
        handle.Name = "Handle"
        handle.Size = Vector3.new(1, 1, 1)
        handle.Anchored = false
        handle.Massless = true
        handle.CanCollide = false
        handle.Parent = acc

        local mesh = Instance.new("SpecialMesh")
        mesh.MeshId = "rbxassetid://4307568890"
        mesh.TextureId = "rbxassetid://4307568951"
        mesh.Scale = Vector3.new(1, 1, 1)
        mesh.Parent = handle

        local rightArm = char:FindFirstChild("Right Arm") or char:FindFirstChild("RightUpperArm")
        if rightArm then
            local weld = Instance.new("Weld")
            weld.Part0 = handle
            weld.Part1 = rightArm
            weld.C0 = CFrame.new(-0.6, -1.3, 0)
            weld.Parent = handle
        end
    end
})

PlayerTab:TextInput({
    Title = 'Kill Sound ID',
    PlaceHolder = 'Enter Sound ID',
    CallBack = function(text)
        text = tostring(text):gsub("%s+", "")
        if text == "" then return end
        
        local soundId = "rbxassetid://" .. text
        local sound = Instance.new("Sound")
        sound.SoundId = soundId
        sound.Volume = 1
        sound.Parent = SoundService
        
        local leaderstats = LocalPlayer:WaitForChild("leaderstats", 10)
        if leaderstats then
            local kills = leaderstats:FindFirstChild("Kills")
            if kills then
                kills:GetPropertyChangedSignal("Value"):Connect(function()
                    local soundClone = sound:Clone()
                    soundClone.Parent = workspace.CurrentCamera
                    soundClone:Play()
                    Debris:AddItem(soundClone, 5)
                end)
            end
        end
    end
})

PlayerTab:Button({
    Title = 'Fix Lag MAX (Boost)',
    CallBack = function()
        for _, v in ipairs(Lighting:GetChildren()) do
            if v:IsA("PostEffect") then
                v.Enabled = false
            end
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e9
        Lighting.Brightness = 1

        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Explosion") or obj:IsA("Highlight") then
                pcall(function()
                    obj.Enabled = false
                    obj:Destroy()
                end)
            end
            if obj:IsA("BasePart") then
                obj.CastShadow = false
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            end
        end

        local map = workspace:FindFirstChild("Map")
        if map then
            local treesFolder = map:FindFirstChild("Trees")
            if treesFolder then
                for _, tree in ipairs(treesFolder:GetChildren()) do
                    if tree:IsA("Model") and tree.Name == "Tree" then
                        tree:Destroy()
                    end
                end
            end
        end

        syde:Notify({
            Title = 'Fix Lag',
            Content = 'MAX Boost Enabled',
            Duration = 3,
        })
    end
})

-- ===== HOP TAB =====
HopTab:Section('Server Management')

local function formatTime(sec)
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = math.floor(sec % 60)
    return string.format("%02dh %02dm %02ds", h, m, s)
end

HopTab:Paragraph({
    Title = 'Server Info',
    Content = 'Loading...',
})

task.spawn(function()
    while true do
        local currentPlayers = #Players:GetPlayers()
        local maxPlayers = Players.MaxPlayers
        local placeId = game.PlaceId
        local jobId = game.JobId
        local uptime = workspace.DistributedGameTime
        
        -- Update paragraph content (syde doesn't have direct content update, so we recreate)
        -- For simplicity, we'll just update via a separate label approach
        -- In Syde, you'd need to recreate or use a different approach
        task.wait(1)
    end
end)

HopTab:Button({
    Title = 'Copy JobId',
    CallBack = function()
        if setclipboard then
            setclipboard(game.JobId)
            syde:Notify({
                Title = 'Copied!',
                Content = 'JobId copied to clipboard',
                Duration = 2,
            })
        end
    end
})

HopTab:Button({
    Title = 'Rejoin Server',
    CallBack = function()
        pcall(function()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end)
    end
})

HopTab:Button({
    Title = 'Hop Server (Random)',
    CallBack = function()
        local function getServers(maxPages)
            local servers = {}
            local cursor = ""
            local pages = 0

            repeat
                pages = pages + 1
                local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" .. (cursor ~= "" and "&cursor=" .. cursor or "")
                local success, res = pcall(function()
                    return HttpService:JSONDecode(game:HttpGet(url))
                end)

                if not success or not res or not res.data then break end

                for _, srv in ipairs(res.data) do
                    if srv.playing < srv.maxPlayers and srv.id ~= game.JobId then
                        table.insert(servers, srv)
                    end
                end

                cursor = res.nextPageCursor
            until not cursor or pages >= (maxPages or 5)

            return servers
        end

        local servers = getServers(6)
        if #servers > 0 then
            local pick = servers[math.random(1, #servers)]
            task.wait(0.2)
            TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LocalPlayer)
        end
    end
})

HopTab:Button({
    Title = 'Anti AFK',
    CallBack = function()
        loadstring(game:HttpGet("https://pastefy.app/23rycg2Q/raw"))()
    end
})

HopTab:TextInput({
    Title = 'Join by JobID',
    PlaceHolder = 'Paste JobId...',
    CallBack = function(text)
        if text and text ~= "" then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, text, LocalPlayer)
        end
    end
})

-- ===== INITIAL NOTIFICATION =====
syde:Notify({
    Title = 'ThanhDuy Hub',
    Content = 'Loaded successfully!',
    Duration = 3,
})

print('ThanhDuy Hub loaded successfully with Syde UI Library!')