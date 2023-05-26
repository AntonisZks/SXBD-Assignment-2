# ----- CONFIGURE YOUR EDITOR TO USE 4 SPACES PER TAB ----- #
import lib.pymysql as db
import settings
import sys
import os
sys.path.append(os.path.join(os.path.split(
    os.path.abspath(__file__))[0], 'lib'))


def connection():
    ''' User this function to create your connections '''
    con = db.connect(
        settings.mysql_host,
        settings.mysql_user,
        settings.mysql_passwd,
        settings.mysql_schema)

    return con


def findTrips(x, a, b):
    # Create a new connection
    database = connection()
    # Create a cursor on the connection
    cursor = database.cursor()

    q1 = f"""SELECT tp.cost_per_person, tp.max_num_participants, 
	            COUNT(*) as reservations, (tp.max_num_participants - COUNT(*)) as empty_seats,
	            CONCAT(e.name, ' ', e.surname) AS travel_guide, tp.trip_start, tp.trip_end
            FROM reservation r, travel_agency_branch tab, trip_package tp, employees e, travel_guide tg
            WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id 
                AND r.offer_trip_package_id = tp.trip_package_id
                AND e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
                AND tg.travel_guide_employee_AM = e.employees_AM
                AND tab.travel_agency_branch_id = {x} AND tp.trip_start >= '{a}' AND tp.trip_start <= '{b}'
            GROUP BY tp.trip_package_id, tp.cost_per_person, tp.max_num_participants, tg.travel_guide_employee_AM, tp.trip_start, tp.trip_end;"""
    try:
        cursor.execute(q1)
        results = list(cursor.fetchall())
        results.insert(0, ("cost_per_person", "max_num_participants", "reservations", "empty_seats", "travel_guide", "trip_start", "trip_end"))
        return results
    except:
        print("Error: unable to fetch data")

def findRevenue(x):
    # Create a new connection
    database = connection()
    # Create a cursor on the connection
    cursor = database.cursor()

    q2 = f"""SELECT DISTINCT incomes_travel_agency_branch_id as travel_agency_branch_id, reservations AS total_num_reservations, SUM(income) AS total_income,
                 num_of_employees, total_salary
             FROM (
                 -- Returns a table with all branches and their incomes
                 SELECT tab.travel_agency_branch_id AS incomes_travel_agency_branch_id, COUNT(r.Reservation_id)*tp.cost_per_person as income
                 FROM reservation r, travel_agency_branch tab, trip_package tp
                 WHERE r.travel_agency_branch_id =  tab.travel_agency_branch_id AND r.offer_trip_package_id = tp.trip_package_id
                 GROUP BY incomes_travel_agency_branch_id, tp.cost_per_person
                 ) travel_agency_branch_incomes,
                 (
                 -- Returns a table all braches with their number of reservations
                 SELECT tab.travel_agency_branch_id AS reservations_travel_agency_branch_id, COUNT(r.Reservation_id) as reservations
                 FROM reservation r, travel_agency_branch tab
                 WHERE r.travel_agency_branch_id = tab.travel_agency_branch_id
                 GROUP BY reservations_travel_agency_branch_id
                 ) travel_agency_branch_reservations,
                 (
                 -- Returns a table with all branches and their number of employees and total salary
                 SELECT tab.travel_agency_branch_id AS employees_travel_agency_brach_id, COUNT(e.employees_AM) AS num_of_employees, SUM(e.salary) AS total_salary
                 FROM employees e, travel_agency_branch tab
                 WHERE e.travel_agency_branch_travel_agency_branch_id = tab.travel_agency_branch_id
                 GROUP BY employees_travel_agency_brach_id
                 ) travel_agency_branch_employees
             WHERE travel_agency_branch_incomes.incomes_travel_agency_branch_id = travel_agency_branch_reservations.reservations_travel_agency_branch_id
             AND reservations_travel_agency_branch_id = travel_agency_branch_employees.employees_travel_agency_brach_id
             GROUP BY incomes_travel_agency_branch_id
             ORDER BY total_income {x};"""
    
    try:
        cursor.execute(q2)
        results = list(cursor.fetchall())
        results.insert(0, ("travel_agency_branch_id", "total_num_reservations", "total_income", "total_num_employees", "total_salary"))
        return results
    except:
        print("Error: unable to fetch data")


def bestClient(x):
    # Create a new connection
    database = connection()
    # Create a cursor on the connection
    cursor = database.cursor()

    best_client_query = """SELECT t.name, t.surname, t.traveler_id, SUM(tp.cost_per_person) AS total_cost
                          FROM traveler t, reservation r, trip_package tp
                          WHERE r.Customer_id = t.traveler_id
                            AND r.offer_trip_package_id = tp.trip_package_id
                          GROUP BY t.traveler_id
                          ORDER BY total_cost DESC
                          LIMIT 1;"""
    
    try:
        cursor.execute(best_client_query)
        best_client_data = list(cursor.fetchall())
        best_client_id = best_client_data[0][2]
        
    except:
        print("Error: unable to fetch data")

    countries_and_cities_query = f"""SELECT cities_traveler_id AS traveler_id, name AS first_name, surname AS last_name, countries AS total_countries_visited, cities AS total_cities_visited
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
                                    HAVING traveler_id = {best_client_id};"""

    try:
        cursor.execute(countries_and_cities_query)
        countries_and_cities_result = list(cursor.fetchall())
        
    except:
        print("Error: unable to fetch data")
    

    tourist_attractions_query = f"""SELECT DISTINCT traveler_id as client, city, country, tourist_attraction
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
                                    HAVING client = {best_client_id};"""

    try:
        cursor.execute(tourist_attractions_query)
        tourist_attractions_result = list(cursor.fetchall())
        
    except:
        print("Error: unable to fetch data")


    print(best_client_data)
    print(countries_and_cities_result)
    print(tourist_attractions_result)

    result_list = [("first_name", "last_name", "total_countries_visited", "total_cities_visited", "list_of_attractions")]
    for i in range(len(tourist_attractions_result)):
        row = (countries_and_cities_result[0][1], countries_and_cities_result[0][2], countries_and_cities_result[0][3], countries_and_cities_result[0][4], tourist_attractions_result[i][3])
        result_list.append(row)
    
    return result_list

def giveAway(N):
    # Create a new connection
    con = connection()

    # Create a cursor on the connection
    cur = con.cursor()

    return [("string"), ]
