-- Query 3: bestClient |
SELECT DISTINCT traveler_id as client, city, country, tourist_attraction
FROM
	(
	SELECT t.traveler_id as traveler_id, r.Reservation_id as travelers_reservations_id
	FROM reservation r, traveler t
    WHERE r.Customer_id = t.traveler_id
	ORDER BY t.traveler_id
    ) travels_reserevations,
    (
    SELECT r.Reservation_id as trips_reservations_id, tp.trip_package_id as trip_package_id
	FROM reservation r, trip_package tp
    WHERE r.offer_trip_package_id = tp.trip_package_id
	ORDER BY r.Reservation_id
    ) reservations_trips,
    (
    SELECT tp.trip_package_id as destinations_trip_package_id, d.name as city, d.country, ta.name as tourist_attraction
	FROM trip_package_has_destination tphd, trip_package tp, destination d, tourist_attraction ta
	WHERE tphd.trip_package_trip_package_id = tp.trip_package_id
      AND tphd.destination_destination_id = d.destination_id
      AND ta.destination_destination_id = d.destination_id
	ORDER BY tp.trip_package_id
    ) trips_destinations
WHERE travels_reserevations.travelers_reservations_id = reservations_trips.trips_reservations_id
  AND reservations_trips.trip_package_id = trips_destinations.destinations_trip_package_id
HAVING client = 1741;



-- Traveler Countries
SELECT DISTINCT t.traveler_id, d.country
FROM reservation r, traveler t, trip_package tp, trip_package_has_destination tphd, destination d
WHERE r.Customer_id = t.traveler_id AND r.offer_trip_package_id = tp.trip_package_id
  AND tphd.trip_package_trip_package_id = tp.trip_package_id
  AND tphd.destination_destination_id = d.destination_id
HAVING t.traveler_id = 1741;

-- Traveler cities
SELECT DISTINCT t.traveler_id, d.destination_id
FROM reservation r, traveler t, trip_package tp, trip_package_has_destination tphd, destination d
WHERE r.Customer_id = t.traveler_id AND r.offer_trip_package_id = tp.trip_package_id
  AND tphd.trip_package_trip_package_id = tp.trip_package_id AND tphd.destination_destination_id = d.destination_id
HAVING t.traveler_id = 1741;

-- Destination's attractions
SELECT DISTINCT t.traveler_id, ta.name
FROM traveler t, reservation r, trip_package tp, guided_tour gt, tourist_attraction ta
WHERE r.Customer_id = t.traveler_id
  AND r.offer_trip_package_id = tp.trip_package_id
  AND gt.trip_package_id = tp.trip_package_id
  AND ta.tourist_attraction_id = gt.tourist_attraction_id
HAVING t.traveler_id = 1741;

-- Traveler name and surname
SELECT t.name, t.surname
FROM traveler t
WHERE t.traveler_id = 1741;



SELECT t.name, t.surname, t.traveler_id, SUM(o.cost) AS total_cost
FROM traveler t, reservation r, trip_package tp, offer o
WHERE r.Customer_id = t.traveler_id
AND r.offer_trip_package_id = tp.trip_package_id
AND r.offer_id = o.offer_id
GROUP BY t.traveler_id
ORDER BY total_cost DESC;