# Copyright 2019 Volvo Cars
#
# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# ”License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#  http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# “AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

defmodule Base.SystemService.Server do
  use GRPC.Server, service: Base.SystemService.Service
  require Logger
  alias GRPC.Server
  alias Payload.Descriptions.Frame
  alias Payload.Descriptions.Field

  @gateway_pid GRPCService.Application.get_gateway_pid()

  @spec get_configuration(Base.Empty.t, GRPC.Server.Stream.t) :: Base.Configuration.t
  def get_configuration(request, _stream) do
    signal_tree = SignalServerProxy.get_configuration(@gateway_pid)
    networks = Enum.map(signal_tree, fn({namespace, %{type: type}}) ->
      Base.NetworkInfo.new(namespace: Base.NameSpace.new(name: Atom.to_string(namespace)), type: type, description: "")
    end)
    Base.Configuration.new(networkInfo: networks)
  end

  @spec list_signals(Base.NameSpace.t, GRPC.Server.Stream.t) :: Base.Frames.t
  def list_signals(request, _stream) do
    signal_tree = SignalServerProxy.get_channels_tree(@gateway_pid, String.to_atom(request.name))

    frames = Enum.map(signal_tree, fn(%Frame{name: frame, fields: childs, payload_size: payload_size}) ->
      subsignals = Enum.map(childs, fn(%Field{name: name, length: length, is_raw: is_raw}) ->
        meta_data = Base.MetaData.new(description: "", max: 0, min: 0, unit: "", size: length, is_raw: is_raw)
        signal_id = Base.SignalId.new(name: name, namespace: Base.NameSpace.new(name: request.name))
        Base.SignalInfo.new(id: signal_id, metaData: meta_data)
      end)

      meta_data = Base.MetaData.new(description: "", max: 0, min: 0, unit: "", size: payload_size, is_raw: true)
      signal_id = Base.SignalId.new(name: frame, namespace: Base.NameSpace.new(name: request.name))
      signal = Base.SignalInfo.new(id: signal_id, metaData: meta_data)
      Base.FrameInfo.new(signalInfo: signal, childInfo: subsignals)
    end)

    Base.Frames.new(frame: frames)
  end
end
