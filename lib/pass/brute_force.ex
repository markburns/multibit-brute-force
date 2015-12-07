defmodule Pass.BruteForce do
  def run(encrypted_filename, recovered_filename, passwords_file) do
    try do
      File.stream!(passwords_file, [])
      |> Pass.Parallel.map &(try_password(encrypted_filename, recovered_filename, &1))
    catch
      :exit -> IO.puts("Found password"); {:ok, "password"}
      value ->  value

    end
  end

  def try_password(encrypted_filename, recovered_filename, password) do
    password = String.rstrip(password)
    result = Pass.Decrypt.run encrypted_filename, recovered_filename, password

    case result do
      {:ok, contents} -> File.write("#{recovered_filename}-found", contents); exit(password)
      {:error, _} -> IO.puts "Wrong: #{password}"
    end
  end
end
