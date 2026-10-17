-- Cethiel/Drummyfish CC0 geometry + original Collada animation tracks.
-- CPU skinning of 633 vertices keeps the complete original welded silhouette.
local folder=script.Parent.dragon
local geometry=require(folder.Geometry)
local skeleton=require(folder.Rig)
local Mesh={}
local function cf(v)return CFrame.new(table.unpack(v))end
local armature=cf(skeleton.armature)
local bones={};local boneNames={}
for _,b in ipairs(skeleton.bones)do bones[#bones+1]={index=b.index,name=b.name,parent=b.parent,rest=cf(b.rest),inverse=cf(b.inverse)};boneNames[b.index]=b.name end
local clips={}
for name,module in pairs({idle=folder.Idle,walk=folder.Walk,attack=folder.Attack,die=folder.Die})do
 local source=require(module);local tracks={}
 for index,v in pairs(source.tracks)do
  local poses={};for _,p in ipairs(v.poses)do table.insert(poses,cf(p))end
  tracks[tonumber(index)]={times=v.times,poses=poses}
 end
 clips[name]={duration=source.duration,tracks=tracks}
end
local positions={};for _,v in ipairs(geometry.positions)do table.insert(positions,Vector3.new(table.unpack(v)))end
local function sample(track,time)
 local times=track.times
 for i=1,#times-1 do if time<=times[i+1]then return track.poses[i]:Lerp(track.poses[i+1],math.clamp((time-times[i])/math.max(.0001,times[i+1]-times[i]),0,1))end end
 return track.poses[#times]
end
function Mesh.create(parent)
 local asset=game:GetService('AssetService')
 local editable=asset:CreateEditableMesh();assert(editable,'Editable mesh memory budget exhausted')
 local ids={}
 for _,p in ipairs(positions)do table.insert(ids,editable:AddVertex(p))end
 for i,tri in ipairs(geometry.triangles)do
  local face=editable:AddTriangle(ids[tri[1]],ids[tri[2]],ids[tri[3]])
  local colors={}
  for j=1,3 do local rgb=geometry.colors[(i-1)*3+j];colors[j]=editable:AddColor(Color3.fromRGB(rgb[1],rgb[2],rgb[3]),1)end
  editable:SetFaceColors(face,colors)
  if i%250==0 then task.wait()end
 end
 local part=asset:CreateMeshPartAsync(Content.fromObject(editable))
 part.Name='CethielDragonMesh';part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.DoubleSided=true;part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic;part.Parent=parent
 local rig={mesh=editable,part=part,ids=ids,previous={},center=editable:GetCenter()}
 Mesh.pose(rig,CFrame.identity,0,'idle',0)
 return rig
end
function Mesh.pose(rig,origin,time,mode,progress,gaitTime)
 local clip=clips[(mode=='walk'and'walk')or(mode=='breath'or mode=='eruption'or mode=='roar'or mode=='airBreath')and'attack'or'idle']
 local playTime=(mode=='breath'or mode=='eruption'or mode=='roar'or mode=='airBreath')and math.clamp(progress or 0,0,1)*clip.duration or (mode=='walk'and(gaitTime or time)or time)%clip.duration
 local targetFlight=(mode=='fly'or mode=='airBreath')and 1 or(mode=='dive'and .8 or 0)
 rig.flight=(rig.flight or 0)+(targetFlight-(rig.flight or 0))*.18
 local tailTarget=0
 if mode=='tailWindup'then tailTarget=.35*(progress or 0)
 elseif mode=='tail'then local p=progress or 0;tailTarget=.35*(1-p)-.45*math.sin(p*math.pi)end
 rig.tailAngle=(rig.tailAngle or 0)+(tailTarget-(rig.tailAngle or 0))*.3
 local global,skin,wingPivot={},{},{}
 local tailBase,tailAxis
 for _,b in ipairs(bones)do
  local track=clip.tracks[b.index]
  local pose=track and sample(track,playTime)or b.rest
  if rig.previous[b.index]then pose=rig.previous[b.index]:Lerp(pose,.45)end
  rig.previous[b.index]=pose
  local parent=b.parent==0 and armature or global[b.parent]
  local g=parent*pose
  if rig.flight>.001 and string.find(b.name,'wing_')then
   local side=string.find(b.name,'_L$')and 1 or -1
   local beat=math.sin(time*5.5)
   local angle=(string.find(b.name,'upper')and(-1.85+beat*.25)or(beat*.45))*side*rig.flight
   if mode=='dive'then angle*=.8 end
   local pivot=g.Position;g=CFrame.new(pivot)*CFrame.Angles(0,0,angle)*CFrame.new(-pivot)*g
  end
  if rig.flight>.001 and string.find(b.name,'leg_')and string.find(b.name,'upper')then
   local pivot=g.Position;g=CFrame.new(pivot)*CFrame.Angles(-.55*rig.flight,0,0)*CFrame.new(-pivot)*g
  elseif math.abs(rig.tailAngle)>.001 and(string.find(b.name,'^tail')or b.name=='back2')then
   local weight=b.name=='back2'and .25 or(b.name=='tail1'and .8 or(b.name=='tail2'and .45 or .25))
   local angle=rig.tailAngle*weight
   local pivot=g.Position;g=CFrame.new(pivot)*CFrame.Angles(0,angle,0)*CFrame.new(-pivot)*g
  end
  if string.find(b.name,'wing_lower')then wingPivot[b.index]=g.Position
  elseif string.find(b.name,'wing_upper')then wingPivot[b.index]=wingPivot[b.parent]end
  if b.name=='tail1'then tailBase=g.Position elseif b.name=='tail2'and tailBase then tailAxis=(g.Position-tailBase).Unit end
  global[b.index]=g;skin[b.index]=g*b.inverse
 end
 for i,p in ipairs(positions)do
  local result=Vector3.zero
  for _,w in ipairs(geometry.weights[i])do
   local point=skin[w[1]]*p;local pivot=wingPivot[w[1]]
   if pivot then
    local offset=point-pivot
    -- Extend span more than chord, retaining the thin membrane and body proportions.
    offset=Vector3.new(offset.X*1.9,offset.Y*1.5,offset.Z*1.8)
    point=pivot+offset*(1+rig.flight*.7)
   end
   if tailBase and tailAxis and string.find(boneNames[w[1]],'^tail')then point+=tailAxis*(point-tailBase):Dot(tailAxis)*1.0 end
   result+=point*w[2]
  end
  rig.mesh:SetPosition(rig.ids[i],result)
 end
 local lean=mode=='dive'and -math.sin((progress or 0)*math.pi)*math.rad(23)or((mode=='fly'or mode=='airBreath')and -math.rad(7)or 0)
 local landing=mode=='land'and -.9*math.sin((progress or 0)*math.pi)or 0
 local visualOrigin=origin*CFrame.Angles(lean,0,(rig.bank or 0)*rig.flight)*CFrame.new(0,landing,0)
 rig.part.CFrame=visualOrigin*CFrame.new(0,skeleton.groundOffset,0)
 rig.jaw=visualOrigin*CFrame.new(0,skeleton.groundOffset,0)*global[7]
 if rig.part.Parent then rig.part.Parent:SetAttribute('DragonMouth',rig.jaw.Position)end
end
function Mesh.destroy(rig)
 rig.part:Destroy();rig.mesh:Destroy()
end
return Mesh
