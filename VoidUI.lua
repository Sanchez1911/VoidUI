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
    Version = "1.3.2",
    _windows = {},
}

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

---------------------------------------------------------------------------
-- Theme
---------------------------------------------------------------------------
local Theme = {
    Accent = Color3.fromRGB(168, 85, 247),       -- purple
    AccentDim = Color3.fromRGB(126, 58, 210),
    Bg = Color3.fromRGB(11, 9, 15),
    BgPanel = Color3.fromRGB(17, 14, 24),
    BgSidebar = Color3.fromRGB(9, 7, 12),
    BgSection = Color3.fromRGB(22, 18, 30),
    BgHover = Color3.fromRGB(42, 32, 60),
    BgInput = Color3.fromRGB(34, 28, 46),
    BgToggleOff = Color3.fromRGB(52, 44, 66),
    Stroke = Color3.fromRGB(58, 46, 78),
    Divider = Color3.fromRGB(40, 34, 54),
    Text = Color3.fromRGB(255, 255, 255),
    TextDim = Color3.fromRGB(168, 158, 186),
    TextMute = Color3.fromRGB(112, 102, 130),
    Shadow = Color3.fromRGB(0, 0, 0),
    Danger = Color3.fromRGB(255, 92, 110),
    Success = Color3.fromRGB(168, 85, 247),
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
-- Icons — Lucide / Geist / Craft (Footagesus/Icons, same as WindUI)
-- Usage: "swords" | "lucide:swords" | "geist:window" | "craft:macbook-stroke"
--        or raw "rbxassetid://..."
---------------------------------------------------------------------------
local ICON_CDN = {
    lucide = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/lucide/dist/Icons.lua",
    craft = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/craft/dist/Icons.lua",
    geist = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/geist/dist/Icons.lua",
    solar = "https://raw.githubusercontent.com/Footagesus/Icons/refs/heads/main/solar/dist/Icons.lua",
}

local IconPacks = {}
local IconAlias = {
    home = "house",
    sword = "swords",
    bag = "backpack",
    gear = "settings",
    plant = "leaf",
    cart = "shopping-cart",
    shop = "shopping-cart",
    piggy = "piggy-bank",
    money = "coins",
    keys = "key",
    robot = "bot",
    turtle = "origami",
    chevron = "chevron-down",
    close = "x",
    minimize = "minus",
    search = "search",
    warn = "triangle-alert",
    check = "check",
    info = "info",
    dice = "dices",
    expand = "maximize-2",
    target = "crosshair",
    flame = "flame",
    bolt = "zap",
    eye = "eye",
    lock = "lock",
    unlock = "lock-open",
    server = "server",
    code = "code",
    list = "list",
    grid = "layout-grid",
    user = "user",
    star = "star",
    play = "play",
    pause = "pause",
    plus = "plus",
    minus = "minus",
}

local function httpGet(url)
    local ok, body = pcall(function()
        if type(game.HttpGetAsync) == "function" then
            return game:HttpGetAsync(url)
        end
        return game:HttpGet(url)
    end)
    if ok and type(body) == "string" and #body > 50 and body:sub(1, 1) ~= "<" then
        return body
    end
    return nil
end

local function loadIconPack(pack)
    pack = string.lower(pack or "lucide")
    if IconPacks[pack] then return IconPacks[pack] end
    local url = ICON_CDN[pack]
    if not url then return nil end
    local src = httpGet(url)
    if not src then return nil end
    local fn = (loadstring or load)(src, "@Icons-" .. pack)
    if not fn then return nil end
    local ok, data = pcall(fn)
    if ok and type(data) == "table" then
        IconPacks[pack] = data
        return data
    end
    return nil
end

-- returns rbxassetid string or nil
local function resolveIcon(name)
    if not name or name == "" then return nil end
    if typeof(name) ~= "string" then
        name = tostring(name)
    end
    if name:find("rbxasset", 1, true) or name:find("http", 1, true) then
        return name
    end

    local pack, iconName = "lucide", name
    local colon = name:find(":", 1, true)
    if colon then
        pack = string.lower(name:sub(1, colon - 1))
        iconName = name:sub(colon + 1)
    else
        iconName = IconAlias[string.lower(name)] or string.lower(name)
    end

    local set = loadIconPack(pack)
    if not set then
        -- fallback lucide
        if pack ~= "lucide" then
            set = loadIconPack("lucide")
            iconName = IconAlias[string.lower(iconName)] or iconName
        end
    end
    if not set then return nil end

    local id = set[iconName] or set[IconAlias[iconName]]
    if type(id) == "string" then return id end
    if type(id) == "number" then return "rbxassetid://" .. tostring(id) end
    if type(id) == "table" and id.Image then
        local img = id.Image
        if type(img) == "number" then return "rbxassetid://" .. tostring(img) end
        return img
    end
    return nil
end

local function makeIcon(parent, iconName, size, color, z)
    size = size or 18
    local asset = resolveIcon(iconName)
    local holder = Instance.new("Frame")
    holder.BackgroundTransparency = 1
    holder.Size = UDim2.fromOffset(size, size)
    holder.Parent = parent

    local img
    if asset then
        img = Instance.new("ImageLabel")
        img.BackgroundTransparency = 1
        img.Image = asset
        img.ImageColor3 = color or Theme.TextDim
        img.ScaleType = Enum.ScaleType.Fit
        img.Size = UDim2.fromScale(1, 1)
        img.ZIndex = z or 2
        img.Parent = holder
        holder:SetAttribute("IsIcon", true)
        return holder, img
    end
    local dot = Instance.new("Frame")
    dot.BackgroundColor3 = color or Theme.TextDim
    dot.BackgroundTransparency = 0.45
    dot.AnchorPoint = Vector2.new(0.5, 0.5)
    dot.Position = UDim2.fromScale(0.5, 0.5)
    dot.Size = UDim2.fromOffset(math.max(4, math.floor(size * 0.28)), math.max(4, math.floor(size * 0.28)))
    dot.Parent = holder
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = dot
    return holder, nil
end

local function setIconColor(iconImg, color)
    if iconImg and iconImg:IsA("ImageLabel") then
        iconImg.ImageColor3 = color
    end
end

VoidUI.ResolveIcon = resolveIcon
VoidUI.SetIconPack = function(_, pack)
    loadIconPack(pack)
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
    -- load lucide pack once (cached) so sidebar icons aren't blank on first paint
    loadIconPack("lucide")

    local accent = cfg.Accent or Theme.Accent
    local title = cfg.Title or "VoidUI"
    local author = cfg.Author or cfg.Subtitle or ""
    local logoIcon = cfg.Icon or "rbxassetid://111627748770819"
    local size = cfg.Size or UDim2.fromOffset(680, 540)
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
        ImageTransparency = 0.35,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(size.X.Scale, size.X.Offset + 56, size.Y.Scale, size.Y.Offset + 56),
        ZIndex = 0,
        Parent = screen,
    })

    local main = mk("Frame", {
        Name = "Main",
        BackgroundColor3 = T.Bg,
        BackgroundTransparency = cfg.Transparent and 0.04 or 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = size,
        ClipsDescendants = true,
        Parent = screen,
    })
    corner(main, 20)
    stroke(main, Color3.fromRGB(88, 60, 130), 1, 0.55)

    -- Sidebar
    local sidebarW = 64
    local sidebar = mk("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = T.BgSidebar,
        BackgroundTransparency = 0,
        Size = UDim2.new(0, sidebarW, 1, 0),
        BorderSizePixel = 0,
        Parent = main,
    })
    mk("Frame", {
        BackgroundColor3 = T.Stroke,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.fromScale(1, 0),
        Size = UDim2.new(0, 1, 1, 0),
        BackgroundTransparency = 0.35,
        Parent = sidebar,
    })

    local logo = mk("Frame", {
        Name = "Logo",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 64),
        Parent = sidebar,
    })
    -- no purple chip behind hub logo — keeps brand sharp
    local logoIsAsset = typeof(logoIcon) == "string" and (logoIcon:find("rbxasset", 1, true) or logoIcon:find("http", 1, true))
    local logoTint = logoIsAsset and Color3.new(1, 1, 1) or accent
    local logoHolder = makeIcon(logo, logoIcon, logoIsAsset and 32 or 24, logoTint, 2)
    logoHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    logoHolder.Position = UDim2.fromScale(0.5, 0.5)

    local sideNav = mk("ScrollingFrame", {
        Name = "Nav",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.fromOffset(0, 64),
        Size = UDim2.new(1, 0, 1, -64),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    list(sideNav, Enum.FillDirection.Vertical, 6, Enum.HorizontalAlignment.Center)
    pad(sideNav, 2, 0, 14, 0)

    -- Content shell (transparent so main corner radius fits clean — no bottom seam)
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
        Size = UDim2.new(1, 0, 0, 52),
        Parent = content,
    })
    pad(topBar, 0, 14, 0, 18)

    local titleLbl = mk("TextLabel", {
        BackgroundTransparency = 1,
        Font = Fonts.Title,
        TextSize = 16,
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
            TextSize = 12,
            TextColor3 = T.TextMute,
            TextXAlignment = Enum.TextXAlignment.Left,
            Text = author,
            Position = UDim2.fromOffset(0, 26),
            Size = UDim2.new(0.55, 0, 0, 14),
            Parent = topBar,
        })
        titleLbl.Size = UDim2.new(0.55, 0, 0, 24)
        titleLbl.Position = UDim2.fromOffset(0, 6)
    end

    local winBtns = mk("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -4, 0.5, 0),
        Size = UDim2.fromOffset(72, 30),
        Parent = topBar,
    })
    list(winBtns, Enum.FillDirection.Horizontal, 8, Enum.HorizontalAlignment.Right, Enum.VerticalAlignment.Center)

    local function winBtn(iconName, cb)
        local b = mk("TextButton", {
            BackgroundColor3 = T.BgInput,
            BackgroundTransparency = 0.15,
            Text = "",
            Size = UDim2.fromOffset(30, 30),
            AutoButtonColor = false,
            Parent = winBtns,
        })
        corner(b, 9)
        local h, img = makeIcon(b, iconName, 14, T.TextDim, 2)
        h.AnchorPoint = Vector2.new(0.5, 0.5)
        h.Position = UDim2.fromScale(0.5, 0.5)
        hover(b, function()
            tween(b, TI(0.12), { BackgroundColor3 = T.BgHover })
            setIconColor(img, T.Text)
        end, function()
            tween(b, TI(0.12), { BackgroundColor3 = T.BgInput })
            setIconColor(img, T.TextDim)
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    -- Horizontal subtabs strip
    local subTabBar = mk("Frame", {
        Name = "SubTabs",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 52),
        Size = UDim2.new(1, 0, 0, 36),
        Visible = false,
        Parent = content,
    })
    pad(subTabBar, 0, 18, 0, 18)
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
        Position = UDim2.fromOffset(0, 52),
        Size = UDim2.new(1, 0, 1, -52),
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
            pages.Position = UDim2.fromOffset(0, 88)
            pages.Size = UDim2.new(1, 0, 1, -88)
        else
            subTabBar.Visible = false
            pages.Position = UDim2.fromOffset(0, 52)
            pages.Size = UDim2.new(1, 0, 1, -52)
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

    winBtn("lucide:minus", function()
        Window:SetVisible(false)
        VoidUI:Notify({ Title = title, Content = "Hidden — press toggle key to show", Duration = 2 })
    end)
    winBtn("lucide:x", function()
        Window:Destroy()
    end)

    -- Toggle key (mutable — Keybind can rebind via Window:SetToggleKey)
    local toggleKeyState = toggleKey
    function Window:SetToggleKey(key)
        if typeof(key) == "EnumItem" then
            toggleKeyState = key
        end
    end
    function Window:GetToggleKey()
        return toggleKeyState
    end

    UserInputService.InputBegan:Connect(function(input, gp)
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        if input.KeyCode ~= toggleKeyState then return end
        -- allow toggle even if gameProcessed (chat/menus often eat G); skip only when typing in a TextBox
        if UserInputService:GetFocusedTextBox() then return end
        Window:Toggle()
    end)

    ---------------------------------------------------------------------------
    -- Tab (sidebar entry)
    ---------------------------------------------------------------------------
    function Window:Tab(opts)
        opts = opts or {}
        local tabTitle = opts.Title or "Tab"
        local tabIcon = opts.Icon or "lucide:house"
        local selected = opts.Selected

        local btn = mk("TextButton", {
            Name = "Tab_" .. tabTitle,
            BackgroundTransparency = 1,
            Text = "",
            Size = UDim2.fromOffset(48, 48),
            AutoButtonColor = false,
            Parent = sideNav,
        })

        local indicator = mk("Frame", {
            BackgroundColor3 = accent,
            BorderSizePixel = 0,
            AnchorPoint = Vector2.new(0, 0.5),
            Position = UDim2.new(0, 2, 0.5, 0),
            Size = UDim2.fromOffset(3, 0),
            Parent = btn,
        })
        corner(indicator, 2)

        local iconBg = mk("Frame", {
            BackgroundColor3 = accent,
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(40, 40),
            Parent = btn,
        })
        corner(iconBg, 12)

        local iconHolder, iconLbl = makeIcon(iconBg, tabIcon, 20, T.TextDim, 2)
        iconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
        iconHolder.Position = UDim2.fromScale(0.5, 0.5)

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

        local darkIcon = Color3.new(1, 1, 1) -- white icon on purple active chip
        function Tab:_setActive(on)
            pageHost.Visible = on
            if on then
                tween(indicator, TI(0.18, Enum.EasingStyle.Quart), { Size = UDim2.fromOffset(3, 22) })
                tween(iconBg, TI(0.18), { BackgroundTransparency = 0 })
                if iconLbl then
                    tween(iconLbl, TI(0.18), { ImageColor3 = darkIcon })
                end
            else
                tween(indicator, TI(0.18), { Size = UDim2.fromOffset(3, 0) })
                tween(iconBg, TI(0.18), { BackgroundTransparency = 1 })
                if iconLbl then
                    tween(iconLbl, TI(0.18), { ImageColor3 = T.TextDim })
                end
            end
        end

        btn.MouseEnter:Connect(function()
            if not pageHost.Visible then
                tween(iconBg, TI(0.12), { BackgroundColor3 = T.BgHover, BackgroundTransparency = 0 })
            end
        end)
        btn.MouseLeave:Connect(function()
            if not pageHost.Visible then
                tween(iconBg, TI(0.12), { BackgroundTransparency = 1 })
                iconBg.BackgroundColor3 = accent
            end
        end)

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
                ScrollBarThickness = 2,
                ScrollBarImageColor3 = T.TextMute,
                ScrollBarImageTransparency = 0.35,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                Visible = false,
                Parent = pageHost,
            })
            pad(frame, 12, 20, 40, 20)

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
                    BackgroundTransparency = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Parent = wrap,
                })
                corner(card, 14)
                stroke(card, T.Stroke, 1, 0.25)
                pad(card, 4, 6, 4, 6)
                list(card, Enum.FillDirection.Vertical, 0)

                local Section = { Frame = card, Title = secTitle }
                local rowOrder = 0

                -- thin separator between consecutive rows
                local function addDivider()
                    if rowOrder == 0 then return end
                    rowOrder = rowOrder + 1
                    local d = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 1),
                        LayoutOrder = rowOrder,
                        Parent = card,
                    })
                    mk("Frame", {
                        BackgroundColor3 = T.Divider,
                        BorderSizePixel = 0,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.new(1, -12, 0, 1),
                        Parent = d,
                    })
                end

                -- base row container: fixed comfortable height, left text + right control slot
                local function makeRow(titleText, descText)
                    addDivider()
                    rowOrder = rowOrder + 1
                    local row = mk("Frame", {
                        BackgroundColor3 = T.BgSection,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        LayoutOrder = rowOrder,
                        Parent = card,
                    })
                    row:SetAttribute("_bt", 1)
                    pad(row, 12, 12, 12, 14)

                    -- subtle hover highlight over the whole row
                    local hitBg = mk("Frame", {
                        BackgroundColor3 = T.BgHover,
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        ZIndex = 0,
                        Parent = row,
                    })
                    corner(hitBg, 8)

                    local left = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, -138, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        Parent = row,
                    })
                    list(left, Enum.FillDirection.Vertical, 3)

                    mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Title,
                        TextSize = 14,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = titleText or "",
                        Size = UDim2.new(1, 0, 0, 17),
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

                    addDivider()
                    rowOrder = rowOrder + 1
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        LayoutOrder = rowOrder,
                        Parent = card,
                    })
                    pad(row, 12, 12, 12, 14)
                    list(row, Enum.FillDirection.Vertical, 8)

                    local top = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 17),
                        LayoutOrder = 1,
                        Parent = row,
                    })
                    mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Title,
                        TextSize = 14,
                        TextColor3 = T.Text,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Text = o.Title or "Slider",
                        Size = UDim2.new(1, -60, 1, 0),
                        Parent = top,
                    })
                    local valLbl = mk("TextLabel", {
                        BackgroundTransparency = 1,
                        Font = Fonts.Title,
                        TextSize = 13,
                        TextColor3 = accent,
                        TextXAlignment = Enum.TextXAlignment.Right,
                        Text = (decimals > 0 and string.format("%." .. decimals .. "f", value) or tostring(math.floor(value + 0.5))) .. suffix,
                        AnchorPoint = Vector2.new(1, 0.5),
                        Position = UDim2.new(1, 0, 0.5, 0),
                        Size = UDim2.fromOffset(56, 17),
                        Parent = top,
                    })

                    if o.Desc and o.Desc ~= "" then
                        mk("TextLabel", {
                            BackgroundTransparency = 1,
                            Font = Fonts.Desc,
                            TextSize = 11,
                            TextColor3 = T.TextDim,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextYAlignment = Enum.TextYAlignment.Top,
                            TextWrapped = true,
                            Text = o.Desc,
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            LayoutOrder = 2,
                            Parent = row,
                        })
                    end

                    local trackWrap = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 14),
                        LayoutOrder = 3,
                        Parent = row,
                    })
                    local track = mk("Frame", {
                        BackgroundColor3 = T.BgInput,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.new(1, 0, 0, 6),
                        Parent = trackWrap,
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
                        Size = UDim2.fromOffset(16, 16),
                        ZIndex = 3,
                        Parent = track,
                    })
                    corner(knob, 8)
                    stroke(knob, Color3.fromRGB(12, 8, 18), 3, 0)

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
                        Size = UDim2.new(1, -32, 1, 0),
                        Parent = box,
                    })
                    local chevHolder = makeIcon(box, "lucide:chevron-down", 14, T.TextDim, 2)
                    chevHolder.AnchorPoint = Vector2.new(1, 0.5)
                    chevHolder.Position = UDim2.new(1, -8, 0.5, 0)

                    local open = false
                    local menu
                    local openToken = 0

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

                    -- IgnoreGuiInset ScreenGui AbsolutePosition is inset-free;
                    -- GetMouseLocation includes topbar — must subtract or bottom row fails hit-tests.
                    local function mouseGuiPos()
                        return UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
                    end

                    local function pointIn(gui, p)
                        local a = gui.AbsolutePosition
                        local s = gui.AbsoluteSize
                        return p.X >= a.X and p.X <= a.X + s.X and p.Y >= a.Y and p.Y <= a.Y + s.Y
                    end

                    local function openMenu()
                        if open then closeMenu() return end
                        open = true
                        openToken += 1

                        local abs = box.AbsolutePosition
                        local boxSz = box.AbsoluteSize
                        local itemH = 32
                        local gap = 3
                        local padTop, padBot = 8, 10
                        local menuH = padTop + padBot + #values * itemH + math.max(0, #values - 1) * gap
                        local menuW = math.max(boxSz.X, 172)

                        local screenH = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.Y or 1080
                        local spaceBelow = screenH - (abs.Y + boxSz.Y)
                        local openUp = spaceBelow < (menuH + 16)
                        local posX = math.max(8, abs.X + boxSz.X - menuW)
                        local posY = openUp and (abs.Y - menuH - 6) or (abs.Y + boxSz.Y + 6)
                        posY = math.max(8, posY)

                        menu = mk("Frame", {
                            BackgroundColor3 = T.BgSection,
                            BorderSizePixel = 0,
                            Position = UDim2.fromOffset(posX, posY),
                            Size = UDim2.fromOffset(menuW, menuH),
                            ZIndex = 500,
                            Parent = screen,
                        })
                        corner(menu, 10)
                        stroke(menu, accent, 1, 0.55)
                        pad(menu, padTop, 8, padBot, 8)

                        local listHost = mk("Frame", {
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 501,
                            Parent = menu,
                        })
                        list(listHost, Enum.FillDirection.Vertical, gap)

                        for _, v in ipairs(values) do
                            local selected = isSelected(v)
                            local item = mk("TextButton", {
                                BackgroundColor3 = selected and accent or T.BgInput,
                                BackgroundTransparency = selected and 0.35 or 0.2,
                                AutoButtonColor = false,
                                Active = true,
                                Text = "",
                                Size = UDim2.new(1, 0, 0, itemH),
                                ZIndex = 502,
                                Parent = listHost,
                            })
                            corner(item, 8)
                            mk("TextLabel", {
                                BackgroundTransparency = 1,
                                Font = Fonts.Body,
                                TextSize = 12,
                                TextColor3 = selected and Color3.new(1, 1, 1) or T.Text,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                Text = tostring(v),
                                Size = UDim2.new(1, -14, 1, 0),
                                Position = UDim2.fromOffset(12, 0),
                                ZIndex = 503,
                                Active = false,
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
                                    txt.Text = labelText()
                                    fire()
                                    closeMenu()
                                    task.defer(openMenu)
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
                        if not open or not menu then return end
                        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
                        local tokenAtClick = openToken
                        task.delay(0.05, function()
                            if tokenAtClick ~= openToken or not open or not menu then return end
                            local p = mouseGuiPos()
                            if pointIn(menu, p) or pointIn(box, p) then return end
                            closeMenu()
                        end)
                    end)

                    if o.Flag then Window._flags[o.Flag] = api end
                    return api
                end

                -----------------------------------------------------------------
                -- Button
                -----------------------------------------------------------------
                function Section:Button(o)
                    o = o or {}
                    addDivider()
                    rowOrder = rowOrder + 1
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 50),
                        LayoutOrder = rowOrder,
                        Parent = card,
                    })
                    pad(row, 8, 8, 8, 8)
                    local b = mk("TextButton", {
                        BackgroundColor3 = accent,
                        AutoButtonColor = false,
                        Font = Fonts.Title,
                        TextSize = 13,
                        TextColor3 = Color3.new(1, 1, 1),
                        Text = o.Title or "Button",
                        Size = UDim2.fromScale(1, 1),
                        Parent = row,
                    })
                    corner(b, 10)
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
                        if o.WindowToggle and Window.SetToggleKey then
                            Window:SetToggleKey(k)
                        end
                        if not silent and o.Callback then task.spawn(o.Callback, k) end
                    end
                    api.Set = function(_, k, silent) setKey(k, silent) end

                    if o.WindowToggle and Window.SetToggleKey then
                        Window:SetToggleKey(key)
                    end

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
                            return
                        end
                        -- Window toggle is handled by Window listener — don't double-fire Pressed
                        if o.WindowToggle then return end
                        if UserInputService:GetFocusedTextBox() then return end
                        if not listening and key and key ~= Enum.KeyCode.Unknown and input.KeyCode == key then
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
                    addDivider()
                    rowOrder = rowOrder + 1
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.Y,
                        LayoutOrder = rowOrder,
                        Parent = card,
                    })
                    pad(row, 12, 12, 12, 14)
                    list(row, Enum.FillDirection.Vertical, 4)
                    if o.Title then
                        mk("TextLabel", {
                            BackgroundTransparency = 1,
                            Font = Fonts.Title,
                            TextSize = 14,
                            TextColor3 = T.Text,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = o.Title,
                            Size = UDim2.new(1, 0, 0, 17),
                            LayoutOrder = 1,
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
                        LayoutOrder = 2,
                        Parent = row,
                    })
                    return {
                        Set = function(_, text)
                            body.Text = tostring(text or "")
                        end,
                    }
                end

                function Section:Divider()
                    rowOrder = rowOrder + 1
                    local row = mk("Frame", {
                        BackgroundTransparency = 1,
                        Size = UDim2.new(1, 0, 0, 12),
                        LayoutOrder = rowOrder,
                        Parent = card,
                    })
                    mk("Frame", {
                        BackgroundColor3 = T.Divider,
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.fromScale(0.5, 0.5),
                        Size = UDim2.new(1, -12, 0, 1),
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
