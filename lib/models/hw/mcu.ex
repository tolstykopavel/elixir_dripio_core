defmodule Dripio.MCU do
  alias Dripio.Device
  use Dripio.Trace

  def to_bits(code) when is_binary(code) do
    with {value, ""} <- Integer.parse(code) do
      for <<(x::1 <- <<value::16>>)>>, do: x
    else
      _ -> []
    end
  end

  def set_mcu_status(%{"id" => id}, mcu_status, mcu_error \\ nil) do
    Trace.wrap do
      with {:ok, device} <- Device.get_by_id(id) do
        old_errors = device.mcu_errors || []

        Device.set_device_data(
          device,
          %{
            mcu_status: mcu_status,
            mcu_errors:
              unless mcu_status do
                [Enum.join(to_bits(mcu_error))] ++ old_errors
              else
                []
              end
          },
          "Device #{id} MCU status is #{
            if mcu_status do
              "OK"
            else
              "error"
            end
          }"
        )
      end
    end
  end
end
