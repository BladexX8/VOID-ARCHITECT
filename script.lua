```lua
--[[
====================================================================
VOID ARCHITECT // ULTIMATE CLIENT SUITE v4.7
CLIENT-SIDE / TEST ENVIRONMENT

CORREÇÕES:
- Aimbot em primeira pessoa
- Aimbot em terceira pessoa
- Aimbot executado após a câmera
- FOV usa centro em primeira pessoa
- FOV usa mouse em terceira pessoa
- Mouse livre com painel aberto
- Mouse escondido somente em primeira pessoa quando fechado
- Mouse livre em terceira pessoa quando fechado
- Aimbot Hold Mode
- Keybind configurável
- ESP
- Hitbox
- Fly
- Noclip
- Spin
- Blink
- Anti-Fling
- Infinite Zoom
- Fullbright
- No Fog
- Crosshair
- FPS Counter
- Waypoints
- Anti-AFK
====================================================================
]]

--==================================================================
-- SERVICES
--==================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

--==================================================================
-- REFERENCES
--==================================================================

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

local Camera = workspace.CurrentCamera

--==================================================================
-- CLEANUP
--==================================================================

local OldUI = PlayerGui:FindFirstChild("ArchitectSuiteUI")

if OldUI then
    OldUI:Destroy()
end

pcall(function()
    RunService:UnbindFromRenderStep("ArchitectAimbot")
end)

--==================================================================
-- CONFIG
--==================================================================

local TOGGLE_KEY = Enum.KeyCode.RightControl
local ListeningFor = nil

local Theme = {
    BG = Color3.fromRGB(10, 11, 16),
    Header = Color3.fromRGB(16, 17, 24),
    Sidebar = Color3.fromRGB(14, 15, 21),
    Card = Color3.fromRGB(20, 22, 30),

    Accent = Color3.fromRGB(138, 92, 246),

    Text = Color3.fromRGB(243, 244, 246),
    SubText = Color3.fromRGB(156, 163, 175)
}

--==================================================================
-- STATE
--==================================================================

local State = {

    -- PLAYER
    SpeedEnabled = false,
    WalkSpeed = 120,

    JumpEnabled = false,
    JumpPower = 150,

    InfJump = false,
    BhopEnabled = false,

    GodMode = false,

    ClickTP = false,

    HipHeightEnabled = false,
    HipHeightValue = 2,

    InfiniteZoom = false,
    ZoomDistance = 500,

    PlatformStand = false,

    -- MOVEMENT
    FlyEnabled = false,
    FlySpeed = 80,

    NoclipEnabled = false,

    LowGravity = false,
    GravityValue = 50,

    BlinkEnabled = false,

    SpinbotEnabled = false,
    SpinSpeed = 20,

    AntiFling = false,

    -- VISUAL
    ESPEnabled = false,
    ESPBoxes = true,
    ESPNames = true,
    ESPTracers = false,

    Fullbright = false,
    NoFog = false,

    FOVEnabled = false,
    FOVValue = 90,

    CrosshairEnabled = false,

    FPSCounter = false,

    -- COMBAT
    AimbotEnabled = false,
    AimbotHold = false,
    AimbotKey = Enum.KeyCode.LeftAlt,

    AimbotSmoothness = 0.2,
    AimbotFOV = 150,

    ShowFOVCircle = false,

    AimPart = "Head",

    Triggerbot = false,

    HitboxEnabled = false,
    HitboxSize = 10,

    -- UTILITY
    AntiAFK = true,

    Waypoints = {},

    -- ORIGINAL
    OriginalGravity = workspace.Gravity,
    OriginalFogEnd = Lighting.FogEnd,
    OriginalAmbient = Lighting.Ambient,
    OriginalBrightness = Lighting.Brightness,
    OriginalFOV = Camera.FieldOfView,
    OriginalZoom = LocalPlayer.CameraMaxZoomDistance
}

--==================================================================
-- CAMERA HELPERS
--==================================================================

local function RefreshCamera()
    Camera = workspace.CurrentCamera or Camera
end

local function IsFirstPerson()
    RefreshCamera()

    local Character = LocalPlayer.Character
    local Head = Character and Character:FindFirstChild("Head")

    if not Head or not Camera then
        return false
    end

    return (
        Camera.CFrame.Position - Head.Position
    ).Magnitude < 1.25
end

local function GetAimPosition()
    RefreshCamera()

    if IsFirstPerson() then
        return Vector2.new(
            Camera.ViewportSize.X / 2,
            Camera.ViewportSize.Y / 2
        )
    end

    return UserInputService:GetMouseLocation()
end

--==================================================================
-- DRAWING
--==================================================================

local FOVCircle = Drawing.new("Circle")

FOVCircle.Thickness = 1.5
FOVCircle.Color = Theme.Accent
FOVCircle.Filled = false
FOVCircle.Transparency = 1
FOVCircle.NumSides = 64
FOVCircle.Visible = false

local Crosshair = {
    Top = Drawing.new("Line"),
    Bottom = Drawing.new("Line"),
    Left = Drawing.new("Line"),
    Right = Drawing.new("Line")
}

for _, Line in pairs(Crosshair) do
    Line.Color = Color3.fromRGB(255, 255, 255)
    Line.Thickness = 1.5
    Line.Transparency = 0.8
    Line.Visible = false
end

--==================================================================
-- GUI
--==================================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "ArchitectSuiteUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==================================================================
-- FPS LABEL
--==================================================================

local FPSLabel = Instance.new("TextLabel")

FPSLabel.Size = UDim2.new(0, 140, 0, 25)
FPSLabel.Position = UDim2.new(0, 10, 0, 10)
FPSLabel.BackgroundTransparency = 1
FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Theme.Accent
FPSLabel.TextSize = 12
FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.Visible = false
FPSLabel.Parent = ScreenGui

--==================================================================
-- NOTIFICATIONS
--==================================================================

local NotificationContainer = Instance.new("Frame")

NotificationContainer.Size =
    UDim2.new(
        0,
        240,
        1,
        -20
    )

NotificationContainer.Position =
    UDim2.new(
        1,
        -250,
        0,
        10
    )

NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local NotificationLayout =
    Instance.new("UIListLayout")

NotificationLayout.SortOrder =
    Enum.SortOrder.LayoutOrder

NotificationLayout.VerticalAlignment =
    Enum.VerticalAlignment.Bottom

NotificationLayout.Padding =
    UDim.new(0, 6)

NotificationLayout.Parent =
    NotificationContainer

local function Notify(TitleText, DescriptionText)

    local Card = Instance.new("Frame")

    Card.Size =
        UDim2.new(
            1,
            0,
            0,
            48
        )

    Card.BackgroundColor3 =
        Theme.Card

    Card.BorderSizePixel = 0

    Card.Parent =
        NotificationContainer

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Card

    local Stroke = Instance.new("UIStroke")
    Stroke.Thickness = 1
    Stroke.Color = Theme.Accent
    Stroke.Parent = Card

    local Title = Instance.new("TextLabel")

    Title.Size =
        UDim2.new(
            1,
            -10,
            0,
            18
        )

    Title.Position =
        UDim2.new(
            0,
            8,
            0,
            4
        )

    Title.BackgroundTransparency = 1
    Title.Text = TitleText
    Title.TextColor3 = Theme.Accent
    Title.TextSize = 11
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = Card

    local Description = Instance.new("TextLabel")

    Description.Size =
        UDim2.new(
            1,
            -10,
            0,
            18
        )

    Description.Position =
        UDim2.new(
            0,
            8,
            0,
            22
        )

    Description.BackgroundTransparency = 1
    Description.Text = DescriptionText
    Description.TextColor3 = Theme.Text
    Description.TextSize = 10
    Description.Font = Enum.Font.Gotham
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.Parent = Card

    task.delay(3.5, function()

        if not Card.Parent then
            return
        end

        TweenService:Create(
            Card,
            TweenInfo.new(0.3),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Title,
            TweenInfo.new(0.3),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Description,
            TweenInfo.new(0.3),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Stroke,
            TweenInfo.new(0.3),
            {
                Transparency = 1
            }
        ):Play()

        task.wait(0.3)

        if Card.Parent then
            Card:Destroy()
        end
    end)
end

--==================================================================
-- MAIN FRAME
--==================================================================

local MainFrame = Instance.new("Frame")

MainFrame.Name = "MainFrame"

MainFrame.Size =
    UDim2.new(
        0,
        650,
        0,
        460
    )

MainFrame.Position =
    UDim2.new(
        0.5,
        -325,
        0.5,
        -230
    )

MainFrame.BackgroundColor3 =
    Theme.BG

MainFrame.BorderSizePixel = 0

MainFrame.Active = true

MainFrame.Draggable = true

MainFrame.ClipsDescendants = true

MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")

MainStroke.Thickness = 1.2
MainStroke.Color =
    Color3.fromRGB(
        40,
        42,
        58
    )

MainStroke.Parent = MainFrame

--==================================================================
-- MOUSE CONTROLLER
--==================================================================

local LastMenuState = nil
local LastFirstPersonState = nil

local function UpdateMouseState(Force)

    local MenuOpen =
        MainFrame.Visible

    local FirstPerson =
        IsFirstPerson()

    if not Force then

        if
            MenuOpen == LastMenuState
            and
            FirstPerson == LastFirstPersonState
        then

            return
        end
    end

    LastMenuState =
        MenuOpen

    LastFirstPersonState =
        FirstPerson

    -- MENU ABERTO
    if MenuOpen then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default

        UserInputService.MouseIconEnabled = true

        return
    end

    -- PRIMEIRA PESSOA
    if FirstPerson then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.LockCenter

        UserInputService.MouseIconEnabled = false

        return
    end

    -- TERCEIRA PESSOA
    UserInputService.MouseBehavior =
        Enum.MouseBehavior.Default

    UserInputService.MouseIconEnabled = true
end

--==================================================================
-- HEADER
--==================================================================

local Header = Instance.new("Frame")

Header.Size =
    UDim2.new(
        1,
        0,
        0,
        45
    )

Header.BackgroundColor3 =
    Theme.Header

Header.BorderSizePixel = 0

Header.Parent =
    MainFrame

local Title = Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        0,
        400,
        1,
        0
    )

Title.Position =
    UDim2.new(
        0,
        15,
        0,
        0
    )

Title.BackgroundTransparency = 1

Title.Text =
    "VOID // ARCHITECT SUITE v4.7"

Title.TextColor3 =
    Theme.Accent

Title.TextSize = 13

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    Header

local CloseButton =
    Instance.new("TextButton")

CloseButton.Size =
    UDim2.new(
        0,
        28,
        0,
        28
    )

CloseButton.Position =
    UDim2.new(
        1,
        -36,
        0.5,
        -14
    )

CloseButton.BackgroundColor3 =
    Color3.fromRGB(
        239,
        68,
        68
    )

CloseButton.BackgroundTransparency =
    0.85

CloseButton.Text = "×"

CloseButton.TextColor3 =
    Color3.fromRGB(
        248,
        113,
        113
    )

CloseButton.TextSize = 18

CloseButton.Font =
    Enum.Font.GothamBold

CloseButton.Parent =
    Header

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(0, 6)

CloseCorner.Parent =
    CloseButton

CloseButton.MouseButton1Click:Connect(function()

    MainFrame.Visible = false

    UpdateMouseState(true)
end)

--==================================================================
-- SIDEBAR
--==================================================================

local Sidebar =
    Instance.new("Frame")

Sidebar.Size =
    UDim2.new(
        0,
        145,
        1,
        -45
    )

Sidebar.Position =
    UDim2.new(
        0,
        0,
        0,
        45
    )

Sidebar.BackgroundColor3 =
    Theme.Sidebar

Sidebar.BorderSizePixel = 0

Sidebar.Parent =
    MainFrame

local SidebarLayout =
    Instance.new("UIListLayout")

SidebarLayout.Padding =
    UDim.new(0, 4)

SidebarLayout.Parent =
    Sidebar

local SidebarPadding =
    Instance.new("UIPadding")

SidebarPadding.PaddingTop =
    UDim.new(0, 10)

SidebarPadding.PaddingLeft =
    UDim.new(0, 8)

SidebarPadding.PaddingRight =
    UDim.new(0, 8)

SidebarPadding.Parent =
    Sidebar

--==================================================================
-- CONTENT
--==================================================================

local ContentArea =
    Instance.new("Frame")

ContentArea.Size =
    UDim2.new(
        1,
        -145,
        1,
        -45
    )

ContentArea.Position =
    UDim2.new(
        0,
        145,
        0,
        45
    )

ContentArea.BackgroundTransparency = 1

ContentArea.Parent =
    MainFrame

--==================================================================
-- TABS
--==================================================================

local Tabs = {}

local function CreateTab(Name)

    local Button =
        Instance.new("TextButton")

    Button.Size =
        UDim2.new(
            1,
            0,
            0,
            32
        )

    Button.BackgroundColor3 =
        Theme.Sidebar

    Button.BackgroundTransparency =
        1

    Button.Text =
        "  " .. Name

    Button.TextColor3 =
        Theme.SubText

    Button.TextSize = 11

    Button.Font =
        Enum.Font.GothamMedium

    Button.TextXAlignment =
        Enum.TextXAlignment.Left

    Button.Parent =
        Sidebar

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(0, 6)

    ButtonCorner.Parent =
        Button

    local Scroll =
        Instance.new("ScrollingFrame")

    Scroll.Name =
        Name .. "Tab"

    Scroll.Size =
        UDim2.new(
            1,
            -20,
            1,
            -20
        )

    Scroll.Position =
        UDim2.new(
            0,
            10,
            0,
            10
        )

    Scroll.BackgroundTransparency = 1

    Scroll.BorderSizePixel = 0

    Scroll.ScrollBarThickness = 3

    Scroll.ScrollBarImageColor3 =
        Theme.Accent

    Scroll.Visible = false

    Scroll.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    Scroll.Parent =
        ContentArea

    local Layout =
        Instance.new("UIListLayout")

    Layout.Padding =
        UDim.new(0, 8)

    Layout.Parent =
        Scroll

    Layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(function()

        Scroll.CanvasSize =
            UDim2.new(
                0,
                0,
                0,
                Layout.AbsoluteContentSize.Y + 20
            )
    end)

    Button.MouseButton1Click:Connect(function()

        for _, Tab in pairs(Tabs) do

            Tab.Scroll.Visible = false

            Tab.Button.BackgroundTransparency =
                1

            Tab.Button.TextColor3 =
                Theme.SubText
        end

        Scroll.Visible = true

        Button.BackgroundColor3 =
            Theme.Card

        Button.BackgroundTransparency =
            0

        Button.TextColor3 =
            Theme.Accent
    end)

    local Data = {
        Button = Button,
        Scroll = Scroll
    }

    table.insert(
        Tabs,
        Data
    )

    if #Tabs == 1 then

        Scroll.Visible = true

        Button.BackgroundColor3 =
            Theme.Card

        Button.BackgroundTransparency =
            0

        Button.TextColor3 =
            Theme.Accent
    end

    return Scroll
end

--==================================================================
-- UI BUILDERS
--==================================================================

local function AddToggle(
    Parent,
    TitleText,
    DescriptionText,
    Callback
)

    local Card =
        Instance.new("Frame")

    Card.Size =
        UDim2.new(
            1,
            -4,
            0,
            48
        )

    Card.BackgroundColor3 =
        Theme.Card

    Card.BorderSizePixel = 0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent =
        Card

    local TitleLabel =
        Instance.new("TextLabel")

    TitleLabel.Size =
        UDim2.new(
            0.7,
            0,
            0,
            18
        )

    TitleLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            5
        )

    TitleLabel.BackgroundTransparency = 1

    TitleLabel.Text =
        TitleText

    TitleLabel.TextColor3 =
        Theme.Text

    TitleLabel.TextSize = 11

    TitleLabel.Font =
        Enum.Font.GothamMedium

    TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    TitleLabel.Parent =
        Card

    local DescriptionLabel =
        Instance.new("TextLabel")

    DescriptionLabel.Size =
        UDim2.new(
            0.7,
            0,
            0,
            16
        )

    DescriptionLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            23
        )

    DescriptionLabel.BackgroundTransparency =
        1

    DescriptionLabel.Text =
        DescriptionText

    DescriptionLabel.TextColor3 =
        Theme.SubText

    DescriptionLabel.TextSize = 9

    DescriptionLabel.Font =
        Enum.Font.Gotham

    DescriptionLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    DescriptionLabel.Parent =
        Card

    local Button =
        Instance.new("TextButton")

    Button.Size =
        UDim2.new(
            0,
            36,
            0,
            18
        )

    Button.Position =
        UDim2.new(
            1,
            -44,
            0.5,
            -9
        )

    Button.BackgroundColor3 =
        Color3.fromRGB(
            40,
            42,
            58
        )

    Button.Text = ""

    Button.Parent =
        Card

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(1, 0)

    ButtonCorner.Parent =
        Button

    local Indicator =
        Instance.new("Frame")

    Indicator.Size =
        UDim2.new(
            0,
            12,
            0,
            12
        )

    Indicator.Position =
        UDim2.new(
            0,
            3,
            0.5,
            -6
        )

    Indicator.BackgroundColor3 =
        Color3.fromRGB(
            180,
            180,
            200
        )

    Indicator.BorderSizePixel = 0

    Indicator.Parent =
        Button

    local IndicatorCorner =
        Instance.new("UICorner")

    IndicatorCorner.CornerRadius =
        UDim.new(1, 0)

    IndicatorCorner.Parent =
        Indicator

    local Enabled = false

    Button.MouseButton1Click:Connect(function()

        Enabled = not Enabled

        if Enabled then

            TweenService:Create(
                Indicator,
                TweenInfo.new(0.15),
                {
                    Position =
                        UDim2.new(
                            1,
                            -15,
                            0.5,
                            -6
                        )
                }
            ):Play()

            TweenService:Create(
                Button,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        Theme.Accent
                }
            ):Play()

        else

            TweenService:Create(
                Indicator,
                TweenInfo.new(0.15),
                {
                    Position =
                        UDim2.new(
                            0,
                            3,
                            0.5,
                            -6
                        )
                }
            ):Play()

            TweenService:Create(
                Button,
                TweenInfo.new(0.15),
                {
                    BackgroundColor3 =
                        Color3.fromRGB(
                            40,
                            42,
                            58
                        )
                }
            ):Play()
        end

        Callback(Enabled)
    end)
end

local function AddSlider(
    Parent,
    TitleText,
    MinValue,
    MaxValue,
    DefaultValue,
    Callback
)

    local Card =
        Instance.new("Frame")

    Card.Size =
        UDim2.new(
            1,
            -4,
            0,
            52
        )

    Card.BackgroundColor3 =
        Theme.Card

    Card.BorderSizePixel = 0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent =
        Card

    local TitleLabel =
        Instance.new("TextLabel")

    TitleLabel.Size =
        UDim2.new(
            0.6,
            0,
            0,
            18
        )

    TitleLabel.Position =
        UDim2.new(
            0,
            10,
            0,
            5
        )

    TitleLabel.BackgroundTransparency = 1

    TitleLabel.Text =
        TitleText

    TitleLabel.TextColor3 =
        Theme.Text

    TitleLabel.TextSize = 11

    TitleLabel.Font =
        Enum.Font.GothamMedium

    TitleLabel.TextXAlignment =
        Enum.TextXAlignment.Left

    TitleLabel.Parent =
        Card

    local Input =
        Instance.new("TextBox")

    Input.Size =
        UDim2.new(
            0,
            50,
            0,
            20
        )

    Input.Position =
        UDim2.new(
            1,
            -60,
            0,
            4
        )

    Input.BackgroundColor3 =
        Color3.fromRGB(
            30,
            32,
            44
        )

    Input.BorderSizePixel = 0

    Input.Text =
        tostring(DefaultValue)

    Input.TextColor3 =
        Theme.Accent

    Input.TextSize = 11

    Input.Font =
        Enum.Font.GothamBold

    Input.ClearTextOnFocus =
        false

    Input.Parent =
        Card

    local InputCorner =
        Instance.new("UICorner")

    InputCorner.CornerRadius =
        UDim.new(0, 4)

    InputCorner.Parent =
        Input

    local Track =
        Instance.new("Frame")

    Track.Size =
        UDim2.new(
            1,
            -20,
            0,
            5
        )

    Track.Position =
        UDim2.new(
            0,
            10,
            0,
            34
        )

    Track.BackgroundColor3 =
        Color3.fromRGB(
            40,
            42,
            58
        )

    Track.BorderSizePixel = 0

    Track.Parent =
        Card

    local TrackCorner =
        Instance.new("UICorner")

    TrackCorner.CornerRadius =
        UDim.new(1, 0)

    TrackCorner.Parent =
        Track

    local InitialPercent =
        math.clamp(
            (
                DefaultValue -
                MinValue
            ) /
            (
                MaxValue -
                MinValue
            ),
            0,
            1
        )

    local Fill =
        Instance.new("Frame")

    Fill.Size =
        UDim2.new(
            InitialPercent,
            0,
            1,
            0
        )

    Fill.BackgroundColor3 =
        Theme.Accent

    Fill.BorderSizePixel = 0

    Fill.Parent =
        Track

    local FillCorner =
        Instance.new("UICorner")

    FillCorner.CornerRadius =
        UDim.new(1, 0)

    FillCorner.Parent =
        Fill

    local function SetValue(Value)

        Value =
            math.clamp(
                Value,
                MinValue,
                MaxValue
            )

        Input.Text =
            tostring(Value)

        local Percent =
            (
                Value -
                MinValue
            ) /
            (
                MaxValue -
                MinValue
            )

        Fill.Size =
            UDim2.new(
                Percent,
                0,
                1,
                0
            )

        Callback(Value)
    end

    local Dragging = false

    local function UpdateSlider(InputObject)

        if Track.AbsoluteSize.X <= 0 then
            return
        end

        local Percent =
            (
                InputObject.Position.X -
                Track.AbsolutePosition.X
            ) /
            Track.AbsoluteSize.X

        Percent =
            math.clamp(
                Percent,
                0,
                1
            )

        local Value =
            math.floor(
                MinValue +
                (
                    MaxValue -
                    MinValue
                ) *
                Percent
            )

        SetValue(Value)
    end

    Track.InputBegan:Connect(
        function(InputObject)

            if
                InputObject.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                Dragging = true

                UpdateSlider(
                    InputObject
                )
            end
        end
    )

    UserInputService.InputChanged:Connect(
        function(InputObject)

            if
                Dragging
                and
                InputObject.UserInputType ==
                Enum.UserInputType.MouseMovement
            then

                UpdateSlider(
                    InputObject
                )
            end
        end
    )

    UserInputService.InputEnded:Connect(
        function(InputObject)

            if
                InputObject.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                Dragging = false
            end
        end
    )

    Input.FocusLost:Connect(function()

        local Number =
            tonumber(Input.Text)

        if Number then
            SetValue(Number)
        else
            SetValue(DefaultValue)
        end
    end)
end

local function AddButton(
    Parent,
    TitleText,
    ButtonText,
    Callback
)

    local Card =
        Instance.new("Frame")

    Card.Size =
        UDim2.new(
            1,
            -4,
            0,
            40
        )

    Card.BackgroundColor3 =
        Theme.Card

    Card.BorderSizePixel = 0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent =
        Card

    local Label =
        Instance.new("TextLabel")

    Label.Size =
        UDim2.new(
            0.6,
            0,
            1,
            0
        )

    Label.Position =
        UDim2.new(
            0,
            10,
            0,
            0
        )

    Label.BackgroundTransparency = 1

    Label.Text =
        TitleText

    Label.TextColor3 =
        Theme.Text

    Label.TextSize = 11

    Label.Font =
        Enum.Font.GothamMedium

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Parent =
        Card

    local Button =
        Instance.new("TextButton")

    Button.Size =
        UDim2.new(
            0,
            95,
            0,
            24
        )

    Button.Position =
        UDim2.new(
            1,
            -105,
            0.5,
            -12
        )

    Button.BackgroundColor3 =
        Theme.Accent

    Button.Text =
        ButtonText

    Button.TextColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    Button.TextSize = 10

    Button.Font =
        Enum.Font.GothamBold

    Button.Parent =
        Card

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(0, 4)

    ButtonCorner.Parent =
        Button

    Button.MouseButton1Click:Connect(
        Callback
    )

    return Button
end

local function AddTextBox(
    Parent,
    TitleText,
    PlaceholderText,
    Callback
)

    local Card =
        Instance.new("Frame")

    Card.Size =
        UDim2.new(
            1,
            -4,
            0,
            42
        )

    Card.BackgroundColor3 =
        Theme.Card

    Card.BorderSizePixel = 0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent =
        Card

    local Label =
        Instance.new("TextLabel")

    Label.Size =
        UDim2.new(
            0.45,
            0,
            1,
            0
        )

    Label.Position =
        UDim2.new(
            0,
            10,
            0,
            0
        )

    Label.BackgroundTransparency = 1

    Label.Text =
        TitleText

    Label.TextColor3 =
        Theme.Text

    Label.TextSize = 11

    Label.Font =
        Enum.Font.GothamMedium

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Parent =
        Card

    local Input =
        Instance.new("TextBox")

    Input.Size =
        UDim2.new(
            0.5,
            -10,
            0,
            24
        )

    Input.Position =
        UDim2.new(
            0.5,
            0,
            0.5,
            -12
        )

    Input.BackgroundColor3 =
        Color3.fromRGB(
            30,
            32,
            44
        )

    Input.BorderSizePixel = 0

    Input.PlaceholderText =
        PlaceholderText

    Input.Text = ""

    Input.TextColor3 =
        Theme.Text

    Input.PlaceholderColor3 =
        Theme.SubText

    Input.TextSize = 10

    Input.Font =
        Enum.Font.Gotham

    Input.Parent =
        Card

    local InputCorner =
        Instance.new("UICorner")

    InputCorner.CornerRadius =
        UDim.new(0, 4)

    InputCorner.Parent =
        Input

    Input.FocusLost:Connect(
        function(EnterPressed)

            if EnterPressed then

                Callback(
                    Input.Text
                )
            end
        end
    )
end

--==================================================================
-- TABS
--==================================================================

local TabPlayer =
    CreateTab("Jogador")

local TabMovement =
    CreateTab("Movimento")

local TabVisual =
    CreateTab("Visual & ESP")

local TabCombat =
    CreateTab("Combate")

local TabWaypoints =
    CreateTab("Waypoints")

local TabServer =
    CreateTab("Servidor")

local TabConfig =
    CreateTab("Configurações")

--==================================================================
-- PLAYER
--==================================================================

AddToggle(
    TabPlayer,
    "Super Velocidade",
    "Aumenta a velocidade.",
    function(Value)

        State.SpeedEnabled =
            Value
    end
)

AddSlider(
    TabPlayer,
    "Velocidade",
    16,
    400,
    State.WalkSpeed,
    function(Value)

        State.WalkSpeed =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Super Pulo",
    "Aumenta a força do salto.",
    function(Value)

        State.JumpEnabled =
            Value
    end
)

AddSlider(
    TabPlayer,
    "Força do Pulo",
    50,
    500,
    State.JumpPower,
    function(Value)

        State.JumpPower =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Pulo Infinito",
    "Permite pular no ar.",
    function(Value)

        State.InfJump =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Auto Bhop",
    "Pulo automático.",
    function(Value)

        State.BhopEnabled =
            Value
    end
)

AddToggle(
    TabPlayer,
    "God Mode Local",
    "Mantém a saúde cheia.",
    function(Value)

        State.GodMode =
            Value
    end
)

AddToggle(
    TabPlayer,
    "HipHeight",
    "Altera a altura.",
    function(Value)

        State.HipHeightEnabled =
            Value
    end
)

AddSlider(
    TabPlayer,
    "Altura",
    0,
    30,
    State.HipHeightValue,
    function(Value)

        State.HipHeightValue =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Click Teleport",
    "Ctrl + clique.",
    function(Value)

        State.ClickTP =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Infinite Zoom",
    "Aumenta o zoom.",
    function(Value)

        State.InfiniteZoom =
            Value

        if Value then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance

        else

            LocalPlayer.CameraMaxZoomDistance =
                State.OriginalZoom
        end
    end
)

AddSlider(
    TabPlayer,
    "Distância da Câmera",
    16,
    1000,
    State.ZoomDistance,
    function(Value)

        State.ZoomDistance =
            Value

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                Value
        end
    end
)

AddToggle(
    TabPlayer,
    "Platform Stand",
    "Estado físico livre.",
    function(Value)

        State.PlatformStand =
            Value
    end
)

AddButton(
    TabPlayer,
    "Resetar Personagem",
    "Reset",
    function()

        local Character =
            LocalPlayer.Character

        local Humanoid =
            Character and
            Character:FindFirstChildOfClass(
                "Humanoid"
            )

        if Humanoid then
            Humanoid.Health = 0
        end
    end
)

--==================================================================
-- MOVEMENT
--==================================================================

AddToggle(
    TabMovement,
    "Fly",
    "Movimentação aérea.",
    function(Value)

        State.FlyEnabled =
            Value
    end
)

AddSlider(
    TabMovement,
    "Velocidade do Fly",
    20,
    350,
    State.FlySpeed,
    function(Value)

        State.FlySpeed =
            Value
    end
)

AddToggle(
    TabMovement,
    "Noclip",
    "Atravessa objetos.",
    function(Value)

        State.NoclipEnabled =
            Value
    end
)

AddToggle(
    TabMovement,
    "Low Gravity",
    "Reduz a gravidade.",
    function(Value)

        State.LowGravity =
            Value

        if not Value then

            workspace.Gravity =
                State.OriginalGravity
        end
    end
)

AddSlider(
    TabMovement,
    "Gravidade",
    0,
    196,
    State.GravityValue,
    function(Value)

        State.GravityValue =
            Value
    end
)

AddToggle(
    TabMovement,
    "Blink",
    "Prende o personagem.",
    function(Value)

        State.BlinkEnabled =
            Value
    end
)

AddToggle(
    TabMovement,
    "Spinbot",
    "Rotação contínua.",
    function(Value)

        State.SpinbotEnabled =
            Value
    end
)

AddSlider(
    TabMovement,
    "Velocidade de Rotação",
    1,
    100,
    State.SpinSpeed,
    function(Value)

        State.SpinSpeed =
            Value
    end
)

AddToggle(
    TabMovement,
    "Anti-Fling",
    "Reduz velocidades extremas.",
    function(Value)

        State.AntiFling =
            Value
    end
)

--==================================================================
-- VISUAL
--==================================================================

AddToggle(
    TabVisual,
    "ESP",
    "Ativa o ESP.",
    function(Value)

        State.ESPEnabled =
            Value
    end
)

AddToggle(
    TabVisual,
    "ESP Boxes",
    "Destaca jogadores.",
    function(Value)

        State.ESPBoxes =
            Value
    end
)

AddToggle(
    TabVisual,
    "ESP Names",
    "Mostra informações.",
    function(Value)

        State.ESPNames =
            Value
    end
)

AddToggle(
    TabVisual,
    "ESP Tracers",
    "Linhas até jogadores.",
    function(Value)

        State.ESPTracers =
            Value
    end
)

AddToggle(
    TabVisual,
    "Fullbright",
    "Ilumina o ambiente.",
    function(Value)

        State.Fullbright =
            Value

        if not Value then

            Lighting.Ambient =
                State.OriginalAmbient

            Lighting.Brightness =
                State.OriginalBrightness
        end
    end
)

AddToggle(
    TabVisual,
    "No Fog",
    "Remove a névoa.",
    function(Value)

        State.NoFog =
            Value

        if not Value then

            Lighting.FogEnd =
                State.OriginalFogEnd
        end
    end
)

AddToggle(
    TabVisual,
    "Crosshair",
    "Mira fixa.",
    function(Value)

        State.CrosshairEnabled =
            Value
    end
)

AddToggle(
    TabVisual,
    "Custom FOV",
    "Altera o FOV.",
    function(Value)

        State.FOVEnabled =
            Value

        if not Value then

            Camera.FieldOfView =
                State.OriginalFOV
        end
    end
)

AddSlider(
    TabVisual,
    "FOV",
    70,
    130,
    State.FOVValue,
    function(Value)

        State.FOVValue =
            Value
    end
)

AddToggle(
    TabVisual,
    "FPS Counter",
    "Mostra FPS.",
    function(Value)

        State.FPSCounter =
            Value

        FPSLabel.Visible =
            Value
    end
)

--==================================================================
-- COMBAT
--==================================================================

AddToggle(
    TabCombat,
    "Aimbot",
    "Seleciona o alvo mais próximo.",
    function(Value)

        State.AimbotEnabled =
            Value

        Notify(
            "Aimbot",
            Value and
                "Ativado" or
                "Desativado"
        )
    end
)

AddToggle(
    TabCombat,
    "Aimbot Hold",
    "Só funciona segurando a tecla.",
    function(Value)

        State.AimbotHold =
            Value
    end
)

local AimKeyButton

AimKeyButton =
    AddButton(
        TabCombat,
        "Tecla do Aimbot",
        State.AimbotKey.Name,
        function()

            ListeningFor =
                "AIM"

            AimKeyButton.Text =
                "Pressione..."
        end
    )

AddSlider(
    TabCombat,
    "Suavidade",
    1,
    10,
    2,
    function(Value)

        State.AimbotSmoothness =
            Value / 10
    end
)

AddToggle(
    TabCombat,
    "Mostrar FOV",
    "Mostra a área de seleção.",
    function(Value)

        State.ShowFOVCircle =
            Value
    end
)

AddSlider(
    TabCombat,
    "Raio do FOV",
    50,
    400,
    State.AimbotFOV,
    function(Value)

        State.AimbotFOV =
            Value
    end
)

AddButton(
    TabCombat,
    "Parte do Alvo",
    "Cabeça / Torso",
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
    TabCombat,
    "Triggerbot",
    "Ação automática.",
    function(Value)

        State.Triggerbot =
            Value
    end
)

AddToggle(
    TabCombat,
    "Hitbox Extender",
    "Aumenta a área.",
    function(Value)

        State.HitboxEnabled =
            Value
    end
)

AddSlider(
    TabCombat,
    "Tamanho da Hitbox",
    2,
    40,
    State.HitboxSize,
    function(Value)

        State.HitboxSize =
            Value
    end
)

--==================================================================
-- WAYPOINTS
--==================================================================

AddTextBox(
    TabWaypoints,
    "Novo Waypoint",
    "Nome do local...",
    function(Text)

        if
            Text
            and
            Text ~= ""
            and
            LocalPlayer.Character
            and
            LocalPlayer.Character:
                FindFirstChild(
                    "HumanoidRootPart"
                )
        then

            table.insert(
                State.Waypoints,
                {
                    Name = Text,
                    Position =
                        LocalPlayer.Character
                        .HumanoidRootPart
                        .Position
                }
            )

            Notify(
                "Waypoint",
                "Salvo: " .. Text
            )
        end
    end
)

AddButton(
    TabWaypoints,
    "Último Waypoint",
    "Ir",
    function()

        if #State.Waypoints == 0 then

            Notify(
                "Waypoint",
                "Nenhum waypoint."
            )

            return
        end

        local Waypoint =
            State.Waypoints[
                #State.Waypoints
            ]

        local Character =
            LocalPlayer.Character

        local Root =
            Character and
            Character:FindFirstChild(
                "HumanoidRootPart"
            )

        if Root then

            Root.CFrame =
                CFrame.new(
                    Waypoint.Position +
                    Vector3.new(
                        0,
                        3,
                        0
                    )
                )
        end
    end
)

AddButton(
    TabWaypoints,
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

--==================================================================
-- SERVER
--==================================================================

AddToggle(
    TabServer,
    "Anti-AFK",
    "Evita desconexão.",
    function(Value)

        State.AntiAFK =
            Value
    end
)

AddButton(
    TabServer,
    "Reconectar",
    "Rejoin",
    function()

        TeleportService:
            TeleportToPlaceInstance(
                game.PlaceId,
                game.JobId,
                LocalPlayer
            )
    end
)

AddButton(
    TabServer,
    "Trocar Servidor",
    "Hop",
    function()

        TeleportService:
            Teleport(
                game.PlaceId,
                LocalPlayer
            )
    end
)

AddButton(
    TabServer,
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
        end
    end
)

--==================================================================
-- CONFIG
--==================================================================

local PanelKeyButton

PanelKeyButton =
    AddButton(
        TabConfig,
        "Atalho do Painel",
        TOGGLE_KEY.Name,
        function()

            ListeningFor =
                "PANEL"

            PanelKeyButton.Text =
                "Pressione..."
        end
    )

local function CreateTheme(
    Parent,
    Name,
    Color
)

    AddButton(
        Parent,
        "Tema: " .. Name,
        "Aplicar",
        function()

            Theme.Accent =
                Color

            Title.TextColor3 =
                Color

            FOVCircle.Color =
                Color

            FPSLabel.TextColor3 =
                Color

            for _, Tab in pairs(Tabs) do

                Tab.Scroll.ScrollBarImageColor3 =
                    Color

                if Tab.Scroll.Visible then

                    Tab.Button.TextColor3 =
                        Color
                end
            end

            Notify(
                "Tema",
                "Aplicado: " .. Name
            )
        end
    )
end

CreateTheme(
    TabConfig,
    "Roxo Neon",
    Color3.fromRGB(
        138,
        92,
        246
    )
)

CreateTheme(
    TabConfig,
    "Azul Cyber",
    Color3.fromRGB(
        14,
        165,
        233
    )
)

CreateTheme(
    TabConfig,
    "Verde Matrix",
    Color3.fromRGB(
        34,
        197,
        94
    )
)

CreateTheme(
    TabConfig,
    "Vermelho",
    Color3.fromRGB(
        239,
        68,
        68
    )
)

CreateTheme(
    TabConfig,
    "Ouro",
    Color3.fromRGB(
        234,
        179,
        8
    )
)

--==================================================================
-- INPUT
--==================================================================

UserInputService.InputBegan:Connect(
    function(Input, GameProcessed)

        -- KEYBIND
        if ListeningFor then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                if ListeningFor ==
                    "PANEL"
                then

                    TOGGLE_KEY =
                        Input.KeyCode

                    PanelKeyButton.Text =
                        Input.KeyCode.Name

                    Notify(
                        "Painel",
                        "Tecla alterada."
                    )

                elseif ListeningFor ==
                    "AIM"
                then

                    State.AimbotKey =
                        Input.KeyCode

                    AimKeyButton.Text =
                        Input.KeyCode.Name

                    Notify(
                        "Aimbot",
                        "Tecla alterada."
                    )
                end

                ListeningFor = nil
            end

            return
        end

        -- TOGGLE MENU
        if
            not GameProcessed
            and
            Input.KeyCode ==
                TOGGLE_KEY
        then

            MainFrame.Visible =
                not MainFrame.Visible

            UpdateMouseState(true)
        end
    end
)

--==================================================================
-- CLICK TELEPORT
--==================================================================

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

    local Character =
        LocalPlayer.Character

    local Root =
        Character and
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if Root and Mouse.Hit then

        Root.CFrame =
            Mouse.Hit +
            Vector3.new(
                0,
                3,
                0
            )
    end
end)

--==================================================================
-- INFINITE JUMP
--==================================================================

UserInputService.JumpRequest:Connect(function()

    if not State.InfJump then
        return
    end

    local Character =
        LocalPlayer.Character

    local Humanoid =
        Character and
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if Humanoid then

        Humanoid:ChangeState(
            Enum.HumanoidStateType.Jumping
        )
    end
end)

--==================================================================
-- ANTI AFK
--==================================================================

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

--==================================================================
-- FPS
--==================================================================

local FPSFrames = 0
local FPSTime = os.clock()

RunService.RenderStepped:Connect(function()

    FPSFrames += 1

    local Now =
        os.clock()

    if Now - FPSTime >= 1 then

        FPSLabel.Text =
            "FPS: " ..
            tostring(
                FPSFrames
            )

        FPSFrames = 0
        FPSTime = Now
    end
end)

--==================================================================
-- MOUSE STATE MONITOR
--==================================================================

RunService.RenderStepped:Connect(function()

    RefreshCamera()

    local FirstPerson =
        IsFirstPerson()

    local MenuOpen =
        MainFrame.Visible

    if
        FirstPerson ~=
            LastFirstPersonState
        or
        MenuOpen ~=
            LastMenuState
    then

        UpdateMouseState(true)
    end
end)

--==================================================================
-- MAIN LOOP
--==================================================================

RunService.RenderStepped:Connect(function()

    RefreshCamera()

    local Character =
        LocalPlayer.Character

    local Humanoid =
        Character and
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    local Root =
        Character and
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    --==============================================================
    -- PLAYER
    --==============================================================

    if Humanoid then

        if State.SpeedEnabled then

            Humanoid.WalkSpeed =
                State.WalkSpeed
        end

        if State.JumpEnabled then

            Humanoid.UseJumpPower =
                true

            Humanoid.JumpPower =
                State.JumpPower
        end

        if State.GodMode then

            Humanoid.Health =
                Humanoid.MaxHealth
        end

        if State.HipHeightEnabled then

            Humanoid.HipHeight =
                State.HipHeightValue
        end

        Humanoid.PlatformStand =
            State.PlatformStand

        if
            State.BhopEnabled
            and
            Humanoid.FloorMaterial ~=
                Enum.Material.Air
            and
            UserInputService:
                IsKeyDown(
                    Enum.KeyCode.Space
                )
        then

            Humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end

    --==============================================================
    -- ZOOM
    --==============================================================

    if State.InfiniteZoom then

        LocalPlayer.CameraMaxZoomDistance =
            State.ZoomDistance
    end

    --==============================================================
    -- GRAVITY
    --==============================================================

    if State.LowGravity then

        workspace.Gravity =
            State.GravityValue
    end

    --==============================================================
    -- FLY
    --==============================================================

    if
        State.FlyEnabled
        and
        Root
    then

        local Direction =
            Vector3.zero

        if UserInputService:IsKeyDown(
            Enum.KeyCode.W
        ) then

            Direction +=
                Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.S
        ) then

            Direction -=
                Camera.CFrame.LookVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.A
        ) then

            Direction -=
                Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.D
        ) then

            Direction +=
                Camera.CFrame.RightVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.Space
        ) then

            Direction +=
                Vector3.new(
                    0,
                    1,
                    0
                )
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.LeftShift
        ) then

            Direction -=
                Vector3.new(
                    0,
                    1,
                    0
                )
        end

        Root.Velocity =
            Direction *
            State.FlySpeed

        Root.RotVelocity =
            Vector3.zero
    end

    --==============================================================
    -- ANTI FLING
    --==============================================================

    if
        State.AntiFling
        and
        Root
        and
        not State.FlyEnabled
    then

        if
            Root.AssemblyLinearVelocity.Magnitude
            > 150
        then

            Root.AssemblyLinearVelocity =
                Vector3.zero
        end

        if
            Root.AssemblyAngularVelocity.Magnitude
            > 100
        then

            Root.AssemblyAngularVelocity =
                Vector3.zero
        end
    end

    --==============================================================
    -- SPIN
    --==============================================================

    if
        State.SpinbotEnabled
        and
        Root
    then

        Root.CFrame =
            Root.CFrame *
            CFrame.Angles(
                0,
                math.rad(
                    State.SpinSpeed
                ),
                0
            )
    end

    --==============================================================
    -- BLINK
    --==============================================================

    if
        State.BlinkEnabled
        and
        Root
    then

        Root.Anchored = true

    elseif
        Root
        and
        not State.BlinkEnabled
        and
        Root.Anchored
    then

        Root.Anchored = false
    end

    --==============================================================
    -- NOCLIP
    --==============================================================

    if
        State.NoclipEnabled
        and
        Character
    then

        for _, Part in ipairs(
            Character:GetDescendants()
        ) do

            if Part:IsA("BasePart") then

                Part.CanCollide = false
            end
        end
    end

    --==============================================================
    -- VISUAL
    --==============================================================

    if State.Fullbright then

        Lighting.Ambient =
            Color3.fromRGB(
                255,
                255,
                255
            )

        Lighting.Brightness = 2
    end

    if State.NoFog then

        Lighting.FogEnd =
            1000000
    end

    if State.FOVEnabled then

        Camera.FieldOfView =
            State.FOVValue
    end

    --==============================================================
    -- FOV CIRCLE
    --==============================================================

    if State.ShowFOVCircle then

        FOVCircle.Position =
            GetAimPosition()

        FOVCircle.Radius =
            State.AimbotFOV

        FOVCircle.Visible = true

    else

        FOVCircle.Visible = false
    end

    --==============================================================
    -- CROSSHAIR
    --==============================================================

    if State.CrosshairEnabled then

        local Center =
            Vector2.new(
                Camera.ViewportSize.X / 2,
                Camera.ViewportSize.Y / 2
            )

        local Length = 8

        Crosshair.Top.From =
            Center -
            Vector2.new(
                0,
                3
            )

        Crosshair.Top.To =
            Center -
            Vector2.new(
                0,
                3 + Length
            )

        Crosshair.Bottom.From =
            Center +
            Vector2.new(
                0,
                3
            )

        Crosshair.Bottom.To =
            Center +
            Vector2.new(
                0,
                3 + Length
            )

        Crosshair.Left.From =
            Center -
            Vector2.new(
                3,
                0
            )

        Crosshair.Left.To =
            Center -
            Vector2.new(
                3 + Length,
                0
            )

        Crosshair.Right.From =
            Center +
            Vector2.new(
                3,
                0
            )

        Crosshair.Right.To =
            Center +
            Vector2.new(
                3 + Length,
                0
            )

        for _, Line in pairs(
            Crosshair
        ) do

            Line.Visible = true
        end

    else

        for _, Line in pairs(
            Crosshair
        ) do

            Line.Visible = false
        end
    end

    --==============================================================
    -- TRIGGERBOT
    --==============================================================

    if
        State.Triggerbot
        and
        Mouse.Target
        and
        mouse1click
    then

        local TargetCharacter =
            Mouse.Target:
                FindFirstAncestorOfClass(
                    "Model"
                )

        if
            TargetCharacter
            and
            TargetCharacter:
                FindFirstChildOfClass(
                    "Humanoid"
                )
            and
            Players:
                GetPlayerFromCharacter(
                    TargetCharacter
                ) ~= LocalPlayer
        then

            mouse1click()
        end
    end

    --==============================================================
    -- ESP / HITBOX
    --==============================================================

    for _, Player in ipairs(
        Players:GetPlayers()
    ) do

        if
            Player ~= LocalPlayer
            and
            Player.Character
        then

            local TargetCharacter =
                Player.Character

            local TargetRoot =
                TargetCharacter:
                    FindFirstChild(
                        "HumanoidRootPart"
                    )

            local TargetHumanoid =
                TargetCharacter:
                    FindFirstChildOfClass(
                        "Humanoid"
                    )

            if TargetRoot then

                if State.HitboxEnabled then

                    TargetRoot.Size =
                        Vector3.new(
                            State.HitboxSize,
                            State.HitboxSize,
                            State.HitboxSize
                        )

                    TargetRoot.Transparency =
                        0.7

                    TargetRoot.Color =
                        Theme.Accent

                    TargetRoot.Material =
                        Enum.Material.ForceField

                    TargetRoot.CanCollide =
                        false

                else

                    TargetRoot.Size =
                        Vector3.new(
                            2,
                            2,
                            1
                        )

                    TargetRoot.Transparency =
                        1
                end
            end

            local Highlight =
                TargetCharacter:
                    FindFirstChild(
                        "ArchitectESP"
                    )

            if
                State.ESPEnabled
                and
                State.ESPBoxes
            then

                if not Highlight then

                    Highlight =
                        Instance.new(
                            "Highlight"
                        )

                    Highlight.Name =
                        "ArchitectESP"

                    Highlight.FillColor =
                        Theme.Accent

                    Highlight.OutlineColor =
                        Color3.fromRGB(
                            255,
                            255,
                            255
                        )

                    Highlight.FillTransparency =
                        0.5

                    Highlight.Parent =
                        TargetCharacter
                end

                Highlight.FillColor =
                    Theme.Accent

            else

                if Highlight then
                    Highlight:Destroy()
                end
            end
        end
    end
end)

--==================================================================
-- AIMBOT
-- EXECUTADO APÓS A CÂMERA
--==================================================================

RunService:BindToRenderStep(
    "ArchitectAimbot",
    Enum.RenderPriority.Camera.Value + 1,
    function()

        RefreshCamera()

        if not Camera then
            return
        end

        if not State.AimbotEnabled then
            return
        end

        if
            State.AimbotHold
            and
            not UserInputService:IsKeyDown(
                State.AimbotKey
            )
        then
            return
        end

        local AimPosition =
            GetAimPosition()

        local ClosestTarget = nil

        local ClosestDistance =
            State.AimbotFOV

        for _, Player in ipairs(
            Players:GetPlayers()
        ) do

            if
                Player ~= LocalPlayer
                and
                Player.Character
            then

                local Character =
                    Player.Character

                local Humanoid =
                    Character:
                    FindFirstChildOfClass(
                        "Humanoid"
                    )

                local AimPart =
                    Character:
                    FindFirstChild(
                        State.AimPart
                    )

                if
                    Humanoid
                    and
                    Humanoid.Health > 0
                    and
                    AimPart
                then

                    local ScreenPosition,
                        OnScreen =
                        Camera:
                        WorldToViewportPoint(
                            AimPart.Position
                        )

                    if OnScreen then

                        local Distance =
                            (
                                Vector2.new(
                                    ScreenPosition.X,
                                    ScreenPosition.Y
                                ) -
                                AimPosition
                            ).Magnitude

                        if
                            Distance <
                            ClosestDistance
                        then

                            ClosestDistance =
                                Distance

                            ClosestTarget =
                                AimPart
                        end
                    end
                end
            end
        end

        if not ClosestTarget then
            return
        end

        -- Guarda a posição atual da câmera
        -- e gira somente a direção dela.
        local CameraPosition =
            Camera.CFrame.Position

        local TargetCFrame =
            CFrame.lookAt(
                CameraPosition,
                ClosestTarget.Position
            )

        local Smooth =
            math.clamp(
                State.AimbotSmoothness,
                0.01,
                1
            )

        Camera.CFrame =
            Camera.CFrame:Lerp(
                TargetCFrame,
                Smooth
            )
    end
)

--==================================================================
-- CHARACTER RESPAWN
--==================================================================

LocalPlayer.CharacterAdded:Connect(function()

    task.wait(1)

    RefreshCamera()

    if State.InfiniteZoom then

        LocalPlayer.CameraMaxZoomDistance =
            State.ZoomDistance
    end

    UpdateMouseState(true)
end)

--==================================================================
-- PLAYER REMOVING
--==================================================================

Players.PlayerRemoving:Connect(
    function(Player)

        local Character =
            Player.Character

        if Character then

            local Highlight =
                Character:FindFirstChild(
                    "ArchitectESP"
                )

            if Highlight then
                Highlight:Destroy()
            end
        end
    end
)

--==================================================================
-- INITIALIZATION
--==================================================================

MainFrame.Visible = true

UpdateMouseState(true)

Notify(
    "VOID ARCHITECT",
    "v4.7 inicializada!"
)
```
