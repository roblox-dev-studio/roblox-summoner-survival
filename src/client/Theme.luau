local palette={bg=Color3.fromRGB(15,25,34),card=Color3.fromRGB(25,40,50),text=Color3.fromRGB(234,244,244),muted=Color3.fromRGB(155,182,188),mint=Color3.fromRGB(93,242,207),gold=Color3.fromRGB(255,196,103)}
local function make(class,parent,props)
	local obj=Instance.new(class); for k,v in pairs(props) do obj[k]=v end; obj.Parent=parent; return obj
end
local function round(obj,radius) make("UICorner",obj,{CornerRadius=UDim.new(0,radius or 12)}) end
local function stroke(obj,color) make("UIStroke",obj,{Color=color or Color3.fromRGB(57,82,91),Thickness=1}) end
local function label(parent,text,size,pos,font,color)
	return make("TextLabel",parent,{BackgroundTransparency=1,Text=text,Size=size,Position=pos or UDim2.new(),Font=font or Enum.Font.GothamMedium,TextColor3=color or palette.text,TextSize=16,TextWrapped=true})
end
return {Palette=palette, Make=make, Round=round, Stroke=stroke, Label=label}
