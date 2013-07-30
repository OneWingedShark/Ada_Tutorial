Separate (LISP.Lists.Streams)
    procedure Output(
		     Stream : not null access Root_Stream_Type'Class;
		     Item   : in  LIST
		    ) is
Begin
    LIST'Write( Stream, Item );
End Output;
