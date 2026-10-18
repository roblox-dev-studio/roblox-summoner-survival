-- Reuse the actual KayKit CC0 warrior skull AND its original open helmet.
-- Select head-weighted faces from the checked-in warrior geometry; no new asset download.
local geometry=require(script.Parent.skeleton.Geometry)
local source=require(script.Parent.skeleton.Rig)
local Skull={}
local cache,building
local function build()
 local head;for i,b in ipairs(source.bones)do if b.name=='head'then head=i end end
 assert(head,'Warrior head bone missing')
 local selected={};local low=Vector3.one*1e6;local high=-low
 for i,weights in ipairs(geometry.weights)do
  for _,weight in ipairs(weights)do if weight[1]==head and weight[2]>.5 then
   selected[i]=true;local p=Vector3.new(table.unpack(geometry.positions[i]));low=low:Min(p);high=high:Max(p)
  end end
 end
 local center=(low+high)/2;local factor=2.65/(high.Y-low.Y)
 local asset=game:GetService('AssetService');local editable,part
 local ok,result=pcall(function()
  editable=asset:CreateEditableMesh();assert(editable,'Commander skull mesh memory exhausted')
  local ids,colors,normals={},{},{};local uv=editable:AddUV(Vector2.zero)
  for i in pairs(selected)do
   ids[i]=editable:AddVertex((Vector3.new(table.unpack(geometry.positions[i]))-center)*factor)
   colors[i]=editable:AddColor(Color3.fromRGB(table.unpack(geometry.colors[i])),1)
   normals[i]=editable:AddNormal(Vector3.new(table.unpack(geometry.normals[i])))
  end
  local count=0
  for _,t in ipairs(geometry.triangles)do if selected[t[1]]and selected[t[2]]and selected[t[3]]then
   local face=editable:AddTriangle(ids[t[1]],ids[t[2]],ids[t[3]])
   editable:SetFaceColors(face,{colors[t[1]],colors[t[2]],colors[t[3]]});editable:SetFaceNormals(face,{normals[t[1]],normals[t[2]],normals[t[3]]});editable:SetFaceUVs(face,{uv,uv,uv})
   count+=1;if count%400==0 then task.wait()end
  end end
  editable:RemoveUnused();local fixed=asset:CreateEditableMeshAsync(Content.fromObject(editable),{FixedSize=true});assert(fixed,'Commander skull fixed mesh memory exhausted');editable:Destroy();editable=fixed
  part=asset:CreateMeshPartAsync(Content.fromObject(editable));part.Name='KayKitWarriorSkull';part.Anchored=true;part.CanCollide=false;part.CanTouch=false;part.CanQuery=false;part.DoubleSided=true;part.Color=Color3.new(1,1,1);part.Material=Enum.Material.SmoothPlastic
  return {part=part,editable=editable,users=0}
 end)
 if not ok then if part then part:Destroy()end;if editable then editable:Destroy()end;error(result)end
 return result
end
function Skull.create(parent,scale)
 if building then repeat task.wait()until not building end
 if not cache then building=true;local ok,result=pcall(build);building=false;if not ok then error(result)end;cache=result end
 if not parent.Parent then return nil end
 local part=cache.part:Clone();part.Size*=scale;part.Parent=parent;cache.users+=1
 return {part=part,cache=cache}
end
function Skull.destroy(rig)if not rig or rig.destroyed then return end;rig.destroyed=true;rig.part:Destroy();rig.cache.users-=1 end
function Skull.releaseUnused()if cache and cache.users==0 and not building then cache.part:Destroy();cache.editable:Destroy();cache=nil end end
return Skull
