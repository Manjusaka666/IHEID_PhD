# 总体判断

这五份新 draft 相比上一版有**实质性进步**，不是简单的措辞修补。最重要的变化有四点：

第一，数学命题的 epistemic status 明显更准确。新的文本开始严格区分 theorem、conditional proposition、numerical property 和 scenario output。例如，Diagnostic 增加了有限网格下基于 Kakutani 的混合策略存在性结果；Trade 改用 Jacobian 与标准 fold nondegeneracy conditions；Narrative 将 primitive hump 与 equilibrium hump 分开；Ambiguity 明确认可 observational equivalence；Sanctions 将 maximal discretion 降格为 fixed-belief punishment benchmark。    

第二，calibration 的表述成熟了很多。现在多数未经估计的数值已被明确称为 **reference scenario**，而不再伪装成 structural estimate。

第三，无法获得的数据基本已从必要设计中删除。Sanctions 不再使用 country-level COFER；Trade 明确使用 importer–exporter–HS6 而非不存在的公开 firm–supplier links；Narrative 区分 media coverage 与 latent investor prevalence；Ambiguity 使用公开 holder-sector aggregates 和 historical vintages。

第四，prose 从“雄心很强但过度断言”转向“高度自觉、甚至略显防御”。这是进步，但目前五篇又出现了新的共同问题：**过多元语言式免责声明削弱了论文的推进力**。

我的总体评价是：

> 这五篇现在已经达到“严肃、可讨论、数学上基本自洽的高水平 first draft”标准。它们不再像五份被 headline number 驱动的 proposal，而开始像真正的研究论文。不过，文献定位和 empirical identification 仍落后于理论包装；尤其 Diagnostic 和 Trade 面临直接的 contemporaneous-paper collision。

以下评分只反映当前 draft 的各维度，不代表推进顺序。

| Draft                          | 数学推导 | Calibration | 计量设计 | Prose | 经济学深度 | 创新/前沿 | 趣味性 |
| ------------------------------ | ---: | ----------: | ---: | ----: | ----: | ----: | --: |
| Diagnostic Expectations        |  8.5 |         7.0 |  7.0 |   8.5 |   8.0 |   5.5 | 8.5 |
| Sanctions & Dollar Convenience |  8.0 |         6.5 |  6.0 |   8.0 |   7.5 |   6.5 | 8.0 |
| Endogenous Trade Fragmentation |  8.5 |         6.0 |  6.5 |   8.0 |   8.5 |   6.0 | 9.0 |
| Ambiguity & Rollover Crises    |  8.5 |         5.5 |  6.5 |   8.5 |   8.0 |   7.0 | 8.0 |
| Narrative Contagion            |  8.0 |         5.0 |  5.5 |   8.5 |   7.5 |   7.5 | 9.0 |

---

# I. Diagnostic Expectations and Sovereign Default

## 1. 当前版本的核心改进

这一版解决了上一稿三个最严重的问题：

* 加入了有限网格经济的存在性论证，而不再把 compact self-map 错当作固定点定理；
* 不再把季度 fixed-target 映射机械应用到月度 annual fixed-event forecasts，而是模拟真实 survey timing；
* 将五年期债券、coupon、resale price 和 SMM criterion 纳入主要 quantitative implementation。

尤其是 Proposition 1 的处理是正确方向。作者承认 deterministic policy discontinuity，转而在 mixed stationary policies 上使用 Kakutani，并另外报告从 zero、risk-free 和 rational initial price schedules 出发的收敛审计。这比许多已发表 quantitative papers 对存在性和数值选择的处理更严谨。

## 2. 数学模型与推导

### 已经做得好的部分

Gaussian diagnostic tilt、FOSD ordering、debt monotonicity 和 conditional price monotonicity 的逻辑清晰。严格性条件现在被准确写成 repayment indicator 在正测度集合上发生变化，而不是笼统声称所有 interior points 都严格单调。

Forecast mapping 的处理也明显成熟。季度解析式被保留为 benchmark，而真正的 inversion 由月度模拟完成。模拟在 (\theta=0.5) 时得到 (-0.282)，并能数值恢复输入参数。这是非常好的 model-to-measurement discipline。

### 仍需解决的问题

**第一，主理论仍是短债模型，而主 quantitative model 是长债模型。**

在一时期债务下：

[
q(b',x,h)
=========

R^{-1}\widehat{\mathbb E}_{\theta}
[1-d(b',x',x)]
]

使 price monotonicity 很直接。但在长期债务中，价格还依赖：

[
q(b'',x',x),
]

即未来 resale price、未来 issuance 和 dilution。短债的 expected-return sign 和 history-dependent default-set theorem 不会自动逐字继承到长债模型。

当前文本说 long debt “does not change the conditional news restriction”，对 rational zero 是成立的：(\theta=0) 时 (h) 应退出价格状态。但对 (\theta>0) 下的单调性、strictness 和 excess-return sign，目前主要是 numerical result，而不是已证明 theorem。正文必须明确区分：

* exact theorem：short bond；
* structural zero under rational pricing：long bond；
* numerical monotonicity and return sign：long-bond calibration。

**第二，monotone default in income 仍是 load-bearing assumption。**

数值验证做得很好，但仍不能替代 theorem。比较合理的做法不是强行证明一般 persistent-income 模型，而是增加一个 restricted sufficient-condition result，例如 i.i.d. income 或特定 default cost 下的 monotonicity。否则三个主要命题在 seminar 中仍会被概括为“conditional on the thing you need”。

**第三，temporary equilibrium 的经济基础仍然偏弱。**

所有 marginal lenders 都使用相同 diagnostic belief，而 rational arbitrage capital 仅用文字中的 limited arbitrage 解释。这个假设在 first draft 可以接受，但顶级 seminar 会问：

[
\text{为什么理性资本不能改变边际价格？}
]

可行的简化扩展是加入一类有资本约束的 rational intermediaries，检验 price effect 是否随着其 wealth share 连续衰减，而非要求完整 intermediary model。

## 3. Calibration 与 quantitative implementation

长债模型是重大改进。论文现在使用 Chatterjee–Eyigungor 式随机到期债务，固定平均期限，并把 ((\beta,d_0,d_1)) 联合匹配到 debt、spread 和 volatility moments；default frequency、debt service 和 spread cyclicality 作为 overidentifying moments，return predictability 作为 untargeted validation。

但目前 quantitative section 仍有一个明显完成度问题：Table 3 的 long-duration mechanism experiment 存在若干空缺 moment。比如显示了 (\theta=0) 和 (\theta=0.5) 的 median spread，却没有完整、平行地报告 spread standard deviation、debt 和 default 等所有列。这会使读者怀疑长债结果是否尚未完全跑完或表格生成存在问题。

此外，三个 calibrated parameters 与六个 moments 的 criterion 使用简单 diagonal weights：

[
W_{jj}=\max{|m_j^{data}|,0.01}^{-2}.
]

这可以作为 first draft，但最终至少应报告：

* alternative weighting matrices；
* moment Jacobian；
* local identification rank；
* parameter confidence intervals；
* model fit under (\theta=0) 与 forecast-estimated (\theta)；
* untargeted return moments 的 sampling uncertainty。

## 4. 计量模型设计

### Forecast block

leave-one-out mean revision 作为 individual revision 的 instrument，不一定满足排除限制。其他 forecasters 的 revision 反映共同新闻，而共同新闻也决定最终 realization，因此可能直接进入 forecast error。

更可信的设计应把 instrument 限定为：

* 对同一公开 release 的 heterogeneous loading；
* forecaster-specific historical responsiveness；
* release surprise 与预定暴露度的交互；
* 或使用 errors-in-variables correction，而不是把 common revision 当作自然外生变量。

此外，country-level (\widehat\theta_i) 会非常噪声。第二阶段 spread coefficient 与 (\widehat\theta_i) 的交互必须处理 generated-regressor uncertainty，最好使用 hierarchical estimation 或 split-sample construction。

### Spread block

within-cell rational zero 是漂亮的模型 restriction，但不是一般理性模型的零限制。现实价格还依赖 reserves、commodity exposure、政治风险、maturity wall、global risk 和 permanent-growth beliefs。论文已经加入 commodity terms、fiscal revisions、ratings 与 flexible cells，这是正确改进。

真正最有辨识力的仍是 **future excess returns**，而不是 contemporaneous spreads：

[
RX_{i,t+h}
==========

\alpha_i+\tau_t+
\beta Rev_{it}
+\Gamma X_{it}+\varepsilon_{it+h}.
]

若好消息后价格高但未来 realized returns 低，这更接近过度反应的核心含义。论文已有理论和长债 return calculation，应将该检验从 supporting prediction 提升为核心结果。

## 5. Prose

英文专业性很高，叙事清楚，intro 能迅速把读者带入经济问题。但有三个问题：

1. “changes one primitive and nothing else” 已不再准确。论文包含长债、measurement simulation 和政策信念组合，远不只是改变一个 primitive。
2. “three years of ordinary macroeconomic news are too thin a basis” 是修辞判断，不是可验证的经济陈述。
3. 引言过长且结果过多。理论、measurement、两套 quantitative exercises、empirics 和 fiscal rules 全部在前四页展开，容易让核心贡献失焦。

## 6. 创新性与前沿性：当前最大问题

这里存在一个必须立即解决的直接重叠。Niemann 和 Prein 的 **Sovereign Risk under Diagnostic Expectations** 已经将 diagnostic expectations 放入长期主权债务模型，使用 IMF growth forecasts 提供行为证据，匹配 sovereign spreads/default moments，并研究 debt-brake 和 spread-brake fiscal rules。

这意味着当前论文不能再把下列内容作为总体 novelty：

* diagnostic expectations in sovereign default；
* long-term sovereign debt；
* growth-forecast evidence；
* fiscal rules under diagnostic beliefs。

当前真正可能独立成立的贡献是：

1. 一个清楚的 one-state history-dependence theorem；
2. exact/simulated forecast-revision-to-(\theta) mapping；
3. conditional-news zero restriction；
4. sovereign bond return predictability；
5. market beliefs 与 government beliefs 的完整 (2\times2) welfare decomposition。

这些差异足以构成论文，但前提是 intro 必须在第一页直接讨论 Niemann–Prein，而不能继续只与一般 sovereign-default literature 比较。Diagnostic expectations 的宏观信用周期机制本身也已进入 2026 年 AER 前沿，因此本文必须把 sovereign-specific identification，而非 general credit-cycle mechanism，作为中心。([American Economic Association][1])

### 严格结论

数学完成度很高，quantitative route 已经成形，prose 也接近成熟论文。但 literature positioning 当前存在严重缺口。若不处理直接同题论文，技术上的进步无法转化为 novelty。

**置信度：90%。**

---

# II. Sanctions Risk and Dollar Convenience

## 1. 当前版本的核心改进

这一版是五篇中 conceptually “去过度声称”最成功的一篇。

它已经：

* 加入 heterogeneous (\kappa_i,\lambda_i,\chi_i)；
* 承认 homogeneous cancellation 不是 raw cross-country identification theorem；
* 加入 crisis-liquidity multiplier；
* 加入 issuer capture share (\zeta_H)；
* 把 local approximation 与 global routine-use scenario 分开；
* 将 maximal discretion 明确称作 fixed-belief punishment allocation；
* 不再把 geopolitical stakes 当成估计值，而是反演 required benefit threshold。

这些变化使模型从一篇过于干净的 LQ policy note，变成了一篇更认真对待 measurement 与 policy interpretation 的 international finance draft。

## 2. 数学模型

局部异质模型的表达是正确且有用的：

[
\frac{dN}{d\bar s}
==================

-\frac{A_z}{1-\ell_1A_\lambda}.
]

它清楚说明直接 exposure、portfolio curvature 和 network loading 如何共同决定 aggregate response。

固定信念 Ramsey 结果的 closed form 也基本清楚。加入 (\zeta_H) 后，issuer 只取得部分 convenience benefit，避免了把全部全球流动性服务机械算成美国财政收益。

### 仍需解决的问题

**第一，动态模型与异质静态模型没有真正统一。**

静态主模型允许 (\kappa_i,\lambda_i,\nu_i,\chi_i) 异质，但 saddle-path theorem 又回到 homogeneous ((\kappa,\nu))。实证部分估计的是异质 direct semi-elasticity，动态 half-life 却来自代表性 reserve manager。两部分目前属于相邻模型，不是统一模型。

不需要强求解析异质 saddle path，但至少应给出线性化矩阵：

[
\mathbf a_{t+1}
===============

A\mathbf a_t+B\widehat{\boldsymbol \pi}_t,
]

并说明 aggregate persistence 何时仍大于 cross-sectional gap persistence。

**第二，global scenario 仍有任意性。**

logistic convenience function 与 cubic marginal portfolio cost 被选择为匹配当前 equilibrium level 和 local derivatives：

[
\ell^g(N_0)=\ell(N_0),\qquad
\ell^{g\prime}(N_0)=\ell_1,\qquad
C''(N_0)=\kappa.
]

但无限多组 global functions 都能满足相同 local matching，却给出完全不同的 (N=0.23) counterfactual 和 sanctions-use threshold。

因此 routine-use section 不能只比较 parameter values，还必须比较 **functional-form classes**：

* logistic；
* CES-type bounded convenience；
* concave power function；
* alternative convex cost curvature。

否则 5.5% crossing 是某一 global closure 的属性，不是由 local evidence推出的结果。

**第三，reputation block 目前更像 notation than solved model。**

递归式

[
V(r,N,x)=\max_s{\cdots}
]

是正确方向，但 (B(r,s,x)) 没有结构化，trigger strategy 也只是一个 enforcement illustration。应避免让读者以为 reputation state 已经被定量求解。

## 3. Calibration

“threshold inversion rather than welfare estimate” 是很好的处理。现在：

[
\gamma^*(p,\phi,\mu,m,\zeta_H,\chi)
]

比一个貌似精确的 optimal sanctions number 更有政策意义。

但 (\kappa=73bp/0.59) 仍强烈依赖：

* (\bar r=0)；
* homogeneous benchmark；
* 73bp 完全等于 central-bank reserve convenience；
* 当前 share 是 interior optimum。

它应被称为 model-implied curvature，而当前 draft 已经这样做，这是正确的。

最需要估计的其实不是 (\gamma)，而是：

[
A_z,\quad A_\lambda,\quad \nu,\quad \zeta_H,\quad\chi.
]

若这些对象没有数据约束，sanctions frontier 仍主要是 scenario geometry。

## 4. 计量设计与数据可得性

数据可得性现在基本合格。COFER 只用于 aggregate series；IMF 明确规定 individual-country COFER submissions 严格保密，因此删除 country-level COFER 是必要且正确的。([IMF Data][2])

TIC 是可用的公开 country-level alternative，但美国财政部明确说明其 geographic attribution 基于 custody，不能完整识别 ultimate beneficial owner。当前 draft 已意识到 custody centres 问题并计划单独处理，这是正确的。([U.S. Department of the Treasury][3])

### 核心识别困难仍未解决

1. **TIC/reserves 不是 dollar reserve share。**
   它只观察美国证券持有，且 official/private separation 并非所有表格、所有时期都同样充分。

2. **2022 不是单一 sanctions shock。**
   它同时包含战争、Fed tightening、美元升值、商品冲击、避险需求和黄金购买。

3. **network multiplier 很难从 aggregate time series 中识别。**
   COFER、convenience yield 和 aligned-country holdings 的 joint system 比单回归好，但这些变量仍受到共同全球冲击。

4. **exposure index 的多维加权存在 researcher degrees of freedom。**
   Alignment、prior sanctions、reserve adequacy、dollar debt 和 invoicing 应分别进入，而不是先合成一个不透明 index。

比较可信的 empirical outcome 不是精确点估计 (m)，而是：

* direct response 的区间；
* aligned response 是否显著非零；
* network multiplier 的 identified set；
* 在不同 (\chi,\zeta_H) 下的 policy threshold set。

## 5. Prose

语言专业、稳健，明显不再夸大。问题是 abstract 过于拥挤：

* heterogeneous costs；
* fixed-belief discretion；
* reputation；
* local/global split；
* (\zeta_H)；
* crisis liquidity；
* three thresholds。

一个 abstract 同时解释八个防御性修正，会削弱核心直觉。更好的 abstract 应只保留：

1. sanctions wedge；
2. network amplification；
3. rule-versus-discretion；
4. threshold—not estimate。

正文中“not X, but Y”式句子过多。它们是有用的 referee defence，但重复出现会让论文像对审稿意见的逐条答复，而不是自然推进的研究论证。

## 6. 创新性与前沿性

Bianchi 和 Sosa-Padilla 已经证明 anticipatory sanctions 会降低 dollar convenience yield 和 dollar asset holdings，并研究 welfare；该工作已发表于 *Economic Journal*。([NBER][4])

当前论文已正确承认 sanctions wedge 不是 novelty。真正的增量是：

* policy rule endogenously determines wedge；
* wedge changes network；
* network changes value of future policy；
* local micro response 与 aggregate network effect 的区分；
* issuer capture 和 crisis-state liquidity 的 policy threshold。

这一定位是可成立的。问题是 rule block 需要比当前 trigger illustration 更深，否则主要贡献仍可能被评价为“在已有 wedge 上加一个 reduced-form policymaker”。

### 严格结论

这是一篇有政策价值、结构清楚的 theory-plus-measurement draft。最大风险已不再是数据根本不可得，而是 aggregate network multiplier 实际不可精确识别，以及 global routine-use results 依赖任意 closure。

**置信度：90%。**

---

# III. Endogenous Trade Fragmentation

## 1. 当前版本的核心改进

这篇的数学修订最明显。

现在正确地把 equilibrium response 写成：

[
\frac{d\mathbf F^*}{dz}
=======================

(I-J)^{-1}b_z,
]

并用 spectral radius (\varrho(J)<1) 表示局部稳定，而不再把多部门问题错误压缩成统一 scalar multiplier。

Fold theorem 也已改用标准条件：

[
R=0,\quad R_F=0,\quad R_{FF}\neq0,\quad R_\delta\neq0.
]

并明确承认 max slope (>1) 并不足以证明 fold。

此外，temporary shock 的 permanent outcome 被准确限定为 partial-adjustment dynamics 下 crossing the unstable branch，而非一般 forward-looking equilibrium theorem。政策结果也从“friend-shoring subsidy is wrong”改为：

[
v_m<\tau_m^*(F),
]

即独立供应的社会价值低于 deterrence externality 时，maintenance subsidy 才是正确工具。

这是非常实质性的进步。

## 2. 数学模型

### 优点

一般 benefit distribution 下：

[
\pi_m(F_m,F)
============

\delta_m[1-G_m(C_m(F_m,F))]+\eta_aF
]

清楚表明 uniform distribution 只用于 affine calibration，而非 strategic complementarity 的必要条件。

Jacobian inverse 的非负性在 (J\ge0) 且 (\varrho(J)<1) 下由 Neumann series 得到，理论上干净。reference scenario 报告 (\varrho(J)=0.196)，critical-sector total response/direct response 约为 1.24，也使 scalar approximation 的误差被量化。

### 仍需解决的问题

**第一，stationary threshold lemma 与 transition dynamics 之间仍存在张力。**

“forward-looking and myopic thresholds coincide”仅在 stationary environment、switching absorbing 且未来 premium path 不变时成立。但模型最有趣的区域正是：

* (F_t) 快速变化；
* friendly capacity 降低未来 premium；
* hazard 内生变化；
* 接近 fold。

此时 option value 很可能不是“小修正”。Appendix 目前给出定性讨论，但最终需要数值比较：

[
F_t^{adaptive}
\quad\text{vs.}\quad
F_t^{perfect\ foresight}.
]

尤其政策可能本身改变预期 branch，若 forward-looking solution 与 adaptive solution 差异很大，hysteresis 和 subsidy counterfactual 都会改变。

**第二，CES disruption loss 可能产生过大的机械非线性。**

当 (\sigma=2,s=0.5) 时，删除该 input variety 使 input price index 翻倍，再乘 1.5 年，得到 (\lambda^0=1.5)。这对“一个关键 input”未必不可能，但它假设：

* cost share 保持为初始 share；
* 零紧急替代；
* CES 在极端 quantity-to-zero 处仍适用；
* 无库存、rationing 或质量变化；
* downstream pass-through 的计量方式正确。

该参数极大地决定 critical sector 的 fold。必须用短期 disruption evidence 而不是一般 trade elasticity 支撑。

**第三，global branch structure 是 numerical property。**

当前 draft 已经诚实承认这一点。但最终应报告 numerical continuation algorithm、root completeness、grid independence 和 fold-location residuals，而不只是图形。

## 3. Calibration

reference scenario 的 epistemic status 现在非常清楚：66% fold distance、6.4% wedge、25% subsidy tipping 都是条件性 phase experiments。

不过 calibration 仍非常脆弱。Fold 是否存在主要依赖：

[
H_m,\quad \theta,\quad \xi,\quad\chi,\quad\lambda_m^0.
]

其中 premium dispersion 从 0.5 升到 0.7 就可以使 fold 消失。说明关键经济结论不是对广泛参数稳健，而是一个需要精确估计 density at the margin 的问题。

最终不能只 bootstrap moments 后给 fold confidence interval；还应报告：

* no-fold probability；
* fold above feasible hazard range 的概率；
* high branch welfare ranking；
* model selection across alternative premium distributions；
* sensitivity to nonparametric (H_m)。

## 4. 计量设计和数据

公开数据路线是可行的。BACI 提供约 200 个国家、HS6 产品层级的 bilateral trade flows；OECD ICIO 提供跨国行业投入产出结构。([CEPII][5])

将 empirical unit 改为 importer–exporter–HS6 relationship 是正确决定。它避免了伪称存在公开 firm–supplier links。

### 仍然最困难的部分

**Deterrence regression 只能识别 dyad-level trade–escalation relation，不能直接识别 sector-specific (\theta_m)。**

[
P(Escalation_{ij,t}=1\mid Dispute_{ij,t}=1)
]

对总贸易 exposure 的响应，不等于某一 HS6 sector 退出对该 sector export-control hazard 的边际影响。当前 draft 已承认没有 product-level chronology 就不声称 sector-specific deterrence，这是正确的；但这也意味着 fold 的最关键 sector-specific parameter 仍未被直接识别。

**Unit-value gap 不是干净的 switching premium。**

它同时反映：

* quality；
* markups；
* transport cost；
* tariff；
* composition；
* selection into suppliers。

Importer-product-year 和 exporter-product fixed effects 有帮助，但不足以消除 endogenous quality choice。

**PortWatch 识别的是 route disruption recovery，不一定是“贸易变薄使地缘政治 disruption loss 更大”。**

PortWatch 可以支持 corridor-thickness mechanism，但外部 maritime disruption 与 export-control disruption 的恢复技术未必相同。

因此 empirical program 是可执行的，但参数的 structural interpretation 仍会有较宽范围。

## 5. Prose

这篇的文字最有记忆点：

* “trade is its own hostage”；
* “defend the bridge, then burn it”。

这些短语有效地传达经济直觉。但使用次数偏多，容易让论文显得由 slogan 驱动。更新版 abstract 更克制，这是好事。

另一个问题是引言仍然写道“existing work treats the risk as exogenous”。这在当前文献前沿下已不准确。

## 6. 创新性与前沿性

2025 年的 *The Fragmentation Paradox* 已经把 diplomacy/escalation game 嵌入 quantitative trade model，并明确得到：decoupling 可能降低 trade opportunity cost，从而削弱 restraint incentives、提高 escalation probability。([CEPII][6])

因此“使 disruption risk endogenous”不能作为本文的总体 novelty。该文甚至与当前 draft 使用了非常接近的安全困境直觉。

当前 draft 真正不同的贡献是：

1. decision unit 是 private firms，而不是国家层面的 trade policy；
2. firms 不 internalize 其 trade links 的 deterrence externality；
3. endogenous sourcing choices 产生 Jacobian amplification；
4. sectoral fold 与 aggregate invisibility；
5. welfare wedge 在低、高 fragmentation branches 上可能换符号；
6. route thickness 与 friendly capacity 加入 deterrence loop。

这些是有实质内容的差异，但必须在 introduction 中直接与 *Fragmentation Paradox* 对照，而不是继续宣称前人均外生化 risk。

### 严格结论

经济机制很深、政策结论有反常识性、数学已大幅修复。当前主要障碍是 direct literature overlap，以及 sector-specific deterrence 参数无法由现有公开数据直接识别。

**置信度：90%。**

---

# IV. Ambiguity, Investor Composition, and Sovereign Rollover Crises

## 1. 当前版本的核心改进

这一版在 intellectual honesty 上处理得最好。

最重要的新增命题不是某个 quantitative number，而是：

> max-min ambiguity 与 Bayesian pessimistic signal bias 在 equilibrium choices 和 prices 上 observationally equivalent。

论文现在明确承认 spreads 不能识别 ambiguity preferences，revision histories 和 forecast data 必须先约束有效 pessimism，再用 market outcomes 检验 coordination mechanism。

此外：

* exit payoff 不再被假设为完全 state-independent；
* holder types 可以有不同 payoff hurdles；
* precision comparative static 与 ex ante welfare 被分开；
* current holder data 与 historical Arslanalp–Tsuda sample 被正确区分；
* 不再用 spread inversion 直接“估计 ambiguity”。

这些都是关键修正。

## 2. 数学模型

### 优点

在：

[
R_k-\underline R_k>Q_k-q_k
]

下，rollover payoff 对 crisis state 更敏感，两个行动的 worst case 都位于最大 pessimistic bias endpoint。因此 as-if shift：

[
y\mapsto y-\delta_k
]

仍成立，并导出：

[
x_k^*-x_{B,k}^*
===============

\frac{\alpha}{\beta}\delta_k.
]

这一推广比 safe-exit benchmark 强得多。

Uniqueness condition 也处理得好。不同 (\delta_k) 平移 cdf arguments，但不改变最大 slope bound：

[
\frac{\alpha}{\sqrt\beta}<\sqrt{2\pi}.
]

Composition derivative 现在正确写成“fragile type run probability 高于 stable type 时为正”，而非无条件声称 foreign/private holdings 必然 destabilising。

### 剩余问题

**第一，标题中的“Ambiguity”仍比模型可识别内容更强。**

既然 Proposition 1 证明所有 equilibrium observables 都可由 heterogeneous Bayesian bias beliefs 复制，经验上最稳妥的论文其实是关于：

> distrust-equivalent pessimism and investor composition。

若继续使用 Ambiguity 作为标题中心，必须有 sovereign-spread equation 之外的证据区分 ambiguity preference 与 biased belief。否则标题会承诺一个论文主动证明自己无法识别的对象。

**第二，(\delta_k) 与 revision quantile 的映射并不充分。**

官方数据最终 revision 的上尾是 realized reporting error distribution；(\delta_k) 是投资者主观 model set 的半径。二者并不相等：

[
\delta_k
\neq
Q_{0.95}(\text{historical revision})
]

除非进一步假定投资者用该 quantile 构造 worst-case set。该假设需要 survey、实验或机构证据，而不是只靠历史数据。

**第三，ex ante welfare block 目前只是正确的 accounting identity。**

[
W(\alpha)
=========

-\int L(\theta)
1{\theta\le\theta^*(y,\alpha)}
f_\alpha(y\mid\theta),dy,dF(\theta)
-C(\alpha).
]

它成功说明 conditional sign 不是 welfare result，但没有进一步给出任何一般 sufficient condition。因此正文可以更简短，不应把这个 section 写成完成的 welfare analysis。

## 3. Calibration

这一版正确称 18bp 和 98bp 为 **ambiguity-equivalent scenario increments**，不是 ambiguity premium estimates。

这一区分非常重要，因为同样数值可以由 Bayesian pessimistic biases 产生。

Calibration 的弱点仍是信息 block：

[
\sigma_x=0.15,\quad
\sigma_y=0.33,\quad
\delta=0.08,\quad
\mu=0.40
]

目前都是 scenario targets。模型能够展示 state dependence，但还不能回答“经济量级是否现实”。

尤其 coordination multiplier 2.1 来自 normal density 在 cutoff 的位置；只要 news level 或 signal precision 稍变，multiplier 可以显著变化。应报告 multiplier distribution，而不是一个固定 calibration number。

## 4. 计量设计

WEO historical forecasts 是真实可用的公开 vintage archive；ECB SHSS 也提供按 holder sector、holder country 和 instrument 分类的 security holdings。([IMF Data][7])

因此数据访问原则上可行。

### 但 identification 仍有三个难点

**1. Cross-sectional forecast dispersion 不等于 private-signal variance。**

它还包含：

* forecaster model heterogeneity；
* sticky information；
* differential loss functions；
* strategic rounding；
* different target definitions。

因此从 residual variance 直接得到 (\sigma_x^2) 需要一个显式 measurement model。

**2. “Fragile share”不是 observable category。**

ECB SHSS 提供 holder sectors，但 sector label 不等于 live run margin。Domestic banks 可能被监管约束稳定持有，也可能受 liquidity、capital 和 doom-loop forces 驱动快速抛售。Foreign nonbanks 也不一定全部 fragile。

更合理的是估计 type-specific payoff hurdle，而不是事前把 sectors 二分。

**3. Institutional reform timing 很难因果解释。**

当前 draft 已明确承认 SDDS、fiscal councils、Article IV timing 是选择性的。这种诚实是优点，但也意味着 event studies 多数只能作为 descriptive validation，而不能识别 credibility causal effect。

最可能的 empirical payoff 是检验三重交互：

[
D_{it}\times\mu_{it}\times Stress_{it},
]

而不是精确恢复 (\delta_i)。

## 5. Prose

这是五篇中最“referee-proof”的 prose：

* 用词准确；
* 每项定量结论都注明 scenario；
* 识别极限在摘要中就说明；
* conditional threshold 和 welfare ranking 被清楚分开。

问题是它现在略显过于冷静和抽象。标题、摘要和引言都以 identification caveat 为主，经济故事的冲击力下降。

建议把开头重心放回：

> 同一份官方财政报告，由不同 investor bases 持有债务时，会产生不同 rollover threshold。

然后再引入 ambiguity equivalence，而不是让 identification limit 成为摘要的主旋律。

## 6. 创新性与前沿性

Ui 的 *Strategic Ambiguity in Global Games* 已研究 ambiguous-quality information 对 debt rollover crises 的影响，并证明在 rollover setting 中 ambiguity 会提高危机概率。

因此本文的 novelty 不是“ambiguity in a rollover global game”。真正增量是：

* heterogeneous effective pessimism；
* investor composition；
* type-specific payoff hurdles；
* unique threshold comparative statics；
* precision versus credibility；
* observational equivalence 与相应 empirical sequence。

这是一组相对清楚、可以成立的理论贡献。尤其 observational equivalence 不是缺点；若写得好，它本身是一个有价值的 negative identification result。

### 严格结论

理论现在相当扎实，prose 专业，innovation positioning 也比之前诚实。最大风险是 empirical proxy (\delta) 仍不能真正代表 subjective ambiguity set，且 holder composition 与 run propensity 的对应关系需要估计而不是分类。

**置信度：90%。**

---

# V. Narrative Contagion at the Sovereign Default Boundary

## 1. 当前版本的核心改进

这一版修正了上一稿几乎所有明显的数学过度声称：

* primitive hump 是 theorem；
* equilibrium hump 需要 derivative condition；
* bounded multiplier 本身不保证 single peak；
* epidemic dynamics 改为 continuous time；
* annual-to-monthly mapping 显式给出；
* zero-drift root 不再被称为 global basin boundary；
* 增加 phase diagram；
* media coverage 不再被直接当作 investor wealth prevalence；
* OMT 被称为 compound intervention，而非纯 communication experiment。

这是非常明显的质量提升。

## 2. 数学模型

### 优点

Primitive theorem 很干净：

[
G(z)=\Phi(z+\Delta)-\Phi(z)
]

在 (z=-\Delta/2) 有唯一峰值，且两端趋零。这是论文真正坚固、一般化潜力最大的结果。

Equilibrium effect：

[
\frac{\partial s^*}{\partial n}
===============================

(1-R)G(z^*)M(\theta,n)
]

现在由 (Q_z<0) 的 sufficient condition 保证 single peak，并报告 scenario grid 上最大 (Q_z=-0.474)。这种处理是合格的：理论条件与数值验证被清楚区分。

Continuous-time prevalence：

[
\dot n
======

\beta(\theta,n)n(1-n)-\gamma n
]

也比原来的 monthly Euler equation 更自然，并自动保持 (n\in[0,1])。

### 仍需解决的问题

**第一，costly attention 只 microfound 了 attention/adoption decision，没有 microfound false-belief acceptance。**

投资者可以认为某个故事值得研究、传播或交易，但仍不相信它。因此至少需要区分：

[
a_t=\text{aware/attentive share},
\qquad
n_t=\text{believing share}.
]

当前 (H_c(\lambda|\partial s/\partial n|)) 把 attention、transmission 和 belief adoption 合并为一个动作。它比纯 reduced form 更好，但还不是完整 behavioral foundation。

**第二，债券定价过于简化。**

[
s=(1-R)\bar p
]

忽略：

* discounting；
* maturity；
* coupon；
* duration；
* risk premium；
* time-varying recovery；
* liquidity premium。

当模型产生 3,000–4,000bp spread 时，这种 expected-loss approximation 可能明显失真。它作为理论 reduced form 可以，但 quantitative headline 不应被解释成 actual EMBI spread prediction。

至少应改成 hazard-rate pricing：

[
s \simeq \lambda^Q(1-R)+LP+RP,
]

并说明 narrative 影响的是哪一部分。

**第三，global seeded-default result 仍是 scenario exhibit。**

论文现在已正确承认这一点。Figure 4 的 phase field 是很好的改进，但最终应报告：

* invariant-region verification；
* nullcline intersections；
* local stability eigenvalues；
* seed threshold；
* basin boundary 的 numerical continuation。

## 3. Calibration

当前 calibration 极其诚实：除 recovery 外，所有主要参数均标为 scenario。

但这也意味着 230bp、5.3pp 和 month 39 都没有经验识别。最关键的参数：

[
\xi,\quad\gamma,\quad R_0^{peak},\quad n_0,\quad\chi
]

共同决定全部 headline outcomes。

特别是 (\chi\in[0.1,0.3]) 时，loop gain 从温和水平升至 0.96，peak price relevance 从 124bp 上升至 1,931bp。这不是普通 sensitivity，而是模型接近 bifurcation 的表现。靠近 1 的结果应被单独标为 boundary cases，不应与稳定 interior scenarios 平均讨论；当前文本已经开始这样做，是正确方向。

## 4. 计量模型与测量

GDELT 作为公开 media core、Factiva/LexisNexis 作为 licensed validation，是可执行路线。Narrative measurement 采用：

[
TextIndex_{it}=a_i+\lambda_i n_{it}+e_{it}
]

而非直接把报道份额当 wealth-weighted belief prevalence，这是重要改进。

现代 narrative-macro 文献已经构建了 contagious narratives 的理论、经验与数量框架，因此本文的测量必须在 sovereign-specific identification 上更加精确。

### 仍然最困难的识别问题

**1. 单一 measurement equation 下 latent (n_t) 并不识别。**

若只有一个 TextIndex，(\lambda_i n_t) 的 scale 任意。需要：

* 多个独立 text indicators；
* survey beliefs；
* analyst reports；
* search data；
* 或规范化 (\lambda_i=1)。

否则不能把 estimated state 转换成“10 percentage points of investor prevalence”。

**2. Boundary proxy 是 generated regressor。**

[
B_{it}
======

\widehat{
\partial s_{it}/\partial FundamentalSurprise_{it}
}
]

由历史窗口估计，可能非常噪声。若 (f_h(B)) 用 splines 拟合，measurement error 会把 hump 扁平化，并可能制造 regression-to-the-mean patterns。需要 sample splitting、empirical Bayes shrinkage 和 bootstrap over first-stage estimation。

**3. Residual narrative take-up 仍然内生。**

即使控制 scheduled release surprise，release 后的媒体扩散也可能响应：

* 政治评论；
* policy response；
* market price movement；
* 同时发布的 fiscal details。

当前 draft 已承认 release design 不产生 random exposure。最终因果 claim 必须克制。

**4. OMT 不能验证“cap kills narrative”这一单一机制。**

OMT 改变 redenomination insurance、conditional policy support、tail risk 和 equilibrium regime。把它作为 descriptive case study 是合适的；不能把 narrative decline 解释成 adoption function 的结构识别。

## 5. Prose

这篇的 prose 最有吸引力，开场、经济直觉和图形叙述都很强。更新版避免了上一稿中一些过度文学化表述，但仍保留了可读性。

需要警惕两个倾向：

1. “portable pessimistic claim”“where stories kill”等表达若过多，会让严肃计量问题被文学性遮蔽。
2. 每隔一段加入“this is a scenario, not an estimate”“not a basin boundary”“not a pure experiment”，虽然正确，但阅读节奏过于防御。

可以把 epistemic classification 集中放入一个 subsection 或 boxed note，而不是在全文不断重复。

## 6. 创新性与前沿性

Flynn 与 Sastry 已经建立 contagious narratives、epidemiological feedback 和 unique-equilibrium macro fluctuations 的理论—经验—数量框架。([NBER][8])

本文真正的新贡献是：

* sovereign default boundary 赋予 narrative price relevance 一个 hump restriction；
* boundary sensitivity 同时决定 price effect 和 diffusion incentive；
* debt-service feedback 把 narrative tax 转为 real default risk；
* text prevalence 必须与 boundary proximity 交互；
* policy cap 影响 narrative relevance，而不只是 carriers。

这是一个真实且有趣的组合。相比其他四篇，它的 originality 不主要受 direct-paper collision 限制，而主要受 measurement credibility 限制。

### 严格结论

理论骨架现在已经相当专业，prose 很强，研究问题有高度趣味性。但它仍是五篇中 measurement 和 causal identification 风险最大的项目。当前 quantitative numbers 应继续被严格视为 scenario outputs。

**置信度：90%。**

---

# 六个跨论文问题

## 1. 五篇的数学严谨性已经显著提高，但仍不能让“数学防御”压过经济模型

新版本大量加入：

* exact/conditional/scenario distinctions；
* nondegeneracy conditions；
* fixed-point audits；
* observational-equivalence caveats；
* data-feasibility qualifications。

这些都正确。但 top economics paper 不是数学审计报告。最终正文必须让读者先记住经济机制，再理解 theorem scope。

## 2. 五篇的 prose 过度同质化

几乎每篇都采用同一修辞结构：

1. 一个醒目的现实事件；
2. “The question of this paper is…”；
3. 一个新 state；
4. 一个 multiplier；
5. 一个 identification warning；
6. 一个 policy sign reversal；
7. “These are scenarios, not estimates.”

单独看每篇很专业；五篇放在一起，会产生模板化、机器优化式写作的观感。应让每篇形成独立 voice：

* Diagnostic：forecast measurement 与 sovereign return；
* Sanctions：policy rule；
* Trade：strategic sourcing externality；
* Ambiguity：information credibility × holder composition；
* Narrative：boundary-dependent diffusion。

## 3. Calibration 分类已基本正确，下一步是 sampling uncertainty

目前主要解决了“不要把 scenario 叫 estimate”。下一步不能停留在 sensitivity grid，而应进入：

[
\widehat\Theta
\rightarrow
\text{sampling distribution}
\rightarrow
\text{distribution of model outputs}.
]

特别是：

* Diagnostic：return and crisis-hazard uncertainty；
* Sanctions：identified set for (m)；
* Trade：probability of no fold；
* Ambiguity：distribution of effective pessimism；
* Narrative：uncertainty in latent prevalence and (R_0)。

## 4. 数据“可获得”不等于变量“被观察”

五篇目前基本避免了不可获得数据，但仍存在 proxy-to-primitive gaps：

* TIC holdings (\neq) reserve-currency share；
* unit-value gap (\neq) switching premium；
* sector label (\neq) run propensity；
* media coverage (\neq) investor prevalence；
* historical revisions (\neq) subjective ambiguity radius；
* forecast revision (\neq) pure diagnostic news。

这些不是普通 measurement error，而是 identification 的中心内容。

## 5. Direct literature collisions 必须在正文主动处理

最严重的是：

* Diagnostic 对 Niemann–Prein；
* Trade 对 *The Fragmentation Paradox*；
* Sanctions 对 Bianchi–Sosa-Padilla；
* Ambiguity 对 Ui；
* Narrative 对 Flynn–Sastry。

其中前两篇如果不在 introduction 前三页明确比较，会被 referee 认为 novelty review 不完整。相关已有工作已分别覆盖长期主权债务中的 diagnostic expectations、内生 trade–conflict escalation、sanctions 与 dollar convenience、ambiguity global games，以及 contagious macro narratives。

## 6. 当前五篇已具备真正 first-draft 水准，但 empirical sections 仍主要是 design

这不是缺点本身。First draft 可以尚未完成实证。但必须保持文本一致：

* 尚未跑出的 regression 不应使用结果式语气；
* 尚未估计的 parameter 不应进入标题式政策结论；
* calibration figures 应持续标为 phase diagrams 或 scenario arithmetic；
* 数据可得性、变量可测量性与因果识别应分开陈述。


[1]: https://www.aeaweb.org/articles?id=10.1257%2Faer.20211820&utm_source=chatgpt.com "Real Credit Cycles"
[2]: https://data.imf.org/en/news/october%201%202025%20cofer?utm_source=chatgpt.com "Currency Composition of Official Foreign Exchange Reserves"
[3]: https://home.treasury.gov/news/press-releases/sb0499?utm_source=chatgpt.com "Treasury International Capital Data for March"
[4]: https://www.nber.org/system/files/working_papers/w31024/w31024.pdf?utm_source=chatgpt.com "Javier Bianchi César Sosa-Padilla Working Paper 31024"
[5]: https://www.cepii.fr/CEPII/en/bdd_modele/bdd_modele_item.asp?id=37&utm_source=chatgpt.com "CEPII - BACI"
[6]: https://www.cepii.fr/PDF_PUB/wp/2025/wp2025-23.pdf "The Fragmentation Paradox: De-risking Trade and Global Safe"
[7]: https://data.imf.org/en/datasets/IMF.RES%3AWEO?utm_source=chatgpt.com "WEO - IMF Data - International Monetary Fund"
[8]: https://www.nber.org/system/files/working_papers/w32602/w32602.pdf?utm_source=chatgpt.com "The Macroeconomics of Narratives Joel P. Flynn Karthik ..."
