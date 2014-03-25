httpServer=require('./mods/httpServer').class
route=require('./mods/route').class
proxyPass=require('./mods/proxyPass').class
logBackend=require('./mods/logBackend').class
configDecoder=require('./mods/configDecoder').class

program=require 'commander'
fs=require 'fs'

version=JSON.parse(fs.readFileSync('./package.json')).version

program.version(version).option('-p --port','The port the server should listen to').option('-c --config','The config file, default to config.json')

cd=new configDecoder()
cp='./config.json'
if(program.config)
	cp=program.config
cd.decode cp

hs=new httpServer(cd)
hs.setRoute new route(cd)
hs.setPass new proxyPass(cd)
hs.setLog new logBackend(cd)
hs.start()
