import csv
from geopy.geocoders import Nominatim

filename = "facilities.csv"
output_filename = "updated_facilities.csv"
fields = []
rows = []

with open(filename, 'r', newline='', encoding='utf-8') as csvfile:
    csvreader = csv.reader(csvfile)
    fields = next(csvreader)    
    for row in csvreader:
        rows.append(row)

fields.append('Adresa')
fields.append('Sirina')
fields.append('Duzina')

for row in rows:
    postanski_broj = row[4]
    ulica = row[3]
    naselje = row[2]
    adresa = f"{ulica} {naselje} {postanski_broj}"
    row.append(adresa)

geolocator = Nominatim(user_agent="diplomski")

for row in rows:
    adresa = row[6]
    print(f"Geocoding address: {adresa}")
    location = geolocator.geocode(adresa, addressdetails=True)
    if location:
        row.append(location.latitude)
        row.append(location.longitude)
    else:
        row.append(0)
        row.append(0)

with open(output_filename, 'w', newline='', encoding='utf-8') as csvfile:
    csvwriter = csv.writer(csvfile)   
    csvwriter.writerow(fields)
    csvwriter.writerows(rows)
