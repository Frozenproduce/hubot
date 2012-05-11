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

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.deployments
        @cache = @robot.brain.data.deployments

  add: (deployment) ->
    if !this.is_running deployment.stage
      @cache.push deployment
      @robot.brain.data.deployments = @cache

  remove: (deployment) ->
    @cache = _.filter @cache, (d) ->
      d.env != deployment.env
    @robot.brain.data.deployments = @cache

  is_running: (env) ->
    for running in @cache
      return true if running.env == env

  recognised_env: (env) ->
    envs = ['staging', 'production']
    _.include envs, env

  status: ->
    return "No deployments in progress" if @cache.length == 0
    mapped = _.map @cache, (d) ->
      "#{d.user} is deploying to #{d.env}"
    mapped.join ', '

class Deployment
  constructor: (@user, @env) -> {}

module.exports = (robot) ->
  deployments = new Deployments robot

  robot.respond /deploy status/i, (msg) ->
    msg.send deployments.status()

  robot.respond /([\w]+) deploy (start|begin)/i, (msg) ->
    env = msg.match[1]
    if_valid_env env, msg, ->
      return msg.send "STOP!! a #{env} deployment is currently in progress" if deployments.is_running env
      deployment = new Deployment msg.message.user.name, env
      deployments.add deployment
      msg.send "All good.. the #{env} deployment env is all yours"

  robot.respond /([\w]+) deploy (end|complete|finish)/i, (msg) ->
    env = msg.match[1]
    if_valid_env env, msg, ->
      return msg.send "Huh?! No #{env} deploy is currently in progress?!"  if !deployments.is_running env
      deployment = new Deployment msg.message.user.name, env
      deployments.remove deployment
      msg.send "Nice work... #{env} deployment marked as completed!"

  if_valid_env = (env, msg, func) ->
    if deployments.recognised_env env
      func()
    else
      msg.send "ERROR: #{env} is an unknown environment"
