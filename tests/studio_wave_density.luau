local folder=Instance.new('Folder');folder.Name='WaveDensityCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local actors=require(modules.shared.Actors)({world=folder});local enemies={}
 local waves=require(modules.world.Waves)({world=folder,states={},enemies=enemies,clock={phase='survival'},roundLength=120,creature=actors.Create,rootOf=function()end,rng=Random.new(25)})
 for i=1,200 do waves.Spawn(.05,1,i*.05)end
 local firstTen=#enemies;assert(firstTen>=12 and firstTen<=14,'Opening density is 12-14 enemies per ten seconds')
 local before=#enemies;waves.Spawn(1,1,18);assert(#enemies==before+7,'A normal spawn plus six-actor pincer pack')
 for i=1,1200 do waves.Spawn(.05,1,90);if i%100==0 then task.wait()end end
 assert(#enemies==84,'Hard cap bounds the denser wave')
 local elites,chargers=0,0
 for _,e in ipairs(enemies)do if e.elite then elites+=1;assert(e.model:FindFirstChild('EliteCrown'),'Elite is visibly marked')end;if e.role=='charger'then chargers+=1 end end
 assert(elites>0 and chargers>0,'Late mix contains elites and chargers')
 return {opening=firstTen,cap=#enemies,elites=elites,chargers=chargers,pack=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
