defmodule CreditCardChecker.LayoutView do
  use CreditCardChecker.Web, :view
  def nav_pill(name, opts) do
    desired_path = Keyword.get(opts, :to)
    current_path = Keyword.get(opts, :current_path)
    inner = Phoenix.HTML.Link.link name, opts
    li_opts = if (desired_path == current_path) do
      "active"
    else
      ""
    end
    Phoenix.HTML.Tag.content_tag :li, inner, class: li_opts
  end
end
