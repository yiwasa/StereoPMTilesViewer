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

check_input() {
    if [ ! -f "$1" ]; then
        echo ""
        echo "エラー: $1 が見つかりません。"
        echo "このスクリプトと同じフォルダーに置いてください。"
        exit 1
    fi

    if [ ! -s "$1" ]; then
        echo ""
        echo "エラー: $1 の内容が空です。"
        exit 1
    fi
}

check_pmtiles() {
    FILE="$1"

    if [ ! -s "$FILE" ]; then
        echo ""
        echo "エラー: $FILE が作成されていないか、内容が空です。"
        exit 1
    fi

    MAGIC="$(LC_ALL=C head -c 7 "$FILE")"

    if [ "$MAGIC" != "PMTiles" ]; then
        echo ""
        echo "エラー: $FILE は正常なPMTilesではありません。"
        echo "ファイル先頭:"
        xxd -l 32 "$FILE" || true
        exit 1
    fi

    echo "$FILE のPMTilesヘッダーを確認しました。"
}

check_input "$LEFT_TIF"
check_input "$RIGHT_TIF"

echo ""
echo "[1/6] Python仮想環境を作り直しています..."
rm -rf "$VENV_DIR"
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo ""
echo "[2/6] 変換ツールをインストールしています..."
python -m pip install --upgrade pip setuptools wheel
python -m pip install --upgrade rasterio rio-pmtiles pmtiles

echo ""
echo "[3/6] インストールされたツールを確認しています..."
python -m pip show rio-pmtiles
rio pmtiles --help >/dev/null

echo ""
echo "[4/6] 以前の出力ファイルを削除しています..."
rm -f "$LEFT_PMTILES" "$RIGHT_PMTILES"

echo ""
echo "[5/6] 左画像を変換しています..."
rio pmtiles "$LEFT_TIF" "$LEFT_PMTILES" \
  --format JPEG \
  --resampling bilinear \
  --tile-size 512

check_pmtiles "$LEFT_PMTILES"

echo ""
echo "[6/6] 右画像を変換しています..."
rio pmtiles "$RIGHT_TIF" "$RIGHT_PMTILES" \
  --format JPEG \
  --resampling bilinear \
  --tile-size 512

check_pmtiles "$RIGHT_PMTILES"

echo ""
echo "======================================"
echo "変換とPMTilesヘッダー確認が完了しました"
echo ""
ls -lh "$LEFT_PMTILES" "$RIGHT_PMTILES"
echo ""
echo "次のファイルをビューアーで選択してください:"
echo "$LEFT_PMTILES"
echo "$RIGHT_PMTILES"
echo "======================================"
``