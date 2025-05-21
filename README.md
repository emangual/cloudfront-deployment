# CloudFront Continuous Deployment Setup

This repo contains Terraform infrastructure and AWS CLI scripts for managing CloudFront continuous deployment with separate S3 buckets for prod/staging and a custom domain.

## Structure

- `terraform/` — Infrastructure code (S3, CloudFront, ACM)
- `scripts/` — Bash script for promoting staging config to prod

## Promotion

To promote the staging CloudFront config to the primary distribution:

```bash
cd scripts
chmod +x promote_staging_to_prod.sh
./promote_staging_to_prod.sh
```
