# Commands
* d - delete(also cut)
* c - change(delete, then place in insert mode)
* y - yank(copy)
* v - visually select


# Motions
* a - all
* i - in
* t - 'til
* f - find forward
* F - find backward

#Text objects
* w - word
* s - sentence 
* p - paragraph
* t - tags


# Examples
* daw - delete all word
* ciw - change in word


# Additional Commands
* dd/yy - delete/yank the current line
* D/C - delete/change until end of line
* ^/$ - move to the beginning/end of line
* I/A - move to the beginning/end of line and insert
* o/O - insert new line above/below current line and insert 

* ^E - scroll the window down
* ^Y - scroll the window up
* ^F - scroll down one page
* ^B - scroll up one page
* H - move cursor to the top of the window
* M - move cursor to the middle of the window
* L - move cursor to the bottom of thw window


# Dot command
* . - Make things repeatable.


# Macro
```
# Record a macro
q{register}
(do the things)
q

#Play a macro
@{register}
```


