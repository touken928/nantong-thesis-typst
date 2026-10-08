# 南通大学本科毕业论文／毕业设计 Typst 模板

本项目依据 `resources/ntugraduatedesign.doc` 的本科版式及明确批注实现。该文件与[学校官网发布的 2024 年本科格式要求附件](https://smkxxy.ntu.edu.cn/2024/0621/c2314a240363/page.htm) SHA-256 完全一致。论文和设计共用版式，按官方批注切换名称。

## 项目结构

```text
.
├── main.typ                    # 元信息、摘要、全部正文、致谢与附录
├── template/
│   └── ntu-bachelor.typ         # 本科版式、字体、编号和自动续表
├── figures/
│   └── pipeline.typ            # 流程图源码
├── tables/
│   ├── measurements.csv        # 表格自己的完整样本记录
│   └── measurements.typ        # 数据读取与完整记录表
├── references/
│   ├── refs.bib                # 参考文献资料
│   └── gb-t-7714-2015-numeric.csl # 著录样式
├── resources/                  # 官方 Word 模板、校名和校徽
├── main.pdf                    # 已编译的示例
└── README.md
```

在 `main.typ` 中连续写作，在对应的图、表目录中维护素材和数据。示例统一采用指纹增强主题，按照“研究问题—方法—实验与结果—结论”展开；此章节安排可按专业和题目调整，不是学校规定的固定章节名称。示例包含两篇可由 DOI 核对的文献，以及 45 条人工构造的数据，这些数据只用于展示排版和文件组织。

## 编译

需要 Typst 0.15.1 或更新版本。西文使用 Times New Roman。中文默认按已安装字体自动选择：优先官方家族，未安装时使用下列 macOS 对应家族，关闭其他字体的自动回退：

| 用途 | 优先使用的官方家族 | macOS 对应家族 |
| --- | --- | --- |
| 宋体 | SimSun | Songti SC |
| 黑体 | SimHei | Heiti SC |
| 楷体 | KaiTi | Kaiti SC |

直接使用 Typst 编译：

```bash
# 自动选择已安装字体，毕业设计（默认）
typst compile --root . main.typ main.pdf

# 毕业论文
typst compile --root . --input kind=thesis main.typ main-thesis.pdf
```

Typst 模板无法读取操作系统或查询已安装字体，因此默认通过字体列表的优先级选择，未读取操作系统名称。通常 Windows 使用官方字体，macOS 使用对应家族；Linux 需自行安装这些字体。上述 macOS 替换是本项目的用户指定配置，不表示学校官方认可。

仍可显式固定方案：`--input ntu-platform=darwin` 只选 macOS 对应家族，`--input ntu-platform=windows` 或 `linux` 只选官方家族，`auto` 为默认值。也可用 `--input song-font=SimSun`、`--input hei-font=SimHei`、`--input kai-font=KaiTi` 逐项固定字体；模板只接受表中对应的家族，固定为 Windows／Linux 方案时只接受官方家族。

自动模式中，Typst 仍会对列表里未安装的家族产生 `unknown font family` 警告，即使已成功使用后面的家族。这与缺字不同；若希望消除这类警告，可显式固定已安装的方案或字体。请用 `typst fonts` 确认 Times New Roman 和每类至少一个中文家族已安装，并检查 PDF 中是否有缺字。项目不打包字体；自己已有的字体文件可放入自定义目录，编译时增加 `--font-path ./fonts`，并用 `typst fonts --font-path ./fonts` 检查家族名称。

当前 macOS 环境使用 Times New Roman、Songti SC、Heiti SC、Kaiti SC，已按上述规则重新生成 `main.pdf`。

### VS Code / Tinymist 预览

用 VS Code 打开整个项目文件夹，打开 `main.typ` 并启动 Tinymist 预览。字体自动选择由模板实现，无需项目级编辑器配置或平台参数；Tinymist 默认读取系统字体。

如需固定字体，可使用上面的命令行参数编译。若一类中文字体的两个家族都未安装，由于模板关闭了其他字体的回退，仍会出现缺字或方框，应先安装字体。

封面校名图片使用 `fit: "contain"`，在既定区域内按原比例完整显示。原图为 800 × 230 像素，比例与 10.42cm × 3.4cm 的区域不同；默认的 `cover` 会裁掉左右部分。

## 填写与写作

在 `main.typ` 开头的 `ntu-bachelor.with(...)` 中填写封面信息、中英文摘要和关键词，后面依次书写正文、参考文献、致谢和附录。默认类型为毕业设计；使用 `--input kind=thesis` 可编译毕业论文，封面、页眉和诚信承诺书同步切换。承诺书及授权说明中的签名、日期按官方要求手写。

正文使用 `= 章标题`、`== 节标题`、`=== 小节标题`，直接在入口文件中调整章节顺序，不手写章号。每章另起一页，摘要和目录采用大写罗马页码，正文从阿拉伯数字 1 开始。

### 可选部分与自定义标题

封面和正文始终保留，其他部分默认开启，可以独立关闭。在 `main.typ` 的 `ntu-bachelor.with(...)` 中，直接把 `sections` 对应项改为 `false`。只填写需要关闭的项也可以，其余项自动使用默认值：

```typst
sections: (
  toc: false,
  acknowledgement: false,
  appendix: false,
),
```

| `sections` 配置项 | 命令行参数 | 控制的部分 |
| --- | --- | --- |
| `declaration` | `show-declaration` | 诚信承诺书及使用授权说明（整页一起关闭） |
| `abstract` | `show-abstract` | 中文摘要及中文关键词 |
| `abstract-en` | `show-abstract-en` | 英文摘要及英文关键词 |
| `toc` | `show-toc` | 目录 |
| `references` | `show-references` | 正文文献角标、参考文献标题及列表 |
| `acknowledgement` | `show-acknowledgement` | 致谢 |
| `appendix` | `show-appendix` | 全部附录 |

模板统一处理默认值、论文类型和命令行解析，`main.typ` 无需编写 `sys.inputs` 或解析函数。命令行参数优先于源码配置，例如 `--input show-toc=false` 会覆盖 `sections.toc: true`，`--input kind=thesis` 会覆盖 `kind: "design"`。源码开关须为布尔值，命令行开关只接受 `true` 或 `false`。

关闭部分不会留下空白页或目录条目。保留的摘要、目录从罗马页码 I 连续编号，正文始终从阿拉伯数字 1 开始。只校验已开启摘要的关键词数量；双语摘要都开启时，仍要求中英文关键词数量一致。`references()`、`acknowledgement[...]` 和 `appendix(...)[...]` 可以继续保留在源码中，模板会按开关跳过输出。

`sections.references: false` 同时关闭正文的文献角标和参考文献列表。文献继续使用 `@hong1998` 等写法；若仍保留文献引用，显式填写 `bib`，模板会读取它以解析引用，但不显示角标、列表，也不加载自定义 CSL 样式。

关闭文献且不需要解析文献引用时，可以省略 `bib` 或设为 `none`，模板不会读取文献文件。未找到目标的 `@引用` 直接报错，不按名称或前缀推断引用类型，也不会自动忽略。图表、公式和章节标签的解析不受文献开关影响。开启文献时，省略 `bib` 会使用默认的 `/references/refs.bib`。

关闭附录时，指向附录图表或公式的正文引用也应同步调整。示例使用 `when-section` 切换对附录表格的引用，关闭后改为指向 CSV 数据文件。该函数读取模板解析后的开关，源码配置和命令行覆盖都能生效：

```typst
#import "template/ntu-bachelor.typ": when-section

#when-section("appendix", otherwise: [完整记录见 CSV 数据文件。])[
  完整记录见@tab-measurements。
]
```

`cover-title` 控制封面上原来的“本科毕业设计／论文”，`header-title` 控制左上角原来的“南通大学毕业设计／论文”。两项可分别设置字符串或 Typst 内容；默认值 `none` 表示沿用 `kind` 对应名称。在 `ntu-bachelor.with(...)` 中可以直接填写：

```typst
cover-title: "课程设计报告",
header-title: "南通大学课程设计",
```

它们只修改这两处显示文字，诚信承诺书中的“毕业设计／论文”仍由 `kind` 控制。也可用命令行覆盖标题和开关，例如仅保留封面与正文：

```bash
typst compile --root . \
  --input 'cover-title=课程设计报告' \
  --input 'header-title=南通大学课程设计' \
  --input show-declaration=false \
  --input show-abstract=false \
  --input show-abstract-en=false \
  --input show-toc=false \
  --input show-references=false \
  --input show-acknowledgement=false \
  --input show-appendix=false \
  main.typ course-report.pdf
```

直接复用 `template/ntu-bachelor.typ` 时也使用同一个 `sections` 字典，无需单独声明或传递一组 `show-*` 变量。

图表在首次讨论它们的正文附近插入，完整记录可以放在附录。示例在入口文件顶部导入图表定义，然后在适当位置使用：

```typst
#import "figures/pipeline.typ": pipeline
#import "tables/measurements.typ": measurements

处理流程见@fig-pipeline，完整记录见@tab-measurements。
#fig(pipeline, caption: [处理流程], label: <fig-pipeline>)
#tbl(measurements, caption: [完整样本记录], label: <tab-measurements>)
```

## 图与表各自维护素材

`figures/` 保存图的 Typst 源码、绘图数据或导出的 SVG／PDF／PNG 图片。示例流程图由 Typst 绘制，沿用模板字体。新增图片或绘图数据时，直接放在此目录中维护；修改外部绘图数据后，应使用绘图软件重新导出图片。

外部图片中的文字须采用项目允许的字体。

`tables/` 保存表格定义与表格使用的数据。`measurements.typ` 从同目录的 `measurements.csv` 读取样本并定义完整记录表。CSV 修改后，表格记录随编译更新。不同表也可以在此目录维护各自的数据文件。

图和表分别维护自己的文件；比较同一组实验时，应人工核对它们的方案名称、指标定义、数据版本及数值是否一致。

表格示例采用 UTF-8 CSV，首行为字段名，每行对应一个样本：

| 字段 | 含义 | 单位／范围 |
| --- | --- | --- |
| `sample` | 唯一样本标识，如 S001 | 文本 |
| `baseline_score` | 原始图像的演示质量分数 | 0–1，无量纲 |
| `gabor_score` | Gabor 方案的演示质量分数 | 0–1，无量纲 |
| `adaptive_score` | 自适应方案的演示质量分数 | 0–1，无量纲 |
| `adaptive_time_ms` | 自适应方案的演示耗时 | 毫秒 |

这里的分数不是已验证的指纹质量标准。正式写作时应说明真实指标的定义、样本来源和计算方法。更换实验字段时，应同时修改对应表格的数据读取和表头。

## 编号、引用与自动续表

图题在下、表题在上。图、表、独立公式分别按章编号，正文用 `@标签` 引用，不手写“图2.1”等编号。图表标签通过 `label` 参数传入；建议使用 `fig-`、`tab-`、`eq-` 前缀，且标签在全文中唯一。

```typst
$ bar(q) = 1 / N sum_(i=1)^N q_i $ <eq-mean>
均值计算见@eq-mean。
```

`tbl` 对短表保持整表排版，超过一整页的长表自动续页、重复表头，并在右上方显示原表号，例如“续表A.1”。自动续表需要把 `table(...)` 直接传给 `tbl`，全部表头行写在同一个 `table.header(...)` 中。实际示例在 `tables/measurements.typ` 中，正文只需调用：

```typst
#tbl(measurements,
  caption: [完整样本记录],
  label: <tab-measurements>,
)
```

需要指定拆分位置时，仍可用 `table-continued("2.1")[...]` 手动另起续页并自行重复表头。

## 参考文献与附录

参考文献集中写入 `references/refs.bib`，正文用 `@hong1998` 等引用键引用。开启文献时，`references()` 按首次引用顺序生成文献列表，本地 CSL 文件控制著录格式；关闭文献时，角标和列表均不输出，显式提供的 Bib 仅用于解析正文引用。引用键应保持稳定，不按当前参考文献序号命名。新增条目应核对作者、题名、出处、年份、页码和 DOI，并确认正文实际引用了它。

两篇示例文献的资料来源：[Hong 等论文原文](https://www.cse.msu.edu/~rossarun/BiometricsTextBook/Papers/Fingerprint/HongFpImageEnhancement.pdf)、[Chikkerur 等论文的作者所在大学记录](https://researchconnect.buffalo.edu/en/publications/fingerprint-enhancement-using-stft-analysis/)。

`acknowledgement[...]` 生成致谢，`appendix("材料名称")[...]` 生成附录。它们的内容直接写在 `main.typ` 中。附录图表和公式自动使用 A、B 等前缀，多次调用 `appendix(...)` 可以增加不同的附录材料。

示例正文长度与参考文献数量不足以用于提交。根据本模板的官方要求：中文题目一般不超过 25 个汉字，中文摘要不少于 300 个汉字，中英文关键词各 3–5 个且对应，正文不少于 15000 个汉字符（含图表字符），参考文献不少于 15 篇、其中外文不少于 5 篇。已开启摘要的关键词数量由模板校验，其余要求应在提交前人工核对。

## 格式依据

核对日期：2026-10-07。官方附件 SHA-256：`3bae0d60bd7a9f152afd4db5a5cdd82b78c885bec250354c98097c97ecfd6dd1`。

官方 Word 示例个别实际样式与批注不一致时，优先遵循明确的格式批注；保留正式声明文字，不输出教学说明和批注。

以下描述默认全部开启时的版式；各可选部分及两处显示标题可按上文配置。

| 项目 | 官方要求／实际页面设置 | 本项目实现 |
| --- | --- | --- |
| 纸张、装订 | A4；四边各 2cm；左装订线 0.5cm | 210mm × 297mm；左边合计 2.5cm，右边 2cm，上下 2cm；不镜像；关闭悬挂标点，默认表格描边预留外侧空间 |
| 封面 | 校名、校徽、本科毕业设计／论文、题目框、姓名／专业／导师／日期 | 保留已有校名校徽资产及信息结构；题目小二 18pt 黑体居中 |
| 承诺及授权 | 标题宋体二号加粗，正文宋体四号；签名、日期手写 | 22pt／14pt，签名和日期留空；承诺书按类型切换 |
| 正文 | 宋体小四，西文 Times New Roman；1.5 倍行距，两端对齐、首行缩进 2 字符 | 12pt；基线间距 23.4pt，首行 24pt；段间不额外空行 |
| 章标题、摘要等 | 黑体小三加粗居中；段前后各 0.5 行、1.5 倍行距；另起一页 | 15pt；段前后各 7.8pt；不强制奇数页 |
| 二级标题 | 宋体四号加粗、顶格；段前后各 0.5 行、1.5 倍行距 | 14pt；段前后各 7.8pt；与后文保持同页 |
| 三级标题 | 宋体小四加粗、顶格；段前后 0 行、1.5 倍行距 | 12pt；无附加段前后间距；与后文保持同页 |
| 摘要关键词 | 小四正文；关键词标签四号加粗；与摘要空一行；中文用分号、末尾无标点 | 标签 14pt、内容 12pt；中英文各 3–5 项且数量一致；英文续行与关键词内容起始对齐 |
| 目录 | 小三黑体标题，三倍行距；最多三级；条目 1.5 倍行距；一级四号宋体，二级小四宋体，三级小四楷体 | 自动目录；正文页码右齐、可跳转；二三级分别缩进 2、4 个汉字；长标题自动换行 |
| 页眉页脚 | 封面、声明无页眉；其后宋体小五、左对齐；摘要罗马页码、正文阿拉伯页码居中；Word 中页眉距顶约 1.2cm、页脚距底约 1.5cm | 9pt；页眉距顶 1.2cm、页码下缘距底 1.5cm；从摘要 I 开始，正文重置为 1；页眉区底线 0.75pt |
| 图、表 | 五号宋体，西文 Times New Roman；分章连续编号；图题下、表题上 | 10.5pt；图表各自计数；跨章引用读取目标位置的章号 |
| 续表 | 原则不跨页；接写时省略表题、重复表头、右上注明续表号 | 短表整表排版，过长表格自动续页；重复声明的表头，右上显示原表号，不增加计数 |
| 公式 | 独立行，12pt，中文括号、右对齐、分章连续编号 | 原生数学排版；独立公式编号，标签再次引用不增加编号 |
| 参考文献 | 五号；首次引用顺序；保留前三名作者；续行与文字对齐 | 数字上标；10.5pt，依据 Word 示例固定 19pt 基线；CSL `second-field-align="flush"` |
| 致谢、附录 | 另起一页，小三黑体标题；正文沿用正文格式 | 不编号的一级标题；附录材料名不进入目录；附录图表公式另用 A、B 前缀 |

Word 文档网格为 312 twips，即 15.6pt，普通正文 1.5 倍行距对应 23.4pt。Typst 的 `leading` 表示两行文字边界之间的距离，不能把 `0.5em` 直接当作 Word 的 1.5 倍行距；模板明确设定文字边界来稳定中英文基线距离。正文基线、标题间距、参考文献基线均经过导出 PDF 检查。

页边距按官方文档中的明确文字要求统一设置：左侧 2cm 加 0.5cm 装订线，其余三边 2cm，正文区域为 16.5cm × 25.7cm。Word 文件的一处连续分节把装订线设为 0，模板不沿用这一不一致设置。Typst 的 `binding: left` 只确定装订方向，不会自动增加 0.5cm；页眉、页脚在页边距区域内单独定位，不能把 Word 的距边界数值直接填入 `header-ascent` 或 `footer-descent`。PDF 检查区分正文区域、字形实际墨迹、表格描边与页眉页脚，避免将页眉页码误当成正文越界。

已核对[化学化工学院 2024 年发布的统一模板](https://hgxy.ntu.edu.cn/2024/1010/c9282a251080/page.htm)。其中若干要求不同：右边距 1.5cm、二级标题段前后 0 行、公式 10.5pt 及半角括号等。本项目保留已有、与官网 2024 年新附件一致的规范，不把不同学院条款混合成一种版式。

## 提交前检查

打开编译后的 PDF，核对封面信息、承诺书、页眉、分页和页码、图表与公式编号、附录编号、参考文献及字体显示。

Typst 与 Word 是不同排版引擎，本项目提供 PDF 模板，不能保证通过只接受 Word 样式信息的学校检测。当前 CSL 处理器使用统一的中文区域设置，外文条目超过三名作者时会输出“等”，尚不能逐条自动切换为官方要求的“et al”；此类条目需要核对。英文题名大小写应在 Bib 文件中按官方要求填写，不自动改变缩写或专名。具体学院若发布不同规范，应以学院要求为准。
