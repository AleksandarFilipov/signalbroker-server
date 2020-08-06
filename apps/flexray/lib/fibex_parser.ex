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

defmodule Fibex_Parser do
  import SweetXml

  @moduledoc """
  Elixir mapping of the Fibex (FlexRay) settings:


  SignalMap[key: Fibex::Signal]      =       Fibex::Signal + Fibex::Coding
         ^
         |
         +-------------------------------------------+
                             |
                             |
  PduMap[key: Fibex::Pdu instance id =        Fibex::Pdu + Fibex::Signal-Instance
         ^
         |
         +-----------------------------------------+
                               |
                               |
                               |
  FrameMap[key: slot++cycle]         =        Fibex::Frame + Fibex::FrameRef


  A Frame consists of zero to many PDU instances. Two Frames can contain the same
  PDU, but at different offsets. The same goes for Signals, the same signal can
  be at different offsets in different PDUs.
  Therefore all lookups must from the Frame perspective.
  """

  defmodule Fibex, do: defstruct [
    pdus: %{},
    signals: %{},
    frames: %{},
    missing_frame_warn_once: %{}
  ]

  defp getcodings(doc) do

    [%{:codings => codings}] = doc |> xpath(~x"//fx:FIBEX/fx:PROCESSING-INFORMATION/fx:CODINGS"l,
      codings: [~x"./fx:CODING"l,
        id: ~x"./@ID",
        coded_type: ~x"./ho:CODED-TYPE/@ENCODING",
        bitlength: ~x"./ho:CODED-TYPE/ho:BIT-LENGTH/text()",
        category: ~x"./ho:COMPU-METHODS/ho:COMPU-METHOD/ho:CATEGORY/text()",
        lower_limit: ~x"./ho:COMPU-METHODS/ho:COMPU-METHOD/ho:PHYS-CONSTRS/ho:SCALE-CONSTR/ho:LOWER-LIMIT/text()",
        upper_limit: ~x"./ho:COMPU-METHODS/ho:COMPU-METHOD/ho:PHYS-CONSTRS/ho:SCALE-CONSTR/ho:UPPER-LIMIT/text()",
        numerator: ~x"./ho:COMPU-METHODS/ho:COMPU-METHOD/ho:COMPU-INTERNAL-TO-PHYS/ho:COMPU-SCALES/ho:COMPU-SCALE/ho:COMPU-RATIONAL-COEFFS/ho:COMPU-NUMERATOR/ho:V"l,
        denomenator: ~x"./ho:COMPU-METHODS/ho:COMPU-METHOD/ho:COMPU-INTERNAL-TO-PHYS/ho:COMPU-SCALES/ho:COMPU-SCALE/ho:COMPU-RATIONAL-COEFFS/ho:COMPU-DENOMINATOR/ho:V/text()",
           ]
    )

    [doc, Enum.reduce(codings, %{}, fn x, acc ->
      y = case x[:category] do
    n when n in ['TEXTTABLE', nil] ->
      %{:factor => 1.0, :offset => 0.0, :min => nil, :max => nil}
    n when n in ['LINEAR', 'IDENTICAL'] ->
      [offset_xml, factor_num_xml] = x[:numerator]
      {offset, ""} = elem(offset_xml, 8) |> Enum.at(0) |> elem(4) |> Kernel.to_string |> Float.parse
      {factor_num, ""} = elem(factor_num_xml, 8) |> Enum.at(0) |> elem(4) |> Kernel.to_string |> Float.parse
      {factor_den, ""} = x[:denomenator] |> Kernel.to_string |> Float.parse
      {min, ""} = x[:lower_limit] |> Kernel.to_string |> Float.parse
      {max, ""} = x[:upper_limit] |> Kernel.to_string |> Float.parse

      %{:factor => factor_num / factor_den, :offset => offset,
        :min => min, :max => max}
      end
      {bitlength, ""} = x[:bitlength] |> Kernel.to_string |> Integer.parse

      Map.put(acc, x[:id], Map.merge(y, %{:coded_type => x[:coded_type],
                      :bitlength => bitlength,
                     }))
     end
    )]
  end

  defp getsignals(data) do
    [doc, codings] = data

    [%{:signal => signal}] = doc |> xpath( ~x"//fx:FIBEX/fx:ELEMENTS/fx:SIGNALS"l,
      signal: [~x"./fx:SIGNAL"l,
           id: ~x"./@ID",
           name: ~x"./ho:SHORT-NAME/text()",
           default_value: ~x"./fx:DEFAULT-VALUE/text()",
           coding_ref: ~x"./fx:CODING-REF/@ID-REF"
          ]
    )
    Enum.reduce(signal, %{}, fn x, acc ->
      dv = case x[:default_value] do
             nil -> 0.0
             _ -> x[:default_value] |> Kernel.to_string |> Float.parse() |> elem(0)
           end

      Map.put(acc, x[:id],
        %{:name => Kernel.to_string(x[:name]),
          :default_value => dv,
          :is_signed => codings[x[:coding_ref]][:coded_type] == 'SIGNED',
          :factor => codings[x[:coding_ref]][:factor],
          :offset => codings[x[:coding_ref]][:offset],
          :length => codings[x[:coding_ref]][:bitlength],
          :min => codings[x[:coding_ref]][:min],
          :max => codings[x[:coding_ref]][:max],
          :is_pdu => false
        })
    end)
  end

  defp getpdus(doc) do
    [%{:pdus => pdus}] = doc |> xpath(~x"//fx:FIBEX/fx:ELEMENTS/fx:PDUS"l,
      pdus: [~x"./fx:PDU"l,
         id: ~x"./@ID",
         name: ~x"./ho:SHORT-NAME/text()",
         byte_length: ~x"./fx:BYTE-LENGTH/text()",
         signal_instances: [~x"./fx:SIGNAL-INSTANCES/fx:SIGNAL-INSTANCE"l,
                id: ~x"./@ID",
                bit_position: ~x"./fx:BIT-POSITION/text()",
                is_high_low_byte_order: ~x"./fx:IS-HIGH-LOW-BYTE-ORDER/text()",
                signal_ref: ~x"./fx:SIGNAL-REF/@ID-REF",
                signal_update_bit_position: ~x"./fx:SIGNAL-UPDATE-BIT-POSITION/text()"
                   ]
        ]
    )
    Enum.reduce(pdus, %{}, fn x, acc -> Map.put(acc, x[:id], x) end)
  end

  defp getframetriggers(doc) do
    [%{:channels => [%{:frame_triggers => frame_triggers}]}] = doc |> xpath(~x"//fx:FIBEX/fx:ELEMENTS/fx:CHANNELS"l,
      channels: [~x"./fx:CHANNEL"l,
         name: ~x"./ho:SHORT-NAME/text()",
         frame_triggers: [
           ~x"./fx:FRAME-TRIGGERINGS/fx:FRAME-TRIGGERING"l,
           id: ~x"./@ID",
           slot_id: ~x"./fx:TIMINGS/fx:ABSOLUTELY-SCHEDULED-TIMING/fx:SLOT-ID/text()",
           base_cycle: ~x"./fx:TIMINGS/fx:ABSOLUTELY-SCHEDULED-TIMING/fx:BASE-CYCLE/text()",
           cycle_repetition: ~x"./fx:TIMINGS/fx:ABSOLUTELY-SCHEDULED-TIMING/fx:CYCLE-REPETITION/text()",
           ref_id: ~x"./fx:FRAME-REF/@ID-REF",
         ]
        ]
    )
    [doc, Enum.reduce(frame_triggers, %{}, fn x, acc ->
    Map.put(acc, x[:ref_id],
    %{:slot_id => x[:slot_id] |> Kernel.to_string |> Integer.parse |> elem(0),
      :base_cycle => x[:base_cycle] |> Kernel.to_string |> Integer.parse |> elem(0),
      :cycle_repetition => x[:cycle_repetition] |> Kernel.to_string |> Integer.parse |> elem(0)}
    )
      end)]
  end


  defp lookupforallcycles(frame_triggers, x, z, n) do
    cycle = frame_triggers[x[:id]][:base_cycle] + frame_triggers[x[:id]][:cycle_repetition] * n
    case cycle < 64 do
      true -> lookupforallcycles(frame_triggers, x, Map.put(z, {frame_triggers[x[:id]][:slot_id], cycle}, x), n+1)
      false -> z
    end
  end

  defp getframes(data) do
    [doc, frame_triggers] = data

    [%{:frames => frames}] = doc |> xpath( ~x"//fx:FIBEX/fx:ELEMENTS/fx:FRAMES"l,
      frames: [~x"./fx:FRAME"l,
          id: ~x"./@ID",
          name: ~x"./ho:SHORT-NAME/text()",
          byte_length: ~x"./fx:BYTE-LENGTH/text()",
          pdu_instances: [~x"./fx:PDU-INSTANCES/fx:PDU-INSTANCE"l,
                  id: ~x"./@ID",
                  pdu_ref: ~x"./fx:PDU-REF/@ID-REF",
                  bit_position: ~x"./fx:BIT-POSITION/text()",
                  is_high_low_byte_order: ~x"./fx:IS-HIGH-LOW-BYTE-ORDER/text()"
                 ]
         ]
    )
    Enum.reduce(frames, %{}, fn x, acc ->
      Map.merge(acc, lookupforallcycles(frame_triggers, x, %{}, 0))
    end)
  end

  def load(fibex_file) do
    {:ok, doc} = File.read(fibex_file)

    signal_task = Task.async(fn -> doc |> getcodings |> getsignals end)
    pdu_task = Task.async(fn -> doc |> getpdus end)
    frames_task = Task.async(fn -> doc |> getframetriggers |> getframes end)

    signals = Task.await(signal_task, 300010)
    pdus = Task.await(pdu_task, 300011)
    frames = Task.await(frames_task, 300012)

    %Fibex{
      :signals => signals,
      :pdus => pdus,
      :frames => frames,
    }
  end

  def frameid2signals(fibex) do
    Enum.reduce(fibex.frames, %{}, fn {frame_id, frame_data}, acc ->
      Map.merge(acc,
        Enum.reduce(frame_data[:pdu_instances], %{}, fn pdu_instance, acc ->
          start_bit = pdu_instance[:bit_position] |> Kernel.to_string |> Integer.parse |> elem(0)
          pdu = fibex.pdus[pdu_instance[:pdu_ref]]
          pdu_length = pdu[:byte_length] |> Kernel.to_string |> Integer.parse |> elem(0)
          pdu_as_signal = [%{name: pdu[:name] |> Kernel.to_string,
                             start_bit: start_bit, # Do not convert to motorola byte for some reason!
                             length: pdu_length * 8,
                             factor: 1.0,
                             offset: 0.0,
                             is_pdu: true,
                             is_signed: false}]


          Map.put(acc, frame_id,
            Enum.reduce(pdu[:signal_instances], pdu_as_signal, fn signal_instance, acc ->
              sig_pos = (signal_instance[:bit_position] |> Kernel.to_string |> Integer.parse |> elem(0)) + start_bit
              signal = Map.put(fibex.signals[signal_instance[:signal_ref]], :start_bit, sig_pos |> DBC.motorola_byte)
              acc ++ case signal_instance[:signal_update_bit_position] do
                       nil -> [signal]
                       ub -> [signal] ++ [%{name: signal[:name] <> "_UB",
                                           start_bit: ((ub |> Kernel.to_string |> Integer.parse |> elem(0)) + start_bit) |> DBC.motorola_byte,
                                           length: 1,
                                           factor: 1.0,
                                           offset: 0.0,
                                           is_pdu: false,
                                           is_signed: false}]
                     end
            end)
          )
        end)
      )
    end)
  end

end
