# Web Quickstart

This guide will show you how to add Wit to your web app.

### Prerequisites

To follow this tutorial:

- You need a trained Wit instance (follow [this guide](https://wit.ai/docs/quickstart) to get started)
- Your browser must support WebRTC, which is the case of Chrome, Firefox and Opera right now. Safari and IE don’t support WebRTC yet. Please refer [this link](http://caniuse.com/#search=webrtc) for up-to-date information.

### Step 1: Get Microphone

Create a new folder for your app, download our [Web SDK (aka. Microphone)](https://github.com/wit-ai/microphone/releases/download/0.8.2/microphone-0.8.4.tar.gz) and extract the archive

```bash
  mkdir myapp
  cd myapp
  curl -sL https://github.com/wit-ai/microphone/releases/download/0.8.2/microphone-0.8.4.tar.gz | tar xvzf -
  mv microphone-* microphone
```


### Step 2: Create index.html

In the `myapp` folder, create a file `index.html` containing the snippet on the right.

**Replace `CLIENT_TOKEN` with the client access token of your Wit instance. ** Not the Server access token

```html
  <html>
  <head>
    <link rel="stylesheet" href="microphone/css/microphone.min.css">
  </head>
  <body style="text-align: center;">
    <center><div id="microphone"></div></center>
    <pre id="result"></pre>
    <div id="info"></div>
    <div id="error"></div>
    <script src="microphone/js/microphone.min.js"></script>

    <script>
      var mic = new Wit.Microphone(document.getElementById("microphone"));
      var info = function (msg) {
        document.getElementById("info").innerHTML = msg;
      };
      var error = function (msg) {
        document.getElementById("error").innerHTML = msg;
      };
      mic.onready = function () {
        info("Microphone is ready to record");
      };
      mic.onaudiostart = function () {
        info("Recording started");
        error("");
      };
      mic.onaudioend = function () {
        info("Recording stopped, processing started");
      };
      mic.onresult = function (intent, entities) {
        var r = kv("intent", intent);

        for (var k in entities) {
          var e = entities[k];

          if (!(e instanceof Array)) {
            r += kv(k, e.value);
          } else {
            for (var i = 0; i < e.length; i++) {
              r += kv(k, e[i].value);
            }
          }
        }

        document.getElementById("result").innerHTML = r;
      };
      mic.onerror = function (err) {
        error("Error: " + err);
      };
      mic.onconnecting = function () {
        info("Microphone is connecting");
      };
      mic.ondisconnected = function () {
        info("Microphone is not connected");
      };

      mic.connect("CLIENT_TOKEN");
      // mic.start();
      // mic.stop();

      function kv (k, v) {
        if (toString.call(v) !== "[object String]") {
          v = JSON.stringify(v);
        }
        return k + "=" + v + "\n";
      }
    </script>
  </body>
  </html>
```

### Step 3: See it in action

#### Serve your app with the webserver of your choice

For example, using Python:

```bash
  python -m SimpleHTTPServer
```

#### Load your page

Go on Chrome, Firefox or Opera and hit `http://localhost:8000` (you may have to adjust the domain and port depending on your web server configuration). You'll have to authorize the page to access the microphone.


#### Click on the microphone to start/stop recording.

The intents and entities received from Wit should be displayed on the page.
