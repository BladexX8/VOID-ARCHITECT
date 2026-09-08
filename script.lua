```lua
--[[
====================================================================
VOID ARCHITECT // CLEAN CLIENT SUITE
Para usar como LocalScript na sua própria experiência.

CONTROLES:
RightControl = abrir/fechar painel
LeftAlt     = aimbot quando Hold Mode estiver ativado

IMPORTANTE:
Esta versão não usa:
- Drawing.new
- mouse1click
- setclipboard
- APIs específicas de executor

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

--==============================================================
-- PLAYER
--==============================================================

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--==============================================================
-- CLEANUP
--==============================================================

local OldGui = PlayerGui:FindFirstChild("ArchitectSuiteUI")

if OldGui then
    OldGui:Destroy()
end

pcall(function()
    RunService:UnbindFromRenderStep("ArchitectAimbot")
end)

--==============================================================
-- STATE
--==============================================================

local State = {

    MenuOpen = true,

    -- Player
    Speed = false,
    WalkSpeed = 120,

    SuperJump = false,
    JumpPower = 150,

    InfiniteJump = false,
    Bhop = false,

    GodMode = false,

    HipHeight = false,
    HipHeightValue = 2,

    InfiniteZoom = false,
    ZoomDistance = 500,

    -- Movement
    Fly = false,
    FlySpeed = 80,

    Noclip = false,

    LowGravity = false,
    Gravity = 50,

    Spinbot = false,
    SpinSpeed = 20,

    AntiFling = false,

    -- Visual
    ESP = false,
    Fullbright = false,
    NoFog = false,

    CustomFOV = false,
    FOV = 90,

    Crosshair = false,
    ShowAimbotFOV = false,

    -- Aim
    Aimbot = false,
    AimbotHold = false,
    AimbotKey = Enum.KeyCode.LeftAlt,

    AimbotFOV = 150,
    AimbotSmoothness = 0.2,

    AimPart = "Head",

    -- Others
    ClickTP = false,

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

local OriginalZoom =
    LocalPlayer.CameraMaxZoomDistance

--==============================================================
-- THEME
--==============================================================

local Theme = {

    BG = Color3.fromRGB(
        10,
        11,
        16
    ),

    Header = Color3.fromRGB(
        16,
        17,
        24
    ),

    Sidebar = Color3.fromRGB(
        14,
        15,
        21
    ),

    Card = Color3.fromRGB(
        20,
        22,
        30
    ),

    Track = Color3.fromRGB(
        40,
        42,
        58
    ),

    Accent = Color3.fromRGB(
        138,
        92,
        246
    ),

    Text = Color3.fromRGB(
        243,
        244,
        246
    ),

    SubText = Color3.fromRGB(
        156,
        163,
        175
    )
}

--==============================================================
-- CAMERA HELPERS
--==============================================================

local function GetCamera()

    Camera =
        workspace.CurrentCamera or Camera

    return Camera
end

local function IsFirstPerson()

    local camera =
        GetCamera()

    local Character =
        LocalPlayer.Character

    local Head =
        Character and
        Character:FindFirstChild("Head")

    if
        not camera
        or
        not Head
    then
        return false
    end

    return (
        camera.CFrame.Position -
        Head.Position
    ).Magnitude < 1.25
end

local function GetAimPosition()

    local camera =
        GetCamera()

    if IsFirstPerson() then

        return Vector2.new(
            camera.ViewportSize.X / 2,
            camera.ViewportSize.Y / 2
        )

    end

    return UserInputService:GetMouseLocation()
end

--==============================================================
-- GUI
--==============================================================

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

--==============================================================
-- MAIN FRAME
--==============================================================

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
    "VOID // ARCHITECT SUITE"

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

Content.BackgroundTransparency =
    1

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

    local ButtonCorner =
        Instance.new("UICorner")

    ButtonCorner.CornerRadius =
        UDim.new(
            0,
            6
        )

    ButtonCorner.Parent =
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

--==============================================================
-- TOGGLE
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

    local Desc =
        Instance.new("TextLabel")

    Desc.Size =
        UDim2.new(
            0.7,
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

    Desc.BackgroundTransparency =
        1

    Desc.Text =
        Description

    Desc.TextColor3 =
        Theme.SubText

    Desc.TextSize =
        9

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

    local Corner2 =
        Instance.new("UICorner")

    Corner2.CornerRadius =
        UDim.new(
            0,
            4
        )

    Corner2.Parent =
        Button

    Button.MouseButton1Click:Connect(
        Callback
    )

    return Button
end

--==============================================================
-- SLIDER
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

    Fill.BackgroundColor3 =
        Theme.Accent

    Fill.BorderSizePixel =
        0

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

    Track.InputBegan:Connect(
        function(InputObject)

            if
                InputObject.UserInputType ==
                Enum.UserInputType.MouseButton1
            then

                Dragging =
                    true

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

                Dragging =
                    false
            end
        end
    )

    Input.FocusLost:Connect(
        function()

            local Number =
                tonumber(
                    Input.Text
                )

            if Number then

                SetValue(Number)

            else

                SetValue(Default)
            end
        end
    )
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
    CreateTab("Config")

--==============================================================
-- PLAYER
--==============================================================

AddToggle(
    PlayerTab,
    "Super Velocidade",
    "Aumenta WalkSpeed.",
    function(Value)
        State.Speed = Value
    end
)

AddSlider(
    PlayerTab,
    "Velocidade",
    16,
    400,
    State.WalkSpeed,
    function(Value)
        State.WalkSpeed = Value
    end
)

AddToggle(
    PlayerTab,
    "Super Pulo",
    "Aumenta JumpPower.",
    function(Value)
        State.SuperJump = Value
    end
)

AddSlider(
    PlayerTab,
    "Força do Pulo",
    50,
    500,
    State.JumpPower,
    function(Value)
        State.JumpPower = Value
    end
)

AddToggle(
    PlayerTab,
    "Pulo Infinito",
    "Permite pular no ar.",
    function(Value)
        State.InfiniteJump = Value
    end
)

AddToggle(
    PlayerTab,
    "Auto Bhop",
    "Pula automaticamente.",
    function(Value)
        State.Bhop = Value
    end
)

AddToggle(
    PlayerTab,
    "God Mode Local",
    "Mantém a vida no máximo.",
    function(Value)
        State.GodMode = Value
    end
)

AddToggle(
    PlayerTab,
    "Infinite Zoom",
    "Permite zoom distante.",
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
    PlayerTab,
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
    PlayerTab,
    "HipHeight",
    "Altera altura.",
    function(Value)

        State.HipHeight =
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

AddToggle(
    PlayerTab,
    "Platform Stand",
    "Ativa PlatformStand.",
    function(Value)

        State.PlatformStand =
            Value
    end
)

--==============================================================
-- MOVEMENT
--==============================================================

AddToggle(
    MovementTab,
    "Fly",
    "Movimentação aérea.",
    function(Value)

        State.Fly =
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
    "Atravessa partes.",
    function(Value)

        State.Noclip =
            Value
    end
)

AddToggle(
    MovementTab,
    "Low Gravity",
    "Altera a gravidade.",
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
    State.Gravity,
    function(Value)

        State.Gravity =
            Value
    end
)

AddToggle(
    MovementTab,
    "Spinbot",
    "Gira o personagem.",
    function(Value)

        State.Spinbot =
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

        State.ESP =
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
    "Remove a neblina.",
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
    State.FOV,
    function(Value)

        State.FOV =
            Value
    end
)

AddToggle(
    VisualTab,
    "Crosshair",
    "Mira no centro.",
    function(Value)

        State.Crosshair =
            Value
    end
)

AddToggle(
    VisualTab,
    "Mostrar FOV do Aimbot",
    "Mostra o círculo de alcance.",
    function(Value)

        State.ShowAimbotFOV =
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

        State.Aimbot =
            Value
    end
)

AddToggle(
    CombatTab,
    "Hold Mode",
    "Só funciona segurando uma tecla.",
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

            AimKeyButton.Text =
                "Pressione..."

            State.WaitingForAimKey =
                true
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

AddSlider(
    CombatTab,
    "FOV do Aimbot",
    50,
    400,
    State.AimbotFOV,
    function(Value)

        State.AimbotFOV =
            Value
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

local WaypointName =
    Instance.new("TextBox")

WaypointName.Size =
    UDim2.new(
        1,
        -4,
        0,
        40
    )

WaypointName.BackgroundColor3 =
    Theme.Card

WaypointName.BorderSizePixel =
    0

WaypointName.PlaceholderText =
    "Nome do waypoint..."

WaypointName.Text =
    ""

WaypointName.TextColor3 =
    Theme.Text

WaypointName.Parent =
    WaypointTab

local WaypointCorner =
    Instance.new("UICorner")

WaypointCorner.CornerRadius =
    UDim.new(
        0,
        6
    )

WaypointCorner.Parent =
    WaypointName

AddButton(
    WaypointTab,
    "Salvar posição",
    "Salvar",
    function()

        if WaypointName.Text == "" then
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
                Name =
                    WaypointName.Text,

                Position =
                    Root.Position
            }
        )

        WaypointName.Text =
            ""

        Notify(
            "Waypoint",
            "Posição salva."
        )
    end
)

AddButton(
    WaypointTab,
    "Último waypoint",
    "Ir",
    function()

        local Waypoint =
            State.Waypoints[
                #State.Waypoints
            ]

        if not Waypoint then
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

--==============================================================
-- CONFIG
--==============================================================

local PanelKeyButton

PanelKeyButton =
    AddButton(
        ConfigTab,
        "Atalho do Painel",
        TOGGLE_KEY.Name,
        function()

            PanelKeyButton.Text =
                "Pressione..."

            State.WaitingForPanelKey =
                true
        end
    )

--==============================================================
-- CROSSHAIR GUI
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

local function CrosshairPart(
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

CrosshairPart(
    UDim2.new(0, 2, 0, 8),
    UDim2.new(0.5, 0, 0.5, -7)
)

CrosshairPart(
    UDim2.new(0, 2, 0, 8),
    UDim2.new(0.5, 0, 0.5, 7)
)

CrosshairPart(
    UDim2.new(0, 8, 0, 2),
    UDim2.new(0.5, -7, 0.5, 0)
)

CrosshairPart(
    UDim2.new(0, 8, 0, 2),
    UDim2.new(0.5, 7, 0.5, 0)
)

--==============================================================
-- FOV UI
--==============================================================

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

--==============================================================
-- ESP
--==============================================================

local ESP = {}

local function RemoveESP(Player)

    local Highlight =
        ESP[Player]

    if Highlight then

        Highlight:Destroy()

        ESP[Player] =
            nil
    end
end

local function UpdateESP(Player)

    if Player == LocalPlayer then
        return
    end

    if not State.ESP then

        RemoveESP(Player)

        return
    end

    local Character =
        Player.Character

    if not Character then

        RemoveESP(Player)

        return
    end

    if not ESP[Player] then

        local Highlight =
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

        ESP[Player] =
            Highlight
    else

        ESP[Player].FillColor =
            Theme.Accent
    end
end

--==============================================================
-- MOUSE CONTROL
--==============================================================

local function UpdateMouse()

    if MainFrame.Visible then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default

        UserInputService.MouseIconEnabled =
            true

        return
    end

    if IsFirstPerson() then

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.LockCenter

        UserInputService.MouseIconEnabled =
            false

    else

        UserInputService.MouseBehavior =
            Enum.MouseBehavior.Default

        UserInputService.MouseIconEnabled =
            true
    end
end

CloseButton.MouseButton1Click:Connect(
    function()

        MainFrame.Visible =
            false

        State.MenuOpen =
            false

        UpdateMouse()
    end
)

--==============================================================
-- KEYBOARD INPUT
--==============================================================

UserInputService.InputBegan:Connect(
    function(Input, Processed)

        if State.WaitingForPanelKey then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                TOGGLE_KEY =
                    Input.KeyCode

                PanelKeyButton.Text =
                    Input.KeyCode.Name

                State.WaitingForPanelKey =
                    false
            end

            return
        end

        if State.WaitingForAimKey then

            if
                Input.UserInputType ==
                Enum.UserInputType.Keyboard
            then

                State.AimbotKey =
                    Input.KeyCode

                AimKeyButton.Text =
                    Input.KeyCode.Name

                State.WaitingForAimKey =
                    false
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

            State.MenuOpen =
                MainFrame.Visible

            UpdateMouse()

            return
        end
    end
)

--==============================================================
-- INFINITE JUMP
--==============================================================

UserInputService.JumpRequest:Connect(
    function()

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
    end
)

--==============================================================
-- MAIN LOOP
--==============================================================

RunService.RenderStepped:Connect(
    function()

        GetCamera()

        --==========================================================
        -- MOUSE
        --==========================================================

        UpdateMouse()

        --==========================================================
        -- CHARACTER
        --==========================================================

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

        --==========================================================
        -- SPEED
        --==========================================================

        if
            Humanoid
            and
            State.Speed
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
            State.SuperJump
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
        -- HIP HEIGHT
        --==========================================================

        if
            Humanoid
            and
            State.HipHeight
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
                State.Gravity
        end

        --==========================================================
        -- FLY
        --==========================================================

        if
            State.Fly
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

            Root.AssemblyLinearVelocity =
                Direction *
                State.FlySpeed
        end

        --==========================================================
        -- NOCLIP
        --==========================================================

        if
            State.Noclip
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

        --==========================================================
        -- ANTI FLING
        --==========================================================

        if
            State.AntiFling
            and
            Root
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

            Camera.FieldOfView =
                State.FOV
        end

        --==========================================================
        -- CROSSHAIR
        --==========================================================

        CrosshairContainer.Visible =
            State.Crosshair

        CrosshairContainer.Position =
            UDim2.new(
                0,
                Camera.ViewportSize.X / 2,
                0,
                Camera.ViewportSize.Y / 2
            )

        --==========================================================
        -- FOV DISPLAY
        --==========================================================

        if State.ShowAimbotFOV then

            local Position =
                GetAimPosition()

            FOVDisplay.Position =
                UDim2.new(
                    0,
                    Position.X,
                    0,
                    Position.Y
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

            if Player ~= LocalPlayer then

                UpdateESP(Player)
            end
        end
    end
)

--==============================================================
-- AIMBOT
--==============================================================

RunService:BindToRenderStep(
    "ArchitectAimbot",
    Enum.RenderPriority.Camera.Value + 1,
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

        local Target =
            nil

        local Closest =
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
                        OnScreen =
                        CameraObject:
                        WorldToViewportPoint(
                            AimPart.Position
                        )

                    if OnScreen then

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
                            Closest
                        then

                            Closest =
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

        local Desired =
            CFrame.lookAt(
                CameraPosition,
                Target.Position
            )

        CameraObject.CFrame =
            CameraObject.CFrame:Lerp(
                Desired,
                math.clamp(
                    State.AimbotSmoothness,
                    0.01,
                    1
                )
            )
    end
)

--==============================================================
-- RESPAWN
--==============================================================

LocalPlayer.CharacterAdded:Connect(
    function()

        task.wait(1)

        GetCamera()

        if State.InfiniteZoom then

            LocalPlayer.CameraMaxZoomDistance =
                State.ZoomDistance
        end

        UpdateMouse()
    end
)

--==============================================================
-- INITIALIZE
--==============================================================

MainFrame.Visible =
    true

State.MenuOpen =
    true

UpdateMouse()

Notify(
    "VOID ARCHITECT",
    "Sistema iniciado."
)
```
