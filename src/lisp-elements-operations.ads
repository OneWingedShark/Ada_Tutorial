With LISP.Lists;
Package LISP.Elements.Operations is

    -- It would be more convenient to refer to "List" in
    -- parameters than LISP.Lists.List, though there is nothing
    -- preventing us from using the fully-qualified format.
    Use LISP.Lists;

    -- Operable tells us that the list can indeed be operated
    -- on; every function in LISP is a list, but not every list
    -- is a function.
    -- Example: What should (1 2 3 4 6) do? On the other hand
    -- ("+" 1 2 3 4 5) is simple enough - we apply the function
    -- "+" to the tail, which returns 15.
    Function Operable( Input : List; Element_Type : Data_Type )
		Return Boolean;
    Function Operable( Input : List ) Return Boolean;


    -- Addition.
    Function Plus( Input : List ) Return Element
    with Pre => Operable(Input);

    -- Subtraction.
    Function Minus ( Input : List ) Return Element
    with pre => Operable(Input);

    --And so forth...
End LISP.Elements.Operations;
