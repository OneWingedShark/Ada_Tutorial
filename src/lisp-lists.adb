With
Ada.Text_IO,
LISP.Strings,
LISP.Elements.Operations,
Ada.Characters.Handling,
Ada.Containers.Indefinite_Ordered_Maps;

Package body LISP.Lists is
   use Implementation;
   use type Ada.Containers.Count_Type;

    -- The constant SEPERATOR defines the seperator used, by
    -- default, in a list.
    -- The LISP 1.5 manual is available here:
    -- http://www.softwarepreservation.org/projects/LISP/book/LISP%201.5%20Programmers%20Manual.pdf
    -- Page 4 gives the comma-seperated list as equivelant the
    -- space seperated list.
   SEPARATOR : constant Standard.String := ", ";


    -- Reterns the first element of the list, if the list is empty it returns
    -- an Empty_Type element.
   Function Head(Input : List) Return LISP.Elements.Element is
      (if Input.Length = 0 then Create else Input.First_Element);


    -- Tail returns a copy of the list, less the first element.
   Function Tail(Input : List) Return List is
   begin
      Return Result : List:= Input.Copy do
         Result.Delete_First;
      End return;
   end Tail;


    -- To_String converts a list to its string representation.
    Function To_String  (Input : List) Return String is
	-- We define something to hold the string-
	-- representations of the individual elements, so we
	-- can construct the list's string.
	Type String_Set is Array(Positive Range <>) of Access Standard.String;

	-- Here we provide the function to convert the above
	-- into a single string, it's nested, overloaded, and
	-- recursive.
	Function To_String( S: String_Set ) Return String is
	begin
	    if S'Length = 0 then
		Return "";
	    else
		-- Below we create a subtype of the range we
		-- want to use in our array-slice; as you can
		-- see, the attributes used are:
		-- 	First, Last, and Succ.
		-- "Succ" for the successive element of a
		-- discrete type.
		declare
		    Subtype Tail is Positive Range
		      Positive'Succ(S'First)..S'Last;
		begin
		    -- Here we return the first element's value,
		    -- followed conditionally by a seperator,

		    -- and the recursive call to the function.
		    -- The conditional expression is new to
		    -- Ada 2012 and comes in the
		    -- (if/then[else])-flavor, and the (case)-
		    -- flavor; both must be in parenthises,
		    -- this is to distinguish them from normal
		    -- conditional statements.
		    Return S(S'First).All &
		    (if S'Length > 1 then SEPARATOR else "") &
		      To_String( S(Tail) );
		end;
	    end if;
	end To_String;

	-- Internal String level 2 (is2) performs the
	-- transformation of List's elements to a String_Set,
	-- and uses To_String to return the result.
	Function is2(Input : list) return Standard.string is
	    -- Strings declares a string_set of the appropriate
	    -- size, and temporarilly fills it with 'pointers'
	    -- to the empty string, further, note the use of
	    -- 'others' to denote an arbitrary range.
	    Strings : String_Set(1..Natural(Input.Length)):=
	      ( others => <> );
	begin
	    -- Here we get the strings of the individual elements.
	    for Index in Strings'Range loop
		declare
		    -- Here we type-cast to "Vector", to take
		    -- advantage of implicit-derefrencing,
		    -- after indexing the proper element.
		    Item : String:= Vector(Input)(Index).To_String;
		begin
		    -- ...and put the result into its proper place.
		    Strings(Index):= new String'( Item );
		end;
	    end loop;
	    -- After which we have the proper list.
	    Return To_String( Strings );
	end is2;

    begin
	-- Add the parenthises to the list's internal string.
	Return '(' & is2(Input) & ')';
    end To_String;

    -- Here we want to have the items contained in Elements
    -- and Strings directly visible. This will aid the
    -- readability of the text in the subprograms, as well as
    -- shortening the parameter types of some subprograms.
    Use LISP.Elements, LISP.Strings;


    -- Function_Type is merely a callback, the one we will use to define
    -- (and "register") functions in the interpreter.
    Type Function_Type is
	Not Null Access Function ( Input : List ) Return Elements.Element;

    -- The "Function_List_Pkg" paackages define a mappping of
    -- String to the appropriate functions (precompiled/
    -- internal, or user/external); I would like to use the
    -- ID_String as the Key, however a compiler-error in my
    -- compiler [GNAT GPL 2012 (20120509)] prevents that.
    --
    -- WORKAROUND:	All key insertions & retrievals be of type Name_String.
   Package Function_List_Pkg is new Ada.Containers.Indefinite_Ordered_Maps
     (  Key_Type	=> String,
        Element_Type	=> Function_Type
     );

    -- Like Function_List_Pkg this package is for associating
    -- functions with their names; in this case, however, the
    -- functions are actually lists which will be executed.
   Package User_Function_List_Pkg is new Ada.Containers.Indefinite_Ordered_Maps
     (  Key_Type	=> String,
        Element_Type	=> List
     );

    -- Dictionary is the variable, of the aforementioned type,
    -- which holds the actual string/function associations.
    System_Dictionary	:  Function_List_Pkg.Map;
    User_Dictionary	:  User_Function_List_Pkg.Map;

    -- Make Map & Cursor operations visible.
    Use Type
	Function_List_Pkg.Map,
	Function_List_Pkg.Cursor,
	User_Function_List_Pkg.Map,
	User_Function_List_Pkg.Cursor;

    Function Sys_Key_Exists(Name : ID_String) Return Boolean is
      ( System_Dictionary.Find(Name) /= Function_List_Pkg.No_Element );

    Function User_Key_Exists(Name : ID_String) Return Boolean is
      ( User_Dictionary.Find(Name) /= User_Function_List_Pkg.No_Element );


    -- Get_Function reterns the function associated with the
    -- given string; it has been renamed (1) for clarity in the
    -- program text when invoked, and (2) to provide a central
    -- place to edit should more error-checking or correction
    -- be needed than provided by Function_List_Pkg.Map.Element.
   Function Get_Function (Name: ID_String) Return Function_Type
	Renames System_Dictionary.Element;
   Function Get_Function (Name: ID_String) Return List
	Renames User_Dictionary.Element;



    -- Is Accessor returns true for functions accessiong list
    -- elemrnts; (CAR, CDR, and the abbreviations thereof:
    -- CAAR, CADR, CDAR, CDDR, etc.)
    Function Is_Accessor(S : ID_String) Return Boolean is
    begin
	Return	S'Length > 2	 AND
		S(S'First) = 'C' AND
		S(S'Last)  = 'R' AND
		(for all C of Get_Internals(S) => C in 'A' | 'D');
    end Is_Accessor;

    -- Handles detecting DEFINE statements.
    Function Is_Definition( Name : ID_String ) Return Boolean is
    ( Name = "DEFINE" );


    -- Evaluate is the heart of the interpreter.
   Function Evaluate(Input : List) Return List is
	Use Elements, Ada.Characters.Handling;
	Function_Name : String renames To_Upper(Input.Head.To_String);
    begin
	-- Check if Head is an executable name.
	if Input.Head.Get_Type in String_Type..Name_Type then
	    --Ada.Text_IO.Put_Line( "--DEBUG-- INTERNAL_FUNCTION: " &
	    --	 Internal_Function(Function_Name)'Img);

	    if Is_Accessor(Function_Name) then
		-- Here we execute the accessor to return the
		-- proper [sub]list from what we've been given.
		Return Result : List := Input.Tail do
		    -- We need to reverse the loop in order to
		    -- have the proper order; the manual gives
		    -- the example of "caddr" referencing the
		    -- third element of a list and in order to
		    -- do that we need to process the last
		    -- character first so that we get "the head
		    -- of the tail of the tail".
		    for C of reverse Get_Internals(Function_Name) loop
			case C is
			-- CAR returns the head.
			when 'A' => Result:= (if Result.Head.Get_Type = List_Type
						then Result.Head.As_List
						else Result.Head.To_List);
			-- CDR returns the tail.
			when 'D' => Result:= Result.Tail;
			when others => raise Program_Error;
			end case;
		    end loop;
		End return;
	    elsif Is_Definition(Function_Name) then
		-- Here is where we handle the user-defined functions.
		Handle_Definition:
		declare
		    -- This Function_Name hides the previous
		    -- Function_Name; if we needed that, we
		    -- could refrence it with the subprogram
		    -- name (i.e. Evaluate.Function_Name).
		    Function_Name : ID_String renames
		      To_Upper(Input.Tail.Head.To_String);
		    Function_Body : List renames Input.Tail.Tail;
		begin
		    User_Dictionary.Insert(
			     Key      => Function_Name,
			     New_Item => Function_Body
			    );
		    Return Create(Function_Name) & Create("Defined");
		End Handle_Definition;
	    elsif Sys_Key_Exists(Function_Name) then
		Handle_System_Function:
		begin
		    declare
			-- Get the function from the name, and execute it.
			F : Function_Type Renames Get_Function( Function_Name );
			E : Elements.Element Renames F(Input.Tail);
		    begin
			-- If the result is a list, return it, if not convert it.
			Return (if E.Get_Type = List_Type then
				   E.As_List
				   else
				   E.To_List);
		    end;

		    -- A CONSTRAINT_ERROR is raised when an
		    -- invalid key is given to a Map, the
		    -- following handles that by raising
		    -- the proper exception: UNDEFINED_ELEMENT.
		    -- NOTE:	This is a development artifact
		    --		that should be	removed, I am
		    --		leaving it as an example of
		    --		'converting' exceptions.
		Exception
		    When CONSTRAINT_ERROR => Raise Undefined_Element;
		end Handle_System_Function;
	    elsif User_Key_Exists(Function_Name) then
		Handle_User_Function:
		begin
		    -- Get the function from the name, and execute it.
		    Return Get_Function( Function_Name ).Evaluate;
		end Handle_User_Function;
	    else
		-- The function wasn't found in our dictionaries.
		Ada.Text_IO.Put_Line( "Unknown Function: " & Function_Name );
		Raise Undefined_Element;
	    end if;
	else
	    -- If the head is not executable, we return the list.
	    Return Input.Copy;
	end if;

    end Evaluate;

    -- Homoginized_list returns true when all elements of the
    -- given list are the same, false otherwise. This will be
    -- useful for aritimatic functions.
   Function Homoginized_List( Input : List ) Return Boolean is
      Use Type Elements.Data_Type;
      T : Elements.Data_Type Renames Input.Head.Get_type;
   begin
	-- If the Length of the list is less than two, then it
	-- must be homogenous, otherwise we have to test all
	-- elements of the list for the proper type.
      Return Input.Length < 2
        or else (For all E of Input => E.Get_Type = T);
   End Homoginized_List;

    -- Unfortionately, because we're directly text-processing
    -- LISP, rather than processing a binary or a modified text-
    -- format, this means we need to do character-processing
    -- rather than the more simple method of reading in the
    -- elements as elements.

    -- Because reading is itself more complicated we will
    -- make the function itself SEPARATE.
    procedure Read(
		    Stream : not null access Root_Stream_Type'Class;
		    Item   : out LIST
		  ) is separate;

--      procedure Read(
--  		    Stream : not null access Root_Stream_Type'Class;
--  		    Item   : out LIST
--  		  ) is
--  	Use ASCII, Ada.Characters.Handling, Ada.Streams.Stream_IO;
--
--  	Subtype Whitespace is Character Range NUL..' '
--  	  with Static_Predicate => Whitespace in NUL | HT..CR |  ' ';
--
--  	-- The following function gets the next non white-space character.
--  	function Get_Next_Character Return Character is
--  	begin
--  	    Return Result : Character:= ASCII.NUL do
--  		loop
--  		    Character'Read( Stream, Result );
--  		    Exit When Result not in Whitespace;
--  		end loop;
--  	    End return;
--
--  	Exception
--  	    When End_Error => Raise Parse_Error;
--  	end Get_Next_Character;
--
--      begin
--  	Null;
--      end Read;

    -- Write is simple: wirte out the string representation of
    -- the list to the stream.
    procedure Write(
		    Stream : not null access Root_Stream_Type'Class;
		    Item   : in LIST
		   )  is
    begin
	String'Write( Stream, Item.To_String );
    end Write;


    -- We want Operations to have the full-visibility for registering them.
   Use Elements.Operations; use LISP.Elements;
Begin
   System_Dictionary.Insert(Key      => "+",
                            New_Item => Plus'Access
                    );
   System_Dictionary.Insert(Key      => "-",
                            New_Item => Minus'Access
                    );
End LISP.Lists;
