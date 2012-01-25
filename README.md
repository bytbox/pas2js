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

First note that this code is a) outdated and b) written for a different dialect
of pascal than you're using, written by a programmer who doesn't have your
habits. Don't assume that it will do anything but barf when you feed it your
own code. Listed below are some known and important bugs.

 * Types aren't handled quite correctly. (Specifically, they are mostly
   ignored.)

 * Labels and `GOTO` statements will not work. (It is not completely infeasible
   to support these in the future, but doing so may result in a serious
   performance penalty.)

 * `WITH` blocks will generate warnings when run through a pretty-printer or a
   linter, since the converted version uses JavaScript's deprecated `with`
   construct.

 * The `pascal.js` library is far from complete.

