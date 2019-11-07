defmodule ExGitHub.ParserTest do
  @moduledoc false

  use ExUnit.Case, async: false

  alias ExGitHub.Parser

  test "correctly parses request params" do

    # When passing a single element list
    param = Parser.parse_request_params(follow: [995_719_891_624_673_280])
    assert param == [{"follow", "995719891624673280"}]
  end
end
