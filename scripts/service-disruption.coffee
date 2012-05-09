module.exports = (robot) ->
  robot.respond /show tube status for (.*)line?/i, (msg) ->
    query = msg.match[1].trim()
    msg.http("http://service-disruption.herokuapp.com/network/#{query}")
      .get() (err, res, body) ->
        if res.statusCode == 200
          line = JSON.parse(body)
          msg.send "The #{line.line.name} line is currently running with #{line.line.status.status_description}"
        else
          msg.send "NEIN, NEIN, NEIN, NEIN, NEIN!!"



