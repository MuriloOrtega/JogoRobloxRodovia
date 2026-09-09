local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local DSS=game:GetService("DataStoreService")
local MarketplaceService=game:GetService("MarketplaceService")
local Config=require(RS.Shared.Config)
local Tycoon=require(script.Parent.TycoonService)
local Vehicles=require(script.Parent.VehicleFactory)
local store=DSS:GetDataStore("ImperioDaRodovia_Tycoon_v1")
local states={}

local remotes=Instance.new("Folder",RS); remotes.Name="RodoviaRemotes"
local action=Instance.new("RemoteFunction",remotes); action.Name="TycoonAction"
local update=Instance.new("RemoteEvent",remotes); update.Name="TycoonUpdate"
local income=Instance.new("RemoteEvent",remotes); income.Name="Income"
local incidentEvent=Instance.new("RemoteEvent",remotes); incidentEvent.Name="Incident"
local resolveIncident=Instance.new("RemoteFunction",remotes); resolveIncident.Name="ResolveIncident"
local operationEvent=Instance.new("RemoteEvent",remotes); operationEvent.Name="OperationEvent"
local resolveOperation=Instance.new("RemoteFunction",remotes); resolveOperation.Name="ResolveOperation"
Tycoon.BuildWorld()

local regions={"Interior","Serra","Litoral","Metropole"}
local missionDefs={
    vehicles={title="Atenda 25 veiculos",goal=25,reward=500},
    revenue={title="Arrecade 2.500 moedas",goal=2500,reward=750},
    repairs={title="Resolva 2 falhas",goal=2,reward=1000},
}
local missionOrder={"vehicles","revenue","repairs"}
local function today() return math.floor(os.time()/86400) end
local function resetMissions(s)
    if s.missionDay~=today() then s.missionDay=today(); s.missions={vehicles=0,revenue=0,repairs=0}; s.claimed={} end
end

local function expansionCost(s) return math.floor(1500*2.35^(s.plazas-1)) end
local function tariffCost(s) return math.floor(250*1.32^(s.tariff-1)) end
local function trafficCost(s) return math.floor(450*1.38^(s.traffic-1)) end
local function qualityCost(s) return math.floor(600*1.42^(s.quality-1)) end
local function automationCost(s) return math.floor(900*1.48^(s.automation-1)) end
local function revenueMultiplier(s)
    return (1+(s.tariff-1)*.12)*(s.revenuePass and 1.25 or 1)*(1+((s.region or 1)-1)*.3)*(1+(s.prestige or 0)*.25)
end
local function incidentChance(s) return math.max(.02,.18-(s.quality-1)*.015) end
-- Trafego controla quantos veiculos chegam; automacao controla a velocidade da cobranca.
local function boostMultiplier(s) return (s.boostUntil or 0)>os.time() and 2 or 1 end
local function trafficInterval(s) return math.max(1.2,8/(1+(s.traffic-1)*.08)/boostMultiplier(s)) end
local function serviceSpeed(s) return math.min(5,(1+(s.automation-1)*.12)*boostMultiplier(s)) end
local function regionRequirement(s) return 8+((s.region or 1)-1)*2+(s.prestige or 0)*2 end
local function canAdvance(s)
    local req=regionRequirement(s)
    return s.plazas>=5 and s.tariff>=req and s.traffic>=req and s.quality>=req and s.automation>=req
end
local function payload(s)
    resetMissions(s)
    local missions={}
    for _,key in ipairs(missionOrder) do local def=missionDefs[key]; table.insert(missions,{key=key,title=def.title,progress=math.min(def.goal,s.missions[key] or 0),goal=def.goal,reward=def.reward,claimed=s.claimed[key] or false}) end
    return {coins=s.coins,plazas=s.plazas,tariff=s.tariff,traffic=s.traffic,
        quality=s.quality,automation=s.automation,expansionCost=expansionCost(s),tariffCost=tariffCost(s),trafficCost=trafficCost(s),
        qualityCost=qualityCost(s),automationCost=automationCost(s),maxPlazas=5,incomeMultiplier=revenueMultiplier(s),
        incidentChance=math.floor(incidentChance(s)*1000)/10,vip=s.vip or false,
        boostRemaining=math.max(0,(s.boostUntil or 0)-os.time()),missions=missions,region=s.region,regionName=regions[s.region],prestige=s.prestige,
        regionRequirement=regionRequirement(s),canAdvance=canAdvance(s)}
end
local function sync(p) local s=states[p]; if s then update:FireClient(p,payload(s)); local ls=p:FindFirstChild("leaderstats"); if ls then ls.Moedas.Value=s.coins end end end
local function save(p)
    local s=states[p]; if not s then return end
    local data={coins=s.coins,plazas=s.plazas,tariff=s.tariff,traffic=s.traffic,quality=s.quality,automation=s.automation,boostUntil=s.boostUntil or 0,repairCredits=s.repairCredits or 0,
        region=s.region,prestige=s.prestige,missionDay=s.missionDay,missions=s.missions,claimed=s.claimed}
    local ok,err=pcall(function() store:UpdateAsync("player_"..p.UserId,function() return data end) end)
    if not ok then warn("Falha ao salvar: "..tostring(err)) end
end
local function load(p)
    local s={coins=0,plazas=1,tariff=1,traffic=1,quality=1,automation=1,boostUntil=0,repairCredits=0,region=1,prestige=0,missionDay=today(),missions={vehicles=0,revenue=0,repairs=0},claimed={}}
    local ok,data=pcall(function() return store:GetAsync("player_"..p.UserId) end)
    if ok and type(data)=="table" then
        s.coins=tonumber(data.coins) or 0; s.plazas=math.clamp(tonumber(data.plazas) or 1,1,5)
        s.tariff=math.max(1,tonumber(data.tariff) or tonumber(data.level) or 1); s.traffic=math.max(1,tonumber(data.traffic) or 1)
        s.quality=math.max(1,tonumber(data.quality) or 1); s.automation=math.max(1,tonumber(data.automation) or 1); s.boostUntil=tonumber(data.boostUntil) or 0; s.repairCredits=tonumber(data.repairCredits) or 0
        s.region=math.clamp(tonumber(data.region) or 1,1,#regions); s.prestige=math.max(0,tonumber(data.prestige) or 0); s.missionDay=tonumber(data.missionDay) or today(); s.missions=type(data.missions)=="table" and data.missions or s.missions; s.claimed=type(data.claimed)=="table" and data.claimed or {}
    else
        local oldOk,old=pcall(function() return DSS:GetDataStore(Config.DATASTORE_NAME):GetAsync("player_"..p.UserId) end)
        if oldOk and type(old)=="table" then s.coins=tonumber(old.coins) or 0; s.tariff=tonumber(old.level) or 1 end
    end
    resetMissions(s); s.broken={}; s.nextSpawn=0; s.nextOperation=os.clock()+math.random(35,60); states[p]=s
    local ls=Instance.new("Folder",p); ls.Name="leaderstats"
    local coins=Instance.new("IntValue",ls); coins.Name,coins.Value="Moedas",s.coins
    for key,id in pairs(Config.PASSES) do
        if id>0 then
            local passOk,owns=pcall(MarketplaceService.UserOwnsGamePassAsync,MarketplaceService,p.UserId,id)
            if passOk and owns then
                if key=="VIP" then s.vip=true elseif key=="GERENTE_AUTOMATICO" then s.managerPass=true elseif key=="RECEITA_EXTRA" then s.revenuePass=true elseif key=="PERSONALIZACAO_PREMIUM" then s.premiumTheme=true end
            end
        end
    end
    Tycoon.Assign(p,s); Tycoon.UpdateVisuals(p,s); p:SetAttribute("RodoviaVIP",s.vip or false); sync(p)
end


local protocols={{"SENSOR","MOTOR","RESET"},{"ENERGIA","REDE","RESET"},{"CABINE","SISTEMA","LIBERAR"}}
local faults={"Cancela travada","Cabine sem comunicacao","Sensor de veiculo com falha"}
local function createIncident(p,s,roadIndex)
    for _ in pairs(s.broken) do return false end
    local protocol=protocols[math.random(#protocols)]
    local token=tostring(p.UserId)..":"..roadIndex..":"..tostring(math.random(100000,999999))
    -- Reserva a primeira posicao para qualquer veiculo que ja esteja se aproximando.
    s.broken[roadIndex]={token=token,protocol=protocol,step=1,queued=1}
    Tycoon.SetBarrierBroken(p,roadIndex,true)
    incidentEvent:FireClient(p,{road=roadIndex,fault=faults[math.random(#faults)],protocol=protocol,token=token})
    if (s.repairCredits or 0)>0 then
        s.repairCredits-=1
        task.delay(.6,function()
            if states[p] and s.broken[roadIndex] and s.broken[roadIndex].token==token then
                s.broken[roadIndex]=nil; Tycoon.SetBarrierBroken(p,roadIndex,false)
                incidentEvent:FireClient(p,{resolved=true,road=roadIndex,automatic=true})
            end
        end)
    end
    local delaySeconds=s.managerPass and math.max(5,14-(s.quality-1)) or math.max(10,45-(s.quality-1)*2)
    task.delay(delaySeconds,function()
        if states[p] and s.broken[roadIndex] and s.broken[roadIndex].token==token then
            s.broken[roadIndex]=nil
            Tycoon.SetBarrierBroken(p,roadIndex,false)
            incidentEvent:FireClient(p,{resolved=true,road=roadIndex,automatic=true})
        end
    end)
    return true
end

resolveIncident.OnServerInvoke=function(p,token,choice)
    local s=states[p]; if not s then return false,"Dados indisponiveis" end
    for road,incident in pairs(s.broken) do
        if incident.token==token then
            if incident.protocol[incident.step]~=choice then incident.step=1; return false,"Ordem incorreta. Reinicie o protocolo." end
            incident.step+=1
            if incident.step>#incident.protocol then
                s.broken[road]=nil; Tycoon.SetBarrierBroken(p,road,false); s.coins+=100*s.quality; s.missions.repairs=(s.missions.repairs or 0)+1; sync(p)
                return true,"Manutencao concluida! Bonus recebido.",true
            end
            return true,"Etapa correta.",false
        end
    end
    return false,"Incidente ja resolvido",true
end

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(p,passId,purchased)
    if not purchased or not states[p] then return end
    local s=states[p]
    if passId==Config.PASSES.VIP then s.vip=true; p:SetAttribute("RodoviaVIP",true)
    elseif passId==Config.PASSES.GERENTE_AUTOMATICO then s.managerPass=true
    elseif passId==Config.PASSES.RECEITA_EXTRA then s.revenuePass=true
    elseif passId==Config.PASSES.PERSONALIZACAO_PREMIUM then s.premiumTheme=true; Tycoon.SetPremiumTheme(p,true) end
    sync(p)
end)

MarketplaceService.ProcessReceipt=function(receipt)
    local p=Players:GetPlayerByUserId(receipt.PlayerId)
    local s=p and states[p]
    if not p or not s then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local productId=receipt.ProductId
    if productId==Config.PRODUCTS.CAIXA_PEQUENA.id then s.coins+=Config.PRODUCTS.CAIXA_PEQUENA.coins
    elseif productId==Config.PRODUCTS.CAIXA_MEDIA.id then s.coins+=Config.PRODUCTS.CAIXA_MEDIA.coins
    elseif productId==Config.PRODUCTS.CAIXA_GRANDE.id then s.coins+=Config.PRODUCTS.CAIXA_GRANDE.coins
    elseif productId==Config.PRODUCTS.OPERACAO_ACELERADA.id then
        s.boostUntil=math.max(os.time(),s.boostUntil or 0)+Config.PRODUCTS.OPERACAO_ACELERADA.duration
    elseif productId==Config.PRODUCTS.REPARO_EMERGENCIAL.id then
        local repaired=false
        for road in pairs(s.broken) do
            s.broken[road]=nil; Tycoon.SetBarrierBroken(p,road,false)
            incidentEvent:FireClient(p,{resolved=true,road=road,automatic=false})
            repaired=true
        end
        if not repaired then s.repairCredits=(s.repairCredits or 0)+1 end
    else return Enum.ProductPurchaseDecision.NotProcessedYet end
    sync(p); save(p)
    return Enum.ProductPurchaseDecision.PurchaseGranted
end

local operationDefs={
    {title="AMBULANCIA EM EMERGENCIA",description="Um veiculo de resgate precisa passar sem cobranca.",answer="LIBERAR PASSAGEM",options={"LIBERAR PASSAGEM","COBRAR TARIFA","BLOQUEAR PISTA"}},
    {title="VEICULO TENTANDO EVADIR",description="O veiculo avancou sem realizar o pagamento.",answer="ACIONAR FISCALIZACAO",options={"IGNORAR","ACIONAR FISCALIZACAO","FECHAR TODAS AS PISTAS"}},
    {title="PLACA ILEGIVEL",description="O sistema nao conseguiu confirmar a placa do veiculo.",answer="REVISAO MANUAL",options={"REVISAO MANUAL","LIBERAR SEM REGISTRO","APAGAR EVENTO"}},
}

resolveOperation.OnServerInvoke=function(p,token,choice)
    local s=states[p]; local event=s and s.operation
    if not event or event.token~=token then return false,"Evento expirado" end
    s.operation=nil
    if choice==event.answer then
        local reward=300*(s.region or 1); s.coins+=reward; sync(p)
        return true,"Decisao correta! +"..reward.." moedas"
    end
    local penalty=math.min(s.coins,100*(s.region or 1)); s.coins-=penalty; sync(p)
    return false,"Decisao incorreta. -"..penalty.." moedas"
end

action.OnServerInvoke=function(p,kind,param)
    local s=states[p]; if not s then return false,"Dados indisponiveis" end
    if kind=="get" then return true,payload(s) end
    if kind=="claimMission" then
        resetMissions(s)
        local def=missionDefs[param]
        if not def then return false,"Missao invalida" end
        if s.claimed[param] then return false,"Recompensa ja coletada" end
        if (s.missions[param] or 0)<def.goal then return false,"Missao ainda nao concluida" end
        s.claimed[param]=true; s.coins+=def.reward; sync(p); task.spawn(function() save(p) end)
        return true,"Missao concluida! +"..def.reward.." moedas"
    elseif kind=="advanceRegion" then
        if not canAdvance(s) then return false,"Complete 5 rodovias e leve todas as melhorias ao nivel "..regionRequirement(s) end
        if s.region<#regions then s.region+=1 else s.region=1; s.prestige+=1 end
        s.coins=math.floor(s.coins*.1); s.plazas=1; s.tariff=1; s.traffic=1; s.quality=1; s.automation=1; s.broken={}
        Tycoon.Rebuild(p,s); Tycoon.SetPremiumTheme(p,s.premiumTheme); sync(p); task.spawn(function() save(p) end)
        return true,s.region==1 and "Novo prestigio! Bonus permanente aumentado." or "Nova regiao liberada: "..regions[s.region]
    end
    local cost
    if kind=="expansion" then
        if s.plazas>=5 then return false,"Todas as rodovias foram compradas" end
        cost=expansionCost(s); if s.coins<cost then return false,"Faltam "..(cost-s.coins).." moedas" end
        s.coins-=cost; s.plazas+=1; Tycoon.Expand(p,s); Tycoon.SetPremiumTheme(p,s.premiumTheme)
    elseif kind=="tariff" then
        cost=tariffCost(s); if s.coins<cost then return false,"Faltam "..(cost-s.coins).." moedas" end
        s.coins-=cost; s.tariff+=1
    elseif kind=="traffic" then
        cost=trafficCost(s); if s.coins<cost then return false,"Faltam "..(cost-s.coins).." moedas" end
        s.coins-=cost; s.traffic+=1
    elseif kind=="quality" then
        cost=qualityCost(s); if s.coins<cost then return false,"Faltam "..(cost-s.coins).." moedas" end
        s.coins-=cost; s.quality+=1
    elseif kind=="automation" then
        cost=automationCost(s); if s.coins<cost then return false,"Faltam "..(cost-s.coins).." moedas" end
        s.coins-=cost; s.automation+=1
    else return false,"Acao invalida" end
    Tycoon.UpdateVisuals(p,s); sync(p); task.spawn(function() save(p) end); return true,"Melhoria comprada! A praca evoluiu."
end

Players.PlayerAdded:Connect(load)
Players.PlayerRemoving:Connect(function(p) save(p); Tycoon.Release(p); states[p]=nil end)
game:BindToClose(function() for _,p in Players:GetPlayers() do save(p) end end)

task.spawn(function()
    while true do
        local now=os.clock()
        for p,s in pairs(states) do
            local plot=Tycoon.GetPlot(p)
            if plot and now>=s.nextSpawn then
                s.nextSpawn=now+trafficInterval(s)
                for i=1,s.plazas do
                    local lane=plot.lanes[i]
                    local roadIndex,owner,ownerState=i,p,s
                    if lane then
                        local incident=ownerState.broken[roadIndex]
                        local queueSlot=1
                        if incident then incident.queued=(incident.queued or 0)+1; queueSlot=incident.queued end
                        Vehicles.Spawn(plot.model,lane,function(kind,_,def)
                        if kind=="open" then Tycoon.MoveBarrier(owner,roadIndex,true)
                        elseif kind=="close" then Tycoon.MoveBarrier(owner,roadIndex,false)
                        elseif kind=="charge" and states[owner] and not ownerState.broken[roadIndex] then
                            if math.random()<incidentChance(ownerState) and createIncident(owner,ownerState,roadIndex) then return end
                            local gain=math.floor(def.fare*revenueMultiplier(ownerState))
                            resetMissions(ownerState)
                            ownerState.coins+=gain; ownerState.missions.vehicles=(ownerState.missions.vehicles or 0)+1; ownerState.missions.revenue=(ownerState.missions.revenue or 0)+gain
                            income:FireClient(owner,def.name,gain); sync(owner)
                        end
                    end,{queueSlot=queueSlot,serviceSpeed=serviceSpeed(ownerState),isBlocked=function()
                        return states[owner]~=nil and ownerState.broken[roadIndex]~=nil
                    end}) end
                end
            end
        end
        task.wait(.5)
    end
end)

task.spawn(function()
    while true do
        local now=os.clock()
        for p,s in pairs(states) do
            if now>=(s.nextOperation or math.huge) and not s.operation and next(s.broken)==nil then
                s.nextOperation=now+math.random(55,85)
                local def=operationDefs[math.random(#operationDefs)]
                local token=tostring(p.UserId)..":OP:"..tostring(math.random(100000,999999))
                s.operation={token=token,answer=def.answer}
                operationEvent:FireClient(p,{token=token,title=def.title,description=def.description,options=def.options,time=22})
                local owner,state,eventToken=p,s,token
                task.delay(22,function()
                    if states[owner]==state and state.operation and state.operation.token==eventToken then
                        state.operation=nil; state.coins=math.max(0,state.coins-100*(state.region or 1)); sync(owner)
                        operationEvent:FireClient(owner,{expired=true,message="Tempo esgotado: operacao recebeu penalidade"})
                    end
                end)
            end
        end
        task.wait(1)
    end
end)

task.spawn(function() while true do task.wait(60); for p in pairs(states) do save(p) end end end)
