# Microphone

## Quickstart

See quickstart.md

## Example

[Home automation demo](http://labs.wit.ai/demo/index.html)

![Demo](https://github.com/wit-ai/house/blob/master/app/images/house.png)

(Source code: https://github.com/wit-ai/house)

## API

Here are the methods available on the Microphone object

### Assumptions

 You know how to create the microphone. See quickstart.md for instructions on how to create your microphone.

### Available methods

```javascript
connect(token)
```
 connect the microphone to the Wit instance identified by the token
 
----  
```javascript
start()
```

start streaming audio to the Wit instance (also achieved by clicking on the microphone element on the page)

----  
```javascript
stop()
```

stop recording audio (also achieved by clicking on the microphone element on the page). Wit will send a response, received via the `onresult` handler.

----  
```javascript
onready(callback)
```

call the given callback when the microphone is ready to record

----  
```javascript
onresult(callback)
```

call the given callback when a response is received from the instance. The callback function takes two arguments: a string corresponding to the detected intent, and a list of entity objects.

----  
```javascript
onerror(callback)
```

call the given callback whenever an error occurs. An error string is passed to the callback function.

----  
```javascript
onaudiostart(callback)
```

call the given callback when the recording starts.

----  
```javascript
onaudioend(callback)
```

call the given callback when the recording stops

----  
```javascript
onconnecting(callback)
```

call the given callback when Microphone is waiting for the server to reply or for the user to allow access to her microphone.

----  
```javascript
ondisconnected(callback)
```

call the given callback when the connection is closed by the server or the client.

## How to build

### Dev

```bash
grunt serve
```

### Release

```bash
# bump version in bower.json
./release.sh
```
