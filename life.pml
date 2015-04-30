#define ROWS 7
#define COLS 7
#define MAX_TURN 4
#define BOARD_SIZE (ROWS * COLS)
#define INIT_LIVES 5

#define STILL_LIFE 0
#define OSCILLATOR 1
#define DEATH 2
#define LIFE 3
#define SEARCH DEATH

#define not_border(r, c) \
    !((r == ROWS - 1 || c == COLS - 1 || r == 0 || c == 0) && buffer[r].col[c]);


typedef row {
    bool col[COLS];
};

int ro, col;
int init_live_count = 0;
int prev_live_count = 0;
int prev_two_live_count = 0;
int live_count = 0;

//Boards
row current[ROWS];
row buffer[ROWS];
row prevOne[ROWS];
row prevTwo[ROWS];

inline get_live(r, c) {
    d_step {
        ro = r;
        col = c;

        if
        :: r == 0 && c == 0 ->
            live = current[r + 1].col[c] + current[r + 1].col[c + 1] \
                + current[r].col[c + 1];
        :: (r > 0 && r < ROWS - 1) && c == 0 ->
            live = current[r - 1].col[c] + current[r + 1].col[c] \
                + current[r + 1].col[c + 1] + current[r].col[c + 1] \
                + current[r - 1].col[c + 1];
        :: r == ROWS - 1 && c == 0 ->
            live = current[r - 1].col[c] + current[r].col[c + 1] \
                + current[r - 1].col[c + 1];
        :: r == ROWS - 1 && (c > 0 && c < COLS - 1) ->
            live = current[r - 1].col[c - 1] + current[r].col[c - 1] \
                + current[r].col[c + 1] + current[r - 1].col[c + 1] \
                + current[r - 1].col[c];
        :: r == ROWS - 1 && c == COLS - 1 ->
            live = current[r - 1].col[c - 1] + current[r].col[c - 1] \
                + current[r - 1].col[c];
        :: (r > 0 && r < ROWS - 1) && c == COLS - 1 ->
            live = current[r - 1].col[c - 1] + current[r].col[c - 1] \
                + current[r + 1].col[c - 1] + current[r + 1].col[c] \
                + current[r - 1].col[c];
        :: r == 0 && c == COLS - 1 ->
            live = current[r].col[c - 1] + current[r + 1].col[c - 1] \
                + current[r + 1].col[c];
        :: r == 0 && (c > 0 && c < COLS - 1) ->
            live = current[r].col[c - 1] + current[r + 1].col[c - 1] \
                + current[r + 1].col[c] + current[r + 1].col[c + 1] \
                + current[r].col[c + 1];
        :: else ->
            live = current[r - 1].col[c - 1] \
                + current[r].col[c - 1] + current[r + 1].col[c - 1] \
                + current[r + 1].col[c] + current[r + 1].col[c + 1] \
                + current[r].col[c + 1] + current[r - 1].col[c + 1] \
                + current[r - 1].col[c];
        fi;
    }
}

inline write_board() {
    d_step {
	int p;
        c_code {
                FILE *fp;
                #if SEARCH == STILL_LIFE
                    fp = fopen("still.txt", "a");
                #elif SEARCH == OSCILLATOR
                    fp = fopen("osc.txt", "a");
                #elif SEARCH == DEATH
                    fp = fopen("death.txt", "a");
		#elif SEARCH == LIFE
		    fp = fopen("life.txt", "a");
                #endif
                fprintf(fp, "\nNext Instance Found:\n");
                fclose(fp);
        }
	for(p : 0 .. 2) {
            c_code {
                    FILE *fp;
                    #if SEARCH == STILL_LIFE
                        fp = fopen("still.txt", "a");
                    #elif SEARCH == OSCILLATOR
                        fp = fopen("osc.txt", "a");
                    #elif SEARCH == DEATH
                        fp = fopen("death.txt", "a");
		    #elif SEARCH == LIFE
		    	fp = fopen("life.txt", "a");
                    #endif
                    fprintf(fp, "\n\n");
                    fclose(fp);
            }

            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    get_live(r, c);

                    if
                    :: p == 0 ->
                        c_code {
                            FILE *fp;
                            #if SEARCH == STILL_LIFE
                                fp = fopen("still.txt", "a");
                            #elif SEARCH == OSCILLATOR
                                fp = fopen("osc.txt", "a");
                            #elif SEARCH == DEATH
                                fp = fopen("death.txt", "a");
                            #elif SEARCH == LIFE
		    		fp = fopen("life.txt", "a");
			    #endif
                            fprintf(fp, "%d ", now.prevTwo[now.ro].col[now.col]);
                            fclose(fp);
                        }
                    :: p == 1 ->
                            c_code {
                                FILE *fp;
                                #if SEARCH == STILL_LIFE
                                    fp = fopen("still.txt", "a");
                                #elif SEARCH == OSCILLATOR
                                    fp = fopen("osc.txt", "a");
                                #elif SEARCH == DEATH
                                    fp = fopen("death.txt", "a");
                                #elif SEARCH == LIFE
				    fp = fopen("life.txt", "a");
				#endif
                                fprintf(fp, "%d ", now.prevOne[now.ro].col[now.col]);
                                fclose(fp);
                            }
                    :: p == 2 ->
                            c_code {
                                FILE *fp;
                                #if SEARCH == STILL_LIFE
                                    fp = fopen("still.txt", "a");
                                #elif SEARCH == OSCILLATOR
                                    fp = fopen("osc.txt", "a");
                                #elif SEARCH == DEATH
                                    fp = fopen("death.txt", "a");
                                #elif SEARCH == LIFE
		    		    fp = fopen("life.txt", "a");
				#endif
                                fprintf(fp, "%d ", now.current[now.ro].col[now.col]);
                                fclose(fp);
                            }
                    :: else
                    fi;
                }

                c_code {
                    FILE *fp;
                    #if SEARCH == STILL_LIFE
                        fp = fopen("still.txt", "a");
                    #elif SEARCH == OSCILLATOR
                        fp = fopen("osc.txt", "a");
                    #elif SEARCH == DEATH
                        fp = fopen("death.txt", "a");
                    #elif SEARCH == LIFE
		        fp = fopen("life.txt", "a");
		    #endif
                    fprintf(fp, "\n");
                    fclose(fp);
                }
            }
	}
    }
}

proctype BoardRun() {
    int turn = 0;
    int live;
    int r, c;
    bool osc, st;
    do
    :: turn == 0 ->
        /*Board Init*/
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                if
                :: current[r].col[c] = 0;
                    buffer[r].col[c] = 0;
                :: current[r].col[c] = 1;
                    buffer[r].col[c] = 1;
                    init_live_count++;
                fi;
            }
        }

        turn++;
    :: turn > 0 && turn <= MAX_TURN ->
        d_step {
	    prev_two_live_count = 0;
	    prev_live_count = 0;
	    live_count = 0;
            /*Board Print*/
            printf("Current Board\n");

            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    get_live(r, c);
                    printf(" %d (%d) ", current[r].col[c], live);
                }
                printf("\n");
            }

            /*Board Store*/
            if
            :: turn > 1 ->
                for(r : 0 .. ROWS - 1) {
                    for(c : 0 .. COLS - 1) {
                        prevTwo[r].col[c] = prevOne[r].col[c];
                        prev_two_live_count = prev_two_live_count + prevOne[r].col[c];
                    }
                }
                for(r : 0 .. ROWS - 1) {
                    for(c : 0 .. COLS - 1) {
                        prevOne[r].col[c] = buffer[r].col[c];
                        prev_live_count = prev_live_count + buffer[r].col[c];
                    }
                }
            :: turn == 1 ->
                for(r : 0 .. ROWS - 1) {
                    for(c : 0 .. COLS - 1) {
                        prevOne[r].col[c] = buffer[r].col[c];
                        prev_live_count = prev_live_count + buffer[r].col[c];
                    }
                }
            fi;

            /*Board Transition*/
            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    get_live(r, c);
                    if
                    :: live < 2 ->
                        buffer[r].col[c] = 0;
                    :: live == 2 ->
                        skip;
                    :: live == 3 ->
                        buffer[r].col[c] = 1;
                    :: live > 3 ->
                        buffer[r].col[c] = 0;
                    fi;
                }
            }

            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    current[r].col[c] = buffer[r].col[c];
                    live_count = live_count + buffer[r].col[c];
                }
            }

            /*Board Search*/
            if
            :: turn > 1 ->
                #if SEARCH == STILL_LIFE
                    st = 1;
                    for (r : 0 .. ROWS - 1) {
                        for(c : 0 .. COLS - 1) {
                            st = st && \
                                prevOne[r].col[c] == buffer[r].col[c] && \
                                not_border(r, c);
                        }
                    }

                    st = st && live_count > 0;

                    if
                    :: st -> write_board();
                    :: else
                    fi;

                    assert(!st);
                #elif SEARCH == OSCILLATOR
                    osc = 1;
                    for(r : 0 .. ROWS - 1) {
                        for(c : 0 .. COLS - 1) {
                            osc = osc && \
                                prevTwo[r].col[c] == buffer[r].col[c] && \
                                not_border(r, c);
                        }
                    }

                    if
                    :: osc -> write_board();
                    :: else
                    fi;

                    assert(!osc);
                #elif SEARCH == DEATH
		    if
		    :: init_live_count == INIT_LIVES ->
			if
                    	:: (live_count == 0) -> write_board();
                    	:: else
                    	fi;
			assert((live_count > 0));
		    :: else
		    fi;
		#elif SEARCH == LIFE
		    if
		    :: init_live_count == INIT_LIVES ->
		        if
                        :: (live_count == BOARD_SIZE) -> write_board();
                        :: else
                        fi;
		        assert((live_count < BOARD_SIZE));
		    :: else
		    fi;
                #endif
            :: else
            fi;

            turn++;
        }
    :: else ->
        break;
    od;
}

init {
    run BoardRun();
}

//ltl explosiveGrowth { eventually true }
//ltl explosiveGrowth { <> live_count < prev_two_live_count || live_count < prev_live_count }
