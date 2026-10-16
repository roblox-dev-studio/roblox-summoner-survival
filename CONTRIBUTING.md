# 참여 방법

버그를 제보할 때 재현 순서, 기대한 동작, 실제 동작, 사용 기기와 Studio Output의 오류를 적어 주세요. 계정 토큰이나 비밀번호는 올리지 마세요.

변경 제안은 저장소를 Fork해서 작업한 뒤 Pull Request로 보내 주세요.

1. `server.luau`, `client.luau`, `arena.luau` 중 필요한 소스를 수정합니다.
2. `python3 tools/build_installer.py`로 통합 설치기를 갱신합니다.
3. 새 Studio Baseplate에 설치하고 관련 동작을 직접 확인합니다.
4. 변경 이유와 확인한 동작, 남은 제약을 PR에 적습니다.

설치기만 직접 수정하면 다음 생성 때 덮어써집니다. 설치 절차 변경은 `tools/installer_header.luau`에서 작업하세요. 외부 소재를 추가하면 출처와 이용 조건을 `ASSET_CREDITS.md`에 기록해 주세요.

협동과 모바일은 아직 검증 범위가 제한되어 있으므로 해당 변경은 사용한 테스트 환경을 함께 적어 주세요.
