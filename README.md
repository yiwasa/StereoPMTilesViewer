# Stereo PMTiles Viewer

[日本語の説明はこちら](#日本語)

[Stereo PMTiles Viewer](https://yiwasa.github.io/StereoPMTilesViewer/) is a web application for displaying a left-right pair of stereo PMTiles images side by side in a web browser on an iPad, Mac, or PC. It supports stereoscopic viewing using the unaided parallel-viewing method.

Main features:

- Load left and right PMTiles files
- Display the left and right images side by side
- Synchronize panning and zooming between the two images
- Manually adjust horizontal and vertical parallax
- Correct the displayed parallax when zooming in or out
- Display the current location using GPS or other location services

---

## 1. Usage

### 1.1 Prepare the data

* Create the left and right GeoTIFF images using a QGIS plugin such as [Stereo MPI-RRIM Creator](https://github.com/yiwasa/Stereo-MPI-RRIM-Creator).
* Convert the GeoTIFFs to PMTiles using a QGIS plugin.

    * Install the **GeoTIFF2PMTiles** plugin in QGIS.
    * In the **Processing Toolbox**, expand **PMTiles Converter** > **PMTiles Tools**, and select **Convert GeoTIFF to PMTiles**.
    * Set `left.tif` as **Left Image (Left GeoTIFF)** and `right.tif` as **Right Image (Right GeoTIFF)**.
    * Select an output folder and click **Run**.
    * When processing is complete, the following files will be created in the selected folder:

```text
output_folder/
├── left.pmtiles
└── right.pmtiles
```

The tool checks whether the Python libraries required for conversion, including `rasterio`, `rio-pmtiles`, and `pmtiles`, are available in the QGIS environment. If the libraries are not available, the tool attempts to install them automatically. The first run may therefore take several minutes and requires an Internet connection.

The output files are raster PMTiles containing JPEG tiles with a tile size of 512 pixels.

> [!NOTE]
> To view the files on a mobile device, copy `left.pmtiles` and `right.pmtiles` to the device itself or to a location accessible from the device, such as iCloud Drive or external storage.

### 1.2 Open the web application

* Open [Stereo PMTiles Viewer](https://yiwasa.github.io/StereoPMTilesViewer/).
    * On an iPad or another mobile device, open the page, tap the browser's Share button, and select **Add to Home Screen** for easier access in the future.
* Use the left and right **Select PMTiles** controls to select `left.pmtiles` and `right.pmtiles`.
* Pan or zoom the images as needed. You can also use the parallax controls at the bottom of the screen and display your current location using GPS.

### 1.3 Offline use

This web application runs in a browser. PMTiles files can be stored on an iPad, in external storage, or in iCloud Drive and loaded using the file-selection controls.

However, an Internet connection may be required when accessing the application for the first time or when loading its libraries. Before using the application in the field, open it on the device and confirm that both PMTiles files are displayed correctly.

---

## 2. Troubleshooting

### 2.1 The PMTiles images are not displayed

Check the following:

- Both the left and right PMTiles files have been selected.
- The files were successfully created as raster PMTiles.
- `left.tif` and `right.tif` contain valid georeferencing information.
- No errors occurred during the PMTiles conversion.
- The current map view is within the geographic extent of the PMTiles files.

### 2.2 The conversion fails in QGIS

Check the following:

- Both GeoTIFF inputs have been specified correctly.
- The selected output folder exists and is writable.
- QGIS has permission to install or access the required Python libraries.
- An Internet connection is available if the libraries need to be installed automatically.

If automatic installation fails, restart QGIS with the permissions required to install Python packages and run the tool again.

### 2.3 The GPS marker is not displayed

Check the following:

- Location access has been allowed in the browser.
- Location Services are enabled on the device.
- The application is accessed over HTTPS.
- The current location is within the geographic extent of the PMTiles files.

---

## 3. Notes on data preparation

The left and right GeoTIFFs should have the same geographic extent, coordinate reference system, and spatial resolution. If the resulting PMTiles files have different extents or zoom-level configurations, synchronized display and parallax adjustment may not work correctly.

---

## 4. License

MIT License

---

## 5. Disclaimer

This application is a viewer for displaying user-created PMTiles files in a web browser.

When using it for terrain interpretation, field surveys, or research, verify the accuracy of the source data, data-processing conditions, georeferencing information, and GPS positioning.

Do not use the displayed results or GPS position as the sole basis for surveying, legal boundary determination, safety decisions, or other critical purposes.

---

# 日本語

[Stereo PMTiles Viewer](https://yiwasa.github.io/StereoPMTilesViewer/) は、左右一組のステレオPMTiles画像をiPad、Mac、PCのWebブラウザ上で横並びに表示し、裸眼平行法による実体視を支援するWebアプリです。

主な機能は以下のとおりです。

- 左右のPMTilesファイルの読み込み
- 左右画像の横並び表示
- パン・ズームの同期
- 視差X・視差Yの手動調整
- 拡大・縮小時の視差表示補正
- GPS・位置情報を利用した現在位置の表示

---

## 1. 使い方

### 1.1 データの準備

* [Stereo MPI-RRIM Creator](https://github.com/yiwasa/Stereo-MPI-RRIM-Creator)などのQGISプラグインを使用して、左右のGeoTIFF画像を作成します。
* QGISプラグインを使用してGeoTIFFをPMTilesに変換する

    * QGISのGeoTIFF2PMTilesプラグインをインストール
    * プロセシングツールボックスの`PMTiles Converter`→`PMTiles Tools`を展開し、`Convert GeoTIFF to PMTiles`を選択
    * 左画像（Left GeoTIFF）に`left.tif`を、右画像（Right GeoTIFF）に`right.tif`を指定
    * 保存先フォルダを選択し、実行をクリック
    * 処理が完了すると、指定したフォルダ内に次のファイルが生成されます。

```text
保存先フォルダ/
├── left.pmtiles
└── right.pmtiles
```

このツールは、`rasterio`、`rio-pmtiles`、`pmtiles`など、変換に必要なPythonライブラリがQGISの環境で利用できるかを確認します。ライブラリが存在しない場合には自動インストールを試みるため、初回の実行には数分かかることがあり、インターネット接続が必要です。

出力されるファイルは、タイルサイズ512ピクセル、JPEG形式のラスターPMTilesです。

> [!NOTE]
> モバイル端末で閲覧する場合は、`left.pmtiles`と`right.pmtiles`を端末内、iCloud Drive、または外部ストレージなど、端末からアクセスできる場所へコピーしてください。

### 1.2 Webアプリを起動する

* [Stereo PMTiles Viewer](https://yiwasa.github.io/StereoPMTilesViewer/)を開く
    * iPadなどでは、ページを開いた後、ブラウザ右上の共有ボタンをタップ　→ ホーム画面に追加 とすると、次回からページにアクセスしやすくなります
* 左右それぞれの**PMTiles選択**から、`left.pmtiles`と`right.pmtiles`を選択します。
* 必要に応じて画像を移動または拡大・縮小します。画面下部の視差調整機能や、GPSによる現在位置表示も利用できます。

### 1.3 オフライン利用について

このWebアプリはブラウザ上で動作します。PMTilesファイルは、iPad内、外部ストレージ、iCloud Driveなどに保存し、使用時にファイル選択画面から読み込むことができます。

ただし、初回アクセス時やライブラリの読み込み時には、インターネット接続が必要になる場合があります。野外で使用する前に、端末上でWebアプリを起動し、左右のPMTilesが正しく表示されることを確認してください。

---

## 2. トラブルシューティング

### 2.1 PMTilesが表示されない

以下を確認してください。

- 左右両方のPMTilesを選択しているか
- ラスターPMTilesとして正常に作成されているか
- `left.tif`と`right.tif`に正しい位置情報が含まれているか
- PMTilesの変換時にエラーが発生していないか
- 現在表示している範囲がPMTilesの収録範囲内にあるか

### 2.2 QGISでの変換に失敗する

以下を確認してください。

- 左右のGeoTIFFを正しく指定しているか
- 保存先フォルダが存在し、書き込み可能であるか
- QGISから必要なPythonライブラリをインストールまたは参照できるか
- ライブラリの自動インストールが必要な場合、インターネットに接続されているか

自動インストールに失敗する場合は、Pythonパッケージのインストールに必要な権限でQGISを起動し直し、再度実行してください。

### 2.3 GPSマーカーが表示されない

以下を確認してください。

- ブラウザで位置情報の利用を許可しているか
- 端末の位置情報サービスがオンになっているか
- HTTPSでアクセスしているか
- 現在位置がPMTilesの収録範囲内にあるか

---

## 3. データ作成時の注意

左右のGeoTIFFは、同じ範囲、同じ座標参照系、同じ解像度で作成してください。左右のPMTilesで収録範囲やズームレベルの構成が異なる場合、表示の同期や視差調整が正しく機能しないことがあります。

---

## 4. ライセンス

MIT License

---

## 5. 免責事項

本アプリは、ユーザーが作成したPMTilesファイルをWebブラウザ上で表示するためのビューアです。

地形判読、野外調査、研究などに利用する場合は、元データの精度、作成条件、位置情報、GPS精度を確認したうえで使用してください。

本アプリの表示結果やGPS位置表示を、測量、法的境界の確認、安全上の判断などにおける唯一の根拠として使用しないでください。
