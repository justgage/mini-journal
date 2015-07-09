module Timetravel: sig
  val add_seconds : float -> float -> float
  val add_minutes : float -> float -> float
  val add_hours : float -> float -> float
  val add_days : float -> float -> float
  val subtract_days : float -> float -> float
  val add_years : float -> float -> float
  val is_weekday : float -> bool
end
