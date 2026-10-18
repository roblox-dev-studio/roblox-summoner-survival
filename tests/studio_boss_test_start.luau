-- Server fixture: no live-player state; test start, guards, matching readiness and reset.
local folder=Instance.new('Folder');folder.Name='BossStartCheck';folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules;local states,enemies,gems={},{},{}
 local player={Name='BossTester'};local participants={player};local clock={phase='survival',elapsed=0,roundLength=120}
 player.LoadCharacterAsync=function(p)if p.Character then p.Character:Destroy()end;local c=Instance.new('Model');c.Parent=folder;local r=Instance.new('Part');r.Name='HumanoidRootPart';r.Anchored=true;r.Parent=c;local h=Instance.new('Humanoid');h.RequiresNeck=false;h.Parent=c;p.Character=c end
 local function creature()local m=Instance.new('Model');local r=Instance.new('Part');r.Anchored=true;r.Parent=m;m.PrimaryPart=r;m.Parent=folder;return m end
 local deps={players={GetPlayers=function()return participants end},world=folder,states=states,enemies=enemies,gems=gems,rng=Random.new(12),creature=creature,finishDash=function()end,clearIceShots=function()end,sync=function()end,clock=clock,resetSpawn=function()end,resetBoss=function()clock.phase='survival' end}
 local session=require(modules.flow.Session)(deps);session.AddPlayer(player);local s=states[player];local ids={'ice','meteor','blades','lightRing'}
 session.StartBossTest(s,ids,'fire');assert(s.lobby and not s.queued and clock.elapsed==0,'Production permission defaults to disabled')
 session.StartFieldBossTest(s,ids,'fire');assert(s.lobby and not s.queued and clock.elapsed==0,'Field test also defaults to disabled')
 deps.allowBossTest=true;session.StartBossTest(s,{'fire','meteor','blades','lightRing'},'fire');assert(s.lobby and not s.queued,'Test still validates automatic spells')
 s.lastLobbyRequest=nil;session.StartBossTest(s,ids,'invalid');assert(s.lobby,'Test still validates Q')
 s.lastLobbyRequest=nil;session.StartBossTest(s,ids,'fire');assert(not s.lobby and s.bossTest and clock.elapsed==120,'Test skips survival')
 for _,id in ipairs(ids)do assert(s[id]==5,'Only equipped spells reach maximum')end
 assert(s.golem==5 and s.level==21 and s.lightning==0 and s.fire==0,'Golem maxed without granting unselected spells')
 session.StartBossTest(s,ids,'fire');assert(clock.elapsed==120,'Repeated active request cannot reset run')
 session.ReturnToLobby(s);task.wait(.15);s=states[player];assert(s.lobby and not s.bossTest and s.ice==0 and s.golem==1 and clock.elapsed==0,'Return clears test progression')
 session.StartRound(s,ids,'fire');assert(not s.lobby and not s.bossTest and s.ice==1 and s.golem==1 and clock.elapsed==0,'Normal run is still rank one survival')
 session.EndPlayer(s,'defeat');session.Restart();task.wait(.15);s=states[player]
 local other={Name='Other',LoadCharacterAsync=player.LoadCharacterAsync};table.insert(participants,other);session.AddPlayer(other)
 session.StartBossTest(s,ids,'fire');local second=states[other];session.StartRound(second,ids,'fire');assert(s.queued and second.lobby and not second.queued,'Mixed normal/test modes cannot start together')
 second.lastLobbyRequest=nil;session.StartBossTest(second,ids,'fire');assert(not s.lobby and not second.lobby and second.ice==5,'Matching test mode starts both prepared participants')
 session.EndPlayer(s,'defeat');session.EndPlayer(second,'defeat');session.Restart();task.wait(.15)
 s=states[player];second=states[other]
 session.StartFieldBossTest(s,ids,'fire');session.StartBossTest(second,ids,'fire');assert(s.queued and not second.queued,'Field and dragon tests cannot mix')
 second.lastLobbyRequest=nil;session.StartFieldBossTest(second,ids,'fire')
 assert(not s.lobby and s.fieldBossTest and not s.bossTest and s.ice==3 and s.golem==3 and s.level==11 and clock.elapsed==60,'Field test skips to spawn with rank-three build')
 return {fieldTest=true,permission=true,validation=true,boosted=true,skipSurvival=true,reset=true,normalRun=true,modeMatching=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
