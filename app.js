let leftMap;
let rightMap;

let leftLayer = null;
let rightLayer = null;

let leftPMTiles = null;
let rightPMTiles = null;

let leftHeader = null;
let rightHeader = null;

let isSyncing = false;

let parallaxX = 0;
let parallaxY = 0;

let gpsWatchId = null;
let gpsEnabled = false;

let leftGpsMarker = null;
let rightGpsMarker = null;

const leftFileInput = document.getElementById("leftFile");
const rightFileInput = document.getElementById("rightFile");

const parallaxXInput = document.getElementById("parallaxX");
const parallaxYInput = document.getElementById("parallaxY");
const parallaxXValue = document.getElementById("parallaxXValue");
const parallaxYValue = document.getElementById("parallaxYValue");

const gpsButton = document.getElementById("gpsButton");
const resetButton = document.getElementById("resetButton");
const statusEl = document.getElementById("status");

function setStatus(text) {
  statusEl.textContent = text;
}

function initMaps() {
  leftMap = L.map("leftMap", {
    zoomControl: false,
    attributionControl: false,
    preferCanvas: true,
    inertia: true,
    maxZoom: 30,
    zoomSnap: 0.25,
    zoomDelta: 0.5
  });

  rightMap = L.map("rightMap", {
    zoomControl: false,
    attributionControl: false,
    preferCanvas: true,
    inertia: true,
    maxZoom: 30,
    zoomSnap: 0.25,
    zoomDelta: 0.5
  });

  leftMap.setView([0, 0], 0);
  rightMap.setView([0, 0], 0);

  leftMap.on("move zoom", () => {
    syncRightToLeft();
  });

  rightMap.on("move zoom", () => {
    syncLeftToRight();
  });

  window.addEventListener("resize", () => {
    leftMap.invalidateSize();
    rightMap.invalidateSize();
    syncRightToLeft();
  });
}

async function loadPMTiles(file, side) {
  if (!file) {
    return;
  }

  const sideName = side === "left" ? "左" : "右";

  setStatus(`${sideName}PMTilesを確認しています: ${file.name}`);

  try {
    // 空ファイルや、明らかに小さすぎるファイルを除外
    if (file.size === 0) {
      throw new Error("ファイルの内容が空です");
    }

    if (file.size < 127) {
      throw new Error(
        "ファイルサイズが小さすぎます。正しいPMTilesファイルではない可能性があります"
      );
    }

    const source = new pmtiles.FileSource(file);
    const archive = new pmtiles.PMTiles(source);

    // 読み込みが完了しない場合に、画面が永久に止まることを防ぐ
    const timeoutPromise = new Promise((_, reject) => {
      setTimeout(() => {
        reject(
          new Error(
            "PMTilesのヘッダーを読み込めませんでした。ファイルが壊れているか、対応していない形式の可能性があります"
          )
        );
      }, 15000);
    });

    const header = await Promise.race([
      archive.getHeader(),
      timeoutPromise
    ]);

    console.log("PMTiles header", side, header);

    /*
      PMTilesのtileType
      1 = MVT（ベクトル）
      2 = PNG
      3 = JPEG
      4 = WebP
      5 = AVIF
    */
    const rasterTileTypes = [2, 3, 4];

    if (!rasterTileTypes.includes(header.tileType)) {
      if (header.tileType === 1) {
        throw new Error(
          "このファイルはベクトルPMTilesです。このビューアーではラスターPMTilesのみ表示できます"
        );
      }

      throw new Error(
        `タイル形式を判定できませんでした（tileType: ${header.tileType}）`
      );
    }

    if (
      !Number.isFinite(header.minZoom) ||
      !Number.isFinite(header.maxZoom)
    ) {
      throw new Error(
        "PMTiles内のズームレベル情報を読み取れませんでした"
      );
    }

    const nativeMinZoom = header.minZoom;
    const nativeMaxZoom = header.maxZoom;
    const displayMaxZoom = 30;

    setStatus(`${sideName}PMTilesを読み込んでいます: ${file.name}`);

    const layer = pmtiles.leafletRasterLayer(archive, {
      attribution: "",
      minZoom: 0,
      maxZoom: displayMaxZoom,
      minNativeZoom: nativeMinZoom,
      maxNativeZoom: nativeMaxZoom,
      noWrap: true,
      updateWhenZooming: false,
      updateWhenIdle: true,
      keepBuffer: 8
    });

    // タイル単位の読込エラーも画面に出す
    layer.on("tileerror", (event) => {
      console.error("PMTiles tile error", side, event);

      const message =
        event && event.error && event.error.message
          ? event.error.message
          : "タイルデータを読み込めませんでした";

      setStatus(`${sideName}PMTilesタイル読込エラー: ${message}`);
    });

    if (side === "left") {
      if (leftLayer) {
        leftMap.removeLayer(leftLayer);
      }

      leftPMTiles = archive;
      leftHeader = header;
      leftLayer = layer.addTo(leftMap);

      leftMap.setMinZoom(0);
      leftMap.setMaxZoom(displayMaxZoom);
      fitMapToHeader(leftMap, header);
      leftMap.invalidateSize();
    } else {
      if (rightLayer) {
        rightMap.removeLayer(rightLayer);
      }

      rightPMTiles = archive;
      rightHeader = header;
      rightLayer = layer.addTo(rightMap);

      rightMap.setMinZoom(0);
      rightMap.setMaxZoom(displayMaxZoom);

      if (!leftHeader) {
        fitMapToHeader(rightMap, header);
      }

      rightMap.invalidateSize();
    }

    if (leftHeader && rightHeader) {
      syncRightToLeft();
    }

    const tileTypeNames = {
      2: "PNG",
      3: "JPEG",
      4: "WebP"
    };

    const tileTypeName =
      tileTypeNames[header.tileType] || String(header.tileType);

    setStatus(
      `${sideName}PMTiles読込完了: ${tileTypeName} / native zoom ${nativeMinZoom}-${nativeMaxZoom}`
    );
  } catch (error) {
    console.error("PMTiles load error", side, error);

    const message =
      error && error.message
        ? error.message
        : String(error);

    setStatus(`${sideName}PMTiles読込エラー: ${message}`);

    alert(
      `${sideName}PMTilesを開けませんでした。\n\n` +
      `ファイル名: ${file.name}\n` +
      `ファイルサイズ: ${Math.round(file.size / 1024).toLocaleString()} KB\n\n` +
      `原因:\n${message}`
    );
  }
}

function fitMapToHeader(map, header) {
  const centerLat = header.centerLat ?? 0;
  const centerLon = header.centerLon ?? 0;

  let zoom = header.maxZoom;

  if (typeof zoom !== "number" || !Number.isFinite(zoom)) {
    zoom = 10;
  }

  zoom = Math.max(0, zoom - 2);

  map.setView([centerLat, centerLon], zoom, {
    animate: false
  });

  map.setMinZoom(0);
  map.setMaxZoom(30);
}


function getEffectiveParallaxX(map) {
  return parallaxX;
}

function getEffectiveParallaxY(map) {
  return parallaxY;
}

function syncRightToLeft() {
  if (isSyncing || !leftMap || !rightMap || !leftLayer || !rightLayer) {
    return;
  }

  isSyncing = true;

  const zoom = leftMap.getZoom();
  const center = leftMap.getCenter();
  const projected = leftMap.project(center, zoom);

  const adjusted = L.point(
    projected.x + getEffectiveParallaxX(leftMap),
    projected.y + getEffectiveParallaxY(leftMap)
  );

  const rightCenter = rightMap.unproject(adjusted, zoom);

  rightMap.setView(rightCenter, zoom, {
    animate: false
  });

  isSyncing = false;
}

function syncLeftToRight() {
  if (isSyncing || !leftMap || !rightMap || !leftLayer || !rightLayer) {
    return;
  }

  isSyncing = true;

  const zoom = rightMap.getZoom();
  const center = rightMap.getCenter();
  const projected = rightMap.project(center, zoom);

  const adjusted = L.point(
    projected.x - getEffectiveParallaxX(rightMap),
    projected.y - getEffectiveParallaxY(rightMap)
  );

  const leftCenter = leftMap.unproject(adjusted, zoom);

  leftMap.setView(leftCenter, zoom, {
    animate: false
  });

  isSyncing = false;
}

function updateParallaxValues() {
  parallaxX = Number(parallaxXInput.value);
  parallaxY = Number(parallaxYInput.value);

  parallaxXValue.textContent = String(Math.round(parallaxX));
  parallaxYValue.textContent = String(Math.round(parallaxY));

  syncRightToLeft();
}

function resetView() {
  parallaxXInput.value = "0";
  parallaxYInput.value = "0";
  updateParallaxValues();

  if (leftHeader) {
    fitMapToHeader(leftMap, leftHeader);
  }

  if (rightHeader && !leftHeader) {
    fitMapToHeader(rightMap, rightHeader);
  }

  syncRightToLeft();
  setStatus("表示をリセットしました");
}

function gpsIcon() {
  return L.divIcon({
    className: "gps-marker",
    iconSize: [22, 22],
    iconAnchor: [11, 11]
  });
}

function startGPS() {
  if (!("geolocation" in navigator)) {
    setStatus("このブラウザではGPSを使用できません");
    return;
  }

  gpsEnabled = true;
  gpsButton.textContent = "GPS停止";
  setStatus("GPS取得中...");

  gpsWatchId = navigator.geolocation.watchPosition(
    (position) => {
      const lat = position.coords.latitude;
      const lon = position.coords.longitude;
      const accuracy = Math.round(position.coords.accuracy);

      const latlng = [lat, lon];

      if (!leftGpsMarker) {
        leftGpsMarker = L.marker(latlng, { icon: gpsIcon() }).addTo(leftMap);
      } else {
        leftGpsMarker.setLatLng(latlng);
      }

      if (!rightGpsMarker) {
        rightGpsMarker = L.marker(latlng, { icon: gpsIcon() }).addTo(rightMap);
      } else {
        rightGpsMarker.setLatLng(latlng);
      }

      setStatus(`GPS: 精度 約${accuracy}m`);
    },
    (error) => {
      setStatus(`GPSエラー: ${error.message}`);
    },
    {
      enableHighAccuracy: true,
      maximumAge: 1000,
      timeout: 15000
    }
  );
}

function stopGPS() {
  gpsEnabled = false;
  gpsButton.textContent = "GPS開始";

  if (gpsWatchId !== null) {
    navigator.geolocation.clearWatch(gpsWatchId);
    gpsWatchId = null;
  }

  if (leftGpsMarker) {
    leftMap.removeLayer(leftGpsMarker);
    leftGpsMarker = null;
  }

  if (rightGpsMarker) {
    rightMap.removeLayer(rightGpsMarker);
    rightGpsMarker = null;
  }

  setStatus("GPSを停止しました");
}

function toggleGPS() {
  if (gpsEnabled) {
    stopGPS();
  } else {
    startGPS();
  }
}

leftFileInput.addEventListener("change", async (event) => {
  const file = event.target.files[0];
  await loadPMTiles(file, "left");
});

rightFileInput.addEventListener("change", async (event) => {
  const file = event.target.files[0];
  await loadPMTiles(file, "right");
});

parallaxXInput.addEventListener("input", updateParallaxValues);
parallaxYInput.addEventListener("input", updateParallaxValues);

gpsButton.addEventListener("click", toggleGPS);
resetButton.addEventListener("click", resetView);

if ("serviceWorker" in navigator) {
  window.addEventListener("load", async () => {
    const registrations = await navigator.serviceWorker.getRegistrations();
    for (const registration of registrations) {
      await registration.unregister();
    }
    console.log("Service Worker unregistered for development");
  });
}

initMaps();
updateParallaxValues();