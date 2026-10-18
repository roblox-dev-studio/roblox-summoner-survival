-- Studio-only visual templates. Replicate model instances, never server modules or AI.
local catalog=require(script.Parent.EnemyCatalog)
return function(deps)
 local folder=Instance.new('Folder');folder.Name='EnemyPreviewModels'
 for _,entry in ipairs(catalog.Entries)do
  local model=deps.create(entry.displayName,entry.id,folder)
  model.Name=entry.id
  model:SetAttribute('EnemyKind',entry.id);model:SetAttribute('EnemyRole',entry.role)
  model:SetAttribute('EnemyFamily',entry.family);model:SetAttribute('EnemyVariant',entry.variant)
  model:SetAttribute('FamilyName',entry.familyName);model:SetAttribute('DisplayName',entry.displayName)
  if entry.projectileHeight then model:SetAttribute('ProjectileHeight',entry.projectileHeight)end
  model:SetAttribute('Role',entry.roleLabel);model:SetAttribute('Description',entry.description);model:SetAttribute('Order',entry.order)
 end
 folder.Parent=deps.parent;return folder
end
