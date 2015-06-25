open Core.Std
open Core.Out_channel
open CalendarLib
open Printf

let dir_name = "mini-journal/";;

let get_home () =
  let homeOpt = Sys.getenv "HOME" in
  match homeOpt with
    | Some home -> home ^ "/"
    | None -> "~/" (* we can only hope *)
;;

(* creates the folder if it doesn't exist* *)
let touch_folder name = Unix.mkdir_p ((get_home ()) ^ dir_name ^ name);;

(** returns a string of the filename path *)
let file_name_path name = 
  let now_string = Printer.Calendar.sprint "%F-%a" (Calendar.now ()) in
  let home = get_home () in
  let name = name ^ "/" in
  home ^ dir_name ^ name ^ now_string  ^ ".md"
;;

(** Will append an entry to a file *)
let file_append name entry = 
  touch_folder name;
  let now_string = Printer.Calendar.sprint "%r" (Calendar.now ()) in (* just the time *)
  let filename = file_name_path name in
  let outc = Core.Out_channel.create ~append:true filename in
  fprintf outc "**%s:** %s\n\n" now_string entry; (* entry text *)
  Core.Out_channel.close outc
;;

(** Will make a new entry*)
let entry_add name_opt entry =
  let name = match name_opt with
  | Some x -> x
  | None -> "default"
  in
  let filename = file_name_path name in
  printf "journal entry added to: %s\n" filename;
  file_append name entry
;;

let spec =
  let open Command.Spec in
  empty
  +> flag "-n" (optional string) ~doc: "name of the jornal (makes a new one if it doesn't exist)" (* anonomus entry *)
  +> anon ("message" %: string) (* ~doc: "message of the entry" *)

let command = 
  Command.basic
  ~summary: "This is mini-journal! It provides a git commit style journaling"
  ~readme:(fun () -> "This should have more detailed info... but it doesn't yet")
  spec
  (fun name message () -> entry_add name message)

let () =
  Time_Zone.change Time_Zone.Local;;
  Command.run ~version:"0.1" ~build_info:"RWO" command
