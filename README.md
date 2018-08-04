# Confage

Confage is a config storage for applications with web interface. Applications can take the configs when needed and can subscribe to updates.

To run docker image:
```bash
~ docker build -t confage .
~ docker run -p 4000:4000 -e USERNAME=user -e PASSWORD=pass -v confage
```