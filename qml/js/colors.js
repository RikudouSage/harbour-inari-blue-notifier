function parseIntoRgb(color) {
    return "rgb(" +
               Math.round(color.r * 255) + ", " +
               Math.round(color.g * 255) + ", " +
               Math.round(color.b * 255) + ")"
}
