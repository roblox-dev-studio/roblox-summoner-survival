-- One server-approved air jump per stable ground contact. No client-supplied velocity.
return function(deps)
 local world=deps.world or workspace
 local now=deps.now or os.clock
 local function body(s)
  local c=s.player.Character;local h=c and c:FindFirstChildOfClass('Humanoid');local r=c and c:FindFirstChild('HumanoidRootPart')
  return c,h,r
 end
 local function grounded(c,h,r)
  if r.AssemblyLinearVelocity.Y>3 then return false end
  local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude
  params.FilterDescendantsInstances={c,deps.runtime};params.RespectCanCollide=true
  return world:Raycast(r.Position,Vector3.new(0,-(h.HipHeight+r.Size.Y*.5+.25),0),params)~=nil
 end
 local function step(s,dt)
  local c,h,r=body(s)
  if not c or not h or not r or h.Health<=0 then s.airJump=nil;return end
  local a=s.airJump
  if not a or a.character~=c or a.lobby~=s.lobby then
   a={character=c,lobby=s.lobby,available=false,groundTime=0,airTime=0,sequence=c:GetAttribute('SummonerAirJumpSequence')or 0,lastRequest=-10};s.airJump=a
   c:SetAttribute('SummonerAirJumpSequence',a.sequence);c:SetAttribute('SummonerAirJumpAt',nil)
  end
  if grounded(c,h,r)then
   a.groundTime+=dt;a.airTime=0
   if a.groundTime>=.08 then a.available=true end
  else a.groundTime=0;a.airTime+=dt end
 end
 local function request(s)
  local a=s.airJump;local c,h,r=body(s);local t=now()
  if not a or a.character~=c or a.lobby~=s.lobby or t-a.lastRequest<.12 then return false end
  a.lastRequest=t
  if not h or not r or h.Health<=0 or not s.loaded or s.over or s.offers or s.returning or s.queued
   or s.dash or s.previewDragon or s.previewSkills or deps.paused() or h.WalkSpeed<=0
   or h.Sit or h.PlatformStand or r.Anchored or not a.available then return false end
  local state=h:GetState()
  if state~=Enum.HumanoidStateType.Jumping and state~=Enum.HumanoidStateType.Freefall then return false end
  if grounded(c,h,r)then return false end
  a.available=false;a.sequence+=1
  local base=h.UseJumpPower and h.JumpPower or math.sqrt(2*world.Gravity*h.JumpHeight)
  local speed=math.clamp(base*.9,30,55)
  local v=r.AssemblyLinearVelocity;r.AssemblyLinearVelocity=Vector3.new(v.X,speed,v.Z)
  c:SetAttribute('SummonerAirJumpAt',workspace:GetServerTimeNow())
  c:SetAttribute('SummonerAirJumpSequence',a.sequence)
  -- Network owner applies the already-approved impulse; observers use replicated attributes.
  deps.effect:FireClient(s.player,'airJump',c,a.sequence,speed)
  return true
 end
 return {Step=step,Request=request}
end
