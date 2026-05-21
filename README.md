# Stereo PMTiles Viewer

[Stereo PMTiles Viewer](https://yiwasa.github.io/StereoPMTilesViewer/) は、左右ペアのステレオペア PMTiles 画像を iPad / Mac / PC のWebブラウザ上で横並び表示し、裸眼平行法によるステレオ閲覧を支援するためのWebアプリです。

主な機能は以下です。

- 左右 PMTiles ファイルの読み込み
- 左右画像の横並び表示
- パン・ズームの同期
- 視差X / 視差Yの手動調整
- 拡大・縮小時の視差表示補正
- GPS / 位置情報を使った現在位置表示


---

## 1. 使い方

### 1.1 事前準備

* [QGISプラグイン Stereo MPI-RRIM Creatorなど]で左右のGeoTIFFを作成し、left.tif / right.tif として保存

* githubのファイル一覧にあるファイル（MacOSの場合は`make_pmtiles_mac.sh` /Windows OSの場合は`make_pmtiles_windows.bat`）を left.tif / right.tif を保存したフォルダにダウンロード

* PMTilesへの変換

  * macOSの場合：保存したフォルダを右クリックし「新規ターミナルタブでフォルダに移動」を選択 → `chmod +x make_pmtiles_mac.sh` をターミナルにコピペして、エンター　→ `./make_pmtiles_mac.sh` をターミナルにコピペして、エンター
  * Windowsの場合：保存した `make_pmtiles_windows.bat` をダブルクリック
  →left.pmtiles / right.pmtiles が生成される
    * モバイル端末で閲覧する場合にはモバイル端末にpmtilesファイルをコピーする

* 成功すると、フォルダ内に以下が作成されます。

```text
Stereo_Web_Test/
├── left.tif
├── right.tif
├── left.pmtiles
├── right.pmtiles
├── make_pmtiles.sh
└── pmtiles_env/
```

### 1.2 webアプリを起動する

* [Stereo PMTiles Viewer](https://yiwasa.github.io/StereoPMTilesViewer/) を開く
  * iPadなどでは、ページを開いた後、ブラウザ右上の共有ボタンをタップ　→ `ホーム画面に追加` とすると、ページにアクセスしやすくなります

* 左右それぞれの　`PMTiles選択` から、PMTilesを選ぶ

* 必要に応じて、画像の移動や拡大・縮小、画面下部の視差調整を利用してください。GPSを利用して現在位置を表示することもできます。

### 1.3. オフライン利用について

このWebアプリはブラウザ上で動作します。

PMTilesファイル自体は、iPad内や外部ストレージ、iCloud Driveなどに保存しておき、使用時にファイル選択から読み込むことを想定しています。

ただし、初回アクセス時やライブラリ読み込み時にはインターネット接続が必要になる場合があります。

野外で使う前に、必ず現地へ行く前にiPad上で起動とPMTiles表示を確認してください。

---

## 2. トラブルシューティング

### 2.1 PMTilesが表示されない

以下を確認してください。

- 左右両方のPMTilesを選択しているか
- PMTilesがラスターPMTilesとして正しく作成されているか
- `left.tif` / `right.tif` に位置情報が含まれているか
- PMTiles作成時にエラーが出ていないか

### 2.2 GPSマーカーが出ない

以下を確認してください。

- ブラウザで位置情報を許可したか
- iPadの位置情報サービスがオンになっているか
- HTTPSでアクセスしているか
- 現在位置がPMTilesの範囲内にあるか

---

## 3. データ作成時の注意

左右のGeoTIFFは、同じ範囲・同じ座標系・同じ解像度で作成してください。

左右のPMTilesが異なる範囲や異なるズーム構成を持つ場合、表示同期や視差調整がうまくいかないことがあります。

---

## 12. ライセンス

MIT License

---

## 13. 免責事項

本アプリは、ユーザーが作成したPMTilesファイルをブラウザ上で表示するためのビューアです。

地形判読、野外調査、研究利用においては、元データの精度、作成条件、位置情報、GPS精度を確認したうえで使用してください。

本アプリの表示結果やGPS位置表示を、測量・法的境界確認・安全判断などの唯一の根拠として使用しないでください。
