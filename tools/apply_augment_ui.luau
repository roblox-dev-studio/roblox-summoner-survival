-- Edit Command Bar: validate the edited preview before replacing the local template.
-- This changes the local place only. Save ChoiceOverlay as .rbxmx for Git handoff.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before applying a GUI design")
local preview = game.StarterGui:FindFirstChild("AugmentDesignPreview")
assert(preview and preview:FindFirstChild("ChoiceOverlay"), "Run tools/preview_augment_ui.luau first")
local candidate = preview.ChoiceOverlay
for _, item in ipairs(candidate:GetDescendants()) do
    assert(not item:IsA("LuaSourceContainer"), "GUI asset must not contain scripts")
end
local folder = game.ReplicatedStorage:WaitForChild("SummonerUI")
local modules = game.StarterPlayer.StarterPlayerScripts.SummonerClient.Modules.flow
local holder = Instance.new("Folder")
-- Edit-mode require caches survive Source changes. Validate the current saved code.
local validator = modules.AugmentChoice:Clone()
local iconModule = modules.SkillIcons:Clone()
local ok, result = pcall(function()
    local view = require(validator)({
        parent=holder, template=candidate, icons=require(iconModule),
        send=function() error("Design validation must not send actions") end, inspect=function() end,
    })
    for _, rarity in ipairs({"common", "rare", "epic"}) do
        view.Render({offers={{id="ice",title="검수",desc="배치 유지",tag="마법",level=1,kind="level",rarity=rarity}},offerRevision=1})
    end
end)
holder:Destroy()
validator:Destroy()
iconModule:Destroy()
assert(ok, result)
local copy = candidate:Clone()
copy.Visible = false
local previous = folder:FindFirstChild("ChoiceOverlay")
if previous then previous:Destroy() end
copy.Parent = folder
game:GetService("Selection"):Set({candidate})
return "Local template updated. Save selected ChoiceOverlay as assets/ui/augment-choice.rbxmx, then rebuild and check."
