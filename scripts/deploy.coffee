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

  clear: ->
    @cache = []
    @robot.brain.data.deployments = @cache

class Deployment
  constructor: (@user, @env) -> {}

module.exports = (robot) ->
  deployments = new Deployments robot

  robot.respond /deploy status/i, (msg) ->
    msg.send deployments.to_s()

  robot.respond /([\w]+) deploy (start|begin)/i, (msg) ->
    env = msg.match[1]
    if_valid_env env, msg, ->
      return msg.send deployment_in_progress_msg(env) if deployments.in_progress env
      deployments.start new Deployment msg.message.user.name, env
      msg.send deployment_started_msg(msg.message.user.name, env)

  robot.respond /([\w]+) deploy (end|complete|finish)/i, (msg) ->
    env = msg.match[1]
    if_valid_env env, msg, ->
      return msg.send deployment_not_in_progress_msg(env) if !deployments.in_progress env
      deployments.finish new Deployment msg.message.user.name, env
      msg.send deployment_finished_msg(msg.message.user.name, env)

  robot.respond /deployments clear all/i, (msg) ->
    deployments.clear()
    msg.send deployments_cleared_msg()

  robot.router.get "/hubot/deployments", (req, res) ->
    res.writeHead 200, {'Content-Type': 'application/json'}
    res.end deployments.to_json()

  robot.router.put "/hubot/deployments", (req, res) ->
    env = req.body.environment
    user = req.body.user
    return respond(res, 403) if deployments.in_progress env || !deployments.valid_env env
    deployments.start new Deployment user, env
    res.writeHead 201, {'Content-Type': 'application/json'}
    res.end JSON.stringify { 'user' : user, 'environment' : env }

  robot.router.delete "/hubot/deployments", (req, res) ->
    env = req.body.environment
    user = req.body.user
    return respond(res, 403) if !deployments.in_progress env || !deployments.valid_env env
    deployments.finish new Deployment user, env
    respond(res, 204)

  if_valid_env = (env, msg, func) ->
    if deployments.valid_env env
      func()
    else
      msg.send invalid_environment_msg(env)

  deployment_started_msg = (user, env) ->
    "You're my boy #{user}, deploy the s**t out of that!! The #{env} deployment environment is all yours"

  deployment_finished_msg = (user, env) ->
    "Wow.. You must some kind of sorcerer, #{user}. Right on!!... #{env} deployment marked as completed!"

  deployment_in_progress_msg = (env) ->
    "STOP!!! Nein nein nein!! A #{env} deployment is currently in progress!"

  invalid_environment_msg = (env) ->
    "ERROR: Wat!?! #{env} is not an environment!! Go make everyone a cup of tea and think about what you've done"

  deployment_not_in_progress_msg = (env) ->
    "Huh?! No #{env} deploy is currently in progress?!"

  deployments_cleared_msg = ->
    "Deployments cleared"

  respond = (res, status_code) ->
    res.writeHead status_code, {'Content-Type': 'text/plain'}
    res.end ''
