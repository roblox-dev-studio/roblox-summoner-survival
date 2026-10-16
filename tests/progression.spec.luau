-- Pure module regression checks. These do not simulate Roblox physics or networking.
local createProgression = require("../src/server/flow/Progression")
local humanoid = {Health=50, MaxHealth=100, WalkSpeed=22}
local packets, dashStops = {}, 0
local s = {player={},level=1,xp=5,kills=0,fire=1,lightning=0,ice=0,golem=1,
    vitality=0,agility=0,magnet=0,cooldown=0,over=false}
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
