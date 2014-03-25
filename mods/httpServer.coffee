http=require 'http'
fs=require 'fs'
class httpServer
	constructor:(configObj)->
		@port=configObj.port
		@UNIXsocket=configObj.UNIXsocket
		@tls=false
		if(configObj.isTLS=="true")
			@tls=true
			@tlsCert=fs.readFileSync(configObj.tlsCert)
			@tlsKey=fs.readFileSync(configObj.tlsKey)
	setRoute:(routeObj)=>
		@routeObj=routeObj
	setLog:(logObj)=>
		@logObj=logObj
	start:()=>
		if(not @logObj? or not @routeObj?)
			return
		hs=null
		if not @tls
			hs=http.createServer()
		else
			options=
				key:@tlsKey
				cert:@tlsCert
			hs=https.createServer(options)

		hs.on 'request',(req,res)=>
			@logObj.logRequest req,res
			@routeObj.route req,res
		hs.on 'close',()=>
			@logObj.log 'Server closed'
		hs.on 'clientError',(e,socket)=>
			try
				@logObj.log 'Client error:'+JSON.stringify(e)+' socket will be closed'
			catch e
				@logObj.log 'Client error:Strange socket will be closed'
			socket.close()
		#Can be both
		if @port?
			hs.listen @port
		if @UNIXsocket?
			hs.listen @UNIXsocket
