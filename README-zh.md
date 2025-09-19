# Florae - 植物照護助手

<div align="center">
    <img src="docs/banner.png" alt="Banner logo" width="450">
</div>

一款協助您照護植物的 Flutter 應用程式，讓您輕鬆管理植物並獲得照護提醒。

## 功能特點

- 📱 植物管理: 輕鬆管理您的所有植物及其照護需求
- ⏰ 照護提醒: 設定並接收植物照護的通知提醒  
- 📅 照護計畫: 查看未來的照護規劃
- 📖 植物圖鑑: 瀏覽豐富的植物資訊
- 📏 尺寸比較: 使用內建尺規功能進行實物比較
- 🌍 多語言支援: 支援英文、西班牙文和法文

## 環境需求

- Flutter SDK: 3.0.0 或以上
- Dart SDK: 2.17.0 或以上
- Android SDK: API Level 21 或以上
- iOS: 11.0 或以上 (部分功能可能受限)

## 安裝與執行

1. 複製專案
```bash
git clone https://github.com/yourusername/florae.git
cd florae
```

2. 安裝依賴
```bash 
flutter pub get
```

3. 執行應用
```bash
flutter run
```

## 專案結構

```
lib/
├── data/           # 數據模型與業務邏輯
├── screens/        # UI 頁面
│   ├── plugins/    # 自定義元件
│   └── widgets/    # 共用元件
├── services/       # 服務層
├── states/         # 狀態管理
├── l10n/           # 多語言資源
└── main.dart       # 應用程式入口
```

## 重要目錄說明

- `lib/data`: 包含所有數據模型和業務邏輯
- `lib/screens`: 包含所有頁面 UI 實現
- `lib/services`: 實現後端服務和 API 調用
- `lib/l10n`: 多語言翻譯文件

## 測試

運行單元測試:
```bash
flutter test
```

運行整合測試:
```bash
flutter drive --target=test_driver/app.dart
```

## 注意事項

- 通知功能可能受到不同手機廠商的電池優化政策影響
- 部分功能僅支援 Android 平台
- 建議參考 [Don't kill my app!](https://dontkillmyapp.com/) 以確保通知正常運作

## 語言支援

目前支援的語言:
- English
- Español
- Français

如需添加新語言，請在 `lib/l10n` 目錄下添加對應的翻譯文件。

## 授權

本專案採用 GNU General Public License v3.0 授權。