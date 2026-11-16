# Utility functions for LLM4MDE_SLR.R
findPapers <- function(title) {
    found <- c()
    for (bib in ALL_BIB) {
        btitle <- bib$title
        if (!is.null(btitle)) {
            if (identical(tolower(formatString(title)), tolower(formatString(btitle)))) {
                found <- append(found, attr(bib, "key")[[1]])
            }
        }
    }
    return(found)
}

existsInArray <- function(item, array) {
    if (is.null(array)) 
        return(FALSE)
    if (is.null(item)) 
        return(FALSE)
    return(item %in% array)
}

cmd <- function(prefix, command, content) {
    return(paste("\\newcommand{\\", prefix, command, "}{", content, "\\xspace}", sep = ""))
}

clean_text_4latex <- function(text) {
    mask <- is.na(text) | text == ""
    clean_text <- str_replace_all(text, "(?<!\\\\)([#$%&_{}])", "\\\\\\1")
    clean_text <- clean_text %>% str_replace_all("\342\210\206|\316\224", "$\\\\Delta$") %>% str_replace_all("\316\264", 
        "$\\\\delta$") %>% str_replace_all("\302\261", "$\\\\pm$") %>% str_replace_all("\342\211\245", "$\\\\ge$") %>% 
        str_replace_all("\342\211\244", "$\\\\le$") %>% str_replace_all("\303\227", "$\\\\times$") %>% str_replace_all("%", 
        "\\%")
    clean_text[mask] <- text[mask]
    return(clean_text)
}

extract_urls <- function(text) {
    pattern <- "https?://(?:www\\.)?[\\w-]+(\\.[\\w-]+)+([\\w-.,@?^=%&:/~+#]*[\\w@?^=%&/~+#])?"
    str_extract_all(text, pattern)[[1]]
}

otherInSummary <- function(list_data, threshold = NULL) {
    data <- list_data
    summary_data <- as.data.frame(table(data))
    if (!is.null(threshold)) {
        others <- (subset(summary_data, summary_data$Freq < threshold))$data
        data <- ifelse(data %in% others, "Others", data)
    }
    return(as.data.frame(table(data)))
}

containValidValue <- function(content, extraExclude = NULL) {
    exclude <- INVALID_VALUE
    if (!is.null(extraExclude)) 
        exclude <- c(exclude, extraExclude)
    content_clean <- str_trim(as.character(content))
    is_valid <- !is.na(content_clean) & content_clean != "" & !(tolower(content_clean) %in% exclude)
    return(is_valid)
}

is_blank_str <- function(text) {
    if (is.null(text) || length(text) == 0) {
        return(TRUE)
    }
    res <- is.na(text) | (stringr::str_trim(text) == "")
    return(res)
}

get_host_alias <- function(url, default = "Link") {
    if (is.na(url) || url == "") 
        return("Link")
    url_lower <- tolower(url)
    if (grepl("github.com", url_lower)) 
        return("GitHub")
    if (grepl("zenodo.org", url_lower)) 
        return("Zenodo")
    if (grepl("huggingface.co", url_lower)) 
        return("huggingface")
    if (grepl("figshare.com", url_lower)) 
        return("Figshare")
    if (grepl("gitlab", url_lower)) 
        return("GitLab")
    if (grepl("drive.google.com", url_lower)) 
        return("Google-Drive")
    if (grepl("docs.google.com", url_lower)) 
        return("Google-Doc")
    if (grepl("google.com/forms", url_lower)) 
        return("Google-Form")
    if (grepl("anonymous.4open.science", url_lower)) 
        return("4open.science")
    if (grepl("europa.eu", url_lower)) 
        return("europa.eu")
    host_match <- regexec("//([^/]+)", url)
    host_parts <- regmatches(url, host_match)[[1]]
    if (length(host_parts) >= 2) {
        host <- host_parts[2]
        host <- gsub(":[0-9]+$", "", host)
        host <- gsub("^www\\.", "", host)
        return(host)
    }
    if (is.null(default)) 
        return("Link")
    return(default)
}

extract_urls_valid <- function(text, extraExclude = NULL, invalidLabel = "-", latexUrl = TRUE, aliasName = NULL) {
    exclude <- INVALID_VALUE
    if (!is.null(extraExclude)) 
        exclude <- c(exclude, extraExclude)
    if (text %in% exclude) 
        return(invalidLabel)
    else {
        if (latexUrl) {
            url_text <- extract_urls(text)
            if (all(is_blank_str(url_text))) {
                if (containValidValue(text)) 
                  return(text)
                else return("")
            }
            if (is.null(aliasName)) 
                return(paste0("\\url{", url_text, "}", sep = ""))
            else {
                valid_urls <- url_text[!is_blank_str(url_text)]
                raw_aliases <- sapply(valid_urls, get_host_alias, default = aliasName)
                final_labels <- ave(raw_aliases, raw_aliases, FUN = function(x) {
                  if (length(x) > 1) 
                    paste(x, seq_along(x), sep = "~")
                  else x
                })
                href_vector <- sprintf("\\href{%s}{\\underline{%s}}", valid_urls, final_labels)
                return(paste0("", paste(href_vector, collapse = ", "), ""))
            }
        }
        return(extract_urls(text))
    }
}

formatString <- function(title) {
    t <- gsub("[^A-Za-z]", "", title, ignore.case = TRUE)
    return(t)
}

extractGroupNameAndContentAsDataframe <- function(text, groupNameIfNull = NULL) {
    group_name_pattern <- "^(.*?):\\s*(.*)$"
    if (grepl(group_name_pattern, text)) {
        result <- str_match(text, "^(.*?):\\s*(.*)$")
        return(list(groupName = trimws(result[1, 2]), groupContent = trimws(result[1, 3])))
    }
    return(list(groupName = groupNameIfNull, groupContent = trimws(text)))
}

extractContentInSquareBrackets <- function(text) {
    matches <- regmatches(text, gregexpr("\\[([^]]+)\\]", text, perl = TRUE))[[1]]
    contents <- gsub("\\[|\\]", "", matches)
    if (length(contents) == 0) 
        return(text)
    return(contents)
}

extractGroupNameAndContent <- function(text) {
    return(splitBy(text, ":"))
}

extractItem <- function(text, sep = NULL, separator = ";") {
    if (is.null(sep)) 
        return(trimws(splitBy(text, separator)))
    for (s in sep) {
        if (grepl(s, text)) 
            return(trimws(splitBy(text, separator)))
    }
    return(text)
}

extractItemsInGroup <- function(text) {
    sp <- extractGroupNameAndContent(text)
    return(extractItem(sp[length(sp)]))
}

splitBy <- function(text, sep) {
    gs <- unlist(strsplit(text, sep))
    return(trimws(gs))
}

extractAll <- function(col_data) {
    return(unlist(lapply(col_data, function(s) {
        items <- extractItem(s)
        unlist(lapply(items, extractContentInSquareBrackets))
    })))
}

extractAllWithGroup <- function(col_data) {
    return(unlist(lapply(col_data, function(s) {
        items <- extractContentInSquareBrackets(s)
        unlist(lapply(items, extractItemsInGroup))
    })))
}

RQ_label_prefix <- function(num) {
    return(paste("RQ", formatString(nom_ord(strtoi(num))), sep = ""))
}

getCitationCmdByIndex <- function(index) {
    i <- index
    if (!is.numeric(i)) 
        i <- as.numeric(i)
    citation <- paste("\\paper", formatString(nom_ord(i)), sep = "")
    return(citation)
}

getCitations <- function(data, removeDuplicated = TRUE, onlyID = FALSE, ID_cols_name = "ID") {
    citations <- NULL
    rd <- data
    if (!onlyID) {
        rd <- data[[ID_cols_name]]
    }
    if (removeDuplicated) 
        rd <- unique(rd)
    for (p in rd) {
        comma <- ""
        if (!is.null(citations)) 
            comma <- ","
        citations <- paste(citations, comma, getCitationCmdByIndex(p), sep = "")
    }
    return(paste("\\cite{", citations, "}"))
}

removeItems <- function(org_vec, removed_vec) {
    return(org_vec[!org_vec %in% removed_vec])
}

pieChart <- function(fileName, list, w = 8, h = 5, summarizedData = FALSE) {
    data <- list
    if (!summarizedData) 
        data <- as.data.frame(table(list))
    if (ncol(data) == 2) {
        colnames(data) <- c("category", "value")
        data <- data %>% mutate(percent = value/sum(value) * 100, label = sprintf("%s  \n %d (%.2f%%)", category, 
            value, percent), csum = rev(cumsum(rev(value))), pos = value/2 + lead(csum, 1), pos = if_else(is.na(pos), 
            value/2, pos))
    }
    else if (ncol(data) == 3) {
        colnames(data) <- c("category", "value", "info")
        data <- data %>% mutate(percent = value/sum(value) * 100, label = sprintf("%s  \n %d (%.2f%%) %s", category, 
            value, percent, info), csum = rev(cumsum(rev(value))), pos = value/2 + lead(csum, 1), pos = if_else(is.na(pos), 
            value/2, pos))
    }
    pa <- c("stripe", "none", "circle", "crosshatch")
    if (nrow(data) == 2) {
        pa <- pa[2:3]
    }
    else {
        pa <- pa[1:nrow(data)]
    }
    n_cat <- nrow(data)
    if (n_cat < 13) {
        fill_colors <- brewer.pal(max(3, n_cat), "Set3")[seq_len(n_cat)]
    }
    else {
        fill_colors <- viridis(n = n_cat, option = "mako")
    }
    ggplot(data, aes(x = "", y = value, fill = category)) + geom_col(color = "black", width = 1) + coord_polar("y", 
        start = 0, clip = "off") + scale_fill_manual(values = alpha(fill_colors, 0.6)) + geom_label_repel(data = data, 
        aes(y = pos, label = label), size = 4.5, nudge_x = 1, show.legend = FALSE, fill = alpha(fill_colors, 0.6)) + 
        theme_void() + theme(legend.position = "none", plot.margin = margin(0, 0, -4, 0, unit = "lines"), panel.border = element_blank(), 
        aspect.ratio = 1)
    ggsave(paste(GENERATED_FILES, "/", fileName, ".pdf", sep = ""), width = w, height = h, dpi = 300, device = "pdf", 
        limitsize = FALSE)
}

orderBarChart <- function(data, xLabel = "x", yLabel = "y", fileName = "default_ordered_bar", convert2Table = TRUE, 
    width = 8, height = 6, coord_fixed_ratio = 1, hjust = -0.5) {
    df <- data
    if (convert2Table) {
        df <- as.data.frame(table(data))
    }
    else if (ncol(data) != 2) {
        stop("data must have two colnames")
    }
    colnames(df) <- c("items", "freq")
    ggplot(df, aes(x = freq, y = reorder(items, freq))) + geom_col(fill = "grey70", colour = "black", width = 0.5, 
        linewidth = 0.3) + geom_text(aes(label = freq), hjust = hjust, size = 3.5, color = "black", fontface = "bold") + 
        labs(x = xLabel, y = yLabel) + theme_classic() + theme(plot.title = element_text(size = 14, hjust = 0.5, 
        face = "bold"), axis.text.x = element_text(size = 12), axis.text.y = element_text(size = 12, margin = margin(r = 5)), 
        axis.title = element_text(size = 13), panel.grid = element_blank(), axis.line = element_line(colour = "black"), 
        plot.margin = unit(c(5, 10, 5, 5), "mm")) + scale_x_continuous(expand = expansion(mult = c(0, 0.1))) + 
        coord_fixed(ratio = coord_fixed_ratio)
    ggsave(paste(GENERATED_FILES, "/", fileName, ".pdf", sep = ""), height = height, width = width, dpi = 300)
}

barChart <- function(data, xLabel = "x", yLabel = "y", fileName = "default_bar", width = 8, height = 6, reorderBasedOnFreq = TRUE, 
    globalTotal = NULL, axisXAngle = 90, axisHjust = 1, axisVjust = 0.5, barwidth = 0.5) {
    item_totals <- data %>% group_by(Items) %>% summarise(Total = sum(Freq))
    if (reorderBasedOnFreq) {
        data <- data %>% left_join(item_totals, by = "Items") %>% mutate(Items = reorder(Items, -Total))
    }
    if (!is.null(globalTotal)) {
        item_totals <- item_totals %>% mutate(Percentage = paste0(formatC(Total/TOTAL_NUM_SELECTED_PAPERS * 100, 
            digits = 2, format = "f"), "%", sep = "")) %>% mutate(Top = paste0(Total, ", ", Percentage, sep = ""))
    }
    else {
        item_totals <- item_totals %>% mutate(Top = Total)
    }
    ggplot(data, aes(y = Freq, x = Items)) + geom_col(fill = "grey70", colour = "black", width = barwidth, linewidth = 0.3) + 
        geom_text(data = item_totals, aes(x = Items, y = Total, label = Top, fill = NULL), vjust = -0.5, size = 4, 
            fontface = "bold", color = "black") + scale_fill_brewer(palette = "Set3") + labs(x = xLabel, y = yLabel) + 
        theme_classic() + theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), axis.text.x = element_text(color = "black", 
        size = 12, angle = axisXAngle, hjust = axisHjust, vjust = axisVjust), axis.text.y = element_text(color = "black", 
        size = 12, margin = margin(r = 5)), axis.title = element_text(size = 13), panel.grid = element_blank(), 
        axis.line = element_line(colour = "black"), plot.margin = unit(c(5, 10, 5, 5), "mm"), legend.position = "top") + 
        scale_x_discrete(expand = expansion(mult = c(0.1, 0.1))) + scale_y_continuous(expand = expansion(mult = c(0, 
        0.1)))
    ggsave(paste(GENERATED_FILES, "/", fileName, ".pdf", sep = ""), height = height, width = width, dpi = 300)
}

bubble_plot <- function(df, rqNum, xLabel, yLabel, fileName, width = 4, height = 5, vjust = 0.5, hjust = -2.4) {
    p <- ggplot(df, aes(x = Items, y = Category, size = Freq, colour = color_group)) + geom_point(alpha = 0.7, 
        color = "darkgreen") + geom_text(aes(label = Freq), color = "black", size = 3, vjust = vjust, hjust = hjust) + 
        scale_size(range = c(3, 10)) + labs(x = xLabel, y = yLabel) + theme(axis.text.x = element_text(angle = 45, 
        hjust = 1, color = "black"), axis.text.y = element_text(color = "black"), panel.grid.major = element_line(color = "grey90", 
        linetype = "dashed"), panel.background = element_blank(), axis.line = element_line(color = "black"))
    ggsave(filename = paste(GENERATED_FILES, "/", fileName, "_bubble.pdf", sep = ""), plot = p, width = width, 
        height = height, dpi = 300, device = "pdf")
    return(p)
}

stackedBarChart <- function(data, xLabel = "x", yLabel = "y", legendTitle = "Category", fileName = "default_stacked_bar", 
    width = 8, height = 6, reorderBasedOnFreq = TRUE, globalTotal = NULL, axisXAngle = 0, axisHjust = 0.5, axisVjust = 1, 
    barwidth = 0.3, textGap = 0.12, showTable = TRUE, annotation_labels = NULL, x_mult = c(0.1, 0.15), col_set = "Set3") {
    data <- data %>% group_by(Items, Category) %>% summarise(Freq = sum(Freq, na.rm = TRUE), .groups = "drop")
    if (grepl("task", legendTitle, ignore.case = TRUE)) {
        category_levels <- sort(unique(as.character(data$Category)), method = "radix", na.last = NA)
        data$Category <- factor(data$Category, levels = category_levels)
    }
    if (!is.factor(data$Category)) {
        data$Category <- as.factor(data$Category)
    }
    item_totals <- data %>% group_by(Items) %>% summarise(Total = sum(Freq, na.rm = TRUE), .groups = "drop")
    if (reorderBasedOnFreq) {
        data <- data %>% left_join(item_totals, by = "Items") %>% mutate(Items = reorder(Items, -Total))
    }
    else {
        data <- data %>% mutate(Items = factor(Items))
    }
    item_levels <- levels(data$Items)
    item_totals <- item_totals %>% mutate(Items = factor(Items, levels = item_levels))
    data <- data %>% arrange(Items, desc(Category)) %>% group_by(Items) %>% mutate(n_cat = n_distinct(Category[Freq > 
        0]), y_top = cumsum(Freq), y_mid = y_top - (Freq/2)) %>% ungroup()
    if (!is.null(globalTotal)) {
        item_totals <- item_totals %>% mutate(Percentage = paste0(formatC(Total/globalTotal * 100, digits = 2, 
            format = "f"), "%")) %>% mutate(Top = paste0(Total, ", ", Percentage))
    }
    else {
        item_totals <- item_totals %>% mutate(Top = Total)
    }
    n_cats <- length(unique(data$Category))
    fill_palette <- colorRampPalette(brewer.pal(min(n_cats, 12), col_set))(n_cats)
    names(fill_palette) <- levels(droplevels(data$Category))
    p <- ggplot(data, aes(x = as.numeric(Items), y = Freq)) + geom_col(aes(fill = Category), colour = "black", 
        width = barwidth, linewidth = 0.3) + geom_segment(data = data %>% filter(Freq > 0, n_cat > 1), aes(x = as.numeric(Items) + 
        (barwidth/2), xend = as.numeric(Items) + (barwidth/2) + (textGap * 0.7), y = y_mid, yend = y_mid), color = "grey30", 
        linewidth = 0.3) + geom_text(data = data %>% filter(Freq > 0, n_cat > 1), aes(x = as.numeric(Items) + (barwidth/2) + 
        textGap, y = y_mid, label = Freq), hjust = 0, size = 3.5, color = "black") + geom_text(data = item_totals, 
        aes(x = as.numeric(Items), y = Total, label = Top), vjust = -0.5, size = 4, fontface = "bold", color = "black") + 
        scale_fill_manual(values = fill_palette, name = legendTitle) + labs(x = xLabel, y = yLabel) + coord_cartesian(clip = "off") + 
        theme_classic() + theme(plot.title = element_text(size = 14, hjust = 0.5, face = "bold"), axis.text.x = element_text(color = "black", 
        size = 12, angle = axisXAngle, hjust = axisHjust, vjust = axisVjust), axis.text.y = element_text(color = "black", 
        size = 12, margin = margin(r = 5)), axis.title = element_text(size = 13), panel.grid = element_blank(), 
        axis.line = element_line(colour = "black"), plot.margin = unit(c(5, 10, 0, 5), "mm"), legend.position = "top") + 
        scale_x_continuous(breaks = seq_along(item_levels), labels = item_levels, expand = expansion(mult = x_mult)) + 
        scale_y_continuous(expand = expansion(mult = c(0, 0.15)))
    if (!is.null(annotation_labels)) {
        p <- p + annotate("text", x = max(as.numeric(data$Items)) - 3, y = Inf, label = annotation_labels, hjust = 0, 
            vjust = 1, size = 3.5, lineheight = 1.1)
    }
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

extractMultipleRowsBySeparator <- function(row, index, df_colnames, separator = ";", extractAsGroup = TRUE) {
    split_text <- strsplit(row, separator)
    if (!extractAsGroup) {
        text <- gsub("\\[|\\]", "", row)
        split_text <- strsplit(text, ";")
    }
    count <- length(split_text[[index]])
    clean_text <- lapply(split_text, function(x) {
        x <- gsub("\\[|\\]", "", trimws(x))
        if (length(x) < count) 
            c(x, rep(x[1], count - length(x)))
        else x
    })
    result <- tryCatch({
        as.data.frame(clean_text)
    }, error = function(e) {
        message("error: ", paste0(e$message, clean_text), sep = "\\n")
        stop()
    })
    tryCatch({
        colnames(result) <- df_colnames
    }, error = function(e) {
        message("error: ", paste0(e$message, clean_text), sep = "\\n")
        stop()
    })
    return(result)
}

rename <- function(text) {
    if (identical(text, "Grover's algorithm")) 
        return("Grover")
    return(text)
}

percentage_exp <- function(num, total, digits = 2, showNum = FALSE) {
    per <- paste(formatC((num * 100)/total, digits = digits, format = "f"), "\\%", sep = "")
    if (!showNum) 
        return(per)
    return(paste(num, " (", per, ")", sep = ""))
}

emphExp <- function(text) {
    return(paste("\\emph{", text, "}", sep = ""))
}

multipleSEProblem <- function(problem) {
    isprefix <- TRUE
    prefix <- ""
    if (grepl("software failure prediction", problem, ignore.case = TRUE)) 
        prefix <- blacktriangleright("red", isprefix)
    if (grepl("scheduling problem", problem, ignore.case = TRUE)) 
        prefix <- blacktriangleright("green", isprefix)
    if (grepl("security attack identification", problem, ignore.case = TRUE)) 
        prefix <- blacktriangleright("blue", isprefix)
    if (grepl("security management", problem, ignore.case = TRUE)) 
        prefix <- blacktriangleright("orange", isprefix)
    if (isprefix) 
        return(paste(prefix, " ", problem, sep = ""))
    else return(paste(problem, " ", prefix, sep = ""))
}

blacktriangleright <- function(color_text, prefix = FALSE) {
    if (!prefix) 
        return(paste("\\textcolor{", color_text, "}{$\\blacktriangleleft$}", sep = ""))
    return(paste("\\textcolor{", color_text, "}{$\\blacktriangleright$}", sep = ""))
}

upsetPlot_complex <- function(set_list, fileName, width = 15, height = 5.5) {
    data_df <- as.data.frame(fromList(set_list))
    set_names <- names(set_list)
    plot <- ComplexUpset::upset(data_df, set_names, name = "Intersections", width_ratio = 0.12, set_sizes = (upset_set_size() + 
        geom_text(aes(label = ..count..), stat = "count", hjust = -0.3, size = 5.5, color = "black", fontface = "bold") + 
        scale_y_continuous(expand = expansion(mult = c(0, 0.25))) + theme(axis.text.x = element_blank(), axis.ticks.x = element_blank(), 
        axis.title.x = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank())), 
        base_annotations = list(`Intersection size` = intersection_size(text = list(size = 4.5, fontface = "bold")) + 
            theme(axis.title.y = element_text(size = 18), axis.text.y = element_text(size = 14))), themes = upset_modify_themes(list(overall_heatmap = theme(text = element_text(size = 15)), 
            intersections_matrix = theme(text = element_text(size = 15)))))
    ggsave(filename = paste0(GENERATED_FILES, "/", fileName, "_complex_upset.pdf"), plot = plot, width = width, 
        height = height, device = "pdf")
}

plot_mde_heatmap <- function(df, xLabel, yLabel, fileName, width, height) {
    p <- ggplot(df, aes(x = x, y = y, fill = n)) + geom_tile() + geom_text(aes(label = n), color = "white") + scale_fill_viridis_c() + 
        theme_minimal() + labs(x = xLabel, y = yLabel, fill = "Count") + theme(axis.text.x = element_text(angle = 45, 
        hjust = 1))
    print(p)
    ggsave(paste0(GENERATED_FILES, "/", fileName, ".pdf"), plot = p, width = width, height = height)
    return(p)
}

orderedBarChartWithColorCategory <- function(data, xLabel = "Number of model types", yLabel = "Model Type", fileName = "RQ_modeltype_final", 
    palette = "Set3", width = 12, height = 10, category_totals = NULL, category_total_denominator = NULL) {
    if (!is.null(category_totals)) {
        category_totals <- category_totals %>% mutate(Category = str_to_title(Category))
        total_sum <- if (!is.null(category_total_denominator)) {
            category_total_denominator
        }
        else {
            sum(category_totals$CategoryTotal, na.rm = TRUE)
        }
    }
    else {
        total_sum <- sum(data$Freq, na.rm = TRUE)
    }
    plot_data <- data %>% mutate(Category = str_to_title(Category)) %>% {
        if (!is.null(category_totals)) {
            left_join(., category_totals, by = "Category")
        }
        else {
            group_by(., Category) %>% mutate(CategoryTotal = sum(Freq, na.rm = TRUE)) %>% ungroup()
        }
    } %>% mutate(CategoryPerc = round(CategoryTotal/total_sum * 100, 2)) %>% arrange(desc(CategoryTotal), Category, 
        desc(Freq)) %>% mutate(ModelType = factor(ModelType, levels = rev(unique(ModelType)))) %>% mutate(y_idx = as.numeric(ModelType))
    max_freq <- max(plot_data$Freq, na.rm = TRUE)
    x_base <- ceiling(max_freq/5) * 5
    x_limit <- x_base + 12
    brace_coords <- plot_data %>% group_by(Category) %>% summarise(y_min = min(y_idx), y_max = max(y_idx), y_mid = (y_min + 
        y_max)/2, label_text = paste0(first(Category), "\n", first(CategoryTotal), " (", first(CategoryPerc), "%)"), 
        .groups = "drop")
    brace_x <- x_limit - 6
    label_x <- x_limit - 5
    num_cats <- length(unique(plot_data$Category))
    get_palette <- colorRampPalette(RColorBrewer::brewer.pal(min(num_cats, 12), palette))
    p <- ggplot(plot_data, aes(x = Freq, y = ModelType, fill = Category)) + geom_col(colour = "black", width = 0.7, 
        linewidth = 0.3) + scale_fill_manual(values = get_palette(num_cats)) + geom_text(aes(label = Freq), hjust = -0.4, 
        size = 3, fontface = "bold") + geom_segment(data = brace_coords, aes(x = brace_x, xend = brace_x, y = y_min + 
        0.1, yend = y_max - 0.1), inherit.aes = FALSE, size = 0.5) + geom_curve(data = brace_coords, aes(x = brace_x, 
        xend = brace_x - 0.6, y = y_min + 0.1, yend = y_min - 0.2), curvature = -0.2, inherit.aes = FALSE, size = 0.5) + 
        geom_curve(data = brace_coords, aes(x = brace_x, xend = brace_x - 0.6, y = y_max - 0.1, yend = y_max + 
            0.2), curvature = 0.2, inherit.aes = FALSE, size = 0.5) + geom_segment(data = brace_coords, aes(x = brace_x, 
        xend = brace_x + 0.6, y = y_mid, yend = y_mid), inherit.aes = FALSE, size = 0.5) + geom_text(data = brace_coords, 
        aes(x = label_x, y = y_mid, label = label_text), inherit.aes = FALSE, hjust = 0, size = 3.2, fontface = "bold", 
        lineheight = 0.85) + labs(x = xLabel, y = yLabel, fill = "Category") + theme_classic() + theme(legend.position = "top", 
        legend.title = element_text(face = "bold"), axis.text.y = element_text(color = "black", size = 9), plot.margin = unit(c(5, 
            5, 5, 5), "mm")) + scale_x_continuous(limits = c(0, x_limit), expand = c(0, 0))
    print(p)
    ggsave(paste0(GENERATED_FILES, "/", fileName, ".pdf"), plot = p, width = width, height = height)
    return(p)
}

clean_and_flatten <- function(id, metric_str, norm_str, id_col = "ID", metric_col = "Metric", norm_col = "Normalized") {
    if (is.na(metric_str) | is.na(norm_str)) 
        return(NULL)
    norms <- str_split(str_replace_all(norm_str, "\\[|\\]", ""), ";")[[1]] %>% str_trim()
    metrics_raw <- str_extract_all(metric_str, "\\[[^\\[\\]]+\\]")[[1]]
    if (length(metrics_raw) == 0) {
        metrics_raw <- str_split(metric_str, ";")[[1]] %>% str_trim()
    }
    len <- min(length(metrics_raw), length(norms))
    map2_dfr(metrics_raw[1:len], norms[1:len], function(m, n) {
        m_clean <- m %>% str_replace_all("^\\[+", "") %>% str_replace_all("\\]+$", "") %>% str_replace_all("(?<=\\[|\\b|^)[^:;]+:", 
            "") %>% str_trim()
        m_sub_elements <- str_split(m_clean, ";")[[1]] %>% str_trim()
        res <- tibble(col1 = id, col2 = m_sub_elements, col3 = n)
        setNames(res, c(id_col, metric_col, norm_col))
    })
}

clean_and_flatten_copy <- function(id, metric_str, norm_str, id_col = "ID", metric_col = "Metric", norm_col = "Normalized") {
    if (is.na(metric_str) || is.na(norm_str)) 
        return(NULL)
    clean_norms <- str_replace_all(norm_str, "\\[|\\]", "") %>% str_split(";") %>% purrr::pluck(1) %>% str_trim()
    clean_metrics <- str_replace_all(metric_str, "\\[|\\]", "") %>% str_split(";") %>% purrr::pluck(1) %>% str_trim()
    len_m <- length(clean_metrics)
    len_n <- length(clean_norms)
    if (len_m == 1 && len_n > 1) {
        clean_metrics <- rep(clean_metrics, len_n)
    }
    else if (len_n == 1 && len_m > 1) {
        clean_norms <- rep(clean_norms, len_m)
    }
    else {
        target_len <- min(len_m, len_n)
        clean_metrics <- clean_metrics[1:target_len]
        clean_norms <- clean_norms[1:target_len]
    }
    res <- tibble::tibble(`:=`(!!id_col, id), `:=`(!!metric_col, clean_metrics), `:=`(!!norm_col, clean_norms))
    return(res)
}

expand_and_flatten <- function(id, metric_str, norm_str, id_col = "ID", metric_col = "Metric", norm_col = "Normalized") {
    if (is.na(metric_str) || is.na(norm_str)) 
        return(NULL)
    clean_metrics <- str_replace_all(metric_str, "\\[|\\]", "") %>% str_split(";") %>% purrr::pluck(1) %>% str_trim() %>% 
        .[. != ""]
    clean_norms <- str_replace_all(norm_str, "\\[|\\]", "") %>% str_split(";") %>% purrr::pluck(1) %>% str_trim() %>% 
        .[. != ""]
    res_grid <- tidyr::crossing(`:=`(!!metric_col, clean_metrics), `:=`(!!norm_col, clean_norms))
    res <- res_grid %>% mutate(`:=`(!!id_col, id)) %>% select(all_of(id_col), all_of(metric_col), all_of(norm_col))
    return(res)
}

orderSETasks <- function(se_data) {
    se_task <- se_data$RQ4.SETask
    SETask <- extractAll(se_task)
    freq_df <- as.data.frame(table(SETask))
    freq_df <- freq_df[order(freq_df$Freq, decreasing = TRUE), ]
    return(as.character(freq_df$SETask))
}

formatTaskName <- function(name) {
    all <- unlist(strsplit(name, " "))
    fall <- lapply(all, function(x) {
        if (!all(grepl("^[A-Z0-9!?.,]+$", x))) 
            tolower(x)
        else x
    })
    return(paste(fall, collapse = " "))
}

strToTitle_skip <- function(x, skip = NULL) {
    res <- str_to_title(x)
    if (is.null(skip)) 
        return(res)
    for (s in skip) {
        res <- str_replace_all(res, regex(s, ignore_case = TRUE), s)
    }
    return(res)
}

formatTitleName <- function(name) {
    fname <- strToTitle_skip(name, c("CPS", "IoT", "ADS", "ADASs", "TV", "TVs", "DSM"))
    fname <- gsub("Software Engineering", "SE", fname)
    fname <- gsub("N/A", "-", fname)
    return(fname)
}

filterUnspecified <- function(list_data) {
    new_list_data <- list_data[!tolower(list_data) %in% c("null", "unspecified")]
    return(new_list_data)
}
