--[[
    ╔══════════════════════════════════════════════════════════╗
    ║               SWORD MASTER PRO - FLOATING PROGRESS       ║
    ║        TEMA: SUPER RED | SEM BIBLIOTECAS EXTERNAS        ║
    ║          100% COMPATÍVEL COM DELTA / MOBILE              ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Remove versões antigas
if CoreGui:FindFirstChild("ReyzimHubCustom") then CoreGui.ReyzimHubCustom:Destroy() end

-- [ CONFIGURAÇÕES ]
local espadasConfig = {
    {nome = "Yama", meta = 350},
    {nome = "Tushita", meta = 350},
    {nome = "Saishi", meta = 300},
    {nome = "Shizu", meta = 300},
    {nome = "Oroshi", meta = 300}
}
_G.MasteryEnabled = false

-- [ CRIAÇÃO DA INTERFACE ]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ReyzimHubCustom"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Botão Flutuante (Logo + Progresso)
local FloatingContainer = Instance.new("Frame")
local FloatingLogo = Instance.new("ImageButton")
local FloatingCorner = Instance.new("UICorner")
local FloatingStroke = Instance.new("UIStroke")
local FloatingText = Instance.new("TextLabel")

FloatingContainer.Name = "FloatingContainer"
FloatingContainer.Parent = ScreenGui
FloatingContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingContainer.BackgroundTransparency = 1 -- Invisível, serve para agrupar
FloatingContainer.Position = UDim2.new(0.1, 0, 0.2, 0)
FloatingContainer.Size = UDim2.new(0, 60, 0, 85) -- Aumentado para caber o texto embaixo

FloatingLogo.Name = "FloatingLogo"
FloatingLogo.Parent = FloatingContainer
FloatingLogo.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
FloatingLogo.Size = UDim2.new(0, 60, 0, 60)
FloatingLogo.Image = "https://raw.githubusercontent.com/gtzimooo/raw-poder-remove/refs/heads/main/file_000000007644720ea092ead937d3b54d.png"
FloatingLogo.Draggable = true
FloatingLogo.Active = true

FloatingCorner.CornerRadius = UDim.new(1, 0)
FloatingCorner.Parent = FloatingLogo

FloatingStroke.Color = Color3.fromRGB(255, 0, 0)
FloatingStroke.Thickness = 2
FloatingStroke.Parent = FloatingLogo

FloatingText.Name = "ProgressText"
FloatingText.Parent = FloatingContainer
FloatingText.Position = UDim2.new(0, -20, 0, 65)
FloatingText.Size = UDim2.new(0, 100, 0, 20)
FloatingText.BackgroundTransparency = 0.5
FloatingText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
FloatingText.Text = "Aguardando..."
FloatingText.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatingText.Font = Enum.Font.GothamBold
FloatingText.TextSize = 10
FloatingText.Visible = true

local TextCorner = Instance.new("UICorner", FloatingText)
TextCorner.CornerRadius = UDim.new(0, 5)

-- Painel Principal
local MainFrame = Instance.new("Frame")
local MainCorner = Instance.new("UICorner")
local MainStroke = Instance.new("UIStroke")
local Title = Instance.new("TextLabel")
local StatusLabel = Instance.new("TextLabel")
local Container = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")

MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -150)
MainFrame.Size = UDim2.new(0, 260, 0, 320)
MainFrame.Visible = false
MainFrame.ClipsDescendants = true

MainCorner.CornerRadius = UDim.new(0, 15)
MainCorner.Parent = MainFrame

MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

Title.Name = "Title"
Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0, 45)
Title.BackgroundTransparency = 1
Title.Text = "SWORD MASTER PRO"
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16

StatusLabel.Name = "Status"
StatusLabel.Parent = MainFrame
StatusLabel.Position = UDim2.new(0, 10, 0, 45)
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Status: Aguardando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ToggleBtn = Instance.new("TextButton")
local ToggleCorner = Instance.new("UICorner")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = MainFrame
ToggleBtn.Position = UDim2.new(0, 10, 0, 80)
ToggleBtn.Size = UDim2.new(1, -20, 0, 35)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
ToggleBtn.Text = "INICIAR AUTO MASTERY"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 13
ToggleCorner.CornerRadius = UDim.new(0, 8)
ToggleCorner.Parent = ToggleBtn

Container.Name = "Container"
Container.Parent = MainFrame
Container.Position = UDim2.new(0, 10, 0, 125)
Container.Size = UDim2.new(1, -20, 1, -135)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 0, 300)
UIListLayout.Parent = Container
UIListLayout.Padding = UDim.new(0, 8)

local labels = {}
for _, espada in ipairs(espadasConfig) do
    local ItemFrame = Instance.new("Frame")
    local ItemCorner = Instance.new("UICorner")
    local ItemLabel = Instance.new("TextLabel")
    ItemFrame.Size = UDim2.new(1, -5, 0, 40)
    ItemFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    ItemFrame.Parent = Container
    ItemCorner.CornerRadius = UDim.new(0, 8)
    ItemCorner.Parent = ItemFrame
    ItemLabel.Size = UDim2.new(1, -10, 1, 0)
    ItemLabel.Position = UDim2.new(0, 10, 0, 0)
    ItemLabel.BackgroundTransparency = 1
    ItemLabel.Text = "⚔️ " .. espada.nome .. ": Verificando..."
    ItemLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
    ItemLabel.Font = Enum.Font.Gotham
    ItemLabel.TextSize = 11
    ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
    ItemLabel.Parent = ItemFrame
    labels[espada.nome] = ItemLabel
end

-- [ LÓGICA DE INTERAÇÃO ]
FloatingLogo.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

ToggleBtn.MouseButton1Click:Connect(function()
    _G.MasteryEnabled = not _G.MasteryEnabled
    if _G.MasteryEnabled then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        ToggleBtn.Text = "PARAR AUTO MASTERY"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        ToggleBtn.Text = "INICIAR AUTO MASTERY"
        FloatingText.Text = "Parado"
    end
end)

-- [ LÓGICA DE MAESTRIA COM PROGRESSO NO FLUTUANTE ]
task.spawn(function()
    while true do
        task.wait(1)
        if _G.MasteryEnabled then
            for _, espada in ipairs(espadasConfig) do
                if not _G.MasteryEnabled then break end
                
                local nome = espada.nome
                local meta = espada.meta
                
                StatusLabel.Text = "Status: Verificando " .. nome
                FloatingText.Text = "Checando " .. nome
                
                pcall(function() 
                    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LoadItem", nome) 
                end)
                task.wait(2.5)
                
                local item = LocalPlayer.Character:FindFirstChild(nome) or LocalPlayer.Backpack:FindFirstChild(nome)
                
                if item then
                    local level = item:GetAttribute("Level") or 0
                    if level < meta then
                        while level < meta and _G.MasteryEnabled do
                            if not LocalPlayer.Character:FindFirstChild(nome) then
                                pcall(function() game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LoadItem", nome) end)
                            end
                            level = item:GetAttribute("Level") or 0
                            
                            -- ATUALIZAÇÃO EM TEMPO REAL NO FLUTUANTE
                            FloatingText.Text = nome .. ": " .. level .. "/" .. meta
                            StatusLabel.Text = "Status: Upando " .. nome
                            labels[nome].Text = "⚔️ " .. nome .. ": " .. level .. " / " .. meta .. " [ATIVO]"
                            labels[nome].TextColor3 = Color3.fromRGB(255, 100, 100)
                            
                            task.wait(3)
                        end
                        labels[nome].Text = "⚔️ " .. nome .. ": Concluído ✓"
                        labels[nome].TextColor3 = Color3.fromRGB(100, 255, 100)
                    else
                        labels[nome].Text = "⚔️ " .. nome .. ": Já atingiu a meta ✓"
                        labels[nome].TextColor3 = Color3.fromRGB(100, 255, 100)
                    end
                else
                    labels[nome].Text = "⚔️ " .. nome .. ": Não encontrada ✗"
                end
            end
            FloatingText.Text = "Finalizado ✅"
        end
    end
end)

-- Arrastar o container inteiro quando a logo for arrastada
FloatingLogo.Changed:Connect(function()
    FloatingContainer.Position = FloatingLogo.Position
end)

StatusLabel.Text = "Status: Hub Reyzim Pronto!"
