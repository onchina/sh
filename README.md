# MosDNS 自动化更新脚本

## 前置要求

请确保已在 OpenWrt 中安装 **luci-app-mosdns** 插件，否则脚本将自动退出。

## 使用方法

### 定时任务

在 OpenWrt 的"系统 -> 计划任务"中配置：

```
# 每小时执行
0 * * * * curl -sL https://raw.githubusercontent.com/onchina/sh/main/mosdns/mosdns.sh | sh

# 每天凌晨 4 点执行
0 4 * * * curl -sL https://raw.githubusercontent.com/onchina/sh/main/mosdns/mosdns.sh | sh
```

### 直接运行

```bash
curl -sL https://raw.githubusercontent.com/onchina/sh/main/mosdns/mosdns.sh | sh
```

### 参数

| 参数 | 说明 |
|------|------|
| 无参数 | 默认仅更新 `streaming.txt` |
| `-a` | 更新所有规则文件 |
| `-r 文件名` | 指定要更新的规则文件（可多次使用） |
| `-h` | 显示帮助 |

### 示例

```bash
# 默认：仅更新 streaming.txt
curl -sL https://raw.githubusercontent.com/onchina/sh/main/mosdns/mosdns.sh | sh

# 更新所有规则文件
curl -sL https://raw.githubusercontent.com/onchina/sh/main/mosdns/mosdns.sh | sh -s -- -a

# 更新指定规则文件
curl -sL https://raw.githubusercontent.com/onchina/sh/main/mosdns/mosdns.sh | sh -s -- -r streaming.txt -r whitelist.txt
```

## 本地部署

如果需要本地运行或调试，可以克隆本仓库：

```bash
git clone https://github.com/onchina/sh.git
cd sh/mosdns
chmod +x mosdns.sh
./mosdns.sh
```

## 文件说明

| 文件/目录 | 说明 |
|-----------|------|
| `mosdns.sh` | 主脚本，负责下载和更新配置 |
| `uci/mosdns` | MosDNS UCI 配置文件 |
| `rule/` | 规则文件目录 |

### 规则文件详解

| 文件 | 说明 |
|------|------|
| `blocklist.txt` | **黑名单**：屏蔽域名 DNS 解析 |
| `whitelist.txt` | **白名单**：域名使用本地 DNS 解析，优先级最高 |
| `greylist.txt` | **灰名单**：域名使用远程 DNS 解析 |
| `hosts.txt` | **Host 规则**：域名直接使用规则中指定的 IP，不经过 DNS 解析 |
| `redirect.txt` | **重定向**：域名 A 重定向到域名 B |
| `ddnslist.txt` | **DDNS 规则**：域名使用本地 DNS 解析，强制 TTL 5 秒，不缓存 |
| `local-ptr.txt` | **PTR 黑名单**：阻止域名 PTR 请求 |
| `cloudflare-cidr.txt` | Cloudflare IP 段，DNS 泄露防护 |
| `streaming.txt` | **关键域名指定 DNS**：特定域名使用指定 DNS 服务器 |

> 注：空白规则文件暂无需使用，留空即可。
