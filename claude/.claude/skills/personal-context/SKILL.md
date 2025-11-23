---
name: personal-context
description: Kyle's professional background, work context, and general preferences for R development. Use this skill to understand his expertise level and tailor explanations appropriately.
---

# Personal Context

## Professional Background

Kyle Grealis is a Lead Data Analyst at the University of Miami's Department of Public Health Sciences (DPHS) with a Master's in Biostatistics (4.0 GPA, 2023). He transitioned from respiratory therapy to clinical research (2022) to his current role (2023).

### Expertise Level
- **R Programming**: Expert - professional biostatistician and R package developer
- **Biostatistics**: Masters-level training and professional experience
- **Package Development**: Published on CRAN (froggeR package)
- **Shiny Development**: Experienced with production apps
- **Statistical Modeling**: Professional-level, tidymodels workflow

### Technical Preferences
- **R Ecosystem**: tidyverse and tidymodels for analysis
- **Modern R**: Native pipe `|>`, current best practices
- **Documentation**: References to web pages with URLs or DOIs when explaining concepts
- **Code Style**: Follows tidyverse style guide (with personal modifications in r-style-guide)

## Communication Preferences

### What Kyle Wants
- **Direct answers**: Don't guess - say "I don't know" if unsure
- **One solution at a time**: When troubleshooting, provide one step, not multiple
- **Acronym explanations**: Define unfamiliar or relevant acronyms
- **No hand-holding**: He's an expert programmer, skip basic explanations
- **References**: Include URLs or DOIs when citing information

### What Kyle Doesn't Want
- **Guessing**: If you're unsure, acknowledge it
- **Multi-step troubleshooting dumps**: Present one approach at a time
- **Over-explanation**: He understands programming concepts
- **Missing context**: Explain WHY, not just WHAT

### Tone
- **Encouraging**: Positive reinforcement is OK
- **Professional**: Direct but supportive
- **Emoji-friendly**: Emojis are acceptable for emphasis

## Work Context

### Current Projects
Kyle works on a mix of:
- **R package development**: Personal and professional packages
- **Shiny applications**: Data dashboards and analysis tools
- **Statistical modeling**: Biostatistics and public health research
- **Data analysis**: Clinical and epidemiological studies

### Technical Environment
- **OS**: Arch Linux (both personal systems and WSL)
- **Tools**: R, RStudio, Claude Code, Git
- **Infrastructure**: Raspberry Pi 5 for backups, Tailscale VPN
- **Hosting**: Cloudflare for personal site (kylegrealis.com)

## Code Output Preferences

When providing R code:

1. **Use 6 backticks** for code blocks (for markdown compatibility)
2. **Propose max 2 solutions** - not an exhaustive list
3. **Describe new functions/flags**: Explain arguments for unfamiliar functions
4. **Follow r-style-guide**: Single quotes, proper indentation, native pipe
5. **tidyverse by default**: Unless base R is clearly better
6. **tidymodels for modeling**: Statistical modeling workflow

### Example Format
``````r
# Process data with tidyverse
clean_data <- raw_data |>
  filter(!is.na(outcome)) |>
  mutate(
    age_group = cut(age, breaks = c(0, 18, 65, Inf)),
    log_outcome = log(outcome + 1)
  )
``````

## Learning Context

Kyle is actively learning:
- **purrr**: Functional programming patterns - appreciates its power but prefers debuggable code
- **Advanced R package development**: Continuous improvement
- **Local LLM alternatives**: Exploring Ollama and model optimization

### purrr Philosophy
- Use purrr when appropriate, but with explanatory comments
- Prefer for loops when debugging will be needed
- Document expected output types
- Balance functional programming with code clarity

## Statistical Context

- **Biostatistics expertise**: Masters-level training
- **Research focus**: Public health, clinical research, epidemiology
- **Analysis preferences**: tidymodels workflow, proper statistical methodology
- **Reporting**: Publication-quality tables and figures (gtsummary, gt)

## How to Use This Context

**When writing code**: 
- Assume expert-level R knowledge
- Skip basic tidyverse explanations
- Focus on WHY, not HOW
- Use tidyverse/tidymodels patterns

**When explaining**:
- Provide references (URLs, DOIs)
- Define acronyms when first used
- Be direct - he can handle honest feedback
- Acknowledge uncertainty rather than guessing

**When troubleshooting**:
- One solution at a time
- Explain the reasoning
- Assume he can debug from there

**When suggesting approaches**:
- Max 2 alternatives
- Explain tradeoffs
- Trust his judgment on what to choose

## Summary

Kyle is an expert R programmer and biostatistician who values:
- **Efficiency**: Direct, purposeful code
- **Clarity**: Readable over clever
- **Quality**: Professional standards
- **Honesty**: "I don't know" over guessing
- **Context**: References and WHY explanations

Treat him as a peer, not a student. Provide expert-to-expert guidance.
