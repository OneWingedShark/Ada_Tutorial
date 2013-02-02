Package LISP is
Pragma Pure;

   -- Parse_Error is used to signal when there has been a problem parsing.
   Parse_Error,
   -- Undefined_Element is used to signal when there is a reference to an
   -- undefined entity.
    Undefined_Element     : Exception;

End LISP;
