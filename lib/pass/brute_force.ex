defmodule Pass.BruteForce do
  use Timex

  def stop do
    Application.stop(ConsumerSupervisor)
  end

  def run(encrypted_filename, passwords_file, found_output_file, password_file_length \\ nil) do
    stop
    num_passwords = password_file_length || num_passwords_from(passwords_file)

    Pass.ConsumerSupervisor.start


    process(passwords_file, encrypted_filename, found_output_file, num_passwords)
  end

  defp process(passwords_file, encrypted_filename, found_output_file, num_passwords) do
    start_time         = Date.local
    encrypted_contents = File.read! encrypted_filename

    message = %{
      password:           nil,
      index:              nil,
      total:              num_passwords,
      start_time:         start_time,
      encrypted_contents: encrypted_contents,
      found_output_file:  found_output_file
    }

    File.stream!(passwords_file, [])
    |> Stream.map(&(String.rstrip(&1)))
    |> Stream.with_index
    #|> Enum.map(&(display(&1)))
    |> Enum.map(&(add_to_queue(&1, message)))

    {:ok, "finished"}
  end

  defp add_to_queue({password, index}, message) do
    message = %{message | password: password, index: index }

    add_to_queue(message)
  end

  defp add_to_queue(message) do
    if Queue.length > 100_000 do
      IO.puts "Queue greater than 100,000, sleeping..."
      :timer.sleep 1000
      add_to_queue(message)
    else
      #IO.inspect "queuing MESSAGE: #{inspect message}"
      Queue.enqueue message
    end
  end


  #defp _display(i) do
    #  IO.puts inspect i
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
