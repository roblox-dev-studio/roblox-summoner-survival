-- Server fixture: visual cues follow actual caster/fuse states, never client authority.
local folder=Instance.new('Folder');folder.Name='EnemyCastCueCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local target=Instance.new('Part');target.Anchored=true;target.Position=Vector3.new(0,3,0);target.Parent=folder
 local root=game.ReplicatedStorage.EnemyPreviewModels
 local caster=root.caster:Clone();caster.Parent=folder
 local state={};local e={model=caster,pos=Vector3.new(0,3,20),hp=100,kind='caster',speed=9,slow=0,hitClock=0,castClock=0,seed=1}
 local enemies={e};local waves=require(game.ServerScriptService.SummonerServer.Modules.world.Waves)({states={state},enemies=enemies,rng=Random.new(1),roundLength=120,rootOf=function()return target,{TakeDamage=function()end}end,world=folder})
 waves.Step(.4);assert(caster:GetAttribute('Preparing')and not caster:GetAttribute('AttackSequence'),'Caster shows actual windup before release')
 waves.Step(.41);assert(not caster:GetAttribute('Preparing')and caster:GetAttribute('AttackSequence')==1 and folder:FindFirstChild('EnemyArcaneBolt'),'Release cue and real projectile share timing')
 caster:Destroy();table.clear(enemies)
 local bomber=root.ember:Clone();bomber.Parent=folder;local bomb={model=bomber,pos=Vector3.new(0,3,6),hp=100,kind='ember',speed=9,slow=0,hitClock=0,seed=2};table.insert(enemies,bomb)
 waves.Step(.1);assert(bomber:GetAttribute('Detonating')and bomber:FindFirstChild('EnemyBlastWarning'),'Fuse cue accompanies real ground warning')
 local fuse=bomb.fuse;bomb.frozen=2;waves.Step(.5);assert(bomb.fuse==fuse and bomber.Parent,'Frozen bomb does not advance fuse')
 waves.ResetSpawn();return {castWindup=true,releaseCue=true,realProjectile=true,bombFuse=true,freeze=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
