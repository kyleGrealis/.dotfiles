---
name: r-style-guide
description: Kyle's R coding style guide combining tidyverse conventions with personal preferences. Use when writing or reviewing R code to ensure consistency with preferred style patterns.
---

# Kyle's R Style Guide

This skill defines the coding style standards for all R code. These preferences blend tidyverse style guide conventions with personal choices that prioritize readability and maintainability.

## Quote Usage

**ALWAYS use single quotes** unless one of these exceptions applies:

1. **Regex expressions** - Use double quotes for regex patterns
2. **Strings with apostrophes** - Use double quotes to avoid escaping: `"Don't know"` not `'Don\'t know'`
3. **User-facing messages** - Use double quotes when the message naturally contains apostrophes

```r
# GOOD
x <- 'simple string'
pattern <- "\\d{3}-\\d{4}"  # regex uses double quotes
message <- "User's input is invalid"  # apostrophe in string

# BAD
x <- "simple string"  # unnecessary double quotes
message <- 'User\'s input is invalid'  # ugly escape
```

## Function Arguments & Indentation

**Arguments MUST start on a new line** after the opening parenthesis. Never vertically align arguments.

```r
# GOOD - Arguments on new lines with 2-space indent
result <- function_name(
  argument_1,
  argument_2,
  argument_3
)

# Also acceptable for very short calls
result <- function_name(arg1, arg2)

# BAD - Vertical alignment
result <- function_name(argument_1,
                        argument_2,
                        argument_3)

# BAD - First argument on same line as function when breaking
result <- function_name(argument_1,
  argument_2,
  argument_3
)
```

**Multi-line formulas** must use proper indentation:

```r
# GOOD
formula_m2 <- kdm_bioage ~ use_category + riagendr + race_ethnicity +
  education + income + marital_status + has_health_ins +
  alcohol_status + smq020 + pa_level + any_substances

# BAD - Misaligned continuation
formula_m2 <- kdm_bioage ~ use_category + riagendr + race_ethnicity +
                           education + income + marital_status + has_health_ins
```

## Indentation Rules

- **2 spaces** per indentation level (never tabs)
- Continuation lines indent by 2 spaces from the start
- Pipe chains: indent each step by 2 spaces
- No trailing whitespace on any line

```r
# GOOD
data |>
  filter(value > 10) |>
  select(id, value) |>
  arrange(desc(value))

# BAD - Inconsistent indentation
data |>
    filter(value > 10) |>
  select(id, value)
```

## Pipe Usage

- **Use native pipe `|>`** not `%>%`
- One operation per line
- Start pipe on same line as object
- Indent subsequent operations by 2 spaces

```r
# GOOD
result <- data |>
  filter(status == 'active') |>
  group_by(category) |>
  summarize(mean_value = mean(value, na.rm = TRUE))

# BAD - Using magrittr pipe
result <- data %>%
  filter(status == 'active')
```

## Assignment

- **Use `<-` for assignment**, not `=`
- Exception: function arguments use `=`

```r
# GOOD
x <- 5
result <- function_call(arg = 'value')

# BAD
x = 5
```

## Spacing

- Space after commas: `c(1, 2, 3)`
- Spaces around operators: `x + y`, `x == 5`
- Space after `#` in comments
- No spaces around `::` or `:::`
- Space before opening brace: `if (x) {`

## Line Length

- **Maximum 90 characters**
- Break at logical points (before operators, after commas)
- Use line breaks to improve readability even if under 90 chars

## Markdown & Quarto Lists

**CRITICAL**: Bulleted lists in markdown/Quarto documents MUST have 2 trailing spaces after each line for proper rendering.

```markdown
Here is the introduction with 2 spaces at the end.  
- First item with 2 trailing spaces  
- Second item with 2 trailing spaces  
- Third item with 2 trailing spaces  

Next paragraph starts here.
```

**Why**: Without the 2 trailing spaces, markdown renderers will collapse the list into a single line or create formatting issues.

## purrr Usage Philosophy

Kyle is learning `purrr` and appreciates its power but prioritizes **debuggability and readability**.

**When using purrr functions**:
1. Add an explanatory comment BEFORE the code
2. Document the expected output type
3. Consider: "Would a for loop be clearer here?"
4. If the answer is yes → use the loop

```r
# GOOD - purrr with explanation
# Map over each dataset and calculate summary stats
# Returns: list of data frames with mean, sd, n
summary_list <- datasets |>
  map(\(df) {
    df |>
      summarize(
        mean = mean(value, na.rm = TRUE),
        sd = sd(value, na.rm = TRUE),
        n = n()
      )
  })

# ALSO GOOD - Clear for loop
summary_list <- list()
for (i in seq_along(datasets)) {
  summary_list[[i]] <- datasets[[i]] |>
    summarize(
      mean = mean(value, na.rm = TRUE),
      sd = sd(value, na.rm = TRUE),
      n = n()
    )
}
```

**Prefer `purrr` when**:
- Mapping over multiple inputs simultaneously (`map2()`, `pmap()`)
- Working with nested lists
- Functional programming clarity outweighs debugging complexity

**Prefer loops when**:
- Simple iteration with clear steps
- Debugging will be needed
- The intent is clearer with explicit iteration

## tidyverse vs Base R

**Default to tidyverse** for data manipulation, but be pragmatic:

- Use tidyverse (`dplyr`, `tidyr`) for data wrangling - it's clearer
- Use `across()` for column-wise operations where possible
- Use base R when it's genuinely faster or simpler
- Never sacrifice readability for minor performance gains

```r
# GOOD - tidyverse for clarity
data |>
  filter(status == 'active') |>
  mutate(across(starts_with('val_'), log))

# ALSO GOOD - explicit when debugging needed
data |>
  filter(status == 'active') |>
  mutate(
    val_1 = log(val_1),
    val_2 = log(val_2)
  )
```

## File Structure

- UTF-8 encoding
- Unix line endings (LF, not CRLF)
- Final newline at end of every file
- No trailing whitespace

## Control Flow

- Space before opening brace: `if (condition) {`
- `else` on same line as closing brace: `} else {`
- One-line if statements are acceptable if under 90 chars: `if (x == y) print('OK!')`

```r
# GOOD
if (x > 10) {
  do_something()
} else {
  do_other_thing()
}

# ALSO GOOD - one-liner
if (x > 10) result <- 'high'

# BAD
if(x>10){do_something()}  # no spaces
```

## Comments

- Space after `#`
- Explain WHY, not WHAT (code should be self-documenting)
- Use roxygen2 comments `#'` with space for documentation

```r
# GOOD
# Calculate weighted average to account for sampling design
weighted_mean <- sum(x * weights) / sum(weights)

# BAD
# This calculates the weighted mean
weighted_mean <- sum(x * weights) / sum(weights)
```

## Naming Conventions

- **snake_case** for functions and variables
- **SCREAMING_SNAKE_CASE** for constants
- **PascalCase** for S3/S4 class names only
- No dots in function names (except S3 methods)
- Clear, descriptive names over abbreviations

```r
# GOOD
calculate_summary_stats <- function(data, na_rm = TRUE) { }
MAX_ITERATIONS <- 1000

# BAD
calcSummaryStats <- function(data, na.rm = TRUE) { }  # camelCase
calc.stats <- function(data) { }  # dots in name
```

## Red Flags to Avoid

These patterns should be flagged immediately:

- **`attach()` usage** - Creates namespace conflicts
- **`setwd()` in scripts** - Breaks reproducibility (use `here::here()`)
- **`=` for assignment** - Use `<-`
- **`%>%` instead of `|>`** - Use native pipe
- **Double quotes for simple strings** - Use single quotes
- **Vertical alignment of arguments** - Never do this
- **Growing vectors in loops** - Pre-allocate or vectorize
- **Missing `na.rm` in aggregation functions** - Be explicit
- **Hard-coded file paths** - Use `here::here()` or relative paths

## Summary

The goal is **readable, maintainable code** that follows modern R conventions while respecting personal preferences. When in doubt:

1. Favor readability over cleverness
2. Be consistent within a project
3. Write code that you'll understand in 6 months
4. Document the WHY, not the WHAT
