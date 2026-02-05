#!/bin/bash
# shellcheck disable=SC2016
# Evidence Collection Script for Compliance Audit Trail
# Generates SHA256 hashes and manifests of released artifacts

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_FILE="${1:-evidence.json}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
GIT_SHA=$(git rev-parse HEAD 2>/dev/null || echo "unknown")
GIT_TAG=$(git describe --tags --exact-match 2>/dev/null || echo "untagged")

echo "Generating evidence manifest..."

# Start JSON output
cat > "$OUTPUT_FILE" << EOF
{
  "metadata": {
    "timestamp": "$TIMESTAMP",
    "git_sha": "$GIT_SHA",
    "git_tag": "$GIT_TAG",
    "generator": "generate-evidence.sh",
    "version": "1.0.0"
  },
  "artifacts": {
EOF

# Generate hashes for agent files
echo '    "agents": [' >> "$OUTPUT_FILE"
first=true
if [ -d "$ROOT_DIR/dist/agents" ]; then
    for file in "$ROOT_DIR/dist/agents"/*.md; do
        [ -f "$file" ] || continue
        filename=$(basename "$file")
        hash=$(sha256sum "$file" | cut -d' ' -f1)
        size=$(stat -c%s "$file" 2>/dev/null || stat -f%z "$file" 2>/dev/null)
        
        if [ "$first" = true ]; then
            first=false
        else
            echo ',' >> "$OUTPUT_FILE"
        fi
        printf '      {"file": "%s", "sha256": "%s", "size": %s}' "$filename" "$hash" "$size" >> "$OUTPUT_FILE"
    done
fi
echo '' >> "$OUTPUT_FILE"
echo '    ],' >> "$OUTPUT_FILE"

# Include dangerous commands config hash
echo '    "security_config": {' >> "$OUTPUT_FILE"
if [ -f "$ROOT_DIR/config/dangerous_commands.json" ]; then
    dc_hash=$(sha256sum "$ROOT_DIR/config/dangerous_commands.json" | cut -d' ' -f1)
    echo "      \"dangerous_commands_sha256\": \"$dc_hash\"" >> "$OUTPUT_FILE"
else
    echo '      "dangerous_commands_sha256": null' >> "$OUTPUT_FILE"
fi
echo '    },' >> "$OUTPUT_FILE"

# Include eval results if present
echo '    "intelligence_tests": {' >> "$OUTPUT_FILE"
if [ -f "$ROOT_DIR/eval/results.json" ]; then
    # Extract pass rate if available
    pass_rate=$(jq -r '.results.stats.passRate // "unknown"' "$ROOT_DIR/eval/results.json" 2>/dev/null || echo "unknown")
    total_tests=$(jq -r '.results.stats.totalTests // 0' "$ROOT_DIR/eval/results.json" 2>/dev/null || echo "0")
    eval_hash=$(sha256sum "$ROOT_DIR/eval/results.json" | cut -d' ' -f1)
    cat >> "$OUTPUT_FILE" << EOF
      "results_sha256": "$eval_hash",
      "pass_rate": "$pass_rate",
      "total_tests": $total_tests
EOF
else
    cat >> "$OUTPUT_FILE" << EOF
      "results_sha256": null,
      "pass_rate": null,
      "total_tests": 0
EOF
fi
echo '    }' >> "$OUTPUT_FILE"

# Close JSON
cat >> "$OUTPUT_FILE" << EOF
  }
}
EOF

echo "Evidence manifest generated: $OUTPUT_FILE"
echo "Git SHA: $GIT_SHA"
echo "Git Tag: $GIT_TAG"
