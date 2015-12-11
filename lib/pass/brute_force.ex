defmodule Pass.BruteForce do
  use Timex

  def stop do
    Application.stop(ConsumerSupervisor)
  end

  def run(encrypted_filename, passwords_file, found_output_file, num_passwords \\ nil) do
    num_passwords = num_passwords || num_passwords_from(passwords_file)

    case Pass.ConsumerSupervisor.start do
      {:ok, _} -> process(passwords_file, encrypted_filename, found_output_file, num_passwords)
      _ -> {:error, "No valid password found"}
    end
  end

  def process(passwords_file, encrypted_filename, found_output_file, num_passwords) do
    start_time = Date.now(:secs)
    encrypted_contents = File.read! encrypted_filename
    File.stream!(passwords_file, [])
    |> Stream.map(&(String.rstrip(&1)))
    |> Stream.with_index
    |> Stream.map(&display(&1))
    #|> Enum.map(&(display("password: #{ &1}")))
    |> Enum.map(&(add_to_queue(encrypted_contents, &1, found_output_file, num_passwords, start_time)))

    {:ok, "finished"}
  end

  def add_to_queue(encrypted_contents, {element, index}, found_output_file, total, start_time) do
    if rem(index, 1000) == 0 do
      display_progress(element, index, total, start_time)
    end

    message = %{password: element, encrypted_contents: encrypted_contents, found_output_file: found_output_file}
    #IO.inspect "queuing MESSAGE: #{inspect message}"

    Queue.enqueue message
  end

  defp display_progress(el, index, total, start_time) do
    if rem(index, 1000) == 0 do
      IO.puts inspect el
      IO.puts "#{index} / #{total}"
      percent = 100.0 * index / total

      IO.puts inspect el
      IO.puts "completed: #{index} / #{total}"
      IO.puts "#{inspect percent}%"

      now = Date.now(:secs)
      time_diff = now - start_time

      if time_diff > 0 do
        IO.puts time_diff

        percent_per_second = percent / time_diff
        eta = now + (100.0 / percent_per_second)
        formatted_date = eta |> DateFormat.format("%a, %d %b %Y %H:%M:%S", :strftime)

        IO.puts "ETA: #{formatted_date}"
      end
    end
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
