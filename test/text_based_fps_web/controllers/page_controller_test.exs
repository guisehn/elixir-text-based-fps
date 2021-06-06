defmodule TextBasedFPSWeb.PageControllerTest do
  use TextBasedFPSWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Text-based FPS"
  end
end
