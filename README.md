# MuseCanvas 无限画布 · Windows 本地部署版

原始开发源码不公开。本仓库只提供部署说明、安装脚本、版本清单和 Releases 成品包。

**0.21.0 是完整包，可独立全新安装，也可覆盖升级；不需要先安装旧版。** 本版新增：内置授权模块（当前未启用，见下文「授权模块」）、新版本提示、豆包生图生视频、Claude Code 命令行一键安装（修复接 API 模型连不上）、合成节点上限提高到 200 段。第一至第三版已下架，不再更新。

已做自动化测试、安装和升级测试。真实 Muse、豆包账号上的生成仍须使用者本人验收；不能把“已连接”当成全部功能可用的证据。

## 复制给 AI 的安装指令

```text
请读取 https://github.com/fangrui202575/muse-canvas-deploy 的 DEPLOY.md 和 manifest.json，在我的 Windows 电脑上安装对应的完整 MuseCanvas 发布包。先确认程序目录、数据目录和实际使用的 Windows 账号；未经我同意不要默认占用 C 盘、停止其他程序、删除旧数据或发起消耗额度的模型/生成测试。下载后核对 SHA-256，严格按说明安装；账号登录由我本人完成。最后分别报告通过、未通过、未测试的项目，不要只凭“已连接”宣布成功。
```

## 手动安装

1. 从本仓库 [Releases](https://github.com/fangrui202575/muse-canvas-deploy/releases) 下载 `MuseCanvas-<版本>.zip`，核对 manifest 的大小和 SHA-256，解压到临时目录。
2. 在解压目录运行，路径和账号按实际情况修改：

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\Install.ps1 -Destination 'E:\MuseCanvas' -DataDirectory 'E:\MuseCanvasData' -ForUser '你的Windows账号'
   ```

3. 实际使用者在自己的 Windows 桌面会话双击 MuseCanvas 快捷方式。不要从 SSH 或会话 0 启动日常服务。
4. 用自己的 Muse 账号接入生成池；用自己的 Codex / Claude 账号或 API Key 接入 Agent。

升级时 `-Destination` 指向旧安装，省略 `-DataDirectory` 即继承旧数据目录。不要先删旧安装、数据或浏览器资料。详见 [DEPLOY.md](DEPLOY.md)。

## 授权模块

0.21.0 内置授权模块，**当前未启用**，所有功能不受限。启用前会另行公告。

- 软件每 6 小时向 `https://license.fylmlgsb.xyz` 询问一次总开关状态和是否有新版本，这两个请求不带任何设备或账号信息。
- 本软件是独立的第三方工具，与 Meta、Muse、豆包及其他 AI 平台没有关联，也未获它们授权。软件通过自动操作网页使用你自己的账号，**平台的服务条款可能不允许这种方式，平台有权限制或关闭账号，风险由使用者自行承担**；建议使用单独注册的账号。

## 功能与前提

| 功能 | 需要什么 |
| --- | --- |
| 画布、视频预览、选段合成、导出 | 包内环境与已有素材 |
| 生图、生视频 | 自己的 Muse 账号、额度和可达网络 |
| Codex Agent | 包内 Codex 运行时及自己的账号/额度 |
| Claude 会员 Agent | 在 Agent 模型页一键安装官方 Claude Code，再用自己的会员登录 |
| Agnes / 其他 API Agent | Claude Code（同上一键安装）、自己的 Key、正确协议和模型 ID |
| 豆包生图、生视频（可选） | 在流量池页面登录一次自己的豆包；图片带豆包水印，视频固定 10 秒 720p，都不支持参考图。豆包《用户协议》不允许把生成内容用于商业用途，请自行判断 |
| 本地语音转文字 | 已包含 faster-whisper-small 模型，开箱可用（本地转写） |

Agnes 选 **OpenAI 兼容格式**，无需 CC Switch。其他供应商按实际文档选择 OpenAI 或 Anthropic 格式。程序传递所选模型 ID，不自动切换其他模型；供应商的最终映射和计费以其返回及账单为准。

Windows 10/11 x64，至少 5 GB 安装空间及后续素材空间，Chrome 或 Edge。Node、Python 环境和 FFmpeg 已包含；Claude Code 是 Anthropic 的软件，不能随包分发，模型页提供一键安装（约 160 MB，校验官方签名）。

## 数据和隐私

`instance.json` 记录数据目录；该目录保存本机凭证、设置及作品相关数据。不要公开运行数据。发布包不含账号、密钥、Cookie、作品或浏览器登录态。

服务监听本机回环地址。云端功能会把指令、上下文和选用素材发送给选中的供应商。OpenAI 协议适配器临时运行于回环地址，任务结束后关闭；其输入 token 计数是估算，不能用作账单核对。

不公开源码工程不等于浏览器资源无法阅读或二进制无法分析。第三方组件按各自许可分发，见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。
