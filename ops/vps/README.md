# VPS Page Factory

This directory makes the static ARM repository releasable to an already-approved VPS without a dashboard login for each page change. It deliberately contains no provider credential, hostname, IP address, or live DNS record.

The first server and public hostname remain an explicit infrastructure decision. After the server, deployment user, repository branch, DNS route, TLS issuance, rollback root, and GitHub deployment secrets are approved, ordinary source releases run the same preflight and immutable-release process.

## Required first-host baseline

| Area | Required before the first cutover |
| --- | --- |
| Server | Supported Linux host, non-root deployment user, SSH public-key access, provider snapshot, and owner for patching/incident response. |
| Network | Provider firewall and host firewall allow public TCP 80/443. Restrict SSH to known administrative networks; do not open database or administration ports publicly. |
| TLS | Install Caddy, associate the final hostname in `Caddyfile`, check the domain’s CAA policy, and verify certificate issuance before canonical traffic changes. |
| Storage | Create `${VPS_ROOT}/releases`, `${VPS_ROOT}/shared`, and the `current` symlink owned by the deploy user. Keep a retained release set plus a provider-level snapshot. |
| Observability | Keep Caddy access/error logs, configure an anonymous HTTPS health check, and name the person who receives a failed-check alert. |
| DNS | Preserve the current origin, record the exact existing DNS values, and obtain explicit approval of the proposed record diff and rollback step. |

## Routine release

The release script validates the static content, uploads a uniquely named artifact, switches the `current` symlink only after extraction succeeds, and retains the newest five releases. It exits without network action unless `CONFIRM_VPS_RELEASE=yes` is set by an approved deployment workflow.

```bash
node ops/vps/scripts/preflight.mjs
CONFIRM_VPS_RELEASE=yes VPS_HOST=... VPS_DEPLOY_USER=... \
  VPS_ROOT=/var/www/arm-page-factory bash ops/vps/scripts/release.sh
```

Set the deployment workflow’s variables and deploy key only after the initial server ownership and hostname decisions are confirmed. Do not set `VPS_RELEASES_ENABLED=true` until the first manually verified release has passed.

## Rollback

List releases on the server, point `current` to the prior verified release, reload Caddy only if its configuration changed, then run the anonymous HTTPS and mobile checks. For a failed DNS cutover, restore the recorded prior DNS target rather than changing unrelated nameserver, MX, or verification records.

## Production acceptance

Read [`production-acceptance.md`](production-acceptance.md) before moving any hostname from preview to canonical production. A production release needs an approved release manifest, an anonymous HTTPS check, a desktop and mobile render check, a working health-check timer, a verified retained release, and a named rollback owner. Passing source preflight alone is not production readiness.

## Resources

- `scripts/preflight.mjs` validates the repository artifact before upload.
- `scripts/release.sh` creates a guarded immutable release and switches `current`.
- `templates/Caddyfile` serves the static site with compression and explicit cache behavior.
- `templates/arm-page-factory.service` is an optional server-side one-shot release service.
- `cutover-manifest.example.yml` captures the exact first-host approval and rollback record.
- `hostinger-baseline.md` maps the kit to a Hostinger VPS without embedding a server ID, IP, credential, or public hostname.
