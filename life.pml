#define ROWS 4
#define COLS 4
#define BOARD_COUNT 5
#define MAX_TURN 4

#define PRINT_STATE 0
#define TRANS_STATE 1
#define SEARCH_STATE 2
#define OSCILLATOR_STATE 3
#define COPY_STATE 4

#define CURRENT_BOARD 0
#define BUFFER_BOARD 1
#define PREV_ONE_BOARD 2
#define PREV_TWO_BOARD 3

typedef row {
    bool col[COLS + 1];
};

int ro, col;

//Boards
row current[ROWS + 1];
row buffer[ROWS + 1];
row prevOne[ROWS + 1];
row prevTwo[ROWS + 1];

inline get_live(r, c) {
    //live = 0;
    d_step {
        ro = r;
        col = c;

        if
        :: r == 0 && c == 0 ->
            live = current[r + 1].col[c] + current[r + 1].col[c + 1] \
                + current[r].col[c + 1];
        :: (r > 0 && r < ROWS) && c == 0 ->
            live = current[r - 1].col[c] + current[r + 1].col[c] \
                + current[r + 1].col[c + 1] + current[r].col[c + 1] \
                + current[r - 1].col[c + 1];
        :: r == ROWS && c == 0 ->
            live = current[r - 1].col[c] + current[r].col[c + 1] \
                + current[r - 1].col[c + 1];
        :: r == ROWS && (c > 0 && c < COLS) ->
            live = current[r - 1].col[c - 1] + current[r].col[c - 1] \
                + current[r].col[c + 1] + current[r - 1].col[c + 1] \
                + current[r - 1].col[c];
        :: r == ROWS && c == COLS ->
            live = current[r - 1].col[c - 1] + current[r].col[c - 1] \
                + current[r - 1].col[c];
        :: (r > 0 && r < ROWS) && c == COLS ->
            live = current[r - 1].col[c - 1] + current[r].col[c - 1] \
                + current[r + 1].col[c - 1] + current[r + 1].col[c] \
                + current[r - 1].col[c];
        :: r == 0 && c == COLS ->
            live = current[r].col[c - 1] + current[r + 1].col[c - 1] \
                + current[r + 1].col[c];
        :: r == 0 && (c > 0 && c < COLS) ->
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

proctype BoardRun() {
    int turn = 0;
    int live;
    int r, c, i;
    bool osc;

    do
    :: turn == 0 ->
        /*Board Init*/

        for(r : 0 .. ROWS) {
            for(c : 0 .. COLS) {
                if
                :: current[r].col[c] = 0;
                    buffer[r].col[c] = 0;
                :: current[r].col[c] = 1;
                    buffer[r].col[c] = 1;
                fi;
            }
        }

        turn++;
    :: turn > 0 && turn <= MAX_TURN ->
        d_step {
            /*Board Print*/
            printf("Current Board\n");

            for(r : 0 .. ROWS) {
                for(c : 0 .. COLS) {
                    get_live(r, c);
                    printf(" %d (%d) ", current[r].col[c], live);
                }
                printf("\n");
            }

            /*Board Store*/
            if
            :: turn > 1 ->
                for(r : 0 .. ROWS) {
                    for(c : 0 .. COLS) {
                        prevTwo[r].col[c] = prevOne[r].col[c];
                    }
                }
                for(r : 0 .. ROWS) {
                    for(c : 0 .. COLS) {
                        prevOne[r].col[c] = buffer[r].col[c];
                    }
                }
                :: turn == 1 ->
                for(r : 0 .. ROWS) {
                    for(c : 0 .. COLS) {
                        prevOne[r].col[c] = buffer[r].col[c];
                    }
                }
            fi;

            /*Board Transition*/
            for(r : 0 .. ROWS) {
                for(c : 0 .. COLS) {
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

            //Copy buffer into board
            for(r : 0 .. ROWS) {
                for(c : 0 .. COLS) {
                    current[r].col[c] = buffer[r].col[c];
                }
            }

            /*Board Search*/
            // Include check for no squares with three live on the edges of the board
            // Use get_live and increase the range for for loops
            if
            :: turn > 1 ->
                osc = 1;

                for(r : 0 .. ROWS) {
                    for(c : 0 .. COLS) {
                        osc = (osc && (prevTwo[r].col[c] == buffer[r].col[c]));
                    }
                }

                if
                :: osc ->
                    for(r : 0 .. ROWS) {
                        for(c : 0 .. COLS) {
                            get_live(r, c);
                            c_code {
                                FILE *fp;
                                fp = fopen("test.txt", "a");
                                fprintf(fp, "%d ", now.current[now.ro].col[now.col]);
                                fclose(fp);
                            }
                        }
                        c_code {
                            FILE *fp;
                            fp = fopen("test.txt", "a");
                            fprintf(fp, "\n");
                            fclose(fp);
                        }
                    }

                    c_code {
                        FILE *fp;
                        fp = fopen("test.txt", "a");
                        fprintf(fp, "\n\n");
                        fclose(fp);
                    }
                :: else
                fi;

                assert(!osc);
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

