-- Isolated server session fixture; fake players never touch live session state.
local folder=Instance.new('Folder');folder.Name='RetreatCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local states,enemies,gems={},{},{};local a={Name='RetreatA'};local b={Name='RetreatB'};local participants={a,b}
 local function load(p)
  if p.Character then p.Character:Destroy()end
  local c=Instance.new('Model');c.Parent=folder;local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.Parent=c
  local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;p.Character=c
 end
 a.LoadCharacterAsync=load;b.LoadCharacterAsync=load
 local function pet(name)local m=Instance.new('Model');m.Name=name;local p=Instance.new('Part');p.Anchored=true;p.Parent=m;m.PrimaryPart=p;m.Parent=folder;return m end
 local clock={elapsed=0};local cleared={};local dash={};local resets=0
 local session=require(modules.flow.Session)({players={GetPlayers=function()return participants end},world=folder,states=states,enemies=enemies,gems=gems,rng=Random.new(17),creature=pet,finishDash=function(s)dash[s]=true end,clearIceShots=function(s)if s then cleared[s]=true end end,sync=function()end,clock=clock,resetSpawn=function()resets+=1 end})
 local loadout={'lightning','ice','meteor','lightRing'}
 session.AddPlayer(a);session.AddPlayer(b)
 local sa,sb=states[a],states[b];session.StartRound(sa,loadout,'iceRush');session.StartRound(sb,loadout)
 sa.level=5;sa.fire=4;sa.cooldown=5;sa.dashCooldown=2;sa.offers={};sa.previewSkills=true;clock.elapsed=42;table.insert(enemies,{hp=100});table.insert(gems,{})
 local oldPet=sa.pet;session.ReturnToLobby(sa);task.wait(.12)
 assert(states[a]~=sa and states[a].lobby and states[a].level==1 and states[a].fire==0,'Retreat resets own progression to selection lobby')
 assert(states[a].cooldown==0 and not states[a].dashCooldown,'Cooldowns reset')
 assert(states[a].activeSkill=='iceRush'and states[a].loadout[3]=='meteor','Keep chosen loadout and Q')
 assert(states[b]==sb and not sb.lobby and not sb.over and clock.elapsed==42 and #enemies==1 and #gems==1,'Teammate and world continue untouched')
 assert(cleared[sa]and dash[sa]and not oldPet.Parent and not states[a].previewSkills,'Own projectiles/dash/pet/preview state cleared')
 session.ReturnToLobby(sa);session.ReturnToLobby(states[a]);assert(resets==0,'Stale and lobby requests cannot reset a run')
 local waiting=states[a];session.StartRound(waiting,loadout);assert(not waiting.queued,'Cannot rejoin the active teammate mid-round')
 session.ReturnToLobby(sb);task.wait(.12)
 assert(states[a].lobby and states[b].lobby and clock.elapsed==0 and #enemies==0 and #gems==0 and resets==1,'Last active retreat resets shared round')
 sa,sb=states[a],states[b];session.StartRound(sa,loadout,'iceRush');session.StartRound(sb,loadout)
 session.EndPlayer(sa,'defeat');session.ReturnToLobby(sa);task.wait(.12)
 assert(states[a].lobby and states[b]==sb and not sb.over,'Defeated player can also return without stopping teammate')
 session.ReturnToLobby(sb);task.wait(.12)
 return {soloReset=true,ownCleanup=true,coopContinues=true,selectionPreserved=true,invalidRejected=true,defeatedReturn=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
