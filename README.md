# tv_program
simple json api for tv programs

startup:
  - git clone
  - bundle install
  - rackup -o 0.0.0.0 -p 3000 -D

kill server:
  lsof -P | grep ':3000' | awk '{print $2}' | xargs kill -9

request example:
  curl -X "POST" "http://localhost:3000/" \
       -H 'Content-Type: application/json' \
       -H 'Authorization: SOMEKEY' \
       -H 'Accept: application/json' \
       -d $'{
    "channels": [
      "RTR",
      "Prime",
      "TV1000",
      "РЕН ТВ HD"
    ]
  }'
