-- Pure CLI regression: only authoritative completed normal runs can enter session records.
local makeScores=require('../src/server/flow/LobbyScores')
local scores=makeScores()
local a={UserId=12,Name='ScholarA',DisplayName='Scholar A'}
local b={UserId=7,Name='ScholarB'}
assert(scores.Add(a)and scores.Add(b)and #scores.Snapshot()==0,'Joining does not fabricate scores')
local function run(player,kills,result,extra)
 local state={player=player,kills=kills,result=result or'defeat',over=true,lobby=false}
 for key,value in pairs(extra or{})do state[key]=value end
 return state,scores.Record(state,state.result)
end
local first,added=run(a,14,'defeat');assert(added and scores.Snapshot()[1].bestScore==14,'Defeat records server kills')
first.kills=999;assert(not scores.Record(first,'defeat')and scores.Snapshot()[1].bestScore==14,'One result per state')
run(a,5,'retreat');assert(scores.Snapshot()[1].bestScore==14,'Smaller retreat retains best')
run(b,14,'victory');local tied=scores.Snapshot();assert(tied[1].userId==7 and tied[2].userId==12,'UserId resolves score ties')
run(a,25,'retreat');assert(scores.Snapshot()[1].userId==12 and scores.Snapshot()[1].bestScore==25,'Larger retreat updates best')
for _,extra in ipairs({{bossTest=true},{fieldBossTest=true},{lobby=true},{over=false}})do
 local _,changed=run(a,1000,'victory',extra);assert(not changed,'Test/lobby/incomplete runs excluded')
end
for _,case in ipairs({{value=-1},{value=2.5},{value=math.huge},{value=-math.huge},{value=0/0},{value='4'},{value={}},{},{value=9007199254740992}})do
 local _,changed=run(a,case.value,'defeat');assert(not changed,'Malformed non-integer/non-finite/negative kills excluded')
end
for _,result in ipairs({'reset','unknown','ready'})do local _,changed=run(a,99,result);assert(not changed,'Only completed result kinds accepted')end
local contradictory={player=a,kills=200,over=true,result='victory'};assert(not scores.Record(contradictory,'defeat'),'Result must match server state')
local stale={UserId=999,Name='Unregistered'};local _,changed=run(stale,500,'victory');assert(not changed,'Disconnected/unregistered player excluded')
assert(not scores.Add({UserId=12,Name='Duplicate'}),'One connected owner per user id')
assert(not scores.Add({UserId=0/0,Name='Bad'})and not scores.Add({UserId=math.huge,Name='Bad'})and not scores.Add({UserId=1.2,Name='Bad'}),'Finite integer identity required')
assert(scores.Add(a)and scores.Snapshot()[1].bestScore==25,'Re-registering after round reset retains record')
local copy=scores.Snapshot();copy[1].bestScore=999999;table.clear(copy);assert(scores.Snapshot()[1].bestScore==25,'Snapshots cannot mutate private records')
for i=1,25 do local p={UserId=100+i,Name='Fixture'..i};scores.Add(p);run(p,30+i,'victory')end
local top=scores.Snapshot();assert(#top==20 and top[1].bestScore==55 and top[20].bestScore==36,'Only top twenty sorted records returned')
scores.Remove(a);assert(scores.Add(a),'Same account can join a new connection');run(a,0,'defeat')
-- A new collector isolates zero and disconnect checks from the top-twenty limit.
local fresh=makeScores();fresh.Add(a);local zero={player=a,kills=0,over=true,result='defeat'};assert(fresh.Record(zero,'defeat')and fresh.Snapshot()[1].bestScore==0,'Completed zero-kill run is an actual record')
fresh.Remove(a);assert(#fresh.Snapshot()==0,'Disconnect erases record');fresh.Add(a);assert(#fresh.Snapshot()==0,'Reconnect does not restore an old connection record')
print('PASS: connected-session records, normal completed outcomes, validation, test exclusions, idempotency, top20, ties, copies, disconnect')

local createProgression=require('../src/server/flow/Progression')
local packets,reads={},0
local state={player={},level=1,xp=0,kills=3,fire=0,lightning=0,ice=0,golem=1,cooldown=0,lobby=true}
local progression=createProgression({states={},gems={},rootOf=function()return nil end,paused=function()return false end,
 augments={Luck=function()return 0 end,Weights=function()return {}end,Summary=function()return {}end},
 lobbyScores=function()reads+=1;return {{userId=12,name='Scholar A',bestScore=25}}end,
 update={FireClient=function(_,_,packet)table.insert(packets,packet)end},clock={roundLength=120,elapsed=0}})
progression.Sync(state);assert(reads==1 and packets[1].lobbyScores[1].bestScore==25,'Lobby packet contains read-only snapshot')
state.lobby=false;progression.Sync(state);assert(reads==1 and packets[2].lobbyScores==nil,'Combat packet excludes score snapshot entirely')
print('PASS: lobby-only score snapshot serialization; no scoreboard read in combat')
