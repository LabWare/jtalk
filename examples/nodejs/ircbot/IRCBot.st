Object subclass: #STalkerPlugin
        instanceVariableNames: 'socket'
        category: 'IRCBot'!
!STalkerPlugin methodsFor: 'initializing'!

socket
	^socket
!

socket: aSocket
	socket := aSocket.
!

handle: data
	^(self pattern: data) ifTrue: [self doYourStuff: data]
! !

STalkerPlugin subclass: #EchoPlugin
        instanceVariableNames: ''
        category: 'IRCBot'!

!EchoPlugin methodsFor: 'initializing'!

pattern: aLine
	^(RegularExpression fromString: '^PING :(.+)$') test: aLine. "'$"
!

doYourStuff: data
	socket write: ((data replaceRegexp: 'PING' with: 'PONG'),'\r\n').
! !


Object subclass: #IRCBot
        instanceVariableNames: 'plugins'
        category: 'IRCBot'!

!IRCBot methodsFor: 'initializing'!

initialize
	|echoPlugin|
	plugins := Array new.

	"HACK to have socket everywhere"
	echoPlugin := EchoPlugin new.
	echoPlugin socket: socket.

	plugins add: echoPlugin.
!

start
    console log: socket.
    socket on: 'connect' callback:[ console log: 'hem connectat'] .
    socket on:'data' callback:[:data|
	data linesDo: [:line |
 	      	 	console log: 'RECV - ' , line.
			line = '' ifFalse:[ self handle: line]]].
socket setEncoding: 'ascii'.
socket setNoDelay.
socket connect: 6667 host: 'irc.freenode.org'.

<function sleep(callback) {
  var now = new Date().getTime();
  while(new Date().getTime() < now + 1000) {
  }
  callback();
}

console.log('Sleep');
for(var i = 0; i < 4; i++) {
  sleep(function() {console.log(i)});
}>.
     [ socket write: 'NICK jtalkbot1919', String crlf.
       socket write: 'USER guest1919191 8 * :Node.js IRC bot',String crlf. ] valueWithTimeout: 1000.
       console log: 'enviat: NICK jtalkbot1919'.
       console log: 'USER guest1919191 8 * :Node.js IRC bot'.
     [ socket write: 'JOIN #vectorlinux-es', String crlf. ] valueWithTimeout: 1000.

!

handle: data
	plugins do:[:plugin | plugin handle: data ]
! !

!IRCBot class methodsFor: 'initialization'!
initialize
        "We require these Node modules."
    os := require value: 'os'.
    http := require value: 'http'.
    net := require value: 'net'.
    socket :=  < new require('net').Socket()>.
!

main
	self new start
! !
