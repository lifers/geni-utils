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
    git clone https://github.com/lifers/tpch-spark.git
    cd tpch-spark/dbgen
    make

    # generate ~200GB dataset
    ./dbgen -s 200

    cd ..
    sbt package
) &
wait
