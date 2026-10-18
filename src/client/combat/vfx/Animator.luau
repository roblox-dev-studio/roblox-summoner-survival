--!strict
--[[
	Animator
	One frame loop for every running effect, instead of one Tween / RenderStepped
	connection per part.

	Why not only TweenService?
	  * Multi-phase curves (spawn -> hold -> dissipate) from ONE normalized time value.
	  * Time-scale groups: Hitstop can freeze every "world" effect for 80 ms, then resume.
	  * CFrame writes are batched into a single workspace:BulkMoveTo call per frame.
	  * A thrown error in one effect never kills the others (and cleanup still runs).
	TweenService is still perfect for fire-and-forget single-property tweens.

	Usage:
		Animator.play(0.4, function(t, dt)
			part.Transparency = Ease.inQuad(t)
			Animator.move(part, origin * CFrame.Angles(0, t * math.pi, 0))
		end, { group = "world", onComplete = function() pool:release(part) end })

		Animator.setTimeScale("world", 0) -- freeze (hitstop)
]]

local RunService = game:GetService("RunService")

export type StepFn = (t: number, dt: number, elapsed: number) -> ()
export type CompleteFn = (cancelled: boolean) -> ()

export type PlayOptions = {
	group: string?, -- time-scale group, default "world"
	delay: number?, -- seconds (time-scaled) before the first step
	onComplete: CompleteFn?, -- always called once: finished, cancelled or errored
}

export type Handle = {
	cancel: (self: Handle) -> (),
	isDone: (self: Handle) -> boolean,
}

type Job = {
	duration: number,
	delay: number,
	elapsed: number,
	step: StepFn?,
	onComplete: CompleteFn?,
	group: string,
	done: boolean,
}

local Animator = {}

local jobs: { Job } = {}
local timeScales: { [string]: number } = {}
local moveParts: { BasePart } = {}
local moveCFrames: { CFrame } = {}
local connection: RBXScriptConnection? = nil

local function finish(job: Job, cancelled: boolean)
	if job.done then
		return
	end
	job.done = true
	local onComplete = job.onComplete
	job.onComplete = nil
	job.step = nil
	if onComplete then
		local ok, err = (pcall :: any)(onComplete, cancelled)
		if not ok then
			warn("[VFX.Animator] onComplete error:", err)
		end
	end
end

local function flushMoves()
	if #moveParts > 0 then
		workspace:BulkMoveTo(moveParts, moveCFrames, Enum.BulkMoveMode.FireCFrameChanged)
		table.clear(moveParts)
		table.clear(moveCFrames)
	end
end

local completed: { Job } = {}
local failed: { Job } = {}

local function onFrame(dt: number)
	local count = #jobs -- jobs added during this frame start next frame
	for i = 1, count do
		local job = jobs[i]
		if job.done then
			continue
		end
		local scaledDt = dt * (timeScales[job.group] or 1)
		job.elapsed += scaledDt
		local active = job.elapsed - job.delay
		if active < 0 then
			continue
		end
		local t = if job.duration == math.huge then 0 else math.min(active / job.duration, 1)
		local step = job.step
		if step then
			local ok, err = (pcall :: any)(step, t, scaledDt, active)
			if not ok then
				warn("[VFX.Animator] step error:", err)
				table.insert(failed, job)
				continue
			end
		end
		if t >= 1 then
			table.insert(completed, job)
		end
	end

	-- Flush CFrame writes BEFORE completion callbacks: a callback that parks a pooled
	-- part must win over the part's last queued move.
	flushMoves()

	for _, job in completed do
		finish(job, false)
	end
	for _, job in failed do
		finish(job, true)
	end
	table.clear(completed)
	table.clear(failed)

	-- Compact finished jobs (stable order).
	local write = 0
	for read = 1, #jobs do
		local job = jobs[read]
		if not job.done then
			write += 1
			jobs[write] = job
		end
	end
	for i = #jobs, write + 1, -1 do
		jobs[i] = nil
	end

	if #jobs == 0 and #moveParts == 0 and connection then
		connection:Disconnect()
		connection = nil
	end
end

local function ensureRunning()
	if connection == nil then
		local event = if RunService:IsClient() then RunService.PreRender else RunService.Heartbeat
		connection = event:Connect(onFrame)
	end
end

local HandleMethods = {}
HandleMethods.__index = HandleMethods

function HandleMethods.cancel(self: any)
	finish(self._job, true)
end

function HandleMethods.isDone(self: any): boolean
	return self._job.done
end

local function makeHandle(job: Job): Handle
	return (setmetatable({ _job = job }, HandleMethods) :: any) :: Handle
end

-- Runs `step(t, dt, elapsed)` every frame for `duration` seconds (t goes 0 -> 1).
-- The last call always receives t == 1 exactly.
function Animator.play(duration: number, step: StepFn, options: PlayOptions?): Handle
	local job: Job = {
		duration = math.max(duration, 1e-3),
		delay = if options and options.delay then options.delay else 0,
		elapsed = 0,
		step = step,
		onComplete = options and options.onComplete,
		group = if options and options.group then options.group else "world",
		done = false,
	}
	table.insert(jobs, job)
	ensureRunning()
	return makeHandle(job)
end

-- Runs `step(dt, elapsed)` every frame until the handle is cancelled.
function Animator.bind(step: (dt: number, elapsed: number) -> (), options: PlayOptions?): Handle
	return Animator.play(math.huge, function(_t, dt, elapsed)
		step(dt, elapsed)
	end, options)
end

-- Time-scaled delay (respects hitstop freezes, unlike task.delay).
function Animator.delay(seconds: number, callback: () -> (), group: string?): Handle
	return Animator.play(1e-3, function() end, {
		delay = seconds,
		group = group,
		onComplete = function(cancelled)
			if not cancelled then
				callback()
			end
		end,
	})
end

function Animator.setTimeScale(group: string, scale: number)
	timeScales[group] = math.max(scale, 0)
end

function Animator.getTimeScale(group: string): number
	return timeScales[group] or 1
end

-- Queues a CFrame write, flushed once per frame with workspace:BulkMoveTo.
function Animator.move(part: BasePart, cframe: CFrame)
	table.insert(moveParts, part)
	table.insert(moveCFrames, cframe)
	ensureRunning()
end

function Animator.activeCount(): number
	return #jobs
end

-- Test hook: advances one frame manually.
Animator._step = onFrame

return Animator
