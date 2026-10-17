import assert from "node:assert/strict"
import test from "node:test"
import type { Root, RootContent, Text } from "hast"
import { unified } from "unified"
import remarkParse from "remark-parse"
import remarkRehype from "remark-rehype"
import type { BuildCtx } from "../../util/ctx"
import { PlainEllipses } from "./plainEllipses"

const ctx = {} as BuildCtx

async function render(source: string): Promise<Root> {
  const pipeline = unified()
    .use(remarkParse)
    .use(remarkRehype)
    .use(PlainEllipses().htmlPlugins!(ctx))
  return await pipeline.run(pipeline.parse(source)) as Root
}

function textNodes(node: Root | RootContent): Text[] {
  if (node.type === "text") return [node]
  return "children" in node ? node.children.flatMap(textNodes) : []
}

test("keeps plain ellipses and normalizes typographic ones without changing quotes", async () => {
  const tree = await render('“Wait\u2026”\n\n“Подожди...”\n\nA familiar pause\u2026')
  assert.deepEqual(textNodes(tree).map(node => node.value).filter(value => value.trim()), [
    "“Wait...”",
    "“Подожди...”",
    "A familiar pause...",
  ])
})

test("preserves literal ellipses inside inline and fenced code", async () => {
  const tree = await render("A pause... `literal\u2026`\n\n```\nliteral\u2026\n```\n")
  assert.deepEqual(textNodes(tree).map(node => node.value).filter(value => value.trim()), [
    "A pause... ",
    "literal\u2026",
    "literal\u2026\n",
  ])
})

test("preserves original song lyrics while normalizing surrounding prose", async () => {
  const tree: Root = {
    type: "root",
    children: [
      {
        type: "element",
        tagName: "p",
        properties: {},
        children: [{ type: "text", value: "Her story continues\u2026" }],
      },
      {
        type: "element",
        tagName: "section",
        properties: { className: ["astaria-lyrics"] },
        children: [
          {
            type: "element",
            tagName: "span",
            properties: { className: ["astaria-lyric-line"] },
            children: [{ type: "text", value: "Dry up\u2026" }],
          },
          {
            type: "text",
            value: "Highlander, the hope for us all\u2026\u00a0",
          },
        ],
      },
    ],
  }
  const result = await unified().use(PlainEllipses().htmlPlugins!(ctx)).run(tree)
  assert.deepEqual(textNodes(result).map(node => node.value), [
    "Her story continues...",
    "Dry up\u2026",
    "Highlander, the hope for us all\u2026\u00a0",
  ])
})
