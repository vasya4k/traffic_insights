#!/bin/ash

echo "Waiting Kibana to start on 5601..."

while ! nc -z kib01 5601; do   
  sleep 0.1 # wait for 1/10 of the second before check again
done

echo "Kibana started"

# --max-time 10     (how long each retry will wait)
# --retry 5         (it will retry 5 times)
# --retry-delay 0   (an exponential backoff algorithm)
# --retry-max-time  (total time before it's considered failed)
curl --max-time 10 --retry 12 --retry-delay 0 --retry-max-time 120 -vX POST kib01:5601/api/kibana/dashboards/import  -H 'kbn-xsrf: true' -H "Content-Type: application/json" -d @dashboard.json
curl --max-time 10 --retry 12 --retry-delay 0 --retry-max-time 120 -vX PUT  es01:9200/sflow -H 'kbn-xsrf: true' 
curl --max-time 10 --retry 12 --retry-delay 0 --retry-max-time 120 -vX POST es01:9200/sflow/_mapping  -H 'kbn-xsrf: true' -H "Content-Type: application/json" -d @mappings.json

