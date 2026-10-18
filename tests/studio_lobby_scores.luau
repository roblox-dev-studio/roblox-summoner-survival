-- Server fixture: isolated participants, session lifecycle, lobby safety and score hooks.
local holder=Instance.new('Folder');holder.Name='LobbyScoreSessionCheck';holder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local scores=require(modules.flow.LobbyScores)();local states,enemies,gems={},{},{}
 local a={Name='ScoreA',UserId=201};local b={Name='ScoreB',UserId=202};local participants={a,b}
 local function load(p)
  if p.Character then p.Character:Destroy()end
  local c=Instance.new('Model');c.Parent=holder;local root=Instance.new('Part');root.Name='HumanoidRootPart';root.Anchored=true;root.Parent=c
  local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;p.Character=c
 end
 a.LoadCharacterAsync=load;b.LoadCharacterAsync=load
 local function creature()
  local model=Instance.new('Model');local root=Instance.new('Part');root.Anchored=true;root.Parent=model;model.PrimaryPart=root;model.Parent=holder;return model
 end
 local spawn=CFrame.new(0,4,187);local clock={phase='survival',elapsed=0,roundLength=120}
 local session=require(modules.flow.Session)({players={GetPlayers=function()return participants end},world=holder,states=states,enemies=enemies,gems=gems,rng=Random.new(21),creature=creature,finishDash=function()end,clearIceShots=function()end,sync=function()end,clock=clock,resetSpawn=function()end,allowBossTest=true,lobbySpawn=spawn,lobbyCenter=Vector3.new(0,0,178),lobbyRadius=58,scoreAdd=scores.Add,scoreRecord=scores.Record,scoreRemove=scores.Remove})
 local loadout={'ice','meteor','blades','lightRing'}
 local function restart()session.Restart();task.wait(.1);assert(states[a].lobby and states[b].lobby,'Restart returns both participants')end
 local function start(mode)
  local method=mode=='boss'and session.StartBossTest or(mode=='field'and session.StartFieldBossTest or session.StartRound)
  method(states[a],loadout,'fire');method(states[b],loadout,'fire');assert(not states[a].lobby and not states[b].lobby,'Matching mode starts')
 end
 session.AddPlayer(a);session.AddPlayer(b)
 assert(a.Character.Humanoid.WalkSpeed==18 and b.Character.Humanoid.WalkSpeed==18,'Lobby exploration speed18')
 a.Character.HumanoidRootPart.CFrame=CFrame.new(59,4,178);session.StepLobby();assert(a.Character.HumanoidRootPart.CFrame==spawn,'Outside lobby radius returns to spawn')
 a.Character.HumanoidRootPart.CFrame=CFrame.new(54,4,178);session.StepLobby();assert(a.Character.HumanoidRootPart.Position.X==54,'Inside lobby remains freely walkable')
 a.Character.HumanoidRootPart.CFrame=CFrame.new(0,-11,178);session.StepLobby();assert(a.Character.HumanoidRootPart.CFrame==spawn,'Falling below lobby returns to spawn')
 start();assert(a.Character.Humanoid.WalkSpeed==22,'Combat speed22 preserved')
 a.Character.HumanoidRootPart.CFrame=CFrame.new(60,4,178);session.StepLobby();assert(a.Character.HumanoidRootPart.Position.X==60,'Lobby safety never teleports active combat state')
 local old=states[a];old.kills=12;session.EndPlayer(old,'defeat');session.ReturnToLobby(old);task.wait(.1)
 assert(states[a]~=old and states[a].lobby and scores.Snapshot()[1].bestScore==12,'Death record survives individual retreat while teammate fights')
 old.kills=900;session.EndPlayer(old,'victory');assert(scores.Snapshot()[1].bestScore==12,'Stale ended state cannot update records')
 states[b].kills=9;session.EndPlayer(states[b],'victory');session.ReturnToLobby(states[b]);task.wait(.1)
 assert(states[a].lobby and states[b].lobby and #scores.Snapshot()==2,'Victory record survives final retreat/full reset')
 start();states[a].kills=5;states[b].kills=4;session.EndPlayer(states[a],'retreat');session.EndPlayer(states[b],'defeat');restart()
 assert(scores.Snapshot()[1].bestScore==12 and scores.Snapshot()[2].bestScore==9,'Ordinary Restart preserves higher earlier records')
 for _,mode in ipairs({'boss','field'})do
  start(mode);states[a].kills=1000;states[b].kills=2000;session.EndPlayer(states[a],'victory');session.EndPlayer(states[b],'defeat');restart()
  assert(scores.Snapshot()[1].bestScore==12 and scores.Snapshot()[2].bestScore==9,mode..' test cannot enter rankings')
 end
 start();states[a].kills=20;session.ReturnToLobby(states[a]);task.wait(.1);assert(scores.Snapshot()[1].bestScore==20,'Active normal retreat records real kills before replacing state')
 session.EndPlayer(states[b],'defeat');session.ReturnToLobby(states[b]);task.wait(.1)
 table.remove(participants,1);session.RemovePlayer(a);assert(#scores.Snapshot()==1 and scores.Snapshot()[1].userId==202,'Disconnected record removed')
 table.clear(participants);session.RemovePlayer(b);assert(#scores.Snapshot()==0,'Last disconnect clears session leaderboard')
 return {lobbyWalk18=true,combatWalk22=true,boundary=true,fallRecovery=true,combatIsolation=true,death=true,victory=true,retreat=true,restartKeepsBest=true,testModesExcluded=true,disconnect=true}
end,debug.traceback)
holder:Destroy();if not ok then error(result)end;return result
