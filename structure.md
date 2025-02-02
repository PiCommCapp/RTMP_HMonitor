# Application Structure

```bash
|- .gitignore                  # Git ignore file
|- LICENSE                     # Pretty straight forward
|- README.md                   # Readme... yep
|- structure.md                # This here, the only way I can think
|- docker-compose.yml          # The complete docker compose development stack  w/ influxdb & grafana, python container
|- sample.env
|- app                         # The application and dockerfile, mounted to python container `/usr/local/bin/rtmpmonitor`
|    |- rtmpmonitor.py         # Entry Script
|    |- main.py
|- config                      # Mount tpython container at `/usr/local/bin/rtmpmonitor/config`

```