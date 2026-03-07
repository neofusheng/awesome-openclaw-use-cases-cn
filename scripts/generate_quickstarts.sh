#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

INDEX_JSON="${ROOT_DIR}/docs/USECASES.json"
OUT_MD="${ROOT_DIR}/docs/QUICKSTARTS.md"
OUT_JSON="${ROOT_DIR}/docs/QUICKSTARTS.json"
TOP_N=20

usage() {
  cat <<'USAGE' >&2
Usage:
  scripts/generate_quickstarts.sh [options]

Options:
  --index <file>       Input usecases JSON (default: docs/USECASES.json)
  --out-md <file>      Output markdown file (default: docs/QUICKSTARTS.md)
  --out-json <file>    Output JSON file (default: docs/QUICKSTARTS.json)
  --top <n>            Number of quickstarts to generate (default: 20)
  -h, --help           Show help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --index)
      INDEX_JSON="${2:-}"
      shift 2
      ;;
    --out-md)
      OUT_MD="${2:-}"
      shift 2
      ;;
    --out-json)
      OUT_JSON="${2:-}"
      shift 2
      ;;
    --top)
      TOP_N="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if ! [[ "$TOP_N" =~ ^[0-9]+$ ]]; then
  echo "Error: --top must be a non-negative integer." >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not found." >&2
  exit 1
fi

if [[ ! -f "$INDEX_JSON" ]]; then
  echo "Error: index JSON not found: ${INDEX_JSON}" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT_MD")"
mkdir -p "$(dirname "$OUT_JSON")"

generated_at="${OPENCLAW_GENERATED_AT:-$(date '+%Y-%m-%d %H:%M:%S %Z')}"

jq \
  --arg generated_at "$generated_at" \
  --argjson top_n "$TOP_N" '
  def risk_weight($risk):
    if $risk == "low" then 0
    elif $risk == "medium" then 1
    elif $risk == "high" then 2
    else 3
    end;

  def ranking_score($u):
    (((($u.source_confidence // 0) * 0.55)
      + (($u.reproducibility_score // 0) * 0.45))
      - (risk_weight($u.security_risk // "high") * 8));

  def round1: ((. * 10) | round / 10);

  def stack_by_category($category):
    if $category == "开发运维" then ["Bash", "Python", "Cron", "日志监控"]
    elif $category == "效率自动化" then ["Python", "Webhook", "任务调度", "通知渠道"]
    elif $category == "学习知识" then ["Markdown", "Embedding/RAG", "向量检索", "定时归档"]
    elif $category == "内容增长" then ["LLM", "内容模板", "发布API", "指标看板"]
    elif $category == "投资交易" then ["行情API", "风险控制", "审计日志", "回测脚本"]
    elif $category == "安全" then ["隔离环境", "最小权限凭据", "审计日志", "只读扫描"]
    elif $category == "生活方式" then ["消息机器人", "日历/天气API", "提醒策略", "隐私配置"]
    else ["Python", "Bash", "Webhook", "日志"]
    end;

  def preflight($u):
    [
      "阅读并确认上游用例范围与授权要求",
      "在隔离目录创建实验分支或临时项目",
      "记录目标产出与成功判定标准"
    ] +
    (if ($u.security_risk // "low") == "high" then
      ["使用测试账号、假数据与最小权限密钥", "禁止直接连接生产系统"]
    elif ($u.security_risk // "low") == "medium" then
      ["限制外部调用配额并开启审计日志"]
    else
      []
    end);

  def steps($u):
    [
      "打开上游链接，提取输入、输出和触发条件",
      ("按分类 " + ($u.category // "通用") + " 搭建最小可运行版本"),
      "先打通单次执行，再补调度、通知或集成接口",
      "将参数与密钥改为环境变量，并增加失败重试与错误日志"
    ];

  def verification($u):
    [
      "至少跑通 1 次端到端流程并保存输出样例",
      "验证异常路径：缺参数、超时、上游失败",
      "确认输出与目标一致，并记录可复现命令"
    ] +
    (if ($u.security_risk // "low") == "high" then
      ["确认敏感数据未落盘，日志已脱敏"]
    else
      []
    end);

  def rollback($u):
    [
      "暂停该自动化任务的定时触发",
      "停用临时密钥并清理缓存数据",
      "回退到手工流程并保留排障日志"
    ];

  def difficulty($u; $score):
    if (($u.security_risk // "low") == "high") or ($score < 65) then "advanced"
    elif $score < 80 then "medium"
    else "easy"
    end;

  def eta_minutes($u; $score):
    if ($u.security_risk // "low") == "high" then 60
    elif $score >= 80 then 25
    elif $score >= 65 then 40
    else 55
    end;

  (.usecases // []) as $all
  | ($all
      | map(. + {ranking_score: (ranking_score(.) | round1)})
      | sort_by([
          risk_weight(.security_risk // "high"),
          -(.ranking_score),
          -(.source_confidence // 0),
          -(.reproducibility_score // 0),
          .source,
          .path
        ])
      | .[:$top_n]) as $selected
  | {
      generated_at: $generated_at,
      source_generated_at: (.generated_at // ""),
      top_n: $top_n,
      selected_count: ($selected | length),
      ranking_formula: "score=0.55*source_confidence+0.45*reproducibility_score-risk_penalty(low=0,medium=8,high=16)",
      quickstarts: (
        $selected
        | to_entries
        | map(
            .value as $u
            | ($u.ranking_score) as $score
            | {
                rank: (.key + 1),
                source: $u.source,
                path: $u.path,
                title: $u.title,
                url: $u.url,
                category: ($u.category // "通用"),
                security_risk: ($u.security_risk // "unknown"),
                source_confidence: ($u.source_confidence // 0),
                reproducibility_score: ($u.reproducibility_score // 0),
                ranking_score: $score,
                quickstart: {
                  difficulty: difficulty($u; $score),
                  estimated_minutes: eta_minutes($u; $score),
                  recommended_stack: stack_by_category($u.category // "通用"),
                  preflight: preflight($u),
                  steps: steps($u),
                  verification: verification($u),
                  rollback: rollback($u)
                }
              }
          )
      )
    }
' "$INDEX_JSON" > "$OUT_JSON"

jq -r '
  "# OpenClaw Top Quickstarts\n\n"
  + "> 自动生成文件，请勿手工编辑。\n\n"
  + "- 生成时间: \(.generated_at)\n"
  + "- 索引时间: \(.source_generated_at)\n"
  + "- TopN: \(.top_n)\n"
  + "- 实际输出: \(.selected_count)\n"
  + "- 排序规则: \(.ranking_formula)\n\n"
  + "## 总览\n\n"
  + "| Rank | Title | Source | Category | Risk | Confidence | Repro | Score |\n"
  + "|---|---|---|---|---|---:|---:|---:|\n"
  + ((.quickstarts
      | map("| \(.rank) | \(.title) | \(.source) | \(.category) | \(.security_risk) | \(.source_confidence) | \(.reproducibility_score) | \(.ranking_score) |")
      | join("\n")) + "\n\n")
  + (.quickstarts
      | map(
          "## \(.rank). \(.title)\n\n"
          + "- Source: \(.source)\n"
          + "- Path: `\(.path)`\n"
          + "- Category: \(.category)\n"
          + "- Risk: \(.security_risk)\n"
          + "- Confidence: \(.source_confidence)\n"
          + "- Reproducibility: \(.reproducibility_score)\n"
          + "- Score: \(.ranking_score)\n"
          + "- Difficulty: \(.quickstart.difficulty)\n"
          + "- Estimated: \(.quickstart.estimated_minutes) min\n"
          + "- URL: \(.url)\n\n"
          + "### Recommended Stack\n\n"
          + "- " + (.quickstart.recommended_stack | join("\n- ")) + "\n\n"
          + "### Preflight\n\n"
          + (.quickstart.preflight | to_entries | map("\(.key + 1). \(.value)") | join("\n")) + "\n\n"
          + "### Steps\n\n"
          + (.quickstart.steps | to_entries | map("\(.key + 1). \(.value)") | join("\n")) + "\n\n"
          + "### Verification\n\n"
          + (.quickstart.verification | map("- " + .) | join("\n")) + "\n\n"
          + "### Rollback\n\n"
          + (.quickstart.rollback | map("- " + .) | join("\n"))
        )
      | join("\n\n"))
' "$OUT_JSON" > "$OUT_MD"

echo "Generated quickstarts markdown: ${OUT_MD}"
echo "Generated quickstarts json: ${OUT_JSON}"
