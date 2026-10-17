-- Client engine lifecycle test for shared live/gallery renderers.
local folder=Instance.new('Folder');folder.Name='ElementalArtCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.combat
 local fire=require(modules.FireArt)({folder=folder});local lightning=require(modules.LightningArt)({folder=folder})
 fire.Bolt(Vector3.new(400,4,400),Vector3.new(400,4,370),3)
 fire.Wave(Vector3.new(410,4,400),Vector3.new(0,0,-1),30)
 lightning.Strike(Vector3.new(420,4,400),Vector3.new(420,4,380),1)
 lightning.Strike(Vector3.new(420,4,380),Vector3.new(427,4,380),2)
 task.wait(.12)
 local bolt=folder:FindFirstChild('SolarFireball');assert(bolt and bolt:FindFirstChild('WhiteHotCore'),'Bright fireball created')
 assert(not bolt:FindFirstChildWhichIsA('BillboardGui',true) and bolt:FindFirstChild('AttachedFlame',true),'Attached flame and light body')
 local flameLayers=0;for _,v in ipairs(bolt:GetDescendants())do if v:IsA('ParticleEmitter')and v.Name~='BriefFlameRemnants'and v.Name~='AttachedTailFlame'then flameLayers+=1 end end;assert(flameLayers==4,'Full flame body and three attached tongues remain visible')
 local tailCount=0;for _,v in ipairs(bolt:GetChildren())do if v.Name=='FlameTailLayer'then tailCount+=1;assert(v.Position.Z>0 and v:FindFirstChild('AttachedTailFlame'),'Flame tail stays behind projectile')end end;assert(tailCount==11,'Tapered moving flame tail exists')
 local longest=0;for _,v in ipairs(bolt:GetDescendants())do if v:IsA('Beam')then longest=math.max(longest,v.Attachment1.Position.Z)end end;assert(longest>2.8*4,'Tail silhouette extends at least four head-size units')
 local wave=folder:FindFirstChild('RollingFlameWave');assert(wave and #wave:GetChildren()==3,'Three separate flame plumes');assert(not wave:FindFirstChildWhichIsA('MeshPart',true) and not wave:FindFirstChildWhichIsA('BillboardGui',true),'No fixed surface or image card');local plume=wave:FindFirstChild('FlamePlume');local previous=plume.Position
 for _,root in ipairs({bolt,wave})do for _,v in ipairs(root:GetDescendants())do
  assert(not v:IsA('Fire'),'No ground fire')
  if v:IsA('Beam')then assert((v.Name=='FlameTongue'or v.Name=='FlameTailCore')and v.Width0>v.Width1 and v.Attachment1.Position.Z>0,'Attached tapered flame tongue')end
  if v:IsA('Trail')then assert(v.Name=='SoftFlameWake' and v.Lifetime<=.15 and v.Transparency.Keypoints[1].Value>=.6,'Only a short faint wake')end
  if v:IsA('ParticleEmitter')then
   if v.Name=='BriefFlameRemnants'then assert(not v.LockedToPart and v.Lifetime.Max<=.16 and v.Rate<=22 and v.Size.Keypoints[1].Value<2,'Sparse short flame remnants only')
   else assert(v.LockedToPart and v.Speed.Max==0 and v.VelocityInheritance==0,'Main flame stays with projectile')end
  end
 end end
 local electric=folder:FindFirstChild('BranchedChainLightning');assert(electric,'Branched strike created')
 local visible,white=0,0
 for _,v in ipairs(electric:GetDescendants())do if v:IsA('Beam')then if v.Transparency.Keypoints[1].Value<1 then visible+=1 end;if v.Name=='LightningWhiteCore'then white+=1 end end end
 assert(visible>0 and white>12,'White main/branch/floor channels display')
 local shock=electric:FindFirstChild('LightningGroundShockRing',true);assert(shock,'Floor shock fronts created');local before=(shock.Attachment0.Position-shock.Attachment1.Position).Magnitude
 task.wait(.07);assert((shock.Attachment0.Position-shock.Attachment1.Position).Magnitude>before,'Shock front spreads outward over time');assert((plume.Position-previous).Magnitude>.1,'Plumes move independently through the scene')
 task.wait(.72)
 assert(not bolt.Parent and not folder:FindFirstChild('FireballImpact'),'Projectile ends without a secondary impact effect');assert(not wave.Parent,'Short-lived flame plumes disappear after passage')
 assert(not bolt:FindFirstChildOfClass('Fire')and not wave:FindFirstChildWhichIsA('Fire',true),'Native flames do not linger after projectile impact or wave travel')
 for _,v in ipairs(wave:GetDescendants())do if v:IsA('ParticleEmitter')then assert(not v.Enabled,'Wave emitters stop after travelling')end end
 task.wait(1.5);assert(#folder:GetChildren()==0,'All transient spell roots expire')
 local temporary=Instance.new('Folder');temporary.Parent=folder
 require(modules.FireArt)({folder=temporary}).Bolt(Vector3.new(400,4,400),Vector3.new(400,4,370),3)
 require(modules.FireArt)({folder=temporary}).Wave(Vector3.new(410,4,400),Vector3.new(0,0,-1),30)
 require(modules.LightningArt)({folder=temporary}).Strike(Vector3.new(400,4,400),Vector3.new(400,4,380),1)
 temporary:Destroy();task.wait(.08)
 return {fireball=true,wave=true,lightning=true,impact=true,cleanup=true,earlyRemoval=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
