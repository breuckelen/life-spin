##What we set out to model:

*We set out to verify various properties about configurations in Conway's game of life.

*This includes verification that certain starting states will result in death states, still life states, oscillating states, and spaceship states.

*This includes searching for still lifes, oscillators, spaceships, and death states.

*Lastly this includes the safety property that there is no unbounded growth, and the liveness properties that encompass the rules of transitioning from one board state to another.


##What we have modeled:

*Currently, we are able to transition correctly from one board state to the next.

*We are able to verify the unbounded growth property by searching for fully alive states (and finding none).

*We are able to search for arbitrary oscillators, death states, still life, and spaceships.

*We are able to verify hardcoded given starting states as either still lifes or oscillators.


##Modeling decisions we had to make:

*We chose to model the board as an exact sized board (generally between 5x5 -> 8x8).

*Although Conway's Game of Life exists on an infinite sized board, it did not seem practical to try to search for specific configurations on an infinite sized board in Spin.

*As the bord is limited, we treat border states as if cells outside them do not exist (or are all permanently dead cells), so that only cells inside the border cells are considered  as able to be live or dead.
		
*This forces our configurations to exist inside the outermost cells on our board.

*The unbounded growth property was difficult to formulate as an ltl property.
		
*We left the commented out property in our code. However, instead of using an ltl property we chose to simply search for fully alive states, and when finding none, we can reason that there was no unbounded growth.

*We chose not to write a spaceship verifier as the parameters for what it means to be a spaceship are very loose, and so a verifier might incorrectly verify. Therefore, we found that it was much more useful to search for spaceship instances and then reason whether or not the instance fiven is actually a spaceship.


##Extra:

*By changing the variable that follows the SEARCH variable at the top of the code, you are able to alter what instances our model is searching for/verifying.

*We also output the three most recent states for every instance into a separate text file, named according to what instances were being searched for. After each run, you can view the text file and view the configurations leading up to a given instance.

*We do not actually terminatee our process, instead searching for instances until you manually kill the process via terminal. We figured this would be more useful as you can then search for all instances until spin can find no more. Therefore, when running our model, if you feel you have found enough instances, terminate the process, then view the instances in the appropriate output text file.


##Running our model:

*To run our model, in a terminal cd into the directory containing life.pml:

		spin -aS life.pml

		gcc -DSAFETY -o pan pan.c

		./pan -i	

  
