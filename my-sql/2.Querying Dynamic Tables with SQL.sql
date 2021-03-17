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


-- Ride Count per Number of Passengers
select psgCnt, count(*) as rideCnt
from Rides
where isStart
  and isinnyc(lon, lat)
group by psgCnt;


-- Ride Count per Area and Hour of Day

select toareaid(lon, lat) area, isStart, HOUR(rideTime) hourOfDay, count(*) as cnt
from Rides
where isinnyc(lon, lat)
group by toareaid(lon, lat), HOUR(rideTime), isStart
having count(*) >60
;