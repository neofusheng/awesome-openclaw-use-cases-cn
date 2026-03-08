# GitHub PR Review Agent：在聊天里发起代码协作

- 场景：通过聊天渠道发起代码审阅、总结 PR 风险、整理 review 建议
- 用户：开发者、技术负责人、独立开发者
- 渠道：Discord / Telegram / Feishu / CLI
- 用到的能力：sessions_spawn / acp / subagents / read / exec / message
- 难度：中级
- 效果：把代码协作入口从 IDE 扩展到消息渠道

## 为什么值得做

很多代码协作动作不是“写代码”，而是：

- 看 PR 到底改了什么
- 有哪些潜在风险
- 是否值得合并
- 应该给出怎样的 review 意见

这正是 Agent 很适合切入的地方。

## 工作流

1. 用户在聊天中发起 PR Review 请求
2. Agent 拉取仓库 / 读取 diff / 查看上下文
3. 生成 review 总结、风险点、建议修改项
4. 如有需要，继续交给 ACP / 子 Agent 深入分析

## 关键 Prompt / 配置

```txt
请对这个 PR 做一次偏工程负责人的 review：
- 先总结改动目的
- 再列出风险点
- 再给出 blocking / non-blocking 建议
- 最后给出是否建议合并的判断
```

## 踩坑

- 只看 diff 容易误判，最好结合上下文文件
- review 结果必须分清“高风险问题”和“风格建议”
- 如果要自动评论，建议先人工确认

## 演示 / 截图

- 可补聊天里发起 review 的截图
- 可补 review 输出示例

## 适合谁复用

- 技术团队
- 独立开发者
- 想做 AI coding workflow 展示的人
