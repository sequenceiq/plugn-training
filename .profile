export PATH=$BASH_SOURCE/bin:$PATH
export PLUGIN_PATH=$(dirname $BASH_SOURCE)/plugins

BRIDGE_IP=$(docker run --rm busybox ip ro | grep default | cut -d" " -f 3)
sudo networksetup -setdnsservers Wi-Fi $BRIDGE_IP 8.8.8.8
sudo networksetup -setsearchdomains Wi-Fi service.consul node.consul

debug() {
  [[ "$DEBUG" ]] && echo "=====> $*" 2>&1
}

debug_run() {
  declare cmd="$@"
  debug "$cmd"
  eval $cmd
}

start_consul() {
  debug_run \
  docker run -d \
    -h node1 \
    --name=consul \
    -p ${BRIDGE_IP}:53:53/udp \
    -p ${BRIDGE_IP}:8400:8400 \
    -p ${BRIDGE_IP}:8500:8500 \
    sequenceiq/consul:v0.4.1.ptr -server -bootstrap -advertise ${BRIDGE_IP}
}

start_registrator() {
  debug_run \
  docker run -d \
  --name=registrator \
  -v /var/run/docker.sock:/tmp/docker.sock \
  progrium/registrator consul://${BRIDGE_IP}:8500
}

consul_members() {	
  debug_run consul members --rpc-addr=$BRIDGE_IP:8400
}

con() {
  declare path=$1
  shift
  [[ ${path:0:1} != '/' ]] && path="/$path"
  debug curl -s $BRIDGE_IP:8500/v1$path
  curl -s $BRIDGE_IP:8500/v1$path "$@" | jq .
}
