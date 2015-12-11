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

    File.stream!(passwords_file, [])
    |> Stream.map(&(String.rstrip(&1)))
    |> Stream.with_index
    #|> Enum.map(&(display(&1)))
    |> Enum.map(&(add_to_queue(encrypted_contents, &1, found_output_file, num_passwords, start_time)))

    {:ok, "finished"}
  end

  defp add_to_queue(encrypted_contents, {element, index}, found_output_file, total, start_time) do
    if Queue.length > 1000 do
      IO.puts "Queue greater than 1,000, sleeping..."
      :timer.sleep 100
      add_to_queue(encrypted_contents, {element, index}, found_output_file, total, start_time)
    end

    display_progress(element, index, total, start_time)

    message = %{password: element, encrypted_contents: encrypted_contents, found_output_file: found_output_file}
    #IO.inspect "queuing MESSAGE: #{inspect message}"

    Queue.enqueue message
  end


  defp display_progress(_el, index, total, start_time) do
    if index > 0 && (rem(index, 1000) == 0) do
      #IO.puts "trying password: #{inspect el}"

      percent = 100.0 * index / total
      time_diff = time_diff_from(start_time)

      IO.puts "(#{index}/#{total}) #{inspect percent}%  ETA: #{formatted_date(percent, time_diff)}"
    end
  end

  defp time_diff_from(start_time) do
    time_diff = Date.diff Date.local, start_time, :secs
    if time_diff == 0 do
      1
    else
      time_diff
    end
  end

  defp formatted_date percent, time_diff do
    seconds_per_percent = if percent == 0 do
      0
    else
      time_diff / percent
    end
    diff = Time.to_timestamp((100.0 * seconds_per_percent), :secs)

    Date.local
    |> Date.add(diff)
    |> DateFormat.format!("%H:%M:%S, %a, %d %b %Y", :strftime)
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
