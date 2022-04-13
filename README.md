# BoosBrantleyHusted ENV872 EDA Final Project
Spring 2022 EDA Final Project: Atlantic Hurricane Season Trends

Instructions: copy and paste this template into your project README file (found in the parent folder of the repository). Fill in relevant information as requested.

General notes: This is the read me file for the final EDA project. It includes information on the repository structure, files within it, and the premise of the project. 

## Summary

This repository contains downloaded USGS data for three locations along the Eastern US Coast as well as code used to analyze trends for each of these locations. Trends in these three locations (New York, North Carolina, and Florida) are analyzed to determine changes in hurricane regimes over time. 

## Investigators

Andrew Brantley
Elise Boos
Kelsey Husted

## Keywords

Hurricane, Trend, Seasonality, Discharge

## Database Information

All data was retrieved from USGS historical discharge datasets recorded by USGS stream gages in the three states being investigated. All data was downloaded on 4/1/22. Processed data was wrangled by the investigators and written into the Processed Data folder in the repository.

## Folder structure, file formats, and naming conventions 

Folders in this repository include: Code, Data/Raw, & Data/Processed. Data files are all downloaded/processed into csv format and code is in both .Rmd files as well as .R files. Files are named to include whether they are raw or processed and they include the site in which the code or data is in reference to.

## Metadata

<For each data file in the repository, describe the data contained in each column. Include the column name, a description of the information, the class of data, and any units associated with the data. Create a list or table for each data file.>

Raw Data:

NC_Discharge_NewRiver_RAW.csv
  1. Columns: "agency_cd", "site_no", "datetime", "tz_cd", "X164771_00065", "X164771_00065_cd", "X89345_00060", "X89345_00060_cd", "X89346_00065", "X89346_00065_cd", "Date" 
  2. Column Meanings: agency (USGS), USGS gage #, date and time of collection, time zone, gage height in ft (backup), backup gage height data certification status, discharge (cfs), discharge data certification status, gage height in ft, gage height data certification status

NY_MeanDailyDischarge.csv
  1. Columns: "agency_", "cd.......site_no", "datetime", "X104599_00060_00003", "X104599_00060_00003", "Month", "Day", "Year", "Date"
  2. Column Meanings: agency (USGS), USGS gage number, date and time of collection, mean daily discharge (csf), collection approval, Month, Day, Year, Date


Processed Data:

NC_Discharge_NewRiver_PROC.csv
  1. Columns: "Agency", "Site_No", "Discharge_cfs", "Date", "Year", "Month", "Day"
  2. Column Meanings: agency (USGS), USGS gage #, mean daily discharge (cfs), date, year, month, and day
  
NY_DischargeData_Processed.csv
  1. Columns: "Agency", "SiteNumber", "MeanDischarge", "Month", "Date", "Year"
  2. Column Meanings: Agency (USGS), USGS gage number, mean daily discharge (csf), Month, Date, Year


## Scripts and code

None

## Quality assurance/quality control

None
