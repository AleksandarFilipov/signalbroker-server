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

defmodule Util.MixProject do
  use Mix.Project

  def project,
    do: [
      app: :util,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      aliases: aliases(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]

  def application,
    do: [
      extra_applications: [:logger, :inets],
      mod: {Util.Application, []}
    ]

  defp deps,
    do: [
      {:poison, "~> 3.0"},
      {:mac_address, "~> 0.0.1"}
    ]

  defp aliases,
    do: [
      test: "test --no-start"
    ]
end
