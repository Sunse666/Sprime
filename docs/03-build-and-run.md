# Build and Run (Local)

Environment used for development: Windows 11, JDK 21, Android SDK at D:/IO/sdk.

## Requirements

| Tool | Version |
|---|---|
| JDK | 21 |
| Android SDK platform | 36 |
| Build tools | 36.0.0 |
| NDK | 28.0.13004108 |
| CMake | 3.31.6 |
| Python | 3.13, exposed as python3 |

## First time

    git clone https://github.com/Sunse666/Sprime.git
    cd Sprime
    git submodule update --init --recursive
    echo sdk.dir=D:/IO/sdk > local.properties

Boost is downloaded by CMake on first configure (about 100 MB, from GitHub releases).
If the download is slow, put the archive at app/src/main/jni/boost-1.89.0.tar.xz
(sha256 67acec02d0d118b5de9eb441f5fb707b3a1cdd884be00ca24b9a73c995511f74) and
extract it to app/src/main/jni/boost with --strip-components=1; CMake then skips the download.

OpenCC data generation runs python3 scripts, so python3 must be on PATH for the Gradle daemon.

## Build

    ./gradlew :app:assembleDebug

Default ABIs are arm64-v8a and x86_64 (see gradle.properties). Override for a single target:

    ./gradlew :app:assembleDebug -PbuildAbi=x86_64

Output: app/build/outputs/apk/debug/.

## Install and enable

    adb install -r app/build/outputs/apk/debug/<apk>
    adb shell ime enable com.sprime.ime.debug/com.osfans.trime.ime.core.TrimeInputMethodService
    adb shell ime set com.sprime.ime.debug/com.osfans.trime.ime.core.TrimeInputMethodService

The debug variant has the applicationId suffix .debug; release builds use com.sprime.ime.

Note: the MuMu emulator blocks the ime and settings commands, so enable the keyboard
from Settings > Language & input there.

## Network

The build needs GitHub (submodules, Boost) and Maven Central / Google. Behind a proxy,
set both the git proxy and the Gradle proxy:

    git config --global http.proxy http://127.0.0.1:7890
    # ~/.gradle/gradle.properties
    systemProp.http.proxyHost=127.0.0.1
    systemProp.http.proxyPort=7890
    systemProp.https.proxyHost=127.0.0.1
    systemProp.https.proxyPort=7890

## Troubleshooting

- python3 missing: the OpenCC data task fails with exit code 9009.
- Boost download timeout: see the offline archive trick above.
- INSTALL_FAILED_TEST_ONLY: build without -Pandroid.injected.build.abi, or pass adb install -t.

## Release 构建

1. 生成签名（只做一次，文件已被 .gitignore 忽略）：

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File tools/make-keystore.ps1
   ```

   它会生成 `.secrets/sprime-release.jks` 与仓库根目录的 `keystore.properties`（含 storeFile / storePassword / keyAlias / keyPassword）。

2. 打包：

   ```powershell
   .\gradlew.bat :app:assembleRelease -PbuildAbi=arm64-v8a
   ```

   产物在 `app/build/outputs/apk/release/`，已用上面的密钥签名。R8 默认开启，规则见 `app/proguard-rules.pro`。

3. 上架前检查：

   - 版本号 `versionCode` / `versionName` 在 `app/build.gradle.kts`
   - 隐私说明与截图/无障碍开关的文案（设置 → Sprime）
   - 若使用无障碍能力，需在商店后台按要求声明用途
