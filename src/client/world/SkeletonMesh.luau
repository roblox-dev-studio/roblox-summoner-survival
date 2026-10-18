-- KayKit CC0 native skinning. One immutable EditableMesh shared by all instances.
local profiles=require(script.Parent.EnemyProfiles)
local gear=require(script.Parent.EnemyGear)
local assets={}
local function loadAsset(folder)
local geometry=require(folder.Geometry)
local source=require(folder.Rig)
local function cf(v)return CFrame.new(table.unpack(v))end
local center=Vector3.new(table.unpack(source.center))
local bones={}
for i,b in ipairs(source.bones)do bones[i]={name=b.name,parent=b.parent,bind=cf(b.bind),rest=cf(b.rest)}end
local active={}
for _,weights in ipairs(geometry.weights)do for _,w in ipairs(weights)do local i=w[1];while i>0 and not active[i]do active[i]=true;i=bones[i].parent end end end
local clips={}
local modules={idle=folder.Idle,walk=folder.Walk,attack=folder.Attack}
if folder:FindFirstChild('Armed')then modules.armed=folder.Armed end
for _,name in ipairs({'Sweep','Guard','Bash','Sit'})do if folder:FindFirstChild(name)then modules[string.lower(name)]=folder[name]end end
if folder:FindFirstChild('Prepare')then modules.prepare=folder.Prepare end
for name,module in pairs(modules)do
 local c=require(module);local frames={}
 for f,poses in ipairs(c.frames)do frames[f]={};for i,p in ipairs(poses)do frames[f][i]=bones[i].rest:ToObjectSpace(cf(p))end end
 clips[name]={duration=c.duration,frames=frames}
end
local state={users=0}
local prototype,editable,building,failure
local function build()
 local asset=game:GetService('AssetService');editable=asset:CreateEditableMesh();assert(editable,'EditableMesh memory budget exhausted')
 local ids,boneIds,colorIds,normalIds={},{},{},{}
 local normalCache={};local uv=editable:AddUV(Vector2.zero)
 for i,b in ipairs(bones)do
  local properties={Name=b.name,CFrame=b.bind,Virtual=false};if b.parent>0 then properties.ParentId=boneIds[b.parent]end
  boneIds[i]=editable:AddBone(properties)
 end
 for i,p in ipairs(geometry.positions)do
  ids[i]=editable:AddVertex(Vector3.new(table.unpack(p)))
  local refs,weights={},{}
  for _,w in ipairs(geometry.weights[i])do table.insert(refs,boneIds[w[1]]);table.insert(weights,w[2])end
  editable:SetVertexBones(ids[i],refs);editable:SetVertexBoneWeights(ids[i],weights)
  local rgb=geometry.colors[i];local key=table.concat(rgb,',')
  if not colorIds[key]then colorIds[key]=editable:AddColor(Color3.fromRGB(table.unpack(rgb)),1)end
  colorIds[i]=colorIds[key];local normal=geometry.normals[i];local normalKey=string.format('%.5f,%.5f,%.5f',normal[1],normal[2],normal[3]);if not normalCache[normalKey]then normalCache[normalKey]=editable:AddNormal(Vector3.new(table.unpack(normal)))end;normalIds[i]=normalCache[normalKey]
 end
 for i,tri in ipairs(geometry.triangles)do
  local face=editable:AddTriangle(ids[tri[1]],ids[tri[2]],ids[tri[3]])
  editable:SetFaceColors(face,{colorIds[tri[1]],colorIds[tri[2]],colorIds[tri[3]]})
  editable:SetFaceNormals(face,{normalIds[tri[1]],normalIds[tri[2]],normalIds[tri[3]]});editable:SetFaceUVs(face,{uv,uv,uv})
  if i%400==0 then task.wait()end
 end
 editable:RemoveUnused()
 local fixed=asset:CreateEditableMeshAsync(Content.fromObject(editable),{FixedSize=true});assert(fixed,'Fixed mesh memory budget exhausted');editable:Destroy();editable=fixed
 prototype=asset:CreateMeshPartAsync(Content.fromObject(editable))
 prototype.Name='KayKitSkeleton';prototype.Anchored=true;prototype.CanCollide=false;prototype.CanTouch=false;prototype.CanQuery=false;prototype.DoubleSided=true;prototype.Material=Enum.Material.SmoothPlastic;prototype.Color=Color3.new(1,1,1)
end
function state.create(model)
 if not prototype and not failure then
  if building then repeat task.wait()until not building
  else
   building=true;local ok,err=pcall(build);building=false
   if not ok then failure=tostring(err);if prototype then prototype:Destroy();prototype=nil end;if editable then editable:Destroy();editable=nil end;warn('[SkeletonMesh] '..failure)end
  end
 end
 if failure then model:SetAttribute('SkeletonMeshStatus','Failed');return nil end
 if not model.Parent then return nil end
 local profile=profiles[model:GetAttribute('EnemyKind')]or profiles.stalker
 local part=prototype:Clone();local scale=model:GetScale()*profile.size;part.Size=prototype.Size*scale
 local instances,byName={},{}
 for i,b in ipairs(bones)do
  local v=Instance.new('Bone');v.Name=b.name
  local localFrame=b.parent>0 and bones[b.parent].bind:ToObjectSpace(b.bind)or b.bind
  v.CFrame=localFrame.Rotation+localFrame.Position*scale
  v.Parent=b.parent>0 and instances[b.parent]or part;instances[i]=v;byName[b.name]=v
 end
 local rig={part=part,bones=instances,byName=byName,scale=scale,model=model,hidden={},asset=state,profile=profile,stride=profile.stride}
 for _,v in ipairs(model:GetDescendants())do
  if v:IsA('BasePart')and v.Name~='Core'and v.Name~='EliteCrown'and v.Name~='ChargeWarning'and v.Name~='EnemyBlastWarning'then rig.hidden[v]=v.LocalTransparencyModifier;v.LocalTransparencyModifier=1 end
 end
 part.Parent=model;state.users+=1;state.pose(rig,model:GetPivot(),0,'idle')
 gear.create(rig,profile)
 if not model.Parent then state.destroy(rig);return nil end
 state.pose(rig,model:GetPivot(),0,'idle');model:SetAttribute('SkeletonMeshStatus','Ready');model:SetAttribute('VisualProfile',profile.folder);return rig
end
function state.clip(rig,mode)
 if mode=='attack'then
  if rig.profile.attack then mode=rig.profile.attack
  elseif rig.model:GetAttribute('EnemyKind')=='stalker'and rig.model:GetAttribute('Elite')then mode='armed'end
 end
 return clips[mode]or clips.idle
end
function state.pose(rig,origin,time,mode)
 local clip=state.clip(rig,mode)
 local t=(mode=='attack'or mode=='prepare'or mode=='sweep'or mode=='bash'or mode=='guard')and math.min(time,clip.duration)or time%clip.duration
 local position=t/clip.duration*(#clip.frames-1);local first=math.min(math.floor(position)+1,#clip.frames);local second=math.min(first+1,#clip.frames);local alpha=position-math.floor(position)
 for i,b in ipairs(rig.bones)do
  if active[i]then
   local transform=clip.frames[first][i]:Lerp(clip.frames[second][i],alpha)
   if rig.profile.mounted and clips.sit and(b.Name:find('leg')or b.Name:find('foot'))then transform=clips.sit.frames[1][i]end
   b.Transform=transform.Rotation+transform.Position*rig.scale
  end
 end
 state.place(rig,origin,time)
 if rig.model:GetAttribute('SkeletonMotion')~=mode then rig.model:SetAttribute('SkeletonMotion',mode)end
end
function state.place(rig,origin,time)
 rig.origin=origin;rig.part.CFrame=origin*CFrame.new(center*rig.scale-Vector3.new(0,3,0));gear.pose(rig,time or 0,rig.charging)
end
function state.destroy(rig)
 if rig.destroyed then return end;rig.destroyed=true;state.users-=1
 for v,previous in pairs(rig.hidden)do if v.Parent then v.LocalTransparencyModifier=previous end end
 gear.destroy(rig);rig.part:Destroy()
end
function state.releaseUnused()
 if state.users==0 and not building then
  if prototype then prototype:Destroy();prototype=nil end
  if editable then editable:Destroy();editable=nil end
  failure=nil
 end
end
return state
end
local Mesh={}
function Mesh.create(model)
 local profile=profiles[model:GetAttribute('EnemyKind')]or profiles.stalker
 if not assets[profile.folder]then assets[profile.folder]=loadAsset(script.Parent[profile.folder])end
 return assets[profile.folder].create(model)
end
function Mesh.pose(rig,origin,time,mode)rig.asset.pose(rig,origin,time,mode)end
function Mesh.place(rig,origin)rig.asset.place(rig,origin)end
function Mesh.duration(rig,mode)return rig.asset.clip(rig,mode).duration end
function Mesh.destroy(rig)if rig then rig.asset.destroy(rig)end end
function Mesh.releaseUnused()for _,asset in pairs(assets)do asset.releaseUnused()end;gear.releaseUnused()end
return Mesh
