type kind =
  (* The good one, should be reported (TP) *)
  | Ruleid
  (* Those should *not* be reported (TN) *)
  | Ok
  (* Should be reported but are not because of current engine limitations (FN) *)
  | Todoruleid
  (* Are reported but should not (FP) *)
  | Todook
[@@deriving show]

(* ex: "#ruleid: lang.ocaml.do-not-use-lisp-map" *)
type t = kind * Rule_ID.t [@@deriving show]

(* just to get a show_annotations *)
type annotations = t list [@@deriving show]

(* starts at 1 *)
type linenb = int

val annotations : Fpath.t -> (t * linenb) list

val group_positive_annotations :
  (t * linenb) list -> (Rule_ID.t, linenb list) Assoc.t

val filter_todook : (t * linenb) list -> linenb list -> linenb list
