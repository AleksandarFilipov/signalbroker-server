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

defmodule Util.Config do
  use GenServer
  require Logger

  # CLIENT

  def start_link(path) do
    GenServer.start_link(__MODULE__, path, name: __MODULE__)
  end

  def start_link(path, pid) do
    GenServer.start_link(__MODULE__, path, name: pid)
  end

  def get_config() do
    GenServer.call(__MODULE__, :get_config)
  end

  def get_config(pid) do
    GenServer.call(pid, :get_config)
  end

  def is_test() do
    Application.get_env(:util, :is_test)
  end

  @doc """
  Converts a IP-4 address to a tuple compatible with `:gen_udp` and `:gen_tcp`.
  """
  def parse_ip_string(str) do
    to_charlist(str)
  end

  @doc """
  Log a message that doesn't show up during testing
  """
  def app_log(msg) do
    if !is_test() do
      Logger.info(msg)
    end
  end

  # SERVER

  # this is a test url, go visit it on the web, potentially generate your own.
  def post_data_to_endpoint(url, body) do
    # {:ok, {{'HTTP/1.1', 200, 'OK'}, _headers, _body}} =
    :httpc.request(
      :post,
      {String.to_charlist(url), [], 'application/json', String.to_charlist(body)},
      [],
      []
    )
  end

  # hash, true addresses are irrelevant
  defp encode_address(address) do
    :crypto.hash(:md5, inspect(address)) |> Base.encode64()
  end

  defp machine_id do
    {:ok, addresses} = MACAddress.mac_addresses()
    Enum.map(addresses, fn {name, address} -> %{if: name, adr: encode_address(address)} end)
  end

  def update_data(file_name) do
    store =
      case File.read(file_name) do
        {:ok, data} ->
          Poison.decode!(data, keys: :atoms)
        _ ->
          %{starts: [], machine_id: machine_id(), version: BuildVersion.get(), os: inspect(:os.type())}
      end

    store = Map.put(store, :count, Map.get(store, :count, 0) + 1)
    store2 = Map.put(store, :starts, Enum.take(store.starts ++ [:os.system_time(:millisecond)], -10))
    case File.open(file_name, [:write]) do
      {:ok, file} ->
        IO.binwrite(file, Poison.encode!(store2))
        File.close(file_name)
      error -> Logger.debug("cant access file #{inspect error}")
    end
    store2
  end

  @url "https://www.beamylabs.com/usage"
  def dispatch_statistics(config, data_file) do
    usage_stats = %{configuration: config, system: update_data(data_file)}
    post_data_to_endpoint(Map.get(config, :usage_endpoint, @url), Poison.encode!(usage_stats))
  end

  @system_file "boot"
  def init(config_file) do
    Logger.debug "paths is #{inspect config_file}"
    _config =
      config_file
      |> File.read()
      |> case do
        {:ok, content} ->
          config =
            content
            |> Poison.decode!(keys: :atoms)
            |> refine()

          spawn(fn ->
            dispatch_statistics(config, Path.join(Path.dirname(config_file), @system_file))
          end)

          Logger.info("You are running version #{inspect BuildVersion.get()}")
          {:ok, config}

        {:error, reason} ->
          {:stop, "Can't open configuration file (#{config_file}) reason: #{inspect(reason)}"}
      end
  end

  def handle_call(:get_config, _, config) do
    {:reply, config, config}
  end

  # Change some fields from strings to atoms
  defp refine(config) do
    # Change gateway from a string to an Atom
    new_gateway = %{config.gateway | gateway_pid: String.to_atom(config.gateway.gateway_pid)}

    # Return with updated fields
    %{config | gateway: new_gateway}
  end
end
