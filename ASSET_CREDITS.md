# 대지 강타 효과 소재와 확인 기록

## 적용한 공개 소재

| 소재 | 출처 | 이용 조건 및 적용 |
| --- | --- | --- |
| GroundSpikes 바위 메시 | clotuder의 [ground slam vfx](https://create.roblox.com/store/asset/12192129638), 메시 ID `967645205` | Creator Store에서 무료 공개된 모델. [Creator Store Terms](https://en.help.roblox.com/hc/en-us/articles/21308223046932-Creator-Store-Terms)에 따른 Roblox 사용 소재이며 CC0로 표시하지 않음. 메시 한 개만 추출하고 자식 객체를 제거하여 `ReplicatedStorage.SummonerVFXAssets.GroundSpikes`로 보관. 로드 성공 확인. |
| 먼지·연기 | Roblox 내장 `rbxasset://textures/particles/smoke_main.dds` | Studio에 포함된 엔진 텍스처를 ParticleEmitter에서 사용. 런타임 로드 성공 확인. |
| 손의 반짝임 | Roblox 내장 `rbxasset://textures/particles/sparkles_main.dds` | Studio에 포함된 엔진 텍스처. 런타임 로드 성공 확인. |
| 화염 파동·화염탄의 불꽃·불씨 | Roblox 내장 `rbxasset://textures/particles/fire_main.dds`, `fire_sparks_main.dds` | 현재 파동·탄환에 사용. 불꽃·불씨 두 텍스처 모두 런타임 Success 확인. |
| 빙결·전기 불꽃 | Roblox 내장 `sparkles_main.dds` 및 직접 생성한 결정·번개 형상 | 얼음 결정, 잔상, 상태 윤곽, 가지가 갈라지는 번개 줄기는 프로젝트에서 작성. 외부 코드나 유료 에셋을 추가하지 않음. |
| 주문의 부드러운 잔광 | Roblox 내장 `rbxasset://textures/particles/forcefield_glow_main.dds` | 런타임 로드 성공 확인. 시전 고리·얼음 결정·낙뢰와 지면 전류 및 Bloom 설정은 직접 작성. |
| 마법형 화염·대시 | Roblox 내장 `sparkles_main.dds` 및 직접 만든 리본·곡선·잔상 | 불꽃 입자 파동·화염 탄환, 캐릭터의 일시적인 푸른 잔상을 직접 구성. 추가 외부 에셋 없음. |

공개 모델의 실제 구성은 메시 2개와 Weld였으며 실행 스크립트는 없었습니다. 실행에 사용하는 템플릿은 순수 MeshPart 한 개이고 충돌·접촉·쿼리를 끈 시각 효과입니다. 충격파, 섬광, 먼지 방출, 지면 균열, 파편 움직임과 타격 타이밍은 이 프로젝트에서 작성했습니다.

## 검토했지만 적용하지 않은 소재

- [Raffaele Picca / RPicster의 파티클 텍스처](https://github.com/RPicster/Godot-particle-and-vfx-textures): 원작자 README와 LICENSE에서 CC0-1.0을 확인했습니다. 그러나 Studio 이미지 업로드 도구가 원본 GitHub 주소를 신뢰 주소로 허용하지 않아 업로드되지 않았으며 게임에는 포함하지 않았습니다.
- [Roblox 공식 Custom particle effects 예제](https://github.com/Roblox/creator-docs/blob/main/content/en-us/tutorials/use-case-tutorials/vfx/custom-particle-effects.md)의 이미지 `3845808160`: 문서에서 용도를 확인했지만 현재 프로젝트의 클라이언트 로드가 실패하여 최종 코드에서는 정상 로드되는 내장 연기로 교체했습니다.
- Creator Store의 여러 파티클 팩도 검색했지만 재업로드 설명이나 불명확한 원작자 표시가 있는 후보는 채택하지 않았습니다.

## 검증

대지 강타 효과의 준비 빛·먼지·충격파·바위 메시를 플레이 모드에서 재생하고 화면으로 확인했습니다. 메시 및 내장 파티클 두 종류의 ContentProvider 로드 상태가 Success임을 확인했습니다. 시각 점검용 반복 재생·정지 프레임·고정 카메라·숨긴 HUD는 플레이 종료로 제거했습니다. 전투 피해·자동 강타 판단·플레이어 화염 파동 규칙은 유지하며 서버에 강타 준비 연출 이벤트만 추가했습니다.

## 재사용한 캐릭터 모션 (2026-10-16)

Quaternius [Universal Animation Library 2](https://quaternius.com/packs/universalanimationlibrary2.html)
Standard에서 이전 AFTERLIGHT 테스트가 R15로 변환한 네 클립을 재사용했습니다.
제공자 페이지와 동봉 원문에서 CC0-1.0을 확인했습니다. 원문은
`assets/animations/Quaternius-LICENSE.txt`, 원본/변환본 SHA-256과 이전 경로는
`assets/animations/manifest.json`에 보존했습니다.

- `Walk_Carry_Loop`: 이동 속도에 맞춘 하체 주기. 물건을 드는 상체 자세는 사용하지 않음.
- `NinjaJump_Start`, `NinjaJump_Idle_Loop`, `NinjaJump_Land`: 점프·공중·착지 하체.
- 클립 데이터 자체는 변경하지 않았으며, 게임에서는 양쪽 Hip/Knee/Ankle만 혼합합니다.
  Root 이동·상체·실제 점프 궤적은 가져오지 않습니다. FPS 팔/카메라 구현도 가져오지 않음.
- Mixamo 걷기/달리기/점프/사망 변환본은 후보로 확인했지만 포함하지 않았습니다.
  [Adobe FAQ](https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html)는 게임 사용을 허용하지만,
  공개 저장소에서 추출 가능한 모션 데이터 재배포까지 확인된 근거는 확보하지 못했습니다.

이번 새 Baseplate에서 선택적 GroundSpikes import는 생성되지 않았습니다.
위의 과거 로드 성공 기록과 구별하며, 현재 테스트 place는 내장 입자/절차적 파편을 사용합니다.
