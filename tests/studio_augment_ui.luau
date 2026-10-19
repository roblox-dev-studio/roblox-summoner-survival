-- Client engine fixture: real native GUI/controller, isolated state/send recorder.
-- Does not grant XP, select real upgrades or modify the live HUD/template.
local player = game.Players.LocalPlayer
local modules = player.PlayerScripts.SummonerClient.Modules.flow
local host = Instance.new("ScreenGui")
host.Name = "AugmentUIFixture"
host.Parent = player.PlayerGui
local template = game.ReplicatedStorage.SummonerUI.ChoiceOverlay:Clone()
local ui
local ok, result = xpcall(function()
    local authored = template.Modal.AugmentCards.Choice1
    authored.BackgroundColor3 = Color3.fromRGB(46,32,61)
    authored.Title.Position = UDim2.fromOffset(88,33)
    authored.Title.TextSize = 23
    authored.IconTile.IconFallback.TextSize = 18
    template.RarityPalette.rare.Value = Color3.fromRGB(90,240,180)
    local sends = {}
    ui = require(modules.AugmentChoice)({parent=host, template=template,
        icons=require(modules.SkillIcons), inspect=function() end,
        send=function(...) table.insert(sends, table.pack(...)) end})
    local offer = {id="aug_ice_twin", title="쌍빙창", desc="얼음창 2발", tag="얼음", level=1, kind="augment", rarity="rare"}
    local state = {offers={offer}, offerRevision=51, rerolls=2, paused=true}
    ui.Render(state)
    local card = ui.Gui.Modal.AugmentCards.Choice1
    assert(card.BackgroundColor3 == authored.BackgroundColor3 and card.Title.Position == authored.Title.Position, "Designer color/position preserved")
    assert(card.Title.TextSize == 23 and card.IconTile.IconFallback.TextSize == 18 and not card.IconTile.IconFallback.TextScaled, "Designer typography preserved")
    assert(card.Border.Color == template.RarityPalette.rare.Value, "Rarity color comes from editable palette")
    assert(not ui.Gui.Modal.AugmentCards.Choice2.Visible, "Absent choices hidden")
    assert(ui.Choose(1) and not ui.Choose(1) and not ui.Reroll(), "One intent until server acknowledges")
    ui.Render(state)
    assert(not ui.Choose(1) and #sends == 1, "Periodic same revision cannot unlock pending input")
    assert(sends[1][1] == "choose" and sends[1][2] == offer.id and sends[1][3] == 51, "Server contract unchanged")
    state.offerRevision = 52
    ui.Render(state)
    assert(ui.Reroll() and not ui.Reroll() and #sends == 2 and sends[2][2] == 52, "Fresh revision can reroll once")
    state.offerRevision = 53
    state.rerolls = 0
    ui.Render(state)
    assert(not ui.Reroll() and not ui.Gui.Modal.Reroll.Active, "Empty budget blocks reroll")
    ui.Render({lobby=true, offers={offer}, offerRevision=53})
    assert(not ui.Gui.Visible and not ui.Choose(1) and card:GetAttribute("ChoiceId") == nil, "Lobby clears stale card intent")
    ui.Render(state)
    assert(ui.Choose(1), "A new offer after hiding is usable")
    ui.Render({over=true, offers={offer}, offerRevision=53})
    assert(not ui.Gui.Visible and not ui.Choose(1), "Ending cannot submit stale choices")
    assert(template.Modal.AugmentCards.Choice1.Title.Text ~= offer.title, "Template source not mutated")
    -- Engine layout at phone-sized bounds; this is not a physical touch-device test.
    local bounds=Instance.new("Frame");bounds.Size=UDim2.fromOffset(844,390);bounds.Parent=host
    ui.Gui.Parent=bounds
    state.offers={offer,offer,offer};state.offerRevision=54;ui.Render(state);task.wait();task.wait()
    local modal=ui.Gui.Modal;local cards=modal.AugmentCards
    assert(not modal.LuckInfo.Visible and cards.AbsoluteSize.Y >= card.AbsoluteSize.Y, "Landscape keeps a full card visible")
    assert(cards.AbsolutePosition.Y+cards.AbsoluteSize.Y <= modal.Reroll.AbsolutePosition.Y, "Cards do not overlap footer")
    assert(cards.AbsoluteCanvasSize.Y > cards.AbsoluteSize.Y, "Remaining choices scroll in landscape")
    bounds.Size=UDim2.fromOffset(390,844);task.wait();task.wait()
    assert(modal.LuckInfo.Visible and cards.Position==template.Modal.AugmentCards.Position and cards.Size==template.Modal.AugmentCards.Size, "Portrait restores authored layout")
    assert(card.Title.TextBounds.Y <= card.Title.AbsoluteSize.Y and card.Description.TextBounds.Y <= card.Description.AbsoluteSize.Y, "Portrait card text fits")
    return {designerEditsPreserved=true,rarityPalette=true,duplicateBlocked=true,ackRevision=true,zeroBudget=true,hiddenStaleBlocked=true,templateUnchanged=true,landscapeScrollable=true,portraitRestored=true}
end, debug.traceback)
if ui then ui.Destroy() end
template:Destroy()
host:Destroy()
if not ok then error(result) end
return result
