defmodule Pass.DecryptionConsumer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init _args do
    loop

    {:ok, {}}
  end

  def loop do
    spawn fn ->
      result = Queue.dequeue

      case  result do
        nil             -> :timer.sleep(200) ; loop
        {:error, error} -> IO.inspect error   ; exit(-2)
        payload         -> consume(payload)   ; loop
      end
    end
  end

  defp consume(payload) do
    #IO.puts "consume method called with: payload: #{inspect payload}"

    case try_password({payload.encrypted_contents, payload.password}) do
      {:ok,     result} -> found(payload, result)
      {:error, details} -> nil && IO.puts "invalid password #{details}"
    end
  end

  def found payload, result do
    #IO.puts "saving to #{inspect payload.found_output_file}"

    contents =  "Found password\n#{inspect result}\n#{inspect payload}"
    File.write payload.found_output_file, contents
  end

  def try_password({encrypted_contents, password}) do
    result = Pass.Decrypt.run encrypted_contents, password
    #IO.puts "Decrypt result #{inspect result}"

    case result do
      {:ok, contents}   -> IO.puts "found password: #{password}"; {:ok, {:password, password, :contents, contents}}
      {:error, message} -> {:error, message}
    end
  end
end

