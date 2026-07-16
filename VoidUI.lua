--[[
    VoidUI — WindUI / Cascade style library
    Dark + lime · sidebar · tabs · toggle/slider/dropdown/input/keybind/button
    Usage:
      local VoidUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Sanchez1911/VoidUI/main/VoidUI.lua"))()

    API sketch:
      local W = VoidUI:CreateWindow({ Title=..., Icon=..., Accent=..., ToggleKey=Enum.KeyCode.RightShift })
      local T = W:Tab({ Title="Farm", Icon="sword" })
      local S = T:Section({ Title="AUTOMATION" })
      S:Toggle({ Title=..., Desc=..., Value=false, Callback=fn })
      S:Slider({ Title=..., Min=0, Max=10, Value=5, Suffix="s", Callback=fn })
      S:Dropdown({ Title=..., Values={...}, Value=..., Multi=false, Callback=fn })
      S:Button / Input / Keybind / Paragraph / Divider
      VoidUI:Notify({ Title=..., Content=..., Duration=3 })
]]

local VoidUI = {
    Version = "1.0.0",
    _windows = {},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

---------------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------------
local Theme = {
    Accent = Color3.fromRGB(192, 255, 62),
    AccentDim = Color3.fromRGB(140, 190, 40),
    Bg = Color3.fromRGB(18, 18, 18),
    BgPanel = Color3.fromRGB(22, 22, 22),
    BgSidebar = Color3.fromRGB(14, 14, 14),
    BgSection = Color3.fromRGB(28, 28, 28),
    BgHover = Color3.fromRGB(36, 36, 36),
    BgInput = Color3.fromRGB(32, 32, 32),
    BgToggleOff = Color3.fromRGB(48, 48, 48),
    Stroke = Color3.fromRGB(40, 40, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(140, 140, 140),
    TextMute = Color3.fromRGB(90, 90, 90),
    Shadow = Color3.fromRGB(0, 0, 0),
    Danger = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(192, 255, 62),
}

local Fonts = {
    Title = Enum.Font.GothamBold,
    Body = Enum.Font.GothamMedium,
    Desc = Enum.Font.Gotham,
    Mono = Enum.Font.Code,
}

local TI = TweenInfo.new
local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

---------------------------------------------------------------------------
-- Icons (simple lucide-ish glyph map via unicode / rbxasset)
-- Prefer Image when rbxassetid given; else TextLabel glyph
---------------------------------------------------------------------------
local Icons = {
    home = "⌂",
    house = "⌂",
    sword = "⚔",
    swords = "⚔",
    dice = "⚄",
    backpack = "🎒",
    bag = "🎒",
    expand = "⤢",
    compass = "◎",
    wrench = "🔧",
    settings = "⚙",
    gear = "⚙",
    leaf = "☘",
    plant = "☘",
    cart = "🛒",
    shop = "🛒",
    piggy = "🐷",
    money = "💰",
    mail = "✉",
    moon = "☾",
    key = "🔑",
    keys = "🔑",
    cloud = "☁",
    star = "★",
    user = "☺",
    search = "⌕",
    close = "✕",
    minimize = "–",
    chevron = "▾",
    check = "✓",
    info = "ℹ",
    warn = "⚠",
    plus = "+",
    minus = "−",
    play = "▶",
    pause = "❚❚",
    robot = "⚙",
    turtle = "🐢",
    target = "◎",
    flame = "🔥",
    bolt = "⚡",
    eye = "👁",
    lock = "🔒",
    unlock = "🔓",
    server = "▦",
    code = "</>",
    list = "☰",
    grid = "▦",
}

local function resolveIcon(name)
    if not name or name == "" then return nil, nil end
    if typeof(name) == "string" then
        if name:find("rbxasset", 1, true) or name:find("http", 1, true) then
            return name, nil
        end
        local g = Icons[string.lower(name)]
        return nil, g or name
    end
    return nil, tostring(name)
end

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function protect(gui)
    if syn and syn.protect_gui then
        pcall(syn.protect_gui, gui)
    elseif protect_gui then
        pcall(protect_gui, gui)
    end
    local parent
    if gethui then
        pcall(function() parent = gethui() end)
    end
    if not parent then
        pcall(function() parent = CoreGui end)
    end
    if not parent then
        parent = LP:FindFirstChildOfClass("PlayerGui") or LP:WaitForChild("PlayerGui")
    end
    gui.Parent = parent
    return gui
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thick or 1
    s.Transparency = trans or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function pad(parent, t, r, b, l)
    local p = Instance.new("UIPadding")
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingRight = UDim.new(0, r or t or 0)
    p.PaddingBottom = UDim.new(0, b or t or 0)
    p.PaddingLeft = UDim.new(0, l or r or t or 0)
    p.Parent = parent
    return p
end

local function list(parent, dir, padPx, hAlign, vAlign)
    local l = Instance.new("UIListLayout")
    l.FillDirection = dir or Enum.FillDirection.Vertical
    l.Padding = UDim.new(0, padPx or 8)
    l.SortOrder = Enum.SortOrder.LayoutOrder
    l.HorizontalAlignment = hAlign or Enum.HorizontalAlignment.Left
    l.VerticalAlignment = vAlign or Enum.VerticalAlignment.Top
    l.Parent = parent
    return l
end

local function mk(class, props, children)
    local i = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            i[k] = v
        end
    end
    if children then
        for _, c in ipairs(children) do
            c.Parent = i
        end
    end
    if props and props.Parent then
        i.Parent = props.Parent
    end
    return i
end

local function hover(btn, onEnter, onLeave)
    btn.MouseEnter:Connect(onEnter)
    btn.MouseLeave:Connect(onLeave)
end

local function ripples(btn, color)
    -- light press flash
    btn.MouseButton1Down:Connect(function()
        tween(btn, TI(0.08), { BackgroundTransparency = math.min((btn.BackgroundTransparency or 0) + 0.1, 0.5) })
    end)
    btn.MouseButton1Up:Connect(function()
        tween(btn, TI(0.12), { BackgroundTransparency = btn:GetAttribute("_bt") or 0 })
    end)
end

---------------------------------------------------------------------------
-- Notifications
---------------------------------------------------------------------------
local notifHost

local function ensureNotifHost()
    if notifHost and notifHost.Parent then return notifHost end
    local sg = Instance.new("ScreenGui")
    sg.Name = "VoidUI_Notify"
    sg.ResetOnSpawn = false
    sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    sg.DisplayOrder = 9999
    protect(sg)
    notifHost = mk("Frame", {
        Name = "Host",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.fromOffset(320, 600),
        Parent = sg,
    })
    list(notifHost, Enum.FillDirection.Vertical, 10, Enum.HorizontalAlignment.Right)
    return notifHost
end

function VoidUI:Notify(opts)
    opts = opts or {}
    local host = ensureNotifHost()
    local duration = opts.Duration or 3.5
    local accent = opts.Accent or Theme.Accent

    local card = mk("Frame", {
        BackgroundColor3 = Theme.BgPanel,
        Size = UDim2.fromOffset(300, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = host,
    })
    corner(card, 12)
    stroke(card, Theme.Stroke, 1, 0.3)
    pad(card, 14, 14, 14, 14)

    local bar = mk("Frame", {
        BackgroundColor3 = accent,
        Size = UDim2.new(0, 3, 1, 0),
        Position = UDim2.fromOffset(0, 0),
        BorderSizePixel = 0,
        Parent = card,
    })
    corner(bar, 2)

    mk("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.Title,
        TextSize = 14,
        TextColor3 = Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = opts.Title or "Notification",
        Size = UDim2.new(1, -8, 0, 18),
        Position = UDim2.fromOffset(8, 0),
        Parent = card,
    })

    if opts.Content and opts.Content ~= "" then
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Font = Fonts.Desc,
            TextSize = 12,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Text = opts.Content,
            Size = UDim2.new(1, -8, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.fromOffset(8, 22),
            Parent = card,
        })
    end

    card.BackgroundTransparency = 1
    tween(card, TI(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { BackgroundTransparency = 0.05 })

    task.delay(duration, function()
        if not card.Parent then return end
        local tw = tween(card, TI(0.2), { BackgroundTransparency = 1 })
        tw.Completed:Wait()
        card:Destroy()
    end)
    return card
end

---------------------------------------------------------------------------
-- CreateWindow
---------------------------------------------------------------------------
function VoidUI:CreateWindow(cfg)
    cfg = cfg or {}
    local accent = cfg.Accent or Theme.Accent
    local title = cfg.Title or "VoidUI"
    local author = cfg.Author or cfg.Subtitle or ""
    local iconAsset, iconGlyph = resolveIcon(cfg.Icon or "turtle")
    local size = cfg.Size or UDim2.fromOffset(620, 480)
    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    local folder = cfg.Folder -- optional config folder name

    -- deep copy theme overrides
    local T = {}
    for k, v in pairs(Theme) do T[k] = v end
    T.Accent = accent
    if cfg.Theme and type(cfg.Theme) == "table" then
        for k, v in pairs(cfg.Theme) do T[k] = v end
    end

    local screen = Instance.new("ScreenGui")
    screen.Name = "VoidUI_" .. tostring(math.random(1000, 9999))
    screen.ResetOnSpawn = false
    screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screen.DisplayOrder = 100
    screen.IgnoreGuiInset = true
    protect(screen)

    -- Drop shadow
    local shadow = mk("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.45,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(size.X.Scale, size.X.Offset + 40, size.Y.Scale, size.Y.Offset + 40),
        ZIndex = 0,
        Parent = screen,
    })

    local main = mk("Frame", {
        Name = "Main",
        BackgroundColor3 = T.Bg,
        BackgroundTransparency = cfg.Transparent and 0.08 or 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        ClipsDescendants = true,
        Parent = screen,
    })
    corner(main, 16)
    stroke(main, T.Stroke, 1, 0.35)

    -- Sidebar
    local sidebarW = 56
    local sidebar = mk("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = T.BgSidebar,
        BackgroundTransparency = 0.15,
        Size = UDim2.new(0, sidebarW, 1, 0),
        BorderSizePixel = 0,
        Parent = main,
    })
    stroke(sidebar, T.Stroke, 1, 0.5)

    local logo = mk("Frame", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 56),
        Parent = sidebar,
    })

    if iconAsset then
        mk("ImageLabel", {
            BackgroundTransparency = 1,
            Image = iconAsset,
            ImageColor3 = accent,
            Size = UDim2.fromOffset(28, 28),
            Position = UDim2.new(0.5, -14, 0.5, -14),
            Parent = logo,
        })
    else
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Text = iconGlyph or "🐢",
            TextSize = 22,
            Font = Fonts.Title,
            TextColor3 = accent,
            Size = UDim2.fromScale(1, 1),
            Parent = logo,
        })
    end

    local sideNav = mk("ScrollingFrame", {
        Name = "Nav",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 56),
        Size = UDim2.new(1, 0, 1, -56),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    list(sideNav, Enum.FillDirection.Vertical, 4, Enum.HorizontalAlignment.Center)
    pad(sideNav, 4, 0, 12, 0)

    -- Content shell
    local content = mk("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(sidebarW, 0),
        Size = UDim2.new(1, -sidebarW, 1, 0),
        ClipsDescendants = true,
        Parent = main,
    })

    -- Top bar (title + window controls)
    local topBar = mk("Frame", {
        Name = "TopBar",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 44),
        Parent = content,
    })
    pad(topBar, 0, 12, 0, 16)

    local titleLbl = mk("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.Title,
        TextSize = 15,
        TextColor3 = T.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Text = title,
        Size = UDim2.new(0.55, 0, 1, 0),
        Parent = topBar,
    })

    if author ~= "" then
        mk("TextLabel", {
            BackgroundTransparency = 1,
            Font = Fonts.Desc,
            TextSize = 11,
            TextColor3 = T.TextMute,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = author,
            Position = UDim2.fromOffset(0, 22),
            Size = UDim2.new(0.55, 0, 0, 14),
            Parent = topBar,
        })
        titleLbl.Size = UDim2.new(0.55, 0, 0, 22)
        titleLbl.Position = UDim2.fromOffset(0, 4)
    end

    local winBtns = mk("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.fromOffset(72, 28),
        Parent = topBar,
    })
    list(winBtns, Enum.FillDirection.Horizontal, 6, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local function winBtn(glyph, cb)
        local b = mk("TextButton", {
            BackgroundColor3 = T.BgInput,
            BackgroundTransparency = 0.3,
            Text = glyph,
            TextColor3 = T.TextDim,
            TextSize = 14,
            Font = Fonts.Body,
            Size = UDim2.fromOffset(28, 28),
            AutoButtonColor = false,
            Parent = winBtns,
        })
        corner(b, 8)
        hover(b, function()
            tween(b, TI(0.12), { BackgroundColor3 = T.BgHover, TextColor3 = T.Text })
        end, function()
            tween(b, TI(0.12), { BackgroundColor3 = T.BgInput, TextColor3 = T.TextDim })
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    -- Horizontal subtabs strip
    local subTabBar = mk("Frame", {
        Name = "SubTabs",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 0, 36),
        Visible = false,
        Parent = content,
    })
    pad(subTabBar, 0, 16, 0, 16)
    local subTabList = mk("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
        Parent = subTabBar,
    })
    list(subTabList, Enum.FillDirection.Horizontal, 18, Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)

    -- Pages host
    local pages = mk("Frame", {
        Name = "Pages",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 1, -44),
        ClipsDescendants = true,
        Parent = content,
    })

    ---------------------------------------------------------------------------
    -- Drag
    ---------------------------------------------------------------------------
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            local np = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            main.Position = np
            shadow.Position = np
        end
    end)

    ---------------------------------------------------------------------------
    -- Window API
    ---------------------------------------------------------------------------
    local Window = {
        ScreenGui = screen,
        Main = main,
        Theme = T,
        Accent = accent,
        _tabs = {},
        _activeTab = nil,
        _flags = {},
        Visible = true,
    }

    local function setPagesOffset(hasSub)
        if hasSub then
            subTabBar.Visible = true
            pages.Position = UDim2.fromOffset(0, 80)
            pages.Size = UDim2.new(1, 0, 1, -80)
        else
            subTabBar.Visible = false
            pages.Position = UDim2.fromOffset(0, 44)
            pages.Size = UDim2.new(1, 0, 1, -44)
        end
    end

    function Window:SetVisible(v)
        self.Visible = v and true or false
        screen.Enabled = self.Visible
    end

    function Window:Toggle()
        self:SetVisible(not self.Visible)
    end

    function Window:Destroy()
        screen:Destroy()
        for i, w in ipairs(VoidUI._windows) do
            if w == self then
                table.remove(VoidUI._windows, i)
                break
            end
        end
    end

    function Window:SelectTab(tab)
        if not tab then return end
        for _, t in ipairs(self._tabs) do
            t:_setActive(t == tab)
        end
        self._activeTab = tab
        -- rebuild subtabs
        for _, c in ipairs(subTabList:GetChildren()) do
            if c:IsA("GuiObject") then c:Destroy() end
        end
        local hasSub = #tab._pages > 1
        setPagesOffset(hasSub)
        if hasSub then
            for _, page in ipairs(tab._pages) do
                local btn = mk("TextButton", {
                    BackgroundTransparency = 1,
                    AutoButtonColor = false,
                    Font = Fonts.Body,
                    TextSize = 13,
                    Text = page.Title,
                    TextColor3 = page._active and accent or T.TextDim,
                    Size = UDim2.fromOffset(0, 28),
                    AutomaticSize = Enum.AutomaticSize.X,
                    Parent = subTabList,
                })
                local under = mk("Frame", {
                    BackgroundColor3 = accent,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(0, 1),
                    Position = UDim2.new(0, 0, 1, 0),
                    Size = UDim2.new(1, 0, 0, page._active and 2 or 0),
                    Parent = btn,
                })
                corner(under, 1)
                btn.MouseButton1Click:Connect(function()
                    tab:SelectPage(page)
                end)
                page._subBtn = btn
                page._under = under
            end
        end
        if tab._activePage then
            tab:SelectPage(tab._activePage)
        elseif tab._pages[1] then
            tab:SelectPage(tab._pages[1])
        end
    end

    winBtn("–", function()
        Window:SetVisible(false)
        VoidUI:Notify({ Title = title, Content = "Hidden — press toggle key to show", Duration = 2 })
    end)
    winBtn("✕", function()
        Window:Destroy()
    end)

    -- Toggle key
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            Window:Toggle()
        end
    end)

    ---------------------------------------------------------------------------
    -- Tab (sidebar entry)
    ---------------------------------------------------------------------------
    function Window:Tab(opts)
        opts = opts or {}
        local tabTitle = opts.Title or "Tab"
        local img, glyph = resolveIcon(opts.Icon or "home")
        local selected = opts.Selected

        local btn = mk("TextButton", {
            Name = "Tab_" .. tabTitle,
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.fromOffset(44, 44),
            AutoButtonColor = false,
            Parent = sideNav,
        })

        local indicator = mk("Frame", {
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 0, 0.5, 0),
            Size = UDim2.fromOffset(3, 0),
            Parent = btn,
        })
        corner(indicator, 2)

        local iconBg = mk("Frame", {
            BackgroundColor3 = T.BgHover,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(36, 36),
            Parent = btn,
        })
        corner(iconBg, 10)

        local iconLbl
        if img then
            iconLbl = mk("ImageLabel", {
                BackgroundTransparency = 1,
                Image = img,
                ImageColor3 = T.TextDim,
                Size = UDim2.fromOffset(20, 20),
                Position = UDim2.new(0.5, -10, 0.5, -10),
                Parent = iconBg,
            })
        else
            iconLbl = mk("TextLabel", {
                BackgroundTransparency = 1,
                Text = glyph or "•",
                TextSize = 16,
                Font = Fonts.Body,
                TextColor3 = T.TextDim,
                Size = UDim2.fromScale(1, 1),
                Parent = iconBg,
            })
        end

        local pageHost = mk("Frame", {
            Name = "TabHost_" .. tabTitle,
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            Visible = false,
            Parent = pages,
        })

        local Tab = {
            Title = tabTitle,
            Button = btn,
            Host = pageHost,
            _pages = {},
            _activePage = nil,
            _window = Window,
        }

        function Tab:_setActive(on)
            pageHost.Visible = on
            if on then
                tween(indicator, TI(0.18, Enum.EasingStyle.Quart), { Size = UDim2.fromOffset(3, 22) })
                tween(iconBg, TI(0.18), { BackgroundTransparency = 0.55 })
                if iconLbl:IsA("ImageLabel") then
                    tween(iconLbl, TI(0.18), { ImageColor3 = accent })
                else
                    tween(iconLbl, TI(0.18), { TextColor3 = accent })
                end
            else
                tween(indicator, TI(0.18), { Size = UDim2.fromOffset(3, 0) })
                tween(iconBg, TI(0.18), { BackgroundTransparency = 1 })
                if iconLbl:IsA("ImageLabel") then
                    tween(iconLbl, TI(0.18), { ImageColor3 = T.TextDim })
                else
                    tween(iconLbl, TI(0.18), { TextColor3 = T.TextDim })
                end
            end
        end

        function Tab:SelectPage(page)
            for _, p in ipairs(self._pages) do
                p.Frame.Visible = (p == page)
                p._active = (p == page)
                if p._subBtn then
                    p._subBtn.TextColor3 = p._active and accent or T.TextDim
                end
                if p._under then
                    tween(p._under, TI(0.15), { Size = UDim2.new(1, 0, 0, p._active and 2 or 0) })
                end
            end
            self._activePage = page
        end

        ---------------------------------------------------------------------------
        -- Page (horizontal sub-tab) — if only one, no subtab UI
        ---------------------------------------------------------------------------
        function Tab:Page(popts)
            popts = popts or {}
            local pageTitle = popts.Title or tabTitle

            local frame = mk("ScrollingFrame", {
                Name = "Page_" .. pageTitle,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
                ScrollBarThickness = 3,
                ScrollBarImageColor3 = accent,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible = false,
                Parent = pageHost,
            })
            pad(frame, 8, 16, 20, 16)

            -- two-column optional layout container
            local body = mk("Frame", {
                Name = "Body",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = frame,
            })

            local columns = popts.Columns or 1
            local colFrames = {}
            if columns >= 2 then
                local row = mk("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = body,
                })
                local layout = Instance.new("UIListLayout")
                layout.FillDirection = Enum.FillDirection.Horizontal
                layout.Padding = UDim.new(0, 12)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Parent = row
                for i = 1, columns do
                    local col = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1 / columns, -6, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        LayoutOrder = i,
                        Parent = row,
                    })
                    list(col, Enum.FillDirection.Vertical, 14)
                    colFrames[i] = col
                end
            else
                list(body, Enum.FillDirection.Vertical, 14)
                colFrames[1] = body
            end

            local Page = {
                Title = pageTitle,
                Frame = frame,
                Body = body,
                _active = false,
                _columns = colFrames,
            }

            function Page:Section(sopts)
                sopts = sopts or {}
                local colIndex = sopts.Column or 1
                local parentCol = colFrames[colIndex] or colFrames[1]
                local secTitle = sopts.Title or "SECTION"

                local wrap = mk("Frame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = parentCol,
                })
                list(wrap, Enum.FillDirection.Vertical, 8)

                mk("TextLabel", {
                    BackgroundTransparency = 1,
                    Font = Fonts.Body,
                    TextSize = 11,
                    TextColor3 = T.TextMute,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Text = string.upper(secTitle),
                    Size = UDim2.new(1, 0, 0, 14),
                    Parent = wrap,
                })

                local card = mk("Frame", {
                    BackgroundColor3 = T.BgSection,
                    BackgroundTransparency = 0.25,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = wrap,
                })
                corner(card, 12)
                stroke(card, T.Stroke, 1, 0.55)
                pad(card, 6, 10, 6, 10)
                list(card, Enum.FillDirection.Vertical, 2)

                local Section = { Frame = card, Title = secTitle }

                local function makeRow(titleText, descText)
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = card,
                    })
                    pad(row, 10, 4, 10, 4)

                    local left = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -130, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = row,
                    })
                    list(left, Enum.FillDirection.Vertical, 3)

                    mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Title,
                        TextSize = 13,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = titleText or "",
                        Size = UDim2.new(1, 0, 0, 16),
                        Parent = left,
                    })

                    if descText and descText ~= "" then
                        mk("TextLabel", {
                            BackgroundTransparency = 1,
                            Font = Fonts.Desc,
                            TextSize = 11,
                            TextColor3 = T.TextDim,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextWrapped = true,
                            Text = descText,
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            Parent = left,
                        })
                    end

                    local right = mk("Frame", {
                        BackgroundTransparency = 1,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.fromOffset(120, 28),
                        Parent = row,
                    })
                    return row, left, right
                end

                -----------------------------------------------------------------
                -- Toggle
                -----------------------------------------------------------------
                function Section:Toggle(o)
                    o = o or {}
                    local value = o.Value and true or false
                    local _, _, right = makeRow(o.Title or "Toggle", o.Desc)

                    right.Size = UDim2.fromOffset(46, 26)
                    local track = mk("Frame", {
                        BackgroundColor3 = value and accent or T.BgToggleOff,
                        Size = UDim2.fromScale(1, 1),
                        Parent = right,
                    })
                    corner(track, 13)
                    local knob = mk("Frame", {
                        BackgroundColor3 = Color3.new(1, 1, 1),
                        Size = UDim2.fromOffset(20, 20),
                        Position = value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
                        Parent = track,
                    })
                    corner(knob, 10)

                    local hit = mk("TextButton", {
                        BackgroundTransparency = 1,
                        Text = "",
                        Size = UDim2.fromScale(1, 1),
                        Parent = track,
                    })

                    local api = {
                        Value = value,
                        Set = function(self, v, silent)
                            self.Value = v and true or false
                            tween(track, TI(0.18), { BackgroundColor3 = self.Value and accent or T.BgToggleOff })
                            tween(knob, TI(0.18, Enum.EasingStyle.Quart), {
                                Position = self.Value and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10),
                            })
                            if not silent and o.Callback then
                                task.spawn(o.Callback, self.Value)
                            end
                        end,
                    }

                    hit.MouseButton1Click:Connect(function()
                        api:Set(not api.Value)
                    end)

                    if o.Flag then Window._flags[o.Flag] = api end
                    return api
                end

                -----------------------------------------------------------------
                -- Slider
                -----------------------------------------------------------------
                function Section:Slider(o)
                    o = o or {}
                    local min, max = o.Min or 0, o.Max or 100
                    local value = math.clamp(o.Value or min, min, max)
                    local suffix = o.Suffix or ""
                    local decimals = o.Decimals or 0

                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = card,
                    })
                    pad(row, 10, 4, 10, 4)

                    local top = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 18),
                        Parent = row,
                    })
                    mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Title,
                        TextSize = 13,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = o.Title or "Slider",
                        Size = UDim2.new(1, -50, 1, 0),
                        Parent = top,
                    })
                    local valLbl = mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Body,
                        TextSize = 12,
                        TextColor3 = accent,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = (decimals > 0 and string.format("%." .. decimals .. "f", value) or tostring(math.floor(value + 0.5))) .. suffix,
                        AnchorPoint = Vector2.new(1, 0),
                        Position = UDim2.fromScale(1, 0),
                        Size = UDim2.fromOffset(48, 18),
                        Parent = top,
                    })

                    if o.Desc and o.Desc ~= "" then
                        mk("TextLabel", {
                            BackgroundTransparency = 1,
                            Font = Fonts.Desc,
                            TextSize = 11,
                            TextColor3 = T.TextDim,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextWrapped = true,
                            Text = o.Desc,
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            Parent = row,
                        })
                    end

                    local track = mk("Frame", {
                        BackgroundColor3 = T.BgInput,
                        Size = UDim2.new(1, 0, 0, 6),
                        Parent = row,
                    })
                    corner(track, 3)
                    local fill = mk("Frame", {
                        BackgroundColor3 = accent,
                        Size = UDim2.new((value - min) / math.max(max - min, 1e-6), 0, 1, 0),
                        Parent = track,
                    })
                    corner(fill, 3)
                    local knob = mk("Frame", {
                        BackgroundColor3 = accent,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new((value - min) / math.max(max - min, 1e-6), 0, 0.5, 0),
                        Size = UDim2.fromOffset(14, 14),
                        Parent = track,
                    })
                    corner(knob, 7)
                    stroke(knob, Color3.new(1, 1, 1), 1, 0.7)

                    local sliding = false
                    local api = { Value = value }

                    local function setFromX(x, silent)
                        local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
                        local raw = min + rel * (max - min)
                        if decimals <= 0 then
                            raw = math.floor(raw + 0.5)
                        else
                            local m = 10 ^ decimals
                            raw = math.floor(raw * m + 0.5) / m
                        end
                        api.Value = raw
                        local p = (raw - min) / math.max(max - min, 1e-6)
                        fill.Size = UDim2.new(p, 0, 1, 0)
                        knob.Position = UDim2.new(p, 0, 0.5, 0)
                        valLbl.Text = (decimals > 0 and string.format("%." .. decimals .. "f", raw) or tostring(raw)) .. suffix
                        if not silent and o.Callback then
                            task.spawn(o.Callback, raw)
                        end
                    end

                    function api:Set(v, silent)
                        v = math.clamp(v, min, max)
                        local p = (v - min) / math.max(max - min, 1e-6)
                        self.Value = v
                        fill.Size = UDim2.new(p, 0, 1, 0)
                        knob.Position = UDim2.new(p, 0, 0.5, 0)
                        valLbl.Text = (decimals > 0 and string.format("%." .. decimals .. "f", v) or tostring(v)) .. suffix
                        if not silent and o.Callback then task.spawn(o.Callback, v) end
                    end

                    track.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = true
                            setFromX(input.Position.X)
                        end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                            setFromX(input.Position.X)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            sliding = false
                        end
                    end)

                    if o.Flag then Window._flags[o.Flag] = api end
                    return api
                end

                -----------------------------------------------------------------
                -- Dropdown
                -----------------------------------------------------------------
                function Section:Dropdown(o)
                    o = o or {}
                    local values = o.Values or { "Option 1" }
                    local multi = o.Multi == true
                    local current = o.Value
                    if multi then
                        if type(current) ~= "table" then current = {} end
                    else
                        if current == nil then current = values[1] end
                    end

                    local row, _, right = makeRow(o.Title or "Dropdown", o.Desc)
                    right.Size = UDim2.fromOffset(128, 30)

                    local box = mk("TextButton", {
                        BackgroundColor3 = T.BgInput,
                        AutoButtonColor = false,
                        Text = "",
                        Size = UDim2.fromScale(1, 1),
                        Parent = right,
                    })
                    corner(box, 8)
                    stroke(box, T.Stroke, 1, 0.4)

                    local function labelText()
                        if multi then
                            local n = #current
                            if n == 0 then return o.Placeholder or "Select..." end
                            if n == 1 then return tostring(current[1]) end
                            return n .. " selected"
                        end
                        return tostring(current or o.Placeholder or "Select...")
                    end

                    local txt = mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Body,
                        TextSize = 12,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextTruncate = Enum.TextTruncate.AtEnd,
                        Text = labelText(),
                        Position = UDim2.fromOffset(10, 0),
                        Size = UDim2.new(1, -28, 1, 0),
                        Parent = box,
                    })
                    mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Text = "▾",
                        TextColor3 = T.TextDim,
                        TextSize = 12,
                        Font = Fonts.Body,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, -8, 0.5, 0),
                        Size = UDim2.fromOffset(14, 14),
                        Parent = box,
                    })

                    local open = false
                    local menu

                    local api = {
                        Value = current,
                        Values = values,
                    }

                    local function closeMenu()
                        open = false
                        if menu then menu:Destroy() menu = nil end
                    end

                    local function isSelected(v)
                        if multi then
                            for _, x in ipairs(current) do
                                if x == v then return true end
                            end
                            return false
                        end
                        return current == v
                    end

                    local function fire()
                        if o.Callback then task.spawn(o.Callback, current) end
                    end

                    local function openMenu()
                        if open then closeMenu() return end
                        open = true
                        -- portal to Main so ScrollingFrame doesn't clip the list
                        local abs = box.AbsolutePosition
                        local rootPos = main.AbsolutePosition
                        local menuH = math.min(28 + #values * 30, 220)
                        local menuW = math.max(box.AbsoluteSize.X, 160)
                        menu = mk("Frame", {
                            BackgroundColor3 = T.BgPanel,
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(
                                abs.X - rootPos.X + box.AbsoluteSize.X - menuW,
                                abs.Y - rootPos.Y + box.AbsoluteSize.Y + 6
                            ),
                            Size = UDim2.fromOffset(menuW, menuH),
                            ZIndex = 200,
                            Parent = main,
                        })
                        corner(menu, 10)
                        stroke(menu, T.Stroke, 1, 0.3)
                        local sc = mk("ScrollingFrame", {
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 1),
                            ScrollBarThickness = 3,
                            ScrollBarImageColor3 = accent,
                            CanvasSize = UDim2.new(0, 0, 0, 0),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ZIndex = 201,
                            Parent = menu,
                        })
                        pad(sc, 6, 6, 6, 6)
                        list(sc, Enum.FillDirection.Vertical, 2)

                        for _, v in ipairs(values) do
                            local item = mk("TextButton", {
                                BackgroundColor3 = isSelected(v) and accent or T.BgInput,
                                BackgroundTransparency = isSelected(v) and 0.75 or 0.4,
                                AutoButtonColor = false,
                                Text = "",
                                Size = UDim2.new(1, 0, 0, 28),
                                ZIndex = 202,
                                Parent = sc,
                            })
                            corner(item, 7)
                            mk("TextLabel", {
                                BackgroundTransparency = 1,
                                Font = Fonts.Body,
                                TextSize = 12,
                                TextColor3 = isSelected(v) and accent or T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = tostring(v),
                                Size = UDim2.new(1, -12, 1, 0),
                                Position = UDim2.fromOffset(10, 0),
                                ZIndex = 203,
                                Parent = item,
                            })
                            item.MouseButton1Click:Connect(function()
                                if multi then
                                    local found
                                    for i, x in ipairs(current) do
                                        if x == v then found = i break end
                                    end
                                    if found then
                                        table.remove(current, found)
                                    else
                                        table.insert(current, v)
                                    end
                                    api.Value = current
                                    closeMenu()
                                    openMenu()
                                    txt.Text = labelText()
                                    fire()
                                else
                                    current = v
                                    api.Value = current
                                    txt.Text = labelText()
                                    closeMenu()
                                    fire()
                                end
                            end)
                        end
                    end

                    box.MouseButton1Click:Connect(openMenu)

                    function api:Set(v, silent)
                        if multi then
                            current = type(v) == "table" and v or { v }
                        else
                            current = v
                        end
                        self.Value = current
                        txt.Text = labelText()
                        if not silent then fire() end
                    end

                    function api:Refresh(newValues)
                        values = newValues or values
                        self.Values = values
                    end

                    UserInputService.InputBegan:Connect(function(input)
                        if open and input.UserInputType == Enum.UserInputType.MouseButton1 then
                            task.defer(function()
                                if not open or not menu then return end
                                local m = UserInputService:GetMouseLocation()
                                local abs = menu.AbsolutePosition
                                local sz = menu.AbsoluteSize
                                local inMenu = m.X >= abs.X and m.X <= abs.X + sz.X and m.Y >= abs.Y and m.Y <= abs.Y + sz.Y
                                local babs = box.AbsolutePosition
                                local bsz = box.AbsoluteSize
                                local inBox = m.X >= babs.X and m.X <= babs.X + bsz.X and m.Y >= babs.Y and m.Y <= babs.Y + bsz.Y
                                if not inMenu and not inBox then closeMenu() end
                            end)
                        end
                    end)

                    if o.Flag then Window._flags[o.Flag] = api end
                    return api
                end

                -----------------------------------------------------------------
                -- Button
                -----------------------------------------------------------------
                function Section:Button(o)
                    o = o or {}
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 44),
                        Parent = card,
                    })
                    pad(row, 6, 4, 6, 4)
                    local b = mk("TextButton", {
                        BackgroundColor3 = accent,
                        AutoButtonColor = false,
                        Font = Fonts.Title,
                        TextSize = 13,
                        TextColor3 = Color3.fromRGB(20, 20, 20),
                        Text = o.Title or "Button",
                        Size = UDim2.fromScale(1, 1),
                        Parent = row,
                    })
                    corner(b, 9)
                    hover(b, function()
                        tween(b, TI(0.12), { BackgroundColor3 = T.AccentDim })
                    end, function()
                        tween(b, TI(0.12), { BackgroundColor3 = accent })
                    end)
                    b.MouseButton1Click:Connect(function()
                        if o.Callback then task.spawn(o.Callback) end
                    end)
                    return b
                end

                -----------------------------------------------------------------
                -- Input
                -----------------------------------------------------------------
                function Section:Input(o)
                    o = o or {}
                    local _, _, right = makeRow(o.Title or "Input", o.Desc)
                    right.Size = UDim2.fromOffset(128, 30)
                    local box = mk("TextBox", {
                        BackgroundColor3 = T.BgInput,
                        Font = Fonts.Body,
                        TextSize = 12,
                        TextColor3 = T.Text,
                        PlaceholderText = o.Placeholder or "...",
                        PlaceholderColor3 = T.TextMute,
                        Text = o.Value and tostring(o.Value) or "",
                        ClearTextOnFocus = false,
                        Size = UDim2.fromScale(1, 1),
                        Parent = right,
                    })
                    corner(box, 8)
                    stroke(box, T.Stroke, 1, 0.4)
                    pad(box, 0, 8, 0, 8)

                    local api = { Value = box.Text }
                    box.FocusLost:Connect(function(enter)
                        api.Value = box.Text
                        if o.Callback then task.spawn(o.Callback, box.Text, enter) end
                    end)
                    function api:Set(v, silent)
                        box.Text = tostring(v or "")
                        self.Value = box.Text
                        if not silent and o.Callback then task.spawn(o.Callback, box.Text, false) end
                    end
                    if o.Flag then Window._flags[o.Flag] = api end
                    return api
                end

                -----------------------------------------------------------------
                -- Keybind
                -----------------------------------------------------------------
                function Section:Keybind(o)
                    o = o or {}
                    local key = o.Value or Enum.KeyCode.Unknown
                    local _, _, right = makeRow(o.Title or "Keybind", o.Desc)
                    right.Size = UDim2.fromOffset(100, 30)
                    local box = mk("TextButton", {
                        BackgroundColor3 = T.BgInput,
                        AutoButtonColor = false,
                        Font = Fonts.Body,
                        TextSize = 12,
                        TextColor3 = T.Text,
                        Text = key.Name or "None",
                        Size = UDim2.fromScale(1, 1),
                        Parent = right,
                    })
                    corner(box, 8)
                    stroke(box, T.Stroke, 1, 0.4)

                    local listening = false
                    local api = { Value = key }

                    local function setKey(k, silent)
                        key = k
                        api.Value = k
                        box.Text = (k and k.Name) or "None"
                        if not silent and o.Callback then task.spawn(o.Callback, k) end
                    end
                    api.Set = function(_, k, silent) setKey(k, silent) end

                    box.MouseButton1Click:Connect(function()
                        listening = true
                        box.Text = "..."
                        box.TextColor3 = accent
                    end)

                    UserInputService.InputBegan:Connect(function(input, gp)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            listening = false
                            box.TextColor3 = T.Text
                            if input.KeyCode == Enum.KeyCode.Escape then
                                setKey(Enum.KeyCode.Unknown)
                            else
                                setKey(input.KeyCode)
                            end
                        elseif not gp and not listening and key and key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
                            if o.Pressed then task.spawn(o.Pressed) end
                        end
                    end)

                    if o.Flag then Window._flags[o.Flag] = api end
                    return api
                end

                -----------------------------------------------------------------
                -- Paragraph / Label
                -----------------------------------------------------------------
                function Section:Paragraph(o)
                    o = o or {}
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = card,
                    })
                    pad(row, 10, 4, 10, 4)
                    if o.Title then
                        mk("TextLabel", {
                            BackgroundTransparency = 1,
                            Font = Fonts.Title,
                            TextSize = 13,
                            TextColor3 = T.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = o.Title,
                            Size = UDim2.new(1, 0, 0, 16),
                            Parent = row,
                        })
                    end
                    local body = mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Desc,
                        TextSize = 12,
                        TextColor3 = T.TextDim,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        TextYAlignment = Enum.TextYAlignment.Top,
                        TextWrapped = true,
                        Text = o.Content or o.Desc or "",
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = row,
                    })
                    return {
                        Set = function(_, text)
                            body.Text = tostring(text or "")
                        end,
                    }
                end

                function Section:Divider()
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        Parent = card,
                    })
                    mk("Frame", {
                        BackgroundColor3 = T.Stroke,
                        BackgroundTransparency = 0.4,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.new(1, -8, 0, 1),
                        BorderSizePixel = 0,
                        Parent = row,
                    })
                end

                return Section
            end

            -- convenience: Tab:Section goes to first/default page
            table.insert(Tab._pages, Page)
            if not Tab._activePage then
                Tab._activePage = Page
                Page.Frame.Visible = true
                Page._active = true
            end
            return Page
        end

        -- Tab:Section → auto page
        function Tab:Section(sopts)
            if #self._pages == 0 then
                self:Page({ Title = self.Title })
            end
            return self._pages[1]:Section(sopts)
        end

        btn.MouseButton1Click:Connect(function()
            Window:SelectTab(Tab)
        end)

        table.insert(Window._tabs, Tab)
        if selected or #Window._tabs == 1 then
            Window:SelectTab(Tab)
        else
            Tab:_setActive(false)
        end
        return Tab
    end

    -- Config helpers
    function Window:GetFlag(name)
        return self._flags[name]
    end

    function Window:SaveConfig(name)
        if not (writefile and folder) then return false end
        local data = {}
        for flag, api in pairs(self._flags) do
            if api and api.Value ~= nil then
                local v = api.Value
                if typeof(v) == "EnumItem" then
                    data[flag] = { __enum = v.EnumType.Name, name = v.Name }
                else
                    data[flag] = v
                end
            end
        end
        pcall(function()
            if makefolder and not isfolder(folder) then makefolder(folder) end
            writefile(folder .. "/" .. (name or "config") .. ".json", HttpService:JSONEncode(data))
        end)
        return true
    end

    function Window:LoadConfig(name)
        if not (readfile and isfile and folder) then return false end
        local path = folder .. "/" .. (name or "config") .. ".json"
        if not isfile(path) then return false end
        local ok, raw = pcall(readfile, path)
        if not ok then return false end
        local ok2, data = pcall(HttpService.JSONDecode, HttpService, raw)
        if not ok2 or type(data) ~= "table" then return false end
        for flag, val in pairs(data) do
            local api = self._flags[flag]
            if api and api.Set then
                if type(val) == "table" and val.__enum then
                    local enumType = Enum[val.__enum]
                    if enumType then
                        pcall(function() api:Set(enumType[val.name], true) end)
                    end
                else
                    pcall(function() api:Set(val, true) end)
                end
            end
        end
        return true
    end

    table.insert(VoidUI._windows, Window)

    if cfg.OpenCallback then
        task.spawn(cfg.OpenCallback, Window)
    end

    return Window
end

function VoidUI:SetAccent(color)
    Theme.Accent = color
end

return VoidUI
