-- This package is to define the various types of Strings to be
-- used in the underlying implementation of the interpreter.
--
-- For that reason it is declared as a PRIVATE PACKAGE, this
-- means that the only clients that may use it in a context
-- clause ("with") are its parent or decendents thereof. Also,
-- though it desn't matter in our case (with a pure package
-- which has no private part), it is worth noting that private
-- children are granted the full view of their ancestors's
-- specification.
Pragma Ada_2012;
Private Package LISP.Strings is

    -- ID_String imposes a few amount of restrictions, as
    -- we need "+" & "-" to be valid Identifiers; none of its
    -- characters may be whitespace, and it may not parse as a
    -- valid number.
    SubType ID_String is String
    with Static_Predicate => Valid_ID( ID_String )
                             and not Valid_Number(ID_String);

    -- Identifier is a type that represents a user's variable-
    -- or function-name, it is a private type.
    Type Identifier is private;

    -- Conversion functions for Strings & Identifiers.
    Function To_String( Item : Identifier  ) Return String;
    Function To_Identifier(Item : ID_String) Return Identifier;

    -------------------------------------
    --  String-manipulation Functions  --
    -------------------------------------

    -- Get_Internals returns the given string less the first
    -- and last character ex: "dave" => "av".
    Function Get_Internals(S : String) Return String;

    -- Returns TRUE when S conforms to the rules regarding names.
    -------------------------------------------------------------
    -- It is a PURE_FUNCTION which specifies that it is to be
    -- considered pure for the purposes of code generation.
    -- This means that the compiler can assume that there are
    -- no side-effects; particularly: that two calls with
    -- identical arguments produce the same result.
    --
    -- NOTE: It is not the case that the compiler ensures this.
    Function Valid_ID( S : String ) Return Boolean
    with Pure_Function;


    -- Returns TRUE when S is a valid string representation of
    -- a number whose type recognized by the interpreter.
    Function Valid_Number( S : String ) Return Boolean
    with Pure_Function;


Private
    ------------------
    -- Declarations --
    ------------------

    -- Subtypes denoting various character ranges & sets.
    SubType ALPHA	is Character Range 'A'..'Z';
    SubType NUMBER	is Character Range '0'..'9';

    -- Identifiers are not allowed to be changed in-place;
    -- therefore, we introduce an access to a constant, this in
    -- addition to the NOT NULL means we don't haver to worry
    -- about null-values.
    Type Identifier is Not Null Access Constant ID_String;

End LISP.Strings;
