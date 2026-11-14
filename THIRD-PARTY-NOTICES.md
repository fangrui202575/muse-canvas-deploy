# 第三方组件清单 · MuseCanvas 0.23.0

第三方组件的版权、许可及源码权利仍属于各自作者，

| 组件 | 包内位置和许可材料 |
| --- | --- |
| infinite-canvas 定制前端 | web 构建产物；licenses/infinite-canvas-MIT.txt |
| muse2api 定制生成池 | pool；licenses/muse2api-MIT.txt |
| canvas-agent 定制运行时 | agent；依赖清单 agent/licenses/npm-license-manifest.json，依赖目录中附带各自许可 |
| Node v24.18.0 | node/node.exe；agent/licenses/Node-v24.18.0-LICENSE.txt |
| Codex 0.166.0 | agent/node_modules/@openai/ 下的运行包及所附许可 |
| Python 与池子依赖 | pool/_internal 中的发行元数据、licenses 和许可文件 |
| 新接口服务的 Python 依赖（FastAPI、uvicorn、httpx、curl_cffi、websockets、cryptography、Pillow 等） | protocol/_internal 中的发行元数据（*.dist-info）及所附许可文件 |
| FFmpeg / FFprobe | tools；FFmpeg-LICENSE.md 和 licenses/FFmpeg-GPLv3.txt；本包二进制使用 enable-gpl、enable-version3 |
| 语音模型 faster-whisper-small | models/faster-whisper-small；MIT（Systran/faster-whisper-small，基于 OpenAI Whisper，MIT） |

FFmpeg 二进制版本为 `n8.1.3-34-ga35157abb9-20261106`，构建来自 [BtbN/FFmpeg-Builds](https://github.com/BtbN/FFmpeg-Builds)，原工程与许可见 [FFmpeg](https://ffmpeg.org/legal.html)。版本及构建参数见 licenses/FFmpeg-build.txt。

FFmpeg 对应源码和构建脚本的下载位置：[发布时填写 Release 链接]。

本清单记录实物位置，不把“有一份许可索引”等同于所有再分发义务已完成。不要上传用户的账号、密钥、Cookie、浏览器资料、作品和运行日志。
