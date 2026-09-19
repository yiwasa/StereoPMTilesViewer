#!/bin/bash

set -euo pipefail

echo "======================================"
echo "GeoTIFF to PMTiles Converter"
echo "======================================"

cd "$(dirname "$0")"

LEFT_TIF="left.tif"
RIGHT_TIF="right.tif"
LEFT_PMTILES="left.pmtiles"
RIGHT_PMTILES="right.pmtiles"
VENV_DIR="pmtiles_env"

# 適切なPython 3.8以上を自動検索する関数
find_python() {
    # 1. まず標準のコマンドから探す
    for cmd in python3.12 python3.11 python3.10 python3.9 python3.8 python3; do
        if command -v "$cmd" >/dev/null 2>&1; then
            local minor=$("$cmd" -c 'import sys; print(sys.version_info.minor)' 2>/dev/null || echo "0")
            if [ "$minor" -ge 8 ]; then
                echo "$cmd"
                return 0
            fi
        fi
    done

    # 2. 見つからない（または古い）場合は、QGIS内蔵のPythonを探す
    for app in "/Applications/QGIS.app" "/Applications/QGIS-LTR.app"; do
        local qgis_py="$app/Contents/MacOS/bin/python3"
        if [ -x "$qgis_py" ]; then
            local minor=$("$qgis_py" -c 'import sys; print(sys.version_info.minor)' 2>/dev/null || echo "0")
            if [ "$minor" -ge 8 ]; then
                echo "$qgis_py"
                return 0
            fi
        fi
    done

    return 1
}

echo "[1/5] システムまたはQGISから適切なPythonを探しています..."
PYTHON_CMD=$(find_python) || {
    echo ""
    echo "============================================================"
    echo "エラー: 必要な Python (3.8以上) または QGIS が見つかりません。"
    echo "ブラウザで QGIS のダウンロードページを開きます。"
    echo "============================================================"
    open "https://qgis.org/"
    exit 1
}

echo "使用するPython: $PYTHON_CMD ($("$PYTHON_CMD" --version))"

echo ""
echo "[2/5] 仮想環境を作り直しています..."
rm -rf "$VENV_DIR"
"$PYTHON_CMD" -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo ""
echo "[3/5] 変換ツールをインストールしています..."
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade rasterio rio-pmtiles pmtiles

echo ""
echo "[4/5] 既存のファイルを削除しています..."
rm -f "$LEFT_PMTILES" "$RIGHT_PMTILES"

echo ""
echo "[5/5] 画像を変換しています..."
echo "左画像を変換中..."
rio pmtiles "$LEFT_TIF" "$LEFT_PMTILES" --format JPEG --tile-size 512

echo "右画像を変換中..."
rio pmtiles "$RIGHT_TIF" "$RIGHT_PMTILES" --format JPEG --tile-size 512

echo ""
echo "======================================"
echo "完了しました"
ls -lh "$LEFT_PMTILES" "$RIGHT_PMTILES"
echo "======================================"