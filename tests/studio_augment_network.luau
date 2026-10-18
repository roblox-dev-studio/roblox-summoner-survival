-- Run once in Client, then once in Server, in the disposable review place's lobby.
-- Read PlayerGui.AugmentNetworkCheck.Result on Client within 15 seconds.
-- Uses real replication / Effect remote / live Effects listener; fixture damage only.
local Run=game:GetService('RunService')
if Run:IsClient()then
 local player=game.Players.LocalPlayer
 assert(not player.PlayerGui:FindFirstChild('AugmentNetworkCheck'),'Previous observer still active')
 local result=Instance.new('Folder');result.Name='AugmentNetworkCheck';result.Parent=player.PlayerGui
 local seen,events={},{}
 local camera=workspace.CurrentCamera;local old={camera.CameraType,camera.CFrame}
 local root=player.Character.HumanoidRootPart
 local connection=game.ReplicatedStorage.SummonerNet.Effect.OnClientEvent:Connect(function(kind,_,_,meta)
  events[kind]=(events[kind]or 0)+1
  if kind=='augmentImpact'and meta.phase=='echo'then events.echo=true end
 end)
 Run:BindToRenderStep('AugmentNetworkCheck',Enum.RenderPriority.Last.Value+10,function()
  camera.CameraType=Enum.CameraType.Scriptable;camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(25,35,40),root.Position)
  local fx=workspace:FindFirstChild('SummonerLocalEffects')
  local visuals=fx and fx:FindFirstChild('AugmentVisuals')
  if visuals then for _,part in ipairs(visuals:GetChildren())do
   local id=part:GetAttribute('Augment')
   if id then for _,v in ipairs(part:GetDescendants())do if v:IsA('Beam')and v.Enabled then seen[id]=true end end end
  end end
  result:SetAttribute('Result',game:GetService('HttpService'):JSONEncode({seen=seen,events=events}))
 end)
 task.delay(15,function()
  connection:Disconnect();Run:UnbindFromRenderStep('AugmentNetworkCheck');camera.CameraType=old[1];camera.CFrame=old[2]
 end)
 return 'Observer ready for 15 seconds'
end
local folder=Instance.new('Folder');folder.Name='AugmentNetworkFixture';folder.Parent=workspace
local area,state
local ok,value=xpcall(function()
 local player=game.Players:GetPlayers()[1];local root=player.Character.HumanoidRootPart
 local target=Instance.new('Model');target.Parent=folder
 local enemy={model=target,pos=root.Position+Vector3.new(0,0,-12),hp=1000,slow=0}
 area=require(game.ServerScriptService.SummonerServer.Modules.combat.AreaSpells)({
  world=workspace.SummonerRuntime,enemies={enemy},effect=game.ReplicatedStorage.SummonerNet.Effect,
  damage=function(e,n)e.hp-=n end,
 })
 state={player=player,augments={meteor_wide=1,meteor_echo=1,ward_reservoir=1,ward_pulse=1},meteor=2,ward=2}
 area.Step(state,root,.01)
 for _,cast in ipairs(state.areaCasts)do assert(cast.anchor:GetAttribute('VFXAugments')~='','Metadata replicated')end
 for _=1,82 do task.wait(.05);area.Step(state,root,.05)end
 assert(math.abs(enemy.hp-836.5)<.001,'Primary and delayed meteor damage')
 state.shield=0;area.Step(state,root,.05);task.wait(.2)
 return {realRemote=true,primaryAndEcho=true,wardRelease=true}
end,debug.traceback)
if area and state then area.Clear(state)end
folder:Destroy();if not ok then error(value)end;return value
