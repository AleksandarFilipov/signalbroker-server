# tiny grpc python example

## Installation, configuration

start the server and make sure it uses [configuration file:](config/interfaces.json)

inspiration from
https://grpc.io/docs/tutorials/basic/python.html


proto files are available in: [signal_server/apps/grpc_service/proto_files/](/apps/grpc_service/proto_files/)

## Setup
```bash
pip install grpcio-tools
```

to re-generate files (already generated in the [generated](generated/) folder)

```bash
python -m grpc_tools.protoc -I../../../apps/grpc_service/proto_files --python_out=./generated --grpc_python_out=./generated ../../../apps/grpc_service/proto_files/*
```

## Run
modify localhost in the sample code to the ip where your server is running.
run the simple_example.sh from your terminal.
```bash
python simple_example.sh
```

make sure you have can traffic running eg "cangen vcan0  -v -g 4" check root readme. Have patience.

# Example of virtual network: 
## Publisher and Subscriber
This examples uses both `virtual_example_pub.py` and `virtual_example_sub.py`.
By running them in separate terminals:
* You can use `virtual_example_pub.py` to type numbers in the console and send them to the SignalBroker using grpc.
* `virtual_example_sub.py` will subscribe to the SignalBroker and receive the stream of data. Every time you type a new number in the "Publisher" you will see the data received in the "Subscriber" side.

## Run
1. Make sure you have an `interfaces.json` file that contains `"type": "virtual"` in its `"chains"` array :
```json
    "chains": [
      {
        "device_name": "virtual",
        "namespace": "VirtualInterface",
        "type": "virtual"
      }
    ],
  ```
  > The `interfaces.json` file that you can find in the `config` folder already has this included.

2. Start the SignalBroker with this new configuration.
3. Execute `virtual_example_sub.py` on a new terminal.
4. In a different terminal, execute `virtual_example_pub.py`.
5. Write numbers in the terminal where you execute `virtual_example_pub.py`.
6. Watch those same numbers appear in the terminal where you execute `virtual_example_sub.py`
