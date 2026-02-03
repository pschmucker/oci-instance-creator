# oci-instance-creator
A small Dockerized wrapper around Terraform that continuously retries provisioning an Oracle Cloud Infrastructure (OCI) free‑tier instance when the target region reports "out of capacity", and stops once the instance is created successfully.

---

## 🔁 Features
- Continuously attempts `terraform init` and `terraform apply` until a run succeeds
- Handles `init` retries with `-reconfigure` and `-upgrade` fallbacks
- Designed to work with OCI free‑tier capacity errors (e.g., temporary "out of capacity")

## 🔧 Requirements
- Docker (or Podman)
- Docker Compose (optional, for provided `docker-compose.yaml`)
- An OCI tenancy with API key (see `.env.example`)
- Terraform configuration files in `./terraform` that provision the desired instance

## 🔥 Quick start
1. Copy the example env file and fill in your OCI details:

   ```sh
   cp .env.example .env
   # Edit .env to set your OCIDs, region, and the private key path
   ```

2. Store your OCI private key in the `keys/` directory (file name and path must match `PRIVATE_KEY_PATH` inside `.env`). For example:

   - Place `private-key.pem` at `./keys/private-key.pem`
   - Set `PRIVATE_KEY_PATH=/root/.ssh/private-key.pem` in `.env`

   The compose file mounts `./keys` to `/root/.ssh` (read-only) inside the container.

3. Run with Docker Compose:

   ```sh
   docker compose up -d
   docker compose logs -f oci-instance-creator
   ```

   Or run the image directly:

   ```sh
   docker run --rm -it \
     -v "$(pwd)/terraform:/app/terraform" \
     -v "$(pwd)/keys:/root/.ssh:ro" \
     --env-file .env \
     ghcr.io/pschmucker/oci-instance-creator:latest
   ```

## 🔍 How it works
- The container runs `loop-apply.sh`, which:
  - Changes into `/app/terraform`
  - Runs `terraform init` with fallbacks (`-reconfigure`, `-upgrade`) when necessary
  - Runs `terraform apply -auto-approve` in a loop until it succeeds
- On success the container exits (so it won't keep running unnecessarily)

## 🛠️ Logs & troubleshooting
- View runtime logs:
  - `docker logs -f oci-instance-creator` (compose)
- Common problems:
  - Incorrect OCIDs or fingerprint → Terraform/Oci provider errors
  - Wrong `PRIVATE_KEY_PATH` or missing key → auth failures
  - Provider reports "out of capacity" → this tool will retry until capacity appears

## ⚠️ Security & notes
- Ensure private keys are readable only by you (`chmod 600 keys/private-key.pem`).

## 🤝 Contributing
Patches and improvements are welcome via pull requests. Please follow standard GitHub workflows.

## 📄 License
This project is licensed under the MIT License. See the `LICENSE` file for details.
