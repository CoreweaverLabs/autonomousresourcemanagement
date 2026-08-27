# VPS Page Factory — Production Acceptance

## Release candidate checklist

| Area | Acceptance check | Evidence to record | Owner |
| --- | --- | --- | --- |
| Content and route | Page carries a specific audience decision, a claim map, source links, metadata, canonical route, and an appropriate ARM/context link. | Release packet and committed source revision. | Content owner. |
| Static artifact | `node ops/vps/scripts/preflight.mjs` passes and the deployment archive contains only the intended public files. | CI log and release identifier. | Release owner. |
| Access and TLS | Anonymous HTTPS returns a valid success response for root and each intended route; the certificate name, redirect policy, and CAA conditions are checked. | Timestamped response and certificate check. | Infrastructure owner. |
| Security | Provider and host firewalls expose only approved public ports; SSH access is key-based and restricted; Caddy headers and served-path exclusions are in place. | Firewall rule record and configuration revision. | Infrastructure owner. |
| Visual and mobile | The page is inspected at desktop and a 375px mobile viewport; no primary control, text block, or route is hidden or horizontally clipped. | Screenshots and issue disposition. | Release owner. |
| Observability | The HTTPS health-check service and timer are active, logs are retained, and a named person receives failed-check notification. | Timer status and alert test record. | Operations owner. |
| Rollback | A prior release is retained; the current symlink target and prior DNS/origin record are documented; the rollback command is rehearsed in preview. | Release list, manifest, and rehearsal record. | Release and infrastructure owners. |

## Cutover order

1. Verify the candidate on the VPS using a noncanonical preview hostname.
2. Capture the current DNS and origin state in the approved cutover manifest.
3. Confirm the exact record change, TTL, canonical redirect behavior, certificate readiness, and rollback owner.
4. Apply the approved DNS change once; do not alter nameservers or unrelated records.
5. Check anonymous HTTPS, route responses, certificate chain, desktop/mobile rendering, health-check timer, logs, and canonical behavior.
6. If any required check fails, restore the recorded prior DNS/origin before debugging further.

## Routine release condition

After a successful first release and rollback rehearsal, routine releases can be automated only for an approved branch and hostname. The workflow remains prohibited from purchasing infrastructure, changing DNS, changing a canonical hostname, modifying the firewall, publishing new claims outside the reviewed source, or initiating external communication.
