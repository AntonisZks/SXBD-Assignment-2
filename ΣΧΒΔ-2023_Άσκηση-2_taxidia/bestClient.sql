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
HAVING client = 1901;

SELECT cities_traveler_id AS traveler_id, name AS first_name, surname AS last_name, countries AS total_countries_visited, cities AS total_cities_visited
FROM
	(
	SELECT t.traveler_id AS cities_traveler_id, t.name, t.surname, COUNT(d.name) as cities
	FROM reservation r, traveler t, trip_package tp, trip_package_has_destination tphd, destination d
	WHERE r.Customer_id = t.traveler_id AND r.offer_trip_package_id = tp.trip_package_id
      AND tphd.trip_package_trip_package_id = tp.trip_package_id AND tphd.destination_destination_id = d.destination_id
	GROUP BY traveler_id
	) travelers_cities,
    (
    SELECT traveler_id AS countries_traveler_id, COUNT(country) AS countries
	FROM
		(
		SELECT DISTINCT t.traveler_id, d.country
		FROM reservation r, traveler t, trip_package tp, trip_package_has_destination tphd, destination d
		WHERE r.Customer_id = t.traveler_id AND r.offer_trip_package_id = tp.trip_package_id
          AND tphd.trip_package_trip_package_id = tp.trip_package_id
          AND tphd.destination_destination_id = d.destination_id
		) travelers_countries
	GROUP BY traveler_id
    ) travelers_countries
WHERE travelers_cities.cities_traveler_id = travelers_countries.countries_traveler_id
HAVING traveler_id = 1901;
    

SELECT t.name, t.surname, t.traveler_id, SUM(tp.cost_per_person) AS total_cost
FROM traveler t, reservation r, trip_package tp
WHERE r.Customer_id = t.traveler_id
  AND r.offer_trip_package_id = tp.trip_package_id
GROUP BY t.traveler_id
ORDER BY total_cost DESC
LIMIT 1;