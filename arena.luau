-- Ashen Crown courtyard. Reproducible, original static environment; run in Edit.
assert(not game:GetService('RunService'):IsRunning(),'Stop Play before rebuilding the arena')
local Lighting=game:GetService('Lighting')
local previous=workspace:FindFirstChild('SummonerArena')
assert(not workspace:FindFirstChild('SummonerArenaBuilding'),'An arena build is already in progress')
local arena=Instance.new('Folder');arena.Name='SummonerArenaBuilding';arena.Parent=workspace
local rng=Random.new(72418)
local ENABLE_INTERIOR_DEBRIS=true -- Independent courtyard rubble; never removes wall blocks.
local stone=Color3.fromRGB(74,83,92);local pale=Color3.fromRGB(106,113,117)
local soot=Color3.fromRGB(40,46,54);local moss=Color3.fromRGB(57,70,67)
local cyan=Color3.fromRGB(92,183,178);local ember=Color3.fromRGB(239,132,65)
local section,batch,count,total
local function flush()
 if batch and count>0 then batch.Parent=section;task.wait()end
 batch=Instance.new('Folder');batch.Name='Masonry';count=0
end
local function group(name)
 if batch then flush();batch:Destroy()end
 section=Instance.new('Folder');section.Name=name;section.Parent=arena
 batch=Instance.new('Folder');batch.Name='Masonry';count=0
end
local function part(name,size,cf,color,material,shape,solid)
 if count>=100 then flush()end
 local p=Instance.new(shape=='wedge'and'WedgePart'or'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=material or Enum.Material.Slate
 p.Anchored=true;p.CanCollide=solid==true;p.CanTouch=false;p.CanQuery=solid==true;p.CastShadow=size.Y>.3
 p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape=='ball'then local m=Instance.new('SpecialMesh');m.MeshType=Enum.MeshType.Sphere;m.Parent=p end
 p.Parent=batch;count+=1;total=(total or 0)+1;return p
end
local function beam(name,a,b,width,color,material)
 return part(name,Vector3.new(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,material)
end
local function ring(name,center,radius,segments,width,color,material)
 for i=1,segments do local a=(i-1)*math.pi*2/segments;local b=i*math.pi*2/segments
  beam(name,center+Vector3.new(math.cos(a),0,math.sin(a))*radius,center+Vector3.new(math.cos(b),0,math.sin(b))*radius,width,color,material)
 end
end
local function brazier(frame,ghost)
 part('BrazierFoot',Vector3.new(3,.55,3),frame*CFrame.new(0,.3,0),soot)
 part('BrazierStem',Vector3.new(1,2.3,1),frame*CFrame.new(0,1.6,0),stone)
 part('BrazierBowl',Vector3.new(2.6,.7,2.6),frame*CFrame.new(0,2.8,0),soot,Enum.Material.Metal,'wedge')
 local fire=part('BrazierGlow',Vector3.new(1.2,.6,1.2),frame*CFrame.new(0,3.18,0),ghost and cyan or ember,Enum.Material.Neon,'ball')
 local light=Instance.new('PointLight');light.Color=fire.Color;light.Range=15;light.Brightness=1.1;light.Shadows=false;light.Parent=fire
 local sparks=Instance.new('ParticleEmitter');sparks.Name='AshSparks';sparks.Texture='rbxasset://textures/particles/sparkles_main.dds';sparks.Color=ColorSequence.new(fire.Color);sparks.LightEmission=.8;sparks.Rate=3;sparks.Lifetime=NumberRange.new(.6,1.4);sparks.Speed=NumberRange.new(1,2.5);sparks.SpreadAngle=Vector2.new(15,15);sparks.Size=NumberSequence.new(.14,0);sparks.Transparency=NumberSequence.new(.2,1);sparks.Parent=fire
end
local function rubble(frame,amount)
 for _=1,amount do
  local x,z=rng:NextNumber(-8,8),rng:NextNumber(-5,5);local h=rng:NextNumber(.7,2.5)
  part('FallenMasonry',Vector3.new(rng:NextNumber(1.5,4),h,rng:NextNumber(1.3,3.6)),frame*CFrame.new(x,h*.35,z)*CFrame.Angles(rng:NextNumber(-.3,.3),rng:NextNumber(0,6.28),rng:NextNumber(-.25,.25)),stone:Lerp(soot,rng:NextNumber(0,.5)))
 end
end
local function wall(frame,length,height)
 part('WallBacking',Vector3.new(length,height+1.4,3.8),frame*CFrame.new(0,height/2-.7,0),stone)
 for row=0,2 do
  local n=math.floor(length/7)
  for j=1,n do
   do
    local h=height/3;part('WallAshlar',Vector3.new(length/n-.18,h-.13,4.4),frame*CFrame.new((j-.5)*length/n-length/2,(row+.5)*h,0),stone:Lerp(soot,rng:NextNumber(.1,.38)))
   end
  end
 end
 part('WallCornice',Vector3.new(length, .65,5.2),frame*CFrame.new(0,height+.1,0),pale)
 for x=-length/2+2,length/2-1,5 do
  if rng:NextNumber()>.18 then part('BrokenMerlon',Vector3.new(2.9,rng:NextNumber(2,4.2),4.7),frame*CFrame.new(x,height+1.4,0),stone)end
 end
end
local function tower(frame,height,ruined)
 for row=0,math.floor(height/4)-1 do
  for side=0,3 do
   do -- Keep tower bodies closed; weathering belongs above the parapet.
    part('TowerCourse',Vector3.new(13,3.85,3),frame*CFrame.Angles(0,side*math.pi/2,0)*CFrame.new(0,row*4+2,-5.3),row%3==0 and stone:Lerp(pale,.22)or stone)
   end
  end
 end
 local top=math.floor(height/4)*4
 for side=0,3 do for j=-1,1 do
  if not(ruined and side==1)then part('TowerCrenellation',Vector3.new(3,3.7,3.4),frame*CFrame.Angles(0,side*math.pi/2,0)*CFrame.new(j*4.6,top+1.5,-5.3),soot)end
 end end
 for _,y in ipairs({8,18})do if y<height-3 then
  part('TowerWindow',Vector3.new(1.4,3.8,.1),frame*CFrame.new(0,y,-6.85),Color3.fromRGB(20,28,34))
 end end
end
local function arch(frame,radius,spring,depth)
 for _,side in ipairs({-1,1})do
  for y=1,spring,3 do part('ArchPier',Vector3.new(3.6,2.9,depth),frame*CFrame.new(side*(radius+1.3),y,0),pale)end
 end
 for i=0,12 do
  local a=i*math.pi/12
  part('ArchVoussoir',Vector3.new(3.05,3.8,depth),frame*CFrame.new(math.cos(a)*radius,spring+math.sin(a)*radius,0)*CFrame.Angles(0,0,a-math.pi/2),i==6 and soot or pale)
 end
end

group('BattlePlaza')
part('ArenaFloor',Vector3.new(186,3,186),CFrame.new(0,-1.5,0),Color3.fromRGB(55,63,69),Enum.Material.Slate,nil,true)
part('OuterEarth',Vector3.new(470,5,470),CFrame.new(0,-3.6,0),Color3.fromRGB(45,54,54),Enum.Material.Ground)
for x=-9,9 do for z=-9,9 do
 local shade=rng:NextNumber();local color=Color3.fromRGB(66+shade*13,75+shade*13,81+shade*13)
 part('CourtyardPaver',Vector3.new(9.45,.09,9.45),CFrame.new(x*9.65,.045,z*9.65),color,Enum.Material.Cobblestone)
end end
-- Four worn approaches and a quiet stone medallion, all flat and nonblocking.
for side=0,3 do
 local frame=CFrame.Angles(0,side*math.pi/2,0)
 for i=3,10 do
  part('ProcessionalStone',Vector3.new(8.8,.12,6.8),frame*CFrame.new(0,.08,-i*8),stone:Lerp(pale,.24),Enum.Material.Limestone)
  for _,s in ipairs({-1,1})do part('ProcessionalBorder',Vector3.new(.27,.13,7.5),frame*CFrame.new(s*5,.09,-i*8),pale)end
 end
end
ring('MedallionInlay',Vector3.new(0,.17,0),17,64,.23,pale,Enum.Material.Limestone)
ring('MedallionInlay',Vector3.new(0,.17,0),14.5,56,.16,soot)
ring('FadedRune',Vector3.new(0,.185,0),10.5,48,.085,Color3.fromRGB(65,113,113),Enum.Material.Neon)
for side=0,7 do
 local f=CFrame.Angles(0,side*math.pi/4,0)
 part('CompassPetal',Vector3.new(1.4,.13,6),f*CFrame.new(0,.1,-5.4),pale,Enum.Material.Limestone,'wedge')
 part('RuneMarker',Vector3.new(.35,.09,1.4),f*CFrame.new(0,.15,-12.5),cyan,Enum.Material.Neon)
end
for _=1,22 do
 local x,z=rng:NextNumber(-78,78),rng:NextNumber(-78,78)
 if x*x+z*z>600 then
  local a=rng:NextNumber(0,6.28);local f=CFrame.new(x,.112,z)*CFrame.Angles(0,a,0)
  part('PavingFracture',Vector3.new(.065,.015,rng:NextNumber(2,5)),f,soot)
  part('PavingFracture',Vector3.new(.05,.015,2.2),f*CFrame.new(.6,0,1.7)*CFrame.Angles(0,.6,0),soot)
 end
end

group('BrokenRamparts')
for _,side in ipairs({-1,1})do
 wall(CFrame.new(side*59,0,-100),64,13)
 wall(CFrame.new(side*60,0,100),58,10)
 wall(CFrame.new(side*100,0,-53)*CFrame.Angles(0,math.pi/2,0),78,12)
 wall(CFrame.new(side*100,0,7)*CFrame.Angles(0,math.pi/2,0),48,12)
 wall(CFrame.new(side*100,0,61)*CFrame.Angles(0,math.pi/2,0),66,9)
 for _,z in ipairs({-95,95})do tower(CFrame.new(side*96,0,z),side*z<0 and 28 or 20,true)end
end
wall(CFrame.new(0,0,100),62.4,10) -- Close the unframed southern gap; keep the northern arch.
-- Collision boundary matches the existing 186-stud arena, scenery stays beyond it.
for _,edge in ipairs({{0,94,190,4},{0,-94,190,4},{94,0,4,190},{-94,0,4,190}})do
 local p=part('InvisibleBoundary',Vector3.new(edge[3],30,edge[4]),CFrame.new(edge[1],12,edge[2]),soot,nil,nil,true);p.Transparency=1
end

group('CommandersGate')
local gate=CFrame.new(0,0,-105)
arch(gate,11,12,6)
for _,side in ipairs({-1,1})do
 tower(gate*CFrame.new(side*20,0,-1),32,side==1)
 part('GateButtress',Vector3.new(5,10,9),gate*CFrame.new(side*13.8,4.8,3.8),soot,nil,'wedge')
 brazier(CFrame.new(side*22,0,-86),false)
 for y=4,17,4 do part('GateIronBand',Vector3.new(8,.5,.5),gate*CFrame.new(side*20,y,6.9),soot,Enum.Material.Metal)end
 -- Torn royal standards hang outside the combat area.
 beam('BannerPole',Vector3.new(side*18,26,-96),Vector3.new(side*18,13,-96),.22,soot,Enum.Material.Metal)
 part('TatteredBanner',Vector3.new(4,8,.15),CFrame.new(side*18,20,-95.9),Color3.fromRGB(78,37,47),Enum.Material.Fabric,'wedge')
end
part('GateThreshold',Vector3.new(22,.25,19),CFrame.new(0,.08,-101),pale,Enum.Material.Cobblestone)
for i=-4,4 do part('FallenPortcullis',Vector3.new(.25,.3,13),gate*CFrame.new(i*1.8,.25,-5)*CFrame.Angles(0,.12,0),soot,Enum.Material.Metal)end
rubble(CFrame.new(30,0,-97),12)
for i=1,3 do
 part('DragonClawScorch',Vector3.new(.5,.06,14),CFrame.new(35+i*2,.16,-76)*CFrame.Angles(0,-.65,0),Color3.fromRGB(33,36,40))
end

group('Graveyard')
part('GraveyardEarth',Vector3.new(53,.18,72),CFrame.new(-123,-.03,-7),moss,Enum.Material.Ground)
for row=0,3 do for col=0,2 do
 local f=CFrame.new(-108-col*12,0,-30+row*16)*CFrame.Angles(0,rng:NextNumber(-.22,.22),rng:NextNumber(-.1,.1))
 part('GraveSlab',Vector3.new(5.6,.3,8.2),f*CFrame.new(0,.18,3),soot)
 part('Headstone',Vector3.new(3.6,3.8,.7),f*CFrame.new(0,2,-1.2),stone,Enum.Material.Limestone)
 part('HeadstoneCrown',Vector3.new(3.6,1.6,.7),f*CFrame.new(0,4.05,-1.2),stone,Enum.Material.Limestone,'ball')
 part('GraveInscription',Vector3.new(.24,1.6,.08),f*CFrame.new(0,2.7,-.8),pale)
 part('GraveInscription',Vector3.new(1.1,.24,.08),f*CFrame.new(0,2.95,-.8),pale)
end end
local crypt=CFrame.new(-126,0,-63)
part('CryptFoundation',Vector3.new(24,1.2,18),crypt*CFrame.new(0,.5,0),soot)
part('CryptDarkness',Vector3.new(10,10,.2),crypt*CFrame.new(0,5,1.8),Color3.fromRGB(15,23,29))
arch(crypt*CFrame.new(0,0,2),4.6,5,4)
for _,side in ipairs({-1,1})do part('CryptSide',Vector3.new(5,10,15),crypt*CFrame.new(side*9,5,-3),stone)end
part('CryptLintel',Vector3.new(24,2.3,17),crypt*CFrame.new(0,11,-3),soot)
part('CryptRoof',Vector3.new(26,4.5,19),crypt*CFrame.new(0,13.5,-3)*CFrame.Angles(0,0,math.pi),stone,nil,'wedge')
brazier(CFrame.new(-103,0,-20),true);brazier(CFrame.new(-105,0,26),true)
rubble(CFrame.new(-99,0,-45),8)

group('BurntChapel')
local chapel=CFrame.new(123,0,2)*CFrame.Angles(0,math.pi/2,0)
part('ChapelPlinth',Vector3.new(29,1.4,44),chapel*CFrame.new(0,.4,0),soot)
arch(chapel*CFrame.new(0,0,-18),6.5,8,3.4)
for _,side in ipairs({-1,1})do
 for i=0,3 do
  part('ChapelColumn',Vector3.new(2.4,12+i%2*4,3),chapel*CFrame.new(side*12,6,-13+i*9),stone)
  part('ChapelFlyingButtress',Vector3.new(3.5,7,5),chapel*CFrame.new(side*14.3,3.4,-13+i*9),soot,nil,'wedge')
 end
 for i=0,2 do part('ChapelBrokenWall',Vector3.new(2,5+i%2*3,8),chapel*CFrame.new(side*11.5,2.5,-9+i*11),stone)end
end
part('ChapelAltar',Vector3.new(8,3.6,4),chapel*CFrame.new(0,2,13),pale)
beam('ChapelBurntRafter',chapel:PointToWorldSpace(Vector3.new(-10,12,10)),chapel:PointToWorldSpace(Vector3.new(7,1,-8)),.9,Color3.fromRGB(31,29,30),Enum.Material.Wood)
rubble(chapel*CFrame.new(0,1,0),18)
brazier(CFrame.new(101,0,22),false)

group('DistantKingdom')
-- Northern skyline, with the southern lobby at z=150 deliberately unobstructed.
for _,x in ipairs({-54,-27,0,27,54})do
 tower(CFrame.new(x,-2,-174),x==0 and 59 or 32+math.abs(x)*.18,x~=0)
 if x==0 then
  part('KeepRoof',Vector3.new(18,13,18),CFrame.new(0,64,-174),soot,nil,'wedge')
 else wall(CFrame.new(x+10,-2,-177),22,20)end
end
for i=1,11 do
 local a=-math.pi+(.2+i/12*2.7);local radius=280+rng:NextNumber(-12,20)
 local x,z=math.cos(a)*radius,math.sin(a)*radius;local h=rng:NextNumber(28,65)
 part('DistantRidge',Vector3.new(rng:NextNumber(85,130),h,rng:NextNumber(75,110)),CFrame.new(x,-h*.4,z)*CFrame.Angles(0,a,0),Color3.fromRGB(47,61,69),Enum.Material.Rock,'ball')
end
for i=1,14 do
 local side=i%2==0 and 1 or -1;local x=side*rng:NextNumber(145,194);local z=rng:NextNumber(-115,82);local h=rng:NextNumber(9,19)
 local base=Vector3.new(x,0,z);local tip=base+Vector3.new(side*.7,h,1)
 beam('CharredTrunk',base,tip,.9,Color3.fromRGB(36,37,40),Enum.Material.Wood)
 for j=1,3 do
  local from=base:Lerp(tip,.4+j*.12);local to=from+Vector3.new((j%2==0 and -1 or 1)*rng:NextNumber(3,6),rng:NextNumber(2,5),rng:NextNumber(-2,3))
  beam('CharredBranch',from,to,.38,soot,Enum.Material.Wood)
  beam('CharredTwig',to,to+Vector3.new(j%2==0 and 1 or -1,2.5,-1),.2,soot,Enum.Material.Wood)
 end
end
if ENABLE_INTERIOR_DEBRIS then
 group('InteriorDebris')
 section:SetAttribute('Experimental',true)
 local debrisRng=Random.new(3019)
 for _,at in ipairs({{-53,-47,.2},{56,-44,-.35},{-55,42,-.2}})do
  local f=CFrame.new(at[1],0,at[2])*CFrame.Angles(0,at[3],0)
  part('CourtyardBrokenSlab',Vector3.new(3.4,.45,2.5),f*CFrame.new(0,.3,0)*CFrame.Angles(.08,.3,.13),stone,Enum.Material.Limestone)
  part('CourtyardStoneFragment',Vector3.new(1.9,.95,1.3),f*CFrame.new(1.3,.55,.5)*CFrame.Angles(.1,-.5,.15),pale,nil,'wedge')
  for i=1,6 do
   local h=debrisRng:NextNumber(.22,.65)
   part('CourtyardRubble',Vector3.new(debrisRng:NextNumber(.6,1.6),h,debrisRng:NextNumber(.6,1.3)),f*CFrame.new(debrisRng:NextNumber(-3.4,3.4),h*.5+.1,debrisRng:NextNumber(-2.8,2.8))*CFrame.Angles(.1,debrisRng:NextNumber(0,6.28),-.12),i%2==0 and soot or stone)
  end
 end
end
flush();batch:Destroy()
local base=workspace:FindFirstChild('Baseplate');if base then base.Transparency=1;base.CanCollide=false end
local spawn=workspace:FindFirstChildOfClass('SpawnLocation');if spawn then spawn.Position=Vector3.new(0,.5,0);spawn.Transparency=1;spawn.CanCollide=false;spawn.Neutral=true;spawn.Duration=0 end
if previous then previous:Destroy()end
arena.Name='SummonerArena';arena:SetAttribute('Theme','AshenCrownCourtyard');arena:SetAttribute('MapRevision',4);arena:SetAttribute('PartCount',total)
Lighting.ClockTime=16;Lighting.Brightness=2.4
Lighting.Ambient=Color3.fromRGB(134,143,154);Lighting.OutdoorAmbient=Color3.fromRGB(151,158,166)
Lighting.FogColor=Color3.fromRGB(98,121,137);Lighting.FogStart=155;Lighting.FogEnd=480
-- Reuse the previous installer atmosphere, without accumulating another on each rebuild.
local atmosphere=Lighting:FindFirstChild('SummonerAtmosphere')
if not atmosphere then
 for _,v in ipairs(Lighting:GetChildren())do if v:IsA('Atmosphere')and math.abs(v.Density-.22)<.001 then atmosphere=v;break end end
end
if not atmosphere then atmosphere=Instance.new('Atmosphere');atmosphere.Parent=Lighting end
atmosphere.Name='SummonerAtmosphere';atmosphere.Density=.23;atmosphere.Offset=.1;atmosphere.Color=Color3.fromRGB(177,195,206);atmosphere.Decay=Color3.fromRGB(84,101,124);atmosphere.Glare=.12;atmosphere.Haze=1.3
local grade=Lighting:FindFirstChild('SummonerMapGrade')or Instance.new('ColorCorrectionEffect');grade.Name='SummonerMapGrade';grade.Brightness=.015;grade.Contrast=.03;grade.Saturation=-.08;grade.TintColor=Color3.fromRGB(241,246,255);grade.Parent=Lighting
workspace.CurrentCamera.CFrame=CFrame.lookAt(Vector3.new(125,115,135),Vector3.new(0,2,-20))
return 'Ashen Crown courtyard built: '..tostring(total)..' parts'
