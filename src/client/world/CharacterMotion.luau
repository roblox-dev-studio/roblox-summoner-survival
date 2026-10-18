-- Quaternius locomotion, retargeted to R15. Original Animate remains the idle fallback.
-- Presentation only: no root displacement, jump physics or server state changes.
return function(deps)
 deps=deps or {}
 local Players=deps.players or game:GetService("Players")
 local RunService=deps.runService or game:GetService("RunService")
 local now=deps.now or function()return workspace:GetServerTimeNow()end
 local folder=script.Parent:WaitForChild("clips")
 local clips={walk=require(folder.Walk_Loop),run=require(folder.Jog_Fwd_Loop),
  jump=require(folder.Jump_Start),air=require(folder.Jump_Loop),land=require(folder.Jump_Land),roll=require(folder.Roll)}
 local Motion=require(script.Parent.Locomotion)
 local joints=clips.walk.Frames[1].Pose
 local records={}
 local function restore(record)
  for motor,transform in pairs(record.restore)do if motor.Parent then motor.Transform=transform end end
  table.clear(record.restore)
 end
 local function clear(character,record)
  restore(record);record.added:Disconnect()
  character:SetAttribute("SummonerMotion",nil);character:SetAttribute('SummonerMotionJointCount',nil);records[character]=nil
 end
 local function beforeStep()for _,record in pairs(records)do restore(record)end end
 local function step(dt)
  local live={}
  for _,player in ipairs(Players:GetPlayers())do
   local character=player.Character
   local h=character and character:FindFirstChildOfClass("Humanoid")
   local root=character and character:FindFirstChild("HumanoidRootPart")
   if not h or not root or h.RigType~=Enum.HumanoidRigType.R15 then continue end
   live[character]=true
   local record=records[character]
   if not record then
    record={motors={},restore={},motion=Motion.New()}
    local function addJoint(child)
     if (child:IsA('AnimationConstraint')or child:IsA('Motor6D'))and joints[child.Name]then
      local existing=record.motors[child.Name]
      if not existing or child:IsA('AnimationConstraint')then record.motors[child.Name]=child end
      local count=0;for _ in pairs(record.motors)do count+=1 end
      character:SetAttribute('SummonerMotionJointCount',count)
     end
    end
    for _,child in ipairs(character:GetDescendants())do addJoint(child)end
    record.added=character.DescendantAdded:Connect(addJoint)
    records[character]=record
   end
   local state=h:GetState();local v=root.AssemblyLinearVelocity
   local airborne=state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
   local blocked=h.Health<=0 or h.WalkSpeed<=0 or h.Sit or h.PlatformStand or not h.AutoRotate
    or state==Enum.HumanoidStateType.Swimming or state==Enum.HumanoidStateType.Climbing
    or state==Enum.HumanoidStateType.Physics or state==Enum.HumanoidStateType.Ragdoll
   local started=character:GetAttribute('SummonerAirJumpAt')
   local pose,weight,mode=Motion.Step(record.motion,dt,{speed=Vector3.new(v.X,0,v.Z).Magnitude,
    airborne=airborne,rising=v.Y>0,blocked=blocked,dead=h.Health<=0,
    sequence=character:GetAttribute('SummonerAirJumpSequence')or 0,airJumpAge=started and now()-started or 10},clips)
   -- Equipped tools and Action tracks retain their upper-body gestures during normal movement.
   local upperOwned=character:FindFirstChildOfClass('Tool')~=nil
   local animator=h:FindFirstChildOfClass('Animator')
   if animator and mode~='doubleJump'then
    for _,track in animator:GetPlayingAnimationTracks()do
     if track.Priority.Value>=Enum.AnimationPriority.Action.Value and track.WeightCurrent>.1 then upperOwned=true;break end
    end
   end
   if pose and weight>.001 then
    for name,motor in pairs(record.motors)do
     local upper=name=='Waist'or name=='Neck'or name:find('Shoulder')or name:find('Elbow')or name:find('Wrist')
     if motor.Parent and (not motor:IsA('AnimationConstraint')or motor.IsKinematic)
      and not(upperOwned and upper and mode~='doubleJump')then
      record.restore[motor]=motor.Transform
      motor.Transform=motor.Transform:Lerp(pose[name],weight)
     end
    end
   end
   if character:GetAttribute('SummonerMotion')~=mode then character:SetAttribute('SummonerMotion',mode)end
  end
  for character,record in pairs(records)do if not live[character]then clear(character,record)end end
 end
 -- Restore before Animator writes, apply after it writes. No additive Transform drift.
 local before=RunService.PreAnimation:Connect(beforeStep)
 local connection=RunService.PreSimulation:Connect(step)
 return {Destroy=function()
  before:Disconnect();connection:Disconnect()
  for character,record in pairs(records)do clear(character,record)end
 end}
end
