-- Real engine session fixture with fake participants; never touches the live session table.
local folder=Instance.new('Folder');folder.Name='LobbyCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local loadouts=require(modules.flow.Loadout)
 assert(loadouts.Validate({'meteor','ward','frost','lightRing'}))
 for _,invalid in ipairs({{}, {'meteor','meteor','frost'}, {'gravity','ward','frost'}, {[2]='meteor',[3]='ward'}})do assert(not loadouts.Validate(invalid))end
 local states,enemies,gems={},{},{}
 local a={Name='A'};local b={Name='B'};local participants={a,b}
 local function load(p)
  if p.Character then p.Character:Destroy()end
  local c=Instance.new('Model');c.Parent=folder;local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.Parent=c
  local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;p.Character=c
 end
 a.LoadCharacterAsync=load;b.LoadCharacterAsync=load
 local function pet(name)
  local m=Instance.new('Model');m.Name=name;local p=Instance.new('Part');p.Anchored=true;p.Parent=m;m.PrimaryPart=p;m.Parent=folder;return m
 end
 local clock={elapsed=0};local query=require(modules.shared.PlayerState)({states=states})
 local session=require(modules.flow.Session)({players={GetPlayers=function()return participants end},world=folder,states=states,enemies=enemies,gems=gems,rng=Random.new(17),creature=pet,finishDash=function()end,clearIceShots=function()end,sync=function()end,clock=clock,resetSpawn=function()end})
 session.AddPlayer(a);session.AddPlayer(b)
 local sa,sb=states[a],states[b]
 assert(sa.lobby and sb.lobby and query.LiveCount()==0,'Lobby does not advance combat')
 session.StartRound(sa,{'meteor','meteor','frost'});assert(not sa.queued,'Invalid request rejected')
 sa.lastLobbyRequest=nil;session.StartRound(sa,{'meteor','ward','frost','lightRing'},'thunder');assert(sa.queued and sb.lobby and query.LiveCount()==0,'Wait for every participant')
 session.CancelReady(sa);assert(not sa.queued,'Cancel ready')
 sa.lastLobbyRequest=nil;session.StartRound(sa,{'meteor','ward','frost','lightRing'},'thunder');session.StartRound(sb,{'meteor','blades','ice','lightRing'})
 assert(not sa.lobby and not sb.lobby and query.LiveCount()==2,'All ready starts together')
 assert(sa.activeSkill=='thunder' and sa.meteor==1 and sa.ward==1 and sa.frost==1 and sa.fire==0 and sa.lightRing==1,'Only selected spells start at rank one')
 session.StartRound(sa,{'fire','ice','lightning','lightRing'});assert(sa.fire==0,'Cannot change loadout during combat')
 session.EndPlayer(sa,'defeat');session.Restart();assert(states[a]==sa,'Cannot reset a teammate still fighting')
 session.EndPlayer(sb,'defeat');session.Restart();task.wait(.1)
 sa,sb=states[a],states[b]
 assert(sa.lobby and sb.lobby and sa.level==1 and sa.fire==0 and sa.loadout[1]=='meteor' and sa.activeSkill=='thunder','Return to lobby resets rank, keeps loadout')
 session.StartRound(sa,{'meteor','ward','frost','lightRing'});table.remove(participants,2);session.RemovePlayer(b)
 assert(not sa.lobby and query.LiveCount()==1,'Last unready player leaving releases ready participant')
 session.RemovePlayer(a);assert(next(states)==nil,'Departure cleanup')
 return {validation=true,ready=true,coop=true,equipped=true,returnLobby=true,departure=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
