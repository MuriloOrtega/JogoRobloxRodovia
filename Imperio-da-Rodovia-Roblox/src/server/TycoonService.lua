local TycoonService={}
local TweenService=game:GetService("TweenService")
local plots={}
local playerPlots={}
local plotCenters={-525,-315,-105,105,315,525}
local regionNames={"INTERIOR","SERRA","LITORAL","METROPOLE"}
local regionColors={Color3.fromRGB(72,126,64),Color3.fromRGB(78,102,76),Color3.fromRGB(62,125,132),Color3.fromRGB(82,88,102)}

local function part(parent,name,size,pos,color,material)
    local p=Instance.new("Part",parent)
    p.Name,p.Size,p.Position,p.Color=name,size,pos,color
    p.Anchored,p.Material=true,material or Enum.Material.SmoothPlastic
    p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
    return p
end

local function surfaceText(parent,text)
    -- As placas sao finas no eixo X; Right/Left sao as faces largas (Y x Z).
    for _,face in ipairs({Enum.NormalId.Right,Enum.NormalId.Left}) do
        local gui=Instance.new("SurfaceGui",parent); gui.Name="TextoPlaca"..face.Name; gui.Face=face
        gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud; gui.PixelsPerStud=38; gui.LightInfluence=0; gui.AlwaysOnTop=false
        local label=Instance.new("TextLabel",gui); label.Name="TextLabel"; label.Position=UDim2.fromScale(.05,.08); label.Size=UDim2.fromScale(.9,.84)
        label.BackgroundColor3=Color3.fromRGB(12,30,27); label.BackgroundTransparency=.18
        label.TextColor3=Color3.new(1,1,1); label.TextStrokeColor3=Color3.fromRGB(0,0,0); label.TextStrokeTransparency=.55
        label.TextScaled=true; label.TextWrapped=true; label.Font=Enum.Font.GothamBold; label.Text=text
        Instance.new("UICorner",label).CornerRadius=UDim.new(0,10)
        local constraint=Instance.new("UITextSizeConstraint",label); constraint.MinTextSize=12; constraint.MaxTextSize=58
    end
end

local function changeSurfaceText(parent,text)
    for _,gui in ipairs(parent:GetChildren()) do
        if gui:IsA("SurfaceGui") then
            local label=gui:FindFirstChild("TextLabel")
            if label then label.Text=text end
        end
    end
end

local function roadLine(parent,name,a,b,color)
    local delta=b-a
    local line=part(parent,name,Vector3.new(delta.Magnitude,.13,.28),(a+b)/2,color,Enum.Material.Neon)
    line.CFrame=CFrame.new((a+b)/2)*CFrame.Angles(0,-math.atan2(delta.Z,delta.X),0)
    return line
end

local function tree(parent,pos,scale)
    part(parent,"Tronco",Vector3.new(1.8,7,1.8),pos+Vector3.new(0,3.5,0),Color3.fromRGB(100,65,38),Enum.Material.Wood)
    local crown=part(parent,"Copa",Vector3.new(7,7,7)*scale,pos+Vector3.new(0,8,0),Color3.fromRGB(38,112,55),Enum.Material.Grass); crown.Shape=Enum.PartType.Ball
end

local function buildPlaza(plot,index)
    local laneZ=plot.centerZ+(index-3)*34
    local folder=Instance.new("Folder",plot.model); folder.Name="Rodovia"..index
    part(folder,"Asfalto",Vector3.new(300,1,30),Vector3.new(0,0,laneZ),Color3.fromRGB(42,44,48),Enum.Material.Asphalt)
    part(folder,"Faixa1",Vector3.new(300,.12,.35),Vector3.new(0,.57,laneZ-14),Color3.fromRGB(240,240,230),Enum.Material.Neon)
    part(folder,"Faixa2",Vector3.new(300,.12,.35),Vector3.new(0,.57,laneZ+14),Color3.fromRGB(240,240,230),Enum.Material.Neon)
    -- Duas faixas de aproximacao convergem para uma unica cabine e se abrem novamente na saida.
    for x=-140,-62,18 do part(folder,"DivisoriaEntrada",Vector3.new(9,.12,.35),Vector3.new(x,.58,laneZ),Color3.fromRGB(245,205,50),Enum.Material.Neon) end
    roadLine(folder,"AfunilEsquerdo",Vector3.new(-58,.59,laneZ-14),Vector3.new(-15,.59,laneZ-7),Color3.fromRGB(245,205,50))
    roadLine(folder,"AfunilDireito",Vector3.new(-58,.59,laneZ+14),Vector3.new(-15,.59,laneZ+7),Color3.fromRGB(245,205,50))
    roadLine(folder,"AberturaEsquerda",Vector3.new(15,.59,laneZ-7),Vector3.new(58,.59,laneZ-14),Color3.fromRGB(245,205,50))
    roadLine(folder,"AberturaDireita",Vector3.new(15,.59,laneZ+7),Vector3.new(58,.59,laneZ+14),Color3.fromRGB(245,205,50))
    for x=65,140,18 do part(folder,"DivisoriaSaida",Vector3.new(9,.12,.35),Vector3.new(x,.58,laneZ),Color3.fromRGB(245,205,50),Enum.Material.Neon) end
    local booth=part(folder,"Cabine",Vector3.new(8,8,6),Vector3.new(0,4.5,laneZ+6),Color3.fromRGB(0,110,78),Enum.Material.Metal)
    local window=part(folder,"Janela",Vector3.new(.2,2.5,3.8),Vector3.new(-4.1,5.3,laneZ+6),Color3.fromRGB(70,180,220),Enum.Material.Glass); window.Transparency=.2
    local roof=part(folder,"Cobertura",Vector3.new(28,1,24),Vector3.new(0,10,laneZ),Color3.fromRGB(225,230,235),Enum.Material.Metal)
    local sign=part(folder,"Letreiro",Vector3.new(.6,3,14),Vector3.new(-1,12,laneZ),Color3.fromRGB(0,90,65),Enum.Material.Metal)
    surfaceText(sign,"RODOVIA "..index)
    -- A cancela fica imediatamente antes da cabine, no sentido de chegada dos veiculos.
    local barrierX=-6.5
    part(folder,"PosteCancela",Vector3.new(1.3,4,1.3),Vector3.new(barrierX,2.5,laneZ-5),Color3.fromRGB(40,45,50),Enum.Material.Metal)
    local arm=part(folder,"Cancela",Vector3.new(.55,.55,10),Vector3.new(barrierX,4.2,laneZ),Color3.fromRGB(245,245,240),Enum.Material.Metal); arm.CanCollide=false
    local stripes={}
    for offset=-3,3,2 do
        local stripe=part(folder,"FaixaVermelha",Vector3.new(.58,.58,1),Vector3.new(barrierX,4.2,laneZ+offset),Color3.fromRGB(220,45,45),Enum.Material.Neon); stripe.CanCollide=false
        table.insert(stripes,{part=stripe,relative=arm.CFrame:ToObjectSpace(stripe.CFrame)})
    end
    local signal=part(folder,"Sinal",Vector3.new(.5,.8,.8),Vector3.new(barrierX-.7,3,laneZ-5),Color3.fromRGB(255,45,45),Enum.Material.Neon); signal.CanCollide=false
    plot.lanes[index]=laneZ
    plot.barriers[index]={arm=arm,closed=arm.CFrame,signal=signal,stripes=stripes,broken=false}
end

function TycoonService.BuildWorld()
    local Lighting=game:GetService("Lighting")
    Lighting.ClockTime=14; Lighting.Brightness=2.2; Lighting.EnvironmentDiffuseScale=.45; Lighting.EnvironmentSpecularScale=.65
    local atmosphere=Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere",Lighting)
    atmosphere.Density=.28; atmosphere.Haze=1.1; atmosphere.Color=Color3.fromRGB(210,230,245); atmosphere.Decay=Color3.fromRGB(100,120,145)
    local world=Instance.new("Folder",workspace); world.Name="ImperiosIndividuais"
    part(world,"Mundo",Vector3.new(410,1,1260),Vector3.new(0,-1,0),Color3.fromRGB(65,120,60),Enum.Material.Grass)
    for i,z in ipairs(plotCenters) do
        local model=Instance.new("Folder",world); model.Name="Terreno"..i
        part(model,"Base",Vector3.new(400,.4,195),Vector3.new(0,-.25,z),Color3.fromRGB(75,128,68),Enum.Material.Grass)
        local ownerSign=part(model,"PlacaDono",Vector3.new(1,7,24),Vector3.new(-172,6,z-82),Color3.fromRGB(22,42,36),Enum.Material.Metal)
        surfaceText(ownerSign,"TERRENO DISPONIVEL")
        part(model,"PostePlaca1",Vector3.new(.7,6,.7),Vector3.new(-172,3,z-89),Color3.fromRGB(65,70,72),Enum.Material.Metal)
        part(model,"PostePlaca2",Vector3.new(.7,6,.7),Vector3.new(-172,3,z-75),Color3.fromRGB(65,70,72),Enum.Material.Metal)
        for n=1,8 do
            local x=-145+(n-1)*40
            local side=n%2==0 and -88 or 88
            tree(model,Vector3.new(x,0,z+side),.75+(n%3)*.12)
        end
        local brasil=part(model,"PlacaBrasil",Vector3.new(.7,6,15),Vector3.new(-118,5,z+80),Color3.fromRGB(20,92,135),Enum.Material.Metal)
        surfaceText(brasil,"BR-101\nBOA VIAGEM")
        part(model,"CaminhoTorre",Vector3.new(28,.4,10),Vector3.new(-164,.2,z),Color3.fromRGB(105,108,110),Enum.Material.Concrete)
        part(model,"BaseTorre",Vector3.new(24,2,24),Vector3.new(-178,1,z),Color3.fromRGB(45,50,55),Enum.Material.Concrete)
        part(model,"Torre",Vector3.new(8,42,8),Vector3.new(-178,22,z),Color3.fromRGB(155,160,165),Enum.Material.Concrete)
        for y=7,38,6 do
            part(model,"JanelaTorre",Vector3.new(.2,3,3.2),Vector3.new(-173.9,y,z),Color3.fromRGB(65,155,195),Enum.Material.Glass).Transparency=.18
        end
        part(model,"Mirante",Vector3.new(24,2,24),Vector3.new(-178,44,z),Color3.fromRGB(35,40,45),Enum.Material.Metal)
        local sala=part(model,"SalaControle",Vector3.new(19,8,19),Vector3.new(-178,49,z),Color3.fromRGB(70,165,200),Enum.Material.Glass); sala.Transparency=.3
        part(model,"TetoTorre",Vector3.new(23,1,23),Vector3.new(-178,53.5,z),Color3.fromRGB(0,100,72),Enum.Material.Metal)
        part(model,"Antena",Vector3.new(.6,12,.6),Vector3.new(-178,60,z),Color3.fromRGB(95,100,105),Enum.Material.Metal)
        local cameraPoint=part(model,"CameraPoint",Vector3.new(1,1,1),Vector3.new(-178,58,z),Color3.new(1,1,1)); cameraPoint.Transparency=1; cameraPoint.CanCollide=false
        plots[i]={index=i,centerZ=z,model=model,sign=ownerSign,owner=nil,lanes={},barriers={}}
    end
    task.spawn(function()
        while world.Parent do Lighting.ClockTime=(Lighting.ClockTime+.04)%24; task.wait(1) end
    end)
    return world
end

function TycoonService.Assign(player,state)
    for _,plot in ipairs(plots) do
        if not plot.owner then
            plot.owner=player; playerPlots[player]=plot
            player:SetAttribute("PlotCenterZ",plot.centerZ)
            for _,child in ipairs(plot.model:GetChildren()) do if child.Name:match("Rodovia") then child:Destroy() end end
            plot.lanes={}; plot.barriers={}; for i=1,state.plazas do buildPlaza(plot,i) end
            changeSurfaceText(plot.sign,"IMPERIO DE\n"..string.upper(player.DisplayName))
            player.RespawnLocation=nil
            task.defer(function()
                local character=player.Character or player.CharacterAdded:Wait()
                character:PivotTo(CFrame.new(-120,5,plot.centerZ-60))
            end)
            return plot
        end
    end
end

function TycoonService.Expand(player,state)
    local plot=playerPlots[player]; if not plot then return end
    buildPlaza(plot,state.plazas)
end

function TycoonService.SetPremiumTheme(player,enabled)
    local plot=playerPlots[player]; if not plot then return end
    for _,road in ipairs(plot.model:GetChildren()) do
        if road.Name:match("Rodovia") then
            local booth=road:FindFirstChild("Cabine")
            local sign=road:FindFirstChild("Letreiro")
            if booth then booth.Color=enabled and Color3.fromRGB(24,35,48) or Color3.fromRGB(0,110,78) end
            if sign then sign.Color=enabled and Color3.fromRGB(205,150,30) or Color3.fromRGB(0,90,65) end
        end
    end
end

function TycoonService.UpdateVisuals(player,state)
    local plot=playerPlots[player]; if not plot then return end
    local level=math.max(state.tariff,state.traffic,state.quality,state.automation)
    local tier=level>=15 and 4 or level>=10 and 3 or level>=5 and 2 or 1
    local region=math.clamp(state.region or 1,1,#regionNames)
    local base=plot.model:FindFirstChild("Base"); if base then base.Color=regionColors[region] end
    changeSurfaceText(plot.sign,"IMPERIO DE\n"..string.upper(player.DisplayName).."\n"..regionNames[region])
    for index=1,state.plazas do
        local road=plot.model:FindFirstChild("Rodovia"..index)
        if road then
            local booth=road:FindFirstChild("Cabine"); local roof=road:FindFirstChild("Cobertura"); local sign=road:FindFirstChild("Letreiro")
            if booth then booth.Color=state.premiumTheme and Color3.fromRGB(24,35,48) or ({Color3.fromRGB(126,86,44),Color3.fromRGB(0,110,78),Color3.fromRGB(25,115,165),Color3.fromRGB(35,38,48)})[tier]; booth.Material=tier>=3 and Enum.Material.Metal or Enum.Material.Concrete end
            if roof then roof.Color=tier==4 and Color3.fromRGB(225,190,65) or Color3.fromRGB(225,230,235); roof.Material=tier>=3 and Enum.Material.Metal or Enum.Material.Concrete end
            if sign then sign.Color=state.premiumTheme and Color3.fromRGB(205,150,30) or ({Color3.fromRGB(105,72,38),Color3.fromRGB(0,90,65),Color3.fromRGB(20,90,145),Color3.fromRGB(25,28,38)})[tier]; changeSurfaceText(sign,regionNames[region].."  •  NIVEL "..tier) end
            local upgrades=road:FindFirstChild("EvolucaoVisual"); if upgrades then upgrades:Destroy() end
            upgrades=Instance.new("Folder",road); upgrades.Name="EvolucaoVisual"
            if tier>=2 then
                for _,offset in ipairs({-9,9}) do part(upgrades,"Luminaria",Vector3.new(.7,.7,5),Vector3.new(2,9.1,(plot.lanes[index] or 0)+offset),Color3.fromRGB(255,245,190),Enum.Material.Neon) end
            end
            if tier>=3 then
                part(upgrades,"SensorAutomatico",Vector3.new(1,.25,8),Vector3.new(-15,.75,plot.lanes[index] or 0),Color3.fromRGB(55,220,255),Enum.Material.Neon)
                local board=part(upgrades,"PainelDigital",Vector3.new(.5,2.4,9),Vector3.new(-3,14,plot.lanes[index] or 0),Color3.fromRGB(8,35,42),Enum.Material.Metal); surfaceText(board,"COBRANCA\nAUTOMATICA")
            end
            if tier>=4 then
                for _,offset in ipairs({-11,11}) do part(upgrades,"PilarPremium",Vector3.new(1,13,1),Vector3.new(0,6.5,(plot.lanes[index] or 0)+offset),Color3.fromRGB(210,165,45),Enum.Material.Metal) end
            end
        end
    end
end

function TycoonService.Rebuild(player,state)
    local plot=playerPlots[player]; if not plot then return end
    for _,child in ipairs(plot.model:GetChildren()) do if child.Name:match("Rodovia") then child:Destroy() end end
    plot.lanes={}; plot.barriers={}; for i=1,state.plazas do buildPlaza(plot,i) end
    TycoonService.UpdateVisuals(player,state)
end

function TycoonService.GetPlot(player) return playerPlots[player] end
function TycoonService.MoveBarrier(player,index,open)
    local plot=playerPlots[player]; local b=plot and plot.barriers[index]
    if not b or b.broken then return end
    b.signal.Color=open and Color3.fromRGB(45,255,105) or Color3.fromRGB(255,45,45)
    local target=b.closed*CFrame.Angles(open and math.rad(82) or 0,0,0)
    TweenService:Create(b.arm,TweenInfo.new(.35,Enum.EasingStyle.Quad),{CFrame=target}):Play()
    for _,stripe in ipairs(b.stripes) do TweenService:Create(stripe.part,TweenInfo.new(.35,Enum.EasingStyle.Quad),{CFrame=target*stripe.relative}):Play() end
end
function TycoonService.SetBarrierBroken(player,index,broken)
    local plot=playerPlots[player]; local b=plot and plot.barriers[index]
    if not b then return end
    b.broken=broken; b.signal.Color=broken and Color3.fromRGB(255,145,25) or Color3.fromRGB(255,45,45)
    if broken then
        TweenService:Create(b.arm,TweenInfo.new(.3),{CFrame=b.closed}):Play()
        for _,stripe in ipairs(b.stripes) do TweenService:Create(stripe.part,TweenInfo.new(.3),{CFrame=b.closed*stripe.relative}):Play() end
    end
end
function TycoonService.Release(player)
    local plot=playerPlots[player]; if not plot then return end
    plot.owner=nil; playerPlots[player]=nil
    for _,child in ipairs(plot.model:GetChildren()) do if child.Name:match("Rodovia") then child:Destroy() end end
    changeSurfaceText(plot.sign,"TERRENO\nDISPONIVEL")
    plot.lanes={}; plot.barriers={}
end

return TycoonService
