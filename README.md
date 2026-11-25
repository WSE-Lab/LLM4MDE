# LLMs for Model-driven Engineering: A Systematic Literature Review

This repository provides artifacts for the Systematic Literature Review (SLR) titled: _LLMs for Model-driven Engineering: A Systematic Literature Review_.

During the SLR, we have the following data and supporting artifacts available:
* [`initial_search.csv`](data/initial_search.csv): This file contains the complete raw dataset obtained from the initial keyword search. It includes details of the 2,663 primary studies after removing duplicates across different databases.
* [`final_selection.csv`](data/final_selection.csv): This file presents the final set of 235 selected primary studies, derived from keyword searching and snowballing. The file covers raw data used to produce the results reported in the manuscript for the proposed research questions.
* [`index_reference.pdf`](data/index_reference.pdf): This file maps the IDs in `final_selection.csv` to the corresponding numbered references in the manuscript.

## Reproducing the analysis

The [`rcr/`](rcr/) directory contains the R scripts and generated
figures and LaTeX tables for reproducing the review's results.

- [`Search guide`](rcr/README-Search.md): Database-specific search queries for reproducing or extending the literature search.
- [`Analysis guide`](rcr/README-Analysis.md): Run the analysis using Docker or local R, generate results for each of the four perspectives, and read the output files.
- [`Generated results`](rcr/generated_files/): Figures (`.pdf`) and tables (`.tex`) produced by the analysis.

The pre-built Docker image includes R, the required packages, scripts, and input
data.
After installing and starting Docker,
run the following commands from the directory where you want to save the results:

```sh
docker pull manzh/llm4mde-r:1.0
docker run --rm -v "./outputs:/analysis/rcr/generated_files" manzh/llm4mde-r:1.0
```

Wait for the analysis to finish successfully before copying the results. Use a
new `outputs` directory to avoid nesting copied directories. No local R
installation or image build is required. See the analysis guide for interactive
function calls and saving results directly to a mounted output directory.

## Citation

If you use this code or dataset in your research, please cite our paper:

**Zhang, M., Li, Y., and Yue, T. (2026).**
LLMs for Model-driven Engineering: A Systematic Literature Review.
*ACM Transactions on Software Engineering and Methodology*.
https://doi.org/10.1145/3859883

```bibtex
@article{zhang2026llms,
  title   = {LLMs for Model-driven Engineering: A Systematic Literature Review},
  author  = {Zhang, Man and Li, Yunyang and Yue, Tao},
  journal = {ACM Transactions on Software Engineering and Methodology},
  year    = {2026},
  doi     = {10.1145/3859883}
}
```
