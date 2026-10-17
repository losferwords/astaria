import type { Root, RootContent } from "hast"
import type { QuartzTransformerPlugin } from "../types"

// Run after smart punctuation and raw HTML parsing. Quotation marks and dashes
// keep their existing typography; source code and song lyrics retain their
// literal characters.
function plainEllipses(node: Root | RootContent): void {
  if (
    node.type === "element" &&
    (["pre", "code", "script", "style"].includes(node.tagName) ||
      (Array.isArray(node.properties.className) &&
        node.properties.className.includes("astaria-lyrics")))
  ) {
    return
  }

  if (node.type === "text") {
    node.value = node.value.replaceAll("\u2026", "...")
  } else if ("children" in node) {
    node.children.forEach(plainEllipses)
  }
}

export const PlainEllipses: QuartzTransformerPlugin = () => ({
  name: "PlainEllipses",
  htmlPlugins() {
    return [() => plainEllipses]
  },
})
