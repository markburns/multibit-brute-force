defmodule Pass.DecryptionConsumer do
  use GenServer
  require Logger

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init _args do
    spawn_link fn -> loop end

    {:ok, {}}
  end

  def loop do
    result = Queue.dequeue

    case  result do
      {:error, error} -> IO.inspect error   ; exit(-2)
      nil             -> Logger.debug("Queue empty: #{__MODULE__} sleeping"); receive do after 200 -> nil end
      payload         -> consume(payload)
    end

    loop
  end

  defp consume(payload) do
    Logger.error "consuming #{inspect payload}"
    Pass.Progress.display(payload)

    case try_password({payload.encrypted_contents, payload.password}) do
      {:ok,     result} -> found(payload, result)
      {:error, details} -> nil && IO.puts "invalid password #{details}"
    end
  end

  def found payload, result do
    body = "#{payload.password}\n#{result.contents}"
    File.write payload.found_output_file, body
  end

  def try_password({encrypted_contents, password}) do
    result = Pass.Decrypt.run encrypted_contents, password
    #IO.puts "Decrypt result #{inspect result}"

    case result do
      {:ok, contents}   -> IO.puts "found password: #{password}"; {:ok, %{password: password, contents: contents}}
      {:error, message} -> {:error, message}
    end
  end
end

