With Ada.Containers;

Package body LISP.Elements.Operations is
   Use Type Ada.Containers.Count_Type;

   Function Operable( Input : List; Element_Type : Data_Type ) Return Boolean is
     ( if Input.Length > 0 then
        Input.Head.Get_Type = Element_Type and
        Input.Homoginized_List
     );

   Function Operable( Input : List ) Return Boolean is
      (if Input.Length=0 then True else Operable(Input, Input.Head.Get_Type) );


--   Use LISP.Elements;

   Generic
      Type Element(<>) is Private;
      With Function Value ( Item: Elements.Element ) Return Element is <>;
      With Function Create( Item: Element ) Return Elements.Element is <>;
      With Function "+"( Right, Left : Element ) Return Element;
   Function Operation( Input : List ) Return Elements.Element;

   Function Operation( Input : List ) Return Elements.Element is
      Temp : Element:= Value( Input.Head );
   Begin
      For Item of Input.Tail loop
         Temp:= Temp + Value(Item);
      end loop;

      Return Create( Temp );
   End Operation;


   -------------------------------
   --  Operator Instantiations  --
   -------------------------------


   Function Plus_Op	is New Operation( Element => Integer, "+" => "+" );
   Function Minus_Op	is New Operation( Element => Integer, "+" => "-" );


   -------------------------
   --  Operation Renames  --
   -------------------------

   Function Plus  ( Input : List ) Return Element Renames Plus_Op;
   Function Minus ( Input : List ) Return Element Renames Minus_Op;

--     Function Plus1( Input : List ) Return Elements.Element is
--        Value : Integer := 0;
--     begin
--        For Item of Input loop
--           Value:= Value + Item.Int_Val;
--        end loop;
--
--        Return Result : Element_Integer:= Create( Value );
--     end Plus1;



End LISP.Elements.Operations;
