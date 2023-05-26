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