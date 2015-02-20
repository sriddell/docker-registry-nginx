#Setting up a private registry

The Dockerfile is based on the registry dockerfile in the public repo.

It adds nginx to protect the registry with ssl+basic auth.

#Running
The container exposes volumes /ssl /htpasswd, and /registry to hold the ssl key/cert htpasswd file and the registry data.  Then nginx config expects to find the following files:

```
/ssl/server.crt
/ssl/server.key
/htpassd/htpasswd
```

Map host directories to these volumes, and map a port to the exposed port of 443.  For example

```
docker.io run -v /home/sriddell/docker-registry-data/ssl:/ssl -v /home/sriddell/docker-registry-data/registry:/registry -v /home/sriddell/docker-registry-data/htpwasswd:/htpasswd -p 443:443
```

To run on aws using S3 for storage, use something like

```
sudo docker.io run -e SETTINGS_FLAVOR=prod -e AWS_BUCKET=my_bucket -e STORAGE_PATH=/registry -e AWS_KEY=key -e AWS_SECRET=secret_key -p 443:443 -v /home/ubuntu/docker-registry-data/ssl:/ssl -v /home/ubuntu/docker-registry-data/htpasswd:/htpasswd [image_name]
```

#Putting users in htpwasswd

On ubuntu, install apache2-utils.

```
sudo apt-get install apache2-utils
```

Then create/update the htpasswd file wherever you mount the container's /htpasswd dir to, for example

```
sudo htpasswd -c /home/ubuntu/docker-registry-data/htpasswd exampleuser
```

#Using
Put the auth string for the server in .dockercfg.  Note that if you use the port, you will need to put it in twice.

For example, if a Dockerfile with a FROM line of

```
FROM myserver.domain.com/image:0.1.0
```

Requires myserser.domain.com to have an entry in the .dockercfg for authentication.

```
FROM myserver.domain.com:443/image:0.1.0
```

Requires .dockercfg to define an authentication string for myserver.domain.com:443.

#Caveats
If you get a message about a missing version header when trying to push an image, it likely means that your local docker client does not trust the cert chain.  The client just talks to the local daemon, and the daemon appears to cache the CA bundle on startup.  So if you add a new trusted CA, you need to bounce the daemon for pushes to work.

For example, on ubuntu, if you are signing the ssl cert with your own authority, you need to put the ca cert in /usr/local/share/ca-certificates, run update-ca-certificates to add it, then bounce the docker daemon to see the changes.
