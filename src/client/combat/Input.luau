-- Movement-facing Q and held basic attack. No pointer aiming or client damage.
return function(deps)
 local UIS=game:GetService('UserInputService');local Run=game:GetService('RunService')
 local player,net=deps.player,deps.net
 local suspended,basicBlocked=false,false;local held={};local basicClock=0;local hudInput
 local function clearHeld()table.clear(held);basicClock=0;hudInput=nil end
 local function setBasicHeld(source,value,input)
  if value and(suspended or basicBlocked or UIS:GetFocusedTextBox())then return end
  if source=='HUD'then
   if not value and input and hudInput and input~=hudInput then return end
   hudInput=value and input or nil
  end
  held[source]=value and true or nil
 end
 local function requestDash()
  if suspended then return end
  local char=player.Character;local h=char and char:FindFirstChildOfClass('Humanoid');local root=char and char:FindFirstChild('HumanoidRootPart')
  if not h or not root then return end
  net.Action:FireServer('dash',h.MoveDirection.Magnitude>.1 and h.MoveDirection or root.CFrame.LookVector)
 end
 local function fireWave()
  if suspended then return end
  local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
  if root then net.Action:FireServer('fireWave',root.CFrame.LookVector)end
 end
 local function basicKey(input)
  if input.KeyCode==Enum.KeyCode.F then return 'F'end
  if input.KeyCode==Enum.KeyCode.ButtonR1 then return 'R1'end
  if input.UserInputType==Enum.UserInputType.MouseButton1 then return 'Mouse'end
 end
 UIS.InputBegan:Connect(function(input,processed)
  if processed then return end
  local key=basicKey(input)
  if key then setBasicHeld(key,true)
  elseif input.KeyCode==Enum.KeyCode.Q or input.KeyCode==Enum.KeyCode.ButtonR2 then fireWave()
  elseif input.KeyCode==Enum.KeyCode.E or input.KeyCode==Enum.KeyCode.ButtonB then requestDash()end
 end)
 UIS.InputEnded:Connect(function(input)
  local key=basicKey(input);if key then setBasicHeld(key,false)end
  if input==hudInput then setBasicHeld('HUD',false,input)end
 end)
 UIS.WindowFocusReleased:Connect(clearHeld);player.CharacterRemoving:Connect(clearHeld)
 Run.Heartbeat:Connect(function(dt)
  if suspended or basicBlocked or not next(held)or UIS:GetFocusedTextBox()then basicClock=0;return end
  basicClock-=dt
  if basicClock<=0 then basicClock=.1;net.Action:FireServer('basicAttack')end
 end)
 return {Dash=requestDash,FireWave=fireWave,SetBasicHeld=setBasicHeld,
  SetBasicBlocked=function(value)basicBlocked=value;if value then clearHeld()end end,
  SetSuspended=function(value)suspended=value;if value then clearHeld()end end}
end
