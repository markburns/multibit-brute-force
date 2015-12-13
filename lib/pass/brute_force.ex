defmodule Pass.BruteForce do
  require Logger
  use Timex
  @limit 5

  def stop do
    Application.stop(ConsumerSupervisor)
  end

  def run(encrypted_filename, passwords_file, found_output_file, password_file_length \\ nil) do
    Logger.info "Brute Force Started"
    stop
    spawn_link fn -> Pass.ConsumerSupervisor.start end

    num_passwords = password_file_length || num_passwords_from(passwords_file)

    start_time         = Date.local
    encrypted_contents = File.read! encrypted_filename

    message = %{
      encrypted_contents: encrypted_contents,
      found_output_file:  found_output_file,
      password:           nil,
      index:              nil,
      total:              num_passwords,
      start_time:         start_time
    }

    process(passwords_file, message)

    {:ok, "finished"}
  end

  defp process(passwords_file, message) do
    File.stream!(passwords_file, [])
    |> Stream.map(&(String.rstrip(&1)))
    |> Stream.with_index
    |> Enum.map(&(add_to_queue(&1, message)))
  end

  defp add_to_queue({password, index}, message) do
    message = %{message | password: password, index: index }
    #IO.puts "MESSAGE: #{inspect message}"

    add_to_queue(message)
  end

  defp add_to_queue(message) do
    if (len = Queue.length) > @limit do
      Logger.info "Queue length: (#{len}) greater than #{@limit}, sleeping... item: #{message.index}"

      receive do
      after
        1_000 -> add_to_queue(message)
      end

    else
      #Logger.debug "queuing MESSAGE: #{inspect message}"
      Queue.enqueue message
    end
  end


  #defp _display(i) do
    #  Logger.debug inspect i
    #  i
    #end

    defp num_passwords_from(f) do
      #IO.puts "calculating total number of passwords..."

      System.cmd("wc", [f]) |> _extract_number_from_wc
    end

    defp _extract_number_from_wc({item, _}) do
      String.split(item, ~r/\s+/)
      |> line_count_from
      |> String.to_integer
    end

    defp line_count_from(columns) do
      Enum.at columns, 1
    end
end
