# 项目经历总览

以下是我在 OPay（出海独角兽 Fintech）实习期间完成的主要项目。每个项目都记录了**完整的分析思路**：从问题背景、方法选型、SQL/Python 实现到最终结论与商业影响。

---

<div class="project-card" markdown>

### :material-cellphone-cog: [ANR 因果推断：当 "+15%" 只是海市蜃楼](anr-optimization.md) {#project-anr}

**关键词**：Difference-in-Differences · 准实验 · 发薪日混淆 · 因果推断

策略全量上线无法 A/B，用 DID 方法以 >2G 设备为对照组，剥离月底发薪日季节性效应后证明 GTV 真实因果增量仅 +1.6%（而非 +15%），将决策框架重定义为成本-收益权衡。

</div>

<div class="project-card" markdown>

### :material-chart-timeline-variant: [Growth Accounting：拆解增长的"漏水桶"](growth-accounting.md) {#project-growth}

**关键词**：Growth Accounting · Overlap Window · 用户状态流转 · MAU 拆解

在 MAU 停滞但买量不停的背景下，主动引入 Growth Accounting 框架。用 SQL 窗口函数构建 Overlap Window 滚动追踪，将 MAU 拆解为 New/Retained/Resurrected/Churned 四个分量，定位到网盟渠道的"漏水点"。

</div>

<div class="project-card" markdown>

### :material-advertisements: [广告渠道反作弊：当 36 个子渠道呈现同一种异常](ad-channel-analysis.md) {#project-ad-channel}

**关键词**：Click Flooding · CTIT/ITET · 四平台基线 · 归因优化

从 AppsFlyer 数据的阶梯状分布主动发现异常，拉取 Google/Facebook/TikTok 与嫌疑网盟多月原始数据进行四维度 EDA + 多平台校准 + 漏斗分解，产出反作弊规则，将网盟 UAC 降低 20%。

</div>
