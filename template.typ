// 编译原理实验报告 Typst 模板
// 使用方法: 修改下方参数后编译即可

#let report(
  title: "编译原理实验报告",
  experiments: ("实验1：XXX", "实验2：XXX"),
  members: (("张三", "XXXX"), ("李四", "XXXX")),
  date: "2026年1月1日",
  body,
) = {
  // 页面设置: A4, 页边距与Word模板一致
  set page(paper: "a4", margin: (top: 2.5cm, bottom: 2.5cm, left: 3.2cm, right: 3.2cm))
  set text(font: ("Times New Roman", "SimSun"), lang: "zh", region: "cn")
  set par(leading: 1.0em, first-line-indent: (amount: 2em, all: true))
  set heading(numbering: none)
  show figure.where(kind: table): set figure.caption(position: top)
  show figure: set par(first-line-indent: 0em)
  set figure.caption(separator: [ ])
  show figure.caption: it => {
    set text(size: 10.5pt)
    set par(first-line-indent: 0em)
    align(center)[
      #text(weight: "bold")[#it.supplement #it.counter.display(it.numbering).] #it.body
    ]
  }
  show table: it => {
    set par(first-line-indent: 0em)
    set align(center)
    it
  }
  show raw.where(block: true): it => {
    set par(first-line-indent: 0em)
    block(fill: luma(245), inset: 8pt, radius: 3pt, width: 100%, it)
  }
  show heading.where(level: 1): it => {
    set text(size: 22pt, weight: "bold", font: ("Times New Roman", "SimSun"))
    set par(first-line-indent: 0em)
    align(center, it)
  }
  show heading.where(level: 2): it => {
    set text(size: 15pt, weight: "regular", font: ("Times New Roman", "SimSun"))
    set par(first-line-indent: 0em)
    v(0.5em)
    it
    v(0.4em)
  }

  // ===== 封面 =====
  {
    set par(first-line-indent: 0em)
    v(4cm)
    align(center, text(size: 42pt, font: ("Times New Roman", "SimSun"))[#title])
    v(1.5cm)
    for exp in experiments {
      text(size: 20pt, font: ("Times New Roman", "SimSun"))[#exp]
      v(0.3cm)
    }
    v(1fr)
    for (i, (name, id)) in members.enumerate() {
      if i == 0 {
        align(right, text(size: 14pt)[小组成员：#name（学号：#id）])
      } else {
        align(right, text(size: 14pt)[#name（学号：#id）])
      }
      v(0.2cm)
    }
    v(0.5cm)
    align(right, text(size: 14pt)[完成日期：#date])
    v(1.5cm)
    pagebreak()
  }

  // ===== 目录 =====
  {
    set par(first-line-indent: 0em)
    align(center, text(size: 22pt, weight: "bold")[实验目录])
    v(1cm)
    show outline.entry: it => {
      set text(size: 12pt, weight: "regular")
      show strong: set text(weight: "regular")
      it
      v(0.4em)
    }
    outline(title: none, indent: 1.5em, depth: 2)
    pagebreak()
  }

  // ===== 正文 =====
  body
}

// 实验章节标题 (如 "实验1：词法分析")
#let exp-title(title) = {
  heading(level: 1)[#title]
}

// 实验小节标题，带中文编号 (一、实验目的)
#let section-titles = ("一", "二", "三", "四", "五", "六", "七", "八")
#let exp-section(number, title) = {
  let prefix = section-titles.at(number - 1)
  heading(level: 2)[#prefix、#h(0.25em)#title]
}

// 三线表 (CVPR 风格)
// 用法: #three-line-table(columns: 3, [列A], [列B], [列C], [1], [2], [3])
#let three-line-table(columns: auto, ..args) = {
  set par(first-line-indent: 0em)
  table(
    columns: columns,
    stroke: none,
    inset: (x: 8pt, y: 5pt),
    table.hline(stroke: 1.5pt + black),
    ..args.pos().slice(0, if type(columns) == int { columns } else { args.pos().len() }),
    table.hline(stroke: 0.75pt + black),
    ..args.pos().slice(if type(columns) == int { columns } else { args.pos().len() }),
    table.hline(stroke: 1.5pt + black),
  )
}

// ========== 以下为示例用法，请根据实际内容修改 ==========

#show: report.with(
  title: "编译原理实验报告",
  experiments: ("实验1：词法分析", "实验2：语法分析"),
  members: (("张三", "2024001"), ("李四", "2024002")),
  date: "2026年5月1日",
)

#exp-title("实验1：词法分析")

#exp-section(1, "实验目的")

// 在此填写实验目的

#exp-section(2, "实验内容")

// 在此填写实验内容

#exp-section(3, "实验要求")

// 在此填写实验要求

#exp-section(4, "实验过程及重点内容")

// 在此填写实验过程及重点内容

#exp-section(5, "实验结果")

// 在此填写实验结果（附截图）

#exp-section(6, "实验中遇到的问题、难点及解决方案")

// 在此填写遇到的问题及解决方案

#exp-section(7, "感想和收获")

// 在此填写感想和收获

#exp-section(8, "小组分工情况")

// 在此填写小组分工情况
