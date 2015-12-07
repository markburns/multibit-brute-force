defmodule Pass.CLI do
  @module_doc """
    Handle the command line parsing to crack a multibit password
  """

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(argv) do
    parse = OptionParser.parse(argv,
      switches: [help: :boolean],
      aliases:  [h:    :help])

    case parse do
      { [help: true], _,_} -> :help
      { _,  [encrypted_key_file, passwords_file],  _ } -> {encrypted_key_file, passwords_file }
      _ -> :help
    end
  end

  def process(:help) do
    IO.puts """
    usage: pass <encrypted_key_file> <passwords_file>
    """

    System.halt 0
  end

  def process({encrypted_key_file, passwords_file}) do
    Pass.BruteForce.run(encrypted_key_file, passwords_file)
  end
end
