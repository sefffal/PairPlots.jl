import { defineConfig } from 'vitepress'
import { tabsMarkdownPlugin } from 'vitepress-plugin-tabs'
import mathjax3 from "markdown-it-mathjax3";
import footnote from "markdown-it-footnote";

// https://vitepress.dev/reference/site-config
export default defineConfig({
  base: '/yourgithubusername.github.io/YourPackage.jl/',// TODO: replace this in makedocs!
  title: 'PairPlots.jl',
  description: "A VitePress Site",
  lastUpdated: true,
  cleanUrls: true,
  outDir: '../final_site', // This is required for MarkdownVitepress to work correctly...
  
  ignoreDeadLinks: true,

  markdown: {
    math: true,
    config(md) {
      md.use(tabsMarkdownPlugin),
      md.use(mathjax3),
      md.use(footnote)
    },
    theme: {
      light: "github-light",
      dark: "github-dark"}
  },
  themeConfig: {
    outline: 'deep',
    logo: { src: '/logo.png', width: 24, height: 24},
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },
    nav: [
{ text: 'Home', link: '/index' },
{ text: 'Getting Started', link: '/getting-started' },
{ text: 'Guide', link: '/guide' },
{ text: 'MCMCChains', link: '/chains' },
{ text: 'API', link: '/api' }
]
,
    sidebar: [
{ text: 'Home', link: '/index' },
{ text: 'Getting Started', link: '/getting-started' },
{ text: 'Guide', link: '/guide' },
{ text: 'MCMCChains', link: '/chains' },
{ text: 'API', link: '/api' }
]
,
    editLink: { pattern: "https://github.com/YourGithubUsername/YourPackage.jl/edit/master/docs/src/:path" },
    socialLinks: [
      { icon: 'github', link: 'https://github.com/YourGithubUsername/YourPackage.jl' }
    ],
    footer: {
      message: 'Made with <a href="https://documenter.juliadocs.org/stable/" target="_blank"><strong>Documenter.jl</strong></a> & <a href="https://vitepress.dev" target="_blank"><strong>VitePress</strong></a> <br>',
      copyright: `© Copyright ${new Date().getUTCFullYear()}.`
    }
  }
})
