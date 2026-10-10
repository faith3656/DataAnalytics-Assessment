#!/bin/bash
set -e
docker_process_sql --database="$MYSQL_DATABASE" < /tmp/setup_mysql.sql
