-- Client engine fixture for sequential ground eruption and cleanup.
local player=game.Players.LocalPlayer
local folder=Instance.new('Folder');folder.Name='GlacialArtCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local art=require(player.PlayerScripts.SummonerClient.Modules.combat.GlacialArt)({folder=folder})
 art.Strike(Vector3.new(400,3,400),Vector3.new(0,0,-1),{range=34,width=6})
 task.wait(.08)
 local effect=folder:FindFirstChild('GlacialEruption');assert(effect,'Ice effect created')
 local main={};for _,v in effect:GetChildren()do if v.Name=='GlacialSpire'then table.insert(main,v)end end
 assert(#main==7,'Seven main ice rows')
 assert(main[1]:GetScale()>.5 and main[7]:GetScale()<.1,'Close rows rise before distant rows')
 local emitters=0
 for _,v in effect:GetChildren()do if v.Name=='IceBirthEmitter'then emitters+=1;assert(math.abs(v.Position.Y-.32)<.01,'Birth light stays above ground rather than following buried crystal')end end
 assert(emitters==14,'Each crystal has a ground flash and frost emitter')
 task.wait(.52)
 assert(main[7]:GetScale()>.95,'Distant row finishes rising')
 assert(not effect:FindFirstChild('ColdLightCrescent',true),'No crescent silhouette remains')
 task.wait(1.6);assert(not effect.Parent,'Transient crystals and particles cleaned')
 return {rows=true,sequential=true,groundFlash=true,noCrescent=true,cleanup=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
