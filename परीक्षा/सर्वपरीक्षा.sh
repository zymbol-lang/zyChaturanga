#!/usr/bin/env bash
# ============================================================
# परीक्षा/सर्वपरीक्षा.sh — run every चतुरङ्गम् suite
#   bash परीक्षा/सर्वपरीक्षा.sh
# ============================================================
#
# ── NOTE ─────────────────────────────────────────────────────────────────
# This script is not the authority. It compares each suite against its
# recorded golden, which is better than grepping for FAIL — a suite that
# crashes half way through does not match a golden — but it still runs one
# engine and knows nothing about the others.
#
# The gate is in ZyQuality, which runs every engine that can:
#
#     cd ../zyquality && ./zyq suite --only project
#     cd ../zyquality && bash project/run.sh --only chaturanga
#
# What is worth running here is the `zymbol check` sweep at the end, which is
# about this application's own sources rather than about the language.
# ─────────────────────────────────────────────────────────────────────────
set -u
cd "$(dirname "$0")/.."

ENGINE="${1:-}"
fallo=0

# The goldens are recorded by ZyQuality, which drops blank lines before it
# compares. So this script drops them too — otherwise the two tools would
# disagree about a suite that both of them consider correct, which is the
# worst possible way for a gate to be wrong.
normaliza() { grep -v '^[[:space:]]*$'; }

for suite in नियमपरीक्षा गतिपरीक्षा चित्रपरीक्षा भाषापरीक्षा अनुप्रयोगपरीक्षा मतिपरीक्षा; do
    printf '─── परीक्षा/%s.zy  ' "$suite"
    salida=$(zymbol run $ENGINE "परीक्षा/$suite.zy" 2>&1 | normaliza)
    if [ ! -f "परीक्षा/$suite.expected" ]; then
        echo "NO GOLDEN"
        fallo=1
        continue
    fi
    if [ "$salida" = "$(normaliza < "परीक्षा/$suite.expected")" ]; then
        echo "$(echo "$salida" | tail -1)"
    else
        echo "DIFF"
        diff <(echo "$salida") "परीक्षा/$suite.expected" | head -20
        fallo=1
    fi
done

echo
echo "─── zymbol check"
for f in $(find . -name '*.zy' -not -path './.git/*' | sort); do
    salida=$(zymbol check "$f" 2>&1)
    estado=$?
    if [ $estado -ne 0 ]; then
        echo "  FAIL  $f"
        echo "$salida" | head -5
        fallo=1
    fi
done
[ "$fallo" -eq 0 ] && echo "  every source checks clean"

echo
if [ "$fallo" -eq 0 ]; then
    echo "सर्वपरीक्षा PASS"
else
    echo "सर्वपरीक्षा FAIL"
    exit 1
fi
