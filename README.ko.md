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
/plugin install stylish-review@stylish-code
/plugin install stylish-packages@stylish-code
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
- `/stylish-git:create-worktree` - 격리된 워크트리 생성

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

---

### stylish-review

인터랙티브 코드 리뷰. 전체 리뷰 파이프라인을 돌리고 finding을 한 건씩 직접 결정합니다.

**스킬:**

- `/stylish-review:code-review` - 인터랙티브 코드 리뷰 워크스루 (PR 또는 로컬 diff, finding마다 적용/수정/대기/오탐 종결)

---

### stylish-packages

의존성 일괄 업데이트. 프레임워크나 자체 업그레이드 CLI가 있는 패키지는 함부로 건드리지 않고, `@types/node`는 머신에 설치된 Node 최신 메이저에 맞춰서 정렬합니다.

**스킬:**

- `/stylish-packages:update` - npm/pnpm/yarn/bun 전부 지원. 패치/마이너 안전한 것은 한 번에 일괄 업데이트, 메이저는 한 건씩 확인, 프레임워크(TypeScript, Next.js, React 등)와 자체 업그레이드 도구가 있는 패키지(Storybook, Prisma, shadcn 등)는 보류하고 적절한 CLI 명령어를 안내합니다.

## 라이선스

MIT
