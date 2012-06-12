# Enquire as to whether it is safe to deploy to a certain environment
#
# <env> deploy begin - Enquires if a deploy can take place
# <env> deploy end - Mark a deployment as complete
# deploy status - View current deployments

# REQUIRED MODULES
# sudo npm install underscore

_  = require("underscore")

class Deployments
  constructor: (@robot) ->
    @cache = []
    @envs = ['staging', 'production']

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.deployments
        @cache = @robot.brain.data.deployments

  start: (deployment) ->
    if !this.in_progress deployment.stage
      @cache.push deployment
      @robot.brain.data.deployments = @cache

  finish: (deployment) ->
    @cache = _.filter @cache, (d) ->
      d.env != deployment.env
    @robot.brain.data.deployments = @cache

  in_progress: (env) ->
    for running in @cache
      return true if running.env == env

  valid_env: (env) ->
    _.include @envs, env

  to_s: ->
    return "No deployments in progress" if @cache.length == 0
    mapped = _.map @cache, (d) ->
      "#{d.user} is deploying to #{d.env}"
    mapped.join ', '

  to_json: ->
    JSON.stringify @cache

class Deployment
  constructor: (@user, @env) -> {}

module.exports = (robot) ->
  deployments = new Deployments robot

  robot.respond /deploy status/i, (msg) ->
    msg.send deployments.to_s()

  robot.respond /([\w]+) deploy (start|begin)/i, (msg) ->
    env = msg.match[1]
    if_valid_env env, msg, ->
      return msg.send "STOP!!! Nein nein nein!! A #{env} deployment is currently in progress!" if deployments.in_progress env
      deployments.start new Deployment msg.message.user.name, env
      msg.send "You're my boy #{msg.message.user.name}, deploy the s**t out of that!! The #{env} deployment environment is all yours"

  robot.respond /([\w]+) deploy (end|complete|finish)/i, (msg) ->
    env = msg.match[1]
    if_valid_env env, msg, ->
      return msg.send "Huh?! No #{env} deploy is currently in progress?!"  if !deployments.in_progress env
      deployments.finish new Deployment msg.message.user.name, env
      msg.send "Wow.. You must some kind of sorcerer, #{msg.message.user.name}. Right on!!... #{env} deployment marked as completed!"

  robot.router.get "/hubot/deploy/status", (req, res) ->
    res.writeHead 200, {'Content-Type': 'application/json'}
    res.end deployments.to_json()

  if_valid_env = (env, msg, func) ->
    if deployments.valid_env env
      func()
    else
      msg.send "ERROR: Wat!?! #{env} is not an environment!! Go make everyone a cup of tea and think about what you've done"
