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
local function assertReturned(renderer,label)
 local s=renderer.Stats()
 assert(s.active==0 and s.freeArcs==s.arcs and s.freeShards==s.shards and s.freeParticles==s.particles,label)
end
local function assertBounded(renderer)
 local s=renderer.Stats()
 assert(s.active<=40 and s.arcs<=128 and s.shards<=192 and s.particles<=24,'All augment pools bounded')
end
local ok,result=xpcall(function()
 local camera=workspace.CurrentCamera;local point=camera.CFrame.Position+camera.CFrame.LookVector*20
 local anchor=Instance.new('Part');anchor.Anchored=true;anchor.Transparency=1;anchor.Position=point;anchor.Parent=folder
 anchor:SetAttribute('Duration',3.2);anchor:SetAttribute('Radius',8);anchor:SetAttribute('Elapsed',.5)
 art.Cast(anchor,'ice');assert(art.Stats().active==0,'Base has no augment overlay')
 art.Impact(point,3,{ids='missile_hunter',empowered=false});assert(art.Stats().active==0,'No false elite bonus')
 art.Impact(point,3,{ids='aether_execute',empowered=false});assert(art.Stats().active==0,'No false execute bonus')
 art.Impact(point,6,{ids='meteor_echo,frost_echo',phase='hit',empowered=true})
 art.Impact(point,6,{ids='lightRing_return',phase='hit'})
 assert(art.Stats().active==0 and art.Stats().particles==0,'Echo and return do not render on a normal hit')
 local n=0
 for spell,entries in pairs(styles)do for _,v in ipairs(entries)do
  n+=1;anchor:SetAttribute('VFXAugments',v.id);art.Cast(anchor,spell,spell=='blades'and'aura'or nil)
  art.Impact(point,6,{ids=v.id,phase='echo',empowered=true});task.wait()
  assertBounded(art);art.Clear();assert(art.Stats().active==0 and art.Stats().particles==0,'Clear releases jobs and particle holders')
 end end
 assert(n==22,'All specialist augments covered')
 -- Early cancellation, folder deletion and reuse cannot retain visible pooled parts/jobs.
 for _=1,4 do anchor:SetAttribute('VFXAugments','ward_reservoir');art.Cast(anchor,'ward');task.wait();art.Clear()end
 assert(art.Stats().active==0)
 local polished={'meteor_wide','meteor_echo','frost_wide','frost_echo','ward_pulse','fire_blast'}
 for _,id in ipairs(polished)do
  art.Impact(point,8,{ids=id,phase=id:find('echo')and 'echo'or 'hit'});task.wait(.12)
  assert(art.Stats().active==1 and art.Stats().particles==1,'Selected impact owns one particle holder: '..id)
  local overlay=folder:FindFirstChild('AugmentVisuals');local emitterCount=0
  for _,item in ipairs(overlay:GetDescendants())do
   if item:IsA('ParticleEmitter')then
    emitterCount+=1;assert(not item.Enabled and item.Rate==0 and item.Lifetime.Max<=.7,'Burst-only emitters have bounded lifetime')
    assert(item.Texture:find('rbxasset://textures/particles/',1,true)==1,'Use bundled particle textures')
   elseif item:IsA('BasePart')then
    assert(not item.CanCollide and not item.CanTouch and not item.CanQuery and not item.CastShadow,'Cosmetic parts cannot interfere with play')
   end
  end
  assert(emitterCount==2,'Exactly two emitters per impact holder')
  task.wait(1.4);assertReturned(art,'Natural completion returns geometry and particles: '..id)
  for _,item in ipairs(overlay:GetChildren())do
   if item:IsA('BasePart')then assert(item.Position.Y<-49999,'Every pooled holder is parked')end
  end
  art.Clear()
 end
 -- Resource saturation must gracefully skip layers, then return all acquired slots.
 for _=1,60 do art.Impact(point,8,{ids='frost_wide',phase='hit'})end
 local high=art.Stats();assertBounded(art)
 assert(high.active==40 and high.shards==192 and high.particles==24,'Saturation reaches declared limits')
 task.wait(1.45);assertReturned(art,'Saturated impacts return every resource');art.Clear()
 -- Reuse after natural completion resets the emitter palette without allocating again.
 art.Impact(point,6,{ids='fire_blast',phase='hit'});task.wait(1.45)
 local holder=folder.AugmentVisuals:FindFirstChild('AugmentParticles')
 art.Impact(point,6,{ids='frost_echo',phase='echo'});task.wait(.08)
 assert(art.Stats().particles==1 and holder.Sparks.Texture:find('sparkles_main.dds',1,true),'Reused emitters reset their profile')
 art.Clear()
 -- A paused anchor does not keep emitting, even when render time advances.
 anchor:SetAttribute('VFXAugments','fire_blast');anchor:SetAttribute('Elapsed',.5);art.Cast(anchor,'fire');task.wait(.08)
 holder=folder.AugmentVisuals:FindFirstChild('AugmentParticles');local before=holder.CFrame
 anchor.Position+=Vector3.new(3,0,0);task.wait(.22)
 assert(holder.CFrame==before,'No new burst while replicated cast time is paused')
 anchor:SetAttribute('Elapsed',.8);task.wait(.08);assert(holder.CFrame~=before,'Burst follows resumed cast')
 -- Removing and replacing the container in one frame must cancel old owners.
 folder.AugmentVisuals:Destroy();art.Cast(anchor,'fire');task.wait(.08)
 assert(art.Stats().active==1 and art.Stats().particles==1 and art.Stats().freeParticles==0,'Only replacement container owns resources')
 anchor:Destroy();task.wait(.08);assertReturned(art,'Anchor deletion releases cast particles')
 art.Impact(point,8,{ids='ward_pulse',phase='hit'});task.wait(.08);folder:Destroy();task.wait(.08)
 assert(art.Stats().active==0,'Parent deletion cancels effects');art.Clear()
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
 return {specialists=n,galleryRuns=runs,baseHasNoOverlay=true,conditionalBonus=true,poolReturned=true,polishedImpacts=#polished,particlePoolBounded=true,pausedEmission=true,containerReplacement=true,errors=#messages}
end,debug.traceback)
camera.CFrame=oldFrame;camera.CameraType=oldType
if scene then scene.Destroy()end;art.Clear();connection:Disconnect();gui:Destroy();folder:Destroy()
assert(ok,result);return result
