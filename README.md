# Openclaw-Usecases-CN

中文 OpenClaw 用例导航与同步工具链：聚合社区高质量案例，生成可读索引与机器可读数据，便于检索、分析和二次集成。

[![CI](https://github.com/AIPMAndy/Openclaw-Usecases-CN/actions/workflows/ci.yml/badge.svg)](https://github.com/AIPMAndy/Openclaw-Usecases-CN/actions/workflows/ci.yml)
[![Data](https://img.shields.io/badge/data-markdown%20%2B%20json-brightgreen)](docs/USECASES.json)

## 为什么这个仓库值得用

- 保守合规：默认只保留索引和上游回链，降低版权风险。
- 双格式产物：同时输出 `Markdown`（人读）和 `JSON`（程序读）。
- 一键同步：支持自动抓取、增量刷新、统计分析、来源报告。
- 可持续维护：内置测试、CI、Makefile，便于长期运营。

## 当前结构

- `scripts/fetch_and_build.sh`：抓取上游 + 生成所有产物（主入口）。
- `scripts/generate_usecases_index.sh`：生成 `USECASES.md / USECASES.json / STATS.md`。
- `scripts/generate_sources_report.sh`：生成来源与许可证快照 `SOURCES.md`。
- `scripts/generate_usecases_diff.sh`：对比新旧索引并生成 `DIFF.md / DIFF.json`（NEW/UPDATED/REMOVED）。
- `scripts/generate_quickstarts.sh`：基于评分生成 TopN 可执行 `QUICKSTARTS.md / QUICKSTARTS.json`。
- `scripts/query_usecases.sh`：按关键词/分类/来源快速检索 JSON 索引。
- `scripts/run_quality_gates.sh`：项目质量门（lint/test/build）。
- `docs/USECASES.md`：中文总索引（人工浏览）。
- `docs/USECASES.json`：结构化索引（自动化系统对接）。
- `docs/STATS.md`：分类统计与来源占比。
- `docs/SOURCES.md`：来源仓库、提交信息、许可证文件快照。
- `docs/DIFF.md`：本次同步增量变化摘要（NEW/UPDATED/REMOVED）。
- `docs/DIFF.json`：增量变化机器可读结果。
- `docs/QUICKSTARTS.md`：高价值 TopN 用例的可执行落地手册。
- `docs/QUICKSTARTS.json`：Quickstart 结构化版本（可用于前端或自动化）。

## 30 秒开始

```bash
chmod +x scripts/*.sh
scripts/fetch_and_build.sh
```

执行完成后，会在 `docs/` 下更新以下文件：

- `USECASES.md`
- `USECASES.json`
- `STATS.md`
- `SOURCES.md`
- `DIFF.md`
- `DIFF.json`
- `QUICKSTARTS.md`
- `QUICKSTARTS.json`

## 常用命令

```bash
# 默认：新建临时目录抓取并保留缓存路径
scripts/fetch_and_build.sh

# 指定工作目录（可复用缓存）
scripts/fetch_and_build.sh --work-dir /tmp/openclaw-sync

# 执行后清理工作目录
scripts/fetch_and_build.sh --work-dir /tmp/openclaw-sync --clean-work-dir

# 已有本地上游仓库时，直接生成索引
scripts/generate_usecases_index.sh --src-a /path/to/repo-a --src-b /path/to/repo-b

# 仅更新来源报告
scripts/generate_sources_report.sh --src-a /path/to/repo-a --src-b /path/to/repo-b

# 比较旧版和新版索引
scripts/generate_usecases_diff.sh --old docs/USECASES.prev.json --new docs/USECASES.json

# 生成 TopN Quickstarts（默认 20）
scripts/generate_quickstarts.sh --index docs/USECASES.json --top 20

# 查询 JSON 索引
scripts/query_usecases.sh --keyword security --limit 10
scripts/query_usecases.sh --category 安全 --source B
scripts/query_usecases.sh --risk high --min-confidence 70 --min-repro 60
```

## Makefile（可选）

```bash
make test
make build
make quality
make query Q=security
make quickstarts TOP=20
```

## 自动化维护

- `CI`：每次 Push/PR 自动执行质量门（`lint + test + build smoke`）。
- `Sync Upstream Usecases`：每天 UTC 02:00 自动抓取上游并发起 PR（有变更时）。
  PR 中会包含本次增量摘要（NEW/UPDATED/REMOVED）。

## 同步流程

1. 抓取或刷新两个上游仓库。
2. 扫描 `usecases/*.md` 并提取标题。
3. 自动分类并生成索引表。
4. 输出统计报告（分类分布、来源占比、潜在重复标题）。
5. 记录来源提交和许可证快照，形成可审计证据。

## 合规与来源说明

- 本仓库以索引和链接为主，不复制上游正文内容。
- 许可证状态以最新上游仓库为准，建议每次同步后复核 `docs/SOURCES.md`。
- 对无显式许可证的来源，默认仅保留链接索引，不做全文镜像。

## License

- 本仓库采用 [Apache-2.0](LICENSE)。
- 同时附加了 `ADDITIONAL TERMS / 附加条款`，详见 `LICENSE` 文件末尾。

## Roadmap

- [ ] 引入按主题/行业的更细粒度标签。
- [ ] 增加重复用例的相似度检测与去重建议。
- [ ] 增加定时同步工作流（PR 模式）与变更摘要。
- [ ] 提供简单检索页面（静态前端读取 `USECASES.json`）。

## 贡献

欢迎提交 Issue / PR：

- 新增来源建议
- 分类规则优化
- 同步与生成脚本改进
- 文档与合规建议
