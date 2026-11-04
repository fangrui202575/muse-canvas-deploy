# 第三方组件与许可清单（MuseCanvas 0.20.0-preview.1）

本安装包由以下第三方开源组件构成或包含它们，各组件的版权归其各自作者所有，按其各自许可分发。本清单为预览版整理；包内 `licenses` 顶层目录将在下一版本补齐索引。

| 组件 | 用途 | 许可与文件位置 |
| --- | --- | --- |
| infinite-canvas 0.20.0 | 画布网页前端（基于其二次开发） | MIT，许可全文在包内 `licenses/infinite-canvas-MIT.txt` |
| muse2api（定制构建） | Muse 生成池 | MIT，许可全文在包内 `licenses/muse2api-MIT.txt` |
| canvas-agent 0.6.0（@basketikun/canvas-agent，定制构建） | 右侧 Agent 后台 | 随包分发；其依赖许可清单在包内 `agent/licenses/npm-license-manifest.json` |
| Codex 0.166.0（@openai/codex） | Agent 的 Codex 运行时 | 随其 npm 包目录分发（见 `agent/node_modules/@openai/` 内文件） |
| Node.js v24.18.0 | Agent 与本地服务运行时 | 许可全文在包内 `agent/licenses/Node-v24.18.0-LICENSE.txt` |
| Python 运行时 + PyInstaller 打包组件 | 生成池可执行文件（MusePool.exe） | Python 按 PSF License 分发 |
| Chromium（开源构建） | 生成池驱动的无头浏览器 | Chromium 开源项目许可（BSD 式） |
| FFmpeg（GPL 构建） | 片段合成与导出 | GPL，许可说明在包内 `tools/FFmpeg-LICENSE.md`，构建来源与对应源码获取方式见该文件 |
| faster-whisper | 语音转文字引擎（可选功能） | MIT；模型权重未包含在包内，由用户自行获取后放入 `models/faster-whisper-small` |

说明：

- 本包不包含任何账号、密钥、用户作品与浏览器登录态。
- 原始开发源码不随包分发；上表组件的再分发遵循其各自许可条款。
