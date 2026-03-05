# Openclaw-Usecases-CN

基于 OpenClaw 社区用例仓库整理的中文导航项目，用于快速查找真实可复用的 OpenClaw 使用场景。

## 数据来源

你给的 3 个链接里有 1 个重复项，已去重后使用以下 2 个来源：

1. https://github.com/hesamsheikh/awesome-openclaw-usecases
2. https://github.com/EvoLinkAI/awesome-openclaw-usecases-moltbook

## 当前收录

- 社区合集：36 个用例
- Moltbook 合集：70 个用例（已排除 `TEMPLATE.md`）
- 总计：106 个用例

总索引见：[docs/USECASES.md](docs/USECASES.md)

## 使用方式

1. 一键抓取并生成（推荐）：

```bash
chmod +x scripts/fetch_and_build.sh scripts/generate_usecases_index.sh
scripts/fetch_and_build.sh
```

2. 如果你已经本地克隆了两个上游仓库，也可以直接生成：

```bash
chmod +x scripts/generate_usecases_index.sh
scripts/generate_usecases_index.sh <awesome-openclaw-usecases目录> <awesome-openclaw-usecases-moltbook目录>
```

3. 查看输出文件：`docs/USECASES.md`

## 说明

- 本仓库默认以“索引 + 上游链接”为主，避免复制无明确授权内容。
- 详细来源与授权说明见：[docs/SOURCES.md](docs/SOURCES.md)
