# Draws man/figures/logo.png: endline-vs-follow-up effect sizes with correlated
# sampling-error ellipses, the naive slope (dashed) and the corrected one (solid).
library(ggplot2)

navy <- "#16233A"; gold <- "#F2B544"; coral <- "#E4675A"; ice <- "#CFE3F2"

hex <- data.frame(x = 0.965 * cos(pi / 2 + 0:5 * pi / 3), y = 0.965 * sin(pi / 2 + 0:5 * pi / 3))

# effect-size pairs around a line of slope 0.45; ellipses tilted by rho = 0.75
set.seed(8)
k <- 11
x0 <- sort(runif(k, -0.5, 0.5))
pts <- data.frame(id = seq_len(k), x = x0, y = 0.2 + 0.45 * x0 + rnorm(k, 0, 0.06))
circ <- cbind(cos(seq(0, 2 * pi, length.out = 60)), sin(seq(0, 2 * pi, length.out = 60)))
L <- chol(matrix(c(1, 0.75, 0.75, 1), 2)) * 0.075
ell <- do.call(rbind, lapply(seq_len(k), function(i) {
  e <- circ %*% L
  data.frame(id = i, x = pts$x[i] + e[, 1], y = pts$y[i] + e[, 2])
}))

line <- function(b, a, col, lty, lw) {
  xs <- c(-0.56, 0.56)
  annotate("segment", x = xs[1], xend = xs[2], y = a + b * xs[1], yend = a + b * xs[2],
           colour = col, linetype = lty, linewidth = lw, lineend = "round")
}

p <- ggplot() +
  geom_polygon(data = hex, aes(x, y), fill = navy, colour = gold, linewidth = 5) +
  annotate("segment", x = -0.6, xend = 0.6, y = -0.12, yend = -0.12, colour = ice,
           alpha = 0.35, linewidth = 0.6) +
  annotate("segment", x = -0.6, xend = -0.6, y = -0.12, yend = 0.5, colour = ice,
           alpha = 0.35, linewidth = 0.6) +
  geom_polygon(data = ell, aes(x, y, group = id), fill = ice, alpha = 0.16,
               colour = ice, linewidth = 0.3) +
  geom_point(data = pts, aes(x, y), colour = ice, size = 3.2) +
  line(0.72, 0.2, coral, "22", 1.6) +
  line(0.45, 0.2, gold, "solid", 2.4) +
  annotate("text", x = 0, y = -0.43, label = "ghreg", colour = "white",
           family = "Avenir Next", fontface = "bold", size = 30) +
  annotate("text", x = 0, y = -0.68, label = "persistence meta-regression",
           colour = ice, family = "Avenir Next", size = 7) +
  coord_fixed(xlim = c(-0.87, 0.87), ylim = c(-1, 1), expand = FALSE) +
  theme_void() +
  theme(plot.background = element_rect(fill = "transparent", colour = NA),
        panel.background = element_rect(fill = "transparent", colour = NA))

ragg::agg_png("man/figures/logo.png", width = 1039, height = 1200, res = 300,
              background = "transparent", scaling = 0.33)
print(p)
invisible(dev.off())
