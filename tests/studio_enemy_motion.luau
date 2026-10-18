-- Client fixture: distinct phases and smooth bounded sway with frozen clocks.
local Motion=require(game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules.world.EnemyMotion)
local duration=1.2;local states={};local phases={}
for i=1,20 do
 local s=Motion.create('Shade_'..i..':stalker',duration);states[i]=s;phases[math.floor(s.gait*10000)]=true
 assert(s.tempo>=.94 and s.tempo<=1.06,'Variation stays near authored walk tempo')
end
local count=0;for _ in pairs(phases)do count+=1 end;assert(count>15,'Same species do not march on the same frame')
local first=Motion.create('Shade_7:stalker',duration);local again=Motion.create('Shade_7:stalker',duration)
assert(first.gait==again.gait and first.tempo==again.tempo,'Same identity stable after elite rebuild')
local s=states[1];local previous=CFrame.identity
for frame=1,120 do
 -- Simulate 20Hz roots feeding a 24Hz display: periodic frames have no new packet.
 Motion.advance(s,1/24,frame%6==0 and 0 or .45,7,false)
 local cf=Motion.frame(s,CFrame.identity,1/24,true,false)
 assert(cf.Position.Magnitude<=.1,'Visual sway remains near server hit anchor')
 assert(math.abs(cf.UpVector.X)<.00001 and math.abs(cf.UpVector.Z)<.00001,'Added sway never tilts body or head')
 assert((cf.Position-previous.Position).Magnitude<.05,'No frame-random lateral jitter');previous=cf
 if frame>12 then assert(s.speed>.35,'Packet gaps do not flicker into idle')end
end
local gait,time,weight=s.gait,s.time,s.weight;local held=Motion.frame(s,CFrame.identity,0,true,true)
Motion.advance(s,.5,4,7,true);local frozen=Motion.frame(s,CFrame.identity,.5,false,true)
assert(s.gait==gait and s.time==time and s.weight==weight and frozen==held,'Freeze holds phase and sway')
for _=1,24 do Motion.advance(s,1/24,0,7,false);Motion.frame(s,CFrame.identity,1/24,false,false)end
assert(s.speed<.01 and s.weight<.001,'Stopping settles without permanent wobble')
return {differentPhases=count,smoothSway=true,bounded=true,packetGaps=true,freeze=true,stop=true,stableIdentity=true}
