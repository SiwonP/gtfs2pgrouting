CREATE DOMAIN wgs84_lat AS DOUBLE PRECISION CHECK(VALUE >= -90 AND VALUE <= 90);
CREATE DOMAIN wgs84_lon AS DOUBLE PRECISION CHECK(VALUE >= -180 AND VALUE <= 180);

CREATE TABLE agency
(
  agency_id         text UNIQUE NULL,
  agency_name       text NOT NULL,
  agency_url        text NOT NULL,
  agency_timezone   text NOT NULL,
  agency_lang       text NULL,
  agency_phone      text NULL,
  agency_fare_url   text NULL,
  agency_email      text NULL 
);

CREATE TABLE stops
(
  stop_id           text PRIMARY KEY,
  stop_code         text UNIQUE NULL,
  stop_name         text NOT NULL,
  stop_desc         text NULL,
  stop_lat          wgs84_lat NOT NULL,
  stop_lon          wgs84_lon NOT NULL,
  zone_id           text NULL,
  stop_url          text NULL,
  location_type     int NULL,
  parent_station    text NULL,
  stop_timezone     text NULL,
  wheelchair_boarding int NULL,
  level_id          text NULL,
  platform_code     text NULL
);

CREATE TABLE routes
(
  route_id          text PRIMARY KEY,
  agency_id         text NULL REFERENCES agency(agency_id) ON DELETE CASCADE,
  route_short_name  text NOT NULL,
  route_long_name   text NOT NULL,
  route_desc        text NULL,
  route_type        integer NOT NULL CHECK(route_type >= 0 and route_type <= 12),
  route_url         text NULL,
  route_color       text NULL,
  route_text_color  text NULL,
  route_sort_order  int NULL CHECK(route_sort_order > 0),
  continuous_pickup int NULL CHECK(continuous_pickup >= 0 and continuous_pickup <= 3),
  continuous_dropoff int NULL CHECK(continuous_dropoff >= 0 and continuous_dropoff <= 3)
);

CREATE TABLE calendar
(
  service_id        text PRIMARY KEY,
  monday            boolean NOT NULL,
  tuesday           boolean NOT NULL,
  wednesday         boolean NOT NULL,
  thursday          boolean NOT NULL,
  friday            boolean NOT NULL,
  saturday          boolean NOT NULL,
  sunday            boolean NOT NULL,
  start_date        numeric(8) NOT NULL,
  end_date          numeric(8) NOT NULL
);

CREATE TABLE shapes
(
  shape_id          text,
  shape_pt_lat      wgs84_lat NOT NULL,
  shape_pt_lon      wgs84_lon NOT NULL,
  shape_pt_sequence integer NOT NULL,
  shape_dist_traveled double precision NULL,
  PRIMARY KEY (shape_id, shape_pt_sequence)
);

CREATE TABLE trips
(
  route_id          text NOT NULL REFERENCES routes ON DELETE CASCADE,
  service_id        text NOT NULL REFERENCES calendar,
  trip_id           text NOT NULL PRIMARY KEY,
  trip_headsign     text NULL,
  trip_short_name   text NULL,
  direction_id      boolean NULL,
  block_id          text NULL,
  shape_id          text NULL,
  wheelchair_accessible int NULL,
  bikes_allowed     int NULL
);

CREATE TABLE stop_times
(
  trip_id           text NOT NULL REFERENCES trips ON DELETE CASCADE,
  arrival_time      interval NOT NULL,
  departure_time    interval NOT NULL,
  stop_id           text NOT NULL REFERENCES stops ON DELETE CASCADE,
  stop_sequence     integer NOT NULL,
  stop_headsign     text NULL,
  pickup_type       integer NULL CHECK(pickup_type >= 0 and pickup_type <=3),
  drop_off_type     integer NULL CHECK(drop_off_type >= 0 and drop_off_type <=3),
  shape_dist_traveled double precision NULL,
  timepoint         boolean NULL,
  PRIMARY KEY (trip_id, stop_sequence)
);

CREATE TABLE frequencies
(
  trip_id           text NOT NULL REFERENCES trips ON DELETE CASCADE,
  start_time        interval NOT NULL,
  end_time          interval NOT NULL,
  headway_secs      integer NOT NULL
);
