defmodule DripioCore.State do
  use GenServer

  alias DripioCore.State.AccountConfirmation
  alias DripioCore.State.PasswordReset

  def start_link(state \\ %{}) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(_state \\ %{}) do
    state =
      for module <- [AccountConfirmation, PasswordReset] do
        {module.key(), module.init()}
      end
      |> Enum.into(%{})

    iterate()

    {:ok, state}
  end

  #

  def handle_call({module, :get, params}, _from, state) do
    result = module.get(params, Map.get(state, module.key()))

    {:reply, result, state}
  end

  def handle_cast({module, :put, params}, state) do
    result = module.put(params, Map.get(state, module.key()))

    state = Map.put(state, module.key(), result)

    {:noreply, state}
  end

  #

  def handle_info(:validate, state) do
    state =
      for {key, data} <- state do
        {key, data.module.validate(data)}
      end
      |> Enum.into(%{})

    iterate()
    {:noreply, state}
  end

  #

  defp iterate() do
    loop_delay = Application.get_env(:dripio_core, :loop_delay)
    Process.send_after(self(), :validate, loop_delay)
  end

  def put_value(module, value) do
    GenServer.cast(__MODULE__, {module, :put, value})
  end

  def get_value(module, value) do
    GenServer.call(__MODULE__, {module, :get, value})
  end
end
