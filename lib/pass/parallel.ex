defmodule Pass.Parallel do
  @doc ~S"""
  Parallelizes the calculation of `fun` mapped over `collection`

  ## Examples
      iex> Pass.Parallel.map([1,2],&(&1 +2))
      [3,4]
  """

  def map(collection, fun) do
    collection
    |> parallelize(self, fun)
    |> collate_results
  end

  defp parallelize(list, me, fun) do
    list
    |> Enum.map &(calculate_individual(&1, me, fun))
  end

  defp calculate_individual(elem, me, fun) do
    spawn_link fn -> send(me, {self, fun.(elem)}) end
  end

  defp collate_results list do
    list
    |> Enum.map(fn (pid) ->
      receive do {^pid, result} -> result end
    end)
  end
end
