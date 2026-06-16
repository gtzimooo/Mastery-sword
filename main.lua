-- ========================================== --
--  SCRIPT DE AUTO-SWAP ESPADAS (BLOX FRUITS) --
-- ========================================== --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local localPlayer = Players.LocalPlayer

-- Configuração das Espadas e suas metas de Level
local espadasConfig = {
    {nome = "Yama", meta = 350},
    {nome = "Tushita", meta = 350},
    {nome = "Saishi", meta = 300},
    {nome = "Shizu", meta = 300},
    {nome = "Oroshi", meta = 300}
}

-- 1. CRIANDO A INTERFACE FLUTUANTE PROFISSIONAL
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasteryManagerUI"
ScreenGui.ResetOnSpawn = false

-- Tratamento para injetores (Delta / Mobile)
if syn and syn.protect_gui then
    syn.protect_gui(ScreenGui)
    ScreenGui.Parent = game:CoreGui
elseif getgui then
    ScreenGui.Parent = getgui()
else
    local success, errorMsg = pcall(function()
        ScreenGui.Parent = game:CoreGui
    end)
    if not success then
        ScreenGui.Parent = localPlayer:WaitForChild("PlayerGui")
    end
end

-- Painel Principal (Bordas arredondadas, tema Escuro/Moderno)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 220)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0) -- Aparece flutuando no canto esquerdo
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.15
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Você pode arrastar a interface para onde quiser
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 16) -- Bordas bem redondas e elegantes
UICorner.Parent = MainFrame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "⚔️ SWORD MASTER"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Dourado
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- Status Atual (Qual espada está equipada e o status)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 35)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Inicializando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 13
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
StatusLabel.Parent = MainFrame

-- Linha de Separação
local Line = Instance.new("Frame")
Line.Size = UDim2.new(1, -20, 0, 1)
Line.Position = UDim2.new(0, 10, 0, 75)
Line.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
Line.BorderSizePixel = 0
Line.Parent = MainFrame

-- Container para a lista das espadas
local ListContainer = Instance.new("Frame")
ListContainer.Size = UDim2.new(1, -20, 1, -85)
ListContainer.Position = UDim2.new(0, 10, 0, 80)
ListContainer.BackgroundTransparency = 1
ListContainer.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 6)
UIListLayout.Parent = ListContainer

-- Criando as labels estáticas de progresso para cada espada
local labelsEspadas = {}
for i, espada in ipairs(espadasConfig) do
    local ItemLabel = Instance.new("TextLabel")
    ItemLabel.Size = UDim2.new(1, 0, 0, 20)
    ItemLabel.BackgroundTransparency = 1
    ItemLabel.Text = "• " .. espada.nome .. " (Aguardando...)"
    ItemLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    ItemLabel.Font = Enum.Font.GothamSemibold
    ItemLabel.TextSize = 12
    ItemLabel.TextXAlignment = Enum.TextXAlignment.Left
    ItemLabel.Parent = ListContainer
    
    labelsEspadas[espada.nome] = ItemLabel
end

-- 2. SISTEMA LOGICO DE TROCA E VERIFICAÇÃO DE MAESTRIA
local function equiparEspada(nomeEspada)
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    local args = {"LoadItem", nomeEspada}
    commF:InvokeServer(unpack(args))
end

-- Função para ler o nível atual da espada equipada
local function obterLevelAtual(nomeEspada)
    -- Método principal: Lendo os dados locais salvos no jogador
    local playerStats = localPlayer:FindFirstChild("Data")
    if playerStats then
        -- O Blox Fruits armazena maestria de várias formas, dependendo da versão do jogo
        -- Tentando localizar o registro direto da arma
        local inventoryData = playerStats:FindFirstChild("Inventory") or playerStats
        local armaObj = inventoryData:FindFirstChild(nomeEspada)
        if armaObj and armaObj:FindFirstChild("Level") then
            return armaObj.Level.Value
        elseif armaObj and armaObj:FindFirstChild("Mastery") then
            return armaObj.Mastery.Value
        end
    end

    -- Método Secundário: Lê direto do texto da interface se ela estiver visível na tela
    local mainGui = localPlayer:FindFirstChild("PlayerGui") and localPlayer.PlayerGui:FindFirstChild("Main")
    if mainGui then
        local masteryBar = mainGui:FindFirstChild("Action") and mainGui.Action:FindFirstChild("Mastery")
        if masteryBar and masteryBar.Visible then
            local textLabel = masteryBar:FindFirstChild("TextLabel") or masteryBar:FindFirstChild("Level")
            if textLabel then
                -- Filtra apenas os números do texto (ex: "Lv. 320" vira 320)
                local nivelDetectado = string.match(textLabel.Text, "%d+")
                if nivelDetectado then
                    return tonumber(nivelDetectado)
                end
            end
        end
    end

    return 0 -- Caso não encontre de primeira (acontece antes de atacar ou registrar o item)
end

-- Loop Principal de Monitoramento
task.spawn(function()
    while true do
        local todasProntas = true

        for _, espada in ipairs(espadasConfig) do
            local nome = espada.nome
            local meta = espada.meta
            
            StatusLabel.Text = "⚙️ Verificando: " .. nome .. "..."
            equiparEspada(nome)
            task.wait(1.5) -- Tempo para o jogo registrar que equipou
            
            local levelAtual = obterLevelAtual(nome)
            
            -- Se falhar em ler (0), o script espera um pouco para dar tempo de carregar a UI do jogo
            if levelAtual == 0 then
                StatusLabel.Text = "⏳ Carregando dados de " .. nome .. "..."
                task.wait(2)
                levelAtual = obterLevelAtual(nome)
            end

            if levelAtual < meta then
                todasProntas = false
                labelsEspadas[nome].Text = "• " .. nome .. ": " .. levelAtual .. " / " .. meta .. " ⚔️"
                labelsEspadas[nome].TextColor3 = Color3.fromRGB(255, 100, 100) -- Vermelho (Upar)
                StatusLabel.Text = "🔥 Upando agora: " .. nome
                
                -- Fica nessa espada até que ela atinja o nível da meta
                repeat
                    task.wait(3) -- Verifica o progresso a cada 3 segundos
                    levelAtual = obterLevelAtual(nome)
                    labelsEspadas[nome].Text = "• " .. nome .. ": " .. levelAtual .. " / " .. meta .. " ⚔️"
                until levelAtual >= meta or not localPlayer.Parent
                
                -- Quando termina de upar essa, atualiza visualmente para verde
                labelsEspadas[nome].Text = "• " .. nome .. ": " .. levelAtual .. " [MAX] ✓"
                labelsEspadas[nome].TextColor3 = Color3.fromRGB(100, 255, 100)
            else
                -- Se já estava no level certo, pula direto
                labelsEspadas[nome].Text = "• " .. nome .. ": " .. levelAtual .. " [PRONTA] ✓"
                labelsEspadas[nome].TextColor3 = Color3.fromRGB(100, 255, 100) -- Verde (Ok)
            end
        end

        if todasProntas then
            StatusLabel.Text = "🎉 🎉 TODAS AS ESPADAS DOMINADAS! 🎉 🎉"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
            break -- Encerra o script pois o objetivo foi alcançado
        end
        
        task.wait(1)
    end
end)
