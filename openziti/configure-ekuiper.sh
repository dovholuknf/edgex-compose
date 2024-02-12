# shellcheck disable=SC2164
cd "$HOME/git/github/dovholuknf/edgex/edgex-compose"

curl -X DELETE http://192.168.1.83:22224/rules/ruleBool
curl -X DELETE http://192.168.1.83:22224/streams/EdgexStream

curl -X POST http://192.168.1.83:22224/streams -d '{"sql": "create stream EdgexStream () WITH (FORMAT=\"JSON\", TYPE=\"edgex\")"}'
curl -X POST http://192.168.1.83:22224/rules -d @- <<HERE
{
  "id": "ruleBool",
  "sql": "SELECT Bool FROM EdgexStream where Bool = true",
  "actions": [
    {
      "rest": {
        "url": "http://core-command.edgex.ziti:80/api/v3/device/name/Random-Integer-Device/Int64",
        "method": "get",
        "dataTemplate": "\"newKey\":\"{{.key}}\"",
        "sendSingle": true
      }
    }
  ]
}
HERE
