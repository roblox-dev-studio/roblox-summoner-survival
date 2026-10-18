-- Solo client, idle lobby only. Real character physics/network/joints; scripted input, not visual review.
local p=game.Players.LocalPlayer;local c=p.Character;local h=c.Humanoid;local root=c.HumanoidRootPart
local hub=p.PlayerGui:FindFirstChild('SummonerLobbyHub')
assert(hub and hub:GetAttribute('InLobby'),'Run in the idle lobby')
assert(h.FloorMaterial~=Enum.Material.Air and h.Health>0,'Start grounded and alive')
local net=game.ReplicatedStorage.SummonerNet;local seq=c:GetAttribute('SummonerAirJumpSequence')or 0
local y=root.Position.Y;local peak=y;local inverted=false;local modes={}
local rootJoint=c:FindFirstChild('Root',true)
assert(rootJoint and c:GetAttribute('SummonerMotionJointCount')==15,'Real rig joint layer installed')
local ok,err=pcall(function()
 h.Jump=true;task.wait(.22);h.Jump=false;net.Action:FireServer('airJump')
 for i=1,60 do
  task.wait(.02);peak=math.max(peak,root.Position.Y)
  modes[c:GetAttribute('SummonerMotion')or'none']=true
  if rootJoint.Transform.UpVector.Y<-.5 then inverted=true end
  if i==8 then net.Action:FireServer('airJump')end
 end
 assert(c:GetAttribute('SummonerAirJumpSequence')==seq+1,'Exactly one additional jump, third press rejected')
 assert(peak-y>9 and inverted,'Real second ascent and imported full-body rotation')
 assert(modes.doubleJump and modes.land and h.FloorMaterial~=Enum.Material.Air,'Tumble exits to landing')
end)
h.Jump=false;assert(ok,err)
return {result='PASS: scripted native jump / remote approval / real rise / real joint roll / third-jump rejection / landing',heightAboveStart=peak-y}
