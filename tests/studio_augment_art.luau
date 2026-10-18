-- Run on a disposable Studio CLIENT. Real engine instances; not a human quality verdict.
local player=game.Players.LocalPlayer
local modules=player.PlayerScripts.SummonerClient.Modules
local styles=require(modules.combat.AugmentStyles)
local folder=Instance.new('Folder');folder.Name='AugmentArtCheck';folder.Parent=workspace
local gui=Instance.new('ScreenGui');gui.Parent=player.PlayerGui
local art=require(modules.combat.AugmentArt)({folder=folder})
local messages={};local connection=game:GetService('LogService').MessageOut:Connect(function(message,kind)
 if message:find('[VFX.Animator]',1,true)or kind==Enum.MessageType.MessageError then table.insert(messages,message)end
end)
local scene
local camera=workspace.CurrentCamera;local oldFrame=camera.CFrame;local oldType=camera.CameraType
local ok,result=xpcall(function()
 local camera=workspace.CurrentCamera;local point=camera.CFrame.Position+camera.CFrame.LookVector*20
 local anchor=Instance.new('Part');anchor.Anchored=true;anchor.Transparency=1;anchor.Position=point;anchor.Parent=folder
 anchor:SetAttribute('Duration',3.2);anchor:SetAttribute('Radius',8);anchor:SetAttribute('Elapsed',.5)
 art.Cast(anchor,'ice');assert(art.Stats().active==0,'Base has no augment overlay')
 art.Impact(point,3,{ids='missile_hunter',empowered=false});assert(art.Stats().active==0,'No false elite bonus')
 art.Impact(point,3,{ids='aether_execute',empowered=false});assert(art.Stats().active==0,'No false execute bonus')
 local n=0
 for spell,entries in pairs(styles)do for _,v in ipairs(entries)do
  n+=1;anchor:SetAttribute('VFXAugments',v.id);art.Cast(anchor,spell,spell=='blades'and'aura'or nil)
  art.Impact(point,6,{ids=v.id,phase='echo',empowered=true});task.wait()
  local stats=art.Stats();assert(stats.arcs<=128 and stats.shards<=192,'Bounded pool');art.Clear();assert(art.Stats().active==0,'Clear releases jobs')
 end end
 assert(n==22,'All specialist augments covered')
 -- Early cancellation, folder deletion and reuse cannot retain visible pooled parts/jobs.
 for _=1,4 do anchor:SetAttribute('VFXAugments','ward_reservoir');art.Cast(anchor,'ward');task.wait();art.Clear()end
 assert(art.Stats().active==0)
 art.Impact(point,6,{ids='ward_pulse',phase='hit'});task.wait(.85)
 local stats=art.Stats();assert(stats.active==0 and stats.freeArcs==stats.arcs and stats.freeShards==stats.shards,'Impact returns every resource')
 art.Clear();anchor:Destroy()
 scene=require(modules.combat.PreviewScene)({player=player,net=game.ReplicatedStorage.SummonerNet,gui=gui})
 camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(scene.Origin+Vector3.new(0,45,70),scene.Origin)
 local runs=0
 for spell,entries in pairs(styles)do
  local variants={''};for _,v in ipairs(entries)do table.insert(variants,v.id)end
  if #entries==2 then table.insert(variants,entries[1].id..','..entries[2].id)end
  for _,variant in ipairs(variants)do
   local seconds=scene.Play(spell,2,variant)
   for _=1,math.ceil((seconds+.3)/.2)do scene.Step(.2);task.wait(.015)end
   runs+=1;scene.Clear()
  end
 end
 task.wait(.1);assert(#messages==0,table.concat(messages,'\n'))
 return {specialists=n,galleryRuns=runs,baseHasNoOverlay=true,conditionalBonus=true,poolReturned=true,errors=#messages}
end,debug.traceback)
camera.CFrame=oldFrame;camera.CameraType=oldType
if scene then scene.Destroy()end;art.Clear();connection:Disconnect();gui:Destroy();folder:Destroy()
assert(ok,result);return result
