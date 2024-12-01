# Brawl Stars Analytics

A Ruby on Rails application that collects and analyzes Brawl Stars player data using the official Brawl Stars API.

## Overview

This application tracks top Brawl Stars players and their battles across different countries. It periodically fetches player data and battle logs to build a comprehensive database of high-level gameplay.

## Key Features

### Data Collection
- Fetches top players by country using the Brawl Stars API
- Records detailed battle logs including:
  - Team compositions
  - Player performance (power level, trophies)
  - Battle results and modes
  - Star player recognition
  - Brawler selection and gear usage

### Country Coverage
- Supports all countries using ISO 3166 country codes
- Can fetch data for individual countries or run global updates
- Includes country flags and proper naming

### Battle Tracking
- Records multiple battle types:
  - Regular team modes
  - Duo Showdown
  - Other special modes
- Tracks battle specifics:
  - Map information
  - Battle duration
  - Team rankings
  - Victory/defeat/draw outcomes

### Player Data
- Stores player statistics
- Tracks brawler usage and performance
- Records power levels and trophy counts
- Maintains star player achievements

## Technical Details

### Models
- `Battle`: Records individual matches and their outcomes
- `Team`: Tracks team composition and results
- `TeamPlayer`: Stores player performance in battles
- `Brawler`: Maintains brawler information
- `Country`: Handles country-specific data and operations

### Jobs
- `FetchTopPlayersJob`: Retrieves top players for a country
- `FetchPlayerDetailsJob`: Gets detailed player information and battle logs

### Services
- `BrawlStarsService`: Handles API communication with rate limiting

### Data Flow
1. Country selection triggers top player fetch
2. Player details and battle logs are retrieved
3. Battles are recorded with team and player information
4. Data is stored for analysis

## Configuration
- Requires Brawl Stars API key
- Configurable rate limiting for API requests
- Adjustable job scheduling intervals

## Usage

To fetch data for all countries:

```ruby
Country.fetch_