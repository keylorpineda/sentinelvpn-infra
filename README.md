# SentinelVPN – Infrastructure

Infrastructure repository for SentinelVPN (WireGuard-based VPN).

## Features
- WireGuard VPN server
- Automated client lifecycle management
- Firewall and hardening templates
- Cloud VM ready (Azure)

## Scripts
- `add-client.sh` – create VPN clients
- `remove-client.sh` – remove VPN clients

## Security
This repository intentionally excludes:
- private keys
- real WireGuard configs
- generated client profiles
- runtime state
