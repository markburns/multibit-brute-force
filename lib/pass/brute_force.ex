defmodule Pass.BruteForce do
  use Timex

  def stop do
    Application.stop(ConsumerSupervisor)
  end

  def run(encrypted_filename, passwords_file, found_output_file, password_file_length \\ nil) do
    num_passwords = password_file_length || num_passwords_from(passwords_file)

    case Pass.ConsumerSupervisor.start do
      {:ok, _} -> process(passwords_file, encrypted_filename, found_output_file, num_passwords)
      _ -> {:error, "No valid password found"}
    end
  end

  def process(passwords_file, encrypted_filename, found_output_file, num_passwords) do
    start_time = Date.now
    encrypted_contents = File.read! encrypted_filename
    File.stream!(passwords_file, [])
    |> Stream.map(&(String.rstrip(&1)))
    |> Stream.with_index
    #|> Enum.map(&(display("password: #{ &1}")))
    |> Enum.map(&(add_to_queue(encrypted_contents, &1, found_output_file, num_passwords, start_time)))

    {:ok, "finished"}
  end

  def add_to_queue(encrypted_contents, {element, index}, found_output_file, total, start_time) do
    if rem(index, 10) == 0 do
      display_progress(element, index, total, start_time)
    end

    message = %{password: element, encrypted_contents: encrypted_contents, found_output_file: found_output_file}
    #IO.inspect "queuing MESSAGE: #{inspect message}"

    Queue.enqueue message
  end


  defp display_progress(el, index, total, start_time) do
    if (rem(index, 1000) == 0) do
      IO.puts "trying password: #{inspect el}"
      IO.puts "completed: #{index} / #{total}"

      percent = 100.0 * index / total
      IO.puts "#{inspect percent}%"

      time_diff = time_diff_from(start_time)

      IO.puts "ETA: #{formatted_date(percent, time_diff)}"
    end
  end

  defp time_diff_from(start_time) do
    time_diff = Date.diff Date.now, start_time, :secs
    time_diff = if time_diff == 0 do
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

    Date.now
    |> Date.add(diff)
    |> DateFormat.format!("%H:%M:%S, %a, %d %b %Y", :strftime)
  end

  def display(i) do
    IO.inspect i
    i
  end

  defp num_passwords_from(f) do
    IO.puts "calculating total number of passwords..."

    System.cmd("wc", [f]) |> _extract_number_from_wc
  end

  defp _extract_number_from_wc({item, _}) do
    String.split(item, ~r/\s+/)
    |> line_count_from
    |> String.to_integer
  end

  def line_count_from(columns) do
    Enum.at columns, 1
  end
end
