<!-- TITLE/ -->

# Seed

<!-- /TITLE -->

Seed is an interactive software environment. With it you can create and use computer programs in many ways. It is based on the Common Lisp language and runs inside the Web browser, allowing you to build software on a local or remote computer system, and it can present programs and their output using a wide variety of display modes. Seed depicts programs in the form of a tree grid, featuring glyphs that denote different functions and types of data. All of Seed's display modes share basic interface principles in common, so you can quickly feel at home with whatever way your program is presented.


## Background

The Lisp family of programming languages offer unmatched flexibility in defining software, but this flexibility is not matched by the character strings most often used to express that software. Computer programs have been widely regarded as inextricable from and synonymous with character strings like the one you're reading now. While visual programming paradigms have made headway in a number of areas, most visual programming solutions are tightly coupled to particular domains.

The choice of Lisp's creators to forego a detailed syntax in favor of symbolic expressions marked a turn down a road less traveled by language developers. Users may be confused by the sometimes homogenous, sometimes verbose nature of Lisp code, but the problem in these cases is not a shortcoming of Lisp -- it is a shortcoming of character strings. Through the choice of a regular syntax for the language, Lisp was set on a path that could lead to programming beyond the limits of plain text.

These ideas have been the foundation of Seed. Your experience with this system will determine their truth.


## In Practice

Seed can be seen as a type of IDE. It integrates ASDF, the standard Common Lisp build system, and the software systems it's used to develop are often expressed as ASDF systems.


## The First Step: Building and Running Seed

Seed depends on Common Lisp, ASDF and Quicklisp. The only Common Lisp implementation tested so far has been Steel Bank Common Lisp (SBCL). Seed also requires Node.js, NPM and Gulp to build the Javascript that runs its Web interface. Install the required software if you don't have it, then clone this repository.

#### Please Note

**On some systems, the install process encounters errors compiling the static-vectors and fast-io packages. It's usually possible to complete the installation without problems by choosing to "continue" or "accept" when these errors occur. They appear to be connected to the presence of outdated packages in Quicklisp.**

### Using the automatic installer

Seed comes with an installation program called, appropriately enough, install-seed.lisp. To use it, enter the Seed repository directory and load the install-seed.lisp file using your Common Lisp implementation. For example, if you are using SBCL, type:

```
sbcl --load install-seed.lisp
```

This should automatically set Seed up, install its dependencies and build the components of the browser interface. If there are problems it will display error messages that should help with fixing them. If this doesn't work, you should try...

### Installing Seed manually

Enter your Quicklisp local-projects directory (usually ~/quicklisp/local-projects) and create a symbolic link to the directory where you cloned the Seed repository. For example, if you cloned the repo to ~/mystuff/seed and your Quicklisp directory is ~/quicklisp/, enter:

```
cd ~/quicklisp/local-projects
ln -s ~/mystuff/seed
```

Then, start a Common Lisp REPL and enter:

```
(ql:quickload 'seed)
```

This will build Seed and install the software it needs to run. As long as you have Node, NPM and Gulp installed, the Javascript and CSS required to run the Seed interface should be automatically built. 

### Starting Seed automatically

From now on, if you'd like to automatically start seed whenever you run SBCL, you can open your .sbclrc file (usually located at ~/.sbclrc) and add the lines:

```
(asdf:load-system 'seed)
(seed:contact-open)
```

The contact-open method will open Seed's Web interface at the designated HTTP port. If you would prefer not to automatically open the Web interface when you start Common Lisp, you can omit the (seed:contact-open) line above.

### The Web interface

Once opened, Seed's web interface will be located at port 8055 by default; if you wish to change that, just edit seed.lisp in the main Seed directory.

To visit the Web interface for the default portal "portal.demo1", which comes included with Seed, visit the URI:

```
http://localhost:8055/portal.demo1/index.html
```

If you create another portal, substitute that portal's name in the URI.


## A Seed Tutorial

Once you load the Web interface, you will be greeted by a banner declaring "portal.demo1" and a list of systems. Once you're tired of watching the introductory animation, you can click on one of the systems to open it. The basis of every Seed instance is a portal, which constitutes an interface to a number of software systems. The portal "demo1" is linked to two systems, demoSheet and demoDrawing.

### Basic movement

If you check out demoSheet, you will see that it implements a spreadsheet with a code window on the left side to control the content of the cells. The demoDrawing system contains code that generates vector graphics. For now, let's try using the demoSheet system. The first thing you'll want to learn how to do is move the cursor and enter code.

The cursor is indicated by a cell in the tree grid that is darker than the others. To move it, you can press the arrow keys on your keyboard, the number pad arrow keys, or the h, j, k and l keys as used by vim and other text editing tools. These three sets of keys can be used interchangeably to navigate.

### Copy and paste

Once you've learned to move, try copying the contents of an atom or form to the clipboard. Simply hold the C key and press right. Seed uses many letter keys in combination with directional keys. This is called a navigational interface; many common editing tasks are represented through navigational metaphors.

In the future, we'll refer to combinations like holding the C key and pressing right to: C+right.

Once you've pressed C+right, you'll notice that a red tick mark has appeared at the far right of the screen. This indicates that there is one item in the clipboard.

Now try moving the cursor to a different location, and press C+left. Watch as whatever was originally present at the cursor's location is replaced by the item you saved to the clipboard.

Try saving some more items to the clipboard by pressing C+right. You'll notice that more marks appear at the far right, and the only one of these marks can be red at one time. The red mark indicates the item that will be copied from the clipboard when you press C+left. Each time you copy an item, it goes to the top of the list and becomes the selected item for pasting.

How can you choose which item to paste from the clipboard? Try pressing C+up and C+down. The red mark at the right will move. Try copying and pasting a few different items to get a hang of it.

### Saving and reverting changes

In the course of all that copying and pasting, you may have damaged the demoSheet program, so press Shift+R or click on the Revert buttom at the bottom right of the code display. This will cancel your changes.

If you wish to save changes that you make and see how they affect the spreadsheet, press Shift+S or click on the Save button at the bottom of the code display.

### Building forms

Now that you know the basics of moving the cursor and moving items to and from the clipboard, let's try creating some new code.

Move the cursor to the upper left-most cell in the grid, labeled "cell" with the "a2" atom to its right.

Now, press F+down to create a new blank atom beneath the "cell" form.

This will be the beginning of a new "cell" form. With the cursor at the blank form, press the Enter key or space bar on your keyboard. A text cursor will appear. Type "cell" and press the Enter key.

You have now created an atom containing the "cell" symbol. Press F+right and this atom will become a form with only one member, equivalent to "(cell)" in textual Lisp code.

Press F+right again and a blank atom will be added to the form. With the cursor occupying this atom, type F+R. This will set the atom's type to a string and create a text cursor for this atom. Type "a1" and press Enter.

The new atom is now a string, "a1". Press F+down again to create another new atom in the form. With the cursor on this empty atom, press F+D, which will change the atom's type to a number and open the atom for editing. Enter whatever number you wish and press enter.

You have now created a new form that specifies the value of a spreadsheet cell. Let's save the program and see the result. Press Shift+S or click on the Save button at the bottom of the code display to see the result of your changes. The number you entered should appear at the top left cell in the spreadsheet.

### More to come

More tutorial material will be coming soon.

#### Credit

Seed contains a modified copy of Panic, a utility for building React components written by Michael J. Forster. Thanks to Michael for creating this tool.