## run setup to load networks for plot
source(here::here("scripts", "viz_setup.R"))

mark <- c(
  "#fafa6e",
  "#f7d253",
  "#eeab42",
  "#df853a",
  "#ca6037"
)

blue <- c(
  "#6dbae1",
  "#439db4",
  "#238088",
  "#0f625d",
  "#084537"
)

pub_colors <- append(blue, mark)

ggraph(reduced_paper_network, layout = "kk") +
  geom_node_point(
    aes(
      size = size_ref,
      color = pub_decade_adjusted
    ),
    show.legend = FALSE
  ) +
  scale_size_identity() +
  scale_color_manual(values = pub_colors) +
  theme_void() +
  theme(
    plot.background = element_rect(fill = "black", color = "black"),
    panel.background = element_rect(fill = "black", color = "black")
  ) +
  coord_flip() +
  scale_x_reverse()



