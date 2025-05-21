#!/bin/bash
set -e

# ===== CONFIGURATION =====
STAGING_DIST_ID="E1XXXXXXXXSTAGING"
PRIMARY_DIST_ID="E3XXXXXXXXPROD"

echo "📥 Fetching staging distribution config..."
aws cloudfront get-distribution-config --id $STAGING_DIST_ID > staging-config.json

ETAG=$(jq -r '.ETag' staging-config.json)
jq '.DistributionConfig' staging-config.json > staging-dist-config.json

echo "🔄 Updating primary distribution with staging config..."
aws cloudfront update-distribution \
  --id $PRIMARY_DIST_ID \
  --if-match "$ETAG" \
  --distribution-config file://staging-dist-config.json

echo "✅ Primary distribution updated with staging config."

# Optional: Invalidate cache
echo "⚠️  Invalidating cache..."
aws cloudfront create-invalidation \
  --distribution-id $PRIMARY_DIST_ID \
  --paths '/*'

echo "✅ Invalidation request submitted."
