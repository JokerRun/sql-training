create table Rides
(
    rideId   BIGINT,
    taxiId   BIGINT,
    isStart  BOOLEAN,
    lon      FLOAT,
    lat      FLOAT,
    rideTime TIMESTAMP(3), --  *ROWTIME*
    psgCnt   INT int not null
);
create table Fares
(
    rideId    BIGINT,
    payTime   TIMESTAMP(3), -- *ROWTIME*
    payMethod STRING,
    tip       FLOAT,
    toll      FLOAT,
    fare      FLOAT
);
create table DriverChanges
(
    taxiId         BIGINT,
    driverId       BIGINT,
    usageStartTime TIMESTAMP(3) -- *ROWTIME*,
);



-- ## Interval Joins
-- ### Average Tip per Hour of Day
-- Compute the average tip per （hour of day and number of passengers）.
select Hour(r.rideTime) as pt, r.psgCnt, avg(f.tip)
from Rides r
         join Fares f on r.rideId = f.rideId
    and f.payTime between r.rideTime - interval '5' minute and r.rideTime
where not r.isStart
group by Hour(r.rideTime), r.psgCnt
;

-- ### Compute the Ride Duration
-- only interested in rides that start and end in New York City and take less than two hours.

select a.rideId, TIMESTAMPDIFF(minute, l.rideTime, a.rideTime) as durationMin
from Rides l
         join Rides a
              on l.rideId = a.rideId
                  and l.isStart
                  and not a.isStart
                  and a.rideTime between l.rideTime and (l.rideTime + interval '2' hour)
where isinnyc(a.lon, a.lat)
   or isinnyc(l.lon, l.lat)
;

-- ##  Temporal Table Joins

-- ### Identify Drivers with many Passengers
-- Identify all drivers who served in 15 minutes at least 10 passengers.
select b.driverId,
       sum(r.psgCnt)                                     sumPsg,
       tumble_start(r.rideTime, interval '15' minute) as t
from Rides r
   , LATERAL table (drivers(r.rideTime))as b

where r.taxiId = b.taxiId and r.isStart
group by b.driverId, tumble(r.rideTime, interval '15' minute)
having sum(r.psgCnt)>=10
;


-- ## Regular Joins
-- Compute Per-Taxi Statistics
select a.taxiId, driveCnt, psgCnt
from (
         select taxiId, count(1) as driveCnt
         from DriverChanges
         group by taxiId
     ) a
         join(
    select r.taxiId, sum(r.psgCnt) as psgCnt
    from Rides r
    group by r.taxiId) b on a.taxiId = b.taxiId
;











