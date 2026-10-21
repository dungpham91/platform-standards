# Problem 3 — Local container stack

```bash
cd src/problem3/api && npm ci && npm test
docker compose up --build
curl http://localhost:8080/api/users
bash tests/problem3_smoke.sh   # from repo root
```

Report: [SOLUTION.md](SOLUTION.md).
