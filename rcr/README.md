# LLM4MDE SLR analysis

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

Keep `final_selection.csv`, `llm4MDE.bib`, and `Utils.R` beside the script.
Generated figures and LaTeX tables are saved in `generated_files/`.

## Generate results for each perspective

By default, the script runs all four perspectives:

| Function | Results |
| --- | --- |
| `group1Analysis()` | Publication years, venues, and paper types |
| `group2Analysis()` | Modeling languages, model types, MDE/SE tasks, and application domains |
| `group3Analysis()` | LLM families and versions, access modes, pipelines, prompting, enhancement, tool integration, and human interaction |
| `group4Analysis()` | Evaluation metrics, baselines, benchmarks, replication artifacts, and comparisons between benchmark and proposed-method studies |

To run one perspective, comment out the other three calls in the final **Invoke analysis functions** section of `LLM4MDE_SLR.R`, then run `Rscript LLM4MDE_SLR.R`. Keep `dir.create(...)` enabled.

Each perspective writes its figures (`.pdf`) and tables (`.tex`) to `generated_files/`. 
Existing files with the same names are overwritten. Output filenames retain the original analysis RQ numbering, which may differ from the public CSV column numbering.


## Example: generate the RQ1 answer

RQ1 examines how the number of publications changes over time. 
To generate only this result, replace the four perspective analysis calls in the final **Invoke analysis functions** section with:

```r
dir.create(GENERATED_FILES, recursive = TRUE, showWarnings = FALSE)
rq1()
print(RQ_results)
```

Run `Rscript LLM4MDE_SLR.R` from this directory. The publication trend is saved as `generated_files/RQ1_plot_num_publications_over_year.pdf`. The console shows the maximum annual publication count (`maxNumYear`) and the corresponding year(s) (`maxYear`).

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

## Database search queries

To support extending the review with recent studies, we provide database-specific search strings below. These strings do not restrict publication dates or publication types. After retrieval, remove duplicate records and screen the studies against the inclusion and exclusion criteria reported in the paper.

### ACM Digital Library

Search within the title, abstract, or keyword fields:

```text
[[[Title: "system modeling"] OR [Title: "software modeling"] OR [Title: "domain modeling"] OR [Title: "conceptual modeling"] OR [Title: "model-driven engineering"] OR [Title: "model driven engineering"] OR [Title: "mde"] OR [Title: "model-based software engineering"] OR [Title: "model-based system engineering"] OR [Title: "model based software engineering"] OR [Title: "model based system engineering"] OR [Title: "mbse"] OR [Title: "model-based engineering"] OR [Title: "model based engineering"] OR [Title: "mbe"] OR [Title: "model-based testing"] OR [Title: "model based testing"] OR [Title: "mbt"] OR [Title: "domain-specific modeling"] OR [Title: "dsm"] OR [Title: "mdd"] OR [Title: "mda"] OR [Title: "model-driven architecture"] OR [Title: "model driven architecture"] OR [Title: "model-driven development"] OR [Title: "model driven development"] OR [Title: "uml"] OR [Title: "sysml"] OR [Title: "ocl"] OR [Title: "bpmn"] OR [Title: "er"] OR [Title: "simulink"] OR [Title: "dsl"] OR [Title: "dsml"]] AND [[Title: "llm"] OR [Title: "llms"] OR [Title: "large language model"] OR [Title: "large language models"] OR [Title: "language model"] OR [Title: "language models"] OR [Title: "large model"] OR [Title: "large models"] OR [Title: "lm"] OR [Title: "generative language model"] OR [Title: "generative language models"] OR [Title: "generative model"] OR [Title: "generative models"] OR [Title: "generative ai"] OR [Title: "genai"] OR [Title: "gai"] OR [Title: "artificial general intelligence"] OR [Title: "agi"] OR [Title: "agentic ai"] OR [Title: "ai agent"] OR [Title: "ai agents"] OR [Title: "gpt"] OR [Title: "bert"] OR [Title: "t5"] OR [Title: "gemini"] OR [Title: "llama"] OR [Title: "claude"] OR [Title: "deepseek"] OR [Title: "grok"] OR [Title: "qwen"] OR [Title: "palm"]]]
OR [[[Abstract: "system modeling"] OR [Abstract: "software modeling"] OR [Abstract: "domain modeling"] OR [Abstract: "conceptual modeling"] OR [Abstract: "model-driven engineering"] OR [Abstract: "model driven engineering"] OR [Abstract: "mde"] OR [Abstract: "model-based software engineering"] OR [Abstract: "model-based system engineering"] OR [Abstract: "model based software engineering"] OR [Abstract: "model based system engineering"] OR [Abstract: "mbse"] OR [Abstract: "model-based engineering"] OR [Abstract: "model based engineering"] OR [Abstract: "mbe"] OR [Abstract: "model-based testing"] OR [Abstract: "model based testing"] OR [Abstract: "mbt"] OR [Abstract: "domain-specific modeling"] OR [Abstract: "dsm"] OR [Abstract: "mdd"] OR [Abstract: "mda"] OR [Abstract: "model-driven architecture"] OR [Abstract: "model driven architecture"] OR [Abstract: "model-driven development"] OR [Abstract: "model driven development"] OR [Abstract: "uml"] OR [Abstract: "sysml"] OR [Abstract: "ocl"] OR [Abstract: "bpmn"] OR [Abstract: "er"] OR [Abstract: "simulink"] OR [Abstract: "dsl"] OR [Abstract: "dsml"]] AND [[Abstract: "llm"] OR [Abstract: "llms"] OR [Abstract: "large language model"] OR [Abstract: "large language models"] OR [Abstract: "language model"] OR [Abstract: "language models"] OR [Abstract: "large model"] OR [Abstract: "large models"] OR [Abstract: "lm"] OR [Abstract: "generative language model"] OR [Abstract: "generative language models"] OR [Abstract: "generative model"] OR [Abstract: "generative models"] OR [Abstract: "generative ai"] OR [Abstract: "genai"] OR [Abstract: "gai"] OR [Abstract: "artificial general intelligence"] OR [Abstract: "agi"] OR [Abstract: "agentic ai"] OR [Abstract: "ai agent"] OR [Abstract: "ai agents"] OR [Abstract: "gpt"] OR [Abstract: "bert"] OR [Abstract: "t5"] OR [Abstract: "gemini"] OR [Abstract: "llama"] OR [Abstract: "claude"] OR [Abstract: "deepseek"] OR [Abstract: "grok"] OR [Abstract: "qwen"] OR [Abstract: "palm"]]]
OR [[[Keywords: "system modeling"] OR [Keywords: "software modeling"] OR [Keywords: "domain modeling"] OR [Keywords: "conceptual modeling"] OR [Keywords: "model-driven engineering"] OR [Keywords: "model driven engineering"] OR [Keywords: "mde"] OR [Keywords: "model-based software engineering"] OR [Keywords: "model-based system engineering"] OR [Keywords: "model based software engineering"] OR [Keywords: "model based system engineering"] OR [Keywords: "mbse"] OR [Keywords: "model-based engineering"] OR [Keywords: "model based engineering"] OR [Keywords: "mbe"] OR [Keywords: "model-based testing"] OR [Keywords: "model based testing"] OR [Keywords: "mbt"] OR [Keywords: "domain-specific modeling"] OR [Keywords: "dsm"] OR [Keywords: "mdd"] OR [Keywords: "mda"] OR [Keywords: "model-driven architecture"] OR [Keywords: "model driven architecture"] OR [Keywords: "model-driven development"] OR [Keywords: "model driven development"] OR [Keywords: "uml"] OR [Keywords: "sysml"] OR [Keywords: "ocl"] OR [Keywords: "bpmn"] OR [Keywords: "er"] OR [Keywords: "simulink"] OR [Keywords: "dsl"] OR [Keywords: "dsml"]] AND [[Keywords: "llm"] OR [Keywords: "llms"] OR [Keywords: "large language model"] OR [Keywords: "large language models"] OR [Keywords: "language model"] OR [Keywords: "language models"] OR [Keywords: "large model"] OR [Keywords: "large models"] OR [Keywords: "lm"] OR [Keywords: "generative language model"] OR [Keywords: "generative language models"] OR [Keywords: "generative model"] OR [Keywords: "generative models"] OR [Keywords: "generative ai"] OR [Keywords: "genai"] OR [Keywords: "gai"] OR [Keywords: "artificial general intelligence"] OR [Keywords: "agi"] OR [Keywords: "agentic ai"] OR [Keywords: "ai agent"] OR [Keywords: "ai agents"] OR [Keywords: "gpt"] OR [Keywords: "bert"] OR [Keywords: "t5"] OR [Keywords: "gemini"] OR [Keywords: "llama"] OR [Keywords: "claude"] OR [Keywords: "deepseek"] OR [Keywords: "grok"] OR [Keywords: "qwen"] OR [Keywords: "palm"]]]
```

### IEEE Xplore

We use three sub-strings in Command Search, targeting the abstract, document title, and author keywords separately. Run all three, then merge and deduplicate the results.

**Sub-string 1: Abstract**

```text
(("Abstract": "system modeling" OR "Abstract": "software modeling" OR "Abstract": "domain modeling" OR "Abstract": "conceptual modeling" OR "Abstract": "model-driven engineering" OR "Abstract": "model driven engineering" OR "Abstract": "MDE" OR "Abstract": "model-based software engineering" OR "Abstract": "model-based system engineering" OR "Abstract": "model based software engineering" OR "Abstract": "model based system engineering" OR "Abstract": "MBSE" OR "Abstract": "model-based engineering" OR "Abstract": "model based engineering" OR "Abstract": "MBE" OR "Abstract": "model-based testing" OR "Abstract": "model based testing" OR "Abstract": "MBT" OR "Abstract": "domain-specific modeling" OR "Abstract": "DSM" OR "Abstract": "MDD" OR "Abstract": "MDA" OR "Abstract": "model-driven architecture" OR "Abstract": "model driven architecture" OR "Abstract": "model-driven development" OR "Abstract": "model driven development" OR "Abstract": "UML" OR "Abstract": "SysML" OR "Abstract": "OCL" OR "Abstract": "BPMN" OR "Abstract": "ER" OR "Abstract": "Simulink" OR "Abstract": "DSL" OR "Abstract": "DSML") AND ("Abstract": "LLM*" OR "Abstract": "Large Language Model*" OR "Abstract": "Language Model*" OR "Abstract": "Large Model*" OR "Abstract": "LM" OR "Abstract": "Generative Language Model*" OR "Abstract": "Generative Model*" OR "Abstract": "Generative AI" OR "Abstract": "GenAI" OR "Abstract": "GAI" OR "Abstract": "Artificial General Intelligence" OR "Abstract": "AGI" OR "Abstract": "Agentic AI" OR "Abstract": "AI Agent" OR "Abstract": "AI Agents" OR "Abstract": "GPT" OR "Abstract": "BERT" OR "Abstract": "T5" OR "Abstract": "Gemini" OR "Abstract": "Llama" OR "Abstract": "Claude" OR "Abstract": "DeepSeek" OR "Abstract": "Grok" OR "Abstract": "Qwen" OR "Abstract": "PaLM") )
```

**Sub-string 2: Document Title**

```text
("Document Title": "system modeling" OR "Document Title": "software modeling" OR "Document Title": "domain modeling" OR "Document Title": "conceptual modeling" OR "Document Title": "model-driven engineering" OR "Document Title": "model driven engineering" OR "Document Title": "MDE" OR "Document Title": "model-based software engineering" OR "Document Title": "model-based system engineering" OR "Document Title": "model based software engineering" OR "Document Title": "model based system engineering" OR "Document Title": "MBSE" OR "Document Title": "model-based engineering" OR "Document Title": "model based engineering" OR "Document Title": "MBE" OR "Document Title": "model-based testing" OR "Document Title": "model based testing" OR "Document Title": "MBT" OR "Document Title": "domain-specific modeling" OR "Document Title": "DSM" OR "Document Title": "MDD" OR "Document Title": "MDA" OR "Document Title": "model-driven architecture" OR "Document Title": "model driven architecture" OR "Document Title": "model-driven development" OR "Document Title": "model driven development" OR "Document Title": "UML" OR "Document Title": "SysML" OR "Document Title": "OCL" OR "Document Title": "BPMN" OR "Document Title": "ER" OR "Document Title": "Simulink" OR "Document Title": "DSL" OR "Document Title": "DSML")
AND
("Document Title": "LLM*" OR "Document Title": "Large Language Model*" OR "Document Title": "Language Model*" OR "Document Title": "Large Model*" OR "Document Title": "LM" OR "Document Title": "Generative Language Model*" OR "Document Title": "Generative Model*" OR "Document Title": "Generative AI" OR "Document Title": "GenAI" OR "Document Title": "GAI" OR "Document Title": "Artificial General Intelligence" OR "Document Title": "AGI" OR "Document Title": "Agentic AI" OR "Document Title": "AI Agent" OR "Document Title": "AI Agents" OR "Document Title": "GPT" OR "Document Title": "BERT" OR "Document Title": "T5" OR "Document Title": "Gemini" OR "Document Title": "Llama" OR "Document Title": "Claude" OR "Document Title": "DeepSeek" OR "Document Title": "Grok" OR "Document Title": "Qwen" OR "Document Title": "PaLM")
```

**Sub-string 3: Author Keywords**

```text
("Author Keywords": "system modeling" OR "Author Keywords": "software modeling" OR "Author Keywords": "domain modeling" OR "Author Keywords": "conceptual modeling" OR "Author Keywords": "model-driven engineering" OR "Author Keywords": "model driven engineering" OR "Author Keywords": "MDE" OR "Author Keywords": "model-based software engineering" OR "Author Keywords": "model-based system engineering" OR "Author Keywords": "model based software engineering" OR "Author Keywords": "model based system engineering" OR "Author Keywords": "MBSE" OR "Author Keywords": "model-based engineering" OR "Author Keywords": "model based engineering" OR "Author Keywords": "MBE" OR "Author Keywords": "model-based testing" OR "Author Keywords": "model based testing" OR "Author Keywords": "MBT" OR "Author Keywords": "domain-specific modeling" OR "Author Keywords": "DSM" OR "Author Keywords": "MDD" OR "Author Keywords": "MDA" OR "Author Keywords": "model-driven architecture" OR "Author Keywords": "model driven architecture" OR "Author Keywords": "model-driven development" OR "Author Keywords": "model driven development" OR "Author Keywords": "UML" OR "Author Keywords": "SysML" OR "Author Keywords": "OCL" OR "Author Keywords": "BPMN" OR "Author Keywords": "ER" OR "Author Keywords": "Simulink" OR "Author Keywords": "DSL" OR "Author Keywords": "DSML")
AND
("Author Keywords": "LLM*" OR "Author Keywords": "Large Language Model*" OR "Author Keywords": "Language Model*" OR "Author Keywords": "Large Model*" OR "Author Keywords": "LM" OR "Author Keywords": "Generative Language Model*" OR "Author Keywords": "Generative Model*" OR "Author Keywords": "Generative AI" OR "Author Keywords": "GenAI" OR "Author Keywords": "GAI" OR "Author Keywords": "Artificial General Intelligence" OR "Author Keywords": "AGI" OR "Author Keywords": "Agentic AI" OR "Author Keywords": "AI Agent" OR "Author Keywords": "AI Agents" OR "Author Keywords": "GPT" OR "Author Keywords": "BERT" OR "Author Keywords": "T5" OR "Author Keywords": "Gemini" OR "Author Keywords": "Llama" OR "Author Keywords": "Claude" OR "Author Keywords": "DeepSeek" OR "Author Keywords": "Grok" OR "Author Keywords": "Qwen" OR "Author Keywords": "PaLM")
```

### Scopus

Use Advanced Search with title, abstract, and keyword fields.

```text
TITLE-ABS-KEY ( ( "system modeling" OR "software modeling" OR "domain modeling" OR "conceptual modeling" OR "model-driven engineering" OR "model driven engineering" OR "MDE" OR "model-based software engineering" OR "model-based system engineering" OR "model based software engineering" OR "model based system engineering" OR "MBSE" OR "model-based engineering" OR "model based engineering" OR "MBE" OR "model-based testing" OR "model based testing" OR "MBT" OR "domain-specific modeling" OR "DSM" OR "MDD" OR "MDA" OR "model-driven architecture" OR "model driven architecture" OR "model-driven development" OR "model driven development" OR "UML" OR "SysML" OR "OCL" OR "BPMN" OR "ER" OR "Simulink" OR "DSL" OR "DSML" ) AND ( "LLM*" OR "Large Language Model*" OR "Language Model*" OR "Large Model*" OR "LM" OR "Generative Language Model*" OR "Generative Model*" OR "Generative AI" OR "GenAI" OR "GAI" OR "Artificial General Intelligence" OR "AGI" OR "Agentic AI" OR "AI Agent" OR "AI Agents" OR "GPT" OR "BERT" OR "T5" OR "Gemini" OR "Llama" OR "Claude" OR "DeepSeek" OR "Grok" OR "Qwen" OR "PaLM" ) )
```

### Web of Science

Use the Topic (`TS`) field in Advanced Search, which searches titles, abstracts, and author keywords:

```text
TS=(("system modeling" OR "software modeling" OR "domain modeling" OR "conceptual modeling" OR "model-driven engineering" OR "model driven engineering" OR "MDE" OR "model-based software engineering" OR "model-based system engineering" OR "model based software engineering" OR "model based system engineering" OR "MBSE" OR "model-based engineering" OR "model based engineering" OR "MBE" OR "model-based testing" OR "model based testing" OR "MBT" OR "domain-specific modeling" OR "DSM" OR "MDD" OR "MDA" OR "model-driven architecture" OR "model driven architecture" OR "model-driven development" OR "model driven development" OR "UML" OR "SysML" OR "OCL" OR "BPMN" OR "ER" OR "Simulink" OR "DSL" OR "DSML") AND ("LLM*" OR "Large Language Model*" OR "Language Model*" OR "Large Model*" OR "LM" OR "Generative Language Model*" OR "Generative Model*" OR "Generative AI" OR "GenAI" OR "GAI" OR "Artificial General Intelligence" OR "AGI" OR "Agentic AI" OR "AI Agent" OR "AI Agents" OR "GPT" OR "BERT" OR "T5" OR "Gemini" OR "Llama" OR "Claude" OR "DeepSeek" OR "Grok" OR "Qwen" OR "PaLM"))
```

### Springer Nature Link

Springer does not provide a search option restricted to titles, abstracts, and keywords. We therefore use the following query across all searchable content:

```text
("system modeling" OR "software modeling" OR "domain modeling" OR "conceptual modeling" OR "model-driven engineering" OR "model driven engineering" OR "MDE" OR "model-based software engineering" OR "model-based system engineering" OR "model based software engineering" OR "model based system engineering" OR "MBSE" OR "model-based engineering" OR "model based engineering" OR "MBE" OR "model-based testing" OR "model based testing" OR "MBT" OR "domain-specific modeling" OR "DSM" OR "MDD" OR "MDA" OR "model-driven architecture" OR "model driven architecture" OR "model-driven development" OR "model driven development" OR "UML" OR "SysML" OR "OCL" OR "BPMN" OR "ER" OR "Simulink" OR "DSL" OR "DSML")
AND
("LLM" OR "LLMs" OR "Large Language Model" OR "Large Language Models" OR "Language Model" OR "Language Models" OR "Large Model" OR "Large Models" OR "LM" OR "Generative Language Model" OR "Generative Language Models" OR "Generative Model" OR "Generative Models" OR "Generative AI" OR "GenAI" OR "GAI" OR "Artificial General Intelligence" OR "AGI" OR "Agentic AI" OR "AI Agent" OR "AI Agents" OR "GPT" OR "BERT" OR "T5" OR "Gemini" OR "Llama" OR "Claude" OR "DeepSeek" OR "Grok" OR "Qwen" OR "PaLM")
```
