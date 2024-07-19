--This query returns path to the closest facility from a given point
WITH point_of_interest AS (
    SELECT geom, hitnost
    FROM point
    WHERE id = 19
),
closest_facility AS (
    SELECT
        f.id AS facility_id,
        f.geom AS facility_geom,
        ST_Distance(f.geom, poi.geom) AS distance_to_point
    FROM
        facility f,
        point_of_interest poi
	WHERE (poi.hitnost IS NULL OR f.hitnost = poi.hitnost)
    ORDER BY
        ST_Distance(f.geom, poi.geom)
    LIMIT 1
),
closest_point_to_given_point AS (
    SELECT
        p.id AS path_id,
        p.point AS path_geom,
        ST_Distance(p.point, poi.geom) AS distance_to_point
    FROM
        paths p,
        point_of_interest poi
    ORDER BY
        ST_Distance(p.point, poi.geom)
    LIMIT 1
),
closest_point_to_facility AS (
    SELECT
        p.id AS path_id,
        p.point AS path_geom,
        ST_Distance(p.point, cf.facility_geom) AS distance_to_facility
    FROM
        paths p,
        closest_facility cf
    ORDER BY
        ST_Distance(p.point, cf.facility_geom)
    LIMIT 1
)
SELECT 
    dij.seq, 
    dij.path_seq, 
    dij.node, 
    dij.edge, 
    dij.cost, 
    dij.agg_cost, 
    e.geom
FROM pgr_dijkstra(
    'SELECT id, source, target, cost FROM edges',
    (SELECT path_id FROM closest_point_to_given_point),
    (SELECT path_id FROM closest_point_to_facility), false
) AS dij
JOIN edges e ON dij.edge = e.id;
