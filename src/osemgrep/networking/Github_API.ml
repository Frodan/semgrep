(* GitHub REST API *)

let find_branchoff_point_async caps ~gh_token ~api_url ~repo_name
    ~base_branch_hash head_branch_hash =
  let str = Auth.string_of_token gh_token in
  let headers = [ ("Authorization", Fmt.str "Bearer %s" str) ] in
  let%lwt response =
    Http_helpers.get ~headers caps#network
      (Uri.of_string
         (Fmt.str "%a/repos/%s/compare/%a...%a" Uri.pp api_url repo_name
            Digestif.SHA1.pp base_branch_hash Digestif.SHA1.pp head_branch_hash))
  in
  match response with
  | Ok { body = Ok body; _ } ->
      let body = body |> Yojson.Basic.from_string in
      let commit =
        Option.bind
          Glom.(
            get_and_coerce_opt string body [ k "merge_base_commit"; k "sha" ])
          Digestif.SHA1.of_hex_opt
      in
      Lwt.return commit
  | Ok { body = Error e; code; _ } ->
      Logs.err (fun m -> m "Github API returned an error code %d: %s" code e);
      Lwt.return_none
  | Error e ->
      Logs.err (fun m -> m "Failed to fetch branch off point: %s" e);
      Lwt.return_none
