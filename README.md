# 再谈线性回归模型——基于研究设计视角

组会报告 slides 及配套代码。

## 背景

2025 年 12 月 1 日，我和导师王倩老师一起在线听了张子尧的讲座[《再谈线性回归模型——基于研究设计视角》](https://mp.weixin.qq.com/s/6pNB_hj3JCK9ehQFXRZCBQ)。那次讲座对我们师徒二人而言都是颠覆性的——它从因果推断的角度重新审视了控制变量的选择问题，彻底改变了我们对线性回归中"该控制什么、不该控制什么"的理解。

2026 年春季学期开学后，导师想起这件事，让我在 4 月的第一次组会上把这次讲座的核心内容讲给大家。于是我回过头重新学习了讲座对应的论文，并结合 Brady Neal 的因果推断课程中的经典案例，制作了这份 Beamer slides。

## 核心参考文献

- **张子尧 & 黄炜.** (2025). 实证研究中的控制变量选择：原理与原则. *管理世界*, 41(10), 210–234. https://doi.org/10.19744/j.cnki.11-1235/f.2025.0136
- **Brady Neal.** *Introduction to Causal Inference* (YouTube 课程). https://www.youtube.com/playlist?list=PLoazKTcS0RzZ1SUgeOgc6SWt51gfT80N0

## 项目结构

```
.
├── main.tex                          # Beamer 主文件
├── references.bib                    # 参考文献
├── sections/
│   ├── 01_intro.tex                  # 整体逻辑线
│   ├── 02_传统范式.tex                # 传统范式：OVB、FWL 定理
│   ├── 03_基于设计的研究范式.tex       # 潜在结果框架、CIA、分块随机化
│   ├── 04_Simpson's Paradox.tex      # 辛普森悖论与后门调整
│   └── 05_good-bad control.tex       # 好控制变量与坏控制变量分类
├── tables/
│   └── Simpson's Paradox.tex         # COVID-27 列联表
├── scenario1_confounder.do           # Stata 代码：C 为混杂变量
├── scenario2_mediator.do             # Stata 代码：C 为中介变量
└── 控制变量选择_组会讲稿.md            # 完整讲稿（Markdown）
└── 控制变量模拟数据.xlsx              # 张子尧 & 黄炜(2025)论文中例子的计算示例
```

## 内容概要

Slides 围绕一个核心思想展开：**控制变量的本质作用是让观测性数据在局部逼近随机化实验。**

1. **传统范式**——遗漏变量偏误（OVB）公式、多元回归与 FWL 定理，以及传统范式的局限性。
2. **基于设计的研究范式**——潜在结果框架、选择性偏误、条件独立性假设（CIA）与分块随机化实验。
3. **辛普森悖论（Simpson's Paradox）**——以 Brady Neal 的 COVID-27 为例，演示同一数据在不同因果结构下得出完全相反的结论；展示后门调整公式与精确匹配估计量的对应关系；比较线性回归与饱和回归的加权差异。
4. **好控制变量与坏控制变量**——共同原因、代理变量、精度提升变量 vs. 对撞变量、中介变量、结果变量，附因果图总览。

## Stata 代码说明

两个 `.do` 文件使用完全相同的观测数据（N = 2050），复刻了 Brady Neal slides 中 COVID-27 的列联表，分别对应两种因果结构：

| 文件 | 因果结构 | C 的角色 | 应否控制 C |
|---|---|---|---|
| `scenario1_confounder.do` | C → T, C → Y, T → Y | 混杂变量 | ✅ 应该 |
| `scenario2_mediator.do` | T → C → Y, T → Y | 中介变量 | ❌ 不应该 |

代码内容包括：回归对比（`reg Y T` vs `reg Y T C`）、手动计算后门调整公式、分块估计（精确匹配）、以及效应分解（总效应 = 直接效应 + 间接效应）。

## 编译说明

本项目使用 XeLaTeX + Biber 编译。字体路径指向本地字体仓库（`/Users/eamonsuen/Documents/GitHub/latex-chinese-fonts`,克隆自`https://github.com/Haixing-Hu/latex-chinese-fonts`），如需在其他机器上编译，请修改 `main.tex` 中的 `\FontRoot` 路径，或将字体文件复制到项目目录下。

```bash
xelatex main.tex
biber main
xelatex main.tex
xelatex main.tex
```

## 作者

**孙翊铭**，吉林大学经济学院，导师：王倩

2026 年 4 月
