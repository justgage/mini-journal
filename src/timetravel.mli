module Timetravel: sig
  val add_seconds : float -> float -> float
  val add_minutes : float -> float -> float
  val add_hours : float -> float -> float
  val add_days : float -> float -> float
  val subtract_days : float -> float -> float
  val subtract_weekdays : float -> float -> float
  val add_years : float -> float -> float
  val is_weekday : float -> bool
  val weekday_range : int -> float -> float list
  val weekdays_to_date : early_date:float -> later_date:float -> float list 
end
