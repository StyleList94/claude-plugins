# Stylish Code

🌐 **한국어** | [English](./README.md)

맵시나는 Claude Code 플러그인 모음.

## 설치

마켓플레이스를 Claude Code에 추가합니다:

```shell
/plugin marketplace add stylelist94/claude-plugins
```

개별 플러그인을 설치합니다:

```shell
/plugin install stylish-git@stylish-code
/plugin install stylish-docs@stylish-code
/plugin install stylish-frontend@stylish-code
```

## 사용 가능한 플러그인

### stylish-git

Git 워크플로우 도구 모음.

의외로 귀찮은 것들만 있습니다.

**스킬:**

- `/stylish-git:commit` - 지능형 커밋 메시지 생성기
- `/stylish-git:squash` - GitHub PR 스쿼시 머지 스타일로 커밋 합치기
- `/stylish-git:rebase` - 지능형 충돌 해결 리베이스
- `/stylish-git:cleanup-branch` - 브랜치 정리 및 관리

---

### stylish-docs

각종 문서 생성하기

**스킬:**

- `/stylish-docs:readme` - README 파일 생성기
- `/stylish-docs:react-tsdoc` - React 컴포넌트 TSDoc 생성기

**에이전트:**

- `doc-reviewer` - 문서 품질, 완성도, 코드-문서 일관성 검토

**출력 스타일:**

- `doc-review-report` - 문서 리뷰 결과 구조화 포맷

---

### stylish-frontend

주특기 강화하기

**스킬:**

- `/stylish-frontend:figma-to-code` - Figma 디자인을 코드로 변환 (Figma MCP 필요)
- `/stylish-frontend:vitest-browser` - Vitest 브라우저 테스트 작성
- `/stylish-frontend:component-workflow` - 컴포넌트 개발 워크플로우

**에이전트:**

- `component-reviewer` - 컴포넌트 패턴 일관성, 접근성, 모범 사례 검토

**출력 스타일:**

- `component-review-report` - 컴포넌트 리뷰 결과 구조화 포맷

> **참고:** `/stylish-frontend:figma-to-code`는 [Figma MCP Server](https://github.com/figma/mcp-server-guide) 설정이 필요합니다.

## 라이선스

MIT
