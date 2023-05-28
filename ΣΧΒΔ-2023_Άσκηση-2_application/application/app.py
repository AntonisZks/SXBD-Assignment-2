# ----- CONFIGURE YOUR EDITOR TO USE 4 SPACES PER TAB ----- #
import lib.pymysql as db
import settings
import sys
import os
import random
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

class LuckyPackage:
    def __init__(self, package_id, cost_per_person, cost_category, cursor):
        self.cursor = cursor
        self.package_id = package_id
        self.cost_per_person = cost_per_person
        self.destinations = self.getDestinations(self.cursor)
        self.cost_category = cost_category

    def getDestinations(self, cursor):
        destinations = []
        cursor.execute(f"""SELECT d.name
                           FROM trip_package tp, trip_package_has_destination tphd, destination d
                           WHERE tp.trip_package_id = tphd.trip_package_trip_package_id
                             AND tphd.destination_destination_id = d.destination_id
                             AND tp.trip_package_id = {self.package_id};""")
        result = cursor.fetchall()
        for i in range(len(result)):
            destinations.append(result[i][0])
        return destinations
    
    def __str__(self):
        result_string = f"[id: {self.package_id}, cost: {self.cost_per_person}, destinations: {self.destinations}, category: {self.cost_category}]"
        return result_string

class LuckyTraveler:
    def __init__(self, traveler_id, name, surname, gender, package):
        self.traveler_id = traveler_id
        self.name = name
        self.surname = surname
        self.gender = gender
        self.package = package

    def __str__(self):
        result_string = f"""Traveler {self.name} {self.surname} has:\n\t id: {self.traveler_id}\n\t gender: {self.gender}\n\t package: {self.package}"""
        return result_string

class Offer:
    def __init__(self, offer_start, offer_end, cost, trip_package_id, description, offer_info_category, cursor):
        self.cursor = cursor
        self.offer_start = offer_start
        self.offer_end = offer_end
        self.cost = cost
        self.trip_package_id = trip_package_id
        self.description = description
        self.offer_info_category = offer_info_category
        self.offer_id = self.getId(self.cursor)
    
    def getId(self, cursor):
        cursor.execute(f"SELECT MAX(o.offer_id) FROM offer o;")
        resent_id = cursor.fetchone()[0]
        return resent_id + 1

def getRandomTravelersData(N, cursor):
    # Select all the travelers data that exist
    cursor.execute("SELECT t.traveler_id, t.name, t.surname, t.gender FROM traveler t;")
    travelers_data = list(cursor.fetchall())

    # Select N random travelers
    random_travelers_data = random.sample(travelers_data, int(N))

    return random_travelers_data

def getTravelersPackagesData(cursor, traveler_id, packages_ids_and_costs):
    # Select all the packages ids and costs that the traveler has traveled before
    cursor.execute(f"""SELECT DISTINCT tp.trip_package_id, tp.cost_per_person
                        FROM trip_package tp, reservation r, traveler t
                        WHERE r.offer_trip_package_id = tp.trip_package_id
                            AND r.Customer_id = {traveler_id}
                        ORDER BY tp.trip_package_id;""")
    traveler_packages_ids_and_costs = list(cursor.fetchall())

    # Choose some packages that he didn't travel before
    valid_traveler_packages_ids_and_costs = [data for data in packages_ids_and_costs if data not in traveler_packages_ids_and_costs]

    return valid_traveler_packages_ids_and_costs

def fixCost(cost, cursor, traveler_id):
    # Select the number of reservations the traveler has made
    cursor.execute(f"""SELECT COUNT(r.Reservation_id) AS reservations
                        FROM traveler t, reservation r
                        WHERE r.Customer_id = t.traveler_id
                          AND t.traveler_id = {traveler_id}
                        GROUP BY t.traveler_id;""")
    traveler_reservations_tuple = cursor.fetchall()

    if len(traveler_reservations_tuple) > 0:
        traveler_reservations = traveler_reservations_tuple[0][0]
    else:
        traveler_reservations = 0

    # Fix the cost according to the traveler reservations
    if traveler_reservations > 1:
        cost = 0.75*cost
        return True
    return False

def giveAway(N):
    # Create a new connection
    database = connection()
    # Create a cursor on the connection
    cursor = database.cursor()

    # Get N random travelers from the travelers table
    random_travelers_data = getRandomTravelersData(N, cursor)

    # Select all the packages ids and costs that exist
    cursor.execute("SELECT tp.trip_package_id, tp.cost_per_person FROM trip_package tp;")
    packages_data = list(cursor.fetchall())

    # Create a list for the final packages ids and costs
    final_packages_data = []

    # Define a list for all the traveleres
    lucky_travelers = []

    # Define the return list
    give_away_list = []

    # For each traveler choose a package with the appropriate criteria
    for i in range(len(random_travelers_data)):
        # First select all the valid packages (packages that the traveler hasn't traveled before)
        traveler_packages_data = getTravelersPackagesData(cursor, random_travelers_data[i][0], packages_data)

        # Check if others traveler has the same package
        while True:
            # Select a random package
            random_package_data = traveler_packages_data[random.randint(0, len(traveler_packages_data)-1)]

            # Checking if the selected package has already been selected
            if random_package_data not in final_packages_data:
                final_packages_data.append(list(random_package_data))
                break
        
        # Fix the costs for each package if appropriate
        if fixCost(final_packages_data[i][1], cursor, random_travelers_data[i][0]):
            final_packages_data[i].append("group-discount")
        else:
            final_packages_data[i].append("full-price")            
        final_packages_data[i] = tuple(final_packages_data[i])

        # Creating the Lucky package
        lucky_package = LuckyPackage(final_packages_data[i][0], final_packages_data[i][1], final_packages_data[i][2], cursor)

        # Adding the traveler to the lucky travelers list
        lucky_travelers.append(LuckyTraveler(random_travelers_data[i][0], 
                                             random_travelers_data[i][1], 
                                             random_travelers_data[i][2],
                                             random_travelers_data[i][3], 
                                             lucky_package))
        
        # Create a new offer
        new_offer = Offer("2023-06-15", "2023-08-15", 
                          lucky_package.cost_per_person, 
                          lucky_package.package_id, 
                          "Happy traveler tour", 
                          lucky_package.cost_category,
                          cursor)
    
        # Insert the new offer into the offers table
        cursor.execute(f"""INSERT INTO offer VALUES({new_offer.offer_id}, 
                                                   '{new_offer.offer_start}', 
                                                   '{new_offer.offer_end}', 
                                                   {new_offer.cost}, 
                                                   '{new_offer.description}', 
                                                   {new_offer.trip_package_id}, 
                                                   '{new_offer.offer_info_category}');""")
        database.commit()

        # Creating the paragraph for each traveler
        traveler = lucky_travelers[i]
        gender_message = 'Mr' if traveler.gender == 'male' else 'Ms'
        destinations = ""
        for i in range(len(lucky_package.destinations)):
            if i == 0:
                destinations += f"{lucky_package.destinations[i]}, "
            elif i == len(lucky_package.destinations) - 1:
                destinations += f" and {lucky_package.destinations[i]}"
            else:
                destinations += f"{lucky_package.destinations[i]}, "
        paragraph = (f"""Congratulations {gender_message} {traveler.name} {traveler.surname}! Pack your bags and get ready to enjoy the {new_offer.description}! At ART TOUR travel we acknowledge you as a valued customer and we’ve selected the most incredible tailor-made travel package for you. We offer you the chance to travel to {destinations}  at the incredible price of {new_offer.cost}. Our offer ends on {new_offer.offer_end}. Use code {new_offer.offer_id} to book your trip. Enjoy these holidays that you deserve so much!""",)
        give_away_list.append(paragraph)
        
    give_away_list.insert(0, ("Lucky Travelers Day!",))
    return give_away_list
