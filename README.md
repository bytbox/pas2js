pas2js: Convert Pascal to Javascript
====================================

Usage
-----

    pas2js < program.pas > program.js

The resulting `program.js` will be ill-formatted, so if you're planning on
editing it, you'll want to run it through a pretty-printer, such as google's
closure compiler.

    pas2js < program.pas | closure --formatting PRETTY_PRINT > program.js

The resulting javascript file will be dependendent on `pascal.js` for
equivalents of various pascal functions.

Known Bugs
----------

 * Types aren't handled quite correctly. (Specifically, they are mostly
   ignored.)

 * Labels and `GOTO` statements will not work. (It is not completely infeasible
   to support these in the future, but doing so may result in a serious
   performance penalty.)

 * `WITH` blocks will generate warnings when run through a pretty-printer or a
   linter, since the converted version uses JavaScript's deprecated `with`
   construct.

 * The `pascal.js` library is far from complete.

