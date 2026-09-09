local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local ContextActionService=game:GetService("ContextActionService")
local MarketplaceService=game:GetService("MarketplaceService")
local player=Players.LocalPlayer
local remotes=RS:WaitForChild("RodoviaRemotes")
local action=remotes:WaitForChild("TycoonAction")
local Config=require(RS.Shared.Config)
local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui")); gui.Name="TycoonUI"; gui.ResetOnSpawn=false

local toggle=Instance.new("TextButton",gui)
toggle.Size=UDim2.fromOffset(122,42); toggle.Position=UDim2.new(0,12,0,76)
toggle.BackgroundColor3=Color3.fromRGB(12,42,34); toggle.TextColor3=Color3.fromRGB(115,255,195)
toggle.Text="☰  GESTAO"; toggle.Font=Enum.Font.GothamBold; toggle.TextSize=14; toggle.AutoButtonColor=false
Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,12)
local toggleStroke=Instance.new("UIStroke",toggle); toggleStroke.Color=Color3.fromRGB(45,210,145); toggleStroke.Transparency=.25; toggleStroke.Thickness=1.5

local consoleHint=Instance.new("TextLabel",gui)
consoleHint.Size=UDim2.fromOffset(520,32); consoleHint.Position=UDim2.new(.5,-260,1,-44)
consoleHint.BackgroundColor3=Color3.fromRGB(10,22,28); consoleHint.BackgroundTransparency=.12
consoleHint.TextColor3=Color3.fromRGB(225,240,255); consoleHint.Text="LB MISSOES • Y GESTAO • RB LOJA • X VISAO • A CONFIRMAR • B VOLTAR"
consoleHint.Font=Enum.Font.GothamBold; consoleHint.TextSize=11; consoleHint.Visible=UserInputService.GamepadEnabled
Instance.new("UICorner",consoleHint).CornerRadius=UDim.new(0,10)

local panorama=Instance.new("TextButton",gui)
panorama.Size=UDim2.fromOffset(210,42); panorama.Position=UDim2.new(.5,-105,0,20)
panorama.BackgroundColor3=Color3.fromRGB(38,54,78); panorama.TextColor3=Color3.new(1,1,1)
panorama.Text="◉  VISAO PANORAMICA"; panorama.Font=Enum.Font.GothamBold; panorama.TextSize=13; panorama.AutoButtonColor=false
Instance.new("UICorner",panorama).CornerRadius=UDim.new(0,12)
local panoramaStroke=Instance.new("UIStroke",panorama); panoramaStroke.Color=Color3.fromRGB(115,190,255); panoramaStroke.Transparency=.35; panoramaStroke.Thickness=1.5

local shopToggle=Instance.new("TextButton",gui)
shopToggle.Size=UDim2.fromOffset(112,42); shopToggle.Position=UDim2.new(.5,115,0,20)
shopToggle.BackgroundColor3=Color3.fromRGB(178,112,26); shopToggle.TextColor3=Color3.new(1,1,1)
shopToggle.Text="LOJA"; shopToggle.Font=Enum.Font.GothamBold; shopToggle.TextSize=14; shopToggle.AutoButtonColor=false
Instance.new("UICorner",shopToggle).CornerRadius=UDim.new(0,12)
local shopToggleStroke=Instance.new("UIStroke",shopToggle); shopToggleStroke.Color=Color3.fromRGB(255,215,95); shopToggleStroke.Transparency=.3; shopToggleStroke.Thickness=1.5

local panel=Instance.new("Frame",gui)
panel.Size=UDim2.fromOffset(320,370); panel.Position=UDim2.new(0,-350,1,-382)
panel.BackgroundColor3=Color3.fromRGB(13,31,27); panel.BackgroundTransparency=.04
Instance.new("UICorner",panel).CornerRadius=UDim.new(0,14)
local panelStroke=Instance.new("UIStroke",panel); panelStroke.Color=Color3.fromRGB(66,115,98); panelStroke.Transparency=.45; panelStroke.Thickness=1.5
local panelGradient=Instance.new("UIGradient",panel); panelGradient.Color=ColorSequence.new(Color3.fromRGB(18,43,36),Color3.fromRGB(8,20,18)); panelGradient.Rotation=90
local accent=Instance.new("Frame",panel); accent.Size=UDim2.fromOffset(5,54); accent.Position=UDim2.fromOffset(0,14); accent.BackgroundColor3=Color3.fromRGB(35,220,145); accent.BorderSizePixel=0
Instance.new("UICorner",accent).CornerRadius=UDim.new(1,0)
local close=Instance.new("TextButton",panel); close.Size=UDim2.fromOffset(30,30); close.Position=UDim2.fromOffset(278,8); close.BackgroundColor3=Color3.fromRGB(45,65,59); close.Text="×"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBold; close.TextSize=20; close.AutoButtonColor=false
Instance.new("UICorner",close).CornerRadius=UDim.new(1,0)
local scale=Instance.new("UIScale",panel)
local function fitMobile()
    local v=workspace.CurrentCamera.ViewportSize
    scale.Scale=v.X<700 and .76 or v.X<1000 and .88 or 1
end
workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(fitMobile); fitMobile()
local panelOpen=false
local openPosition=UDim2.new(0,12,1,-382)
local closedPosition=UDim2.new(0,-350,1,-382)
local function setPanel(open)
    panelOpen=open
    toggle.Text=open and "×  FECHAR" or "☰  GESTAO"
    TweenService:Create(panel,TweenInfo.new(.28,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=open and openPosition or closedPosition}):Play()
end
toggle.Activated:Connect(function() setPanel(not panelOpen) end)
close.Activated:Connect(function() setPanel(false) end)

local function label(y,h,text,size,color)
    local l=Instance.new("TextLabel",panel); l.Position=UDim2.fromOffset(14,y); l.Size=UDim2.fromOffset(292,h)
    l.BackgroundTransparency=1; l.TextColor3=color or Color3.new(1,1,1); l.TextXAlignment=Enum.TextXAlignment.Left
    l.TextYAlignment=Enum.TextYAlignment.Top; l.Font=Enum.Font.GothamBold; l.TextSize=size; l.Text=text; return l
end
local title=label(10,26,"MEU IMPERIO RODOVIARIO",18)
local info=label(40,82,"Carregando...",14,Color3.fromRGB(210,230,220))
local status=label(342,20,"Cada rodovia gera renda separadamente",11,Color3.fromRGB(255,215,80))
local function button(y,color)
    local b=Instance.new("TextButton",panel); b.Position=UDim2.fromOffset(14,y); b.Size=UDim2.fromOffset(292,38)
    b.BackgroundColor3=color; b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=12
    b.AutoButtonColor=false; b.TextStrokeColor3=Color3.fromRGB(0,0,0); b.TextStrokeTransparency=.82
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,11)
    local stroke=Instance.new("UIStroke",b); stroke.Color=color:Lerp(Color3.new(1,1,1),.45); stroke.Transparency=.55; stroke.Thickness=1
    local gradient=Instance.new("UIGradient",b); gradient.Color=ColorSequence.new(color:Lerp(Color3.new(1,1,1),.12),color:Lerp(Color3.new(0,0,0),.12)); gradient.Rotation=90
    b.MouseEnter:Connect(function() TweenService:Create(b,TweenInfo.new(.12),{Position=UDim2.fromOffset(11,y),Size=UDim2.fromOffset(298,38)}):Play(); stroke.Transparency=.15 end)
    b.MouseLeave:Connect(function() TweenService:Create(b,TweenInfo.new(.12),{Position=UDim2.fromOffset(14,y),Size=UDim2.fromOffset(292,38)}):Play(); stroke.Transparency=.55 end)
    return b
end
local expand=button(128,Color3.fromRGB(0,145,95))
local tariff=button(170,Color3.fromRGB(30,105,170))
local traffic=button(212,Color3.fromRGB(205,135,30))
local quality=button(254,Color3.fromRGB(115,75,170))
local automation=button(296,Color3.fromRGB(175,65,95))

local function prepareConsoleButton(b)
    b.Selectable=true
    b.SelectionGained:Connect(function()
        local stroke=b:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Color=Color3.fromRGB(255,225,80); stroke.Transparency=0; stroke.Thickness=3 end
    end)
    b.SelectionLost:Connect(function()
        local stroke=b:FindFirstChildOfClass("UIStroke")
        if stroke then stroke.Thickness=1.5; stroke.Transparency=.35 end
    end)
end
for _,b in ipairs({toggle,panorama,shopToggle,close,expand,tariff,traffic,quality,automation}) do prepareConsoleButton(b) end
expand.NextSelectionUp=automation; expand.NextSelectionDown=tariff
tariff.NextSelectionUp=expand; tariff.NextSelectionDown=traffic
traffic.NextSelectionUp=tariff; traffic.NextSelectionDown=quality
quality.NextSelectionUp=traffic; quality.NextSelectionDown=automation
automation.NextSelectionUp=quality; automation.NextSelectionDown=expand

local shopFrame=Instance.new("Frame",gui)
shopFrame.Size=UDim2.fromOffset(430,510); shopFrame.Position=UDim2.new(.5,-215,.5,-255)
shopFrame.BackgroundColor3=Color3.fromRGB(18,26,34); shopFrame.Visible=false
Instance.new("UICorner",shopFrame).CornerRadius=UDim.new(0,16)
local shopStroke=Instance.new("UIStroke",shopFrame); shopStroke.Color=Color3.fromRGB(225,155,45); shopStroke.Thickness=2; shopStroke.Transparency=.25
local shopScale=Instance.new("UIScale",shopFrame); shopScale.Scale=workspace.CurrentCamera.ViewportSize.X<700 and .72 or .9
local shopTitle=Instance.new("TextLabel",shopFrame); shopTitle.Position=UDim2.fromOffset(18,12); shopTitle.Size=UDim2.fromOffset(350,30); shopTitle.BackgroundTransparency=1; shopTitle.Text="CENTRAL ADMINISTRATIVA"; shopTitle.TextColor3=Color3.fromRGB(255,205,90); shopTitle.TextXAlignment=Enum.TextXAlignment.Left; shopTitle.Font=Enum.Font.GothamBold; shopTitle.TextSize=18
local shopClose=Instance.new("TextButton",shopFrame); shopClose.Position=UDim2.fromOffset(382,10); shopClose.Size=UDim2.fromOffset(32,32); shopClose.BackgroundColor3=Color3.fromRGB(60,65,72); shopClose.Text="×"; shopClose.TextColor3=Color3.new(1,1,1); shopClose.Font=Enum.Font.GothamBold; shopClose.TextSize=20
Instance.new("UICorner",shopClose).CornerRadius=UDim.new(1,0)
local shopMessage=Instance.new("TextLabel",shopFrame); shopMessage.Position=UDim2.fromOffset(18,470); shopMessage.Size=UDim2.fromOffset(394,28); shopMessage.BackgroundTransparency=1; shopMessage.Text="Compras sao opcionais"; shopMessage.TextColor3=Color3.fromRGB(190,205,215); shopMessage.Font=Enum.Font.Gotham; shopMessage.TextSize=12
local shopButtons={}
local offers={
    {"VIP • IDENTIDADE EXCLUSIVA  •  PASS",Config.PASSES.VIP,"pass"},
    {"GERENTE • REPARO MAIS RAPIDO  •  PASS",Config.PASSES.GERENTE_AUTOMATICO,"pass"},
    {"RECEITA +25% PERMANENTE  •  PASS",Config.PASSES.RECEITA_EXTRA,"pass"},
    {"CABINES ESCURAS E DOURADAS  •  PASS",Config.PASSES.PERSONALIZACAO_PREMIUM,"pass"},
    {"CAIXA PEQUENA  •  2.500 MOEDAS",Config.PRODUCTS.CAIXA_PEQUENA.id,"product"},
    {"CAIXA MEDIA  •  9.000 MOEDAS",Config.PRODUCTS.CAIXA_MEDIA.id,"product"},
    {"CAIXA GRANDE  •  25.000 MOEDAS",Config.PRODUCTS.CAIXA_GRANDE.id,"product"},
    {"OPERACAO 2X  •  15 MINUTOS",Config.PRODUCTS.OPERACAO_ACELERADA.id,"product"},
    {"REPARO EMERGENCIAL",Config.PRODUCTS.REPARO_EMERGENCIAL.id,"product"},
}
for i,offer in ipairs(offers) do
    local b=Instance.new("TextButton",shopFrame); b.Position=UDim2.fromOffset(18,50+(i-1)*45); b.Size=UDim2.fromOffset(394,39)
    b.BackgroundColor3=i<=4 and Color3.fromRGB(95,66,135) or Color3.fromRGB(25,105,92); b.TextColor3=Color3.new(1,1,1); b.Text=offer[1]; b.Font=Enum.Font.GothamBold; b.TextSize=12; b.AutoButtonColor=false
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9); local stroke=Instance.new("UIStroke",b); stroke.Color=Color3.fromRGB(255,210,100); stroke.Transparency=.65
    prepareConsoleButton(b); table.insert(shopButtons,b)
    b.Activated:Connect(function()
        if offer[2]<=0 then shopMessage.Text="Configure o ID desta oferta no Config.lua"; shopMessage.TextColor3=Color3.fromRGB(255,120,90); return end
        shopMessage.Text="Abrindo compra segura do Roblox..."; shopMessage.TextColor3=Color3.fromRGB(120,235,175)
        if offer[3]=="pass" then MarketplaceService:PromptGamePassPurchase(player,offer[2]) else MarketplaceService:PromptProductPurchase(player,offer[2]) end
    end)
end
for i,b in ipairs(shopButtons) do b.NextSelectionUp=shopButtons[i==1 and #shopButtons or i-1]; b.NextSelectionDown=shopButtons[i==#shopButtons and 1 or i+1] end
prepareConsoleButton(shopClose)
local shopOpen=false
local function setShop(open)
    shopOpen=open; shopFrame.Visible=open
    if open then setPanel(false); GuiService.SelectedObject=shopButtons[1] elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(shopFrame) then GuiService.SelectedObject=nil end
end
shopToggle.Activated:Connect(function() setShop(not shopOpen) end)
shopClose.Activated:Connect(function() setShop(false) end)
local data
local function money(value)
    if value>=1000000000 then return string.format("%.1fB",value/1000000000) end
    if value>=1000000 then return string.format("%.1fM",value/1000000) end
    if value>=1000 then return string.format("%.1fK",value/1000) end
    return tostring(value)
end
local function refresh()
    if not data then return end
    title.Text=data.vip and "★ IMPERIO RODOVIARIO VIP" or "MEU IMPERIO RODOVIARIO"
    info.Text=string.format("Moedas: %d\nRegiao: %s • Prestigio %d\nRodovias: %d/%d  |  Receita: %.2fx\nTarifa %d • Trafego %d • Qualidade %d • Automacao %d\nRisco de falha: %.1f%%",data.coins,data.regionName,data.prestige,data.plazas,data.maxPlazas,data.incomeMultiplier,data.tariff,data.traffic,data.quality,data.automation,data.incidentChance)
    expand.Text=data.plazas>=data.maxPlazas and "✓  IMPERIO RODOVIARIO COMPLETO" or "+  NOVA RODOVIA     "..money(data.expansionCost)
    expand.BackgroundTransparency=data.plazas>=data.maxPlazas and .45 or 0
    tariff.Text="↑  MELHORAR TARIFA     "..money(data.tariffCost)
    traffic.Text="»  ATRAIR MAIS VEICULOS     "..money(data.trafficCost)
    quality.Text="◆  QUALIDADE: MENOS FALHAS     "..money(data.qualityCost)
    automation.Text="⚙  AGILIZAR COBRANCA     "..money(data.automationCost)
end
remotes.TycoonUpdate.OnClientEvent:Connect(function(d) data=d; refresh() end)
remotes.Income.OnClientEvent:Connect(function(vehicle,gain) status.Text=vehicle.." pagou +"..gain.." moedas" end)
task.spawn(function() local ok,success,d=pcall(function() return action:InvokeServer("get") end); if ok and success then data=d; refresh() end end)
local function buy(kind,b)
    b.Active=false; local ok,success,msg=pcall(function() return action:InvokeServer(kind) end)
    status.Text=ok and msg or "Erro ao conectar"; status.TextColor3=ok and success and Color3.fromRGB(90,255,150) or Color3.fromRGB(255,110,100)
    task.wait(.4); b.Active=true
end
expand.Activated:Connect(function() buy("expansion",expand) end)
tariff.Activated:Connect(function() buy("tariff",tariff) end)
traffic.Activated:Connect(function() buy("traffic",traffic) end)
quality.Activated:Connect(function() buy("quality",quality) end)
automation.Activated:Connect(function() buy("automation",automation) end)

local panoramic=false
local function togglePanoramic()
    local camera=workspace.CurrentCamera
    panoramic=not panoramic
    if panoramic then
        local z=player:GetAttribute("PlotCenterZ")
        if not z then panoramic=false; return end
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=CFrame.lookAt(Vector3.new(-178,82,z),Vector3.new(5,3,z))
        camera.FieldOfView=90; panorama.Text="×  SAIR DA VISAO PANORAMICA"
    else
        camera.CameraType=Enum.CameraType.Custom; camera.FieldOfView=70
        local character=player.Character; if character then camera.CameraSubject=character:FindFirstChildOfClass("Humanoid") end
        panorama.Text="◉  VISAO PANORAMICA"
    end
end
panorama.Activated:Connect(togglePanoramic)

local incidentFrame=Instance.new("Frame",gui)
incidentFrame.Size=UDim2.fromOffset(380,245); incidentFrame.Position=UDim2.new(.5,-190,.5,-122)
incidentFrame.BackgroundColor3=Color3.fromRGB(28,31,35); incidentFrame.Visible=false
Instance.new("UICorner",incidentFrame).CornerRadius=UDim.new(0,14)
local incidentScale=Instance.new("UIScale",incidentFrame); incidentScale.Scale=workspace.CurrentCamera.ViewportSize.X<700 and .78 or 1
local incidentTitle=Instance.new("TextLabel",incidentFrame); incidentTitle.Position=UDim2.fromOffset(16,14); incidentTitle.Size=UDim2.fromOffset(348,32); incidentTitle.BackgroundTransparency=1; incidentTitle.TextColor3=Color3.fromRGB(255,90,75); incidentTitle.Font=Enum.Font.GothamBold; incidentTitle.TextSize=19
local incidentHelp=Instance.new("TextLabel",incidentFrame); incidentHelp.Position=UDim2.fromOffset(16,50); incidentHelp.Size=UDim2.fromOffset(348,70); incidentHelp.BackgroundTransparency=1; incidentHelp.TextColor3=Color3.new(1,1,1); incidentHelp.TextWrapped=true; incidentHelp.Font=Enum.Font.Gotham; incidentHelp.TextSize=15
local puzzleStatus=Instance.new("TextLabel",incidentFrame); puzzleStatus.Position=UDim2.fromOffset(16,198); puzzleStatus.Size=UDim2.fromOffset(348,30); puzzleStatus.BackgroundTransparency=1; puzzleStatus.TextColor3=Color3.fromRGB(255,215,80); puzzleStatus.Font=Enum.Font.GothamBold; puzzleStatus.TextSize=13
local puzzleButtons={}
for i=1,3 do
    local b=Instance.new("TextButton",incidentFrame); b.Position=UDim2.fromOffset(16+(i-1)*118,132); b.Size=UDim2.fromOffset(110,52); b.BackgroundColor3=Color3.fromRGB(0,115,85); b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=12; Instance.new("UICorner",b).CornerRadius=UDim.new(0,8); puzzleButtons[i]=b
end
for i,b in ipairs(puzzleButtons) do
    prepareConsoleButton(b)
    b.NextSelectionLeft=puzzleButtons[i==1 and 3 or i-1]
    b.NextSelectionRight=puzzleButtons[i==3 and 1 or i+1]
end
local activeIncident
local function choose(choice)
    if not activeIncident then return end
    local ok,correct,message,finished=pcall(function() return remotes.ResolveIncident:InvokeServer(activeIncident.token,choice) end)
    puzzleStatus.Text=ok and message or "Erro de comunicacao"
    puzzleStatus.TextColor3=ok and correct and Color3.fromRGB(90,255,150) or Color3.fromRGB(255,100,90)
    if ok and finished then task.wait(.7); incidentFrame.Visible=false; activeIncident=nil; GuiService.SelectedObject=panelOpen and expand or nil end
end
for _,b in ipairs(puzzleButtons) do
    local button=b
    button.Activated:Connect(function() if activeIncident then choose(button.Text) end end)
end
remotes.Incident.OnClientEvent:Connect(function(event)
    if event.resolved then
        if activeIncident and activeIncident.road==event.road then
            incidentFrame.Visible=false; activeIncident=nil
            status.Text=event.automatic and "Automacao reparou a rodovia "..event.road or "Incidente resolvido"
            GuiService.SelectedObject=panelOpen and expand or nil
        end
        return
    end
    activeIncident=event; incidentFrame.Visible=true
    incidentTitle.Text="FALHA NA RODOVIA "..event.road
    incidentHelp.Text=event.fault.."\nExecute na ordem: "..table.concat(event.protocol,"  >  ")
    puzzleStatus.Text="Selecione a primeira etapa"
    local shuffled={event.protocol[1],event.protocol[2],event.protocol[3]}
    for i=3,2,-1 do local j=math.random(i); shuffled[i],shuffled[j]=shuffled[j],shuffled[i] end
    for i,b in ipairs(puzzleButtons) do b.Text=shuffled[i] end
    if UserInputService.GamepadEnabled then GuiService.SelectedObject=puzzleButtons[1] end
end)

local function consoleAction(_,inputState,inputObject)
    if inputState~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    if inputObject.KeyCode==Enum.KeyCode.ButtonY then
        if shopOpen then setShop(false) end
        setPanel(not panelOpen)
        GuiService.SelectedObject=panelOpen and expand or nil
    elseif inputObject.KeyCode==Enum.KeyCode.ButtonR1 then
        setShop(not shopOpen)
    elseif inputObject.KeyCode==Enum.KeyCode.ButtonX then
        togglePanoramic()
    elseif inputObject.KeyCode==Enum.KeyCode.ButtonB then
        if shopOpen then setShop(false)
        elseif panoramic then togglePanoramic()
        elseif panelOpen then setPanel(false); GuiService.SelectedObject=nil end
    end
    return Enum.ContextActionResult.Sink
end
ContextActionService:BindAction("RodoviaConsoleUI",consoleAction,false,Enum.KeyCode.ButtonY,Enum.KeyCode.ButtonR1,Enum.KeyCode.ButtonX,Enum.KeyCode.ButtonB)
UserInputService.GamepadConnected:Connect(function() consoleHint.Visible=true end)
UserInputService.GamepadDisconnected:Connect(function() consoleHint.Visible=UserInputService.GamepadEnabled end)
