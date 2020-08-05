defmodule GitVersion do
  def get do
    case System.cmd(
           "git",
           ~w[describe --always --dirty],
           stderr_to_stdout: true
         ) do
      {raw, 0} ->
        case Version.parse(raw) do
          {:ok, version} ->
            version
            |> bump_version()
            |> to_string()

          :error ->
            "0.0.0-#{String.trim(raw)}"
        end

      _ ->
        "0.0.0-dev"
    end
  end

  defp bump_version(%Version{pre: []} = version), do: version

  defp bump_version(%Version{patch: p} = version),
    do: struct(version, patch: p + 1)
end
