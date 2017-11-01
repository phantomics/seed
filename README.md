<!-- TITLE/ -->

# Seed

<!-- /TITLE -->

Seed is an interactive software environment. With it you can create and use computer programs in many ways. It is based on the Common Lisp language and runs inside the Web browser, allowing you to build software on a local or remote computer system, and it can present programs and their output using a wide variety of display modes. Seed depicts programs in the form of a tree grid, featuring glyphs that denote different functions and types of data. All of Seed's display modes share basic interface principles in common, so you can quickly feel at home with whatever way your program is presented.


## Background

The Lisp family of programming languages offer unmatched flexibility in defining software, but this flexibility is not matched by the character strings most often used to express that software. Computer programs have hitherto been widely regarded as inextricable from and synonymous with character strings like the one you're reading now. While visual programming paradigms have made headway in a number of areas, most visual programming tools are tightly coupled to particular domains.

The choice of Lisp's creators to forego a detailed syntax in favor of symbolic expressions marked a turn down a road less traveled by language developers. Users may be confused by the sometimes homogenous, sometimes verbose nature of Lisp code, but the problem in these cases is not a shortcoming of Lisp -- it is a shortcoming of character strings. Through the choice of a regular syntax for the language, Lisp was set on a path that could lead to programming beyond the limits of plain text. Seed is an effort to realize that destination: a language representation orthogonal to the language's structure.

These ideas have been the foundation of Seed. Your experience with this system will determine their truth.


## In Practice

Seed can be seen as a type of IDE. It integrates ASDF, the standard Common Lisp build system, and the software systems it's used to develop are often expressed as ASDF systems. These systems are divided into branches, each of which expresses input to and output from the system. In a given Seed system, there is typically a .seed file located in the package directory that specifies the system and the behavior of each branch.


## The First Step: Installing and Running Seed

Seed depends on Common Lisp, ASDF and Quicklisp. The only Common Lisp implementation tested so far has been Steel Bank Common Lisp (SBCL). Seed also requires Node.js, NPM and Gulp to build the Javascript that runs its Web interface. Install the required software if you don't have it, then clone this repository.

#### Please Note

**On some systems, the install process encounters errors compiling the static-vectors and fast-io packages. It's usually possible to complete the installation without problems by choosing to "continue" or "accept" when these errors occur. They appear to be connected to the presence of outdated packages in Quicklisp.**

### Preparing Quicklisp

Enter your Quicklisp local-projects directory (usually ~/quicklisp/local-projects) and create a symbolic link to the directory where you cloned the Seed repository. For example, if you cloned the repo to ~/mystuff/seed and your Quicklisp directory is ~/quicklisp/, enter:

```
cd ~/quicklisp/local-projects
ln -s ~/mystuff/seed
```

### Using the automatic installer

Seed comes with an installation program called, appropriately enough, install-seed.lisp. To use it, enter the Seed repository directory and load the install-seed.lisp file using your Common Lisp implementation. For example, if you are using SBCL, type:

```
sbcl --load install-seed.lisp
```

This should automatically set Seed up, install its dependencies and build the components of the browser interface. If there are problems it will display error messages that should help with fixing them. If this doesn't work, you should try...

### Installing Seed manually

To complete the installation manually, start a Common Lisp REPL and enter:

```
(ql:quickload 'seed)
```

This will build Seed and install the software it needs to run. As long as you have Node, NPM and Gulp installed, the Javascript and CSS required to run the Seed interface should be automatically built. 

### Starting Seed automatically

From now on, if you'd like to automatically start Seed whenever you run SBCL, you can open your .sbclrc file (usually located at ~/.sbclrc) and add the lines:

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

### [Tutorial](https://github.com/phantomics/seed/wiki/Introductory-Tutorial)

[Click here](https://github.com/phantomics/seed/wiki/Introductory-Tutorial) for a tutorial to help you get started using Seed.

### Credit

Seed contains a modified copy of Panic, a utility for building React components written by Michael J. Forster. Thanks to Michael for creating this tool.