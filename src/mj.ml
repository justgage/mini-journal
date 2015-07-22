open Core.Std
open Core.Out_channel
open CalendarLib
open Printf
open Timetravel

let dir_name = "mini-journal/"

let get_home () =
  let homeOpt = Sys.getenv "HOME" in
  match homeOpt with
    | Some home -> home ^ "/"
    | None -> failwith "Hmm... I can't seem to find your home folder! Are you on Windows?"

(* creates the folder if it doesn't exist* *)
let touch_folder name = Unix.mkdir_p ((get_home ()) ^ dir_name ^ name)

(** returns a string of the filename path *)
let file_name_path date name =
  let now_string = Printer.Calendar.sprint "%F-%a" date in
  let home = get_home () in
  let name = name ^ "/" in
  home ^ dir_name ^ name ^ now_string  ^ ".md"


(** Will append an entry to a file *)
let file_append name entry =
  touch_folder name;
  let now_string = Printer.Calendar.sprint "%r" (Calendar.now ()) in (* just the time *)
  let filename = file_name_path (Calendar.now ()) name in
  let outc = Core.Out_channel.create ~append:true filename in
  fprintf outc "**%s:** %s\n\n" now_string entry; (* entry text *)
  Out_channel.close outc


let use_editor editor =
  let filename = (Filename.temp_file "mini-journal" ".md") in
  let _ = Sys.command (editor ^ " " ^ filename) in
  let chan = In_channel.create filename in
  In_channel.input_all chan

let get_std_input () =
  printf "%s\n\n" "Push CTRL-D TWICE to end input, Push CTRL-C to cancel";
  flush stdout;
  In_channel.input_all In_channel.stdin

(* get's the editor name *)
let get_editor () =
  match Sys.getenv "EDITOR" with
  | Some editor_name -> use_editor editor_name
  | None -> printf "If you set you $EDITOR enviorment variable then this will use that"; get_std_input ()


type coverage = 
  | Found of float
  | Missing of float
  | Broken of float

type coverage_list = coverage list

let print_coverage name = List.iter ~f:(fun entry_coverage -> 
  match entry_coverage with
  | Found _ -> ()
  | Missing date -> printf "Missing entry: %s\n" 
                    (file_name_path (Calendar.from_unixfloat date) name)
  | Broken date -> printf "Missing entry? %s\n" 
                    (file_name_path (Calendar.from_unixfloat date) name)
  )

let rec check_coverage ndays name = 
  match ndays with
  | -1. -> []
  | n -> 
      let now = Calendar.now () |> Calendar.to_unixfloat in
      let before = Timetravel.subtract_weekdays n now in
      let fname = file_name_path (Calendar.from_unixfloat before) name in
        (match Sys.file_exists (fname) with
        | `Unknown -> Broken before
        | `Yes     -> Found before
        | `No      -> Missing before)
      :: check_coverage (ndays -. 1.0) name


(* let prompt_take_care =  *)



(** Will make a new entry*)
let entry_add name_opt entry_opt date =
  let entry = match entry_opt with
  | Some x -> x
  | None -> get_editor ()
      in
  let name = match name_opt with
  | Some x -> x
  | None -> "default"
  in (
    check_coverage 30.0 name |> print_coverage name;
  if String.equal (String.strip entry) "" then (
    printf "\nJournal entry was empty and so it wasn't saved\n";
    exit 0;
  ) else (
    let filename = file_name_path date name in (
      printf "journal entry added to: %s\n" filename;
    file_append name entry
  )
    )
  );;

let entry_add_today name_opt entry_opt =
  entry_add name_opt entry_opt (Calendar.now ())

(* this spesifies the command line interface *)
let spec =
  let open Command.Spec in
  empty
  +> flag "-c" (optional bool) ~doc: "coverage" (* anonomus entry *)
  +> flag "-n" (optional string) ~doc: "name of the jornal (makes a new one if it doesn't exist)" (* anonomus entry *)
  +> flag "-m" (optional string) ~doc: "Message of the entry" (* anonomus entry *)

let parse_args name_opt entry_opt () = entry_add_today name_opt entry_opt

let command =
  Command.basic
  ~summary: "This is mini-journal! It provides a git commit style journaling"
  ~readme:(fun () -> "This should have more detailed info... but it doesn't yet")
  spec
  parse_args

let () =
  Time_Zone.change Time_Zone.Local;
  Command.run ~version:"0.1" ~build_info:"RWO" command
