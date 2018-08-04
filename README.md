# Confage

Confage is a config storage for applications with web interface. Applications can take the configs when needed and can subscribe to updates.

To run docker image:
```bash
~ docker build -t confage .
~ docker run -p 4000:4000 -p 6666:6666 -e USERNAME=user -e PASSWORD=pass -v /data:/priv/storage confage
```
Application running inside container with ports 4000 for web and 6666 for tcp.

For get configs:
```bash
~ telnet localhost 6666
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
get_config:test_app
{"key": "var"}
```

For subscribe:
```bash
~ telnet localhost 6666
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
subscribe:test_app
{"key2": "var2"}
{"key3": "var3"}
```