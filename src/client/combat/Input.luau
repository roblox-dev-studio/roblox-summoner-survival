-- Keyboard and HUD actions share the same client requests.
return function(deps)
	local UIS = game:GetService("UserInputService")
	local player, net = deps.player, deps.net
	local function requestDash()
		local char=player.Character;local h=char and char:FindFirstChildOfClass("Humanoid");local root=char and char:FindFirstChild("HumanoidRootPart")
		if not h or not root then return end
		local direction=h.MoveDirection.Magnitude>.1 and h.MoveDirection or root.CFrame.LookVector
		net.Action:FireServer("dash",direction)
	end
	local function fireWave() net.Action:FireServer("fireWave") end
	UIS.InputBegan:Connect(function(input,processed)
		if processed then return end
		if input.KeyCode==Enum.KeyCode.Q then net.Action:FireServer("fireWave")
		elseif input.KeyCode==Enum.KeyCode.E then requestDash() end
	end)

	return {
		Dash = requestDash,
		FireWave = fireWave,
	}
end
