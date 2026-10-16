-- Run in a NEW, empty Studio project's Command Bar, in edit mode.
assert(not game:GetService("RunService"):IsRunning(), "Stop Play before installing")
assert(not workspace:FindFirstChild("SummonerArena"), "SummonerArena already exists; installation cancelled")
assert(not game.ReplicatedStorage:FindFirstChild("SummonerNet"), "SummonerNet already exists; installation cancelled")
assert(not game.ServerScriptService:FindFirstChild("SummonerServer"), "SummonerServer already exists; installation cancelled")
assert(not game.StarterPlayer.StarterPlayerScripts:FindFirstChild("SummonerClient"), "SummonerClient already exists; installation cancelled");
(function()
-- @ARENA@

end)()
local folder=Instance.new("Folder"); folder.Name="SummonerNet"
for _,name in ipairs({"State","Action","Effect"}) do local r=Instance.new("RemoteEvent"); r.Name=name; r.Parent=folder end
folder.Parent=game.ReplicatedStorage
-- Optional public mesh. Built-in dust and procedural debris work if import is unavailable.
do
    local ok, model = pcall(function() return game:GetService("InsertService"):LoadAsset(12192129638) end)
    if ok and model then
        local source = model:FindFirstChild("GroundSpikes", true)
        if source and source:IsA("MeshPart") and not game.ReplicatedStorage:FindFirstChild("SummonerVFXAssets") then
            local folder = Instance.new("Folder"); folder.Name = "SummonerVFXAssets"
            local mesh = source:Clone(); mesh:ClearAllChildren(); mesh.Name = "GroundSpikes"
            mesh.Anchored = true; mesh.CanCollide = false; mesh.CanTouch = false; mesh.CanQuery = false; mesh.CastShadow = false
            mesh:SetAttribute("Source", "https://create.roblox.com/store/asset/12192129638")
            mesh:SetAttribute("Creator", "clotuder"); mesh:SetAttribute("Terms", "Roblox Creator Store Terms; not CC0")
            mesh.Parent = folder; folder.Parent = game.ReplicatedStorage
        end
        model:Destroy()
    end
end
