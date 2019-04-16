defmodule Todo.CsvImporter do
  def import(file) do
    file
    |> read_lines
    |> create_entries
    |> Todo.List.new
  end

  defp read_lines(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
  end

  defp create_entries(lines) do
    lines
    |> Stream.map(&extract_fields/1)
    |> Stream.map(&create_entry/1)
  end

  defp extract_fields(line) do
    [date, title] = String.split(line, ",")
    {create_date(date), title}
  end

  defp create_date(date) do
    [y,m,d] =
      date
      |> String.split("/")
      |> Enum.map(&String.to_integer/1)
    {:ok, date} = Date.new(y,m,d);
    date
  end

  defp create_entry({date, title}) do
    %{date: date, title: title}
  end
end
