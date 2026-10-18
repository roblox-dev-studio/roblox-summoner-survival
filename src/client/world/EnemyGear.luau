-- CC0 accessory meshes are shared; hands follow the same native animated bones.
local Gear={};local cache,building,failures={},{},{}
local function prototype(name)
 if building[name]then repeat task.wait()until not building[name]end
 if cache[name]then return cache[name]end
 if failures[name]then return nil end
 building[name]=true
 local editable,part
 local ok,result=pcall(function()
  local data=require(script.Parent.gearAssets[name]);local asset=game:GetService('AssetService')
  editable=asset:CreateEditableMesh();assert(editable,'Gear mesh memory budget exhausted')
  local ids,normals,colors,palette={},{},{},{}
  local normalCache={};local uv=editable:AddUV(Vector2.zero)
  for i,p in ipairs(data.positions)do
   ids[i]=editable:AddVertex(Vector3.new(table.unpack(p)));local normal=data.normals[i];local key=string.format('%.5f,%.5f,%.5f',normal[1],normal[2],normal[3]);if not normalCache[key]then normalCache[key]=editable:AddNormal(Vector3.new(table.unpack(normal)))end;normals[i]=normalCache[key]
   local rgb=data.colors[i];local key=table.concat(rgb,',');if not palette[key]then palette[key]=editable:AddColor(Color3.fromRGB(table.unpack(rgb)),1)end;colors[i]=palette[key]
  end
  for i,t in ipairs(data.triangles)do
   local f=editable:AddTriangle(ids[t[1]],ids[t[2]],ids[t[3]]);editable:SetFaceColors(f,{colors[t[1]],colors[t[2]],colors[t[3]]});editable:SetFaceNormals(f,{normals[t[1]],normals[t[2]],normals[t[3]]});editable:SetFaceUVs(f,{uv,uv,uv})
   if i%400==0 then task.wait()end
  end
  editable:RemoveUnused();local fixed=asset:CreateEditableMeshAsync(Content.fromObject(editable),{FixedSize=true});assert(fixed,'Fixed gear memory budget exhausted');editable:Destroy();editable=fixed
  part=asset:CreateMeshPartAsync(Content.fromObject(editable));part.Name=name;part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.DoubleSided=true;part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic
  return {part=part,editable=editable,center=Vector3.new(table.unpack(data.center)),users=0}
 end)
 building[name]=nil
 if not ok then failures[name]=true;if part then part:Destroy()end;if editable then editable:Destroy()end;warn('[EnemyGear] '..name..': '..tostring(result));return nil end
 cache[name]=result;return result
end
local function ball(parent,name,size,color)
 local p=Instance.new('Part');p.Name=name;p.Shape=Enum.PartType.Ball;p.Size=size;p.Color=color;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=parent;return p
end
function Gear.create(rig,profile)
 local folder=Instance.new('Folder');folder.Name='EnemyEquipment';folder.Parent=rig.model
 local items={};local definitions=profile.gear or{}
 if rig.model:GetAttribute('EnemyKind')=='stalker'and rig.model:GetAttribute('Elite')then definitions={{'Blade','handslot.r'},{'Shield_Small_A','handslot.l'}}end
 for _,entry in ipairs(definitions)do
  local source=prototype(entry[1]);local bone=rig.byName[entry[2]]
  if source and bone and rig.model.Parent then
   local p=source.part:Clone();p.Size=source.part.Size*rig.scale;p:SetAttribute('Weapon',entry[1]);p.Parent=folder
   local angle=entry[2]=='handslot.l'and math.pi/2 or -math.pi/2
   if entry[1]=='Staff'then angle=-math.pi/3 end
   local rotation=(entry[1]=='Blade'or entry[1]=='Axe'or entry[1]=='Staff')and CFrame.Angles(0,0,angle)or CFrame.identity
   source.users+=1;table.insert(items,{part=p,bone=bone,offset=source.center,rotation=rotation,source=source})
  end
 end
 if profile.bomb and rig.model.Parent then
  local b=ball(folder,'EmberBomb',Vector3.one*2.1*rig.scale,Color3.fromRGB(49,34,32));b.Material=Enum.Material.Metal
  table.insert(items,{part=b,bone=rig.byName.chest,offset=Vector3.new(0,-.15,-1.05),bomb=true})
  local band=Instance.new('Part');band.Name='BombBand';band.Shape=Enum.PartType.Cylinder;band.Size=Vector3.new(.18,2.18,2.18)*rig.scale;band.Color=Color3.fromRGB(158,101,51);band.Material=Enum.Material.Metal;band.Anchored=true;band.CanCollide=false;band.CanTouch=false;band.CanQuery=false;band.Parent=folder
  rig.bombBand=band
  local fuse=ball(folder,'FuseGlow',Vector3.one*.32*rig.scale,Color3.fromRGB(255,141,45));fuse.Material=Enum.Material.Neon;rig.fuse=fuse
  local attachment=Instance.new('Attachment');attachment.Parent=fuse
  local sparks=Instance.new('ParticleEmitter');sparks.Name='FuseSparks';sparks.Texture='rbxasset://textures/particles/sparkles_main.dds';sparks.Rate=5;sparks.Lifetime=NumberRange.new(.15,.3);sparks.Speed=NumberRange.new(.4,1.5);sparks.Size=NumberSequence.new(.12,0);sparks.LightEmission=1;sparks.Color=ColorSequence.new(Color3.fromRGB(255,161,62));sparks.Parent=attachment;rig.sparks=sparks
 end
 rig.equipment=folder;rig.gear=items;rig.model:SetAttribute('EquipmentCount',#items)
end
function Gear.pose(rig,time,charging)
 for _,v in ipairs(rig.gear or{})do
  local frame=v.bone.TransformedWorldCFrame
  -- Bomb stays in front of the torso, independent of the source bone's local axes.
  if v.bomb then frame=rig.origin*CFrame.new(0,.55*rig.scale,-1.65*rig.scale);v.part.CFrame=frame
   local pulse=charging and(1+math.sin(time*23)*.055)or 1;v.part.Size=Vector3.one*2.1*rig.scale*pulse
   rig.bombBand.CFrame=frame*CFrame.Angles(0,0,math.pi/2);rig.fuse.CFrame=frame*CFrame.new(0,1.25*rig.scale,0)
   rig.fuse.Color=charging and Color3.fromRGB(255,239,143)or Color3.fromRGB(255,130,42);rig.sparks.Rate=charging and 24 or 5
  else v.part.CFrame=frame*v.rotation*CFrame.new(v.offset*rig.scale)end
 end
end
function Gear.destroy(rig)
 if rig.equipmentDestroyed then return end;rig.equipmentDestroyed=true
 for _,item in ipairs(rig.gear or{})do if item.source then item.source.users-=1 end end
 if rig.equipment then rig.equipment:Destroy()end
end
function Gear.releaseUnused()
 for name,source in pairs(cache)do if source.users==0 and not building[name]then source.part:Destroy();source.editable:Destroy();cache[name]=nil end end
 table.clear(failures)
end
return Gear
