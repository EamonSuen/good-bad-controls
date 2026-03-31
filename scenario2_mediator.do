/*==============================================================================
  Scenario 2: C is a MEDIATOR (T→C→Y, T→Y)
  
  COVID-27 Example from Brady Neal's Slides
  
  因果图: T → C → Y, T → Y
  T (治疗选择) 影响 C (病情严重程度), C 再影响 Y (死亡)
  C 是中介变量，不应该控制
  
  关键区别：T是外生随机分配的！
  C 在两组中分布不同，是因为T对C有因果效应（如B的副作用加重病情）
  
  观测到的列联表与Scenario 1完全相同，但因果结构不同。
==============================================================================*/

qui {
clear all
set seed 12345

* --- 构造与Scenario 1完全相同的观测数据 (N=2050) ---
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


* === 验证观测数据与Scenario 1完全相同 ===
tab T C
tab Y T, row


* === 回归 (1): 不控制C — T是随机分配的，直接比较就是因果效应 ===
reg Y T

* === 回归 (2): 错误地控制了中介变量C（"坏控制变量"）===
reg Y T C


* === 因果效应分解: 总效应 = 直接效应 + 间接效应 ===
* 总效应: T → Y (直接) + T → C → Y (间接)

qui {
	reg Y T
	local total_effect = _b[T]

	reg Y T C
	local direct_effect = _b[T]

	local indirect_effect = `total_effect' - `direct_effect'
}

di "总因果效应 (不控制C): " %6.4f `total_effect'     // +0.031, 选A
di "直接效应 (控制C后):   " %6.4f `direct_effect'    // -0.082
di "间接效应 (差值):      " %6.4f `indirect_effect'   // +0.113

* B的直接治疗效果更好，但副作用让病情加重（间接效应为正），
* 导致总效应反而增加死亡率。
* 如果错误地控制了C，只能看到直接效应，从而错误地选择B。
