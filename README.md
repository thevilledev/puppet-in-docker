# puppet-in-docker

Dockerfiles for building and running Puppet within CentOS containers.
Enables fail-fast module testing, perhaps automatically by your CI system.

Currently designed for Puppet 3.8.

# Implementation

Both client and master use the official [Puppetlabs Yum repository](http://yum.puppetlabs.com/)
to install `puppet-agent` and `puppet-server` packages.

Master is configured to use certificate auto-signing.
No external DNS is used. Instead, containers are linked, which means
everything relies heavily on the contents of `/etc/hosts`.

All relevant `master` configuration is stored under `/opt/puppet`.
The following volume mounts are exposed:

- Manifests: `/opt/puppet/conf/manifests/nodes`
- Hiera: `/opt/puppet/conf/manifests/hiera`
- Modules: `/opt/puppet/conf/manifests/modules`

These are not stored within the container for obvious reasons.
Example configuration can be found from this repository. By default,
three clients are configured: puppetclient01, puppetclient02 and puppetclient03.
For example, puppetclient01 is configured in these files:

- [Manifest](master/manifests/nodes/puppetclient.pp)
- [Hiera](master/hiera/nodes/puppetclient.json)

These commands are used as the container entrypoints:

- Client: `/usr/bin/puppet agent --no-daemonize --logdest console`
- Master: `/usr/bin/puppet master --no-daemonize --verbose`

# Running with 'docker-compose' (version 1)

The 'docker-compose.yaml' located in the repository root creates
a single Puppet master and three clients. Just run these commands
and you are good to go:

```
$ git clone https://github.com/vtorhonen/puppet-in-docker.git
$ cd puppet-in-docker
$ sudo docker-compose up -d
```

Now, you might see errors like this on the master:

```
Error: Could not resolve 172.17.0.3: no name for 172.17.0.3
```

Since cross-container links without DNS are not supported in older Docker version
you are just going to have to deal with it. Just ignore the error.

# Running with 'docker-compose' (version 2)

If you are running `docker-engine` newer than 1.10.0 you can use the
`docker-compose-v2.yaml` file to set up the environment. This allows
to create a separate network to the project network namespace called `puppets`.
In addition, the containers do nothave to be linked as DNS inside the namespace works as is.

```
$ sudo docker-compose -f docker-compose-v2.yaml up -d
```

# Container logging

Retrieve logs from both master and clients.

```
$ sudo docker logs puppetmaster
...
Notice: puppetclient01 has a waiting certificate request
Info: Autosigning puppetclient01
Notice: Signed certificate request for puppetclient01
Notice: Removing file Puppet::SSL::CertificateRequest puppetclient01 at '/opt/puppet/var/ssl/ca/requests/puppetclient01.pem'
```

```
$ sudo docker logs puppetclient01
...
Notice: Finished catalog run in 0.06 seconds
```

# Image availability on Docker Hub

Pull pre-built images from Docker Hub.

```
$ sudo docker pull vtorhonen/puppetclient
$ sudo docker pull vtorhonen/puppetmaster
```

# Build your own

Clone this repository and run the following commands:

Client:

```
$ cd client
$ sudo docker build -t my-puppetclient .
```

Master:

```
$ cd master
$ sudo docker build -t my-puppetmaster .
```

# Running manually

Example manifests and Hiera configuration can be found from the
``master`` directory. The idea is to start the master by volume
mounting local manifests, modules and Hiera configuration. You
don't want to store this configuration within the container.

Run the master by running the following commands:

```
$ cd master
$ sudo docker run -d --name puppetmaster -h puppetmaster \
-v $(pwd)/manifests:/opt/puppet/conf/manifests \
-v $(pwd)/modules:/opt/puppet/conf/modules \
-v $(pwd)/hiera:/opt/puppet/conf/hiera \
my-puppetmaster
```

Next, run the client.

```
$ sudo docker run -d --name puppetclient --hostname puppetclient \
--link puppetmaster:puppetmaster \
my-puppetclient
```

# TODO

- Puppet 4.x support
- Directory environments
