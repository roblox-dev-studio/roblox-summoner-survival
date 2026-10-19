"""Compile a script-free Roblox XML GUI into deterministic installer statements.

The .rbxmx is the editable source, including Studio-authored decorations. Unsupported
classes/properties fail the build instead of silently losing a designer's work.
"""
import json
import math
import xml.etree.ElementTree as ET

CLASSES = {
    "Frame", "TextLabel", "TextButton", "ImageLabel", "ImageButton", "ScrollingFrame",
    "UICorner", "UIStroke", "UIGradient", "UIPadding", "UIListLayout", "UIGridLayout",
    "UIAspectRatioConstraint", "UISizeConstraint", "UITextSizeConstraint", "UIScale",
    "Folder", "Color3Value", "StringValue", "NumberValue", "BoolValue",
}
# Studio serialization metadata, not visible design properties.
METADATA = {"SourceAssetId", "UniqueId", "HistoryId", "Capabilities", "DefinesCapabilities"}


def validate_contract(root):
    required = {"RarityPalette": "Folder", "Modal": "Frame"}
    required.update({f"RarityPalette/{name}": "Color3Value" for name in ("common", "rare", "epic")})
    required.update({f"Modal/{name}": "TextLabel" for name in ("Title", "Hint", "LuckInfo", "Status")})
    required.update({f"Modal/{name}": "TextButton" for name in ("Reroll", "InspectBuild")})
    required["Modal/AugmentCards"] = "ScrollingFrame"
    for i in range(1, 4):
        card = f"Modal/AugmentCards/Choice{i}"
        required[card] = "TextButton"
        required.update({f"{card}/{name}": "TextLabel" for name in ("Title", "Description", "Tag")})
        required.update({f"{card}/Border": "UIStroke", f"{card}/IconTile": "Frame",
                         f"{card}/IconTile/SkillIcon": "ImageLabel", f"{card}/IconTile/IconFallback": "TextLabel"})
    paths = {}

    def walk(node, prefix):
        siblings = set()
        for child in node.findall("Item"):
            name = child.findtext("Properties/string[@name='Name']")
            if not name or name in siblings:
                raise ValueError(f"Missing/duplicate GUI sibling name: {prefix}/{name}")
            siblings.add(name)
            path = f"{prefix}/{name}" if prefix else name
            paths[path] = child.get("class")
            walk(child, path)

    walk(root, "")
    for path, kind in required.items():
        if paths.get(path) != kind:
            raise ValueError(f"GUI contract requires {path} ({kind})")


def quote(value):
    return json.dumps(value, ensure_ascii=False)


def number(value):
    result = float(value)
    if not math.isfinite(result):
        raise ValueError("Non-finite GUI property")
    return format(result, ".12g")


def expression(prop):
    tag, value = prop.tag, prop.text or ""
    if tag == "string":
        return quote(value)
    if tag == "bool":
        if value not in ("true", "false"):
            raise ValueError("Invalid GUI boolean")
        return value
    if tag in ("float", "double", "int", "int64"):
        return number(value)
    if tag == "Content":
        if prop.find("null") is not None:
            return '""'
        if prop.find("url") is not None:
            return quote(prop.findtext("url", ""))
    fields = {
        "UDim": ("S", "O"), "UDim2": ("XS", "XO", "YS", "YO"),
        "Vector2": ("X", "Y"), "Color3": ("R", "G", "B"),
    }
    if tag in fields:
        return tag + ".new(" + ",".join(number(prop.findtext(f)) for f in fields[tag]) + ")"
    if tag == "Color3uint8":
        color = int(value)
        return f"Color3.fromRGB({(color >> 16) & 255},{(color >> 8) & 255},{color & 255})"
    if tag == "Rect2D":
        values = [number(prop.findtext(f"{corner}/{axis}")) for corner in ("min", "max") for axis in ("X", "Y")]
        return "Rect.new(" + ",".join(values) + ")"
    if tag in ("ColorSequence", "NumberSequence"):
        values = value.split()
        stride = 5 if tag == "ColorSequence" else 3
        if len(values) < 2 * stride or len(values) % stride:
            raise ValueError("Invalid GUI sequence")
        keys = []
        for i in range(0, len(values), stride):
            row = [number(v) for v in values[i:i + stride]]
            if tag == "ColorSequence":
                keys.append(f"ColorSequenceKeypoint.new({row[0]},Color3.new({','.join(row[1:4])}))")
            else:
                keys.append("NumberSequenceKeypoint.new(" + ",".join(row) + ")")
        return tag + ".new({" + ",".join(keys) + "})"
    if tag == "Font":
        family = prop.findtext("Family/url")
        if family:
            return (f"Font.new({quote(family)},enumValue(Enum.FontWeight,{number(prop.findtext('Weight'))}),"
                    f"enumValue(Enum.FontStyle,{number(prop.findtext('Style'))}))")
    raise ValueError(f"Unsupported GUI property type {tag}: {prop.get('name')}")


def compile_model(path):
    document = ET.parse(path).getroot()
    roots = document.findall("Item")
    if len(roots) != 1 or roots[0].get("class") != "Frame":
        raise ValueError("GUI must contain exactly one root Frame")
    if roots[0].findtext("Properties/string[@name='Name']") != "ChoiceOverlay":
        raise ValueError("GUI root must be named ChoiceOverlay")
    validate_contract(roots[0])
    items = list(roots[0].iter("Item"))
    indices = {id(item): i for i, item in enumerate(items, 1)}
    refs = {item.get("referent"): indices[id(item)] for item in items if item.get("referent")}
    output = ["-- Source: assets/ui/augment-choice.rbxmx", "do", "local nodes={}",
              "local function enumValue(kind,value)",
              "    for _,item in ipairs(kind:GetEnumItems()) do if item.Value==value then return item end end",
              '    error("Invalid GUI enum: "..tostring(kind).." / "..tostring(value))', "end"]
    deferred = []
    for item in items:
        index, kind = indices[id(item)], item.get("class")
        if kind not in CLASSES:
            raise ValueError(f"Unsupported GUI class {kind}; scripts are never allowed in this asset")
        output.append(f"nodes[{index}]=Instance.new({quote(kind)})")
        seen = set()
        for prop in item.findall("Properties/*"):
            name = prop.get("name")
            if not name or name in seen:
                raise ValueError(f"Missing/duplicate GUI property: {name}")
            seen.add(name)
            if name in METADATA:
                continue
            if prop.tag == "BinaryString" and name in ("AttributesSerialize", "Tags") and not (prop.text or "").strip():
                continue
            target = f"nodes[{index}][{quote(name)}]"
            if prop.tag == "token":
                output.append(f"{target}=enumValue({target}.EnumType,{number(prop.text)})")
            elif prop.tag == "Ref":
                if prop.text != "null":
                    if prop.text not in refs:
                        raise ValueError(f"GUI reference outside model: {name}")
                    deferred.append(f"{target}=nodes[{refs[prop.text]}]")
            else:
                output.append(f"{target}={expression(prop)}")
        for child in item.findall("Item"):
            deferred.append(f"nodes[{indices[id(child)]}].Parent=nodes[{index}]")
    output.extend(deferred)
    output.extend(['local folder=Instance.new("Folder");folder.Name="SummonerUI"',
                   "nodes[1].Parent=folder", "folder.Parent=game.ReplicatedStorage", "end", ""])
    return "\n".join(output)
