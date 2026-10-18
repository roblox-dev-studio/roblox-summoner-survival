-- Client scene fixture; exact replicated templates, private viewport, no live actors.
local gui=Instance.new('ScreenGui');gui.Name='EnemyPreviewCheck';gui.Parent=game.Players.LocalPlayer.PlayerGui
local scene
local ok,result=xpcall(function()
 local templates=game.ReplicatedStorage:FindFirstChild('EnemyPreviewModels');assert(templates and #templates:GetChildren()==12,'All twelve server-built templates replicated')
 local view=Instance.new('ViewportFrame');view.Parent=gui;local world=Instance.new('WorldModel');world.Parent=view
 scene=require(game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world.EnemyPreviewScene)({world=world})
 for _,template in ipairs(templates:GetChildren())do
  assert(template:GetAttribute('DisplayName')and template:GetAttribute('Description'),'Catalog has names and traits')
  for _,v in ipairs(template:GetDescendants())do assert(not v:IsA('LuaSourceContainer'),'Visual templates contain no code')end
  scene.Play(template,false,'idle');scene.Step(.1)
  local model=world.PreviewEnemy
  local deadline=os.clock()+10;repeat task.wait()until model:GetAttribute('SkeletonMeshStatus')or os.clock()>deadline;assert(model:GetAttribute('SkeletonMeshStatus')=='Ready','All twelve enemy presentations ready')
  local extra=0;for _,name in ipairs({'KayKitSkeleton','EnemyEquipment','AshHound','VerdantSlime','SlimeSpitter','SlimeBulwark','CrystalScout','CrystalLancer','CrystalMage'})do local added=model:FindFirstChild(name);if added then extra+=1+#added:GetDescendants()end end
  assert(model:GetAttribute('EnemyKind')==template.Name and #model:GetDescendants()==#template:GetDescendants()+extra,'Exact combat template plus imported presentation cloned')
  scene.Play(template,true,'walk');scene.Step(.1);local previous=world.PreviewEnemy:GetPivot().Position;scene.Step(.5)
  assert(world.PreviewEnemy:FindFirstChild('EliteCrown')and math.abs(world.PreviewEnemy:GetScale()-template:GetScale()*1.2)<.001,'Elite appearance scales and has crown')
  assert((world.PreviewEnemy:GetPivot().Position-previous).Magnitude>.5,'Walking demonstration moves')
 end
 scene.Play(templates.charger,false,'attack');scene.Step(.4);assert(world.Demonstration:FindFirstChild('ChargeWarning'),'Charge lane warns');scene.Step(.5);assert(not world.Demonstration:FindFirstChild('ChargeWarning')and world.PreviewEnemy:GetPivot().Position.Z<3,'Charge follows warning')
 scene.Play(templates.caster,false,'attack');scene.Step(.9);assert(world.Demonstration:FindFirstChild('EnemyArcaneBolt'),'Caster fires visual projectile')
 scene.Play(templates.ember,false,'attack');scene.Step(.4);assert(world.Demonstration:FindFirstChild('EnemyBlastWarning'),'Explosion warns');scene.Step(.9);assert(world.Demonstration:FindFirstChild('ExplosionRange'),'Explosion range displayed')
 for _,kind in ipairs({'slime_spitter','crystal_mage'})do
  scene.Play(templates[kind],false,'attack');scene.Step(.3);assert(world.PreviewEnemy:GetAttribute('SkeletonMotion')=='prepare',kind..' preparation pose');scene.Step(.6);assert(world.Demonstration:FindFirstChild('EnemyArcaneBolt'),kind..' ranged role projectile')
 end
 scene.Play(templates.crystal_lancer,false,'attack');scene.Step(.4);assert(world.Demonstration:FindFirstChild('ChargeWarning'),'Crystal lancer lane warns');scene.Step(.5);assert(not world.Demonstration:FindFirstChild('ChargeWarning')and world.PreviewEnemy:GetPivot().Position.Z<3,'Crystal lancer uses charger behavior')
 scene.Clear();assert(not world:FindFirstChild('PreviewEnemy')and #world.Demonstration:GetChildren()==0,'Switch/close cleanup');scene.Destroy();scene=nil;assert(#world:GetChildren()==0,'All scene objects removed')
 return {catalog=12,newFamilyActions=true,exactModels=true,elite=true,movement=true,charge=true,projectile=true,explosion=true,cleanup=true}
end,debug.traceback)
if scene then scene.Destroy()end
gui:Destroy();require(game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world.EnemyVisuals).releaseUnused();if not ok then error(result)end;return result
