-- Query 3: bestClient |
SELECT traveler_id as client, city, country, tourist_attraction
FROM
	(
	SELECT t.traveler_id as traveler_id, r.Reservation_id as travelers_reservations_id
	FROM reservation r 
		JOIN traveler t ON r.Customer_id = t.traveler_id
	ORDER BY t.traveler_id
    ) travels_reserevations JOIN
    (
    SELECT r.Reservation_id as trips_reservations_id, tp.trip_package_id as trip_package_id
	FROM reservation r 
		JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
	ORDER BY r.Reservation_id
    ) reservations_trips ON travels_reserevations.travelers_reservations_id = reservations_trips.trips_reservations_id JOIN
    (
    SELECT tp.trip_package_id as destinations_trip_package_id, d.name as city, d.country, ta.name as tourist_attraction
	FROM trip_package_has_destination tphd
		JOIN trip_package tp ON tphd.trip_package_trip_package_id = tp.trip_package_id
		JOIN destination d ON tphd.destination_destination_id = d.destination_id
        JOIN tourist_attraction ta ON ta.destination_destination_id = d.destination_id
	ORDER BY tp.trip_package_id
    ) trips_destinations ON reservations_trips.trip_package_id = trips_destinations.destinations_trip_package_id;

SELECT cities_traveler_id AS traveler_id, name AS first_name, surname AS last_name, countries AS total_countries_visited, cities AS total_cities_visited
FROM
	(
	SELECT t.traveler_id AS cities_traveler_id, t.name, t.surname, COUNT(d.name) as cities
	FROM reservation r JOIN traveler t ON r.Customer_id = t.traveler_id
		JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
		JOIN trip_package_has_destination tphd ON tphd.trip_package_trip_package_id = tp.trip_package_id
		JOIN destination d ON tphd.destination_destination_id = d.destination_id
	GROUP BY traveler_id
	) travelers_cities JOIN
    (
    SELECT traveler_id AS countries_traveler_id, COUNT(country) AS countries
	FROM
		(
		SELECT DISTINCT t.traveler_id, d.country
		FROM reservation r JOIN traveler t ON r.Customer_id = t.traveler_id
			JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
			JOIN trip_package_has_destination tphd ON tphd.trip_package_trip_package_id = tp.trip_package_id
			JOIN destination d ON tphd.destination_destination_id = d.destination_id
		) travelers_countries
	GROUP BY traveler_id
    ) travelers_countries ON travelers_cities.cities_traveler_id = travelers_countries.countries_traveler_id;