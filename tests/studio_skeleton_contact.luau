-- Server fixture: new animation cue preserves the existing contact hit/cooldown/freeze rules.
local folder=Instance.new('Folder');folder.Name='SkeletonContactCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local m=game.ReplicatedStorage.EnemyPreviewModels.stalker:Clone();m.Parent=folder
 local target=Instance.new('Part');target.Anchored=true;target.Position=Vector3.new(0,3,0);target.Parent=folder
 local hits,total=0,0;local humanoid={TakeDamage=function(_,amount)hits+=1;total+=amount end}
 local state={};local e={model=m,pos=Vector3.new(0,3,3),hp=100,kind='stalker',speed=9,hitClock=0,slow=0,seed=1}
 local waves=require(game.ServerScriptService.SummonerServer.Modules.world.Waves)({states={state},enemies={e},rng=Random.new(1),roundLength=120,rootOf=function()return target,humanoid end,world=folder})
 waves.Step(.05);assert(hits==1 and total==8 and m:GetAttribute('AttackSequence')==1,'Same contact damage emits one motion cue')
 waves.Step(.2);assert(hits==1 and m:GetAttribute('AttackSequence')==1,'Cooldown suppresses extra motion/hits')
 e.frozen=2;waves.Step(1);assert(hits==1,'Freeze suppresses contact attack')
 e.frozen=0;waves.Step(.05);assert(hits==2 and total==16 and m:GetAttribute('AttackSequence')==2,'Contact resumes after cooldown and freeze')
 return {contact=true,damage=8,cooldown=true,freeze=true,animationCue=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
