defmodule Pass.PasswordFile do
  @doc ~S"""
  Determines a tried password list filename based on the SHA of the encrypted key contents
  Examples:
      iex> Pass.PasswordFile.name_for("encrypted-contents")
      "tried-passwords-d9966bba6e0b6696aafd82c69e62f0bf069082ced6111bec93d48af2ef39671f.txt"
  """

  def name_for(contents) do
    "tried-passwords-#{sha_for(contents)}.txt"
  end

  def sha_for(contents) do
    :crypto.hash(:sha256, contents)
    |> Base.encode16
    |> String.downcase
  end
end
