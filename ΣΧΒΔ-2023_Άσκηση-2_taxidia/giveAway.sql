SELECT t.traveler_id
FROM traveler t;

SELECT tp.trip_package_id
FROM trip_package tp;

-- traveler_id = 1901
SELECT DISTINCT tp.trip_package_id
FROM trip_package tp, reservation r, traveler t
WHERE r.offer_trip_package_id = tp.trip_package_id
  AND r.Customer_id = 1901;
  
SELECT t.traveler_id, COUNT(r.Reservation_id) AS reservations
FROM traveler t, reservation r
WHERE r.Customer_id = t.traveler_id
  AND t.traveler_id = 1901
GROUP BY t.traveler_id;

SELECT d.name
FROM trip_package tp, trip_package_has_destination tphd, destination d
WHERE tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
  AND tp.trip_package_id = 102
ORDER BY tp.trip_package_id;

SELECT *
FROM offer o;

INSERT INTO offer VALUES(414, '2023-06-15', '2023-06-17', 500, 'A stupid offer', 179, 'A stupid category');

DELETE FROM offer o WHERE o.offer_id = 414;

SELECT *
FROM traveler t; 