# Enquire as to whether it is safe to deploy to a certain environment
#
# <stage> deploy begin - Enquires if a deploy can take place
# <stage> deploy end - Mark a deployment as complete
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

  add: (stage) ->
    @cache.push stage
    @cache = _.uniq(@cache)
    @robot.brain.data.deployments = @cache

  remove: (stage) ->
    @cache = _.without(@cache, stage)
    @robot.brain.data.deployments = @cache

  is_running: (stage) ->
    for running in @cache
      return true if running == stage

  in_progress: ->
    @cache.join ', '

  recognised_stage: (stage) ->
    envs = ['staging', 'production']
    _.include envs, stage

module.exports = (robot) ->
  deployments = new Deployments robot

  robot.respond /([\w]+) deploy (start|end)/i, (msg) ->

    stage = msg.match[1]
    func = msg.match[2]

    if deployments.recognised_stage stage

      if func == 'start'
        return msg.send "STOP!! a #{stage} deployment is currently in progress" if deployments.is_running stage
        deployments.add stage
        msg.send "All good.. the #{stage} deployment stage is all yours"

      if func == 'end'
        return msg.send "Huh?! No #{stage} deploy is currently in progress?!"  if !deployments.is_running stage
        deployments.remove stage
        msg.send "Nice work... #{stage} deployment marked as completed!"

    else
      msg.send "ERROR: #{stage} is an unkwnown environment"

  robot.respond /deploy status/i, (msg) ->
    msg.send (deployments.in_progress() || 'No') + ' deployment(s) in progress'
