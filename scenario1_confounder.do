/*==============================================================================
  Scenario 1: C is a CONFOUNDER (C→T, C→Y, T→Y)
  
  COVID-27 Example from Brady Neal's Slides
  
  因果图: C → T, C → Y, T → Y
  C (病情严重程度) 同时影响 T (治疗选择) 和 Y (死亡)
  C 是混杂变量，应该控制
  
  数据复刻slides中的列联表：
  Treatment A (T=0): Mild: 210/1400 dead, Severe: 30/100 dead
  Treatment B (T=1): Mild: 5/50 dead,    Severe: 100/500 dead
==============================================================================*/

qui {
clear all
set seed 12345

* --- 构造个体数据 (N=2050) ---
set obs 2050
gen id = _n

gen T = (id > 1500)                                    // Treatment: 0=A, 1=B
gen C = (id >= 1401 & id <= 1500) | (id >= 1551)       // Condition: 0=Mild, 1=Severe
gen Y = 0                                               // Outcome: 0=alive, 1=dead

replace Y = 1 if id <= 210                              // A, Mild: 210/1400
replace Y = 1 if id >= 1401 & id <= 1430                // A, Severe: 30/100
replace Y = 1 if id >= 1501 & id <= 1505                // B, Mild: 5/50
replace Y = 1 if id >= 1551 & id <= 1650                // B, Severe: 100/500
}


* === 验证列联表 ===
tab T C
tab Y T, row
tab Y T if C==0, row
tab Y T if C==1, row


* === 回归 (1): 不控制C — 朴素比较，对应 E[Y|T] ===
reg Y T

* === 回归 (2): 控制C — 消除混杂偏误，对应 E[Y|do(T)] ===
reg Y T C


* === 手动计算后门调整公式 ===
* E[Y|do(T=t)] = Σ_c E[Y|T=t,C=c] × P(C=c)

qui {
	* 各层条件死亡率
	sum Y if T==0 & C==0
	local ya_mild = r(mean)
	sum Y if T==0 & C==1
	local ya_severe = r(mean)
	sum Y if T==1 & C==0
	local yb_mild = r(mean)
	sum Y if T==1 & C==1
	local yb_severe = r(mean)

	* 总体各层比例
	sum C
	local p_severe = r(mean)
	local p_mild = 1 - r(mean)

	* 后门调整
	local causal_A = `ya_mild' * `p_mild' + `ya_severe' * `p_severe'
	local causal_B = `yb_mild' * `p_mild' + `yb_severe' * `p_severe'
	local causal_effect = `causal_B' - `causal_A'
}

di "E[Y|do(T=A)] = " %6.4f `causal_A'       // 19.4%
di "E[Y|do(T=B)] = " %6.4f `causal_B'       // 12.9%
di "因果效应 = "      %6.4f `causal_effect'   // -0.065, 选B


* === 分块估计（精确匹配估计量）===
reg Y T if C==0    // τ(Mild) = -0.05
reg Y T if C==1    // τ(Severe) = -0.10

qui {
	local tau_mild = _b[T]
	// 需要重新跑一次Mild的回归取系数，这里简化处理
	reg Y T if C==0
	local tau_mild = _b[T]
	reg Y T if C==1
	local tau_severe = _b[T]
	local ate_matching = `tau_mild' * `p_mild' + `tau_severe' * `p_severe'
}

di "精确匹配ATE = " %6.4f `ate_matching'     // 与后门调整一致: -0.065
