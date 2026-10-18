-- Client presentation integration. Uses the running LocalScript's watcher/cache,
-- rather than requiring a second renderer cache in the fixture's execution context.
-- These local visual-only models never enter authoritative enemies/AI/damage lists.
local world=workspace:WaitForChild('SummonerRuntime')
local templates=game.ReplicatedStorage:WaitForChild('EnemyPreviewModels')
local models={}
local ok,result=xpcall(function()
 local count=0;local equipment={stalker=0,skitter=2,brute=2,caster=1,ember=1}
 for _,kind in ipairs({'stalker','skitter','brute','caster','ember','charger'})do
  for _,elite in ipairs({false,true})do
   count+=1;local m=templates[kind]:Clone();m.Name='EnemyLiveFixture_'..count
   if elite then m:ScaleTo(1.2);m:SetAttribute('Elite',true)end
   m:PivotTo(CFrame.new((count-1)%6*6-15,3,-12-math.floor((count-1)/6)*9));m.Parent=world;table.insert(models,m)
   local deadline=os.clock()+10;repeat task.wait()until m:GetAttribute('SkeletonMeshStatus')or os.clock()>deadline
   assert(m:GetAttribute('SkeletonMeshStatus')=='Ready',kind..' live watcher attaches')
   if kind~='charger'then
    assert(m.KayKitSkeleton.HasSkinnedMesh,kind..' native live mesh')
    local expected=kind=='stalker'and(elite and 2 or 0)or equipment[kind]
    assert(m:GetAttribute('EquipmentCount')==expected,kind..' correct live equipment')
   else assert(m:FindFirstChild('AshHound'),'Hound live visual')end
  end
 end
 return {liveWatcher=true,simultaneousModels=count,normal=6,elite=6,equipment=true}
end,debug.traceback)
for _,m in ipairs(models)do m:Destroy()end
task.wait(.1)
for _,m in ipairs(world:GetChildren())do assert(not m.Name:match('^EnemyLiveFixture_'),'Live fixture cleanup')end
if not ok then error(result)end;return result
