module Timetravel = struct
  open CalendarLib
  (* unix_dates are in seconds from some spesified date *)

  let add_seconds n unix_date =
    unix_date +. n

  let add_minutes n unix_date =
    add_seconds(n *. 60.0) unix_date

  let add_hours n unix_date =
    add_minutes (n *. 60.0) unix_date

  let add_days n unix_date =
    add_hours (n *. 24.0) unix_date

  let subtract_days n unix_date =
    add_days (-.n) unix_date

  (* This doesn't make sense. What if you go from a month with 31 days
   * and go to a month with 29 days? What happens then?*)
  (*
  let add_month unix_date =
    let date = Calendar.from_unixfloat unix_date in
  let days_in_month = Calendar.days_in_month date in
  add_days  unix_date
  *)

  let add_years n unix_date =
    add_days (n *. 365.0) unix_date
end
