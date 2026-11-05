# 第三方组件清单 · MuseCanvas 0.20.0-preview.3

MuseCanvas 的原始开发工程不在本发布仓库中。第三方组件的版权、许可及源码权利仍属于各自作者，不能用本项目的源码保密要求限制第三方的原有权利。

| 组件 | 包内位置和许可材料 |
| --- | --- |
| infinite-canvas 定制前端 | web 构建产物；licenses/infinite-canvas-MIT.txt |
| muse2api 定制生成池 | pool；licenses/muse2api-MIT.txt |
| canvas-agent 定制运行时 | agent；依赖清单 agent/licenses/npm-license-manifest.json，依赖目录中附带各自许可 |
| Node v24.18.0 | node/node.exe；agent/licenses/Node-v24.18.0-LICENSE.txt |
| Codex 0.166.0 | agent/node_modules/@openai/ 下的运行包及所附许可 |
| Python 与池子依赖 | pool/_internal 中的发行元数据、licenses 和许可文件 |
| FFmpeg / FFprobe | tools；FFmpeg-LICENSE.md 和 licenses/FFmpeg-GPLv3.txt；本包二进制使用 enable-gpl、enable-version3 |
| 可选语音模型 | 权重未包含；models/README.txt |

FFmpeg 二进制版本为 `N-123778-g3b55818764-20260331`，原工程与许可见 [FFmpeg](https://ffmpeg.org/legal.html) 和 [上游源码](https://github.com/FFmpeg/FFmpeg/tree/3b55818764)。版本及构建参数另记在包内 licenses/FFmpeg-build.txt。该上游链接不代表所有外部库、构建脚本及对应源码已在本包齐备；发布前应完成对应材料核对。

本清单记录实物位置，不把“有一份许可索引”等同于所有再分发义务已完成。不要上传用户的账号、密钥、Cookie、浏览器资料、作品和运行日志。
