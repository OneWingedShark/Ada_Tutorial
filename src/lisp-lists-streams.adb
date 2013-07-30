With Ada.Streams;

Separate (LISP.Lists)
Package Body Streams is
    Use Implementation, Ada.Streams;

    -- Unfortionately, because we're directly text-processing
    -- LISP, rather than processing a binary or a modified text-
    -- format, this means we need to do character-processing
    -- rather than the more simple method of reading in the
    -- elements as elements.

    -- For conformity's sake we will use SEPARATE for all subprograms here.
    function Input(
		   Stream : not null access Root_Stream_Type'Class)
		   return LIST is separate;

    procedure Output(
		     Stream : not null access Root_Stream_Type'Class;
		     Item   : in  LIST
		    ) is separate;

    -- Because reading is itself more complicated we will
    -- make the function itself SEPARATE.
    procedure Read(
		   Stream : not null access Root_Stream_Type'Class;
		   Item   : out LIST
		  ) is separate;

    -- Write is simple: wirte out the string representation of
    -- the list to the stream.
    procedure Write(
		    Stream : not null access Root_Stream_Type'Class;
		    Item   : in LIST
		   ) is separate;
End Streams;
