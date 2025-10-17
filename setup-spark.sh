#!/bin/bash
set -e

cd /local

(
    git clone https://github.com/apache/spark.git
    cd spark
    git checkout tags/v4.0.1 -b spark-4.0.1

    export MAVEN_OPTS="-Xss64m -Xmx128g -XX:ReservedCodeCacheSize=2g"
    ./build/mvn -DskipTests clean package
) &
(
    sudo git clone https://github.com/lifers/tpch-spark.git
    cd tpch-spark/dbgen
    sudo make

    # generate ~200GB dataset
    sudo ./dbgen -s 200
) &
wait
