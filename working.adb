-- 'With' introduces a compilation unit dependency to this compilation unit;
-- it's roughly analogous to the 'using' of C#... except that it doesn't alter
-- visibility.
-- Note: a compilation unit is a procedure, function, or package.
With
LISP.Lists,
LISP.Elements,
Ada.Streams.Stream_IO, Ada.Text_IO.Text_Streams,
Ada.Text_IO;      -- Ada.Text_IO: exactly what it says.

-- This names the current compilation unit "working".
Procedure Working is

    Function Open( File_Name : String ) Return Ada.Text_IO.File_Type is
	Use Ada.Text_IO;
    begin
	Return Result : File_Type do
	    Open(File => Result,
		      Mode => In_File,
		      Name => File_Name
	 	);
	End return;
    end;

    Output_Stream : Ada.Text_IO.Text_Streams.Stream_Access :=
      Ada.Text_IO.Text_Streams.Stream( Ada.Text_IO.Standard_Output );

    Input_Stream :  Ada.Text_IO.Text_Streams.Stream_Access :=
      Ada.Text_IO.Text_Streams.Stream( Open("test.lsp") );

   -- Stubs for Read, Eval, and Print.

   -- Hack to terminate the loop; we will replace this later, with an
   -- orderly shutdown-mechanism.
   Loop_Count : Positive:= 1;

    Use LISP.Lists, LISP.Elements;

    -- Our working list.
    Working : List;

--      Procedure Read is
--      begin
--  	-- Artificial input, placeholder until we get to parsing.
--  	Working.Append( Create( Loop_Count ) );
--      end Read;
Procedure Read is
	Function Create_ID( ID : String ) Return LISP.Elements.Element is
	  ( Create( Item => ID, Identifier => True) );
begin
  case Loop_Count is
    When 8  => Working.Prepend( Create_ID("+") );
    When 10 => Working:= Create_ID("define") &
                          Create_ID("bob") &
                          Create_ID("car") &
                          Create(
                            Create("Fire") &
                            Create("Ice") &
                            Create("Air")
                          );
              -- Above: (DEFINE BOB CAR ("Fire" "Ice" "Air"))
              -- Result: BOB => ("Fire" "Ice" "Air")
    When Others => Working.Append( Create( Loop_Count ) );
  end case;
end Read;


    Procedure Eval is
    begin
	-- Eval replaces our working list with the result of the evaluation.
	Working:= Working.Evaluate;
    end Eval;

    Procedure Print is
    begin
	-- To print we simply pass to Put_Line the result of Working.To_String
	-- Note:  When working with tagged-types we may use an alternitive to
	--        the more common object-dot-method; it can be called just like
	--        the subprogram it is.
	Ada.Text_IO.Put_Line( To_String(Working) );
    end Print;

    Sub_Loop : array (Positive Range <>) of Not Null Access Constant String:=
      ( New String'("car"), New String'("cdr"), New String'("cadr"),
        New String'("cdar"), New String'("caddr"), New String'("BOB") );

Begin
   -- We can name loops, and declaration blocks, this allows for stability when
   -- adding or deleting them, as is common when altering algorithms. This can
   -- help because instead of numbering the constructs to 'break', the exit is
   -- tied to the loop that it is associated with.
   --
   -- EXAMPLE:  Below we name the Read-Eval-Print Loop as "REPL".
   REPL:
   loop
      -- Here we use an attribute, "image", to obtain the string-value of the
      -- counter. All discrete types, including enumerations, have this.
      Ada.Text_IO.Put_Line("[Count:" & Positive'Image(Loop_Count) & ']');
      -- Call read, eval, and print: this is the 'heart' of our interpreter.
      Read;
      Eval;
      Print;
	-- Testing functions -- Between the call to print and the loop's exit.
	if Loop_Count = 10 then
	    Working:= Create("A") & Create("B") & Create("C");
	    For E of Sub_Loop loop
		declare
		    Use Type LISP.Lists.Implementation.Vector;
		    Temp : LIST := Create(E.All, True) & Working.Copy;
		    Use Ada.Text_IO;
		begin
		    Put_Line( ASCII.HT & Temp.To_String );
		    Temp:= Temp.Evaluate;
		    Put_Line( E.All & ASCII.HT & "=>" & Temp.To_String );
		end;
	    End loop;
	end if;
      -- Set up the exit-condition; the name is optional but useful when dealing
      -- with nested loops.
      Exit REPL when Loop_Count = 10;
      -- Update the loop-counter;
      Loop_Count:= Loop_Count + 1;
   end loop REPL;

    Ada.Text_IO.Put_Line( "Stream output of Working:" );
    LIST'Write( Output_Stream, Working );
    Ada.Text_IO.New_Line;

    Ada.Text_IO.Put_Line( "Stream input of Working:" );
    LIST'Read( Input_Stream, Working );
    LIST'Write( Output_Stream, Working );
    Ada.Text_IO.New_Line;


   -- Print some text to indicate an orderly shutdown was achieved.
   Ada.Text_IO.Put_Line( "Goodbye." );

End Working;
