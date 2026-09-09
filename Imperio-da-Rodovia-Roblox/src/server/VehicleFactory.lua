local TweenService=game:GetService("TweenService")
local VehicleFactory={}
local defs={
    {name="Hatch",fare=10,kind="car",color=Color3.fromRGB(42,120,215)},
    {name="Esportivo",fare=15,kind="sport",color=Color3.fromRGB(215,45,45)},
    {name="Moto",fare=6,kind="moto",color=Color3.fromRGB(35,35,42)},
    {name="Van",fare=18,kind="van",color=Color3.fromRGB(225,225,215)},
    {name="Onibus",fare=25,kind="bus",color=Color3.fromRGB(230,170,35)},
    {name="Caminhao",fare=35,kind="truck",color=Color3.fromRGB(220,225,230)},
}

local function part(model,class,name,size,cf,color,material)
    local p=Instance.new(class or "Part")
    p.Name,p.Size,p.CFrame,p.Color=name,size,cf,color
    p.Anchored,p.CanCollide,p.Material=true,false,material or Enum.Material.SmoothPlastic
    p.TopSurface,p.BottomSurface=Enum.SurfaceType.Smooth,Enum.SurfaceType.Smooth
    p.Parent=model
    return p
end

local function addWheel(model,x,z)
    for _,side in ipairs({-1,1}) do
        local tire=part(model,"Part","Pneu",Vector3.new(1.7,1.7,.55),CFrame.new(x,1.25,z+side*2.55)*CFrame.Angles(math.rad(90),0,0),Color3.fromRGB(16,16,18),Enum.Material.Rubber)
        tire.Shape=Enum.PartType.Cylinder
        local rim=part(model,"Part","Aro",Vector3.new(.85,.85,.59),tire.CFrame,Color3.fromRGB(175,180,185),Enum.Material.Metal)
        rim.Shape=Enum.PartType.Cylinder
    end
end

local function lights(model,x,z,front)
    for _,side in ipairs({-1,1}) do
        part(model,"Part",front and "Farol" or "Lanterna",Vector3.new(.25,.55,.8),CFrame.new(x,2.15,z+side*1.85),front and Color3.fromRGB(255,245,175) or Color3.fromRGB(255,35,35),Enum.Material.Neon)
    end
end

local function buildCar(model,d)
    local sport=d.kind=="sport"
    part(model,"Part","Chassi",Vector3.new(sport and 8.8 or 8,1.25,4.6),CFrame.new(0,2.05,0),d.color)
    part(model,"WedgePart","Capo",Vector3.new(2.8,1.15,4.4),CFrame.new(4.4,2.25,0)*CFrame.Angles(0,math.rad(90),0),d.color)
    part(model,"WedgePart","Traseira",Vector3.new(2.2,1.1,4.4),CFrame.new(-4.1,2.25,0)*CFrame.Angles(0,math.rad(-90),0),d.color)
    part(model,"Part","Teto",Vector3.new(3.7,sport and .75 or 1.05,4),CFrame.new(-.5,sport and 3.35 or 3.55,0),d.color)
    local frontGlass=part(model,"WedgePart","Parabrisa",Vector3.new(3.8,.16,1.7),CFrame.new(1.15,3.25,0)*CFrame.Angles(math.rad(63),0,math.rad(90)),Color3.fromRGB(65,145,190),Enum.Material.Glass)
    frontGlass.Transparency=.12
    for _,side in ipairs({-1,1}) do
        local sideGlass=part(model,"WedgePart","VidroLateral",Vector3.new(2.8,1.25,.12),CFrame.new(-.35,3.5,side*2.06),Color3.fromRGB(65,145,190),Enum.Material.Glass)
        sideGlass.Transparency=.15
        part(model,"Part","Retrovisor",Vector3.new(.65,.4,.45),CFrame.new(1.25,3.15,side*2.42),d.color)
    end
    addWheel(model,-2.5,0); addWheel(model,2.65,0)
    lights(model,5.15,0,true); lights(model,-5.15,0,false)
    part(model,"Part","Parachoque",Vector3.new(.3,.35,4.1),CFrame.new(5.18,1.7,0),Color3.fromRGB(30,30,34),Enum.Material.Metal)
    if sport then
        part(model,"Part","Aerofolio",Vector3.new(.35,.25,4.3),CFrame.new(-4.2,3.25,0),Color3.fromRGB(25,25,28),Enum.Material.Metal)
        for _,side in ipairs({-1,1}) do part(model,"Part","Suporte",Vector3.new(.25,.7,.25),CFrame.new(-4.2,2.9,side*1.4),Color3.fromRGB(25,25,28),Enum.Material.Metal) end
    end
end

local function buildVanBus(model,d)
    local bus=d.kind=="bus"
    local length=bus and 15 or 10
    local height=bus and 4.7 or 4
    part(model,"Part","Carroceria",Vector3.new(length,height,4.8),CFrame.new(0,1.5+height/2,0),d.color)
    part(model,"WedgePart","FrenteInclinada",Vector3.new(4.5,height-1,2),CFrame.new(length/2+1,2+height/2,0)*CFrame.Angles(0,math.rad(90),0),d.color)
    local glass=part(model,"Part","Parabrisa",Vector3.new(.18,2,3.8),CFrame.new(length/2+.12,3.6,0),Color3.fromRGB(60,140,185),Enum.Material.Glass); glass.Transparency=.15
    if bus then
        for x=-5,4,3 do for _,side in ipairs({-1,1}) do local w=part(model,"Part","Janela",Vector3.new(2.2,1.45,.12),CFrame.new(x,4.25,side*2.46),Color3.fromRGB(55,125,170),Enum.Material.Glass); w.Transparency=.18 end end
    else
        for _,side in ipairs({-1,1}) do local w=part(model,"Part","Janela",Vector3.new(3,1.4,.12),CFrame.new(1,3.8,side*2.46),Color3.fromRGB(55,125,170),Enum.Material.Glass); w.Transparency=.18 end
    end
    addWheel(model,-length*.32,0); addWheel(model,length*.32,0)
    lights(model,length/2+.25,0,true); lights(model,-length/2-.2,0,false)
end

local function buildTruck(model,d)
    part(model,"Part","Cabine",Vector3.new(6,4.3,4.8),CFrame.new(3,3.5,0),d.color)
    part(model,"WedgePart","Capo",Vector3.new(2.4,1.8,4.6),CFrame.new(7.1,2.65,0)*CFrame.Angles(0,math.rad(90),0),d.color)
    local glass=part(model,"Part","Parabrisa",Vector3.new(.18,1.8,3.8),CFrame.new(6.05,4.15,0),Color3.fromRGB(60,140,185),Enum.Material.Glass); glass.Transparency=.15
    part(model,"Part","Reboque",Vector3.new(14,5.2,5),CFrame.new(-7,4.05,0),Color3.fromRGB(65,115,165),Enum.Material.Metal)
    part(model,"Part","FaixaReboque",Vector3.new(12,.45,5.05),CFrame.new(-7,3.4,0),Color3.fromRGB(235,235,235),Enum.Material.Neon)
    addWheel(model,4,0); addWheel(model,-2.5,0); addWheel(model,-10.5,0)
    lights(model,8.35,0,true); lights(model,-14.1,0,false)
    for _,side in ipairs({-1,1}) do part(model,"Part","Retrovisor",Vector3.new(.7,.45,.45),CFrame.new(5.3,4.35,side*2.65),d.color) end
end

local function buildMoto(model,d)
    part(model,"Part","Quadro",Vector3.new(3.5,.65,.75),CFrame.new(0,2,0),d.color,Enum.Material.Metal)
    for _,x in ipairs({-1.8,1.8}) do
        local w=part(model,"Part","Roda",Vector3.new(1.65,1.65,.38),CFrame.new(x,1.25,0)*CFrame.Angles(math.rad(90),0,0),Color3.fromRGB(16,16,18),Enum.Material.Rubber); w.Shape=Enum.PartType.Cylinder
    end
    part(model,"Part","Tanque",Vector3.new(1.8,1.1,1.3),CFrame.new(.25,2.65,0),d.color)
    part(model,"Part","Banco",Vector3.new(1.7,.35,1.1),CFrame.new(-.9,2.75,0),Color3.fromRGB(25,25,28),Enum.Material.Fabric)
    part(model,"Part","Guidao",Vector3.new(.25,.25,2.2),CFrame.new(1.25,3,0),Color3.fromRGB(150,150,155),Enum.Material.Metal)
    part(model,"Part","Farol",Vector3.new(.6,.6,.6),CFrame.new(2.05,2.35,0),Color3.fromRGB(255,245,175),Enum.Material.Neon)
end

function VehicleFactory.Spawn(world,z,onToll,options)
    options=options or {}
    local d=defs[math.random(#defs)]
    local model=Instance.new("Model",world); model.Name=d.name
    if d.kind=="car" or d.kind=="sport" then buildCar(model,d) elseif d.kind=="moto" then buildMoto(model,d) elseif d.kind=="truck" then buildTruck(model,d) else buildVanBus(model,d) end
    model:ScaleTo(d.kind=="bus" and .78 or d.kind=="truck" and .8 or .86)
    local root=part(model,"Part","Root",Vector3.new(.2,.2,.2),CFrame.new(0,1,0),Color3.new(0,0,0)); root.Transparency=1; model.PrimaryPart=root
    local entryOffset=options.entryOffset or (math.random()>.5 and -5 or 5)
    model:PivotTo(CFrame.new(-150,0,z+entryOffset))
    local value=Instance.new("CFrameValue"); value.Value=model:GetPivot()
    local connection=value.Changed:Connect(function(cf) if model.Parent then model:PivotTo(cf) end end)
    local function driveTo(x,seconds,targetZ)
        if not model.Parent then return false end
        local tween=TweenService:Create(value,TweenInfo.new(seconds,Enum.EasingStyle.Linear),{Value=CFrame.new(x,0,targetZ or z)})
        tween:Play(); tween.Completed:Wait()
        return model.Parent~=nil
    end
    task.spawn(function()
        local slot=math.max(1,options.queueSlot or 1)
        local serviceSpeed=math.max(1,options.serviceSpeed or 1)
        local row=math.floor((slot-1)/2)
        local stopX=-15-row*14
        local stopZ=slot==1 and z or z+(slot%2==0 and -5 or 5)
        if not driveTo(-58,5.6,z+entryOffset) then return end
        local distance=math.max(1,stopX+58)
        if not driveTo(stopX,distance/12,stopZ) then return end

        -- Se a pista quebrou, o veiculo permanece parado e os seguintes formam fila.
        while options.isBlocked and options.isBlocked() do task.wait(.25) end
        if slot>1 then task.wait((slot-1)*.7/serviceSpeed) end

        onToll("open",z,d)
        if not driveTo(0,math.max(.35,(0-stopX)/10/serviceSpeed),z) then return end
        onToll("charge",z,d)
        if not driveTo(13,math.max(.4,1.1/serviceSpeed),z) then return end
        onToll("close",z,d)
        local exitOffset=math.random()>.5 and -5 or 5
        if driveTo(58,3,z+exitOffset) then driveTo(160,6.3,z+exitOffset) end
        connection:Disconnect(); value:Destroy()
        if model.Parent then model:Destroy() end
    end)
end

return VehicleFactory
