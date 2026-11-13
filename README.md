# OpenClaw custom image

本目录为本地待审阅文件；尚未创建 GitHub 仓库或发布镜像。

## 目标

- 专用私有仓库：`kingcarn/openclaw-custom-image`。
- 镜像：`ghcr.io/kingcarn/openclaw-custom:<官方版本>-r<修订号>`。
- 平台：linux/amd64。仅 workflow_dispatch 手动构建，无定时构建、无自动部署。
- 基于指定官方成品镜像安装原有工具，不编译 OpenClaw 源码。
- 保留 UID/GID 1000:1600。只处理镜像内 HOME 顶层权限，不更改宿主机挂载目录权限。

## 文件

- Dockerfile：指定官方版本，安装 SSH、GitHub CLI、检索/同步、shell 检查和媒体工具。
- .github/workflows/build.yml：验证输入和仓库名、拒绝覆盖已有标签、构建、离线烟测、通过后发布。
- scripts/check-image.sh：检查精确版本、UID/GID、HOME 和工具可用性。

工作流只对本仓库授予 contents:read、packages:write，使用临时 GITHUB_TOKEN。不需要个人 Token、SSH 密钥或 Portainer 凭据。第三方 Actions 暂用主版本标签；正式上传前建议固定到审阅过的完整 commit SHA。

## 分步实施

1. 本地准备并审阅本目录。
2. 得到用户确认后，仅创建上述专用私有仓库并上传。上传不会触发构建。
3. 得到用户确认后，在 Actions 中选择 Build custom OpenClaw image，输入存在的官方版本（例 2026.10.8）和 revision=1。
4. Actions 拉取官方镜像、安装依赖，验证后推送镜像；从运行摘要/推送日志记录镜像标签和 digest。
5. 确认 GHCR 包保持私有，并验证宿主机能拉取。私有包拉取凭据另行配置，不写入仓库。
6. 正式升级另行批准：备份完整状态、在副本上检查迁移兼容、准备外部恢复通道，再替换运行容器。

首次发布若提示无法读取目标包或权限不明，工作流会停止，不把鉴权/网络错误当成“标签不存在”。需要检查 GHCR 权限后再运行。

## 本地构建参考（本阶段不执行）

```bash
docker build --pull --platform linux/amd64 \
  --build-arg OPENCLAW_VERSION=2026.10.8 \
  -t openclaw-custom:2026.10.8-r1 .
docker run --rm --network none --entrypoint /bin/bash \
  --mount "type=bind,src=$PWD/scripts/check-image.sh,dst=/tmp/check-image.sh,readonly" \
  openclaw-custom:2026.10.8-r1 /tmp/check-image.sh 2026.10.8
```

## 限制与费用

- 静态检查不能替代实际镜像构建，也不能证明现有配置与新版本兼容。
- 官方基础镜像或 Debian 软件源变化仍可能影响构建。依赖包暂未固定版本，因此相同输入不保证字节级一致；部署应记录并使用 digest。
- 容器中的临时安装及用户目录 Python 包不由本 Dockerfile 自动迁移。正式升级前须核实当前挂载与依赖，按需要另行加入。
- 私有仓库 Actions 分钟数与 GHCR 容量/流量，实施前按账号实际额度核实。
- 旧镜像可保留；若状态数据库已迁移，回退需匹配的状态备份。

## 当前验证

本地执行 bash -n、ShellCheck、YAML 解析和流程结构检查。当前容器无 Docker CLI，未实际 build/run/push；这些留待用户批准后的试构建阶段。
