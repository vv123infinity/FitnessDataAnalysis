# 文件说明

[TOC]



> 主要了解“概要”tab栏下的各个子模块。

## 概要（文件夹`Overview`目录）

1. `RootTable.swift` 是APP的主界面对应的视图控制器（也是概要Tab的根视图控制器），作用：

* 控制section1、2和3的UI、显示文字和跳转界面
* 显示section1的具体数据分析结果

2. `overviewItem.plist` 存储需要显示&本地化（翻译）的文本。

---

概要下的各个分区列表项（按钮）对应的代码在文件夹`Overview`目录下。`Overview`目录下的三个子目录：

* `sec1`对应section1。如果授权失败，这个section会用来提示用户无法访问；否则，这个section初步确定功能：**最近一次运动的分析概况**。并且点击section1跳转到更加具体的界面。
* `sec2`对应section2。包含的列表项目：
  * **历史数据查询、可视化**
  * **运动数据分析**
  * 
* `sec3`对应section3。包含的列表项目：
  * 制定计划功能，与push notification组合



### sec1



### sec2

#### 历史数据查询与可视化



#### 数据分析



## 实用工具代码`utilMethod`文件夹





## 其他（先不用理会）

* 设置tab栏在`Settings`文件夹下
* 实用工具tab栏在`Toolbox`文件夹下
* 
