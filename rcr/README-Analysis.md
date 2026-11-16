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
install.packages(c("nombre", "UpSetR", "gridExtra", "ggplot2",
                   "ggpattern", "ggrepel", "ComplexUpset", "dplyr", "tidyr",
                   "stringr", "tidyverse", "RColorBrewer", "scales"))
```

Open a terminal in this directory and run:

```sh
Rscript LLM4MDE_SLR.R
```

Keep `Utils.R` beside the script, and the input CSV at
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
Rendering them may require packages such as `booktabs`.

Existing files with the same names are overwritten when the analysis runs.
Output filenames retain the analysis RQ numbering, which may differ from the
public CSV column numbering.
