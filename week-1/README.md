# Homework Week 1

## Question 1. Understanding docker first run

```bash
docker run -it --rm python:3.12.8 bash
pip --version
```

Running pip version returns the following output:

pip 24.3.1 from /usr/local/lib/python3.12/site-packages/pip (python 3.12)

Therefore the version is 24.3.1

## Question 2. Understanding Docker networking and docker-compose

Run the docker compose yaml file using the following command

```bash
docker compose up -d
```

Then go to the browser to address localhost:8080 and register a server.

The hostname is `postgres`  and on the connection tab the port is `5432`  username and password `postgres`.

Expand the postgres server and you will see the `ny_taxi` database.

The answer to question 2 is therefore `- postgres:5432`.

```bash
wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/green/green_tripdata_2019-10.csv.gz

wget https://github.com/DataTalksClub/nyc-tlc-data/releases/download/misc/taxi_zone_lookup.csv

gunzip green_tripdata_2019-10.csv.gz

head -n 100 green_tripdata_2019-10.csv

head -n 100 green_tripdata_2019-10.csv > sample-green-trip-data.csv
```

You can also use `pgcli`:

```bash
pgcli -h localhost -p 5433 -u postgres -d ny_taxi
```

The password as `postgres` as specified in the docker compose file.

## Question 3. Trip Segmentation Count

During the period of October 1st 2019 (inclusive) and November 1st 2019 (exclusive), how many trips, **respectively**, happened:

1. Up to 1 mile
2. In between 1 (exclusive) and 3 miles (inclusive),
3. In between 3 (exclusive) and 7 miles (inclusive),
4. In between 7 (exclusive) and 10 miles (inclusive),
5. Over 10 miles

Answers:

- 104,802;  197,670;  110,612;  27,831;  35,281
- 104,802;  198,924;  109,603;  27,678;  35,189
- 104,793;  201,407;  110,612;  27,831;  35,281
- 104,793;  202,661;  109,603;  27,678;  35,189
- 104,838;  199,013;  109,645;  27,688;  35,202

```sql
SELECT
    COUNT(CASE WHEN trip_distance <= 1 THEN 1 END) AS trips_up_to_1_mile,
    COUNT(CASE WHEN trip_distance > 1 AND trip_distance <= 3 THEN 1 END) AS trips_between_1_and_3_miles,
    COUNT(CASE WHEN trip_distance > 3 AND trip_distance <= 7 THEN 1 END) AS trips_between_3_and_7_miles,
    COUNT(CASE WHEN trip_distance > 7 AND trip_distance <= 10 THEN 1 END) AS trips_between_7_and_10_miles,
    COUNT(CASE WHEN trip_distance > 10 THEN 1 END) AS trips_over_10_miles
FROM
    public.green_taxi_data
WHERE
    lpep_pickup_datetime >= '2019-10-01' AND lpep_pickup_datetime < '2019-11-01';
```

Results returned by the query above:

```text
104830
198995
109642
27686
35201
```

The option closest to the actual answers appears to be:

- 104,838;  199,013;  109,645;  27,688;  35,202

## Question 4. Longest trip for each day

Which was the pick up day with the longest trip distance?
Use the pick up time for your calculations.

Tip: For every day, we only care about one single trip with the longest distance.

- 2019-10-11
- 2019-10-24
- 2019-10-26
- 2019-10-31

```sql
WITH daily_longest_trips AS (
    SELECT 
        DATE(lpep_pickup_datetime) AS trip_date,
        MAX(trip_distance) AS longest_distance
    FROM 
        green_taxi_data
    GROUP BY 
        DATE(lpep_pickup_datetime)
)
SELECT
    dlt.trip_date,
    gtd.lpep_pickup_datetime,
    gtd.lpep_dropoff_datetime,
    gtd.trip_distance,
    gtd."PULocationID",
    gtd."DOLocationID",
    gtd.total_amount
FROM 
    green_taxi_data gtd
JOIN 
    daily_longest_trips dlt
ON 
    DATE(gtd.lpep_pickup_datetime) = dlt.trip_date
    AND gtd.trip_distance = dlt.longest_distance
ORDER BY 
    trip_date;
```

Answer is below (515.89 miles):

- 2019-10-31

## Question 5. Three biggest pickup zones

Which were the top pickup locations with over 13,000 in
`total_amount` (across all trips) for 2019-10-18?

Consider only `lpep_pickup_datetime` when filtering by date.

- East Harlem North, East Harlem South, Morningside Heights
- East Harlem North, Morningside Heights
- Morningside Heights, Astoria Park, East Harlem South
- Bedford, East Harlem North, Astoria Park

```sql
SELECT 
    tzl."Zone" AS pickup_zone,
    SUM(gtd.total_amount) AS total_amount_sum
FROM 
    green_taxi_data gtd
JOIN 
    taxi_zone_lookup tzl
ON 
    gtd."PULocationID" = tzl."LocationID"
WHERE 
    DATE(gtd.lpep_pickup_datetime) = '2019-10-18'
GROUP BY 
    tzl."Zone"
HAVING 
    SUM(gtd.total_amount) > 13000
ORDER BY 
    total_amount_sum DESC
LIMIT 3;
```

Answer is:

East Harlem North
East Harlem South
Morningside Heights

## Question 6. Largest tip

For the passengers picked up in October 2019 in the zone
named "East Harlem North" which was the drop off zone that had
the largest tip?

Note: it's `tip` , not `trip`

We need the name of the zone, not the ID.

- Yorkville West
- JFK Airport
- East Harlem North
- East Harlem South

```sql
SELECT 
    tzl_dropoff."Zone" AS dropoff_zone,
    MAX(gtd.tip_amount) AS largest_tip
FROM 
    green_taxi_data gtd
JOIN 
    taxi_zone_lookup tzl_pickup
ON 
    gtd."PULocationID" = tzl_pickup."LocationID"
JOIN 
    taxi_zone_lookup tzl_dropoff
ON 
    gtd."DOLocationID" = tzl_dropoff."LocationID"
WHERE 
    tzl_pickup."Zone" = 'East Harlem North'
    AND DATE(gtd.lpep_pickup_datetime) BETWEEN '2019-10-01' AND '2019-10-31'
GROUP BY 
    tzl_dropoff."Zone"
ORDER BY 
    largest_tip DESC
LIMIT 1;
```

Answer is JFK Airport.

## Question 7. Terraform Workflow

Which of the following sequences, **respectively**, describes the workflow for:

1. Downloading the provider plugins and setting up backend,
2. Generating proposed changes and auto-executing the plan
3. Remove all resources managed by terraform`

Answers:

- terraform import, terraform apply -y, terraform destroy
- teraform init, terraform plan -auto-apply, terraform rm
- terraform init, terraform run -auto-approve, terraform destroy
- terraform init, terraform apply -auto-approve, terraform destroy
- terraform import, terraform apply -y, terraform rm

Answer is `terraform init, terraform apply -auto-approve, terraform destroy`