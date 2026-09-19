local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Serviços do Roblox
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

-- Dados do Usuário Local (Denunciante)
local LocalPlayer = Players.LocalPlayer
local playerUserId = LocalPlayer.UserId
local playerNick = LocalPlayer.Name
local playerDisplayName = LocalPlayer.DisplayName

-- Nova Webhook
local webhookURL = "COLOQUE_AQUI_SUA_WEBHOOK_DO_DISCORD"

-- Variáveis de seleção
local alvoSelecionado = nil
local motivoAcusacao = "Sem motivo especificado"

-- Função para atualizar a lista de jogadores no Dropdown
local function obterListaJogadores()
    local lista = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(lista, p.Name .. " (@" .. p.DisplayName .. ")")
    end
    return lista
end

-- Janela Principal
local Window = Rayfield:CreateWindow({
   Name = "Gustavo Hub help",
   LoadingTitle = "Carregando Interface...",
   LoadingSubtitle = "por Gustavo Hub",
   ConfigurationSaving = {
      Enabled = false
   }
})

-- Aba do Sistema de Denúncias
local Tab = Window:CreateTab("Denunciar", 4483362458)

Tab:CreateSection("Painel de Acusação")

-- Dropdown para selecionar o jogador do servidor
local PlayerDropdown = Tab:CreateDropdown({
   Name = "Selecionar Jogador Acusado",
   Options = obterListaJogadores(),
   CurrentOption = {"Selecione um jogador..."},
   MultipleOptions = false,
   Callback = function(Option)
      local nomeLimpo = Option[1]:split(" ")[1] -- Extrai apenas o username
      alvoSelecionado = Players:FindFirstChild(nomeLimpo)
   end,
})

-- Botão para atualizar a lista de jogadores caso entre/saia alguém
Tab:CreateButton({
   Name = "🔄 Atualizar Lista de Players",
   Callback = function()
      PlayerDropdown:Refresh(obterListaJogadores())
   end,
})

-- Input para o motivo da denúncia
Tab:CreateInput({
   Name = "Motivo da Acusação",
   PlaceholderText = "Digite o motivo da denúncia...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      motivoAcusacao = Text
   end,
})

-- Botão para Enviar a Denúncia
Tab:CreateButton({
   Name = "🚨 Enviar Denúncia para Webhook",
   Callback = function()
      if not alvoSelecionado then
         Rayfield:Notify({
            Title = "Aviso!",
            Content = "Por favor, selecione um jogador na lista primeiro.",
            Duration = 4,
            Image = 4483362458,
         })
         return
      end

      local placeId = game.PlaceId
      local jobId = game.JobId
      local playerCount = #Players:GetPlayers()
      
      -- Código de teleporte formatado
      local codigoTeleporte = string.format(
         "local TeleportService = game:GetService(\"TeleportService\")\n" ..
         "TeleportService:TeleportToPlaceInstance(%d, \"%s\", game:GetService(\"Players\").LocalPlayer)",
         placeId, jobId
      )
      
      -- Montagem do Embed idêntico ao modelo
      local embed = {
         ["title"] = "🚨 Alerta de Denúncia de Jogador",
         ["color"] = 16711680, -- Vermelho de alerta
         ["fields"] = {
            {
               ["name"] = "Acusado (Detectado)",
               ["value"] = string.format("**User:** %s\n**Display:** %s\n**ID:** %d", alvoSelecionado.Name, alvoSelecionado.DisplayName, alvoSelecionado.UserId),
               ["inline"] = false
            },
            {
               ["name"] = "Acusação",
               ["value"] = motivoAcusacao,
               ["inline"] = false
            },
            {
               ["name"] = "Denunciado por",
               ["value"] = string.format("%s (%d)", playerNick, playerUserId),
               ["inline"] = false
            },
            {
               ["name"] = "Players Online",
               ["value"] = tostring(playerCount),
               ["inline"] = false
            },
            {
               ["name"] = "Código de Teleporte",
               ["value"] = "```lua\n" .. codigoTeleporte .. "\n```",
               ["inline"] = false
            }
         },
         ["footer"] = {
            ["text"] = "Sistema de Verificação Gustavo Hub"
         }
      }
      
      local data = {
         ["embeds"] = { embed }
      }
      
      -- Requisição HTTP
      local urlRequest = (syn and syn.request) or (http and http.request) or http_request or request
      
      if urlRequest then
         urlRequest({
            Url = webhookURL,
            Method = "POST",
            Headers = {
               ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
         })
         
         Rayfield:Notify({
            Title = "Denúncia Enviada!",
            Content = "O alerta foi enviado com sucesso para a Webhook.",
            Duration = 3,
            Image = 4483362458,
         })
      else
         Rayfield:Notify({
            Title = "Erro!",
            Content = "O teu executor não suporta requisições HTTP.",
            Duration = 5,
            Image = 4483362458,
         })
      end
   end,
})
