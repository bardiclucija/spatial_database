CREATE TABLE streets (
    id SERIAL PRIMARY KEY,
    line GEOMETRY(LineString, 4326)
);

CREATE TABLE facility (
    id SERIAL PRIMARY KEY,
    naziv VARCHAR(255),
    zupanija VARCHAR(255),
    naselje VARCHAR(255),
    ulica VARCHAR(255),
    postanski_broj VARCHAR(255),
    vrsta VARCHAR(255),
    adresa VARCHAR(255),
    longitude FLOAT,
    latitude FLOAT
);

CREATE TABLE paths (
    id SERIAL PRIMARY KEY,
    point GEOMETRY(Point, 4326),
);

CREATE TABLE point (
    id SERIAL PRIMARY KEY,
    geom GEOMETRY(Point, 4326),
    hitnost INT
);

COPY facility(naziv, zupanija, naselje, ulica, postanski_broj, vrsta, adresa, latitude, longitude)
FROM 'updated_ustanove.csv'
DELIMITER ','
CSV HEADER;

UPDATE facility
SET urgency = CASE 
    WHEN vrsta IN ('Zavod Za Javno Zdravstvo Zupanije', 'Dislocirana Jedinica Zavoda Za Javno Zdravstvo') THEN 0
    WHEN vrsta IN ('Ljekarna', 'Ljekarnicka Jedinica') THEN 1
    WHEN vrsta IN ('Ambulanta Doma Zdravlja Dislocirana Jedinica', 'Dom Zdravlja', 'Poliklinika', 'Ustanova Za Zdravstvenu Skrb', 'Dislocirani Odjel Spec. Bolnice') THEN 2
    WHEN vrsta IN ('Klinicki Bolnicki Centar', 'Ustanova Za Hitnu Medicinsku Pomoc') THEN 3
    ELSE urgency 
END;

CREATE TABLE edges (
    id SERIAL PRIMARY KEY,
    source INTEGER,
    target INTEGER,
    cost DOUBLE PRECISION,
    geom GEOMETRY(LineString, 4326)
);

WITH line_segments AS (
    SELECT
        (ST_DumpSegments(line)).geom AS segment_geom
    FROM
        streets
),
segment_points AS (
    SELECT
        segment_geom,
        ST_StartPoint(segment_geom) AS start_point,
        ST_EndPoint(segment_geom) AS end_point
    FROM
        line_segments
),
closest_vertices AS (
    SELECT
        sp.segment_geom,
        p1.id AS source,
        p2.id AS target,
        ST_Length(sp.segment_geom) AS cost
    FROM
        segment_points sp,
        paths p1,
        paths p2
    WHERE
        ST_DWithin(sp.start_point, p1.point, 0.0001)
        AND ST_DWithin(sp.end_point, p2.point, 0.0001)
)
INSERT INTO edges (source, target, cost, geom)
SELECT
    source,
    target,
    cost,
    segment_geom
FROM
    closest_vertices;
