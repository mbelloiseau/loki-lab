#!/bin/bash

# Update arch if needed ...
arch="amd64"

#docker-compose up -d

check_binary(){
  test -f ${1}-linux-${arch}.zip && rm ${1}-linux-${arch}.zip
  test -x ./${1}-linux-${arch}
  if [ $? -ne 0 ] ; then
    echo "* Download ${1}-linux-${arch}.zip"
    wget --quiet https://github.com/grafana/loki/releases/download/v2.3.0/${1}-linux-${arch}.zip
    echo "* Unzip ${1}-linux-${arch}.zip"
    unzip -q ${1}-linux-${arch}.zip
  fi
}

check_loki(){
  while [ `curl -s "http://localhost:3100/ready" | egrep '^ready$' | wc -l` -ne 1 ] ; do 
    echo "* Loki is not ready yet ..."
    sleep 10 
  done
  echo "* Loki is ready !"
}

send_logs(){
  locations=("Paris" "London" "New York" "Madrid" "Sydney")
  echo "* Send some logs to Loki"
  for x in $(seq 1 3600) ; do
    random=$(shuf -i 0-1000 -n 1)
    location=${locations[$random % ${#locations[@]}]}
    echo "Hi, I'm from ${location}" 
    echo "Hi, I'm from ${location}" | ./promtail-linux-amd64 -stdin \
    -server.disable \
    -client.url "http://localhost:3100/loki/api/v1/push" \
    -client.external-labels=city="${location}" >/dev/null 2>&1 && sleep 1
  done
}

check_binary promtail
check_binary logcli 
check_loki
send_logs
