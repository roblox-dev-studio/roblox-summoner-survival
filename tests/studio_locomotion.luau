-- Client engine fixture: real CFrames/imported samples, deterministic state transitions.
local modules=game.Players.LocalPlayer.PlayerScripts.SummonerClient.Modules
local Motion=require(modules.world.Locomotion);local c=modules.world.clips
local clips={walk=require(c.Walk_Loop),run=require(c.Jog_Fwd_Loop),jump=require(c.Jump_Start),air=require(c.Jump_Loop),land=require(c.Jump_Land),roll=require(c.Roll)}
local r=Motion.New();local input={speed=18,airborne=false,rising=false,blocked=false,dead=false,sequence=0,airJumpAge=10}
local function step(n)for _=1,n or 1 do Motion.Step(r,1/60,input,clips)end end
step(60);assert(r.mode=='move'and r.weight>.99)
local previous=r.pose.LeftHip;step(12);assert(previous~=r.pose.LeftHip,'External walking actually changes pose')
input.airborne=true;input.rising=true;step();assert(r.mode=='jump')
step(14);assert(r.mode=='air')
input.sequence=1;input.airJumpAge=0;step();assert(r.mode=='doubleJump')
local rotates=false
for _=1,31 do step();if r.pose.Root.UpVector.Y<-.5 then rotates=true end end
assert(rotates,'Original Roll makes an inverted air-tumble frame')
step(10);assert(r.mode=='air','Tumble finishes once, no repeat while airborne')
input.airborne=false;step();assert(r.mode=='land');step(12);assert(r.mode=='move','Landing does not lock movement')
input.airborne=true;input.rising=false;step();assert(r.mode=='air','Walking off an edge does not replay takeoff')
input.sequence=2;input.airJumpAge=0;step();assert(r.mode=='doubleJump')
input.airborne=false;step();assert(r.mode=='land','Early contact cancels tumble')
input.dead=true;input.blocked=true;step();assert(r.mode=='idle'and r.weight==0)
for _,clip in pairs(clips)do for _,frame in clip.Frames do
 for _,value in pairs(frame.Pose)do assert(value.Position.Magnitude<.0001,'No fake root translation')end
end end
return 'PASS: walk/run, takeoff/edge fall, full source roll, landing cancel, death, root ownership'
