With
Ada.Strings.Fixed,
LISP.Strings,
LISP.Lists;

Package body LISP.Elements is
   Use LISP.Lists, LISP.Strings;

   --------------
   --  CREATE  --
   --------------

    Function Create( Item : Integer ) Return Element is
      ( Data => Integer_Type, int_val => Item );
    Function Create( Item : List  ) Return Element is
      ( Data => List_Type, List_val => new List'(Item) );
    Function Create( Item : String;
		     Identifier	: Boolean := False ) Return Element is
      (	if Identifier then
	 (Data => Name_Type, name_val => To_Identifier(Item))
	else
	 (Data => String_Type, str_val => New Standard.String'(Item))
      );

    -- To_Identifier does the same as To_String, but will not
    -- output quotes.
    Function To_Identifier(Item: Element) return String is
	S : String := Item.To_String;
    begin
	If S(S'First) /= '"' then
	    return S;
	Else
	    return LISP.Strings.Get_Internals(S);
	end if;
    end To_Identifier;

    -- To_String returns the string representation of the element.
    Function To_String(Item: Element) return String is
	Use Ada.Strings, Ada.Strings.Fixed;

	-- The Integer'Image attribute outputs an integer as a
	-- string; however, it puts a single space if it is
	-- positive or '-' in the case of a negative numbers...
	-- so we use the Trim function from Strings.Fixed to
	-- remove any existing white-space.
	Function Image(Item : Integer) Return String is
	  ( Trim(Integer'Image(Item), Side => Left) );

    begin
	Case Item.Data is
	    when Empty_Type   => Return "NULL";
	    when Integer_Type => Return Image(Item.Int_Val);
	    when Name_Type    => Return To_String(Item.Name_val);
	    when String_Type  => Return '"' & Item.Str_val.All & '"';
	    when List_Type    => Return To_String(Item.List_Val.All);
	End case;
    end To_String;

    -- To_List returns the given element as the only item in a list.
    Function To_List  (Item: Element) return Lists.LIST is
    begin
	Return Result : Lists.LIST do
	    Result.Append( Item );
	End return;
    end To_List;

    -- As_List returns the item if it is a list, or it calls
    -- To_list to convert it to one.
    Function As_List  (Item: Element) return Lists.LIST is
      ( if Item.Data = List_Type then Item.List_Val.All else Item.To_List );

End LISP.Elements;
