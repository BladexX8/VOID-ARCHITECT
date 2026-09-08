--[[
    ====================================================================
    SYSTEM: VOID ARCHITECT // ULTIMATE CLIENT SUITE v4.2
    ENVIRONMENT: Client-Side (LocalScript / Executor)
    DEFAULT TOGGLE KEY: RightControl
    UPDATED:
      - Mouse livre ao abrir o painel
      - Mouse preso ao fechar
      - FOV/Aimbot corrigidos para primeira pessoa
      - Melhor limpeza de ESP
      - Melhor gerenciamento de respawn
      - Restauração de valores originais
    ====================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ====================================================================
-- LIMPEZA DE INSTÂNCIAS LEGADAS
-- ====================================================================

local oldUI = PlayerGui:FindFirstChild("ArchitectSuiteUI")
if oldUI then
    oldUI:Destroy()
end

-- ====================================================================
-- ESTADO GLOBAL
-- ====================================================================

local TOGGLE_KEY = Enum.KeyCode.RightControl
local ListeningForKey = false

local Theme = {
    BG = Color3.fromRGB(10, 11, 16),
    Header = Color3.fromRGB(16, 17, 24),
    Sidebar = Color3.fromRGB(14, 15, 21),
    Card = Color3.fromRGB(20, 22, 30),
    CardHover = Color3.fromRGB(26, 28, 38),
    Accent = Color3.fromRGB(138, 92, 246),
    Text = Color3.fromRGB(243, 244, 246),
    SubText = Color3.fromRGB(156, 163, 175),
    CornerRadius = UDim.new(0, 8)
}

local State = {
    -- Player
    SpeedEnabled = false,
    WalkSpeed = 120,

    JumpEnabled = false,
    JumpPower = 150,

    InfJump = false,
    GodMode = false,
    ClickTP = false,
    BhopEnabled = false,

    HipHeightEnabled = false,
    HipHeightValue = 2,

    -- Movement
    FlyEnabled = false,
    FlySpeed = 80,

    NoclipEnabled = false,

    LowGravity = false,
    GravityValue = 50,

    BlinkEnabled = false,

    SpinbotEnabled = false,
    SpinSpeed = 20,

    -- Visual
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPHealth = true,
    ESPTracers = false,

    Fullbright = false,
    FOVEnabled = false,
    FOVValue = 90,

    NoFog = false,
    CrosshairEnabled = false,
    XrayEnabled = false,

    -- Combat
    HitboxEnabled = false,
    HitboxSize = 10,

    AimbotEnabled = false,
    AimbotSmoothness = 0.2,
    AimbotFOV = 150,
    ShowFOVCircle = false,

    AimPart = "Head",

    Triggerbot = false,

    -- Server / Utils
    AntiAFK = true,
    ShiftLockOverride = false,

    Waypoints = {},

    -- Original values
    OriginalGravity = workspace.Gravity,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalAmbient = Lighting.Ambient,
    OriginalBrightness = Lighting.Brightness,
    OriginalFieldOfView = Camera.FieldOfView
}

-- ====================================================================
-- FOV CIRCLE
-- ====================================================================

local fovCircle = Drawing.new("Circle")

fovCircle.Thickness = 1.5
fovCircle.Color = Theme.Accent
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.NumSides = 64
fovCircle.Visible = false

-- ====================================================================
-- CROSSHAIR
-- ====================================================================

local crosshairLines = {
    Top = Drawing.new("Line"),
    Bottom = Drawing.new("Line"),
    Left = Drawing.new("Line"),
    Right = Drawing.new("Line")
}

for _, line in pairs(crosshairLines) do
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1.5
    line.Transparency = 0.8
    line.Visible = false
end

-- ====================================================================
-- GUI PRINCIPAL
-- ====================================================================

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArchitectSuiteUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- ====================================================================
-- NOTIFICAÇÕES
-- ====================================================================

local notificationContainer = Instance.new("Frame")
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.new(0, 240, 1, -20)
notificationContainer.Position = UDim2.new(1, -250, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = screenGui

local notifList = Instance.new("UIListLayout")
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.Padding = UDim.new(0, 6)
notifList.Parent = notificationContainer

local function Notify(titleText, descText)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 48)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = notificationContainer

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = card

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Color = Theme.Accent
    stroke.Parent = card

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -10, 0, 18)
    tLbl.Position = UDim2.new(0, 8, 0, 4)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = titleText
    tLbl.TextColor3 = Theme.Accent
    tLbl.TextSize = 11
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local dLbl = Instance.new("TextLabel")
    dLbl.Size = UDim2.new(1, -10, 0, 18)
    dLbl.Position = UDim2.new(0, 8, 0, 22)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = descText
    dLbl.TextColor3 = Theme.Text
    dLbl.TextSize = 10
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.Parent = card

    task.delay(3.5, function()
        if not card.Parent then
            return
        end

        TweenService:Create(
            card,
            TweenInfo.new(0.3),
            {BackgroundTransparency = 1}
        ):Play()

        TweenService:Create(
            tLbl,
            TweenInfo.new(0.3),
            {TextTransparency = 1}
        ):Play()

        TweenService:Create(
            dLbl,
            TweenInfo.new(0.3),
            {TextTransparency = 1}
        ):Play()

        TweenService:Create(
            stroke,
            TweenInfo.new(0.3),
            {Transparency = 1}
        ):Play()

        task.wait(0.3)

        if card.Parent then
            card:Destroy()
        end
    end)
end

-- ====================================================================
-- MAIN FRAME
-- ====================================================================

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 650, 0, 460)
mainFrame.Position = UDim2.new(0.5, -325, 0.5, -230)
mainFrame.BackgroundColor3 = Theme.BG
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = Theme.CornerRadius
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Thickness = 1.2
mainStroke.Color = Color3.fromRGB(40, 42, 58)
mainStroke.Parent = mainFrame

-- ====================================================================
-- MOUSE BEHAVIOR
-- ====================================================================

local function UpdateMouseBehavior()
    if mainFrame.Visible then
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
    else
        UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
        UserInputService.MouseIconEnabled = false
    end
end

-- ====================================================================
-- HEADER
-- ====================================================================

local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 350, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VOID // ARCHITECT SUITE v4.2"
title.TextColor3 = Theme.Accent
title.TextSize = 13
title.Font = Enum.Font.GothamBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -36, 0.5, -14)
closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
closeBtn.BackgroundTransparency = 0.85
closeBtn.Text = "×"
closeBtn.TextColor3 = Color3.fromRGB(248, 113, 113)
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = header

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    mainFrame.Visible = false
    UpdateMouseBehavior()
end)

-- ====================================================================
-- SIDEBAR
-- ====================================================================

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 145, 1, -45)
sidebar.Position = UDim2.new(0, 0, 0, 45)
sidebar.BackgroundColor3 = Theme.Sidebar
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarList = Instance.new("UIListLayout")
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
sidebarList.Padding = UDim.new(0, 4)
sidebarList.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, 10)
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

-- ====================================================================
-- CONTENT AREA
-- ====================================================================

local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -145, 1, -45)
contentArea.Position = UDim2.new(0, 145, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- ====================================================================
-- SISTEMA DE ABAS
-- ====================================================================

local Tabs = {}

local function CreateTab(name)
    local tabButton = Instance.new("TextButton")

    tabButton.Size = UDim2.new(1, 0, 0, 32)
    tabButton.BackgroundColor3 = Theme.Sidebar
    tabButton.BackgroundTransparency = 1
    tabButton.Text = "  " .. name
    tabButton.TextColor3 = Theme.SubText
    tabButton.TextSize = 11
    tabButton.Font = Enum.Font.GothamMedium
    tabButton.TextXAlignment = Enum.TextXAlignment.Left
    tabButton.Parent = sidebar

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 6)
    tabCorner.Parent = tabButton

    local tabScroll = Instance.new("ScrollingFrame")

    tabScroll.Name = name .. "Tab"
    tabScroll.Size = UDim2.new(1, -20, 1, -20)
    tabScroll.Position = UDim2.new(0, 10, 0, 10)
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 3
    tabScroll.ScrollBarImageColor3 = Theme.Accent
    tabScroll.Visible = false
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.Parent = contentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = tabScroll

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabScroll.CanvasSize = UDim2.new(
            0,
            0,
            0,
            listLayout.AbsoluteContentSize.Y + 20
        )
    end)

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Scroll.Visible = false

            TweenService:Create(
                tab.Button,
                TweenInfo.new(0.2),
                {
                    BackgroundTransparency = 1,
                    TextColor3 = Theme.SubText
                }
            ):Play()
        end

        tabScroll.Visible = true

        TweenService:Create(
            tabButton,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 = Theme.Card,
                BackgroundTransparency = 0,
                TextColor3 = Theme.Accent
            }
        ):Play()
    end)

    local tabData = {
        Button = tabButton,
        Scroll = tabScroll
    }

    table.insert(Tabs, tabData)

    if #Tabs == 1 then
        tabScroll.Visible = true
        tabButton.BackgroundColor3 = Theme.Card
        tabButton.BackgroundTransparency = 0
        tabButton.TextColor3 = Theme.Accent
    end

    return tabScroll
end

-- ====================================================================
-- TOGGLE
-- ====================================================================

local function AddToggle(parent, titleText, descText, callback)
    local card = Instance.new("Frame")

    card.Size = UDim2.new(1, -4, 0, 48)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.7, 0, 0, 18)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local descLbl = Instance.new("TextLabel")
    descLbl.Size = UDim2.new(0.7, 0, 0, 16)
    descLbl.Position = UDim2.new(0, 10, 0, 23)
    descLbl.BackgroundTransparency = 1
    descLbl.Text = descText
    descLbl.TextColor3 = Theme.SubText
    descLbl.TextSize = 9
    descLbl.Font = Enum.Font.Gotham
    descLbl.TextXAlignment = Enum.TextXAlignment.Left
    descLbl.Parent = card

    local toggleBtn = Instance.new("TextButton")

    toggleBtn.Size = UDim2.new(0, 36, 0, 18)
    toggleBtn.Position = UDim2.new(1, -44, 0.5, -9)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    toggleBtn.Text = ""
    toggleBtn.Parent = card

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(1, 0)
    toggleCorner.Parent = toggleBtn

    local indicator = Instance.new("Frame")

    indicator.Size = UDim2.new(0, 12, 0, 12)
    indicator.Position = UDim2.new(0, 3, 0.5, -6)
    indicator.BackgroundColor3 = Color3.fromRGB(180, 180, 200)
    indicator.BorderSizePixel = 0
    indicator.Parent = toggleBtn

    local indicatorCorner = Instance.new("UICorner")
    indicatorCorner.CornerRadius = UDim.new(1, 0)
    indicatorCorner.Parent = indicator

    local active = false

    toggleBtn.MouseButton1Click:Connect(function()
        active = not active

        local targetPos

        if active then
            targetPos = UDim2.new(1, -15, 0.5, -6)
        else
            targetPos = UDim2.new(0, 3, 0.5, -6)
        end

        local targetColor

        if active then
            targetColor = Theme.Accent
        else
            targetColor = Color3.fromRGB(40, 42, 58)
        end

        TweenService:Create(
            indicator,
            TweenInfo.new(0.2),
            {Position = targetPos}
        ):Play()

        TweenService:Create(
            toggleBtn,
            TweenInfo.new(0.2),
            {BackgroundColor3 = targetColor}
        ):Play()

        callback(active)
    end)
end

-- ====================================================================
-- SLIDER
-- ====================================================================

local function AddSlider(parent, titleText, minVal, maxVal, defaultVal, callback)
    local card = Instance.new("Frame")

    card.Size = UDim2.new(1, -4, 0, 52)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(0.6, 0, 0, 18)
    titleLbl.Position = UDim2.new(0, 10, 0, 5)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local valInput = Instance.new("TextBox")

    valInput.Size = UDim2.new(0, 50, 0, 20)
    valInput.Position = UDim2.new(1, -60, 0, 4)
    valInput.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    valInput.BorderSizePixel = 0
    valInput.Text = tostring(defaultVal)
    valInput.TextColor3 = Theme.Accent
    valInput.TextSize = 11
    valInput.Font = Enum.Font.GothamBold
    valInput.ClearTextOnFocus = false
    valInput.Parent = card

    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 4)
    inputCorner.Parent = valInput

    local sliderTrack = Instance.new("Frame")

    sliderTrack.Size = UDim2.new(1, -20, 0, 5)
    sliderTrack.Position = UDim2.new(0, 10, 0, 34)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack

    local initialPercent = (defaultVal - minVal) / (maxVal - minVal)

    local sliderFill = Instance.new("Frame")

    sliderFill.Size = UDim2.new(initialPercent, 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local function SetValue(value)
        local clamped = math.clamp(value, minVal, maxVal)

        valInput.Text = tostring(clamped)

        local percent =
            (clamped - minVal) /
            (maxVal - minVal)

        sliderFill.Size = UDim2.new(
            percent,
            0,
            1,
            0
        )

        callback(clamped)
    end

    local dragging = false

    local function UpdateFromMouse(input)
        if sliderTrack.AbsoluteSize.X <= 0 then
            return
        end

        local pos =
            (input.Position.X - sliderTrack.AbsolutePosition.X) /
            sliderTrack.AbsoluteSize.X

        pos = math.clamp(pos, 0, 1)

        local value =
            math.floor(
                minVal +
                (maxVal - minVal) *
                pos
            )

        SetValue(value)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateFromMouse(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateFromMouse(input)
        end
    end)

    valInput.FocusLost:Connect(function()
        local num = tonumber(valInput.Text)

        if num then
            SetValue(num)
        else
            SetValue(defaultVal)
        end
    end)
end

-- ====================================================================
-- BUTTON
-- ====================================================================

local function AddButton(parent, titleText, btnText, callback)
    local card = Instance.new("Frame")

    card.Size = UDim2.new(1, -4, 0, 40)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local titleLbl = Instance.new("TextLabel")

    titleLbl.Size = UDim2.new(0.6, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local actionBtn = Instance.new("TextButton")

    actionBtn.Size = UDim2.new(0, 95, 0, 24)
    actionBtn.Position = UDim2.new(1, -105, 0.5, -12)
    actionBtn.BackgroundColor3 = Theme.Accent
    actionBtn.Text = btnText
    actionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    actionBtn.TextSize = 10
    actionBtn.Font = Enum.Font.GothamBold
    actionBtn.Parent = card

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = actionBtn

    actionBtn.MouseButton1Click:Connect(callback)
end

-- ====================================================================
-- TEXTBOX
-- ====================================================================

local function AddTextBox(parent, titleText, placeholderText, callback)
    local card = Instance.new("Frame")

    card.Size = UDim2.new(1, -4, 0, 42)
    card.BackgroundColor3 = Theme.Card
    card.BorderSizePixel = 0
    card.Parent = parent

    local cardCorner = Instance.new("UICorner")
    cardCorner.CornerRadius = UDim.new(0, 6)
    cardCorner.Parent = card

    local titleLbl = Instance.new("TextLabel")

    titleLbl.Size = UDim2.new(0.45, 0, 1, 0)
    titleLbl.Position = UDim2.new(0, 10, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = titleText
    titleLbl.TextColor3 = Theme.Text
    titleLbl.TextSize = 11
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = card

    local textBox = Instance.new("TextBox")

    textBox.Size = UDim2.new(0.5, -10, 0, 24)
    textBox.Position = UDim2.new(0.5, 0, 0.5, -12)
    textBox.BackgroundColor3 = Color3.fromRGB(30, 32, 44)
    textBox.PlaceholderText = placeholderText
    textBox.Text = ""
    textBox.TextColor3 = Theme.Text
    textBox.PlaceholderColor3 = Theme.SubText
    textBox.TextSize = 10
    textBox.Font = Enum.Font.Gotham
    textBox.Parent = card

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = textBox

    textBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            callback(textBox.Text)
        end
    end)
end

-- ====================================================================
-- ABAS
-- ====================================================================

local tabPlayer = CreateTab("Jogador")
local tabMovement = CreateTab("Movimento")
local tabVisuals = CreateTab("Visual & ESP")
local tabCombat = CreateTab("Combate")
local tabWaypoints = CreateTab("Waypoints")
local tabServer = CreateTab("Servidor")
local tabThemes = CreateTab("Configurações")

-- ====================================================================
-- JOGADOR
-- ====================================================================

AddToggle(
    tabPlayer,
    "Super Velocidade",
    "Aumenta drasticamente a velocidade de caminhada.",
    function(s)
        State.SpeedEnabled = s
        Notify("Velocidade", s and "Ativado" or "Desativado")
    end
)

AddSlider(
    tabPlayer,
    "Ajustar Velocidade",
    16,
    400,
    State.WalkSpeed,
    function(v)
        State.WalkSpeed = v
    end
)

AddToggle(
    tabPlayer,
    "Super Pulo",
    "Permite saltar em alturas elevadas.",
    function(s)
        State.JumpEnabled = s
    end
)

AddSlider(
    tabPlayer,
    "Força do Pulo",
    50,
    500,
    State.JumpPower,
    function(v)
        State.JumpPower = v
    end
)

AddToggle(
    tabPlayer,
    "Pulo Infinito",
    "Permite saltar repetidamente no ar.",
    function(s)
        State.InfJump = s
    end
)

AddToggle(
    tabPlayer,
    "Auto Bhop",
    "Salta automaticamente assim que toca o chão.",
    function(s)
        State.BhopEnabled = s
    end
)

AddToggle(
    tabPlayer,
    "God Mode Local",
    "Refaz a saúde continuamente para evitar mortes.",
    function(s)
        State.GodMode = s
    end
)

AddToggle(
    tabPlayer,
    "Ajustar HipHeight",
    "Eleva a altura do personagem.",
    function(s)
        State.HipHeightEnabled = s

        if not s and LocalPlayer.Character then
            local humanoid =
                LocalPlayer.Character:FindFirstChildOfClass("Humanoid")

            if humanoid then
                humanoid.HipHeight = 0
            end
        end
    end
)

AddSlider(
    tabPlayer,
    "Altura (HipHeight)",
    0,
    30,
    State.HipHeightValue,
    function(v)
        State.HipHeightValue = v
    end
)

AddToggle(
    tabPlayer,
    "Click Teleport",
    "Ctrl + clique para teleportar.",
    function(s)
        State.ClickTP = s
    end
)

-- ====================================================================
-- MOVIMENTO
-- ====================================================================

AddToggle(
    tabMovement,
    "Modo Voo (Fly)",
    "Flutue e navegue livremente.",
    function(s)
        State.FlyEnabled = s
    end
)

AddSlider(
    tabMovement,
    "Velocidade de Voo",
    20,
    350,
    State.FlySpeed,
    function(v)
        State.FlySpeed = v
    end
)

AddToggle(
    tabMovement,
    "Noclip",
    "Atravesse estruturas e paredes.",
    function(s)
        State.NoclipEnabled = s
    end
)

AddToggle(
    tabMovement,
    "Gravidade Baixa",
    "Altera a gravidade do workspace.",
    function(s)
        State.LowGravity = s

        if not s then
            workspace.Gravity = State.OriginalGravity
        end
    end
)

AddSlider(
    tabMovement,
    "Valor da Gravidade",
    0,
    196,
    State.GravityValue,
    function(v)
        State.GravityValue = v
    end
)

AddToggle(
    tabMovement,
    "Blink",
    "Congela seu personagem.",
    function(s)
        State.BlinkEnabled = s
        Notify(
            "Blink Switch",
            s and "Ativo" or "Inativo"
        )
    end
)

AddToggle(
    tabMovement,
    "Spinbot",
    "Gira o personagem rapidamente.",
    function(s)
        State.SpinbotEnabled = s
    end
)

AddSlider(
    tabMovement,
    "Velocidade de Rotação",
    1,
    100,
    State.SpinSpeed,
    function(v)
        State.SpinSpeed = v
    end
)

-- ====================================================================
-- VISUAL
-- ====================================================================

AddToggle(
    tabVisuals,
    "ESP Master Switch",
    "Ativa o sistema visual.",
    function(s)
        State.ESPEnabled = s
    end
)

AddToggle(
    tabVisuals,
    "Highlight Box",
    "Destaque luminoso nos jogadores.",
    function(s)
        State.ESPBoxes = s
    end
)

AddToggle(
    tabVisuals,
    "ESP Nomes & Distância",
    "Exibe nome, HP e distância.",
    function(s)
        State.ESPNames = s
    end
)

AddToggle(
    tabVisuals,
    "ESP Tracers",
    "Linhas da tela até os jogadores.",
    function(s)
        State.ESPTracers = s
    end
)

AddToggle(
    tabVisuals,
    "Fullbright",
    "Ilumina as áreas escuras.",
    function(s)
        State.Fullbright = s

        if not s then
            Lighting.Ambient = State.OriginalAmbient
            Lighting.Brightness = State.OriginalBrightness
        end
    end
)

AddToggle(
    tabVisuals,
    "Sem Névoa",
    "Remove a neblina.",
    function(s)
        State.NoFog = s

        if not s then
            Lighting.FogEnd = State.OriginalFogEnd
        end
    end
)

AddToggle(
    tabVisuals,
    "Crosshair",
    "Mira fixa no centro.",
    function(s)
        State.CrosshairEnabled = s
    end
)

AddToggle(
    tabVisuals,
    "FOV Customizado",
    "Aumenta o campo de visão.",
    function(s)
        State.FOVEnabled = s

        if not s then
            Camera.FieldOfView = State.OriginalFieldOfView
        end
    end
)

AddSlider(
    tabVisuals,
    "Ângulo FOV",
    70,
    130,
    State.FOVValue,
    function(v)
        State.FOVValue = v
    end
)

-- ====================================================================
-- COMBATE
-- ====================================================================

AddToggle(
    tabCombat,
    "Camera Lock / Aimbot",
    "Trava a câmera no alvo mais próximo.",
    function(s)
        State.AimbotEnabled = s
        Notify(
            "Aimbot",
            s and "Ativado" or "Desativado"
        )
    end
)

AddSlider(
    tabCombat,
    "Suavidade do Aimbot",
    1,
    10,
    math.floor(State.AimbotSmoothness * 10),
    function(v)
        State.AimbotSmoothness = v / 10
    end
)

AddToggle(
    tabCombat,
    "Mostrar Círculo FOV",
    "Exibe o raio do aimbot.",
    function(s)
        State.ShowFOVCircle = s
    end
)

AddSlider(
    tabCombat,
    "Raio do FOV Aim",
    50,
    400,
    State.AimbotFOV,
    function(v)
        State.AimbotFOV = v
    end
)

AddButton(
    tabCombat,
    "Mudar Alvo do Aim",
    "Trocar Cabeça/Torso",
    function()
        if State.AimPart == "Head" then
            State.AimPart = "HumanoidRootPart"
            Notify(
                "Aimbot",
                "Alvo: TORSO"
            )
        else
            State.AimPart = "Head"
            Notify(
                "Aimbot",
                "Alvo: CABEÇA"
            )
        end
    end
)

AddToggle(
    tabCombat,
    "Triggerbot",
    "Ativa automaticamente ao mirar no alvo.",
    function(s)
        State.Triggerbot = s
    end
)

AddToggle(
    tabCombat,
    "Hitbox Extender",
    "Aumenta a área de acerto.",
    function(s)
        State.HitboxEnabled = s
    end
)

AddSlider(
    tabCombat,
    "Tamanho da Hitbox",
    2,
    40,
    State.HitboxSize,
    function(v)
        State.HitboxSize = v
    end
)

-- ====================================================================
-- WAYPOINTS
-- ====================================================================

AddTextBox(
    tabWaypoints,
    "Novo Waypoint",
    "Nome do local...",
    function(text)
        if
            text
            and text ~= ""
            and LocalPlayer.Character
            and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        then
            local pos =
                LocalPlayer.Character.HumanoidRootPart.Position

            table.insert(
                State.Waypoints,
                {
                    Name = text,
                    Position = pos
                }
            )

            Notify(
                "Waypoint",
                "Salvo: " .. text
            )
        end
    end
)

AddButton(
    tabWaypoints,
    "Teleportar p/ Último Waypoint",
    "Ir",
    function()
        if #State.Waypoints == 0 then
            Notify(
                "Waypoint",
                "Nenhum waypoint registrado!"
            )
            return
        end

        local last =
            State.Waypoints[#State.Waypoints]

        local char = LocalPlayer.Character

        if char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame =
                CFrame.new(
                    last.Position +
                    Vector3.new(0, 3, 0)
                )

            Notify(
                "Waypoint",
                "Teleportado para: " .. last.Name
            )
        end
    end
)

AddButton(
    tabWaypoints,
    "Limpar Todos Waypoints",
    "Limpar",
    function()
        State.Waypoints = {}

        Notify(
            "Waypoints",
            "Lista resetada."
        )
    end
)

-- ====================================================================
-- SERVIDOR
-- ====================================================================

AddToggle(
    tabServer,
    "Anti-AFK",
    "Evita desconexão por inatividade.",
    function(s)
        State.AntiAFK = s
    end
)

AddToggle(
    tabServer,
    "Forçar Shift Lock",
    "Ativa o Shift Lock.",
    function(s)
        State.ShiftLockOverride = s

        pcall(function()
            LocalPlayer.DevEnableMouseLock = s
        end)
    end
)

AddButton(
    tabServer,
    "Reconectar ao Servidor",
    "Rejoin",
    function()
        Notify(
            "Servidor",
            "Reconectando..."
        )

        TeleportService:TeleportToPlaceInstance(
            game.PlaceId,
            game.JobId,
            LocalPlayer
        )
    end
)

AddButton(
    tabServer,
    "Server Hop",
    "Hop",
    function()
        Notify(
            "Servidor",
            "Trocando de servidor..."
        )

        TeleportService:Teleport(
            game.PlaceId,
            LocalPlayer
        )
    end
)

AddButton(
    tabServer,
    "Copiar JobID",
    "Copiar",
    function()
        if setclipboard then
            setclipboard(
                tostring(game.JobId)
            )

            Notify(
                "Servidor",
                "JobID copiado!"
            )
        else
            Notify(
                "Servidor",
                "setclipboard não disponível."
            )
        end
    end
)

-- ====================================================================
-- CONFIGURAÇÕES
-- ====================================================================

local keybindCard = Instance.new("Frame")

keybindCard.Size = UDim2.new(1, -4, 0, 40)
keybindCard.BackgroundColor3 = Theme.Card
keybindCard.BorderSizePixel = 0
keybindCard.Parent = tabThemes

local kbCorner = Instance.new("UICorner")
kbCorner.CornerRadius = UDim.new(0, 6)
kbCorner.Parent = keybindCard

local kbLbl = Instance.new("TextLabel")

kbLbl.Size = UDim2.new(0.6, 0, 1, 0)
kbLbl.Position = UDim2.new(0, 10, 0, 0)
kbLbl.BackgroundTransparency = 1
kbLbl.Text = "Atalho do Painel"
kbLbl.TextColor3 = Theme.Text
kbLbl.TextSize = 11
kbLbl.Font = Enum.Font.GothamMedium
kbLbl.TextXAlignment = Enum.TextXAlignment.Left
kbLbl.Parent = keybindCard

local kbBtn = Instance.new("TextButton")

kbBtn.Size = UDim2.new(0, 95, 0, 24)
kbBtn.Position = UDim2.new(1, -105, 0.5, -12)
kbBtn.BackgroundColor3 = Theme.Accent
kbBtn.Text = TOGGLE_KEY.Name
kbBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
kbBtn.TextSize = 10
kbBtn.Font = Enum.Font.GothamBold
kbBtn.Parent = keybindCard

local kbBtnCorner = Instance.new("UICorner")
kbBtnCorner.CornerRadius = UDim.new(0, 4)
kbBtnCorner.Parent = kbBtn

kbBtn.MouseButton1Click:Connect(function()
    ListeningForKey = true
    kbBtn.Text = "Pressione..."
end)

local function CreateThemePicker(parent, themeName, color)
    AddButton(
        parent,
        "Tema: " .. themeName,
        "Aplicar",
        function()
            Theme.Accent = color

            title.TextColor3 = color
            fovCircle.Color = color

            for _, tab in pairs(Tabs) do
                tab.Scroll.ScrollBarImageColor3 = color

                if tab.Scroll.Visible then
                    tab.Button.TextColor3 = color
                end
            end

            Notify(
                "Tema",
                "Tema alterado para " .. themeName
            )
        end
    )
end

CreateThemePicker(
    tabThemes,
    "Roxo Neon",
    Color3.fromRGB(138, 92, 246)
)

CreateThemePicker(
    tabThemes,
    "Azul Cyber",
    Color3.fromRGB(14, 165, 233)
)

CreateThemePicker(
    tabThemes,
    "Verde Matrix",
    Color3.fromRGB(34, 197, 94)
)

CreateThemePicker(
    tabThemes,
    "Vermelho Rubro",
    Color3.fromRGB(239, 68, 68)
)

CreateThemePicker(
    tabThemes,
    "Amarelo Ouro",
    Color3.fromRGB(234, 179, 8)
)

-- ====================================================================
-- INPUT DO PAINEL
-- ====================================================================

UserInputService.InputBegan:Connect(function(input, gpe)
    if ListeningForKey then
        if input.UserInputType == Enum.UserInputType.Keyboard then
            TOGGLE_KEY = input.KeyCode
            ListeningForKey = false

            kbBtn.Text = TOGGLE_KEY.Name

            Notify(
                "Atalho Modificado",
                "Novo atalho: " .. TOGGLE_KEY.Name
            )
        end

        return
    end

    if not gpe and input.KeyCode == TOGGLE_KEY then
        mainFrame.Visible = not mainFrame.Visible
        UpdateMouseBehavior()
    end
end)

-- ====================================================================
-- CLICK TELEPORT
-- ====================================================================

Mouse.Button1Down:Connect(function()
    if not State.ClickTP then
        return
    end

    if not UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        return
    end

    local char = LocalPlayer.Character

    if
        char
        and char:FindFirstChild("HumanoidRootPart")
        and Mouse.Hit
    then
        char.HumanoidRootPart.CFrame =
            Mouse.Hit +
            Vector3.new(0, 3, 0)
    end
end)

-- ====================================================================
-- ANTI AFK
-- ====================================================================

local VirtualUser = game:GetService("VirtualUser")

LocalPlayer.Idled:Connect(function()
    if not State.AntiAFK then
        return
    end

    VirtualUser:Button2Down(
        Vector2.new(0, 0),
        Camera.CFrame
    )

    task.wait(1)

    VirtualUser:Button2Up(
        Vector2.new(0, 0),
        Camera.CFrame
    )
end)

-- ====================================================================
-- PULO INFINITO
-- ====================================================================

UserInputService.JumpRequest:Connect(function()
    if not State.InfJump then
        return
    end

    local char = LocalPlayer.Character

    if not char then
        return
    end

    local humanoid =
        char:FindFirstChildOfClass("Humanoid")

    if humanoid then
        humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

-- ====================================================================
-- ESP CACHE
-- ====================================================================

local espCache = {}

local function CleanupESP(plr)
    local cache = espCache[plr]

    if not cache then
        return
    end

    if cache.Text then
        pcall(function()
            cache.Text:Remove()
        end)
    end

    if cache.Tracer then
        pcall(function()
            cache.Tracer:Remove()
        end)
    end

    espCache[plr] = nil
end

-- ====================================================================
-- HELPER: PRIMEIRA PESSOA
-- ====================================================================

local function IsFirstPerson()
    if not Camera then
        return false
    end

    return (
        Camera.CFrame.Position -
        Camera.Focus.Position
    ).Magnitude < 1
end

-- ====================================================================
-- HELPER: POSIÇÃO DO AIM/FOV
-- ====================================================================

local function GetAimScreenPosition()
    if IsFirstPerson() then
        return Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )
    end

    return UserInputService:GetMouseLocation()
end

-- ====================================================================
-- LOOP PRINCIPAL
-- ====================================================================

RunService.RenderStepped:Connect(function()
    Camera = workspace.CurrentCamera or Camera

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local root = char and char:FindFirstChild("HumanoidRootPart")

    -- ================================================================
    -- PLAYER
    -- ================================================================

    if hum then
        if State.SpeedEnabled then
            hum.WalkSpeed = State.WalkSpeed
        end

        if State.JumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPower
        end

        if State.GodMode then
            hum.Health = hum.MaxHealth
        end

        if State.HipHeightEnabled then
            hum.HipHeight = State.HipHeightValue
        end

        if
            State.BhopEnabled
            and hum.FloorMaterial ~= Enum.Material.Air
            and UserInputService:IsKeyDown(Enum.KeyCode.Space)
        then
            hum:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end

    -- ================================================================
    -- GRAVIDADE
    -- ================================================================

    if State.LowGravity then
        workspace.Gravity = State.GravityValue
    end

    -- ================================================================
    -- FLY
    -- ================================================================

    if State.FlyEnabled and root then
        local moveDir = Vector3.zero

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            moveDir += Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            moveDir -= Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            moveDir -= Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            moveDir += Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            moveDir += Vector3.new(0, 1, 0)
        end

        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            moveDir -= Vector3.new(0, 1, 0)
        end

        root.Velocity =
            moveDir * State.FlySpeed

        root.RotVelocity = Vector3.zero
    end

    -- ================================================================
    -- SPINBOT
    -- ================================================================

    if State.SpinbotEnabled and root then
        root.CFrame =
            root.CFrame *
            CFrame.Angles(
                0,
                math.rad(State.SpinSpeed),
                0
            )
    end

    -- ================================================================
    -- BLINK
    -- ================================================================

    if State.BlinkEnabled and root then
        root.Anchored = true
    elseif root and not State.BlinkEnabled and root.Anchored then
        root.Anchored = false
    end

    -- ================================================================
    -- NOCLIP
    -- ================================================================

    if State.NoclipEnabled and char then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end

    -- ================================================================
    -- FULLBRIGHT
    -- ================================================================

    if State.Fullbright then
        Lighting.Ambient =
            Color3.fromRGB(
                255,
                255,
                255
            )

        Lighting.Brightness = 2
    end

    -- ================================================================
    -- NO FOG
    -- ================================================================

    if State.NoFog then
        Lighting.FogEnd = 1e6
    end

    -- ================================================================
    -- FOV
    -- ================================================================

    if State.FOVEnabled then
        Camera.FieldOfView = State.FOVValue
    end

    -- ================================================================
    -- FOV CIRCLE
    -- ================================================================

    if State.ShowFOVCircle then
        fovCircle.Position = GetAimScreenPosition()
        fovCircle.Radius = State.AimbotFOV
        fovCircle.Visible = true
    else
        fovCircle.Visible = false
    end

    -- ================================================================
    -- CROSSHAIR
    -- ================================================================

    if State.CrosshairEnabled then
        local center = Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )

        local length = 8

        crosshairLines.Top.From =
            center -
            Vector2.new(0, 3)

        crosshairLines.Top.To =
            center -
            Vector2.new(0, 3 + length)

        crosshairLines.Bottom.From =
            center +
            Vector2.new(0, 3)

        crosshairLines.Bottom.To =
            center +
            Vector2.new(0, 3 + length)

        crosshairLines.Left.From =
            center -
            Vector2.new(3, 0)

        crosshairLines.Left.To =
            center -
            Vector2.new(3 + length, 0)

        crosshairLines.Right.From =
            center +
            Vector2.new(3, 0)

        crosshairLines.Right.To =
            center +
            Vector2.new(3 + length, 0)

        for _, line in pairs(crosshairLines) do
            line.Visible = true
        end
    else
        for _, line in pairs(crosshairLines) do
            line.Visible = false
        end
    end

    -- ================================================================
    -- TRIGGERBOT
    -- ================================================================

    if State.Triggerbot and Mouse.Target then
        local targetChar =
            Mouse.Target:FindFirstAncestorOfClass("Model")

        if
            targetChar
            and targetChar:FindFirstChildOfClass("Humanoid")
            and Players:GetPlayerFromCharacter(targetChar) ~= LocalPlayer
        then
            if mouse1click then
                mouse1click()
            end
        end
    end

    -- ================================================================
    -- ESP / HITBOX
    -- ================================================================

    for _, plr in ipairs(Players:GetPlayers()) do
        if
            plr ~= LocalPlayer
            and plr.Character
        then
            local targetChar = plr.Character

            local pRoot =
                targetChar:FindFirstChild(
                    "HumanoidRootPart"
                )

            local pHum =
                targetChar:FindFirstChildOfClass(
                    "Humanoid"
                )

            -- ========================================================
            -- HITBOX
            -- ========================================================

            if pRoot then
                if State.HitboxEnabled then
                    pRoot.Size =
                        Vector3.new(
                            State.HitboxSize,
                            State.HitboxSize,
                            State.HitboxSize
                        )

                    pRoot.Transparency = 0.7
                    pRoot.Color = Theme.Accent
                    pRoot.Material =
                        Enum.Material.ForceField
                    pRoot.CanCollide = false
                else
                    pRoot.Size =
                        Vector3.new(
                            2,
                            2,
                            1
                        )

                    pRoot.Transparency = 1
                end
            end

            -- ========================================================
            -- HIGHLIGHT
            -- ========================================================

            local highlight =
                targetChar:FindFirstChild(
                    "ArchitectESP"
                )

            if
                State.ESPEnabled
                and State.ESPBoxes
            then
                if not highlight then
                    highlight =
                        Instance.new("Highlight")

                    highlight.Name =
                        "ArchitectESP"

                    highlight.FillColor =
                        Theme.Accent

                    highlight.OutlineColor =
                        Color3.fromRGB(
                            255,
                            255,
                            255
                        )

                    highlight.FillTransparency =
                        0.5

                    highlight.Parent =
                        targetChar
                else
                    highlight.FillColor =
                        Theme.Accent
                end
            else
                if highlight then
                    highlight:Destroy()
                end
            end

            -- ========================================================
            -- ESP DRAWING
            -- ========================================================

            if
                State.ESPEnabled
                and pRoot
                and pHum
                and pHum.Health > 0
            then
                local screenPos, onScreen =
                    Camera:WorldToViewportPoint(
                        pRoot.Position
                    )

                if onScreen then
                    if not espCache[plr] then
                        espCache[plr] = {
                            Text = Drawing.new("Text"),
                            Tracer = Drawing.new("Line")
                        }

                        espCache[plr].Text.Size = 13
                        espCache[plr].Text.Center = true
                        espCache[plr].Text.Outline = true
                        espCache[plr].Text.Color =
                            Color3.fromRGB(
                                255,
                                255,
                                255
                            )

                        espCache[plr].Tracer.Thickness = 1
                        espCache[plr].Tracer.Color =
                            Theme.Accent
                    end

                    local cache = espCache[plr]

                    -- Nomes
                    if State.ESPNames then
                        local dist =
                            math.floor(
                                (
                                    pRoot.Position -
                                    Camera.CFrame.Position
                                ).Magnitude
                            )

                        cache.Text.Position =
                            Vector2.new(
                                screenPos.X,
                                screenPos.Y - 25
                            )

                        cache.Text.Text =
                            string.format(
                                "%s [%d HP | %dm]",
                                plr.Name,
                                math.floor(
                                    pHum.Health
                                ),
                                dist
                            )

                        cache.Text.Visible = true
                    else
                        cache.Text.Visible = false
                    end

                    -- Tracer
                    if State.ESPTracers then
                        cache.Tracer.From =
                            Vector2.new(
                                Camera.ViewportSize.X / 2,
                                Camera.ViewportSize.Y
                            )

                        cache.Tracer.To =
                            Vector2.new(
                                screenPos.X,
                                screenPos.Y
                            )

                        cache.Tracer.Color =
                            Theme.Accent

                        cache.Tracer.Visible = true
                    else
                        cache.Tracer.Visible = false
                    end
                else
                    if espCache[plr] then
                        espCache[plr].Text.Visible = false
                        espCache[plr].Tracer.Visible = false
                    end
                end
            else
                CleanupESP(plr)
            end
        else
            CleanupESP(plr)
        end
    end

    -- ================================================================
    -- AIMBOT
    -- ================================================================

    if State.AimbotEnabled then
        local target = nil
        local minDistance = State.AimbotFOV

        -- CORREÇÃO:
        -- Primeira pessoa = centro da tela
        -- Terceira pessoa = posição real do mouse
        local aimPosition =
            GetAimScreenPosition()

        for _, plr in ipairs(Players:GetPlayers()) do
            if
                plr ~= LocalPlayer
                and plr.Character
            then
                local targetPart =
                    plr.Character:FindFirstChild(
                        State.AimPart
                    )

                local pHum =
                    plr.Character:FindFirstChildOfClass(
                        "Humanoid"
                    )

                if
                    targetPart
                    and pHum
                    and pHum.Health > 0
                then
                    local screenPos, onScreen =
                        Camera:WorldToViewportPoint(
                            targetPart.Position
                        )

                    if onScreen then
                        local distToAim =
                            (
                                Vector2.new(
                                    screenPos.X,
                                    screenPos.Y
                                ) -
                                aimPosition
                            ).Magnitude

                        if distToAim < minDistance then
                            minDistance =
                                distToAim

                            target =
                                targetPart
                        end
                    end
                end
            end
        end

        -- ============================================================
        -- CAMERA LOCK
        -- ============================================================

        if target then
            local targetCFrame =
                CFrame.new(
                    Camera.CFrame.Position,
                    target.Position
                )

            local smooth =
                math.clamp(
                    State.AimbotSmoothness,
                    0.01,
                    1
                )

            Camera.CFrame =
                Camera.CFrame:Lerp(
                    targetCFrame,
                    smooth
                )
        end
    end
end)

-- ====================================================================
-- PLAYER REMOVING
-- ====================================================================

Players.PlayerRemoving:Connect(function(plr)
    CleanupESP(plr)
end)

-- ====================================================================
-- RESPAWN
-- ====================================================================

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)

    Camera =
        workspace.CurrentCamera or Camera

    if not mainFrame.Visible then
        UpdateMouseBehavior()
    end
end)

-- ====================================================================
-- INICIALIZAÇÃO
-- ====================================================================

UpdateMouseBehavior()

Notify(
    "VOID ARCHITECT",
    "Suite v4.2 inicializada com sucesso!"
)
