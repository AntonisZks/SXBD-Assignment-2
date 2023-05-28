/* ΜΕΡΟΣ Α */

/*1. Βρείτε τα ονόματα των ξεναγών που έχουν χρησιμοποιηθεί από το πρακτορείο σε όλους τους προορισμούς της Γερμανίας. */
SELECT CONCAT(em.name, ' ', em.surname) as full_name
FROM employees em, travel_guide tg, guided_tour gt, trip_package tp, trip_package_has_destination tphd, destination d
WHERE em.employees_AM = tg.travel_guide_employee_AM 
      AND gt.travel_guide_employee_AM = tg.travel_guide_employee_AM
      AND gt.trip_package_id = tp.trip_package_id
      AND tp.trip_package_id = tphd.trip_package_trip_package_id
      AND tphd.destination_destination_id = d.destination_id
      AND d.country = "Germany"
GROUP BY em.name, em.surname;

/* 2. Βρείτε τους κωδικούς των ξεναγών με περισσότερες από 3 ξεναγήσεις στο έτος 2019.*/
SELECT tg.travel_guide_employee_AM, COUNT(gt.trip_package_id) AS tours
FROM travel_guide tg, guided_tour gt, trip_package tp
WHERE tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
  AND gt.trip_package_id = tp.trip_package_id
  AND tp.trip_start >= '2019-01-01' AND tp.trip_start <= '2019-12-31'
GROUP BY tg.travel_guide_employee_AM
HAVING tours > 3
ORDER BY tg.travel_guide_employee_AM;

/* 3. Βρείτε τον αριθμό των υπαλλήλων που έχει κάθε υποκατάστημα του ταξιδιωτικού πρακτορείου.*/
SELECT tab.travel_agency_branch_id, COUNT(e.employees_AM) AS num_employees
FROM employees e, travel_agency_branch tab
WHERE tab.travel_agency_branch_id = e.travel_agency_branch_travel_agency_branch_id
GROUP BY tab.travel_agency_branch_id;


/* 4. Βρείτε τα ταξιδιωτικά πακέτα και τον αριθμό των κρατήσεων που έγιναν σε αυτά στο διάστημα '2021-01-01' έως '2021-12-31' με προορισμό το Παρίσι.*/
SELECT tp.trip_package_id, COUNT(r.Reservation_id) AS reservations
FROM trip_package tp, reservation r, trip_package_has_destination tphd, destination d
WHERE r.offer_trip_package_id = tp.trip_package_id
  AND tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
  AND r.date >= '2021-01-01' AND r.date <= '2021-12-31'
  AND d.name = 'Paris'
GROUP BY tp.trip_package_id
ORDER BY tp.trip_package_id;

/* 5. Βρείτε τους ξεναγούς που έχουν κάνει όλες τις ξεναγήσεις στην ίδια γλώσσα. */
SELECT e.name, e.surname
FROM
	(
	SELECT travel_guide_tour_languages.travel_guide_employee_AM, 
		   COUNT(travel_guide_tour_languages.travel_guide_language_id) as languages
	FROM
		(
		SELECT DISTINCT tg.travel_guide_employee_AM, gt.travel_guide_language_id
		FROM travel_guide tg, guided_tour gt
		WHERE tg.travel_guide_employee_AM = gt.travel_guide_employee_AM
		ORDER BY tg.travel_guide_employee_AM
		) travel_guide_tour_languages
	GROUP BY travel_guide_employee_AM
	HAVING languages = 1
	) final_travel_guides, employees e
WHERE e.employees_AM = final_travel_guides.travel_guide_employee_AM;

/* 6. Ελέγξτε αν υπήρξε προσφορά μέσα στο έτος 2020 η οποία δεν χρησιμοποιήθηκε από κανέναν. Το ερώτημα θα πρέπει να επιστρέφει ως απάντηση μια σχέση με μια
πλειάδα και μια στήλη με τιμή “yes” ή “no”). Απαγορεύεται η χρήση Flow Control Operators (δηλαδή, if, case, κ.λπ.).*/
SELECT o.offer_id, COUNT(r.Reservation_id) as reservations
FROM reservation r, offer o
WHERE r.offer_id = o.offer_id
	AND r.date >= '2020-01-01' AND r.date <= '2020-12-31'
GROUP BY o.offer_id
HAVING reservations = 0; -- WTF?????????????????????????????????????????????????

/* 7. Βρείτε όλους τους άντρες ταξιδιώτες που έχουν ηλικία από 40 και πάνω κι έχουν κάνει κρατήσεις σε περισσότερα από 3 ταξιδιωτικά πακέτα.*/
SELECT t.traveler_id, t.name, t.surname
FROM traveler t
WHERE t.gender = 'male'
  AND t.age >= 40
  AND (
    SELECT COUNT(DISTINCT r.offer_trip_package_id)
    FROM reservation r
    WHERE r.Customer_id = t.traveler_id
  ) > 3
GROUP BY t.traveler_id, t.name, t.surname;

/* 8. Βρείτε τα ονόματα των ξεναγών που μιλάνε Αγγλικά και τον αριθμό των τουριστικών αξιοθέατων που έχει γίνει κάποια ξενάγηση από τον καθένα ξεναγό στην παραπάνω γλώσσα. */
SELECT tg.travel_guide_employee_AM, e.name, e.surname, gt.trip_package_id, ta.tourist_attraction_id, ta.name
FROM travel_guide tg, travel_guide_has_languages tghl, employees e, guided_tour gt, tourist_attraction ta, trip_package tp
WHERE tg.travel_guide_employee_AM = tghl.travel_guide_employee_AM
  AND tghl.languages_id = (
    SELECT l.languages_id
    FROM languages l
    WHERE l.name = 'English'
  )
  AND tg.travel_guide_employee_AM = e.employees_AM
  AND gt.travel_guide_employee_AM = tg.travel_guide_employee_AM
  AND gt.tourist_attraction_id = ta.tourist_attraction_id
  AND gt.trip_package_id = tp.trip_package_id
ORDER BY tg.travel_guide_employee_AM;

SELECT tg.travel_guide_employee_AM, em.name, em.surname, COUNT(ta.tourist_attraction_id) as num_of_attractions
FROM employees em, travel_guide tg, travel_guide_has_languages tghl, tourist_attraction ta, guided_tour gt
WHERE tg.travel_guide_employee_AM = tghl.travel_guide_employee_AM
  AND    em.employees_AM= tg.travel_guide_employee_AM
  AND tghl.languages_id = (
    SELECT languages_id
    FROM languages l
    WHERE l.name = 'English'
  )
  AND tg.travel_guide_employee_AM=gt.travel_guide_employee_AM
  AND gt.travel_guide_language_id=tghl.languages_id
  AND ta.tourist_attraction_id=gt.tourist_attraction_id
  GROUP BY tg.travel_guide_employee_AM, em.name, em.surname 
  ORDER BY tg.travel_guide_employee_AM ;

/* 9. Βρείτε τη χώρα του "προορισμού" που υπάρχει σε περισσότερα ταξιδιωτικά πακέτα από οποιαδήποτε άλλη. */
SELECT d.country, COUNT(tp.trip_package_id) as trips
FROM trip_package tp, trip_package_has_destination tphd, destination d
WHERE tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
GROUP BY d.country
ORDER BY trips DESC
LIMIT 1;

/* 10.Βρείτε τους κωδικούς των ταξιδιωτικών πακέτων που περιλαμβάνουν όλους τους ταξιδιωτικούς προορισμούς που σχετίζονται με την Ιρλανδία. */
SELECT DISTINCT tp.trip_package_id
FROM trip_package tp, trip_package_has_destination tphd, destination d
WHERE tp.trip_package_id = tphd.trip_package_trip_package_id
  AND tphd.destination_destination_id = d.destination_id
  AND d.country = 'Ireland';