/** Resolve preview HTML independently from the canonical navigation URL. */
export function resolveSearchPreviewUrl(
  target: string,
  page: string,
  documentBase: string,
  configuredBase: string,
  language: string,
): string {
  const pageUrl = new URL(page)
  const url = new URL(target, pageUrl)
  if (url.origin !== pageUrl.origin) return url.toString()

  const localeSegment = "/__locales/"
  const configuredRoot = configuredBase.split(localeSegment)[0].replace(/\/$/, "")
  const basePath = new URL(documentBase, pageUrl).pathname
  const localePosition = basePath.indexOf(localeSegment)
  const root =
    localePosition >= 0
      ? basePath.slice(0, localePosition)
      : configuredRoot &&
          (pageUrl.pathname === configuredRoot || pageUrl.pathname.startsWith(`${configuredRoot}/`))
        ? configuredRoot
        : ""

  let route = url.pathname
  for (const prefix of [configuredRoot, root]) {
    if (prefix && (route === prefix || route.startsWith(`${prefix}/`))) {
      route = route.slice(prefix.length)
      break
    }
  }
  route = route.replace(/^\/__locales\/[^/]+(?=\/|$)/, "") || "/"
  const locale = language.toLowerCase().startsWith("ru") ? "/__locales/ru" : ""
  url.pathname = `${root}${locale}${route.startsWith("/") ? route : `/${route}`}`
  return url.toString()
}
