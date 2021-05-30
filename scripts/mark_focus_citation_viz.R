## run setup to load networks for plot
source(here::here("scripts", "viz_setup.R"))


ggraph(reduced_paper_network, layout = "kk") +
  geom_edge_arc(
    color = "grey90", 
    aes(alpha=big_boy),
    show.legend = FALSE
  ) +
  scale_edge_alpha_manual(values = c(.1, 0)) +
  geom_node_point(
    aes(
      size = big_boy,
      color = pub_decade
    ),
    show.legend = FALSE
  ) +
  scale_size_manual(values = c(.3, 3)) +
  theme_void() +
  theme(plot.background = element_rect(fill = "black", color = "black"),
        panel.background = element_rect(fill = "black", color = "black")) +
  coord_flip() +
  scale_x_reverse()

# try to turn edges off for things connected to big boy
# make big boy bigger
# continue to play with color
