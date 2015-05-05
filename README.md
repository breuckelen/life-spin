##IMPORTANT

* Our code does not run on department linux machines, likely due to different versions of spin. You may have to update your version of spin to run the project.


## What we set out to model
* We set out to verify various properties Conway's game of life, and search for interesting configurations within the game.

* This includes verification that certain starting states will result in
	1. Empty boards (death states)
	2. Boards that do not change (still lifes)
	3. Boards that repeat every other turn (oscillators)
	4. Boards that have groups of live squares that move across the board (space ship states)

* This also includes a safety property that there is no unbounded growth, and other liveness properties related to finding interesting board configurations.


##What we have modeled

* A game that follows the rules of Conway's game of life (with an important modification)

* Partial verification for the unbounded growth property by searching for fully alive states (and finding none).

* Search for oscillators, death states, still life, and spaceships.

* Verification that given starting states are either still lifes, oscillators, or death states.


##Modeling decisions we had to make

* The most important decision, that affected the rules of the game was that we chose to model the board as an exact sized board (generally between 5x5 -> 8x8). Although Conway's Game of Life exists on an infinite sized board, it did not seem practical, or necessarily simple, to try to search for specific configurations on an infinite sized board in Spin.

* As the bord is limited, we treat border states as if cells outside them do not exist (or are all permanently dead cells), so that only cells inside the border cells are considered as able to be live or dead.
		
* This forces our configurations to exist inside the outermost cells on our board.

* t was hard to define what "unbounded growth" meant, and hard to formulate our arbitrary definition as an ltl property in spin.
		
* We left the commented out property in our code. However, instead of using an ltl property we chose to simply search for fully alive states, and when finding none, we can reason that there was no unbounded growth for a limited search space.

* We chose not to write a spaceship verifier as the parameters for what it means to be a spaceship are very loose, and so a verifier might incorrectly verify. Therefore, we found that it was much more useful to search for spaceship instances and then reason whether or not the instance fiven is actually a spaceship.


##Extra

* By changing the variable that follows the SEARCH / VERIFY variable at the top of the code, you are able to alter what instances our model is searching for/verifying.

* We also output the three most recent states for every instance into a separate text file, named according to what instances were being searched for. After each run, you can view the text file and view the configurations leading up to a given instance.

* We do not actually terminate our search process (although when it is verifying whether a configuration is an oscillator or a still life, it terminates), instead searching for instances until you manually kill the process via terminal. We figured this would be more useful as you can then search for all instances until spin can find no more. Therefore, when running our model, if you feel you have found enough instances, terminate the process, then view the instances in the appropriate output text file.


##Running our model

* To run our model, in a terminal cd into the directory containing life.pml:

		spin -aS life.pml

		gcc -DSAFETY -o pan pan.c

		./pan -i (for searches)
		OR
		./pan -E (for verifications)

  
