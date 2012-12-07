module.exports = (robot) ->
  robot.hear /hesnon/i, (msg) ->
    msg.send "http://musicgluewwwassets.s3.amazonaws.com/images/hesnoned.jpg"
