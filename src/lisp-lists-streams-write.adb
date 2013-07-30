Separate (LISP.Lists.Streams)
    procedure Write(
		    Stream : not null access Root_Stream_Type'Class;
		    Item   : in LIST
		   ) is
Begin
    String'Write( Stream, Item.To_String );
End Write;
