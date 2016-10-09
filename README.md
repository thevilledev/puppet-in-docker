# puppet-in-docker

Dockerfiles for building and running Puppet within CentOS containers.
Enables fail-fast module testing, perhaps automatically by your CI system.

Currently designed for Puppet 3.8.

# Implementation

Both client and master use the official [Puppetlabs Yum repository](http://yum.puppetlabs.com/)
to install `puppet-agent` and `puppet-server` packages.

Master is configured to use certificate auto-signing.
No DNS is used. Instead, containers are linked, which means everything
relies heavily on the contents of `/etc/hosts`.

All relevant `master` configuration is stored under `/opt/puppet`.
The following volume mounts are exposed:

- Manifests: `/opt/puppet/conf/manifests/nodes`
- Hiera: `/opt/puppet/conf/manifests/hiera`
- Modules: `/opt/puppet/conf/manifests/modules`

These are not stored within the container for obvious reasons.
Example configuration can be found from this repository. By default,
a machine called 'puppetclient' is configured by these files
in this repository:

- [Manifest](master/manifests/nodes/puppetclient.pp)
- [Hiera](master/hiera/nodes/puppetclient.json)

These commands are used as the container entry points:

- Client: `/usr/bin/puppet agent --no-daemonize --logdest console`
- Master: `/usr/bin/puppet master --no-daemonize --verbose`

# Installing

Pull pre-built images from Docker Hub.

```
$ docker pull vtorhonen/puppetclient
$ docker pull vtorhonen/puppetmaster
```

# Building

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

# Running

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
-e PUPPETMASTER_TCP_HOST="puppetmaster" \
--link puppetmaster:puppetmaster \
my-puppetclient
```

# Logging

See the logs from Docker journal.

```
$ sudo docker logs my-puppetmaster
```

```
$ sudo docker logs my-puppetclient
```

# TODO

- Puppet 4.x support
- Directory environments
