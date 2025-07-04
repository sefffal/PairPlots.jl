---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "PairPlots"
  tagline: Beautiful and flexible visualizations of high dimensional data
  image:
    src: /logo.png
    alt: DocumenterVitepress
  actions:
    - theme: brand
      text: Getting Started
      link: /getting-started
    - theme: alt
      text: Full Guide
      link: /guide
    - theme: alt
      text: View on Github
      link: https://github.com/sefffal/PairPlots.jl

features:
  - icon: <img width="64" height="64" src="https://dataframes.juliadata.org/stable/assets/logo.png" alt="tables"/>
    title: Tables
    details: Compatible with DataFrames or any Julia table
    link: https://dataframes.juliadata.org/stable/
  - icon: <img width="64" height="64" src="https://avatars.githubusercontent.com/u/26261527?s=200&v=4" />
    title: MCMC
    details: Turing.jl and MCMCChains.jl compatible
    link: https://turinglang.org/MCMCChains.jl/stable/
  - icon: <img width="64" height="64" src="https://avatars.githubusercontent.com/u/98041931?s=200&v=4"/>
    title: Flexible
    details: Highly configurable and themeable using the Makie plotting package.
    link: https://docs.makie.org/stable
---

<p style="margin-bottom:2cm"></p>

<div class="vp-doc" style="width:80%; margin:auto">


This package produces pair plots, otherwise known as corner plots or scatter plot matrices: grids of 1D and 2D histograms that allow you to visualize high dimensional data. Both Julia and Python are supported (PairPlots.jl and pairplots.py).

Pair plots are an excellent way to visualize the results of MCMC simulations, but are also a useful way to visualize correlations in general data tables.

PairPlots is inspired by the excellent [corner.py](https://corner.readthedocs.io/en/latest/index.html) and [chainconsumer.py](https://samreay.github.io/ChainConsumer/usage.html) packages.

The current version of PairPlots uses the [Makie](https://docs.makie.org/stable/) plotting library. If instead you prefer to use Plots.jl, you can install the legacy version `0.6` of PairPlots (see [archived documentation here](https://github.com/sefffal/PairPlots.jl/blob/b632abd79c0dfbe7387d44393f4fb5b7f74ac5d8/README.md))
</div>

