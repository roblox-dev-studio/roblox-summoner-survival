-- Standard Roblox orbit camera setup.
return function(deps)
	local player = deps.player
	-- Roblox's standard camera supplies mouse orbit, wheel zoom and touch controls.
	local function bindCamera(character)
		local humanoid=character:WaitForChild("Humanoid")
		local root=character:WaitForChild("HumanoidRootPart")
		if player.Character~=character then return end
		local camera=workspace.CurrentCamera
		player.CameraMode=Enum.CameraMode.Classic
		player.CameraMaxZoomDistance=85
		player.CameraMinZoomDistance=32
		camera.CameraSubject=humanoid
		camera.CameraType=Enum.CameraType.Custom
		camera.FieldOfView=65
		camera.CFrame=CFrame.lookAt(root.Position+Vector3.new(0,28,24),root.Position)
		task.delay(.4,function()
			if player.Character==character then player.CameraMinZoomDistance=10 end
		end)
	end
	player.CharacterAdded:Connect(function(character) task.spawn(bindCamera,character) end)
	if player.Character then task.spawn(bindCamera,player.Character) end

	return {
	}
end
