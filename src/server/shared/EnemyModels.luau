-- Distinct silhouettes share only their invisible hit anchor.
return function(deps)
 local block=deps.block
 local function make(name,kind,world)
  local m=Instance.new('Model');m.Name=name
  local visualAssets={commander='OriginalGildedHalberdCommander',stalker='KayKitSkeletonWarrior',skitter='KayKitSkeletonRogue',brute='KayKitSkeletonWarriorHeavy',caster='KayKitSkeletonMage',ember='KayKitSkeletonMinionBomber',charger='AshHound'}
  m:SetAttribute('VisualAsset',visualAssets[kind])
  local root=block(m,'Core',Vector3.one,CFrame.identity.Position,Color3.new());root.Transparency=1;root.Position=Vector3.new(0,3,0);m.PrimaryPart=root
  local function p(label,size,position,color,shape,rotation)
   local cf=CFrame.new(position)*(rotation or CFrame.identity)
   local v
   if shape=='wedge'then v=Instance.new('WedgePart');v.Name=label;v.Size=size;v.CFrame=cf;v.Color=color;v.Anchored=true;v.CanCollide=false;v.CanTouch=false;v.CanQuery=false;v.Material=Enum.Material.Slate;v.Parent=m
   else v=block(m,label,size,position,color,Enum.Material.Slate);v.CFrame=cf;if shape=='ball'then local mesh=Instance.new('SpecialMesh');mesh.MeshType=Enum.MeshType.Sphere;mesh.Parent=v end end
   return v
  end
  local function neon(label,size,position,color,shape)local v=p(label,size,position,color,shape);v.Material=Enum.Material.Neon;return v end
  local function limb(a,b,width,color)
   local v=p('Limb',Vector3.new(width,width,(b-a).Magnitude), (a+b)/2,color,'ball');v.CFrame=CFrame.lookAt((a+b)/2,b)
  end
  if kind=='skitter'then
   local green=Color3.fromRGB(91,167,126)
   p('Abdomen',Vector3.new(3,1.8,3.5),Vector3.new(0,2.2,.5),green,'ball')
   p('Head',Vector3.new(2.2,1.3,1.8),Vector3.new(0,2,-1.7),Color3.fromRGB(30,64,57),'ball')
   for _,side in ipairs({-1,1})do
    for j=1,3 do local a=Vector3.new(side*1.1,2.1,j-1.5);local b=Vector3.new(side*(2.1+j*.25),1.6,j*1.15-2.5);limb(a,b,.28,green);limb(b,Vector3.new(b.X+side*.5,.4,b.Z-.3),.18,green)end
    neon('Eye',Vector3.new(.3,.28,.3),Vector3.new(side*.6,2.2,-2.5),Color3.fromRGB(182,255,163),'ball')
    p('Fang',Vector3.new(.3,.6,.8),Vector3.new(side*.4,1.6,-2.6),Color3.fromRGB(214,239,203),'wedge')
   end
  elseif kind=='brute'or kind=='charger'or kind=='commander'then
   local armor=kind=='charger'and Color3.fromRGB(145,56,65)or Color3.fromRGB(73,101,126)
   p('ArmoredShell',Vector3.new(kind=='charger'and 3.2 or 4.6,kind=='charger'and 2.4 or 3,kind=='charger'and 5.8 or 4.8),Vector3.new(0,3,.4),armor,'ball')
   p('Head',Vector3.new(2.1,1.7,2.2),Vector3.new(0,2.3,-2),Color3.fromRGB(36,49,69),'ball')
   for i=-1,1 do p('ShellPlate',Vector3.new(1.5,1,4),Vector3.new(i*1.35,3.9,.3),armor,'wedge',CFrame.Angles(0,0,i*-.25))end
   for _,side in ipairs({-1,1})do
    for _,z in ipairs({-1.2,1.7})do limb(Vector3.new(side*1.4,2.5,z),Vector3.new(side*2.7,.5,z),.6,armor)end
    p('Tusk',Vector3.new(.7,1.6,1.6),Vector3.new(side*1.1,2.7,-2.7),Color3.fromRGB(226,218,184),'wedge',CFrame.Angles(-.5,0,side*.3))
    neon('Eye',Vector3.new(.3,.22,.2),Vector3.new(side*.52,2.6,-3.04),Color3.fromRGB(112,222,255),'ball')
   end
  elseif kind=='caster'then
   local purple=Color3.fromRGB(104,60,141)
   p('Robe',Vector3.new(2.6,3.6,2),Vector3.new(0,3,0),purple,'wedge')
   p('Hood',Vector3.new(2.1,2,1.9),Vector3.new(0,5.25,0),Color3.fromRGB(66,37,96),'ball')
   p('Face',Vector3.new(1.3,1.1,.18),Vector3.new(0,5.2,-.9),Color3.fromRGB(13,15,31),'ball')
   for _,side in ipairs({-1,1})do neon('Eye',Vector3.new(.2,.17,.15),Vector3.new(side*.35,5.35,-1.02),Color3.fromRGB(247,151,255),'ball');p('Sleeve',Vector3.new(.9,1.8,1),Vector3.new(side*1.5,3.6,-.2),purple,'wedge')end
   limb(Vector3.new(1.9,1.1,-.4),Vector3.new(1.9,6,-.4),.2,Color3.fromRGB(155,119,181))
   neon('StaffOrb',Vector3.new(.9,.9,.9),Vector3.new(1.9,6.2,-.4),Color3.fromRGB(214,127,255),'ball')
   for i=1,4 do local a=i*math.pi/2;neon('OrbitShard',Vector3.new(.25,.6,.25),Vector3.new(math.cos(a)*1.8,1.4,math.sin(a)*1.8),Color3.fromRGB(169,112,232),'wedge')end
  elseif kind=='ember'then
   local coal=Color3.fromRGB(79,37,44)
   p('ObsidianShell',Vector3.new(2.8,2.7,2.8),Vector3.new(0,2.5,0),coal,'ball')
   neon('FurnaceCore',Vector3.new(1.7,1.5,.3),Vector3.new(0,2.5,-1.35),Color3.fromRGB(255,106,36),'ball')
   for i=1,6 do local a=i*math.pi/3;p('Spine',Vector3.new(.35,1.2,.6),Vector3.new(math.sin(a)*1.2,3.5,math.cos(a)*1.2),coal,'wedge',CFrame.Angles(math.cos(a)*.5,0,-math.sin(a)*.5))end
   for _,side in ipairs({-1,1})do limb(Vector3.new(side*.8,1.7,.2),Vector3.new(side*1.1,.4,-.2),.5,coal);neon('Eye',Vector3.new(.22,.22,.22),Vector3.new(side*.45,3.1,-1.3),Color3.fromRGB(255,221,135),'ball')end
  else
   local dark=Color3.fromRGB(56,61,80)
   p('Body',Vector3.new(2.3,2.5,1.5),Vector3.new(0,3,0),dark,'wedge')
   p('Mask',Vector3.new(1.7,1.7,1.3),Vector3.new(0,4.8,-.2),Color3.fromRGB(130,135,148),'wedge')
   for _,side in ipairs({-1,1})do
    limb(Vector3.new(side*.55,2.1,0),Vector3.new(side*.8,.5,-.1),.55,dark)
    limb(Vector3.new(side*1.1,3.6,0),Vector3.new(side*1.7,1.8,-.6),.45,dark)
    p('Claw',Vector3.new(.3,.75,.45),Vector3.new(side*1.7,1.45,-.6),Color3.fromRGB(183,187,195),'wedge')
    neon('Eye',Vector3.new(.24,.25,.2),Vector3.new(side*.42,4.9,-.9),Color3.fromRGB(255,118,151),'ball')
   end
  end
  if kind=='charger'then
   for _,side in ipairs({-1,1})do
    p('ChargeHorn',Vector3.new(.45,.7,3.4),Vector3.new(side*.85,3.3,-3),Color3.fromRGB(255,204,151),'wedge',CFrame.Angles(.25,0,side*.1))
   end
   neon('ChargeCrest',Vector3.new(.22,.8,2.8),Vector3.new(0,4.6,-.6),Color3.fromRGB(255,118,83),'wedge')
  end
  m:SetAttribute('EnemyKind',kind);m.Parent=world;return m
 end
 return make
end
