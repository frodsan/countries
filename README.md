# countries

Code exercise to build a simple command line tool that fetches the [REST countries API](https://restcountries.com).

![example](/doc/example.gif)

## Prerequisites

- Ruby 3.1.1
- Bundler

## Installation

Install dependencies with:

```
$ bundle install
```

## Problem statement

1. Fetch a list of countries with metadata using the [REST countries API](https://restcountries.com).

2. Process and display the data accordingly:
      - List countries in a table
      - Show columns: Name, Region, Area, Population
      - Format the area in square metric miles, without decimals (example, for Norway “125020”)
      - Format the population in millions with one decimal (example, for Norway “5.2”)
      - Input option for visualization: sort by one of name, population or area
      - Summary at the end: Show the population average from all the countries, and also the countries with smallest and biggest area.
      - List languages with the countries that speak it in a table
      - Show columns: Language, Countries[], Population

## Solution

I have made a CLI in Ruby that fetches and displays data from [REST countries API](https://restcountries.com).

#### Usage

```
USAGE
  $ bin/countries [OPTIONS]

OPTIONS
  -f condition value   filter countries by the specified conditions.
                       [conditions: name, region, subregion, lang]

  -s condition         sort countries by `condition` in ascending order.
                       [conditions: name (default), region, area, population]
```

#### Examples

- Find countries where German is the official language and sort them by population:

      $ bin/countries -f lang german -s population
      +-------------------------------------------------------------------------------+
      |                               Countries Summary                               |
      +------------------------------+--------+------------+--------------------------+
      | Name                         | Region | Area (mi²) | Population (in millions) |
      +------------------------------+--------+------------+--------------------------+
      | Liechtenstein                | Europe |         61 |                     0.0M |
      | Luxembourg                   | Europe |        998 |                     0.6M |
      | Namibia                      | Africa |     318770 |                     2.5M |
      | Belgium                      | Europe |      11786 |                    11.6M |
      | Germany                      | Europe |     137881 |                    83.2M |
      +------------------------------+--------+------------+--------------------------+
      | Population average           |        |            |                    19.6M |
      +------------------------------+--------+------------+--------------------------+
      | Smallest area: Liechtenstein | Europe |         61 |                     0.0M |
      | Biggest area: Namibia        | Africa | 318770     |                     2.5M |
      +------------------------------+--------+------------+--------------------------+

- Find countries whose of their names include 'fr' and sort them by area:

      $bin/countries -f name fr -s area
      +-----------------------------------------------------------------------------------------+
      |                                    Countries Summary                                    |
      +-------------------------------------+-----------+------------+--------------------------+
      | Name                                | Region    | Area (mi²) | Population (in millions) |
      +-------------------------------------+-----------+------------+--------------------------+
      | Saint Martin                        | Americas  |         20 |                     0.0M |
      | French Polynesia                    | Oceania   |       1608 |                     0.3M |
      | French Southern and Antarctic Lands | Antarctic |       2991 |                     0.0M |
      | France                              | Europe    |     213009 |                    67.4M |
      | Central African Republic            | Africa    |     240534 |                     4.8M |
      | South Africa                        | Africa    |     471442 |                    59.3M |
      +-------------------------------------+-----------+------------+--------------------------+
      | Population average                  |           |            |                    22.0M |
      +-------------------------------------+-----------+------------+--------------------------+
      | Smallest area: Saint Martin         | Americas  |         20 |                     0.0M |
      | Biggest area: South Africa          | Africa    | 471442     |                    59.3M |
      +-------------------------------------+-----------+------------+--------------------------+
