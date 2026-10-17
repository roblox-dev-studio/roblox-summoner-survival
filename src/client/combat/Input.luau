-- Fire along the character's facing, independent of pointer and camera position.
return function(deps)
 local UIS=game:GetService('UserInputService')
 local player,net=deps.player,deps.net
 local suspended=false
 local function requestDash()
  if suspended then return end
  local char=player.Character;local h=char and char:FindFirstChildOfClass('Humanoid');local root=char and char:FindFirstChild('HumanoidRootPart')
  if not h or not root then return end
  net.Action:FireServer('dash',h.MoveDirection.Magnitude>.1 and h.MoveDirection or root.CFrame.LookVector)
 end
 local function fireWave()
  if suspended then return end
  local char=player.Character;local root=char and char:FindFirstChild('HumanoidRootPart')
  if root then net.Action:FireServer('fireWave',root.CFrame.LookVector) end
 end
 UIS.InputBegan:Connect(function(input,processed)
  if processed then return end
  if input.KeyCode==Enum.KeyCode.Q or input.KeyCode==Enum.KeyCode.ButtonR2 then fireWave()
  elseif input.KeyCode==Enum.KeyCode.E or input.KeyCode==Enum.KeyCode.ButtonB then requestDash() end
 end)
 return {Dash=requestDash,FireWave=fireWave,SetSuspended=function(value)suspended=value end}
end
