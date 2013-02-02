With
Ada.Characters.Handling;

Private with LISP.Strings;

Limited with LISP.Lists;

Package LISP.Elements is

    -- Data_Type is the enumeration of the various types that an
    -- Element might contain; the values are self-explanitory.
    Type Data_Type is (Empty_Type,
		       Integer_Type,
		       String_Type, Name_Type,
		       List_Type);

    -- These subtypes are useful for determining classes of the element.
    -- Assuming X is value of Data_Type, they can be used as follows:
    --		if X in Atomic then [...]
    SubType Non_Empty is Data_Type Range
      Data_Type'Succ(Data_Type'First)..Data_Type'Last;
    SubType Atomic is Non_Empty Range
      Data_Type'Succ(Non_Empty'First)..Non_Empty'Last;


    -- Element is the data-type which our lists contain.
    -- This is the publicly visible declaration, the keyword
    -- PRIVATE indicates that its internal structure is not
    -- publicly available and shouldn't be depended on by
    -- client packages, the keyword TAGGED indicates that it
    -- is extensible (a 'class' in C++ termonology).
    Type Element(<>) is tagged private;

    -- Various functions to create an element.
    Function Create			  Return Element;
    Function Create( Item : Integer	) Return Element;
    Function Create( Item : Lists.List	) Return Element;
    Function Create( Item : String;
		     Identifier : Boolean := False ) Return Element;

    -- Returns the Element's value as a string.
    Function To_String(Item: Element) return String;

    -- Returns the type of the element.
    Function Get_Type (Item: Element) return Data_Type;

    -- Various functions producing a list from an element.
    Function To_List  (Item: Element) return Lists.LIST;
    Function As_List  (Item: Element) return Lists.LIST;

    -- The same as To_String, but without quotes.
    Function To_Identifier(Item: Element) return String;


Private
    Use LISP.Strings;

    -- This completes the type-definition for Element.
    -- It is discriminated by a Data_Type value, which is
    -- used to create different internal structures by the
    -- use of the Case inside the record.
    Type Element( Data : Data_Type ) is tagged record
	Case Data is
	when Empty_Type   => Null;
	when Integer_Type => Int_Val  : Integer;
	when Name_Type    => Name_val : Identifier;
	when String_Type  => Str_val  : not null access Standard.String;
	when List_Type    => List_Val : Not Null Access LISP.Lists.List'Class;
	End case;
    End Record;

    ----------------------------------------------------------
    -- Private specifications; in case we need to move the  --
    -- implementation to the body, these will allow us to   --
    -- keep everything else here unchanged as it preserves  --
    -- the visibility to child packages.                    --
    ----------------------------------------------------------

    -- These Value functions overload the name "Value", which
    -- accesses the internal value of the Element, this allows
    -- for the child packages to have generics that refer to
    -- the internal field (which has a different name for each)
    -- as a default.
    Function Value( E: Element ) Return Integer;
    Function Value( E: Element ) Return String;

    -- Expression-Functions as completions.
    Function Value( E: Element ) Return Integer is
      ( E.Int_val );
    Function Value( E: Element ) Return String  is
      ( if E.Data = String_Type then E.Str_val.all else To_String(E.Name_Val) );
    Function Create Return Element is
      ( Data => Empty_Type );
    Function Get_Type (Item: Element) return Data_Type is
      ( Item.Data );

End Lisp.Elements;
