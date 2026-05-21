# Stereo PMTiles Viewer

Stereo PMTiles Viewer は、左右ペアの PMTiles 画像を iPad / Mac / PC のWebブラウザ上で横並び表示し、裸眼平行法によるステレオ閲覧を支援するためのWebアプリです。

主な機能は以下です。

- 左右 PMTiles ファイルの読み込み
- 左右画像の横並び表示
- パン・ズームの同期
- 視差X / 視差Yの手動調整
- 拡大・縮小時の視差表示補正
- GPS / 位置情報を使った現在位置表示
- GitHub Pages での公開
- iPad Safari での利用

このアプリは、ユーザーがあらかじめ作成した左右の PMTiles 形式のステレオペア画像を読み込んで表示します。アプリ本体には地図データやDEMデータは含まれません。

---

## 1. 全体の流れ

このWebアプリを使うまでの基本的な流れは以下です。

```text
QGISプラグイン等で左右のGeoTIFFを作成
↓
left.tif / right.tif を準備
↓
make_pmtiles.sh で left.pmtiles / right.pmtiles に変換
↓
WebアプリをGitHub Pagesで開く
↓
左PMTiles / 右PMTilesを選択
↓
ステレオペア画像を閲覧
```

---

## 2. 必要なファイル

### Webアプリ本体

GitHub Pages にアップロードする基本ファイルは以下です。

```text
index.html
style.css
app.js
manifest.json
service-worker.js
README.md
make_pmtiles.sh
```

### ユーザーが作成するデータ

Webアプリで読み込むデータは以下です。

```text
left.pmtiles
right.pmtiles
```

これらのPMTilesファイルは、通常はGitHubにアップロードせず、iPadやMacのローカルストレージ、iCloud Drive、外部ストレージなどに保存して、Webアプリの画面から選択します。

---

## 3. GeoTIFFからPMTilesを作成する

### 3.1 入力ファイル名

PMTiles変換スクリプトは、同じフォルダ内に以下の2つのGeoTIFFがあることを前提にしています。

```text
left.tif
right.tif
```

- `left.tif`：左目用画像
- `right.tif`：右目用画像

これらは、QGISプラグイン等で作成した位置情報付きGeoTIFFを想定しています。

---

### 3.2 フォルダ構成

変換前のフォルダは次のようにします。

```text
Stereo_Web_Test/
├── left.tif
├── right.tif
└── make_pmtiles.sh
```

---

### 3.3 make_pmtiles.sh の概要

`make_pmtiles.sh` は、GeoTIFFを直接PMTilesへ変換するためのMac用シェルスクリプトです。

スクリプトの主な処理は以下です。

1. スクリプトが置かれているフォルダへ移動する
2. `pmtiles_env` というPython仮想環境を作成する
3. `pip` を更新する
4. `rasterio` と `rio-pmtiles` をインストールする
5. 既存の `left.pmtiles` / `right.pmtiles` を削除する
6. `left.tif` を `left.pmtiles` に変換する
7. `right.tif` を `right.pmtiles` に変換する

---

### 3.4 make_pmtiles.sh の内容

```bash
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
```

---

### 3.5 変換の実行方法

Macのターミナルで、`left.tif` / `right.tif` / `make_pmtiles.sh` があるフォルダへ移動します。

例：デスクトップ上に `Stereo_Web_Test` フォルダがある場合

```bash
cd ~/Desktop/Stereo_Web_Test
```

最初に実行権限を付けます。

```bash
chmod +x make_pmtiles.sh
```

スクリプトを実行します。

```bash
./make_pmtiles.sh
```

---

### 3.6 変換後のファイル

成功すると、フォルダ内に以下が作成されます。

```text
Stereo_Web_Test/
├── left.tif
├── right.tif
├── left.pmtiles
├── right.pmtiles
├── make_pmtiles.sh
└── pmtiles_env/
```

Webアプリで使用するのは以下の2つです。

```text
left.pmtiles
right.pmtiles
```

---

## 4. Webアプリを起動する

### 4.1 GitHub Pagesで公開する場合

GitHubリポジトリに以下のファイルをアップロードします。

```text
index.html
style.css
app.js
manifest.json
service-worker.js
README.md
make_pmtiles.sh
```

GitHubのリポジトリ設定で、以下を設定します。

```text
Settings
↓
Pages
↓
Source: Deploy from a branch
Branch: main
Folder: /root
```

公開後、以下のようなURLでアクセスできます。

```text
https://ユーザー名.github.io/リポジトリ名/
```

---

### 4.2 iPadで開く

iPadのSafariでGitHub PagesのURLを開きます。

必要に応じて、Safariの共有ボタンから以下を選びます。

```text
ホーム画面に追加
```

これにより、Webアプリをホーム画面から起動できます。

---

## 5. PMTilesを表示する

Webアプリを開くと、画面下部に以下のボタンがあります。

```text
左PMTiles選択
右PMTiles選択
GPS開始
リセット
```

### 5.1 左PMTilesを選択

`左PMTiles選択` を押し、左目用のPMTilesを選びます。

例：

```text
left.pmtiles
area01_left.pmtiles
```

### 5.2 右PMTilesを選択

`右PMTiles選択` を押し、右目用のPMTilesを選びます。

例：

```text
right.pmtiles
area01_right.pmtiles
```

左右両方を読み込むと、画面上部に左右の画像が横並びで表示されます。

---

## 6. 基本操作

### 6.1 パン

画面上をドラッグすると、画像を移動できます。

左画像を動かすと右画像も同期して移動します。右画像を動かした場合も、左画像が同期します。

### 6.2 ズーム

ピンチ操作またはマウスホイールで拡大・縮小できます。

左右画像のズームは同期します。

### 6.3 リセット

`リセット` ボタンを押すと、視差X/Yを0に戻し、表示位置を初期化します。

---

## 7. 視差調整

画面下部に以下のスライダーがあります。

```text
視差X
視差Y
```

### 7.1 視差X

左右画像の水平方向のずれを調整します。

裸眼平行法で立体視しやすい位置になるように調整してください。

### 7.2 視差Y

左右画像の上下方向のずれを調整します。

通常は0付近で使用しますが、左右画像の生成条件によって上下方向の補正が必要な場合に使用します。

### 7.3 拡大・縮小時の視差

Webアプリでは、拡大・縮小操作を行っても、左右画像の同期と視差調整が維持されるようにしています。

必要に応じて、拡大後に視差X/Yスライダーで再調整してください。

---

## 8. GPS現在位置表示

### 8.1 GPS開始

`GPS開始` ボタンを押すと、ブラウザが位置情報の使用許可を求めます。

許可すると、現在位置が左右画像上に赤いマーカーで表示されます。

### 8.2 注意点

- GPS / 位置情報の利用にはHTTPSが必要です。
- GitHub Pages上で公開した場合はHTTPSでアクセスできます。
- iPadのWi-Fiモデルでは、Cellularモデルに比べて現在位置の精度が低い場合があります。
- 現在位置がPMTilesの範囲外にある場合、マーカーは表示されません。

---

## 9. オフライン利用について

このWebアプリはブラウザ上で動作します。

PMTilesファイル自体は、iPad内や外部ストレージ、iCloud Driveなどに保存しておき、使用時にファイル選択から読み込むことを想定しています。

ただし、初回アクセス時やライブラリ読み込み時にはインターネット接続が必要になる場合があります。野外で使う前に、必ず現地へ行く前にiPad上で起動とPMTiles表示を確認してください。

---

## 10. トラブルシューティング

### 10.1 PMTilesが表示されない

以下を確認してください。

- 左右両方のPMTilesを選択しているか
- PMTilesがラスターPMTilesとして正しく作成されているか
- `left.tif` / `right.tif` に位置情報が含まれているか
- PMTiles作成時にエラーが出ていないか

### 10.2 拡大すると白くなる

PMTilesに含まれている最大ズームレベルを超えて拡大すると、表示が白くなる場合があります。

その場合は以下を確認してください。

- 最新版の `app.js` が読み込まれているか
- ブラウザキャッシュやService Workerキャッシュが残っていないか
- PMTiles作成時のズームレベルが十分か

### 10.3 GPSマーカーが出ない

以下を確認してください。

- ブラウザで位置情報を許可したか
- iPadの位置情報サービスがオンになっているか
- HTTPSでアクセスしているか
- 現在位置がPMTilesの範囲内にあるか

---

## 11. データ作成時の注意

左右のGeoTIFFは、同じ範囲・同じ座標系・同じ解像度で作成してください。

左右のPMTilesが異なる範囲や異なるズーム構成を持つ場合、表示同期や視差調整がうまくいかないことがあります。

---

## 12. ライセンス

このリポジトリのライセンスは、利用目的に応じて設定してください。

例：

```text
MIT License
```

研究用途や教育用途で公開する場合でも、ソースコードとサンプルデータのライセンスは分けて明記することをおすすめします。

---

## 13. 免責事項

本アプリは、ユーザーが作成したPMTilesファイルをブラウザ上で表示するためのビューアです。

地形判読、野外調査、研究利用においては、元データの精度、作成条件、位置情報、GPS精度を確認したうえで使用してください。

本アプリの表示結果やGPS位置表示を、測量・法的境界確認・安全判断などの唯一の根拠として使用しないでください。
