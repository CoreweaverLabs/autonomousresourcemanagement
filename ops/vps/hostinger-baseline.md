# Hostinger VPS Baseline for the ARM Page Factory

## Scope and decision boundary

This baseline applies the provider-neutral page-factory kit to a **Hostinger VPS that already exists**. The connected account currently has no virtual machine, so the server identifier, IPv4 address, and public hostname remain intentionally blank. Do not execute any step that creates a server, changes DNS, changes nameservers, changes a firewall, attaches a public key, or issues a certificate without an approved cutover manifest.

Hostinger exposes virtual-machine, backup, snapshot, public-key, firewall, and post-install-script functions in its VPS API; this guide uses those as the responsibility map, not as an instruction to invoke them automatically.[1]

## Required values after provisioning approval

| Value | Example format | Owner | Where it belongs |
| --- | --- | --- | --- |
| VPS identifier | Provider-generated resource ID | Infrastructure owner | Approved cutover manifest only. |
| IPv4 address | `203.0.113.10` | Infrastructure owner | Approved cutover manifest and GitHub environment variable. |
| Public hostname | `field-systems.example.com` | Domain owner | Caddy configuration, health-check env, and cutover manifest. |
| Deployment user | `armdeploy` | Release owner | VPS and GitHub variable. |
| Deployment SSH public key | Ed25519 public key | Release owner | VPS public-key attachment. |
| GitHub deploy private key | Ed25519 private key | Release owner | `ARM_VPS_DEPLOY_KEY` GitHub environment secret only. |
| SSH administrative ranges | Named office/VPN/CIDR sources | Infrastructure owner | Provider and host firewall record. |
| Monitoring alert recipient | Named person or approved alert target | Operations owner | Monitoring record; never committed to source. |

## First-host implementation sequence

| Order | Hostinger-side action | Acceptance evidence | Does this change public traffic? |
| --- | --- | --- | --- |
| 1 | Provision a supported Linux VPS and record its immutable server ID, location, and IPv4 in the approved manifest. | Provider resource record and a recovery/snapshot decision. | No. |
| 2 | Add the release owner’s SSH public key and disable password-based routine access where the chosen image supports it. | Successful key-based, non-root SSH login. | No. |
| 3 | Create `armdeploy`, grant ownership of `/var/www/arm-page-factory`, and keep the deployment process non-root. | `id armdeploy` and ownership record. | No. |
| 4 | Configure the Hostinger firewall to allow TCP 80 and 443 publicly and SSH only from approved administrative ranges; reinforce the same policy with the host firewall. | Provider-rule and host-rule records. | No, until DNS points to the host. |
| 5 | Install Caddy and deploy the reviewed `Caddyfile`; create Caddy’s log directory with appropriate service ownership. | `caddy validate` and service status. | No, until DNS points to the host. |
| 6 | Create `/etc/arm-page-factory/healthcheck.env` containing only the approved public URL and intended route paths. Install the reviewed health-check service and timer. | `systemctl status` for service and timer. | No. |
| 7 | Configure GitHub environment `vps-production` with approval protection, deployment variables, and the restricted release key secret. Keep `VPS_RELEASES_ENABLED` false while the host is still unverified. | Environment configuration review. | No. |
| 8 | Perform one manual immutable release to a noncanonical host. Confirm retained release, logs, anonymous HTTPS, mobile render, and rollback. | Acceptance checklist and release ID. | Only on the noncanonical host. |
| 9 | Enable routine branch deployment after a successful release and rollback rehearsal. | Approved production acceptance record. | No new DNS change. |

## Firewall baseline

Hostinger’s managed firewall operates before server traffic reaches the instance and uses explicit rules. An empty active rule set blocks traffic, so record the intended allow-list before attaching it to the VPS.[2]

| Layer | Rule | Source | Reason |
| --- | --- | --- | --- |
| Hostinger firewall | Allow TCP 80 | Anywhere | HTTP-to-HTTPS handling and certificate validation. |
| Hostinger firewall | Allow TCP 443 | Anywhere | Public HTTPS delivery. |
| Hostinger firewall | Allow TCP 22 | Approved administrative CIDRs only | Break-glass and administration access. |
| Hostinger firewall | Reject or drop all other inbound traffic | Anywhere | Prevent unneeded public services. |
| Host firewall | Match the provider allow-list | Same as above | Defense in depth and finer host control. |

Do not expose a database, Docker daemon, Caddy admin interface, monitoring dashboard, deployment webhook receiver, or SSH to the open internet without a separately approved design.

## Caddy and health-check installation record

The server’s actual Caddy configuration uses the reviewed repository template, replacing only the public hostname and the approved release root. Caddy should be validated before reload. The health-check environment should contain a single `PUBLIC_URL` for the noncanonical preview first, then the approved production hostname after cutover. The timer’s five-minute interval is an availability check, not a publishing trigger; its service only performs an anonymous HTTPS response check and logs a failure.

Store deploy-time values outside the repository:

| Location | Contains | Must not contain |
| --- | --- | --- |
| GitHub `vps-production` environment variables | Host, user, port, release root, `VPS_RELEASES_ENABLED`. | Private keys, API tokens, hostname changes not recorded in the manifest. |
| GitHub `vps-production` environment secrets | `ARM_VPS_DEPLOY_KEY`. | DNS/provider credentials unless a separately approved automation design needs them. |
| `/etc/arm-page-factory/healthcheck.env` | `PUBLIC_URL`, health-check paths, timeout. | Provider API key, GitHub private key, or public-site content. |
| `/etc/caddy/Caddyfile` | Public hostname, site root, headers, log path. | SSH keys, API credentials, or private operational contacts. |

## Backup and rollback

Take a Hostinger snapshot or confirm the provider backup posture before the first host configuration. Preserve the five immutable application releases defined by the release kit. Provider recovery is for a server-level failure; the `current` symlink is for a bad static release; the DNS rollback record is for a bad routing change. Each has a different owner and a different recovery path.

## First cutover hold points

The final cutover manifest remains blocked until all fields below are named:

1. Provider and VPS identifier.
2. Public hostname and the exact pre-existing DNS records.
3. The authoritative DNS operator and the permitted record change.
4. CAA and certificate readiness.
5. Operations, release, and rollback owners.
6. The preview release ID and its acceptance record.

## References

[1] [Hostinger API Reference — VPS operations](https://developers.hostinger.com/)

[2] [Hostinger, “How to use a managed VPS firewall.”](https://www.hostinger.com/support/8172641-how-to-use-a-managed-vps-firewall-at-hostinger/)
