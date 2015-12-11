defmodule Pass.ConsumerSupervisor do
  use Supervisor

  def start do
    Supervisor.start_link(__MODULE__, :ok, name: ConsumerSupervisor)
  end

  def init(:ok) do
    {:ok, _} = Queue.start_link([])

    {cores, 0} = System.cmd("sysctl", ["-n", "hw.ncpu"]) 

    cores = cores|> String.rstrip |> String.to_integer
    #cores = 10_000
    children = Enum.map 1..cores, &(create_worker(&1))

    result = supervise(children, strategy: :one_for_one)
    #IO.puts "supervise children #{inspect children}"
    result
  end

  defp create_worker(id) do
    id = "#{__MODULE__}:worker_#{id}"
    worker(Pass.DecryptionConsumer, [], restart: :temporary, id: id)
  end
end
