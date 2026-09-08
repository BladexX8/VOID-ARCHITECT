--[[
====================================================================
VOID ARCHITECT // ULTIMATE CLIENT SUITE v5.1
====================================================================

UI
- RightControl = painel
- Mouse livre com painel aberto
- Mouse livre em terceira pessoa
- Mouse preso somente em primeira pessoa

PLAYER
- Speed
- Jump
- Infinite Jump
- Bhop
- God Mode local
- HipHeight
- Infinite Zoom
- Platform Stand
- Click Teleport

MOVEMENT
- Fly
- Noclip
- Low Gravity
- Blink
- Spinbot
- Anti-Fling

VISUAL
- ESP Highlight
- ESP Nome
- ESP Distância
- ESP Tracer
- Fullbright
- NoFog
- Custom FOV
- Crosshair
- Aimbot FOV
- FPS Counter

COMBAT
- Aimbot
- Hold Mode
- Aim Key
- Aim FOV
- Aim Smoothness
- Head / Torso
- Triggerbot
- Hitbox Visual

SERVER
- Anti-AFK
- Rejoin
- Server Hop

UTILITY
- Waypoints
- Themes
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

local OldUI =
    PlayerGui:FindFirstChild(
        "ArchitectSuiteUI"
    )

if OldUI then
    OldUI:Destroy()
end

pcall(function()
    RunService:UnbindFromRenderStep(
        "VOID_Aimbot"
    )
end)

--==================================================================
-- THEME
--==================================================================

local Theme = {

    BG =
        Color3.fromRGB(
            10,
            11,
            16
        ),

    Header =
        Color3.fromRGB(
            16,
            17,
            24
        ),

    Sidebar =
        Color3.fromRGB(
            14,
            15,
            21
        ),

    Card =
        Color3.fromRGB(
            20,
            22,
            30
        ),

    Track =
        Color3.fromRGB(
            40,
            42,
            58
        ),

    Accent =
        Color3.fromRGB(
            138,
            92,
            246
        ),

    Text =
        Color3.fromRGB(
            243,
            244,
            246
        ),

    SubText =
        Color3.fromRGB(
            156,
            163,
            175
        )
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

    InfiniteJump = false,
    Bhop = false,

    GodMode = false,

    ClickTeleport = false,

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
    ESPDistance = true,
    ESPTracers = false,

    Fullbright = false,
    NoFog = false,

    CustomFOV = false,
    FOVValue = 90,

    CrosshairEnabled = false,

    ShowAimbotFOV = false,

    FPSCounter = false,

    -- COMBAT

    AimbotEnabled = false,
    AimbotHold = false,

    AimbotKey =
        Enum.KeyCode.LeftAlt,

    AimbotFOV = 150,

    AimbotSmoothness = 0.2,

    AimPart = "Head",

    TriggerbotEnabled = false,

    TriggerCooldown = 0.15,

    HitboxEnabled = false,

    HitboxSize = 10,

    -- SERVER

    AntiAFK = false,

    -- WAYPOINTS

    Waypoints = {},

    -- KEY CONFIG

    WaitingPanelKey = false,
    WaitingAimKey = false
}

--==================================================================
-- ORIGINAL VALUES
--==================================================================

local OriginalGravity =
    workspace.Gravity

local OriginalFogEnd =
    Lighting.FogEnd

local OriginalAmbient =
    Lighting.Ambient

local OriginalBrightness =
    Lighting.Brightness

local OriginalFOV =
    Camera.FieldOfView

local OriginalZoom =
    LocalPlayer.CameraMaxZoomDistance

--==================================================================
-- CAMERA HELPERS
--==================================================================

local function GetCamera()

    Camera =
        workspace.CurrentCamera
        or Camera

    return Camera
end

local function GetCharacter()

    return LocalPlayer.Character
end

local function GetHumanoid()

    local Character =
        GetCharacter()

    if not Character then
        return nil
    end

    return Character:
        FindFirstChildOfClass(
            "Humanoid"
        )
end

local function GetRoot()

    local Character =
        GetCharacter()

    if not Character then
        return nil
    end

    return Character:
        FindFirstChild(
            "HumanoidRootPart"
        )
end

local function IsFirstPerson()

    local CameraObject =
        GetCamera()

    local Character =
        GetCharacter()

    if
        not CameraObject
        or
        not Character
    then
        return false
    end

    local Head =
        Character:FindFirstChild(
            "Head"
        )

    if not Head then
        return false
    end

    return (
        CameraObject.CFrame.Position -
        Head.Position
    ).Magnitude <= 1.25
end

local function GetAimPosition()

    local CameraObject =
        GetCamera()

    if IsFirstPerson() then

        return Vector2.new(
            CameraObject.ViewportSize.X / 2,
            CameraObject.ViewportSize.Y / 2
        )
    end

    return UserInputService:
        GetMouseLocation()
end

--==================================================================
-- GUI
--==================================================================

local ScreenGui =
    Instance.new("ScreenGui")

ScreenGui.Name =
    "ArchitectSuiteUI"

ScreenGui.ResetOnSpawn =
    false

ScreenGui.ZIndexBehavior =
    Enum.ZIndexBehavior.Sibling

ScreenGui.Parent =
    PlayerGui

--==================================================================
-- MAIN FRAME
--==================================================================

local MainFrame =
    Instance.new("Frame")

MainFrame.Name =
    "MainFrame"

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

MainFrame.BorderSizePixel =
    0

MainFrame.Active =
    true

MainFrame.Draggable =
    true

MainFrame.Parent =
    ScreenGui

local MainCorner =
    Instance.new("UICorner")

MainCorner.CornerRadius =
    UDim.new(
        0,
        8
    )

MainCorner.Parent =
    MainFrame

local MainStroke =
    Instance.new("UIStroke")

MainStroke.Thickness =
    1.2

MainStroke.Color =
    Color3.fromRGB(
        40,
        42,
        58
    )

MainStroke.Parent =
    MainFrame

--==================================================================
-- HEADER
--==================================================================

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

Header.BorderSizePixel =
    0

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

Title.BackgroundTransparency =
    1

Title.Text =
    "VOID // ARCHITECT SUITE v5.1"

Title.TextColor3 =
    Theme.Accent

Title.TextSize =
    13

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

CloseButton.Text =
    "×"

CloseButton.TextColor3 =
    Color3.fromRGB(
        248,
        113,
        113
    )

CloseButton.TextSize =
    18

CloseButton.Font =
    Enum.Font.GothamBold

CloseButton.Parent =
    Header

local CloseCorner =
    Instance.new("UICorner")

CloseCorner.CornerRadius =
    UDim.new(
        0,
        6
    )

CloseCorner.Parent =
    CloseButton

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

Sidebar.BorderSizePixel =
    0

Sidebar.Parent =
    MainFrame

local SidebarLayout =
    Instance.new("UIListLayout")

SidebarLayout.Padding =
    UDim.new(
        0,
        4
    )

SidebarLayout.Parent =
    Sidebar

local SidebarPadding =
    Instance.new("UIPadding")

SidebarPadding.PaddingTop =
    UDim.new(
        0,
        10
    )

SidebarPadding.PaddingLeft =
    UDim.new(
        0,
        8
    )

SidebarPadding.PaddingRight =
    UDim.new(
        0,
        8
    )

SidebarPadding.Parent =
    Sidebar

--==================================================================
-- CONTENT
--==================================================================

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

Content.BackgroundTransparency =
    1

Content.Parent =
    MainFrame

--==================================================================
-- TAB SYSTEM
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

    Button.BackgroundTransparency =
        1

    Button.Text =
        "  " .. Name

    Button.TextColor3 =
        Theme.SubText

    Button.TextSize =
        11

    Button.Font =
        Enum.Font.GothamMedium

    Button.TextXAlignment =
        Enum.TextXAlignment.Left

    Button.Parent =
        Sidebar

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            6
        )

    Corner.Parent =
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

    Scroll.BackgroundTransparency =
        1

    Scroll.BorderSizePixel =
        0

    Scroll.ScrollBarThickness =
        3

    Scroll.ScrollBarImageColor3 =
        Theme.Accent

    Scroll.Visible =
        false

    Scroll.CanvasSize =
        UDim2.new(
            0,
            0,
            0,
            0
        )

    Scroll.Parent =
        Content

    local Layout =
        Instance.new("UIListLayout")

    Layout.Padding =
        UDim.new(
            0,
            8
        )

    Layout.Parent =
        Scroll

    Layout:GetPropertyChangedSignal(
        "AbsoluteContentSize"
    ):Connect(
        function()

            Scroll.CanvasSize =
                UDim2.new(
                    0,
                    0,
                    0,
                    Layout.AbsoluteContentSize.Y + 20
                )
        end
    )

    Button.MouseButton1Click:Connect(
        function()

            for _, Tab in ipairs(Tabs) do

                Tab.Scroll.Visible =
                    false

                Tab.Button.BackgroundTransparency =
                    1

                Tab.Button.TextColor3 =
                    Theme.SubText
            end

            Scroll.Visible =
                true

            Button.BackgroundColor3 =
                Theme.Card

            Button.BackgroundTransparency =
                0

            Button.TextColor3 =
                Theme.Accent
        end
    )

    local Data = {
        Button = Button,
        Scroll = Scroll
    }

    table.insert(
        Tabs,
        Data
    )

    if #Tabs == 1 then

        Scroll.Visible =
            true

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
-- TOGGLE
--==================================================================

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

    Card.BorderSizePixel =
        0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            6
        )

    Corner.Parent =
        Card

    local Label =
        Instance.new("TextLabel")

    Label.Size =
        UDim2.new(
            0.7,
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

    Label.BackgroundTransparency =
        1

    Label.Text =
        Name

    Label.TextColor3 =
        Theme.Text

    Label.TextSize =
        11

    Label.Font =
        Enum.Font.GothamMedium

    Label.TextXAlignment =
        Enum.TextXAlignment.Left

    Label.Parent =
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
        Description

    DescriptionLabel.TextColor3 =
        Theme.SubText

    DescriptionLabel.TextSize =
        9

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
        Theme.Track

    Button.Text = ""

    Button.Parent =
        Card

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

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

    Dot.BorderSizePixel =
        0

    Dot.Parent =
        Button

    local DotCorner =
        Instance.new("UICorner")

    DotCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

    DotCorner.Parent =
        Dot

    local Enabled =
        false

    Button.MouseButton1Click:Connect(
        function()

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
        end
    )
end

--==================================================================
-- SLIDER
--==================================================================

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

    Card.BorderSizePixel =
        0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            6
        )

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

    Label.BackgroundTransparency =
        1

    Label.Text =
        Name

    Label.TextColor3 =
        Theme.Text

    Label.TextSize =
        11

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

    Input.BorderSizePixel =
        0

    Input.Text =
        tostring(Default)

    Input.TextColor3 =
        Theme.Accent

    Input.TextSize =
        11

    Input.Font =
        Enum.Font.GothamBold

    Input.ClearTextOnFocus =
        false

    Input.Parent =
        Card

    local InputCorner =
        Instance.new("UICorner")

    InputCorner.CornerRadius =
        UDim.new(
            0,
            4
        )

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

    Track.BorderSizePixel =
        0

    Track.Parent =
        Card

    local TrackCorner =
        Instance.new("UICorner")

    TrackCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

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

    Fill.BorderSizePixel =
        0

    Fill.Parent =
        Track

    local FillCorner =
        Instance.new("UICorner")

    FillCorner.CornerRadius =
        UDim.new(
            1,
            0
        )

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

    local Dragging =
        false

    local function UpdateSlider(
        InputObject
    )

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

                Dragging =
                    true

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

                Dragging =
                    false
            end
        end
    )

    Input.FocusLost:Connect(
        function()

            local Number =
                tonumber(Input.Text)

            if Number then

                SetValue(Number)

            else

                SetValue(Default)
            end
        end
    )
end

--==================================================================
-- BUTTON
--==================================================================

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

    Card.BorderSizePixel =
        0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            6
        )

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

    Label.BackgroundTransparency =
        1

    Label.Text =
        Name

    Label.TextColor3 =
        Theme.Text

    Label.TextSize =
        11

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

    Button.TextSize =
        10

    Button.Font =
        Enum.Font.GothamBold

    Button.Parent =
        Card

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(
            0,
            4
        )

    ButtonCorner.Parent =
        Button

    Button.MouseButton1Click:Connect(
        Callback
    )

    return Button
end

--==================================================================
-- WAYPOINT INPUT
--==================================================================

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

    Card.BorderSizePixel =
        0

    Card.Parent =
        Parent

    local Corner =
        Instance.new("UICorner")

    Corner.CornerRadius =
        UDim.new(
            0,
            6
        )

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

    Label.BackgroundTransparency =
        1

    Label.Text =
        Name

    Label.TextColor3 =
        Theme.Text

    Label.TextSize =
        11

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

    Input.BorderSizePixel =
        0

    Input.PlaceholderText =
        Placeholder

    Input.TextColor3 =
        Theme.Text

    Input.TextSize =
        10

    Input.Font =
        Enum.Font.Gotham

    Input.Parent =
        Card

    local InputCorner =
        Instance.new("UICorner")

    InputCorner.CornerRadius =
        UDim.new(
            0,
            4
        )

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
-- CREATE TABS
--==================================================================

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

--==================================================================
-- PLAYER
--==================================================================

AddToggle(
    TabPlayer,
    "Super Velocidade",
    "Aumenta WalkSpeed.",
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
    "Aumenta JumpPower.",
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

        State.InfiniteJump =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Auto Bhop",
    "Pulo automático.",
    function(Value)

        State.Bhop =
            Value
    end
)

AddToggle(
    TabPlayer,
    "God Mode Local",
    "Mantém a vida cheia.",
    function(Value)

        State.GodMode =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Click Teleport",
    "Ctrl + clique para teleportar.",
    function(Value)

        State.ClickTeleport =
            Value
    end
)

AddToggle(
    TabPlayer,
    "HipHeight",
    "Ativa altura personalizada.",
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
    "Infinite Zoom",
    "Aumenta o zoom máximo.",
    function(Value)

        State.InfiniteZoom =
            Value

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
    "Distância da Câmera",
    16,
    1000,
    State.ZoomDistance,
    function(Value)

        State.ZoomDistance =
            Value
    end
)

AddToggle(
    TabPlayer,
    "Platform Stand",
    "Ativa PlatformStand.",
    function(Value)

        State.PlatformStand =
            Value
    end
)

--==================================================================
-- MOVEMENT
--==================================================================

AddToggle(
    TabMovement,
    "Fly",
    "Movimento aéreo.",
    function(Value)

        State.FlyEnabled =
            Value
    end
)

AddSlider(
    TabMovement,
    "Fly Speed",
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
    "Atravessa partes.",
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
                OriginalGravity
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
    "Gira continuamente.",
    function(Value)

        State.SpinbotEnabled =
            Value
    end
)

AddSlider(
    TabMovement,
    "Spin Speed",
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
    "Ativa ESP.",
    function(Value)

        State.ESPEnabled =
            Value
    end
)

AddToggle(
    TabVisual,
    "ESP Names",
    "Mostra nome.",
    function(Value)

        State.ESPNames =
            Value
    end
)

AddToggle(
    TabVisual,
    "ESP Distance",
    "Mostra distância.",
    function(Value)

        State.ESPDistance =
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
    "Ilumina o mapa.",
    function(Value)

        State.Fullbright =
            Value

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
    "Remove neblina.",
    function(Value)

        State.NoFog =
            Value

        if not Value then

            Lighting.FogEnd =
                OriginalFogEnd
        end
    end
)

AddToggle(
    TabVisual,
    "Custom FOV",
    "Muda FOV.",
    function(Value)

        State.CustomFOV =
            Value

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
    State.FOVValue,
    function(Value)

        State.FOVValue =
            Value
    end
)

AddToggle(
    TabVisual,
    "Crosshair",
    "Mira central.",
    function(Value)

        State.CrosshairEnabled =
            Value
    end
)

AddToggle(
    TabVisual,
    "Mostrar Aim FOV",
    "Mostra área do aimbot.",
    function(Value)

        State.ShowAimbotFOV =
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
    end
)

--==================================================================
-- COMBAT
--==================================================================

AddToggle(
    TabCombat,
    "Aimbot",
    "Seleciona alvo próximo da mira.",
    function(Value)

        State.AimbotEnabled =
            Value
    end
)

AddToggle(
    TabCombat,
    "Hold Mode",
    "Só funciona segurando a tecla.",
    function(Value)

        State.AimbotHold =
            Value
    end
)

local AimKeyButton =
    AddButton(
        TabCombat,
        "Tecla do Aimbot",
        State.AimbotKey.Name,
        function()

            State.WaitingAimKey =
                true

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
    "Parte do Alvo",
    "Head / Torso",
    function()

        if State.AimPart ==
            "Head"
        then

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

AddToggle(
    TabCombat,
    "Triggerbot",
    "Ativa a ferramenta equipada sobre um alvo.",
    function(Value)

        State.TriggerbotEnabled =
            Value
    end
)

AddToggle(
    TabCombat,
    "Hitbox Visual",
    "Mostra uma área maior sobre os jogadores.",
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
    "Waypoint",
    "Nome...",
    function(Text)

        if Text == "" then
            return
        end

        local Root =
            GetRoot()

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

        local Root =
            GetRoot()

        if Waypoint
            and
            Root
        then

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

        State.Waypoints =
            {}

        Notify(
            "Waypoint",
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
    "Ativa proteção contra AFK.",
    function(Value)

        State.AntiAFK =
            Value
    end
)

AddButton(
    TabServer,
    "Rejoin",
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
    TabServer,
    "Server Hop",
    "Hop",
    function()

        Notify(
            "Servidor",
            "Trocando servidor..."
        )

        TeleportService:
            Teleport(
                game.PlaceId,
                LocalPlayer
            )
    end
)

--==================================================================
-- CONFIG
--==================================================================

local PanelKeyButton =
    AddButton(
        TabConfig,
        "Atalho do Painel",
        "RightControl",
        function()

            State.WaitingPanelKey =
                true

            PanelKeyButton.Text =
                "Pressione..."
        end
    )

local function ApplyTheme(
    Color
)

    Theme.Accent =
        Color

    Title.TextColor3 =
        Color

    FOVDisplayStroke.Color =
        Color

    FPSLabel.TextColor3 =
        Color

    for _, Tab in ipairs(Tabs) do

        Tab.Scroll.ScrollBarImageColor3 =
            Color

        if Tab.Scroll.Visible then

            Tab.Button.TextColor3 =
                Color
        end
    end
end

AddButton(
    TabConfig,
    "Tema Roxo",
    "Aplicar",
    function()

        ApplyTheme(
            Color3.fromRGB(
                138,
                92,
                246
            )
        )
    end
)

AddButton(
    TabConfig,
    "Tema Azul",
    "Aplicar",
    function()

        ApplyTheme(
            Color3.fromRGB(
                14,
                165,
                233
            )
        )
    end
)

AddButton(
    TabConfig,
    "Tema Verde",
    "Aplicar",
    function()

        ApplyTheme(
            Color3.fromRGB(
                34,
                197,
                94
            )
        )
    end
)

AddButton(
    TabConfig,
    "Tema Vermelho",
    "Aplicar",
    function()

        ApplyTheme(
            Color3.fromRGB(
                239,
                68,
                68
            )
        )
    end
)

AddButton(
    TabConfig,
    "Tema Ouro",
    "Aplicar",
    function()

        ApplyTheme(
            Color3.fromRGB(
                234,
                179,
                8
            )
        )
    end
)

--==================================================================
-- CROSSHAIR
--==================================================================

local Crosshair =
    Instance.new("Frame")

Crosshair.Size =
    UDim2.new(
        0,
        1,
        0,
        1
    )

Crosshair.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

Crosshair.BackgroundTransparency =
    1

Crosshair.Parent =
    ScreenGui

local function CreateCrossLine(
    Size,
    Position
)

    local Line =
        Instance.new("Frame")

    Line.Size =
        Size

    Line.Position =
        Position

    Line.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Line.BackgroundColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    Line.BorderSizePixel =
        0

    Line.Parent =
        Crosshair
end

CreateCrossLine(
    UDim2.new(
        0,
        2,
        0,
        8
    ),
    UDim2.new(
        0.5,
        0,
        0.5,
        -7
    )
)

CreateCrossLine(
    UDim2.new(
        0,
        2,
        0,
        8
    ),
    UDim2.new(
        0.5,
        0,
        0.5,
        7
    )
)

CreateCrossLine(
    UDim2.new(
        0,
        8,
        0,
        2
    ),
    UDim2.new(
        0.5,
        -7,
        0.5,
        0
    )
)

CreateCrossLine(
    UDim2.new(
        0,
        8,
        0,
        2
    ),
    UDim2.new(
        0.5,
        7,
        0.5,
        0
    )
)

--==================================================================
-- FOV
--==================================================================

local FOVDisplay =
    Instance.new("Frame")

FOVDisplay.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

FOVDisplay.BackgroundTransparency =
    1

FOVDisplay.Visible =
    false

FOVDisplay.Parent =
    ScreenGui

local FOVDisplayCorner =
    Instance.new("UICorner")

FOVDisplayCorner.CornerRadius =
    UDim.new(
        1,
        0
    )

FOVDisplayCorner.Parent =
    FOVDisplay

local FOVDisplayStroke =
    Instance.new("UIStroke")

FOVDisplayStroke.Thickness =
    1.5

FOVDisplayStroke.Color =
    Theme.Accent

FOVDisplayStroke.Parent =
    FOVDisplay

--==================================================================
-- FPS
--==================================================================

local FPSLabel =
    Instance.new("TextLabel")

FPSLabel.Size =
    UDim2.new(
        0,
        120,
        0,
        25
    )

FPSLabel.Position =
    UDim2.new(
        0,
        10,
        0,
        10
    )

FPSLabel.BackgroundTransparency =
    1

FPSLabel.Text =
    "FPS: --"

FPSLabel.TextColor3 =
    Theme.Accent

FPSLabel.TextSize =
    12

FPSLabel.Font =
    Enum.Font.GothamBold

FPSLabel.TextXAlignment =
    Enum.TextXAlignment.Left

FPSLabel.Visible =
    false

FPSLabel.Parent =
    ScreenGui

--==================================================================
-- ESP
--==================================================================

local ESPObjects = {}

local function RemoveESP(
    Player
)

    local Data =
        ESPObjects[Player]

    if not Data then
        return
    end

    if Data.Highlight then
        Data.Highlight:Destroy()
    end

    if Data.Billboard then
        Data.Billboard:Destroy()
    end

    if Data.Beam then
        Data.Beam:Destroy()
    end

    if Data.PlayerAttachment then
        Data.PlayerAttachment:Destroy()
    end

    if Data.TracerAttachment then
        Data.TracerAttachment:Destroy()
    end

    ESPObjects[Player] = nil
end

local function UpdateESP(
    Player
)

    if Player == LocalPlayer then
        return
    end

    local Character =
        Player.Character

    if not Character
        or
        not State.ESPEnabled
    then

        RemoveESP(Player)

        return
    end

    local Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    local Humanoid =
        Character:FindFirstChildOfClass(
            "Humanoid"
        )

    if not Root
        or
        not Humanoid
        or
        Humanoid.Health <= 0
    then

        RemoveESP(Player)

        return
    end

    local Data =
        ESPObjects[Player]

    if not Data then

        Data = {}

        --==========================================================
        -- HIGHLIGHT
        --==========================================================

        Data.Highlight =
            Instance.new(
                "Highlight"
            )

        Data.Highlight.Name =
            "ArchitectESP"

        Data.Highlight.FillColor =
            Theme.Accent

        Data.Highlight.OutlineColor =
            Color3.fromRGB(
                255,
                255,
                255
            )

        Data.Highlight.FillTransparency =
            0.5

        Data.Highlight.Parent =
            Character

        --==========================================================
        -- BILLBOARD
        --==========================================================

        Data.Billboard =
            Instance.new(
                "BillboardGui"
            )

        Data.Billboard.Size =
            UDim2.new(
                0,
                180,
                0,
                40
            )

        Data.Billboard.StudsOffset =
            Vector3.new(
                0,
                3,
                0
            )

        Data.Billboard.AlwaysOnTop =
            true

        Data.Billboard.Parent =
            Root

        Data.Label =
            Instance.new(
                "TextLabel"
            )

        Data.Label.Size =
            UDim2.fromScale(
                1,
                1
            )

        Data.Label.BackgroundTransparency =
            1

        Data.Label.TextColor3 =
            Color3.fromRGB(
                255,
                255,
                255
            )

        Data.Label.TextStrokeTransparency =
            0.25

        Data.Label.TextSize =
            12

        Data.Label.Font =
            Enum.Font.GothamBold

        Data.Billboard.Parent =
            Root

        Data.Label.Parent =
            Data.Billboard

        ESPObjects[Player] =
            Data
    end

    --==============================================================
    -- UPDATE HIGHLIGHT
    --==============================================================

    if Data.Highlight then

        Data.Highlight.FillColor =
            Theme.Accent

        Data.Highlight.Enabled =
            State.ESPBoxes
    end

    --==============================================================
    -- UPDATE TEXT
    --==============================================================

    local Distance =
        math.floor(
            (
                Root.Position -
                Camera.CFrame.Position
            ).Magnitude
        )

    local Text = Player.Name

    if State.ESPDistance then

        Text =
            Text ..
            " [" ..
            tostring(Distance) ..
            "m]"
    end

    Data.Label.Text =
        Text

    Data.Billboard.Enabled =
        State.ESPNames
end

--==================================================================
-- TRACER UPDATE
--==================================================================

local function UpdateTracer(
    Player
)

    local Data =
        ESPObjects[Player]

    if
        not State.ESPEnabled
        or
        not State.ESPTracers
    then

        if Data then

            if Data.Beam then
                Data.Beam.Enabled = false
            end
        end

        return
    end

    if not Data then
        return
    end

    local Character =
        Player.Character

    if not Character then
        return
    end

    local Root =
        Character:FindFirstChild(
            "HumanoidRootPart"
        )

    if not Root then
        return
    end

    -- Beam needs attachments
    if not Data.PlayerAttachment then

        Data.PlayerAttachment =
            Instance.new(
                "Attachment"
            )

        Data.PlayerAttachment.Parent =
            Root
    end

    if not Data.TracerAttachment then

        Data.TracerAttachment =
            Instance.new(
                "Attachment"
            )

        Data.TracerAttachment.Parent =
            Camera
    end

    if not Data.Beam then

        Data.Beam =
            Instance.new(
                "Beam"
            )

        Data.Beam.FaceCamera =
            true

        Data.Beam.Width0 =
            0.03

        Data.Beam.Width1 =
            0.03

        Data.Beam.Color =
            ColorSequence.new(
                Theme.Accent
            )

        Data.Beam.Attachment0 =
            Data.TracerAttachment

        Data.Beam.Attachment1 =
            Data.PlayerAttachment

        Data.Beam.Parent =
            Root
    end

    Data.Beam.Color =
        ColorSequence.new(
            Theme.Accent
        )

    Data.Beam.Enabled =
        State.ESPTracers
end

--==================================================================
-- MOUSE CONTROLLER
--==================================================================

local LastMouseMode =
    nil

local function UpdateMouseState(
    Force
)

    local MenuOpen =
        MainFrame.Visible

    local FirstPerson =
        IsFirstPerson()

    local Mode =
        tostring(MenuOpen)
        ..
        "_"
        ..
        tostring(FirstPerson)

    if
        not Force
        and
        Mode == LastMouseMode
    then

        return
    end

    LastMouseMode =
        Mode

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

--==================================================================
-- CLOSE BUTTON
--==================================================================

CloseButton.MouseButton1Click:Connect(
    function()

        MainFrame.Visible =
            false

        UpdateMouseState(true)
    end
)

--==================================================================
-- INPUT
--==================================================================

UserInputService.InputBegan:Connect(
    function(
        Input,
        GameProcessed
    )

        --==========================================================
        -- PANEL KEY
        --==========================================================

        if State.WaitingPanelKey then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                _G.VOID_ARCHITECT_KEY =
                    Input.KeyCode

                PanelKeyButton.Text =
                    Input.KeyCode.Name

                State.WaitingPanelKey =
                    false
            end

            return
        end

        --==========================================================
        -- AIM KEY
        --==========================================================

        if State.WaitingAimKey then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                State.AimbotKey =
                    Input.KeyCode

                AimKeyButton.Text =
                    Input.KeyCode.Name

                State.WaitingAimKey =
                    false
            end

            return
        end

        local PanelKey =
            _G.VOID_ARCHITECT_KEY
            or
            Enum.KeyCode.RightControl

        if
            not GameProcessed
            and
            Input.KeyCode ==
                PanelKey
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

Mouse.Button1Down:Connect(
    function()

        if not State.ClickTeleport then
            return
        end

        if not UserInputService:IsKeyDown(
            Enum.KeyCode.LeftControl
        ) then
            return
        end

        local Root =
            GetRoot()

        if Root and Mouse.Hit then

            Root.CFrame =
                Mouse.Hit +
                Vector3.new(
                    0,
                    3,
                    0
                )
        end
    end
)

--==================================================================
-- INFINITE JUMP
--==================================================================

UserInputService.JumpRequest:Connect(
    function()

        if not State.InfiniteJump then
            return
        end

        local Humanoid =
            GetHumanoid()

        if Humanoid then

            Humanoid:ChangeState(
                Enum.HumanoidStateType.Jumping
            )
        end
    end
)

--==================================================================
-- MAIN LOOP
--==================================================================

local FPSFrames =
    0

local FPSTimer =
    os.clock()

local LastTriggerTime =
    0

RunService.RenderStepped:Connect(
    function()

        local CameraObject =
            GetCamera()

        --==========================================================
        -- MOUSE
        --==========================================================

        UpdateMouseState(false)

        --==========================================================
        -- FPS
        --==========================================================

        if State.FPSCounter then

            FPSFrames += 1

            if
                os.clock() -
                FPSTimer >= 1
            then

                FPSLabel.Text =
                    "FPS: " ..
                    tostring(
                        FPSFrames
                    )

                FPSFrames =
                    0

                FPSTimer =
                    os.clock()
            end

        else

            FPSFrames =
                0
        end

        --==========================================================
        -- CHARACTER
        --==========================================================

        local Character =
            GetCharacter()

        local Humanoid =
            GetHumanoid()

        local Root =
            GetRoot()

        --==========================================================
        -- SPEED
        --==========================================================

        if
            Humanoid
            and
            State.SpeedEnabled
        then

            Humanoid.WalkSpeed =
                State.WalkSpeed
        end

        --==========================================================
        -- JUMP
        --==========================================================

        if
            Humanoid
            and
            State.JumpEnabled
        then

            Humanoid.UseJumpPower =
                true

            Humanoid.JumpPower =
                State.JumpPower
        end

        --==========================================================
        -- GOD
        --==========================================================

        if
            Humanoid
            and
            State.GodMode
        then

            Humanoid.Health =
                Humanoid.MaxHealth
        end

        --==========================================================
        -- HIPHEIGHT
        --==========================================================

        if
            Humanoid
            and
            State.HipHeightEnabled
        then

            Humanoid.HipHeight =
                State.HipHeightValue
        end

        --==========================================================
        -- PLATFORM STAND
        --==========================================================

        if Humanoid then

            Humanoid.PlatformStand =
                State.PlatformStand
        end

        --==========================================================
        -- BHOP
        --==========================================================

        if
            Humanoid
            and
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

        --==========================================================
        -- ZOOM
        --==========================================================

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance
        end

        --==========================================================
        -- GRAVITY
        --==========================================================

        if State.LowGravity then

            workspace.Gravity =
                State.GravityValue
        end

        --==========================================================
        -- FLY
        --==========================================================

        if
            State.FlyEnabled
            and
            Root
        then

            local Direction =
                Vector3.zero

            local CameraCF =
                CameraObject.CFrame

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

        --==========================================================
        -- BLINK
        --==========================================================

        if
            Root
            and
            State.BlinkEnabled
        then

            Root.Anchored =
                true

        elseif
            Root
            and
            not State.BlinkEnabled
            and
            Root.Anchored
        then

            Root.Anchored =
                false
        end

        --==========================================================
        -- NOCLIP
        --==========================================================

        if
            Character
            and
            State.NoclipEnabled
        then

            for _, Part in ipairs(
                Character:GetDescendants()
            ) do

                if Part:IsA("BasePart") then

                    Part.CanCollide =
                        false
                end
            end
        end

        --==========================================================
        -- ANTI FLING
        --==========================================================

        if
            Root
            and
            State.AntiFling
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

        --==========================================================
        -- SPINBOT
        --==========================================================

        if
            Root
            and
            State.SpinbotEnabled
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

        --==========================================================
        -- FULLBRIGHT
        --==========================================================

        if State.Fullbright then

            Lighting.Ambient =
                Color3.fromRGB(
                    255,
                    255,
                    255
                )

            Lighting.Brightness =
                2
        end

        --==========================================================
        -- NO FOG
        --==========================================================

        if State.NoFog then

            Lighting.FogEnd =
                1000000
        end

        --==========================================================
        -- FOV
        --==========================================================

        if State.CustomFOV then

            CameraObject.FieldOfView =
                State.FOVValue
        end

        --==========================================================
        -- CROSSHAIR
        --==========================================================

        Crosshair.Position =
            UDim2.new(
                0,
                CameraObject.ViewportSize.X / 2,
                0,
                CameraObject.ViewportSize.Y / 2
            )

        Crosshair.Visible =
            State.CrosshairEnabled

        --==========================================================
        -- AIM FOV
        --==========================================================

        if State.ShowAimbotFOV then

            local AimPosition =
                GetAimPosition()

            FOVDisplay.Position =
                UDim2.new(
                    0,
                    AimPosition.X,
                    0,
                    AimPosition.Y
                )

            FOVDisplay.Size =
                UDim2.new(
                    0,
                    State.AimbotFOV * 2,
                    0,
                    State.AimbotFOV * 2
                )

            FOVDisplay.Visible =
                true

        else

            FOVDisplay.Visible =
                false
        end

        --==========================================================
        -- ESP
        --==========================================================

        for _, Player in ipairs(
            Players:GetPlayers()
        ) do

            UpdateESP(Player)

            UpdateTracer(Player)
        end

        --==========================================================
        -- HITBOX VISUAL
        --==========================================================

        for _, Player in ipairs(
            Players:GetPlayers()
        ) do

            if
                Player ~= LocalPlayer
                and
                Player.Character
            then

                local TargetRoot =
                    Player.Character:
                    FindFirstChild(
                        "HumanoidRootPart"
                    )

                if TargetRoot then

                    local Existing =
                        TargetRoot:
                        FindFirstChild(
                            "ArchitectHitbox"
                        )

                    if State.HitboxEnabled then

                        if not Existing then

                            Existing =
                                Instance.new(
                                    "BoxHandleAdornment"
                                )

                            Existing.Name =
                                "ArchitectHitbox"

                            Existing.Adornee =
                                TargetRoot

                            Existing.Size =
                                Vector3.new(
                                    State.HitboxSize,
                                    State.HitboxSize,
                                    State.HitboxSize
                                )

                            Existing.Color3 =
                                Theme.Accent

                            Existing.Transparency =
                                0.65

                            Existing.AlwaysOnTop =
                                true

                            Existing.ZIndex =
                                5

                            Existing.Parent =
                                TargetRoot

                        else

                            Existing.Size =
                                Vector3.new(
                                    State.HitboxSize,
                                    State.HitboxSize,
                                    State.HitboxSize
                                )

                            Existing.Color3 =
                                Theme.Accent
                        end

                    elseif Existing then

                        Existing:Destroy()
                    end
                end
            end
        end

        --==========================================================
        -- TRIGGERBOT
        --==========================================================

        if
            State.TriggerbotEnabled
            and
            os.clock() -
                LastTriggerTime >=
                State.TriggerCooldown
        then

            local TargetPart =
                Mouse.Target

            if TargetPart then

                local CharacterModel =
                    TargetPart:
                    FindFirstAncestorOfClass(
                        "Model"
                    )

                if CharacterModel then

                    local Player =
                        Players:
                        GetPlayerFromCharacter(
                            CharacterModel
                        )

                    local TargetHumanoid =
                        CharacterModel:
                        FindFirstChildOfClass(
                            "Humanoid"
                        )

                    if
                        Player
                        and
                        Player ~= LocalPlayer
                        and
                        TargetHumanoid
                        and
                        TargetHumanoid.Health > 0
                    then

                        local Tool =
                            Character and
                            Character:
                            FindFirstChildOfClass(
                                "Tool"
                            )

                        if Tool then

                            pcall(function()
                                Tool:Activate()
                            end)

                            LastTriggerTime =
                                os.clock()
                        end
                    end
                end
            end
        end
    end
)

--==================================================================
-- AIMBOT
--==================================================================

local function FindBestTarget()

    local CameraObject =
        workspace.CurrentCamera

    if not CameraObject then
        return nil
    end

    local AimPosition =
        GetAimPosition()

    local BestTarget =
        nil

    local BestDistance =
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
                        BestDistance
                    then

                        BestDistance =
                            Distance

                        BestTarget =
                            AimPart
                    end
                end
            end
        end
    end

    return BestTarget
end

--==================================================================
-- AIMBOT RENDER STEP
--==================================================================

RunService:BindToRenderStep(
    "VOID_Aimbot",
    Enum.RenderPriority.Camera.Value + 10,
    function()

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

        local CameraObject =
            workspace.CurrentCamera

        if not CameraObject then
            return
        end

        local Target =
            FindBestTarget()

        if not Target then
            return
        end

        local CameraPosition =
            CameraObject.CFrame.Position

        local Desired =
            CFrame.lookAt(
                CameraPosition,
                Target.Position
            )

        local Smooth =
            math.clamp(
                State.AimbotSmoothness,
                0.01,
                1
            )

        CameraObject.CFrame =
            CameraObject.CFrame:Lerp(
                Desired,
                Smooth
            )
    end
)

--==================================================================
-- ANTI AFK
--==================================================================

local VirtualUser

pcall(function()

    VirtualUser =
        game:GetService(
            "VirtualUser"
        )
end)

if VirtualUser then

    LocalPlayer.Idled:Connect(
        function()

            if not State.AntiAFK then
                return
            end

            pcall(function()

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
        end
    )
end

--==================================================================
-- CHARACTER RESPAWN
--==================================================================

LocalPlayer.CharacterAdded:Connect(
    function()

        task.wait(1)

        GetCamera()

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance
        end

        UpdateMouseState(true)
    end
)

--==================================================================
-- PLAYER REMOVING
--==================================================================

Players.PlayerRemoving:Connect(
    function(Player)

        RemoveESP(Player)
    end
)

--==================================================================
-- START
--==================================================================

_G.VOID_ARCHITECT_KEY =
    Enum.KeyCode.RightControl

MainFrame.Visible =
    true

UpdateMouseState(true)

Notify(
    "VOID ARCHITECT",
    "v5.1 inicializada."
)
