exception Eof
exception InvalidToken of string Error.located * string

val create_from_file : in_channel -> string -> Lexing.lexbuf
val create_from_stdin : unit -> Lexing.lexbuf
val get_location : unit -> Error.location
val locate : 'a -> 'a Error.located
val token : Lexing.lexbuf -> Parser.token
