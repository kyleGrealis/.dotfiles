---
name: cran-ready
description: Prepare R package for CRAN submission with all quality agents
---

Run these agents in sequence:
1. r-style-enforcer
2. r-doc-writer  
3. r-test-builder
4. r-readme-keeper
5. r-news-chronicler
6. r-code-roaster
7. r-commit-crafter

Then run R CMD check --as-cran and provide comprehensive report.
