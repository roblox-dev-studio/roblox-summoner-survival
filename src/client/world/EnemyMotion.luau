-- Stable per-enemy variation. Smooth gait sway, never per-frame random jitter.
-- Only local visual origins/clocks change; server hit anchors and attack clocks do not.
local Motion={}
function Motion.create(identity,duration)
 local seed=5381
 for i=1,#identity do seed=(seed*33+string.byte(identity,i))%2147483647 end
 local rng=Random.new(seed)
 return {duration=duration,time=rng:NextNumber(0,20),gait=rng:NextNumber(0,duration),
  tempo=rng:NextNumber(.94,1.06),offset=rng:NextNumber(.035,.09),
  yaw=math.rad(rng:NextNumber(.6,1.8)),
  noiseSeed=rng:NextNumber(0,100),speed=0,weight=0}
end
function Motion.advance(state,dt,distance,stride,frozen)
 if frozen then return end
 if distance>10 then distance=0;state.speed=0 end
 local target=math.min(distance/math.max(dt,.001),45)
 state.speed+=(target-state.speed)*(1-math.exp(-dt*12))
 state.time+=dt*state.tempo
 state.gait+=state.speed*dt/stride*state.tempo
end
function Motion.frame(state,origin,dt,walking,frozen)
 if not frozen then state.weight+=((walking and 1 or 0)-state.weight)*(1-math.exp(-dt*12))end
 local phase=state.gait/state.duration*math.pi*2
 local wave=math.sin(phase);local drift=math.noise(state.gait*.65,state.noiseSeed)
 local weight=state.weight
 return origin*CFrame.new((wave*.8+drift*.2)*state.offset*weight,0,0)
  *CFrame.Angles(0,(wave*.65+drift*.35)*state.yaw*weight,0)
end
return Motion
