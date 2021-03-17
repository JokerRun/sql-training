create table Rides
(
    rideId   BIGINT,
    taxiId   BIGINT,
    isStart  BOOLEAN,
    lon      FLOAT,
    lat      FLOAT,
    rideTime TIMESTAMP(3),
    psgCnt   INT int not null
);


-- GROUP BY windows aggregation
-- Windowed Ride Count
-- count the number of arriving and departing rides per area in a window of 5 minutes.
-- We are only interested in events that start or end in New York City
-- and areas with at least 5 arriving or departing rides.
-- 1. start or end in New York City
create temporary view ride_with_nyc as
select rideId, taxiId, isStart, toareaid(lon, lat) as area, rideTime, psgCnt
from Rides
where isinnyc(lon, lat);
-- 2. per area in a window of 5 minutes at least 5
select area, tumble_start(rideTime, interval '5' minute) as start_at, count(*) as cnt
from ride_with_nyc
group by area, tumble(rideTime, interval '5' minute)
having count(*) > 5;



-- OVER window aggregation
-- Areas with Leaving People
-- In this exercise we want to return the areas from which more than 10 people left by taxi in the last 10 minutes.
-- Return for each departure (start) event the area id, the timestamp, and the number of people that left the area in the last 10 minutes, if more than 10 people left.
-- We are only interested in rides that depart from New York City.
-- 1.depart from New York City
create temporary view rides_left_nyc as
select rideId, taxiId, isStart, toareaid(lon, lat) as area, rideTime, psgCnt
from Rides
where isStart
  and isinnyc(lon, lat);
-- 2.left by taxi in the last 10 minutes.
create temporary view rides_left_nyc_ten_min as
select rideId, taxiId, isStart, area, rideTime, sum(psgCnt) over w as peopleCnt
from rides_left_nyc
    window w as (partition by area order by rideTime range between interval '10' minute preceding and current row )
;
-- 3.more than 10 people
select *
from rides_left_nyc_ten_min
where peopleCnt > 10;


-- Combining Temporal and Materializing Operations
-- Average Number of Persons Leaving an Area Per Hour
-- compute for each area in New York City
-- the average number of persons that are leaving the area per hour.
-- For simplicity let's assume that all rides start in another area in which they end.

-- 离开
create temporary view leving_nyc_ride as
select rideId,
       taxiId,
       isStart,
       toareaid(lon, lat) as area,
       rideTime,
       psgCnt
from Rides
where isinnyc(lon, lat)
  and isStart
;
create temporary view per_hourly_leaving_rides as
select area                                      as area,
       tumble_start(rideTime, interval '1' hour) as hr,
       sum(psgCnt)                                 as psgSum
from leving_nyc_ride
group by area, tumble(rideTime, interval '1' hour);

select area, avg(psgSum) as avgPsgLeaving
from per_hourly_leaving_rides
group by area;



















