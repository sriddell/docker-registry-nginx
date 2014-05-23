#Setting up a private registry

The Dockerfile is based on the registry dockerfile in the public repo.

It adds nginx to protect the registry with ssl+basic auth.

#Running
The container exposes volumes /ssl and /registry to hold the ssl key/cert and the registry data.  Map host directories to these volumes, and map a port to the exposed port of 443.  For example

```
docker run -v /home/sriddell/docker-registry-data/ssl:/ssl -v /home/sriddell/docker-registry-data/registry:/registry -p 443:443
```

#Caveats
If you get a message about a missing version header when trying to push an image, it likely means that your local docker client does not trust the cert chain.  The client just talks to the local daemon, and the daemon appears to cache the CA bundle on startup.  So if you add a new trusted CA, you need to bounce the daemon for pushes to work.

For example, on ubuntu, if you are signing the ssl cert with your own authority, you need to put the ca cert in /usr/local/share/ca-certificates, run update-ca-certificates to add it, then bounce the docker daemon to see the changes.
