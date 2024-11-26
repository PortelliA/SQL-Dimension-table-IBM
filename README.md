# Solid Waste Data Warehouse Project

## Project Summary
This project, designed by IBM, demonstrates creating a data warehouse for a solid waste management company in Brazil. The company wants to generate reports on waste collection.

## Objectives
- Total waste collected per year, month, quarter per city
- Total waste collected per year per truck type
- Total waste collected per truck type per city, station

## Schema Design
### Dimension Tables
- **DimDate**: date ID, date, year, quarter, month, day, weekday
- **DimTruck**: truck ID, truck type
- **DimStation**: station ID, city

### Fact Table
- **FactTrips**: trip ID, date ID, station ID, truck ID, waste collected

## SQL Techniques Used
- **Table Creation**: Designed dimension and fact tables
- **Foreign Keys**: Established table relationships
- **Data Import**: Imported data from CSV files
- **Grouping Sets**: Aggregate data by different dimensions
- **Rollup Queries**: Summarized data by year, city, station
- **Materialized Views**: Stored aggregated data for quick access

## Challenges and Learnings
This challenging project provided practical experience in data warehousing and advanced SQL queries.

Time taken: Approximately 1 hour 20 minutes.
