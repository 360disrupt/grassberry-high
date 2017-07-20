# General
I developed the code with the focus on bootstraping a protoype as fast as I could. This affected the code quality, please feel free to open up issues on code quality or improve the quality. New code will be strictly checked to meet code quality. Or in other words, do as I say, not as I do.

Finanical support for the project is always appreciated: [Patreon Campaign](https://www.patreon.com/grassberry)

# License
The project will be opened up more and more gradually. My main goal is to enable private persons to use this code and to charge commercial entities for it in order to put these funds into the project. I will make this transparent in the future to stop discussions about why this is not yet 100% open source etc. If you have any questions about the license, please feel free to discuss it in our Slack Channel, see below.

Please respect the development of the project and don't put any hacked versions online. This would take away important funds from the project and decrease the speed of development for everyone.

By using/contributing to the project you accept the [license](https://github.com/360disrupt/grassberry-high/blob/master/LICENSE).

# Development Slack

Drop an email to **hello \<\> grassberry-high.com** with the title `Invite me to Slack`
to get invited to the [Slack](https://grassberryhigh.slack.com/) channel.
Send me your serial number and I just enable your pi to always get a license. Alternatively you can hack the code, but this is more comfortable and makes it a tiny bit harder for someone to disable the license shield.

# Run

## On the Pi3
Follow the instructions here:
[Build your own tutorial](http://blog.grassberry-high.com/build-your-own-grassberry-high/)

### Short Version

1. Plugin all sensors & controllers into the i2c bus and add the power supply
2. Connect to gh-config wifi hotspot
3. Enter http://grassberry.local
3. Enter your wifi credentials into the configuration, let the device reboot automatically
4. Done

### Get the code on your pi
Create a distilled version of the code with `gulp serve:dist`, this will create a `dist` folder.

#### Manual
To deploy the code onto your Raspberry Pi, you can copy the dist folder to the SD card with a linux system into `/user/pi/app/dist`.

#### Commandline
For deployment form the commandline you add the [code snippet](./.bash_profile.sh) to your bash profile and source it with `source ~/.bash_profile`. After this you can use the command `deployMenu` to start the deployment process. If you want to skip installations on the pi just run `deployMenu true`

## On Your Computer

### Installation

bower and node package manager are required

`npm install`, installs all node packages
`bower install` installs all bower packages

1. Create a `_server-config.js` you can use `_server_config.example.js` as an example
2. gulp serve
3. Open http://localhost:5000/#/

### Database

Install and start a [mongodb instance](https://www.mongodb.com/de).


# Configuration  Variables

## Basic

- NODE_ENV: sets the environment (devlopment, test, production)

## Api

- API_TOKEN: bearer token for api access, for future use

## Database

- MONGODB_URL: url to the database
- MONGODB_ADMIN: admin db

## Simulation

- SEED: automatically seed diff. collections e.g. "chambers sensors outputs rules cronjobs"
- USER_SEED_TOKEN: give a default token to every user for test reasons
- ON_SHOW_MODE_BLOCKED: block c/u of crud to prevent users to mess around with the system on a fair/exibition
- OS: turns on certain simulation functions e.g. I2C Bus, "MAC OSX"
- SIMULATION: turns on simulation mode for sensors

## Debug

- LONG_ERROR_TRACES: enables long error traces in prod mode (in dev always on)
- HEAP_SNAPSHOPT: turn heap snapshots on with 'true'
- DEBUG: enable debug loggers e.g. 'sensor*'

## Other

- NO_CRONS: Disables cronjobs


# Coding Guidlines

..1. Use separate branches for separate problems, feel free to push to master afterwards

..2. More code is read than written, be specific in variable names

..3. Small commits, commit the smallest unit

..4. Write unit tests on critical functions, write unit tests where they are missing

..5. No duplicate code, if code is needed twice, use classes, functions etc.

..6. Write comments, readme if something is not 100% self explaining

# How to Commit

..1. No commit without test

..2. Naming: tag + title + \<msg\> `update`: minor change, `ame`: adding a minor change to a previous commit, `fix`: fixing and issue, please add the issue in the title (be specific, no abreviations), e.g. `update: Water sensor hdc1000 has a safety fuse`

## Git
check this guide: `http://rogerdudler.github.io/git-guide/

### Getting the project
`git pull <url>`
fork the project to contribute.

### How to contribute with git

#### add files
`git add --p` (adds single changes)
`git add <filename>` (adds files)

#### do a commit
`git commit -m "<your message>"`

#### upload
`git pull --rebase origin master` (get the newest version)
(maybe you need to solve merge conflicts)
`git push origin master`

add new packages for production with
`npm add --save <module>`

for development with
`npm add --save-dev <module>`

# Prod packing
1) Use `gulp stat` to pack a deployment version
2) Upload to git repository: https://github.com/360disrupt/grassberry-high-software/blob/master/latest/
3) Use git raw to genrate a url: https://rawgit.com/
4) add url to DB e.g. db.getCollection('softwares').update({}, {$set: {"url": "https://cdn.rawgit.com/360disrupt/grassberry-high-software/a8c075a9/latest/2017-06-22T11_30_05%2B0200.tar.gz"}})
