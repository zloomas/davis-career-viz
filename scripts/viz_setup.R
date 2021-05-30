
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
         big_boy = paper_id == "A1983PY32000010")

paper_edges <- read_tsv(here("data","papers","paper_network_edges.tsv")) %>%
  mutate(citation_type = case_when(
    to %in% mark_papers$paper_id & 
      !(from %in% mark_papers$paper_id) ~ "cited_by_mark",
    from %in% mark_papers$paper_id & 
      !(to %in% mark_papers$paper_id) ~ "cites_mark",
    to %in% mark_papers$paper_id & 
      from %in% mark_papers$paper_id ~ "self-cite"),
    big_boy = from == "A1983PY32000010" | to == "A1983PY32000010"
  )

paper_network <- graph_from_data_frame(
  d=paper_edges,
  vertices=paper_nodes,
  directed=T
)


## citation network with just "big boy"
reduced_paper_edges <- filter(paper_edges,
                              citation_type != "cited_by_mark")

reduced_paper_list <- unique(c(reduced_paper_edges$from, reduced_paper_edges$to))

reduced_paper_nodes <- filter(paper_nodes,
                              paper_id %in% reduced_paper_list)

reduced_paper_network <- graph_from_data_frame(
  d=reduced_paper_edges, 
  vertices=reduced_paper_nodes, 
  directed=T
)

