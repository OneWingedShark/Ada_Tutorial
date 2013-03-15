Package body LISP.Strings is

    -- Real is here for if/when floating-point support is added.
    SubType Real is Float Range Float'Range;

    ----------------------------
    --  FORWARD DECLARATIONS  --
    ----------------------------

    Generic
	-- Check_Type is a [near] arbitrary type; it refers to
	-- the type we wish to convert TO from a String.
	Type Check_Type is private;
	-- Here we assume that "Convert" is well-behaved, in
	-- that it will raise CONSTRAINT_ERROR on an error.
	With Function Convert(Item : String) Return Check_Type is <>;
    Function Validation(Item : in String) return Boolean
    with Pure_Function;

    --------------------------
    --  CONVERSION RENAMES  --
    --------------------------
    -- Yep, it is possible to rename attributes as functions,
    -- combining that with overloading and name-defaulting we
    -- can, in effect, have the 'Value attribute (for widely)
    -- differing types be passed to our generic instantiations
    -- as defaulted parameters.
    Function Convert(S : String) Return Integer
		Renames Integer'Value;
    Function Convert(S : String) Return Float
		Renames Real'Base'Value;

    ----------------------
    --  GENERIC BODIES  --
    ----------------------
    Function Validation(Item : in String) return Boolean is
	Dummy : Check_Type;
    begin
	-- Here we attempt to perform the conversion...
	Dummy := Convert(Item);
	-- If it works we return True...
	return True;
	-- if it doesn't then we need to catch the exceprion
	-- and return False.
    exception
	when CONSTRAINT_ERROR => return False;
    End Validation;

    ------------------------------
    --  GENERIC INSTANTIATIONS  --
    ------------------------------

	-- Note that the Convert parameter is omitted, it is
	-- being defaulted to the Convert function that matches.
    Function Integer_Validation is New Validation(
	Check_Type => Integer
	);

    Function Float_Validation is New Validation(
	Check_Type => Real
	);

    -------------------------
    --  SUBPROGRAM BODIES  --
    -------------------------

    Function Valid_Number( S : String ) Return Boolean
	Renames Integer_Validation;

    -- Valid_Name checks that the given string is a valid name.
    Function Valid_Name( S : String ) Return Boolean is
    begin
	-- A Valid name has the following attributes:
	-- (a) there no padding on the given string, because
	-- (b) every charaaracter is in the set {A..Z|0..9|'_'|'-'}, and
	-- (c) the first character is not numeric or dash.
	Return
		(for all Ch of S => Ch in ALPHA | Number | '_' | '-') and
		S(S'First) not in Number | '-' ;
    end Valid_Name;

    Function Valid_ID( S : String ) Return Boolean is
      (    (For all Ch of S => Ch not in ASCII.NUL..' ' | ASCII.DEL)
       and (For some Ch of S => ch not in NUMBER)
      );

    Function To_String( Item : Identifier  ) Return String is
      ( String'(Item.All) );

    Function To_Identifier( Item : ID_String ) Return Identifier is
      ( New ID_String'(Item) );

    -- Get_Internals returns the given string less the first
    -- and last character ex: "dave" => "av".
    Function Get_Internals(S : String) Return String is
    begin
	Return  S( Positive'Succ(S'First)..Positive'Pred(S'Last) );
    end Get_Internals;

end LISP.Strings;
