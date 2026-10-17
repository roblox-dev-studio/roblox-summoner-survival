-- A staggered eruption of faceted ice spires, with luminous cores and frost bursts.
return function(deps)
 local Run=game:GetService('RunService');local Debris=game:GetService('Debris')
 local fx=deps.folder;local blue=Color3.fromRGB(55,146,231);local cyan=Color3.fromRGB(112,237,255);local white=Color3.fromRGB(228,255,255)
 local function part(parent,name,size,cf,color)
  local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent;return p
 end
 local function face(parent,a,b,c,color,core)
  if(b-a):Cross(c-a).Magnitude<.0001 then return end
  local ab,ac,bc=b-a,c-a,c-b
  if ab:Dot(ab)>ac:Dot(ac)and ab:Dot(ab)>bc:Dot(bc)then c,a=a,c elseif ac:Dot(ac)>ab:Dot(ab)and ac:Dot(ac)>bc:Dot(bc)then a,b=b,a end
  ab,ac,bc=b-a,c-a,c-b;local right=ac:Cross(ab).Unit;local back=bc.Unit;local up=bc:Cross(right).Unit
  for _,v in ipairs({{b,right,back,math.abs(ab:Dot(back))},{c,-right,-back,math.abs(ac:Dot(back))}})do if v[4]>.005 then
   local p=Instance.new('WedgePart');p.Name=core and'IceLightCore'or'IceFacet';p.Size=Vector3.new(.025,math.abs(ab:Dot(up)),v[4]);p.CFrame=CFrame.fromMatrix((a+v[1])/2,v[2],up,v[3]);p.Material=core and Enum.Material.Neon or Enum.Material.Glass;p.Color=color;p.Transparency=core and .12 or .32;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=parent
  end end
 end
 local function edge(pivot,a,b)
  local x=Instance.new('Attachment');x.Position=a;x.Parent=pivot;local y=Instance.new('Attachment');y.Position=b;y.Parent=pivot
  local beam=Instance.new('Beam');beam.Name='IceLitEdge';beam.Attachment0=x;beam.Attachment1=y;beam.Width0=.045;beam.Width1=.02;beam.FaceCamera=true;beam.LightEmission=1;beam.Color=ColorSequence.new(cyan,white);beam.Transparency=NumberSequence.new(.3);beam.Parent=pivot;return beam
 end
 local function emitter(pivot,texture,color,size)
  local p=Instance.new('ParticleEmitter');p.Texture='rbxasset://textures/particles/'..texture..'_main.dds';p.Rate=0;p.Lifetime=NumberRange.new(.3,.6);p.Speed=NumberRange.new(3,8);p.SpreadAngle=Vector2.new(65,65);p.Color=ColorSequence.new(white,color);p.Size=NumberSequence.new(size,0);p.Transparency=NumberSequence.new(.2,1);p.LightEmission=1;p.Parent=pivot;return p
 end
 local function strike(origin,direction,settings)
  local model=Instance.new('Model');model.Name='GlacialEruption';model.Parent=fx;Debris:AddItem(model,3)
  local frame=CFrame.lookAt(Vector3.new(origin.X,.12,origin.Z),Vector3.new(origin.X,.12,origin.Z)+direction)
  local crystals={}
  for row=1,7 do for flank=0,1 do
   local m=Instance.new('Model');m.Name=flank==0 and'GlacialSpire'or'GlacialShard'
   local pivot=part(m,'Pivot',Vector3.one*.1,CFrame.identity,blue);pivot.Transparency=1;m.PrimaryPart=pivot
   local h=flank==0 and 6.8+row*.5 or 4.2+row*.15;local width=flank==0 and 1.35 or .85
   local tip=Vector3.new((row%2==0 and 1 or -1)*.35,h,-h*.2)
   local rim={}
   for j=1,4 do local a=j*math.pi/2+.3;rim[j]=Vector3.new(math.cos(a)*width,h*.38,math.sin(a)*width-.3)end
   for j=1,4 do
    local nextIndex=j%4+1
    face(m,tip,rim[j],rim[nextIndex],j%2==0 and cyan or blue,false)
    local baseA=Vector3.new(rim[j].X*.7,-.15,rim[j].Z*.7)
    local baseB=Vector3.new(rim[nextIndex].X*.7,-.15,rim[nextIndex].Z*.7)
    face(m,baseA,rim[nextIndex],rim[j],blue,false);face(m,baseA,baseB,rim[nextIndex],blue,false)
    local coreA=Vector3.new(rim[j].X*.38,h*.3,rim[j].Z*.38)
    local coreB=Vector3.new(rim[nextIndex].X*.38,h*.3,rim[nextIndex].Z*.38)
    face(m,tip*.91,coreA,coreB,white,true)
    edge(pivot,rim[j],tip)
   end
   local ground=part(model,'IceBirthEmitter',Vector3.one*.1,CFrame.identity,blue);ground.Transparency=1
   local burst=emitter(ground,'sparkles',cyan,.24)
   local mist=emitter(ground,'smoke',blue,2.8);mist.Lifetime=NumberRange.new(.4,.75);mist.Speed=NumberRange.new(1,3);mist.Transparency=NumberSequence.new(.85,1)
   local light=Instance.new('PointLight');light.Color=cyan;light.Brightness=0;light.Range=flank==0 and 12 or 7;light.Parent=ground
   local flash=part(model,'BirthFlash',Vector3.one*.5,CFrame.new(0,.12,0),white);flash.Shape=Enum.PartType.Ball;flash.Transparency=1
   local x=flank==0 and (row%2==0 and .6 or -.6)or(row%2==0 and -1 or 1)*(settings.width-1.3)
   local target=frame*CFrame.new(x,0,-(row-.5)*settings.range/7)*CFrame.Angles(0,row*.67,0)
   ground.CFrame=target*CFrame.new(0,.2,0);flash.CFrame=ground.CFrame
   m:ScaleTo(.03);m:PivotTo(target);m.Parent=model
   local frost=part(model,'GroundFrost',Vector3.new(3.4,.045,4.2),target*CFrame.new(0,.08,0),cyan);frost.Shape=Enum.PartType.Ball;frost.Transparency=1
   local splinters={}
   for chip=1,2 do
    local shard=Instance.new('WedgePart');shard.Name='IceSplinter';shard.Size=Vector3.new(.18,.6+chip*.18,.35);shard.Color=chip==1 and white or cyan;shard.Material=Enum.Material.Glass;shard.Transparency=1;shard.Anchored=true;shard.CanCollide=false;shard.CanTouch=false;shard.CanQuery=false;shard.CastShadow=false;shard.Parent=model
    local angle=row*1.7+flank*2.4+chip*2.1
    splinters[chip]={p=shard,offset=Vector3.new(math.cos(angle),0,math.sin(angle))*1.5,velocity=Vector3.new(math.cos(angle)*2,4+chip,math.sin(angle)*2),angle=angle}
   end
   local parts={};for _,p in m:GetChildren()do if p:IsA('BasePart')and p.Name~='Pivot'and p.Name~='BirthFlash'then parts[#parts+1]=p end end
   crystals[#crystals+1]={model=m,target=target,height=h,delay=(row-1)*.075,burst=burst,mist=mist,light=light,flash=flash,frost=frost,splinters=splinters,parts=parts,started=false}
  end end
  local serverAnchor
  if settings.anchorName then local runtime=workspace:FindFirstChild('SummonerRuntime');serverAnchor=runtime and runtime:FindFirstChild(settings.anchorName)end
  local t=0;local conn
  conn=Run.RenderStepped:Connect(function(dt)
   if not model.Parent then conn:Disconnect();return end
   if serverAnchor and serverAnchor.Parent then t=math.max(0,(serverAnchor:GetAttribute('Elapsed')or .4)-.4)else t+=dt end
   for _,c in ipairs(crystals)do
    local age=t-c.delay;local growth=1-(1-math.clamp(age/.14,0,1))^3;local fade=math.clamp((age-.75)/.55,0,1)
    if age>=0 and not c.started then c.started=true;c.burst:Emit(18);c.mist:Emit(6)end
    c.model:ScaleTo(math.max(.03,growth*(1-fade*.12)))
    c.model:PivotTo(c.target*CFrame.new(0,-c.height*(1-growth)-fade*1.2,0))
    for _,p in ipairs(c.parts)do p.LocalTransparencyModifier=age<0 and 1 or fade end
    c.light.Brightness=age<0 and 0 or(1-math.clamp(age/.35,0,1))*4
    c.flash.Transparency=age<0 and 1 or math.clamp(age/.16,0,1)
    c.flash.Size=Vector3.new(3.8,.25,3.8)*(1+math.clamp(age,0,.16)*5)
    c.frost.Transparency=age<0 and 1 or .82+fade*.18
    for _,chip in ipairs(c.splinters)do
     local u=math.max(0,age);local offset=chip.offset+chip.velocity*u-Vector3.new(0,6*u*u,0)
     offset=Vector3.new(offset.X,math.max(.2,offset.Y),offset.Z)
     chip.p.CFrame=c.target*CFrame.new(offset)*CFrame.Angles(u*3,chip.angle+u*2,.3)
     chip.p.Transparency=age<0 and 1 or .25+math.clamp((age-.35)/.65,0,1)*.75
    end
   end
   if t>=2 then conn:Disconnect();model:Destroy()end
  end)
 end
 return {Strike=strike}
end
