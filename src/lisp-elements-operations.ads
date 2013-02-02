With LISP.Lists;
Package LISP.Elements.Operations is
   Use LISP.Lists;

   Function Operable( Input : List; Element_Type : Data_Type ) Return Boolean;
   Function Operable( Input : List ) Return Boolean;


   Function Plus( Input : List ) Return Element
	with Pre => Operable(Input);

   Function Minus ( Input : List ) Return Element
	with pre => Operable(Input);

End LISP.Elements.Operations;
