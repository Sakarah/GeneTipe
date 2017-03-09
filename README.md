# GeneTipe
This project is a generic, plugin-based, configurable, open source, genetic evolver written in OCaml by 3 students for the TIPE exam.

Let's explain what this means in details:
* __Genetic evolver__:
A genetic evolver is a stochastic program that tries to obtain an acceptable solution to a problem.
It randomly generates a *population* of *individuals* that represents each a possible solution. Then, by recombining (*crossover*) or modifying (*mutation*) them and selecting the best offsprings, it slowly improves the results.
Of course, you need to specify a way to determine how good a possible solution is (with the *fitness function*). The underlying idea is to mimic the natural selection process in a program.
* __Generic__:
You can basically use this project for evolving any kind of population regardless the "thing" you are trying to evolve.
You can very easily create a new evolver implementation following one of the templates provided.
In practice you will also have to provide a fitness function, and at least one random generator and one genetic operator (mutation or crossover) to be able to run a genetic algorithm but usually you will have more.
* __Plugin-based__:
The entire project relies heavily around plugins compiled separately from the core evolver and loaded when requested by the current configuration.
This enables you to add functionalities (such as a new mutation) without recompiling the whole project all the time.
* __Configurable__:
The genetic evolver is coded in a way such as once you get your whole algorithm compiled with all your plugins working together you can tweak it without touching any piece of code just by adjusting values in a simple human-readable JSON file.
It can also be done directly in the command line if the modification is really small and temporary.
* __Open source__:
The whole project including the distributed plugins and the associated tools is under GPLv3.
Anyone can use the project for doing any work with it but if you modify the included files you will have to share your modifications under the same license.
See LICENSE for legal information.
We are not sure if external contributions are allowed before the exam (in summer 2017) but we will be happy to look at them just after it.

## Few words about the TIPE exam
It is a research project in Mathematics, Physics or Informatics done by all students in preparatory classes around a central theme. This year it is *“Optimization: choice, constraints, randomness”*.
We have to explain what we did individually during the oral admission tests in the “Grandes Écoles” (French engineering schools).

# How to use this program?
## Build instructions
First of all please check that your system has all the project dependencies correctly installed and recognized.
These dependencies are OCaml (4.01 or higher), ocamlbuild, ocamlfind, yojson. You can probably install all of them with opam or with your distribution packages. Moreover, we recommand you to also install parmap if you are under a UNIX OS to make the programs run around 3 times faster. On Windows, you will need Cygwin for building and executing the project (the version suggested by OCaml should work fine).

Then just execute `$ make` in the project directory and wait for the end of the compilation.

If you want to build the documentation of the standard modules (that can be freely used by your plugins) execute `$ make doc`

## Program usage
To start evolving a population, first make a configuration file. You can find examples the config/ directory.
This will enable you to define all the options for the genetic evolution.
It is in this file where you specify which plugins are loaded what are the parameters of the genetic evolution.

Then to start the evolution just execute the evolver corresponding to your individual type with `$ ./symbolic-regression path/to/config.json` or `$ ./regexp-search path/to/config.json` and give it the input target data required.

Of course this data can be given by another program (using pipes) or read from a file using the appropriated shell command line.

For any included executable you can get more information about the command line options and the input data required by executing them with the `--help` option.

Some very basic utility tools are included in the project (like `genpts` to create a set of point from a function).

## Make your own plugin
If you want to extend the possibilities of the program, for instance by adding a new genetic operator or selection function, you will have to write a plugin.
A plugin is a standard OCaml module compiled into a .cmxs file for being loaded after by another program.
You have to know how to interact with the rest of the program. This is mostly done through the hook system.

When you create a new function or module in a plugin that you want the rest of the program to know about, you have to register it to the corresponding hooking point by calling `HookingPoint.register "name" function_or_module`.
It will have to match the hook type (i.e.: crossover hooking points will only accept crossover like functions).
Doing so you give your function a unique name that can be referred later to retrieve the function with `HookingPoint.get "name"`.
This name is usually taken directly from the configuration file to enable the user to choose which function to use.

You can also create your own hooking points to make your modules extensible.
You will have to use this strategy in evolver implementation which have to create specific hooking points for the genetic operators related to their individual type.

# Included implementations
For our researches we have to work with concrete examples of genetic algorithms.
That is why we have implemented some (actually only two) genetic types to evolve.
These examples are demonstrations of what can be possibly evolved and give pertinent results.
Here we only cover the goal and the basic principles of each case.

## Symbolic regression
In a symbolic regression process you have to create a function that matches the best way possible a set of points without knowing anything about the function shape.

For doing this you consider that each function is an expression tree with predefined primitives such as operations (*, +), mathematical functions (cos, log) or terminal nodes (x or 3.14).
This tree format give a nice operation order and ensure that each primitive have an appropriated arity.

To test easily the symbolic regression, we often generate a set of points with a known function and then check if the output function matches.
You can test that with a simple `$ ./genpts "ln((2*x)+1)" | ./symbolic-regression config/symbolic_regression.json` for example.

Note that the results are not always as simple as expected. You can force simpler expressions by reducing the maximum depth allowed for individuals.

## Regular expression searching
In regular expression searching, the goal is to find a regular expression (regexp) matching a set of examples and not matching another set of counter-examples. Moreover, we want to avoid over-fitting in order to generalize the pattern as much as possible. For example, if you give email addresses as examples, we expect to give as a result a regexp matching all the email addresses (or at least those looking like the examples) and not only the few ones in the dataset.

Again we use here a tree representation for the regexp then converted into non deterministic finite automata for evaluation.

To test this genetic algorithm, you need to provide a representative set of what kind of strings you want and find appropriate counter-examples. A good counter-example is usually something near what you want but slightly different. Then test against the result other strings not included in the set and see if they are well recognized.
