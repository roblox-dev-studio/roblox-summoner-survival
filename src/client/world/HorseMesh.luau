-- Quaternius CC0 horse: fixed native skinning, original walk/gallop/idle clips.
local data=require(script.Parent.horse.Geometry);local source=require(script.Parent.horse.Rig)
local Horse={};local cache,building
local function cf(v)return CFrame.new(table.unpack(v))end
local center=Vector3.new(table.unpack(source.center));local bones={};local clips={}
for i,b in ipairs(source.bones)do bones[i]={name=b.name,parent=b.parent,bind=cf(b.bind),rest=cf(b.rest)}end
for _,mode in ipairs({'Idle','Walk','Gallop'})do local clip=require(script.Parent.horse[mode]);local frames={}
 for i,frame in ipairs(clip.frames)do frames[i]={};for j,pose in ipairs(frame)do frames[i][j]=bones[j].rest:ToObjectSpace(cf(pose))end end
 clips[string.lower(mode)]={duration=clip.duration,frames=frames}
end
local function build()
 local asset=game:GetService('AssetService');local editable,part
 local ok,result=pcall(function()
  editable=asset:CreateEditableMesh();assert(editable,'Horse EditableMesh memory budget exhausted')
  local ids,boneIds,colorIds,normalIds,palette,normalCache={},{},{},{},{},{}
  local uv=editable:AddUV(Vector2.zero)
  for i,b in ipairs(bones)do local props={Name=b.name,CFrame=b.bind,Virtual=false};if b.parent>0 then props.ParentId=boneIds[b.parent]end;boneIds[i]=editable:AddBone(props)end
  for i,p in ipairs(data.positions)do
   ids[i]=editable:AddVertex(Vector3.new(table.unpack(p)));local refs,weights={},{}
   for _,w in ipairs(data.weights[i])do table.insert(refs,boneIds[w[1]]);table.insert(weights,w[2])end
   editable:SetVertexBones(ids[i],refs);editable:SetVertexBoneWeights(ids[i],weights)
   local rgb=data.colors[i];local key=table.concat(rgb,',');if not palette[key]then palette[key]=editable:AddColor(Color3.fromRGB(table.unpack(rgb)),1)end;colorIds[i]=palette[key]
   local n=data.normals[i];local k=string.format('%.5f,%.5f,%.5f',n[1],n[2],n[3]);if not normalCache[k]then normalCache[k]=editable:AddNormal(Vector3.new(table.unpack(n)))end;normalIds[i]=normalCache[k]
  end
  for i,t in ipairs(data.triangles)do local f=editable:AddTriangle(ids[t[1]],ids[t[2]],ids[t[3]]);editable:SetFaceColors(f,{colorIds[t[1]],colorIds[t[2]],colorIds[t[3]]});editable:SetFaceNormals(f,{normalIds[t[1]],normalIds[t[2]],normalIds[t[3]]});editable:SetFaceUVs(f,{uv,uv,uv});if i%400==0 then task.wait()end end
  editable:RemoveUnused();local fixed=asset:CreateEditableMeshAsync(Content.fromObject(editable),{FixedSize=true});assert(fixed,'Fixed horse memory budget exhausted');editable:Destroy();editable=fixed
  part=asset:CreateMeshPartAsync(Content.fromObject(editable));part.Name='QuaterniusHorse';part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.DoubleSided=true;part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic
  return {part=part,editable=editable,users=0}
 end)
 if not ok then if part then part:Destroy()end;if editable then editable:Destroy()end;error(result)end;return result
end
function Horse.create(parent,scale)
 scale=scale or 1
 local function scaled(frame)return CFrame.new(frame.Position*scale)*frame.Rotation end
 if building then repeat task.wait()until not building end
 if not cache then building=true;local ok,value=pcall(build);building=false;if not ok then error(value)end;cache=value end
 if not parent.Parent then return nil end
 local part=cache.part:Clone();local instances,byName={},{}
 for i,b in ipairs(bones)do local bone=Instance.new('Bone');bone.Name=b.name;bone.CFrame=scaled(b.parent>0 and bones[b.parent].bind:ToObjectSpace(b.bind)or b.bind);bone.Parent=b.parent>0 and instances[b.parent]or part;instances[i]=bone;byName[b.name]=bone end
 part.Size*=scale;part.Parent=parent;cache.users+=1;return {scale=scale,part=part,bones=instances,byName=byName,cache=cache}
end
function Horse.pose(rig,origin,time,mode)
 local now=os.clock();local dt=math.min(.1,now-(rig.lastPose or now));rig.lastPose=now
 if rig.lastMode~=mode then rig.blendFrom={};for i,bone in ipairs(rig.bones)do rig.blendFrom[i]=bone.Transform end;rig.blend=0;rig.lastMode=mode end
 rig.blend=math.min(1,(rig.blend or 0)+dt/.15)
 local clip=clips[mode]or clips.idle;local t=time%clip.duration;local pos=t/clip.duration*(#clip.frames-1);local first=math.min(math.floor(pos)+1,#clip.frames);local second=math.min(first+1,#clip.frames);local alpha=pos-math.floor(pos)
 for i,bone in ipairs(rig.bones)do local pose=clip.frames[first][i]:Lerp(clip.frames[second][i],alpha);pose=CFrame.new(pose.Position*rig.scale)*pose.Rotation;bone.Transform=rig.blend<1 and rig.blendFrom[i]:Lerp(pose,rig.blend)or pose end
 rig.part.CFrame=origin*CFrame.new((center-Vector3.new(0,3,0))*rig.scale+Vector3.new(0,3*(rig.scale-1),0));rig.part:SetAttribute('HorseMotion',mode)
end
function Horse.duration(mode)return(clips[mode]or clips.idle).duration end
function Horse.destroy(rig)if rig.destroyed then return end;rig.destroyed=true;rig.part:Destroy();rig.cache.users-=1 end
function Horse.releaseUnused()if cache and cache.users==0 and not building then cache.part:Destroy();cache.editable:Destroy();cache=nil end end
return Horse
