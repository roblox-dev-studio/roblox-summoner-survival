-- Binds server offers to a script-free, Studio-authored GUI template.
-- Layout, fonts, decorations and card backgrounds remain owned by the designer.
return function(deps)
    local icons = deps.icons
    local overlay = deps.template:Clone()
    overlay.Visible = false
    overlay.Parent = deps.parent
    local modal = overlay:FindFirstChild("Modal")
    assert(modal, "Augment UI contract: missing Modal")
    local function slot(parent, name, className)
        local value = parent:FindFirstChild(name)
        assert(value and value:IsA(className), "Augment UI contract: missing " .. parent:GetFullName() .. "." .. name .. " (" .. className .. ")")
        return value
    end
    local hint = slot(modal, "Hint", "TextLabel")
    local luckInfo = slot(modal, "LuckInfo", "TextLabel")
    local status = slot(modal, "Status", "TextLabel")
    local cards = slot(modal, "AugmentCards", "ScrollingFrame")
    local reroll = slot(modal, "Reroll", "TextButton")
    local inspect = slot(modal, "InspectBuild", "TextButton")
    local palette = slot(overlay, "RarityPalette", "Folder")
    local rarityNames = {common="일반", rare="희귀", epic="영웅"}
    local buttons = {}
    local waiting, revision, rerolls = false, nil, 0
    -- Short landscape screens keep a full card visible. Restore authored layout on resize.
    local normalPosition, normalSize = cards.Position, cards.Size
    local normalLuckVisible = luckInfo.Visible
    local function layout()
        local compact = modal.AbsoluteSize.Y < 480
        local gap = compact and math.max(0, normalPosition.Y.Offset - hint.Position.Y.Offset - hint.Size.Y.Offset - 8) or 0
        luckInfo.Visible = normalLuckVisible and not compact
        cards.Position = normalPosition - UDim2.fromOffset(0, gap)
        cards.Size = normalSize + UDim2.fromOffset(0, gap)
    end
    local resizeConnection = modal:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
    overlay.Destroying:Connect(function() resizeConnection:Disconnect() end)
    layout()
    local function pending(value)
        waiting = value
        status.Text = value and "선택 처리 중…" or ""
        reroll.Active = overlay.Visible and not value and rerolls > 0
        reroll.Selectable = reroll.Active
        for _, item in ipairs(buttons) do
            item.button.Active = overlay.Visible and item.button.Visible and not value
            item.button.Selectable = item.button.Active
        end
    end
    local function choose(index)
        local item = buttons[index]
        if not item or not overlay.Visible or waiting or not item.button.Visible or not revision then return false end
        local id = item.button:GetAttribute("ChoiceId")
        if not id then return false end
        pending(true)
        deps.send("choose", id, revision)
        return true
    end
    local function refresh()
        if not overlay.Visible or waiting or not revision or rerolls <= 0 then return false end
        pending(true)
        deps.send("reroll", revision)
        return true
    end
    for i = 1, 3 do
        local button = slot(cards, "Choice" .. i, "TextButton")
        local tile = slot(button, "IconTile", "Frame")
        buttons[i] = {
            button=button, title=slot(button, "Title", "TextLabel"),
            desc=slot(button, "Description", "TextLabel"), tag=slot(button, "Tag", "TextLabel"),
            image=slot(tile, "SkillIcon", "ImageLabel"), fallback=slot(tile, "IconFallback", "TextLabel"),
            border=slot(button, "Border", "UIStroke"),
        }
        button.Activated:Connect(function() choose(i) end)
    end
    reroll.Activated:Connect(refresh)
    inspect.Activated:Connect(function() if overlay.Visible then deps.inspect() end end)
    local function render(state)
        overlay.Visible = state.offers ~= nil and not state.over and not state.lobby
        if not overlay.Visible then
            revision = nil
            rerolls = 0
            for _, item in ipairs(buttons) do item.button:SetAttribute("ChoiceId", nil) end
            pending(false)
            return
        end
        if revision ~= state.offerRevision then
            revision = state.offerRevision
            waiting = false
            cards.CanvasPosition = Vector2.zero
        end
        rerolls = state.rerolls or 0
        reroll.Text = string.format("무료 새로고침 · %d회", rerolls)
        hint.Text = state.paused and "전투 일시 정지 · 하나를 선택하세요" or "선택하는 동안 보호됩니다 · 하나를 선택하세요"
        local odds = state.offerOdds or {common=100, rare=0, epic=0}
        luckInfo.Text = string.format("행운 +%d · 첫 무작위 칸: 일반 %.1f%% / 희귀 %.1f%% / 영웅 %.1f%%\n다음 칸은 제외 후 재계산 · 단계 강화 1장 보장(가능 시)", state.luck or 0, odds.common, odds.rare, odds.epic)
        for i, item in ipairs(buttons) do
            local offer = state.offers[i]
            item.button.Visible = offer ~= nil
            item.button:SetAttribute("ChoiceId", offer and offer.id or nil)
            if offer then
                local rarity = rarityNames[offer.rarity] and offer.rarity or "common"
                item.tag.Text = string.format("%s · %s / %d%s", rarityNames[rarity], offer.tag, offer.level, offer.kind == "level" and "단계" or "회")
                local color = slot(palette, rarity, "Color3Value").Value
                item.tag.TextColor3 = color
                item.border.Color = color
                item.title.Text = offer.title
                item.desc.Text = offer.desc
                -- Shared icon helper also serves the old loadout. Preserve this template's typography.
                local scaled, wrapped = item.fallback.TextScaled, item.fallback.TextWrapped
                icons.Apply(item.image, offer.id, item.fallback)
                item.fallback.TextScaled, item.fallback.TextWrapped = scaled, wrapped
            end
        end
        pending(waiting)
    end
    return {Gui=overlay, Render=render, Choose=choose, Reroll=refresh, Destroy=function() overlay:Destroy() end}
end
