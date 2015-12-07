defmodule Pass.BruteForce do
  def run(encrypted_filename, passwords_file) do
    encrypted_contents = File.read! encrypted_filename

    try do
      File.stream!(passwords_file, [])
      |> Pass.Parallel.map &(try_password(encrypted_contents, &1))

      {:error, "No valid password found"}
    catch
      _ ->  IO.puts "found"
    end
  end

  def try_password(encrypted_contents, password) do
    password = String.rstrip(password)
    result = Pass.Decrypt.run encrypted_contents, password

    case result do
      {:ok, contents} -> exit({:password, password, :contents, contents})
      {:error, _}     -> IO.puts "Wrong: #{password}"
    end
  end
end
