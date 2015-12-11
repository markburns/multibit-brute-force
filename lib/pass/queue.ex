defmodule Queue do
  use GenServer

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: Queue)
  end

  def enqueue(item) do
    GenServer.cast(Queue, {:enqueue, item})
  end

  def dequeue do
    GenServer.call(Queue, :dequeue)
  end

  # Callbacks
  def handle_call(:dequeue, _from, state) do
    last = List.last(state)
    {:reply, last, List.delete(state, last)}
  end

  def handle_cast({:enqueue, item}, state) do
    {:noreply, [item|state]}
  end
end
