defmodule Forum.CommentView do
  use Forum.Web, :view

  def time_ago_in_words(ecto_datetime) do
    {:ok, date} =  Ecto.DateTime.dump(ecto_datetime)
    
    date
      |> Timex.DateTime.from()
      |> Timex.from_now
  end
end