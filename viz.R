## This relies on guidance from a superb tutorial by Katya Ognyanova
## https://kateto.net/network-visualization

library(igraph)
library(ggraph)
library(ggplot2)
library(readr)
library(dplyr)

nodes <- read_tsv(paste0(getwd(),"/data/author_network_nodes.tsv")) %>%
  mutate(is_linda = ifelse(au_id == "au28", TRUE, FALSE))
edges <- read_tsv(paste0(getwd(),"/data/author_network_edges.tsv")) %>%
  mutate(is_linda = case_when(from == "au28" & to == "au14" ~ TRUE,
                              to == "au28" & from == "au14" ~ TRUE,
                              TRUE ~ FALSE))


author_network <- graph_from_data_frame(d=edges, vertices=nodes, directed=T)

## initial pass at the coauthorship network
ggraph(author_network, layout = "sphere") +
  geom_edge_arc(aes(colour = is_linda, alpha = is_linda), width=.7, show.legend = FALSE) +
  scale_edge_colour_manual(values = c("grey40", "#CC3300")) +
  scale_edge_alpha_manual(values = c(.3, 1)) +
  geom_node_point(aes(color = is_linda), size = 3, show.legend = FALSE) +
  scale_color_manual(values = c("grey30", "#CC3300")) +
  theme_void()

## wishlist:
## - highlight connection between M+L
## - play with modifying edges by metadata (journal/year/paper)
## - tweak general aesthetic until it seems like M+L-worthy art
## - develop other vizualizations (citation network, trends over time, etc.)
## - ???
