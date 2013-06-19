module.exports = (robot) ->
  robot.hear /hesnon/i, (msg) ->
    msg.send "http://musicgluewwwassets.s3.amazonaws.com/images/hesnoned.jpg"
  robot.hear /silver\s?fox/i, (msg) ->
    msg.send "http://i47.tinypic.com/28rl73t.jpg"
  robot.hear /mr\s?t/i, (msg) ->
    msg.send "I pity the fool!"
  robot.hear /silver\s?hammer/i, (msg) ->
    msg.send "http://musicgluewwwassets.s3.amazonaws.com/images/silverhammer.jpg"
  robot.hear /good\s?morning\s?hubot/i, (msg) ->
    msg.send "Don't talk to me, I've got a banging hangover!"
  robot.hear /tobys\s?brain/i, (msg) ->
    msg.send "http://www.psychologytoday.com/files/u116/blackhole.gif"
  robot.hear /maxwell/i, (msg) ->
    msg.send "http://f.cl.ly/items/1k3O3k262c3J3k0L0l3n/maxwelled.png"
