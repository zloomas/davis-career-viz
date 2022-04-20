
library(igraph)
library(ggraph)
library(ggplot2)
library(readr)
library(dplyr)
library(here)

## author network
author_nodes <- read_tsv(here("data","coauthors","author_network_nodes.tsv")) %>%
  mutate(ml_id = case_when(
    au_id == "au29" ~ "linda",
    au_id == "au14" ~ "mark",
    TRUE ~ "not_ml")
  )

author_edges <- read_tsv(here("data","coauthors","author_network_edges.tsv")) %>%
  mutate(is_ml = case_when(
    from == "au29" & to == "au14" ~ "lb4m",
    to == "au29" & from == "au14" ~ "mb4l",
    TRUE ~ "not_ml")
  )

author_network <- graph_from_data_frame(
  d=author_edges, 
  vertices=author_nodes, 
  directed=T
)


## citation network
mark_papers <- read_tsv(here("data","papers","seed_paper_network_nodes.tsv"))

paper_nodes <- read_tsv(here("data","papers","paper_network_nodes.tsv")) %>%
  mutate(pub_decade = floor(pub_year/10),
         big_boy = paper_id == "A1983PY32000010",
         is_mark = paper_id %in% mark_papers$paper_id) %>%
  filter(!is.na(pub_decade))

paper_edges <- read_tsv(here("data","papers","paper_network_edges.tsv")) %>%
  mutate(
    citation_type = case_when(
      to %in% mark_papers$paper_id & 
        !(from %in% mark_papers$paper_id) ~ "cited_by_mark",
      from %in% mark_papers$paper_id & 
        !(to %in% mark_papers$paper_id) ~ "cites_mark",
      to %in% mark_papers$paper_id & 
        from %in% mark_papers$paper_id ~ "self-cite"
    ),
    big_boy = from == "A1983PY32000010" | to == "A1983PY32000010"
  ) %>%
  filter(to %in% paper_nodes$paper_id & from %in% paper_nodes$paper_id)

paper_edges_summary <- paper_edges %>%
  group_by(from) %>%
  summarise(n = n()) %>%
  mutate(log_n_plus = log10(n+1))

paper_nodes <- merge(
  paper_nodes, 
  paper_edges_summary,
  by.x = "paper_id",
  by.y = "from",
  all.x = TRUE
) %>% mutate(
  size_ref = case_when(is.na(log_n_plus) ~ log10(2),
                       TRUE ~ log_n_plus)
) %>% mutate(
  size_ref = ceiling(size_ref)
) %>% mutate(
  size_ref = case_when(size_ref == 1 ~ 3,
                       size_ref == 2 ~ 6,
                       size_ref == 3 ~ 12,
                       size_ref == 4 ~ 15,
                       TRUE ~ 0)
)

paper_network <- graph_from_data_frame(
  d=paper_edges,
  vertices=paper_nodes,
  directed=T
)


## citation network with just "big boy"
reduced_paper_edges <- filter(paper_edges,
                              citation_type == "cites_mark")

reduced_paper_list <- unique(c(reduced_paper_edges$from, reduced_paper_edges$to))

reduced_paper_nodes <- paper_nodes %>%
  filter(paper_id %in% reduced_paper_list) %>%
  mutate(
    pub_decade_adjusted = as.character(
      ifelse(
        is_mark,
        pub_decade*2,
        pub_decade 
      ) 
    )
  )

reduced_paper_network <- graph_from_data_frame(
  d=reduced_paper_edges, 
  vertices=reduced_paper_nodes, 
  directed=T
)

