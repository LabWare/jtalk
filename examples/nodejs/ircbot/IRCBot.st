Object subclass: #STalkerObject
        instanceVariableNames: ''
        category: 'IRCBot'!

!STalkerObject methodsFor: 'logging'!

log: aString
    console log: 'RECV - ', aString.
!

info: aString
    console log: 'INFO - ', aString.
!

error: aString
    console log: 'ERRR - ', aString.
!

warning: aString
    console log: 'WARN - ', aString.
! !

STalkerObject subclass: #STalkerPlugin
        instanceVariableNames: 'socket'
        category: 'IRCBot'!
!STalkerPlugin methodsFor: 'initializing'!

socket
	^socket
!

socket: aSocket
	socket := aSocket.
!

raw: aString
        socket write: aString, String crlf.
!

say: aString to: aChannel
        self raw: 'PRIVMSG ', aChannel, ' :', aString.
!

handle: data
	^(self pattern: data) ifTrue: [self doYourStuff: data]
! !

STalkerPlugin subclass: #PingPlugin
        instanceVariableNames: ''
        category: 'IRCBot'!

!PingPlugin methodsFor: 'initializing'!

pattern: aLine
	^ (RegularExpression fromString: '^PING :(.+)') test: aLine.
!

doYourStuff: data
    self info: 'Answering ping to: ', data.
	self raw: (data replaceRegexp: 'PING' with: 'PONG').
! !

STalkerPlugin subclass: #FreenodeLoginPlugin
        instanceVariableNames: ''
        category: 'IRCBot'!

!FreenodeLoginPlugin methodsFor: 'initializing'!

nickname
        ^ 'StalkerBot', 1000 atRandom.
!

password
        ^ nil
!

realName
        ^ 'JTalk/NodeJS Bot'.
!

pattern: aLine
	^ (RegularExpression fromString: '^.*No Ident response.*') test: aLine
!

doYourStuff: data
	self info: 'Loging in as ', self nickname.
	self raw: 'NICK ', self nickname.
	self raw: 'USER ',  self nickname, ' 8 *  : ', self realName .
! !

STalkerPlugin subclass: #AutojoinPlugin
        instanceVariableNames: 'channels'
        category: 'IRCBot'!

!AutojoinPlugin methodsFor: 'initializing'!

initialize
    super initialize.
    channels := Array new.
    channels add: '#jtalk-bots'.
!

addChannel: aString
        channels add: aString.
!

pattern: aLine
        ":StalkerBot MODE StalkerBot :+i"
        ^ (RegularExpression fromString: '^.+MODE.+\+i.*') test: aLine
!

doYourStuff: data
	self info: 'Autojoining channels.'.
	channels do: [ :channelName |
	                    self raw: 'JOIN ', channelName.
	                    self info: 'Joining ', channelName. ].
! !

STalkerObject subclass: #IRCBot
        instanceVariableNames: 'plugins'
        category: 'IRCBot'!

!IRCBot methodsFor: 'initializing'!


initialize
    super initialize.
    self initializeWithPlugins: (Array with: PingPlugin with: AutojoinPlugin with: FreenodeLoginPlugin).
!

initializeWithPlugins: pluginsToAdd
    self addPlugins: (Array withAll: pluginsToAdd).
!

addPlugins: anArray
    plugins := anArray collect: [:aPlugin| self spawnPlugin: aPlugin].
!

spawnPlugin: aPlugin
    self info: 'Plugin loaded: ', aPlugin name.
    ^(aPlugin new socket: socket).
!

start
    console log: socket.
    socket on: 'connect' callback: [ self info: 'Hem connectat'] .
    socket on:'data' callback:[ :data | data linesDo: [:line |
 	      	 	self log: line.
			    line = '' ifFalse:[ self handle: line]]].
    socket setEncoding: 'ascii'.
    socket setNoDelay.
    socket connect: 6667 host: 'irc.freenode.org'.
!

handle: data
	plugins do:[:plugin | plugin handle: data ]
! !

!IRCBot class methodsFor: 'initialization'!
initialize
    socket :=  < new require('net').Socket()>.
!

main
	self new start
! !
