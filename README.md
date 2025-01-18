# Data Engineering Zoomcamp 2025

```bash
docker build -t test:pandas .
docker run -it test:pandas
pwd
cd /app
python pipeline.py
```

```bash
# list all containers
docker ps -a
# removes all stopped containers
docker system prune -a
# other useful commands
docker stop <container_name_or_ID> # To stop a container using its name or id 
docker rm <container_name_or_ID> # To remove a container or 
docker rm <ID1> <ID2> <ID3> # When you want to remove multiple ones OR
docker rm $(docker ps -aq) # To remove all containers
docker rmi <image_name_or_ID> # TO remove an image 
docker images # To display all images stored on the system 
docker system prune -a # to free up space and remove unused Docker resource
```

Running Postgres on Docker

```bash
docker run -it \
 -e POSTGRES_USER="root" \
 -e POSTGRES_PASSWORD="root" \
 -e POSTGRES_DB="ny_taxi" \
 -v ny_taxi_postgres_data:/var/lib/postgresql/data \
 -p 5432:5432 \
 postgres:13
```

Let's break down this command to understand what each flag does:

- `-e` flags set environment variables for the container (username, password, database name)
- `-v` flag creates a volume to persist data even if container is stopped. The volume is mapped to `/var/lib/postgresql/data` inside the container, which is where PostgreSQL stores its data files. This ensures our data, originally in the host machine's `ny_taxi_postgres_data` volume, survives container restarts or removals.
-p flag maps port 5432 from container to host machine.

`POSTGRES_USER="root"` is the username we want to set for accessing our PostgreSQL database. In this case, we're using "root" as a simple example, though in production we'd want to use a more secure username. `POSTGRES_PASSWORD="root"` sets the password for accessing the database. Again, in a production environment, we would use a much stronger password. `POSTGRES_DB="ny_taxi"` specifies the name of the database that will be created when the container starts up.

If everything is running smoothly then you will see a bunch of files generated in the ny_taxi_postgres_data folder.

## How to access the database inside the container?

The package we will use here is called pgcli. It's a command-line interface tool for PostgreSQL that provides features like auto-completion and syntax highlighting. To install pgcli, we can use pip:

```bash
pip install pgcli
```

And then, to log into the database we use the following command:

```bash
pgcli -h localhost -p 5432 -u root -d ny_taxi
```

Where:

- `h` is not help but it declares the **host variable** which is localhost connection port.
- `u` is the username.
- `d` is the database name

This command connects to our PostgreSQL database running locally on port *5432*, using the username '*root*' and accessing the '*ny_taxi*' database we created earlier.

We are now in the pgcli interactive shell.

The command line `\dt` lists all the tables available in our database and then, we can do some SQL like creating tables, inserting data, and querying the database. For example, we can create a simple table using `CREATE TABLE` or perform `SELECT` queries to retrieve data once we have some tables populated. In our case, because we don’t have any table yet, we must obtain something like.

```bash
python3 -m venv venv_pgcli
source venv_pgcli/bin/activate
pip install pgcli
```

Some commands:

- \dt - Lists all tables in the current database*
- \d+ [table_name]` - Shows detailed information about a specific table including columns and their types*
- \l - Lists all databases*
- \du - Lists all users and their roles*
- \q - Exits pgcli*
