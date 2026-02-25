# MosDNS 自动化更新脚本

## 1. 计划任务 (Crontab) 的标准写法

在 OpenWrt 的"系统 -> 计划任务"中，建议这样配置：

```
# 每天凌晨 4 点下载云端脚本并执行
0 4 * * * curl -sL https://sh.onchina.vip/mosdns.sh | sh
```

### 参数说明

- `-s` (Silent): 显示下载进度，避免静默模式，不日志堆积。
- `-L` (Location): 强制重定向，防止 URL 跳转导致下载失败。
- `| sh`: 直接将下载的内容传给 Shell 执行，无需保存到本地，减少磁盘（闪存）写入。

## 2. 本地部署

如果需要本地运行或调试，可以克隆本仓库：

```bash
git clone https://github.com/onchina/sh.git
cd sh/mosdns
chmod +x mosdns.sh
./mosdns.sh
```

## 3. 文件说明

| 文件/目录 | 说明 |
|-----------|------|
| `mosdns.sh` | 主脚本，负责下载和更新配置 |
| `uci/mosdns` | MosDNS UCI 配置文件 |
| `rule/` | 规则文件目录（广告过滤、域名白名单等） |
