-- Real Session + Progression with isolated fake participants and real Humanoids.
-- Does not mutate live players, live round state or network remotes.
local folder=Instance.new('Folder');folder.Name='AugmentLifecycleCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local A=require(modules.flow.Augments)
 local states,enemies,gems={},{},{}
 local a,b={Name='AugmentA'},{Name='AugmentB'}
 local function load(p)
  if p.Character then p.Character:Destroy()end
  local c=Instance.new('Model');c.Parent=folder
  local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.Parent=c
  local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;p.Character=c
 end
 a.LoadCharacterAsync=load;b.LoadCharacterAsync=load
 local function pet(name)
  local m=Instance.new('Model');m.Name=name;local p=Instance.new('Part');p.Anchored=true;p.Parent=m;m.PrimaryPart=p;m.Parent=folder;return m
 end
 local clock={elapsed=0,roundLength=120}
 local query=require(modules.shared.PlayerState)({states=states})
 local progression=require(modules.flow.Progression)({world=folder,states=states,gems=gems,
  rng={NextInteger=function(_,low)return low end,NextNumber=function()return .5 end},
  rootOf=query.RootOf,paused=query.Paused,clock=clock,update={FireClient=function()end}})
 local session=require(modules.flow.Session)({players={GetPlayers=function()return {a,b}end},world=folder,
  states=states,enemies=enemies,gems=gems,rng=Random.new(19),creature=pet,
  finishDash=function()end,clearIceShots=function()end,sync=progression.Sync,clock=clock,resetSpawn=function()end})
 local loadout={'ice','meteor','ward','missile'}
 session.AddPlayer(a);session.AddPlayer(b)
 session.StartRound(states[a],loadout,'iceRush');session.StartRound(states[b],loadout,'iceRush')
 local old=states[a];old.xp=5;old.rerolls=0
 old.augments={lucky_charm=3,quick_cast=3,active_focus=2}
 progression.LevelCheck(old)
 local oldId,oldRevision=old.offers[1].id,old.offerRevision
 local teammate=states[b];clock.elapsed=42
 session.ReturnToLobby(old);task.wait(.1)
 assert(states[b]==teammate and not teammate.over and clock.elapsed==42,'Retreat preserves active teammate')
 assert(states[a]~=old and states[a].lobby and next(states[a].augments)==nil,'Retreat clears all augment stacks')
 local recap=states[a].lastRun
 assert(recap and recap.result=='retreat'and recap.seconds==42 and recap.luck==60 and recap.augmentCount==8,'Retreat preserves the finished build separately from reset state')
 assert(A.Luck(states[a])==0 and states[a].rerolls==2 and A.ActiveCooldown(states[a])==4,'Luck, rerolls and Q multiplier reset')
 assert(A.Cooldown(states[a],10)==10,'Automatic cooldown multiplier reset')
 clock.elapsed=63;session.EndPlayer(teammate,'defeat')
 local defeat=teammate.runResult;session.EndPlayer(teammate,'victory')
 assert(teammate.runResult==defeat and defeat.result=='defeat'and defeat.seconds==63,'Repeated end cannot replace a captured outcome')
 session.ReturnToLobby(teammate);task.wait(.1)
 assert(clock.elapsed==0 and states[a].lobby and states[b].lobby,'Last retreat resets round')
 assert(states[a].lastRun==recap and recap.seconds==42 and states[b].lastRun==defeat,'Round reset preserves each prior result without rewriting defeat to retreat')
 session.StartRound(states[a],loadout,'iceRush');session.StartRound(states[b],loadout,'iceRush')
 local fresh,other=states[a],states[b];fresh.xp=5;progression.LevelCheck(fresh)
 assert(fresh.offers[1].id==oldId,'Same eligible card appears again in this fixture')
 local offers,level=fresh.offers,fresh[oldId]
 progression.Choose(fresh,oldId,oldRevision)
 assert(fresh.offers==offers and fresh[oldId]==level,'Previous run choice is rejected')
 progression.Reroll(fresh,oldRevision)
 assert(fresh.offers==offers and fresh.rerolls==2,'Previous run reroll cannot spend a new charge')
 other.xp=5;progression.LevelCheck(other)
 local otherOffers=other.offers
 progression.Choose(other,oldId,fresh.offerRevision)
 assert(other.offers==otherOffers,'Cross-player offer replay rejected')
 progression.Choose(fresh,oldId,fresh.offerRevision)
 assert(not fresh.offers and fresh[oldId]==level+1 and a.Character.Humanoid.WalkSpeed==22,'Current choice applies and restores movement')
 progression.Choose(fresh,oldId,fresh.offerRevision);assert(fresh[oldId]==level+1,'Repeat choice ignored')
 progression.Reroll(other,other.offerRevision);assert(other.rerolls==1,'Current reroll spends exactly one charge')
 local currentRevision=other.offerRevision;local currentOffers=other.offers
 progression.Reroll(other,currentRevision-1);assert(other.offers==currentOffers and other.rerolls==1,'Old reroll token rejected')
 session.EndPlayer(fresh,'victory');assert(fresh.runResult.result=='victory'and fresh.runResult.revision>recap.revision,'Next completed run replaces the record')
 session.RemovePlayer(a);session.AddPlayer(a);assert(states[a].lastRun==nil,'Disconnect clears private history')
 return {retreatReset=true,teammatePreserved=true,stacksAndLuckReset=true,rerollsReset=true,
  crossRunReplayRejected=true,crossPlayerReplayRejected=true,currentChoice=true,currentReroll=true,movementRestored=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
