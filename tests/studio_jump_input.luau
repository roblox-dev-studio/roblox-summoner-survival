-- Client fixture: real R15 body and callbacks; isolated network/input signals.
local localPlayer=game.Players.LocalPlayer
local factory=require(localPlayer.PlayerScripts.SummonerClient.Modules.combat.JumpInput)
local events={}
local function event()local e=Instance.new('BindableEvent');table.insert(events,e);return e end
local state,effect,removing=event(),event(),event()
local description=Instance.new('HumanoidDescription')
local c=game.Players:CreateHumanoidModelFromDescriptionAsync(description,Enum.HumanoidRigType.R15);description:Destroy()
c.Parent=workspace;c:PivotTo(CFrame.new(900,100,900));task.wait(.05)
local h=c.Humanoid;h:ChangeState(Enum.HumanoidStateType.Freefall);task.wait(.05);local count=0;local focused=false
local player={Character=c,CharacterRemoving=removing.Event,FindFirstChildOfClass=function()return nil end}
local inputService={GetFocusedTextBox=function()return focused and {}or nil end}
for _,name in {'InputBegan','InputEnded','WindowFocusReleased'}do inputService[name]=event().Event end
local api=factory({player=player,inputService=inputService,net={Action={FireServer=function(_,kind)assert(kind=='airJump');count+=1 end},
 State={OnClientEvent=state.Event},Effect={OnClientEvent=effect.Event}}})
local ok,err=pcall(function()
 state:Fire({lobby=true});task.wait()
 assert(api.Press()and count==1,'One fresh airborne press sends intent')
 assert(not api.Press()and count==1,'Held input cannot auto double jump')
 api.Release();api.SetMenuOpen(true);assert(not api.Press(),'Menu blocked')
 api.Release();api.SetMenuOpen(false);focused=true;assert(not api.Press(),'Typing blocked');focused=false
 api.Release();state:Fire({offers={}});task.wait();assert(not api.Press(),'Level-up blocked')
 api.Release();state:Fire({lobby=false});task.wait();api.SetSuspended(true);assert(not api.Press(),'Preview suspended')
 api.Release();api.SetSuspended(false);assert(api.Press()and count==2,'Release/repress sends next intent')
 local r=c.HumanoidRootPart;r.AssemblyLinearVelocity=Vector3.zero
 effect:Fire('airJump',c,1,45);task.wait();assert(r.AssemblyLinearVelocity.Y>25,'Approved impulse applied')
 r.AssemblyLinearVelocity=Vector3.zero;effect:Fire('airJump',c,1,45);task.wait();assert(r.AssemblyLinearVelocity.Y<=0,'Duplicate approval ignored')
 api.SetMenuOpen(true);effect:Fire('airJump',c,2,45);task.wait();assert(r.AssemblyLinearVelocity.Y<=0,'Late approval does not jump through menu')
end)
api.Destroy();c:Destroy();for _,e in events do e:Destroy()end
assert(ok,err)
return 'PASS: release/repress, held/menu/text/offer/preview guards, approved impulse and duplicate suppression'
