defmodule Pass.Parallel do
  @doc ~S"""
  Parallelizes the calculation of `fun` mapped over `collection`

  ## Examples
    iex> Pass.Parallel.map([1,2], fn({e, _})-> e + 2 end)
    [3,4]
  """

  def map(collection, fun) do
    collection
    |> parallelize(self, fun)
    |> collate_results
  end

  defp parallelize(list, me, fun) do
    list
    |> Stream.with_index
    |> Stream.map &(calculate_individual(me, fun, &1))
  end

  defp calculate_individual(me, fun, function_args) do
    spawn_link fn -> send(me, {self, fun.(function_args)}) end
  end

  defp collate_results list do
    list
    |> Enum.map(fn (pid) ->
      receive do {^pid, result} -> result end
    end)
  end
end
