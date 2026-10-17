-- Call after existing dodge/offer/attack-once checks. Shields absorb before health.
return function(s,humanoid,amount,effect)
 local absorbed=math.min(s.shield or 0,amount)
 s.shield=math.max(0,(s.shield or 0)-absorbed)
 if absorbed>0 and effect then
  local character=s.player.Character;local root=character and character:FindFirstChild('HumanoidRootPart')
  if root then effect:FireAllClients('wardHit',root.Position,s.shield<=0)end
 end
 if amount>absorbed then humanoid:TakeDamage(amount-absorbed)end
 return amount-absorbed
end
