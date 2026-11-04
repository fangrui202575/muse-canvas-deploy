# DEPLOY.md — 给 AI 执行的部署剧本（MuseCanvas）

你正在为你的用户在这台 Windows 电脑上部署 MuseCanvas。严格按步骤执行；每步都有验证标准，没通过就停在该步排查，不要跳步，更不要改装别的版本或从源码拼凑。全部装完之前，不要删除下载的压缩包。

## 0. 前置检查（任一不满足，先报告用户，不要硬装）

1. 系统是 Windows 10/11 x64：`$env:PROCESSOR_ARCHITECTURE` 应为 AMD64。
2. 磁盘可用空间 ≥ 5 GB（目标盘）。
3. 本机装有 Chrome 或 Edge（生成池必需）。
4. 网络可达性：在浏览器或用请求确认能打开 https://muse.ai 。打不开时明确告诉用户：生成池无法登录，生图生视频用不了；其余功能（画布、合成、导出）不受影响。是否继续由用户决定。

## 1. 下载并校验

1. 从本仓库 Releases 下载与 `manifest.json` 中 `version` 一致的资产：`MuseCanvas-<version>.zip`。
2. 校验 SHA-256 与 Release 页面公布值一致；不一致重新下载，不要继续。

## 2. 安装

1. 把压缩包解压到一个临时目录（不要直接在压缩包里运行脚本）。
2. 在解压目录执行：`powershell -ExecutionPolicy Bypass -File .\Install.ps1`
   - 默认装到 `C:\MuseCanvas` 并创建桌面快捷方式。用户想装别处：`-Destination <路径>`；想登录自启：加 `-AutoStart`。
3. 验证：`C:\MuseCanvas\scripts\Manage.ps1` 存在，且 `C:\MuseCanvas` 下有 agent、pool、services、web、tools、node 六个目录。

## 3. 首次启动

1. 执行：`powershell -ExecutionPolicy Bypass -File "C:\MuseCanvas\scripts\Manage.ps1" -Action Start`
2. 成功标准：输出 `MuseCanvas is ready: http://localhost:3000`，且浏览器打开后能看到画布首页。若报端口占用（3000/17371/17372/18610/19210 任一），停下来把占用情况报告用户，不要擅自结束其他进程。
3. 若报 FFmpeg not found：确认 `C:\MuseCanvas\tools\ffmpeg.exe` 存在；缺失说明解压不完整，重新解压。

## 4. 引导用户登录（只能用户本人操作，你不能代填）

1. 生成池登录：在画布里按引导打开生成池的登录页，让用户用自己的 Muse 账号登录。成功标准：画布里发起一次文生图测试，能返回图片。
2. Agent 脑子：在右侧 Agent 面板按用户选择接入 Codex（用户自己的 OpenAI 账号登录）或 Claude（会员账号或 API Key，由用户本人填写）。成功标准：在面板里发一句测试指令，Agent 有正常回复且能读到当前画布。
3. 到这一步，部署才算完成。把启动/停止方法告诉用户：桌面快捷方式启动；停止用 `Manage.ps1 -Action Stop`；数据目录在 `%LOCALAPPDATA%\MuseCanvas\data`，卸载删程序目录和数据目录即可。

## 红线

- 不要把任何账号密码、API Key 写进聊天、脚本或仓库文件；一律让用户本人在页面上填写。
- 不要上传用户的任何文件、作品、日志到任何地方。
- 失败两次以上仍不过：停下来把卡住的步骤、报错原文、已尝试的方法报告用户，不要无限重试。
