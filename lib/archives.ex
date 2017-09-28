defmodule MyMap do
  defmacro flat_two_map(list, func) do
    quote do
      times = round(Enum.count(unquote(list))/2)-1
      (for i <- 0..times do
        unquote(func).(
          Enum.at(unquote(list),i*2),
          Enum.at(unquote(list),i*2+1)
        )
      end) |> Enum.concat
    end
  end
  defmacro two_map(list, func) do
    quote do
      times = round(Enum.count(unquote(list))/2)-1
      for i <- 0..times do
        unquote(func).(
          Enum.at(unquote(list),i*2),
          Enum.at(unquote(list),i*2+1)
        )
      end
    end
  end
  defmacro second_map(list, func) do
    quote do
      times = Enum.count(unquote(list))-1
      for i <- 0..times do
        unquote(func).(
          Enum.at(unquote(list),i),
          Enum.at(unquote(list),i+1)
        )
      end
    end
  end
  defmacro mutual_map(list, func) do
    quote do
      times = Enum.count(unquote(list))-1
      for i <- 0..times do
        unquote(func).(
          Enum.at(unquote(list),i),
          Enum.at(unquote(list),i+1)
        )
      end
    end
  end
end

