local frames={}
for _,f in ipairs(require(script.Parent.WalkFrames1))do table.insert(frames,f)end
for _,f in ipairs(require(script.Parent.WalkFrames2))do table.insert(frames,f)end
for _,f in ipairs(require(script.Parent.WalkFrames3))do table.insert(frames,f)end
return {duration=1.1666666269302368,frames=frames}
