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

defmodule UtilTest do
  use ExUnit.Case

  describe "Forwarder" do
    test "initialize" do
      {:ok, p} = Util.Forwarder.start_link()
      assert Process.alive?(p) == true
      Util.Forwarder.setup(self())
      assert Util.Forwarder.terminate() == :ok
    end

    test "send and receive" do
      {:ok, _} = Util.Forwarder.start_link()
      Util.Forwarder.setup(self())

      Util.Forwarder.send(:something)
      assert Util.Forwarder.receive() == :something

      assert Util.Forwarder.terminate() == :ok
    end

    test "asynchorous worker" do
      Util.Forwarder.start_link()
      Util.Forwarder.setup(self())

      {:ok, a} = AsynchronousCaller.start_link()

      AsynchronousCaller.trigger(a, :heres_something)
      assert Util.Forwarder.receive() == :heres_something

      assert Util.Forwarder.terminate() == :ok
      assert GenServer.stop(a) == :ok
    end
  end

  describe "Config" do
    test "load" do
      {:ok, _} = Util.Config.start_link("config/test1.json")
      assert GenServer.stop(Util.Config) == :ok
    end

    test "parse IP" do
      assert Util.Config.parse_ip_string("127.0.0.1") == '127.0.0.1'
      assert Util.Config.parse_ip_string("192.168.100.1") == '192.168.100.1'
      assert Util.Config.parse_ip_string("my_hostname") == 'my_hostname'
    end

    test "test condition" do
      # Always true in test cases
      assert Util.Config.is_test() == true
    end

    @tag :boot
    test "creates file" do
      {:ok, _} = Util.Config.start_link("config/test1.json")
      Process.sleep(1000)
      {:ok, content} = File.read("config/boot")
      decoded = Poison.decode!(content, keys: :atoms)
      assert decoded.count != 0
      assert decoded.count != nil
      assert decoded.os != nil
      assert decoded.starts != 0
      assert decoded.version != nil
      assert GenServer.stop(Util.Config) == :ok
    end
  end
end
