defmodule Pass.BruteForce do
  def run(encrypted_filename, passwords_file) do
    encrypted_contents = File.read! encrypted_filename

    total_passwords = num_passwords_from(passwords_file)
    IO.puts "Total passwords: #{total_passwords}"

    try do
      File.stream!(passwords_file, [])
      |> Pass.Parallel.map &(try_password(encrypted_contents, &1)), total_passwords

      {:error, "No valid password found"}
    catch
      _ ->  IO.puts "found"
    end
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

  def display(i) do
    IO.inspect i
    i
  end

  def line_count_from(columns) do
    Enum.at columns, 1
  end

  def try_password(encrypted_contents, {password, _}) do
    password = String.rstrip(password)
    result = Pass.Decrypt.run encrypted_contents, password

    case result do
      {:ok, contents} -> exit({:password, password, :contents, contents})
      {:error, _}     -> IO.puts "Wrong: #{password}"
    end
  end
end
