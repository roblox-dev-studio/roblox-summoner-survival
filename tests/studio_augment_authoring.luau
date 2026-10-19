-- Edit engine fixture. Supply preview/apply callbacks from the two tools/*.luau files.
-- Real authored instances and selection are restored even when an assertion fails.
return function(commands)
    assert(not game:GetService("RunService"):IsRunning(), "Run authoring fixture in Edit")
    local starter = game.StarterGui
    local folder = game.ReplicatedStorage.SummonerUI
    local original = folder.ChoiceOverlay
    local preview = starter:FindFirstChild("AugmentDesignPreview")
    local selection = game:GetService("Selection")
    local selected = selection:Get()
    local modules = game.StarterPlayer.StarterPlayerScripts.SummonerClient.Modules.flow
    local originalValidator = modules.AugmentChoice
    local validator = originalValidator:Clone()
    -- Prime an obsolete permissive validator, then replace its Source as an editor would.
    validator.Source = "return function() return {Render=function() end} end"
    require(validator)
    validator.Source = originalValidator.Source
    originalValidator.Parent = nil
    validator.Parent = modules
    local initial = original:Clone()
    original.Parent = nil
    if preview then preview.Parent = nil end
    initial.Parent = folder
    local ok, result = xpcall(function()
        commands.preview()
        local authored = starter.AugmentDesignPreview.ChoiceOverlay
        authored.Modal.Title.Text = "팀원 편집 검수"
        authored.Modal.AugmentCards.Choice1.BackgroundColor3 = Color3.fromRGB(46,32,61)
        commands.preview()
        assert(starter.AugmentDesignPreview.ChoiceOverlay == authored and authored.Modal.Title.Text == "팀원 편집 검수", "Preview preserves existing edits")

        local layout = authored.Modal.AugmentCards.Layout
        layout.Parent = nil
        local accepted, failure = pcall(commands.apply)
        layout.Parent = authored.Modal.AugmentCards
        assert(not accepted and string.find(tostring(failure), "Layout", 1, true), "Invalid edited layout is rejected")
        assert(folder.ChoiceOverlay == initial, "Rejected design keeps previous template instance")

        local bundled = Instance.new("LocalScript")
        bundled.Name = "RejectedFixtureScript"
        bundled.Parent = authored
        local scriptAccepted = pcall(commands.apply)
        bundled:Destroy()
        assert(not scriptAccepted and folder.ChoiceOverlay == initial, "Bundled scripts rejected without replacement")

        commands.apply()
        local applied = folder.ChoiceOverlay
        assert(applied ~= initial and applied ~= authored and not applied.Visible, "Valid design is cloned as hidden runtime template")
        assert(applied.Modal.Title.Text == authored.Modal.Title.Text, "Edited static title retained")
        assert(applied.Modal.AugmentCards.Choice1.BackgroundColor3 == authored.Modal.AugmentCards.Choice1.BackgroundColor3, "Edited card color retained")
        assert(authored.Parent == starter.AugmentDesignPreview, "Designer source remains editable")
        return {previewEditsPreserved=true,missingLayoutRejected=true,scriptRejected=true,failedApplyPreserved=true,validApplyCopied=true,currentSourceValidated=true}
    end, debug.traceback)
    local temporaryPreview = starter:FindFirstChild("AugmentDesignPreview")
    if temporaryPreview then temporaryPreview:Destroy() end
    local temporaryTemplate = folder:FindFirstChild("ChoiceOverlay")
    if temporaryTemplate then temporaryTemplate:Destroy() end
    original.Parent = folder
    if preview then preview.Parent = starter end
    validator:Destroy()
    originalValidator.Parent = modules
    selection:Set(selected)
    if not ok then error(result) end
    return result
end
