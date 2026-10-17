-- Visual showroom only. Kept separate from combat until the boss is approved.
local RS=game:GetService('ReplicatedStorage')
local RunService=game:GetService('RunService')
local TweenService=game:GetService('TweenService')
local Debris=game:GetService('Debris')
local Warden=require(RS:WaitForChild('RiftWardenModel'))
local old=workspace:FindFirstChild('RiftWardenPreview')
local origin=old and old:GetPivot() or CFrame.new(0,0,-28)
if old then old:Destroy() end
local rig=Warden.create(workspace,origin)
rig.model.Name='RiftWardenPreview'
local anchor=Instance.new('Attachment');anchor.Position=Vector3.new(0,6,0);anchor.Parent=rig.root
local prompt=Instance.new('ProximityPrompt');prompt.ActionText='공격 동작 시연';prompt.ObjectText='균열의 수문장 · 외형 미리보기';prompt.MaxActivationDistance=22;prompt.RequiresLineOfSight=false;prompt.HoldDuration=.3;prompt.Parent=anchor
local gui=Instance.new('BillboardGui');gui.Name='PreviewLabel';gui.Size=UDim2.fromOffset(300,65);gui.StudsOffsetWorldSpace=Vector3.new(0,15,0);gui.MaxDistance=100;gui.AlwaysOnTop=false;gui.Adornee=rig.root;gui.Parent=rig.model
local title=Instance.new('TextLabel');title.Size=UDim2.fromScale(1,1);title.BackgroundTransparency=1;title.Text='균열의 수문장\n외형 미리보기 · 가까이서 동작 시연';title.TextColor3=Color3.fromRGB(235,207,255);title.TextStrokeTransparency=.3;title.TextSize=17;title.Font=Enum.Font.GothamBold;title.Parent=gui
local effects=Instance.new('Folder');effects.Name='WardenPreviewEffects';effects.Parent=rig.model
local function effectPart(size,cf,color)
 local p=Instance.new('Part');p.Name='PreviewEffect';p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Material=Enum.Material.Neon;p.Color=color;p.Size=size;p.CFrame=cf;p.Parent=effects
 return p
end
local function circle(pos,radius,color,life)
 for i=1,32 do
  local a=i*math.pi/16
  local p=effectPart(Vector3.new(radius*.17,.06,.16),CFrame.new(pos)*CFrame.Angles(0,a,0)*CFrame.new(0,0,-radius),color)
  TweenService:Create(p,TweenInfo.new(life),{Transparency=1}):Play();Debris:AddItem(p,life)
 end
end
local function shards(pos)
 circle(pos,8,Color3.fromRGB(211,137,255),.7)
 for i=1,12 do
  local a=i*math.pi/6
  local p=effectPart(Vector3.new(.4,1,.4),CFrame.new(pos),Color3.fromRGB(116,93,140));p.Material=Enum.Material.Slate
  TweenService:Create(p,TweenInfo.new(.65,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CFrame=CFrame.new(pos+Vector3.new(math.cos(a)*6,2,math.sin(a)*6))*CFrame.Angles(a,a,1),Transparency=1}):Play();Debris:AddItem(p,.7)
 end
end
local clock=0
local demoStart=nil
local emitted={}
local originHome=origin
local function startDemo()
 if demoStart then return end
 demoStart=clock;emitted={};prompt.Enabled=false
end
prompt.Triggered:Connect(startDemo)
rig.model:GetAttributeChangedSignal('RunDemo'):Connect(function()
 if rig.model:GetAttribute('RunDemo') then rig.model:SetAttribute('RunDemo',false);startDemo() end
end)
RunService.Heartbeat:Connect(function(dt)
 clock+=dt
 local attack,progress,phase=nil,0,1
 if demoStart then
  local age=clock-demoStart
  if age<2.4 then
   attack='slam';progress=age/2.4
   local impact=originHome:PointToWorldSpace(Vector3.new(4.45,.08,-.45))
   if not emitted.warn then emitted.warn=true;circle(impact,8,Color3.fromRGB(255,106,146),1.7) end
   if progress>=.77 and not emitted.slam then emitted.slam=true;shards(impact) end
  elseif age<5.3 then
   phase=2
   if not emitted.rift then
    emitted.rift=true
    for _,angle in ipairs({-.42,0,.42}) do
     local direction=(originHome*CFrame.Angles(0,angle,0)).LookVector
     for j=1,9 do
      local delay=j*.075
      task.delay(delay,function()
       if not effects.Parent then return end
       local p=effectPart(Vector3.new(.28,.08,2),CFrame.lookAt(originHome.Position+direction*(j*2)+Vector3.new(0,.12,0),originHome.Position+direction*(j*2+1)+Vector3.new(0,.12,0)),Color3.fromRGB(198,110,255))
       TweenService:Create(p,TweenInfo.new(.8),{Transparency=1}):Play();Debris:AddItem(p,1)
      end)
     end
    end
   end
  elseif age<7.4 then
   phase=2;attack='charge';progress=(age-5.3)/2.1
   local distance=math.sin(progress*math.pi)*12
   rig.origin=originHome*CFrame.new(0,0,-distance)
  else
   demoStart=nil;rig.origin=originHome;prompt.Enabled=true
  end
 end
 Warden.pose(rig,clock,attack,progress,phase)
end)
