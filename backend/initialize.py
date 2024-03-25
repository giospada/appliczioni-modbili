import requests
from faker import Faker

import random
from datetime import datetime, timedelta

fake = Faker()

# API Base URL
BASE_URL = "https://appliczioni-modbili.vercel.app"#http://localhost:8000"  # Replace this with the actual API URL


NUMBER_OF_USER = 4
NUMBER_OF_ACTIVITY = 2

def signup_user(username, password):
    """Signup a new user."""
    response = requests.post(f"{BASE_URL}/signup", json={"username": username, "password": password})
    return response.json()

def create_activity(token, description, time, position, attributes, numberOfPeople):
    """Create a new activity."""
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.post(f"{BASE_URL}/activities", json={
        "description": description,
        "time": time,
        "position": position,
        "attributes": attributes,
        "numberOfPeople": numberOfPeople
    }, headers=headers)
    return response.json()

def register_activity(token, username, activityId):
    """Register an existing activity."""
    headers = {"Authorization": f"Bearer {token}"}
    response = requests.post(f"{BASE_URL}/activities/register", json={
        "username": username,
        "activityId": activityId
    }, headers=headers)
    return response.json()

# Generate and signup users
users = [{"username": fake.user_name(), "password": fake.password()} for _ in range(NUMBER_OF_USER)]

print('generated users')

tokens = [signup_user(user['username'], user['password'])['access_token'] for user in users]

print('generated tokens')

positions = [
( 44.4878461,11.3751228, "Parco Vincenzo Tanara" ),
( 44.4878461,11.3751228, "Giardini Arcobaleno" ),
( 44.497351,11.386022, "Parco Eugenio Montale, via Scandellara (BO)" ),
( 44.4853122,11.3764531, "Giardino Nino Luccarini, via Felsina (BO)" ),
( 44.5026253,11.3461317, "Parco della Montagnola" ),
( 44.4825995,11.3419118, "Parco di San Michele in Bosco" ),
( 44.5015751,11.3921176, "Parco Vincenzo Tanara" ),
( 44.4884927,11.37479, "Giardino Mario Maragi, via Arcobaleno (BO)" ),
( 44.4743154,11.3952703, "Parco Aquile Randagie" ),
( 44.5069299,11.3630193, "Parco Don Giovanni Bosco" ),
( 44.5099144,11.3734809, "Parco San Donnino, via San Donato (BO)" ),
( 44.4681972,11.4011719, "Parco della Resistenza" ),
( 44.4684883,11.3943287, "Parco Carlo Urbani - Medico medaglia d'oro" ),
( 44.4734054,11.3909682, "Giardino Europa Unita" ),
( 44.4675275,11.3462317, "Parco di Villa Guastavillani via degli Scalini (BO)" ),
( 44.484344,11.3799407, "Parco Wladyslaw Anders" ),
( 44.5019091,11.336289, "Giardino del Cavaticcio" ),
( 44.5129419,11.3507554, "Parco della Zucca" ),
( 44.5114049,11.3309746, "Parco di Villa Angeletti" ),
( 44.5391694,11.3538609, "Parco dei Giardini di via dell'Arcoveggio" ),
( 44.4712189,11.3974931, "Parco dei Cedri" ),
( 44.4774968,11.3734219, "Giardino Lunetta Gamberini" ),
( 44.4998231,11.378675, "Parco Primo Levi, via del Terrapieno (BO)" ),
( 44.5002486,11.3362904, "Parco 11 Settembre 2001" ),
( 44.4674998,11.3867959, "Parco Carlo Urbani" ),
( 44.486899,11.3855091, "Giardino Vittime della Uno Bianca" ),
( 44.4767909,11.326405, "Parco di Villa Ghigi" ),
( 44.5092486,11.3517491, "Parco Artistico Lineare" ),
( 44.5157585,11.3269938, "Parco Andrea Pazienza" ),
( 44.4734204,11.4086441, "Parco Europa" ),
( 44.4720129,11.3938851, "Parco del Cavedone" ),
( 44.4827156,11.3521301, "Giardini Margherita Bologna" ),
( 44.4536044,11.3808697, "Giardino Delle Farfalle" ),
( 44.488732,11.3740575, "Parco giochi giardino arcobaleno" ),
( 44.513579,11.3918382, "Parco Pier Paolo Pasolini" ),
( 44.4698106,11.4069639, "Parco 2 Agosto" ),
( 44.4548855,11.3471484, "Parco di Forte Bandiera (Monte Donato)" ),
( 44.4610825,11.3775014, "Parco Corrado Alvaro via Alberto Mario (BO)" ),
( 44.4869446,11.387654, "Giardino Brigata Partigiana Maiella via Barbacci (BO)" ),
]
"""
script in js for googlemaps downlaod locations


(async () => {
  const elements = document.querySelectorAll('.hfpxzc');
  for (const element of elements) {
    element.click(); // Simulate click
    await new Promise(resolve => setTimeout(resolve, 5000)); // Wait for 1 second
    // Assuming the URL is in the expected format and the tab navigates to the correct URL
    const url = new URL(window.location.href);
    const path = url.pathname;
    const latLngMatch = path.match(/@([\d.-]+),([\d.-]+)/);
    const text = document.querySelector('.DUwDvf').textContent;
    if (latLngMatch) {
      console.log(` ${latLngMatch[1]},${latLngMatch[2]}, "${text}"`);
    } else {
      console.warn('Coordinates not found in URL');
    }
  }
})();
"""

# Create activities for each user
for token in tokens:
    for _ in range(NUMBER_OF_ACTIVITY):
        sport = random.choice(["basketball", "football", "running"])
        time = datetime.now() + timedelta(days=random.randint(0, 7), hours=random.randint(8, 19))
        # position should be replaced with actual data
        choosed = random.randint(0,len(positions)-1)
        position = {"lat": positions[choosed][0], "long": positions[choosed][1]}
        attributes = {"level": "beginner", "price": random.randint(0,10), "sport": sport}
        numberOfPeople = random.randint(1, 7)
        create_activity(token, fake.sentence(), time.isoformat(), position, attributes, numberOfPeople)



