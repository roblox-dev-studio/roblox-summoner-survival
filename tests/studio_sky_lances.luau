local folder=Instance.new('Folder');folder.Name='SkyLanceCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local root=Instance.new('Part');root.Anchored=true;root.CanCollide=false;root.Position=Vector3.new(250,3,0);root.Parent=folder
 local e={pos=Vector3.new(250,3,-12),hp=1000};local far={pos=Vector3.new(270,3,-12),hp=1000}
 local s={player={Character=folder},skyLances=1};local events={}
 local spells=require(game.ServerScriptService.SummonerServer.Modules.combat.SkyLances)({world=folder,enemies={e,far},damage=function(target,n)target.hp-=n end,effect={FireAllClients=function(_,kind)events[kind]=(events[kind]or 0)+1 end}})
 spells.Step(s,root,.01);local a=folder:FindFirstChild('SkyLanceCast_',true)
 for _,v in ipairs(folder:GetChildren())do if v.Name:match('SkyLanceCast_')then a=v end end
 assert(a and e.hp==1000,'Portal appears before damage')
 spells.Step(s,root,.8);assert(e.hp==1000,'Warning has no damage')
 s.offers={};local t=a:GetAttribute('Elapsed');spells.Step(s,root,1);assert(a:GetAttribute('Elapsed')==t,'Selection freezes rain');s.offers=nil
 for _=1,40 do spells.Step(s,root,.05)end
 assert(e.hp==967 and far.hp==1000,'Only the narrow falling path hits, once per lance')
 assert(events.skyLanceHit==5 and not a.Parent,'All five impacts and cleanup')
 far.hp=0;e.pos=Vector3.new(250,3,-30);e.speed=10;e.kind='stalker';s.skyLancesClock=0;spells.Step(s,root,.01)
 local predicted;for _,v in ipairs(folder:GetChildren())do if v.Name:match('SkyLanceCast_')then predicted=v end end
 assert(predicted and math.abs(predicted.Position.Z+17)<.01,'Predict advancing enemies instead of aiming behind them')
 spells.Clear(s)
 for _,kind in ipairs({'slime_spitter','crystal_mage'})do
  e.kind=kind;e.role='caster';s.skyLancesClock=0;spells.Step(s,root,.01)
  local cast;for _,v in ipairs(folder:GetChildren())do if v.Name:match('SkyLanceCast_')then cast=v end end
  assert(cast and math.abs(cast.Position.Z-e.pos.Z)<.01,'Caster family retains non-advancing aim: '..kind)
  spells.Clear(s)
 end
 for _,v in ipairs(folder:GetChildren())do assert(not v.Name:match('SkyLanceCast_'),'Death cancels pending lances')end
 return {warning=true,pause=true,fallingHit=true,five=true,casterFamilyAim=true,cleanup=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
