# 中国海洋大学编译原理实验报告 Typst 模板

基于OUC Word 模板复刻的 Typst 版编译原理实验报告模板

## 文件结构

```
.
├── template.typ   # 模板文件（封面、目录、样式定义）
├── main.typ       # 报告正文（填写内容的地方）
└── README.md
```

## 快速开始

1. 安装 [Typst](https://typst.app/)（或使用在线编辑器 [typst.app](https://typst.app/)）
2. 修改 `main.typ` 中的报告参数：

```typst
#show: report.with(
  title: "编译原理实验报告",
  experiments: ("实验1：词法分析", "实验2：语法分析"),
  members: (("张三", "2024001"),),
  date: "2026年5月1日",
)
```

3. 编译：

```bash
typst compile main.typ
```

## 可用函数

### `exp-title(title)`

实验大标题，居中加粗，22pt。

```typst
#exp-title("实验1：词法分析")
```

### `exp-section(number, title)`

实验小节标题，带中文编号（一、二、三...），靠左，15pt。

```typst
#exp-section(1, "实验目的")
#exp-section(2, "实验内容")
```

### `three-line-table(columns, ..cells)`

三线表，前 `columns` 个参数为表头行。

```typst
#figure(
  three-line-table(
    columns: 3,
    [列A], [列B], [列C],
    [数据1], [数据2], [数据3],
  ),
  caption: [表格标题],
) <tab:my-table>
```

### 插入图片

```typst
#figure(
  image("screenshot.png", width: 80%),
  caption: [运行结果截图],
) <fig:my-figure>
```

### 交叉引用

```typst
如 @tab:my-table 所示，结果见 @fig:my-figure。
```

## 页面参数

| 参数 | 值 |
|------|------|
| 纸张 | A4 |
| 上下页边距 | 2.5cm |
| 左右页边距 | 3.2cm |
| 正文字体 | 宋体 + Times New Roman |
| 行间距 | 1.0em |
| 首行缩进 | 2em |

![OUC编译原理实验模板-1](https://cdn.jsdelivr.net/gh/Pocon041/blogimage2@main/OUC%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86%E5%AE%9E%E9%AA%8C%E6%A8%A1%E6%9D%BF-1.png)

![OUC编译原理实验模板-2](https://cdn.jsdelivr.net/gh/Pocon041/blogimage2@main/OUC%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86%E5%AE%9E%E9%AA%8C%E6%A8%A1%E6%9D%BF-2.png)

![OUC编译原理实验模板-3](https://cdn.jsdelivr.net/gh/Pocon041/blogimage2@main/OUC%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86%E5%AE%9E%E9%AA%8C%E6%A8%A1%E6%9D%BF-3.png)

![OUC编译原理实验模板-4](https://cdn.jsdelivr.net/gh/Pocon041/blogimage2@main/OUC%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86%E5%AE%9E%E9%AA%8C%E6%A8%A1%E6%9D%BF-4.png)

![OUC编译原理实验模板-5](https://cdn.jsdelivr.net/gh/Pocon041/blogimage2@main/OUC%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86%E5%AE%9E%E9%AA%8C%E6%A8%A1%E6%9D%BF-5.png)

![OUC编译原理实验模板-6](https://cdn.jsdelivr.net/gh/Pocon041/blogimage2@main/OUC%E7%BC%96%E8%AF%91%E5%8E%9F%E7%90%86%E5%AE%9E%E9%AA%8C%E6%A8%A1%E6%9D%BF-6.png)















