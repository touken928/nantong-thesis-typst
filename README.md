# 南通大学本科毕业论文／毕业设计 Typst 模板

依据[学校发布的 2024 年本科格式要求模板](https://smkxxy.ntu.edu.cn/2024/0621/c2314a240363/page.htm)制作，同时支持毕业论文和毕业设计。默认采用 A4，上下右边距为 2cm，左侧含装订线共 2.5cm。不同学院若另有要求，请按学院规范核对。

查看示例：[毕业设计 PDF](https://github.com/touken928/nantong-thesis-typst/releases/latest/download/main.pdf) · [毕业论文 PDF](https://github.com/touken928/nantong-thesis-typst/releases/latest/download/main-thesis.pdf)。首次自动发布成功后，下载链接生效。

## 开始使用

1. 安装 [Typst](https://typst.app/) 0.15.1 或更新版本，下载或克隆本仓库。
2. 打开 `main.typ`，修改题目、姓名、专业、指导教师、日期、中英文摘要和关键词。
3. 替换示例正文、图表和文献，编译 PDF：

```bash
typst compile --root . main.typ main.pdf
```

使用 VS Code 时，安装 **Tinymist Typst** 扩展，打开整个项目文件夹，然后打开 `main.typ` 启动预览即可。

示例中的实验数据是人工构造的排版演示数据，正式写作时需替换为自己的研究内容和真实资料。

## 文件放在哪里

```text
main.typ                 封面信息、摘要、正文、致谢和附录
template/ntu-bachelor.typ 本科排版模板
figures/                 图的源码、图片及绘图数据
tables/                  表格定义和 CSV 数据
references/              Bib 文献和著录样式
resources/               官方 Word 模板、校名和校徽
```

日常写作主要修改 `main.typ`，在对应目录维护图、表和文献。复用到其他项目时，保留相同目录结构。

## 字体

西文使用 **Times New Roman**。中文优先使用官方字体，未安装时自动使用对应的 macOS 字体：

| 用途 | 官方字体 | macOS 对应字体 |
| --- | --- | --- |
| 宋体 | SimSun | Songti SC |
| 黑体 | SimHei | Heiti SC |
| 楷体 | KaiTi | Kaiti SC |

Windows 通常使用官方字体，macOS 通常使用右列字体；Linux 需自行安装所需字体。macOS 对应字体是本项目的替换配置，不表示学校认可。

用 `typst fonts` 查看可用字体。若中文出现方框，请确认每类至少安装一个表中字体。自动选择时，未安装的候选字体仍可能产生警告；可在 macOS 上固定字体方案：

```bash
typst compile --root . --input ntu-platform=darwin main.typ main.pdf
```

使用自己提供的字体目录时，在编译命令中增加 `--font-path ./fonts`；字体文件不随仓库分发。

## 选择论文或设计

在 `main.typ` 开头修改：

```typst
kind: "design", // 毕业设计；毕业论文使用 "thesis"。
```

也可临时通过命令行生成毕业论文：

```bash
typst compile --root . --input kind=thesis main.typ main-thesis.pdf
```

封面、页眉和诚信承诺书中的名称会同步切换。承诺书中的签名和日期留空，按学校要求手写。

如需自定义封面大标题和左上角页眉，在同一配置中填写：

```typst
cover-title: "课程设计报告",
header-title: "南通大学课程设计",
```

设为 `none` 时沿用论文或设计的默认名称；这两项不会修改诚信承诺书中的名称。

## 关闭不需要的部分

封面和正文始终保留，其他部分默认开启。在 `main.typ` 的 `sections` 中把对应项改为 `false`：

```typst
sections: (
  toc: false,
  acknowledgement: false,
  appendix: false,
),
```

| 配置项 | 对应部分 |
| --- | --- |
| `declaration` | 诚信承诺书及使用授权说明 |
| `abstract` | 中文摘要和关键词 |
| `abstract-en` | 英文摘要和关键词 |
| `toc` | 目录 |
| `references` | 文献角标和参考文献列表 |
| `acknowledgement` | 致谢 |
| `appendix` | 全部附录 |

未填写的开关保持开启。关闭摘要后，可以省略该摘要和关键词字段；开启时，关键词应为 3–5 项，中英文数量一致。

命令行也可临时关闭，例如 `--input show-toc=false`；命令行配置优先于源码配置。

## 写正文、图表和引用

用标题语法书写章节，编号和目录自动生成：

```typst
= 引言
== 研究背景
=== 研究问题

这里写正文。
```

图、表使用模板提供的 `fig`、`tbl`，通过标签引用，避免手写编号。示例中的图表可以这样使用：

```typst
处理流程见@fig-pipeline，完整记录见@tab-measurements。

#fig(pipeline, caption: [指纹增强处理流程], label: <fig-pipeline>)
#tbl(measurements, caption: [完整样本记录], label: <tab-measurements>)
```

修改 `tables/measurements.csv` 后，示例表格会随编译更新。较长表格会自动续页并重复表头。关闭附录时，应同步调整指向附录的引用；示例已使用 `when-section` 处理这种切换。

在 `references/refs.bib` 中维护文献，正文使用 `@hong1998` 等引用，参考文献按首次引用顺序排列。

关闭 `references` 后，正文文献角标和文献列表都不显示。若仍保留文献的 `@引用`，需显式填写 `bib` 以解析它们；没有文献引用时，可省略 `bib` 或设为 `none`。找不到目标的 `@引用` 会报错，图表、章节和公式引用仍正常解析。

## 自动构建与下载

推送到 GitHub 的 `main` 分支后，Actions 自动构建毕业设计和毕业论文 PDF。与最新 Release 相同时跳过发布；任意一个 PDF 变化时，创建新 Release 并标为最新，保留历史版本。PDF 只作为 Release 附件发布，不提交进 Git。

在 [Releases](https://github.com/touken928/nantong-thesis-typst/releases) 查看历史版本，或使用文档开头的链接下载最新示例。需要重新构建时，可在 Actions 页面手动运行 **Build and release PDFs**。构建失败时，在该次运行的日志中查看原因。

## 提交前

核对封面、摘要、分页、页码、图表与公式编号、文献和字体显示。当前项目生成 PDF；若学校要求提交 Word 文件，请另按提交要求处理。
