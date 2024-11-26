#Data Warehousing Project designed by IBM
# "The data set in this assignment is not a real-life data set. It was programmatically created for this assignment purpose."


CREATE SCHEMA solidwastedata;
USE solidwastedata;
#As a BI Analyst for a solid waste management company in Brazil, which operates hundreds of trucks to collect and recycle solid waste, I am tasked with creating a data warehouse. 
#The company would like to create a data warehouse so that it can create reports like:
#Total waste collected per year per city
#Total waste collected per month per city
#Total waste collected per quarter per city
#Total waste collected per year per trucktype
#Total waste collected per trucktype per city
#Total waste collected per trucktype per station per city


# I'll start by designing a dimension table named MyDimDate with a granularity to the day, allowing for detailed time-based analyses. This table will include the following columns:
#date:id, dayofmonth, monthnumber, monthname, yearnumber, qrtr, dayname. Trying to avoid syntax collision using extended column names
CREATE TABLE MyDimDate(
dateid INT PRIMARY KEY NOT NULL,
dayofmonth INT NOT NULL,
monthname VARCHAR(20) NOT NULL,
yearnumber INT NOT NULL,
qrtr INT  NOT NULL,
dayname VARCHAR(20) NOT NULL
);


#Design the MyDimWaste table that will have information on the individual trips broken down
#tripnumber, wastetype, wastecollectiontons, collectionzone, city, dateinmonth, trucktype,station
CREATE TABLE MyDimWaste(
tripnumber INT PRIMARY KEY NOT NULL,
wastetype VARCHAR(50) NOT NULL,
wastecollectiontons DECIMAL (10,2) NOT NULL,
collectionzone VARCHAR(50) NOT NULL,
city VARCHAR(50) NOT NULL,
dateinmonth DATE NOT NULL,
trucktype VARCHAR(25) NOT NULL,
station VARCHAR(25) NOT NULL
);


#Design the MyDimZone, I dont think this will be heavily populated
#I'll use zoneid, zonename,city,state
CREATE TABLE MyDimZone(
zoneid INT PRIMARY KEY NOT NULL,
zonename VARCHAR(50) NOT NULL,
city VARCHAR(25) NOT NULL,
state VARCHAR(25) NOT NULL
);


#Create the fact table, 
#tripid, tripnumber,zoneid, wastecollectedtons, collectiondate, trucktype, station

#To create my foreign keys I need to match my fact table to MyDimDate with an actual date column which i forgot to include.
ALTER TABLE MyDimDate ADD datedate DATE NOT NULL;
#to fix ill create a date column that I can reference to collectiondate in my fact table.


#After adding the column I ran into an index error, saying an index on datedate column is required
CREATE INDEX idx_datedate ON MyDimDate (datedate);
#first time running into index error, the best explanation I think of is table of content in a book.
#because datedate isnt a primary key MySQL prompts to index the fk so it can locate easier.

CREATE TABLE MyFactTrips(
tripid INT PRIMARY KEY NOT NULL,
tripnumber INT NOT NULL,
zoneid INT NOT NULL,
wastecollectedtons DECIMAL(10,2) NOT NULL,
collectiondate DATE NOT NULL,
trucktype VARCHAR(25) NOT NULL,
station VARCHAR(25) NOT NULL,
CONSTRAINT fk_tripnumber foreign key (tripnumber) references MyDimWaste(tripnumber),
CONSTRAINT fk_zoneid foreign key (zoneid) references MyDimZone(zoneid),
CONSTRAINT fk_collectiondate foreign key (collectiondate) references MyDimDate(datedate)
);


# "After the initial schema design, you were told that due to operational issues, data could not be collected in the format initially planned. 
# This implies that the previous tables (MyDimDate, MyDimWaste, MyDimZone, MyFactTrips) in the Project database and their associated attributes are no longer applicable to the current design. 
#The company has now provided data in CSV files with new tables DimTruck and DimStation as per the new design."
#IBM are bullies, good practice though

CREATE TABLE DimDate (
    dateid INT PRIMARY KEY NOT NULL,
    date DATE NOT NULL,
    year INT NOT NULL,
    quarter INT NOT NULL,
    quartername VARCHAR(10) NOT NULL,
    month INT NOT NULL,
    monthname VARCHAR(20) NOT NULL,
    day INT NOT NULL,
    weekday INT NOT NULL,
    weekdayname VARCHAR(20) NOT NULL
);


CREATE TABLE DimTruck (
truckid INT PRIMARY KEY NOT NULL,
TruckType VARCHAR(25) NOT NULL
);


CREATE TABLE DimStation (
stationid INT PRIMARY KEY NOT NULL,
City VARCHAR(20) NOT NULL
);


CREATE TABLE FactTrips (
    tripid INT PRIMARY KEY NOT NULL,
    dateid INT NOT NULL,
    stationid INT NOT NULL,
    truckid INT NOT NULL,
    wastecollected DECIMAL(10, 2) NOT NULL
);

#used import wizard to import csv file for all 4 tables
#If you see the amount of columns I designed I think i looked into it too much comparitively
#Now I need to asign foreign keys
ALTER TABLE facttrips
ADD constraint fk_dateid FOREIGN KEY (dateid) references dimdate(dateid);

ALTER TABLE facttrips 
ADD constraint fk_stationid FOREIGN KEY (stationid) references dimstation(stationid);

ALTER TABLE facttrips
ADD constraint fk_truckid foreign key (truckid) REFERENCES dimtruck(truckid);

#Have a look
SELECT * FROM solidwastedata.dimdate limit 5;
SELECT * FROM solidwastedata.dimtruck limit 5;
SELECT * FROM solidwastedata.dimstation limit 5;
SELECT * FROM solidwastedata.facttrips limit 5;



#Create a "simple" grouping sets query, in MySQL its union not set like postgre like I learnt
SELECT stationid,
NULL AS trucktype,
SUM(wastecollected) AS totalwastecollected
FROM facttrips
GROUP BY stationid
UNION ALL
SELECT 
NULL AS stationid,
t.trucktype,
SUM(f.wastecollected) AS totalwastecollected
FROM facttrips f
JOIN DimTruck t ON f.tripid = t.truckid
GROUP BY t.trucktype;
# I'm not sure if 20mins to make this as first time is appropriate
# this is also my first time using the table aliases, abit confusing at first


#Now create a roll up query using column years, city, stationid & total waste collected
#using the table aliases is important for this one as facttrips & dimstation have stationid
SELECT dd.year, ds.city, ft.stationid, SUM(ft.wastecollected) AS totalwastecollected
FROM facttrips ft
JOIN dimdate dd ON ft.dateid = dd.dateid
JOIN DimStation ds ON ft.stationid = ds.stationid
GROUP BY year, city, stationid
WITH ROLLUP;



#create a meterial view using columns city, stationid, trucktype & max waste collected
CREATE TABLE max_waste_stats AS
SELECT 
    ds.city, 
    ft.stationid, 
    dt.trucktype, 
    MAX(ft.wastecollected) AS maxwastecollected
FROM 
    facttrips ft
JOIN 
    dimstation ds ON ft.stationid = ds.stationid
JOIN 
    dimtruck dt ON ft.truckid = dt.truckid
GROUP BY 
    ds.city, 
    ft.stationid, 
    dt.trucktype;
SELECT * FROM solidwastedata.max_waste_stats

#estimate time taken = 1 hour 20 minutes. Not bad for first attempt?