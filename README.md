# FitnessDataAnalysis

## 数据分析

<a href="https://github.com/vv123infinity/FitnessDataAnalysis/tree/02a159b2b92efd73f0149fe42d767e34d83447ad/FitnessDataAnalysis/DataModels">FitnessDataAnalysis/DataModels</a>存储了数据分析的相关代码。

> 目前，虽然有少数软件可以提供跑步训练计划，或针对跑步者具体情况简单设计运动方案，但仍无法根据跑步运动数据的统计结果，或前后数据的对比结果来智能化地进行分析。
>
> 运动数据分析比较具有挑战性，可能需要大家一起加把油。

**注意，定义需求，实现需求的都是我们自己，也就是说我们需要自己定义输入和输出。🥹在定义好函数的输入&输出后，可以从Kaggle上下载一些相关数据来测试编写的函数。**

### 数据分析的具体任务

1. ***评估运动表现***

> 本APP已经实现基于距离和时间评估运动表现（运动强度），评估方法为简单加权。此分析过于简单，需要优化。

* 选取评估运动表现的指标（比如速度、心率、距离、VO2Max），具体的可以看看相关论文。
  * 比如 https://www.nature.com/articles/s41467-020-18737-6
  * 这篇论文选取了两个指数来描述跑步者的表现，分别是（1）耐力（耐力指数）和（2）要求MAP输出的速度（有氧功率指数）
* 建立模型，构建评估运动表现的方法。



2. ***优化已有的聚类分析***



3. ***建立线性回归模型***



## 视图控制器说明

<a href="https://github.com/vv123infinity/FitnessDataAnalysis/blob/9201bdaddb3c51fd01f72333e99eb5173f2f4bac/FitnessDataAnalysis/ViewController/readMe.md">FitnessDataAnalysis/ViewController/readMe.md</a>描述了视图控制器各代码文件的作用。
