#define ROWS 10
#define COLS 10
#define MAX_TURN 5

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
    bool col[COLS];
}

//Boards
row current[ROWS];
row buffer[ROWS];
row prevOne[ROWS];
row prevTwo[ROWS];

//State variables
int ro, col;
int cur_id = PRINT_STATE;
int turn = 0;
int live;

/*
inline set_board(board_id) {
    int ro = r, col = c;
    r = 0;
    c = 0;

    if
    :: board_id == CURRENT_BOARD ->
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                board[r].col[c] = current[r].col[c];
            }
        }
    :: board_id == BUFFER_BOARD ->
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                board[r].col[c] = buffer[r].col[c];
            }
        }
    :: board_id == PREV_ONE_BOARD ->
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                board[r].col[c] = prevOne[r].col[c];
            }
        }
    :: board_id == PREV_TWO_BOARD ->
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                board[r].col[c] = prevTwo[r].col[c];
            }
        }
    fi;

    r = ro;
    c = col;
}
*/

inline get_live(r, c) {
    live = 0;
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

//Initialize the board
proctype BoardInit() {
    int r, c;
    for(r : 0 .. ROWS - 1) {
        for(c : 0 .. COLS - 1) {
            if
            :: current[r].col[c] = 0;
            :: current[r].col[c] = 1;
            fi;

            //Copy board into buffer
            buffer[r].col[c] = current[r].col[c];
        }
    }

    turn++;
    cur_id = PRINT_STATE;
}

//Print the board
proctype BoardPrint() {
    int r, c;

    do
    :: cur_id == PRINT_STATE && (turn > 0 && turn <= MAX_TURN) ->
        printf("Current Board\n");

        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(r, c);
                c_code {
                    FILE *fp;
                    fp = fopen("test.txt", "a");
                    fprintf(fp, "%d ", now.current[now.ro].col[now.col]);
                    fclose(fp);
                }
                printf(" %d (%d) ", current[r].col[c], live);
            }
            c_code {
                FILE *fp;
                fp = fopen("test.txt", "a");
                fprintf(fp, "\n");
                fclose(fp);
            }
            printf("\n");
        }

        cur_id = COPY_STATE;
    :: turn > MAX_TURN ->
        break;
    od;
};

//Copy over the last two board states
proctype StorePreviousStates() {
    int r, c;
    do
    :: cur_id == COPY_STATE && (turn > 0 && turn <= MAX_TURN) ->
        if
        :: turn > 1 ->
            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    prevTwo[r].col[c] = prevOne[r].col[c];
                }
            }
            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    prevOne[r].col[c] = buffer[r].col[c];
                }
            }
            :: turn == 1 ->
            for(r : 0 .. ROWS - 1) {
                for(c : 0 .. COLS - 1) {
                    prevOne[r].col[c] = buffer[r].col[c];
                }
            }
        fi;

        cur_id = TRANS_STATE;
    :: turn > MAX_TURN ->
        break;
    od;
}

//Update the board
proctype BoardTransition() {
    int r, c;
    do
    :: cur_id == TRANS_STATE && (turn > 0 && turn <= MAX_TURN) ->
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

        //Copy buffer into board
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                current[r].col[c] = buffer[r].col[c];
            }
        }

        turn++;
        cur_id = OSCILLATOR_STATE;
    :: turn > MAX_TURN ->
        break;
    od;
}

//Update the board for Oscillators
proctype OscillatorSearch() {
    int r, c;
    do
    :: cur_id == OSCILLATOR_STATE && (turn > 0 && turn <= MAX_TURN) ->
        bool same = 1;

        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                same = (same && (prevTwo[r].col[c] == buffer[r].col[c]));
            }
        }

        assert(!same);
	cur_id = PRINT_STATE;
    od;
}

init {
    run BoardInit();
    run BoardPrint();
    run StorePreviousStates();
    run BoardTransition();
    run OscillatorSearch();
}

