## This relies on guidance from a superb tutorial by Katya Ognyanova
## https://kateto.net/network-visualization

library(igraph)
library(ggraph)
library(ggplot2)
library(readr)
library(dplyr)
library(here)

## author network
author_nodes <- read_tsv(here("data","coauthors","author_network_nodes.tsv")) %>%
  mutate(ml_id = case_when(au_id == "au29" ~ "linda",
                           au_id == "au14" ~ "mark",
                           TRUE ~ "not_ml"))

author_edges <- read_tsv(here("data","coauthors","author_network_edges.tsv")) %>%
  mutate(is_ml = case_when(from == "au29" & to == "au14" ~ "lb4m",
                           to == "au29" & from == "au14" ~ "mb4l",
                           TRUE ~ "not_ml"))

author_network <- graph_from_data_frame(d=author_edges, vertices=author_nodes, directed=T)

## basic
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(color = "grey40", width=.3, show.legend = FALSE) +
  geom_node_point(color = "grey30", size = 1, show.legend = FALSE) +
  theme_void()

#ggsave(here("viz","coauthors_test.jpg"), width = 5, height = 5)

## green tests
## nodes w/ darker grey
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(color = "grey40", width=.3, show.legend = FALSE) +
  geom_node_point(color = "#A5D468", size = 2, show.legend = FALSE) +
  theme_void()

#ggsave(here("viz","coauthors_green_nodes_grey40.jpg"), width = 5, height = 5)

## nodes w/ lighter grey
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(color = "grey80", width=.3, show.legend = FALSE) +
  geom_node_point(color = "#A5D468", size = 1, show.legend = FALSE) +
  theme_void()

#ggsave(here("viz","coauthors_green_nodes_grey80.jpg"), width = 5, height = 5)

## green everything
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(color = "#A5D468", width=.3, show.legend = FALSE) +
  geom_node_point(color = "#A2BB81", size = 1, show.legend = FALSE) +
  theme_void()

#ggsave(here("viz","coauthors_green_theme.jpg"), width = 5, height = 5)


## diff colored m+l
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(aes(colour = is_ml, alpha = is_ml), width=.3, show.legend = FALSE) +
  scale_edge_colour_manual(values = c("#9E2B5F", "#2B5F9E", "grey40")) +
  scale_edge_alpha_manual(values = c(1, 1, .3)) +
  geom_node_point(aes(color = ml_id), size = 1, show.legend = FALSE) +
  scale_color_manual(values = c("#9E2B5F", "#2B5F9E", "grey40")) +
  theme_void()

#ggsave(here("viz","coauthors_ml_diff.jpg"), width = 5, height = 5)

## same colored m+l
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(aes(colour = is_ml, alpha = is_ml), width=.3, show.legend = FALSE) +
  scale_edge_colour_manual(values = c("#9E2B5F", "#9E2B5F", "grey40")) +
  scale_edge_alpha_manual(values = c(1, 1, .3)) +
  geom_node_point(aes(color = ml_id), size = 1, show.legend = FALSE) +
  scale_color_manual(values = c("#9E2B5F", "#9E2B5F", "grey40")) +
  theme_void()

#ggsave(here("viz","coauthors_ml_same.jpg"), width = 5, height = 5)

## citation network
mark_papers <- read_tsv(here("data","papers","seed_paper_network_nodes.tsv"))
mark_papers_list <- mark_papers$paper_id

paper_nodes <- read_tsv(here("data","papers","paper_network_nodes.tsv")) %>%
  mutate(is_mark = ifelse(paper_id %in% mark_papers_list, TRUE, FALSE))

paper_edges <- read_tsv(here("data","papers","paper_network_edges.tsv")) %>%
  mutate(citation_type = case_when(to %in% mark_papers_list & !(from %in% mark_papers_list) ~ "cited_by_mark",
                                   from %in% mark_papers_list & !(to %in% mark_papers_list) ~ "cites_mark",
                                   to %in% mark_papers_list & from %in% mark_papers_list ~ "self-cite"))

paper_network <- graph_from_data_frame(d=paper_edges, vertices=paper_nodes, directed=T)

#basic
ggraph(paper_network, layout = "kk") +
  geom_edge_arc(width=.1, color = "grey50", alpha = .2) +
  geom_node_point(size = .1, color = "#3A7BCC") +
  theme_void() +
  coord_flip() +
  scale_x_reverse()

#ggsave(here("viz","citations_test.jpg"), width = 10, height = 10)

#first pass at color
#nodes by whether Mark is an author or not
#edges by whether he cites it, is self-citing, or it cites him
ggraph(paper_network, layout = "kk") +
  geom_edge_arc(width=.1, alpha = .2, aes(color = citation_type), show.legend = FALSE) +
  scale_edge_color_manual(values = c("#2B929E", "#9E2B5F", "#9E832B")) +
  geom_node_point(aes(color = is_mark, size = is_mark), show.legend = FALSE) +
  scale_color_manual(values = c("grey30", "black")) +
  scale_size_manual(values = c(.1, .5)) +
  theme_void() +
  coord_flip() +
  scale_x_reverse()

# ggsave(here("viz","citations_pink.jpg"), width = 10, height = 10)

## green test
ggraph(paper_network, layout = "kk") +
  geom_edge_arc(width=.1, color = "#8A9396", alpha = .2) +
  geom_node_point(size = .1, color = "#A2BB81") +
  theme_void() +
  coord_flip() +
  scale_x_reverse()

#ggsave(here("viz","citations_green.jpg"), width = 10, height = 10)

