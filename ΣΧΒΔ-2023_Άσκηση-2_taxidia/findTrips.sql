SELECT DISTINCT tp.cost_per_person, tp.max_num_participants, 
	   COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
	   e.name, e.surname, tp.trip_start, tp.trip_end
FROM reservation r, travel_agency_branch tab, trip_package tp, employees e, travel_guide tg
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id 
  AND r.offer_trip_package_id = tp.trip_package_id
  AND tab.travel_agency_branch_id = e.employees_AM
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1
  AND tp.trip_start >= '2021-01-01' AND tp.trip_start <= '2021-12-31'
GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, tg.travel_guide_employee_AM, tp.trip_start, tp.trip_end;

SELECT DISTINCT tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, COUNT(r.Reservation_id) AS reservations,
	   (tp.max_num_participants - COUNT(r.Reservation_id)) AS empty_seats, tp.trip_start, tp.trip_end
FROM travel_agency_branch tab, reservation r, trip_package tp
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id
  AND r.offer_trip_package_id = tp.trip_package_id
  AND tab.travel_agency_branch_id = 1 AND tp.trip_start >= '2020-01-01' AND tp.trip_start <= '2020-12-31'
GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, tp.trip_start, tp.trip_end;
  
SELECT DISTINCT e.name, e.surname
FROM travel_agency_branch tab, reservation r, trip_package tp, trip_package_has_destination tphd, 
     destination d, tourist_attraction ta, guided_tour gt, travel_guide tg, employees e
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id
  AND r.offer_trip_package_id = tp.trip_package_id
  AND tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
  AND ta.destination_destination_id = d.destination_id
  AND gt.tourist_attraction_id = ta.tourist_attraction_id
  AND tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1 AND tp.trip_package_id = 63;
  
SELECT DISTINCT e.name, e.surname
FROM guided_tour gt, employees e, travel_agency_branch tab, reservation r
WHERE gt.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = e.travel_agency_branch_travel_agency_branch_id
  AND tab.travel_agency_branch_id = r.travel_agency_branch_id
  AND r.offer_trip_package_id = gt.trip_package_id
  AND tab.travel_agency_branch_id = 1 AND gt.trip_package_id = 63;
  
SELECT DISTINCT tab.travel_agency_branch_id, tp.trip_package_id, e.name, e.surname
FROM travel_agency_branch tab, employees e, travel_guide tg, reservation r, trip_package tp
WHERE e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = r.travel_agency_branch_id
  AND r.offer_trip_package_id = tp.trip_package_id
  AND tab.travel_agency_branch_id = 3;
  
SELECT DISTINCT tab.travel_agency_branch_id, e.name, e.surname
FROM travel_agency_branch tab, employees e, travel_guide tg
WHERE tab.travel_agency_branch_id = e.travel_agency_branch_travel_agency_branch_id
  AND e.employees_AM = tg.travel_guide_employee_AM;
  
SELECT DISTINCT tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, COUNT(r.Reservation_id) AS reservations,
				(tp.max_num_participants - COUNT(r.Reservation_id)) AS empty_seats, e.name, e.surname, tp.trip_start, tp.trip_end
FROM travel_agency_branch tab, reservation r, trip_package tp, employees e, travel_guide tg
WHERE tab.travel_agency_branch_id = r.travel_agency_branch_id
  AND r.offer_trip_package_id = tp.trip_package_id
  AND e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1 
  AND tp.trip_start >= '2020-01-01' AND tp.trip_start <= '2020-12-31'
GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, e.name, e.surname, tp.trip_start, tp.trip_end;