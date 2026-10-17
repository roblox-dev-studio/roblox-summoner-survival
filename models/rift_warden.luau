-- Original procedural boss. No external assets or animation uploads required.
local Warden = {}
local stone = Color3.fromRGB(40, 36, 53)
local edge = Color3.fromRGB(77, 69, 94)
local metal = Color3.fromRGB(118, 104, 133)
local violet = Color3.fromRGB(171, 91, 255)
local pale = Color3.fromRGB(231, 199, 255)
local function part(parent, name, size, cf, color, material, kind)
 local p = Instance.new(kind or 'Part')
 p.Name, p.Size, p.CFrame = name, size, cf
 p.Color, p.Material = color or stone, material or Enum.Material.Slate
 p.Anchored, p.CanCollide, p.CanTouch, p.CanQuery = true, false, false, false
 p.TopSurface, p.BottomSurface = Enum.SurfaceType.Smooth, Enum.SurfaceType.Smooth
 p.Parent = parent
 return p
end
local function sphere(parent, name, size, cf, color)
 local p = part(parent,name,size,cf,color,Enum.Material.Neon)
 p.Shape=Enum.PartType.Ball
 return p
end
local function beam(parent,name,a,b,width,color)
 return part(parent,name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,Enum.Material.Neon)
end
local function ring(parent,name,center,radius,color,count)
 count=count or 20
 for i=1,count do
  local a=(i-1)*math.pi*2/count
  part(parent,name,Vector3.new(2*radius*math.sin(math.pi/count)*.8,.09,.12),center*CFrame.Angles(0,a,0)*CFrame.new(0,0,-radius),color,Enum.Material.Neon)
 end
end
function Warden.create(parent,cf)
 local model=Instance.new('Model');model.Name='RiftWarden'
 model:SetAttribute('DisplayName','균열의 수문장')
 model:SetAttribute('IsBoss',true)
 model:SetAttribute('PreviewOnly',true)
 local root=part(model,'Root',Vector3.new(1,1,1),cf);root.Transparency=1;model.PrimaryPart=root
 local groups={}
 local function group(name,pivot)
  local m=Instance.new('Model');m.Name=name;m.Parent=model
  groups[name]={model=m,pivot=pivot,parts={}}
  return m
 end
 local body=group('Armor',CFrame.new(0,7.3,0))
 part(body,'Breastplate',Vector3.new(5.2,3.2,2.7),CFrame.new(0,8,0))
 part(body,'UpperCuirass',Vector3.new(4.1,.7,2.5),CFrame.new(0,9.65,0),edge)
 part(body,'Waist',Vector3.new(2.6,1,2),CFrame.new(0,5.95,0),edge)
 for _,side in ipairs({-1,1}) do
  part(body,'AngledBreastplate',Vector3.new(1.1,2.9,2.9),CFrame.new(side*2.35,8,0)*CFrame.Angles(0,0,side*.24),edge,nil,'WedgePart')
  part(body,'HipPlate',Vector3.new(1.45,2.5,2.5),CFrame.new(side*1.9,4.9,.05)*CFrame.Angles(0,0,side*.22))
  part(body,'Trim',Vector3.new(.14,2.2,.12),CFrame.new(side*2.1,4.9,-1.23)*CFrame.Angles(0,0,side*.22),metal,Enum.Material.Metal)
  part(body,'RibLight',Vector3.new(.15,1.8,.12),CFrame.new(side*1.9,7.8,-1.42)*CFrame.Angles(0,0,side*.3),violet,Enum.Material.Neon)
 end
 -- A nested, faceted chest cavity instead of a flat glowing square.
 for i=1,8 do
  local a=i*math.pi/4
  part(body,'CoreBezel',Vector3.new(.55,1.2,.45),CFrame.new(math.sin(a)*1.04,8+math.cos(a)*1.04,-1.55)*CFrame.Angles(0,0,-a+math.pi/2),metal,Enum.Material.Metal)
 end
 local core=sphere(body,'RiftCore',Vector3.new(1.35,1.65,.8),CFrame.new(0,8,-1.65),violet)
 sphere(body,'CoreHeart',Vector3.new(.52,.7,.35),CFrame.new(0,8,-2.05),pale)
 local light=Instance.new('PointLight');light.Color=violet;light.Range=13;light.Brightness=1.1;light.Parent=core
 for _,v in ipairs({{-1.8,9.25,-.6,8.6},{.55,7.3,1.35,6.65},{1.5,9.3,2,8.8}}) do
  beam(body,'GlowingFracture',Vector3.new(v[1],v[2],-1.44),Vector3.new(v[3],v[4],-1.44),.07,violet)
 end
 local head=group('Helmet',CFrame.new(0,10.7,0))
 part(head,'Neck',Vector3.new(1.4,.45,1.5),CFrame.new(0,10.15,0),violet,Enum.Material.Neon)
 part(head,'Helm',Vector3.new(2.35,2.25,2.05),CFrame.new(0,11.5,0))
 part(head,'Brow',Vector3.new(2.6,.5,2.2),CFrame.new(0,12,-.08),edge)
 part(head,'FaceShadow',Vector3.new(1.85,.85,.12),CFrame.new(0,11.4,-1.07),Color3.fromRGB(12,8,23),Enum.Material.SmoothPlastic)
 part(head,'EyeSlit',Vector3.new(1.7,.13,.14),CFrame.new(0,11.55,-1.16),pale,Enum.Material.Neon)
 part(head,'NoseGuard',Vector3.new(.25,1.25,.3),CFrame.new(0,11.35,-1.21),metal,Enum.Material.Metal)
 for _,side in ipairs({-1,1}) do
  part(head,'CheekGuard',Vector3.new(.55,1.2,.6),CFrame.new(side*.95,10.95,-.85)*CFrame.Angles(0,0,-side*.15),edge,nil,'WedgePart')
  part(head,'CrownPoint',Vector3.new(.65,1.85,1),CFrame.new(side*1.05,13,.15)*CFrame.Angles(0,0,-side*.22),stone,nil,'WedgePart')
 end
 part(head,'CrownCrest',Vector3.new(.8,1.2,1.2),CFrame.new(0,12.85,.1),edge,nil,'WedgePart')
 for _,side in ipairs({-1,1}) do
  local name=side==1 and 'HammerArm' or 'GuardArm'
  local arm=group(name,CFrame.new(side*3.4,9.2,0))
  part(arm,'Shoulder',Vector3.new(2.5,1.7,3.1),CFrame.new(side*3.55,9.2,0)*CFrame.Angles(0,0,side*.14),edge)
  part(arm,'ShoulderCap',Vector3.new(2.3,.5,2.8),CFrame.new(side*3.65,10.2,0)*CFrame.Angles(0,0,side*.14),stone)
  for j=1,3 do
   part(arm,'ShoulderRune',Vector3.new(.13,.65,.12),CFrame.new(side*(3+j*.34),9.4,-1.6),violet,Enum.Material.Neon)
  end
  part(arm,'UpperArm',Vector3.new(1.45,2.15,1.6),CFrame.new(side*3.6,7.45,0))
  sphere(arm,'ElbowMagic',Vector3.new(1.1,.65,1.1),CFrame.new(side*3.65,6.1,0),violet)
  part(arm,'Gauntlet',Vector3.new(1.85,2.1,2),CFrame.new(side*3.7,4.85,-.1),edge)
  part(arm,'Fist',Vector3.new(1.65,.9,1.65),CFrame.new(side*3.7,3.5,-.15))
  if side==1 then
   part(arm,'HammerShaft',Vector3.new(.45,7.7,.45),CFrame.new(4.45,5.85,-.45),metal,Enum.Material.Metal)
   for j=1,4 do part(arm,'GripBand',Vector3.new(.65,.18,.65),CFrame.new(4.45,3.8+j*.36,-.45),stone) end
   part(arm,'HammerHead',Vector3.new(4.7,2.7,2.9),CFrame.new(4.45,2.3,-.45))
   for _,x in ipairs({-1,1}) do
    part(arm,'HammerEndCap',Vector3.new(.5,2.95,3.15),CFrame.new(4.45+x*2.32,2.3,-.45),edge)
    part(arm,'HammerInlay',Vector3.new(.08,1.9,2.05),CFrame.new(4.45+x*2.6,2.3,-.45),violet,Enum.Material.Neon)
   end
   for j=-1,1 do
    part(arm,'HammerRune',Vector3.new(.16,1.8,.1),CFrame.new(4.45+j*.7,2.3,-1.96)*CFrame.Angles(0,0,j*.2),violet,Enum.Material.Neon)
   end
   part(arm,'HammerPommel',Vector3.new(.9,.7,.9),CFrame.new(4.45,9.8,-.45),edge)
  end
 end
 for _,side in ipairs({-1,1}) do
  local leg=group(side==1 and 'RightGreave' or 'LeftGreave',CFrame.new(side*1.2,4.5,0))
  part(leg,'FloatingThigh',Vector3.new(1.35,1.35,1.5),CFrame.new(side*1.2,4.2,0),edge)
  sphere(leg,'KneeMagic',Vector3.new(.8,.5,.9),CFrame.new(side*1.2,3.15,-.1),violet)
  part(leg,'Greave',Vector3.new(1.55,1.7,1.9),CFrame.new(side*1.2,2.05,-.05))
  part(leg,'KneePlate',Vector3.new(1.7,.9,.55),CFrame.new(side*1.2,2.95,-.9),edge,nil,'WedgePart')
  part(leg,'PointedBoot',Vector3.new(1.7,.75,2.8),CFrame.new(side*1.2,.85,-.5),edge)
  part(leg,'ShinRune',Vector3.new(.12,1.05,.1),CFrame.new(side*1.2,2.05,-1.04),violet,Enum.Material.Neon)
 end
 for i=1,3 do
  local x=(i-2)*3.2
  local slab=group('OrbitSlab'..i,CFrame.new(x,10.4,2.8))
  part(slab,'SuspendedTablet',Vector3.new(1.7,3.6,.65),CFrame.new(x,10.4,2.8)*CFrame.Angles(0,0,(i-2)*-.32),stone,nil,'WedgePart')
  for j=1,3 do
   part(slab,'AncientGlyph',Vector3.new(.8,.12,.09),CFrame.new(x,9.6+j*.45,2.43)*CFrame.Angles(0,0,(j%2==0 and .35 or -.35)),violet,Enum.Material.Neon)
  end
 end
 for _,g in pairs(groups) do
  for _,p in ipairs(g.model:GetDescendants()) do
   if p:IsA('BasePart') then table.insert(g.parts,{part=p,offset=g.pivot:ToObjectSpace(p.CFrame)}) end
  end
 end
 model.Parent=parent
 local rig={model=model,root=root,groups=groups,origin=cf}
 Warden.pose(rig,0)
 return rig
end
function Warden.pose(rig,t,attack,progress,phase)
 local bob=math.sin(t*1.8)*.16
 local bodyLean=0
 local armAngle=.08+math.sin(t*1.3)*.035
 if attack=='slam' then
  -- Wind up, accelerate down, hold the recovery pose.
  if progress<.6 then armAngle=-2.4*math.sin(progress/.6*math.pi/2)
  elseif progress<.77 then armAngle=-2.4+2.4*((progress-.6)/.17)^2
  else armAngle=.08*((progress-.77)/.23) end
  bodyLean=math.max(0,armAngle)*.16
 elseif attack=='charge' then bodyLean=-.24;armAngle=-.45 end
 local base=rig.origin*CFrame.new(0,bob,0)
 rig.root.CFrame=rig.origin
 for name,g in pairs(rig.groups) do
  local extra=CFrame.identity
  if name=='HammerArm' then extra=CFrame.Angles(armAngle,0,-.08)
  elseif name=='GuardArm' then extra=CFrame.Angles(-.08,0,.12)
  elseif name=='Armor' then extra=CFrame.Angles(bodyLean,0,0)
  elseif name=='Helmet' then extra=CFrame.Angles(0,math.sin(t*.6)*.08,0)
  elseif string.find(name,'OrbitSlab') then
   local i=tonumber(string.sub(name,-1))
   extra=CFrame.new(math.sin(t+i)*.15,math.sin(t*1.5+i)*.45,0)*CFrame.Angles(0,math.sin(t*.8+i)*.16,0)
  elseif name=='LeftGreave' then extra=CFrame.new(0,math.sin(t*1.8+.7)*.12,0)
  elseif name=='RightGreave' then extra=CFrame.new(0,math.sin(t*1.8-.7)*.12,0) end
  local pivot=base*g.pivot*extra
  for _,entry in ipairs(g.parts) do entry.part.CFrame=pivot*entry.offset end
 end
 local core=rig.groups.Armor.model:FindFirstChild('RiftCore')
 if core then
  core.Color=phase==2 and Color3.fromRGB(255,100,198) or violet
  local l=core:FindFirstChildOfClass('PointLight');if l then l.Brightness=1.1+math.sin(t*3)*.25 end
 end
end
return Warden
