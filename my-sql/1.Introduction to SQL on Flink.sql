create table Rides
(
    rideId   BIGINT,
    taxiId   BIGINT,
    isStart  BOOLEAN,
    lon      FLOAT,
    lat      FLOAT,
    rideTime TIMESTAMP(3),
    psgCnt   INT int not null
)
;

-- Find a Particular Ride
select *
from Rides
where rideId = 123;

-- Cleanse the Rides
--  removing events that do not start or end in New York City.
select *
from Rides
where isinnyc(lon, lat);

-- NYC Rides View
create view nyc_view as
select *
from Rides
where isinnyc(lon, lat);


-- NYC Areas Rides View
create view nyc_area_view as
select rideId, taxiId, toareaid(lon, lat) as area, rideTime, psgCnt
from nyc_view;