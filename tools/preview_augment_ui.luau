-- Run in Edit Command Bar after installing. Never edit the runtime PlayerGui copy.
-- Edit StarterGui.AugmentDesignPreview.ChoiceOverlay, then Save to File as .rbxmx.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before editing the GUI source")
local starterGui = game:GetService("StarterGui")
local preview = starterGui:FindFirstChild("AugmentDesignPreview")
if preview then
    game:GetService("Selection"):Set({preview.ChoiceOverlay})
    return "Existing design preview selected; edits preserved"
end
local template = game.ReplicatedStorage:WaitForChild("SummonerUI"):WaitForChild("ChoiceOverlay")
preview = Instance.new("ScreenGui")
preview.Name = "AugmentDesignPreview"
preview.ResetOnSpawn = false
preview.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local overlay = template:Clone()
overlay.Visible = true
overlay.Parent = preview
preview.Parent = starterGui
game:GetService("Selection"):Set({overlay})
return "Edit ChoiceOverlay, run tools/apply_augment_ui.luau, then Save only that Frame as assets/ui/augment-choice.rbxmx."
