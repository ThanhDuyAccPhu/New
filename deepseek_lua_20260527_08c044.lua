local _0 = string.char
local _1 = table.concat
local _2 = math.floor
local _3 = tonumber
local _4 = tostring
local _5 = pcall
local _6 = task.spawn
local _7 = task.wait
local _8 = task.delay
local _9 = tick

local _a = game:GetService("Players")
local _b = game:GetService("RunService")
local _c = game:GetService("TweenService")
local _d = game:GetService("UserInputService")

local _e = _a.LocalPlayer
local _f = _e:WaitForChild("PlayerGui")

_G.KibaEnabled = false
_G.KibaEarlyFire = 0.6
_G.KibaCooldownStart = nil

if _f:FindFirstChild("KingKibaTech") then
    _f:FindFirstChild("KingKibaTech"):Destroy()
end

local _g = Instance.new("ScreenGui")
_g.Name = "KingKibaTech"
_g.ResetOnSpawn = false
_g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
_g.IgnoreGuiInset = true
_g.Parent = _f

local _h = Instance.new("Frame")
_h.Name = "MainFrame"
_h.Size = UDim2.new(0, 158, 0, 68)
_h.Position = UDim2.new(1, 10, 0.5, -34)
_h.BackgroundColor3 = Color3.fromRGB(5, 10, 35)
_h.BackgroundTransparency = 0.18
_h.BorderSizePixel = 0
_h.ClipsDescendants = false
_h.Parent = _g

local _i = Instance.new("UICorner")
_i.CornerRadius = UDim.new(0, 20)
_i.Parent = _h

local _j = Instance.new("UIGradient")
_j.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 10, 42)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 26, 78)), ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 10, 42)) })
_j.Rotation = 145
_j.Parent = _h

local _k = Instance.new("UIStroke")
_k.Color = Color3.fromRGB(50, 110, 255)
_k.Thickness = 1.6
_k.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_k.Parent = _h

local _l = Instance.new("Frame")
_l.Size = UDim2.new(0.5, 0, 0, 2)
_l.Position = UDim2.new(0.25, 0, 0, 0)
_l.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
_l.BackgroundTransparency = 0.15
_l.BorderSizePixel = 0
_l.ZIndex = 3
_l.Parent = _h

local _m = Instance.new("UICorner")
_m.CornerRadius = UDim.new(1, 0)
_m.Parent = _l

local _n = Instance.new("Frame")
_n.Name = "TitleBar"
_n.Size = UDim2.new(1, 0, 0, 28)
_n.BackgroundTransparency = 1
_n.ZIndex = 4
_n.Parent = _h

local _o = Instance.new("TextLabel")
_o.Text = "KibaX Tech"
_o.Font = Enum.Font.GothamBold
_o.TextSize = 12
_o.TextColor3 = Color3.fromRGB(190, 215, 255)
_o.BackgroundTransparency = 1
_o.Size = UDim2.new(1, 0, 1, 0)
_o.TextXAlignment = Enum.TextXAlignment.Center
_o.ZIndex = 4
_o.Parent = _n

local _p = Instance.new("UIStroke")
_p.Color = Color3.fromRGB(70, 140, 255)
_p.Thickness = 0.7
_p.Parent = _o

_6(function()
    while true do
        _c:Create(_o, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(230, 245, 255) }):Play()
        _7(1.4)
        _c:Create(_o, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextColor3 = Color3.fromRGB(100, 150, 255) }):Play()
        _7(1.4)
    end
end)

local _q = Instance.new("Frame")
_q.Size = UDim2.new(0.75, 0, 0, 1)
_q.Position = UDim2.new(0.125, 0, 0, 28)
_q.BackgroundColor3 = Color3.fromRGB(50, 100, 220)
_q.BackgroundTransparency = 0.35
_q.BorderSizePixel = 0
_q.Parent = _h

local _r = Instance.new("Frame")
_r.Name = "ToggleTrack"
_r.Size = UDim2.new(1, -20, 0, 22)
_r.Position = UDim2.new(0, 10, 0, 36)
_r.BackgroundColor3 = Color3.fromRGB(16, 26, 68)
_r.BorderSizePixel = 0
_r.ClipsDescendants = true
_r.Parent = _h

local _s = Instance.new("UICorner")
_s.CornerRadius = UDim.new(1, 0)
_s.Parent = _r

local _t = Instance.new("UIStroke")
_t.Color = Color3.fromRGB(35, 75, 175)
_t.Thickness = 1.2
_t.Parent = _r

local _u = Instance.new("TextLabel")
_u.Text = "OFF"
_u.Font = Enum.Font.GothamBold
_u.TextSize = 9
_u.TextColor3 = Color3.fromRGB(80, 100, 160)
_u.BackgroundTransparency = 1
_u.Size = UDim2.new(1, 0, 1, 0)
_u.TextXAlignment = Enum.TextXAlignment.Center
_u.ZIndex = 2
_u.Parent = _r

local _v = Instance.new("Frame")
_v.Size = UDim2.new(0, 16, 0, 16)
_v.Position = UDim2.new(0, 3, 0.5, -8)
_v.BackgroundColor3 = Color3.fromRGB(70, 100, 175)
_v.BorderSizePixel = 0
_v.ZIndex = 3
_v.Parent = _r

local _w = Instance.new("UICorner")
_w.CornerRadius = UDim.new(1, 0)
_w.Parent = _v

local _x = Instance.new("UIStroke")
_x.Color = Color3.fromRGB(60, 120, 220)
_x.Thickness = 1.5
_x.Parent = _v

local _y = false

local function _z(s)
    _y = s
    _G.KibaEnabled = s
    local _A = 158 - 20
    local _B = _A - 16 - 3
    local _C = s and UDim2.new(0, _B, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    local _D = s and Color3.fromRGB(20, 65, 190) or Color3.fromRGB(16, 26, 68)
    local _E = s and Color3.fromRGB(140, 205, 255) or Color3.fromRGB(70, 100, 175)
    local _F = s and Color3.fromRGB(75, 145, 255) or Color3.fromRGB(35, 75, 175)
    local _G2 = s and Color3.fromRGB(110, 190, 255) or Color3.fromRGB(60, 120, 220)
    local _H = s and Color3.fromRGB(160, 220, 255) or Color3.fromRGB(80, 100, 160)
    _c:Create(_v, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { Position = _C, BackgroundColor3 = _E }):Play()
    _c:Create(_r, TweenInfo.new(0.18, Enum.EasingStyle.Quad), { BackgroundColor3 = _D }):Play()
    _c:Create(_t, TweenInfo.new(0.18), { Color = _F }):Play()
    _c:Create(_x, TweenInfo.new(0.18), { Color = _G2 }):Play()
    _c:Create(_u, TweenInfo.new(0.18), { TextColor3 = _H }):Play()
    _c:Create(_k, TweenInfo.new(0.1), { Color = s and Color3.fromRGB(120, 190, 255) or Color3.fromRGB(50, 110, 255) }):Play()
    _8(0.18, function()
        _c:Create(_k, TweenInfo.new(0.28), { Color = Color3.fromRGB(50, 110, 255) }):Play()
    end)
    local _I = s and -1 or 1
    _c:Create(_u, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1, Position = UDim2.new(0, _I * 10, 0, 0) }):Play()
    _8(0.1, function()
        _u.Text = s and "ON" or "OFF"
        _u.Position = UDim2.new(0, -_I * 10, 0, 0)
        _c:Create(_u, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { TextTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }):Play()
    end)
end

_r.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _z(not _y)
    end
end)

local _g2 = _f:WaitForChild("KingKibaTech")
local _h2 = _g2:WaitForChild("MainFrame")
local _n2 = _h2:WaitForChild("TitleBar")
local _k2 = _h2:FindFirstChildOfClass("UIStroke")

local _wm = Instance.new("TextLabel")
_wm.Name = "Watermark"
_wm.Text = "KibaX Tech"
_wm.Font = Enum.Font.GothamBold
_wm.TextSize = 13
_wm.TextColor3 = Color3.fromRGB(180, 210, 255)
_wm.TextTransparency = 0.8
_wm.BackgroundTransparency = 1
_wm.Size = UDim2.new(0, 180, 0, 26)
_wm.AnchorPoint = Vector2.new(1, 1)
_wm.Position = UDim2.new(1, -10, 1, -10)
_wm.TextXAlignment = Enum.TextXAlignment.Right
_wm.ZIndex = 20
_wm.Parent = _g2

local _ws = Instance.new("UIStroke")
_ws.Color = Color3.fromRGB(60, 120, 220)
_ws.Thickness = 0.5
_ws.Transparency = 0.8
_ws.Parent = _wm

_6(function()
    while true do
        _c:Create(_wm, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.6 }):Play()
        _7(2.2)
        _c:Create(_wm, TweenInfo.new(2.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { TextTransparency = 0.85 }):Play()
        _7(2.2)
    end
end)

local function _fs()
    local _fl = Instance.new("Frame")
    _fl.Size = UDim2.new(1, 0, 1, 0)
    _fl.Position = UDim2.new(0, 0, 0, 0)
    _fl.BackgroundColor3 = Color3.fromRGB(80, 160, 255)
    _fl.BackgroundTransparency = 0.82
    _fl.BorderSizePixel = 0
    _fl.ZIndex = 50
    _fl.Parent = _g2
    _c:Create(_fl, TweenInfo.new(0.35, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { BackgroundTransparency = 1 }):Play()
    _8(0.38, function()
        _fl:Destroy()
    end)
    for i = 1, 4 do
        _8((i - 1) * 0.08, function()
            local _rn = Instance.new("Frame")
            _rn.Size = UDim2.new(0, 10, 0, 10)
            _rn.AnchorPoint = Vector2.new(0.5, 0.5)
            _rn.Position = UDim2.new(0.5, 0, 0.5, 0)
            _rn.BackgroundTransparency = 1
            _rn.BorderSizePixel = 0
            _rn.ZIndex = 48
            _rn.Parent = _g2
            local _rc = Instance.new("UICorner")
            _rc.CornerRadius = UDim.new(1, 0)
            _rc.Parent = _rn
            local _rs = Instance.new("UIStroke")
            _rs.Color = Color3.fromRGB(100 + i * 20, 170 + i * 10, 255)
            _rs.Thickness = 3.5 - i * 0.4
            _rs.Transparency = 0
            _rs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            _rs.Parent = _rn
            local _ts = 280 + i * 90
            _c:Create(_rn, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, _ts, 0, _ts) }):Play()
            _c:Create(_rs, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Transparency = 1 }):Play()
            _8(0.6, function()
                _rn:Destroy()
            end)
        end)
    end
    for i = 1, 28 do
        _6(function()
            local _p2 = Instance.new("Frame")
            local _sz = math.random(5, 13)
            _p2.Size = UDim2.new(0, _sz, 0, _sz)
            _p2.AnchorPoint = Vector2.new(0.5, 0.5)
            _p2.Position = UDim2.new(0.5, 0, 0.5, 0)
            _p2.BackgroundColor3 = Color3.fromRGB(math.random(50, 140), math.random(130, 210), 255)
            _p2.BackgroundTransparency = 0
            _p2.BorderSizePixel = 0
            _p2.ZIndex = 47
            _p2.Parent = _g2
            local _pc = Instance.new("UICorner")
            _pc.CornerRadius = UDim.new(1, 0)
            _pc.Parent = _p2
            local _ag = (i / 28) * 360 + math.random(-18, 18)
            local _di = math.random(180, 480)
            local _rd = math.rad(_ag)
            local _ex = 0.5 + math.cos(_rd) * _di / 600
            local _ey = 0.5 + math.sin(_rd) * _di / 600
            _c:Create(_p2, TweenInfo.new(math.random(38, 62) / 100, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(_ex, 0, _ey, 0), BackgroundTransparency = 1, Size = UDim2.new(0, _sz * 0.2, 0, _sz * 0.2) }):Play()
            _8(0.65, function()
                _p2:Destroy()
            end)
        end)
    end
    local _gw = Instance.new("Frame")
    _gw.Size = UDim2.new(0, 20, 0, 20)
    _gw.AnchorPoint = Vector2.new(0.5, 0.5)
    _gw.Position = UDim2.new(0.5, 0, 0.5, 0)
    _gw.BackgroundColor3 = Color3.fromRGB(120, 190, 255)
    _gw.BackgroundTransparency = 0.1
    _gw.BorderSizePixel = 0
    _gw.ZIndex = 46
    _gw.Parent = _g2
    local _gc = Instance.new("UICorner")
    _gc.CornerRadius = UDim.new(1, 0)
    _gc.Parent = _gw
    _c:Create(_gw, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(0, 180, 0, 180), BackgroundTransparency = 1 }):Play()
    _8(0.35, function()
        _gw:Destroy()
    end)
    for i = 1, 16 do
        _6(function()
            _7(math.random(0, 12) / 100)
            local _sp = Instance.new("Frame")
            local _ss = math.random(3, 6)
            _sp.Size = UDim2.new(0, _ss, 0, _ss)
            _sp.AnchorPoint = Vector2.new(0.5, 0.5)
            _sp.Position = UDim2.new(0.5, math.random(-120, 120), 0.5, math.random(-120, 120))
            _sp.BackgroundColor3 = Color3.fromRGB(200, 230, 255)
            _sp.BackgroundTransparency = 0
            _sp.BorderSizePixel = 0
            _sp.ZIndex = 49
            _sp.Parent = _g2
            local _sc = Instance.new("UICorner")
            _sc.CornerRadius = UDim.new(1, 0)
            _sc.Parent = _sp
            _c:Create(_sp, TweenInfo.new(0.4, Enum.EasingStyle.Sine), { BackgroundTransparency = 1, Size = UDim2.new(0, _ss * 0.1, 0, _ss * 0.1) }):Play()
            _8(0.45, function()
                _sp:Destroy()
            end)
        end)
    end
    _c:Create(_k2, TweenInfo.new(0.08), { Color = Color3.fromRGB(180, 230, 255), Thickness = 4 }):Play()
    _8(0.1, function()
        _c:Create(_k2, TweenInfo.new(0.3, Enum.EasingStyle.Quad), { Color = Color3.fromRGB(50, 110, 255), Thickness = 1.6 }):Play()
    end)
end

_G.KibaFireSplash = _fs

local _cf = Instance.new("Frame")
_cf.Name = "CooldownFrame"
_cf.Size = UDim2.new(0, 120, 0, 36)
_cf.BackgroundColor3 = Color3.fromRGB(5, 10, 35)
_cf.BackgroundTransparency = 1
_cf.BorderSizePixel = 0
_cf.ZIndex = 10
_cf.Visible = false
_cf.Parent = _g2

local _cc = Instance.new("UICorner")
_cc.CornerRadius = UDim.new(0, 14)
_cc.Parent = _cf

local _cs = Instance.new("UIStroke")
_cs.Color = Color3.fromRGB(50, 110, 255)
_cs.Thickness = 1.4
_cs.Transparency = 1
_cs.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
_cs.Parent = _cf

local _cg = Instance.new("UIGradient")
_cg.Color = ColorSequence.new({ ColorSequenceKeypoint.new(0, Color3.fromRGB(4, 10, 42)), ColorSequenceKeypoint.new(0.5, Color3.fromRGB(10, 26, 78)), ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 10, 42)) })
_cg.Rotation = 135
_cg.Parent = _cf

local _cl = Instance.new("TextLabel")
_cl.Text = "⏱ 5.0s"
_cl.Font = Enum.Font.GothamBold
_cl.TextSize = 13
_cl.TextColor3 = Color3.fromRGB(140, 190, 255)
_cl.TextTransparency = 1
_cl.BackgroundTransparency = 1
_cl.Size = UDim2.new(1, 0, 0, 27)
_cl.Position = UDim2.new(0, 0, 0, 0)
_cl.TextXAlignment = Enum.TextXAlignment.Center
_cl.ZIndex = 11
_cl.Parent = _cf

local _cls = Instance.new("UIStroke")
_cls.Color = Color3.fromRGB(60, 120, 220)
_cls.Thickness = 0.6
_cls.Transparency = 1
_cls.Parent = _cl

local _cb = Instance.new("Frame")
_cb.Size = UDim2.new(0.85, 0, 0, 3)
_cb.Position = UDim2.new(0.075, 0, 0, 29)
_cb.BackgroundColor3 = Color3.fromRGB(18, 30, 80)
_cb.BackgroundTransparency = 0.3
_cb.BorderSizePixel = 0
_cb.ZIndex = 11
_cb.Parent = _cf

local _cbc = Instance.new("UICorner")
_cbc.CornerRadius = UDim.new(1, 0)
_cbc.Parent = _cb

local _cbr = Instance.new("Frame")
_cbr.Size = UDim2.new(1, 0, 1, 0)
_cbr.BackgroundColor3 = Color3.fromRGB(60, 130, 255)
_cbr.BorderSizePixel = 0
_cbr.ZIndex = 12
_cbr.Parent = _cb

local _cbrc = Instance.new("UICorner")
_cbrc.CornerRadius = UDim.new(1, 0)
_cbrc.Parent = _cbr

local function _pc2()
    local _vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
    _cf.Position = UDim2.new(0, 14, 0, _vp.Y - 52)
end

_pc2()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    _7()
    _pc2()
    if workspace.CurrentCamera then
        workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(_pc2)
    end
end)

local _cv = false
local _ch = false
local _cd = false

local function _sc2()
    if _cv then return end
    _cv = true
    _ch = false
    _cd = false
    _pc2()
    local _by = _cf.Position.Y.Offset
    _cf.Position = UDim2.new(0, 14, 0, _by + 16)
    _cf.BackgroundTransparency = 1
    _cl.TextTransparency = 1
    _cs.Transparency = 1
    _cls.Transparency = 1
    _cf.Visible = true
    _c:Create(_cf, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(0, 14, 0, _by), BackgroundTransparency = 0.2 }):Play()
    _c:Create(_cl, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { TextTransparency = 0 }):Play()
    _c:Create(_cs, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Transparency = 0 }):Play()
    _c:Create(_cls, TweenInfo.new(0.25, Enum.EasingStyle.Quad), { Transparency = 0 }):Play()
end

local function _hc()
    if _ch then return end
    _ch = true
    local _by = _cf.Position.Y.Offset
    _c:Create(_cf, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Position = UDim2.new(0, 14, 0, _by + 16), BackgroundTransparency = 1 }):Play()
    _c:Create(_cl, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { TextTransparency = 1 }):Play()
    _c:Create(_cs, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
    _c:Create(_cls, TweenInfo.new(0.22, Enum.EasingStyle.Quad), { Transparency = 1 }):Play()
    _8(0.32, function()
        _cf.Visible = false
        _cv = false
        _ch = false
    end)
end

local _CDMAX = 5
_b.Heartbeat:Connect(function()
    local _st = _G.KibaCooldownStart
    if _st == nil then
        _cd = false
        return
    end
    local _rm = _CDMAX - (_9() - _st)
    if _rm > 0 then
        _sc2()
        _cl.Text = "⏱ " .. string.format("%.1f", _rm) .. "s"
        _cbr.Size = UDim2.new(math.clamp(_rm / _CDMAX, 0, 1), 0, 1, 0)
        _cs.Color = Color3.fromHSV(0.6, 0.7, 0.6 + math.sin(_9() * 4) * 0.18)
    else
        if not _cd then
            _cd = true
            _cl.Text = "⏱ 0.0s"
            _cbr.Size = UDim2.new(0, 0, 1, 0)
            _G.KibaCooldownStart = nil
            _8(0.6, function()
                _hc()
            end)
        end
    end
end)

local function _sp2()
    local _p3 = Instance.new("Frame")
    _p3.Size = UDim2.new(0, math.random(2, 3), 0, math.random(2, 3))
    _p3.Position = UDim2.new(math.random(10, 90) / 100, 0, 1, 0)
    _p3.BackgroundColor3 = Color3.fromRGB(math.random(50, 110), math.random(100, 170), 255)
    _p3.BackgroundTransparency = 0.1
    _p3.BorderSizePixel = 0
    _p3.ZIndex = 2
    _p3.Parent = _h2
    local _c2 = Instance.new("UICorner")
    _c2.CornerRadius = UDim.new(1, 0)
    _c2.Parent = _p3
    local _tw = _c:Create(_p3, TweenInfo.new(math.random(18, 30) / 10, Enum.EasingStyle.Sine), { Position = UDim2.new(_p3.Position.X.Scale, 0, -0.1, 0), BackgroundTransparency = 1 })
    _tw:Play()
    _tw.Completed:Connect(function()
        _p3:Destroy()
    end)
end

local _gu = true
local _pt = 0
_b.Heartbeat:Connect(function(dt)
    _pt = _pt + dt
    if _pt >= 0.4 then
        _pt = 0
        _5(_sp2)
    end
    if _gu then
        _k2.Thickness = _k2.Thickness + 0.03
        if _k2.Thickness >= 2.8 then
            _gu = false
        end
    else
        _k2.Thickness = _k2.Thickness - 0.03
        if _k2.Thickness <= 1.0 then
            _gu = true
        end
    end
end)

local _dg = false
local _ds = nil
local _dp = nil
_n2.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        _dg = true
        _ds = i.Position
        _dp = _h2.Position
        _c:Create(_h2, TweenInfo.new(0.08), { BackgroundTransparency = 0.04 }):Play()
    end
end)

_d.InputChanged:Connect(function(i)
    if not _dg then return end
    if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
        local _dd = i.Position - _ds
        _h2.Position = UDim2.new(_dp.X.Scale, _dp.X.Offset + _dd.X, _dp.Y.Scale, _dp.Y.Offset + _dd.Y)
    end
end)

_d.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        if _dg then
            _dg = false
            _c:Create(_h2, TweenInfo.new(0.12), { BackgroundTransparency = 0.18 }):Play()
        end
    end
end)

_c:Create(_h2, TweenInfo.new(0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Position = UDim2.new(1, -168, 0.5, -34) }):Play()

local _pl = _a.LocalPlayer
local _ch2 = _pl.Character or _pl.CharacterAdded:Wait()
local _hm = _ch2:WaitForChild("Humanoid")
local _rp = _ch2:WaitForChild("HumanoidRootPart")
local _an = _hm:WaitForChild("Animator")
local _cm = _ch2:WaitForChild("Communicate")

local _AI = "10503381238"
local _DR = 12.7
local _CD2 = 5

local _aw = false
local _fi = false
local _ie = false
local _lt = nil
local _ac = nil
local _we = false
local _lf = 0

local function _rf()
    _aw = false
    _fi = false
    _ie = false
    _lt = nil
end

local function _sa()
    if _ac then
        _ac:Disconnect()
        _ac = nil
    end
    _hm:ChangeState(Enum.HumanoidStateType.Running)
    _hm.AutoRotate = true
end

local function _ft()
    local _cl2 = nil
    local _cd3 = _DR
    for _, p in ipairs(_a:GetPlayers()) do
        if p ~= _pl and p.Character then
            local _rt = p.Character:FindFirstChild("HumanoidRootPart")
            local _ht = p.Character:FindFirstChild("Humanoid")
            if _rt and _ht and _ht.Health > 0 then
                local _di = (_rt.Position - _rp.Position).Magnitude
                if _di < _cd3 then
                    _cd3 = _di
                    _cl2 = _rt
                end
            end
        end
    end
    for _, o in ipairs(workspace:GetDescendants()) do
        if o:IsA("Model") and o ~= _ch2 then
            local _dr = o:FindFirstChild("HumanoidRootPart")
            local _dh = o:FindFirstChild("Humanoid")
            if _dr and _dh and _dh.Health > 0 then
                local _ip = false
                for _, p in ipairs(_a:GetPlayers()) do
                    if p.Character == o then
                        _ip = true
                        break
                    end
                end
                if not _ip then
                    local _di = (_dr.Position - _rp.Position).Magnitude
                    if _di < _cd3 then
                        _cd3 = _di
                        _cl2 = _dr
                    end
                end
            end
        end
    end
    return _cl2
end

local function _ia()
    for _, t in ipairs(_an:GetPlayingAnimationTracks()) do
        local _id = tostring(t.Animation.AnimationId):match("%d+$")
        if _id == _AI then
            return true, t
        end
    end
    return false, nil
end

local function _ea(ct)
    _lf = _9()
    _G.KibaCooldownStart = _lf
    if type(_G.KibaFireSplash) == "function" then
        _5(_G.KibaFireSplash)
    end
    _5(function()
        _cm:FireServer(unpack({ { Dash = Enum.KeyCode.W, Key = Enum.KeyCode.Q, Goal = "KeyPress" } }))
    end)
    if ct and ct.Parent then
        local _ld = _rp.CFrame.LookVector
        local _my = math.atan2(-_ld.X, -_ld.Z)
        local _tp = ct.Position
        local _up = Vector3.new(_tp.X, _tp.Y - 2.8, _tp.Z)
        local _uc = CFrame.new(_up) * CFrame.fromEulerAnglesYXZ(math.pi / 2, _my, 0)
        _hm:ChangeState(Enum.HumanoidStateType.Physics)
        _hm.AutoRotate = false
        _rp.CFrame = _uc
        _rp.AssemblyLinearVelocity = Vector3.zero
        _rp.AssemblyAngularVelocity = Vector3.zero
        local _ro = _uc - _uc.Position
        if _ac then
            _ac:Disconnect()
        end
        local _el = 0
        local _FT = 0.55
        _ac = _b.Heartbeat:Connect(function(dt)
            _el = _el + dt
            if _el >= _FT then
                _ac:Disconnect()
                _ac = nil
                return
            end
            if not ct or not ct.Parent then
                _ac:Disconnect()
                _ac = nil
                return
            end
            local _lv = ct.Position
            local _lu = Vector3.new(_lv.X, _lv.Y - 2.8, _lv.Z)
            local _pr = _el / _FT
            local _ly = math.sin(_pr * math.pi) * 38
            local _dx = _lu.X - _rp.Position.X
            local _dz = _lu.Z - _rp.Position.Z
            _rp.AssemblyLinearVelocity = Vector3.new(_dx * 28, _ly, _dz * 28)
            _rp.AssemblyAngularVelocity = Vector3.zero
            _rp.CFrame = CFrame.new(_rp.Position) * _ro
        end)
    end
    _7(0.55)
    _sa()
    _ie = false
    _fi = false
    _lt = nil
end

_b.Heartbeat:Connect(function()
    local _en = _G.KibaEnabled == true
    local _ef = _3(_G.KibaEarlyFire) or 0.6
    if _en and not _we then
        _rf()
    end
    if not _en and _we then
        _rf()
        _5(_sa)
    end
    _we = _en
    if not _en then return end
    if (_9() - _lf) < _CD2 then return end
    local _pl2, _tr = _ia()
    if _pl2 and not _aw then
        _aw = true
        _fi = false
        _ie = false
        _lt = _ft()
    elseif _pl2 and _aw then
        if not _fi and not _ie and _lt then
            if _tr and _tr.Length and _tr.Length > 0.01 then
                local _tl = _tr.Length - _tr.TimePosition
                if _tl <= _ef then
                    _fi = true
                    _ie = true
                    local _cp = _lt
                    _6(function()
                        _ea(_cp)
                    end)
                end
            end
        end
    elseif not _pl2 and _aw then
        _aw = false
        if not _fi and not _ie and _lt then
            _fi = true
            _ie = true
            local _cp = _lt
            _6(function()
                _ea(_cp)
            end)
        else
            _rf()
        end
    else
        _rf()
    end
end)

print("Owner ThanhDuyHub")
