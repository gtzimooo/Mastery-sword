-- ========================================================= --
--  SCRIPT ATUALIZADO: ATRIBUTOS DO DEX E CORREÇÃO DE PAINEL   --
-- ========================================================= --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local PlayerGui = localPlayer:WaitForChild("PlayerGui")

-- Remove o painel antigo se ele existir
if PlayerGui:FindFirstChild("MasteryManagerUI") then 
    PlayerGui.MasteryManagerUI:Destroy() 
end

local espadasConfig = {
    {nome = "Yama", meta = 350},
    {nome = "Tushita", meta = 350},
    {nome = "Saishi", meta = 300},
    {nome = "Shizu", meta = 300},
    {nome = "Oroshi", meta = 300}
}

-- [Criação do Painel Visível]
local ScreenGui = Instance.new("ScreenGui", PlayerGui)
ScreenGui.Name = "MasteryManagerUI"
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.25, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.2
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true

local UICorner = Instance.new("UICorner", MainFrame)
UICorner.CornerRadius = UDim.new(0, 14)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ SWORD MASTER"
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 15

local StatusLabel = Instance.new("TextLabel", MainFrame)
StatusLabel.Size = UDim2.new(1, -20, 0, 35)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Iniciando..."
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.GothamSemibold
StatusLabel.TextSize = 12
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

local ListContainer = Instance.new("Frame", MainFrame)
ListContainer.Size = UDim2.new(1, -20, 1, -80)
ListContainer.Position = UDim2.new(0, 10, 0, 75)
ListContainer.BackgroundTransparency = 1

local UIListLayout = Instance.new("UIListLayout", ListContainer)
UIListLayout.Padding = UDim.new(0, 5)

local labelsEspadas = {}
for _, espada in ipairs(espadasConfig) do
    local ItemLabel = Instance.new("TextLabel", ListContainer)
    ItemLabel.Size = UDim2.new(1, 0, 0, 22)
    ItemLabel.BackgroundTransparency = 1
    ItemLabel.Text = "• " .. espada.nome .. ": Carregando..."
    ItemLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
    ItemLabel.Font = Enum.Font.Gotham
    ItemLabel.TextSize = 12
    ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
    labelsEspadas[espada.nome] = ItemLabel
end

-- [Funções de Logica]
local function equiparEspada(nomeEspada)
    pcall(function() 
        ReplicatedStorage.Remotes.CommF_:InvokeServer("LoadItem", nomeEspada) 
    end)
end

-- Nova função baseada estritamente nas propriedades exibidas no seu Dex
local function obterLevelAtual(nomeEspada)
    local level = 0
    
    -- 1. Tenta procurar o item se ele estiver equipado no seu Personagem (Character)
    local char = localPlayer.Character
    local itemNoChar = char and char:FindFirstChild(nomeEspada)
    if itemNoChar then
        local attr = itemNoChar:GetAttribute("Level")
        if attr then return tonumber(attr) end
    end
    
    -- 2. Tenta procurar o item guardado na sua Mochila (Backpack)
    local backpack = localPlayer:FindFirstChild("Backpack")
    local itemNaMochila = backpack and backpack:FindFirstChild(nomeEspada)
    if itemNaMochila then
        local attr = itemNaMochila:GetAttribute("Level")
        if attr then return tonumber(attr) end
    end
    
    return level
end

-- [Loop de Atualização]
task.spawn(function()
    while true do
        for _, espada in ipairs(espadasConfig) do
            local nome = espada.nome
            local meta = espada.meta
            
            StatusLabel.Text = "⚙️ Equipando: " .. nome
            equiparEspada(nome)
            task.wait(2) -- Tempo necessário para a arma carregar e registrar o Atributo
            
            local levelAtual = obterLevelAtual(nome)
            
            if levelAtual < meta then
                repeat
                    levelAtual = obterLevelAtual(nome)
                    
                    -- Mostra o progresso do level mudando em tempo real no painel
                    StatusLabel.Text = "🆙 Upando: " .. nome .. " (Lv " .. levelAtual .. ")"
                    labelsEspadas[nome].Text = "• " .. nome .. ": " .. levelAtual .. " / " .. meta
                    labelsEspadas[nome].TextColor3 = Color3.fromRGB(255, 110, 110)
                    
                    task.wait(1.5) -- Atualiza a cada 1.5 segundos
                until levelAtual >= meta or not localPlayer.Parent
                
                labelsEspadas[nome].Text = "• " .. nome .. ": [MAX] ✓"
                labelsEspadas[nome].TextColor3 = Color3.fromRGB(110, 255, 110)
            else
                labelsEspadas[nome].Text = "• " .. nome .. ": " .. levelAtual .. " [PRONTA] ✓"
                labelsEspadas[nome].TextColor3 = Color3.fromRGB(110, 255, 110)
            end
        end
        StatusLabel.Text = "✅ Todas as espadas concluídas!"
        task.wait(5)
    end
end)
