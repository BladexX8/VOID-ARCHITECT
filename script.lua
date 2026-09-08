```lua
--[[
    ====================================================================
    VOID ARCHITECT // ULTIMATE CLIENT SUITE v4.4
    CLIENT-SIDE
    DEFAULT PANEL KEY: RightControl

    CORREÇÕES:
      - Mouse livre ao abrir o painel
      - Mouse escondido somente em primeira pessoa
      - Mouse visível em terceira pessoa
      - NÃO força MouseBehavior todo frame
      - Câmera volta a funcionar ao fechar o painel
      - Detecta mudança entre 1ª e 3ª pessoa
      - FOV/Aim usam centro da tela em primeira pessoa
      - FOV/Aim usam mouse em terceira pessoa

    FUNCIONALIDADES:
      - Speed
      - Jump
      - Infinite Jump
      - God Mode local
      - Click Teleport
      - Auto Bhop
      - HipHeight
      - Infinite Zoom
      - Platform Stand
      - Fly
      - Noclip
      - Low Gravity
      - Blink
      - Spinbot
      - Anti-Fling
      - ESP
      - Hitbox
      - Aimbot
      - Aimbot Hold Mode
      - Triggerbot
      - FOV
      - Crosshair
      - Fullbright
      - No Fog
      - FPS Counter
      - Waypoints
      - Anti-AFK
      - Server Rejoin
      - Server Hop
      - Theme System
    ====================================================================
--]]

-- ====================================================================
-- SERVICES
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

-- ====================================================================
-- REFERENCES
-- ====================================================================

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = workspace.CurrentCamera

-- ====================================================================
-- CLEANUP
-- ====================================================================

local oldUI = PlayerGui:FindFirstChild("ArchitectSuiteUI")

if oldUI then
    oldUI:Destroy()
end

-- ====================================================================
-- CONFIG
-- ====================================================================

local TOGGLE_KEY = Enum.KeyCode.RightControl

local ListeningForKey = nil

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

-- ====================================================================
-- STATE
-- ====================================================================

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

    InfiniteZoom = false,
    ZoomDistance = 500,

    PlatformStand = false,

    -- Movement
    FlyEnabled = false,
    FlySpeed = 80,

    NoclipEnabled = false,

    LowGravity = false,
    GravityValue = 50,

    BlinkEnabled = false,

    SpinbotEnabled = false,
    SpinSpeed = 20,

    AntiFling = false,

    -- Visual
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPTracers = false,

    Fullbright = false,

    FOVEnabled = false,
    FOVValue = 90,

    NoFog = false,

    CrosshairEnabled = false,

    FPSCounter = false,

    -- Combat
    HitboxEnabled = false,
    HitboxSize = 10,

    AimbotEnabled = false,

    AimbotSmoothness = 0.2,

    AimbotFOV = 150,

    ShowFOVCircle = false,

    AimPart = "Head",

    Triggerbot = false,

    AimbotHold = false,

    AimbotKey = Enum.KeyCode.LeftAlt,

    -- Utility
    AntiAFK = true,

    ShiftLockOverride = false,

    Waypoints = {},

    -- Original values
    OriginalGravity = workspace.Gravity,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalAmbient = Lighting.Ambient,
    OriginalBrightness = Lighting.Brightness,
    OriginalFieldOfView = Camera.FieldOfView,
    OriginalZoom = LocalPlayer.CameraMaxZoomDistance
}

-- ====================================================================
-- CAMERA HELPERS
-- ====================================================================

local function RefreshCamera()
    Camera = workspace.CurrentCamera or Camera
end

local function IsFirstPerson()
    RefreshCamera()

    if not Camera then
        return false
    end

    local distance = (
        Camera.CFrame.Position -
        Camera.Focus.Position
    ).Magnitude

    return distance < 1
end

local function GetAimScreenPosition()
    RefreshCamera()

    if IsFirstPerson() then
        return Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )
    end

    return UserInputService:GetMouseLocation()
end

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
-- GUI
-- ====================================================================

local screenGui = Instance.new("ScreenGui")

screenGui.Name = "ArchitectSuiteUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

-- ====================================================================
-- FPS LABEL
-- ====================================================================

local fpsLabel = Instance.new("TextLabel")

fpsLabel.Name = "FPSCounter"

fpsLabel.Size = UDim2.new(0, 140, 0, 25)

fpsLabel.Position = UDim2.new(
    0,
    10,
    0,
    10
)

fpsLabel.BackgroundTransparency = 1

fpsLabel.Text = "FPS: --"

fpsLabel.TextColor3 = Theme.Accent

fpsLabel.TextSize = 12

fpsLabel.Font = Enum.Font.GothamBold

fpsLabel.TextXAlignment =
    Enum.TextXAlignment.Left

fpsLabel.Visible = false

fpsLabel.Parent = screenGui

-- ====================================================================
-- NOTIFICATIONS
-- ====================================================================

local notificationContainer =
    Instance.new("Frame")

notificationContainer.Name =
    "NotificationContainer"

notificationContainer.Size =
    UDim2.new(
        0,
        240,
        1,
        -20
    )

notificationContainer.Position =
    UDim2.new(
        1,
        -250,
        0,
        10
    )

notificationContainer.BackgroundTransparency = 1

notificationContainer.Parent =
    screenGui

local notifList =
    Instance.new("UIListLayout")

notifList.SortOrder =
    Enum.SortOrder.LayoutOrder

notifList.VerticalAlignment =
    Enum.VerticalAlignment.Bottom

notifList.Padding =
    UDim.new(0, 6)

notifList.Parent =
    notificationContainer

local function Notify(titleText, descText)

    local card =
        Instance.new("Frame")

    card.Size =
        UDim2.new(
            1,
            0,
            0,
            48
        )

    card.BackgroundColor3 =
        Theme.Card

    card.BorderSizePixel = 0

    card.Parent =
        notificationContainer

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent = card

    local stroke =
        Instance.new("UIStroke")

    stroke.Thickness = 1

    stroke.Color =
        Theme.Accent

    stroke.Parent = card

    local titleLabel =
        Instance.new("TextLabel")

    titleLabel.Size =
        UDim2.new(
            1,
            -10,
            0,
            18
        )

    titleLabel.Position =
        UDim2.new(
            0,
            8,
            0,
            4
        )

    titleLabel.BackgroundTransparency = 1

    titleLabel.Text = titleText

    titleLabel.TextColor3 =
        Theme.Accent

    titleLabel.TextSize = 11

    titleLabel.Font =
        Enum.Font.GothamBold

    titleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    titleLabel.Parent = card

    local descLabel =
        Instance.new("TextLabel")

    descLabel.Size =
        UDim2.new(
            1,
            -10,
            0,
            18
        )

    descLabel.Position =
        UDim2.new(
            0,
            8,
            0,
            22
        )

    descLabel.BackgroundTransparency = 1

    descLabel.Text = descText

    descLabel.TextColor3 =
        Theme.Text

    descLabel.TextSize = 10

    descLabel.Font =
        Enum.Font.Gotham

    descLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    descLabel.Parent = card

    task.delay(3.5, function()

        if not card.Parent then
            return
        end

        TweenService:Create(
            card,
            TweenInfo.new(0.3),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            titleLabel,
            TweenInfo.new(0.3),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            descLabel,
            TweenInfo.new(0.3),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            stroke,
            TweenInfo.new(0.3),
            {
                Transparency = 1
            }
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

local mainFrame =
    Instance.new("Frame")

mainFrame.Name =
    "MainFrame"

mainFrame.Size =
    UDim2.new(
        0,
        650,
        0,
        460
    )

mainFrame.Position =
    UDim2.new(
        0.5,
        -325,
        0.5,
        -230
    )

mainFrame.BackgroundColor3 =
    Theme.BG

mainFrame.BorderSizePixel = 0

mainFrame.Active = true

mainFrame.Draggable = true

mainFrame.ClipsDescendants = true

mainFrame.Parent =
    screenGui

local mainCorner =
    Instance.new("UICorner")

mainCorner.CornerRadius =
    Theme.CornerRadius

mainCorner.Parent =
    mainFrame

local mainStroke =
    Instance.new("UIStroke")

mainStroke.Thickness = 1.2

mainStroke.Color =
    Color3.fromRGB(
        40,
        42,
        58
    )

mainStroke.Parent =
    mainFrame

-- ====================================================================
-- MOUSE / CAMERA CONTROLLER
-- ====================================================================

local lastFirstPersonState = nil
local lastMenuState = nil

local function ApplyMouseState(force)

    local menuOpen =
        mainFrame.Visible

    local firstPerson =
        IsFirstPerson()

    if not force
        and
        menuOpen == lastMenuState
        and
        firstPerson == lastFirstPersonState
    then
        return
    end

    lastMenuState =
        menuOpen

    lastFirstPersonState =
        firstPerson

    -- ================================================================
    -- MENU ABERTO
    -- ================================================================

    if menuOpen then

        UserInputService.MouseIconEnabled =
            true

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default

        return
    end

    -- ================================================================
    -- MENU FECHADO
    -- ================================================================

    if firstPerson then

        UserInputService.MouseIconEnabled =
            false

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.LockCenter

    else

        UserInputService.MouseIconEnabled =
            true

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default
    end
end

-- ====================================================================
-- HEADER
-- ====================================================================

local header =
    Instance.new("Frame")

header.Name =
    "Header"

header.Size =
    UDim2.new(
        1,
        0,
        0,
        45
    )

header.BackgroundColor3 =
    Theme.Header

header.BorderSizePixel = 0

header.Parent =
    mainFrame

local title =
    Instance.new("TextLabel")

title.Size =
    UDim2.new(
        0,
        350,
        1,
        0
    )

title.Position =
    UDim2.new(
        0,
        15,
        0,
        0
    )

title.BackgroundTransparency = 1

title.Text =
    "VOID // ARCHITECT SUITE v4.4"

title.TextColor3 =
    Theme.Accent

title.TextSize = 13

title.Font =
    Enum.Font.GothamBold

title.TextXAlignment =
    Enum.TextXAlignment.Left

title.Parent =
    header

local closeBtn =
    Instance.new("TextButton")

closeBtn.Size =
    UDim2.new(
        0,
        28,
        0,
        28
    )

closeBtn.Position =
    UDim2.new(
        1,
        -36,
        0.5,
        -14
    )

closeBtn.BackgroundColor3 =
    Color3.fromRGB(
        239,
        68,
        68
    )

closeBtn.BackgroundTransparency =
    0.85

closeBtn.Text = "×"

closeBtn.TextColor3 =
    Color3.fromRGB(
        248,
        113,
        113
    )

closeBtn.TextSize = 18

closeBtn.Font =
    Enum.Font.GothamBold

closeBtn.Parent =
    header

local closeCorner =
    Instance.new("UICorner")

closeCorner.CornerRadius =
    UDim.new(0, 6)

closeCorner.Parent =
    closeBtn

closeBtn.MouseButton1Click:Connect(function()

    mainFrame.Visible = false

    ApplyMouseState(true)
end)

-- ====================================================================
-- SIDEBAR
-- ====================================================================

local sidebar =
    Instance.new("Frame")

sidebar.Name =
    "Sidebar"

sidebar.Size =
    UDim2.new(
        0,
        145,
        1,
        -45
    )

sidebar.Position =
    UDim2.new(
        0,
        0,
        0,
        45
    )

sidebar.BackgroundColor3 =
    Theme.Sidebar

sidebar.BorderSizePixel = 0

sidebar.Parent =
    mainFrame

local sidebarList =
    Instance.new("UIListLayout")

sidebarList.SortOrder =
    Enum.SortOrder.LayoutOrder

sidebarList.Padding =
    UDim.new(0, 4)

sidebarList.Parent =
    sidebar

local sidebarPadding =
    Instance.new("UIPadding")

sidebarPadding.PaddingTop =
    UDim.new(0, 10)

sidebarPadding.PaddingLeft =
    UDim.new(0, 8)

sidebarPadding.PaddingRight =
    UDim.new(0, 8)

sidebarPadding.Parent =
    sidebar

-- ====================================================================
-- CONTENT AREA
-- ====================================================================

local contentArea =
    Instance.new("Frame")

contentArea.Name =
    "ContentArea"

contentArea.Size =
    UDim2.new(
        1,
        -145,
        1,
        -45
    )

contentArea.Position =
    UDim2.new(
        0,
        145,
        0,
        45
    )

contentArea.BackgroundTransparency = 1

contentArea.Parent =
    mainFrame

-- ====================================================================
-- TAB SYSTEM
-- ====================================================================

local Tabs = {}

local function CreateTab(name)

    local tabButton =
        Instance.new("TextButton")

    tabButton.Size =
        UDim2.new(
            1,
            0,
            0,
            32
        )

    tabButton.BackgroundColor3 =
        Theme.Sidebar

    tabButton.BackgroundTransparency =
        1

    tabButton.Text =
        "  " .. name

    tabButton.TextColor3 =
        Theme.SubText

    tabButton.TextSize = 11

    tabButton.Font =
        Enum.Font.GothamMedium

    tabButton.TextXAlignment =
        Enum.TextXAlignment.Left

    tabButton.Parent =
        sidebar

    local tabCorner =
        Instance.new("UICorner")

    tabCorner.CornerRadius =
        UDim.new(0, 6)

    tabCorner.Parent =
        tabButton

    local tabScroll =
        Instance.new("ScrollingFrame")

    tabScroll.Name =
        name .. "Tab"

    tabScroll.Size =
        UDim2.new(
            1,
            -20,
            1,
            -20
        )

    tabScroll.Position =
        UDim2.new(
            0,
            10,
            0,
            10
        )

    tabScroll.BackgroundTransparency = 1

    tabScroll.BorderSizePixel = 0

    tabScroll.ScrollBarThickness = 3

    tabScroll.ScrollBarImageColor3 =
        Theme.Accent

    tabScroll.Visible = false

    tabScroll.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    tabScroll.Parent =
        contentArea

    local listLayout =
        Instance.new("UIListLayout")

    listLayout.SortOrder =
        Enum.SortOrder.LayoutOrder

    listLayout.Padding =
        UDim.new(0, 8)

    listLayout.Parent =
        tabScroll

    listLayout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(function()

        tabScroll.CanvasSize =
            UDim2.new(
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

    table.insert(
        Tabs,
        tabData
    )

    if #Tabs == 1 then

        tabScroll.Visible = true

        tabButton.BackgroundColor3 =
            Theme.Card

        tabButton.BackgroundTransparency = 0

        tabButton.TextColor3 =
            Theme.Accent
    end

    return tabScroll
end

-- ====================================================================
-- TOGGLE BUILDER
-- ====================================================================

local function AddToggle(
    parent,
    titleText,
    descText,
    callback
)

    local card =
        Instance.new("Frame")

    card.Size =
        UDim2.new(
            1,
            -4,
            0,
            48
        )

    card.BackgroundColor3 =
        Theme.Card

    card.BorderSizePixel = 0

    card.Parent =
        parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent =
        card

    local titleLabel =
        Instance.new("TextLabel")

    titleLabel.Size =
        UDim2.new(
            0.7,
            0,
            0,
            18
        )

    titleLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            5
        )

    titleLabel.BackgroundTransparency = 1

    titleLabel.Text =
        titleText

    titleLabel.TextColor3 =
        Theme.Text

    titleLabel.TextSize = 11

    titleLabel.Font =
        Enum.Font.GothamMedium

    titleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    titleLabel.Parent =
        card

    local descLabel =
        Instance.new("TextLabel")

    descLabel.Size =
        UDim2.new(
            0.7,
            0,
            0,
            16
        )

    descLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            23
        )

    descLabel.BackgroundTransparency = 1

    descLabel.Text =
        descText

    descLabel.TextColor3 =
        Theme.SubText

    descLabel.TextSize = 9

    descLabel.Font =
        Enum.Font.Gotham

    descLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    descLabel.Parent =
        card

    local toggleButton =
        Instance.new("TextButton")

    toggleButton.Size =
        UDim2.new(
            0,
            36,
            0,
            18
        )

    toggleButton.Position =
        UDim2.new(
            1,
            -44,
            0.5,
            -9
        )

    toggleButton.BackgroundColor3 =
        Color3.fromRGB(
            40,
            42,
            58
        )

    toggleButton.Text = ""

    toggleButton.Parent =
        card

    local toggleCorner =
        Instance.new("UICorner")

    toggleCorner.CornerRadius =
        UDim.new(1, 0)

    toggleCorner.Parent =
        toggleButton

    local indicator =
        Instance.new("Frame")

    indicator.Size =
        UDim2.new(
            0,
            12,
            0,
            12
        )

    indicator.Position =
        UDim2.new(
            0,
            3,
            0.5,
            -6
        )

    indicator.BackgroundColor3 =
        Color3.fromRGB(
            180,
            180,
            200
        )

    indicator.BorderSizePixel = 0

    indicator.Parent =
        toggleButton

    local indicatorCorner =
        Instance.new("UICorner")

    indicatorCorner.CornerRadius =
        UDim.new(1, 0)

    indicatorCorner.Parent =
        indicator

    local active = false

    toggleButton.MouseButton1Click:Connect(function()

        active = not active

        local targetPosition
        local targetColor

        if active then

            targetPosition =
                UDim2.new(
                    1,
                    -15,
                    0.5,
                    -6
                )

            targetColor =
                Theme.Accent

        else

            targetPosition =
                UDim2.new(
                    0,
                    3,
                    0.5,
                    -6
                )

            targetColor =
                Color3.fromRGB(
                    40,
                    42,
                    58
                )
        end

        TweenService:Create(
            indicator,
            TweenInfo.new(0.2),
            {
                Position = targetPosition
            }
        ):Play()

        TweenService:Create(
            toggleButton,
            TweenInfo.new(0.2),
            {
                BackgroundColor3 =
                    targetColor
            }
        ):Play()

        callback(active)
    end)
end

-- ====================================================================
-- SLIDER BUILDER
-- ====================================================================

local function AddSlider(
    parent,
    titleText,
    minVal,
    maxVal,
    defaultVal,
    callback
)

    local card =
        Instance.new("Frame")

    card.Size =
        UDim2.new(
            1,
            -4,
            0,
            52
        )

    card.BackgroundColor3 =
        Theme.Card

    card.BorderSizePixel = 0

    card.Parent =
        parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent =
        card

    local titleLabel =
        Instance.new("TextLabel")

    titleLabel.Size =
        UDim2.new(
            0.6,
            0,
            0,
            18
        )

    titleLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            5
        )

    titleLabel.BackgroundTransparency = 1

    titleLabel.Text =
        titleText

    titleLabel.TextColor3 =
        Theme.Text

    titleLabel.TextSize = 11

    titleLabel.Font =
        Enum.Font.GothamMedium

    titleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    titleLabel.Parent =
        card

    local input =
        Instance.new("TextBox")

    input.Size =
        UDim2.new(
            0,
            50,
            0,
            20
        )

    input.Position =
        UDim2.new(
            1,
            -60,
            0,
            4
        )

    input.BackgroundColor3 =
        Color3.fromRGB(
            30,
            32,
            44
        )

    input.BorderSizePixel = 0

    input.Text =
        tostring(defaultVal)

    input.TextColor3 =
        Theme.Accent

    input.TextSize = 11

    input.Font =
        Enum.Font.GothamBold

    input.ClearTextOnFocus = false

    input.Parent =
        card

    local inputCorner =
        Instance.new("UICorner")

    inputCorner.CornerRadius =
        UDim.new(0, 4)

    inputCorner.Parent =
        input

    local track =
        Instance.new("Frame")

    track.Size =
        UDim2.new(
            1,
            -20,
            0,
            5
        )

    track.Position =
        UDim2.new(
            0,
            10,
            0,
            34
        )

    track.BackgroundColor3 =
        Color3.fromRGB(
            40,
            42,
            58
        )

    track.BorderSizePixel = 0

    track.Parent =
        card

    local trackCorner =
        Instance.new("UICorner")

    trackCorner.CornerRadius =
        UDim.new(1, 0)

    trackCorner.Parent =
        track

    local initialPercent =
        math.clamp(
            (
                defaultVal -
                minVal
            ) /
            (
                maxVal -
                minVal
            ),
            0,
            1
        )

    local fill =
        Instance.new("Frame")

    fill.Size =
        UDim2.new(
            initialPercent,
            0,
            1,
            0
        )

    fill.BackgroundColor3 =
        Theme.Accent

    fill.BorderSizePixel = 0

    fill.Parent =
        track

    local fillCorner =
        Instance.new("UICorner")

    fillCorner.CornerRadius =
        UDim.new(1, 0)

    fillCorner.Parent =
        fill

    local function SetValue(value)

        local clamped =
            math.clamp(
                value,
                minVal,
                maxVal
            )

        input.Text =
            tostring(clamped)

        local percent =
            (
                clamped -
                minVal
            ) /
            (
                maxVal -
                minVal
            )

        fill.Size =
            UDim2.new(
                percent,
                0,
                1,
                0
            )

        callback(clamped)
    end

    local dragging = false

    local function UpdateFromMouse(inputObject)

        if track.AbsoluteSize.X <= 0 then
            return
        end

        local percentage =
            (
                inputObject.Position.X -
                track.AbsolutePosition.X
            ) /
            track.AbsoluteSize.X

        percentage =
            math.clamp(
                percentage,
                0,
                1
            )

        local value =
            math.floor(
                minVal +
                (
                    maxVal -
                    minVal
                ) *
                percentage
            )

        SetValue(value)
    end

    track.InputBegan:Connect(function(inputObject)

        if inputObject.UserInputType ==
            Enum.UserInputType.MouseButton1
        then

            dragging = true

            UpdateFromMouse(
                inputObject
            )
        end
    end)

    UserInputService.InputChanged:Connect(
        function(inputObject)

            if
                dragging
                and
                inputObject.UserInputType ==
                    Enum.UserInputType.MouseMovement
            then

                UpdateFromMouse(
                    inputObject
                )
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(inputObject)

            if inputObject.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                dragging = false
            end
        end
    )

    input.FocusLost:Connect(function()

        local number =
            tonumber(
                input.Text
            )

        if number then
            SetValue(number)
        else
            SetValue(defaultVal)
        end
    end)
end

-- ====================================================================
-- BUTTON BUILDER
-- ====================================================================

local function AddButton(
    parent,
    titleText,
    buttonText,
    callback
)

    local card =
        Instance.new("Frame")

    card.Size =
        UDim2.new(
            1,
            -4,
            0,
            40
        )

    card.BackgroundColor3 =
        Theme.Card

    card.BorderSizePixel = 0

    card.Parent =
        parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent =
        card

    local titleLabel =
        Instance.new("TextLabel")

    titleLabel.Size =
        UDim2.new(
            0.6,
            0,
            1,
            0
        )

    titleLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            0
        )

    titleLabel.BackgroundTransparency = 1

    titleLabel.Text =
        titleText

    titleLabel.TextColor3 =
        Theme.Text

    titleLabel.TextSize = 11

    titleLabel.Font =
        Enum.Font.GothamMedium

    titleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    titleLabel.Parent =
        card

    local button =
        Instance.new("TextButton")

    button.Size =
        UDim2.new(
            0,
            95,
            0,
            24
        )

    button.Position =
        UDim2.new(
            1,
            -105,
            0.5,
            -12
        )

    button.BackgroundColor3 =
        Theme.Accent

    button.Text =
        buttonText

    button.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    button.TextSize = 10

    button.Font =
        Enum.Font.GothamBold

    button.Parent =
        card

    local buttonCorner =
        Instance.new("UICorner")

    buttonCorner.CornerRadius =
        UDim.new(0, 4)

    buttonCorner.Parent =
        button

    button.MouseButton1Click:Connect(
        callback
    )

    return button
end

-- ====================================================================
-- TEXT BOX
-- ====================================================================

local function AddTextBox(
    parent,
    titleText,
    placeholder,
    callback
)

    local card =
        Instance.new("Frame")

    card.Size =
        UDim2.new(
            1,
            -4,
            0,
            42
        )

    card.BackgroundColor3 =
        Theme.Card

    card.BorderSizePixel = 0

    card.Parent =
        parent

    local corner =
        Instance.new("UICorner")

    corner.CornerRadius =
        UDim.new(0, 6)

    corner.Parent =
        card

    local titleLabel =
        Instance.new("TextLabel")

    titleLabel.Size =
        UDim2.new(
            0.45,
            0,
            1,
            0
        )

    titleLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            0
        )

    titleLabel.BackgroundTransparency = 1

    titleLabel.Text =
        titleText

    titleLabel.TextColor3 =
        Theme.Text

    titleLabel.TextSize = 11

    titleLabel.Font =
        Enum.Font.GothamMedium

    titleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    titleLabel.Parent =
        card

    local textBox =
        Instance.new("TextBox")

    textBox.Size =
        UDim2.new(
            0.5,
            -10,
            0,
            24
        )

    textBox.Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            -12
        )

    textBox.BackgroundColor3 =
        Color3.fromRGB(
            30,
            32,
            44
        )

    textBox.PlaceholderText =
        placeholder

    textBox.Text = ""

    textBox.TextColor3 =
        Theme.Text

    textBox.PlaceholderColor3 =
        Theme.SubText

    textBox.TextSize = 10

    textBox.Font =
        Enum.Font.Gotham

    textBox.Parent =
        card

    local boxCorner =
        Instance.new("UICorner")

    boxCorner.CornerRadius =
        UDim.new(0, 4)

    boxCorner.Parent =
        textBox

    textBox.FocusLost:Connect(
        function(enterPressed)

            if enterPressed then
                callback(textBox.Text)
            end
        end
    )
end

-- ====================================================================
-- TABS
-- ====================================================================

local tabPlayer =
    CreateTab("Jogador")

local tabMovement =
    CreateTab("Movimento")

local tabVisuals =
    CreateTab("Visual & ESP")

local tabCombat =
    CreateTab("Combate")

local tabWaypoints =
    CreateTab("Waypoints")

local tabServer =
    CreateTab("Servidor")

local tabThemes =
    CreateTab("Configurações")

-- ====================================================================
-- PLAYER TAB
-- ====================================================================

AddToggle(
    tabPlayer,
    "Super Velocidade",
    "Aumenta a velocidade.",
    function(enabled)
        State.SpeedEnabled = enabled
    end
)

AddSlider(
    tabPlayer,
    "Velocidade",
    16,
    400,
    State.WalkSpeed,
    function(value)
        State.WalkSpeed = value
    end
)

AddToggle(
    tabPlayer,
    "Super Pulo",
    "Aumenta a força do salto.",
    function(enabled)
        State.JumpEnabled = enabled
    end
)

AddSlider(
    tabPlayer,
    "Força do Pulo",
    50,
    500,
    State.JumpPower,
    function(value)
        State.JumpPower = value
    end
)

AddToggle(
    tabPlayer,
    "Pulo Infinito",
    "Permite pular no ar.",
    function(enabled)
        State.InfJump = enabled
    end
)

AddToggle(
    tabPlayer,
    "Auto Bhop",
    "Pula automaticamente.",
    function(enabled)
        State.BhopEnabled = enabled
    end
)

AddToggle(
    tabPlayer,
    "God Mode Local",
    "Mantém sua vida cheia.",
    function(enabled)
        State.GodMode = enabled
    end
)

AddToggle(
    tabPlayer,
    "Ajustar HipHeight",
    "Altera sua altura.",
    function(enabled)
        State.HipHeightEnabled = enabled
    end
)

AddSlider(
    tabPlayer,
    "HipHeight",
    0,
    30,
    State.HipHeightValue,
    function(value)
        State.HipHeightValue = value
    end
)

AddToggle(
    tabPlayer,
    "Click Teleport",
    "Ctrl + clique para teleportar.",
    function(enabled)
        State.ClickTP = enabled
    end
)

AddToggle(
    tabPlayer,
    "Infinite Zoom",
    "Aumenta o zoom máximo.",
    function(enabled)

        State.InfiniteZoom = enabled

        if enabled then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance

        else

            LocalPlayer.CameraMaxZoomDistance =
                State.OriginalZoom
        end
    end
)

AddSlider(
    tabPlayer,
    "Distância da Câmera",
    16,
    1000,
    State.ZoomDistance,
    function(value)

        State.ZoomDistance = value

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                value
        end
    end
)

AddToggle(
    tabPlayer,
    "Platform Stand",
    "Estado físico livre.",
    function(enabled)
        State.PlatformStand = enabled
    end
)

AddButton(
    tabPlayer,
    "Resetar Personagem",
    "Reset",
    function()

        local character =
            LocalPlayer.Character

        local humanoid =
            character and
            character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then
            humanoid.Health = 0
        end
    end
)

-- ====================================================================
-- MOVEMENT TAB
-- ====================================================================

AddToggle(
    tabMovement,
    "Modo Voo",
    "Movimento livre.",
    function(enabled)
        State.FlyEnabled = enabled
    end
)

AddSlider(
    tabMovement,
    "Velocidade de Voo",
    20,
    350,
    State.FlySpeed,
    function(value)
        State.FlySpeed = value
    end
)

AddToggle(
    tabMovement,
    "Noclip",
    "Atravessa objetos.",
    function(enabled)
        State.NoclipEnabled = enabled
    end
)

AddToggle(
    tabMovement,
    "Gravidade Baixa",
    "Altera a gravidade.",
    function(enabled)

        State.LowGravity = enabled

        if not enabled then
            workspace.Gravity =
                State.OriginalGravity
        end
    end
)

AddSlider(
    tabMovement,
    "Gravidade",
    0,
    196,
    State.GravityValue,
    function(value)
        State.GravityValue = value
    end
)

AddToggle(
    tabMovement,
    "Blink",
    "Prende o personagem.",
    function(enabled)
        State.BlinkEnabled = enabled
    end
)

AddToggle(
    tabMovement,
    "Spinbot",
    "Rotação contínua.",
    function(enabled)
        State.SpinbotEnabled = enabled
    end
)

AddSlider(
    tabMovement,
    "Velocidade de Rotação",
    1,
    100,
    State.SpinSpeed,
    function(value)
        State.SpinSpeed = value
    end
)

AddToggle(
    tabMovement,
    "Anti-Fling",
    "Reduz velocidades físicas extremas.",
    function(enabled)
        State.AntiFling = enabled
    end
)

-- ====================================================================
-- VISUAL TAB
-- ====================================================================

AddToggle(
    tabVisuals,
    "ESP Master Switch",
    "Ativa o ESP.",
    function(enabled)
        State.ESPEnabled = enabled
    end
)

AddToggle(
    tabVisuals,
    "Highlight Box",
    "Destaca jogadores.",
    function(enabled)
        State.ESPBoxes = enabled
    end
)

AddToggle(
    tabVisuals,
    "ESP Nomes & Distância",
    "Mostra nome, HP e distância.",
    function(enabled)
        State.ESPNames = enabled
    end
)

AddToggle(
    tabVisuals,
    "ESP Tracers",
    "Linhas até os jogadores.",
    function(enabled)
        State.ESPTracers = enabled
    end
)

AddToggle(
    tabVisuals,
    "Fullbright",
    "Ilumina o mapa.",
    function(enabled)

        State.Fullbright = enabled

        if not enabled then

            Lighting.Ambient =
                State.OriginalAmbient

            Lighting.Brightness =
                State.OriginalBrightness
        end
    end
)

AddToggle(
    tabVisuals,
    "Sem Névoa",
    "Remove fog.",
    function(enabled)

        State.NoFog = enabled

        if not enabled then

            Lighting.FogEnd =
                State.OriginalFogEnd
        end
    end
)

AddToggle(
    tabVisuals,
    "Crosshair",
    "Mira fixa.",
    function(enabled)
        State.CrosshairEnabled = enabled
    end
)

AddToggle(
    tabVisuals,
    "FOV Customizado",
    "Altera o campo de visão.",
    function(enabled)

        State.FOVEnabled = enabled

        if not enabled then

            Camera.FieldOfView =
                State.OriginalFieldOfView
        end
    end
)

AddSlider(
    tabVisuals,
    "Ângulo FOV",
    70,
    130,
    State.FOVValue,
    function(value)
        State.FOVValue = value
    end
)

AddToggle(
    tabVisuals,
    "FPS Counter",
    "Mostra FPS.",
    function(enabled)

        State.FPSCounter = enabled

        fpsLabel.Visible = enabled
    end
)

-- ====================================================================
-- COMBAT TAB
-- ====================================================================

AddToggle(
    tabCombat,
    "Aimbot",
    "Seleciona o alvo mais próximo.",
    function(enabled)

        State.AimbotEnabled = enabled

        Notify(
            "Aimbot",
            enabled and
                "Ativado" or
                "Desativado"
        )
    end
)

AddToggle(
    tabCombat,
    "Aimbot Hold Mode",
    "Só ativa enquanto segura a tecla.",
    function(enabled)
        State.AimbotHold = enabled
    end
)

local aimKeyButton

aimKeyButton =
    AddButton(
        tabCombat,
        "Tecla do Aimbot Hold",
        State.AimbotKey.Name,
        function()

            ListeningForKey = "AIM"

            aimKeyButton.Text =
                "Pressione..."
        end
    )

AddSlider(
    tabCombat,
    "Suavidade do Aimbot",
    1,
    10,
    math.floor(
        State.AimbotSmoothness * 10
    ),
    function(value)

        State.AimbotSmoothness =
            value / 10
    end
)

AddToggle(
    tabCombat,
    "Mostrar Círculo FOV",
    "Mostra o alcance.",
    function(enabled)
        State.ShowFOVCircle = enabled
    end
)

AddSlider(
    tabCombat,
    "Raio do FOV Aim",
    50,
    400,
    State.AimbotFOV,
    function(value)
        State.AimbotFOV = value
    end
)

AddButton(
    tabCombat,
    "Mudar Alvo",
    "Cabeça/Torso",
    function()

        if State.AimPart == "Head" then

            State.AimPart =
                "HumanoidRootPart"

            Notify(
                "Aimbot",
                "Alvo: TORSO"
            )

        else

            State.AimPart =
                "Head"

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
    "Ação automática sobre alvo.",
    function(enabled)
        State.Triggerbot = enabled
    end
)

AddToggle(
    tabCombat,
    "Hitbox Extender",
    "Aumenta a área do alvo.",
    function(enabled)
        State.HitboxEnabled = enabled
    end
)

AddSlider(
    tabCombat,
    "Tamanho da Hitbox",
    2,
    40,
    State.HitboxSize,
    function(value)
        State.HitboxSize = value
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
            and LocalPlayer.Character:
                FindFirstChild(
                    "HumanoidRootPart"
                )
        then

            local position =
                LocalPlayer.Character
                    .HumanoidRootPart
                    .Position

            table.insert(
                State.Waypoints,
                {
                    Name = text,
                    Position = position
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
    "Último Waypoint",
    "Ir",
    function()

        if #State.Waypoints == 0 then

            Notify(
                "Waypoint",
                "Nenhum waypoint!"
            )

            return
        end

        local waypoint =
            State.Waypoints[
                #State.Waypoints
            ]

        local character =
            LocalPlayer.Character

        if
            character
            and character:
                FindFirstChild(
                    "HumanoidRootPart"
                )
        then

            character.HumanoidRootPart.CFrame =
                CFrame.new(
                    waypoint.Position +
                    Vector3.new(
                        0,
                        3,
                        0
                    )
                )

            Notify(
                "Waypoint",
                "Teleportado para " ..
                    waypoint.Name
            )
        end
    end
)

AddButton(
    tabWaypoints,
    "Limpar Waypoints",
    "Limpar",
    function()

        State.Waypoints = {}

        Notify(
            "Waypoints",
            "Lista limpa."
        )
    end
)

-- ====================================================================
-- SERVER TAB
-- ====================================================================

AddToggle(
    tabServer,
    "Anti-AFK",
    "Evita desconexão.",
    function(enabled)
        State.AntiAFK = enabled
    end
)

AddToggle(
    tabServer,
    "Forçar Shift Lock",
    "Ativa Shift Lock.",
    function(enabled)

        State.ShiftLockOverride =
            enabled

        pcall(function()

            LocalPlayer.DevEnableMouseLock =
                enabled
        end)
    end
)

AddButton(
    tabServer,
    "Reconectar",
    "Rejoin",
    function()

        Notify(
            "Servidor",
            "Reconectando..."
        )

        TeleportService:
            TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )
    end
)

AddButton(
    tabServer,
    "Trocar Servidor",
    "Hop",
    function()

        Notify(
            "Servidor",
            "Trocando..."
        )

        TeleportService:
            Teleport(
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
                tostring(
                    game.JobId
                )
            )

            Notify(
                "Servidor",
                "JobID copiado!"
            )

        else

            Notify(
                "Servidor",
                "Clipboard indisponível."
            )
        end
    end
)

-- ====================================================================
-- CONFIG TAB
-- ====================================================================

local panelKeyButton

panelKeyButton =
    AddButton(
        tabThemes,
        "Atalho do Painel",
        TOGGLE_KEY.Name,
        function()

            ListeningForKey = "PANEL"

            panelKeyButton.Text =
                "Pressione..."
        end
    )

-- ====================================================================
-- THEMES
-- ====================================================================

local function CreateThemePicker(
    parent,
    name,
    color
)

    AddButton(
        parent,
        "Tema: " .. name,
        "Aplicar",
        function()

            Theme.Accent =
                color

            title.TextColor3 =
                color

            fovCircle.Color =
                color

            fpsLabel.TextColor3 =
                color

            for _, tab in pairs(Tabs) do

                tab.Scroll.ScrollBarImageColor3 =
                    color

                if tab.Scroll.Visible then

                    tab.Button.TextColor3 =
                        color
                end
            end

            Notify(
                "Tema",
                "Aplicado: " .. name
            )
        end
    )
end

CreateThemePicker(
    tabThemes,
    "Roxo Neon",
    Color3.fromRGB(
        138,
        92,
        246
    )
)

CreateThemePicker(
    tabThemes,
    "Azul Cyber",
    Color3.fromRGB(
        14,
        165,
        233
    )
)

CreateThemePicker(
    tabThemes,
    "Verde Matrix",
    Color3.fromRGB(
        34,
        197,
        94
    )
)

CreateThemePicker(
    tabThemes,
    "Vermelho Rubro",
    Color3.fromRGB(
        239,
        68,
        68
    )
)

CreateThemePicker(
    tabThemes,
    "Amarelo Ouro",
    Color3.fromRGB(
        234,
        179,
        8
    )
)

-- ====================================================================
-- INPUT HANDLER
-- ====================================================================

UserInputService.InputBegan:Connect(
    function(input, gameProcessed)

        -- ============================================================
        -- KEYBIND LISTENER
        -- ============================================================

        if ListeningForKey then

            if input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                if ListeningForKey ==
                    "PANEL"
                then

                    TOGGLE_KEY =
                        input.KeyCode

                    panelKeyButton.Text =
                        input.KeyCode.Name

                    Notify(
                        "Atalho",
                        "Painel: " ..
                            input.KeyCode.Name
                    )

                elseif ListeningForKey ==
                    "AIM"
                then

                    State.AimbotKey =
                        input.KeyCode

                    aimKeyButton.Text =
                        input.KeyCode.Name

                    Notify(
                        "Aimbot",
                        "Hold: " ..
                            input.KeyCode.Name
                    )
                end

                ListeningForKey = nil
            end

            return
        end

        -- ============================================================
        -- PANEL TOGGLE
        -- ============================================================

        if
            not gameProcessed
            and
            input.KeyCode ==
                TOGGLE_KEY
        then

            mainFrame.Visible =
                not mainFrame.Visible

            ApplyMouseState(true)

            return
        end
    end
)

-- ====================================================================
-- CLICK TELEPORT
-- ====================================================================

Mouse.Button1Down:Connect(function()

    if not State.ClickTP then
        return
    end

    if not UserInputService:
        IsKeyDown(
            Enum.KeyCode.LeftControl
        )
    then
        return
    end

    local character =
        LocalPlayer.Character

    local root =
        character and
        character:FindFirstChild(
            "HumanoidRootPart"
        )

    if
        root
        and Mouse.Hit
    then

        root.CFrame =
            Mouse.Hit +
            Vector3.new(
                0,
                3,
                0
            )
    end
end)

-- ====================================================================
-- ANTI-AFK
-- ====================================================================

local VirtualUser =
    game:GetService(
        "VirtualUser"
    )

LocalPlayer.Idled:Connect(function()

    if not State.AntiAFK then
        return
    end

    VirtualUser:Button2Down(
        Vector2.new(
            0,
            0
        ),
        Camera.CFrame
    )

    task.wait(1)

    VirtualUser:Button2Up(
        Vector2.new(
            0,
            0
        ),
        Camera.CFrame
    )
end)

-- ====================================================================
-- INFINITE JUMP
-- ====================================================================

UserInputService.JumpRequest:Connect(
    function()

        if not State.InfJump then
            return
        end

        local character =
            LocalPlayer.Character

        local humanoid =
            character and
            character:FindFirstChildOfClass(
                "Humanoid"
            )

        if humanoid then

            humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
)

-- ====================================================================
-- ESP
-- ====================================================================

local espCache = {}

local function CleanupESP(player)

    local cache =
        espCache[player]

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

    espCache[player] = nil
end

-- ====================================================================
-- FPS SYSTEM
-- ====================================================================

local fpsFrames = 0
local fpsTimer = os.clock()

RunService.RenderStepped:Connect(
    function()

        fpsFrames += 1

        local now = os.clock()

        if now - fpsTimer >= 1 then

            fpsLabel.Text =
                "FPS: " ..
                tostring(
                    fpsFrames
                )

            fpsFrames = 0

            fpsTimer = now
        end
    end
)

-- ====================================================================
-- CAMERA STATE MONITOR
-- ====================================================================

RunService.RenderStepped:Connect(
    function()

        RefreshCamera()

        -- Só aplica quando o estado mudou.
        ApplyMouseState(false)
    end
)

-- ====================================================================
-- MAIN LOOP
-- ====================================================================

RunService.RenderStepped:Connect(
    function()

        RefreshCamera()

        local character =
            LocalPlayer.Character

        local humanoid =
            character and
            character:FindFirstChildOfClass(
                "Humanoid"
            )

        local root =
            character and
            character:FindFirstChild(
                "HumanoidRootPart"
            )

        -- ============================================================
        -- PLAYER
        -- ============================================================

        if humanoid then

            if State.SpeedEnabled then

                humanoid.WalkSpeed =
                    State.WalkSpeed
            end

            if State.JumpEnabled then

                humanoid.UseJumpPower =
                    true

                humanoid.JumpPower =
                    State.JumpPower
            end

            if State.GodMode then

                humanoid.Health =
                    humanoid.MaxHealth
            end

            if State.HipHeightEnabled then

                humanoid.HipHeight =
                    State.HipHeightValue
            end

            humanoid.PlatformStand =
                State.PlatformStand

            if
                State.BhopEnabled
                and
                humanoid.FloorMaterial ~=
                    Enum.Material.Air
                and
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.Space
                    )
            then

                humanoid:ChangeState(
                    Enum.HumanoidStateType.Jumping
                )
            end
        end

        -- ============================================================
        -- ZOOM
        -- ============================================================

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance
        end

        -- ============================================================
        -- GRAVITY
        -- ============================================================

        if State.LowGravity then

            workspace.Gravity =
                State.GravityValue
        end

        -- ============================================================
        -- FLY
        -- ============================================================

        if
            State.FlyEnabled
            and root
        then

            local direction =
                Vector3.zero

            if
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.W
                    )
            then

                direction +=
                    Camera.CFrame.LookVector
            end

            if
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.S
                    )
            then

                direction -=
                    Camera.CFrame.LookVector
            end

            if
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.A
                    )
            then

                direction -=
                    Camera.CFrame.RightVector
            end

            if
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.D
                    )
            then

                direction +=
                    Camera.CFrame.RightVector
            end

            if
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.Space
                    )
            then

                direction +=
                    Vector3.new(
                        0,
                        1,
                        0
                    )
            end

            if
                UserInputService:
                    IsKeyDown(
                        Enum.KeyCode.LeftShift
                    )
            then

                direction -=
                    Vector3.new(
                        0,
                        1,
                        0
                    )
            end

            root.Velocity =
                direction *
                State.FlySpeed

            root.RotVelocity =
                Vector3.zero
        end

        -- ============================================================
        -- ANTI FLING
        -- ============================================================

        if
            State.AntiFling
            and root
            and not State.FlyEnabled
        then

            if
                root.AssemblyLinearVelocity.Magnitude >
                    150
            then

                root.AssemblyLinearVelocity =
                    Vector3.zero
            end

            if
                root.AssemblyAngularVelocity.Magnitude >
                    100
            then

                root.AssemblyAngularVelocity =
                    Vector3.zero
            end
        end

        -- ============================================================
        -- SPINBOT
        -- ============================================================

        if
            State.SpinbotEnabled
            and root
        then

            root.CFrame =
                root.CFrame *
                CFrame.Angles(
                    0,
                    math.rad(
                        State.SpinSpeed
                    ),
                    0
                )
        end

        -- ============================================================
        -- BLINK
        -- ============================================================

        if
            State.BlinkEnabled
            and root
        then

            root.Anchored = true

        elseif
            root
            and
            not State.BlinkEnabled
            and
            root.Anchored
        then

            root.Anchored = false
        end

        -- ============================================================
        -- NOCLIP
        -- ============================================================

        if
            State.NoclipEnabled
            and
            character
        then

            for _, part in ipairs(
                character:GetDescendants()
            ) do

                if part:IsA("BasePart") then

                    part.CanCollide = false
                end
            end
        end

        -- ============================================================
        -- FULLBRIGHT
        -- ============================================================

        if State.Fullbright then

            Lighting.Ambient =
                Color3.fromRGB(
                    255,
                    255,
                    255
                )

            Lighting.Brightness = 2
        end

        -- ============================================================
        -- NO FOG
        -- ============================================================

        if State.NoFog then

            Lighting.FogEnd =
                1e6
        end

        -- ============================================================
        -- FOV
        -- ============================================================

        if State.FOVEnabled then

            Camera.FieldOfView =
                State.FOVValue
        end

        -- ============================================================
        -- FOV CIRCLE
        -- ============================================================

        if State.ShowFOVCircle then

            fovCircle.Position =
                GetAimScreenPosition()

            fovCircle.Radius =
                State.AimbotFOV

            fovCircle.Visible = true

        else

            fovCircle.Visible = false
        end

        -- ============================================================
        -- CROSSHAIR
        -- ============================================================

        if State.CrosshairEnabled then

            local center =
                Vector2.new(
                    Camera.ViewportSize.X / 2,
                    Camera.ViewportSize.Y / 2
                )

            local length = 8

            crosshairLines.Top.From =
                center -
                Vector2.new(
                    0,
                    3
                )

            crosshairLines.Top.To =
                center -
                Vector2.new(
                    0,
                    3 + length
                )

            crosshairLines.Bottom.From =
                center +
                Vector2.new(
                    0,
                    3
                )

            crosshairLines.Bottom.To =
                center +
                Vector2.new(
                    0,
                    3 + length
                )

            crosshairLines.Left.From =
                center -
                Vector2.new(
                    3,
                    0
                )

            crosshairLines.Left.To =
                center -
                Vector2.new(
                    3 + length,
                    0
                )

            crosshairLines.Right.From =
                center +
                Vector2.new(
                    3,
                    0
                )

            crosshairLines.Right.To =
                center +
                Vector2.new(
                    3 + length,
                    0
                )

            for _, line in pairs(
                crosshairLines
            ) do

                line.Visible = true
            end

        else

            for _, line in pairs(
                crosshairLines
            ) do

                line.Visible = false
            end
        end

        -- ============================================================
        -- TRIGGERBOT
        -- ============================================================

        if
            State.Triggerbot
            and
            Mouse.Target
            and
            mouse1click
        then

            local targetCharacter =
                Mouse.Target:
                    FindFirstAncestorOfClass(
                        "Model"
                    )

            if
                targetCharacter
                and
                targetCharacter:
                    FindFirstChildOfClass(
                        "Humanoid"
                    )
                and
                Players:
                    GetPlayerFromCharacter(
                        targetCharacter
                    ) ~= LocalPlayer
            then

                mouse1click()
            end
        end

        -- ============================================================
        -- ESP / HITBOX
        -- ============================================================

        for _, player in ipairs(
            Players:GetPlayers()
        ) do

            if
                player ~= LocalPlayer
                and
                player.Character
            then

                local targetCharacter =
                    player.Character

                local targetRoot =
                    targetCharacter:
                        FindFirstChild(
                            "HumanoidRootPart"
                        )

                local targetHumanoid =
                    targetCharacter:
                        FindFirstChildOfClass(
                            "Humanoid"
                        )

                -- ====================================================
                -- HITBOX
                -- ====================================================

                if targetRoot then

                    if State.HitboxEnabled then

                        targetRoot.Size =
                            Vector3.new(
                                State.HitboxSize,
                                State.HitboxSize,
                                State.HitboxSize
                            )

                        targetRoot.Transparency =
                            0.7

                        targetRoot.Color =
                            Theme.Accent

                        targetRoot.Material =
                            Enum.Material.ForceField

                        targetRoot.CanCollide =
                            false

                    else

                        targetRoot.Size =
                            Vector3.new(
                                2,
                                2,
                                1
                            )

                        targetRoot.Transparency =
                            1
                    end
                end

                -- ====================================================
                -- HIGHLIGHT
                -- ====================================================

                local highlight =
                    targetCharacter:
                        FindFirstChild(
                            "ArchitectESP"
                        )

                if
                    State.ESPEnabled
                    and
                    State.ESPBoxes
                then

                    if not highlight then

                        highlight =
                            Instance.new(
                                "Highlight"
                            )

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
                            targetCharacter

                    else

                        highlight.FillColor =
                            Theme.Accent
                    end

                else

                    if highlight then
                        highlight:Destroy()
                    end
                end

                -- ====================================================
                -- DRAWING
                -- ====================================================

                if
                    State.ESPEnabled
                    and
                    targetRoot
                    and
                    targetHumanoid
                    and
                    targetHumanoid.Health > 0
                then

                    local screenPosition,
                        onScreen =
                        Camera:
                            WorldToViewportPoint(
                                targetRoot.Position
                            )

                    if onScreen then

                        if not espCache[player] then

                            espCache[player] = {

                                Text =
                                    Drawing.new(
                                        "Text"
                                    ),

                                Tracer =
                                    Drawing.new(
                                        "Line"
                                    )
                            }

                            espCache[player]
                                .Text
                                .Size = 13

                            espCache[player]
                                .Text
                                .Center = true

                            espCache[player]
                                .Text
                                .Outline = true

                            espCache[player]
                                .Text
                                .Color =
                                Color3.fromRGB(
                                    255,
                                    255,
                                    255
                                )

                            espCache[player]
                                .Tracer
                                .Thickness = 1

                            espCache[player]
                                .Tracer
                                .Color =
                                Theme.Accent
                        end

                        local cache =
                            espCache[player]

                        if State.ESPNames then

                            local distance =
                                math.floor(
                                    (
                                        targetRoot.Position -
                                        Camera.CFrame.Position
                                    ).Magnitude
                                )

                            cache.Text.Position =
                                Vector2.new(
                                    screenPosition.X,
                                    screenPosition.Y - 25
                                )

                            cache.Text.Text =
                                string.format(
                                    "%s [%d HP | %dm]",
                                    player.Name,
                                    math.floor(
                                        targetHumanoid.Health
                                    ),
                                    distance
                                )

                            cache.Text.Visible =
                                true

                        else

                            cache.Text.Visible =
                                false
                        end

                        if State.ESPTracers then

                            cache.Tracer.From =
                                Vector2.new(
                                    Camera.ViewportSize.X / 2,
                                    Camera.ViewportSize.Y
                                )

                            cache.Tracer.To =
                                Vector2.new(
                                    screenPosition.X,
                                    screenPosition.Y
                                )

                            cache.Tracer.Color =
                                Theme.Accent

                            cache.Tracer.Visible =
                                true

                        else

                            cache.Tracer.Visible =
                                false
                        end

                    else

                        if espCache[player] then

                            espCache[player]
                                .Text
                                .Visible = false

                            espCache[player]
                                .Tracer
                                .Visible = false
                        end
                    end

                else

                    CleanupESP(player)
                end

            else

                CleanupESP(player)
            end
        end

        -- ============================================================
        -- AIMBOT
        -- ============================================================

        local aimbotActive =
            State.AimbotEnabled

        if
            State.AimbotEnabled
            and
            State.AimbotHold
        then

            aimbotActive =
                UserInputService:
                    IsKeyDown(
                        State.AimbotKey
                    )
        end

        if aimbotActive then

            local target = nil

            local smallestDistance =
                State.AimbotFOV

            local aimPosition =
                GetAimScreenPosition()

            for _, player in ipairs(
                Players:GetPlayers()
            ) do

                if
                    player ~= LocalPlayer
                    and
                    player.Character
                then

                    local targetPart =
                        player.Character:
                            FindFirstChild(
                                State.AimPart
                            )

                    local targetHumanoid =
                        player.Character:
                            FindFirstChildOfClass(
                                "Humanoid"
                            )

                    if
                        targetPart
                        and
                        targetHumanoid
                        and
                        targetHumanoid.Health > 0
                    then

                        local screenPosition,
                            onScreen =
                            Camera:
                                WorldToViewportPoint(
                                    targetPart.Position
                                )

                        if onScreen then

                            local distance =
                                (
                                    Vector2.new(
                                        screenPosition.X,
                                        screenPosition.Y
                                    ) -
                                    aimPosition
                                ).Magnitude

                            if
                                distance <
                                smallestDistance
                            then

                                smallestDistance =
                                    distance

                                target =
                                    targetPart
                            end
                        end
                    end
                end
            end

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
    end
)

-- ====================================================================
-- PLAYER REMOVING
-- ====================================================================

Players.PlayerRemoving:Connect(
    function(player)

        CleanupESP(player)
    end
)

-- ====================================================================
-- CHARACTER ADDED
-- ====================================================================

LocalPlayer.CharacterAdded:Connect(
    function()

        task.wait(1)

        RefreshCamera()

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance
        end

        ApplyMouseState(true)
    end
)

-- ====================================================================
-- INITIAL STATE
-- ====================================================================

mainFrame.Visible = true

ApplyMouseState(true)

Notify(
    "VOID ARCHITECT",
    "v4.4 inicializada!"
)
```
