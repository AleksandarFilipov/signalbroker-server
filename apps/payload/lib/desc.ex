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

defmodule Payload.Descriptions do
  use GenServer
  require Logger

  defmodule Field, do: defstruct [
    :id,
    :name,
    is_signed: false,
    factor: 1.0,
    hs: true,
    offset: 0.0,
    startbit: 0,
    length: 0,
    is_raw: false,
    is_frame: false,
  ]

  defmodule Frame, do: defstruct [
    :id,
    :name,
    payload_size: 64, # Payload size in bits
    fields: [],
  ]

  defmodule State, do: defstruct [
    :signal_pid,
    :writer_pid,
    map_name: %{},          # Key: frame name, Value: [%Field,...]
    map_id: %{},            # Key: frame id, Value: %Frame
    fixed_payload_size: 0,  # >0 means size of payloads will be fixed in bits
    schedules: %{},
  ]


  # CLIENT

  def start_link({name, signal_pid, conf, writer_pid}) do
    descriptions = get_canbus_from_config(conf)
    GenServer.start_link(
      __MODULE__, {signal_pid, descriptions, writer_pid}, [name: name])
  end

  def import_human_json(pid, json),
    do: GenServer.call(pid, {:import_human, json})

  def import_human_json_file(pid, path),
    do: GenServer.call(pid, {:import_human_file, path})

  def import_dbc_file(pid, path),
    do: GenServer.call(pid, {:import_dbc_file, path})

  def import_fibex_file(pid, path),
    do: GenServer.call(pid, {:import_fibex_file, path}, 300001)

  def get_fields_by_names(pid, name),
    do: GenServer.call(pid, {:get_fields_by_names, name}, 100000)

  def get_field_by_name(pid, name) do
    [value] = GenServer.call(pid, {:get_fields_by_names, [name]}, 100000)
    value
  end

  def get_field_by_id(pid, id),
    do: GenServer.call(pid, {:get_field_by_id, id})

  def get_info_map(pid, id, payload),
    do: GenServer.call(pid, {:info_map, id, payload})

    def build_payload(pid, fields_with_values),
    do: GenServer.call(pid, {:build_payload, fields_with_values})

  def get_all_names(pid),
    do: GenServer.call(pid, :get_all_names)

  def get_all_names_tagged(pid),
    do: GenServer.call(pid, :get_all_names_tagged)

  def run_in_context(pid, code, arguments),
    do: GenServer.cast(pid, {:run_in_context, code, arguments})

  # SERVER

  def init({signal_pid, conf, writer_pid}) do

    state = %State{signal_pid: signal_pid, writer_pid: writer_pid}
    state = Enum.reduce(conf, state, &read_configuration/2) # Read config
    state = Enum.reduce(conf, state, &read_import/2) # Read import instructions
    Payload.Writer.ready_descriptors(state.writer_pid)
    {:ok, state}
  end

  def handle_call({:import_human, json}, _from, state),
    do: {:reply, :ok, _import_human_json(json, state)}

  def handle_call({:import_human_file, path}, _from, state),
    do: {:reply, :ok, _import_human_json_file(path, state)}

  def handle_call({:import_dbc_file, path}, _from, state),
    do: {:reply, :ok, _import_dbc_file(path, state)}

  def handle_call({:import_fibex_file, path}, _from, state),
    do: {:reply, :ok, _import_fibex_file(path, state)}


  def handle_call({:get_fields_by_names, names}, _from, state) do
    fields =
      names |> Enum.reduce([], fn name, acc -> acc ++ extract_fields_by_name(name, state) end)
    {:reply, fields, state}
  end

  def handle_call({:get_field_by_id, id}, _from, state),
    do: {:reply, Map.get(state.map_id, id), state}

  def handle_call({:get_all_names_tree}, _, state) do
    all_ids = Map.keys(state.map_id)
    everything = Enum.map(all_ids, fn(frame_id) ->
      frame = Map.get(state.map_id, frame_id)
      case Enum.filter(frame.fields, fn(%Payload.Descriptions.Field{is_frame: is_frame}) -> is_frame == true end) do
        [] ->
          %Frame{frame | name: "missing_header_#{inspect frame.id}", fields: Enum.reject(frame.fields, fn(%Payload.Descriptions.Field{is_frame: is_frame}) -> is_frame == true end)}
        [%Payload.Descriptions.Field{name: frame_name}] ->
          %Frame{frame | name: frame_name, fields: Enum.reject(frame.fields, fn(%Payload.Descriptions.Field{is_frame: is_frame}) -> is_frame == true end)}
      end
    end)
    {:reply, everything, state}
  end

  def handle_call({:info_map, id, payload}, _from, state) do
    case Map.get(state.map_id, id) do
      nil ->
        {:reply, :error, state}
      %Frame{fields: fields} ->
        {:reply, parse_fields(fields, payload), state}
    end
  end

  def handle_call({:build_payload, fields_with_values}, _from, state) do
    {:reply, compose_payload(fields_with_values, state), state}
  end

  def handle_call(:get_all_names, _, state) do
    {:reply, Map.keys(state.map_name), state}
  end

  def handle_call(:get_all_names_tagged, _, state) do

    # Tags with their checks
    checks = [
      {:raw, &(&1.is_raw)},
      {:frame, &(&1.is_frame)},
    ]

    resp =
      state.map_name
      |> Enum.flat_map(fn({name, fields}) ->
      Enum.map(fields, fn field ->
        # Check condition and build tag list for signal
        tags = Enum.reduce(checks, [], fn({tag, condition}, acc) ->
          if(condition.(field), do: [tag | acc], else: acc)
        end)

        {name, tags}
      end)
      end)
    {:reply, resp, state}
  end

  def handle_cast({:run_in_context, code, arguments}, state) do
    code.(arguments, state)
    {:noreply, state}
  end

  def extract_fields_by_name(name, state) do
    case Map.has_key?(state.map_name, name) do
      true -> Map.get(state.map_name, name)
      false -> []
    end
  end

  def compose_payload(fields_with_values, state) do

    # 64 is the default size
    payload_size = case Enum.at(fields_with_values, 0) do
      nil -> 64
      {%Field{id: id}, _value} -> Map.get(state.map_id, id, 64).payload_size
    end

    fields_with_values
    |> Enum.reduce(<< 0 :: size(payload_size) >>, fn {field, value}, packet ->

      # Filter away empty value
      value = case value do
        :empty -> 0
        value -> value
      end

      bit_start = field.startbit
      bit_len = field.length
      bit_trail =  payload_size - (bit_start + bit_len)

      <<
        before :: bitstring-size(bit_start),
        _ :: size(bit_len),
        trailing :: bitstring-size(bit_trail)
      >> = packet

      inverted = case field.is_raw do
        false -> (value - field.offset) / field.factor
        true -> value
      end |> round()

      #it doesn't matter if we use usinged on sigend when whe fill the frame, that
      #thats why you dont se any traces if "is_signed"

      <<
        before :: bitstring-size(bit_start),
        inverted :: unsigned-size(bit_len),
        trailing :: bitstring-size(bit_trail)
      >>
    end)
  end

  # INTERNAL

  defp _import_human_json(json, state),
    do: Enum.reduce(json, state, fn json_field, acc ->
      json_field
      |> parse_human_field()
      |> add_field(acc)
    end)

  # Fibex (FlexRay)

  defp _import_fibex_file(fibex_file, state) do
    Logger.info "FlexRay: Loading fibex and parsning file #{fibex_file} - Please hold on."

    fibex = Fibex_Parser.load(fibex_file)
    frames = Fibex_Parser.frameid2signals(fibex)

    map_id = Enum.reduce(frames, %{}, fn {frame_id, signals}, acc ->
      signals = Enum.reduce(signals, [], fn signal, acc ->
      acc ++ [%Field{
         id: frame_id,
         name: signal[:name],
         factor: signal[:factor],
         offset: signal[:offset],
         length: signal[:length],
         startbit: signal[:start_bit],
         is_frame: signal[:is_pdu],
         is_raw: (is_one(signal[:factor]) and is_zero(signal[:offset])) or signal[:is_pdu]
          }]
      end)

      payload_bytes = fibex.frames[frame_id][:byte_length] |> Kernel.to_string |> Integer.parse |> elem(0)
      payload_size = payload_bytes * 8

      fr = %Frame{id: frame_id,
          payload_size: payload_size,
          fields: Enum.sort(signals, fn a, b -> a.startbit <= b.startbit end)
          }

      Map.put(acc, frame_id, fr)
    end)

    map_name = Enum.reduce(map_id, %{}, fn {_frame_id, frame}, acc ->
    Enum.reduce(frame.fields, acc, fn signal, acc ->
      case Map.has_key?(acc, signal.name) do
        true -> %{acc | signal.name => acc[signal.name] ++ [signal]}
        false -> Map.put(acc, signal.name, [signal])
      end
      end)
    end)

    Logger.info "FlexRay: Fibex file parsed and loaded."

    %State{state | map_id: map_id, map_name: map_name}
  end

  # human

  defp _import_human_json_file(path, state),
    do: path
    |> File.read!
    |> Poison.decode!
    |> _import_human_json(state)


  defp _import_ldf_file(path, state) do
    path = if !Util.Config.is_test do
      path
    else
      "../../" <> path
    end

    _ldf_data = Lin.Ldf.parse_file(path)
    |> _import_ldf(state)
  end

  defp _import_ldf(ldf_data, state) do
    #Logger.debug "#{inspect ldf_data}"

    ldf_signals_field_formated = Enum.map(ldf_data.signals, fn(signal) ->
      factor = Lin.Ldf.get_signal_scale(ldf_data, signal.name, :scale, 1.0)
      offset = Lin.Ldf.get_signal_scale(ldf_data, signal.name, :offset, 0)
      length = Lin.Ldf.get_signal_size(ldf_data.signals, signal.name)
      frame_length = Lin.Ldf.get_frame_of_signal_length(ldf_data.frames, signal.name)
      %Field{
        id: Lin.Ldf.get_signal_id(ldf_data.frames, signal.name),
        name: signal.name,
        factor: factor,
        offset: offset,
        length: length,
        startbit: frame_length * 8 - (Lin.Ldf.get_signal_start_bit(ldf_data.frames, signal.name) + (length)),
        is_raw: is_one(factor) and is_zero(offset)
      }
    end)
    ldf_signals_from_frames = Enum.map(ldf_data.frames, fn(frame) ->
      factor = 1.0
      offset = 0
      %Field{
        id: frame.id,
        name: frame.name,
        factor: factor,
        offset: offset,
        length: frame.frame_size * 8,
        startbit: 0,
        is_raw: is_one(factor) and is_zero(offset),
        is_frame: true,
      }
    end)

    Enum.reduce(ldf_signals_field_formated ++ ldf_signals_from_frames, state, fn ldf_signal, acc ->
      add_field(ldf_signal, acc)
    end)
  end




  defp parse_human_field_id(field),
    do: Integer.parse(field["id"], 16) |> elem(0)

  defp parse_human_field_name(field),
    do: field["name"]

  # %{"factor" => 1.0, "hs" => true, "id" => "39b", "length" => 5,
  #   "name" => "SomeSignal_A", "offset" => 0.0, "startbit" => 33}
  defp parse_human_field(field),
    do: %Field{
      id: parse_human_field_id(field),
      name: parse_human_field_name(field),
      factor: field["factor"],
      hs: field["hs"],
      offset: field["offset"],
      startbit: field["startbit"],
      length: field["length"],
      is_raw: is_one(field["factor"]) and is_zero(field["offset"])
    }

  # this is likely i diagnostics message, mark it as raw
  defp is_one(1), do: true
  defp is_one(1.0), do: true
  defp is_one(_number), do: false

  defp is_zero(0), do: true
  defp is_zero(0.0), do: true
  defp is_zero(_number), do: false

  # DBC

  defp _import_dbc_file(path, state) do
    DBC.stream(path, state, fn content ->
      case content do
        {:can_field, state, frame_info, pack_info} ->
          make_field(:can_field, frame_info, pack_info)
          |> add_field(state)
        {:can_frame, state, frame_info} ->
          make_field(:can_frame, frame_info)
          |> add_field(state)
        {:frame_option, state, _} -> state
        {:signal_option, state, _} -> state
      end
    end)
  end

  defp make_field(:can_field, frame_info, pack_info) do
    %Field{
      id: frame_info.can_id,
      name: pack_info.name,
      is_signed: pack_info.is_signed,
      factor: pack_info.factor,
      offset: pack_info.offset,
      startbit: pack_info.startbit,
      length: pack_info.length,
      is_raw: pack_info.is_raw,
    }
  end

  defp make_field(:can_frame, frame_info) do
    %Field{
      id: frame_info.can_id,
      name: frame_info.name,
      is_signed: false,
      factor: 1,
      offset: 0,
      startbit: 0,
      length: frame_info.size_bytes*8,
      is_raw: true,
      is_frame: true,
    }
  end

  # Misc

  defp add_field(field, state) do

    frame_size = cond do
      # Fixed size mode
      state.fixed_payload_size > 0 -> state.fixed_payload_size

      # A frame, update payload_size
      field.is_frame -> field.length

      # A signal, don't set payload_size
      :else -> 64
    end

    new_map_name = case Map.has_key?(state.map_name, field.name) do
             true -> %{state.map_name | field.name => state.map_name[field.name] ++ [field]}
             false -> Map.put(state.map_name, field.name, [field])
           end

    new_map_id = Map.get_and_update(state.map_id, field.id, fn current ->
      new_arr = case current do
        nil -> %Frame{
          id: field.id,
          fields: [field],
          payload_size: frame_size,
        }
        fr -> %Frame{fr |
          fields: Enum.sort([field | fr.fields], fn a, b ->
            a.startbit <= b.startbit
          end),
          payload_size: min(fr.payload_size, frame_size),
        }
      end
      {current, new_arr}
    end) |> elem(1)

    %State{state | map_name: new_map_name, map_id: new_map_id}
  end

  defp parse_fields(fields, payload) do
    fields
    |> Enum.map(fn f ->
      {f.name, extract_field(f, payload)}
    end)
  end

  defp extract_field(
    %Field{startbit: s, length: l, is_signed: is_signed, factor: f, offset: o, is_raw: is_raw},
    payload) do

    data =
    if is_signed do
      << _ :: bitstring-size(s), extract::signed-integer-size(l), _::bitstring>> = payload
      extract
    else
      << _ :: bitstring-size(s), extract::unsigned-integer-size(l), _::bitstring>> = payload
      extract
    end

    case is_raw do
      true -> data
      false -> f * data + o
    end
  end

  # Configuration of settings and descriptors

  defp read_import({:human_file, path}, state),
    do: _import_human_json_file(path, state)

  defp read_import({:dbc_file, path}, state),
    do: _import_dbc_file(path, state)

  defp read_import({:ldf_file, path}, state),
    do: _import_ldf_file(path, state)

  defp read_import({:fibex_file, path}, state),
    do: _import_fibex_file(path, state)

  defp read_import(_, state), do: state

  defp read_configuration({:fixed_payload_size, bytes}, state),
    do: %State{state | fixed_payload_size: bytes*8}

  defp read_configuration(_, state), do: state

  # Don't change the configuration if it's already a keyword list.
  defp get_canbus_from_config(conf) when is_list(conf), do: conf

  # When the configuration comes from a config.exs file.
  defp get_canbus_from_config(physical) when is_map(physical) do
    # Converts description configuration from config.exs to readable in this
    # module.

    keylist = [:dbc_file, :human_file, :ldf_file, :fixed_payload_size, :fibex_file]

    _descriptors =
      Enum.reduce(keylist, [], fn(key, acc) ->
        case Map.has_key?(physical, key) do
          true -> [{key, Map.get(physical, key)}] ++ acc
          false -> acc
        end
      end)
  end
end
