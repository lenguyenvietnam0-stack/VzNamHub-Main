-- Xóa GUI cũ nếu đã chạy trước đó
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui

if PlayerGui:FindFirstChild("VzNamHubV4UI") then
    PlayerGui.VzNamHubV4UI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VzNamHubV4UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

-- ==================== 1. KHUNG CHÍNH (TRONG SUỐT XUYÊN THẤU + VIỀN MỎNG ĐEN) ====================
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 320)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -160)
MainFrame.BackgroundTransparency = 1 -- Trong suốt hoàn toàn xuyên thấu game
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

-- Viền ngoài cùng mỏng màu đen
local OuterStroke = Instance.new("UIStroke")
OuterStroke.Color = Color3.fromRGB(0, 0, 0)
OuterStroke.Thickness = 1
OuterStroke.Transparency = 0.1
OuterStroke.Parent = MainFrame

-- ==================== 2. TOPBAR THANH TIÊU ĐỀ ====================
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 28)
TopBar.BackgroundTransparency = 1
TopBar.Parent = MainFrame

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 18, 0, 18)
Logo.Position = UDim2.new(0, 10, 0.5, -9)
Logo.BackgroundTransparency = 1
Logo.Image = "rbxassetid://15298567397"
Logo.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 32, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "VzNam Hub V4 : Tổng Hợp"
Title.TextColor3 = Color3.fromRGB(0, 180, 255)
Title.TextSize = 12
Title.Font = Enum.Font.FredokaOne
Title.TextXAlignment = Enum.TextXAlignment.Center
Title.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -13)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TopBar

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- ==================== 3. KHUNG SIDEBAR TRÁI (MÀU ĐEN ĐẶC) ====================
local SidebarPanel = Instance.new("Frame")
SidebarPanel.Name = "SidebarPanel"
SidebarPanel.Size = UDim2.new(0, 145, 1, -34)
SidebarPanel.Position = UDim2.new(0, 6, 0, 28)
SidebarPanel.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
SidebarPanel.BackgroundTransparency = 0
SidebarPanel.BorderSizePixel = 0
SidebarPanel.Parent = MainFrame

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 6)
SidebarCorner.Parent = SidebarPanel

local SidebarStroke = Instance.new("UIStroke")
SidebarStroke.Color = Color3.fromRGB(40, 43, 52)
SidebarStroke.Thickness = 1
SidebarStroke.Parent = SidebarPanel

local SearchBox = Instance.new("TextBox")
SearchBox.Size = UDim2.new(1, -10, 0, 24)
SearchBox.Position = UDim2.new(0, 5, 0, 5)
SearchBox.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
SearchBox.BackgroundTransparency = 0
SearchBox.Text = ""
SearchBox.PlaceholderText = "🔍 Search section or Functi..."
SearchBox.PlaceholderColor3 = Color3.fromRGB(130, 135, 145)
SearchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchBox.TextSize = 10
SearchBox.Font = Enum.Font.FredokaOne
SearchBox.Parent = SidebarPanel

local SearchCorner = Instance.new("UICorner")
SearchCorner.CornerRadius = UDim.new(0, 4)
SearchCorner.Parent = SearchBox

local SidebarScroll = Instance.new("ScrollingFrame")
SidebarScroll.Size = UDim2.new(1, -8, 1, -34)
SidebarScroll.Position = UDim2.new(0, 4, 0, 32)
SidebarScroll.BackgroundTransparency = 1
SidebarScroll.BorderSizePixel = 0
SidebarScroll.ScrollBarThickness = 2
SidebarScroll.Parent = SidebarPanel

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Padding = UDim.new(0, 2)
SidebarLayout.Parent = SidebarScroll

-- ==================== 4. BẢNG NỘI DUNG PHẢI (MÀU ĐEN ĐẶC) ====================
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, -158, 1, -34)
ContentContainer.Position = UDim2.new(0, 153, 0, 28)
ContentContainer.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
ContentContainer.BackgroundTransparency = 0
ContentContainer.BorderSizePixel = 0
ContentContainer.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = ContentContainer

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Color3.fromRGB(40, 43, 52)
ContentStroke.Thickness = 1
ContentStroke.Parent = ContentContainer

-- Thanh tiêu đề bên trong
local ContentHeader = Instance.new("Frame")
ContentHeader.Size = UDim2.new(1, 0, 0, 30)
ContentHeader.BackgroundTransparency = 1
ContentHeader.Parent = ContentContainer

local ActiveTabTitle = Instance.new("TextLabel")
ActiveTabTitle.Size = UDim2.new(1, -40, 1, 0)
ActiveTabTitle.Position = UDim2.new(0, 12, 0, 0)
ActiveTabTitle.BackgroundTransparency = 1
ActiveTabTitle.Text = ""
ActiveTabTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
ActiveTabTitle.TextSize = 12
ActiveTabTitle.Font = Enum.Font.FredokaOne
ActiveTabTitle.TextXAlignment = Enum.TextXAlignment.Left
ActiveTabTitle.Parent = ContentHeader

local SearchInputContent = Instance.new("TextBox")
SearchInputContent.Size = UDim2.new(1, -45, 0, 22)
SearchInputContent.Position = UDim2.new(0, 10, 0.5, -11)
SearchInputContent.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
SearchInputContent.TextColor3 = Color3.fromRGB(255, 255, 255)
SearchInputContent.PlaceholderText = "Search features..."
SearchInputContent.PlaceholderColor3 = Color3.fromRGB(140, 140, 150)
SearchInputContent.TextSize = 10
SearchInputContent.Font = Enum.Font.FredokaOne
SearchInputContent.Visible = false
SearchInputContent.Parent = ContentHeader

local SearchInputCorner = Instance.new("UICorner")
SearchInputCorner.CornerRadius = UDim.new(0, 4)
SearchInputCorner.Parent = SearchInputContent

local SearchContentIcon = Instance.new("TextButton")
SearchContentIcon.Size = UDim2.new(0, 24, 0, 24)
SearchContentIcon.Position = UDim2.new(1, -28, 0.5, -12)
SearchContentIcon.BackgroundTransparency = 1
SearchContentIcon.Text = "🔍"
SearchContentIcon.TextSize = 12
SearchContentIcon.TextColor3 = Color3.fromRGB(200, 205, 215)
SearchContentIcon.Parent = ContentHeader

local HeaderDivider = Instance.new("Frame")
HeaderDivider.Size = UDim2.new(1, 0, 0, 1)
HeaderDivider.Position = UDim2.new(0, 0, 0, 30)
HeaderDivider.BackgroundColor3 = Color3.fromRGB(40, 43, 52)
HeaderDivider.BorderSizePixel = 0
HeaderDivider.Parent = ContentContainer

-- Quản lý Tab & Elements
local Tabs = {}
local FirstTab = nil

local function CreateTab(tabName)
    local tabBtn = Instance.new("TextButton")
    tabBtn.Size = UDim2.new(1, 0, 0, 26)
    tabBtn.BackgroundTransparency = 1
    tabBtn.Text = "   " .. tabName
    tabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    tabBtn.TextSize = 11
    tabBtn.Font = Enum.Font.FredokaOne
    tabBtn.TextXAlignment = Enum.TextXAlignment.Left
    tabBtn.Parent = SidebarScroll

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 3, 0, 12)
    indicator.Position = UDim2.new(0, 0, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    indicator.BorderSizePixel = 0
    indicator.Visible = false
    indicator.Parent = tabBtn

    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 2)
    indCorner.Parent = indicator

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1, -12, 1, -38)
    tabContent.Position = UDim2.new(0, 6, 0, 34)
    tabContent.BackgroundTransparency = 1
    tabContent.BorderSizePixel = 0
    tabContent.ScrollBarThickness = 3
    tabContent.Visible = false
    tabContent.Parent = ContentContainer

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 5)
    contentLayout.Parent = tabContent

    SearchInputContent:GetPropertyChangedSignal("Text"):Connect(function()
        if tabContent.Visible then
            local query = string.lower(SearchInputContent.Text)
            for _, item in ipairs(tabContent:GetChildren()) do
                if item:IsA("Frame") then
                    local titleLbl = item:FindFirstChild("Title") or item:FindFirstChild("Label")
                    if titleLbl and titleLbl:IsA("TextLabel") then
                        if query == "" or string.find(string.lower(titleLbl.Text), query) then
                            item.Visible = true
                        else
                            item.Visible = false
                        end
                    end
                end
            end
        end
    end)

    tabBtn.MouseButton1Click:Connect(function()
        for _, t in pairs(Tabs) do
            t.Content.Visible = false
            t.Indicator.Visible = false
            t.Button.Font = Enum.Font.FredokaOne
        end
        tabContent.Visible = true
        indicator.Visible = true
        tabBtn.Font = Enum.Font.FredokaOne
        ActiveTabTitle.Text = tabName
        SearchInputContent.Text = ""
    end)

    local tabObj = { Button = tabBtn, Content = tabContent, Indicator = indicator }
    table.insert(Tabs, tabObj)

    if not FirstTab then
        FirstTab = tabObj
        tabContent.Visible = true
        indicator.Visible = true
        tabBtn.Font = Enum.Font.FredokaOne
        ActiveTabTitle.Text = tabName
    end

    local Elements = {}

    function Elements:AddDropdown(titleText, defaultOpt)
        local frame = Instance.new("Frame")
        frame.Name = "ItemFrame"
        frame.Size = UDim2.new(1, -4, 0, 36)
        frame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = tabContent

        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0, 5)
        fc.Parent = frame

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -30, 1, 0)
        title.Position = UDim2.new(0, 10, 0, 0)
        title.BackgroundTransparency = 1
        title.Text = titleText .. ": " .. defaultOpt
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.Font = Enum.Font.FredokaOne
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local arrow = Instance.new("TextLabel")
        arrow.Size = UDim2.new(0, 24, 1, 0)
        arrow.Position = UDim2.new(1, -26, 0, 0)
        arrow.BackgroundTransparency = 1
        arrow.Text = ">"
        arrow.TextColor3 = Color3.fromRGB(200, 200, 210)
        arrow.TextSize = 12
        arrow.Font = Enum.Font.FredokaOne
        arrow.Parent = frame
    end

    function Elements:AddToggle(titleText, descText, callback)
        local frame = Instance.new("Frame")
        frame.Name = "ItemFrame"
        frame.Size = UDim2.new(1, -4, 0, 42)
        frame.BackgroundColor3 = Color3.fromRGB(22, 25, 34)
        frame.BackgroundTransparency = 0
        frame.BorderSizePixel = 0
        frame.Parent = tabContent

        local fc = Instance.new("UICorner")
        fc.CornerRadius = UDim.new(0, 5)
        fc.Parent = frame

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, -45, 0, 16)
        title.Position = UDim2.new(0, 10, 0, 5)
        title.BackgroundTransparency = 1
        title.Text = titleText
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 11
        title.Font = Enum.Font.FredokaOne
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = frame

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(1, -45, 0, 12)
        desc.Position = UDim2.new(0, 10, 0, 22)
        desc.BackgroundTransparency = 1
        desc.Text = descText
        desc.TextColor3 = Color3.fromRGB(140, 145, 155)
        desc.TextSize = 9
        desc.Font = Enum.Font.Gotham
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = frame

        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 18, 0, 18)
        box.Position = UDim2.new(1, -28, 0.5, -9)
        box.BackgroundColor3 = Color3.fromRGB(15, 16, 22)
        box.BorderSizePixel = 0
        box.Parent = frame

        local bc = Instance.new("UICorner")
        bc.CornerRadius = UDim.new(0, 4)
        bc.Parent = box

        local boxStroke = Instance.new("UIStroke")
        boxStroke.Color = Color3.fromRGB(0, 180, 255)
        boxStroke.Thickness = 1.5
        boxStroke.Parent = box

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new(1, -4, 1, -4)
        fill.Position = UDim2.new(0, 2, 0, 2)
        fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
        fill.BorderSizePixel = 0
        fill.Visible = false
        fill.Parent = box

        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 2)
        fillCorner.Parent = fill

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 10, 1, 10)
        btn.Position = UDim2.new(0, -5, 0, -5)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.Parent = box

        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            fill.Visible = active
            if callback then callback(active) end
        end)
    end

    function Elements:AddSection(sectionText)
        local label = Instance.new("TextLabel")
        label.Name = "ItemFrame"
        label.Size = UDim2.new(1, 0, 0, 20)
        label.BackgroundTransparency = 1
        label.Text = sectionText
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 11
        label.Font = Enum.Font.FredokaOne
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = tabContent
    end

    return Elements
end

local searching = false
SearchContentIcon.MouseButton1Click:Connect(function()
    searching = not searching
    SearchInputContent.Visible = searching
    ActiveTabTitle.Visible = not searching
    if searching then
        SearchInputContent:CaptureFocus()
    else
        SearchInputContent.Text = ""
    end
end)

-- Resize góc phải dưới
local ResizeBtn = Instance.new("TextButton")
ResizeBtn.Size = UDim2.new(0, 14, 0, 14)
ResizeBtn.Position = UDim2.new(1, -16, 1, -16)
ResizeBtn.BackgroundTransparency = 1
ResizeBtn.Text = "◢"
ResizeBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
ResizeBtn.TextSize = 11
ResizeBtn.Parent = MainFrame

local UserInputService = game:GetService("UserInputService")
local resizing = false
local startInput, startSize

ResizeBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = true
        startInput = input.Position
        startSize = MainFrame.Size
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - startInput
        local newX = math.max(400, startSize.X.Offset + delta.X)
        local newY = math.max(260, startSize.Y.Offset + delta.Y)
        MainFrame.Size = UDim2.new(0, newX, 0, newY)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        resizing = false
    end
end)

-- ==================== VÙNG THÊM TAB MỚI CỦA BẠN (ĐÃ XÓA SẠCH MẪU) ====================
-- Bạn có thể bắt đầu tạo Tab mới tại đây theo cú pháp:
-- local TabMoi = CreateTab("Tên Tab")
-- TabMoi:AddToggle("Chức Năng", "Mô tả", function(v) end)
-- TabMoi:AddDropdown("Lựa Chọn", "Mặc Định")

-- Lấy ảnh Avatar của người chơi hiện tại
local success, avatarThumbnail = pcall(function()
    return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
end)
local avatarUrl = success and avatarThumbnail or "rbxassetid://15298567397"

-- NÚT TRÒN MỞ MENU: AVATAR + VIỀN RAINBOW DÀY DẶN
local OpenButton = Instance.new("ImageButton")
OpenButton.Name = "VzNamOpenBtn"
OpenButton.Size = UDim2.new(0, 42, 0, 42)
OpenButton.Position = UDim2.new(0, 15, 0.2, 0)
OpenButton.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
OpenButton.BorderSizePixel = 0
OpenButton.Image = avatarUrl
OpenButton.Active = true
OpenButton.Draggable = true
OpenButton.Parent = ScreenGui

local OpenCorner = Instance.new("UICorner")
OpenCorner.CornerRadius = UDim.new(1, 0)
OpenCorner.Parent = OpenButton

local OpenStroke = Instance.new("UIStroke")
OpenStroke.Thickness = 3.5
OpenStroke.Parent = OpenButton

-- Vòng lặp chuyển màu Rainbow mượt mà cho viền nút tròn
local RunService = game:GetService("RunService")
task.spawn(function()
    local hue = 0
    while ScreenGui.Parent do
        hue = (tick() % 4) / 4
        OpenStroke.Color = Color3.fromHSV(hue, 1, 1)
        task.wait(0.03)
    end
end)

OpenButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)
