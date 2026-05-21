#!/bin/bash

set -e

echo "======================================"
echo "GeoTIFF to PMTiles Converter"
echo "======================================"

cd "$(dirname "$0")"

LEFT_TIF="left.tif"
RIGHT_TIF="right.tif"

LEFT_PMTILES="left.pmtiles"
RIGHT_PMTILES="right.pmtiles"

VENV_DIR="pmtiles_env"

echo ""
echo "[1/5] Python仮想環境を準備しています..."

if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

source "$VENV_DIR/bin/activate"

echo ""
echo "[2/5] 必要な変換ツールをインストールしています..."
python -m pip install --upgrade pip
python -m pip install rasterio rio-pmtiles

echo ""
echo "[3/5] 既存のPMTilesを削除しています..."
rm -f "$LEFT_PMTILES"
rm -f "$RIGHT_PMTILES"

echo ""
echo "[4/5] 左画像をPMTilesに変換しています..."
rio pmtiles "$LEFT_TIF" "$LEFT_PMTILES" \
  --format JPEG \
  --resampling bilinear \
  --tile-size 512

echo ""
echo "[5/5] 右画像をPMTilesに変換しています..."
rio pmtiles "$RIGHT_TIF" "$RIGHT_PMTILES" \
  --format JPEG \
  --resampling bilinear \
  --tile-size 512

echo ""
echo "======================================"
echo "完了しました"
echo "次の2ファイルを確認してください"
echo "$LEFT_PMTILES"
echo "$RIGHT_PMTILES"
echo "======================================"
``