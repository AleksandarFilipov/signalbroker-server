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

# Import all plugins from `rel/plugins`
# They can then be used by adding `plugin MyPlugin` to
# either an environment, or release definition, where
# `MyPlugin` is the name of the plugin module.
Path.join(["rel", "plugins", "*.exs"])
|> Path.wildcard()
|> Enum.map(&Code.eval_file(&1))

use Mix.Releases.Config,
  # This sets the default release built by `mix release`
  default_release: :default,
  # This sets the default environment used by `mix release`
  default_environment: Mix.env()

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html

# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  # If you are running Phoenix, you should make sure that
  # server: true is set and the code reloader is disabled,
  # even in dev mode.
  # It is recommended that you build with MIX_ENV=prod and pass
  # the --env flag to Distillery explicitly if you want to use
  # dev mode.
  set(dev_mode: true)
  set(include_erts: false)
  set(cookie: :"Q]K37*)C^bjTZOchHqXr$j(J3~a1:H1p!3RTW(oEs!zYilyS%G*Zn!/SxacNl{@G")
end

environment :prod do
  set(include_erts: true)
  set(include_src: false)
  set(cookie: :"bqCJb4j$[SZ1/H6@2{oJ6GQ&KEC0N2P$bc!Jpi~1>/9E?vG!Es=Ow0qFb!HZ&Gf)")
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :signal_server do
  set(version: GitVersion.get())

  set(
    applications: [
      :runtime_tools,
      app_counter: :permanent,
      app_debug: :permanent,
      app_lin: :permanent,
      app_telnet: :permanent,
      app_ngcan: :permanent,
      app_udpcan: :permanent,
      app_unixds: :permanent,
      payload: :permanent,
      diagnostics: :permanent,
      fake_can: :permanent,
      reflector: :permanent,
      signal_base: :permanent,
      util: :permanent,
      grpc_service: :permanent,
      flexray: :permanent
    ]
  )
end
