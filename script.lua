--[[
====================================================================
VOID ARCHITECT // CLIENT SUITE v5.0
REBUILT AIMBOT

- UI normal
- Mouse:
    * menu aberto -> livre
    * menu fechado + 1ª pessoa -> preso/escondido
    * menu fechado + 3ª pessoa -> livre
- Aimbot refeito
- Aimbot funciona em 1ª e 3ª pessoa
- Hold Mode
- FOV
- Troca Head / Torso
- ESP Highlight
- Speed
- Jump
- Fly
- Noclip
- Gravity
- Spinbot
- Infinite Zoom
- Fullbright
- No Fog
- Crosshair
- FPS
- Waypoints

OBS:
O aimbot usa somente APIs normais do cliente Roblox.
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
-- REFERENCES
--==============================================================

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Mouse = LocalPlayer:GetMouse()

--==============================================================
-- CLEANUP
--==============================================================

local OldGui = PlayerGui:FindFirstChild("ArchitectSuiteUI")

if OldGui then
    OldGui:Destroy()
end

pcall(function()
    RunService:UnbindFromRenderStep("VOID_Aimbot")
end)

--==============================================================
-- THEME
--==============================================================

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

    -- PLAYER

    SpeedEnabled = false,
    WalkSpeed = 120,

    JumpEnabled = false,
    JumpPower = 150,

    InfiniteJump = false,
    Bhop = false,

    GodMode = false,

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

    SpinbotEnabled = false,
    SpinSpeed = 20,

    AntiFling = false,

    -- VISUAL

    ESPEnabled = false,

    Fullbright = false,

    NoFog = false,

    CustomFOV = false,
    FOVValue = 90,

    CrosshairEnabled = false,

    FPSCounter = false,

    -- AIMBOT

    AimbotEnabled = false,

    AimbotHold = false,

    AimbotKey = Enum.KeyCode.LeftAlt,

    AimbotFOV = 150,

    AimbotSmoothness = 0.2,

    AimPart = "Head",

    ShowAimbotFOV = false,

    -- UTILITY

    AntiAFK = true,

    ClickTeleport = false,

    Waypoints = {},

    -- INTERNAL

    WaitingPanelKey = false,
    WaitingAimKey = false
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
-- CAMERA HELPERS
--==============================================================

local function GetCamera()

    Camera = workspace.CurrentCamera or Camera

    return Camera
end

local function GetCharacter()

    return LocalPlayer.Character
end

local function GetRoot()

    local Character = GetCharacter()

    if not Character then
        return nil
    end

    return Character:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()

    local Character = GetCharacter()

    if not Character then
        return nil
    end

    return Character:FindFirstChildOfClass("Humanoid")
end

--==============================================================
-- FIRST PERSON DETECTION
--==============================================================

local function IsFirstPerson()

    local CameraObject = GetCamera()
    local Character = GetCharacter()

    if not CameraObject or not Character then
        return false
    end

    local Head = Character:FindFirstChild("Head")

    if not Head then
        return false
    end

    local Distance =
        (CameraObject.CFrame.Position - Head.Position).Magnitude

    return Distance <= 1.25
end

--==============================================================
-- AIM POINT
--==============================================================

local function GetAimScreenPosition()

    local CameraObject = GetCamera()

    if IsFirstPerson() then

        return Vector2.new(
            CameraObject.ViewportSize.X / 2,
            CameraObject.ViewportSize.Y / 2
        )
    end

    return UserInputService:GetMouseLocation()
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
-- MAIN FRAME
--==============================================================

local MainFrame = Instance.new("Frame")

MainFrame.Name = "MainFrame"

MainFrame.Size = UDim2.new(
    0,
    650,
    0,
    460
)

MainFrame.Position = UDim2.new(
    0.5,
    -325,
    0.5,
    -230
)

MainFrame.BackgroundColor3 = Theme.BG
MainFrame.BorderSizePixel = 0

MainFrame.Active = true
MainFrame.Draggable = true

MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 8)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.2
MainStroke.Color = Color3.fromRGB(40, 42, 58)
MainStroke.Parent = MainFrame

--==============================================================
-- HEADER
--==============================================================

local Header = Instance.new("Frame")

Header.Size = UDim2.new(1, 0, 0, 45)

Header.BackgroundColor3 =
    Theme.Header

Header.BorderSizePixel = 0

Header.Parent =
    MainFrame

local Title = Instance.new("TextLabel")

Title.Size = UDim2.new(0, 450, 1, 0)

Title.Position =
    UDim2.new(0, 15, 0, 0)

Title.BackgroundTransparency = 1

Title.Text =
    "VOID // ARCHITECT SUITE v5.0"

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
    UDim2.new(0, 28, 0, 28)

CloseButton.Position =
    UDim2.new(1, -36, 0.5, -14)

CloseButton.BackgroundColor3 =
    Color3.fromRGB(239, 68, 68)

CloseButton.BackgroundTransparency =
    0.85

CloseButton.Text =
    "×"

CloseButton.TextColor3 =
    Color3.fromRGB(248, 113, 113)

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

--==============================================================
-- SIDEBAR
--==============================================================

local Sidebar =
    Instance.new("Frame")

Sidebar.Size =
    UDim2.new(0, 145, 1, -45)

Sidebar.Position =
    UDim2.new(0, 0, 0, 45)

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
    UDim2.new(1, -145, 1, -45)

Content.Position =
    UDim2.new(0, 145, 0, 45)

Content.BackgroundTransparency = 1

Content.Parent =
    MainFrame

--==============================================================
-- TABS
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

    Button.BackgroundTransparency = 1

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
    end)

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

--==============================================================
-- TOGGLE BUILDER
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

    Card.BorderSizePixel =
        0

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

    Label.BackgroundTransparency = 1

    Label.Text = Name

    Label.TextColor3 =
        Theme.Text

    Label.TextSize = 11

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

    Dot.BorderSizePixel =
        0

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

--==============================================================
-- SLIDER BUILDER
--==============================================================

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

    Label.BackgroundTransparency =
        1

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
        Theme.Track

    Track.BorderSizePixel =
        0

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

    Track.InputBegan:Connect(
        function(InputObject)

            if
                InputObject.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                Dragging = true

                local Percent =
                    (
                        InputObject.Position.X -
                        Track.AbsolutePosition.X
                    ) /
                    Track.AbsoluteSize.X

                SetValue(
                    math.floor(
                        Min +
                        (
                            Max - Min
                        ) *
                        math.clamp(
                            Percent,
                            0,
                            1
                        )
                    )
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

                local Percent =
                    (
                        InputObject.Position.X -
                        Track.AbsolutePosition.X
                    ) /
                    Track.AbsoluteSize.X

                SetValue(
                    math.floor(
                        Min +
                        (
                            Max - Min
                        ) *
                        math.clamp(
                            Percent,
                            0,
                            1
                        )
                    )
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

--==============================================================
-- BUTTON
--==============================================================

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

    Label.BackgroundTransparency =
        1

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

--==============================================================
-- TABS
--==============================================================

local PlayerTab =
    CreateTab("Jogador")

local MovementTab =
    CreateTab("Movimento")

local VisualTab =
    CreateTab("Visual")

local CombatTab =
    CreateTab("Combate")

local WaypointTab =
    CreateTab("Waypoints")

local ConfigTab =
    CreateTab("Configurações")

--==============================================================
-- PLAYER
--==============================================================

AddToggle(
    PlayerTab,
    "Super Velocidade",
    "Aumenta a velocidade.",
    function(Value)

        State.SpeedEnabled =
            Value
    end
)

AddSlider(
    PlayerTab,
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
    PlayerTab,
    "Super Pulo",
    "Aumenta o salto.",
    function(Value)

        State.JumpEnabled =
            Value
    end
)

AddSlider(
    PlayerTab,
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
    PlayerTab,
    "Pulo Infinito",
    "Permite pular no ar.",
    function(Value)

        State.InfiniteJump =
            Value
    end
)

AddToggle(
    PlayerTab,
    "Auto Bhop",
    "Pulo automático.",
    function(Value)

        State.Bhop =
            Value
    end
)

AddToggle(
    PlayerTab,
    "God Mode Local",
    "Mantém a saúde cheia.",
    function(Value)

        State.GodMode =
            Value
    end
)

AddToggle(
    PlayerTab,
    "Infinite Zoom",
    "Aumenta a distância da câmera.",
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
    PlayerTab,
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
    PlayerTab,
    "Platform Stand",
    "Ativa PlatformStand.",
    function(Value)

        State.PlatformStand =
            Value
    end
)

AddToggle(
    PlayerTab,
    "HipHeight",
    "Ativa altura personalizada.",
    function(Value)

        State.HipHeightEnabled =
            Value
    end
)

AddSlider(
    PlayerTab,
    "Altura",
    0,
    30,
    State.HipHeightValue,
    function(Value)

        State.HipHeightValue =
            Value
    end
)

--==============================================================
-- MOVEMENT
--==============================================================

AddToggle(
    MovementTab,
    "Fly",
    "Voo livre.",
    function(Value)

        State.FlyEnabled =
            Value
    end
)

AddSlider(
    MovementTab,
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
    MovementTab,
    "Noclip",
    "Atravessa objetos.",
    function(Value)

        State.NoclipEnabled =
            Value
    end
)

AddToggle(
    MovementTab,
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
    MovementTab,
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
    MovementTab,
    "Spinbot",
    "Gira continuamente.",
    function(Value)

        State.SpinbotEnabled =
            Value
    end
)

AddSlider(
    MovementTab,
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
    MovementTab,
    "Anti-Fling",
    "Reduz velocidades extremas.",
    function(Value)

        State.AntiFling =
            Value
    end
)

--==============================================================
-- VISUAL
--==============================================================

AddToggle(
    VisualTab,
    "ESP",
    "Destaca jogadores.",
    function(Value)

        State.ESPEnabled =
            Value
    end
)

AddToggle(
    VisualTab,
    "Fullbright",
    "Ilumina o ambiente.",
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
    VisualTab,
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
    VisualTab,
    "Custom FOV",
    "Altera o FOV.",
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
    VisualTab,
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
    VisualTab,
    "Crosshair",
    "Mira no centro.",
    function(Value)

        State.CrosshairEnabled =
            Value
    end
)

AddToggle(
    VisualTab,
    "Aimbot FOV",
    "Mostra o círculo de alcance.",
    function(Value)

        State.ShowAimbotFOV =
            Value
    end
)

AddSlider(
    VisualTab,
    "Raio do Aim",
    50,
    400,
    State.AimbotFOV,
    function(Value)

        State.AimbotFOV =
            Value
    end
)

AddToggle(
    VisualTab,
    "FPS Counter",
    "Mostra FPS.",
    function(Value)

        State.FPSCounter =
            Value
    end
)

--==============================================================
-- COMBAT
--==============================================================

AddToggle(
    CombatTab,
    "Aimbot",
    "Seleciona o alvo mais próximo.",
    function(Value)

        State.AimbotEnabled =
            Value

        Notify(
            "Aimbot",
            Value
            and "Ativado"
            or "Desativado"
        )
    end
)

AddToggle(
    CombatTab,
    "Hold Mode",
    "Só funciona enquanto segura a tecla.",
    function(Value)

        State.AimbotHold =
            Value
    end
)

local AimKeyButton

AimKeyButton =
    AddButton(
        CombatTab,
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
    CombatTab,
    "Suavidade",
    1,
    10,
    2,
    function(Value)

        State.AimbotSmoothness =
            Value / 10
    end
)

AddButton(
    CombatTab,
    "Parte do Alvo",
    "Head / Torso",
    function()

        if State.AimPart == "Head" then

            State.AimPart =
                "HumanoidRootPart"

            Notify(
                "Aimbot",
                "Alvo: TORso"
            )

        else

            State.AimPart =
                "Head"

            Notify(
                "Aimbot",
                "Alvo: HEAD"
            )
        end
    end
)

--==============================================================
-- WAYPOINTS
--==============================================================

local WaypointInput =
    Instance.new("TextBox")

WaypointInput.Size =
    UDim2.new(
        1,
        -4,
        0,
        40
    )

WaypointInput.BackgroundColor3 =
    Theme.Card

WaypointInput.BorderSizePixel =
    0

WaypointInput.PlaceholderText =
    "Nome do waypoint..."

WaypointInput.Text =
    ""

WaypointInput.TextColor3 =
    Theme.Text

WaypointInput.Font =
    Enum.Font.Gotham

WaypointInput.TextSize =
    11

WaypointInput.Parent =
    WaypointTab

local WaypointCorner =
    Instance.new("UICorner")

WaypointCorner.CornerRadius =
    UDim.new(
        0,
        6
    )

WaypointCorner.Parent =
    WaypointInput

AddButton(
    WaypointTab,
    "Salvar posição",
    "Salvar",
    function()

        local Root =
            GetRoot()

        if
            not Root
            or
            WaypointInput.Text == ""
        then
            return
        end

        table.insert(
            State.Waypoints,
            {
                Name =
                    WaypointInput.Text,

                Position =
                    Root.Position
            }
        )

        Notify(
            "Waypoint",
            "Salvo com sucesso."
        )

        WaypointInput.Text =
            ""
    end
)

AddButton(
    WaypointTab,
    "Último Waypoint",
    "Ir",
    function()

        local Waypoint =
            State.Waypoints[
                #State.Waypoints
            ]

        local Root =
            GetRoot()

        if Waypoint and Root then

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
    WaypointTab,
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

--==============================================================
-- CONFIG
--==============================================================

local PanelKeyButton

PanelKeyButton =
    AddButton(
        ConfigTab,
        "Atalho do Painel",
        "RightControl",
        function()

            State.WaitingPanelKey =
                true

            PanelKeyButton.Text =
                "Pressione..."
        end
    )

--==============================================================
-- CLOSE BUTTON
--==============================================================

CloseButton.MouseButton1Click:Connect(function()

    MainFrame.Visible =
        false
end)

--==============================================================
-- KEYBOARD
--==============================================================

UserInputService.InputBegan:Connect(
    function(Input, GameProcessed)

        -- PANEL KEY
        if State.WaitingPanelKey then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                _G.VOID_PANEL_KEY =
                    Input.KeyCode

                PanelKeyButton.Text =
                    Input.KeyCode.Name

                State.WaitingPanelKey =
                    false
            end

            return
        end

        -- AIM KEY
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
            _G.VOID_PANEL_KEY
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

            UpdateMouseState(
                true
            )
        end
    end
)

--==============================================================
-- MOUSE STATE
--==============================================================

local LastMouseMode = nil

function UpdateMouseState(Force)

    local MenuOpen =
        MainFrame.Visible

    local FirstPerson =
        IsFirstPerson()

    local Mode =
        tostring(MenuOpen)
        .. "_"
        ..
        tostring(FirstPerson)

    if
        not Force
        and
        Mode ==
        LastMouseMode
    then
        return
    end

    LastMouseMode =
        Mode

    -- MENU ABERTO

    if MenuOpen then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default

        UserInputService.MouseIconEnabled =
            true

        return
    end

    -- PRIMEIRA PESSOA

    if FirstPerson then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.LockCenter

        UserInputService.MouseIconEnabled =
            false

        return
    end

    -- TERCEIRA PESSOA

    UserInputService.MouseBehavior =
        Enum.MouseBehavior.Default

    UserInputService.MouseIconEnabled =
        true
end

--==============================================================
-- INFINITE JUMP
--==============================================================

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
end)

--==============================================================
-- ESP
--==============================================================

local ESPObjects = {}

local function RemoveESP(Player)

    local Object =
        ESPObjects[Player]

    if Object then

        Object:Destroy()

        ESPObjects[Player] =
            nil
    end
end

local function UpdateESP(Player)

    if Player == LocalPlayer then
        return
    end

    if not State.ESPEnabled then

        RemoveESP(Player)

        return
    end

    local Character =
        Player.Character

    if not Character then

        RemoveESP(Player)

        return
    end

    local Highlight =
        ESPObjects[Player]

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
            Character

        ESPObjects[Player] =
            Highlight

    else

        Highlight.FillColor =
            Theme.Accent
    end
end

--==============================================================
-- MAIN LOOP
--==============================================================

local FPSFrames = 0
local FPSTime = os.clock()

RunService.RenderStepped:Connect(
    function()

        local CameraObject =
            GetCamera()

        --=========================================================
        -- MOUSE
        --=========================================================

        UpdateMouseState(false)

        --=========================================================
        -- FPS
        --=========================================================

        if State.FPSCounter then

            FPSFrames += 1

            if
                os.clock() -
                FPSTime >= 1
            then

                FPSLabel.Text =
                    "FPS: " ..
                    tostring(
                        FPSFrames
                    )

                FPSFrames = 0

                FPSTime =
                    os.clock()
            end
        end

        --=========================================================
        -- CHARACTER
        --=========================================================

        local Humanoid =
            GetHumanoid()

        local Root =
            GetRoot()

        local Character =
            GetCharacter()

        --=========================================================
        -- SPEED
        --=========================================================

        if
            Humanoid
            and
            State.SpeedEnabled
        then

            Humanoid.WalkSpeed =
                State.WalkSpeed
        end

        --=========================================================
        -- JUMP
        --=========================================================

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

        --=========================================================
        -- GOD
        --=========================================================

        if
            Humanoid
            and
            State.GodMode
        then

            Humanoid.Health =
                Humanoid.MaxHealth
        end

        --=========================================================
        -- HIP HEIGHT
        --=========================================================

        if
            Humanoid
            and
            State.HipHeightEnabled
        then

            Humanoid.HipHeight =
                State.HipHeightValue
        end

        --=========================================================
        -- PLATFORM STAND
        --=========================================================

        if Humanoid then

            Humanoid.PlatformStand =
                State.PlatformStand
        end

        --=========================================================
        -- BHOP
        --=========================================================

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

        --=========================================================
        -- ZOOM
        --=========================================================

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance
        end

        --=========================================================
        -- GRAVITY
        --=========================================================

        if State.LowGravity then

            workspace.Gravity =
                State.GravityValue
        end

        --=========================================================
        -- FLY
        --=========================================================

        if
            State.FlyEnabled
            and
            Root
            and
            CameraObject
        then

            local Direction =
                Vector3.zero

            if UserInputService:IsKeyDown(
                Enum.KeyCode.W
            ) then

                Direction +=
                    CameraObject.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.S
            ) then

                Direction -=
                    CameraObject.CFrame.LookVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.A
            ) then

                Direction -=
                    CameraObject.CFrame.RightVector
            end

            if UserInputService:IsKeyDown(
                Enum.KeyCode.D
            ) then

                Direction +=
                    CameraObject.CFrame.RightVector
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

        --=========================================================
        -- NOCLIP
        --=========================================================

        if
            State.NoclipEnabled
            and
            Character
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

        --=========================================================
        -- ANTI FLING
        --=========================================================

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

        --=========================================================
        -- SPINBOT
        --=========================================================

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

        --=========================================================
        -- FULLBRIGHT
        --=========================================================

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

        --=========================================================
        -- NO FOG
        --=========================================================

        if State.NoFog then

            Lighting.FogEnd =
                1000000
        end

        --=========================================================
        -- FOV
        --=========================================================

        if State.CustomFOV then

            CameraObject.FieldOfView =
                State.FOVValue
        end

        --=========================================================
        -- CROSSHAIR
        --=========================================================

        CrosshairContainer.Position =
            UDim2.new(
                0,
                CameraObject.ViewportSize.X / 2,
                0,
                CameraObject.ViewportSize.Y / 2
            )

        CrosshairContainer.Visible =
            State.CrosshairEnabled

        --=========================================================
        -- FOV DISPLAY
        --=========================================================

        if State.ShowAimbotFOV then

            local Position =
                GetAimScreenPosition()

            FOVDisplay.Position =
                UDim2.new(
                    0,
                    Position.X,
                    0,
                    Position.Y
                )

            FOVDisplay.Visible =
                true

        else

            FOVDisplay.Visible =
                false
        end

        --=========================================================
        -- ESP
        --=========================================================

        for _, Player in ipairs(
            Players:GetPlayers()
        ) do

            UpdateESP(Player)
        end
    end
)

--==============================================================
-- EXTRA UI OBJECTS
--==============================================================

local CrosshairContainer =
    Instance.new("Frame")

CrosshairContainer.Size =
    UDim2.new(
        0,
        1,
        0,
        1
    )

CrosshairContainer.AnchorPoint =
    Vector2.new(
        0.5,
        0.5
    )

CrosshairContainer.BackgroundTransparency =
    1

CrosshairContainer.Visible =
    false

CrosshairContainer.Parent =
    ScreenGui

local function MakeCrosshairPart(
    Size,
    Position
)

    local Part =
        Instance.new("Frame")

    Part.Size =
        Size

    Part.Position =
        Position

    Part.AnchorPoint =
        Vector2.new(
            0.5,
            0.5
        )

    Part.BackgroundColor3 =
        Color3.fromRGB(
            255,
            255,
            255
        )

    Part.BorderSizePixel =
        0

    Part.Parent =
        CrosshairContainer
end

MakeCrosshairPart(
    UDim2.new(0, 2, 0, 8),
    UDim2.new(0.5, 0, 0.5, -7)
)

MakeCrosshairPart(
    UDim2.new(0, 2, 0, 8),
    UDim2.new(0.5, 0, 0.5, 7)
)

MakeCrosshairPart(
    UDim2.new(0, 8, 0, 2),
    UDim2.new(0.5, -7, 0.5, 0)
)

MakeCrosshairPart(
    UDim2.new(0, 8, 0, 2),
    UDim2.new(0.5, 7, 0.5, 0)
)

--==============================================================
-- FOV DISPLAY
--==============================================================

local FOVDisplay =
    Instance.new("Frame")

FOVDisplay.Size =
    UDim2.new(
        0,
        State.AimbotFOV * 2,
        0,
        State.AimbotFOV * 2
    )

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

--==============================================================
-- AIMBOT
--==============================================================

local function FindBestTarget()

    local CameraObject =
        workspace.CurrentCamera

    if not CameraObject then
        return nil
    end

    local AimPosition =
        GetAimScreenPosition()

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

                local ScreenPosition,
                    Visible =
                    CameraObject:
                    WorldToViewportPoint(
                        AimPart.Position
                    )

                if Visible then

                    local ScreenPoint =
                        Vector2.new(
                            ScreenPosition.X,
                            ScreenPosition.Y
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

        local DesiredCFrame =
            CFrame.lookAt(
                CameraPosition,
                Target.Position
            )

        CameraObject.CFrame =
            CameraObject.CFrame:Lerp(
                DesiredCFrame,
                math.clamp(
                    State.AimbotSmoothness,
                    0.01,
                    1
                )
            )
    end
)

--==============================================================
-- CHARACTER RESPAWN
--==============================================================

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

--==============================================================
-- PLAYER REMOVING
--==============================================================

Players.PlayerRemoving:Connect(
    function(Player)

        RemoveESP(Player)
    end
)

--==============================================================
-- INITIALIZATION
--==============================================================

MainFrame.Visible =
    true

UpdateMouseState(true)

Notify(
    "VOID ARCHITECT",
    "v5.0 inicializada."
)
