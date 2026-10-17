-- Server-owned basic-attack profiles. Future equipment chooses an allowed profile ID.
local profiles={
 starlightWand={name='별빛 지팡이',style='starlight',interval=.3,damage=13,speed=80,range=52,radius=1.6},
}
local function get(id)return profiles[id]or profiles.starlightWand end
return {Get=get,Default='starlightWand'}
