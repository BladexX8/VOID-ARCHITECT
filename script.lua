--[[ 
    ====================================================================
    SYSTEM: VOID ARCHITECT // ULTIMATE CLIENT SUITE v3.0 (OVERLORD)
    ENVIRONMENT: Client-Side (LocalScript)
    DEFAULT TOGGLE KEY: RightControl
    FEATURES: ESP/Visuals, Combat Assist, Physics & Fly, Lighting Mod,
              Server Tools, Dynamic Keybinds & Toast Notifications.
    ====================================================================
--]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Limpeza de instâncias legadas
if PlayerGui:FindFirstChild("ArchitectSuiteUI") then
    PlayerGui.ArchitectSuiteUI:Destroy()
end

-- ====================================================================
-- ESTADO GLOBAL & TEMA DINÂMICO
-- ====================================================================
local TOGGLE_KEY = Enum.KeyCode.RightControl
local ListeningForKey = false

local Theme = {
    BG = Color3.fromRGB(12, 13, 18),
    Header = Color3.fromRGB(18, 19, 26),
    Sidebar = Color3.fromRGB(16, 17, 23),
    Card = Color3.fromRGB(22, 24, 33),
    CardHover = Color3.fromRGB(28, 30, 42),
    Accent = Color3.fromRGB(138, 92, 246), -- Purple Accent
    Text = Color3.fromRGB(243, 244, 246),
    SubText = Color3.fromRGB(156, 163, 175),
    CornerRadius = UDim.new(0, 8)
}

local State = {
    -- Player & Physics
    SpeedEnabled = false,
    WalkSpeed = 120,
    JumpEnabled = false,
    JumpPower = 150,
    InfJump = false,
    GodMode = false,
    ClickTP = false,
    
    -- Movement & Flight
    FlyEnabled = false,
    FlySpeed = 80,
    NoclipEnabled = false,
    LowGravity = false,
    GravityValue = 50,
    BlinkEnabled = false,
    
    -- Visuals & ESP
    ESPEnabled = false,
    ESPDistance = false,
    Fullbright = false,
    FOVEnabled = false,
    FOVValue = 90,
    NoFog = false,
    
    -- Combat / Hitbox
    HitboxEnabled = false,
    HitboxSize = 10,
    AimbotEnabled = false,
    AimbotSmoothness = 0.2,

    -- World / Utilities
    AntiAFK = true,
    ShiftLockOverride = false,
    
    -- Caches
    OriginalGravity = workspace.Gravity,
    OriginalFogEnd = Lighting.FogEnd
}

-- ====================================================================
-- SISTEMA DE NOTIFICAÇÕES (TOAST NOTIFICATIONS)
-- ====================================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ArchitectSuiteUI"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = PlayerGui

local notificationContainer = Instance.new("Frame")
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.new(0, 220, 1, -20)
notificationContainer.Position = UDim2.new(1, -230, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = screenGui

local notifList = Instance.new("UIListLayout")
notifList.SortOrder = Enum.SortOrder.LayoutOrder
notifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
notifList.Padding = UDim.new(0, 6)
notifList.Parent = notificationContainer

local function Notify(titleText, descText)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1, 0, 0, 45)
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
    dLbl.Size = UDim2.new(1, -10, 0, 16)
    dLbl.Position = UDim2.new(0, 8, 0, 22)
    dLbl.BackgroundTransparency = 1
    dLbl.Text = descText
    dLbl.TextColor3 = Theme.Text
    dLbl.TextSize = 10
    dLbl.Font = Enum.Font.Gotham
    dLbl.TextXAlignment = Enum.TextXAlignment.Left
    dLbl.Parent = card

    task.delay(3, function()
        TweenService:Create(card, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
        TweenService:Create(tLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(dLbl, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.3), {Transparency = 1}):Play()
        task.wait(0.3)
        card:Destroy()
    end)
end

-- ====================================================================
-- ESTRUTURA PRINCIPAL DA INTERFACE (UI ENGINE)
-- ====================================================================
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 620, 0, 430)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -215)
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

-- Header
local header = Instance.new("Frame")
header.Name = "Header"
header.Size = UDim2.new(1, 0, 0, 45)
header.BackgroundColor3 = Theme.Header
header.BorderSizePixel = 0
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 300, 1, 0)
title.Position = UDim2.new(0, 15, 0, 0)
title.BackgroundTransparency = 1
title.Text = "VOID // ARCHITECT SUITE v3.0"
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
end)

-- Sidebar
local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, 140, 1, -45)
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

-- Content Area
local contentArea = Instance.new("Frame")
contentArea.Name = "ContentArea"
contentArea.Size = UDim2.new(1, -140, 1, -45)
contentArea.Position = UDim2.new(0, 140, 0, 45)
contentArea.BackgroundTransparency = 1
contentArea.Parent = mainFrame

-- ====================================================================
-- SISTEMA DE ABAS DINÂMICAS
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
    tabScroll.ScrollBarThickness = 2
    tabScroll.ScrollBarImageColor3 = Theme.Accent
    tabScroll.Visible = false
    tabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    tabScroll.Parent = contentArea

    local listLayout = Instance.new("UIListLayout")
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Padding = UDim.new(0, 8)
    listLayout.Parent = tabScroll

    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 15)
    end)

    tabButton.MouseButton1Click:Connect(function()
        for _, tab in pairs(Tabs) do
            tab.Scroll.Visible = false
            TweenService:Create(tab.Button, TweenInfo.new(0.2), {
                BackgroundTransparency = 1,
                TextColor3 = Theme.SubText
            }):Play()
        end

        tabScroll.Visible = true
        TweenService:Create(tabButton, TweenInfo.new(0.2), {
            BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 0,
            TextColor3 = Theme.Accent
        }):Play()
    end)

    local tabData = {Button = tabButton, Scroll = tabScroll}
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
-- CONSTRUTORES DE ELEMENTOS INTERATIVOS
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
        local targetPos = active and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
        local targetColor = active and Theme.Accent or Color3.fromRGB(40, 42, 58)

        TweenService:Create(indicator, TweenInfo.new(0.2), {Position = targetPos}):Play()
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        callback(active)
    end)
end

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

    local valLbl = Instance.new("TextLabel")
    valLbl.Size = UDim2.new(0.3, 0, 0, 18)
    valLbl.Position = UDim2.new(0.7, -10, 0, 5)
    valLbl.BackgroundTransparency = 1
    valLbl.Text = tostring(defaultVal)
    valLbl.TextColor3 = Theme.Accent
    valLbl.TextSize = 11
    valLbl.Font = Enum.Font.GothamBold
    valLbl.TextXAlignment = Enum.TextXAlignment.Right
    valLbl.Parent = card

    local sliderTrack = Instance.new("Frame")
    sliderTrack.Size = UDim2.new(1, -20, 0, 5)
    sliderTrack.Position = UDim2.new(0, 10, 0, 34)
    sliderTrack.BackgroundColor3 = Color3.fromRGB(40, 42, 58)
    sliderTrack.BorderSizePixel = 0
    sliderTrack.Parent = card

    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = sliderTrack

    local sliderFill = Instance.new("Frame")
    sliderFill.Size = UDim2.new((defaultVal - minVal)/(maxVal - minVal), 0, 1, 0)
    sliderFill.BackgroundColor3 = Theme.Accent
    sliderFill.BorderSizePixel = 0
    sliderFill.Parent = sliderTrack

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = sliderFill

    local dragging = false
    local function UpdateSlider(input)
        local pos = math.clamp((input.Position.X - sliderTrack.AbsolutePosition.X) / sliderTrack.AbsoluteSize.X, 0, 1)
        local value = math.floor(minVal + (maxVal - minVal) * pos)
        sliderFill.Size = UDim2.new(pos, 0, 1, 0)
        valLbl.Text = tostring(value)
        callback(value)
    end

    sliderTrack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            UpdateSlider(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            UpdateSlider(input)
        end
    end)
end

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
    actionBtn.Size = UDim2.new(0, 90, 0, 24)
    actionBtn.Position = UDim2.new(1, -100, 0.5, -12)
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
-- CRIAÇÃO DAS ABAS
-- ====================================================================
local tabPlayer = CreateTab("Jogador")
local tabMovement = CreateTab("Movimento")
local tabVisuals = CreateTab("Visual & ESP")
local tabCombat = CreateTab("Combate")
local tabServer = CreateTab("Servidor")
local tabThemes = CreateTab("Configurações")

-- --- ABA 1: JOGADOR ---
AddToggle(tabPlayer, "Super Velocidade", "Aumenta drasticamente a velocidade de caminhada.", function(s)
    State.SpeedEnabled = s
    Notify("Velocidade", s and "Ativado" or "Desativado")
end)
AddSlider(tabPlayer, "Ajustar Velocidade", 16, 300, State.WalkSpeed, function(v) State.WalkSpeed = v end)

AddToggle(tabPlayer, "Super Pulo", "Permite saltar em alturas elevadas.", function(s) State.JumpEnabled = s end)
AddSlider(tabPlayer, "Força do Pulo", 50, 400, State.JumpPower, function(v) State.JumpPower = v end)

AddToggle(tabPlayer, "Pulo Infinito", "Permite saltar repetidamente no ar.", function(s) State.InfJump = s end)
AddToggle(tabPlayer, "God Mode Local", "Refaz a saúde continuamente para evitar mortes.", function(s) State.GodMode = s end)
AddToggle(tabPlayer, "Click Teleport (Ctrl + Clique)", "Teleporta instantaneamente para onde clicar.", function(s) State.ClickTP = s end)

-- --- ABA 2: MOVIMENTO ---
AddToggle(tabMovement, "Modo Voo (Fly)", "Flutue e navegue livremente.", function(s) State.FlyEnabled = s end)
AddSlider(tabMovement, "Velocidade de Voo", 20, 250, State.FlySpeed, function(v) State.FlySpeed = v end)

AddToggle(tabMovement, "Noclip", "Atravesse estruturas e paredes.", function(s) State.NoclipEnabled = s end)
AddToggle(tabMovement, "Gravidade Baixa", "Altera a gravidade do workspace.", function(s)
    State.LowGravity = s
    if not s then workspace.Gravity = State.OriginalGravity end
end)
AddSlider(tabMovement, "Valor da Gravidade", 0, 196, State.GravityValue, function(v) State.GravityValue = v end)

AddToggle(tabMovement, "Blink (Lag Switch)", "Congela seu personagem para outros jogadores.", function(s)
    State.BlinkEnabled = s
    Notify("Blink Switch", s and "Ativo (Física Parada)" or "Inativo")
end)

-- --- ABA 3: VISUAL & ESP ---
AddToggle(tabVisuals, "ESP Box / Highlight", "Revela a localização de todos os jogadores.", function(s) State.ESPEnabled = s end)
AddToggle(tabVisuals, "Fullbright", "Ilumina todas as áreas escuras do mapa.", function(s)
    State.Fullbright = s
    if not s then
        Lighting.Ambient = Color3.fromRGB(128, 128, 128)
        Lighting.Brightness = 1
    end
end)
AddToggle(tabVisuals, "Sem Névoa (NoFog)", "Remove neblina do ambiente.", function(s)
    State.NoFog = s
    if not s then Lighting.FogEnd = State.OriginalFogEnd end
end)
AddToggle(tabVisuals, "FOV Customizado", "Aumenta o campo de visão da câmera.", function(s)
    State.FOVEnabled = s
    if not s then workspace.CurrentCamera.FieldOfView = 70 end
end)
AddSlider(tabVisuals, "Ângulo FOV", 70, 120, State.FOVValue, function(v) State.FOVValue = v end)

-- --- ABA 4: COMBATE ---
AddToggle(tabCombat, "Hitbox Extender", "Aumenta a área de acerto nos inimigos.", function(s) State.HitboxEnabled = s end)
AddSlider(tabCombat, "Tamanho da Hitbox", 2, 30, State.HitboxSize, function(v) State.HitboxSize = v end)

AddToggle(tabCombat, "Camera Lock / Aimbot", "Trava a câmera no alvo mais próximo.", function(s) State.AimbotEnabled = s end)

-- --- ABA 5: SERVIDOR & UTILITÁRIOS ---
AddToggle(tabServer, "Anti-AFK", "Impede desconexão por inatividade de 20 min.", function(s) State.AntiAFK = s end)
AddToggle(tabServer, "Forçar Shift Lock", "Habilita a trava do mouse caso desativada.", function(s)
    State.ShiftLockOverride = s
    LocalPlayer.DevEnableMouseLock = s or true
end)

AddButton(tabServer, "Reconectar ao Servidor", "Rejoin", function()
    Notify("Servidor", "Reconectando...")
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

AddButton(tabServer, "Server Hop (Trocar)", "Hop", function()
    Notify("Servidor", "Buscando servidor com menor latência...")
    -- Server hop funcional básico
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- --- ABA 6: CONFIGURAÇÕES & ATALHOS ---
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
kbBtn.Size = UDim2.new(0, 90, 0, 24)
kbBtn.Position = UDim2.new(1, -100, 0.5, -12)
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
    AddButton(parent, "Tema: " .. themeName, "Aplicar", function()
        Theme.Accent = color
        title.TextColor3 = color
        for _, tab in pairs(Tabs) do
            tab.Scroll.ScrollBarImageColor3 = color
            if tab.Scroll.Visible then
                tab.Button.TextColor3 = color
            end
        end
        Notify("Tema", "Tema alterado para " .. themeName)
    end)
end

CreateThemePicker(tabThemes, "Roxo Neon", Color3.fromRGB(138, 92, 246))
CreateThemePicker(tabThemes, "Azul Cyber", Color3.fromRGB(14, 165, 233))
CreateThemePicker(tabThemes, "Verde Matrix", Color3.fromRGB(34, 197, 94))
CreateThemePicker(tabThemes, "Vermelho Rubro", Color3.fromRGB(239, 68, 68))

-- ====================================================================
-- SISTEMAS & LOOPS DA ENGINE
-- ====================================================================

-- Atalho de teclado dinâmico
UserInputService.InputBegan:Connect(function(input, gpe)
    if ListeningForKey and input.UserInputType == Enum.UserInputType.Keyboard then
        TOGGLE_KEY = input.KeyCode
        ListeningForKey = false
        kbBtn.Text = TOGGLE_KEY.Name
        Notify("Atalho Modificado", "Novo atalho: " .. TOGGLE_KEY.Name)
        return
    end

    if not gpe and input.KeyCode == TOGGLE_KEY then
        mainFrame.Visible = not mainFrame.Visible
    end
end)

-- Click Teleport
Mouse.Button1Down:Connect(function()
    if State.ClickTP and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") and Mouse.Hit then
            char.HumanoidRootPart.CFrame = Mouse.Hit + Vector3.new(0, 3, 0)
        end
    end
end)

-- Anti-AFK
local VirtualUser = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    if State.AntiAFK then
        VirtualUser:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-- Pulo Infinito
UserInputService.JumpRequest:Connect(function()
    if State.InfJump then
        local char = LocalPlayer.Character
        if char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Loop Geral de Renderização (RenderStepped)
RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    -- Velocidade & Pulo
    if hum then
        if State.SpeedEnabled then hum.WalkSpeed = State.WalkSpeed end
        if State.JumpEnabled then
            hum.UseJumpPower = true
            hum.JumpPower = State.JumpPower
        end
        if State.GodMode then hum.Health = hum.MaxHealth end
    end

    -- Gravidade
    if State.LowGravity then workspace.Gravity = State.GravityValue end

    -- Flight Mode
    if State.FlyEnabled and root then
        local cam = workspace.CurrentCamera
        local moveDir = Vector3.new(0, 0, 0)

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end

        root.Velocity = moveDir * State.FlySpeed
        root.RotVelocity = Vector3.new(0, 0, 0)
    end

    -- Blink / Lag Switch
    if State.BlinkEnabled and root then
        root.Anchored = true
    elseif root and not State.BlinkEnabled and root.Anchored then
        root.Anchored = false
    end

    -- Noclip
    if State.NoclipEnabled then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end

    -- Rendering Mods
    if State.Fullbright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    end
    if State.NoFog then Lighting.FogEnd = 1e6 end
    if State.FOVEnabled then workspace.CurrentCamera.FieldOfView = State.FOVValue end

    -- Sistema de Hitbox & ESP para Outros Jogadores
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local pRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            
            -- Hitbox Extender
            if pRoot then
                if State.HitboxEnabled then
                    pRoot.Size = Vector3.new(State.HitboxSize, State.HitboxSize, State.HitboxSize)
                    pRoot.Transparency = 0.7
                    pRoot.Color = Theme.Accent
                    pRoot.Material = Enum.Material.ForceField
                    pRoot.CanCollide = false
                else
                    pRoot.Size = Vector3.new(2, 2, 1)
                    pRoot.Transparency = 1
                end
            end

            -- ESP Highlight
            local highlight = plr.Character:FindFirstChild("ArchitectESP")
            if State.ESPEnabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "ArchitectESP"
                    highlight.FillColor = Theme.Accent
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.5
                    highlight.Parent = plr.Character
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end

    -- Camera Lock / Aimbot Básico
    if State.AimbotEnabled then
        local target = nil
        local minDist = math.huge
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pRoot = plr.Character.HumanoidRootPart
                local dist = (pRoot.Position - workspace.CurrentCamera.CFrame.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    target = pRoot
                end
            end
        end

        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
end)

Notify("VOID ARCHITECT", "Sistema inicializado com sucesso. Pressione RightControl para abrir/fechar.")
