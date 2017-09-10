APP_PATH = '/home/pi/app'

inspect = require('util').inspect
chalk = require('chalk')
debugShell = require('debug')('shell')

async = require('async')
moment = require('moment')

shell = require 'shelljs'
shell.config.silent = true

socketIoMessenger = require('../_socket-io/socket-io-messenger.js')
logger = require('../_logger/logger.js').getLogger()

executeCommands = (commands, callback)->
  if process.env.NODE_ENV != 'production'
    return callback null, true
  # commandEchoFinished = "echo \"finished\""
  # commands.push({"name": "commandEchoFinished", "command": commandEchoFinished})
  results = []
  async.eachSeries commands,
    (command, next)->
      shell.exec command.command, (code, stdout, stderr) ->
        err = if stderr? && stderr != "" then stderr else null
        logger.debug "Command: #{command.name}, exited with code: #{code}", stdout if code != 0
        logger.debug "Command: #{command.name}", err if err?
        # return next err if err?
        results.push({"command":command.name, "code":code, "stdout":stdout})
        return next null
    (err)->
      return callback err if err?
      return callback null, results

exports.getWifiOptions = (callback)->
  return callback null, ['MAC OSX'] if process.env.OS == 'MAC OSX'
  commands = []

  commandGetWifiOptions = "iwlist wlan0 scan | grep ESSID"
  commands.push({"name": "commandGetWifiOptions", "command": commandGetWifiOptions})

  executeCommands commands, (err, results)->
    return callback err if err?
    return callback "No wifi detected" if !results?[0]?
    wifiOptions = results[0].stdout.replace(/\n/g, "").split(/ESSID:\"(.*?)\"/g).filter (entry)->
      return entry.trim() != ""

    return callback null, wifiOptions

exports.configureWifi = (wifi, callback)->
  return callback "Not able to do this on #{process.env.OS}" if process.env.OS == 'MAC OSX'
  return callback "Please provide wifi name and pass" if !wifi?.name?

  wifi.pass = "" if !wifi.pass?

  commands = []

  commandFlushOldWifi = "bash /etc/wpa_supplicant/del-old-wifi.sh"
  commands.push({"name": "commandFlushOldWifi", "command": commandFlushOldWifi})

  commandConfigureWifi = "printf '\nnetwork={%s\n\tssid=\"#{wifi.name}\"%s\n\tpsk=\"#{wifi.pass}\"%s\n}' >> /etc/wpa_supplicant/wpa_supplicant.conf"
  commands.push({"name": "commandConfigureWifi", "command": commandConfigureWifi})

  commandDisableHotspot = "sed -e '/DAEMON_CONF/ s/^#*/#/' -i /etc/default/hostapd && cat /etc/dnsmasq.conf.original > /etc/dnsmasq.conf" #to uncomment sed -i '/DAEMON_CONF/s/^#//g' /etc/default/hostapd
  commands.push({"name": "commandDisableHotspot", "command": commandDisableHotspot})

  #TODO move to rc.local (check disk space on boot)
  commandExpandFilesystem = "bash #{__dirname}/shell/expand-filesystem.sh"
  commands.push({"name": "commandExpandFilesystem", "command": commandExpandFilesystem})

  commandReboot = "reboot"
  commands.push({"name": "commandReboot", "command": commandReboot})

  executeCommands commands, callback

exports.configureDateTime = (dateTime, callback)->
  return callback "Not able to do this on #{process.env.OS}" if process.env.OS == 'MAC OSX'
  dateTime = dateTime.dateTime
  timeZone = dateTime.timeZone
  return callback "No valid date time specified" if !dateTime? || moment(dateTime).isValid() == false
  return callback "No time zone specified" if !timeZone?

  commands = []
  commandSetTime = "date --set '#{moment(dateTime).format('YYYY-MM-DD HH:mm:ss')}'"
  commands.push({"name": "commandSetTime", "command": commandSetTime})

  commandSetTimeZone = "echo '#{timeZone}' > /etc/timeZone && dpkg-reconfigure -f noninteractive tzdata"
  commands.push({"name": "commandSetTimeZone", "command": commandSetTimeZone})


  executeCommands commands, (err, results)->
    debugShell "time is now #{ moment().format('YYYY-MM-DD HH:mm:ss')}"
    return callback err, results

exports.getSerial = (callback)->
  return callback null, 'MAC OSX' if process.env.OS == 'MAC OSX'

  commands = []
  commandGetSerial = "cat /proc/cpuinfo | grep Serial | cut -d ' ' -f 2"
  commands.push({"name": "commandGetSerial", "command": commandGetSerial})

  executeCommands commands, (err, results)->
    return callback err if err?
    return callback "Could not get serial" if !results?[0]? || results[0].code != 0
    return callback null, results[0].stdout.replace('\n', '')

exports.installNewVersion = (callback)->
  return callback null, 'MAC OSX' if process.env.OS == 'MAC OSX'

  commands = []
  # commandDeploy = "sudo chown pi:pi newVersion.tar.gz && sudo -u pi bash #{APP_PATH}/deploy.sh"
  commandDeploy = "sudo chown pi:pi newVersion.tar.gz && reboot"
  commands.push({"name": "commandDeploy", "command": commandDeploy})

  payload = {
    id: 'update'
    title: 'System is updating'
    message: 'App may slow down/reboot within the next minute!'
  }
  socketIoMessenger.sendMessage('system', payload)

  setTimeout ()->
    executeCommands commands, (err, results)->
      return callback err if err?
      return callback null, results
  , 2000

exports.checkDiskSpace = (appUser, options, callback)->
  commands = []

  pathPython = "#{__dirname}/python/memory.py"
  console.log chalk.bgGreen "#{}", inspect pathPython
  commandCheckDiskSpace = "python #{pathPython}"
  commands.push({"name": "commandCheckDiskSpace", "command": commandCheckDiskSpace})

  executeCommands commands, (err, status)->
    return callback err, status

exports.reboot = (appUser, options, callback)->
  return callback "Not able to do this on #{process.env.OS}" if process.env.OS == 'MAC OSX'
  commands = []
  commandReboot = "reboot"
  commands.push({"name": "commandReboot", "command": commandReboot})

  executeCommands commands, (err, status)->
    return callback err, status
