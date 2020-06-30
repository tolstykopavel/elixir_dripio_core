defmodule Dripio.Trace do
  defmacro __using__(_opts) do
    quote do
      require Opencensus.Trace
      require Dripio.Trace
      alias Dripio.Trace
    end
  end

  def mfa(%Macro.Env{module: m, function: {f, a}}), do: "#{m}.#{f}/#{a}"

  defmacro wrap(label \\ nil, attributes \\ quote(do: %{}), do: block) do
    label = label || mfa(__CALLER__)

    quote do
      Opencensus.Trace.with_child_span unquote(label), unquote(attributes) do
        unquote(block)
      end
    end
  end
end
