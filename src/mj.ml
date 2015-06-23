open Core.Std
open Core.Out_channel
open CalendarLib
open Printf

(** returns a string of the filename path *)
let file_name_path name = 
  let homeOpt = Sys.getenv "HOME" in
  let fname = ".jrnl-" ^ name ^ ".md" in
  match homeOpt with
    | Some home -> home ^ "/" ^ fname
    | None -> "~/" ^ fname
;;

(** Will append an entry to a file *)
let file_append name entry = 
  let now = Printer.Calendar.sprint "%b %d %Y %a" (Calendar.now ()) in
  let filename = file_name_path name in
  let outc = Core.Out_channel.create ~append:true filename in
  fprintf outc "%s: %s\n\n" now entry; (* entry text *)
  Core.Out_channel.close outc
;;

(** Will make a new entry*)
let entry_add name_opt entry =
  let name = match name_opt with
  | Some x -> x
  | None -> "default"
  in
  printf "Appending to: %s\n" name;
  file_append name entry
;;

let spec =
  let open Command.Spec in
  empty
  +> flag "-n" (optional string) ~doc: "name of the jornal (makes a new one if it doesn't exist)" (* anonomus entry *)
  +> flag "-m" (required string) ~doc: "message of the entry"

let command = 
  Command.basic
  ~summary: "Add a jrnl entry :)"
  ~readme:(fun () -> "More detailed info")
  spec
  (fun name entry () -> entry_add name entry)

let () =
  Command.run ~version:"0.1" ~build_info:"RWO" command
