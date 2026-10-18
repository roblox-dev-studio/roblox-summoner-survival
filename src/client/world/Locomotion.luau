-- Pose selection/blending only. Native Humanoid remains responsible for displacement.
local Motion={}
local function sample(clip,time)
 local t=clip.Loop and time%clip.Duration or math.clamp(time,0,clip.Duration)
 local index=math.clamp(math.floor(t*60)+1,1,#clip.Frames)
 local a,b=clip.Frames[index],clip.Frames[math.min(index+1,#clip.Frames)]
 local alpha=math.clamp((t-a.Time)/math.max(b.Time-a.Time,.00001),0,1);local pose={}
 for name,value in pairs(a.Pose)do pose[name]=value:Lerp(b.Pose[name],alpha)end
 return pose
end
local function blend(a,b,alpha)
 local pose={};for name,value in pairs(b)do pose[name]=(a[name]or value):Lerp(value,alpha)end;return pose
end
function Motion.New()
 return {mode='idle',time=0,phase=0,weight=0,wasAir=false,speed=0,pose=nil,from=nil,transition=1,sequence=0,rollTime=1}
end
function Motion.Step(r,dt,input,clips)
 dt=math.clamp(dt,0,.1)
 r.speed+=(input.speed-r.speed)*(1-math.exp(-dt*12))
 if input.sequence~=r.sequence then
  r.sequence=input.sequence
  if input.sequence>0 and input.airJumpAge>=0 and input.airJumpAge<.55 then r.rollTime=input.airJumpAge end
 end
 local mode='idle'
 if not input.blocked then
  if input.airborne then
   if r.rollTime<.55 then mode='doubleJump'
   elseif input.rising and(not r.wasAir or(r.mode=='jump'and r.time<.2))then mode='jump'
   else mode='air'end
  elseif r.wasAir or(r.mode=='land'and r.time<.16)then mode='land'
  elseif r.speed>.6 then mode='move'end
 end
 if not input.airborne or input.blocked then r.rollTime=1 end
 if mode~=r.mode then r.from=r.pose;r.transition=0;r.time=0;r.mode=mode end
 r.time+=dt;r.transition=math.min(1,r.transition+dt/.1);r.wasAir=input.airborne
 local pose
 if mode=='move'then
  local run=math.clamp((r.speed-10)/8,0,1)
  r.phase=(r.phase+dt*r.speed/(8+6*run))%1
  pose=blend(sample(clips.walk,r.phase*clips.walk.Duration),sample(clips.run,r.phase*clips.run.Duration),run)
 elseif mode=='jump'then pose=sample(clips.jump,clips.jump.Duration*(.35+.65*math.min(r.time/.2,1)))
 elseif mode=='air'then pose=sample(clips.air,r.time)
 elseif mode=='land'then
  pose=sample(clips.land,clips.land.Duration*math.min(r.time/.16,1))
  if r.speed>1 then
   r.phase=(r.phase+dt*r.speed/14)%1
   pose=blend(pose,sample(clips.run,r.phase*clips.run.Duration),math.clamp(r.speed/22,0,.65))
  end
 elseif mode=='doubleJump'then pose=sample(clips.roll,clips.roll.Duration*math.min(r.rollTime/.55,1))end
 if pose then
  local alpha=r.transition*r.transition*(3-2*r.transition)
  -- Roll interpolation must follow the source's full rotation, not repeatedly damp toward it.
  r.pose=r.from and r.transition<1 and blend(r.from,pose,alpha)or pose
 end
 r.rollTime+=dt
 r.weight+=((pose and 1 or 0)-r.weight)*(1-math.exp(-dt*20))
 if input.dead then r.weight=0 end
 return r.pose,r.weight,mode
end
return Motion
