local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local WorldBuilder = {}
local world
local plaza
local barriers = {}

local function part(parent, name, size, cf, color, material, shape)
    local p = Instance.new("Part")
    p.Name, p.Size, p.CFrame, p.Color = name, size, cf, color
    p.Anchored = true
    p.Material = material or Enum.Material.SmoothPlastic
    p.Shape = shape or Enum.PartType.Block
    p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
    p.Parent = parent
    return p
end

local function label(parent, text, color)
    for _,face in ipairs({Enum.NormalId.Left,Enum.NormalId.Right}) do
        local gui=Instance.new("SurfaceGui",parent)
        gui.Face,gui.SizingMode,gui.CanvasSize=face,Enum.SurfaceGuiSizingMode.FixedSize,Vector2.new(800,300)
        local box=Instance.new("TextLabel",gui)
        box.Size,box.BackgroundColor3,box.TextColor3=UDim2.fromScale(1,1),color,Color3.new(1,1,1)
        box.TextScaled,box.Font,box.Text=true,Enum.Font.GothamBold,text
        box.BorderSizePixel=0
    end
end

local function organicPart(parent,name,size,cf,color,material)
    local base=part(parent,name,Vector3.new(1,1,1),cf,color,material)
    local mesh=Instance.new("SpecialMesh",base)
    mesh.MeshType,mesh.Scale=Enum.MeshType.Sphere,size
    return base
end

local function tree(x, z, scale)
    local trunk = part(world, "Tronco", Vector3.new(2*scale, 8*scale, 2*scale), CFrame.new(x, 4*scale, z), Color3.fromRGB(105, 70, 42), Enum.Material.Wood)
    local crown=organicPart(world,"Copa",Vector3.new(7*scale,5*scale,7*scale),CFrame.new(x,9.5*scale,z),Color3.fromRGB(45,125,58),Enum.Material.Grass)
    local crown2=organicPart(world,"Copa",Vector3.new(5*scale,4*scale,5*scale),CFrame.new(x+2*scale,11*scale,z+1.2*scale),Color3.fromRGB(55,145,65),Enum.Material.Grass)
    trunk.CanCollide,crown.CanCollide,crown2.CanCollide=false,false,false
end

local function mountain(x, z, size, color)
    local m = part(world, "Montanha", Vector3.new(size, size, size), CFrame.new(x, size/2-1, z) * CFrame.Angles(0, math.rad(45), math.rad(45)), color, Enum.Material.Slate)
    m.CanCollide = false
end

local function roadSign(text, x, z)
    part(world, "PostePlaca", Vector3.new(0.7, 10, 0.7), CFrame.new(x, 5, z), Color3.fromRGB(90, 95, 100), Enum.Material.Metal)
    local board = part(world, "Placa", Vector3.new(0.7, 5, 12), CFrame.new(x, 10, z), Color3.fromRGB(25, 105, 165), Enum.Material.Metal)
    label(board, text, Color3.fromRGB(25, 105, 165))
end

function WorldBuilder.BuildBase()
    Lighting.ClockTime = 16.2
    Lighting.Brightness = 2.2
    Lighting.EnvironmentDiffuseScale = 0.45
    Lighting.EnvironmentSpecularScale = 0.6
    Lighting.GlobalShadows = true
    Lighting.OutdoorAmbient = Color3.fromRGB(145, 155, 165)
    local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)
    atmosphere.Density, atmosphere.Offset = 0.28, 0.1
    atmosphere.Color, atmosphere.Decay = Color3.fromRGB(205, 225, 240), Color3.fromRGB(110, 125, 150)
    local bloom = Lighting:FindFirstChildOfClass("BloomEffect") or Instance.new("BloomEffect", Lighting)
    bloom.Intensity, bloom.Size, bloom.Threshold = 0.1, 18, 2
    local rays = Lighting:FindFirstChildOfClass("SunRaysEffect") or Instance.new("SunRaysEffect", Lighting)
    rays.Intensity, rays.Spread = 0.06, 0.75
    local color = Lighting:FindFirstChildOfClass("ColorCorrectionEffect") or Instance.new("ColorCorrectionEffect", Lighting)
    color.Contrast, color.Saturation, color.TintColor = 0.03, 0.03, Color3.fromRGB(255, 250, 242)

    world = Instance.new("Folder", workspace)
    world.Name = "ImperioDaRodovia"
    part(world, "Gramado", Vector3.new(320, 1, 220), CFrame.new(0, -1, 0), Color3.fromRGB(68, 125, 62), Enum.Material.Grass)
    part(world, "Rodovia", Vector3.new(320, 1, 66), CFrame.new(0, 0, 0), Color3.fromRGB(43, 45, 49), Enum.Material.Asphalt)
    for _,z in ipairs({-29,29}) do
        part(world,"Acostamento",Vector3.new(320,.08,5),CFrame.new(0,.56,z),Color3.fromRGB(72,74,76),Enum.Material.Asphalt)
        part(world,"FaixaBranca",Vector3.new(320,.11,.35),CFrame.new(0,.59,z+(z>0 and -2.5 or 2.5)),Color3.fromRGB(235,235,225),Enum.Material.Neon)
    end
    for x=-150,150,18 do
        for _,z in ipairs({-10,10}) do part(world,"Faixa",Vector3.new(9,.12,.4),CFrame.new(x,.57,z),Color3.fromRGB(245,210,55),Enum.Material.Neon) end
    end
    for _,z in ipairs({-32,32}) do
        part(world,"GuardRail",Vector3.new(320,.7,.35),CFrame.new(0,1,z),Color3.fromRGB(180,185,190),Enum.Material.Metal)
        for x=-150,150,12 do part(world,"Suporte",Vector3.new(.35,2,.35),CFrame.new(x,.8,z),Color3.fromRGB(115,120,125),Enum.Material.Metal) end
    end
    for i=1,24 do
        local side = i%2==0 and 1 or -1
        tree(-145+(i*12)%290, side*(48+(i%4)*12), .75+(i%3)*.12)
    end
    -- As montanhas são feitas abaixo com Terrain para evitar formas quadradas.
    local terrain=workspace.Terrain
    for x=-150,150,50 do
        terrain:FillBall(Vector3.new(x,-12,92),30,Enum.Material.Rock)
        terrain:FillBall(Vector3.new(x+16,-9,82),23,Enum.Material.Grass)
    end
    for i=1,18 do
        local x=-145+i*16
        local z=(i%2==0 and 1 or -1)*(38+(i%3)*4)
        local rock=part(world,"Pedra",Vector3.new(2+i%4,1.5+i%3,2.5+i%2),CFrame.new(x,.7,z)*CFrame.Angles(math.rad(i*7),math.rad(i*19),0),Color3.fromRGB(100,105,100),Enum.Material.Slate,Enum.PartType.Ball)
        rock.CanCollide=false
    end
    for _,x in ipairs({-125,-70,-15,40,95,140}) do
        local pole=part(world,"PosteLuz",Vector3.new(.55,12,.55),CFrame.new(x,6,-38),Color3.fromRGB(75,80,85),Enum.Material.Metal)
        local arm=part(world,"BracoLuz",Vector3.new(.35,.35,5),CFrame.new(x,11.7,-35.7),Color3.fromRGB(75,80,85),Enum.Material.Metal)
        local lamp=part(world,"Lampada",Vector3.new(1,.25,2),CFrame.new(x,11.5,-33.4),Color3.fromRGB(255,235,175),Enum.Material.Neon)
        local light=Instance.new("SpotLight",lamp); light.Face=Enum.NormalId.Bottom; light.Range=28; light.Angle=80; light.Brightness=2
        pole.CanCollide,arm.CanCollide=false,false
    end
    roadSign("PEDAGIO A 500 m", -85, -42)
    roadSign("REDUZA A VELOCIDADE", 75, 42)
    local spawn = Instance.new("SpawnLocation", world)
    spawn.Name, spawn.Size, spawn.Position = "Spawn", Vector3.new(12,1,12), Vector3.new(38,1,48)
    spawn.Anchored, spawn.Neutral, spawn.Color = true, true, Color3.fromRGB(0,170,127)
    return world
end

local function barrier(z, improvised)
    local postColor = improvised and Color3.fromRGB(100,75,48) or Color3.fromRGB(35,40,44)
    part(plaza,"PosteCancela",Vector3.new(1.5,4,1.5),CFrame.new(-13,2.5,z-4),postColor,improvised and Enum.Material.Wood or Enum.Material.Metal)
    local arm = part(plaza,"Cancela",Vector3.new(.55,.55,8),CFrame.new(-13,4.2,z),Color3.fromRGB(245,245,245),Enum.Material.Metal)
    arm.CanCollide = false
    barriers[z] = {arm=arm, closed=arm.CFrame}
end

local function booth(z, tier)
    local colors = {Color3.fromRGB(115,85,50),Color3.fromRGB(0,105,75),Color3.fromRGB(30,95,145),Color3.fromRGB(30,30,38)}
    local materials = {Enum.Material.Wood,Enum.Material.Metal,Enum.Material.Metal,Enum.Material.Metal}
    local b = part(plaza,"Cabine",Vector3.new(tier==1 and 7 or 9,tier==1 and 7 or 9,6),CFrame.new(1,tier==1 and 4 or 5,z),colors[tier],materials[tier])
    local window = part(plaza,"Janela",Vector3.new(.25,3,4),CFrame.new(tier==1 and -2.62 or -3.62,5.8,z),Color3.fromRGB(90,190,225),Enum.Material.Glass)
    window.Transparency = .2
    label(b, tier==1 and "PARE" or tier==4 and "VIA PREMIUM" or "PEDAGIO", colors[tier])
end

function WorldBuilder.BuildPlaza(tier)
    if plaza then plaza:Destroy() end
    plaza = Instance.new("Folder", world); plaza.Name = "PracaEvolutiva"
    barriers = {}
    local lanes = tier==1 and {-9} or {-9,9}
    for _,z in ipairs(lanes) do barrier(z,tier==1) end
    if tier==1 then
        booth(0,1)
        part(plaza,"Cone1",Vector3.new(2,3,2),CFrame.new(-18,1.5,-2),Color3.fromRGB(240,110,25),Enum.Material.Plastic)
        part(plaza,"Cone2",Vector3.new(2,3,2),CFrame.new(-18,1.5,2),Color3.fromRGB(240,110,25),Enum.Material.Plastic)
    else
        for _,z in ipairs({-18,0,18}) do booth(z,tier) end
        local roofColor = tier==2 and Color3.fromRGB(235,238,240) or tier==3 and Color3.fromRGB(205,225,235) or Color3.fromRGB(28,30,38)
        part(plaza,"Cobertura",Vector3.new(tier==4 and 58 or 46,1.3,58),CFrame.new(0,tier>=3 and 15 or 13,0),roofColor,Enum.Material.Metal)
        for _,z in ipairs({-27,27}) do part(plaza,"Pilar",Vector3.new(1.5,tier>=3 and 15 or 13,1.5),CFrame.new(0,(tier>=3 and 15 or 13)/2,z),tier==4 and Color3.fromRGB(185,145,45) or Color3.fromRGB(0,105,75),Enum.Material.Metal) end
        if tier>=3 then
            for _,x in ipairs({-20,0,20}) do
                local lamp=part(plaza,"LED",Vector3.new(5,.25,1),CFrame.new(x,14.1,0),tier==4 and Color3.fromRGB(255,205,65) or Color3.fromRGB(120,220,255),Enum.Material.Neon)
                local light=Instance.new("PointLight",lamp); light.Range,light.Brightness,light.Color=30,2,lamp.Color
            end
        end
        if tier==4 then
            local crown=part(plaza,"LetreiroPremium",Vector3.new(1,4,30),CFrame.new(-2,18,0),Color3.fromRGB(185,145,45),Enum.Material.Neon)
            label(crown,"PRACA PREMIUM",Color3.fromRGB(25,25,30))
        end
    end
end

function WorldBuilder.MoveBarrier(z, open)
    local b=barriers[z] or barriers[-9]
    if not b then return end
    TweenService:Create(b.arm,TweenInfo.new(.45,Enum.EasingStyle.Quad),{CFrame=b.closed*CFrame.Angles(open and math.rad(82) or 0,0,0)}):Play()
end

return WorldBuilder
