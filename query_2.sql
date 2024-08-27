--This query returns all facilities in the given radius
WITH point_of_interest AS (
    SELECT geom
    FROM point
    WHERE id = 20
)
SELECT
    f.id,
    f.naziv,
    ST_Distance(f.geom, poi.geom) AS distance_meters
FROM
    facility f
CROSS JOIN
    point_of_interest poi
WHERE
    ST_DWithin(f.geom, poi.geom, 400)
ORDER BY
    distance_meters;
