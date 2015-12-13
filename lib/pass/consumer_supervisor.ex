defmodule Pass.ConsumerSupervisor do
  use Supervisor
  require Logger

  def start do
    Supervisor.start_link(__MODULE__, :ok, name: ConsumerSupervisor)
  end

  def init(:ok) do
    Application.stop(Queue)
    Application.stop(Progress)

    Pass.Progress.start
    Queue.start_link []

    {cores, 0} = System.cmd("sysctl", ["-n", "hw.ncpu"]) 

    cores = cores |> String.rstrip |> String.to_integer
    children = Enum.map 1..cores, &(create_worker(&1))

    result = supervise(children, strategy: :one_for_all, restart: :temporary)
    Logger.debug "supervise children #{inspect children}"
    result
  end

  defp create_worker(id) do
    id = "#{__MODULE__}:worker_#{id}"
    worker(Pass.DecryptionConsumer, [], id: id)
  end
end
