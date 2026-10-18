local d={positions={},normals={},colors={},weights={},triangles=require(script.Parent.Triangles)}
for _,v in ipairs(require(script.Parent.Vertices1))do table.insert(d.positions,v[1]);table.insert(d.normals,v[2]);table.insert(d.colors,v[3]);table.insert(d.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices2))do table.insert(d.positions,v[1]);table.insert(d.normals,v[2]);table.insert(d.colors,v[3]);table.insert(d.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices3))do table.insert(d.positions,v[1]);table.insert(d.normals,v[2]);table.insert(d.colors,v[3]);table.insert(d.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices4))do table.insert(d.positions,v[1]);table.insert(d.normals,v[2]);table.insert(d.colors,v[3]);table.insert(d.weights,v[4])end
for _,v in ipairs(require(script.Parent.Vertices5))do table.insert(d.positions,v[1]);table.insert(d.normals,v[2]);table.insert(d.colors,v[3]);table.insert(d.weights,v[4])end
return d
