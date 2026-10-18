-- Studio-only visual templates. Replicate model instances, never server modules or AI.
return function(deps)
 local folder=Instance.new('Folder');folder.Name='EnemyPreviewModels'
 local entries={
  {'stalker','잿빛 해골 병사','해골 근접형','고대 왕국의 해골 병사. 플레이어를 추적하며 가까이 붙으면 공격합니다. 정예는 검과 방패로 무장합니다.'},
  {'skitter','쌍검 해골 도적','빠른 측면 접근','두 자루의 검과 두건을 쓴 해골 도적. 옆으로 파고들어 플레이어를 포위합니다.'},
  {'brute','철갑 해골 집행자','느리고 튼튼한 중갑형','큰 도끼와 방패를 든 중갑 해골. 느리지만 체력과 접촉 피해가 높습니다.'},
  {'caster','황혼 해골 마도사','지팡이 원거리 마법탄','커다란 모자와 지팡이를 든 해골 마법사. 거리를 유지하며 힘을 모아 보라색 마법탄을 쏩니다.'},
  {'ember','불씨 폭탄 운반꾼','폭탄을 안고 접근 후 자폭','불붙은 폭탄을 안고 달려옵니다. 붉은 범위가 나타나면 폭발 전에 벗어나거나 처치하세요.'},
  {'charger','잿불 뿔사냥개','사족 보행과 직선 돌진','갈비 갑옷과 긴 꼬리, 잿빛 두개골을 가진 사냥개. 주황색 경로를 예고한 뒤 직선으로 돌진합니다.'},
 }
 for index,entry in ipairs(entries)do
  local model=deps.create(entry[2],entry[1],folder)
  model.Name=entry[1];model:SetAttribute('DisplayName',entry[2]);model:SetAttribute('Role',entry[3]);model:SetAttribute('Description',entry[4]);model:SetAttribute('Order',index)
 end
 folder.Parent=deps.parent;return folder
end
