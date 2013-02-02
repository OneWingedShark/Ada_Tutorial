-- PACKAGE LISP
--
-- This package serves as the base package for the interpreter,
-- there are child packages for handling the specific elements
-- of the interpreter: one for lists, one for elements, one
-- for string-handling, and so forth. The basic layout is as
-- shown:
--
--  LISP
--  | | \
--  | \ LISP.Lists
--  |  \
--  |  LISP.Elements
--  |         \
--  |        LISP.Elements.operations
--  |
--  LISP.Strings

Package LISP is
Pragma Pure;

   -- Parse_Error is used to signal when there has been a problem parsing.
   Parse_Error,
   -- Undefined_Element is used to signal when there is a reference to an
   -- undefined entity.
    Undefined_Element     : Exception;

End LISP;
