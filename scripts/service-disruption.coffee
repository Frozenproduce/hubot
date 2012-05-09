# Allows Hubot to find out how the Tube is running.
#
# show tube status for <line> line -  Queries the endpoint for the status of that line

module.exports = (robot) ->

  robot.respond /(show)? tube status for all( lines)?/i, (msg) ->
    msg.http("http://service-disruption.herokuapp.com/network")
      .get() (err, res, body) ->
        if res.statusCode == 200
          response = JSON.parse(body)
          return_text = ""
          for line in response.network.lines
            do (line) ->
              return_text += "\nThe #{line.line.name} line is currently running with #{line.line.status.status_description}"
          msg.send return_text
        else
          msg.send "NEIN, NEIN, NEIN, NEIN, NEIN!"


  robot.respond /(show)? tube status( for)? (.*)line?/i, (msg) ->
    query = msg.match[3].trim().replace(/\s+/g, '-').toLowerCase()
    console.log query
    msg.http("http://service-disruption.herokuapp.com/network/#{query}")
      .get() (err, res, body) ->
        if res.statusCode == 200
          line = JSON.parse(body)
          msg.send "The #{line.line.name} line is currently running with #{line.line.status.status_description}"
        else
          msg.send "Achievement unlocked: [GOING NOWHERE UNDERGROUND] no tube line of that name exists"



