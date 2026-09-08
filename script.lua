```lua
--[[
====================================================================
VOID ARCHITECT // STABLE CLIENT SUITE
LocalScript para o seu próprio jogo
====================================================================

PRINCIPAL:
- Menu abre com RightControl
- Menu aberto -> mouse livre
- Menu fechado + primeira pessoa -> mouse preso
- Menu fechado + terceira pessoa -> mouse livre
- Aimbot funciona em primeira pessoa
- Aimbot funciona em terceira pessoa
- FOV visual sem Drawing API
- ESP usando Highlight
- Sem Drawing.new
- Sem mouse1click
- Sem setclipboard
====================================================================
]]

--==============================================================
-- SERVICES
--==============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")

--==============================================================
-- PLAYER
--==============================================================

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Mouse = LocalPlayer:GetMouse()

--==============================================================
-- CLEANUP
--==============================================================

local OldUI = PlayerGui:FindFirstChild("ArchitectSuiteUI")

if OldUI then
    OldUI:Destroy()
end

--==============================================================
-- CONFIG
--==============================================================

local TOGGLE_KEY = Enum.KeyCode.RightControl

local Theme = {
    BG = Color3.fromRGB(10, 11, 16),
    Header = Color3.fromRGB(16, 17, 24),
    Sidebar = Color3.fromRGB(14, 15, 21),
    Card = Color3.fromRGB(20, 22, 30),
    Track = Color3.fromRGB(40, 42, 58),
    Accent = Color3.fromRGB(138, 92, 246),
    Text = Color3.fromRGB(243, 244, 246),
    SubText = Color3.fromRGB(156, 163, 175)
}

--==============================================================
-- STATE
--==============================================================

local State = {

    SpeedEnabled = false,
    WalkSpeed = 120,

    JumpEnabled = false,
    JumpPower = 150,

    InfiniteJump = false,
    Bhop = false,

    GodMode = false,

    FlyEnabled = false,
    FlySpeed = 80,

    Noclip = false,

    LowGravity = false,
    Gravity = 50,

    Spinbot = false,
    SpinSpeed = 20,

    AntiFling = false,

    InfiniteZoom = false,
    ZoomDistance = 500,

    PlatformStand = false,

    ClickTeleport = false,

    HipHeightEnabled = false,
    HipHeight = 2,

    -- Visual
    ESP = false,
    ESPNames = true,

    Fullbright = false,
    NoFog = false,

    CustomFOV = false,
    FOV = 90,

    Crosshair = false,
    FPS = false,

    -- Aim
    Aimbot = false,
    AimbotHold = false,
    AimbotKey = Enum.KeyCode.LeftAlt,

    AimbotFOV = 150,
    AimbotSmoothness = 0.2,

    AimPart = "Head",

    -- Utility
    AntiAFK = true,

    Waypoints = {}
}

--==============================================================
-- ORIGINAL VALUES
--==============================================================

local OriginalGravity = workspace.Gravity
local OriginalFogEnd = Lighting.FogEnd
local OriginalAmbient = Lighting.Ambient
local OriginalBrightness = Lighting.Brightness

local Camera = workspace.CurrentCamera
local OriginalFOV = Camera.FieldOfView
local OriginalZoom = LocalPlayer.CameraMaxZoomDistance

--==============================================================
-- HELPERS
--==============================================================

local function GetCamera()
    Camera = workspace.CurrentCamera or Camera
    return Camera
end

local function IsFirstPerson()
    local camera = GetCamera()

    local character = LocalPlayer.Character
    local head = character and character:FindFirstChild("Head")

    if not camera or not head then
        return false
    end

    return (camera.CFrame.Position - head.Position).Magnitude < 1.25
end

local function GetAimPosition()
    local camera = GetCamera()

    if IsFirstPerson() then
        return Vector2.new(
            camera.ViewportSize.X / 2,
            camera.ViewportSize.Y / 2
        )
    end

    return UserInputService:GetMouseLocation()
end

--==============================================================
-- MOUSE CONTROL
--==============================================================

local LastMouseState = nil

local function UpdateMouse()
    local MenuOpen = MainFrame.Visible
    local FirstPerson = IsFirstPerson()

    local StateKey =
        tostring(MenuOpen) ..
        "_" ..
        tostring(FirstPerson)

    if StateKey == LastMouseState then
        return
    end

    LastMouseState = StateKey

    if MenuOpen then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default

        UserInputService.MouseIconEnabled =
            true

        return
    end

    if FirstPerson then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.LockCenter

        UserInputService.MouseIconEnabled =
            false

        return
    end

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.Default

    UserInputService.MouseIconEnabled =
        true
end

--==============================================================
-- GUI
--==============================================================

local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "ArchitectSuiteUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

--==============================================================
-- FPS
--==============================================================

local FPSLabel = Instance.new("TextLabel")

FPSLabel.Size = UDim2.new(0, 120, 0, 25)
FPSLabel.Position = UDim2.new(0, 10, 0, 10)

FPSLabel.BackgroundTransparency = 1

FPSLabel.Text = "FPS: --"
FPSLabel.TextColor3 = Theme.Accent
FPSLabel.TextSize = 12
FPSLabel.Font = Enum.Font.GothamBold

FPSLabel.TextXAlignment =
    Enum.TextXAlignment.Left

FPSLabel.Visible = false
FPSLabel.Parent = ScreenGui

--==============================================================
-- AIM FOV
--==============================================================

local FOVFrame = Instance.new("Frame")

FOVFrame.Name = "AimbotFOV"

FOVFrame.AnchorPoint =
    Vector2.new(0.5, 0.5)

FOVFrame.BackgroundTransparency = 1

FOVFrame.Visible = false

FOVFrame.ZIndex = 5

FOVFrame.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")

FOVCorner.CornerRadius =
    UDim.new(1, 0)

FOVCorner.Parent =
    FOVFrame

local FOVStroke = Instance.new("UIStroke")

FOVStroke.Thickness = 1.5
FOVStroke.Color = Theme.Accent
FOVStroke.Transparency = 0.1

FOVStroke.Parent =
    FOVFrame

--==============================================================
-- CROSSHAIR
--==============================================================

local CrosshairFrame = Instance.new("Frame")

CrosshairFrame.Size =
    UDim2.new(0, 1, 0, 1)

CrosshairFrame.AnchorPoint =
    Vector2.new(0.5, 0.5)

CrosshairFrame.BackgroundTransparency = 1

CrosshairFrame.Visible = false

CrosshairFrame.Parent =
    ScreenGui

local function CreateCrosshairLine(
    Size,
    Position
)

    local Line = Instance.new("Frame")

    Line.Size = Size
    Line.Position = Position

    Line.AnchorPoint =
        Vector2.new(0.5, 0.5)

    Line.BackgroundColor3 =
        Color3.fromRGB(255, 255, 255)

    Line.BorderSizePixel = 0

    Line.Parent =
        CrosshairFrame

    return Line
end

local CrosshairLines = {
    Top = CreateCrosshairLine(
        UDim2.new(0, 2, 0, 8),
        UDim2.new(0.5, 0, 0.5, -7)
    ),

    Bottom = CreateCrosshairLine(
        UDim2.new(0, 2, 0, 8),
        UDim2.new(0.5, 0, 0.5, 7)
    ),

    Left = CreateCrosshairLine(
        UDim2.new(0, 8, 0, 2),
        UDim2.new(0.5, -7, 0.5, 0)
    ),

    Right = CreateCrosshairLine(
        UDim2.new(0, 8, 0, 2),
        UDim2.new(0.5, 7, 0.5, 0)
    )
}

--==============================================================
-- NOTIFICATION
--==============================================================

local NotificationContainer =
    Instance.new("Frame")

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

local function Notify(
    TitleText,
    DescriptionText
)

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

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent = Card

    local Stroke = Instance.new("UIStroke")

    Stroke.Color =
        Theme.Accent

    Stroke.Thickness = 1

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

    Title.Text =
        TitleText

    Title.TextColor3 =
        Theme.Accent

    Title.TextSize = 11
    Title.Font =
        Enum.Font.GothamBold

    Title.TextXAlignment =
        Enum.TextXAlignment.Left

    Title.Parent = Card

    local Description =
        Instance.new("TextLabel")

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

    Description.Text =
        DescriptionText

    Description.TextColor3 =
        Theme.Text

    Description.TextSize = 10

    Description.Font =
        Enum.Font.Gotham

    Description.TextXAlignment =
        Enum.TextXAlignment.Left

    Description.Parent = Card

    task.delay(3, function()

        if not Card.Parent then
            return
        end

        TweenService:Create(
            Card,
            TweenInfo.new(0.25),
            {
                BackgroundTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Title,
            TweenInfo.new(0.25),
            {
                TextTransparency = 1
            }
        ):Play()

        TweenService:Create(
            Description,
            TweenInfo.new(0.25),
            {
                TextTransparency = 1
            }
        ):Play()

        task.wait(0.25)

        if Card.Parent then
            Card:Destroy()
        end
    end)
end

--==============================================================
-- MAIN FRAME
--==============================================================

local MainFrame = Instance.new("Frame")

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

MainFrame.Parent =
    ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(0, 8)

MainCorner.Parent =
    MainFrame

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Color =
    Color3.fromRGB(
        40,
        42,
        58
    )

MainStroke.Thickness = 1.2

MainStroke.Parent =
    MainFrame

--==============================================================
-- HEADER
--==============================================================

local Header =
    Instance.new("Frame")

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

local Title =
    Instance.new("TextLabel")

Title.Size =
    UDim2.new(
        0,
        450,
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
    "VOID // ARCHITECT SUITE"

Title.TextColor3 =
    Theme.Accent

Title.TextSize = 13

Title.Font =
    Enum.Font.GothamBold

Title.TextXAlignment =
    Enum.TextXAlignment.Left

Title.Parent =
    Header

local Close =
    Instance.new("TextButton")

Close.Size =
    UDim2.new(
        0,
        28,
        0,
        28
    )

Close.Position =
    UDim2.new(
        1,
        -36,
        0.5,
        -14
    )

Close.BackgroundColor3 =
    Color3.fromRGB(
        239,
        68,
        68
    )

Close.BackgroundTransparency =
    0.85

Close.Text = "×"

Close.TextColor3 =
    Color3.fromRGB(
        248,
        113,
        113
    )

Close.TextSize = 18

Close.Font =
    Enum.Font.GothamBold

Close.Parent =
    Header

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(0, 6)

CloseCorner.Parent =
    Close

--==============================================================
-- SIDEBAR
--==============================================================

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

--==============================================================
-- CONTENT
--==============================================================

local Content =
    Instance.new("Frame")

Content.Size =
    UDim2.new(
        1,
        -145,
        1,
        -45
    )

Content.Position =
    UDim2.new(
        0,
        145,
        0,
        45
    )

Content.BackgroundTransparency = 1

Content.Parent =
    MainFrame

--==============================================================
-- TAB SYSTEM
--==============================================================

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

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(0, 6)

    Corner.Parent =
        Button

    local Scroll =
        Instance.new("ScrollingFrame")

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

    Scroll.Parent =
        Content

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

    local Data = {
        Button = Button,
        Scroll = Scroll
    }

    table.insert(
        Tabs,
        Data
    )

    Button.MouseButton1Click:Connect(function()

        for _, Tab in ipairs(Tabs) do

            Tab.Scroll.Visible = false

            Tab.Button.BackgroundTransparency =
                1

            Tab.Button.TextColor3 =
                Theme.SubText
        end

        Scroll.Visible = true

        Button.BackgroundColor3 =
            Theme.Card

        Button.BackgroundTransparency = 0

        Button.TextColor3 =
            Theme.Accent
    end)

    if #Tabs == 1 then

        Scroll.Visible = true

        Button.BackgroundColor3 =
            Theme.Card

        Button.BackgroundTransparency = 0

        Button.TextColor3 =
            Theme.Accent
    end

    return Scroll
end

--==============================================================
-- UI ELEMENTS
--==============================================================

local function AddToggle(
    Parent,
    Name,
    Description,
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

    local Label =
        Instance.new("TextLabel")

    Label.Size =
        UDim2.new(
            0.72,
            0,
            0,
            18
        )

    Label.Position =
        UDim2.new(
            0,
            10,
            0,
            5
        )

    Label.BackgroundTransparency = 1

    Label.Text =
        Name

    Label.TextColor3 =
        Theme.Text

    Label.TextSize = 11

    Label.Font =
        Enum.Font.GothamMedium

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Parent =
        Card

    local Desc =
        Instance.new("TextLabel")

    Desc.Size =
        UDim2.new(
            0.72,
            0,
            0,
            16
        )

    Desc.Position =
        UDim2.new(
            0,
            10,
            0,
            23
        )

    Desc.BackgroundTransparency = 1

    Desc.Text =
        Description

    Desc.TextColor3 =
        Theme.SubText

    Desc.TextSize = 9

    Desc.Font =
        Enum.Font.Gotham

    Desc.TextXAlignment =
        Enum.TextXAlignment.Left

    Desc.Parent =
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
        Theme.Track

    Button.Text = ""

    Button.Parent =
        Card

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(1, 0)

    ButtonCorner.Parent =
        Button

    local Dot =
        Instance.new("Frame")

    Dot.Size =
        UDim2.new(
            0,
            12,
            0,
            12
        )

    Dot.Position =
        UDim2.new(
            0,
            3,
            0.5,
            -6
        )

    Dot.BackgroundColor3 =
        Color3.fromRGB(
            180,
            180,
            200
        )

    Dot.BorderSizePixel = 0

    Dot.Parent =
        Button

    local DotCorner =
        Instance.new("UICorner")

    DotCorner.CornerRadius =
        UDim.new(1, 0)

    DotCorner.Parent =
        Dot

    local Enabled = false

    Button.MouseButton1Click:Connect(function()

        Enabled =
            not Enabled

        if Enabled then

            Dot.Position =
                UDim2.new(
                    1,
                    -15,
                    0.5,
                    -6
                )

            Button.BackgroundColor3 =
                Theme.Accent

        else

            Dot.Position =
                UDim2.new(
                    0,
                    3,
                    0.5,
                    -6
                )

            Button.BackgroundColor3 =
                Theme.Track
        end

        Callback(Enabled)
    end)
end

local function AddSlider(
    Parent,
    Name,
    Min,
    Max,
    Default,
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

    local Label =
        Instance.new("TextLabel")

    Label.Size =
        UDim2.new(
            0.6,
            0,
            0,
            18
        )

    Label.Position =
        UDim2.new(
            0,
            10,
            0,
            5
        )

    Label.BackgroundTransparency = 1

    Label.Text =
        Name

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
        tostring(Default)

    Input.TextColor3 =
        Theme.Accent

    Input.TextSize = 11

    Input.Font =
        Enum.Font.GothamBold

    Input.ClearTextOnFocus = false

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
        Theme.Track

    Track.BorderSizePixel = 0

    Track.Parent =
        Card

    local TrackCorner =
        Instance.new("UICorner")

    TrackCorner.CornerRadius =
        UDim.new(1, 0)

    TrackCorner.Parent =
        Track

    local Fill =
        Instance.new("Frame")

    Fill.Size =
        UDim2.new(
            math.clamp(
                (Default - Min) /
                (Max - Min),
                0,
                1
            ),
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
                Min,
                Max
            )

        Input.Text =
            tostring(Value)

        Fill.Size =
            UDim2.new(
                (
                    Value - Min
                ) /
                (
                    Max - Min
                ),
                0,
                1,
                0
            )

        Callback(Value)
    end

    local Dragging = false

    local function UpdateSlider(InputObject)

        local X =
            InputObject.Position.X -
            Track.AbsolutePosition.X

        local Percent =
            X /
            Track.AbsoluteSize.X

        Percent =
            math.clamp(
                Percent,
                0,
                1
            )

        SetValue(
            math.floor(
                Min +
                (
                    Max - Min
                ) *
                Percent
            )
        )
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
            SetValue(Default)
        end
    end)
end

local function AddButton(
    Parent,
    Name,
    Text,
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
        Name

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
        Text

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
    Name,
    Placeholder,
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
        Name

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
        Placeholder

    Input.TextColor3 =
        Theme.Text

    Input.TextSize = 10

    Input.Font =
        Enum.Font.Gotham

    Input.Parent =
        Card

    local Corner2 =
        Instance.new("UICorner")

    Corner2.CornerRadius =
        UDim.new(0, 4)

    Corner2.Parent =
        Input

    Input.FocusLost:Connect(
        function(EnterPressed)

            if EnterPressed then
                Callback(Input.Text)
            end
        end
    )
end

--==============================================================
-- TABS
--==============================================================

local TabPlayer =
    CreateTab("Jogador")

local TabMovement =
    CreateTab("Movimento")

local TabVisual =
    CreateTab("Visual")

local TabCombat =
    CreateTab("Combate")

local TabWaypoints =
    CreateTab("Waypoints")

local TabServer =
    CreateTab("Servidor")

local TabConfig =
    CreateTab("Configurações")

--==============================================================
-- PLAYER
--==============================================================

AddToggle(
    TabPlayer,
    "Super Velocidade",
    "Altera WalkSpeed.",
    function(Value)
        State.SpeedEnabled = Value
    end
)

AddSlider(
    TabPlayer,
    "Velocidade",
    16,
    400,
    State.WalkSpeed,
    function(Value)
        State.WalkSpeed = Value
    end
)

AddToggle(
    TabPlayer,
    "Super Pulo",
    "Altera JumpPower.",
    function(Value)
        State.JumpEnabled = Value
    end
)

AddSlider(
    TabPlayer,
    "Força do Pulo",
    50,
    500,
    State.JumpPower,
    function(Value)
        State.JumpPower = Value
    end
)

AddToggle(
    TabPlayer,
    "Pulo Infinito",
    "Permite pular no ar.",
    function(Value)
        State.InfiniteJump = Value
    end
)

AddToggle(
    TabPlayer,
    "Auto Bhop",
    "Pula automaticamente.",
    function(Value)
        State.Bhop = Value
    end
)

AddToggle(
    TabPlayer,
    "God Mode",
    "Mantém a vida cheia.",
    function(Value)
        State.GodMode = Value
    end
)

AddToggle(
    TabPlayer,
    "Infinite Zoom",
    "Aumenta o zoom máximo.",
    function(Value)

        State.InfiniteZoom = Value

        if Value then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance

        else

            LocalPlayer.CameraMaxZoomDistance =
                OriginalZoom
        end
    end
)

AddSlider(
    TabPlayer,
    "Zoom",
    16,
    1000,
    State.ZoomDistance,
    function(Value)

        State.ZoomDistance = Value

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                Value
        end
    end
)

AddToggle(
    TabPlayer,
    "Platform Stand",
    "Ativa PlatformStand.",
    function(Value)
        State.PlatformStand = Value
    end
)

AddToggle(
    TabPlayer,
    "HipHeight",
    "Altera altura.",
    function(Value)
        State.HipHeightEnabled = Value
    end
)

AddSlider(
    TabPlayer,
    "HipHeight",
    0,
    30,
    State.HipHeight,
    function(Value)
        State.HipHeight = Value
    end
)

--==============================================================
-- MOVEMENT
--==============================================================

AddToggle(
    TabMovement,
    "Fly",
    "Movimentação aérea.",
    function(Value)
        State.FlyEnabled = Value
    end
)

AddSlider(
    TabMovement,
    "Fly Speed",
    20,
    350,
    State.FlySpeed,
    function(Value)
        State.FlySpeed = Value
    end
)

AddToggle(
    TabMovement,
    "Noclip",
    "Atravessa partes.",
    function(Value)
        State.Noclip = Value
    end
)

AddToggle(
    TabMovement,
    "Low Gravity",
    "Reduz a gravidade.",
    function(Value)

        State.LowGravity = Value

        if not Value then

            workspace.Gravity =
                OriginalGravity
        end
    end
)

AddSlider(
    TabMovement,
    "Gravidade",
    0,
    196,
    State.Gravity,
    function(Value)

        State.Gravity = Value
    end
)

AddToggle(
    TabMovement,
    "Spinbot",
    "Gira o personagem.",
    function(Value)
        State.Spinbot = Value
    end
)

AddSlider(
    TabMovement,
    "Spin Speed",
    1,
    100,
    State.SpinSpeed,
    function(Value)
        State.SpinSpeed = Value
    end
)

AddToggle(
    TabMovement,
    "Anti-Fling",
    "Bloqueia velocidades extremas.",
    function(Value)
        State.AntiFling = Value
    end
)

--==============================================================
-- VISUAL
--==============================================================

AddToggle(
    TabVisual,
    "ESP",
    "Highlight dos jogadores.",
    function(Value)
        State.ESP = Value
    end
)

AddToggle(
    TabVisual,
    "Fullbright",
    "Ilumina o mapa.",
    function(Value)

        State.Fullbright = Value

        if not Value then

            Lighting.Ambient =
                OriginalAmbient

            Lighting.Brightness =
                OriginalBrightness
        end
    end
)

AddToggle(
    TabVisual,
    "No Fog",
    "Remove fog.",
    function(Value)

        State.NoFog = Value

        if not Value then

            Lighting.FogEnd =
                OriginalFogEnd
        end
    end
)

AddToggle(
    TabVisual,
    "Custom FOV",
    "Muda campo de visão.",
    function(Value)

        State.CustomFOV = Value

        if not Value then

            GetCamera().FieldOfView =
                OriginalFOV
        end
    end
)

AddSlider(
    TabVisual,
    "FOV",
    70,
    130,
    State.FOV,
    function(Value)
        State.FOV = Value
    end
)

AddToggle(
    TabVisual,
    "Crosshair",
    "Mira no centro.",
    function(Value)

        State.Crosshair = Value
        CrosshairFrame.Visible = Value
    end
)

AddToggle(
    TabVisual,
    "FPS Counter",
    "Mostra FPS.",
    function(Value)

        State.FPS = Value
        FPSLabel.Visible = Value
    end
)

--==============================================================
-- COMBAT
--==============================================================

AddToggle(
    TabCombat,
    "Aimbot",
    "Seleciona alvo próximo da mira.",
    function(Value)

        State.Aimbot = Value
    end
)

AddToggle(
    TabCombat,
    "Hold Mode",
    "Só funciona segurando a tecla.",
    function(Value)

        State.AimbotHold = Value
    end
)

local AimKeyButton

AimKeyButton =
    AddButton(
        TabCombat,
        "Tecla do Aimbot",
        State.AimbotKey.Name,
        function()

            Notify(
                "Aimbot",
                "Pressione a nova tecla."
            )

            ListeningFor =
                "AIM"
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
    "Mostra o alcance.",
    function(Value)

        State.ShowFOVCircle =
            Value
    end
)

AddSlider(
    TabCombat,
    "Aimbot FOV",
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
    "Trocar Alvo",
    "Head / Torso",
    function()

        if State.AimPart == "Head" then

            State.AimPart =
                "HumanoidRootPart"

        else

            State.AimPart =
                "Head"
        end

        Notify(
            "Aimbot",
            "Alvo: " ..
                State.AimPart
        )
    end
)

--==============================================================
-- WAYPOINTS
--==============================================================

AddTextBox(
    TabWaypoints,
    "Novo Waypoint",
    "Nome...",
    function(Text)

        if Text == "" then
            return
        end

        local Character =
            LocalPlayer.Character

        local Root =
            Character and
            Character:FindFirstChild(
                "HumanoidRootPart"
            )

        if not Root then
            return
        end

        table.insert(
            State.Waypoints,
            {
                Name = Text,
                Position = Root.Position
            }
        )

        Notify(
            "Waypoint",
            "Salvo: " .. Text
        )
    end
)

AddButton(
    TabWaypoints,
    "Último Waypoint",
    "Ir",
    function()

        local Waypoint =
            State.Waypoints[
                #State.Waypoints
            ]

        if not Waypoint then

            Notify(
                "Waypoint",
                "Nenhum waypoint."
            )

            return
        end

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
            "Waypoint",
            "Lista limpa."
        )
    end
)

--==============================================================
-- SERVER
--==============================================================

AddToggle(
    TabServer,
    "Anti-AFK",
    "Evita desconexão.",
    function(Value)

        State.AntiAFK = Value
    end
)

AddButton(
    TabServer,
    "Rejoin",
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

--==============================================================
-- CONFIG
--==============================================================

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

--==============================================================
-- KEYBOARD
--==============================================================

UserInputService.InputBegan:Connect(
    function(Input, Processed)

        if ListeningFor then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                if ListeningFor == "PANEL" then

                    TOGGLE_KEY =
                        Input.KeyCode

                    PanelKeyButton.Text =
                        Input.KeyCode.Name

                elseif ListeningFor == "AIM" then

                    State.AimbotKey =
                        Input.KeyCode

                    AimKeyButton.Text =
                        Input.KeyCode.Name
                end

                ListeningFor = nil
            end

            return
        end

        if
            not Processed
            and
            Input.KeyCode ==
                TOGGLE_KEY
        then

            MainFrame.Visible =
                not MainFrame.Visible

            UpdateMouse()
        end
    end
)

--==============================================================
-- INFINITE JUMP
--==============================================================

UserInputService.JumpRequest:Connect(function()

    if not State.InfiniteJump then
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

--==============================================================
-- CLICK TELEPORT
--==============================================================

Mouse.Button1Down:Connect(function()

    if not State.ClickTeleport then
        return
    end

    if not UserInputService:IsKeyDown(
        Enum.KeyCode.LeftControl
    ) then
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

--==============================================================
-- FPS
--==============================================================

local FPSFrames = 0
local FPSTimer = os.clock()

--==============================================================
-- ESP
--==============================================================

local ESPObjects = {}

local function RemoveESP(Player)

    local Highlight =
        ESPObjects[Player]

    if Highlight then

        if Highlight.Parent then
            Highlight:Destroy()
        end

        ESPObjects[Player] = nil
    end
end

local function UpdateESP(Player)

    if Player == LocalPlayer then
        return
    end

    local Character =
        Player.Character

    if not Character then

        RemoveESP(Player)

        return
    end

    if not State.ESP then

        RemoveESP(Player)

        return
    end

    local Highlight =
        ESPObjects[Player]

    if not Highlight then

        Highlight =
            Instance.new("Highlight")

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
            Character

        ESPObjects[Player] =
            Highlight
    else

        Highlight.FillColor =
            Theme.Accent
    end
end

Players.PlayerRemoving:Connect(
    function(Player)

        RemoveESP(Player)
    end
)

--==============================================================
-- MAIN LOOP
--==============================================================

RunService.RenderStepped:Connect(function()

    GetCamera()

    --============================================================
    -- MOUSE
    --============================================================

    UpdateMouse()

    --============================================================
    -- FPS
    --============================================================

    FPSFrames += 1

    if os.clock() - FPSTimer >= 1 then

        FPSLabel.Text =
            "FPS: " ..
            tostring(
                FPSFrames
            )

        FPSFrames = 0
        FPSTimer = os.clock()
    end

    --============================================================
    -- CHARACTER
    --============================================================

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

    --============================================================
    -- PLAYER
    --============================================================

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

        Humanoid.PlatformStand =
            State.PlatformStand

        if State.HipHeightEnabled then

            Humanoid.HipHeight =
                State.HipHeight
        end

        if
            State.Bhop
            and
            Humanoid.FloorMaterial ~=
                Enum.Material.Air
            and
            UserInputService:IsKeyDown(
                Enum.KeyCode.Space
            )
        then

            Humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end

    --============================================================
    -- ZOOM
    --============================================================

    if State.InfiniteZoom then

        LocalPlayer.CameraMaxZoomDistance =
            State.ZoomDistance
    end

    --============================================================
    -- GRAVITY
    --============================================================

    if State.LowGravity then

        workspace.Gravity =
            State.Gravity
    end

    --============================================================
    -- FLY
    --============================================================

    if
        State.FlyEnabled
        and
        Root
    then

        local Direction =
            Vector3.zero

        local CameraCF =
            Camera.CFrame

        if UserInputService:IsKeyDown(
            Enum.KeyCode.W
        ) then

            Direction +=
                CameraCF.LookVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.S
        ) then

            Direction -=
                CameraCF.LookVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.A
        ) then

            Direction -=
                CameraCF.RightVector
        end

        if UserInputService:IsKeyDown(
            Enum.KeyCode.D
        ) then

            Direction +=
                CameraCF.RightVector
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

        Root.AssemblyLinearVelocity =
            Direction *
            State.FlySpeed
    end

    --============================================================
    -- ANTI FLING
    --============================================================

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

    --============================================================
    -- SPIN
    --============================================================

    if
        State.Spinbot
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

    --============================================================
    -- NOCLIP
    --============================================================

    if
        State.Noclip
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

    --============================================================
    -- FULLBRIGHT
    --============================================================

    if State.Fullbright then

        Lighting.Ambient =
            Color3.fromRGB(
                255,
                255,
                255
            )

        Lighting.Brightness = 2
    end

    --============================================================
    -- NO FOG
    --============================================================

    if State.NoFog then

        Lighting.FogEnd =
            1000000
    end

    --============================================================
    -- FOV
    --============================================================

    if State.CustomFOV then

        Camera.FieldOfView =
            State.FOV
    end

    --============================================================
    -- CROSSHAIR
    --============================================================

    CrosshairFrame.Position =
        UDim2.new(
            0,
            Camera.ViewportSize.X / 2,
            0,
            Camera.ViewportSize.Y / 2
        )

    --============================================================
    -- AIM FOV
    --============================================================

    if State.ShowFOVCircle then

        local Center =
            GetAimPosition()

        FOVFrame.Position =
            UDim2.new(
                0,
                Center.X,
                0,
                Center.Y
            )

        FOVFrame.Size =
            UDim2.new(
                0,
                State.AimbotFOV * 2,
                0,
                State.AimbotFOV * 2
            )

        FOVFrame.Visible = true

    else

        FOVFrame.Visible = false
    end

    --============================================================
    -- ESP
    --============================================================

    for _, Player in ipairs(
        Players:GetPlayers()
    ) do

        if Player ~= LocalPlayer then
            UpdateESP(Player)
        end
    end
end)

--==============================================================
-- AIMBOT
--==============================================================

RunService:BindToRenderStep(
    "ArchitectAimbot",
    Enum.RenderPriority.Camera.Value + 10,
    function()

        if not State.Aimbot then
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

        local CameraObject =
            workspace.CurrentCamera

        if not CameraObject then
            return
        end

        local AimPosition =
            GetAimPosition()

        local Target = nil
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
                    Character:FindFirstChildOfClass(
                        "Humanoid"
                    )

                local AimPart =
                    Character:FindFirstChild(
                        State.AimPart
                    )

                if
                    Humanoid
                    and
                    Humanoid.Health > 0
                    and
                    AimPart
                then

                    local Position,
                        Visible =
                        CameraObject:
                            WorldToViewportPoint(
                                AimPart.Position
                            )

                    if Visible then

                        local ScreenPoint =
                            Vector2.new(
                                Position.X,
                                Position.Y
                            )

                        local Distance =
                            (
                                ScreenPoint -
                                AimPosition
                            ).Magnitude

                        if
                            Distance <
                            ClosestDistance
                        then

                            ClosestDistance =
                                Distance

                            Target =
                                AimPart
                        end
                    end
                end
            end
        end

        if not Target then
            return
        end

        local CameraPosition =
            CameraObject.CFrame.Position

        local TargetCFrame =
            CFrame.lookAt(
                CameraPosition,
                Target.Position
            )

        CameraObject.CFrame =
            CameraObject.CFrame:Lerp(
                TargetCFrame,
                math.clamp(
                    State.AimbotSmoothness,
                    0.01,
                    1
                )
            )
    end
)

--==============================================================
-- INITIALIZATION
--==============================================================

MainFrame.Visible = true

UpdateMouse()

Notify(
    "VOID ARCHITECT",
    "Sistema inicializado."
)
```
