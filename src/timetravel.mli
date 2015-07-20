module Timetravel: sig
  (* type status =   *)
  (*   | Yes_entry a of string *)
  (*   | No_entry a of string *)
  (*   | Weekday *)
  val add_seconds : float -> float -> float
  val add_minutes : float -> float -> float
  val add_hours : float -> float -> float
  val add_days : float -> float -> float
  val subtract_days : float -> float -> float
  val subtract_weekdays : float -> float -> float
  val add_years : float -> float -> float
  val is_weekday : float -> bool
end
