Separate (LISP.Lists.Streams)

procedure Read(
		Stream : not null access Root_Stream_Type'Class;
		Item   : out LIST
	      ) is
begin
    Item:= List'Input( Stream );
end Read;
