# 简介

Grafana 是一款用 GO 语言开发的开源数据可视化工具，可以做数据监控和数据统计，带有告警功能。你只需要提供你需要监控的数据，它就可以帮你生成各种可视化仪表。

官方文档:https://grafana.com/docs/grafana/latest/

https://grafana.com/zh-cn/grafana

# 基础概念

## 组织

Organization（组织） 是一个很大的概念，每个用户可以拥有多个 Organization，Grafana 有一个默认的组织。创建一个 Organization 就相当于开了一个全新的视图，所有的 datasource，dashboard 等都要再重新开始创建。

## 用户

Grafana 里面用户有三种角色 admin,editor,viewer。在2.1版本及之后新增了一种角色read only editor（只读编辑模式），这种模式允许用户修改 DashBoard，但是不允许保存。每个 user 可以拥有多个 Organization。

- admin 权限最高，可以执行任何操作，包括创建用户，新增 Datasource，创建DashBoard。
- editor 角色不可以创建用户，不可以新增 Datasource，可以创建 DashBoard。
- viewer 角色仅可以查看 DashBoard。

## 数据源

Grafana 支持多种数据源。

- 服务器访问模式（默认）

  浏览器------>grafana服务器------>数据源

  所有请求都将从浏览器发出到 Grafana 后端/服务器，后者再将请求转发到数据源，从而避免可能的跨源资源共享（CORS）要求。如果选择此访问方式，则需要可以从 Grafana 后端/服务器访问该 URL。

- 浏览器（直接）访问（将会被废除）

  浏览器----->数据源

## 仪表盘（Dashboard）

一个文件夹下可以有多个仪表盘，一个仪表盘下可以配置多个row。一个row可以有多个面板

- dashboard，仪表盘/看板，一个可以进行数据可视化展示的地方
- row。对多个数据可视化的报表进行统一定义和管理的地方。dashboard下面可以设置文件夹，多个
- panel，面板一个最基本的可视化单元为一个 Panel（面板）。每个panel都是独立的，可以选择一个或多个数据源进行查询



# 数据与图标

（一）按照数据格式区分

柱状图， 折线图， 饼状图的图表都需要数据具有**时间序列**，用于展示在**一定的时间区间或者是连续的时间范围**内，单一数据或者多种分类数据的变化趋势，或者是数量占比。

状态图， 表格数据，仪表盘等则对数据没有时间序列要求，状态图，仪表盘可用于进行一些**总结性的数据展示**，例如速度，温度，进度，完成度等， 表格数据则更适合展示复杂数据或者多维度数据。

（二）按照使用意图区分

数据比较：柱状图，折线图比较合适，可以实现单数据，多种类数据的比较，能清晰看到变化趋势

占比分类：饼图，仪表盘， 单一状态图等比较合适，可以清晰的看到每个数据整体性的占比

趋势比较：折线图，面积图(折线可设置覆盖面积) 等比较合适，能直观展现数据变化

分布类：饼图， 散点图等比较合适



# 内置操作

#### .折线图

这里我们就统计一下学生的月份生日数量。这里我们需要用`$__timeGroup`和`$__timeFilter`函数，它们是Grafana的函数，他们的用法如下:

- `$__timeGroup` 函数用于将时间范围分组成特定的时间间隔，例如每分钟、每小时、每天等。这个函数通常用于创建时间序列图表，帮助用户将数据按照时间间隔进行聚合和展示。
- `$__timeFilter` 函数用于过滤特定的时间范围，用户可以使用该函数来限制数据的时间范围，例如只显示最近一小时的数据或者只显示某个特定时间段的数据。

除了 `$__timeGroup` 和 `$__timeFilter`，Grafana 还提供了其他与时间相关的内置函数，例如:

- `$__timeFrom()`：用于指定起始时间，可以指定相对时间（例如“now-1h”表示当前时间的一小时前）或绝对时间（例如“2023-11-14T00:00:00”表示具体的时间点）。
- `$__timeTo()`：用于指定结束时间，同样可以指定相对时间或绝对时间。
- `$__timeFilterGroup()`：用于根据时间范围过滤数据，并且可以结合其他过滤条件使用
