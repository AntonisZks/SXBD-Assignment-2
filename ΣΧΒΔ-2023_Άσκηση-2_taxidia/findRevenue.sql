-- Query 2: findRevenue
SELECT tab.travel_agency_branch_id, r.Reservation_id, tp.trip_package_id, tp.cost_per_person
FROM reservation r
	JOIN travel_agency_branch tab ON r.travel_agency_branch_id = tab.travel_agency_branch_id
    JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id;
    
SELECT tp.trip_package_id, COUNT(r.Reservation_id)
FROM reservation r
	JOIN travel_agency_branch tab ON r.travel_agency_branch_id = tab.travel_agency_branch_id
    JOIN trip_package tp ON r.offer_trip_package_id = tp.trip_package_id
GROUP BY tp.trip_package_id;