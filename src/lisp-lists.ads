With
LISP.Elements,
Ada.Streams.Stream_IO,
Ada.Containers.Indefinite_Vectors;

Use All Type LISP.Elements.Element;

Package LISP.Lists is

    -- The following package, "implementation", is the
    -- instantiation of a generic package; a generic must be
    -- explicitly instantiated before its use in your program
    -- text, this is to ensure consistancy across compilations.
    Package Implementation is new Ada.Containers.Indefinite_Vectors
      (Index_Type => Positive,  Element_Type => LISP.Elements.Element);
    -- PS: The above is using named association, which can be helpful.

    -- The following line declares inheritance, with no
    -- extension to the data of the base object/class; there
    -- are, however, new 'methods' which are added below.
    Type LIST is new Implementation.Vector with null record
	with	Read  => Streams.Read,	Write  => Streams.Write,
		Input => Streams.Input,	Output => Streams.Output;

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

    package Streams is
	Use Ada.Streams;

	-- Testing GPS comment-binding.
	function Input(
		Stream : not null access Root_Stream_Type'Class)
		return LIST;

	procedure Output(
		  Stream : not null access Root_Stream_Type'Class;
		  Item   : in  LIST
		 );


	procedure Read(
		Stream : not null access Root_Stream_Type'Class;
		Item   : out LIST
	       );

	procedure Write(
		 Stream : not null access Root_Stream_Type'Class;
		 Item   : in LIST
		);
    end Streams;


    -- LIST'Read, LIST'Write, LIST'Output, and LIST'Input are
    -- all stream attributes that can be overriden by the user
    -- in order to interact with Streams.
    --	'Read & 'Write are the simpler, more primitive ones.
    --	'Input & 'Output are higet-level, used for composite types
    --	 they call 'Read/''Write to handle discriminants or bounds
    --	 first, then iterate over their components calling the
    --	 appropriate 'Read/'Write.
    --
    -- These functions are ptivate because the user can access
    -- them via LIST'Read, LIST'Write, etc stream operations.

--      function Input(
--  		    Stream : not null access Ada.Streams.Root_Stream_Type'Class)
--  	return  List renames Streams.Input;
--
--      procedure Output(
--  		    Stream : not null access Ada.Streams.Root_Stream_Type'Class;
--  		    Item   : in  List
--  		      ) renames Streams.Output;
--
--
--      procedure Read(
--  		    Stream : not null access Root_Stream_Type'Class;
--  		    Item   : out LIST
--  		  ) renames LISP.List_Streams.Read;
--
--      procedure Write(
--  		    Stream : not null access Root_Stream_Type'Class;
--  		    Item   : in LIST
--  		  ) renames LISP.List_Streams.Write;



    -- The two following comment lines are the old method of
    -- specifying custom subprograms be used for stream
    -- interaction:

    -- For LIST'Read  Use Read;
    -- For List'Write Use Write;

End Lisp.Lists;
