-- Client fixture: actual R15 motors, controlled scheduler, no live character mutation.
local p=game.Players.LocalPlayer
local factory=require(p.PlayerScripts.SummonerClient.Modules.world.CharacterMotion)
local description=Instance.new('HumanoidDescription')
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15);description:Destroy()
c.Name='MotionRestoreFixture';c.Parent=workspace;c:PivotTo(CFrame.new(900,40,900))
local root=c.HumanoidRootPart;root.Anchored=true
local before,after=Instance.new('BindableEvent'),Instance.new('BindableEvent')
local participants={{Character=c}};local baselines={}
for _,m in c:GetDescendants()do if m:IsA('Motor6D')or m:IsA('AnimationConstraint')then baselines[m]=m.Transform end end
local api=factory({players={GetPlayers=function()return participants end},runService={PreAnimation=before.Event,PreSimulation=after.Event},now=function()return 100 end})
local function frames(n)
 for _=1,n do before:Fire();task.wait();after:Fire(1/60);task.wait()end
end
local ok,err=pcall(function()
 root.AssemblyLinearVelocity=Vector3.new(18,0,0);frames(20)
 assert(c:GetAttribute('SummonerMotionJointCount')==15,'All 15 actual avatar joints resolved')
 assert(c:GetAttribute('SummonerMotion')=='move','Real motor layer selects movement')
 local changed=0;for m,base in pairs(baselines)do if m.Transform~=base then changed+=1 end end
 assert(changed>=10,'Full-body imported gesture, not legs alone')
 before:Fire();task.wait()
 for m,base in pairs(baselines)do assert(m.Transform==base,'Each frame restores animator baseline')end
 root.AssemblyLinearVelocity=Vector3.zero;frames(70)
 for m,base in pairs(baselines)do assert(m.Transform==base,'Idle returns ownership without drift')end
 root.AssemblyLinearVelocity=Vector3.new(22,0,0);frames(12)
 table.clear(participants);frames(1)
 assert(c:GetAttribute('SummonerMotion')==nil,'Removed avatar cleared')
 for m,base in pairs(baselines)do assert(m.Transform==base,'Removal restores original pose')end
end)
api.Destroy();before:Destroy();after:Destroy();c:Destroy();assert(ok,err)
return 'PASS: actual R15 motors, full-body pose, pre-animation restore, idle and removal cleanup'
