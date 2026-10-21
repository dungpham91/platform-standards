## Summary

-

## Test plan

- [ ] `pre-commit run --all-files` or `bash scripts/quality-gate-quick.sh`
- [ ] PR checks green (`pr-quality-gate`)

## Security

- [ ] No secrets or `.env` in diff
- [ ] Terraform/engine pins updated in tfvars example if changed
