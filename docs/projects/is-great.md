# 高价值用户识别：从地区规则到双目标评分

> **MatchUp · 用户分层与预测**　Spark SQL / Python / Logistic Regression

`is_great` 是 MatchUp 用来标记高价值用户的字段。原规则按地区直接给用户打 0/1：香港全是 1，新加坡和 Other 全是 0。要在地区内部决定把资源给谁，这个标签太粗。我先从香港的规则修改入手，发现“本科以上”的条件排除了付费表现更好的用户；接着把问题推进到评分：用打分时可得的信息，分别预测未来互动和未来付费。

## 决策主线

点主图中的一步，右侧就展开这一环的**问题、数据和操作**。主图始终留在视野里。

<div class="great-explorer" role="group" aria-label="高价值用户识别决策链">
  <input class="great-switch" type="radio" name="great-step" id="great-step-0">
  <input class="great-switch" type="radio" name="great-step" id="great-step-1" checked>
  <input class="great-switch" type="radio" name="great-step" id="great-step-2">
  <input class="great-switch" type="radio" name="great-step" id="great-step-3">
  <input class="great-switch" type="radio" name="great-step" id="great-step-4">
  <input class="great-switch" type="radio" name="great-step" id="great-step-5">
  <input class="great-switch" type="radio" name="great-step" id="great-step-6">
  <input class="great-switch" type="radio" name="great-step" id="great-step-7">

  <div class="great-map" aria-label="七步主图">
    <label class="great-node" for="great-step-1"><span class="great-num">01</span><span><strong>原来怎么判？</strong><small>香港全 1；新加坡和 Other 全 0</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓</span>
    <label class="great-node" for="great-step-2"><span class="great-num">02</span><span><strong>香港为什么改？</strong><small>“本科以上”漏掉更好的用户</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓</span>
    <label class="great-node" for="great-step-3"><span class="great-num">03</span><span><strong>为什么转向模型？</strong><small>一个 0/1 装不下两种未来结果</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓</span>
    <label class="great-node" for="great-step-4"><span class="great-num">04</span><span><strong>一行数据怎么造？</strong><small>D0 画像 → 早期行为 → 未来结果</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓</span>
    <label class="great-node" for="great-step-5"><span class="great-num">05</span><span><strong>增量来自哪里？</strong><small>逐步加信息，再挑战模型复杂度</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓</span>
    <label class="great-node" for="great-step-6"><span class="great-num">06</span><span><strong>模型错在哪里？</strong><small>按人群找误差，再改学历表示</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓</span>
    <label class="great-node" for="great-step-7"><span class="great-num">07</span><span><strong>分数怎么用？</strong><small>结合覆盖与成本选人</small></span><span class="great-chevron">›</span></label>
  </div>

  <div class="great-side" aria-live="polite">
    <div class="great-empty"><strong>主图是一条决策链。</strong><p>点左边任一步，可在这里看具体数据与实现。</p></div>

    <section class="great-panel great-panel-1" aria-labelledby="great-title-1">
      <div class="great-panel-top"><span>01 / 原规则</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-1">原规则给了什么答案？</h3>
      <p>同一地区的人拿到同一个标签，运营仍不知道该先触达谁；0 还混着规则未命中、未覆盖和缺失。</p>
      <div class="great-table-wrap"><table><thead><tr><th>地区</th><th>原 <code>is_great</code></th><th>直接后果</th></tr></thead><tbody><tr><td>香港</td><td>全部 1</td><td>区内无法继续区分</td></tr><tr><td>新加坡</td><td>全部 0</td><td>有价值用户也可能被盖在 0 里</td></tr><tr><td>Other</td><td>全部 0</td><td>不同地区与用户进入同一桶</td></tr></tbody></table></div>
      <details><summary>我怎样确认旧规则的实际含义</summary><p>先以<strong>日期 × 用户</strong>为一行，用 Spark SQL 还原各地区命中条件，再查唯一性、Join 覆盖、缺失和值域。一次不可能的负重叠暴露了漏写的规则条件：比较方案前，先确认自己算的是哪条规则。</p></details>
    </section>

    <section class="great-panel great-panel-2" aria-labelledby="great-title-2">
      <div class="great-panel-top"><span>02 / 香港规则</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-2">为什么不按“本科以上”砍？</h3>
      <p>香港原来全标 1。最初收窄候选是“系统繁中港＋本科以上”，但它排除了付费表现反而更好的高中和职校用户。</p>
      <div class="great-table-wrap"><table><thead><tr><th>繁中港用户</th><th>付费率</th><th>最初候选</th></tr></thead><tbody><tr><td>本科</td><td>0.482%</td><td>留下</td></tr><tr><td>职校</td><td>0.571%</td><td>排除</td></tr><tr><td>高中</td><td>0.544%</td><td>排除</td></tr></tbody></table></div>
      <p class="great-takeaway">决策：从“学历高低”改为“是否有明确学历值”。</p>
      <div class="great-table-wrap"><table><thead><tr><th>香港候选</th><th>覆盖率</th><th>付费用户日</th></tr></thead><tbody><tr><td>繁中港＋本科以上</td><td>27.45%</td><td>190</td></tr><tr><td>繁中港＋明确学历值</td><td><strong>46.94%</strong></td><td><strong>350</strong></td></tr></tbody></table></div>
      <details><summary>数据单元与规则取舍</summary><p>比较单元是<strong>活跃用户日</strong>，窗口为 2026-08-13 至 08-19。高中和职校 × 繁中港合计有 28,886 个用户日，被“本科以上”排除。新候选多覆盖 19.49 个百分点，样本期多覆盖 160 个付费用户日；我同时看覆盖与单位价值。</p><p>“明确学历值”指研究生、本科、职校、高中等可解释内容。用户选“其他”、未填、快照缺失和 Join 失败不能简单并成同一种 0。</p></details>
    </section>

    <section class="great-panel great-panel-3" aria-labelledby="great-title-3">
      <div class="great-panel-top"><span>03 / 任务定义</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-3">为什么不继续加规则？</h3>
      <p>香港的修改解决了一次筛选，但每加一条条件，最后仍只剩一个 0/1。它保留不了原始信息，也无法同时回答两件不同的事。</p>
      <div class="great-fork"><span>打分时知道的用户信息</span><div><span>→ 之后会不会互动？</span><span>→ 之后会不会付费？</span></div></div>
      <p class="great-takeaway">旧 <code>is_great</code> 留作比较基线；新的目标是两个未来结果。</p>
      <details><summary>输入与结果具体是什么</summary><p>地区、语言、学历和早期行为是打分时可取得的输入。未来互动与付费分别形成 0/1 结果，各自训练、评估和选阈值。这样可以分别看清模型对哪一种业务结果有增量。</p></details>
    </section>

    <section class="great-panel great-panel-4" aria-labelledby="great-title-4">
      <div class="great-panel-top"><span>04 / 数据结构</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-4">一行用户怎样进入模型？</h3>
      <div class="great-axis"><div><b>D0</b><span>地区、语言、学历等画像</span></div><i aria-hidden="true">→</i><div><b>D+1～3</b><span>早期活跃与互动</span></div><i aria-hidden="true">→</i><div><b>D+4～10</b><span>未来互动与付费</span></div></div>
      <p><strong>D0 可以打一次分；D+3 后可用新增行为更新分数。D+4～10 只用来核对预测。</strong></p>
      <details><summary>看两行数据和时间切分</summary><p>每行是<strong>一个用户在一个起点日</strong>。字段摆放如下：</p><div class="great-samples"><div><b>用户 A</b><span>D0：香港 · 繁中港 · 明确学历</span><span>D+1～3：有早期互动</span><strong>D+4～10：互动 1 · 付费 0</strong></div><div><b>用户 B</b><span>D0：香港 · 繁中港 · 学历未明确</span><span>D+1～3：无早期互动</span><strong>D+4～10：互动 0 · 付费 0</strong></div></div><p>一行内部，输入必须早于结果。多周数据再按时间切开：第 1～6 周训练、第 7 周选择方案、第 8 周检查跨期表现。</p><pre><code>train = data[data.anchor_week &lt;= 6].copy()
validation = data[data.anchor_week == 7].copy()
test = data[data.anchor_week == 8].copy()</code></pre><p>预处理和模型只在 Train 拟合；同一目标的候选共享切分。</p></details>
    </section>

    <section class="great-panel great-panel-5" aria-labelledby="great-title-5">
      <div class="great-panel-top"><span>05 / 模型比较</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-5">新信息带来了什么？</h3>
      <div class="great-ladder"><span>旧规则</span><span>→</span><span>D0 画像</span><span>→</span><span>早期活跃</span><span>→</span><span>完整早期行为</span></div>
      <p>每走一步，只问：<strong>新信息是否让未来结果排得更准？</strong>再给 Tree 一次挑战 Logistic 的机会。</p>
      <div class="great-metrics"><div><small>未来互动 AUC</small><strong>0.509 → 0.844</strong><span>旧规则 → 完整模型</span></div><div><small>未来付费 AUC</small><strong>0.574 → 0.643</strong><span>静态先验 → 加早期行为</span></div></div>
      <details><summary>为什么这样安排比较对象</summary><p>地区均值检查模型是否只是学到地区差异；静态 Logistic 检查 D0 画像价值；仅加活跃度与完整早期行为，拆开“活跃”与更细行为的增量。受控 Tree 用来检查非线性结构是否值得增加复杂度。</p><p>排序之外还看概率与实际发生率是否对得上，以及最终选中的 Top-K 人群。</p></details>
    </section>

    <section class="great-panel great-panel-6" aria-labelledby="great-title-6">
      <div class="great-panel-top"><span>06 / 找错与改输入</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-6">为什么回头改学历特征？</h3>
      <div class="great-diagnostic"><span>整体概率看起来接近实际</span><b>↓ 按学历是否有明确值拆开</b><span>无明确值：预测偏高<br>有明确值：预测偏低</span><b>↓ 回查原字段，只改这一处输入</b><span>学历内容 ＋ 是否有明确学历值</span></div>
      <p>香港分析已提示“学历越高越好”并不成立。模型的人群误差让我回到原始 <code>qualification</code>，检查值域、Join 和打分时能否取得。</p>
      <details><summary>改了哪一列，怎样检验</summary><pre><code>STATIC_NUMS_OLD_EDUCATION = ["tenure_days", "education_level_ordinal"]
STATIC_NUMS = STATIC_NUMS_OLD_EDUCATION + ["has_explicit_education"]

before = logistic_pipeline(POSTERIOR_OLD_EDUCATION[target])
after = logistic_pipeline(POSTERIOR[target])</code></pre><p>两个版本使用同一 Train／Validation／Test、同一 Logistic 配置和其余输入。只改学历表示，再比较排序、人群概率和 Top-K，检验增量来自哪里。</p></details>
    </section>

    <section class="great-panel great-panel-7" aria-labelledby="great-title-7">
      <div class="great-panel-top"><span>07 / 业务动作</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-7">分数最后服务什么决策？</h3>
      <p>模型给每人一个互动或付费概率；运营再根据可触达人数和错误成本选择 Top-K 或阈值。</p>
      <div class="great-fork"><span>预测分数</span><div><span>→ 谁更可能？</span><span>→ 这批人值得投入多少资源？</span></div></div>
      <p class="great-takeaway">是否给这批人更多资源会创造增量，需要下一步动作实验回答。</p>
      <details><summary>从概率到选人，检查哪三层</summary><p>先看排序能否把未来会发生结果的人排在前面；再看分组概率能否支持资源预算；最后看选中人群的覆盖与成本。要判断某种运营动作的增量，在确定目标人群后随机分配动作。</p></details>
    </section>
  </div>
</div>
