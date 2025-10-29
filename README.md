# For-Profit University Stock Price Analysis

This project models time series of stock prices for publicly-traded companies that run for-profit universities. The analysis examines how short-term price changes relate to government policies and political events, including election results and appointments of key officials.

## Project Overview

The goal of this project is to create an academic paper analyzing the relationship between:
- Stock prices of for-profit university companies
- Government policy changes
- Election results
- Appointments of key education officials

## Project Structure

```
profit_price/
├── data/
│   ├── raw/              # Raw data (not tracked in git)
│   └── processed/        # Processed data files
├── scripts/
│   ├── 01_data_collection.R     # Data collection scripts
│   ├── 02_data_processing.R     # Data cleaning and preparation
│   └── 03_time_series_models.R  # Time series modeling
├── analysis/
│   └── main_analysis.Rmd        # Main analysis document for the paper
├── output/
│   ├── figures/          # Generated figures
│   └── tables/           # Generated tables
└── README.md             # This file
```

## Setup

For a detailed quick start guide, see [QUICKSTART.md](QUICKSTART.md).

### Prerequisites

- R (version 4.0 or higher recommended)
- RStudio
- Required R packages:
  - tidyverse
  - quantmod (for stock data)
  - tseries (for time series analysis)
  - forecast (for forecasting)
  - lubridate (for date handling)
  - knitr and rmarkdown (for report generation)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/wdoyle42/profit_price.git
cd profit_price
```

2. Open the project in RStudio by double-clicking `profit_price.Rproj`

3. Install required packages by running in R console:
```r
install.packages(c("tidyverse", "quantmod", "tseries", "forecast", "lubridate", "knitr", "rmarkdown"))
```

## Usage

### Data Collection

Run the data collection script to download stock prices:
```r
source("scripts/01_data_collection.R")
```

### Data Processing

Process and clean the data:
```r
source("scripts/02_data_processing.R")
```

### Analysis

Open and knit the main analysis document:
```r
rmarkdown::render("analysis/main_analysis.Rmd")
```

## Companies Analyzed

For-profit university companies typically include:
- Grand Canyon Education, Inc. (LOPE)
- Strategic Education, Inc. (STRA)
- American Public Education, Inc. (APEI)
- Adtalem Global Education Inc. (ATGE)

## Key Events Analyzed

- Presidential elections
- Congressional elections
- Appointments of Secretary of Education
- Department of Education policy announcements
- Regulatory changes affecting for-profit education

## Methodology

The analysis uses time series models to examine:
1. Event study analysis around key political events
2. ARIMA models for stock price prediction
3. Intervention analysis to measure policy impacts
4. Comparative analysis across different companies

## Output

The main output is an academic paper suitable for publication, generated from the R Markdown analysis file.

## License

Please check with the repository owner for licensing information.

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contact

Will Doyle - Repository owner