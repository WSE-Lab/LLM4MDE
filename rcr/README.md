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
