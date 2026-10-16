--[[
    ═══════════════════════════════════════════════════════
    VzNam Hub-Main (Đã cập nhật Tab Farm & Tính năng Trộm Trứng)
    ═══════════════════════════════════════════════════════
    • Màn hình chờ: Tiêu đề "VzNam Hub-Main" + 3 thông tin + Thanh tiến trình (0 -> 10)
    • Các tab: Trang Chủ, Farm, MISC, Cấu Hình
]]

local CoreGui   = game:GetService("CoreGui")
local Players   = game:GetService("Players")
local TweenService    = game:GetService("TweenService")
local UserInputService= game:GetService("UserInputService")
local SoundService    = game:GetService("SoundService")
local HttpService     = game:GetService("HttpService")
local RunService      = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

if PlayerGui:FindFirstChild("VzNamHubV4UI") then PlayerGui.VzNamHubV4UI:Destroy() end
if PlayerGui:FindFirstChild("VzNamHubLoading") then PlayerGui.VzNamHubLoading:Destroy() end
if SoundService:FindFirstChild("VzNamHubSound") then SoundService.VzNamHubSound:Destroy() end

-- ═════════════════ CONNECTION TRACKING ═════════════════
local Connections = {}
local function Track(conn)
    if conn then table.insert(Connections, conn) end
    return conn
end
local function DisconnectAll()
    for _, c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections = {}
end

-- ═════════════════ STATE ═════════════════
local State = {
    ThemeBase      = Color3.fromRGB(15, 16, 22),
    StrokeMode     = "Solid",
    StrokeColor    = Color3.fromRGB(0, 191, 255),
    Volume         = 0.5,
    SoundId        = "1837879082",
    CurrentConfig  = "Default",
    Transparent    = 0,
    -- Farm / Egg Steal States
    AutoStealEggs       = false,
    SuperSteal          = false,
    SuperStealSteps     = 2,
    FastDelivery        = false,
    SuperStealV2        = false,
    TargetArea          = "12 đã chọn",
    MinRarity           = "Tất cả",
    MinEggValue         = false,
    TargetEgg           = "Tất cả",
    StealMissingLabEggs = false,
    StealMissingBookEggs= false,
    StealPriority       = "Giá trị cao nhất",
    TweenFlySpeed       = 120,
    EggCarrySpeed       = 100,
    DropEggsSafeZone    = false,
    AntiGuardPanel      = false,
}

-- ═════════════════ UI HELPERS ═════════════════
local function Corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = radius or UDim.new(0, 5)
    return c
end

local AllUIStrokes = {}
local function Stroke(parent, color, thickness)
    local s = Instance.new("UIStroke", parent)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Color = color or State.StrokeColor
    s.Thickness = thickness or 1
    table.insert(AllUIStrokes, s)
    return s
end

local ThemedElements = {}
local function RegTheme(el, t)
    table.insert(ThemedElements, {Element = el, Type = t})
    return el
end

-- ═════════════════ ROOT UI ═════════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzNamHubV4UI"
ScreenGui.DisplayOrder = 99999
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 380, 0, 280)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = false -- Ẩn đi chờ load xong
MainFrame.Parent = ScreenGui

Corner(MainFrame, UDim.new(0, 8))
local OuterStroke = Stroke(MainFrame, Color3.fromRGB(0, 191, 255), 2)

-- ═════════════════ LOADING SCREEN ═════════════════
local LoadingGui = Instance.new("ScreenGui")
LoadingGui.Name = "VzNamHubLoading"
LoadingGui.DisplayOrder = 100000
LoadingGui.ResetOnSpawn = false
LoadingGui.Parent = PlayerGui

local LoadFrame = Instance.new("Frame", LoadingGui)
LoadFrame.Size = UDim2.new(0, 340, 0, 220)
LoadFrame.AnchorPoint = Vector2.new(0.5, 0.5)
LoadFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
LoadFrame.BorderSizePixel = 0
Corner(LoadFrame, UDim.new(0, 8))
Stroke(LoadFrame, Color3.fromRGB(0, 191, 255), 2)

local LoadTitle = Instance.new("TextLabel", LoadFrame)
LoadTitle.Size = UDim2.new(1, 0, 0, 35)
LoadTitle.Position = UDim2.new(0, 0, 0, 8)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "🌸 VzNam Hub-Main 🌸"
LoadTitle.TextColor3 = Color3.fromRGB(0, 191, 255)
LoadTitle.TextSize = 13
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextXAlignment = Enum.TextXAlignment.Center

local LoadInfoHolder = Instance.new("Frame", LoadFrame)
LoadInfoHolder.Size = UDim2.new(1, -20, 0, 95)
LoadInfoHolder.Position = UDim2.new(0, 10, 0, 45)
LoadInfoHolder.BackgroundTransparency = 1
local LoadInfoLayout = Instance.new("UIListLayout", LoadInfoHolder)
LoadInfoLayout.SortOrder = Enum.SortOrder.LayoutOrder
LoadInfoLayout.Padding = UDim.new(0, 4)
LoadInfoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateLoadCard(parent, order, bgColor, titleText, mainText, borderColor, iconSymbol)
    local card = Instance.new("Frame", parent)
    card.LayoutOrder = order
    card.Size = UDim2.new(1, 0, 0, 27)
    card.BackgroundColor3 = bgColor
    card.BorderSizePixel = 0
    Corner(card)
    Stroke(card, borderColor, 1)

    local iconCircle = Instance.new("Frame", card)
    iconCircle.Size = UDim2.new(0, 16, 0, 16)
    iconCircle.Position = UDim2.new(0, 4, 0.5, -8)
    iconCircle.BackgroundColor3 = borderColor
    iconCircle.BorderSizePixel = 0
    Corner(iconCircle, UDim.new(1, 0))
    Stroke(iconCircle, borderColor)

    local iconLbl = Instance.new("TextLabel", iconCircle)
    iconLbl.Size = UDim2.new(1,0,1,0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = iconSymbol
    iconLbl.TextColor3 = Color3.fromRGB(255,255,255)
    iconLbl.TextSize = 7
    iconLbl.Font = Enum.Font.GothamBold

    local tLbl = Instance.new("TextLabel", card)
    tLbl.Size = UDim2.new(1, -30, 0, 10)
    tLbl.Position = UDim2.new(0, 24, 0, 1)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = titleText
    tLbl.TextColor3 = Color3.fromRGB(255,150,100)
    tLbl.TextSize = 7
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextXAlignment = Enum.TextXAlignment.Left

    local mLbl = Instance.new("TextLabel", card)
    mLbl.Size = UDim2.new(1, -30, 0, 12)
    mLbl.Position = UDim2.new(0, 24, 0, 12)
    mLbl.BackgroundTransparency = 1
    mLbl.Text = mainText
    mLbl.TextColor3 = Color3.fromRGB(220,220,230)
    mLbl.TextSize = 7
    mLbl.Font = Enum.Font.Gotham
    mLbl.TextXAlignment = Enum.TextXAlignment.Left
end

CreateLoadCard(LoadInfoHolder, 1, Color3.fromRGB(70,20,45), "ĐƯỢC TẠO BỞI", "VzNam ROBLOX", Color3.fromRGB(180,50,50), "👤")
CreateLoadCard(LoadInfoHolder, 2, Color3.fromRGB(30,40,70), "DISCORD SERVER", "https://discord.gg/6TG7krbsU", Color3.fromRGB(60,100,200), "💬")
CreateLoadCard(LoadInfoHolder, 3, Color3.fromRGB(45,45,65), "TIKTOK CHANNEL", "https://www.tiktok.com/@uttop1gl.ovo", Color3.fromRGB(100,100,120), "🎵")

local BarBg = Instance.new("Frame", LoadFrame)
BarBg.Size = UDim2.new(1, -20, 0, 10)
BarBg.Position = UDim2.new(0, 10, 1, -40)
BarBg.BackgroundColor3 = Color3.fromRGB(25,26,35)
Corner(BarBg, UDim.new(1, 0))
Stroke(BarBg, Color3.fromRGB(0, 191, 255), 1)

local BarFill = Instance.new("Frame", BarBg)
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(0, 191, 255)
Corner(BarFill, UDim.new(1, 0))

local PercentLbl = Instance.new("TextLabel", LoadFrame)
PercentLbl.Size = UDim2.new(1, 0, 0, 18)
PercentLbl.Position = UDim2.new(0, 0, 1, -24)
PercentLbl.BackgroundTransparency = 1
PercentLbl.Text = "Đang tải: 0/10"
PercentLbl.TextColor3 = Color3.fromRGB(200,205,215)
PercentLbl.TextSize = 8
PercentLbl.Font = Enum.Font.GothamBold
PercentLbl.TextXAlignment = Enum.TextXAlignment.Center

-- ═════════════════ NÚT MỞ HUB (HIỆN SAU KHI LOAD XONG) ═════════════════
local OpenButton = Instance.new("TextButton", ScreenGui)
OpenButton.Size = UDim2.new(0, 40, 0, 40)
OpenButton.Position = UDim2.new(0, 15, 0.25, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(20,22,28)
OpenButton.BackgroundTransparency = 0
OpenButton.Text = "🌸"
OpenButton.TextSize = 20
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Visible = false
Corner(OpenButton, UDim.new(1, 0))
local OpenStroke = Instance.new("UIStroke", OpenButton)
OpenStroke.Thickness = 3
OpenStroke.Color = Color3.fromRGB(0,191,255)
table.insert(AllUIStrokes, OpenStroke)

-- ═════════════════ TIẾN TRÌNH LOAD 1 -> 10 ═════════════════
task.spawn(function()
    for i = 1, 10 do
        task.wait(0.25)
        BarFill.Size = UDim2.new(i / 10, 0, 1, 0)
        PercentLbl.Text = "Đang tải: " .. i .. "/10"
    end
    task.wait(0.3)
    LoadingGui:Destroy()
    MainFrame.Visible = true
    OpenButton.Visible = true
end)

-- ═════════════════ GIAO DIỆN CHÍNH ═════════════════
local ResizeBtn = Instance.new("TextButton", MainFrame)
ResizeBtn.Size, ResizeBtn.Position = UDim2.new(0, 18, 0, 18), UDim2.new(1, -18, 1, -18)
ResizeBtn.BackgroundTransparency, ResizeBtn.Text = 1, "◢"
ResizeBtn.TextColor3, ResizeBtn.TextSize, ResizeBtn.ZIndex = Color3.fromRGB(0, 191, 255), 12, 10

local resizing, resizeStart, startSize = false, nil, nil
Track(ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        resizeStart = input.Position
        startSize = MainFrame.AbsoluteSize
    end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end))
Track(UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local d = input.Position - resizeStart
        MainFrame.Size = UDim2.new(0,
            math.clamp(startSize.X + d.X, 320, 500), 0,
            math.clamp(startSize.Y + d.Y, 230, 450))
    end
end))

local TopBar = Instance.new("Frame", MainFrame)
TopBar.Size, TopBar.BackgroundTransparency = UDim2.new(1, 0, 0, 26), 1

local Logo = Instance.new("Frame", TopBar)
Logo.Size, Logo.Position = UDim2.new(0, 18, 0, 18), UDim2.new(0, 6, 0.5, -9)
Logo.BackgroundColor3, Logo.BorderSizePixel = Color3.fromRGB(0, 191, 255), 0
Corner(Logo, UDim.new(0, 4))
Stroke(Logo, Color3.fromRGB(0, 191, 255))

local LogoIcon = Instance.new("TextLabel", Logo)
LogoIcon.Size, LogoIcon.BackgroundTransparency = UDim2.new(1,0,1,0), 1
LogoIcon.Text, LogoIcon.TextColor3 = "🌸", Color3.fromRGB(255,255,255)
LogoIcon.TextSize, LogoIcon.Font = 10, Enum.Font.GothamBold

local Title = Instance.new("TextLabel", TopBar)
Title.Size, Title.Position = UDim2.new(1, -60, 1, 0), UDim2.new(0, 28, 0, 0)
Title.BackgroundTransparency, Title.Text = 1, "🌸 VzNam Hub-Main 🌸"
Title.TextColor3, Title.TextSize = Color3.fromRGB(0, 191, 255), 10
Title.Font, Title.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center

local CloseBtn = Instance.new("TextButton", TopBar)
CloseBtn.Size, CloseBtn.Position = UDim2.new(0, 24, 0, 24), UDim2.new(1, -26, 0.5, -12)
CloseBtn.BackgroundTransparency, CloseBtn.Text = 1, "✕"
CloseBtn.TextColor3, CloseBtn.TextSize = Color3.fromRGB(200, 200, 210), 10
CloseBtn.Font = Enum.Font.GothamBold

Track(CloseBtn.MouseButton1Click:Connect(function()
    DisconnectAll()
    if SoundService:FindFirstChild("VzNamHubSound") then
        SoundService.VzNamHubSound:Stop()
        SoundService.VzNamHubSound:Destroy()
    end
    ScreenGui:Destroy()
end))

local SidebarPanel = Instance.new("Frame", MainFrame)
SidebarPanel.Size, SidebarPanel.Position = UDim2.new(0.3, -4, 1, -34), UDim2.new(0, 6, 0, 28)
SidebarPanel.BackgroundColor3, SidebarPanel.BorderSizePixel = Color3.fromRGB(15,16,22), 0
Corner(SidebarPanel, UDim.new(0, 6))
Stroke(SidebarPanel, Color3.fromRGB(0,191,255), 1)

local SearchBoxTab = Instance.new("TextBox", SidebarPanel)
SearchBoxTab.Size, SearchBoxTab.Position = UDim2.new(1, -8, 0, 18), UDim2.new(0, 4, 0, 4)
SearchBoxTab.BackgroundColor3 = Color3.fromRGB(12,12,17)
SearchBoxTab.Text, SearchBoxTab.PlaceholderText = "", "🔍 Search..."
SearchBoxTab.PlaceholderColor3, SearchBoxTab.TextColor3 = Color3.fromRGB(150,155,165), Color3.fromRGB(255,255,255)
SearchBoxTab.TextSize, SearchBoxTab.Font = 8, Enum.Font.Gotham
Corner(SearchBoxTab, UDim.new(0, 4))
Stroke(SearchBoxTab)
RegTheme(SearchBoxTab, "Input")

local SidebarScroll = Instance.new("ScrollingFrame", SidebarPanel)
SidebarScroll.Size, SidebarScroll.Position = UDim2.new(1, -4, 1, -26), UDim2.new(0, 2, 0, 25)
SidebarScroll.BackgroundTransparency, SidebarScroll.BorderSizePixel = 1, 0
SidebarScroll.ScrollBarThickness, SidebarScroll.ClipsDescendants = 2, true
local SidebarLayout = Instance.new("UIListLayout", SidebarScroll)
SidebarLayout.SortOrder, SidebarLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 3)
local SidebarPadding = Instance.new("UIPadding", SidebarScroll)
SidebarPadding.PaddingLeft, SidebarPadding.PaddingRight = UDim.new(0, 2), UDim.new(0, 6)

Track(SidebarLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SidebarScroll.CanvasSize = UDim2.new(0, 0, 0, SidebarLayout.AbsoluteContentSize.Y + 10)
end))

Track(SearchBoxTab:GetPropertyChangedSignal("Text"):Connect(function()
    local q = string.lower(SearchBoxTab.Text)
    for _, item in ipairs(SidebarScroll:GetChildren()) do
        if item:IsA("TextButton") then
            item.Visible = (q == "" or string.find(string.lower(item.Text), q, 1, true)) and true or false
        end
    end
end))

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size, ContentContainer.Position = UDim2.new(0.68, -4, 1, -34), UDim2.new(0.315, 0, 0, 28)
ContentContainer.BackgroundColor3, ContentContainer.BorderSizePixel = Color3.fromRGB(15,16,22), 0
Corner(ContentContainer, UDim.new(0, 6))
Stroke(ContentContainer, Color3.fromRGB(0,191,255), 1)

local ContentHeader = Instance.new("Frame", ContentContainer)
ContentHeader.Size, ContentHeader.BackgroundTransparency = UDim2.new(1, 0, 0, 26), 1

local ActiveTabTitle = Instance.new("TextLabel", ContentHeader)
ActiveTabTitle.Size, ActiveTabTitle.Position = UDim2.new(1, -30, 1, 0), UDim2.new(0, 6, 0, 0)
ActiveTabTitle.BackgroundTransparency, ActiveTabTitle.Text = 1, ""
ActiveTabTitle.TextColor3, ActiveTabTitle.TextSize = Color3.fromRGB(255,255,255), 10
ActiveTabTitle.Font, ActiveTabTitle.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

local SearchInputContent = Instance.new("TextBox", ContentHeader)
SearchInputContent.Size, SearchInputContent.Position = UDim2.new(1, -34, 0, 18), UDim2.new(0, 6, 0.5, -9)
SearchInputContent.BackgroundColor3 = Color3.fromRGB(12,12,17)
SearchInputContent.TextColor3, SearchInputContent.PlaceholderText = Color3.fromRGB(255,255,255), "Search features..."
SearchInputContent.PlaceholderColor3, SearchInputContent.TextSize = Color3.fromRGB(150,155,165), 8
SearchInputContent.Font, SearchInputContent.Visible = Enum.Font.Gotham, false
Corner(SearchInputContent, UDim.new(0, 4))
Stroke(SearchInputContent)
RegTheme(SearchInputContent, "Input")

local SearchContentIcon = Instance.new("TextButton", ContentHeader)
SearchContentIcon.Size, SearchContentIcon.Position = UDim2.new(0, 20, 0, 20), UDim2.new(1, -24, 0.5, -10)
SearchContentIcon.BackgroundTransparency, SearchContentIcon.Text = 1, "🔍"
SearchContentIcon.TextSize, SearchContentIcon.TextColor3 = 9, Color3.fromRGB(200,205,215)

local searching = false
Track(SearchContentIcon.MouseButton1Click:Connect(function()
    searching = not searching
    SearchInputContent.Visible = searching
    ActiveTabTitle.Visible = not searching
    if searching then SearchInputContent:CaptureFocus() else SearchInputContent.Text = "" end
end))

local HeaderDivider = Instance.new("Frame", ContentContainer)
HeaderDivider.Size, HeaderDivider.Position = UDim2.new(1, 0, 0, 1), UDim2.new(0, 0, 0, 26)
HeaderDivider.BackgroundColor3, HeaderDivider.BorderSizePixel = Color3.fromRGB(0,191,255), 0

local Tabs = {}

-- ═════════════════ TAB 0: TRANG CHỦ ═════════════════
local tabHomeBtn = Instance.new("TextButton", SidebarScroll)
tabHomeBtn.LayoutOrder = 0
tabHomeBtn.Size, tabHomeBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
tabHomeBtn.BackgroundTransparency, tabHomeBtn.Text = 0, " 🏠 Trang Chủ"
tabHomeBtn.TextColor3, tabHomeBtn.TextSize = Color3.fromRGB(255,255,255), 8
tabHomeBtn.Font, tabHomeBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
Corner(tabHomeBtn)
RegTheme(tabHomeBtn, "Primary")

local homeIndicator = Instance.new("Frame", tabHomeBtn)
homeIndicator.Size, homeIndicator.Position = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6)
homeIndicator.BackgroundColor3, homeIndicator.BorderSizePixel = Color3.fromRGB(255,105,180), 0
homeIndicator.Visible = false
Corner(homeIndicator, UDim.new(0, 2))

local homeScroll = Instance.new("ScrollingFrame", ContentContainer)
homeScroll.Size, homeScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
homeScroll.BackgroundTransparency, homeScroll.BorderSizePixel = 1, 0
homeScroll.ScrollBarThickness, homeScroll.Visible, homeScroll.ClipsDescendants = 3, false, true
local homeLayout = Instance.new("UIListLayout", homeScroll)
homeLayout.SortOrder, homeLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
homeLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local homePad = Instance.new("UIPadding", homeScroll)
homePad.PaddingLeft, homePad.PaddingRight = UDim.new(0, 4), UDim.new(0, 10)
homePad.PaddingTop, homePad.PaddingBottom = UDim.new(0, 4), UDim.new(0, 4)

Track(homeLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    homeScroll.CanvasSize = UDim2.new(0, 0, 0, homeLayout.AbsoluteContentSize.Y + 15)
end))

Track(tabHomeBtn.MouseButton1Click:Connect(function()
    for _, t in pairs(Tabs) do
        t.Container.Visible = false
        if t.Indicator then t.Indicator.Visible = false end
    end
    homeScroll.Visible, homeIndicator.Visible = true, true
    ActiveTabTitle.Text = "🏠 Trang Chủ"
    SearchInputContent.Text = ""
end))

table.insert(Tabs, {Container = homeScroll, Indicator = homeIndicator})
homeScroll.Visible, homeIndicator.Visible = true, true
ActiveTabTitle.Text = "🏠 Trang Chủ"

local infoToggleBtn = Instance.new("TextButton", homeScroll)
infoToggleBtn.LayoutOrder = 1
infoToggleBtn.Size, infoToggleBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 32), Color3.fromRGB(55,12,40)
infoToggleBtn.BackgroundTransparency, infoToggleBtn.Text = 0, " → thông tin"
infoToggleBtn.TextColor3, infoToggleBtn.TextSize = Color3.fromRGB(255,255,255), 10
infoToggleBtn.Font, infoToggleBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
Corner(infoToggleBtn)
Stroke(infoToggleBtn)
RegTheme(infoToggleBtn, "Secondary")

local infoSubLabel = Instance.new("TextLabel", infoToggleBtn)
infoSubLabel.Size, infoSubLabel.Position = UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -14)
infoSubLabel.BackgroundTransparency, infoSubLabel.Text = 1, "Xem các thông tin Hub"
infoSubLabel.TextColor3, infoSubLabel.TextSize = Color3.fromRGB(140,140,150), 7
infoSubLabel.Font, infoSubLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Center

local infoContainer = Instance.new("Frame", homeScroll)
infoContainer.LayoutOrder = 2
infoContainer.Size, infoContainer.AutomaticSize = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
infoContainer.BackgroundTransparency = 1
infoContainer.Visible = false
local infoLayout = Instance.new("UIListLayout", infoContainer)
infoLayout.SortOrder, infoLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
infoLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Track(infoToggleBtn.MouseButton1Click:Connect(function()
    infoContainer.Visible = not infoContainer.Visible
    infoToggleBtn.Text = infoContainer.Visible and " ↓ thông tin" or " → thông tin"
    infoSubLabel.Visible = infoContainer.Visible
end))

local function CreateHomeCard(parent, order, bgColor, titleText, mainText, copyText, borderColor, iconSymbol)
    local card = Instance.new("Frame", parent)
    card.LayoutOrder, card.Size = order, UDim2.new(1, 0, 0, 26)
    card.BackgroundColor3, card.BorderSizePixel = bgColor, 0
    Corner(card)
    Stroke(card, borderColor, 1)

    local iconCircle = Instance.new("Frame", card)
    iconCircle.Size, iconCircle.Position = UDim2.new(0, 16, 0, 16), UDim2.new(0, 4, 0.5, -8)
    iconCircle.BackgroundColor3, iconCircle.BorderSizePixel = borderColor, 0
    Corner(iconCircle, UDim.new(1, 0))
    Stroke(iconCircle, borderColor)

    local iconLbl = Instance.new("TextLabel", iconCircle)
    iconLbl.Size, iconLbl.BackgroundTransparency = UDim2.new(1,0,1,0), 1
    iconLbl.Text, iconLbl.TextColor3 = iconSymbol, Color3.fromRGB(255,255,255)
    iconLbl.TextSize, iconLbl.Font = 7, Enum.Font.GothamBold

    local tLbl = Instance.new("TextLabel", card)
    tLbl.Size, tLbl.Position = UDim2.new(1, -70, 0, 10), UDim2.new(0, 24, 0, 1)
    tLbl.BackgroundTransparency, tLbl.Text = 1, titleText
    tLbl.TextColor3, tLbl.TextSize = Color3.fromRGB(255,150,100), 7
    tLbl.Font, tLbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

    local mLbl = Instance.new("TextLabel", card)
    mLbl.Size, mLbl.Position = UDim2.new(1, -70, 0, 12), UDim2.new(0, 24, 0, 12)
    mLbl.BackgroundTransparency, mLbl.Text = 1, mainText
    mLbl.TextColor3, mLbl.TextSize = Color3.fromRGB(220,220,230), 7
    mLbl.Font, mLbl.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

    if copyText ~= "" then
        local copyBtn = Instance.new("TextButton", card)
        copyBtn.Size, copyBtn.Position = UDim2.new(0, 42, 0, 16), UDim2.new(1, -44, 0.5, -8)
        copyBtn.BackgroundTransparency, copyBtn.Text = 1, "📋 COPY"
        copyBtn.TextColor3, copyBtn.TextSize = Color3.fromRGB(200,200,210), 7
        copyBtn.Font = Enum.Font.GothamBold

        local function doCopy()
            if typeof(setclipboard) == "function" then
                pcall(setclipboard, copyText)
                copyBtn.Text = "✓ COPIED"
                task.delay(1.5, function()
                    if copyBtn.Parent then copyBtn.Text = "📋 COPY" end
                end)
            end
        end
        Track(copyBtn.MouseButton1Click:Connect(doCopy))
        Track(card.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1
               or input.UserInputType == Enum.UserInputType.Touch then doCopy() end
        end))
    end
end

CreateHomeCard(infoContainer, 1, Color3.fromRGB(70,20,45), "ĐƯỢC TẠO BỞI", "VzNam ROBLOX", "", Color3.fromRGB(180,50,50), "👤")
CreateHomeCard(infoContainer, 2, Color3.fromRGB(30,40,70), "DISCORD SERVER",
    "https://discord.gg/6TG7krbsU",
    "https://discord.gg/6TG7krbsU",
    Color3.fromRGB(60,100,200), "💬")
CreateHomeCard(infoContainer, 3, Color3.fromRGB(45,45,65), "TIKTOK CHANNEL",
    "https://www.tiktok.com/@uttop1gl.ovo",
    "https://www.tiktok.com/@uttop1gl.ovo?_r=1&_t=ZS-9AWatTQR08y",
    Color3.fromRGB(100,100,120), "🎵")

-- ═════════════════ TAB 1: FARM (ĐÃ THÊM CÁC TÍNH NĂNG TRỘM TRỨNG) ═════════════════
local tabFarmBtn = Instance.new("TextButton", SidebarScroll)
tabFarmBtn.LayoutOrder = 1
tabFarmBtn.Size, tabFarmBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
tabFarmBtn.BackgroundTransparency, tabFarmBtn.Text = 0, " 🌾 Farm"
tabFarmBtn.TextColor3, tabFarmBtn.TextSize = Color3.fromRGB(255,255,255), 8
tabFarmBtn.Font, tabFarmBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
Corner(tabFarmBtn)
RegTheme(tabFarmBtn, "Primary")

local farmIndicator = Instance.new("Frame", tabFarmBtn)
farmIndicator.Size, farmIndicator.Position = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6)
farmIndicator.BackgroundColor3, farmIndicator.BorderSizePixel = Color3.fromRGB(255,105,180), 0
farmIndicator.Visible = false
Corner(farmIndicator, UDim.new(0, 2))

local farmScroll = Instance.new("ScrollingFrame", ContentContainer)
farmScroll.Size, farmScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
farmScroll.BackgroundTransparency, farmScroll.BorderSizePixel = 1, 0
farmScroll.ScrollBarThickness, farmScroll.Visible, farmScroll.ClipsDescendants = 3, false, true
local farmLayout = Instance.new("UIListLayout", farmScroll)
farmLayout.SortOrder, farmLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
farmLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local farmPad = Instance.new("UIPadding", farmScroll)
farmPad.PaddingLeft, farmPad.PaddingRight, farmPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)

Track(farmLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    farmScroll.CanvasSize = UDim2.new(0, 0, 0, farmLayout.AbsoluteContentSize.Y + 15)
end))

Track(tabFarmBtn.MouseButton1Click:Connect(function()
    for _, t in pairs(Tabs) do
        t.Container.Visible = false
        if t.Indicator then t.Indicator.Visible = false end
    end
    farmScroll.Visible, farmIndicator.Visible = true, true
    ActiveTabTitle.Text = "🌾 Farm"
end))
table.insert(Tabs, {Container = farmScroll, Indicator = farmIndicator})

-- Nút Thu Gọn/Mở Rộng "Tự Động Trộm Trứng"
local farmToggleBtn = Instance.new("TextButton", farmScroll)
farmToggleBtn.LayoutOrder = 1
farmToggleBtn.Size, farmToggleBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 32), Color3.fromRGB(55,12,40)
farmToggleBtn.BackgroundTransparency, farmToggleBtn.Text = 0, " → Tự Động Trộm Trứng"
farmToggleBtn.TextColor3, farmToggleBtn.TextSize = Color3.fromRGB(255,255,255), 10
farmToggleBtn.Font, farmToggleBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
Corner(farmToggleBtn)
Stroke(farmToggleBtn)
RegTheme(farmToggleBtn, "Secondary")

local farmSubLabel = Instance.new("TextLabel", farmToggleBtn)
farmSubLabel.Size, farmSubLabel.Position = UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -14)
farmSubLabel.BackgroundTransparency, farmSubLabel.Text = 1, "Cài đặt tính năng cướp trứng tự động"
farmSubLabel.TextColor3, farmSubLabel.TextSize = Color3.fromRGB(140,140,150), 7
farmSubLabel.Font, farmSubLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Center

local eggStealContainer = Instance.new("Frame", farmScroll)
eggStealContainer.LayoutOrder = 2
eggStealContainer.Size, eggStealContainer.AutomaticSize = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
eggStealContainer.BackgroundTransparency = 1
eggStealContainer.Visible = false
local eggLayout = Instance.new("UIListLayout", eggStealContainer)
eggLayout.SortOrder, eggLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
eggLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Track(farmToggleBtn.MouseButton1Click:Connect(function()
    eggStealContainer.Visible = not eggStealContainer.Visible
    farmToggleBtn.Text = eggStealContainer.Visible and " ↓ Tự Động Trộm Trứng" or " → Tự Động Trộm Trứng"
    farmSubLabel.Visible = eggStealContainer.Visible
end))

-- Hàm tạo Toggle UI trong tab Farm
local function CreateFarmToggle(parent, order, titleText, stateKey, callback)
    local toggleFrame = Instance.new("Frame", parent)
    toggleFrame.LayoutOrder, toggleFrame.Size = order, UDim2.new(1, 0, 0, 30)
    toggleFrame.BackgroundColor3, toggleFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
    Corner(toggleFrame)
    Stroke(toggleFrame)
    RegTheme(toggleFrame, "Primary")

    local tLabel = Instance.new("TextLabel", toggleFrame)
    tLabel.Size, tLabel.Position = UDim2.new(1, -40, 1, 0), UDim2.new(0, 5, 0, 0)
    tLabel.BackgroundTransparency, tLabel.Text = 1, titleText
    tLabel.TextColor3, tLabel.TextSize = Color3.fromRGB(255,255,255), 9
    tLabel.Font, tLabel.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size, toggleBtn.Position = UDim2.new(0, 30, 0, 15), UDim2.new(1, -34, 0.5, -7.5)
    toggleBtn.BackgroundColor3, toggleBtn.Text = State[stateKey] and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 65, 75), ""
    Corner(toggleBtn, UDim.new(1, 0))
    Stroke(toggleBtn)

    local dot = Instance.new("Frame", toggleBtn)
    dot.Size, dot.Position = UDim2.new(0, 11, 0, 11), State[stateKey] and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
    dot.BackgroundColor3 = Color3.fromRGB(255,255,255)
    Corner(dot, UDim.new(1, 0))

    Track(toggleBtn.MouseButton1Click:Connect(function()
        State[stateKey] = not State[stateKey]
        local active = State[stateKey]
        toggleBtn.BackgroundColor3 = active and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(60, 65, 75)
        dot.Position = active and UDim2.new(1, -13, 0.5, -5.5) or UDim2.new(0, 2, 0.5, -5.5)
        if callback then callback(active) end
    end))
end

-- Hàm tạo Slider UI trong tab Farm
local function CreateFarmSlider(parent, order, titleText, minVal, maxVal, defaultVal, stateKey, unitStr, callback)
    local sFrame = Instance.new("Frame", parent)
    sFrame.LayoutOrder, sFrame.Size = order, UDim2.new(1, 0, 0, 34)
    sFrame.BackgroundColor3, sFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
    Corner(sFrame)
    Stroke(sFrame)
    RegTheme(sFrame, "Primary")

    local titleLbl = Instance.new("TextLabel", sFrame)
    titleLbl.Size, titleLbl.Position = UDim2.new(1, -8, 0, 15), UDim2.new(0, 5, 0, 2)
    titleLbl.BackgroundTransparency, titleLbl.Text = 1, titleText
    titleLbl.TextColor3, titleLbl.TextSize = Color3.fromRGB(255,255,255), 9
    titleLbl.Font, titleLbl.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

    local valLbl = Instance.new("TextLabel", sFrame)
    valLbl.Size, valLbl.Position = UDim2.new(0, 60, 0, 15), UDim2.new(1, -65, 0, 2)
    valLbl.BackgroundTransparency, valLbl.Text = 1, tostring(defaultVal) .. (unitStr or "")
    valLbl.TextColor3, valLbl.TextSize = Color3.fromRGB(0,191,255), 9
    valLbl.Font, valLbl.TextXAlignment = Enum.Font.TextXAlignment.Right

    local barBg = Instance.new("Frame", sFrame)
    barBg.Size, barBg.Position = UDim2.new(1, -16, 0, 8), UDim2.new(0, 8, 0, 21)
    barBg.BackgroundColor3 = Color3.fromRGB(90,25,65)
    Corner(barBg, UDim.new(1, 0))
    Stroke(barBg)

    local initPercent = math.clamp((defaultVal - minVal) / (maxVal - minVal), 0, 1)
    local barFill = Instance.new("Frame", barBg)
    barFill.Size, barFill.BackgroundColor3 = UDim2.new(initPercent, 0, 1, 0), Color3.fromRGB(0,180,255)
    Corner(barFill, UDim.new(1, 0))

    local barBtn = Instance.new("TextButton", barBg)
    barBtn.Size, barBtn.BackgroundTransparency, barBtn.Text = UDim2.new(1, 10, 1, 10), 1, ""

    local adjusting = false
    Track(barBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            adjusting = true
        end
    end))
    Track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            adjusting = false
        end
    end))
    Track(UserInputService.InputChanged:Connect(function(input)
        if adjusting and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local absPos, absSize = barBg.AbsolutePosition.X, barBg.AbsoluteSize.X
            local p = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
            barFill.Size = UDim2.new(p, 0, 1, 0)
            local currentVal = math.floor(minVal + (p * (maxVal - minVal)))
            State[stateKey] = currentVal
            valLbl.Text = tostring(currentVal) .. (unitStr or "")
            if callback then callback(currentVal) end
        end
    end))
end

-- Hàm tạo Dropdown UI trong tab Farm
local function CreateFarmDropdown(parent, order, titleText, options, defaultOption, stateKey, callback)
    local dropHolder = Instance.new("Frame", parent)
    dropHolder.LayoutOrder, dropHolder.Size = order, UDim2.new(1, 0, 0, 26)
    dropHolder.BackgroundColor3, dropHolder.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
    Corner(dropHolder)
    Stroke(dropHolder)
    RegTheme(dropHolder, "Primary")

    local dropBtn = Instance.new("TextButton", dropHolder)
    dropBtn.Size, dropBtn.BackgroundTransparency = UDim2.new(1, 0, 1, 0), 1
    dropBtn.Text = " " .. titleText .. ": " .. defaultOption .. " ∨"
    dropBtn.TextColor3, dropBtn.TextSize = Color3.fromRGB(255,255,255), 9
    dropBtn.Font, dropBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

    local dropListFrame = Instance.new("ScrollingFrame", parent)
    dropListFrame.LayoutOrder = order + 1
    dropListFrame.Size = UDim2.new(1, 0, 0, math.min(#options * 24, 100))
    dropListFrame.BackgroundColor3, dropListFrame.BackgroundTransparency = Color3.fromRGB(80,20,60), 0
    dropListFrame.CanvasSize, dropListFrame.ScrollBarThickness, dropListFrame.Visible = UDim2.new(0,0,0,#options * 25), 3, false
    Corner(dropListFrame)
    Stroke(dropListFrame)
    local dListLayout = Instance.new("UIListLayout", dropListFrame)
    dListLayout.Padding = UDim.new(0, 3)
    RegTheme(dropListFrame, "DropFrame")

    for i, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton", dropListFrame)
        optBtn.LayoutOrder, optBtn.Size = i, UDim2.new(1, 0, 0, 22)
        optBtn.BackgroundColor3, optBtn.BackgroundTransparency = Color3.fromRGB(90,25,65), 0
        optBtn.Text, optBtn.TextColor3, optBtn.TextSize = " " .. opt, Color3.fromRGB(255,255,255), 9
        optBtn.Font, optBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(optBtn, UDim.new(0, 4))
        Stroke(optBtn)
        RegTheme(optBtn, "DropItem")
        Track(optBtn.MouseButton1Click:Connect(function()
            State[stateKey] = opt
            dropBtn.Text = " " .. titleText .. ": " .. opt .. " ∨"
            dropListFrame.Visible = false
            if callback then callback(opt) end
        end))
    end

    Track(dropBtn.MouseButton1Click:Connect(function()
        dropListFrame.Visible = not dropListFrame.Visible
    end))
end

-- 📌 Thêm tất cả các tính năng trộm trứng theo yêu cầu vào eggStealContainer
CreateFarmToggle(eggStealContainer, 1, "Tự Động Cướp Trứng", "AutoStealEggs", function(val)
    print("[VzNam Hub] AutoStealEggs:", val)
end)

CreateFarmToggle(eggStealContainer, 2, "Cướp Siêu Tốc", "SuperSteal", function(val)
    print("[VzNam Hub] SuperSteal:", val)
end)

CreateFarmSlider(eggStealContainer, 3, "Số Bước Cướp Siêu Tốc", 1, 10, 2, "SuperStealSteps", "", function(val)
    print("[VzNam Hub] SuperStealSteps:", val)
end)

CreateFarmToggle(eggStealContainer, 4, "Fast Delivery", "FastDelivery", function(val)
    print("[VzNam Hub] FastDelivery:", val)
end)

CreateFarmToggle(eggStealContainer, 5, "Cướp Siêu Tốc V2", "SuperStealV2", function(val)
    print("[VzNam Hub] SuperStealV2:", val)
end)

CreateFarmDropdown(eggStealContainer, 6, "Khu Vực Mục Tiêu", {"Tất cả", "Khu 1", "Khu 2", "Khu 3", "12 đã chọn"}, "12 đã chọn", "TargetArea", function(val)
    print("[VzNam Hub] TargetArea:", val)
end)

CreateFarmDropdown(eggStealContainer, 7, "Min Rarity", {"Tất cả", "Common", "Rare", "Epic", "Legendary", "Mythic"}, "Tất cả", "MinRarity", function(val)
    print("[VzNam Hub] MinRarity:", val)
end)

CreateFarmToggle(eggStealContainer, 8, "Giá Trị Cướp Min", "MinEggValue", function(val)
    print("[VzNam Hub] MinEggValue:", val)
end)

CreateFarmDropdown(eggStealContainer, 9, "Mục Tiêu Trứng Chỉ Định", {"Tất cả", "Trứng Vàng", "Trứng Kim Cương", "Trứng Rồng"}, "Tất cả", "TargetEgg", function(val)
    print("[VzNam Hub] TargetEgg:", val)
end)

CreateFarmToggle(eggStealContainer, 10, "Cướp Trứng Lab Còn Thiếu", "StealMissingLabEggs", function(val)
    print("[VzNam Hub] StealMissingLabEggs:", val)
end)

CreateFarmToggle(eggStealContainer, 11, "Cướp Trứng Sách Còn Thiếu", "StealMissingBookEggs", function(val)
    print("[VzNam Hub] StealMissingBookEggs:", val)
end)

CreateFarmDropdown(eggStealContainer, 12, "Ưu Tiên Cướp", {"Giá trị cao nhất", "Độ hiếm cao nhất", "Gần nhất", "Ngẫu nhiên"}, "Giá trị cao nhất", "StealPriority", function(val)
    print("[VzNam Hub] StealPriority:", val)
end)

CreateFarmSlider(eggStealContainer, 13, "Tốc Độ Bay (Tween)", 50, 300, 120, "TweenFlySpeed", "%", function(val)
    print("[VzNam Hub] TweenFlySpeed:", val)
end)

CreateFarmSlider(eggStealContainer, 14, "Tốc Độ Bê Trứng", 50, 200, 100, "EggCarrySpeed", "%", function(val)
    print("[VzNam Hub] EggCarrySpeed:", val)
end)

CreateFarmToggle(eggStealContainer, 15, "Drop Eggs At Safe Zone", "DropEggsSafeZone", function(val)
    print("[VzNam Hub] DropEggsSafeZone:", val)
end)

CreateFarmToggle(eggStealContainer, 16, "Bảng Chống Vệ Sĩ", "AntiGuardPanel", function(val)
    print("[VzNam Hub] AntiGuardPanel:", val)
end)


-- ═════════════════ TAB: MISC ═════════════════
local tabMiscBtn = Instance.new("TextButton", SidebarScroll)
tabMiscBtn.LayoutOrder = 2
tabMiscBtn.Size, tabMiscBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
tabMiscBtn.BackgroundTransparency, tabMiscBtn.Text = 0, " ⚙️ MISC"
tabMiscBtn.TextColor3, tabMiscBtn.TextSize = Color3.fromRGB(255,255,255), 8
tabMiscBtn.Font, tabMiscBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
Corner(tabMiscBtn)
RegTheme(tabMiscBtn, "Primary")

local miscIndicator = Instance.new("Frame", tabMiscBtn)
miscIndicator.Size, miscIndicator.Position = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6)
miscIndicator.BackgroundColor3, miscIndicator.BorderSizePixel = Color3.fromRGB(255,105,180), 0
miscIndicator.Visible = false
Corner(miscIndicator, UDim.new(0, 2))

local miscScroll = Instance.new("ScrollingFrame", ContentContainer)
miscScroll.Size, miscScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
miscScroll.BackgroundTransparency, miscScroll.BorderSizePixel = 1, 0
miscScroll.ScrollBarThickness, miscScroll.Visible, miscScroll.ClipsDescendants = 3, false, true
local miscLayout = Instance.new("UIListLayout", miscScroll)
miscLayout.SortOrder, miscLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
miscLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local miscPad = Instance.new("UIPadding", miscScroll)
miscPad.PaddingLeft, miscPad.PaddingRight, miscPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)

Track(miscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    miscScroll.CanvasSize = UDim2.new(0, 0, 0, miscLayout.AbsoluteContentSize.Y + 15)
end))

Track(tabMiscBtn.MouseButton1Click:Connect(function()
    for _, t in pairs(Tabs) do
        t.Container.Visible = false
        if t.Indicator then t.Indicator.Visible = false end
    end
    miscScroll.Visible, miscIndicator.Visible = true, true
    ActiveTabTitle.Text = "⚙️ MISC"
end))
table.insert(Tabs, {Container = miscScroll, Indicator = miscIndicator})

-- ═════════════════ ÂM NHẠC ═════════════════
local musicToggleBtn = Instance.new("TextButton", miscScroll)
musicToggleBtn.LayoutOrder = 1
musicToggleBtn.Size, musicToggleBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
musicToggleBtn.BackgroundTransparency, musicToggleBtn.Text = 0, " ↓ âm nhạc"
musicToggleBtn.TextColor3, musicToggleBtn.TextSize = Color3.fromRGB(255,255,255), 10
musicToggleBtn.Font, musicToggleBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
Corner(musicToggleBtn)
Stroke(musicToggleBtn)
RegTheme(musicToggleBtn, "Secondary")

local muSubLabel = Instance.new("TextLabel", musicToggleBtn)
muSubLabel.Size, muSubLabel.Position = UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -14)
muSubLabel.BackgroundTransparency, muSubLabel.Text = 1, "Cài đặt âm nhạc nền"
muSubLabel.TextColor3, muSubLabel.TextSize = Color3.fromRGB(140,140,150), 7
muSubLabel.Font, muSubLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Center

local musicContainer = Instance.new("Frame", miscScroll)
musicContainer.LayoutOrder, musicContainer.Size = 2, UDim2.new(1, 0, 0, 0)
musicContainer.AutomaticSize, musicContainer.BackgroundTransparency = Enum.AutomaticSize.Y, 1
musicContainer.Visible = true
local muLayout = Instance.new("UIListLayout", musicContainer)
muLayout.SortOrder, muLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
muLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Track(musicToggleBtn.MouseButton1Click:Connect(function()
    musicContainer.Visible = not musicContainer.Visible
    musicToggleBtn.Text = musicContainer.Visible and " ↓ âm nhạc" or " → âm nhạc"
    muSubLabel.Visible = musicContainer.Visible
end))

local HubSound = Instance.new("Sound", SoundService)
HubSound.Name, HubSound.Looped, HubSound.Volume = "VzNamHubSound", true, State.Volume
HubSound.SoundId = "rbxassetid://" .. State.SoundId

local customIdBox = Instance.new("TextBox", musicContainer)
customIdBox.LayoutOrder, customIdBox.Size = 1, UDim2.new(1, 0, 0, 26)
customIdBox.BackgroundColor3, customIdBox.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
customIdBox.PlaceholderText, customIdBox.Text = "🎶 Nhập Sound ID...", ""
customIdBox.TextColor3, customIdBox.TextSize = Color3.fromRGB(255,255,255), 9
customIdBox.Font = Enum.Font.Gotham
Corner(customIdBox)
Stroke(customIdBox)
RegTheme(customIdBox, "Input")

local musicDropBtn = Instance.new("TextButton", musicContainer)
musicDropBtn.LayoutOrder, musicDropBtn.Size = 2, UDim2.new(1, 0, 0, 26)
musicDropBtn.BackgroundColor3, musicDropBtn.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
musicDropBtn.Text, musicDropBtn.TextColor3 = " 🎵 Chọn Nhạc...", Color3.fromRGB(255,255,255)
musicDropBtn.TextSize, musicDropBtn.Font = 9, Enum.Font.Gotham
musicDropBtn.TextXAlignment = Enum.TextXAlignment.Left
Corner(musicDropBtn)
Stroke(musicDropBtn)
RegTheme(musicDropBtn, "Primary")

local musicDropFrame = Instance.new("ScrollingFrame", musicContainer)
musicDropFrame.LayoutOrder, musicDropFrame.Size = 3, UDim2.new(1, 0, 0, 95)
musicDropFrame.BackgroundColor3, musicDropFrame.BackgroundTransparency = Color3.fromRGB(80,20,60), 0
musicDropFrame.CanvasSize, musicDropFrame.ScrollBarThickness, musicDropFrame.Visible = UDim2.new(0,0,0,0), 3, false
Corner(musicDropFrame)
Stroke(musicDropFrame)
local musicListLayout = Instance.new("UIListLayout", musicDropFrame)
musicListLayout.Padding = UDim.new(0, 3)
RegTheme(musicDropFrame, "DropFrame")
local musicPad = Instance.new("UIPadding", musicDropFrame)
musicPad.PaddingRight = UDim.new(0, 8)

local presetMusics = {
    {Name = "🎵 Chill Lofi",        Id = "1837879082"},
    {Name = "🎶 Phonk Beat",        Id = "1843404008"},
    {Name = "🎵 Anime Relax",       Id = "9043887091"},
    {Name = "🎶 EDM Hype",          Id = "1837871000"},
    {Name = "🎶 Như Một Người Dưng",Id = "91897652967267"},
}
for i, m in ipairs(presetMusics) do
    local mBtn = Instance.new("TextButton", musicDropFrame)
    mBtn.LayoutOrder, mBtn.Size = i, UDim2.new(1, 0, 0, 22)
    mBtn.BackgroundColor3, mBtn.BackgroundTransparency = Color3.fromRGB(90,25,65), 0
    mBtn.Text, mBtn.TextColor3, mBtn.TextSize = " " .. m.Name, Color3.fromRGB(255,255,255), 9
    mBtn.Font, mBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
    Corner(mBtn, UDim.new(0, 4))
    Stroke(mBtn)
    RegTheme(mBtn, "DropItem")
    Track(mBtn.MouseButton1Click:Connect(function()
        State.SoundId = m.Id
        musicDropBtn.Text = " 🎵 " .. m.Name
        musicDropFrame.Visible = false
        if HubSound.IsPlaying then
            HubSound.SoundId = "rbxassetid://" .. State.SoundId
            HubSound:Play()
        end
    end))
end
musicDropFrame.CanvasSize = UDim2.new(0, 0, 0, #presetMusics * 25)
Track(musicDropBtn.MouseButton1Click:Connect(function()
    musicDropFrame.Visible = not musicDropFrame.Visible
end))

local volumeFrame = Instance.new("Frame", musicContainer)
volumeFrame.LayoutOrder, volumeFrame.Size = 4, UDim2.new(1, 0, 0, 26)
volumeFrame.BackgroundColor3, volumeFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(volumeFrame)
Stroke(volumeFrame)
RegTheme(volumeFrame, "Primary")

local volumeLabel = Instance.new("TextLabel", volumeFrame)
volumeLabel.Size, volumeLabel.Position = UDim2.new(1, -8, 1, 0), UDim2.new(0, 5, 0, 0)
volumeLabel.BackgroundTransparency, volumeLabel.Text = 1, "🔊 Vol: 50%"
volumeLabel.TextColor3, volumeLabel.TextSize = Color3.fromRGB(255,255,255), 9
volumeLabel.Font, volumeLabel.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

local volumeBarBg = Instance.new("Frame", volumeFrame)
volumeBarBg.Size, volumeBarBg.Position = UDim2.new(0, 80, 0, 8), UDim2.new(1, -86, 0.5, -4)
volumeBarBg.BackgroundColor3 = Color3.fromRGB(90,25,65)
Corner(volumeBarBg, UDim.new(1, 0))
Stroke(volumeBarBg)
RegTheme(volumeBarBg, "DropItem")

local volumeBarFill = Instance.new("Frame", volumeBarBg)
volumeBarFill.Size, volumeBarFill.BackgroundColor3 = UDim2.new(0.5, 0, 1, 0), Color3.fromRGB(0,180,255)
Corner(volumeBarFill, UDim.new(1, 0))

local volumeBtn = Instance.new("TextButton", volumeBarBg)
volumeBtn.Size, volumeBtn.BackgroundTransparency, volumeBtn.Text = UDim2.new(1, 10, 1, 10), 1, ""

local adjustingVol = false
Track(volumeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then adjustingVol = true end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        adjustingVol = false
    end
end))
Track(UserInputService.InputChanged:Connect(function(input)
    if adjustingVol and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local absPos, absSize = volumeBarBg.AbsolutePosition.X, volumeBarBg.AbsoluteSize.X
        local p = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
        volumeBarFill.Size = UDim2.new(p, 0, 1, 0)
        State.Volume = p
        HubSound.Volume = p
        volumeLabel.Text = "🔊 Vol: " .. math.floor(p * 100) .. "%"
    end
end))

local musicToggleFrame = Instance.new("Frame", musicContainer)
musicToggleFrame.LayoutOrder, musicToggleFrame.Size = 5, UDim2.new(1, 0, 0, 30)
musicToggleFrame.BackgroundColor3, musicToggleFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(musicToggleFrame)
Stroke(musicToggleFrame)
RegTheme(musicToggleFrame, "Primary")

local musicTitle = Instance.new("TextLabel", musicToggleFrame)
musicTitle.Size, musicTitle.Position = UDim2.new(1, -40, 1, 0), UDim2.new(0, 5, 0, 0)
musicTitle.BackgroundTransparency, musicTitle.Text = 1, "Phát Nhạc Nền"
musicTitle.TextColor3, musicTitle.TextSize = Color3.fromRGB(255,255,255), 9
musicTitle.Font, musicTitle.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

local toggleMusicBtn = Instance.new("TextButton", musicToggleFrame)
toggleMusicBtn.Size, toggleMusicBtn.Position = UDim2.new(0, 30, 0, 15), UDim2.new(1, -34, 0.5, -7.5)
toggleMusicBtn.BackgroundColor3, toggleMusicBtn.Text = Color3.fromRGB(60,65,75), ""
Corner(toggleMusicBtn, UDim.new(1, 0))
Stroke(toggleMusicBtn)
local musicDot = Instance.new("Frame", toggleMusicBtn)
musicDot.Size, musicDot.Position = UDim2.new(0, 11, 0, 11), UDim2.new(0, 2, 0.5, -5.5)
musicDot.BackgroundColor3 = Color3.fromRGB(255,255,255)
Corner(musicDot, UDim.new(1, 0))

local isMusicPlaying = false
Track(toggleMusicBtn.MouseButton1Click:Connect(function()
    isMusicPlaying = not isMusicPlaying
    if isMusicPlaying then
        toggleMusicBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        musicDot.Position = UDim2.new(1, -13, 0.5, -5.5)
        local customId = tonumber(customIdBox.Text)
        HubSound.SoundId = "rbxassetid://" .. (customId and tostring(customId) or State.SoundId)
        HubSound:Play()
    else
        toggleMusicBtn.BackgroundColor3 = Color3.fromRGB(60, 65, 75)
        musicDot.Position = UDim2.new(0, 2, 0.5, -5.5)
        HubSound:Stop()
    end
end))

-- ═════════════════ MÀU MENU ═════════════════
local menuColorToggleBtn = Instance.new("TextButton", miscScroll)
menuColorToggleBtn.LayoutOrder = 3
menuColorToggleBtn.Size, menuColorToggleBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 34), Color3.fromRGB(55,12,40)
menuColorToggleBtn.BackgroundTransparency, menuColorToggleBtn.Text = 0, " ↓ màu menu"
menuColorToggleBtn.TextColor3, menuColorToggleBtn.TextSize = Color3.fromRGB(255,255,255), 10
menuColorToggleBtn.Font, menuColorToggleBtn.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Center
Corner(menuColorToggleBtn)
Stroke(menuColorToggleBtn)
RegTheme(menuColorToggleBtn, "Secondary")

local mcSubLabel = Instance.new("TextLabel", menuColorToggleBtn)
mcSubLabel.Size, mcSubLabel.Position = UDim2.new(1, 0, 0, 14), UDim2.new(0, 0, 1, -14)
mcSubLabel.BackgroundTransparency, mcSubLabel.Text = 1, "Tùy chỉnh màu sắc & độ trong suốt"
mcSubLabel.TextColor3, mcSubLabel.TextSize = Color3.fromRGB(140,140,150), 7
mcSubLabel.Font, mcSubLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Center

local menuColorContainer = Instance.new("Frame", miscScroll)
menuColorContainer.LayoutOrder, menuColorContainer.Size = 4, UDim2.new(1, 0, 0, 0)
menuColorContainer.AutomaticSize, menuColorContainer.BackgroundTransparency = Enum.AutomaticSize.Y, 1
menuColorContainer.Visible = true
local mcLayout = Instance.new("UIListLayout", menuColorContainer)
mcLayout.SortOrder, mcLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
mcLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

Track(menuColorToggleBtn.MouseButton1Click:Connect(function()
    menuColorContainer.Visible = not menuColorContainer.Visible
    menuColorToggleBtn.Text = menuColorContainer.Visible and " ↓ màu menu" or " → màu menu"
    mcSubLabel.Visible = menuColorContainer.Visible
end))

local menuThemeList = {
    {Name = "🌸 Hồng Pastel",      Bg = Color3.fromRGB(70, 15, 50)},
    {Name = "🌙 Đêm Đen Sâu",     Bg = Color3.fromRGB(15, 16, 22)},
    {Name = "🔥 Đỏ Lửa",           Bg = Color3.fromRGB(70, 10, 15)},
    {Name = "🌊 Xanh Đại Dương",   Bg = Color3.fromRGB(10, 22, 50)},
}

local function ApplyTheme(newBaseColor)
    State.ThemeBase = newBaseColor
    local primary   = newBaseColor:Lerp(Color3.new(1,1,1), 0.08)
    local secondary = newBaseColor:Lerp(Color3.new(1,1,1), 0.15)
    local dropFrame = newBaseColor:Lerp(Color3.new(1,1,1), 0.2)
    local dropItem  = newBaseColor:Lerp(Color3.new(1,1,1), 0.3)
    local input     = newBaseColor:Lerp(Color3.new(0,0,0), 0.4)

    SidebarPanel.BackgroundColor3 = newBaseColor
    ContentContainer.BackgroundColor3 = newBaseColor

    for _, item in ipairs(ThemedElements) do
        local el = item.Element
        if el and el.Parent then
            if     item.Type == "Primary"   then el.BackgroundColor3 = primary
            elseif item.Type == "Secondary" then el.BackgroundColor3 = secondary
            elseif item.Type == "DropFrame" then el.BackgroundColor3 = dropFrame
            elseif item.Type == "DropItem"  then el.BackgroundColor3 = dropItem
            elseif item.Type == "Input"     then el.BackgroundColor3 = input
            end
        end
    end
end

local themeDropBtn = Instance.new("TextButton", menuColorContainer)
themeDropBtn.LayoutOrder, themeDropBtn.Size = 1, UDim2.new(1, 0, 0, 26)
themeDropBtn.BackgroundColor3, themeDropBtn.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
themeDropBtn.Text, themeDropBtn.TextColor3 = " 🎨 Theme: 🌊 Xanh Đại Dương", Color3.fromRGB(255,255,255)
themeDropBtn.TextSize, themeDropBtn.Font = 9, Enum.Font.Gotham
themeDropBtn.TextXAlignment = Enum.TextXAlignment.Left
Corner(themeDropBtn)
Stroke(themeDropBtn)
RegTheme(themeDropBtn, "Primary")

local themeDropFrame = Instance.new("ScrollingFrame", menuColorContainer)
themeDropFrame.LayoutOrder, themeDropFrame.Size = 2, UDim2.new(1, 0, 0, 95)
themeDropFrame.BackgroundColor3, themeDropFrame.BackgroundTransparency = Color3.fromRGB(80,20,60), 0
themeDropFrame.CanvasSize, themeDropFrame.ScrollBarThickness, themeDropFrame.Visible = UDim2.new(0,0,0,0), 3, false
Corner(themeDropFrame)
Stroke(themeDropFrame)
local themeListLayout = Instance.new("UIListLayout", themeDropFrame)
themeListLayout.Padding = UDim.new(0, 3)
RegTheme(themeDropFrame, "DropFrame")
local themePad = Instance.new("UIPadding", themeDropFrame)
themePad.PaddingRight = UDim.new(0, 8)

for i, th in ipairs(menuThemeList) do
    local tBtn = Instance.new("TextButton", themeDropFrame)
    tBtn.LayoutOrder, tBtn.Size = i, UDim2.new(1, 0, 0, 22)
    tBtn.BackgroundColor3, tBtn.BackgroundTransparency = Color3.fromRGB(90,25,65), 0
    tBtn.Text, tBtn.TextColor3, tBtn.TextSize = " " .. th.Name, Color3.fromRGB(255,255,255), 9
    tBtn.Font, tBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
    Corner(tBtn, UDim.new(0, 4))
    Stroke(tBtn)
    RegTheme(tBtn, "DropItem")
    Track(tBtn.MouseButton1Click:Connect(function()
        themeDropBtn.Text = " 🎨 Theme: " .. th.Name
        themeDropFrame.Visible = false
        ApplyTheme(th.Bg)
    end))
end
themeDropFrame.CanvasSize = UDim2.new(0, 0, 0, #menuThemeList * 25)
Track(themeDropBtn.MouseButton1Click:Connect(function()
    themeDropFrame.Visible = not themeDropFrame.Visible
end))

local transFrame = Instance.new("Frame", menuColorContainer)
transFrame.LayoutOrder, transFrame.Size = 3, UDim2.new(1, 0, 0, 26)
transFrame.BackgroundColor3, transFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(transFrame)
Stroke(transFrame)
RegTheme(transFrame, "Primary")

local transLabel = Instance.new("TextLabel", transFrame)
transLabel.Size, transLabel.Position = UDim2.new(1, -8, 1, 0), UDim2.new(0, 5, 0, 0)
transLabel.BackgroundTransparency, transLabel.Text = 1, "✨ Trong suốt: 0%"
transLabel.TextColor3, transLabel.TextSize = Color3.fromRGB(255,255,255), 9
transLabel.Font, transLabel.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

local transBarBg = Instance.new("Frame", transFrame)
transBarBg.Size, transBarBg.Position = UDim2.new(0, 80, 0, 8), UDim2.new(1, -86, 0.5, -4)
transBarBg.BackgroundColor3 = Color3.fromRGB(90,25,65)
Corner(transBarBg, UDim.new(1, 0))
Stroke(transBarBg)
RegTheme(transBarBg, "DropItem")

local transBarFill = Instance.new("Frame", transBarBg)
transBarFill.Size, transBarFill.BackgroundColor3 = UDim2.new(0, 0, 1, 0), Color3.fromRGB(255,105,180)
Corner(transBarFill, UDim.new(1, 0))

local transBtn = Instance.new("TextButton", transBarBg)
transBtn.Size, transBtn.BackgroundTransparency, transBtn.Text = UDim2.new(1, 10, 1, 10), 1, ""

local adjustingTrans = false
Track(transBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then adjustingTrans = true end
end))
Track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        adjustingTrans = false
    end
end))
Track(UserInputService.InputChanged:Connect(function(input)
    if adjustingTrans and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local absPos, absSize = transBarBg.AbsolutePosition.X, transBarBg.AbsoluteSize.X
        local p = math.clamp((input.Position.X - absPos) / absSize, 0, 1)
        transBarFill.Size = UDim2.new(p, 0, 1, 0)
        State.Transparent = p
        MainFrame.BackgroundTransparency = 0.15 + (p * 0.85)
        SidebarPanel.BackgroundTransparency = p
        ContentContainer.BackgroundTransparency = p
        transLabel.Text = "✨ Trong suốt: " .. math.floor(p * 100) .. "%"
    end
end))

local colorList = {
    {Name = "🔵 Xanh Dương",        Color = Color3.fromRGB(0, 191, 255)},
    {Name = "🌈 Cầu Vồng (Rainbow)",Color = "Rainbow"},
    {Name = "🌸 Hồng Kẹo",          Color = Color3.fromRGB(255, 105, 180)},
    {Name = "🔴 Đỏ Đậm",            Color = Color3.fromRGB(220, 20, 60)},
    {Name = "❌ Không Viền",        Color = "None"},
}

local colorDropBtn = Instance.new("TextButton", menuColorContainer)
colorDropBtn.LayoutOrder, colorDropBtn.Size = 4, UDim2.new(1, 0, 0, 26)
colorDropBtn.BackgroundColor3, colorDropBtn.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
colorDropBtn.Text, colorDropBtn.TextColor3 = " 🎨 Viền: 🔵 Xanh Dương", Color3.fromRGB(255,255,255)
colorDropBtn.TextSize, colorDropBtn.Font = 9, Enum.Font.Gotham
colorDropBtn.TextXAlignment = Enum.TextXAlignment.Left
Corner(colorDropBtn)
Stroke(colorDropBtn)
RegTheme(colorDropBtn, "Primary")

local colorDropFrame = Instance.new("ScrollingFrame", menuColorContainer)
colorDropFrame.LayoutOrder, colorDropFrame.Size = 5, UDim2.new(1, 0, 0, 95)
colorDropFrame.BackgroundColor3, colorDropFrame.BackgroundTransparency = Color3.fromRGB(80,20,60), 0
colorDropFrame.CanvasSize, colorDropFrame.ScrollBarThickness, colorDropFrame.Visible = UDim2.new(0,0,0,0), 3, false
Corner(colorDropFrame)
Stroke(colorDropFrame)
local colorListLayout = Instance.new("UIListLayout", colorDropFrame)
colorListLayout.Padding = UDim.new(0, 3)
RegTheme(colorDropFrame, "DropFrame")
local colorPad = Instance.new("UIPadding", colorDropFrame)
colorPad.PaddingRight = UDim.new(0, 8)

local function UpdateAllStrokes(target)
    if target == "None" then
        for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 1 end end
    elseif target == "Rainbow" then
        for _, s in ipairs(AllUIStrokes) do if s then s.Transparency = 0 end end
    else
        State.StrokeColor = target
        for _, s in ipairs(AllUIStrokes) do
            if s then s.Transparency = 0; s.Color = target end
        end
    end
end

for i, cItem in ipairs(colorList) do
    local cBtn = Instance.new("TextButton", colorDropFrame)
    cBtn.LayoutOrder, cBtn.Size = i, UDim2.new(1, 0, 0, 22)
    cBtn.BackgroundColor3, cBtn.BackgroundTransparency = Color3.fromRGB(90,25,65), 0
    cBtn.Text, cBtn.TextColor3, cBtn.TextSize = " " .. cItem.Name, Color3.fromRGB(255,255,255), 9
    cBtn.Font, cBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
    Corner(cBtn, UDim.new(0, 4))
    Stroke(cBtn)
    RegTheme(cBtn, "DropItem")
    Track(cBtn.MouseButton1Click:Connect(function()
        colorDropBtn.Text = " 🎨 Viền: " .. cItem.Name
        colorDropFrame.Visible = false
        if cItem.Color == "Rainbow" then
            State.StrokeMode = "Rainbow"
            UpdateAllStrokes("Rainbow")
        elseif cItem.Color == "None" then
            State.StrokeMode = "None"
            UpdateAllStrokes("None")
        else
            State.StrokeMode = "Solid"
            UpdateAllStrokes(cItem.Color)
        end
    end))
end
colorDropFrame.CanvasSize = UDim2.new(0, 0, 0, #colorList * 25)
Track(colorDropBtn.MouseButton1Click:Connect(function()
    colorDropFrame.Visible = not colorDropFrame.Visible
end))

local rainbowConn = RunService.RenderStepped:Connect(function()
    if State.StrokeMode ~= "Rainbow" then return end
    local rainbow = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    for _, s in ipairs(AllUIStrokes) do
        if s then s.Transparency = 0; s.Color = rainbow end
    end
end)
Track(rainbowConn)

-- ═════════════════ TAB: CẤU HÌNH ═════════════════
local tabConfigBtn = Instance.new("TextButton", SidebarScroll)
tabConfigBtn.LayoutOrder = 3
tabConfigBtn.Size, tabConfigBtn.BackgroundColor3 = UDim2.new(1, 0, 0, 26), Color3.fromRGB(70,15,50)
tabConfigBtn.BackgroundTransparency, tabConfigBtn.Text = 0, " 📦 CẤU HÌNH"
tabConfigBtn.TextColor3, tabConfigBtn.TextSize = Color3.fromRGB(255,255,255), 8
tabConfigBtn.Font, tabConfigBtn.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
Corner(tabConfigBtn)
RegTheme(tabConfigBtn, "Primary")

local configIndicator = Instance.new("Frame", tabConfigBtn)
configIndicator.Size, configIndicator.Position = UDim2.new(0, 3, 0, 12), UDim2.new(0, 0, 0.5, -6)
configIndicator.BackgroundColor3, configIndicator.BorderSizePixel = Color3.fromRGB(255,105,180), 0
configIndicator.Visible = false
Corner(configIndicator, UDim.new(0, 2))

local configScroll = Instance.new("ScrollingFrame", ContentContainer)
configScroll.Size, configScroll.Position = UDim2.new(1, -12, 1, -29), UDim2.new(0, 6, 0, 28)
configScroll.BackgroundTransparency, configScroll.BorderSizePixel = 1, 0
configScroll.ScrollBarThickness, configScroll.Visible, configScroll.ClipsDescendants = 3, false, true
local configLayout = Instance.new("UIListLayout", configScroll)
configLayout.SortOrder, configLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 5)
configLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
local cfgPad = Instance.new("UIPadding", configScroll)
cfgPad.PaddingLeft, cfgPad.PaddingRight, cfgPad.PaddingTop = UDim.new(0,4), UDim.new(0,10), UDim.new(0,4)

Track(configLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    configScroll.CanvasSize = UDim2.new(0, 0, 0, configLayout.AbsoluteContentSize.Y + 15)
end))

Track(tabConfigBtn.MouseButton1Click:Connect(function()
    for _, t in pairs(Tabs) do
        t.Container.Visible = false
        if t.Indicator then t.Indicator.Visible = false end
    end
    configScroll.Visible, configIndicator.Visible = true, true
    ActiveTabTitle.Text = "📦 CẤU HÌNH"
end))
table.insert(Tabs, {Container = configScroll, Indicator = configIndicator})

local CONFIG_FOLDER = "VzNamHub_Configs"
if typeof(makefolder) == "function" then pcall(makefolder, CONFIG_FOLDER) end

local function SerializeState()
    return {
        Version        = 4,
        SavedTime      = os.time(),
        ThemeBase      = {State.ThemeBase.R, State.ThemeBase.G, State.ThemeBase.B},
        StrokeMode     = State.StrokeMode,
        StrokeColor    = {State.StrokeColor.R, State.StrokeColor.G, State.StrokeColor.B},
        Volume         = State.Volume,
        SoundId        = State.SoundId,
        Transparent    = State.Transparent,
    }
end

local function ValidateConfig(data)
    if type(data) ~= "table" then return false end
    if data.Version ~= 4 then return false end
    if data.ThemeBase and type(data.ThemeBase) ~= "table" then return false end
    if data.StrokeColor and type(data.StrokeColor) ~= "table" then return false end
    if data.Volume and type(data.Volume) ~= "number" then return false end
    return true
end

local function SaveConfig(name)
    if typeof(writefile) ~= "function" then return false end
    local ok = pcall(writefile,
        CONFIG_FOLDER .. "/" .. name .. ".json",
        HttpService:JSONEncode(SerializeState()))
    return ok
end

local function LoadConfigRaw(name)
    if typeof(readfile) ~= "function" then return false, "no readfile" end
    local path = CONFIG_FOLDER .. "/" .. name .. ".json"
    local ok, contents = pcall(readfile, path)
    if not ok or not contents then return false, "read fail" end
    local ok2, data = pcall(HttpService.JSONDecode, HttpService, contents)
    if not ok2 then return false, "invalid JSON" end
    if not ValidateConfig(data) then return false, "invalid schema" end
    return true, data
end

local mainConfigContainer = Instance.new("Frame", configScroll)
mainConfigContainer.LayoutOrder = 1
mainConfigContainer.Size, mainConfigContainer.AutomaticSize = UDim2.new(1, 0, 0, 0), Enum.AutomaticSize.Y
mainConfigContainer.BackgroundTransparency = 1
mainConfigContainer.Visible = true
local mainCfgLayout = Instance.new("UIListLayout", mainConfigContainer)
mainCfgLayout.SortOrder, mainCfgLayout.Padding = Enum.SortOrder.LayoutOrder, UDim.new(0, 4)
mainCfgLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local startupFrame = Instance.new("Frame", mainConfigContainer)
startupFrame.LayoutOrder, startupFrame.Size = 1, UDim2.new(1, 0, 0, 30)
startupFrame.BackgroundColor3, startupFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(startupFrame)
Stroke(startupFrame)
RegTheme(startupFrame, "Primary")

local startupLabel = Instance.new("TextLabel", startupFrame)
startupLabel.Size, startupLabel.Position = UDim2.new(1, -8, 1, 0), UDim2.new(0, 5, 0, 0)
startupLabel.BackgroundTransparency = 1
startupLabel.Text = "Startup: " .. State.CurrentConfig
startupLabel.TextColor3, startupLabel.TextSize = Color3.fromRGB(255,255,255), 9
startupLabel.Font, startupLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

local newConfigFrame = Instance.new("Frame", mainConfigContainer)
newConfigFrame.LayoutOrder, newConfigFrame.Size = 2, UDim2.new(1, 0, 0, 30)
newConfigFrame.BackgroundColor3, newConfigFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(newConfigFrame)
Stroke(newConfigFrame)
RegTheme(newConfigFrame, "Primary")

local ncLabel = Instance.new("TextLabel", newConfigFrame)
ncLabel.Size, ncLabel.Position = UDim2.new(0, 80, 1, 0), UDim2.new(0, 5, 0, 0)
ncLabel.BackgroundTransparency, ncLabel.Text = 1, "Tên Config"
ncLabel.TextColor3, ncLabel.TextSize = Color3.fromRGB(255,255,255), 9
ncLabel.Font, ncLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

local configNameBox = Instance.new("TextBox", newConfigFrame)
configNameBox.Size, configNameBox.Position = UDim2.new(1, -95, 0, 20), UDim2.new(0, 85, 0.5, -10)
configNameBox.BackgroundColor3, configNameBox.BackgroundTransparency = Color3.fromRGB(50,10,35), 0
configNameBox.PlaceholderText, configNameBox.Text = "Name...", ""
configNameBox.TextColor3, configNameBox.TextSize = Color3.fromRGB(255,255,255), 9
configNameBox.Font = Enum.Font.Gotham
Corner(configNameBox, UDim.new(0, 4))
Stroke(configNameBox)
RegTheme(configNameBox, "Input")

local createFrame = Instance.new("Frame", mainConfigContainer)
createFrame.LayoutOrder, createFrame.Size = 3, UDim2.new(1, 0, 0, 34)
createFrame.BackgroundColor3, createFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(createFrame)
Stroke(createFrame)
RegTheme(createFrame, "Primary")

local crTitle = Instance.new("TextLabel", createFrame)
crTitle.Size, crTitle.Position = UDim2.new(1, -75, 0, 15), UDim2.new(0, 5, 0, 2)
crTitle.BackgroundTransparency, crTitle.Text = 1, "Tạo Mới Cấu Hình"
crTitle.TextColor3, crTitle.TextSize = Color3.fromRGB(255,255,255), 9
crTitle.Font, crTitle.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

local crSub = Instance.new("TextLabel", createFrame)
crSub.Size, crSub.Position = UDim2.new(1, -75, 0, 14), UDim2.new(0, 5, 0, 17)
crSub.BackgroundTransparency, crSub.Text = 1, "Sao chép cài đặt hiện tại"
crSub.TextColor3, crSub.TextSize = Color3.fromRGB(140,140,150), 7
crSub.Font, crSub.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

local createBtn = Instance.new("TextButton", createFrame)
createBtn.Size, createBtn.Position = UDim2.new(0, 65, 0, 22), UDim2.new(1, -70, 0.5, -11)
createBtn.BackgroundColor3, createBtn.Text = Color3.fromRGB(220,50,50), "Create"
createBtn.TextColor3, createBtn.TextSize = Color3.fromRGB(255,255,255), 9
createBtn.Font = Enum.Font.GothamBold
Corner(createBtn, UDim.new(0, 4))
Stroke(createBtn)

local deleteFrame = Instance.new("Frame", mainConfigContainer)
deleteFrame.LayoutOrder, deleteFrame.Size = 4, UDim2.new(1, 0, 0, 30)
deleteFrame.BackgroundColor3, deleteFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(deleteFrame)
Stroke(deleteFrame)
RegTheme(deleteFrame, "Primary")

local delLabel = Instance.new("TextLabel", deleteFrame)
delLabel.Size, delLabel.Position = UDim2.new(0, 80, 1, 0), UDim2.new(0, 5, 0, 0)
delLabel.BackgroundTransparency, delLabel.Text = 1, "Xóa Cấu Hình"
delLabel.TextColor3, delLabel.TextSize = Color3.fromRGB(255,255,255), 9
delLabel.Font, delLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

local delBtn = Instance.new("TextButton", deleteFrame)
delBtn.Size, delBtn.Position = UDim2.new(0, 85, 0, 20), UDim2.new(1, -90, 0.5, -10)
delBtn.BackgroundColor3, delBtn.BackgroundTransparency = Color3.fromRGB(50,10,35), 0
delBtn.Text, delBtn.TextColor3 = "Không có ∨", Color3.fromRGB(50,200,50)
delBtn.TextSize, delBtn.Font = 8, Enum.Font.GothamBold
delBtn.TextXAlignment = Enum.TextXAlignment.Center
Corner(delBtn, UDim.new(0, 4))
Stroke(delBtn)
RegTheme(delBtn, "Input")

local delDropFrame = Instance.new("ScrollingFrame", mainConfigContainer)
delDropFrame.LayoutOrder, delDropFrame.Size = 5, UDim2.new(1, 0, 0, 80)
delDropFrame.BackgroundColor3, delDropFrame.BackgroundTransparency = Color3.fromRGB(80,20,60), 0
delDropFrame.CanvasSize, delDropFrame.ScrollBarThickness, delDropFrame.Visible = UDim2.new(0,0,0,0), 3, false
Corner(delDropFrame)
Stroke(delDropFrame)
local delDropLayout = Instance.new("UIListLayout", delDropFrame)
delDropLayout.Padding = UDim.new(0, 3)
local delPad = Instance.new("UIPadding", delDropFrame)
delPad.PaddingRight = UDim.new(0, 8)
RegTheme(delDropFrame, "DropFrame")

local loadConfigFrame = Instance.new("Frame", mainConfigContainer)
loadConfigFrame.LayoutOrder, loadConfigFrame.Size = 6, UDim2.new(1, 0, 0, 30)
loadConfigFrame.BackgroundColor3, loadConfigFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(loadConfigFrame)
Stroke(loadConfigFrame)
RegTheme(loadConfigFrame, "Primary")

local ldLabel = Instance.new("TextLabel", loadConfigFrame)
ldLabel.Size, ldLabel.Position = UDim2.new(0, 80, 1, 0), UDim2.new(0, 5, 0, 0)
ldLabel.BackgroundTransparency, ldLabel.Text = 1, "Tải Config"
ldLabel.TextColor3, ldLabel.TextSize = Color3.fromRGB(255,255,255), 9
ldLabel.Font, ldLabel.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

local ldBtn = Instance.new("TextButton", loadConfigFrame)
ldBtn.Size, ldBtn.Position = UDim2.new(0, 85, 0, 20), UDim2.new(1, -90, 0.5, -10)
ldBtn.BackgroundColor3, ldBtn.BackgroundTransparency = Color3.fromRGB(50,10,35), 0
ldBtn.Text, ldBtn.TextColor3 = State.CurrentConfig .. " ∨", Color3.fromRGB(50,200,50)
ldBtn.TextSize, ldBtn.Font = 8, Enum.Font.GothamBold
ldBtn.TextXAlignment = Enum.TextXAlignment.Center
Corner(ldBtn, UDim.new(0, 4))
Stroke(ldBtn)
RegTheme(ldBtn, "Input")

local ldDropFrame = Instance.new("ScrollingFrame", mainConfigContainer)
ldDropFrame.LayoutOrder, ldDropFrame.Size = 7, UDim2.new(1, 0, 0, 80)
ldDropFrame.BackgroundColor3, ldDropFrame.BackgroundTransparency = Color3.fromRGB(80,20,60), 0
ldDropFrame.CanvasSize, ldDropFrame.ScrollBarThickness, ldDropFrame.Visible = UDim2.new(0,0,0,0), 3, false
Corner(ldDropFrame)
Stroke(ldDropFrame)
local ldDropLayout = Instance.new("UIListLayout", ldDropFrame)
ldDropLayout.Padding = UDim.new(0, 3)
local ldPad = Instance.new("UIPadding", ldDropFrame)
ldPad.PaddingRight = UDim.new(0, 8)
RegTheme(ldDropFrame, "DropFrame")

local saveFrame = Instance.new("Frame", mainConfigContainer)
saveFrame.LayoutOrder, saveFrame.Size = 8, UDim2.new(1, 0, 0, 34)
saveFrame.BackgroundColor3, saveFrame.BackgroundTransparency = Color3.fromRGB(70,15,50), 0
Corner(saveFrame)
Stroke(saveFrame)
RegTheme(saveFrame, "Primary")

local svTitle = Instance.new("TextLabel", saveFrame)
svTitle.Size, svTitle.Position = UDim2.new(1, -75, 0, 15), UDim2.new(0, 5, 0, 2)
svTitle.BackgroundTransparency, svTitle.Text = 1, "Lưu Cấu Hình"
svTitle.TextColor3, svTitle.TextSize = Color3.fromRGB(255,255,255), 9
svTitle.Font, svTitle.TextXAlignment = Enum.Font.GothamBold, Enum.TextXAlignment.Left

local svSub = Instance.new("TextLabel", saveFrame)
svSub.Size, svSub.Position = UDim2.new(1, -75, 0, 14), UDim2.new(0, 5, 0, 17)
svSub.BackgroundTransparency, svSub.Text = 1, "Save: " .. State.CurrentConfig
svSub.TextColor3, svSub.TextSize = Color3.fromRGB(140,140,150), 7
svSub.Font, svSub.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left

local saveBtn = Instance.new("TextButton", saveFrame)
saveBtn.Size, saveBtn.Position = UDim2.new(0, 65, 0, 22), UDim2.new(1, -70, 0.5, -11)
saveBtn.BackgroundColor3, saveBtn.Text = Color3.fromRGB(220,50,50), "Save"
saveBtn.TextColor3, saveBtn.TextSize = Color3.fromRGB(255,255,255), 9
saveBtn.Font = Enum.Font.GothamBold
Corner(saveBtn, UDim.new(0, 4))
Stroke(saveBtn)

local function RefreshStartupLabel()
    startupLabel.Text = "Startup: " .. State.CurrentConfig
end

local function ApplyConfig(data)
    if data.ThemeBase then
        local c = Color3.new(data.ThemeBase[1], data.ThemeBase[2], data.ThemeBase[3])
        ApplyTheme(c)
    end
    if data.StrokeMode == "Rainbow" then
        State.StrokeMode = "Rainbow"
        UpdateAllStrokes("Rainbow")
    elseif data.StrokeMode == "None" then
        State.StrokeMode = "None"
        UpdateAllStrokes("None")
    elseif data.StrokeColor then
        local c = Color3.new(data.StrokeColor[1], data.StrokeColor[2], data.StrokeColor[3])
        State.StrokeMode = "Solid"
        UpdateAllStrokes(c)
    end
    if type(data.Volume) == "number" then
        State.Volume = math.clamp(data.Volume, 0, 1)
        HubSound.Volume = State.Volume
        volumeBarFill.Size = UDim2.new(State.Volume, 0, 1, 0)
        volumeLabel.Text = "🔊 Vol: " .. math.floor(State.Volume * 100) .. "%"
    end
    if type(data.SoundId) == "string" then
        State.SoundId = data.SoundId
        HubSound.SoundId = "rbxassetid://" .. State.SoundId
    end
    if type(data.Transparent) == "number" then
        State.Transparent = math.clamp(data.Transparent, 0, 1)
        transBarFill.Size = UDim2.new(State.Transparent, 0, 1, 0)
        MainFrame.BackgroundTransparency = 0.15 + (State.Transparent * 0.85)
        SidebarPanel.BackgroundTransparency = State.Transparent
        ContentContainer.BackgroundTransparency = State.Transparent
        transLabel.Text = "✨ Trong suốt: " .. math.floor(State.Transparent * 100) .. "%"
    end
end

local function LoadConfig(name)
    local ok, dataOrErr = LoadConfigRaw(name)
    if not ok then return false, dataOrErr end
    ApplyConfig(dataOrErr)
    return true
end

local function refreshAllDropdowns()
    for _, drop in ipairs({delDropFrame, ldDropFrame}) do
        for _, child in ipairs(drop:GetChildren()) do
            if child:IsA("TextButton") then child:Destroy() end
        end
    end

    local filesList = {}
    if typeof(listfiles) == "function" then
        local ok, files = pcall(listfiles, CONFIG_FOLDER)
        if ok and type(files) == "table" then
            for _, file in ipairs(files) do
                if type(file) == "string" and string.sub(file, -5) == ".json" then
                    local fileName = string.match(file, "[^/\\]+$") or file
                    table.insert(filesList, string.sub(fileName, 1, -6))
                end
            end
        end
    end
    if #filesList == 0 then delBtn.Text = "Không có ∨" end

    for _, name in ipairs(filesList) do
        local f1 = Instance.new("TextButton", delDropFrame)
        f1.Size, f1.BackgroundColor3, f1.BackgroundTransparency = UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65), 0
        f1.Text, f1.TextColor3, f1.TextSize = " 🗑️ " .. name, Color3.fromRGB(255,100,100), 9
        f1.Font, f1.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(f1, UDim.new(0, 4))
        Stroke(f1)
        RegTheme(f1, "DropItem")
        Track(f1.MouseButton1Click:Connect(function()
            if typeof(delfile) == "function" then
                pcall(delfile, CONFIG_FOLDER .. "/" .. name .. ".json")
            end
            delBtn.Text = name .. " ∨"
            delDropFrame.Visible = false
            refreshAllDropdowns()
        end))

        local f3 = Instance.new("TextButton", ldDropFrame)
        f3.Size, f3.BackgroundColor3, f3.BackgroundTransparency = UDim2.new(1, 0, 0, 22), Color3.fromRGB(90,25,65), 0
        f3.Text, f3.TextColor3, f3.TextSize = " 📂 " .. name, Color3.fromRGB(255,255,255), 9
        f3.Font, f3.TextXAlignment = Enum.Font.Gotham, Enum.TextXAlignment.Left
        Corner(f3, UDim.new(0, 4))
        Stroke(f3)
        RegTheme(f3, "DropItem")
        Track(f3.MouseButton1Click:Connect(function()
            State.CurrentConfig = name
            ldBtn.Text = name .. " ∨"
            svSub.Text = "Save: " .. name
            ldDropFrame.Visible = false
            RefreshStartupLabel()
            local ok, err = LoadConfig(name)
            if not ok then warn("[VzNam] Load config fail: " .. tostring(err)) end
        end))
    end
    delDropFrame.CanvasSize = UDim2.new(0, 0, 0, #filesList * 25)
    ldDropFrame.CanvasSize = UDim2.new(0, 0, 0, #filesList * 25)
end

Track(delBtn.MouseButton1Click:Connect(function()
    refreshAllDropdowns()
    delDropFrame.Visible = not delDropFrame.Visible
    ldDropFrame.Visible = false
end))
Track(ldBtn.MouseButton1Click:Connect(function()
    refreshAllDropdowns()
    ldDropFrame.Visible = not ldDropFrame.Visible
    delDropFrame.Visible = false
end))

Track(createBtn.MouseButton1Click:Connect(function()
    local name = configNameBox.Text
    if name == "" then return end
    if string.find(name, "[\\/:*?\"<>|]") then
        warn("[VzNam] Tên config chứa ký tự không hợp lệ")
        return
    end
    if typeof(writefile) ~= "function" then return end
    if SaveConfig(name) then
        State.CurrentConfig = name
        ldBtn.Text = name .. " ∨"
        svSub.Text = "Save: " .. name
        configNameBox.Text = ""
        RefreshStartupLabel()
        refreshAllDropdowns()
    end
end))

Track(saveBtn.MouseButton1Click:Connect(function()
    if SaveConfig(State.CurrentConfig) then
        svSub.Text = "Save: " .. State.CurrentConfig
    end
end))

Track(OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end))

ApplyTheme(Color3.fromRGB(15, 16, 22))
UpdateAllStrokes(Color3.fromRGB(0, 191, 255))
RefreshStartupLabel()

print("[VzNam Hub-Main] ✅ Loaded successfully with Farm Egg Steal features.")
