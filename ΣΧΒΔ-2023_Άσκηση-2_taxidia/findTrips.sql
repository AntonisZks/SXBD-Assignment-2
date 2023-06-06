#Δίνονται ως όρισμα ο κωδικός ενός υποκαταστήματος και δύο ημερομηνίες. Για τα
#ταξίδια (trip) που διοργανώνονται από το υποκατάστημα του οποίου δόθηκε ο κωδικός,
#και των οποίων η ημερομηνία αναχώρησης είναι μέσα στο διάστημα που δόθηκε ως
#όρισμα, θα επιστρέφονται τα εξής:
#Κόστος ταξιδιού (cost_per_person), μέγιστες θέσεις (max_num_participants), σύνολο
#κρατήσεων (reservations), κενές θέσεις (max_num_participants – σύνολο κρατήσεων),
#επώνυμο και όνομα οδηγού, επώνυμο και όνομα ξεναγού (πχ 'Leuschke Antonia') ,
#ημερομηνία αναχώρησης και επιστροφής.

SELECT DISTINCT tp.cost_per_person, tp.max_num_participants, 
	   COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
	   e.name, e.surname, tp.trip_start, tp.trip_end
FROM reservation r, travel_agency_branch tab, trip_package tp, employees e, travel_guide tg, guided_tour gt
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id 
  AND r.offer_trip_package_id = tp.trip_package_id
  AND tp.trip_package_id = gt.trip_package_id
  AND tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1
  AND tp.trip_start >= '2022-01-01' AND tp.trip_start <= '2022-12-31'
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
FROM travel_agency_branch tab, reservation r, trip_package tp, guided_tour gt, employees e
WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id
  AND r.offer_trip_package_id = tp.trip_package_id
  AND gt.trip_package_id = tp.trip_package_id
  AND gt.travel_guide_employee_AM = e.employees_AM
  AND tab.travel_agency_branch_id = 1 AND tp.trip_package_id = 63;