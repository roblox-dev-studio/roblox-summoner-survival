"""Export current Luau definitions to reviewable JSON/Markdown and UI icon mappings.

Gameplay remains authoritative in Luau. Icon upload IDs are authored only in
assets/ui/skill-icons/manifest.json; generated outputs must never be hand-edited.
"""
import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from bootstrap_luau import VERSION

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = "assets/ui/skill-icons/manifest.json"
SOURCES = [
    "src/server/flow/Loadout.luau", "src/server/flow/Augments.luau",
    "src/server/combat/Weapons.luau", "src/client/combat/AugmentStyles.luau",
    "src/client/flow/SkillPreview.luau",
]
# Navigation metadata only; names, descriptions, IDs and augmentation rules are
# evaluated from the existing source modules below, never copied into this map.
IMPLEMENTATIONS = {
    "ice": (["Combat"], ["Effects", "AugmentArt"]),
    "lightning": (["Combat"], ["LightningArt", "AugmentArt"]),
    "meteor": (["AreaSpells"], ["AreaArt", "AugmentArt"]),
    "blades": (["ArcaneCrystals"], ["ProjectileArt", "AugmentArt"]),
    "frost": (["AreaSpells"], ["AreaArt", "AugmentArt"]),
    "ward": (["AreaSpells"], ["AreaArt", "AugmentArt"]),
    "missile": (["HomingMissiles"], ["ProjectileArt", "AugmentArt"]),
    "skyLances": (["SkyLances"], ["SkyLanceArt", "AugmentArt"]),
    "lightRing": (["LightSpells"], ["LightArt", "AugmentArt"]),
    "fire": (["ActiveSpells"], ["FireArt", "AugmentArt"]),
    "thunder": (["ActiveSpells"], ["ActiveArt", "AugmentArt"]),
    "aetherLance": (["ActiveSpells"], ["AetherLanceArt", "AugmentArt"]),
    "iceRush": (["ActiveSpells"], ["GlacialArt", "AugmentArt"]),
    "basic": (["BasicAttack", "Weapons"], ["LightArt"]),
    "golem": (["Combat"], ["Effects"]),
    "dash": (["Movement"], ["Effects"]),
}
BUILTIN_SKILLS = {"basic", "golem", "dash"}
COMMON_ICONS = {"quick_cast", "active_focus", "lucky_charm"}
CATEGORIES = {"auto": "자동 마법", "active": "Q 사용 스킬", "basic": "기본 공격", "summon": "소환수", "movement": "이동"}
RARITIES = {"common": "일반", "rare": "희귀", "epic": "영웅"}
EXPORT = r'''
local augments=require('../src/server/flow/Augments')
local loadout=require('../src/server/flow/Loadout')
local weapons=require('../src/server/combat/Weapons')
local styles=require('../src/client/combat/AugmentStyles')
local function quote(value)
 return '"'..string.gsub(value,'[%z\1-\31\\"]',function(c)
  if c=='"'then return '\\"'elseif c=='\\'then return '\\\\'end
  return string.format('\\u%04x',string.byte(c))
 end)..'"'
end
local function encode(value)
 local kind=type(value)
 if kind=='string'then return quote(value)end
 if kind=='number'or kind=='boolean'then return tostring(value)end
 if kind=='nil'then return 'null'end
 assert(kind=='table','Unsupported export type: '..kind)
 local pieces={}
 if #value>0 then
  for _,v in ipairs(value)do table.insert(pieces,encode(v))end
  return '['..table.concat(pieces,',')..']'
 end
 local keys={};for k in pairs(value)do table.insert(keys,k)end;table.sort(keys)
 for _,k in ipairs(keys)do table.insert(pieces,quote(k)..':'..encode(value[k]))end
 return '{'..table.concat(pieces,',')..'}'
end
local state={loadout={},golem=1}
for _,option in ipairs(loadout.Options)do state[option.id]=1;table.insert(state.loadout,option.id)end
local levels=augments.Pool(state)
local minimumLevels={}
for _,definition in ipairs(augments.Definitions)do
 if definition.spell then
  local saved=state[definition.spell]
  for level=0,5 do
   state[definition.spell]=level
   if augments.Eligible(state,definition)then minimumLevels[definition.id]=level;break end
  end
  state[definition.spell]=saved
 end
end
print(encode({auto=loadout.Options,active=loadout.ActiveOptions,slots=loadout.SlotCount,defaults=loadout.Defaults,
 augments=augments.Definitions,labels=augments.Labels,levels=levels,styles=styles,minimumLevels=minimumLevels,
 weapon={id=weapons.Default,profile=weapons.Get(weapons.Default)}}))
'''


def source_data(root=ROOT):
    """Run the actual pure modules with pinned Luau; no regex clone of rules."""
    suffix = ".exe" if os.name == "nt" else ""
    binary = root / ".tools" / f"luau-{VERSION}" / ("luau" + suffix)
    if not binary.exists():
        raise ValueError("Run python3 tools/bootstrap_luau.py before exporting the skill catalog")
    with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", suffix=".luau", prefix=".skill-export-", dir=root / "tools", delete=False) as temp:
        temp.write(EXPORT)
        path = Path(temp.name)
    try:
        result = subprocess.run([str(binary), str(path)], cwd=root, capture_output=True, text=True, encoding="utf-8", check=True)
        return json.loads(result.stdout)
    finally:
        path.unlink(missing_ok=True)


def preview_data(root=ROOT):
    text = (root / SOURCES[-1]).read_text(encoding="utf-8")
    block = re.search(r"local spells=\{(.*?)\n \}", text, re.S)
    if not block:
        raise ValueError("SkillPreview spells structure changed; update the explicit caption adapter")
    rows = re.findall(r"\{id='([^']+)',name='([^']+)',note='([^']+)'(?:,common=true)?\}", block[1])
    if len(rows) != 16 or len({row[0] for row in rows}) != 16:
        raise ValueError("Expected sixteen unique SkillPreview captions; update catalog adapter")
    return {key: {"name": name, "note": note} for key, name, note in rows}


def upload_manifest(root=ROOT):
    path = root / MANIFEST
    if not path.exists():
        return {}
    manifest = json.loads(path.read_text(encoding="utf-8"))
    records = manifest.get("icons")
    if not isinstance(records, list):
        raise ValueError("Icon manifest must contain an icons array")
    result = {}
    expected = set(IMPLEMENTATIONS) | COMMON_ICONS
    for record in records:
        key = record.get("id")
        if key not in expected or key in result:
            raise ValueError(f"Unknown or duplicate icon manifest id: {key!r}")
        expected_path = f"assets/ui/skill-icons/{key}.png"
        if record.get("path") != expected_path:
            raise ValueError(f"Icon {key} must use repository-relative path {expected_path}")
        asset_id = record.get("robloxAssetId")
        if asset_id is not None:
            if isinstance(asset_id, bool) or not re.fullmatch(r"[1-9][0-9]*", str(asset_id)):
                raise ValueError(f"Icon {key} requires a positive numeric Roblox asset ID or null")
            asset_id = str(asset_id)
        result[key] = {"path": expected_path, "robloxAssetId": asset_id}
    return result


def icon_record(key, uploads, root=ROOT):
    path = f"assets/ui/skill-icons/{key}.png"
    asset_id = uploads.get(key, {}).get("robloxAssetId")
    exists = (root / path).is_file()
    if asset_id and not exists:
        raise ValueError(f"Uploaded icon {key} is missing its reproducible local PNG")
    status = "uploaded" if asset_id else ("local_ready_unpublished" if exists else "pending_generation")
    return {"iconKey": key, "assetPath": path, "robloxAssetId": asset_id, "iconStatus": status}


def implementation_paths(key, root=ROOT):
    server, client = IMPLEMENTATIONS[key]
    paths = [f"src/server/combat/{name}.luau" for name in server] + [f"src/client/combat/{name}.luau" for name in client]
    for path in paths:
        if not (root / path).is_file():
            raise ValueError(f"Missing skill implementation path: {path}")
    return paths


def build_catalog(root=ROOT):
    source = source_data(root)
    preview = preview_data(root)
    uploads = upload_manifest(root)
    auto_ids = {entry["id"] for entry in source["auto"]}
    active_ids = {entry["id"] for entry in source["active"]}
    if len(auto_ids) != 9 or len(active_ids) != 4 or len(source["auto"]) != 9 or len(source["active"]) != 4 or auto_ids & active_ids:
        raise ValueError("Selectable skill roster changed; update the catalog scope explicitly")
    if auto_ids | active_ids | BUILTIN_SKILLS != set(IMPLEMENTATIONS):
        raise ValueError("Implementation navigation metadata does not match current skill IDs")
    level_descriptions = {entry["id"]: entry["desc"] for entry in source["levels"]}
    skills = []
    for category, entries in (("auto", source["auto"]), ("active", source["active"])):
        for entry in entries:
            key = entry["id"]
            if category == "auto" and source["labels"].get(key) != entry["name"]:
                raise ValueError(f"Loadout and Augments names disagree for {key}")
            skill = {"id": key, "name": entry["name"], "description": entry["desc"], "category": category,
                     "categoryName": CATEGORIES[category], "active": True, "status": "implemented_selectable",
                     "role": entry.get("role"), "upgradeDescription": level_descriptions.get(key),
                     "definitionSource": SOURCES[0], "implementationPaths": implementation_paths(key, root)}
            skill.update(icon_record(key, uploads, root));skills.append(skill)
    for key, category in (("basic", "basic"), ("golem", "summon"), ("dash", "movement")):
        skill = {"id": key, "name": preview[key]["name"], "description": preview[key]["note"], "category": category,
                 "categoryName": CATEGORIES[category], "active": True, "status": "implemented_builtin",
                 "role": None, "upgradeDescription": level_descriptions.get(key),
                 "definitionSource": SOURCES[-1], "descriptionKind": "existing_preview_caption",
                 "implementationPaths": implementation_paths(key, root)}
        if key == "basic":
            skill["weaponProfile"] = source["weapon"]
        skill.update(icon_record(key, uploads, root));skills.append(skill)
    by_id = {skill["id"]: skill for skill in skills}
    styles = {}
    for parent, entries in source["styles"].items():
        for entry in entries:
            if entry["id"] in styles:
                raise ValueError("Duplicate visual augmentation ID")
            styles[entry["id"]] = {**entry, "parentSkill": parent}
    augments = []
    seen = set()
    for entry in source["augments"]:
        key = entry["id"]
        if key in seen:
            raise ValueError(f"Duplicate augmentation {key}")
        seen.add(key)
        parent = entry.get("spell") or entry.get("active")
        if parent and parent not in by_id:
            raise ValueError(f"Unknown augmentation parent {parent}")
        if parent and (key not in styles or styles[key]["parentSkill"] != parent or styles[key]["name"] != entry["name"]):
            raise ValueError(f"Server and visual augmentation definitions disagree for {key}")
        if entry["rarity"] not in RARITIES:
            raise ValueError(f"Unknown rarity for {key}")
        augment = {"id": key, "cardId": "aug_" + key, "name": entry["name"], "description": entry["desc"],
                   "category": "active_augment" if "active" in entry else ("auto_augment" if parent else "common_augment"),
                   "active": True, "status": "implemented", "parentSkill": parent, "rarity": entry["rarity"],
                   "maxStacks": entry.get("max", 1), "requiresAny": entry.get("requiresAny", []),
                   "minimumParentLevel": source["minimumLevels"].get(key),
                   "badge": {"rarity": RARITIES[entry["rarity"]], "variantName": entry["name"]},
                   "iconMode": "parent_with_badge" if parent else "dedicated_common",
                   "visualNote": styles[key]["note"] if parent else None,
                   "definitionSource": SOURCES[1],
                   "implementationPaths": [SOURCES[1]] + (implementation_paths(parent, root) if parent else ["src/server/flow/Progression.luau"])}
        augment.update(icon_record(parent or key, uploads, root));augments.append(augment)
    if len(augments) != 25 or {a["id"] for a in augments if not a["parentSkill"]} != COMMON_ICONS:
        raise ValueError("Expected twenty-two dedicated and three common augmentations")
    if set(styles) != {a["id"] for a in augments if a["parentSkill"]}:
        raise ValueError("Visual augmentation roster drift")
    source_paths = SOURCES + ([MANIFEST] if (root / MANIFEST).exists() else [])
    return {"schemaVersion": 1, "generatedBy": "python3 tools/build_skill_catalog.py",
            "sourceOfTruth": {"gameplay": "Existing server Luau modules; evaluated by pinned Luau", "iconUploads": MANIFEST,
                              "generatedOutputs": ["data/skills.json", "docs/SKILL_CATALOG.md", "src/client/flow/SkillIcons.luau"]},
            "sourceHashes": {path: hashlib.sha256((root / path).read_bytes()).hexdigest() for path in source_paths},
            "loadout": {"autoSlots": source["slots"], "defaults": source["defaults"]},
            "counts": {"auto": 9, "active": 4, "builtin": 3, "skills": 16, "augments": 25, "dedicatedAugments": 22, "commonAugments": 3,
                       "plannedUniqueImages": 19, "builtinImages": 3,
                       "builtinImagesPending": sum(s["id"] in BUILTIN_SKILLS and s["iconStatus"] == "pending_generation" for s in skills)},
            "iconPolicy": "16 skill images (including basic attack, golem and dash) + 3 common augmentation images; 22 dedicated augmentations reuse their parent image with rarity and variant-name badges. Local PNG paths are not Roblox asset URLs.",
            "skills": skills, "augments": augments}


def markdown(catalog):
    def esc(value):
        return str(value).replace("|", "\\|").replace("\n", " ")
    lines = ["# 스킬·증강 카탈로그", "", "> 자동 생성 파일. 직접 수정하지 마세요. `python3 tools/build_skill_catalog.py`로 재생성합니다.", "",
             "현재 코드 기준 자동 마법 **9개**, Q 사용 스킬 **4개**, 기본 공격·골렘·대시 **3개**, 증강 **25개**입니다.",
             f"자동 마법은 {catalog['loadout']['autoSlots']}칸에 장착합니다. 기본 공격·골렘·대시는 기본 제공이며 자동 마법 선택 칸을 사용하지 않습니다.", "",
             "이 문서는 현재 활성 스킬을 정리합니다. `active`는 구현/선택 또는 기본 제공 여부이며 플레이어의 현재 장착 상태가 아닙니다.",
             "피해·쿨다운 규칙의 원본은 서버 Luau입니다. 설명과 증강 조건은 실제 모듈을 실행해 내보내며 수치를 별도로 작성하지 않습니다.",
             "기본 공격·골렘·대시 설명은 기존 미리보기 문구입니다. 골렘의 ‘5단계 최대 연출’은 표시 설정이며 실제 피해 단계와 다릅니다.", "",
             "## 갱신과 확인", "", "```sh", "python3 tools/bootstrap_luau.py  # 도구가 없는 최초 1회", "python3 tools/build_skill_catalog.py", "python3 tools/build_skill_catalog.py --check", "```", "",
             "`Loadout`의 선택 목록, `Augments`의 이름·설명·희귀도·조건, `Weapons`의 기본 무기, `AugmentStyles`의 변형 설명을 대조합니다.",
             "이름/ID/부모 스킬 또는 명단이 어긋나면 실패합니다. 생성 결과는 JSON·이 문서·클라이언트 아이콘 매핑에 함께 반영됩니다.", "",
             "## 이미지 연결", "",
             "고유 이미지 제작 범위는 전체 스킬 16개 + 공통 증강 3개, 총 **19개**입니다. 전용 증강 22개는 **부모 스킬 이미지 + 희귀도/변형명 배지**를 사용합니다. 별도 이미지 22개를 제작했다는 뜻이 아닙니다.",
             "기본 공격·골렘·대시도 각 전용 이미지를 포함합니다. 이 세 스킬은 기본 제공이며 자동 마법 장착 칸을 추가로 사용하지 않습니다.",
             "PNG가 있어도 Roblox에 업로드하기 전 `robloxAssetId`는 `null`입니다. 업로드 후 `assets/ui/skill-icons/manifest.json`의 해당 ID만 갱신하고 재생성합니다.",
             "`SkillIcons.Apply(imageLabel, id, fallback)`는 유효한 업로드 ID가 있을 때만 이미지를 표시합니다. 없는 경우 기존 UI 대체 표시를 유지하며 로컬 경로나 임의 ID를 이미지 URL로 쓰지 않습니다.", "",
             "| 상태 | 의미 |", "| --- | --- |", "| pending_generation | PNG 생성 대기 |", "| local_ready_unpublished | 로컬 PNG 준비, Roblox 미업로드 |", "| uploaded | 로컬 원본과 업로드 ID 연결 |", ""]
    for category in CATEGORIES:
        group = [s for s in catalog["skills"] if s["category"] == category]
        lines += ["## " + CATEGORIES[category], "", "| ID · 이름 | 코드의 설명 | 단계 강화 설명 | 아이콘 · 상태 |", "| --- | --- | --- | --- |"]
        for skill in group:
            path = skill["assetPath"]
            icon = f"[{skill['iconKey']}](../{path})" if path else skill["iconKey"]
            lines.append(f"| `{skill['id']}` · {esc(skill['name'])} | {esc(skill['description'])} | {esc(skill['upgradeDescription'] or '—')} | {icon} · {skill['iconStatus']} |")
        lines.append("")
    lines += ["## 증강 25개", "", "| ID · 이름 | 부모 · 조건 | 희귀도 · 최대 중첩 | 코드의 설명 | 아이콘 방식 |", "| --- | --- | --- | --- | --- |"]
    for item in catalog["augments"]:
        parent = item["parentSkill"] or "공통"
        mode = "부모 + 배지" if item["parentSkill"] else "공통 전용"
        condition = f"{parent} {item['minimumParentLevel']}단계 이상" if item["minimumParentLevel"] is not None else ("선택 Q: " + parent if item["category"] == "active_augment" else parent)
        if item["requiresAny"]:
            condition += " + " + " / ".join(item["requiresAny"]) + " 중 하나 장착"
        lines.append(f"| `{item['id']}` · {esc(item['name'])} | {condition} | {RARITIES[item['rarity']]} · {item['maxStacks']} | {esc(item['description'])} | `{item['iconKey']}` {mode} |")
    lines += ["", "조건 열의 자동 마법 최소 단계는 `Augments.Eligible`을 실행해 확인한 값입니다. 실제 후보는 장착 상태와 기존 획득 횟수까지 서버에서 검증합니다.",
             "생존·수집 카드와 성장 완료 회복 카드는 위 25개 증강과 별도이며 이 증강 이미지 수에 포함하지 않습니다.", "", "## 구현 위치", "", "| 스킬 | 정의 · 관련 구현 |", "| --- | --- |"]
    for skill in catalog["skills"]:
        paths = [skill["definitionSource"], *skill["implementationPaths"]]
        links = " · ".join(f"[{Path(p).name}](../{p})" for p in dict.fromkeys(paths))
        lines.append(f"| `{skill['id']}` | {links} |")
    lines += ["", "전체 필드·해시·증강 부모/조건·기본 무기 프로필은 [data/skills.json](../data/skills.json)을 참고하세요.", ""]
    return "\n".join(lines)


def lua_string(value):
    return json.dumps(value, ensure_ascii=False)


def icon_helper(catalog):
    lines = ["-- Generated by tools/build_skill_catalog.py. Edit server definitions or the icon upload manifest.",
             "-- Presentation metadata only: local PNG paths never become Roblox image URLs.", "local entries={}"]
    for item in [*catalog["skills"], *catalog["augments"]]:
        fields = {"id": item["id"], "iconKey": item["iconKey"], "name": item["name"], "status": item["iconStatus"],
                  "description": item["description"], "category": item["category"]}
        skills = {skill["id"]: skill for skill in catalog["skills"]}
        if "maxStacks" in item:
            parent = item["parentSkill"]
            if item["minimumParentLevel"] is not None:
                condition = f"{skills[parent]['name']} 장착 · {item['minimumParentLevel']}단계 이상"
            elif parent:
                condition = f"Q에 {skills[parent]['name']} 선택"
            else:
                condition = "모든 빌드에서 선택 가능"
            if item["requiresAny"]:
                condition += " + " + " / ".join(skills[key]["name"] for key in item["requiresAny"]) + " 중 하나 장착"
            fields["condition"] = condition + f" · 최대 {item['maxStacks']}회"
            fields["visualNote"] = item["visualNote"] or "전투 수치 강화"
        else:
            fields["categoryName"] = item["categoryName"]
            fields["condition"] = (f"자동 마법 {catalog['loadout']['autoSlots']}칸 중 선택" if item["category"] == "auto" else
                                   "출전 준비에서 Q로 선택" if item["category"] == "active" else "기본 제공 · 자동 마법 칸 사용 안 함")
            fields["upgradeDescription"] = item.get("upgradeDescription") or ""
        for key in ("assetPath", "robloxAssetId", "parentSkill", "rarity"):
            if item.get(key) is not None:
                fields[key] = item[key]
        if "badge" in item:
            fields["badge"] = item["badge"]["rarity"] + " · " + item["badge"]["variantName"]
        record = ",".join(key + "=" + lua_string(value) for key, value in fields.items())
        lines.append(f"entries[{lua_string(item['id'])}]=table.freeze({{{record}}})")
    ids = [item["id"] for item in [*catalog["skills"], *catalog["augments"]]]
    lines += ["table.freeze(entries)", "local order=table.freeze({" + ",".join(lua_string(key) for key in ids) + "})",
              "local function list(group,query)",
              " if group~='all'and group~='auto'and group~='active'and group~='builtin'and group~='augments'then return {} end",
              " query=type(query)=='string'and string.lower(query)or '';local found={}",
              " for _,id in ipairs(order)do",
              "  local entry=entries[id];local category=entry.category;local augment=string.find(category,'_augment',1,true)~=nil",
              "  local match=group=='all'or category==group or(group=='augments'and augment)or(group=='builtin'and not augment and category~='auto'and category~='active')",
              "  local searchable=string.lower(entry.name..' '..entry.description..' '..entry.condition)",
              "  if match and(query==''or string.find(searchable,query,1,true))then table.insert(found,entry)end",
              " end;return found", "end",
              "local function get(id)", " if type(id)~='string'then return nil end",
              " return entries[string.gsub(id,'^aug_','')]", "end", "local function apply(imageLabel,id,fallback)",
              " local entry=get(id)", " local assetId=entry and entry.robloxAssetId",
              " local ready=type(assetId)=='string'and string.match(assetId,'^[1-9]%d*$')~=nil",
              " imageLabel.Image=ready and('rbxassetid://'..assetId)or ''", " imageLabel.Visible=ready",
              " if fallback then fallback.Visible=not ready end", " return ready,entry", "end",
              "return table.freeze({Get=get,Apply=apply,List=list})", ""]
    return "\n".join(lines)


def outputs(root=ROOT):
    catalog = build_catalog(root)
    return {"data/skills.json": json.dumps(catalog, ensure_ascii=False, indent=2) + "\n",
            "docs/SKILL_CATALOG.md": markdown(catalog),
            "src/client/flow/SkillIcons.luau": icon_helper(catalog)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="Fail if any generated catalog or icon map is stale")
    args = parser.parse_args()
    try:
        generated = outputs()
    except (ValueError, subprocess.CalledProcessError) as error:
        raise SystemExit(str(error)) from error
    stale = []
    for name, text in generated.items():
        path = ROOT / name
        if args.check:
            if not path.exists() or path.read_text(encoding="utf-8") != text:
                stale.append(name)
        else:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text, encoding="utf-8")
    if stale:
        raise SystemExit("Stale generated skill catalog; run python3 tools/build_skill_catalog.py: " + ", ".join(stale))
    print("PASS: skill catalog current" if args.check else "Generated 16 skills, 25 augmentations and client icon mappings")


if __name__ == "__main__":
    main()
