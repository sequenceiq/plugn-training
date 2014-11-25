This is the Sequenceiq plugn/consul/dockerhook trainig envionment

## install

Install binaries and set up the environment variables

```
git clone https://github.com/sequenceiq/plugn-training.git
cd plugn-training
. .profile
echo BRIDGE_IP=$BRIDGE_IP
```

## start consul

```
start_consul
```

### RPC api

The `consul` cli tool communicates with the local agent via the `127.0.0.1:8400`. You
can override it with the `--rpc-addr=<HOST>:<PORT>` option. So the first command to issue
to check the membership:

```
consul members --rpc-addr=$BRIDGE_IP:8400
```

In the profile there is a function to do it:
```
consul_members
```

### dns api

The dns port by default is 8600. But out setup uses **53** on the `bridge_IP`.
The `.profile` configured the wifi network to use consul as the default dns.
Check your settings: `cat /etc/resolv.conf `

services
```
dig consul.service.consul
dig consul.service.consul +short
dig +search +short consul
dig +search +short consul SRV
```

nodes
```
dig +short node1.node.consul
dig +short node1.node.dc1.consul
dig +search +short node1
```

### http api

Consul listens on the port **8500**. All path is prefixed with `/v1/`, so
getting the registered services in the **catalog**: 

```
GET <HOST>:<PORT>/v1/catalog/services
```

In the profile there is a helper function called `con`
```
$ con con catalog/services
=====> curl -s 172.19.0.1:8500/v1/catalog/services
{
  "consul": []
}
```

