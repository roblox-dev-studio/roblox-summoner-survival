-- Pure module regression checks. These do not simulate Roblox physics or networking.
local createProgression = require("../src/server/flow/Progression")
local humanoid = {Health=50, MaxHealth=100, WalkSpeed=22}
local packets, dashStops = {}, 0
local s = {player={},level=1,xp=5,kills=0,fire=1,lightning=0,ice=0,golem=1,
    meteor=0,missile=0,blades=0,frost=0,ward=0,vitality=0,agility=0,magnet=0,cooldown=0,over=false}
local progression = createProgression({
    states={s},gems={},rng={NextInteger=function(_,low) return low end},
    rootOf=function() return {},humanoid end, paused=function() return true end,
    finishDash=function() dashStops+=1 end,
    update={FireClient=function(_,_,packet) table.insert(packets,packet) end},
    clock={elapsed=12.5,roundLength=180},
})
progression.LevelCheck(s)
assert(s.level==2 and s.xp==0 and #s.offers==3 and humanoid.WalkSpeed==0)
assert(dashStops==1 and packets[#packets].time==168 and packets[#packets].need==8)
local offers = s.offers
progression.Choose(s, {})
progression.Choose(s, "not-a-server-offer")
assert(s.offers==offers, "Malformed/unoffered choice must not consume offers")
local id, before = s.offers[1].id, s[s.offers[1].id]
progression.Choose(s,id)
assert(s[id]==before+1 and s.offers==nil and humanoid.WalkSpeed==22)
progression.Choose(s,id)
assert(s[id]==before+1, "Repeated choice must not grant a second upgrade")
s.offers={{id="vitality"}}
progression.Choose(s,"vitality")
assert(s.vitality==1 and humanoid.MaxHealth==115 and humanoid.Health==80)
s.over=true;s.offers={{id="fire"}}
local fire=s.fire
progression.Choose(s,"fire")
assert(s.fire==fire, "Ended round must reject upgrades")
print("PASS: progression offer validation, single consumption, vitality, end-state guard")

local loadouts=require('../src/server/flow/Loadout')
assert(loadouts.Validate({'meteor','ward','frost'}))
for _,invalid in ipairs({{}, {'meteor','meteor','frost'}, {'meteor','gravity','ward'}, {'meteor','frost'}, {'meteor','frost','ward','fire'}, {[2]='meteor',[3]='ward'}, {['1']='meteor',[2]='ward',[3]='frost'}})do
 assert(loadouts.Validate(invalid)==nil,'Reject invalid or duplicate loadouts')
end
s.over=false;s.offers=nil;s.loadout={'meteor','ward','frost'};s.fire=1;s.golem=5;s.meteor=0;s.ward=0;s.frost=0;s.xp=1000
progression.LevelCheck(s)
for _,offer in ipairs(s.offers)do assert(table.find(s.loadout,offer.id),'Only equipped spells offered when three are available')end
local previous=s.meteor;s.offers={{id='ward'}};progression.Choose(s,'meteor');assert(s.meteor==previous,'Unchosen spell rejected')
print('PASS: exact-three loadouts, unknown/duplicate/sparse rejection, equipped-only growth')

assert(loadouts.ValidateActive('thunder') and loadouts.ValidateActive('iceRush') and loadouts.ValidateActive('fireWave')and loadouts.ValidateActive('aetherLance'))
assert(not loadouts.ValidateActive('meteor') and not loadouts.ValidateActive({}) and not loadouts.ValidateActive(7))
print('PASS: active Q skill whitelist')

assert(loadouts.Validate({'fire','missile','ice'}),'Tracking missile is an allowed automatic spell')

assert(loadouts.Validate({"skyLances","blades","missile"}),"Sky lances allowed in exact-three loadout")
