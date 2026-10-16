-- Reused CC0 R15 leg clips. Roblox Animate keeps ownership of the upper body.
-- Presentation only: no root displacement, jump physics or server state changes.
return function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local folder = script.Parent:WaitForChild("clips")
	local clips = {
		walk = require(folder:WaitForChild("Walk_Carry_Loop")),
		jump = require(folder:WaitForChild("NinjaJump_Start")),
		air = require(folder:WaitForChild("NinjaJump_Idle_Loop")),
		land = require(folder:WaitForChild("NinjaJump_Land")),
	}
	local legs = {LeftHip=true,RightHip=true,LeftKnee=true,RightKnee=true,LeftAnkle=true,RightAnkle=true}
	local records = {}
	local function sample(clip, time)
		local t = clip.Loop and time % clip.Duration or math.clamp(time,0,clip.Duration)
		local frames = clip.Frames
		local index = math.clamp(math.floor(t*60)+1,1,#frames)
		local a, b = frames[index], frames[math.min(index+1,#frames)]
		local alpha = math.clamp((t-a.Time)/math.max(b.Time-a.Time,.00001),0,1)
		local pose = {}
		for name in pairs(legs) do pose[name] = a.Pose[name]:Lerp(b.Pose[name],alpha) end
		return pose
	end
	local function restore(record)
		for motor, transform in pairs(record.restore) do
			if motor.Parent then motor.Transform = transform end
		end
		table.clear(record.restore)
	end
	-- Restore the previous frame before Animator writes; prevents additive drift.
	local before = RunService.PreAnimation:Connect(function()
		for _, record in pairs(records) do restore(record) end
	end)
	local step = RunService.PreSimulation:Connect(function(dt)
		dt = math.min(dt,.1)
		local live = {}
		for _, player in ipairs(Players:GetPlayers()) do
			local character = player.Character
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			local root = character and character:FindFirstChild("HumanoidRootPart")
			if not humanoid or not root or humanoid.RigType ~= Enum.HumanoidRigType.R15 then continue end
			live[character] = true
			local record = records[character]
			if not record then
				record = {motors={},restore={},phase=0,time=0,weight=0,mode="idle",wasAir=false,pose=nil}
				for _, child in ipairs(character:GetDescendants()) do
					if child:IsA("Motor6D") and legs[child.Name] then record.motors[child.Name] = child end
				end
				records[character] = record
			end
			local state = humanoid:GetState()
			local velocity = root.AssemblyLinearVelocity
			local speed = Vector3.new(velocity.X,0,velocity.Z).Magnitude
			local airborne = state==Enum.HumanoidStateType.Jumping or state==Enum.HumanoidStateType.Freefall
			local blocked = humanoid.Health<=0 or humanoid.WalkSpeed<=0 or humanoid.Sit or humanoid.PlatformStand
				or state==Enum.HumanoidStateType.Swimming or state==Enum.HumanoidStateType.Climbing
			local mode = "idle"
			if not blocked then
				if airborne then
					mode = (not record.wasAir or (record.mode=="jump" and record.time<.18)) and "jump" or "air"
				elseif record.wasAir or (record.mode=="land" and record.time<.2) then mode="land"
				elseif speed>1 and humanoid.AutoRotate then mode="walk" end
			end
			if mode~=record.mode then record.time=0;record.mode=mode end
			record.time+=dt;record.wasAir=airborne
			local target = clips[mode]
			if target then
				local time = record.time
				if mode=="walk" then
					record.phase+=dt*math.clamp(speed/7,.5,3.5);time=record.phase
				elseif mode=="jump" then time=math.min(time/.18,1)*target.Duration
				elseif mode=="land" then time=math.min(time/.2,1)*target.Duration end
				local pose=sample(target,time)
				if record.pose then for name,value in pairs(pose) do pose[name]=record.pose[name]:Lerp(value,1-math.exp(-dt*22)) end end
				record.pose=pose
			end
			record.weight+=( (target and 1 or 0)-record.weight)*(1-math.exp(-dt*18))
			if humanoid.Health<=0 then record.weight=0 end
			if record.pose and record.weight>.001 then
				for name,motor in pairs(record.motors) do
					if motor.Parent then record.restore[motor]=motor.Transform;motor.Transform=motor.Transform:Lerp(record.pose[name],record.weight) end
				end
			end
			character:SetAttribute("SummonerMotion",mode)
		end
		for character,record in pairs(records) do
			if not live[character] then restore(record);records[character]=nil end
		end
	end)
	return {Destroy=function()
		before:Disconnect();step:Disconnect()
		for character,record in pairs(records) do restore(record);character:SetAttribute("SummonerMotion",nil) end
		table.clear(records)
	end}
end
