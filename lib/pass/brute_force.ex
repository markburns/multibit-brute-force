defmodule Pass.BruteForce do
  def stop do
    Application.stop(ConsumerSupervisor)
  end

  def run(encrypted_filename, passwords_file, found_output_file, _num_passwords \\ nil) do
    case Pass.ConsumerSupervisor.start do
      {:ok, _} -> process(passwords_file, encrypted_filename, found_output_file)
      _ -> {:error, "No valid password found"}
    end
  end


  def process(passwords_file, encrypted_filename, found_output_file) do
    encrypted_contents = File.read! encrypted_filename
    File.stream!(passwords_file, [])
    |> Stream.map(&(String.rstrip(&1)))
    #|> Enum.map(&(display("password: #{ &1}")))
    |> Enum.map(&(add_to_queue(encrypted_contents, &1, found_output_file)))
    {:ok, "finished"}
  end


  def add_to_queue(encrypted_contents, element, found_output_file) do
    message = %{password: element, encrypted_contents: encrypted_contents, found_output_file: found_output_file}
    #IO.inspect "queuing MESSAGE: #{inspect message}"

    Queue.enqueue message
  end

  def display(i) do
    IO.inspect i
    i
  end

  #defp num_passwords_from(f) do
    #  IO.puts "calculating total number of passwords..."

    #  System.cmd("wc", [f]) |> _extract_number_from_wc
    #end


    #defp _extract_number_from_wc({item, _}) do
      #  String.split(item, ~r/\s+/)
      #  |> line_count_from
      #  |> String.to_integer
      #end

      #def line_count_from(columns) do
        #  Enum.at columns, 1
        #end
end
