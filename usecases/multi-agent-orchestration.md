# 多 Agent 编排：主 Agent 沟通，子 Agent 执行

- 场景：一个主 Agent 面向用户沟通，多个子 Agent 并行处理不同任务
- 用户：开发者、自动化玩家、复杂项目操盘者
- 渠道：Discord / Feishu / CLI
- 用到的能力：sessions_spawn / subagents / sessions_send / tools
- 难度：高级
- 效果：把复杂任务拆分执行，减少主线程上下文压力

## 为什么值得做

单 Agent 很容易在复杂任务中又沟通又执行，导致上下文混乱。多 Agent 编排让协作更清晰。

## 工作流

1. 主 Agent 接收用户目标
2. 子 Agent 按任务拆分并行处理
3. 主 Agent 汇总阶段结果
4. 需要时继续派发下一轮

## 踩坑

- 不要为了多 Agent 而多 Agent
- 必须定义清楚主从职责，否则只会更乱
