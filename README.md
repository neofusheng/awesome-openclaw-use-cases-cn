[English](README_EN.md) | **简体中文**

<div align="center">

# Awesome OpenClaw Use Cases CN

**把 OpenClaw 上游案例转成可筛选、可追踪、可直接执行的中文数据资产。**

> 中文世界里，最值得收藏的 OpenClaw 实战案例库。
>
> 收录真正 **能落地、能复用、能出效果** 的场景、提示词、配置、工作流与踩坑。

同时，它也是一个面向中文用户的 **OpenClaw 实战案例库 / 灵感库 / 模板库**。

[![CI](https://github.com/AIPMAndy/awesome-openclaw-Usecases-CN/actions/workflows/ci.yml/badge.svg)](https://github.com/AIPMAndy/awesome-openclaw-Usecases-CN/actions/workflows/ci.yml)
[![Data](https://img.shields.io/badge/data-markdown%20%2B%20json-brightgreen)](docs/USECASES.json)
[![Sync](https://img.shields.io/badge/sync-daily-blue)](.github/workflows/sync-upstream.yml)
[![Stars](https://img.shields.io/github/stars/AIPMAndy/awesome-openclaw-Usecases-CN?style=social)](https://github.com/AIPMAndy/awesome-openclaw-Usecases-CN/stargazers)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](#贡献指南)

</div>

## 为什么这个仓库值得 Star

因为大多数人卡住的不是“OpenClaw 强不强”，而是：

- **到底能做什么？**
- **哪些玩法是真能跑通的？**
- **我应该先抄哪一个？**
- **哪些场景最容易做出 wow effect？**

这个仓库同时解决两件事：

1. **做中文实战案例入口**：帮助用户快速找到值得复用的 OpenClaw 用法
2. **做结构化数据资产**：把案例沉淀为 `Markdown + JSON` 双格式，支持检索、追踪、自动同步

你会在这里看到：

- 真实可复制的 OpenClaw 用例
- 一句话就能看懂的场景价值
- 可复用的 Prompt / 配置 / 工作流
- 不同平台（Feishu / Telegram / Discord / WhatsApp / Web / CLI）的实战玩法
- 真实踩坑，而不是空泛概念

> 一句话：
> **这不是 OpenClaw 的“功能介绍”，而是 OpenClaw 的“结果清单 + 数据底座”。**

---

## 🆚 为什么选这个？

| 维度 | 常见用例列表 | Awesome OpenClaw Use Cases CN |
|---|---|---|
| 数据形态 | 纯 Markdown | `Markdown + JSON` 双格式 |
| 增量追踪 | 手工比对 | 自动产出 `NEW/UPDATED/REMOVED` |
| 可靠性判断 | 靠主观阅读 | `security_risk / source_confidence / reproducibility_score` |
| 落地速度 | 自己拆步骤 | 自动生成 TopN `QUICKSTARTS` |
| 阅读体验 | 信息分散 | 首页精选 + 分类索引 + use case 模板 |
| 持续维护 | 人工更新 | CI + 每日定时同步 PR |

---

## 适合谁

- 想快速找到 OpenClaw 灵感的新手
- 想做 Agent 工作流的产品经理 / 开发者 / 创始人
- 想做 AI 内容演示、课程、案例拆解的人
- 想搭建私人助理、团队助手、自动化流程的人
- 想把案例沉淀成机器可读数据源的人

---

## 快速开始：最值得先看的 8 个方向

### 1) 私人助理 / Life OS
- [Feishu 私人助理：把 OpenClaw 变成你的日常协作中枢](./usecases/feishu-personal-assistant.md)
- [Telegram 陪跑助理：把 AI 放进最高频的聊天入口](./usecases/telegram-coach-assistant.md)
- [Founder Chief-of-Staff Agent：给创始人的 AI 参谋台](./usecases/founder-chief-of-staff.md)

### 2) 内容创作自动化
- [内容改写工作流：一篇长文拆成多平台内容](./usecases/content-repurpose.md)

### 3) 办公提效 / 汇报自动化
- [日报 / 周报 Agent：自动把碎片进展整理成可汇报内容](./usecases/weekly-report-agent.md)

### 4) 开发者与技术协作
- [GitHub PR Review Agent：在聊天里发起代码协作](./usecases/github-pr-review-agent.md)

### 5) 高级玩法
- [Browser 自动化 Demo：让 Agent 不只是会说，还会点](./usecases/browser-automation-demo.md)
- [知识库问答助手：把散落信息变成可问可答](./usecases/knowledge-base-qa.md)

---

## 🚀 30 秒快速开始

```bash
chmod +x scripts/*.sh
scripts/fetch_and_build.sh
```

验证产物：

```bash
ls docs/USECASES.md docs/USECASES.json docs/STATS.md docs/SOURCES.md docs/DIFF.md docs/DIFF.json docs/QUICKSTARTS.md docs/QUICKSTARTS.json
```

---

## 📦 你会得到什么

每次构建会在 `docs/` 生成：

- `USECASES.md`：中文总索引（人读）
- `USECASES.json`：结构化索引（程序读）
- `STATS.md`：分类、风险、License 分布
- `SOURCES.md`：来源仓库、提交、许可证快照
- `DIFF.md` / `DIFF.json`：增量变化（NEW/UPDATED/REMOVED）
- `QUICKSTARTS.md` / `QUICKSTARTS.json`：TopN 可执行落地手册

---

## 🔍 典型检索

```bash
# 高风险且高可复现用例
scripts/query_usecases.sh --risk high --min-confidence 70 --min-repro 60 --limit 20

# 关键词检索
scripts/query_usecases.sh --keyword security --limit 10
```

---

## 🛠 核心命令

```bash
# 全量同步（抓取上游 + 生成所有产物）
scripts/fetch_and_build.sh

# 仅基于本地上游仓库生成索引
scripts/generate_usecases_index.sh --src-a /path/to/repo-a --src-b /path/to/repo-b

# 生成来源与许可证快照
scripts/generate_sources_report.sh --src-a /path/to/repo-a --src-b /path/to/repo-b

# 生成增量对比报告
scripts/generate_usecases_diff.sh --old docs/USECASES.prev.json --new docs/USECASES.json

# 生成 TopN 快速落地手册
scripts/generate_quickstarts.sh --index docs/USECASES.json --top 20
```

## ⚙️ Makefile

```bash
make test
make quality
make build
make query Q=security
make quickstarts TOP=20
```

---

## 按场景分类

### 入门友好
- 私人聊天助理
- Feishu / Telegram / Discord 接入
- 提醒与跟进
- 长期记忆助手

### 内容创作
- 选题策划
- 多平台改写
- 研究日报
- 爆款内容拆解

### 个人效率
- 日报/周报生成
- 待办整理
- 日历提醒
- 知识库问答

### 创业 / 商业
- 创始人参谋台
- 顾问式问答
- SOP 助理
- 客户跟进

### 开发者 / 技术
- PR Review 助手
- GitHub 工作流助手
- 多 Agent 协作
- 自动化脚本执行

### 高级玩法
- Browser 自动化
- 多渠道联动
- 节点设备联动
- 长期记忆系统

---

## 🤖 自动化维护

- CI：每次 Push/PR 执行 `lint + test + build smoke`
- 定时同步：每天 UTC `02:00` 自动抓取上游并创建更新 PR
- PR 摘要自动包含：`NEW / UPDATED / REMOVED / Top Quickstarts`

---

## 推荐投稿格式

建议每个案例尽量包含：

- 场景
- 用户对象
- 使用渠道
- 用到的 OpenClaw 能力
- 工作流步骤
- Prompt / 配置
- 效果
- 踩坑
- 截图 / 演示

模板见：
- [`templates/usecase-template.md`](./templates/usecase-template.md)
- [`CONTRIBUTING.md`](./CONTRIBUTING.md)

---

## 收录标准

优先收录：

- **真实跑通过**，不是停留在想法层面
- **别人能复用**，不是只有作者自己看得懂
- **信息密度高**，能看出怎么做、为什么有效
- **有结果感**，最好带截图/GIF/流程/演示
- **有传播性**，别人看一眼就想转发/收藏

不太建议收录：

- 只有概念，没有细节
- 只有一句“可以做 XX”
- 与 OpenClaw 关系很弱的普通 AI 用例

---

## 贡献指南

欢迎提交：

- 新增上游来源
- 新增高质量 use case
- 改进分类/评分规则
- 改进同步脚本与测试覆盖
- 补充截图、Prompt、配置、踩坑
- 优化英文对照、文档与合规说明

如果你不确定怎么写，也可以直接提 Issue：

- 你做了什么
- 用了哪些能力
- 效果如何
- 遇到什么坑

我会帮你整理成可收录版本。

---

## 项目路线图

### Phase 1：把仓库做成“像样的案例库”
- [x] README 首页重构
- [x] 案例模板
- [x] 第一批示例 use cases
- [ ] 增加 10~20 个高质量案例
- [ ] 增加截图 / GIF / 演示链接

### Phase 2：让仓库开始增长
- [ ] 增加英文副标题 / 关键词，覆盖搜索流量
- [ ] 投稿到 awesome / agent / AI automation 社区
- [ ] 联动 Twitter / 即刻 / 小红书 / 微信公众号
- [ ] 邀请真实用户投稿

### Phase 3：从仓库进化成中文生态入口
- [ ] 做可视化导航页
- [ ] 增加标签检索（按平台 / 难度 / 效果）
- [ ] 建立精选案例榜单
- [ ] 沉淀为周更精选 / newsletter

---

## 📄 License

- 本仓库采用 [Apache-2.0](LICENSE)
- 同时附加 `ADDITIONAL TERMS / 附加条款`（见 `LICENSE`）

## 👨‍💻 作者

维护者：**AI酋长Andy**

商业授权联系：微信 `AIPMAndy`

---

## 相关资源

- OpenClaw Docs: <https://docs.openclaw.ai>
- OpenClaw GitHub: <https://github.com/openclaw/openclaw>
- OpenClaw Community: <https://discord.com/invite/clawd>

---

## 这个项目怎么更容易火

核心不是“堆更多链接”，而是这三件事：

1. **首页 5 秒内讲清价值**
2. **前 10 个案例足够让人有记忆点**
3. **投稿门槛低，展示门槛更低**

所以这个项目接下来最值得补的，不只是条目数量，而是：

- 3~5 个封面级案例
- 每个案例至少 1 张截图 / 1 个 GIF / 1 个结果对比
- 更清晰的标签体系
- 更容易参与的投稿机制

如果你愿意一起共建，欢迎：

- Star
- Watch
- 提 PR
- 提 Issue
- 分享给更多 OpenClaw 用户

一起把它做成 **OpenClaw 中文生态最有价值的案例入口** ✦
