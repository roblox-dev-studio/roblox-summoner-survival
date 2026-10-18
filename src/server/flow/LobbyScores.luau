-- Server-only, in-memory records for connected players. No DataStore or client writes.
-- A completed normal run contributes its authoritative kill count exactly once.
return function()
 local entries,owners={},{}
 local finished=setmetatable({},{__mode='k'})
 local cached
 local function integer(value,nonnegative)
  return type(value)=='number'and value==value and math.abs(value)<=9007199254740991 and value%1==0 and(not nonnegative or value>=0)
 end
 local function add(player)
  if not player or not integer(player.UserId,false)or type(player.Name)~='string'or player.Name==''then return false end
  local owner=owners[player.UserId];if owner and owner~=player then return false end
  local name=type(player.DisplayName)=='string'and player.DisplayName~=''and player.DisplayName or player.Name
  local existing=entries[player]
  if existing then if existing.name~=name then existing.name=name;cached=nil end;return true end
  owners[player.UserId]=player;entries[player]={userId=player.UserId,name=name};cached=nil;return true
 end
 local function record(state,result)
  if type(state)~='table'or finished[state]or not entries[state.player]then return false end
  if result~='defeat'and result~='victory'and result~='retreat'then return false end
  if state.over~=true or state.result~=result or state.lobby then return false end
  finished[state]=true
  if state.bossTest or state.fieldBossTest or not integer(state.kills,true)then return false end
  local entry=entries[state.player]
  if entry.bestScore==nil or state.kills>entry.bestScore then entry.bestScore=state.kills;cached=nil;return true end
  return false
 end
 local function remove(player)
  local entry=entries[player];if not entry then return end
  entries[player]=nil;if owners[entry.userId]==player then owners[entry.userId]=nil end;cached=nil
 end
 local function snapshot()
  if not cached then
   cached={}
   for _,entry in pairs(entries)do if entry.bestScore~=nil then table.insert(cached,{userId=entry.userId,name=entry.name,bestScore=entry.bestScore})end end
   table.sort(cached,function(a,b)if a.bestScore==b.bestScore then return a.userId<b.userId end;return a.bestScore>b.bestScore end)
   while #cached>20 do table.remove(cached)end
  end
  local result={};for i,entry in ipairs(cached)do result[i]={userId=entry.userId,name=entry.name,bestScore=entry.bestScore}end;return result
 end
 return {Add=add,Record=record,Remove=remove,Snapshot=snapshot}
end
