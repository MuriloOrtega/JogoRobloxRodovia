local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local GuiService=game:GetService("GuiService")
local UserInputService=game:GetService("UserInputService")
local ContextActionService=game:GetService("ContextActionService")
local player=Players.LocalPlayer
local remotes=RS:WaitForChild("RodoviaRemotes")
local action=remotes:WaitForChild("TycoonAction")

local gui=Instance.new("ScreenGui",player:WaitForChild("PlayerGui")); gui.Name="GameplayUI"; gui.ResetOnSpawn=false; gui.DisplayOrder=5
local toggle=Instance.new("TextButton",gui); toggle.Size=UDim2.fromOffset(126,42); toggle.Position=UDim2.new(0,146,0,76)
toggle.BackgroundColor3=Color3.fromRGB(35,105,160); toggle.TextColor3=Color3.new(1,1,1); toggle.Text="MISSOES"; toggle.Font=Enum.Font.GothamBold; toggle.TextSize=13; toggle.Selectable=true
Instance.new("UICorner",toggle).CornerRadius=UDim.new(0,12); local toggleStroke=Instance.new("UIStroke",toggle); toggleStroke.Color=Color3.fromRGB(105,200,255); toggleStroke.Transparency=.35

local frame=Instance.new("Frame",gui); frame.Size=UDim2.fromOffset(430,390); frame.Position=UDim2.new(.5,-215,.5,-195); frame.BackgroundColor3=Color3.fromRGB(15,30,42); frame.Visible=false
Instance.new("UICorner",frame).CornerRadius=UDim.new(0,16); local frameStroke=Instance.new("UIStroke",frame); frameStroke.Color=Color3.fromRGB(65,165,225); frameStroke.Thickness=2; frameStroke.Transparency=.3
local scale=Instance.new("UIScale",frame); scale.Scale=workspace.CurrentCamera.ViewportSize.X<700 and .76 or .95
local title=Instance.new("TextLabel",frame); title.Position=UDim2.fromOffset(18,12); title.Size=UDim2.fromOffset(350,30); title.BackgroundTransparency=1; title.Text="CENTRAL DE MISSOES"; title.TextColor3=Color3.fromRGB(115,210,255); title.TextXAlignment=Enum.TextXAlignment.Left; title.Font=Enum.Font.GothamBold; title.TextSize=18
local close=Instance.new("TextButton",frame); close.Position=UDim2.fromOffset(382,10); close.Size=UDim2.fromOffset(32,32); close.BackgroundColor3=Color3.fromRGB(55,65,75); close.Text="×"; close.TextColor3=Color3.new(1,1,1); close.Font=Enum.Font.GothamBold; close.TextSize=20; close.Selectable=true
Instance.new("UICorner",close).CornerRadius=UDim.new(1,0)
local regionInfo=Instance.new("TextLabel",frame); regionInfo.Position=UDim2.fromOffset(18,48); regionInfo.Size=UDim2.fromOffset(394,52); regionInfo.BackgroundTransparency=1; regionInfo.TextColor3=Color3.fromRGB(225,235,240); regionInfo.TextXAlignment=Enum.TextXAlignment.Left; regionInfo.TextWrapped=true; regionInfo.Font=Enum.Font.GothamBold; regionInfo.TextSize=13
local missionButtons={}
for i=1,3 do
    local b=Instance.new("TextButton",frame); b.Position=UDim2.fromOffset(18,104+(i-1)*58); b.Size=UDim2.fromOffset(394,50); b.BackgroundColor3=Color3.fromRGB(30,82,112); b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=13; b.TextWrapped=true; b.Selectable=true
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,10); local stroke=Instance.new("UIStroke",b); stroke.Color=Color3.fromRGB(95,195,245); stroke.Transparency=.5
    missionButtons[i]=b
end
local advance=Instance.new("TextButton",frame); advance.Position=UDim2.fromOffset(18,286); advance.Size=UDim2.fromOffset(394,48); advance.BackgroundColor3=Color3.fromRGB(185,115,25); advance.TextColor3=Color3.new(1,1,1); advance.Font=Enum.Font.GothamBold; advance.TextSize=13; advance.TextWrapped=true; advance.Selectable=true
Instance.new("UICorner",advance).CornerRadius=UDim.new(0,10); local advanceStroke=Instance.new("UIStroke",advance); advanceStroke.Color=Color3.fromRGB(255,210,90); advanceStroke.Transparency=.4
local message=Instance.new("TextLabel",frame); message.Position=UDim2.fromOffset(18,344); message.Size=UDim2.fromOffset(394,30); message.BackgroundTransparency=1; message.Text="Missoes renovam diariamente"; message.TextColor3=Color3.fromRGB(180,200,210); message.Font=Enum.Font.Gotham; message.TextSize=12

local open=false
local data
local function setOpen(value)
    open=value; frame.Visible=value
    if value and UserInputService.GamepadEnabled then GuiService.SelectedObject=missionButtons[1] elseif GuiService.SelectedObject and GuiService.SelectedObject:IsDescendantOf(frame) then GuiService.SelectedObject=nil end
end
toggle.Activated:Connect(function() setOpen(not open) end); close.Activated:Connect(function() setOpen(false) end)

local function refresh(d)
    data=d
    regionInfo.Text=string.format("Regiao: %s  •  Prestigio: %d\nBonus regional e permanente: receita %.2fx",d.regionName,d.prestige,d.incomeMultiplier)
    for i,b in ipairs(missionButtons) do
        local mission=d.missions[i]
        if mission then
            b:SetAttribute("MissionKey",mission.key)
            b.Text=mission.claimed and "✓  "..mission.title.."  •  COLETADA" or string.format("%s  •  %d/%d  •  +%d",mission.title,mission.progress,mission.goal,mission.reward)
            b.BackgroundTransparency=mission.claimed and .5 or 0
        end
    end
    advance.Text=d.canAdvance and "LIBERAR PROXIMA REGIAO / PRESTIGIO" or string.format("PROXIMA REGIAO: 5 RODOVIAS + MELHORIAS NIVEL %d",d.regionRequirement)
    advance.BackgroundTransparency=d.canAdvance and 0 or .35
end
remotes.TycoonUpdate.OnClientEvent:Connect(refresh)
task.spawn(function() local ok,success,d=pcall(function() return action:InvokeServer("get") end); if ok and success then refresh(d) end end)
for _,b in ipairs(missionButtons) do
    b.Activated:Connect(function()
        if not b:GetAttribute("MissionKey") then return end
        local ok,success,text=pcall(function() return action:InvokeServer("claimMission",b:GetAttribute("MissionKey")) end)
        message.Text=ok and text or "Erro ao conectar"; message.TextColor3=ok and success and Color3.fromRGB(90,245,145) or Color3.fromRGB(255,105,95)
    end)
end
advance.Activated:Connect(function()
    local ok,success,text=pcall(function() return action:InvokeServer("advanceRegion") end)
    message.Text=ok and text or "Erro ao conectar"; message.TextColor3=ok and success and Color3.fromRGB(90,245,145) or Color3.fromRGB(255,105,95)
end)
for i,b in ipairs(missionButtons) do b.NextSelectionUp=i==1 and advance or missionButtons[i-1]; b.NextSelectionDown=i==3 and advance or missionButtons[i+1] end
advance.NextSelectionUp=missionButtons[3]; advance.NextSelectionDown=missionButtons[1]

local operation=Instance.new("Frame",gui); operation.Size=UDim2.fromOffset(440,300); operation.Position=UDim2.new(.5,-220,.5,-150); operation.BackgroundColor3=Color3.fromRGB(32,26,22); operation.Visible=false
Instance.new("UICorner",operation).CornerRadius=UDim.new(0,16); local operationStroke=Instance.new("UIStroke",operation); operationStroke.Color=Color3.fromRGB(255,155,55); operationStroke.Thickness=3
local operationScale=Instance.new("UIScale",operation); operationScale.Scale=workspace.CurrentCamera.ViewportSize.X<700 and .75 or .95
local opTitle=Instance.new("TextLabel",operation); opTitle.Position=UDim2.fromOffset(18,16); opTitle.Size=UDim2.fromOffset(404,32); opTitle.BackgroundTransparency=1; opTitle.TextColor3=Color3.fromRGB(255,175,75); opTitle.Font=Enum.Font.GothamBold; opTitle.TextSize=19
local opDescription=Instance.new("TextLabel",operation); opDescription.Position=UDim2.fromOffset(18,53); opDescription.Size=UDim2.fromOffset(404,60); opDescription.BackgroundTransparency=1; opDescription.TextColor3=Color3.new(1,1,1); opDescription.TextWrapped=true; opDescription.Font=Enum.Font.Gotham; opDescription.TextSize=15
local opButtons={}
for i=1,3 do
    local b=Instance.new("TextButton",operation); b.Position=UDim2.fromOffset(18,122+(i-1)*47); b.Size=UDim2.fromOffset(404,40); b.BackgroundColor3=Color3.fromRGB(115,68,30); b.TextColor3=Color3.new(1,1,1); b.Font=Enum.Font.GothamBold; b.TextSize=13; b.Selectable=true
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,9); opButtons[i]=b
end
local opToken
local function answer(choice)
    if not opToken then return end
    local ok,correct,text=pcall(function() return remotes.ResolveOperation:InvokeServer(opToken,choice) end)
    opDescription.Text=ok and text or "Erro de comunicacao"; opDescription.TextColor3=ok and correct and Color3.fromRGB(95,255,145) or Color3.fromRGB(255,100,90)
    opToken=nil; task.wait(1.2); operation.Visible=false; GuiService.SelectedObject=open and missionButtons[1] or nil
end
for i,b in ipairs(opButtons) do b.Activated:Connect(function() answer(b.Text) end); b.NextSelectionUp=opButtons[i==1 and 3 or i-1]; b.NextSelectionDown=opButtons[i==3 and 1 or i+1] end
remotes.OperationEvent.OnClientEvent:Connect(function(event)
    if event.expired then operation.Visible=false; opToken=nil; message.Text=event.message; return end
    opToken=event.token; operation.Visible=true; opTitle.Text=event.title; opDescription.Text=event.description.."\nDecida antes que o tempo acabe."
    opDescription.TextColor3=Color3.new(1,1,1)
    for i,b in ipairs(opButtons) do b.Text=event.options[i] end
    if UserInputService.GamepadEnabled then GuiService.SelectedObject=opButtons[1] end
end)

ContextActionService:BindActionAtPriority("RodoviaMissions",function(_,state,input)
    if state~=Enum.UserInputState.Begin then return Enum.ContextActionResult.Pass end
    if input.KeyCode==Enum.KeyCode.ButtonL1 then setOpen(not open); return Enum.ContextActionResult.Sink end
    if input.KeyCode==Enum.KeyCode.ButtonB and open and not operation.Visible then setOpen(false); return Enum.ContextActionResult.Sink end
    return Enum.ContextActionResult.Pass
end,false,2500,Enum.KeyCode.ButtonL1,Enum.KeyCode.ButtonB)
