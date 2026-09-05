# siyuan-modelscope-scripts

SiYuan 部署脚本，由 ModelScope Studio Dockerfile 在容器启动时 `git clone` 拉取。

## 文件说明

| 文件 | 用途 |
|---|---|
| `entrypoint.sh` | 主入口：拉取数据仓库 → 启动 SiYuan → 启动 sync-daemon → 端口转发 |
| `sync-daemon.sh` | 后台守护：每 60s 将 workspace 变更 git push 到 `DATA_REPO` |
| `.gitignore` | 排除 assets/ binaries/SQLite/cache，避免同步大文件 |

## 集成方式

ModelScope Studio 端的 Dockerfile：

```dockerfile
FROM b3log/siyuan:latest
RUN apk add --no-cache socat git openssh
# Runtime clone scripts from this repo
...
ENTRYPOINT ["/bootstrap.sh"]
```

## 环境变量

| 变量 | 说明 |
|---|---|
| `SIYUAN_ACCESS_AUTH_CODE` | 浏览器登录密码 |
| `SIYUAN_LANG` | 界面语言 |
| `DATA_REPO` | 数据仓库 owner/repo |
| `MODELSCOPE_TOKEN` | Git push 认证（可选，不加则不同步） |
| `SYNC_INTERVAL` | 同步间隔秒数（默认 60） |

## License

AGPL-3.0 (inherited from SiYuan)
