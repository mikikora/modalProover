open Syntax

let rec remove_duplicates lst =
  match lst with
  | [] -> []
  | hd :: tl ->
      hd :: (List.filter (function el -> el <> hd) @@ remove_duplicates tl)

let hyp rel ass jgmt =
  if List.mem jgmt ass then Hyp (rel, ass, jgmt)
  else failwith "no assumption matches goal"

let falsee new_jgmt th =
  let rel, ass, jgmt = destruct_th th in
  match (jgmt, new_jgmt) with
  | J (_, F), J (_, _) -> FalseE (th, (rel, ass, new_jgmt))
  | J (_, _), _ -> failwith "False is not in the judgement"
  | _, _ -> failwith "Can't use it on relation judgement"

let coni th1 th2 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2 in
  if rel1 <> rel2 then failwith "Can't build theorem with different relations"
  else
    match (jgmt1, jgmt2) with
    | J (x, p1), J (y, p2) ->
        if x = y then
          ConI
            ( th1,
              th2,
              (rel1, remove_duplicates @@ ass1 @ ass2, J (x, Con (p1, p2))) )
        else failwith "worlds don't match"
    | _ -> failwith "can't use coni on this judgements"

let cone1 th =
  let rel, ass, jgmt = destruct_th th in
  match jgmt with
  | J (x, Con (a, b)) -> ConE (th, (rel, ass, J (x, a)))
  | _ -> failwith "can't use cone on this judgement"

let cone2 th =
  let rel, ass, jgmt = destruct_th th in
  match jgmt with
  | J (x, Con (a, b)) -> ConE (th, (rel, ass, J (x, b)))
  | _ -> failwith "can't use cone on this judgement"

let alti1 prop th =
  let rel, ass, jgmt = destruct_th th in
  match jgmt with
  | J (x, p) -> AltI (th, (rel, ass, J (x, Alt (p, prop))))
  | _ -> failwith "can't use alti on this judgement"

let alti2 prop th =
  let rel, ass, jgmt = destruct_th th in
  match jgmt with
  | J (x, p) -> AltI (th, (rel, ass, J (x, Alt (prop, p))))
  | _ -> failwith "can't use alti on this judgement"

let alte th1 th2 th3 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2
  and rel3, ass3, jgmt3 = destruct_th th3 in
  if rel1 <> rel2 || rel2 <> rel3 then
    failwith "Can't build theorem with different relations"
  else
    match jgmt1 with
    | J (x, Alt (p1, p2)) ->
        if
          List.mem (J (x, p1)) ass2
          && List.mem (J (x, p2)) ass3
          && jgmt2 = jgmt3
        then
          let ass =
            List.filter (function v -> v <> J (x, p1)) (ass2 @ ass3)
          in
          AltE (th1, th2, th3, (rel1, remove_duplicates @@ ass1 @ ass, jgmt2))
        else failwith "can't use alte with this assumptions"
    | _ -> failwith "can't use alte on this judgement"

let impi left_jgmt th =
  let y, prop =
    match left_jgmt with
    | J (y, prop) -> (y, prop)
    | _ -> failwith "this judgement can't be used in implication"
  in
  let rel, ass, jgmt = destruct_th th in
  match jgmt with
  | J (x, p) ->
      if List.mem left_jgmt ass && x = y then
        ImpI
          ( th,
            ( rel,
              List.filter (function v -> v <> left_jgmt) ass,
              J (x, Imp (prop, p)) ) )
      else failwith "can't use impi with this proposition"
  | _ -> failwith "can't use impi on this judgement"

let impe th1 th2 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2 in
  if rel1 <> rel2 then failwith "Can't build theorem with different relations"
  else
    match (jgmt1, jgmt2) with
    | J (x, Imp (p1, p2)), J (y, p3) ->
        if x = y && p1 = p3 then
          ImpE (th1, th2, (rel1, remove_duplicates @@ ass1 @ ass2, J (x, p2)))
        else failwith "can't use impe with this judgement"
    | _ -> failwith "can't use impe on this judgement"

let boxi world th =
  let rel, ass, jgmt = destruct_th th in
  match jgmt with
  | J (y, p) ->
      let matching_assumptions = assumptions_with_world y ass in
      if matching_assumptions = [ R (world, y) ] then
        BoxI (th, (rel, ass, J (world, p)))
      else failwith "can't use boxi with this assumptions"
  | _ -> failwith " can't use boxi on this judgement"

let boxe world th1 th2 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2 in
  if rel1 <> rel2 then failwith "Can't build theorem with different relations"
  else
    match (jgmt1, jgmt2) with
    | J (x, Box p), R (y, world) ->
        if x = y then
          BoxE (th1, th2, (rel1, remove_duplicates @@ ass1 @ ass2, J (world, p)))
        else failwith "worlds don't match"
    | _ -> failwith "can't use boxe here"

let diai world th1 th2 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2 in
  if rel1 <> rel2 then failwith "Can't build theorem with different relations"
  else
    match (jgmt1, jgmt2) with
    | J (y, p), R (world, z) ->
        if y = z then
          DiaI
            ( th1,
              th2,
              (rel1, remove_duplicates @@ ass1 @ ass2, J (world, Dia p)) )
        else failwith "worlds don't match"
    | _ -> failwith "can't use diai here"

let diae y th1 th2 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2 in
  if rel1 <> rel2 then failwith "Can't build theorem with different relations"
  else
    match (jgmt1, jgmt2) with
    | J (x, Dia a), J (z, b) ->
        let matching_assumptions = assumptions_with_world y ass2 in
        if
          List.length matching_assumptions = 2
          && List.mem (R (x, y)) matching_assumptions
          && List.mem (J (y, a)) matching_assumptions
        then
          let ass2 =
            List.filter (function v -> v <> R (x, y) && v <> J (y, a)) ass2
          in
          DiaE (th1, th2, (rel1, remove_duplicates @@ ass1 @ ass2, J (z, b)))
        else failwith "can't use diae with this assumptions"
    | _ -> failwith "can't use diae here"

let seriality x y th =
  let rel, ass, jgmt = destruct_th th in
  if Relation.has_property Relation.Seriality rel then
    match jgmt with
    | J (z, prop) ->
        let matching_assumptions = assumptions_with_world y ass in
        if y = x || y = z || matching_assumptions <> [ R (x, y) ] then
          failwith "can't use seriality with this assumptions"
        else
          let new_ass = List.filter (function v -> v <> R (x, y)) ass in
          D (th, (rel, new_ass, jgmt))
    | _ -> failwith "can't use seriality here"
  else failwith "seriality can only be used with seriable relation"

let reflexivity x th =
  let rel, ass, jgmt = destruct_th th in
  if Relation.has_property Relation.Reflexivity rel then
    match jgmt with
    | J (y, prop) ->
        if assumptions_with_world x ass = [ R (x, x) ] then
          let new_ass = List.filter (function v -> v <> R (x, x)) ass in
          T (th, (rel, new_ass, jgmt))
        else
          failwith
            "There is no reflexive assumption with this world in the scope"
    | _ -> failwith "can't use reflexivity here"
  else failwith "reflexivity can only be used with reflexivitive relation"

let symmetry th1 th2 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2 in
  if rel1 = rel2 && Relation.has_property Relation.Symmetry rel1 then
    match (jgmt1, jgmt2) with
    | R (x, y), J (_, _) ->
        if List.mem (R (y, x)) ass2 then
          let new_ass2 = List.filter (function v -> v <> R (y, x)) ass2 in
          let new_ass = remove_duplicates @@ ass1 @ new_ass2 in
          B (th1, th2, (rel1, new_ass, jgmt2))
        else
          failwith
            "There is no symmetry assumption with this worlds in the scope"
    | _, _ -> failwith "can't use symmetry here"
  else
    failwith
      "Can't build theorem with different relations or with non symmetrical \
       relation"

let transitivity th1 th2 th3 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2
  and rel3, ass3, jgmt3 = destruct_th th3 in
  if
    rel1 = rel2 && rel2 = rel3
    && Relation.has_property Relation.Transitivity rel1
  then
    match (jgmt1, jgmt2, jgmt3) with
    | R (x, y1), R (y2, z), J (_, _) ->
        if y1 = y2 && List.mem (R (x, z)) ass3 then
          let new_ass3 = List.filter (function v -> v <> R (x, z)) ass3 in
          let new_ass = remove_duplicates @@ ass1 @ ass2 @ new_ass3 in
          Four (th1, th2, th3, (rel1, new_ass, jgmt3))
        else failwith "Premises can't build this rule"
    | _, _, _ -> failwith "can't use transitivity here"
  else
    failwith
      "Can't build theorem with different relations or with non transitive \
       relation"

let euclideanness th1 th2 th3 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2
  and rel3, ass3, jgmt3 = destruct_th th3 in
  if
    rel1 = rel2 && rel2 = rel3
    && Relation.has_property Relation.Euclideanness rel1
  then
    match (jgmt1, jgmt2, jgmt3) with
    | R (x1, y), R (x2, z), J (_, _) ->
        if x1 = x2 && List.mem (R (y, z)) ass3 then
          let new_ass3 = List.filter (function v -> v <> R (y, z)) ass3 in
          let new_ass = remove_duplicates @@ ass1 @ ass2 @ new_ass3 in
          Five (th1, th2, th3, (rel1, new_ass, jgmt3))
        else failwith "Premises can't build this rule"
    | _, _, _ -> failwith "can't use euclideanness here"
  else
    failwith
      "Can't build theorem with different relations or with non euclidean \
       relation"

let directedness w th1 th2 th3 =
  let rel1, ass1, jgmt1 = destruct_th th1
  and rel2, ass2, jgmt2 = destruct_th th2
  and rel3, ass3, jgmt3 = destruct_th th3 in
  if
    rel1 = rel2 && rel2 = rel3
    && Relation.has_property Relation.Euclideanness rel1
  then
    match (jgmt1, jgmt2, jgmt3) with
    | R (x1, y), R (x2, z), J (v, _) ->
        let matching_assumptions = assumptions_with_world v ass3 in
        if
          x1 = x2 && w <> x1 && w <> y && w <> z && w <> v
          && List.length matching_assumptions = 2
          && List.mem (R (y, w)) matching_assumptions
          && List.mem (R (z, w)) matching_assumptions
        then
          let new_ass3 =
            List.filter (function v -> v <> R (y, w) && v <> R (z, w)) ass3
          in
          let new_ass = remove_duplicates @@ ass1 @ ass2 @ new_ass3 in
          Two (th1, th2, th3, (rel1, new_ass, jgmt3))
        else failwith "Premises can't build this rule"
    | _, _, _ -> failwith "can't use directedness here"
  else
    failwith
      "Can't build theorem with different relations or with non directed \
       relation"
