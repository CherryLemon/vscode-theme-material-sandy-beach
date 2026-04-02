#!/bin/bash

# ============================================================
# Material Sandy Beach Theme - 构建脚本
# ============================================================

set -e

# 颜色输出
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# ============================================================
# 读取包信息
# ============================================================
PACKAGE_NAME=$(node -p "require('./package.json').name")
VERSION=$(node -p "require('./package.json').version")
VSIX_FILE="${PACKAGE_NAME}-${VERSION}.vsix"

log_info "构建插件: ${PACKAGE_NAME} v${VERSION}"

# ============================================================
# 检查依赖
# ============================================================
if ! command -v vsce &> /dev/null; then
    log_warn "未检测到 vsce，正在全局安装..."
    npm install -g @vscode/vsce
fi

# ============================================================
# 校验主题文件
# ============================================================
THEME_FILE="themes/material-sandy-beach-color-theme.json"
if [ ! -f "${THEME_FILE}" ]; then
    log_error "主题文件不存在: ${THEME_FILE}"
    exit 1
fi

log_info "校验主题 JSON 格式..."
node -e "JSON.parse(require('fs').readFileSync('${THEME_FILE}', 'utf8'))" \
    && log_info "主题 JSON 格式合法" \
    || { log_error "主题 JSON 格式有误，请检查 ${THEME_FILE}"; exit 1; }

# ============================================================
# 打包
# ============================================================
log_info "开始打包 .vsix ..."
vsce package --out "${VSIX_FILE}"

if [ -f "${VSIX_FILE}" ]; then
    SIZE=$(du -sh "${VSIX_FILE}" | cut -f1)
    log_info "打包成功: ${VSIX_FILE} (${SIZE})"
else
    log_error "打包失败，未生成 ${VSIX_FILE}"
    exit 1
fi

# ============================================================
# 可选：本地安装
# ============================================================
if [[ "$1" == "--install" ]]; then
    log_info "正在安装到本地 VS Code..."
    code --install-extension "${VSIX_FILE}"
    log_info "安装完成，重启 VS Code 后生效。"
fi

# ============================================================
# 可选：发布到 Marketplace
# ============================================================
if [[ "$1" == "--publish" ]]; then
    log_info "正在发布到 VS Code Marketplace..."
    vsce publish
    log_info "发布完成！"
fi

log_info "全部完成。"
