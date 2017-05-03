A CommandBox command for accessing [cfdocs.org](https://cfdocs.org/) documentation.

![Screen Shot](http://www.petefreitag.com/images/blog/cfdocs-commandbox.png)

## Install

First make sure you have CommandBox installed, then type:

    box install cfdocs

Or if you are already within the CommandBox CLI, you can just type:

    install cfdocs

## Using the command

There are a few display modes you can use, the default:

    doc cfdump

If you want full or verbose documentation try:

    doc cfdump full

If you want a listing of function arguments try:

    doc rereplace arguments

For tag attributes use:

    doc cfhttp attributes

For examples try:

    doc rereplace examples

There are a few shortcuts to these modes, you can use args instead of arguments,
or attr instead of attributes, or ex instead of examples.
