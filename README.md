# NetLink

Basic example of Netlink communication in pure Elixir using :socket module

## Usage example

```
iex(1)> NetLink.get_addr
seq: 1645065762
pid: 935615
[
  <<172, 17, 0, 1>>,
  <<192, 168, 112, 1>>,
  <<192, 168, 1, 106>>,
  <<192, 168, 1, 156>>,
  <<127, 0, 0, 1>>
]
```

Currently just one message is processed (does not wait for the end of a dump message)

## Debug

For debugging it might be useful use tcpdump

```
sudo ip link add  nlmon0 type nlmon
sudo ip link set dev nlmon0 up
sudo tcpdump -i nlmon0 -w messages.pcap
```
