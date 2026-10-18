-- Keep Roblox's first jump. A fresh second press only submits an air-jump intent.
return function(deps)
 local UIS=deps.inputService or game:GetService('UserInputService')
 local GuiService=game:GetService('GuiService')
 local player,net=deps.player,deps.net
 local held,menu,suspended,inLobby,blocked=false,false,false,true,true
 local touch,receivedCharacter,receivedSequence=nil,nil,0
 local connections={}
 local function characterBody()
  local c=player.Character;return c,c and c:FindFirstChildOfClass('Humanoid'),c and c:FindFirstChild('HumanoidRootPart')
 end
 local function release()held=false;touch=nil end
 local function press()
  if held then return false end
  held=true
  if menu or blocked or GuiService.MenuIsOpen or(suspended and not inLobby)or UIS:GetFocusedTextBox()then return false end
  local _,h,r=characterBody();if not h or not r or h.Health<=0 or h.WalkSpeed<=0 or h.Sit or h.PlatformStand then return false end
  local state=h:GetState()
  if h.FloorMaterial~=Enum.Material.Air or(state~=Enum.HumanoidStateType.Jumping and state~=Enum.HumanoidStateType.Freefall)then return false end
  net.Action:FireServer('airJump');return true
 end
 local function jumpKey(input)return input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonA end
 local function jumpTouch(input)
  if input.UserInputType~=Enum.UserInputType.Touch then return false end
  local gui=player:FindFirstChildOfClass('PlayerGui');local tg=gui and gui:FindFirstChild('TouchGui')
  local controls=tg and tg:FindFirstChild('TouchControlFrame');local button=controls and controls:FindFirstChild('JumpButton')
  if not button or not button.Visible then return false end
  local p,size=button.AbsolutePosition,button.AbsoluteSize;local point=input.Position
  return point.X>=p.X and point.X<=p.X+size.X and point.Y>=p.Y and point.Y<=p.Y+size.Y
 end
 table.insert(connections,UIS.InputBegan:Connect(function(input)
  if jumpTouch(input)then touch=input;press()
  elseif jumpKey(input)then press()end
 end))
 table.insert(connections,UIS.InputEnded:Connect(function(input)if jumpKey(input)or input==touch then release()end end))
 table.insert(connections,UIS.WindowFocusReleased:Connect(release))
 table.insert(connections,player.CharacterRemoving:Connect(function()release();receivedCharacter=nil;receivedSequence=0 end))
 table.insert(connections,net.State.OnClientEvent:Connect(function(s)
  inLobby=s.lobby==true;blocked=s.over==true or s.offers~=nil or s.paused==true or s.queued==true
 end))
 table.insert(connections,net.Effect.OnClientEvent:Connect(function(kind,c,sequence,speed)
  if kind~='airJump'or c~=player.Character then return end
  if receivedCharacter~=c then receivedCharacter=c;receivedSequence=0 end
  if type(sequence)~='number'or sequence<=receivedSequence or type(speed)~='number'or speed<30 or speed>55 then return end
  receivedSequence=sequence
  local _,h,r=characterBody()
  if not h or not r or h.Health<=0 or menu or blocked or h.Sit or h.PlatformStand then return end
  local state=h:GetState()
  if h.FloorMaterial~=Enum.Material.Air or(state~=Enum.HumanoidStateType.Jumping and state~=Enum.HumanoidStateType.Freefall)then return end
  h.Jump=false -- Do not retrigger the native takeoff impulse on the following physics step.
  local v=r.AssemblyLinearVelocity;r.AssemblyLinearVelocity=Vector3.new(v.X,speed,v.Z)
 end))
 return {Press=press,Release=release,SetMenuOpen=function(v)menu=v end,SetSuspended=function(v)suspended=v end,
  Destroy=function()for _,c in connections do c:Disconnect()end;release()end}
end
