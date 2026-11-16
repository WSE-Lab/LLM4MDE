# LLM4MDE SLR analysis

[`LLM4MDE_SLR.R`](LLM4MDE_SLR.R) analyzes the labelled studies in
[`data/final_selection.csv`](../data/final_selection.csv) and generates the
figures and LaTeX tables used to answer the review's research questions.

Run the analysis using the pre-built Docker image or a local R installation.

## Running the Analysis with Docker

A pre-built image, `manzh/llm4mde-r:1.0`, contains R, the required packages,
analysis scripts, and input data. Install and start Docker before continuing.
On Windows, ensure Docker Desktop is configured to use Linux containers.
No local R installation or image build is required.

**1. Pull the Docker image**

```bash
docker pull manzh/llm4mde-r:1.0
```

**2. Run the analysis and save the results**

Run these commands from the directory where you want to save the results.
They work in PowerShell, Git Bash, and Linux/macOS shells without bind mounts:

```bash
docker run --name llm4mde-analysis manzh/llm4mde-r:1.0
docker cp llm4mde-analysis:/analysis/rcr/generated_files ./outputs
docker rm llm4mde-analysis
```

The first command runs all four perspectives. Wait for it to finish successfully
before copying results. Use a new `outputs` directory for each run; copying into
an existing directory can create a nested `generated_files` directory.
Keep the container until results have been copied; `docker rm` removes it.
After pulling the image, the analysis requires no network access.

The image contains the inputs and scripts from its publication date. Local edits
do not change the image. See the RQ1 example below to run an edited script with
the same installed environment.

## Running the Analysis with local R

Requires R. Install dependencies once in R:

```r
install.packages(c("nombre", "UpSetR", "gridExtra", "bibtex", "ggplot2",
                   "ggpattern", "ggrepel", "ComplexUpset", "dplyr", "tidyr",
                   "stringr", "tidyverse", "RColorBrewer", "scales"))
```

Open a terminal in this directory and run:

```sh
Rscript LLM4MDE_SLR.R
```

Keep `llm4MDE.bib` and `Utils.R` beside the script, and the input CSV at
`../data/final_selection.csv` relative to this directory.
Generated figures and LaTeX tables are saved in `generated_files/`.


## Generate results for each perspective with Docker

Our SLR examines the selected studies from four perspectives. Each perspective
has a corresponding R function that generates its figures and tables:

| Function | Results |
| --- | --- |
| `group1Analysis()` | Publication years, venues, and paper types |
| `group2Analysis()` | Modeling languages, model types, MDE/SE tasks, and application domains |
| `group3Analysis()` | LLM families and versions, access modes, pipelines, prompting, enhancement, tool integration, and human interaction |
| `group4Analysis()` | Evaluation metrics, baselines, benchmarks, replication artifacts, and comparisons between benchmark and proposed-method studies |


Follow the steps below to call these functions in an interactive R session
inside Docker. Mounting a local `outputs` directory saves the generated figures
and tables directly to your computer.

**1. Start an interactive R session**

Open a terminal in the directory where you want to save the results, then run
the commands for your operating system and shell.

**Windows PowerShell:**

```powershell
New-Item -ItemType Directory -Force outputs | Out-Null
docker run --rm -it --mount "type=bind,source=${PWD}/outputs,target=/analysis/rcr/generated_files" manzh/llm4mde-r:1.0 R --vanilla
```

**Windows Git Bash:**

```bash
mkdir -p outputs
MSYS_NO_PATHCONV=1 docker run --rm -it --mount "type=bind,source=$(pwd -W)/outputs,target=/analysis/rcr/generated_files" manzh/llm4mde-r:1.0 R --vanilla
```

`MSYS_NO_PATHCONV=1` prevents Git Bash from rewriting container paths. If your
Git Bash terminal reports that it is not a TTY, run the command in PowerShell.

**Linux/macOS:**

```sh
mkdir -p outputs
docker run --rm -it --mount "type=bind,source=$(pwd)/outputs,target=/analysis/rcr/generated_files" manzh/llm4mde-r:1.0 R --vanilla
```

**2. Load the script and run the analysis functions**

At the R prompt, load the script and call the functions for the perspectives
you want to analyze. The example below calls all four:

```r
source("LLM4MDE_SLR.R")
group1Analysis()
group2Analysis()
group3Analysis()
group4Analysis()
```

The current script also runs all four analyses automatically when loaded with
`source()`. Wait for this initial run to finish; subsequent function calls
regenerate the corresponding results. Files with matching names are overwritten.

**3. Exit the session**

At the R prompt, run:

```r
q(save = "no")
```

The `--rm` option removes the container when R exits. Generated files remain
in your local `outputs/` directory, so no `docker cp` step is needed. Each new
container starts a fresh R session; load the script with `source()` before
calling its functions again.


## How to read the generated files

After running the analysis, open `outputs/` if you used the Docker commands
above, or `rcr/generated_files/` if you used local R.

| File type | How to read it |
| --- | --- |
| `.pdf` | Open in a PDF viewer to inspect the generated figures. Axis labels, legends, and annotations describe the plotted categories and counts or percentages. |
| `.tex` | Open in a text editor to inspect the LaTeX table source. Include it in a LaTeX document with `\input{path/to/file.tex}` to render the table. |

Filenames start with an RQ identifier and describe the result. For example,
`RQ1_plot_num_publications_over_year.pdf` shows the publication trend over time.
Related figures and tables share the same RQ prefix; their suffixes distinguish
the analysis or breakdown shown.

The `.tex` files are table fragments rather than standalone LaTeX documents.
Rendering them may require packages such as `booktabs` and the bibliography
configuration used by the surrounding document. Paper citation keys can be
looked up in [`llm4MDE.bib`](llm4MDE.bib).

Existing files with the same names are overwritten when the analysis runs.
Output filenames retain the analysis RQ numbering, which may differ from the
public CSV column numbering.

## Mapping generated outputs to the paper

The following tables map the generated files in `generated_files/` to the figures and tables in the associated paper. PDF files contain figures; `.tex` files contain table fragments included in the paper.

The tables also provide the function calls for generating individual outputs.

### Figures

| Generated file | Function call(s) | Position in the paper | Content |
| --- | --- | --- | --- |
| `RQ1_plot_num_publications_over_year.pdf` | `rq1()` | Figure 3 | Number of publications by year from 2017 to October 2025 |
| `RQ3_types_venue_paper_stacked_bar_number.pdf` | `rq2And3StackedBar()` | Figure 4 | Number of publications according to types of venue and paper |
| `RQ5_setask_mdetask_stacked_bar.pdf` | `setask_mdetask_stacked_bar(5)` | Figure 5 | A 100% stacked bar plot representing the distribution of papers across MDE and SE tasks |
| `RQ6_modeling_language.pdf` | `modelinglanguage(6)` | Figure 6 | Bar plot representing the distribution of papers across each modeling language |
| `RQ6_mde_language_heatmap.pdf` | `mdetask_modellanguage(6)` | Figure 7 | Heatmap illustrating the distribution of modeling languages across different types of MDE tasks |
| `RQ6_modeltype_by_category.pdf` | `model_type_category(6)` | Figure 8 | Bar plot representing the distribution of papers associated with each type of models |
| `RQ6_mdetask_model_language_model_type_grouped_heatmap_main_tasks.pdf` | [RQ6 heatmap call](#rq6-heatmap-call) | Figure 9 | Heatmap of model types and modeling languages addressed by LLM-based solutions for MDE tasks |
| `RQ6_mdetask_model_language_model_type_grouped_heatmap_other_tasks.pdf` | [RQ6 heatmap call](#rq6-heatmap-call) | Figure 10 | Heatmap of model types and modeling languages addressed by LLM-based solutions for MDE tasks (continued) |
| `RQ8_foundation_models_bar.pdf` | `llm_foundation_model(8)` | Figure 11 | Bar chart presenting the distribution of foundation models employed in the primary studies |
| `RQ8_mdetask_accessmode_100_stacked_bar.pdf` | `llm_used(8)` | Figure 12 | The 100% stacked bar plot showing how LLMs are accessed across MDE tasks |
| `RQ8_llm_pipeline_pie.pdf` | `llm_pipeline(8)` | Figure 13 | Distribution of LLM uses in LLM-based MDE solutions |
| `RQ9_prompt_technique_complex_upset.pdf` | `prompt_techniques(9)` | Figure 14 | Prompt engineering techniques employed in the primary studies |
| `RQ10_enhanced_venue_mdetask_stacked_bar_number.pdf` | `LLM_enhanced(10)` | Figure 15 | Enhancement techniques for each type of MDE tasks |
| `RQ10_enhanced_venue_model_stacked_bar_number_bubble.pdf` | `LLM_enhanced(10)` | Figure 16 | Enhancement techniques applied to each LLM family |
| `RQ12_human_in_the_loop_bar.pdf` | `human_in_loop(12)` | Figure 17 | HITL interaction patterns of the LLM-based MDE solutions |
| `RQ13_mdetask_model_language_model_type_grouped_heatmap_main_tasks.pdf` | [RQ13 heatmap call](#rq13-heatmap-call) | Figure 18 | Heatmap of model types and modeling languages addressed by benchmarking and evaluation studies across MDE tasks |
| `RQ13_mdetask_model_language_model_type_grouped_heatmap_other_tasks.pdf` | [RQ13 heatmap call](#rq13-heatmap-call) | Figure 19 | Heatmap of model types and modeling languages addressed by benchmarking and evaluation studies across MDE tasks (continued) |
| `RQ15_baselines_summary_bar.pdf` | `baselines(15)` | Figure 20 | Bar chart presenting the distribution of types of baselines employed by the primary studies |
| `RQ16_replication_component_summary_bar.pdf` | `replication(16)` | Figure 21 | Bar chart representing the distribution of types of artifacts made available as replication materials |

### Main-text tables

| Generated file | Function call(s) | Position in the paper | Content |
| --- | --- | --- | --- |
| `RQ2_venue.tex` | `rq2and3()` | Table 3 | Number of publications per venue |
| `RQ4_se.tex` | `seAnalysis(4)` | Table 5 | Papers for tackling SE problems |
| `RQ7_application_domain.tex` | `application(data = DATA_TO_ANALYSIS, rqNum = 7, label = "")` | Table 9 | Application domains of LLM-based MDE solutions |
| `RQ8_llm_version_size.tex` | `llm_model_version_size(8)` | Table 10 | Detailed versions and parameter sizes of LLMs used in the primary studies |
| `RQ11_integration_modeltype_GT1.tex` | `integration_model_type(11, function(x) x == 1, "_GT1")` | Table 11 | LLM Integration with MDE tools and platforms adopted in more than one primary study |
| `RQ11_integration_modeltype_one.tex` | `integration_model_type(11, function(x) x > 1, "_one")` | Table 12 | LLM integration with MDE tools and platforms adopted in only one primary study |
| `RQ13_proposed_vs_benchmark_mde_task_coverage.tex` | `benchmark_vs_proposed_problems(13)` | Table 13 | MDE tasks in proposed-approach studies vs. benchmarking and evaluation studies |
| `RQ13_benchmarks_application_domain.tex` | `application(data = Benchmarks_PAPERS, rqNum = 13, label = "_benchmarks")` | Table 14 | Application domains addressed in benchmarking and evaluation studies |
| `RQ13_benchmarks_comparison.tex` | `benchmarks_comparison(13)` | Table 15 | LLM and prompting-technique comparisons in benchmarking and evaluation studies |
| `RQ14_metrics_semantic.tex` | `eff_metrics(14)` | Table 17 | Semantic effectiveness metrics applied in the primary studies |
| `RQ14_metrics_nonsemantic.tex` | `eff_metrics(14)` | Table 18 | Syntactic and semantic-syntactic effectiveness metrics applied in the primary studies |
| `RQ14_mde_task_metrics.tex` | `mdetask_metric_table(14)` | Table 19 | Metrics used for evaluating different MDE tasks in the primary studies |
| `RQ14_cost_metrics.tex` | `cost_metrics(14)` | Table 20 | Cost metrics applied in the primary studies to assess LLM-based MDE solutions |
| `RQ16_components_replication.tex` | `replication(16)` | Table 21 | Replicable artifacts made available in the primary studies |
| `RQ16_replication.tex` | `replication(16)` | Table 22 | Summary of available artifacts provided for replication and evaluation |

### Appendix tables

| Generated file | Function call(s) | Position in the paper | Content |
| --- | --- | --- | --- |
| `RQ5_setask_mdetask.tex` | `setask_mdetask_table(5)` | Table 23 (Appendix) | Primary studies proposing solutions, grouped by MDE and SE task associations |
| `RQ6_model_type_category.tex` | `model_type_category_table(6)` | Table 24 (Appendix) | Primary studies proposing solutions, grouped by model type category |
| `RQ12_human_in_the_loop_summary.tex` | `human_in_loop_table(12)` | Table 25 (Appendix) | Primary studies reporting human-in-the-loop interaction patterns |
| `RQ13_model_type_category.tex` | `model_type_category_table(13, data = Benchmarks_PAPERS)` | Table 26 (Appendix) | Benchmarking and evaluation studies, grouped by model type category |
| `RQ15_baselines.tex` | `baselines(15)` | Table 27 (Appendix) | Primary studies reporting baseline comparisons, grouped by baseline type and MDE task |

### Heatmap calls

#### RQ6 heatmap call

```r
mdetask_modellanguage_modeltype_grouped_heatmap(
  DATA_TO_ANALYSIS, 6,
  first_width = 9, first_height = 11,
  first_wrap_task_label_width = 17, first_wrap_task_label = TRUE,
  second_width = 11, second_height = 15,
  second_tasks_per_row = 4, second_last_row_tasks = 5,
  second_wrap_task_label_width = 20, second_wrap_task_label = TRUE
)
```

#### RQ13 heatmap call

```r
mdetask_modellanguage_modeltype_grouped_heatmap(
  Benchmarks_PAPERS, 13,
  main_tasks = c("Model generation", "Model comprehension"),
  first_width = 8, first_height = 8, first_wrap_task_label = FALSE,
  second_width = 10, second_height = 3,
  second_tasks_per_row = 7, second_last_row_tasks = 7,
  second_wrap_task_label_width = 16, second_wrap_task_label = TRUE
)
```
