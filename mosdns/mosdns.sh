#!/bin/sh

# =========================================================
# MosDNS 高维度自动化更新脚本 (完美版)
# 适用场景: 远程同步 LuCI 配置与规则数据
# =========================================================

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

# 配置区
BASE_URL="https://sh.onchina.vip/mosdns"
UCI_CONF="/etc/config/mosdns"
RULE_DIR="/etc/mosdns/rule"
TMP_DIR="/tmp/mosdns_update"
NEED_RELOAD=0

# 日志函数
log() {
    logger -t "MosDNS_Cloud" "$1"
    echo ">>> $1"
}

# 1. 环境准备
mkdir -p "$RULE_DIR"
mkdir -p "$TMP_DIR"

# 2. 网络连通性预检 (防止断网导致下载空文件)
if ! ping -c 1 223.5.5.5 > /dev/null 2>&1; then
    log "错误: 网络不可达，停止更新。"
    exit 1
fi

# 3. 函数：安全下载并校验
# 参数: 远程URL, 本地目标路径, 标识关键词(用于格式校验)
safe_update() {
    local url="$1"
    local target="$2"
    local keyword="$3"
    local filename=$(basename "$target")
    local tmp_file="$TMP_DIR/$filename"

    # 下载
    if ! curl -sL --connect-timeout 10 "$url" -o "$tmp_file"; then
        log "下载失败: $filename"
        return 1
    fi

    # 基础校验：文件必须存在且大小大于0
    if [ ! -s "$tmp_file" ]; then
        log "校验失败: $filename 文件为空"
        return 1
    fi

    # 逻辑校验：如果提供了关键词，检查文件中是否存在
    if [ -n "$keyword" ]; then
        if ! grep -q "$keyword" "$tmp_file"; then
            log "格式校验失败: $filename 未包含关键特征 '$keyword'"
            return 1
        fi
    fi

    # MD5 对比：无变化则不处理
    local new_md5=$(md5sum "$tmp_file" | awk '{print $1}')
    local old_md5="none"
    [ -f "$target" ] && old_md5=$(md5sum "$target" | awk '{print $1}')

    if [ "$new_md5" != "$old_md5" ]; then
        cp "$tmp_file" "$target"
        chmod 644 "$target"
        log "更新成功: $filename"
        NEED_RELOAD=1
    fi
    return 0
}

# --- 执行阶段 ---

log "开始检查同步任务..."

# A. 更新 UCI 配置文件 (通过检测 'config mosdns' 确保不是下载到了 404 页面)
safe_update "$BASE_URL/uci/mosdns" "$UCI_CONF" "config mosdns 'config'"

# B. 批量更新规则文件 (规则文件通常是文本，不指定关键词强制检查)
RULES="blocklist.txt cloudflare-cidr.txt ddnslist.txt greylist.txt hosts.txt local-ptr.txt redirect.txt streaming.txt whitelist.txt"
for rule in $RULES; do
    safe_update "$BASE_URL/rule/$rule" "$RULE_DIR/$rule"
done

# C. 触发接口生效
if [ "$NEED_RELOAD" -eq 1 ]; then
    log "检测到配置变更，正在应用新设置..."
    
    # 使用接口重载
    /etc/init.d/mosdns reload
    
    # 验证服务状态
    sleep 2
    if /etc/init.d/mosdns status | grep -q "running"; then
        log "MosDNS 重载成功，进程运行正常。"
    else
        log "警告: MosDNS 重载后未运行，请检查配置合法性！"
        # 这里可以加入回滚逻辑，如果需要的话
    fi
else
    log "所有配置已是最新，无需操作。"
fi

# 清理痕迹
rm -rf "$TMP_DIR"