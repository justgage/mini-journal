open Core.Std
open Core.Out_channel
open CalendarLib
open Printf



let get_home_file name = 
  let homeOpt = Sys.getenv "HOME" in
  let fname = ".jrnl-" ^ name ^ ".md" in
  match homeOpt with
    | Some home -> home ^ "/" ^ fname
    | None -> "~/" ^ fname
;;

let file_append name entry = 
  let now = Printer.Calendar.to_string (Calendar.now ()) in
  let filename = get_home_file name in
  let outc = Core.Out_channel.create ~append:true filename in
  fprintf outc "%s: %s\n\n" now entry;
  Core.Out_channel.close outc
;;

let entry_add name entry =
  printf "Appending to: %s\n" name;
  file_append name entry
;; (* needs more *)

let spec =
  let open Command.Spec in
  empty
  +> anon ("name" %: string) (* anonomus entry *)
  +> anon ("entry" %: string)

let command = 
  Command.basic
  ~summary: "Add a jrnl entry :)"
  ~readme:(fun () -> "More detailed info")
  spec
  (fun name entry () -> entry_add name entry)

let () =
  Command.run ~version:"0.1" ~build_info:"RWO" command
