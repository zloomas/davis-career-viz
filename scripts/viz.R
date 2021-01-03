## This relies on guidance from a superb tutorial by Katya Ognyanova
## https://kateto.net/network-visualization

library(igraph)
library(ggraph)
library(ggplot2)
library(readr)
library(dplyr)

## author network
author_nodes <- read_tsv(paste0(getwd(),"/data/coauthors/author_network_nodes.tsv")) %>%
  mutate(ml_id = case_when(au_id == "au29" ~ "linda",
                           au_id == "au14" ~ "mark",
                           TRUE ~ "not_ml"))

author_edges <- read_tsv(paste0(getwd(),"/data/coauthors/author_network_edges.tsv")) %>%
  mutate(is_ml = case_when(from == "au29" & to == "au14" ~ "lb4m",
                           to == "au29" & from == "au14" ~ "mb4l",
                           TRUE ~ "not_ml"))

author_network <- graph_from_data_frame(d=author_edges, vertices=author_nodes, directed=T)

## basic
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(color = "grey40", width=.3, show.legend = FALSE) +
  geom_node_point(color = "grey30", size = 1, show.legend = FALSE) +
  theme_void()

#ggsave(paste0(getwd(), "/viz/coauthors_test.jpg"), width = 5, height = 5)

## diff colored m+l
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(aes(colour = is_ml, alpha = is_ml), width=.3, show.legend = FALSE) +
  scale_edge_colour_manual(values = c("#9E2B5F", "#2B5F9E", "grey40")) +
  scale_edge_alpha_manual(values = c(1, 1, .3)) +
  geom_node_point(aes(color = ml_id), size = 1, show.legend = FALSE) +
  scale_color_manual(values = c("#9E2B5F", "#2B5F9E", "grey40")) +
  theme_void()

#ggsave(paste0(getwd(), "/viz/coauthors_ml_diff.jpg"), width = 5, height = 5)

## same colored m+l
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(aes(colour = is_ml, alpha = is_ml), width=.3, show.legend = FALSE) +
  scale_edge_colour_manual(values = c("#9E2B5F", "#9E2B5F", "grey40")) +
  scale_edge_alpha_manual(values = c(1, 1, .3)) +
  geom_node_point(aes(color = ml_id), size = 1, show.legend = FALSE) +
  scale_color_manual(values = c("#9E2B5F", "#9E2B5F", "grey40")) +
  theme_void()

#ggsave(paste0(getwd(), "/viz/coauthors_ml_same.jpg"), width = 5, height = 5)

## citation network
paper_nodes <- read_tsv(paste0(getwd(),"/data/papers/paper_network_nodes.tsv"))
paper_edges <- read_tsv(paste0(getwd(),"/data/papers/paper_network_edges.tsv"))


paper_network <- graph_from_data_frame(d=paper_edges, vertices=paper_nodes, directed=T)

#basic
ggraph(paper_network, layout = "kk") +
  geom_edge_arc(width=.1, color = "grey40", alpha = .2) +
  geom_node_point(size = .1, color = "orange") +
  theme_void()

ggsave(paste0(getwd(), "/viz/citations_test.jpg"))