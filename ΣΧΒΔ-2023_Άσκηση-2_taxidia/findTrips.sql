-- Query 1: findTrips | trip_package_id: 1, trip_start: 2019-06-01, trip_end: 2022-09-12
SELECT tp.cost_per_person, tp.max_num_participants, 
	   COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
       CONCAT(e.name, ' ', e.surname) AS driver, tp.trip_start, tp.trip_end
FROM reservation r 
	 JOIN travel_agency_branch tab ON r.travel_agency_branch_id = tab.travel_agency_branch_id
	 JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
     JOIN employees e ON e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
     JOIN drivers d ON d.driver_employee_AM = e.employees_AM
WHERE tab.travel_agency_branch_id = 1 AND tp.trip_start BETWEEN '2019-06-01' AND '2022-09-12'
GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, d.driver_employee_AM, tp.trip_start, tp.trip_end