# Frontend ↔ backend security

## Production (AWS)

| Control | Implementation |
| --- | --- |
| TLS | Terminate at **ALB / CloudFront** (TLS 1.2+); HSTS at edge |
| Auth | **OAuth2/OIDC** or signed **JWT** (short TTL, refresh via HttpOnly cookie or BFF) |
| CORS | Allowlist exact SPA origins only — [backend CORS](../src/problem4/apps/backend/src/index.js) via `CORS_ORIGINS` |
| Cookies | `Secure`, `HttpOnly`, `SameSite=Strict` for session refresh |
| API | No secrets in static S3 bundle; call API on separate host `api.platform.example` |

## Local (Problem 3 / 4)

- NGINX on `:8080` → API; TLS not enabled locally (document gap).
- Set `CORS_ORIGINS=http://localhost:8080` for API container.

## CORS and non-browser clients

The API allows requests with **no `Origin` header** (e.g. curl, server-side jobs) in addition to origins listed in `CORS_ORIGINS`. With `credentials: true`, only use this pattern when callers are trusted; browser SPAs must use an exact allowlisted origin.

## Threat notes

- Static frontend cannot hold API keys; use short-lived tokens from auth service.
- WAF + rate limit at edge; NGINX `limit_req` in [default.conf](../src/problem3/nginx/conf.d/default.conf) for local parity.
