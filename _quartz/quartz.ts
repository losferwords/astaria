import { loadQuartzConfig, loadQuartzLayout } from "./quartz/plugins/loader/config-loader"
import * as ExternalPlugin from "./.quartz/plugins"

ExternalPlugin.Explorer({
  title: "Астария",
  folderDefaultState: "open",
  folderClickBehavior: "link",
  useSavedState: true,
  mapFn: (node: any) => {
    const names: Record<string, string> = {
      index: "Астария",
      countries: "Страны",
      gods: "Боги",
      peoples: "Народы",
      places: "Места",
      organizations: "Организации",
      characters: "Персонажи",
      imitei: "Имитеи",
      lore: "Знания",
      events: "События",
      items: "Предметы",
      literature: "Литература",
      timeline: "Хронология",
      map: "Карты",
    }

    if (node.slugSegment && names[node.slugSegment]) {
      node.displayName = names[node.slugSegment]
    }

    return node
  },
  sortFn: (a: any, b: any) => {
    const order: Record<string, number> = {
      index: 0,
      countries: 10,
      gods: 20,
      peoples: 30,
      places: 40,
      organizations: 50,
      characters: 60,
      imitei: 70,
      lore: 80,
      events: 90,
      items: 100,
      literature: 110,
      timeline: 120,
      map: 130,
    }

    const aOrder = order[a.slugSegment || ""] ?? 1000
    const bOrder = order[b.slugSegment || ""] ?? 1000
    if (aOrder !== bOrder) return aOrder - bOrder

    if (a.isFolder !== b.isFolder) {
      return a.isFolder ? -1 : 1
    }

    return (a.displayName || "").localeCompare(b.displayName || "", "ru", {
      numeric: true,
      sensitivity: "base",
    })
  },
  filterFn: (node: any) => node.slugSegment !== "tags",
})

const config = await loadQuartzConfig()
export default config
export const layout = await loadQuartzLayout()
