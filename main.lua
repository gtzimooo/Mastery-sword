--[[
    ╔══════════════════════════════════════════════════════════╗
    ║               SWORD MASTER PRO - REYZIM                  ║
    ║        TEMA: RED PROFESSIONAL | LOGO FLUTUANTE           ║
    ║          OTIMIZADO PARA EXECUTORES MOBILE                ║
    ╚══════════════════════════════════════════════════════════╝
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Sword Master Pro - Reyzim",
    SubTitle = "Mastery Manager",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Configuração de Cores
Fluent.Options = {
    AccentColor = Color3.fromRGB(255, 0, 0),
    MainColor = Color3.fromRGB(20, 20, 20),
    BackgroundColor = Color3.fromRGB(15, 15, 15),
    OutlineColor = Color3.fromRGB(255, 0, 0)
}

-- FUNÇÃO PARA CARREGAR IMAGEM
local function GetImage(url)
    local success, result = pcall(function() return game:HttpGet(url) end)
    if success then
        local name = "ReyzimLogo.png"
        writefile(name, result)
        return getcustomasset(name)
    end
    return ""
end

-- BOTÃO FLUTUANTE
local ScreenGui = Instance.new("ScreenGui")
local ImageButton = Instance.new("ImageButton")
local UICorner = Instance.new("UICorner")
ScreenGui.Name = "SwordMasterFloatingLogo"
ScreenGui.Parent = game.CoreGui
ImageButton.Parent = ScreenGui
ImageButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
ImageButton.BackgroundTransparency = 0.3
ImageButton.Position = UDim2.new(0.1, 0, 0.6, 0)
ImageButton.Size = UDim2.new(0, 55, 0, 55)
ImageButton.Image = GetImage("https://raw.githubusercontent.com/gtzimooo/raw-poder-remove/refs/heads/main/file_000000007644720ea092ead937d3b54d.png")
ImageButton.Draggable = true
UICorner.CornerRadius = UDim.new(1, 0)
UICorner.Parent = ImageButton

local toggled = true
ImageButton.MouseButton1Click:Connect(function()
    toggled = not toggled
    if Window.Root then Window.Root.Visible = toggled end
    local gui = game.CoreGui:FindFirstChild("Fluent")
    if gui then gui.Enabled = toggled end
end)

-- CONFIGURAÇÕES DE ESPADAS
local espadasConfig = {
    {nome = "Yama", meta = 350},
    {nome = "Tushita", meta = 350},
    {nome = "Saishi", meta = 300},
    {nome = "Shizu", meta = 300},
    {nome = "Oroshi", meta = 300}
}

-- FUNÇÕES DE LOGICA
local function temAEspada(nomeEspada)
    local player = game:GetService("Players").LocalPlayer
    if player.Character:FindFirstChild(nomeEspada) or player.Backpack:FindFirstChild(nomeEspada) then
        return true
    end
    return false
end

local function equiparEspada(nomeEspada)
    pcall(function() 
        game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("LoadItem", nomeEspada) 
    end)
end

local function obterLevelAtual(nomeEspada)
    local player = game:GetService("Players").LocalPlayer
    local item = player.Character:FindFirstChild(nomeEspada) or player.Backpack:FindFirstChild(nomeEspada)
    if item then
        local attr = item:GetAttribute("Level")
        return attr and tonumber(attr) or 0
    end
    return 0
end

-- TABS
local Tabs = {
    Main = Window:AddTab({ Title = "Maestria", Icon = "swords" }),
    Settings = Window:AddTab({ Title = "Configurações", Icon = "settings" })
})

Tabs.Main:AddSection("Progresso de Maestria")

local StatusParagraph = Tabs.Main:AddParagraph({
    Title = "Status Atual",
    Content = "Verificando inventário..."
})

local labels = {}
for _, espada in ipairs(espadasConfig) do
    labels[espada.nome] = Tabs.Main:AddParagraph({
        Title = espada.nome,
        Content = "Aguardando..."
    })
end

-- LOOP DE AUTOMAÇÃO ATUALIZADO
_G.MasteryEnabled = false
Tabs.Main:AddToggle("MasteryToggle", {
    Title = "Iniciar Auto Mastery",
    Default = false,
    Callback = function(Value) _G.MasteryEnabled = Value end
})

spawn(function()
    while true do
        task.wait(1)
        if _G.MasteryEnabled then
            local algumaEspadaEncontrada = false
            
            for _, espada in ipairs(espadasConfig) do
                if not _G.MasteryEnabled then break end
                
                local nome = espada.nome
                local meta = espada.meta
                
                -- VERIFICAÇÃO SE O JOGADOR TEM A ESPADA
                if temAEspada(nome) then
                    algumaEspadaEncontrada = true
                    StatusParagraph:SetDesc("⚙️ Processando: " .. nome)
                    
                    equiparEspada(nome)
                    task.wait(2)
                    
                    local levelAtual = obterLevelAtual(nome)
                    
                    if levelAtual < meta then
                        while levelAtual < meta and _G.MasteryEnabled do
                            levelAtual = obterLevelAtual(nome)
                            StatusParagraph:SetDesc("🆙 Upando: " .. nome .. " (Lv " .. levelAtual .. ")")
                            labels[nome]:SetDesc("Progresso: " .. levelAtual .. " / " .. meta)
                            task.wait(2)
                        end
                    else
                        labels[nome]:SetDesc("Concluído: " .. levelAtual .. " [MAX] ✓")
                    end
                else
                    labels[nome]:SetDesc("Status: Não encontrada no inventário ✗")
                end
            end
            
            if not algumaEspadaEncontrada then
                StatusParagraph:SetDesc("❌ Nenhuma das espadas configuradas foi encontrada!")
            else
                StatusParagraph:SetDesc("✅ Ciclo de maestria concluído!")
            end
        end
    end
end)

-- SETTINGS
Tabs.Settings:AddButton({
    Title = "Destruir Hub",
    Callback = function() 
        _G.MasteryEnabled = false
        ScreenGui:Destroy()
        Window:Destroy() 
    end
})

Window:SelectTab(1)
Fluent:Notify({
    Title = "Sword Master Pro",
    Content = "Script atualizado com detecção de inventário!",
    Duration = 5
})
