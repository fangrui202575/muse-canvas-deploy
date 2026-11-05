# MuseCanvas 无限画布（本地部署版）

> 当前推荐包为 **0.20.0-preview.2**（完整安装包）。它修复了 preview.1 的首次安装 Agent 令牌、媒体加载和实例目录问题。已知限制：Claude 对话尚未自动注册画布工具；Agnes 的 OpenAI 接口不能直接填入本版 Claude 的 Anthropic 接口入口。这两项正在后续版本修复，请勿把 Claude 能聊天当作能操作画布。preview.1 仅保留用于回退。

一套在你自己电脑上运行的 AI 画布工作台：无限画布编辑、文生图 / 文生视频、多个视频片段合成成片并导出、右侧 Agent 面板用自然语言指挥画布干活。全部服务只监听本机（127.0.0.1），程序和你的作品数据都存在你自己的电脑上。

**免费使用。不包含任何账号**：生图生视频用的 Muse 账号、Agent 用的 Codex / Claude 账号，都需要你用自己的账号登录，额度算你自己的。

## 最省事的装法：让你的 AI 来装

把下面这句话复制给你的 AI 助手（Claude、Codex 等），它会照着本仓库的部署说明一步步装好并带你登录：

```
请打开这个仓库的 DEPLOY.md，严格按里面的步骤在这台电脑上部署 MuseCanvas：https://github.com/fangrui202575/muse-canvas-deploy （部署说明以仓库内文件为准；每一步都有验证标准，没通过不要跳步；需要我本人登录账号时停下来告诉我。）
```

## 手动安装（Windows x64）

1. 从本仓库 Releases 下载 `MuseCanvas-<版本>.zip`（约 491 MB，含 FFmpeg；解压后约 1.4 GB），解压到任意目录。
2. 右键以 PowerShell 运行解压目录里的 `Install.ps1`（或执行 `powershell -ExecutionPolicy Bypass -File .\Install.ps1 -ForUser <你的 Windows 账号>`）。它会把程序装到 `C:\MuseCanvas`，在公共桌面建快捷方式（所有用户可见），并把数据目录位置记录在安装目录的 `instance.json` 里，之后从任何账号启动都用同一份数据；想把数据放别的盘加 `-DataDirectory <路径>`，想登录自启加 `-AutoStart`。
3. 在桌面上双击 MuseCanvas 快捷方式启动（不要从 SSH 等远程命令窗口启动，否则生成池的登录窗口在桌面上看不见），浏览器会自动打开画布（http://localhost:3000）。
4. 首次使用按页面引导，用你自己的 Muse 账号登录生成池；Agent 面板用你自己的 Codex / Claude 账号或 API Key 配置。
5. 停止：在安装目录执行 `powershell -ExecutionPolicy Bypass -File .\scripts\Manage.ps1 -Action Stop`（数据保留在 `instance.json` 记录的数据目录里，默认为你的 `%LOCALAPPDATA%\MuseCanvas\data`）。

## 环境要求

- Windows 10/11 x64，约 3 GB 可用磁盘（程序 1.4 GB + 数据增长）。
- Chrome 或 Edge 浏览器（生成池登录和生成要用）。
- 能正常打开 muse.ai 的网络（生成池靠它工作；打不开就无法生图生视频）。
- 不需要预装 Node、Python 或 FFmpeg，包内自带。

## 包含什么 / 不包含什么

- 包含：画布网页、Agent 后台（含 Codex 0.166 运行时）、Muse 生成池、片段合成与导出服务、FFmpeg、本地运行环境。
- 不包含：任何账号、密钥、作品和浏览器登录态；语音转文字的模型权重（单独的可选包，装上后放进 `models\faster-whisper-small`）；Claude Code 命令行工具（Agent 想用 Claude 当脑子时需另行安装并登录，步骤见 DEPLOY.md；包内自带的是 Codex 运行时）。

## 隐私与安全

- 所有服务只绑 127.0.0.1；本机密钥在首次启动时自动生成，只存放在你的数据目录。本软件本身不收集、不回传你的数据。
- 但功能层面要说清：生图 / 生视频会把你的提示词和参考素材发给 Muse（muse.ai）处理，Agent 干活会把指令发给它接入的模型服务（OpenAI / Anthropic）。这是这些云端功能的工作方式，发送范围以你主动发起的操作为限。
- 本软件不公开原始开发源码。浏览器里运行的网页资源和第三方组件按其各自许可分发：主要许可文件在包内 `licenses` 目录，FFmpeg 的 GPL 许可在包内 `tools` 目录，完整的第三方组件与许可清单见本仓库根目录的 `THIRD-PARTY-NOTICES.md`。

## 版本

见仓库根目录 `manifest.json`（组件与版本清单）。当前版本：0.20.0-preview.2。
