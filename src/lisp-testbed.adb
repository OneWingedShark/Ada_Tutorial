With
LISP.Elements,
LISP.Lists,
Ada.Text_IO;

Procedure LISP.Testbed is

   Use LISP.Lists, LISP.Elements;

   -----------------------------
   --  Forward  Declarations  --
   -----------------------------

   -- Terminate the execution of the testbed function.
   Procedure Exit_Testbed with inline;

   -- Read input from the INPUT stream.
   Procedure Read;

   -- Executes the data read from the INPUT stream.
   Procedure Eval;

   -- Write the data to the OUTPUT stream.
   Procedure Print;

   Function Count Return Positive;

   ------------------------
   --  State  Variables  --
   ------------------------

   -- Flag for the orderly termination of the Read-Eval-Print loop.
   Terminated : Boolean := False;

   -- Working list
   Working : List;

   -- Stream accesses for the input and output.
--   INPUT  : Stream_Access:= Stream( Ada.Text_IO.Standard_Input );
--   OUTPUT : Stream_Access:= Stream( Ada.Text_IO.Standard_Output );

   Procedure Exit_Testbed is
   begin
      Terminated:= True;
   end Exit_Testbed;


   -- Reading Long Strings Using Recursion (Martin C. Carlisle)
   function Next_Line(File : in Ada.Text_IO.File_Type :=
                        Ada.Text_Io.Standard_Input) return String is
      Answer : String(1..256);
      Last   : Natural;
   begin
      Ada.Text_IO.Get_Line(File => File,
                           Item => Answer,
                           Last => Last);
      if Last = Answer'Last then
         return Answer & Next_Line(File);
      else
         return Answer(1..Last);
      end if;
   end Next_Line;


   Procedure Read is
--      Temp : String:= Next_Line;
   begin
--    Ada.Text_IO.Put('['&Enclosing_Entity&']');
      --LIST'Read( INPUT, Working );
	case Count is
	When 8 | 3		=> Working.Prepend( Create("+", Identifier => True));
	--When 3 | 5 | 6	=> Working:= Create(Count) & Create(Working);
	When 1 		=> Declare
			    Insertion_List : Constant List:= Create("car") &
		  		Create(Create("Fire") & Create("Ice") & Create("Air"));
			   Begin
				Working:= Create("define") & Create("bob") &
						Insertion_List;
			   End;
	When Others    => Working.Append( Create( Count ) );
         --Append( Create(Create( 128 ) & Create( "Bob" )) );
	end case;
      null;
   end Read;

   Procedure Eval is
   begin
--        Ada.Text_IO.Put('['&Enclosing_Entity&']');
      Ada.Text_IO.Put( To_String(Working) & " => ");
      Working:= Working.Evaluate;
   end Eval;

   Procedure Print is
   begin
--      Ada.Text_IO.Put('['&Enclosing_Entity&']');
      Ada.Text_IO.Put_Line( To_String(Working) );
   end Print;

   Loop_Count : Positive:= 11;

   Function Count Return Positive is
     ( Loop_Count );

    Sub_Loop : array (Positive Range <>) of Not Null Access Constant String:=
      ( New String'("car"), New String'("cdr"), New String'("cadr"),
        New String'("cdar"), New String'("caddr"), New String'("BOB") );
Begin
--     Flush_Input:
--     declare
--        Ch   : Character;
--        More : Boolean;
--     begin
--        loop
--           Ada.Text_IO.Get_Immediate (Ch, More);
--           exit when not More;
--        end loop;
--     end Flush_Input;

   REPL:	   -- Read-Eval-Print Loop
    loop
      Ada.Text_IO.Put_Line("[Count:" & Loop_Count'Img & ']');
      Read;
      Eval;
      Print;
	-- Testing functions.
	if Loop_Count = 1 then
	    Working:= Create("A") & Create("B") & Create("C");
	    For E of Sub_Loop loop
		declare
		    Use Type LISP.Lists.Implementation.Vector;
		    Temp : LIST := Create(E.All) & Working.Copy;
		    Use Ada.Text_IO;
		begin
		    Put_Line( ASCII.HT & Temp.To_String );
		    Temp:= Temp.Evaluate;
		    Put_Line( E.All & ASCII.HT & "=>" & Temp.To_String );
		end;
	    End loop;
	end if;
      Exit REPL when Terminated;
      Loop_Count:= Loop_Count - 1;
   end loop REPL;
   Ada.Text_IO.Put_Line( "Goodbye." );

exception
    when Constraint_Error =>
	TEST_STREAM_READ:
	declare
	begin
	    null;
	end TEST_STREAM_READ;
End LISP.Testbed;
