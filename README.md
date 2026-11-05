# MuseCanvas 无限画布 · Windows 本地部署版

免费使用，原始开发源码不公开。本仓库只提供部署说明、安装脚本、版本清单和 Releases 成品包。

**0.20.0-preview.3 是完整包，可独立全新安装，也可覆盖升级；不需要先安装旧版。** 新版补上 Claude 的实例画布工具注册，并增加 Agnes 等 OpenAI 格式 API 的适配。旧版本保留作回退。

这是预览版：已做不消耗云端额度的协议、工具、安装和导出检查；真实 Claude 会员、Agnes 账号及新电脑上的生成，仍须使用者本人验收。不能把“已连接”当成全部功能验收通过。

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

## 功能与前提

| 功能 | 需要什么 |
| --- | --- |
| 画布、视频预览、选段合成、导出 | 包内环境与已有素材 |
| 生图、生视频 | 自己的 Muse 账号、额度和可达网络 |
| Codex Agent | 包内 Codex 运行时及自己的账号/额度 |
| Claude 会员 Agent | 另行安装官方 Claude Code，用自己的会员登录 |
| Agnes / 其他 API Agent | 官方 Claude Code、自己的 Key、正确协议和模型 ID |
| 本地语音转文字 | 已包含 faster-whisper-small 模型，开箱可用（本地转写） |

Agnes 选 **OpenAI 兼容格式**，无需 CC Switch。其他供应商按实际文档选择 OpenAI 或 Anthropic 格式。程序传递所选模型 ID，不自动切换其他模型；供应商的最终映射和计费以其返回及账单为准。

Windows 10/11 x64，至少 5 GB 安装空间及后续素材空间，Chrome 或 Edge。Node、Python 环境和 FFmpeg 已包含；Claude Code 不在包内，需满足其官方 Windows 运行要求。

## 数据和隐私

`instance.json` 记录数据目录；该目录保存本机凭证、设置及作品相关数据。不要公开运行数据。发布包不含账号、密钥、Cookie、作品或浏览器登录态。

服务监听本机回环地址。云端功能会把指令、上下文和选用素材发送给选中的供应商。OpenAI 协议适配器临时运行于回环地址，任务结束后关闭；其输入 token 计数是估算，不能用作账单核对。

不公开源码工程不等于浏览器资源无法阅读或二进制无法分析。第三方组件按各自许可分发，见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。
