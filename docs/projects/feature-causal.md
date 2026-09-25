# Super Like：从会话质量到首次使用验证

> **MatchUp · Super Like 首次使用策略**　Spark SQL / 实验设计 / 因果推断

我在分析付费会员的多个功能，想判断 Super Like 值不值得继续投入。Super Like 让会员主动表达强烈兴趣。先看已经形成 Match 的会话：到 D+3 时，SuperLiked 会话有至少 5 条消息的比例为 **36.9%**，Swipe 会话为 **22.5%**。这提示了 Match 后的聊天质量，但没有形成 Match 的发送、以及没有使用功能的会员，都不在这个比较里。

接着检查规模为什么上不去：使用者日均消耗 3.07 个 Super Like，用量达到 5 个及以上的用户日仅占全部活跃付费用户日的 8.57%；**75.6% 的活跃付费用户日当天零使用**。现有数据更值得先追问采用问题，而不是直接增加额度。因此我把下一步转向验证首次使用：帮助低频付费会员使用后，完整目标人群能否多产生深聊？推进这个问题时，我把**主分析分母从哪里开始**作为与同事、业务对齐的关键点。只看已形成 Match 的结果可能很亮眼，却回答不了这项策略对全部目标人群的增量。

## 决策主线

点左侧任一步，在右侧看具体的数据、操作和判断。只沿左侧，也能读完为什么下一步会出现。

<div class="great-explorer feature-explorer" role="group" aria-label="付费功能评估决策链">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-0">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-1">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-2">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-3">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-4">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-5">
  <input class="great-switch" type="radio" name="feature-step" id="great-step-6" checked>
  <input class="great-switch" type="radio" name="feature-step" id="great-step-7">

  <div class="great-map" aria-label="七步主图">
    <label class="great-node" for="great-step-1"><span class="great-num">01</span><span><strong>质量信号来自谁？</strong><small>36.9% 对 22.5%，分母都是已形成 Match 的会话</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓ 质量信号成立，再查使用规模卡在哪</span>
    <label class="great-node" for="great-step-2"><span class="great-num">02</span><span><strong>额度卡住使用了吗？</strong><small>先看消耗与触顶，再看日采用率</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓ 零使用占多数，再拆首次采用与复用</span>
    <label class="great-node" for="great-step-3"><span class="great-num">03</span><span><strong>采用问题发生在哪？</strong><small>按历史使用与当天 Swipe，区分激活和召回</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓ 行为线索不能证明原因，需要一个可测试动作</span>
    <label class="great-node" for="great-step-4"><span class="great-num">04</span><span><strong>到底测试什么？</strong><small>固定教育入口＋一键使用的组合策略</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓ 想解释结果，先保证人群和策略语义成立</span>
    <label class="great-node" for="great-step-5"><span class="great-num">05</span><span><strong>实验开始前查什么？</strong><small>每类目标用户有两组；同一标签有稳定体验</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓ 下一步先和业务对齐：究竟对谁计算增量</span>
    <label class="great-node" for="great-step-6"><span class="great-num">06</span><span><strong>和业务对齐哪个分母？</strong><small>只看 Match 的数字亮眼，却回答错策略问题</small></span><span class="great-chevron">›</span></label>
    <span class="great-connector" aria-hidden="true">↓ 锁定主比较后，才谈证据是否足以行动</span>
    <label class="great-node" for="great-step-7"><span class="great-num">07</span><span><strong>显著就推广吗？</strong><small>看效果大小、精度、成熟窗口与体验代价</small></span><span class="great-chevron">›</span></label>
  </div>

  <div class="great-side" aria-live="polite">
    <div class="great-empty"><strong>从一个观察差异，走到一个可以回答业务决策的比较。</strong><p>点左侧任一步，查看对应证据。</p></div>

    <section class="great-panel great-panel-1" aria-labelledby="great-title-1">
      <div class="great-panel-top"><span>01 / 观察线索</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-1">会话更深，是否代表功能带来增量？</h3>
      <p>我们先问一个简单的问题：已经 Match 的会话，哪一种在三天后聊得更深？</p>
      <div class="great-samples"><div><b>SuperLiked Match</b><span>到 D+3 至少 5 条消息的 SuperLiked 会话</span><strong>÷ 全部已形成的 SuperLiked Match 会话 = 36.9%</strong></div><div><b>Swipe Match</b><span>到 D+3 至少 5 条消息的 Swipe 会话</span><strong>÷ 全部已形成的 Swipe Match 会话 = 22.5%</strong></div></div>
      <p class="great-takeaway">判断：在已形成 Match 的会话中，SuperLiked 的深聊比例更高。这是继续研究该功能的线索；是否能带来总体增量，还要看未形成 Match 的机会和未使用的人。</p>
    </section>

    <section class="great-panel great-panel-2" aria-labelledby="great-title-2">
      <div class="great-panel-top"><span>02 / 杠杆选择</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-2">先查额度，再查采用</h3>
      <div class="great-metrics"><div><small>使用者日 · 平均消耗</small><strong>3.07</strong><span>用量达到 5 个及以上的用户日，占全部活跃付费用户日 8.57%</span></div><div><small>活跃付费用户日 · 当天零使用</small><strong>75.6%</strong><span>当天有使用的用户日为 24.4%</span></div></div>
      <p>先用余额、赠额重置和单买记录核对真实触顶人数及触顶后的需求；“用了 5 个及以上”本身不能证明额度已用尽。再看日采用率：多数付费用户日根本没有使用，当前更大的可见缺口发生在使用前。</p>
      <p class="great-takeaway">判断：先定位首次采用和复用问题；若核实有一批用户持续触顶，再单独评估加额度。</p>
    </section>

    <section class="great-panel great-panel-3" aria-labelledby="great-title-3">
      <div class="great-panel-top"><span>03 / 目标人群</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-3">零使用，是没开始用，还是用过后停了？</h3>
      <p>在实验前的观察窗口，先看零使用 Super Like 的付费会员当天是否仍在 Swipe；再按历史记录区分窗口内从未使用、偶尔使用和用过后停用。</p>
      <div class="great-axis"><div><b>观察期当天</b><span>Super Like = 0<br>是否仍 Swipe</span></div><i>→</i><div><b>历史</b><span>窗口内未使用 / 用过后停用</span></div><i>→</i><div><b>对应动作</b><span>首次激活 / 召回与复用</span></div></div>
      <p class="great-takeaway">判断：先对仍有社交行为、但尚未采用的人测试首次使用；用过后停用的人另查复用障碍。</p>
    </section>

    <section class="great-panel great-panel-4" aria-labelledby="great-title-4">
      <div class="great-panel-top"><span>04 / 策略定义</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-4">要估计哪一套真实体验？</h3>
      <div class="great-fork"><span>分配前符合资格的低频付费用户</span><div><span>对照：维持原有使用体验</span><span>策略：教育入口＋一键 Super Like</span></div></div>
      <p>这两项改动是一套组合策略。后续即便看到效果，也只能先评价这套组合，不能分别归因给教育内容或一键入口。</p>
      <p class="great-takeaway">判断：先固定要推广的产品动作，才有清楚的潜在结果 Y(1) 与 Y(0)。</p>
      <details><summary>策略版本与记录合同</summary><p>记录用户分组、入口版本、实际曝光、使用动作和触发时间。若同一标签下混入不同版本或临时赠额，必须知道这些变化；若混合版本本身就是稳定的推广策略，应明确按整体策略评价。被分配后没有实际曝光仍留在策略效果中，不自动构成一致性失败。</p></details>
    </section>

    <section class="great-panel great-panel-5" aria-labelledby="great-title-5">
      <div class="great-panel-top"><span>05 / 实验前检查</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-5">总体 50/50，是否就能比较每类用户？</h3>
      <p>随机分组要落到计划覆盖的目标人群里；策略标签也要对应可解释的实际体验。总体分组比例正常，不能替代这两项检查。</p>
      <div class="great-table-wrap"><table><thead><tr><th>检查</th><th>一个会被总体检查遮住的例子</th><th>行动</th></tr></thead><tbody><tr><td>正值性</td><td>iOS 只有策略组，Android 只有对照组</td><td>按关键目标人群查两组覆盖</td></tr><tr><td>一致性</td><td>同一“策略组”标签混入不同入口或赠额</td><td>核对配置、版本与实际交付</td></tr></tbody></table></div>
      <p class="great-takeaway">判断：平台分流正常，是必要检查；比较对象与产品体验仍需逐层确认。</p>
      <details><summary>展开一层：正值性与一致性在公式里做什么</summary><p>对决策相关的实验前人群 X，正值性要求 <code>0 &lt; P(Z=1 | X=x) &lt; 1</code>。一致性要求观测到的结果对应其被分配的、定义清楚的策略世界：<code>Yobs = Y(Z)</code>。随机化负责让分组前的潜在结果类型在两组可比；一致性负责把实际观测接到对应的潜在结果上。</p></details>
    </section>

    <section class="great-panel great-panel-6" aria-labelledby="great-title-6">
      <div class="great-panel-top"><span>06 / 对齐主分母</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-6">这项策略要对谁计算增量？</h3>
      <p>推进首次使用策略时，我把主分母与同事、业务先对齐：要判断的是完整目标人群的深聊有没有增加。只看“深聊 / 已形成 Match”可能得到更好看的结果，但它把没形成 Match 的机会排除在外，回答的是另一件事。</p>
      <div class="great-axis"><div><b>分配时</b><span>完整合格机会<br>两组随机可比</span></div><i>→</i><div><b>分配后</b><span>曝光 / 使用 / Match<br>同时受策略与意愿影响</span></div><i>→</i><div><b>错误主比较</b><span>两组各留下的 Match<br>不再自动可比</span></div></div>
      <p class="great-takeaway">判断：主结论从分配时的完整合格机会开始；Match 后质量保留作解释，不能替代策略增量。</p>
      <details><summary>为什么随机化保护没有跟着筛选走</summary><p>设 <code>Z</code> 为分组，<code>M</code> 为是否形成 Match，<code>Y</code> 为成熟深聊。随机化让 <code>Z</code> 在分组前不按潜在结果挑人；一致性把现实结果接到对应策略世界，因此完整人群的策略效果可由两组结果均值之差估计。</p><p>但只保留 Match 后，比较变成 <code>E[Y(1) | M(1)=1] − E[Y(0) | M(0)=1]</code>：左右条件中的人未必是同一类。策略可能让原本不会 Match 的边缘用户进入一侧，原本的社交意愿也影响 Match。即使平台的分流、A/A、SRM 都正常，也需要分析师与业务确认这个分母是否回答了原问题。</p><p>这也不意味着所有 Match 后分析都无用。它能描述已形成关系后的体验；不能拿来代替完整人群的策略增量。</p></details>
      <details><summary>一行可执行的主比较</summary><p><code>ITT = mean(D3 深聊 | 已分配策略组、合格且 D3 已成熟) − mean(D3 深聊 | 已分配对照组、合格且 D3 已成熟)</code>。用户层固定分组；若同一用户贡献多次机会，区间估计按用户聚类。曝光、使用、Match 是解释链路的指标，不是主结果的入样条件。</p></details>
    </section>

    <section class="great-panel great-panel-7" aria-labelledby="great-title-7">
      <div class="great-panel-top"><span>07 / 证据到行动</span><label for="great-step-0" aria-label="收起细节">×</label></div>
      <h3 id="great-title-7">深聊显著增加，就该推广吗？</h3>
      <p>先约定主结果窗口、值得投入的最小增量和接收方体验护栏。结果出来后同时看方向、幅度、区间、成熟率及漏斗损耗，不能只盯一个“显著”。</p>
      <div class="great-table-wrap"><table><thead><tr><th>结果形态</th><th>下一步判断</th></tr></thead><tbody><tr><td>使用增加，成熟深聊也增加</td><td>结合接收方体验与成本，评估扩大范围</td></tr><tr><td>使用增加，成熟深聊没有增加</td><td>查替代 Swipe、Match 到聊天的损耗；调整人群或体验</td></tr><tr><td>使用没有增加</td><td>查曝光与入口执行，再决定改版或停止</td></tr></tbody></table></div>
      <p class="great-takeaway">判断：统计证据有多强，与业务愿意承担多少风险，是两次不同的判断。</p>
      <details><summary>假设检验怎样避免新的假结果</summary><p>观察结果前固定主指标、分析分母、结果成熟窗口与判断标准。置信区间跨过零意味着证据不足以排除零效果，不等于证明策略没有价值；区间很宽时还要看是否覆盖业务上值得投入的效果。看完结果再调显著性门槛，不会增加证据。若风险可控，仍可选择继续受控验证，但理由应是明确承担不确定性。</p></details>
    </section>
  </div>
</div>

**项目判断：** Match 后聊天质量是投入线索，零使用分布指向首次使用空间。与同事、业务对齐主分母后，再评估这项策略能否让完整目标人群多产生深聊。

<script>
  if (window.matchMedia('(max-width: 640px)').matches) {
    document.getElementById('great-step-0').checked = true;
  }
</script>
