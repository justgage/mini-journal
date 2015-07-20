module Timetravel = struct
  open CalendarLib
  (* float_dates are in seconds from some spesified date *)

  let add_seconds n float_date =
    float_date +. n

  let add_minutes n float_date =
    add_seconds(n *. 60.0) float_date

  let add_hours n float_date =
    add_minutes (n *. 60.0) float_date

  let add_days n float_date =
    add_hours (n *. 24.0) float_date

  let subtract_days n float_date =
    add_days (-.n) float_date

  let is_weekday float_date = 
    let wday = float_date 
                |> Calendar.from_unixfloat
                |> Calendar.day_of_week
    in (* note <> stands for inequality *)
    wday <> Calendar.Sat && wday <> Calendar.Sun (* && wday != 6 *)

let rec subtract_weekdays n float_date =
  let date = add_days (-.n) float_date in
  if is_weekday date then
    date
  else
    subtract_weekdays 1.0 date


  (* This doesn't make sense. What if you go from a month with 31 days
   * and go to a month with 29 days? What happens then?*)
  (*
  let add_month float_date =
    let date = Calendar.from_unixfloat float_date in
  let days_in_month = Calendar.days_in_month date in
  add_days  float_date
  *)

  let add_years n float_date =
    add_days (n *. 365.0) float_date
end
