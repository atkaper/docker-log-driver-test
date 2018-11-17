# docker-log-driver-test

This is a fork of the (official?) example https://github.com/cpuguy83/docker-log-driver-test

I wanted to have a docker log file, just like the standard one, but with the addition of having the container name in it.
This to ease the sending of the file using filebeat or fluent-bit/fluentd using it's ordinary tailing of the logs.

Advantage is that you can keep using the ```docker logs -f ...``` command, and in case the log collector system crashes,
you still have the logs, which will be send to the collector (ELK stack) again later in a retry.

The original example did not have a build script, and no explanation on how to build or use it.
So after some more searching the internet, I managed to get it running. A build/test script is added to ease the process.

Also, the original example was not compiling anymore (due to newer docker version), and did have a nice bug in it, keeping
the log file(s) open. Both have been fixed.

As the example uses the underlying json docker logger, I took the shortcut of altering one of the existing fields in the output.
The stream field will contain the container name and the stream. Also I wanted to keep the location unchanged, so the example
has been altered to use the original destination / log file name.

Here's an example run:

```
$ docker run --rm --name my-test-container --log-driver docker-log-driver-test -d busybox echo -n 'This is a test!'
56c10bdb6b99b7ef9f9f730035aa966ec078d2a9d622b24228888c1e51951974

$ cat /var/lib/docker/containers/56c10bdb6b99b7ef9f9f730035aa966ec078d2a9d622b24228888c1e51951974/56c10bdb6b99b7ef9f9f730035aa966ec078d2a9d622b24228888c1e51951974-json.log
{"log":"This is a test!\n","stream":"my-test-container stdout","time":"2018-11-17T15:45:23.404253723Z"}
```

To build and test the plugin, execute ```./build-and-test.sh```
It quits as soon as something goes wrong (due to the ```set -e```). On my system it sometimes quits due to timeouts, so you might
want to just try running it more than once if it does not work. And if it keeps stopping, then start investigating the error
messages in the output.

A success run should end with displaying the above example.

If you want to use something like this, you should change the project name, and tune the code to your needs.
And at the end of the plugin build, you can push the plugin to your own docker registry for use by your docker daemon.
Also, instead of specifying the plugin to use on the docker run for each image, you can configure the plugin
somewhere centrally, so be used for all container runs automatically.

Disclaimer: I am NOT a GO programmer (yet), so I might have used some silly constructs in the code. Use at your own risk.
This is the first GO project code I touched.

17/11/2018, Thijs Kaper.

