-- Generated KayKit CC0 geometry; chunks respect Studio Source size limits.
local data={positions={},normals={},colors={},weights={},triangles=require(script.Parent.Triangles)}
for _,v in ipairs(require(script.Parent.Vertices1))do table.insert(data.positions,v[1]);table.insert(data.normals,v[2]);table.insert(data.colors,v[3]);table.insert(data.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices2))do table.insert(data.positions,v[1]);table.insert(data.normals,v[2]);table.insert(data.colors,v[3]);table.insert(data.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices3))do table.insert(data.positions,v[1]);table.insert(data.normals,v[2]);table.insert(data.colors,v[3]);table.insert(data.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices4))do table.insert(data.positions,v[1]);table.insert(data.normals,v[2]);table.insert(data.colors,v[3]);table.insert(data.weights,v[4])end
return data
