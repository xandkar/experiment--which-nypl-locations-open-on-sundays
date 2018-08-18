Which NYPL locations are open on Sundays?
=========================================

It was surprisingly-hard to find an answer on nypl.org, which seems to expect
you to click on each location one-by-one... very annoying....

After a few minutes of examining network requests while loading the locations
page (https://www.nypl.org/locations/list) and a few hours of re-reading `man jq`,
I got more or less what I was looking for:

TL;DR:
------
```sh
curl 'https://refinery.nypl.org/api/nypl/locations/v1.0/locations' \
| jq '
    .locations
    | map(select(
            ( .hours.regular
            | map(select(
                   .day == "Sun." and .open != null
               ))
            | length
            ) > 0
        ))
    | map([.name, .street_address, .locality, .region, .contacts.phone, .hours.regular])
    '
```

Going a bit further
-------------------

Now that we can get the more-or-less (though certainly mostly-less) a database
dump of NYPL locations, why not cache it locally and query that instead of
cursing at the webpage? Like, which locations sport a bike rack?


```sh
$ cat uri-api-response-pretty.json \
| jq '
    .locations
    | map(select((._embedded.amenities | map(select(.amenity.name == "Bicycle rack"))) | length > 0 ))
    | map(.name)
    '
[
  "58th Street Library",
  "96th Street Library",
  "Allerton Library",
  "Bloomingdale Library",
  "City Island Library",
  "Countee Cullen Library",
  "Dongan Hills Library",
  "Eastchester Library",
  "Great Kills Library",
  "Hamilton Fish Park Library",
  "Huguenot Park Library",
  "Inwood Library",
  "Kingsbridge Library",
  "New Dorp Library",
  "New York Public Library for the Performing Arts, Dorothy and Lewis B. Cullman Center",
  "Parkchester Library",
  "Pelham Bay Library",
  "Richmondtown Library",
  "Soundview Library",
  "South Beach Library",
  "Spuyten Duyvil Library",
  "St. George Library Center"
]

```

The scripts in this repository show an example - cache data locally and do
something with it - filter and build 2 alternative views - text and html.
