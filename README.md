# Minerva Search API v1.2.40 배포용 패키지

이 패키지는 `minerva_search_v1.2.40_intent_ranking_bugcheck`를 기준으로 만든 백엔드 배포본입니다. 개발용 백업 파일과 누적 패치 노트는 제외했고, 운영에 필요한 파일만 남겼습니다.

## 포함된 것

```txt
backend/server.js
backend/library_data.xml
backend/package.json
backend/package-lock.json
backend/.env.example
Dockerfile
render.yaml
Procfile
deploy/start-production.sh
deploy/smoke-test.sh
deploy/minerva-search-api.service.example
BUILD_INFO.json
```

## 배포 전 체크

1. Node.js는 **18.17 이상**을 사용하세요. Docker 배포는 Node 20 Alpine 이미지를 사용합니다.
2. `backend/.env.example`을 `backend/.env`로 복사한 뒤 실제 키를 넣으세요.
3. 프론트 도메인이 다르면 `ALLOWED_ORIGINS`에 추가하세요.
4. 리버스 프록시나 PaaS 뒤에서 돌릴 때는 `TRUST_PROXY=1`을 권장합니다.

## 일반 서버 배포

```bash
cd backend
cp .env.example .env
# .env 편집
npm ci --omit=dev
NODE_ENV=production npm start
```

상태 확인:

```bash
curl -fsS http://localhost:3000/api/health
curl -fsS "http://localhost:3000/api/library-search?query=강남구%20야간%20운영%20도서관&debug=1"
```

## Docker 배포

```bash
docker build -t minerva-search-api:1.2.40 .
docker run --env-file backend/.env -p 3000:3000 minerva-search-api:1.2.40
```

## Render 배포

`render.yaml`을 그대로 사용하거나, Render 대시보드에서 다음처럼 설정하세요.

```txt
Root Directory: backend
Build Command: npm ci --omit=dev
Start Command: npm start
```

환경변수는 `.env.example`을 참고해서 Render의 Environment Variables에 등록하세요. 실제 비밀키는 저장소에 커밋하지 마세요.

## systemd 예시

`deploy/minerva-search-api.service.example`에서 경로와 사용자명을 서버 환경에 맞게 바꾼 뒤 사용하세요.

```bash
sudo cp deploy/minerva-search-api.service.example /etc/systemd/system/minerva-search-api.service
sudo systemctl daemon-reload
sudo systemctl enable --now minerva-search-api
sudo systemctl status minerva-search-api
```

## 운영 확인 포인트

- `/api/health`가 `{ "ok": true }`를 반환하는지 확인
- `/api/library-search?query=강남구 야간 운영 도서관`에서 의도 기반 랭킹 결과가 나오는지 확인
- `NODE_ENV=production`에서 CORS 허용 도메인이 맞는지 확인
- `ADMIN_SECRET`을 비워두면 관리자 XML 리로드 엔드포인트는 404로 숨겨집니다

## 이 배포본에서 정리한 점

- `node_modules` 제외
- 개발 백업 파일 제외
- 누적 패치 노트 제외
- npm lock 파일의 내부 레지스트리 URL을 public npm registry URL로 정리
- 사용하지 않는 `lru-cache` 의존성 제거
- 배포용 `.env.example`, Dockerfile, Render 설정, smoke test 스크립트 추가
