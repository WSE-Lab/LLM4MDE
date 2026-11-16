# LLM4MDE SLR analysis. Run from this directory: Rscript LLM4MDE_SLR.R
# ==================== Libraries ====================
library(nombre)
library(UpSetR)
library(gridExtra)
library(grid)
library(bibtex)
library(ggplot2)
library(ggpattern)
library(ggrepel)
library(ComplexUpset)
library(dplyr)
library(tidyr)
library(stringr)
library(tidyverse)
library(RColorBrewer)
library(scales)

# ==================== Global variables ====================

PAPERS <- "final_selection.csv"

PAPER_BIB_FILE_PATH <- "llm4MDE.bib"

GENERATED_FILES <- "generated_files"

LATEX_DIR <- "."

BIBFILE <- PAPER_BIB_FILE_PATH

YES_EXP = c("Y", "Y*", "YES", "YES*", "[Y]", "[Y*]", "[YES]", "[YES*]")

ALL_DATA <- read.csv(PAPERS, header = TRUE)

ALL_BIB <- bibtex::read.bib(PAPER_BIB_FILE_PATH)

COLLECTION_SELECTED_ROW = "isSelected."

COLLECTION_SNOWBALLING_ROW = "Snowballing."

COLLECTION_BIBINFO_ROW = "BibTex"

ALL_SELECTED <- ALL_DATA

APPROACH_PAPERS = subset(ALL_SELECTED, ALL_SELECTED$RQ3.PaperType == "Proposed method")

Benchmarks_PAPERS = subset(ALL_SELECTED, ALL_SELECTED$RQ3.PaperType == "Benchmarking and evaluation")

TOTAL_NUM_SELECTED_PAPERS <- nrow(ALL_SELECTED)

RESULTS_BIBTEX = paste(GENERATED_FILES, "/selected_paper_bib.bib", sep = "")

RESULTS_COLLECTIONS = paste(GENERATED_FILES, "/collection_statistics.tex", sep = "")

RESULTS_CMD = paste(GENERATED_FILES, "/RQ_results.tex", sep = "")

DATABASES = c("IEEE", "ACM", "Scopus", "Wiley", "WoS", "Springer")

DATABASES_FULL_NAME = c("IEEE\\emph{Xplore}", "ACM", "Scopus", "Wiley", "Web of Science", "Springer Nature Link")

DATABASES_INITAL = c(179, 66, 845, 0, 706, 932)

DATABASES_INTIAL_TOTAL = 2066

FULL_DATABASES = c("IEEE", "ACM", "Scopus", "Web", "Springer", "Wiley", "Arxiv")

DATA_TO_ANALYSIS <- APPROACH_PAPERS

RQ_results <- data.frame(prefix = character(0), command = character(0), content = character(0), stringsAsFactors = FALSE)

model_type_category_mapping <- list(`Requirement/\nGoal` = c("Requirement", "Requirement Specification", "Use Case", 
    "Goal", "Problem", "Purposive", "Decision"), Behavior = c("Process", "Activity", "State Machine", "Sequence", 
    "Interaction", "Communication", "Collaboration", "Timing", "Flowchart", "Reaction Network", "Program Graph", 
    "Data Flow"), `Structure/\nArchitecture` = c("Class", "Object", "Block", "Block Definition", "Internal Block", 
    "Package", "Composite Structure", "Data", "Multi-level", "Value", "Business Capability Map", "Dimensional Fact", 
    "Architecture", "Component", "Deployment", "Context"), `Knowledge/\nDomain` = c("Ontology", "Taxonomy", "DSM"), 
    Constraint = c("Constraint", "Legal Contract", "Smart Contract"), Verification = c("Assurance Case", "Test Scenario", 
        "Safety Case"), Others = c("Causal", "Query", "Crash Description", "Crisis Management", "Task Specification"))

category_mapping <- list(`Transportation Systems` = c("Automotive Systems", "ADS", "Advanced Driver Assistance Systems (ADASs)", 
    "Train Autonomous Control System"), `Aerospace Systems` = c("Aircraft", "Spacecraft", "Aerospace"), `Computing and Digital Systems` = c("Cloud computing", 
    "Embedded system", "Enterprise Digital Twins", "Network", "IoT", "CPS", "Collective adaptive systems", "Robotic Process Automation", 
    "Smart TVs", "Collective adaptive systems", "Robotic"), `Energy and Power Systems` = c("Electric Power Industry"), 
    `Business and Enterprise Systems` = c("Business"), `Governance and Public Systems` = c("Crisis management", 
        "Public administration"), `Education Systems` = c("Education"), `Healthcare Systems` = c("Healthcare"), 
    `General Systems` = c("General"))

application_domain_category_definition_mapping <- list(`Transportation Systems` = "Systems concerned with transportation, mobility, and vehicle operation, including automotive, driver-assistance, train control, and autonomous driving systems.", 
    `Aerospace Systems` = "Systems used in aviation, spacecraft, and broader aerospace contexts where modeling supports design, operation, analysis, or assurance of aerospace artifacts.", 
    `Computing and Digital Systems` = "Software-intensive and cyber-physical digital systems, including cloud, embedded, networked, IoT, CPS, digital twin, robotic, adaptive, and smart-device systems.", 
    `Energy and Power Systems` = "Systems related to energy production, delivery, monitoring, or operation, including electric power industry applications.", 
    `Business and Enterprise Systems` = "Systems that support business processes, organizational operations, enterprise workflows, or enterprise-level digital transformation.", 
    `Governance and Public Systems` = "Systems used for public administration, governance, emergency response, crisis management, or services operated in public-sector contexts.", 
    `Education Systems` = "Systems and applications used in educational settings, including learning, teaching, training, and educational support scenarios.", 
    `Healthcare Systems` = "Systems and applications used in healthcare contexts, including clinical, medical, patient-care, and health-service scenarios.", 
    `General Systems` = "General-purpose or domain-independent systems where no specific application domain is identified.")

model_type_category_definition_mapping <- list(`Requirement/\nGoal` = "Models that capture desired system capabilities, stakeholder intentions, usage scenarios, problems, or goals that motivate system development.", 
    Behavior = "Models that describe dynamic system behavior, including processes, activities, interactions, states, event sequences, communication, timing, data or control flows, and executable graphs.", 
    `Structure/\nArchitecture` = "Models that describe static system, software, or business organization, including entities, relationships, architectural elements, components, packages, deployments, contexts, multi-level structures, and value structures.", 
    `Knowledge/\nDomain` = "Models that capture domain knowledge, concepts, classifications, or domain-specific abstractions, including ontologies, taxonomies, and domain-specific models.", 
    Constraint = "Models that specify rules, restrictions, contracts, or conditions that must hold for a system, process, or generated artifact.", 
    Verification = "Models used to support validation, verification, assurance, or testing, including assurance cases, safety cases and test scenarios.", 
    Others = "Model types that do not fit the preceding categories or represent specialized modeling purposes such as causal reasoning, crash descriptions, crisis management or task specification.")

metric_category_mapping <- list(`LLM-based solution metrics` = c("Accuracy", "Precision", "Precision@k", "Recall", 
    "Recall@k", "F-measure", "F-measure@k", "Macro F1", "Soft F-measure", "Soft precision", "Soft recall", "BLEU", 
    "BLEU@k", "SacreBLEU", "METEOR", "METEOR@k", "BERTScore", "EM (Exact match)", "Pass@k", "Hits@k", "MAP@k", 
    "MRR", "MRR@k", "NDCGp (Normalized Discounted Cumulative Gain at p)", "Success rate", "Success rate@k", "Validity", 
    "Validity@k", "Error rate"), `Model related \\#/\\% metrics` = c("# of correct elements", "# of correct models", 
    "# of correct outputs", "# of covered elements", "# of enhanced elements", "# of hallucinated elements", "# of inconsistencies", 
    "# of incorrect elements", "# of incorrect models", "# of incorrect outputs", "# of misplaced elements", "# of missing auxiliary elements", 
    "# of missing elements", "# of neutral additional elements", "# of out-of-scope additional elements", "# of pragmatic errors", 
    "# of preserved auxiliary elements", "# of relevant additional elements", "# of specific elements", "# of syntactic errors", 
    "# of unnecessary elements", "# of unsatisfied requirements", "# of violations of consistency rules", "% of acceptable models", 
    "% of correct elements", "% of correct models", "% of correct outputs", "% of covered elements", "% of granularity variations", 
    "% of hallucinated elements", "% of incorrect elements", "% of incorrect models", "% of models conforming to semantic constraints", 
    "% of models satisfying semantic constraints", "% of relevant additional elements", "% of satisfied constraints", 
    "Clarity rate", "Contribution rate", "Importability rate", "Size", "Density", "Cohesion", "Separability", "Variability", 
    "Richness", "Information content", "Discrepancy in # of elements"), `Distance metrics` = c("Alignment score", 
    "Behavioral similarity", "Cosine similarity", "Cosine similarity@k", "Euclidean distance", "Graph edit distance", 
    "Jaccard similarity", "Levenshtein distance", "Model distance", "Overlap coefficient", "SSIM (Structural similarity index measure)", 
    "Similarity score", "Structural similarity", "TEDS (Tree-Edit-Distance-based Similarity)"), `Rating-based metrics` = c("Advanced features rating", 
    "Clarity rating", "Ease of updating rating", "Pragmatic rating", "Rating", "Readability rating", "Reasonability rating", 
    "Redundancy rating", "Relevance rating", "Similarity rating", "Simplicity rating", "Terminological alignment rating", 
    "Understandability rating"), Others = c("ET-Conformance precision", "Footprint-based fitness", "Specificity", 
    "Token-based fitness", "XCORE"))

metric_category_colors <- list(`LLM-based solution metrics` = "blue!12", `Model related \\#/\\% metrics` = "green!12", 
    `Distance metrics` = "orange!16", `Rating-based metrics` = "purple!12", Others = "gray!15")

INVALID_VALUE <- c("un-specified", "unspecified", "n/a", "no", "[no]")

# ==================== Utility functions ====================
source("Utils.R")

# ==================== Analysis functions ====================

generateCmdForSelectedPapers <- function() {
    titles <- ALL_SELECTED$Title
    indexs <- ALL_SELECTED$ID
    missingPaper <- c()
    duplicated <- c()
    index <- 0
    for (e in titles) {
        index <- index + 1
        eindex <- indexs[index]
        found <- findPapers(e)
        if (length(found) >= 1) {
            if (length(found) > 1) {
                duplicated <- append(duplicated, e)
            }
            id <- paste("\\newcommand{\\paper", formatString(nom_ord(strtoi(eindex))), "}{", found[1], "}", sep = "")
            cat(id, "\n", sep = "")
        }
        else if (length(found) == 0) {
            missingPaper <- append(missingPaper, e)
        }
    }
    if (length(missingPaper) > 0) {
        cat("\n\n%=================Missing=================\n", sep = "")
        for (nr in missingPaper) {
            cat("%", nr, "\n")
        }
    }
    if (length(duplicated) > 0) {
        cat("\n\n%=================Duplicated=================\n", sep = "")
        for (nr in duplicated) {
            cat("%", nr, "\n")
        }
    }
}


getfinalSelectNumByDb <- function(dbName, data_to_analysis) {
    rows <- subset(data_to_analysis, grepl(dbName, data_to_analysis$Source))
    return(nrow(rows))
}

group1Analysis <- function() {
    rq1()
    rq2and3()
    rq2And3StackedBar()
}

group2Analysis <- function() {
    modelAnalysis(6)
    mdeAnalysis(5)
    setask_mdetask_stacked_bar(5)
    setask_mdetask_table(5)
    model_generation(5)
    mdetask_modellanguage(6)
    models_modellanguage(5)
    model_generation_modellanguage(5)
    mdetask_modellanguage_modeltype_grouped_heatmap(DATA_TO_ANALYSIS, 6, first_width = 9, first_height = 11, first_wrap_task_label_width = 17,
        first_wrap_task_label = TRUE, second_width = 11, second_height = 15, second_tasks_per_row = 4, second_last_row_tasks = 5, 
        second_wrap_task_label_width = 20, second_wrap_task_label = TRUE)
    seAnalysis(6)
    application_domain_category_definition(7)
    application(data = DATA_TO_ANALYSIS, 7, label = "")
}

group3Analysis <- function() {
    llm_foundation_model(8)
    llm_model_version_size(8)
    llm_used(8)
    llm_pipeline(8)
    prompt_techniques(9)
    integration(11)
    integration_model_type(11, function(x) {
        return(x > 1)
    }, "_one")
    integration_model_type(11, function(x) {
        return(x == 1)
    }, "_GT1")
    human_in_loop(12)
    human_in_loop_table(12)
    LLM_enhanced(10)
}

group4Analysis <- function() {
    model_type_category_table(13, data = Benchmarks_PAPERS)
    eff_metrics(14)
    mdetask_metric_table(14)
    cost_metrics(14)
    mdetask_modellanguage_modeltype_grouped_heatmap(Benchmarks_PAPERS, 13, main_tasks = c("Model generation", "Model comprehension"), 
        first_width = 8, first_height = 8, first_wrap_task_label = FALSE, second_width = 10, second_height = 3, 
        second_tasks_per_row = 7, second_last_row_tasks = 7, second_wrap_task_label_width = 16, second_wrap_task_label = TRUE)
    benchmark_vs_proposed_problems(13)
    baselines(15)
    benchmarks(15)
    replication(16)
    benchmarks_comparison(13)
    benchmarks_problems(13)
    application(data = Benchmarks_PAPERS, 13, label = "_benchmarks")
}

rq1 <- function() {
    yearsIndb <- sort(unique(ALL_SELECTED$RQ1.Year))
    nums <- c()
    years <- c()
    for (year in yearsIndb) {
        num <- nrow(subset(ALL_SELECTED, ALL_SELECTED$RQ1.Year == year))
        nums <- append(nums, num)
        years <- append(years, as.integer(extractContentInSquareBrackets(year)))
    }
    data <- data.frame(year = c(years), value = c(nums)) %>% tidyr::complete(year = seq.int(2017, max(year)), fill = list(value = 0))
    RQ1_label <- RQ_label_prefix(1)
    RQ_results <<- rbind(RQ_results, c(RQ1_label, "maxNumYear", max(nums)))
    maxYears <- (subset(data, data$value == max(nums)))$year
    if (length(maxYears) == 1) 
        RQ_results <<- rbind(RQ_results, c(RQ1_label, "maxYear", maxYears[1]))
    else {
        for (i in 1:length(maxYears)) {
            RQ_results <<- rbind(RQ_results, c(RQ1_label, paste("maxYear", formatString(nom_ord(strtoi(i))), sep = ""), 
                maxYears[i]))
        }
    }
    ggplot(data, aes(x = year, y = value)) + geom_line(color = "black", linewidth = 1) + geom_point(color = "black", 
        size = 3, shape = 16) + scale_x_continuous(breaks = data$year, labels = ifelse(data$year == 2025, "Oct-2025", 
        data$year)) + geom_text(aes(label = value), vjust = -1, hjust = ifelse(data$year %in% c(2022, 2025), -0.2, 
        0.5), color = "black", size = 4) + labs(title = "Trend Over Years", x = "Year", y = "Number of Papers") + 
        theme_bw() + theme(panel.grid = element_blank(), plot.title = element_text(size = 14, hjust = 0.5), axis.text.x = element_text(size = 12), 
        axis.text.y = element_text(size = 12), axis.title.x = element_text(size = 13), axis.title.y = element_text(size = 13))
    ggsave(paste(GENERATED_FILES, "/RQ1_plot_num_publications_over_year.pdf", sep = ""), width = 8, height = 6, 
        dpi = 300)
}

rq2and3 <- function() {
    ALL_SELECTED$RQ3.VenueType <- trimws(ALL_SELECTED$RQ3.VenueType)
    venue_groups <- ALL_SELECTED %>% distinct(RQ2.Venue, RQ3.VenueType) %>% arrange(RQ2.Venue, RQ3.VenueType)
    nums <- c()
    venues <- c()
    venuetypes <- c()
    rename_venues <- c()
    papertypes <- c()
    for (i in seq_len(nrow(venue_groups))) {
        v <- venue_groups$RQ2.Venue[i]
        vt <- venue_groups$RQ3.VenueType[i]
        results <- subset(ALL_SELECTED, ALL_SELECTED$RQ2.Venue == v & ALL_SELECTED$RQ3.VenueType == vt)
        venue <- extractContentInSquareBrackets(v)
        venuetype <- extractContentInSquareBrackets(vt)
        num <- nrow(results)
        nums <- append(nums, num)
        venues <- append(venues, venue)
        venuetypes <- append(venuetypes, venuetype)
        if (num > 2) {
            rename_venues <- append(rename_venues, venue)
        }
        else {
            rename_venues <- append(rename_venues, paste("Other ", venuetype, sep = ""))
        }
    }
    data <- data.frame(venue = venues, venueType = trimws(venuetypes), venueAKA = rename_venues, value = nums)
    rq2Table(data)
    rq3VenueType()
    rq3PaperType()
}

rq2And3StackedBar <- function() {
    types_venues_papers <- ALL_SELECTED[, c("RQ3.VenueType", "RQ3.PaperType")]
    types_venues_papers$RQ3.VenueType <- trimws(types_venues_papers$RQ3.VenueType)
    types_venues_papers$RQ3.PaperType <- trimws(types_venues_papers$RQ3.PaperType)
    freq_types_venues_papers <- as.data.frame(table(types_venues_papers$RQ3.VenueType, types_venues_papers$RQ3.PaperType))
    colnames(freq_types_venues_papers) <- c("Items", "Category", "Freq")
    stackedBarChart(data = freq_types_venues_papers, xLabel = "Type of Venue", yLabel = "# of Papers", legendTitle = "Paper Type", 
        fileName = "RQ3_types_venue_paper_stacked_bar_number")
}

modelAnalysis <- function(rqNum) {
    modelinglanguage(rqNum)
    modelType(rqNum)
    modelCategory(rqNum)
    model_type_category_definition(rqNum)
    model_type_category(rqNum)
    model_type_category_table(rqNum)
}

mdeAnalysis <- function(rqNum) {
    MDEtasks <- removeItems(extractAll(DATA_TO_ANALYSIS$RQ5.MDETask), c("N/A"))
    orderBarFile <- paste("RQ", rqNum, "_MDE_tasks", sep = "")
    orderBarChart(data = MDEtasks, xLabel = "Number of papers associated with each MDE Tasks", yLabel = "MDE Tasks", 
        orderBarFile, width = 14, height = 8, coord_fixed_ratio = 2.5)
    freq_df <- as.data.frame(table(MDEtasks))
    freq_df <- freq_df[order(freq_df$Freq, decreasing = TRUE), ]
    RQ_label <- RQ_label_prefix(rqNum)
    for (i in 1:min(4, nrow(freq_df))) {
        RQ_results <<- rbind(RQ_results, c(RQ_label, paste("top", formatString(nom_ord(strtoi(i))), "MDETaskNum", 
            sep = ""), freq_df$Freq[i]))
        RQ_results <<- rbind(RQ_results, c(RQ_label, paste("top", formatString(nom_ord(strtoi(i))), "MDETask", 
            sep = ""), emphExp(as.character(freq_df$MDETasks)[i])))
        RQ_results <<- rbind(RQ_results, c(RQ_label, paste("percentTop", formatString(nom_ord(strtoi(i))), "MDETaskNum", 
            sep = ""), paste(formatC((freq_df$Freq[i]) * 100/TOTAL_NUM_SELECTED_PAPERS, digits = 2, format = "f"), 
            "\\%", sep = "")))
    }
}

setask_mdetask_stacked_bar <- function(rqNum, data = DATA_TO_ANALYSIS) {
    setask_mdetask_col <- "RQ5.SETaskMDETask"
    mdetask_setask_col <- "RQ4.MDETaskSETask"
    if (setask_mdetask_col %in% names(data)) {
        task_col <- setask_mdetask_col
        group_is_setask <- TRUE
    }
    else if (mdetask_setask_col %in% names(data)) {
        task_col <- mdetask_setask_col
        group_is_setask <- FALSE
    }
    else {
        stop("Missing RQ4 SETask-MDETask mapping column.")
    }
    invalid_values <- c("", "n/a", "unspecified", "null")
    task_pairs <- data.frame(ID = character(), MDETask = character(), SETask = character())
    for (i in seq_len(nrow(data))) {
        raw_value <- data[[task_col]][i]
        if (is.na(raw_value) || trimws(raw_value) == "") {
            next
        }
        groups <- regmatches(raw_value, gregexpr("\\[([^]]+)\\]", raw_value, perl = TRUE))[[1]]
        if (length(groups) == 0) {
            groups <- raw_value
        }
        for (group_text in groups) {
            group_text <- gsub("^\\[|\\]$", "", group_text)
            group_data <- extractGroupNameAndContentAsDataframe(group_text, groupNameIfNull = "None")
            group_name <- trimws(group_data$groupName)
            group_content <- trimws(group_data$groupContent)
            if (is.null(group_name) || is.na(group_name) || group_name == "") {
                group_name <- "None"
            }
            if (is.na(group_content) || tolower(group_content) %in% invalid_values) {
                next
            }
            content_items <- trimws(unlist(strsplit(group_content, ",\\s*|;\\s*", perl = TRUE)))
            content_items <- content_items[!(tolower(content_items) %in% invalid_values)]
            if (length(content_items) == 0) {
                next
            }
            if (group_is_setask) {
                rows <- data.frame(ID = as.character(data$ID[i]), MDETask = content_items, SETask = group_name)
            }
            else {
                rows <- data.frame(ID = as.character(data$ID[i]), MDETask = group_name, SETask = content_items)
            }
            task_pairs <- rbind(task_pairs, rows)
        }
    }
    if (nrow(task_pairs) == 0) {
        return(NULL)
    }
    task_pairs <- task_pairs %>% filter(tolower(trimws(MDETask)) != "none")
    if (nrow(task_pairs) == 0) {
        return(NULL)
    }
    task_summary <- task_pairs %>% distinct(ID, MDETask, SETask) %>% count(MDETask, SETask, name = "Freq") %>% 
        dplyr::rename(Items = MDETask, Category = SETask)
    task_paper_totals <- task_pairs %>% distinct(ID, MDETask) %>% count(MDETask, name = "Top") %>% dplyr::rename(Items = MDETask)
    stackedBarChart100(data = task_summary, item_top_labels = task_paper_totals, xLabel = "MDE Task", yLabel = "Percentage of Papers", 
        legendTitle = "SE Task", fileName = paste("RQ", rqNum, "_setask_mdetask_stacked_bar", sep = ""), width = 14, 
        height = 8, axisXAngle = 45, axisHjust = 1, axisVjust = 1, barwidth = 0.45, showTable = FALSE, x_mult = c(0.03, 
            0.04))
    return(task_summary)
}

setask_mdetask_table <- function(rqNum, data = DATA_TO_ANALYSIS) {
    setask_mdetask_col <- "RQ5.SETaskMDETask"
    mdetask_setask_col <- "RQ4.MDETaskSETask"
    if (setask_mdetask_col %in% names(data)) {
        task_col <- setask_mdetask_col
        group_is_setask <- TRUE
    }
    else if (mdetask_setask_col %in% names(data)) {
        task_col <- mdetask_setask_col
        group_is_setask <- FALSE
    }
    else {
        stop("Missing RQ4 SETask-MDETask mapping column.")
    }
    invalid_values <- c("", "n/a", "unspecified", "null")
    task_pairs <- data.frame(ID = character(), MDETask = character(), SETask = character())
    for (i in seq_len(nrow(data))) {
        raw_value <- data[[task_col]][i]
        if (is.na(raw_value) || trimws(raw_value) == "") {
            next
        }
        groups <- regmatches(raw_value, gregexpr("\\[([^]]+)\\]", raw_value, perl = TRUE))[[1]]
        if (length(groups) == 0) {
            groups <- raw_value
        }
        for (group_text in groups) {
            group_text <- gsub("^\\[|\\]$", "", group_text)
            group_data <- extractGroupNameAndContentAsDataframe(group_text, groupNameIfNull = "None")
            group_name <- trimws(group_data$groupName)
            group_content <- trimws(group_data$groupContent)
            if (is.null(group_name) || is.na(group_name) || group_name == "") {
                group_name <- "None"
            }
            if (is.na(group_content) || tolower(group_content) %in% invalid_values) {
                next
            }
            content_items <- trimws(unlist(strsplit(group_content, ",\\s*|;\\s*", perl = TRUE)))
            content_items <- content_items[!(tolower(content_items) %in% invalid_values)]
            if (length(content_items) == 0) {
                next
            }
            if (group_is_setask) {
                rows <- data.frame(ID = as.character(data$ID[i]), MDETask = content_items, SETask = group_name)
            }
            else {
                rows <- data.frame(ID = as.character(data$ID[i]), MDETask = group_name, SETask = content_items)
            }
            task_pairs <- rbind(task_pairs, rows)
        }
    }
    task_pairs <- task_pairs %>% filter(tolower(trimws(MDETask)) != "none") %>% distinct(ID, MDETask, SETask)
    if (nrow(task_pairs) == 0) {
        return(NULL)
    }
    task_paper_totals <- task_pairs %>% distinct(ID, MDETask) %>% count(MDETask, name = "PaperNum") %>% arrange(desc(PaperNum), 
        MDETask)
    task_summary <- task_pairs %>% group_by(MDETask, SETask) %>% summarise(PaperNum = n_distinct(ID), Papers = getCitations(ID, 
        onlyID = TRUE), .groups = "drop")
    TABLE <- paste0(GENERATED_FILES, "/RQ", rqNum, "_setask_mdetask.tex")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    on.exit(sink(), add = TRUE)
    cat("\\begin{tabular} {p{0.3\\textwidth}  p{0.3\\textwidth} p{0.02\\textwidth} p{0.5\\textwidth}} \\\\ \n")
    cat("\\toprule \n")
    cat("MDE task & SE task & \\# & Papers\\\\ \n")
    for (mde_task in task_paper_totals$MDETask) {
        mde_total <- task_paper_totals$PaperNum[task_paper_totals$MDETask == mde_task]
        se_tasks <- task_summary %>% filter(MDETask == mde_task) %>% arrange(desc(PaperNum), SETask)
        cat("\\midrule  \n")
        cat(formatTitleName(mde_task), " (", mde_total, ")", sep = "")
        for (i in seq_len(nrow(se_tasks))) {
            se_task_label <- if (tolower(se_tasks$SETask[i]) == "none") 
                "-"
            else se_tasks$SETask[i]
            cat(" & ", emphExp(formatTitleName(formatTaskName(se_task_label))), " & ", se_tasks$PaperNum[i], " & ", 
                se_tasks$Papers[i], "\\\\ \n", sep = "")
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    return(task_summary)
}

model_generation <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID = ID, MDETask = RQ5.MDETask, SubTask = RQ4.Sub.category.of.model.generation) %>% 
        filter(grepl("Model generation", MDETask)) %>% mutate(SubTask = str_replace_all(SubTask, "\\u2013|\\u2014", 
        "-")) %>% separate_rows(SubTask, sep = ";") %>% mutate(SubTask = str_squish(SubTask)) %>% filter(!is.na(SubTask), 
        SubTask != "", !(tolower(SubTask) %in% c("n/a", "unspecified", "null"))) %>% distinct(ID, SubTask)
    model_generation_summary <- df %>% count(SubTask, sort = TRUE)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_model_generation.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.34\\textwidth} p{0.05\\textwidth} p{0.60\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Modeling & \\# & Papers\\\\ \n")
    cat("\\midrule  \n")
    for (i in 1:nrow(model_generation_summary)) {
        modeling <- model_generation_summary$SubTask[i]
        modeling_data <- subset(df, df$SubTask == modeling)
        cat(modeling, " & ", model_generation_summary$n[i], " & ", getCitations(modeling_data), "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

mdetask_modellanguage <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID = ID, MDETask = RQ5.MDETask, ModelLanguage = RQ6.ModelingLanguage)
    frequency_table <- pmap_dfr(list(df$ID, df$MDETask, df$ModelLanguage), expand_and_flatten, id_col = "ID", metric_col = "MDETask", 
        norm_col = "ModelLanguage") %>% filter(!is.na(MDETask), !(tolower(MDETask) %in% c("n/a", "unspecified", 
        "null")), !(tolower(ModelLanguage) %in% c("n/a", "unspecified", "null")), ) %>% count(MDETask, ModelLanguage)
    colnames(frequency_table) <- c("y", "x", "n")
    filename <- paste("RQ", rqNum, "_mde_language_heatmap", sep = "")
    plot_mde_heatmap(frequency_table, "Modeling Language", "MDE Task", fileName = filename, width = 8, height = 8)
}

models_modellanguage <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID = ID, ML2Model = RQ6.ModelingLanguageModelType)
    parse_model_language_model_type <- function(id, ml2model) {
        if (is.na(ml2model) || trimws(ml2model) == "") 
            return(NULL)
        matches <- str_match_all(ml2model, "\\[([^:\\]]+)\\s*:\\s*([^\\]]+)\\]")[[1]]
        if (nrow(matches) == 0) 
            return(NULL)
        pmap_dfr(list(matches[, 2], matches[, 3]), function(model_language, model_types) {
            types <- str_split(model_types, ";")[[1]] %>% str_trim() %>% .[. != ""]
            tibble(ID = id, ModelLanguage = str_trim(model_language), ModelType = types)
        })
    }
    frequency_table <- pmap_dfr(list(df$ID, df$ML2Model), parse_model_language_model_type) %>% filter(!is.na(ModelLanguage), 
        !is.na(ModelType), !(tolower(ModelLanguage) %in% c("n/a", "unspecified", "null")), !(tolower(ModelType) %in% 
            c("n/a", "unspecified", "null"))) %>% count(ModelType, ModelLanguage)
    mapping_df <- stack(model_type_category_mapping) %>% select(ModelType = values, Category = ind) %>% mutate(Category = as.character(Category), 
        CategoryOrder = as.integer(factor(Category, levels = names(model_type_category_mapping))), TypeOrder = row_number())
    frequency_table <- frequency_table %>% left_join(mapping_df, by = "ModelType") %>% mutate(Category = replace_na(Category, 
        "Unclassified"), CategoryOrder = replace_na(CategoryOrder, length(model_type_category_mapping) + 1L), TypeOrder = if_else(is.na(TypeOrder), 
        max(mapping_df$TypeOrder, na.rm = TRUE) + row_number(), TypeOrder)) %>% group_by(ModelType) %>% mutate(ModelTypeTotal = sum(n)) %>% 
        ungroup() %>% group_by(ModelLanguage) %>% mutate(ModelLanguageTotal = sum(n)) %>% ungroup() %>% arrange(CategoryOrder, 
        TypeOrder, desc(ModelTypeTotal), ModelType)
    model_type_levels <- rev(unique(frequency_table$ModelType))
    model_language_levels <- frequency_table %>% distinct(ModelLanguage, ModelLanguageTotal) %>% arrange(desc(ModelLanguageTotal), 
        ModelLanguage) %>% pull(ModelLanguage)
    frequency_table <- frequency_table %>% mutate(Category = factor(Category, levels = c(names(model_type_category_mapping), 
        "Unclassified")), ModelType = factor(ModelType, levels = model_type_levels), ModelLanguage = factor(ModelLanguage, 
        levels = model_language_levels))
    filename <- paste("RQ", rqNum, "_model_language_model_type_heatmap", sep = "")
    p <- ggplot(frequency_table, aes(x = ModelLanguage, y = ModelType, fill = n)) + geom_tile(color = "white", 
        linewidth = 0.3) + geom_text(aes(label = n), color = "white", size = 3) + scale_fill_viridis_c() + facet_grid(Category ~ 
        ., scales = "free_y", space = "free_y") + theme_minimal() + labs(x = "Modeling Language", y = "Model Type", 
        fill = "Count") + theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.text.y = element_text(angle = 0, 
        face = "bold"), panel.spacing.y = unit(0.15, "lines"), panel.border = element_rect(color = "grey50", fill = NA, 
        linetype = "dashed", linewidth = 0.4))
    print(p)
    ggsave(paste0(GENERATED_FILES, "/", filename, ".pdf"), plot = p, width = 10, height = 9)
    return(p)
}

model_generation_modellanguage <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID = ID, MDETask = RQ5.MDETask, ML2Model = RQ6.ModelingLanguageModelType) %>% 
        filter(grepl("Model generation", MDETask))
    parse_model_language_model_type <- function(id, ml2model) {
        if (is.na(ml2model) || trimws(ml2model) == "") 
            return(NULL)
        matches <- str_match_all(ml2model, "\\[([^:\\]]+)\\s*:\\s*([^\\]]+)\\]")[[1]]
        if (nrow(matches) == 0) 
            return(NULL)
        pmap_dfr(list(matches[, 2], matches[, 3]), function(model_language, model_types) {
            types <- str_split(model_types, ";")[[1]] %>% str_trim() %>% .[. != ""]
            tibble(ID = id, ModelLanguage = str_trim(model_language), ModelType = types)
        })
    }
    frequency_table <- pmap_dfr(list(df$ID, df$ML2Model), parse_model_language_model_type) %>% filter(!is.na(ModelLanguage), 
        !is.na(ModelType), !(tolower(ModelLanguage) %in% c("n/a", "unspecified", "null")), !(tolower(ModelType) %in% 
            c("n/a", "unspecified", "null"))) %>% distinct(ID, ModelType, ModelLanguage) %>% count(ModelType, ModelLanguage)
    mapping_df <- stack(model_type_category_mapping) %>% select(ModelType = values, Category = ind) %>% mutate(Category = as.character(Category), 
        CategoryOrder = as.integer(factor(Category, levels = names(model_type_category_mapping))), TypeOrder = row_number())
    frequency_table <- frequency_table %>% left_join(mapping_df, by = "ModelType") %>% mutate(Category = replace_na(Category, 
        "Unclassified"), CategoryOrder = replace_na(CategoryOrder, length(model_type_category_mapping) + 1L), TypeOrder = if_else(is.na(TypeOrder), 
        max(mapping_df$TypeOrder, na.rm = TRUE) + row_number(), TypeOrder)) %>% group_by(ModelType) %>% mutate(ModelTypeTotal = sum(n)) %>% 
        ungroup() %>% group_by(ModelLanguage) %>% mutate(ModelLanguageTotal = sum(n)) %>% ungroup() %>% arrange(CategoryOrder, 
        TypeOrder, desc(ModelTypeTotal), ModelType)
    model_type_levels <- rev(unique(frequency_table$ModelType))
    model_language_levels <- frequency_table %>% distinct(ModelLanguage, ModelLanguageTotal) %>% arrange(desc(ModelLanguageTotal), 
        ModelLanguage) %>% pull(ModelLanguage)
    frequency_table <- frequency_table %>% mutate(Category = factor(Category, levels = c(names(model_type_category_mapping), 
        "Unclassified")), ModelType = factor(ModelType, levels = model_type_levels), ModelLanguage = factor(ModelLanguage, 
        levels = model_language_levels))
    filename <- paste("RQ", rqNum, "_model_generation_model_language_model_type_heatmap", sep = "")
    p <- ggplot(frequency_table, aes(x = ModelLanguage, y = ModelType, fill = n)) + geom_tile(color = "white", 
        linewidth = 0.3) + geom_text(aes(label = n), color = "white", size = 3) + scale_fill_viridis_c() + facet_grid(Category ~ 
        ., scales = "free_y", space = "free_y") + theme_minimal() + labs(x = "Modeling Language", y = "Model Type", 
        fill = "Count") + theme(axis.text.x = element_text(angle = 45, hjust = 1), strip.text.y = element_text(angle = 0, 
        face = "bold"), panel.spacing.y = unit(0.15, "lines"), panel.border = element_rect(color = "grey50", fill = NA, 
        linetype = "dashed", linewidth = 0.4))
    print(p)
    ggsave(paste0(GENERATED_FILES, "/", filename, ".pdf"), plot = p, width = 10, height = 9)
    return(p)
}

mdetask_modellanguage_modeltype_grouped_heatmap <- function(df, rqNum, main_tasks = c("Model generation", "Model comprehension", 
    "Model analysis"), first_width = 11, first_height = 13, first_wrap_task_label_width = 17, first_wrap_task_label = FALSE, 
    second_width = 14, second_height = 13, second_tasks_per_row = 5, second_last_row_tasks = 6, second_wrap_task_label_width = 17, 
    second_wrap_task_label = FALSE) {
    df <- df %>% select(ID = ID, MDETask = RQ5.MDETask, ML2Model = RQ6.ModelingLanguageModelType)
    parse_model_language_model_type <- function(id, ml2model) {
        if (is.na(ml2model) || trimws(ml2model) == "") 
            return(NULL)
        matches <- str_match_all(ml2model, "\\[([^:\\]]+)\\s*:\\s*([^\\]]+)\\]")[[1]]
        if (nrow(matches) == 0) 
            return(NULL)
        pmap_dfr(list(matches[, 2], matches[, 3]), function(model_language, model_types) {
            types <- str_split(model_types, ";")[[1]] %>% str_trim() %>% .[. != ""]
            tibble(ID = id, ModelLanguage = str_trim(model_language), ModelType = types)
        })
    }
    mde_task_df <- df %>% select(ID, MDETask) %>% filter(containValidValue(MDETask)) %>% mutate(MDETask = str_replace_all(MDETask, 
        "\\[|\\]", "")) %>% separate_rows(MDETask, sep = ";\\s*") %>% mutate(MDETask = str_squish(MDETask)) %>% 
        filter(!is.na(MDETask), MDETask != "", !(tolower(MDETask) %in% c("n/a", "unspecified", "null"))) %>% distinct(ID, 
        MDETask)
    language_model_type_df <- pmap_dfr(list(df$ID, df$ML2Model), parse_model_language_model_type) %>% filter(!is.na(ModelLanguage), 
        !is.na(ModelType), !(tolower(ModelLanguage) %in% c("n/a", "unspecified", "null")), !(tolower(ModelType) %in% 
            c("n/a", "unspecified", "null"))) %>% distinct(ID, ModelLanguage, ModelType)
    heatmap_data <- mde_task_df %>% inner_join(language_model_type_df, by = "ID", relationship = "many-to-many") %>% 
        distinct(ID, MDETask, ModelLanguage, ModelType) %>% count(MDETask, ModelLanguage, ModelType, name = "n")
    mapping_df <- stack(model_type_category_mapping) %>% select(ModelType = values, Category = ind) %>% mutate(Category = as.character(Category), 
        CategoryOrder = as.integer(factor(Category, levels = names(model_type_category_mapping))), TypeOrder = row_number())
    heatmap_data <- heatmap_data %>% left_join(mapping_df, by = "ModelType") %>% mutate(Category = replace_na(Category, 
        "Unclassified"), CategoryOrder = replace_na(CategoryOrder, length(model_type_category_mapping) + 1L), TypeOrder = if_else(is.na(TypeOrder), 
        max(mapping_df$TypeOrder, na.rm = TRUE) + row_number(), TypeOrder))
    plot_grouped_heatmap <- function(plot_data, filename_suffix, width, height, tasks_per_row = NULL, last_row_tasks = NULL, 
        plot_wrap_task_label_width = 17, plot_wrap_task_label = FALSE, plot_count_legend_position = "bottom", plot_count_legend_breaks_n = 1) {
        task_levels <- plot_data %>% group_by(MDETask) %>% summarise(Total = sum(n), .groups = "drop") %>% arrange(desc(Total), 
            MDETask) %>% pull(MDETask)
        category_levels <- c(names(model_type_category_mapping))
        plot_category_levels <- category_levels[category_levels %in% unique(plot_data$Category)]
        category_palette <- c(`Requirement/\nGoal` = "#D9E8FB", Behavior = "#DDF3DF", `Structure/\nArchitecture` = "#FBE4C9", 
            `Knowledge/\nDomain` = "#E9DDF6", Constraint = "#F8D7DA", Verification = "#D9F0F2", Others = "#E6E6E6", 
            Unclassified = "#F2F2F2")
        category_text_palette <- c(`Requirement/\nGoal` = "#1F5A99", Behavior = "#2E7D32", `Structure/\nArchitecture` = "#B45F06", 
            `Knowledge/\nDomain` = "#6A3D9A", Constraint = "#A61C2B", Verification = "#1B7C83", Others = "#4D4D4D", 
            Unclassified = "#666666")
        count_limits <- range(plot_data$n, na.rm = TRUE)
        if (count_limits[1] == count_limits[2]) {
            count_limits <- c(0, count_limits[2])
        }
        build_heatmap_plot <- function(row_data, row_task_levels, show_legend = TRUE, show_x_title = TRUE, wrap_task_label_width = 17, 
            wrap_task_label = FALSE, count_legend_position = "bottom", count_legend_breaks_n = 1) {
            type_meta <- row_data %>% distinct(ModelType, Category, CategoryOrder, TypeOrder) %>% arrange(CategoryOrder, 
                TypeOrder, ModelType)
            type_levels <- rev(type_meta$ModelType)
            type_label_colors <- type_meta %>% mutate(ModelType = factor(ModelType, levels = type_levels)) %>% 
                arrange(ModelType) %>% pull(Category) %>% {
                category_text_palette[.]
            }
            language_levels <- row_data %>% group_by(ModelLanguage) %>% summarise(Total = sum(n), .groups = "drop") %>% 
                arrange(desc(Total), ModelLanguage) %>% pull(ModelLanguage)
            row_data <- row_data %>% mutate(MDETask = factor(MDETask, levels = row_task_levels), ModelLanguage = factor(ModelLanguage, 
                levels = language_levels), ModelType = factor(ModelType, levels = type_levels))
            legend_data <- tibble(Category = factor(plot_category_levels, levels = category_levels)) %>% mutate(ModelType = factor(type_levels[1], 
                levels = type_levels), ModelLanguage = factor(language_levels[1], levels = language_levels), MDETask = factor(row_task_levels[1], 
                levels = row_task_levels))
            task_labeller <- if (wrap_task_label) {
                labeller(MDETask = label_wrap_gen(width = wrap_task_label_width))
            }
            else {
                "label_value"
            }
            count_legend_vertical <- count_legend_position %in% c("right", "left")
            ggplot(row_data, aes(x = ModelLanguage, y = ModelType, fill = n)) + geom_tile(color = "white", linewidth = 0.3) + 
                geom_text(aes(label = n), color = "white", size = 2.8) + geom_point(data = legend_data, aes(x = ModelLanguage, 
                y = ModelType, color = Category), inherit.aes = FALSE, alpha = 0, show.legend = show_legend) + 
                scale_x_discrete(drop = TRUE) + scale_y_discrete(drop = FALSE, labels = function(x) {
                vapply(x, function(label) {
                  lines <- str_wrap(label, width = 12) %>% strsplit("\n", fixed = TRUE) %>% unlist()
                  if (length(lines) > 1) {
                    lines[-length(lines)] <- paste0(lines[-length(lines)], "-")
                  }
                  paste(lines, collapse = "\n")
                }, character(1), USE.NAMES = FALSE)
            }) + scale_fill_viridis_c(limits = count_limits, breaks = seq(ceiling(count_limits[1]), floor(count_limits[2]), 
                by = count_legend_breaks_n)) + scale_color_manual(values = category_palette, breaks = plot_category_levels, 
                limits = category_levels, drop = FALSE, name = "Category") + facet_grid(. ~ MDETask, scales = "free_x", 
                space = "free_x", labeller = task_labeller) + theme_minimal() + labs(x = if (show_x_title) 
                "Modeling Language"
            else NULL, y = "Model Type", fill = "Count") + guides(fill = guide_colorbar(order = 1, position = count_legend_position, 
                direction = if (count_legend_vertical) 
                  "vertical"
                else "horizontal", title.position = if (count_legend_vertical) 
                  "top"
                else "left", title.hjust = 0.5, barwidth = if (count_legend_vertical) 
                  unit(0.35, "cm")
                else unit(3.5, "cm"), barheight = if (count_legend_vertical) 
                  unit(3.5, "cm")
                else unit(0.35, "cm"), reverse = FALSE), color = guide_legend(order = 2, position = "bottom", nrow = 1, 
                title.position = "left", override.aes = list(size = 5, alpha = 1, shape = 15))) + theme(axis.text.x = element_text(angle = 45, 
                hjust = 1), axis.text.y = element_text(size = 8.5, color = type_label_colors), axis.ticks.y = element_blank(), 
                strip.text = element_text(face = "bold"), panel.border = element_rect(color = "grey60", fill = NA, 
                  linewidth = 0.3), plot.margin = margin(5.5, 5.5, 5.5, 5.5), legend.position = ifelse(show_legend, 
                  "bottom", "none"), legend.box = "horizontal", legend.direction = "horizontal")
        }
        if (is.null(tasks_per_row)) {
            p <- build_heatmap_plot(plot_data, task_levels, wrap_task_label_width = plot_wrap_task_label_width, 
                wrap_task_label = plot_wrap_task_label, count_legend_position = plot_count_legend_position, count_legend_breaks_n = plot_count_legend_breaks_n)
        }
        else {
            if (!is.null(last_row_tasks) && length(task_levels) > last_row_tasks) {
                leading_tasks <- head(task_levels, length(task_levels) - last_row_tasks)
                task_chunks <- split(leading_tasks, ceiling(seq_along(leading_tasks)/tasks_per_row))
                task_chunks <- c(task_chunks, list(tail(task_levels, last_row_tasks)))
            }
            else {
                task_chunks <- split(task_levels, ceiling(seq_along(task_levels)/tasks_per_row))
            }
            row_plots <- lapply(seq_along(task_chunks), function(i) {
                row_task_levels <- task_chunks[[i]]
                build_heatmap_plot(plot_data %>% filter(MDETask %in% row_task_levels), row_task_levels, show_legend = i == 
                  length(task_chunks), show_x_title = i == length(task_chunks), wrap_task_label_width = plot_wrap_task_label_width, 
                  wrap_task_label = plot_wrap_task_label, count_legend_position = plot_count_legend_position, count_legend_breaks_n = plot_count_legend_breaks_n)
            })
            row_heights <- sapply(seq_along(task_chunks), function(i) {
                row_task_levels <- task_chunks[[i]]
                row_type_count <- plot_data %>% filter(MDETask %in% row_task_levels) %>% summarise(n = n_distinct(ModelType)) %>% 
                  pull(n)
                row_type_count <- row_type_count + 1
                if (i == length(task_chunks)) 
                  row_type_count <- row_type_count + 3
                return(row_type_count)
            })
            p <- gridExtra::arrangeGrob(grobs = row_plots, ncol = 1, heights = row_heights)
        }
        filename <- paste("RQ", rqNum, "_mdetask_model_language_model_type_grouped_heatmap_", filename_suffix, 
            sep = "")
        print(p)
        ggsave(paste0(GENERATED_FILES, "/", filename, ".pdf"), plot = p, width = width, height = height)
        return(p)
    }
    main_plot <- plot_grouped_heatmap(heatmap_data %>% filter(MDETask %in% main_tasks), "main_tasks", width = first_width, 
        height = first_height, plot_wrap_task_label_width = first_wrap_task_label_width, plot_wrap_task_label = first_wrap_task_label, 
        plot_count_legend_position = "right", plot_count_legend_breaks_n = 2)
    other_plot <- plot_grouped_heatmap(heatmap_data %>% filter(!(MDETask %in% main_tasks)), "other_tasks", width = second_width, 
        height = second_height, tasks_per_row = second_tasks_per_row, last_row_tasks = second_last_row_tasks, plot_wrap_task_label_width = second_wrap_task_label_width, 
        plot_wrap_task_label = second_wrap_task_label)
    return(list(main_tasks = main_plot, other_tasks = other_plot))
}

seAnalysis <- function(rqNum = 5) {
    se_data <- DATA_TO_ANALYSIS
    df <- NULL
    df_colnames <- c("ID", "RQ4.SEActivity", "RQ4.SETask")
    for (i in 1:nrow(se_data)) {
        row_data <- c(se_data$ID[i], se_data$RQ4.SEActivity[i], tolower(se_data$RQ4.SETask[i]))
        r <- extractMultipleRowsBySeparator(row_data, 2, df_colnames = df_colnames, extractAsGroup = FALSE)
        if (is.null(df)) 
            df <- r
        else df <- rbind(df, r)
    }
    seTable(df, rqNum)
}

application_domain_category_definition <- function(rqNum) {
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_application_domain_category_definitions.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.32\\textwidth} p{0.69\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Category & Definition\\\\ \n")
    cat("\\midrule  \n")
    for (category in names(category_mapping)) {
        definition <- application_domain_category_definition_mapping[[category]]
        if (is.null(definition)) {
            definition <- "-"
        }
        cat(clean_text_4latex(category), " & ", clean_text_4latex(definition), "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

application <- function(data = DATA_TO_ANALYSIS, rqNum, label = "") {
    data_selected <- data %>% select(RQ7.ApplicationDomain, ID) %>% dplyr::rename(Category = RQ7.ApplicationDomain) %>% 
        tidyr::separate_rows(Category, sep = ";") %>% mutate(Category = trimws(Category)) %>% mutate(AbstractCategory = sapply(Category, 
        identify_abstract_category))
    abs_categories <- data_selected %>% count(AbstractCategory, sort = TRUE)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, label, "_application_domain.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.3\\textwidth} p{0.05\\textwidth} p{0.64\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Domain & \\# & Papers\\\\ \n")
    cat("\\midrule  \n")
    for (abs_index in 1:nrow(abs_categories)) {
        abs <- as.character(abs_categories$AbstractCategory[abs_index])
        cat(as.character(abs), " & ", if (rqNum == 7 && abs == "Computing and Digital Systems") paste0("{", abs_categories[abs_index, 2], "}") else as.character(abs_categories[abs_index, 2]), " & ", sep = "")
        abs_data <- subset(data_selected, data_selected$AbstractCategory == abs)
        cs <- unique(abs_data$Category)
        if (length(cs) == 1) {
            cat(getCitations(abs_data), "\\\\ \n", sep = "")
        }
        else {
            anybefore <- FALSE
            for (c_index in 1:length(cs)) {
                c <- cs[c_index]
                c_data <- subset(abs_data, abs_data$Category == c)
                if (anybefore) 
                  cat(", ")
                if (length(unique(c_data$ID)) > 0) {
                  cat(formatTitleName(c), "~", getCitations(c_data), sep = "")
                  anybefore <- TRUE
                }
                if (c_index == length(cs)) 
                  cat("\\\\ \n")
            }
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

llm_foundation_model <- function(rqNum) {
    data <- filterUnspecified(extractAll(extractAllWithGroup(DATA_TO_ANALYSIS$RQ8.FoundationLLMFamiliy)))
    data_summary <- otherInSummary(data, 4)
    data_new <- data.frame(category = data_summary$data, value = data_summary$Freq)
    RQ_label <- RQ_label_prefix(rqNum)
    collectRQResults(data_summary, RQ_label)
    pieChartFile <- paste("RQ", rqNum, "_foundation_models_pie", sep = "")
    pieChart(pieChartFile, data_new, summarizedData = TRUE, w = 10, h = 8)
    data_summary <- otherInSummary(data, NULL)
    data <- data.frame(Items = data_summary$data, Freq = data_summary$Freq)
    barFile <- paste("RQ", rqNum, "_foundation_models_bar", sep = "")
    barChart(data, xLabel = "LLM Foundation Model", yLabel = "# of Papers", barFile, width = 12, axisXAngle = 45, 
        axisHjust = 1, axisVjust = 1)
}

llm_model_version_size <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, raw = RQ8.VersionParameter)
    normalize_model_part <- function(x) {
        x <- str_squish(x)
        x <- str_replace_all(x, "\\u2013|\\u2014", "-")
        ifelse(is.na(x) | x == "" | tolower(x) %in% c("n/a", "unspecified", "null"), "-", x)
    }
    parse_model_version_size <- function(id, raw) {
        if (is.na(raw) || str_squish(raw) == "") 
            return(NULL)
        groups <- raw %>% str_replace("^\\s*\\[\\[", "[") %>% str_replace("\\]\\]\\s*$", "]") %>% str_replace_all("\\]\\s*;\\s*\\[", 
            "]|[") %>% str_split("\\|") %>% purrr::pluck(1) %>% str_remove("^\\[") %>% str_remove("\\]$") %>% str_squish()
        pmap_dfr(list(groups), function(group) {
            family <- ifelse(str_detect(group, ":"), str_replace(group, "^([^:]*):.*$", "\\1"), "-")
            content <- str_replace(group, "^[^:]*:\\s*", "")
            matches <- str_match_all(content, "([^;\\[\\]]+)\\[([^\\]]*)\\]")[[1]]
            if (nrow(matches) == 0) {
                return(tibble(ID = id, Family = normalize_model_part(family), Version = "-", Size = "-"))
            }
            pmap_dfr(list(matches[, 2], matches[, 3]), function(version, size) {
                sizes <- str_split(size, ";|/")[[1]] %>% str_squish() %>% .[. != ""]
                if (length(sizes) == 0) 
                  sizes <- "-"
                tibble(ID = id, Family = normalize_model_part(family), Version = normalize_model_part(version), 
                  Size = normalize_model_part(sizes))
            })
        })
    }
    version_size_data <- pmap_dfr(list(df$ID, df$raw), parse_model_version_size) %>% filter(!is.na(Family), !is.na(Version), 
        !is.na(Size), !(tolower(Family) %in% c("n/a", "unspecified", "null", "-", "")), ) %>% mutate(VersionSize = paste0("\\textbf{", 
        Version, "}~(", Size, ")")) %>% distinct(ID, Family, VersionSize)
    family_summary <- version_size_data %>% count(Family, sort = TRUE)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_llm_version_size.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.12\\textwidth} p{1.0\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("LLM family & Version (Parameter Size): Count\\\\ \n")
    cat("\\midrule  \n")
    for (i in 1:nrow(family_summary)) {
        family <- family_summary$Family[i]
        family_data <- subset(version_size_data, version_size_data$Family == family)
        version_size_summary <- family_data %>% count(VersionSize, sort = TRUE)
        version_size_items <- lapply(version_size_summary$VersionSize, function(version_size) {
            version_size_data <- subset(family_data, family_data$VersionSize == version_size)
            paste0(version_size, ": \\textbf{", if (version_size %in% c("\\textbf{GPT-4}~(-)", "\\textbf{GPT-3.5}~(-)") ) paste0("{", length(unique(version_size_data$ID)), "}") else length(unique(version_size_data$ID)), "} ", getCitations(version_size_data),
                sep = "")
        })
        cat(family, " & ", paste(version_size_items, collapse = "; "), "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

llm_used <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, MDETask = RQ5.MDETask, access = RQ8.LLMAccessMode)
    access_data <- pmap_dfr(list(df$ID, df$MDETask, df$access), expand_and_flatten, id_col = "ID", metric_col = "MDETask", 
        norm_col = "AccessMode") %>% mutate(MDETask = str_squish(MDETask), AccessMode = str_squish(AccessMode)) %>% 
        filter(!is.na(MDETask), !is.na(AccessMode), !(tolower(MDETask) %in% c("n/a", "unspecified", "null")), !(tolower(AccessMode) %in% 
            c("n/a", "unspecified", "null"))) %>% distinct(ID, MDETask, AccessMode) %>% count(MDETask, AccessMode, 
        name = "Freq")
    task_levels <- access_data %>% group_by(MDETask) %>% summarise(Total = sum(Freq), .groups = "drop") %>% arrange(desc(Total), 
        MDETask) %>% pull(MDETask)
    access_data <- access_data %>% group_by(MDETask) %>% mutate(Total = sum(Freq), Percentage = Freq/Total, Label = ifelse(Percentage >= 
        0.08, paste0(Freq, "\n", formatC(Percentage * 100, digits = 0, format = "f"), "%"), "")) %>% ungroup() %>% 
        mutate(MDETask = factor(MDETask, levels = task_levels))
    access_summary <- access_data %>% group_by(AccessMode) %>% summarise(Total = sum(Freq), .groups = "drop") %>% 
        mutate(Percentage = Total/sum(Total), Label = paste0(AccessMode, ": ", Total, " (", formatC(Percentage * 
            100, digits = 2, format = "f"), "%)")) %>% arrange(desc(Total), AccessMode) %>% pull(Label) %>% paste(collapse = "   ")
    filename <- paste0("RQ", rqNum, "_mdetask_accessmode_100_stacked_bar", sep = "")
    p <- ggplot(access_data, aes(x = MDETask, y = Freq, fill = AccessMode)) + geom_col(position = "fill", colour = "black", 
        width = 0.55, linewidth = 0.3) + geom_text(aes(label = Label), position = position_fill(vjust = 0.5), size = 3, 
        lineheight = 0.9) + scale_y_continuous(labels = scales::percent_format()) + labs(x = "MDE Task", y = "Percentage of Papers", 
        fill = "LLM Access Mode", title = access_summary) + guides(fill = guide_legend(nrow = 1, title.position = "left")) + 
        theme_classic() + theme(legend.position = c(0.95, 1.05), legend.justification = c(1, 1), legend.direction = "horizontal", 
        legend.box = "horizontal", plot.title = element_text(size = 12, hjust = 0.5, face = "bold"), axis.text.x = element_text(color = "black", 
            size = 11, angle = 45, hjust = 1, vjust = 1), axis.text.y = element_text(color = "black", size = 11), 
        axis.title = element_text(size = 13))
    print(p)
    ggsave(paste0(GENERATED_FILES, "/", filename, ".pdf"), plot = p, width = 13, height = 7)
    return(p)
}

llm_pipeline <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, raw = RQ8.PipelineLLMComposition)
    pipeline_data <- df %>% mutate(raw = str_squish(raw), Pipeline = case_when(raw == "Single LLM" ~ "Single-LLM", 
        raw == "Same LLM in pipeline" ~ "Multi-Same-LLM", raw == "Different LLMs in pipeline" ~ "Multi-Different-LLM", 
        TRUE ~ raw)) %>% filter(!is.na(Pipeline), !(tolower(Pipeline) %in% c("n/a", "unspecified", "null", ""))) %>% 
        distinct(ID, Pipeline) %>% count(Pipeline, name = "value") %>% arrange(desc(value), Pipeline)
    data <- data.frame(category = pipeline_data$Pipeline, value = pipeline_data$value) %>% mutate(percent = value/sum(value), 
        label = ifelse(percent >= 0.03, paste0(category, "\n", value, " (", formatC(percent * 100, digits = 2, 
            format = "f"), "%)"), ""), legend_label = paste0(category, ": ", value, " (", formatC(percent * 100, 
            digits = 2, format = "f"), "%)"))
    pieChartFile <- paste("RQ", rqNum, "_llm_pipeline_pie", sep = "")
    fill_colors <- brewer.pal(nrow(data), "Set3")
    names(fill_colors) <- data$legend_label
    data <- data %>% mutate(legend_label = factor(legend_label, levels = legend_label))
    p <- ggplot(data, aes(x = 1, y = value, fill = legend_label)) + geom_col(color = "black", width = 1, linewidth = 0.3) + 
        geom_text(aes(label = label), position = position_stack(vjust = 0.5), size = 2.8, lineheight = 0.9) + coord_polar(theta = "y") + 
        scale_fill_manual(values = fill_colors, name = "LLM use in solution") + theme_void() + theme(legend.position = "right", 
        legend.title = element_text(size = 11, face = "bold"), legend.text = element_text(size = 10), legend.margin = margin(0, 
            0, 0, 0, "mm"), legend.box.margin = margin(0, 0, 0, 0, "mm"), plot.margin = margin(-3, -3, -3, -3, 
            "mm"), aspect.ratio = 1)
    print(p)
    ggsave(paste0(GENERATED_FILES, "/", pieChartFile, ".pdf"), plot = p, width = 6.8, height = 3.2, dpi = 300)
    return(p)
}

prompt_techniques <- function(rqNum) {
    prompt_tokens <- function(prompt_value) {
        if (is.na(prompt_value) || trimws(prompt_value) == "") {
            return(character())
        }
        prompt_value <- gsub("Iterative\\([^)]*\\)", "Iterative", prompt_value)
        prompt_value <- gsub("\\[|\\]", "", prompt_value)
        tokens <- trimws(unlist(strsplit(prompt_value, "\\+|;")))
        tokens <- tokens[!(tolower(tokens) %in% c("", "n/a", "unspecified", "null"))]
        tokens[tokens == "Grammer prompting"] <- "Grammar prompting"
        unique(tokens)
    }
    prompt_by_paper <- lapply(DATA_TO_ANALYSIS$RQ9.Prompt.engineering, prompt_tokens)
    prompt_types <- unique(unlist(prompt_by_paper))
    set_list <- lapply(prompt_types, function(type) {
        DATA_TO_ANALYSIS$ID[sapply(prompt_by_paper, function(tokens) type %in% tokens)]
    })
    names(set_list) <- sapply(prompt_types, function(type) {
        name_mapping <- c(`Structured Chain-of-thought` = "SCOT", `Chain-of-thought` = "COT", `Tree-of-Thoughts` = "TOT", 
            `Graph-of-thought` = "GOT", `Grammer prompting` = "GrammarPrompting", `Grammar prompting` = "GrammarPrompting")
        if (type %in% names(name_mapping)) 
            return(name_mapping[[type]])
        return(gsub("[[:space:]]|-", "", type))
    })
    set_list <- tapply(set_list, names(set_list), function(x) unique(unlist(x)))
    result <- data.frame(name = names(set_list), count = sapply(set_list, length), row.names = NULL)
    RQ_label <- RQ_label_prefix(rqNum)
    prefix <- paste0("RQ", rqNum, "_prompt_technique", sep = "")
    upsetPlot_complex(set_list = set_list, fileName = prefix, height = 12)
}

integration <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, task = RQ5.MDETask, tool = RQ11.Integration)
    result <- df %>% filter(containValidValue(tool)) %>% mutate(task = str_split(task, ";\\s*"), tool = str_split(tool, 
        "(?<=\\]);\\s*(?=\\[)")) %>% unnest(c(task, tool)) %>% mutate(tool = str_replace_all(tool, "\\[|\\]", ""), 
        tool = str_split(tool, ";\\s*")) %>% unnest(tool) %>% filter(containValidValue(tool)) %>% select(ID, MDETask = task, 
        IntegrationFramework = tool)
    sorted_result <- result %>% group_by(IntegrationFramework) %>% mutate(framework_freq = n()) %>% group_by(IntegrationFramework, 
        MDETask) %>% mutate(task_freq = n()) %>% ungroup() %>% arrange(desc(framework_freq), IntegrationFramework, 
        desc(task_freq), MDETask)
    id_ml_df <- DATA_TO_ANALYSIS %>% select(ID, ModelingLanguage = RQ6.ModelingLanguage)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_integration.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.02\\textwidth} p{0.45\\textwidth} p{0.35\\textwidth} p{0.48\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat(" & Tool (\\#) & MDE Task (\\#) & Modeling Language (\\#) Papers \\\\ \n")
    cat("\\midrule  \n")
    tools <- unique(sorted_result$IntegrationFramework)
    index <- 1
    ntools <- length(tools)
    col_index <- 1
    for (tool in tools) {
        if (col_index%%2 == 0) 
            cat("\\rowcolor{gray!15} \n")
        tasks <- subset(sorted_result, sorted_result$IntegrationFramework == tool)
        cat(index, "& ", tool, " (", length(unique(tasks$ID)), ")", sep = "")
        task_index <- 1
        for (task in unique(tasks$MDETask)) {
            if (task_index > 1) {
                if (col_index%%2 == 0) 
                  cat("\\rowcolor{gray!15} \n")
                cat(" & ")
            }
            col_index <- col_index + 1
            task_df <- subset(tasks, tasks$MDETask == task)
            cat(" & ", clean_text_4latex(task), " (", length(unique(task_df$ID)), ")", sep = "")
            filtered_df <- id_ml_df %>% filter(ID %in% task_df$ID)
            citation_summary <- filtered_df %>% separate_rows(ModelingLanguage, sep = ";") %>% mutate(ModelingLanguage = str_trim(ModelingLanguage)) %>% 
                filter(ModelingLanguage != "" & !is.na(ModelingLanguage)) %>% group_by(ModelingLanguage) %>% summarise(Count = n(), 
                Citations = getCitations(ID, onlyID = TRUE), .groups = "drop") %>% arrange(desc(Count)) %>% mutate(FormattedModelingLanguage = paste0("\\textbf{", 
                ModelingLanguage, "}", sep = "")) %>% mutate(Formatted = str_glue("{FormattedModelingLanguage} ({Count}) {Citations}"))
            output_text <- citation_summary %>% pull(Formatted) %>% paste(collapse = ", ")
            cat(" & ", output_text, "\\\\ \n", sep = "")
            task_index <- task_index + 1
        }
        index <- index + 1
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

integration_model_type <- function(rqNum, stop_function, suffix = "") {
    TABLE <- paste0(GENERATED_FILES, "/RQ", rqNum, "_integration_modeltype", suffix, ".tex")
    df <- DATA_TO_ANALYSIS %>% select(ID, task = RQ5.MDETask, tool = RQ11.Integration)
    df$tool <- gsub("S<U+00B3>", "S\\textsuperscript{3}", df$tool, fixed = TRUE)
    result <- df %>% filter(containValidValue(tool)) %>% mutate(task = str_split(task, ";\\s*"), tool = str_split(tool, 
        "(?<=\\]);\\s*(?=\\[)")) %>% unnest(c(task, tool)) %>% mutate(tool = str_replace_all(tool, "\\[|\\]", ""), 
        tool = str_split(tool, ";\\s*")) %>% unnest(tool) %>% filter(containValidValue(tool)) %>% select(ID, MDETask = task, 
        IntegrationFramework = tool)
    sorted_result <- result %>% group_by(IntegrationFramework) %>% mutate(framework_freq = n()) %>% group_by(IntegrationFramework, 
        MDETask) %>% mutate(task_freq = n()) %>% ungroup() %>% arrange(desc(framework_freq), IntegrationFramework, 
        desc(task_freq), MDETask)
    id_ml_df <- DATA_TO_ANALYSIS %>% select(ID, ModelType = RQ6.ModelType)
    task_levels <- sort(unique(result$MDETask), na.last = TRUE)
    # Explicit task palettes reproduce the published tables.
    task_colors <- if (suffix == "_one") c("Model generation" = "#D1F1E3", "Model operation" = "#CFEFF4", "Model restructuring" = "#E3E9FE", "Model analysis" = "#F2E9D4", 
"Model-based code completion" = "#FFE2E8", "Model matching" = "#CDF1E9", "Model comprehension" = "#E4EDD4", "Model synthesis" = "#F3E4FC", 
"Model element extraction" = "#D6F0DD", "Model completion" = "#EBEBD3", "Model slicing" = "#ECE7FD") else c("Model generation" = "#D1F1E3", "Model analysis" = "#F2E9D4", "Model-based code generation" = "#FBE5DC", "Model constraint generation" = "#DDEFD8", 
"Model matching" = "#CDF1E9", "Model recognition" = "#DCECFC", "Model restructuring" = "#E3E9FE", "Model synthesis" = "#F3E4FC", 
"Model transformation" = "#F9E3F8", "Model view generation" = "#FDE2F3", "Model-based code evolution" = "#FEE3E1", 
"Model completion" = "#EBEBD3", "Model operation" = "#CFEFF4", "Model mutation" = "#CCF0EF", "Model-based test generation" = "#F7E7D7", 
"Model comprehension" = "#E4EDD4", "Model query generation" = "#D4EEF9", "N/A" = "#FFE2EE")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.02\\textwidth} p{0.45\\textwidth} p{0.35\\textwidth} p{0.48\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat(" & Tool (\\#) & MDE Task (\\#) & Model Type (\\#) Papers \\\\ \n")
    cat("\\midrule  \n")
    tools <- unique(sorted_result$IntegrationFramework)
    index <- 1
    ntools <- length(tools)
    col_index <- 1
    for (tool in tools) {
        tasks <- subset(sorted_result, sorted_result$IntegrationFramework == tool)
        num_rows <- length(unique(tasks$ID))
        if (stop_function(num_rows)) 
            next
        if (col_index%%2 == 0) 
            cat("\\rowcolor{gray!15} \n")
        cat(index, "& ", tool, " (", num_rows, ")", sep = "")
        task_index <- 1
        for (task in unique(tasks$MDETask)) {
            if (task_index > 1) {
                if (col_index%%2 == 0) 
                  cat("\\rowcolor{gray!15} \n")
                cat(" & ")
            }
            col_index <- col_index + 1
            task_df <- subset(tasks, tasks$MDETask == task)
            cat(" & \\cellcolor[HTML]{", sub("^#", "", task_colors[[task]]), "}", clean_text_4latex(task), " (", 
                length(unique(task_df$ID)), ")", sep = "")
            filtered_df <- id_ml_df %>% filter(ID %in% task_df$ID)
            citation_summary <- filtered_df %>% separate_rows(ModelType, sep = ";") %>% mutate(ModelType = str_trim(ModelType)) %>% 
                filter(ModelType != "" & !is.na(ModelType)) %>% group_by(ModelType) %>% summarise(Count = n(), 
                Citations = getCitations(ID, onlyID = TRUE), .groups = "drop") %>% arrange(desc(Count)) %>% mutate(FormattedModelType = paste0("\\textbf{", 
                ModelType, "}", sep = "")) %>% mutate(Formatted = str_glue("{FormattedModelType} ({Count}) {Citations}"))
            output_text <- citation_summary %>% pull(Formatted) %>% paste(collapse = ", ")
            cat(" & ", output_text, "\\\\ \n", sep = "")
            task_index <- task_index + 1
        }
        index <- index + 1
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

human_in_loop <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, RQ12.InteractionPattern, RQ12.AdditionalInformation)
    sub_df_sorted <- df %>% filter(containValidValue(RQ12.InteractionPattern)) %>% group_by(RQ12.InteractionPattern) %>% 
        mutate(frequency = n()) %>% ungroup() %>% arrange(desc(frequency), RQ12.InteractionPattern)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_human_in_the_loop.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.07\\textwidth} p{0.2\\textwidth} p{0.7\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Paper & Interaction & Description\\\\ \n")
    cat("\\midrule  \n")
    for (i in 1:nrow(sub_df_sorted)) {
        cat(getCitations(sub_df_sorted$ID[i], onlyID = TRUE), " & ", str_to_title(sub_df_sorted$RQ12.InteractionPattern[i]), 
            " & ", sub_df_sorted$RQ12.AdditionalInformation[i], "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
    Items <- extractAllWithGroup(sub_df_sorted$RQ12.InteractionPattern)
    freq_num <- as.data.frame(table(Items))
    freq_num <- freq_num[order(freq_num$Items, decreasing = FALSE), ]
    barChartFile <- paste("RQ", rqNum, "_human_in_the_loop_bar", sep = "")
    barChart(freq_num, xLabel = "Type of Interaction Pattern", yLabel = "# of Papers", fileName = barChartFile, 
        reorderBasedOnFreq = TRUE, axisXAngle = 0, axisHjust = 0.5, axisVjust = 0.5, barwidth = 0.3, width = 8, 
        height = 4)
}

human_in_loop_table <- function(rqNum, data = DATA_TO_ANALYSIS) {
    interaction_papers <- data %>% select(ID, Interaction = RQ12.InteractionPattern) %>% filter(containValidValue(Interaction)) %>% 
        mutate(Interaction = lapply(Interaction, extractAllWithGroup)) %>% unnest(Interaction) %>% filter(containValidValue(Interaction)) %>% 
        distinct(ID, Interaction)
    interaction_summary <- interaction_papers %>% group_by(Interaction) %>% summarise(PaperNum = n_distinct(ID), 
        Papers = getCitations(ID, onlyID = TRUE), .groups = "drop") %>% arrange(desc(PaperNum), Interaction)
    TABLE <- paste0(GENERATED_FILES, "/RQ", rqNum, "_human_in_the_loop_summary.tex")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    on.exit(sink(), add = TRUE)
    cat("\\begin{tabular} {p{0.26\\textwidth} p{0.02\\textwidth} p{0.72\\textwidth}} \\\\ \n")
    cat("\\toprule \n")
    cat("Interaction & \\# & Papers\\\\ \n")
    cat("\\midrule  \n")
    for (i in seq_len(nrow(interaction_summary))) {
        cat(emphExp(formatTitleName(interaction_summary$Interaction[i])), " & ", interaction_summary$PaperNum[i], 
            " & ", interaction_summary$Papers[i], "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    return(interaction_summary)
}

LLM_enhanced <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, Technique = RQ10.EnhancementTechnique, Model = RQ10.EnhancedLLM, ModelTask = RQ5.MDETask, 
        ModelingLanguage = RQ6.ModelingLanguage) %>% filter(!is.na(Technique), !(Technique %in% c("N/A", "Unspecified")))
    enhanced_model_clean_and_flatten_df <- pmap_dfr(list(df$ID, df$Technique, df$Model), clean_and_flatten_copy, 
        id_col = "ID", metric_col = "Technique", norm_col = "Model") %>% filter(!is.na(Technique), !(Technique %in% 
        c("N/A", "Unspecified")), !is.na(Model), !(Model %in% c("N/A", "Unspecified")))
    enhanced_model_clean_and_flatten_df$Model <- unlist(lapply(enhanced_model_clean_and_flatten_df$Model, extractItemsInGroup))
    freq_enhanced_model_papers <- as.data.frame(table(enhanced_model_clean_and_flatten_df$Technique, enhanced_model_clean_and_flatten_df$Model))
    colnames(freq_enhanced_model_papers) <- c("Items", "Category", "Freq")
    bubble_plot(df = freq_enhanced_model_papers, xLabel = "Type of Enhanced Techniques", yLabel = "LLM Family", 
        fileName = paste0("RQ", rqNum, "_enhanced_venue_model_stacked_bar_number", sep = ""), width = 6, height = 8)
    enhanced_task_clean_and_flatten_df <- pmap_dfr(list(df$ID, df$ModelTask, df$Technique), clean_and_flatten_copy, 
        id_col = "ID", metric_col = "MDETask", norm_col = "Technique") %>% filter(!is.na(Technique), !(Technique %in% 
        c("N/A", "Unspecified")), !is.na(MDETask), !(MDETask %in% c("N/A", "Unspecified")))
    freq_enhanced_task_papers <- as.data.frame(table(enhanced_task_clean_and_flatten_df$Technique, enhanced_task_clean_and_flatten_df$MDETask))
    colnames(freq_enhanced_task_papers) <- c("Items", "Category", "Freq")
    stackedBarChart(data = freq_enhanced_task_papers, xLabel = "Enhanced Techniques", yLabel = "# of Papers", legendTitle = "MDETask", 
        fileName = paste0("RQ", rqNum, "_enhanced_venue_mdetask_stacked_bar_number", sep = ""), showTable = FALSE, 
        width = 12)
}

eff_metrics <- function(rqNum) {
    df <- ALL_SELECTED %>% select(ID, Metric = RQ14.EffectivenessMetric) %>% filter(containValidValue(Metric))
    df_expanded <- df %>% mutate(temp_data = map(Metric, splitMetrics)) %>% unnest(temp_data) %>% mutate(Category = case_when(Category == 
        "Sem" ~ "Semantic", Category == "Syn" ~ "Syntactic", TRUE ~ Category), Measurement = case_when(Measurement == 
        "Quant" ~ "Quantitative", Measurement == "Qual" ~ "Qualitative", TRUE ~ Measurement), ObjvsSubj = case_when(ObjvsSubj == 
        "obj" ~ "Objective", ObjvsSubj == "subj" ~ "Subjective", TRUE ~ ObjvsSubj), Reference = case_when(Reference == 
        "True" ~ "Ref-based", Reference == "False" ~ "Ref-free", TRUE ~ Reference), Combined = str_glue("{Measurement} ({ObjvsSubj}, {Reference})"))
    paired_metric_bases <- find_count_percentage_metric_bases(df_expanded$Label)
    write_metrics_table <- function(table_suffix, included_types) {
        TABLE = paste(GENERATED_FILES, "/RQ", rqNum, table_suffix, sep = "")
        unlink(TABLE)
        sink(TABLE, append = TRUE, split = TRUE)
        cat("\\begin{tabular} { p{0.15\\textwidth} p{0.3\\textwidth} p{0.85\\textwidth} } \\\\ \n")
        cat("\\toprule \n")
        cat("Scope & Aspect & Papers\\\\ \n")
        cat("\\midrule  \n")
        types <- unique(df_expanded$Category)
        types <- types[types %in% included_types]
        for (type in types) {
            df_type <- subset(df_expanded, df_expanded$Category == type)
            cat(type, " (", length(unique(df_type$ID)), ")", sep = "")
            aspects <- unique(df_type$Aspect)
            for (a_index in 1:length(aspects)) {
                aspect <- aspects[a_index]
                df_aspect <- subset(df_type, df_type$Aspect == aspect)
                cat(" & ", str_replace_all(aspect, "\\s*\\+\\s*", " + "), " (", length(unique(df_aspect$ID)), ")", 
                  sep = "")
                coms <- unique(df_aspect$Combined)
                for (c_index in 1:length(coms)) {
                  com <- coms[c_index]
                  if (c_index != 1) 
                    cat(" & ")
                  df_com <- subset(df_aspect, df_aspect$Combined == com)
                  formatted_com <- com
                  if (table_suffix %in% c("_metrics_semantic.tex", "_metrics_nonsemantic.tex")) {
                    label_colors <- c(Quantitative = "EAF2FB", Qualitative = "F3ECF8", Objective = "EAF5EC", Subjective = "FFF2E5", 
                      `Ref-based` = "E8F5F3", `Ref-free` = "FFF7DF")
                    for (label in names(label_colors)) {
                      formatted_com <- gsub(label, paste0("\\colorbox[HTML]{", label_colors[[label]], "}{", label, 
                        "}"), formatted_com, fixed = TRUE)
                    }
                  }
                  cat(" & \\textbf{", formatted_com, "}: ", sep = "")
                  combine_results <- format_metric_citations(df_com, group_by_metric_category = grepl("^Quantitative \\(Objective", 
                    com), paired_bases = paired_metric_bases)
                  cat(paste(combine_results, collapse = ", "))
                  cat("\\\\ \n")
                }
            }
        }
        cat("\\bottomrule \n")
        cat("\\end{tabular} \n")
        sink()
    }
    write_metrics_table("_metrics_semantic.tex", c("Semantic"))
    write_metrics_table("_metrics_nonsemantic.tex", setdiff(unique(df_expanded$Category), "Semantic"))
}

mdetask_metric_table <- function(rqNum, data = ALL_SELECTED) {
    metric_pairs <- data.frame(ID = character(), MDETask = character(), Metric = character())
    invalid_values <- c("", "n/a", "unspecified", "null", "none")
    metric_data <- data %>% select(ID, MDETaskMetric = RQ14.MDETaskMetric) %>% filter(containValidValue(MDETaskMetric))
    for (i in seq_len(nrow(metric_data))) {
        raw_value <- metric_data$MDETaskMetric[i]
        groups <- regmatches(raw_value, gregexpr("\\[([^]]+)\\]", raw_value, perl = TRUE))[[1]]
        if (length(groups) == 0) {
            groups <- raw_value
        }
        for (group_text in groups) {
            group_text <- gsub("^\\[|\\]$", "", group_text)
            group_data <- extractGroupNameAndContentAsDataframe(group_text, groupNameIfNull = "None")
            mde_task <- trimws(group_data$groupName)
            metrics <- trimws(unlist(strsplit(group_data$groupContent, ";\\s*", perl = TRUE)))
            metrics <- metrics[!(tolower(metrics) %in% invalid_values)]
            if (length(mde_task) == 0 || is.na(mde_task) || mde_task == "" || length(metrics) == 0) {
                next
            }
            metric_pairs <- rbind(metric_pairs, data.frame(ID = as.character(metric_data$ID[i]), MDETask = mde_task, 
                Metric = metrics))
        }
    }
    if (nrow(metric_pairs) == 0) {
        return(NULL)
    }
    metric_pairs <- metric_pairs %>% merge_count_percentage_metrics() %>% distinct(ID, MDETask, Metric)
    metric_summary <- metric_pairs %>% group_by(MDETask, Metric) %>% summarise(PaperNum = n_distinct(ID), .groups = "drop") %>% 
        arrange(MDETask, desc(PaperNum), Metric)
    task_order <- metric_pairs %>% group_by(MDETask) %>% summarise(PaperNum = n_distinct(ID), .groups = "drop") %>% 
        arrange(desc(PaperNum), MDETask) %>% pull(MDETask)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_mde_task_metrics.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.32\\textwidth} p{0.74\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("MDE Task & Metrics\\\\ \n")
    cat("\\midrule  \n")
    for (mde_task in task_order) {
        task_metrics <- subset(metric_summary, metric_summary$MDETask == mde_task)
        metric_text <- mapply(format_metric_with_color, task_metrics$Metric, task_metrics$PaperNum, USE.NAMES = FALSE)
        cat(clean_text_4latex(mde_task), " & ", paste(metric_text, collapse = "; "), "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
    return(metric_summary)
}

cost_metrics <- function(rqNum) {
    time_df <- ALL_SELECTED %>% select(ID, COST = RQ14.TimeCostMetric) %>% filter(containValidValue(COST, extraExclude = c("no"))) %>% 
        mutate(Category = "Time")
    resource_df <- ALL_SELECTED %>% select(ID, COST = RQ14.ResourceCostMetric) %>% filter(containValidValue(COST, 
        extraExclude = c("no"))) %>% mutate(Category = "Resource")
    df <- rbind(time_df, resource_df)
    total <- length(unique(df$ID))
    sorted_results <- df %>% mutate(cost_split = strsplit(as.character(COST), ";\\s*")) %>% unnest(cost_split) %>% 
        group_by(ID) %>% group_by(cost_split) %>% mutate(cost_freq = n()) %>% ungroup() %>% arrange(desc(cost_freq), 
        cost_split)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_cost_metrics.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.15\\textwidth} p{0.3\\textwidth} p{0.5\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Category & Metrics & Papers\\\\ \n")
    cat("\\midrule  \n")
    categories <- unique(sorted_results$Category)
    for (category in categories) {
        metrics <- subset(sorted_results, sorted_results$Category == category)
        cat(category, " (", length(unique(metrics$ID)), ")", sep = "")
        for (metric in unique(metrics$cost_split)) {
            metric_df <- subset(metrics, metrics$cost_split == metric)
            cat(" & ", clean_text_4latex(metric), " (", length(unique(metric_df$ID)), ")", " & ", getCitations(metric_df$ID, 
                onlyID = TRUE), "\\\\ \n", sep = "")
        }
    }
    cat("\\midrule  \n")
    ntime <- length(unique(time_df$ID))
    nresource <- length(unique(resource_df$ID))
    ntotal <- nrow(ALL_SELECTED)
    cat("Total\\textsubscript{time} & ", ntime, " & ", paste0("{", formatC(ntime * 100 / ntotal, digits = 2, format = "f"), "}\\%"), "\\\\ \n")
    cat("Total\\textsubscript{resource} & ", nresource, " & ", paste0("{", formatC(nresource * 100 / ntotal, digits = 2, format = "f"), "}\\%"), "\\\\ \n")
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

benchmark_vs_proposed_problems <- function(rqNum) {
    proposed_df <- DATA_TO_ANALYSIS %>% select(ID = ID, MDETask = RQ5.MDETask) %>% mutate(ID = as.character(ID), 
        StudyType = "Proposed papers")
    benchmark_df <- Benchmarks_PAPERS %>% select(ID = ID, MDETask = RQ5.MDETask) %>% mutate(ID = as.character(ID), 
        StudyType = "Benchmark papers")
    invalid_values <- c("n/a", "unspecified", "null", "")
    expand_mde_task <- function(data) {
        data %>% filter(!is.na(MDETask), str_squish(MDETask) != "", !(tolower(str_squish(MDETask)) %in% invalid_values)) %>% 
            mutate(MDETask = str_replace_all(MDETask, "\\[|\\]", "")) %>% separate_rows(MDETask, sep = ";\\s*") %>% 
            mutate(MDETask = str_squish(MDETask)) %>% filter(!is.na(MDETask), MDETask != "", !(tolower(MDETask) %in% 
            invalid_values)) %>% distinct(ID, StudyType, MDETask)
    }
    expanded_data <- bind_rows(expand_mde_task(proposed_df), expand_mde_task(benchmark_df))
    coverage_df <- expanded_data %>% distinct(MDETask, StudyType) %>% mutate(Covered = TRUE) %>% pivot_wider(names_from = StudyType, 
        values_from = Covered, values_fill = FALSE) %>% mutate(`Proposed papers` = ifelse(`Proposed papers`, "$\\checkmark$", 
        ""), `Benchmark papers` = ifelse(`Benchmark papers`, "$\\checkmark$", ""))
    task_order <- expanded_data %>% count(MDETask, name = "Total") %>% arrange(desc(Total), MDETask) %>% pull(MDETask)
    coverage_df <- coverage_df %>% mutate(MDETask = factor(MDETask, levels = task_order)) %>% arrange(MDETask)
    TABLE <- paste0(GENERATED_FILES, "/RQ", rqNum, "_proposed_vs_benchmark_mde_task_coverage.tex")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { l c c } \\\\ \n")
    cat("\\toprule \n")
    cat("MDE Task & Proposed Approach & Benchmarking/Evaluation\\\\ \n")
    cat("\\midrule \n")
    for (i in seq_len(nrow(coverage_df))) {
        cat(clean_text_4latex(as.character(coverage_df$MDETask[i])), " & ", coverage_df$`Proposed papers`[i], " & ", 
            coverage_df$`Benchmark papers`[i], "\\\\ \n", sep = "")
    }
    proposed_sum <- sum(coverage_df$`Proposed papers` == "$\\checkmark$")
    benchmark_sum <- sum(coverage_df$`Benchmark papers` == "$\\checkmark$")
    cat("\\midrule \n")
    cat("\\textbf{Sum} & \\textbf{", proposed_sum, "} & \\textbf{", benchmark_sum, "}\\\\ \n", sep = "")
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
    return(coverage_df)
}

baselines <- function(rqNum) {
    baseline_pairs <- data.frame(ID = character(), MDETask = character(), Baseline = character())
    invalid_values <- c("", "n/a", "unspecified", "null", "none")
    df <- ALL_SELECTED %>% select(ID, MDETaskBaseline = RQ15.MDETaskBaseline) %>% filter(containValidValue(MDETaskBaseline))
    for (i in seq_len(nrow(df))) {
        raw_value <- df$MDETaskBaseline[i]
        groups <- regmatches(raw_value, gregexpr("\\[([^]]+)\\]", raw_value, perl = TRUE))[[1]]
        if (length(groups) == 0) {
            groups <- raw_value
        }
        for (group_text in groups) {
            group_text <- gsub("^\\[|\\]$", "", group_text)
            group_data <- extractGroupNameAndContentAsDataframe(group_text, groupNameIfNull = "None")
            mde_task <- trimws(group_data$groupName)
            baselines <- trimws(unlist(strsplit(group_data$groupContent, ";\\s*", perl = TRUE)))
            baselines <- baselines[!(tolower(baselines) %in% invalid_values)]
            if (length(mde_task) == 0 || is.na(mde_task) || mde_task == "" || length(baselines) == 0) {
                next
            }
            baseline_pairs <- rbind(baseline_pairs, data.frame(ID = as.character(df$ID[i]), MDETask = mde_task, 
                Baseline = baselines))
        }
    }
    if (nrow(baseline_pairs) == 0) {
        return(NULL)
    }
    baseline_pairs <- baseline_pairs %>% mutate(Baseline = case_when(Baseline == "Machine learning" ~ "ML", Baseline == 
        "Machine Learning" ~ "ML", Baseline == "Lexical Database Matching" ~ "Lexical.", Baseline == "Ontolog matching" ~ 
        "Ontolog.", TRUE ~ Baseline))
    baselines_table(baseline_pairs, rqNum)
    baseline_summary <- baseline_pairs %>% distinct(ID, MDETask, Baseline) %>% count(Baseline, MDETask, name = "Freq") %>% 
        dplyr::rename(Items = Baseline, Category = MDETask)
    baseline_paper_totals <- baseline_pairs %>% distinct(ID, Baseline) %>% count(Baseline, name = "Top") %>% dplyr::rename(Items = Baseline)
    barChartFile <- paste("RQ", rqNum, "_baselines_summary_bar", sep = "")
    stackedBarChart100(data = baseline_summary, item_top_labels = baseline_paper_totals, xLabel = "Type of Baselines", 
        yLabel = "Percentage of Papers", legendTitle = "MDE Task", fileName = barChartFile, reorderBasedOnFreq = TRUE, 
        axisXAngle = 45, axisHjust = 1, axisVjust = 1, barwidth = 0.45, showTable = FALSE, x_mult = c(0.03, 0.04), 
        width = 12, height = 7)
}

benchmarks <- function(rqNum) {
    df <- ALL_SELECTED %>% select(ID, BenchmarkType = RQ16.EvaluationSubjectType)
    non_cs <- subset(df, !containValidValue(df$BenchmarkType, extraExclude = c("no")))
    only_closed <- subset(df, trimws(df$BenchmarkType) == "Closed")
    has_open <- subset(df, grepl("Open", df$BenchmarkType))
    industrial_open_cs <- subset(df, grepl("industrial - open", tolower(df$BenchmarkType)))
    industrial_closed_cs <- subset(df, grepl("industrial - closed", tolower(df$BenchmarkType)))
    results <- data.frame(Items = c("None", "Closed Non-Industrial CS", "Open Non-Industrial CS", "Open Industrial CS", 
        "Closed Industrial CS"), Freq = c(nrow(non_cs), nrow(only_closed), nrow(has_open), nrow(industrial_open_cs), 
        nrow(industrial_closed_cs)))
    barChartFile <- paste("RQ", rqNum, "_benchmark_summary_bar", sep = "")
    barChart(results, xLabel = "Type of Benchmarks and Datesets", yLabel = "# of Papers", fileName = barChartFile, 
        reorderBasedOnFreq = TRUE, axisXAngle = 45, axisHjust = 1, axisVjust = 1)
}

replication <- function(rqNum) {
    df <- ALL_SELECTED %>% select(ID, Replication = RQ16.AvailableComponents) %>% filter(containValidValue(Replication))
    results <- df %>% filter(containValidValue(Replication)) %>% mutate(Component = strsplit(as.character(Replication), 
        ";\\s*")) %>% unnest(Component) %>% group_by(ID) %>% mutate(Component = case_when(Component == "Benchmark" ~ 
        "Evaluated Subject", Component == "Model" ~ "Enhanced-LLM", Component == "Code" ~ "Source Code", TRUE ~ 
        Component)) %>% distinct(ID, Component, .keep_all = TRUE)
    Items <- results$Component
    freq_num <- as.data.frame(table(Items))
    freq_num <- freq_num[order(freq_num$Items, decreasing = FALSE), ]
    barChartFile <- paste("RQ", rqNum, "_replication_component_summary_bar", sep = "")
    barChart(freq_num, xLabel = "Type of Replicable Artifacts", yLabel = "# of Papers", fileName = barChartFile, 
        reorderBasedOnFreq = TRUE, axisXAngle = 45, axisHjust = 1, axisVjust = 1)
    sorted_df <- df %>% group_by(Replication) %>% mutate(TotalFreq = n()) %>% ungroup() %>% mutate(sep_count = str_count(Replication, 
        ";") + 1) %>% arrange(desc(sep_count), desc(TotalFreq), Replication, ID) %>% select(-TotalFreq, -sep_count)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_replication.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.08\\textwidth} p{0.12\\textwidth} p{0.12\\textwidth} p{0.12\\textwidth} p{0.15\\textwidth}  | p{0.08\\textwidth} p{0.12\\textwidth} p{0.12\\textwidth} p{0.12\\textwidth} p{0.15\\textwidth}  } \\\\ \n")
    cat("\\toprule \n")
    cat("Paper & Source Code & Prompt & Enhanced-LLM & Evaluation Subject & Paper & Source Code & Prompt & Enhanced-LLM & Evaluation Subject \\\\ \n")
    cat("\\midrule  \n")
    papers <- sorted_df$ID
    columns_num <- 2
    rows_num <- (length(papers) + 1)/2
    for (row_index in 1:rows_num) {
        for (col_index in 1:columns_num) {
            index <- (col_index - 1) * rows_num + row_index
            if (col_index != 1) 
                cat(" & ")
            if (index <= length(papers)) {
                paper <- papers[[index]]
                cat(getCitations(paper, onlyID = TRUE))
                cat(" & ")
                row <- subset(ALL_SELECTED, ALL_SELECTED$ID == paper)
                cat(extract_urls_valid(row$RQ16.SourceCodeLink, aliasName = "link"))
                cat(" & ")
                cat(extract_urls_valid(row$RQ16.PromptLink, aliasName = "link"))
                cat(" & ")
                cat(extract_urls_valid(row$RQ16.EnhancedLLMLink, aliasName = "link"))
                cat(" & ")
                cat(extract_urls_valid(row$RQ16.EvaluationSubjectLink, aliasName = "link"))
            }
            else {
                cat(" & & & &")
            }
        }
        cat("\\\\ \n")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
    component_order <- c(Code = 1, Prompt = 2, `Enhanced-LLM` = 3, `Evaluation Subject` = 4)
    sorted_df_freq <- sorted_df %>% mutate(Replication = str_replace_all(Replication, "Benchmark", "Evaluation Subject"), 
        Replication = str_replace_all(Replication, "Model", "Enhanced-LLM"), Replication = str_replace_all(Replication, 
            "Code", "Source Code"), Replication = map_chr(Replication, function(x) {
            parts <- str_split(x, ";")[[1]] %>% str_trim()
            sorted_parts <- parts[order(match(parts, names(component_order)))]
            paste(sorted_parts, collapse = " + ")
        })) %>% group_by(Replication) %>% mutate(Replication_freq = n()) %>% ungroup()
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_components_replication.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.5\\textwidth} p{0.02\\textwidth} p{0.5\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Artifacts & \\# & Papers\\\\ \n")
    cat("\\midrule  \n")
    components <- unique(sorted_df_freq$Replication)
    for (component in components) {
        comp_df <- subset(sorted_df_freq, sorted_df_freq$Replication == component)
        cat(component, " & ", length(unique(comp_df$ID)), " & ", getCitations(comp_df$ID, onlyID = TRUE), "\\\\ \n", 
            sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

benchmarks_comparison <- function(rqNum) {
    df <- Benchmarks_PAPERS %>% select(ID, LLM = RQ8.FoundationLLMFamiliy, Prompt = RQ9.Prompt.engineering)
    llm_order <- c("GPT", "LLaMA", "Mistral", "Gemini", "Claude", "DeepSeek", "Qwen", "BERT", "Gemma", "PaLM", 
        "Phi", "BART", "GLM", "T5", "Codex", "WizardLM", "Aya", "Baichuan", "BLOOM", "C4AI", "CodeGen", "CodeParrot", 
        "Codestral", "CogVLM", "Electra", "Falcon", "GitHub Copilot", "GraniteMoE", "Grok", "InternVL", "Kimi", 
        "LED", "LLaVA", "MiniLM", "Nova", "OLMo", "OpenChat", "Phind", "Pixtral", "StableLM", "StarCoder", "TeleChat", 
        "Vicuna", "XLNet", "Zephyr")
    llm_aliases <- c(Gemni = "Gemini")
    extract_comparison_items <- function(raw_value) {
        if (!containValidValue(raw_value)) 
            return(character(0))
        str_replace_all(raw_value, "\\[|\\]", "") %>% str_split(";\\s*") %>% unlist() %>% str_trim() %>% .[. != 
            ""] %>% .[!(tolower(.) %in% c("n/a", "unspecified", "null"))] %>% unique()
    }
    llm_comparison_label <- function(raw_value) {
        items <- extract_comparison_items(raw_value)
        items <- ifelse(items %in% names(llm_aliases), llm_aliases[items], items)
        items <- llm_order[llm_order %in% items]
        if (length(items) < 2) 
            return("-")
        paste(items, collapse = " vs. ")
    }
    prompt_comparison_label <- function(raw_value) {
        items <- extract_comparison_items(raw_value)
        items <- str_replace_all(items, "Iterative\\s*\\([^)]*\\)", "Iterative")
        if (length(items) < 2) 
            return("-")
        paste(items, collapse = " vs. ")
    }
    labelled_df <- df %>% mutate(LLMComparison = map_chr(LLM, llm_comparison_label), PromptComparison = map_chr(Prompt, 
        prompt_comparison_label))
    total_papers <- n_distinct(labelled_df$ID)
    no_comparison_num <- labelled_df %>% filter(LLMComparison == "-", PromptComparison == "-") %>% summarise(n = n_distinct(ID)) %>% 
        pull(n)
    only_llm_comparison_num <- labelled_df %>% filter(LLMComparison != "-", PromptComparison == "-") %>% summarise(n = n_distinct(ID)) %>% 
        pull(n)
    only_prompt_comparison_num <- labelled_df %>% filter(LLMComparison == "-", PromptComparison != "-") %>% summarise(n = n_distinct(ID)) %>% 
        pull(n)
    both_comparison_num <- labelled_df %>% filter(LLMComparison != "-", PromptComparison != "-") %>% summarise(n = n_distinct(ID)) %>% 
        pull(n)
    with_comparison_num <- total_papers - no_comparison_num
    no_comparison_pct <- ifelse(total_papers == 0, 0, no_comparison_num/total_papers * 100)
    only_llm_comparison_pct <- ifelse(total_papers == 0, 0, only_llm_comparison_num/total_papers * 100)
    only_prompt_comparison_pct <- ifelse(total_papers == 0, 0, only_prompt_comparison_num/total_papers * 100)
    both_comparison_pct <- ifelse(total_papers == 0, 0, both_comparison_num/total_papers * 100)
    with_comparison_pct <- ifelse(total_papers == 0, 0, with_comparison_num/total_papers * 100)
    comparison_df <- labelled_df %>% filter(!(LLMComparison == "-" & PromptComparison == "-")) %>% group_by(LLMComparison, 
        PromptComparison) %>% summarise(PaperNum = n_distinct(ID), Papers = getCitations(ID, onlyID = TRUE), .groups = "drop") %>% 
        arrange(desc(PaperNum), LLMComparison, PromptComparison)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_benchmarks_comparison.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.45\\textwidth} p{0.45\\textwidth} p{0.2\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("LLM Comparison & Prompt Comparison & Papers\\\\ \n")
    cat("\\midrule  \n")
    for (i in 1:nrow(comparison_df)) {
        cat(clean_text_4latex(comparison_df$LLMComparison[i]), " & ", clean_text_4latex(comparison_df$PromptComparison[i]), 
            " & ", comparison_df$Papers[i], "\\\\ \n", sep = "")
    }
    cat("\\midrule \n")
    cat("\\textbf{Summary} & & \\\\ \n")
    cat("Only LLM comparison: & ", only_llm_comparison_num, "& ", "\\\\ \n", sep = "")
    cat("Only Prompt comparison: & ", only_prompt_comparison_num, "& ", "\\\\ \n", sep = "")
    cat("Both LLM and Prompt comparison: & ", both_comparison_num, "& ", "\\\\ \n", sep = "")
    cat("With LLM/prompt comparison: & ", with_comparison_num, " (", sprintf("%.1f", with_comparison_pct), "\\%) &", 
        "\\\\ \n", sep = "")
    cat("Without LLM/prompt comparison: & ", no_comparison_num, " (", sprintf("%.1f", no_comparison_pct), "\\%) & \\\\ \n", 
        sep = "")
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

benchmarks_problems <- function(rqNum) {
    df <- Benchmarks_PAPERS %>% select(ID, MDETask = RQ5.MDETask, SEActivity = RQ4.SEActivity, SETask = RQ4.SETask, 
        ModelingLanguageModelType = RQ6.ModelingLanguageModelType, ApplicationDomain = RQ7.ApplicationDomain)
    expand_benchmark_field <- function(data, raw_col, item_col = "Item") {
        data %>% select(ID, Raw = {
            {
                raw_col
            }
        }) %>% filter(containValidValue(Raw)) %>% mutate(Item = str_replace_all(Raw, "\\[|\\]", "")) %>% separate_rows(Item, 
            sep = ";\\s*") %>% mutate(Item = str_squish(Item)) %>% filter(!is.na(Item), Item != "", !(tolower(Item) %in% 
            c("n/a", "unspecified", "null"))) %>% distinct(ID, Item) %>% rename_with(~item_col, .cols = Item)
    }
    parse_model_language_model_type <- function(id, raw_value) {
        if (!containValidValue(raw_value)) 
            return(NULL)
        matches <- str_match_all(raw_value, "\\[([^:\\]]+)\\s*:\\s*([^\\]]+)\\]")[[1]]
        if (nrow(matches) == 0) 
            return(NULL)
        pmap_dfr(list(matches[, 2], matches[, 3]), function(model_language, model_types) {
            types <- str_split(model_types, ";\\s*")[[1]] %>% str_trim() %>% .[. != ""] %>% .[!(tolower(.) %in% 
                c("n/a", "unspecified", "null"))]
            tibble(ID = id, ModelingLanguage = str_squish(model_language), ModelType = types)
        }) %>% filter(!is.na(ModelingLanguage), ModelingLanguage != "", !(tolower(ModelingLanguage) %in% c("n/a", 
            "unspecified", "null"))) %>% distinct(ID, ModelingLanguage, ModelType)
    }
    language_model_type_df <- pmap_dfr(list(df$ID, df$ModelingLanguageModelType), parse_model_language_model_type)
    old_table <- paste(GENERATED_FILES, "/RQ", rqNum, "_benchmarks_problems.tex", sep = "")
    unlink(old_table)
    se_pairs <- df %>% select(ID, SEActivity, SETask) %>% filter(containValidValue(SEActivity), containValidValue(SETask)) %>% 
        mutate(SEActivity = str_replace_all(SEActivity, "\\[|\\]", ""), SETask = str_replace_all(SETask, "\\[|\\]", 
            "")) %>% separate_rows(SEActivity, sep = ";\\s*") %>% separate_rows(SETask, sep = ";\\s*") %>% mutate(SEActivity = str_squish(SEActivity), 
        SETask = str_squish(SETask)) %>% filter(!is.na(SEActivity), !is.na(SETask), SEActivity != "", SETask != 
        "", !(tolower(SEActivity) %in% c("n/a", "unspecified", "null", "unspecified context")), !(tolower(SETask) %in% 
        c("n/a", "unspecified", "null"))) %>% distinct(ID, SEActivity, SETask)
    se_summary <- se_pairs %>% group_by(SEActivity, SETask) %>% summarise(PaperNum = n_distinct(ID), Papers = getCitations(ID, 
        onlyID = TRUE), .groups = "drop") %>% group_by(SEActivity) %>% mutate(ActivityTotal = sum(PaperNum)) %>% 
        ungroup() %>% arrange(desc(ActivityTotal), SEActivity, desc(PaperNum), SETask)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_benchmarks_se.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.22\\textwidth} p{0.26\\textwidth} p{0.04\\textwidth} p{0.58\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("SE Activity & SE Task & \\# & Papers\\\\ \n")
    for (activity in unique(se_summary$SEActivity)) {
        activity_df <- se_summary %>% filter(SEActivity == activity)
        cat("\\midrule  \n")
        for (i in seq_len(nrow(activity_df))) {
            activity_label <- ifelse(i == 1, formatTitleName(activity), "")
            cat(clean_text_4latex(activity_label), " & ", emphExp(clean_text_4latex(formatTitleName(formatTaskName(activity_df$SETask[i])))), 
                " & ", activity_df$PaperNum[i], " & ", activity_df$Papers[i], "\\\\ \n", sep = "")
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
    mde_df <- expand_benchmark_field(df, MDETask, "MDETask")
    modeling_pairs <- mde_df %>% inner_join(language_model_type_df, by = "ID", relationship = "many-to-many") %>% 
        distinct(ID, MDETask, ModelingLanguage, ModelType)
    modeling_summary <- modeling_pairs %>% group_by(MDETask, ModelingLanguage, ModelType) %>% summarise(PaperNum = n_distinct(ID), 
        Papers = getCitations(ID, onlyID = TRUE), .groups = "drop") %>% left_join(modeling_pairs %>% group_by(MDETask) %>% 
        summarise(MDETaskPaperNum = n_distinct(ID), .groups = "drop"), by = "MDETask") %>% group_by(MDETask) %>% 
        mutate(MDETaskTotal = sum(PaperNum)) %>% ungroup() %>% group_by(MDETask, ModelingLanguage) %>% mutate(LanguageTotal = sum(PaperNum)) %>% 
        ungroup() %>% arrange(desc(MDETaskTotal), MDETask, desc(LanguageTotal), ModelingLanguage, desc(PaperNum), 
        ModelType)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_benchmarks_modeling.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.35\\textwidth} p{0.19\\textwidth} p{0.24\\textwidth} p{0.02\\textwidth} p{0.30\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("MDE Task & Modeling Language & Model Type & \\# & Papers\\\\ \n")
    cat("\\midrule  \n")
    for (mde_task in unique(modeling_summary$MDETask)) {
        task_df <- modeling_summary %>% filter(MDETask == mde_task)
        for (language in unique(task_df$ModelingLanguage)) {
            language_df <- task_df %>% filter(ModelingLanguage == language)
            for (i in seq_len(nrow(language_df))) {
                task_label <- ifelse(language == unique(task_df$ModelingLanguage)[1] && i == 1, paste0(mde_task, 
                  " (", language_df$MDETaskPaperNum[i], ")"), "")
                language_label <- ifelse(i == 1, language, "")
                cat(clean_text_4latex(task_label), " & ", clean_text_4latex(language_label), " & ", clean_text_4latex(language_df$ModelType[i]), 
                  " & ", language_df$PaperNum[i], " & ", language_df$Papers[i], "\\\\ \n", sep = "")
            }
        }
        if (mde_task != tail(unique(modeling_summary$MDETask), 1)) 
            cat("\\midrule \n")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

rq2Table <- function(data) {
    RQ2_label <- RQ_label_prefix(2)
    for (v in sort(unique(data$venueType))) {
        ss <- subset(data, data$venueType == v)
        maxValue <- max(ss$value)
        venueInCmd <- formatString(v)
        RQ_results <<- rbind(RQ_results, c(RQ2_label, paste("maxNum", venueInCmd, sep = ""), maxValue))
        vs <- (subset(ss, ss$value == maxValue))$venue
        if (length(vs) == 1) 
            RQ_results <<- rbind(RQ_results, c(RQ2_label, paste("max", venueInCmd, sep = ""), emphExp(vs[1])))
        else {
            for (i in 1:length(vs)) {
                RQ_results <<- rbind(RQ_results, c(RQ2_label, paste("max", venueInCmd, formatString(nom_ord(strtoi(i))), 
                  sep = ""), emphExp(vs[i])))
            }
        }
    }
    data_merged <- data %>% group_by(venueAKA) %>% summarise(venue = first(venue), venueType = first(venueType), 
        value = sum(value))
    data_sorted <- data_merged[order(-data_merged$value), ]
    TABLE = paste(GENERATED_FILES, "/RQ2_venue.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { l p{0.8\\textwidth} r r} \\\\ \n")
    cat("\\toprule \n")
    cat(" & Venue &  \\#Papers & Venue Type \\\\ \n")
    cat("\\midrule  \n")
    for (i in 1:nrow(data_sorted)) {
        cat("", i, " & \\emph{", modify_venue_abbreviation(data_sorted$venueAKA[i]), "} & ", data_sorted$value[i], 
            " & ", data_sorted$venueType[i], "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

rq3VenueType <- function() {
    rqNum <- 3
    RQ3_label <- RQ_label_prefix(3)
    Items <- trimws(ALL_SELECTED$RQ3.VenueType)
    freq_venuetype <- as.data.frame(table(Items))
    freq_venuetype <- freq_venuetype[order(freq_venuetype$Items, decreasing = FALSE), ]
    barChartFile <- paste("RQ", rqNum, "_venue_type_bar", sep = "")
    barChart(freq_venuetype, xLabel = "Type of Venue", yLabel = "# of Papers", fileName = barChartFile, reorderBasedOnFreq = TRUE, 
        width = 8, height = 6, axisXAngle = 0, axisHjust = 0.5, axisVjust = 0.2, barwidth = 0.2)
}

rq3PaperType <- function() {
    ptypes <- sort(unique(ALL_SELECTED$RQ3.PaperType))
    paperTypeSummary <- ALL_SELECTED %>% count(RQ3.PaperType, name = "amount")
    RQ3_label <- RQ_label_prefix(3)
    collectRQResults(paperTypeSummary, RQ3_label)
    data <- data.frame(category = paperTypeSummary$RQ3.PaperType, value = paperTypeSummary$amount)
    pieChart("RQ3_paper_type", data, summarizedData = TRUE, w = 6, h = 7)
}

modelinglanguage <- function(rqNum) {
    Language <- removeItems(extractAll(DATA_TO_ANALYSIS$RQ6.ModelingLanguage), c("Unspecified"))
    ptypes <- sort(unique(Language))
    LanguageSummary <- as.data.frame(table(Language))
    RQ_label <- RQ_label_prefix(rqNum)
    collectRQResults(LanguageSummary, RQ_label)
    orderBarFile <- paste("RQ", rqNum, "_modeling_language", sep = "")
    orderBarChart(data = Language, xLabel = "Number of modeling languages", yLabel = "Modeling Language", orderBarFile, 
        width = 14, height = 6)
}

modelType <- function(rqNum) {
    ModelType <- removeItems(extractAll(DATA_TO_ANALYSIS$RQ6.ModelType), c("Unspecified", "N/A"))
    ptypes <- sort(unique(ModelType))
    ModelTypeSummary <- as.data.frame(table(ModelType))
    RQ_label <- RQ_label_prefix(rqNum)
    collectRQResults(ModelTypeSummary, RQ_label)
    orderBarFile <- paste("RQ", rqNum, "_model_type", sep = "")
    orderBarChart(data = ModelType, xLabel = "Number of model types", yLabel = "Model Type", orderBarFile, width = 14, 
        height = 10)
}

modelCategory <- function(rqNum) {
    Category <- extractAll(DATA_TO_ANALYSIS$RQ6.Category)
    ptypes <- sort(unique(Category))
    CategorySummary <- as.data.frame(table(Category))
    RQ_label <- RQ_label_prefix(rqNum)
    collectRQResults(CategorySummary, RQ_label)
    data <- data.frame(category = CategorySummary$Category, value = CategorySummary$Freq)
    pieChartFile <- paste("RQ", rqNum, "_model_category", sep = "")
    pieChart(pieChartFile, data, summarizedData = TRUE, w = 6, h = 5)
}

model_type_category_definition <- function(rqNum) {
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_model_type_category_definitions.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.22\\textwidth} p{0.75\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Category & Definition\\\\ \n")
    cat("\\midrule  \n")
    for (category in names(model_type_category_mapping)) {
        definition <- model_type_category_definition_mapping[[category]]
        if (is.null(definition)) {
            definition <- "-"
        }
        category_label <- str_replace_all(category, "\\n", " ")
        cat(clean_text_4latex(category_label), " & ", clean_text_4latex(definition), "\\\\ \n", sep = "")
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

model_type_category <- function(rqNum) {
    df <- DATA_TO_ANALYSIS %>% select(ID, ModelType = RQ6.ModelType) %>% filter(!(tolower(ModelType) %in% c("n/a", 
        "unspecified", "null")), )
    mapping_df <- stack(model_type_category_mapping) %>% select(ModelType = values, Category = ind) %>% mutate(Category = as.character(Category), 
        Category = str_to_title(Category))
    df_processed <- df %>% mutate(ModelType = str_replace_all(ModelType, "\\[|\\]", "")) %>% separate_rows(ModelType, 
        sep = ";\\s*") %>% mutate(ModelType = str_trim(ModelType)) %>% group_by(ModelType) %>% summarise(Freq = n(), 
        .groups = "drop") %>% left_join(mapping_df, by = "ModelType") %>% mutate(Category = replace_na(Category, 
        "unclassified"))
    category_totals <- df %>% mutate(ModelType = str_replace_all(ModelType, "\\[|\\]", "")) %>% separate_rows(ModelType, 
        sep = ";\\s*") %>% mutate(ModelType = str_trim(ModelType)) %>% left_join(mapping_df, by = "ModelType") %>% 
        mutate(Category = replace_na(Category, "unclassified")) %>% distinct(Category, ID) %>% count(Category, 
        name = "CategoryTotal")
    orderedBarChartWithColorCategory(data = df_processed, xLabel = "Number of model types", yLabel = "Model Type", 
        fileName = paste0("RQ", rqNum, "_modeltype_by_category"), width = 11, height = 8, category_totals = category_totals, 
        category_total_denominator = n_distinct(df$ID))
}

model_type_category_table <- function(rqNum, data = DATA_TO_ANALYSIS) {
    mapping_df <- stack(model_type_category_mapping) %>% transmute(ModelType = as.character(values), Category = str_to_title(as.character(ind)))
    models <- data %>% select(ID, ModelType = RQ6.ModelType) %>% filter(!(tolower(ModelType) %in% c("n/a", "unspecified", 
        "null"))) %>% mutate(ModelType = str_replace_all(ModelType, "\\[|\\]", "")) %>% separate_rows(ModelType, 
        sep = ";\\s*") %>% mutate(ModelType = str_trim(ModelType)) %>% left_join(mapping_df, by = "ModelType") %>% 
        mutate(Category = replace_na(Category, "unclassified")) %>% distinct(ID, Category, ModelType)
    category_totals <- models %>% distinct(ID, Category) %>% count(Category, name = "PaperNum") %>% arrange(desc(PaperNum), 
        Category)
    model_summary <- models %>% group_by(Category, ModelType) %>% summarise(PaperNum = n_distinct(ID), Papers = getCitations(ID, 
        onlyID = TRUE), .groups = "drop")
    TABLE <- paste0(GENERATED_FILES, "/RQ", rqNum, "_model_type_category.tex")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    on.exit(sink(), add = TRUE)
    cat("\\begin{tabular} {p{0.24\\textwidth}  p{0.26\\textwidth} p{0.02\\textwidth} p{0.48\\textwidth}} \\\\ \n")
    cat("\\toprule \n")
    cat("Category & Model type & \\# & Papers\\\\ \n")
    for (category in category_totals$Category) {
        category_total <- category_totals$PaperNum[category_totals$Category == category]
        model_types <- model_summary %>% filter(Category == category) %>% arrange(desc(PaperNum), ModelType)
        cat("\\midrule  \n")
        cat(formatTitleName(str_replace_all(category, "\\n", "")), " (", category_total, ")", sep = "")
        for (i in seq_len(nrow(model_types))) {
            cat(" & ", emphExp(formatTitleName(model_types$ModelType[i])), " & ", model_types$PaperNum[i], " & ", 
                model_types$Papers[i], "\\\\ \n", sep = "")
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    return(model_summary)
}

stackedBarChart100 <- function(data, item_top_labels = NULL, xLabel = "x", yLabel = "y", legendTitle = "Category", 
    fileName = "default_100_stacked_bar", width = 8, height = 6, reorderBasedOnFreq = TRUE, axisXAngle = 0, axisHjust = 0.5, 
    axisVjust = 1, barwidth = 0.3, textGap = 0.12, showTable = TRUE, x_mult = c(0.1, 0.15), col_set = "Set3") {
    data <- data %>% group_by(Items, Category) %>% summarise(Freq = sum(Freq, na.rm = TRUE), .groups = "drop")
    if (!is.factor(data$Category)) {
        data$Category <- as.factor(data$Category)
    }
    item_totals <- data %>% group_by(Items) %>% summarise(Total = sum(Freq, na.rm = TRUE), .groups = "drop")
    if (reorderBasedOnFreq) {
        data <- data %>% left_join(item_totals, by = "Items") %>% mutate(Items = reorder(Items, -Total))
    }
    else {
        data <- data %>% left_join(item_totals, by = "Items") %>% mutate(Items = factor(Items))
    }
    item_levels <- levels(data$Items)
    item_totals <- item_totals %>% mutate(Items = factor(Items, levels = item_levels), Top = Total)
    if (!is.null(item_top_labels)) {
        item_totals <- item_totals %>% select(-Top) %>% left_join(item_top_labels, by = "Items") %>% mutate(Items = factor(Items, 
            levels = item_levels)) %>% mutate(Top = ifelse(is.na(Top), Total, Top))
    }
    data <- data %>% mutate(Percentage = Freq/Total) %>% arrange(Items, desc(Category)) %>% group_by(Items) %>% 
        mutate(n_cat = n_distinct(Category[Freq > 0]), y_top = cumsum(Percentage), y_mid = y_top - (Percentage/2)) %>% 
        ungroup()
    n_cats <- length(unique(data$Category))
    fill_palette <- colorRampPalette(brewer.pal(min(n_cats, 12), col_set))(n_cats)
    p <- ggplot(data, aes(x = as.numeric(Items), y = Percentage)) + geom_col(aes(fill = Category), colour = "black", 
        width = barwidth, linewidth = 0.3) + geom_segment(data = data %>% filter(Freq > 0, n_cat > 1), aes(x = as.numeric(Items) + 
        (barwidth/2), xend = as.numeric(Items) + (barwidth/2) + (textGap * 0.7), y = y_mid, yend = y_mid), color = "grey30", 
        linewidth = 0.3) + geom_text(data = data %>% filter(Freq > 0, n_cat > 1), aes(x = as.numeric(Items) + (barwidth/2) + 
        textGap, y = y_mid, label = Freq), hjust = 0, size = 3.5, color = "black") + geom_text(data = item_totals, 
        aes(x = as.numeric(Items), y = 1, label = Top), vjust = -0.5, size = 4, fontface = "bold", color = "black") + 
        scale_fill_manual(values = fill_palette, name = legendTitle) + labs(x = xLabel, y = yLabel) + coord_cartesian(clip = "off") + 
        theme_classic() + theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), axis.text.x = element_text(color = "black", 
        size = 12, angle = axisXAngle, hjust = axisHjust, vjust = axisVjust), axis.text.y = element_text(color = "black", 
        size = 12, margin = margin(r = 5)), axis.title = element_text(size = 13), panel.grid = element_blank(), 
        axis.line = element_line(colour = "black"), plot.margin = unit(c(5, 4, 0, 5), "mm"), legend.position = "top") + 
        scale_x_continuous(breaks = seq_along(item_levels), labels = item_levels, expand = expansion(mult = x_mult)) + 
        scale_y_continuous(labels = scales::percent_format(accuracy = 1), expand = expansion(mult = c(0, 0.15)))
    if (showTable) {
        cat_summary <- data %>% group_by(Category) %>% summarise(Total = sum(Freq, na.rm = TRUE), .groups = "drop") %>% 
            mutate(Percentage = paste0(formatC(Total/sum(Total) * 100, digits = 2, format = "f"), "%")) %>% arrange(desc(Total))
        colnames(cat_summary) <- c(legendTitle, "Total Count", "Percentage")
        n_rows <- nrow(cat_summary)
        core_hjust <- c(rep(0, n_rows), rep(1, n_rows), rep(1, n_rows))
        core_x <- c(rep(0.1, n_rows), rep(0.9, n_rows), rep(0.9, n_rows))
        head_hjust <- c(0, 1, 1)
        head_x <- c(0.1, 0.9, 0.9)
        row_colors <- rep(c("grey95", "white"), length.out = n_rows)
        core_fill <- rep(row_colors, times = 3)
        tt <- ttheme_minimal(core = list(bg_params = list(fill = core_fill, col = NA), fg_params = list(hjust = core_hjust, 
            x = core_x), padding = unit(c(4, 6), "mm")), colhead = list(fg_params = list(hjust = head_hjust, x = head_x, 
            fontface = "bold"), padding = unit(c(4, 8), "mm")))
        tbl <- tableGrob(cat_summary, rows = NULL, theme = tt)
        tbl$widths <- unit(c(8, 3.5, 3.5), "cm")
        separator <- segmentsGrob(x0 = unit(0.05, "npc"), y0 = unit(0.5, "npc"), x1 = unit(0.95, "npc"), y1 = unit(0.5, 
            "npc"), gp = gpar(col = "grey50", lwd = 1.2, lty = "dashed"))
        final_plot <- arrangeGrob(p, separator, tbl, heights = c(4, 0.05, 1.4))
        save_height <- height + 1.6
    }
    else {
        final_plot <- p
        save_height <- height
    }
    ggsave(paste0(GENERATED_FILES, "/", fileName, ".pdf"), plot = final_plot, height = save_height, width = width, 
        dpi = 300)
    return(final_plot)
}

seTable <- function(data, rqNum) {
    SEActivity <- data$RQ4.SEActivity
    freq_phase_df <- as.data.frame(table(SEActivity))
    freq_phase_df <- freq_phase_df[order(freq_phase_df$Freq, decreasing = TRUE), ]
    phs <- as.character(freq_phase_df$SEActivity)
    se_task <- data$RQ4.SETask
    SETask <- extractAll(se_task)
    freq_df <- as.data.frame(table(SETask))
    freq_df <- freq_df[order(freq_df$Freq, decreasing = TRUE), ]
    RQ_label <- RQ_label_prefix(rqNum)
    TABLE = paste(GENERATED_FILES, "/RQ4_se.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} {p{0.24\\textwidth}  p{0.26\\textwidth} p{0.02\\textwidth} p{0.48\\textwidth}} \\\\ \n")
    cat("\\toprule \n")
    cat("SE Activity & SE Task & \\# & Papers\\\\ \n")
    ps <- as.character(freq_df$SETask)
    probs_across <- c()
    for (ph in phs) {
        ph_data <- subset(data, grepl(ph, data$RQ4.SEActivity))
        index <- 0
        probs <- orderSETasks(ph_data)
        for (p in probs) {
            ps_data <- subset(ph_data, grepl(p, ph_data$RQ4.SETask))
            if (nrow(ps_data) > 0) {
                index <- index + 1
                if (index == 1) {
                  cat("\\midrule  \n")
                  cat(formatTitleName(ph), " (", if (formatTitleName(ph) == "SE Models And Methods") paste0("{", length(unique(ph_data$ID)), "}") else length(unique(ph_data$ID)), ")", sep = "")
                }
                ac_num <- length(unique(extractAllWithGroup(subset(data, grepl(p, data$RQ4.SETask))$RQ4.SEActivity)))
                p_intable <- emphExp(formatTitleName(formatTaskName(p)))
                if (ac_num > 1) {
                  p_intable <- multipleSEProblem(p_intable)
                  probs_across <- append(probs_across, p)
                }
                cat(" & ", p_intable, " & ", if (formatTitleName(ph) == "SE Models And Methods") paste0("{", length(unique(ps_data$ID)), "}") else length(unique(ps_data$ID)), " & ", getCitations(ps_data, ID_cols_name = "ID"), 
                  "\\\\ \n", sep = "")
            }
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

identify_abstract_category <- function(category_name) {
    for (abstract_cat in names(category_mapping)) {
        if (tolower(category_name) %in% tolower(category_mapping[[abstract_cat]])) {
            return(abstract_cat)
        }
    }
    return(category_name)
}

collectRQResults <- function(summaryData, RQLabel) {
    for (pi in 1:nrow(summaryData)) {
        RQ_results <<- rbind(RQ_results, c(RQLabel, paste("NumOf", summaryData[pi, 1], sep = ""), summaryData[pi, 
            2]))
        RQ_results <<- rbind(RQ_results, c(RQLabel, paste("PercentOf", summaryData[pi, 1], sep = ""), percentage_exp(summaryData[pi, 
            2], TOTAL_NUM_SELECTED_PAPERS)))
    }
}

splitMetrics <- function(raw_string) {
    items <- str_split(raw_string, "(?<=\\]);\\s*")[[1]]
    df <- data.frame(full_text = items) %>% extract(full_text, into = c("Label", "Properties"), regex = "(.*)\\[(.*)\\]") %>% 
        separate(Properties, into = c("Category", "Aspect", "Reference", "Measurement", "ObjvsSubj"), sep = ";\\s*")
    return(df)
}

find_count_percentage_metric_bases <- function(metrics) {
    count_percentage_metrics <- data.frame(Metric = metrics) %>% filter(grepl("^(#|%) of ", Metric)) %>% mutate(MetricBase = sub("^(#|%) of ", 
        "", Metric), MetricPrefix = substr(Metric, 1, 1)) %>% distinct(MetricBase, MetricPrefix)
    paired_bases <- count_percentage_metrics %>% group_by(MetricBase) %>% summarise(HasCount = "#" %in% MetricPrefix, 
        HasPercentage = "%" %in% MetricPrefix, .groups = "drop") %>% filter(HasCount, HasPercentage) %>% pull(MetricBase)
    return(paired_bases)
}

format_metric_citations <- function(df_com, group_by_metric_category = FALSE, paired_bases = NULL) {
    metric_summary <- df_com %>% transmute(ID = as.character(ID), Metric = Label) %>% merge_count_percentage_metrics(paired_bases = paired_bases) %>% 
        distinct(ID, Metric) %>% group_by(Metric) %>% summarise(PaperNum = n_distinct(ID), Citations = getCitations(ID, 
        onlyID = TRUE), .groups = "drop") %>% arrange(desc(PaperNum), Metric)
    if (!group_by_metric_category) {
        return(paste0(clean_text_4latex(metric_summary$Metric), "~", metric_summary$Citations))
    }
    metric_summary <- metric_summary %>% mutate(MetricCategory = sapply(Metric, identify_metric_category), MetricCategoryOrder = match(MetricCategory, 
        names(metric_category_mapping))) %>% arrange(MetricCategoryOrder, desc(PaperNum), Metric)
    category_results <- c()
    category_index <- 0
    for (metric_category in names(metric_category_mapping)) {
        category_metrics <- subset(metric_summary, metric_summary$MetricCategory == metric_category)
        if (nrow(category_metrics) == 0) {
            next
        }
        category_index <- category_index + 1
        metric_entries <- paste0(clean_text_4latex(category_metrics$Metric), "~", category_metrics$Citations)
        category_results <- append(category_results, paste0("\\textcircled{", category_index, "} \\textbf{", clean_text_4latex(metric_category), 
            "}: ", paste(metric_entries, collapse = ", ")))
    }
    return(category_results)
}

metrics <- function(rqNum) {
    df <- ALL_SELECTED %>% select(ID, Metric = RQ13.Metric.for.evaluating.model.output, Normalized = RQ13.Normalized.metric.for.evaluating.model.output)
    final_result <- pmap_dfr(list(df$ID, df$Metric, df$Normalized), clean_and_flatten)
    final_result_with_counts <- final_result %>% filter(containValidValue(Normalized)) %>% group_by(Normalized) %>% 
        mutate(Normalized_Frequency = n_distinct(ID)) %>% ungroup() %>% group_by(Metric) %>% mutate(Metric_Frequency = n_distinct(ID)) %>% 
        ungroup() %>% arrange(desc(Normalized_Frequency), Normalized, desc(Metric_Frequency), Metric)
    final_result_final <- final_result_with_counts %>% select(ID, Normalized, Normalized_Frequency, Metric, Metric_Frequency)
    TABLE = paste(GENERATED_FILES, "/RQ", rqNum, "_metrics.tex", sep = "")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    cat("\\begin{tabular} { p{0.18\\textwidth} p{0.22\\textwidth} p{0.8\\textwidth} } \\\\ \n")
    cat("\\toprule \n")
    cat("Category & Metrics & Papers\\\\ \n")
    cat("\\midrule  \n")
    categories <- unique(final_result_final$Normalized)
    for (category in categories) {
        metrics <- subset(final_result_final, final_result_final$Normalized == category)
        cat(category, " (", length(unique(metrics$ID)), ")", sep = "")
        gtr1_metric <- subset(metrics, ave(ID, Metric, FUN = function(x) length(unique(x))) > 1)
        for (metric in unique(gtr1_metric$Metric)) {
            metric_df <- subset(final_result_final, final_result_final$Normalized == category & final_result_final$Metric == 
                metric)
            cat(" & ", clean_text_4latex(metric), " (", length(unique(metric_df$ID)), ")", " & ", getCitations(metric_df$ID, 
                onlyID = TRUE), "\\\\ \n", sep = "")
        }
        ew1_metric <- subset(metrics, ave(ID, Metric, FUN = function(x) length(unique(x))) == 1)
        if (nrow(ew1_metric) > 1) {
            cat(" & Others (", length(unique(ew1_metric$ID)), ") &", sep = "")
            metrics_data <- clean_text_4latex(unlist(ew1_metric$Metric))
            citations_data <- unlist(lapply(ew1_metric$ID, function(id) {
                paste0("~", getCitations(id, onlyID = TRUE), sep = "")
            }))
            combine_results <- paste0(metrics_data, citations_data)
            cat(paste(combine_results, collapse = ", "))
            cat("\\\\ \n")
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    sink()
}

merge_count_percentage_metrics <- function(metric_pairs, paired_bases = NULL) {
    if (is.null(paired_bases)) {
        paired_bases <- find_count_percentage_metric_bases(metric_pairs$Metric)
    }
    metric_pairs %>% mutate(MetricBase = ifelse(grepl("^(#|%) of ", Metric), sub("^(#|%) of ", "", Metric), NA_character_), 
        Metric = ifelse(!is.na(MetricBase) & MetricBase %in% paired_bases, paste0("#/% of ", MetricBase), Metric)) %>% 
        select(-MetricBase)
}

format_metric_with_color <- function(metric_name, paper_num) {
    metric_category <- identify_metric_category(metric_name)
    bg_color <- metric_category_colors[[metric_category]]
    if (is.null(bg_color)) {
        bg_color <- metric_category_colors[["Others"]]
    }
    paste0("{\\setlength{\\fboxsep}{1pt}\\colorbox{", bg_color, "}{\\strut\\scriptsize ", clean_text_4latex(metric_name), 
        " (", paper_num, ")}}")
}

baselines_table <- function(data, rqNum) {
    baseline_totals <- data %>% distinct(ID, Baseline) %>% count(Baseline, name = "PaperNum") %>% arrange(desc(PaperNum), 
        Baseline)
    baseline_summary <- data %>% distinct(ID, Baseline, MDETask) %>% group_by(Baseline, MDETask) %>% summarise(PaperNum = n_distinct(ID), 
        Papers = getCitations(ID, onlyID = TRUE), .groups = "drop")
    TABLE <- paste0(GENERATED_FILES, "/RQ", rqNum, "_baselines.tex")
    unlink(TABLE)
    sink(TABLE, append = TRUE, split = TRUE)
    on.exit(sink(), add = TRUE)
    cat("\\begin{tabular} {p{0.24\\textwidth}  p{0.26\\textwidth} p{0.02\\textwidth} p{0.48\\textwidth}} \\\\ \n")
    cat("\\toprule \n")
    cat("Baseline & MDE Task & \\# & Papers\\\\ \n")
    for (baseline in baseline_totals$Baseline) {
        baseline_total <- baseline_totals$PaperNum[baseline_totals$Baseline == baseline]
        mde_tasks <- baseline_summary %>% filter(Baseline == baseline) %>% arrange(desc(PaperNum), MDETask)
        cat("\\midrule  \n")
        cat(strToTitle_skip(baseline, c("LLM", "ML")), " (", baseline_total, ")", sep = "")
        for (i in seq_len(nrow(mde_tasks))) {
            cat(" & ", emphExp(formatTitleName(mde_tasks$MDETask[i])), " & ", mde_tasks$PaperNum[i], " & ", mde_tasks$Papers[i], 
                "\\\\ \n", sep = "")
        }
    }
    cat("\\bottomrule \n")
    cat("\\end{tabular} \n")
    return(baseline_summary)
}

modify_venue_abbreviation <- function(venue_string) {
    venue_map <- c(`International Conference on Model Driven Engineering Languages and Systems: Companion Proceedings` = "International Conference on Model Driven Engineering Languages and Systems (MODELS): Companion Proceedings", 
        `International Conference on Conceptual Modeling` = "International Conference on Conceptual Modeling (ER)", 
        `International Conference on Model Driven Engineering Languages and Systems` = "International Conference on Model Driven Engineering Languages and Systems (MODELS)", 
        `International Requirements Engineering Conference Workshops` = "International Requirements Engineering Conference (RE) Workshops", 
        `Software and Systems Modeling` = "Software and Systems Modeling (SoSyM)", `International Conference on Cooperative Information Systems` = "International Conference on Cooperative Information Systems (CoopIS)", 
        `Business Process Management Workshops` = "Business Process Management (BPM) Workshops", `International Conference on Model-Based Software and Systems Engineering` = "International Conference on Model-Based Software and Systems Engineering (MODELSWARD)", 
        `Process Mining Workshops` = "International Conference on Process Mining (ICPM) Workshops", `Euromicro Conference on Software Engineering and Advanced Applications` = "Euromicro Conference on Software Engineering and Advanced Applications (SEAA)", 
        `International Conference on Software Architecture Companion` = "International Conference on Software Architecture Companion (SAC)", 
        `Advances in Conceptual Modeling` = "Advances in Conceptual Modeling (ER Workshops)")
    if (venue_string %in% names(venue_map)) {
        return(venue_map[[venue_string]])
    }
    else {
        return(venue_string)
    }
}

identify_metric_category <- function(metric_name) {
    if (grepl("^#/% of ", metric_name)) {
        return("Model related \\#/\\% metrics")
    }
    for (metric_category in names(metric_category_mapping)) {
        if (tolower(metric_name) %in% tolower(metric_category_mapping[[metric_category]])) {
            return(metric_category)
        }
    }
    return("Others")
}

# ==================== Invoke analysis functions ====================
dir.create(GENERATED_FILES,recursive=TRUE,showWarnings=FALSE)
group1Analysis()
group2Analysis()
group3Analysis()
group4Analysis()
