With
LISP.Elements,
Ada.Streams.Stream_IO,
Ada.Containers.Indefinite_Vectors;

Use All Type LISP.Elements.Element;

Package LISP.Lists is

    -- The following package, "implementation", is the
    -- instantiation of a generic package; a generic must be
    -- explicitly instantiated before its use in your program
    -- text.
    Package Implementation is new Ada.Containers.Indefinite_Vectors
      (Index_Type => Positive,  Element_Type => LISP.Elements.Element);
    -- PS: The above is using named association, which can be helpful.

    -- The following line declares inheritance, with no
    -- extension to the data of the base object/class; there
    -- are, however, new 'methods' which are added below.
    Type LIST is new Implementation.Vector with null record
	with Read => Read, Write => Write;
    -- For some reason, the subtype-rename causes an error on
    -- visibility; therefore, the type-extension above is used.
    --     SubType List is Implementation.Vector;

    -- Primitive operations are those subprograms which
    -- interact with a type and are declared before the type is
    -- frozen. (Read as: in the same declaring unit, before
    -- some point which the compiler must commit to a type.)
    --
    -- The following are primitive operations for LIST.
    Function Evaluate(Input : List) Return List;
    Function Head(Input : List) Return LISP.Elements.Element;
    Function Tail(Input : List) Return List;
    Function To_String  (Input : List)   Return String;
    Function Homoginized_List( Input : List ) Return Boolean;

Private
    Use Implementation, Ada.Streams;

    -- Read and Write are ptivate because the user can access
    -- them via LIST'Read and LIST'Write stream operations.

    procedure Read(
		    Stream : not null access Root_Stream_Type'Class;
		    Item   : out LIST
		  );

    procedure Write(
		    Stream : not null access Root_Stream_Type'Class;
		    Item   : in LIST
		  );

    -- The two following comment lines are commented out until
    -- parsing is handled in the tutorial.

    -- For LIST'Read  Use Read;
    -- For List'Write Use Write;

End Lisp.Lists;
