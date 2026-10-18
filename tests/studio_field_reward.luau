-- Reward queue does not overwrite an open card or pay twice.
local folder=Instance.new('Folder');folder.Parent=workspace
local ok,result=xpcall(function()
 local modules=game.ServerScriptService.SummonerServer.Modules
 local h=Instance.new('Humanoid');h.RequiresNeck=false;h.MaxHealth=150;h.Health=60;h.Parent=folder
 local state={player={},level=3,xp=2,cooldown=0,kills=0,golem=1,vitality=0,agility=0,magnet=0,loadout={'ice','meteor','blades','lightRing'},ice=1,meteor=1,blades=1,lightRing=1}
 local progression=require(modules.flow.Progression)({world=folder,states={state},gems={},rng=Random.new(1),clock={phase='survival',elapsed=70,roundLength=120},rootOf=function(s)if s.over or s.lobby then return end;return {},h end,paused=function()return false end,update={FireClient=function()end}})
 state.offers={{id='ice',level=2}};state.offerRevision=1;local current=state.offers
 progression.FieldBossReward(state);assert(state.offers==current and state.xp==13 and h.Health==90,'Existing choice preserved; heal 20% and bank exact level XP')
 progression.FieldBossReward(state);assert(state.xp==13 and h.Health==90,'Idempotent')
 progression.Choose(state,'ice',state.offerRevision);assert(state.ice==2 and state.level==4 and state.offers and state.xp==2,'Extra selection follows existing selection, old XP preserved')
 local previous=state.xp;state.fieldBossRewarded=nil;state.over=true;progression.FieldBossReward(state);assert(state.xp==previous,'Dead/end state excluded')
 state.over=false;state.lobby=true;progression.FieldBossReward(state);assert(not state.fieldBossRewarded,'Lobby excluded')
 state.lobby=false;state.bossTest=true;progression.FieldBossReward(state);assert(not state.fieldBossRewarded,'Dragon test excluded')
 return {heal=true,queue=true,once=true,endState=true,lobby=true,dragonTest=true}
end,debug.traceback)
folder:Destroy();if not ok then error(result)end;return result
