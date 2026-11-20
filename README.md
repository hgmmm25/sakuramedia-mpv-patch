# SakuraMedia Windows 客户端 libmpv 补丁

SakuraMedia Windows 客户端捆绑的 `libmpv-2.dll`（2023-09 media_kit build）无法播放
**PMT `stream_type=0` 的 MPEG-TS 文件**（常见于流式下载得到的文件，扩展名 .mp4、
头部带 1×1 PNG stub）：老版 libmpv 不对未声明的基本流做内容探测，会把视频 PID
误判为 MP3 音频轨并找不到视频轨，导致内部播放器永远等不到首帧（外部播放器正常）。

详情见上游 issue：https://github.com/tinypinglite/sakuramedia/issues/85

本仓库不重打包客户端，只做两件事：

1. **自动跟踪** zhongfly/mpv-winbuild 的最新 mpv-dev 构建中的 `libmpv-2.dll`，
   冒烟测试（加载 dll + 校验 client API 版本）后按 `libmpv-<short-hash>` 发 release，
   附 SHA256。
2. **一键补丁脚本**，替换本机客户端里的旧 dll（自动备份原件）。

## 用法

```powershell
# 默认安装目录 D:\SakuraMedia；其他位置传 -InstallDir
.\patch-sakuramedia.ps1
```

脚本会：检测安装目录 → 若客户端在运行则先关闭 → 备份当前
`libmpv-2.dll` 为 `libmpv-2.dll.bak-<时间戳>` → 从本仓库最新 release 下载新
dll 并替换 → 打印替换前后的哈希。

## 注意

- mpv client API / render API 向后兼容，media_kit 原生插件无需重编译。
- **客户端每次更新/重装都会把旧 dll 覆盖回去，更新后重跑一次本脚本即可。**
- 只分发 libmpv-2.dll（mpv 为 GPLv2+，构建来源：
  https://github.com/zhongfly/mpv-winbuild/releases ），不修改、不分发客户端本体。
