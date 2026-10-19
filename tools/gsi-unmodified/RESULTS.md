# 無改変Android 10 GSIの実機試験

## 判定

配布原本のGSIで起動と設定画面の操作を実機確認した。GSIのファイルシステム、プロパティ、署名、AVBは編集していない。user版・ro.debuggable=0・SELinux Enforcingでの結果である。全機能の互換性認証ではない。

## 入力と条件

- 配布物: aosp_arm64-exp-QJR1.191112.001-6004257.zip。
- 使用原本: gsi/android10-aosp-arm64-system.img、1498497024bytes。
- 原本および起動直前の実機system prefix SHA256: 18a42a793798294183089e582c56bdf666e9d493523fb4389c6a3f7101ec6b60。
- 実機: TAB-A04-BR3、元USB修正版4.14.141+ #18、既存vendor。AOSP本体・参照BSPに変更なし。
- ユーザー承認によりuserdataを初期化。2回目は同じGSIのまま、このPCのADB公開鍵のみuserdataへ登録して通常のshell接続を使用した。秘密鍵やGSIの認証設定を変更していない。
- 一時vendorサービスで60/180秒のプロパティ・画面・ログを保存し、独立240秒deadlineで修正recoveryへ自動復帰。GSIのpolicyは変更していない。

## 実測

| 項目 | 結果 |
| --- | --- |
| 初回起動完了 | 約57秒でsys.boot_completed=1、60/180秒の記録でも1 |
| 実ビルド | QJR1.191112.001/6004257:user/release-keys、ro.debuggable=0 |
| SELinux | Enforcing |
| 描画・操作 | USB認証ダイアログ、Settings、Wi-Fi設定を実描画。ADBによる画面起動・キー操作に応答 |
| Home解決 | com.android.launcher3/.Launcher |
| Wi-Fi | 電源ON、周辺のAPを検出。未接続でありインターネット通信は未試験 |
| Bluetooth | enabled=true、state=ON。ペアリング・通信は未試験 |
| Camera | camera HAL running、camera serviceが2台を列挙。撮影は未試験 |
| Audio | AudioFlinger Hardware status=0。実際の再生・録音は未試験 |
| 復旧経路 | 単発deadlineでrecoveryへ実際に戻り、root ADBで記録を回収 |

## NVRAM警告

Wi-Fi一覧にNVRAM WARNING: Err=0x10がある。このkernelのwlan_lib.hはBIT(4)をNVRAM_ERROR_INVALID_MAC_ADDRと定義する。試験前の稼働AOSPのuserdataバックアップとGSI試験後のAPCFG/APRDEB/WIFIは、ともに1026bytes、SHA256 58698595d8c709c78d8b518e7a510d537cf6226014081f8cf2007a8a6d2ffa52で完全一致し、MAC欄はゼロだった。今回の初期化で異なる値へ書き換わった証拠はない。通常AOSPへの復元・userdata再初期化後も、Wi-Fi一覧に同じErr=0x10を確認した。GSI限定の症状ではなく、共通する既存のMAC校正データの課題として残る。今回この警告自体の修正はしていない。

GSIではnvram_daemonのproc_cmdline等にAVC拒否も記録された。これだけで警告の原因や全互換性を断定しない。主要機能の起動確認と全周辺機能の完全互換は区別する。

## 転送と失敗試行の扱い

初回streaming転送後のSHAは元AOSPのprefixと一致し、GSIは実際には配置されていなかった。照合失敗後に外側shellが再起動を続ける不備もあった。この元AOSP起動をGSI成功に数えていない。strictなsubprocess checkへ修正した。

転送物自体とホスト展開内容のSHAが正しくても、LZ4の既定sparse出力はゼロ範囲をseekして旧ブロックを残すため、ブロックデバイス上でSHA不一致になった。--no-sparseを指定して全ゼロ領域も書くと、原本との完全一致を確認できた。以後、照合が通るまで起動しない手順で実施した。

## recoveryの修正とrelease

旧recoveryはMTK ramdisk名がROOTFSで、LKが名前不一致として拒否しrootfs mount panicとなった。純正と同じRECOVERY名に修正。実機メニュー、ユーザーの画面確認、ADB recovery列挙とroot shellを確認した。

公開main90c264aで梱包toolを修正し、v1.0のrecovery.img、SHA256SUMS、説明を差替え。GitHubから再ダウンロードしてrecovery SHA256 0b42e8b9fb24e0bbba369bb8d8e813c884d49a9c045fc4944f07ef30365a6da2およびmanifest一致を確認。他のreleaseバイナリは変更していない。

## 記録

- logs/gsi-unmodified-runtime/ 以下: state、Wi-Fi、Bluetooth、camera、audio、logcat。
- analysis/gsi-unmodified-capture/tmp/ 以下: 60/180秒のGSI内記録。
- analysis/gsi-settings-interactive.png、gsi-wifi-scan.png: 操作試験時の画面。
- logs/gsi-unmodified-written-sha.txt: 起動前の原本一致。
- logs/gsi-aosp-restored-system-sha.txt: 通常AOSP全systemの復元一致。
- logs/flash.log: 書込み固定ログ。logs/uart-ttyUSB0-921600.log: 連続UART。

公開試験手順: https://github.com/mouseos/android_device_benesse_a04br3/tree/gsi-unmodified-20261019/tools/gsi-unmodified
通常AOSPの復元と最終状態の実測はこの記録へ追記する。

## 最終状態

通常AOSPを復元。GSIが変更したsystem prefixのみを戻した後、system全4311744512bytesのSHA256が元バックアップd8e3e09aa0f8e575d26464d4e61630165f3c34f043c4513579d1ee6bd1df3fe7と完全一致した。元boot全16MiBも760cf0d774211d7d705fae1dc2618cadd3fc6be88534410ebd4d5899630093f4一致。4.14.141+ #18、元QP1A.190711.019 userdebug、boot_completed=1、SurfaceFlinger・camera HAL running、Homeへ戻る操作を確認。

userdataはユーザー指示に従って初期化。GSI用vendor試験サービスは削除し、自動再起動は残っていない。FMアプリ・モジュール・実験用DSPは通常構成から撤去。vendorとkernelは通常mainを使用し、実験branchを通常ビルドへ混入させない。UART固定記録は継続。通常AOSPのWi-Fiも電源ON・AP検出を確認したが、同じNVRAM MAC警告が残る。
