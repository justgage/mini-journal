open Core.Std
open Core.Out_channel
open CalendarLib
open Printf
open Timetravel

module Colors = struct
  let normal = "\027[0m"
  let colorize color str = "\027[" ^ color ^ "m" ^ str ^ normal
  let cyan = colorize "36"
  let red = colorize "31"
  let blue = colorize "34"
  let green = colorize "32"
  let yellow = colorize "33"
  let magenta = colorize "35"
end

let dir_name = "mini-journal/"

let get_home () =
  let homeOpt = Sys.getenv "HOME" in
  match homeOpt with
    | Some home -> home ^ "/"
    | None -> failwith "Hmm... I can't seem to find your home folder! Are you on Windows?"

(* creates the folder if it doesn't exist* *)
let touch_folder name = Unix.mkdir_p ((get_home ()) ^ dir_name ^ name)

let mj_dir () = (get_home ()) ^ dir_name

(** returns a string of the filename path *)
let file_name_path date name =
  let now_string = Printer.Calendar.sprint "%F-%a" date in
  let home = get_home () in
  let name = name ^ "/" in
  home ^ dir_name ^ name ^ now_string  ^ ".md"

(** Will append an entry to a file *)
let file_append name entry date =
  touch_folder name;
  let now_string = Printer.Calendar.sprint "%r" date in (* just the time *)
  let filename = file_name_path date name in
  let outc = Core.Out_channel.create ~append:true filename in
  fprintf outc "**%s:** %s\n\n" now_string entry; (* entry text *)
  Out_channel.close outc


let use_editor editor date_str =
  let filename = (Filename.temp_file date_str ".md") in
  let _ = Sys.command (editor ^ " " ^ filename) in
  let chan = In_channel.create filename in
  In_channel.input_all chan

let get_std_input () =
  printf "%s\n\n" "Push CTRL-D TWICE to end input, Push CTRL-C to cancel";
  flush stdout;
  In_channel.input_all In_channel.stdin

(* get's the editor name *)
let get_editor date_str =
  match Sys.getenv "EDITOR" with
  | Some editor_name -> use_editor editor_name date_str
  | None -> printf "If you set you $EDITOR enviorment variable then this will use that\n %s " date_str; get_std_input ()


type coverage = 
  | Found of float
  | Missing of float
  | Broken of float

type coverage_list = coverage list

let print_coverage name =  List.iter ~f:(fun entry_coverage -> 
  let date_name x = (Calendar.from_unixfloat x |> (Printer.Calendar.sprint "%b %d, %Y  %a") ) in
  match entry_coverage with
  | Found date   -> printf "%s  %s\n" (Colors.green "✔") (Colors.magenta @@ date_name date )
  | Missing date -> printf  "   %s\n" (date_name date)
  | Broken date -> printf  "%s  %s\n" "?" (Colors.red @@ date_name date )
  )

let check_coverage_date first_date name = 
  let now = Calendar.now () |> Calendar.to_unixfloat in
  (Timetravel.weekdays_to_date ~early_date:first_date ~later_date:now)
  |> List.map 
  ~f:(fun date -> 
      let fname = file_name_path (Calendar.from_unixfloat date) name in
      (match Sys.file_exists (fname) with
        | `Unknown -> Broken date
        | `Yes     -> Found date
        | `No      -> Missing date)
      )

let check_coverage ndays name = 
  let now = Calendar.now () |> Calendar.to_unixfloat in
  Timetravel.weekday_range ndays now
  |> List.map ~f:
    (fun date -> 
      let fname = file_name_path (Calendar.from_unixfloat date) name in
      (match Sys.file_exists (fname) with
        | `Unknown -> Broken date
        | `Yes     -> Found date
        | `No      -> Missing date)
      )

(* let prompt_take_care =  *)


let def_name name_opt =
  match name_opt with
  | Some x -> x
  | None -> "default"

(** Will make a new entry*)
let entry_add name_opt entry_opt date =
  let entry = match entry_opt with
  | Some x -> x
  | None -> get_editor (Printer.Calendar.sprint "%F-%a" date)
      in
  let name = def_name name_opt 
    in (
  if String.equal (String.strip entry) "" then (
    printf "\nJournal entry was empty and so it wasn't saved\n";
    exit 0;
  ) else (
    let filename = file_name_path date name in (
      printf "journal entry added to: %s\n" filename;
    file_append name entry date
  )
    )
  );;

let entry_add_today name_opt entry_opt =
  entry_add name_opt entry_opt (Calendar.now ())

let entry_add_missing days name = 
  check_coverage days name 
  |> List.iter ~f:(fun entry_coverage -> 
  match entry_coverage with
  | Found _   -> ()
  | Broken _  -> ()
  | Missing date -> entry_add (Some name) None (Calendar.from_unixfloat date)
  )

(* this spesifies the command line interface *)
let spec =
  let open Command.Spec in
  empty
  +> flag "first-day" (optional bool) ~doc: "coverage (days span)"
  +> flag "coverage" (optional int)   ~doc: "coverage (days span)"
  +> flag "push" (optional bool)      ~doc: "(bool) git push"
  +> flag "cu" (optional int)         ~doc: "(days span) coverage catch up "
  +> flag "name" (optional string)    ~doc: "name of the jornal (makes a new one if it doesn't exist)" (* anonomus entry *)
  +> flag "message" (optional string) ~doc: "Message of the entry" (* anonomus entry *)

let parse_args first_op coverage_opt push_opt coverage_catchup_opt name_opt entry_opt () = 
  let first_day = ((Printer.Calendar.from_string "2015-05-26 23:24:08") |> Calendar.to_unixfloat ) in
  match push_opt with
  | Some true -> 
      printf "Syncing... %s" (get_home ());
      Sys.chdir (mj_dir ());
      let _ = Sys.command "git add ." in
      let _ = Sys.command "git commit -m 'save entries'" in 
      let _ = Sys.command "git push" in
      printf "Synced to via git\n"
  | Some false | None -> 
      let name = (def_name name_opt) in

  match coverage_catchup_opt with (* if we only check coverage *)
  | Some days -> entry_add_missing days name
  | None -> 

  match first_op with (* if we only check coverage *)
  | Some x ->
    (check_coverage_date first_day name) |> print_coverage name
  | None -> 

  match coverage_opt with (* if we only check coverage *)
  | Some x -> 
      check_coverage x name |> print_coverage name
  | None -> entry_add_today name_opt entry_opt


let command =
  Command.basic
  ~summary: "This is mini-journal! It provides a git commit style journaling"
  ~readme:(fun () -> "This should have more detailed info... but it doesn't yet")
  spec
  parse_args

let () =
  Time_Zone.change Time_Zone.Local;
  Command.run ~version:"0.1" ~build_info:"RWO" command
