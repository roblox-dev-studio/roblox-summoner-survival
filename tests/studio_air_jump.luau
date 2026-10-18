-- Server engine fixture. Ground contact/clock are injected; real physics tested separately.
local factory=require(game.ServerScriptService.SummonerServer.Modules.combat.AirJump)
local models={};local ground=true;local time=0;local fired=0;local paused=false
local function body()
 local description=Instance.new('HumanoidDescription')
 local c=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15);description:Destroy()
 c.Name='AirJumpFixture';c.Parent=workspace;c:PivotTo(CFrame.new(900,60,900))
 local r=c.HumanoidRootPart;local h=c.Humanoid;h.UseJumpPower=true;h.JumpPower=50;r:SetNetworkOwner(nil)
 table.insert(models,c);return c,h,r
end
local ok,err=pcall(function()
 local c,h,r=body();local s={player={Character=c},lobby=true,loaded=true}
 local controller=factory({world={Gravity=196.2,Raycast=function()return ground and {}or nil end},
  now=function()return time end,paused=function()return paused end,
  effect={FireClient=function(_,player,kind,char,seq,speed)
   assert(player==s.player and kind=='airJump'and char==c and seq>0 and speed==45);fired+=1
  end}})
 controller.Step(s,.1);assert(s.airJump.available,'Stable ground arms one jump')
 assert(not controller.Request(s),'Ground request rejected')
 ground=false;r.AssemblyLinearVelocity=Vector3.new(8,10,-4);h:ChangeState(Enum.HumanoidStateType.Freefall);task.wait(.05)
 controller.Step(s,.05);assert(not controller.Request(s),'Request rate limit applies across takeoff')
 time+=.2;controller.Step(s,.1);local beforeVelocity=r.AssemblyLinearVelocity;assert(controller.Request(s),'Second fresh press allowed')
 assert(not s.airJump.available and fired==1 and r.AssemblyLinearVelocity.Y==45 and math.abs(r.AssemblyLinearVelocity.X-beforeVelocity.X)<.0001,'Vertical impulse only, one permit consumed')
 time+=.2;assert(not controller.Request(s),'Third jump/spam rejected')
 ground=true;r.AssemblyLinearVelocity=Vector3.zero;controller.Step(s,.04);assert(not s.airJump.available,'Brief contact cannot recharge')
 ground=false;controller.Step(s,.1);time+=.2;assert(not controller.Request(s),'One-frame floor flicker cannot recharge')
 ground=true;controller.Step(s,.1);assert(s.airJump.available)
 ground=false;controller.Step(s,.15);time+=.2
 for _,flag in {'over','offers','returning','queued','dash','previewSkills'}do
  s[flag]=true;assert(not controller.Request(s),flag..' prevents air jump');s[flag]=nil;time+=.2
 end
 paused=true;assert(not controller.Request(s),'Paused rejected');paused=false;time+=.2
 assert(controller.Request(s)and fired==2,'Landing recharges')
 s.lobby=false;controller.Step(s,.1);time+=.2
 assert(not controller.Request(s),'Round transition does not mint a midair charge')
 local old=c;c,h,r=body();s.player.Character=c;controller.Step(s,.2);time+=.2
 assert(not controller.Request(s),'Respawn starts unarmed until grounded')
 old:Destroy()
end)
for _,c in models do c:Destroy()end
assert(ok,err)
return 'PASS: air jump authority, one charge, spam, stable landing, blocked states and respawn'
