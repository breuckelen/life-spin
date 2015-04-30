#define ROWS 7
#define COLS 7
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

#define not_border(r, c) \
    !((r == ROWS - 1 || c == COLS - 1 || r == 0 || c == 0) && buffer[r].col[c]);

typedef row {
    bool col[COLS];
};

int ro, col;
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

inline write_board(fid) {
    d_step {
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(r, c);
                if
                :: fid == 0 ->
                    c_code {
                        FILE *fp;
                        fp = fopen("osc.txt", "a");
                        fprintf(fp, "%d ", now.current[now.ro].col[now.col]);
                        fclose(fp);
                    }
                :: fid == 1 ->
                    c_code {
                        FILE *fp;
                        fp = fopen("still.txt", "a");
                        fprintf(fp, "%d ", now.current[now.ro].col[now.col]);
                        fclose(fp);
                    }
                :: else
                fi;
            }
            if
            :: fid == 0 ->
                c_code {
                    FILE *fp;
                    fp = fopen("osc.txt", "a");
                    fprintf(fp, "\n");
                    fclose(fp);
                }
            :: fid == 1 ->
                c_code {
                    FILE *fp;
                    fp = fopen("still.txt", "a");
                    fprintf(fp, "\n");
                    fclose(fp);
                }
            :: else
            fi;
        }

        if
        :: fid == 0 ->
            c_code {
                FILE *fp;
                fp = fopen("osc.txt", "a");
                fprintf(fp, "\n\n");
                fclose(fp);
            }
        :: fid == 1 ->
            c_code {
                FILE *fp;
                fp = fopen("still.txt", "a");
                fprintf(fp, "\n\n");
                fclose(fp);
            }
        :: else
        fi;
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
                fi;
            }
        }

        turn++;
    :: turn > 0 && turn <= MAX_TURN ->
        d_step {
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
                :: st -> write_board(1);
                :: else
                fi;

                assert(!st);

                osc = 1;
                for(r : 0 .. ROWS - 1) {
                    for(c : 0 .. COLS - 1) {
                        osc = osc && \
                            prevTwo[r].col[c] == buffer[r].col[c] && \
                            not_border(r, c);
                    }
                }

                if
                :: osc -> write_board(0);
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

//ltl explosiveGrowth { <> live_count < prev_two_live_count || live_count < prev_live_count }
