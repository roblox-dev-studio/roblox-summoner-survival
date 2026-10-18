-- Detached end-of-run state; no Roblox engine needed.
local A=require('../src/server/flow/Augments')
local L=require('../src/server/flow/Loadout')
local summaries=require('../src/server/flow/RunSummary')({augments=A,loadouts=L})
local scores=require('../src/server/flow/LobbyScores')()
local p={UserId=42,Name='Scholar'};scores.Add(p)
local state={player=p,over=true,result='defeat',kills=37,level=7,golem=2,loadout={'ice','meteor','blades','ward'},
 ice=3,meteor=2,blades=1,ward=2,activeSkill='iceRush',augments={ice_twin=1,lucky_charm=2},
 rerolls=1,agility=2,magnet=1,vitality=3,runStartedAt=0,fieldBossRewarded=true}
local changed=scores.Record(state,state.result)
local clock={elapsed=73.9}
local first=summaries.Capture(state,clock,scores.Best(p),changed)
assert(first.seconds==73 and first.kills==37 and first.bestScore==37 and first.newBest)
assert(first.spells[1].id=='ice'and first.spells[1].level==3 and #first.spells==4)
assert(first.augments[1].id=='ice_twin'and first.augmentCount==3 and first.luck==40)
assert(first.activeName=='빙하 쇄도'and first.rerollsUsed==1 and first.fieldBossRewarded)
state.ice=5;state.loadout[1]='frost';state.augments.ice_twin=0;state.kills=900;clock.elapsed=999
assert(first.spells[1].id=='ice'and first.spells[1].level==3 and first.augments[1].count==1 and first.kills==37 and first.seconds==73,'Later state/clock changes cannot rewrite record')
for _,mode in ipairs({'bossTest','fieldBossTest'})do
 state[mode]=true;state.runStartedAt=120;clock.elapsed=125.7
 local test=summaries.Capture(state,clock,999,true)
 assert(test.seconds==5 and test.testMode and not test.newBest and test.bestScore==nil,'Test skips prefilled clock and ranking')
 state[mode]=nil
end
state.result='retreat';state.kills=2;state.runStartedAt=0;clock.elapsed=11
local retreat=summaries.Capture(state,clock,37,false)
assert(retreat.result=='retreat'and not retreat.newBest and retreat.bestScore==37 and retreat.revision>first.revision)
state.result='victory';local victory=summaries.Capture(state,clock,37,false)
assert(victory.result=='victory'and victory.revision>retreat.revision)
scores.Remove(p);assert(scores.Best(p)==nil,'Disconnect clears personal best')
print('PASS: detached build/time, augment IDs/stacks, Q, utilities, best score, test exclusion, outcome/revision')

local packets={}
local progression=require('../src/server/flow/Progression')({states={},gems={},augments=A,rootOf=function()return nil end,
 paused=function()return false end,clock={elapsed=0,roundLength=120},update={FireClient=function(_,_,packet)table.insert(packets,packet)end}})
state.cooldown=0;state.xp=0;state.runResult=first;state.lastRun=retreat;state.over=false;state.lobby=false
progression.Sync(state);assert(not packets[1].runResult and not packets[1].lastRun,'Combat excludes history')
state.over=true;progression.Sync(state);assert(packets[2].runResult==first and not packets[2].lastRun,'Ended participant receives fixed current result')
state.over=false;state.lobby=true;progression.Sync(state);assert(packets[3].lastRun==retreat and not packets[3].runResult,'Lobby receives prior result')
print('PASS: result packet appears only at end or in lobby')
