-- Query 1: findTrips | trip_package_id: 1, trip_start: 2019-06-01, trip_end: 2022-09-12
SELECT tp.cost_per_person, tp.max_num_participants, count(r.Reservation_id) AS reservations,
	   (tp.max_num_participants - count(r.Reservation_id)) AS empty_seats, tp.trip_start, tp.trip_end
FROM trip_package tp, reservation r
WHERE tp.trip_package_id = 1 AND tp.trip_start >= '2019-06-01' AND tp.trip_start <= '2022-09-12'
	  AND tp.trip_package_id = r.offer_trip_package_id
GROUP BY tp.cost_per_person, tp.max_num_participants, tp.trip_start, tp.trip_end;