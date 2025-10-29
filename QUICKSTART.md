# Quick Start Guide

This guide will help you get started with the For-Profit University Stock Price Analysis project.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **R** (version 4.0 or higher)
   - Download from: https://cran.r-project.org/
   
2. **RStudio** (recommended IDE)
   - Download from: https://posit.co/download/rstudio-desktop/
   
3. **LaTeX** (optional, for PDF generation)
   - Windows: MiKTeX (https://miktex.org/)
   - Mac: MacTeX (https://www.tug.org/mactex/)
   - Linux: TeX Live (`sudo apt-get install texlive-full`)

## Quick Start

### Option 1: Run Complete Analysis Pipeline

The easiest way to run the entire analysis is to use the master script:

```r
# Open RStudio and set working directory to the project folder
# Then run:
source("run_analysis.R")
```

This will:
1. Download stock price data from Yahoo Finance
2. Process the data and calculate features
3. Run time series models and event studies
4. Generate the analysis report (HTML and PDF)

### Option 2: Run Scripts Step-by-Step

If you prefer to run each step individually:

#### Step 1: Data Collection

```r
source("scripts/01_data_collection.R")
```

This downloads stock price data for:
- LOPE (Grand Canyon Education)
- STRA (Strategic Education)
- APEI (American Public Education)
- ATGE (Adtalem Global Education)

Data is saved to `data/raw/stock_prices.rds`

#### Step 2: Data Processing

```r
source("scripts/02_data_processing.R")
```

This processes the raw data and:
- Calculates returns and volatility
- Creates moving averages
- Defines political/policy events
- Creates event windows

Processed data is saved to `data/processed/`

#### Step 3: Time Series Modeling

```r
source("scripts/03_time_series_models.R")
```

This runs:
- ARIMA models for each stock
- Event study analysis
- Cumulative abnormal return calculations

Results are saved to `output/`

#### Step 4: Generate Report

```r
# Open analysis/main_analysis.Rmd in RStudio
# Click "Knit" button, or run:
rmarkdown::render("analysis/main_analysis.Rmd")
```

This generates the academic paper with all figures and tables.

## Installing Required Packages

If you don't have the required packages installed, run:

```r
install.packages(c(
  "tidyverse",
  "quantmod",
  "tseries",
  "forecast",
  "lubridate",
  "knitr",
  "rmarkdown",
  "zoo",
  "kableExtra",
  "scales"
))
```

## Project Structure

```
profit_price/
├── analysis/              # Main analysis and paper
│   ├── main_analysis.Rmd # R Markdown document
│   └── references.bib    # Bibliography
├── scripts/              # R scripts for data and analysis
├── data/                 # Data directories
│   ├── raw/             # Raw downloaded data
│   └── processed/       # Processed data
├── output/              # Analysis results
│   ├── figures/        # Generated plots
│   └── tables/         # Generated tables
└── run_analysis.R      # Master script
```

## Troubleshooting

### "Cannot download stock data"

- Check your internet connection
- Yahoo Finance may be temporarily unavailable
- Some stocks may have been delisted

### "pandoc not found"

- Install pandoc separately: https://pandoc.org/installing.html
- Or use RStudio which includes pandoc

### "LaTeX Error"

- For PDF output, you need LaTeX installed
- Alternatively, generate HTML output only:
  ```r
  rmarkdown::render("analysis/main_analysis.Rmd", output_format = "html_document")
  ```

### Package installation fails

- Try installing packages one at a time
- Check that you have write permissions to the R library folder
- Update R to the latest version

## Customization

### Adding More Companies

Edit `scripts/01_data_collection.R` and add ticker symbols to the `stock_symbols` vector:

```r
stock_symbols <- c("LOPE", "STRA", "APEI", "ATGE", "YOUR_SYMBOL")
```

### Adding More Events

Edit `scripts/02_data_processing.R` and add rows to the `events` tibble:

```r
events <- tribble(
  ~event_date, ~event_type, ~event_description,
  "2024-11-05", "election", "2024 Presidential Election",
  # ... more events
)
```

### Changing Date Range

Edit `scripts/01_data_collection.R` and modify:

```r
start_date <- "2010-01-01"  # Change start date
end_date <- Sys.Date()      # Change end date
```

## Next Steps

1. Review the generated analysis in `analysis/main_analysis.html` or `.pdf`
2. Examine the figures in the `output/figures/` directory
3. Customize the analysis for your specific research questions
4. Edit the R Markdown document to add your interpretation and discussion

## Getting Help

- Check the main README.md for more details
- Review the comments in each R script
- Consult R package documentation:
  - quantmod: https://www.quantmod.com/
  - forecast: https://pkg.robjhyndman.com/forecast/
  - tidyverse: https://www.tidyverse.org/

## Citation

If you use this project in your research, please cite:

```
Doyle, W. (2025). Political Events and Stock Prices: Evidence from For-Profit Universities. 
GitHub repository: https://github.com/wdoyle42/profit_price
```
