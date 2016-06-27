# haproxy + confd

Docker image which configures haproxy dynamically using confd -> remote etcd hosted on Compose.io.

This is specifically useful if you want to run ECS Tasks with dynamic port allocations (tracked in etcd), and want dynamic service discovery / HTTP routing.

## Usage

```
docker run --name haproxy \
           --rm \
           -p 8080:8080 \
           -p 1000:1000 \
           -e ETCD_NODE=${etcd_proto}://${etcd_host} \
           -e ETCD_USER=${etcd_user} \
           -e ETCD_PASS=${etcd_pass} \
           -e ETCD_CACERT=${etcd_cacert_contents} \
           uniiverse/haproxy:latest
```

 - haproxy runs on 8080
 - ha status page runs on 1000 (suitable for health checks)
 - etcd properties passed in as environment variables

## Assumptions
 - assumes etcd uses the key path `/v2/keys/backends/universe/<service name>` -> `10.1.2.3:32770`

## Props

This project builds off the excellent resources provided by Jason Wilder @ http://jasonwilder.com/blog/2014/07/15/docker-service-discovery.  Thanks for the community contributions that made this possible!
