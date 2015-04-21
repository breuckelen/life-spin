#define ROWS 10
#define COLS 10
#define TRANS_ID 0
#define PRINT_ID 1
#define SEARCH_ID 2
#define OSCILLATOR_ID 3
#define COPY_BOARD_ID 4
#define MAX_TURN 20
#define get_live (live, r, c, board) (live = 0; \
                if \
                :: r == 0 && c == 0 -> \
                    live = board[r + 1].col[c] + board[r + 1].col[c + 1] \
                        + board[r].col[c + 1]; \
                :: (r > 0 && r < ROWS - 1) && c == 0 -> \
                    live = board[r - 1].col[c] + board[r + 1].col[c] \
                        + board[r + 1].col[c + 1] + board[r].col[c + 1] \
                        + board[r - 1].col[c + 1]; \
                :: r == ROWS - 1 && c == 0 -> \
                    live = board[r - 1].col[c] + board[r].col[c + 1] \
                        + board[r - 1].col[c + 1]; \
                :: r == ROWS - 1 && (c > 0 && c < COLS - 1) -> \
                    live = board[r - 1].col[c - 1] + board[r].col[c - 1] \
                        + board[r].col[c + 1] + board[r - 1].col[c + 1] \
                        + board[r - 1].col[c]; \
                :: r == ROWS - 1 && c == COLS - 1 -> \
                    live = board[r - 1].col[c - 1] + board[r].col[c - 1] \
                        + board[r - 1].col[c]; \
                :: (r > 0 && r < ROWS - 1) && c == COLS - 1 -> \
                    live = board[r - 1].col[c - 1] + board[r].col[c - 1] \
                        + board[r + 1].col[c - 1] + board[r + 1].col[c] \
                        + board[r - 1].col[c]; \
                :: r == 0 && c == COLS - 1 -> \
                    live = board[r].col[c - 1] + board[r + 1].col[c - 1] \
                        + board[r + 1].col[c]; \
                :: r == 0 && (c > 0 && c < COLS - 1) -> \
                    live = board[r].col[c - 1] + board[r + 1].col[c - 1] \
                        + board[r + 1].col[c] + board[r + 1].col[c + 1] \
                        + board[r].col[c + 1]; \
                :: else -> \
                    live = board[r - 1].col[c - 1] \
                        + board[r].col[c - 1] + board[r + 1].col[c - 1] \
                        + board[r + 1].col[c] + board[r + 1].col[c + 1] \
                        + board[r].col[c + 1] + board[r - 1].col[c + 1] \
                        + board[r - 1].col[c]; \
                fi;)

typedef row {
    bool col[COLS];
}

//Boards
row board[ROWS];
row buffer[ROWS];
row prevOne[ROWS];
row prevTwo[ROWS];

//State variables
int cur_id = 0;
int turn = 0;

//Initialize the board
proctype BoardInit() {
    int r, c;

    for(r : 0 .. ROWS - 1) {
        for(c : 0 .. COLS - 1) {
            if
            :: board[r].col[c] = 0;
            :: board[r].col[c] = 1;
            fi;

            //Copy board into buffer
            buffer[r].col[c] = board[r].col[c];
        }
    }
    turn++;
    cur_id = PRINT_ID;
}

//Print the board
proctype BoardPrint() {
    int r, c;
    int live;

    do
    :: cur_id == PRINT_ID && (turn > 0 && turn <= MAX_TURN) ->
        printf("Current Board\n");

        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(live, r, c, board);
                    printf(" %d (%d) ", board[r].col[c], live);
	}
            printf("\n");
        }

        printf("Current Buffer\n");
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(live, r, c, buffer);
                    printf(" %d (%d) ", buffer[r].col[c], live);
	}
            printf("\n");
        }

        printf("Current Previous One\n");
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(live, r, c, prevOne);
                    printf(" %d (%d) ", prevOne[r].col[c], live);
	}
            printf("\n");
        }

        printf("Current Previous Two\n");
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(live, r, c, prevTwo);
                    printf(" %d (%d) ", prevTwo[r].col[c], live);
	}
            printf("\n");
        }

        cur_id = COPY_BOARD_ID;
    :: turn > MAX_TURN ->
        break;
    od;
};

//Copy over the last two board states
proctype StorePreviousStates() {
    int r, c;
    int live;
    do
    :: cur_id == COPY_BOARD_ID && (turn > 0 && turn <= MAX_TURN) ->
        if
        :: turn >= 1 ->
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
        :: turn < 1 ->
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                prevOne[r].col[c] = buffer[r].col[c];
            }
        }
        fi;
        cur_id = TRANS_ID;
    od;
}

//Update the board for Oscillators
proctype OscillatorSearch() {
    int r, c;
    do
    :: cur_id == OSCILLATOR_ID && (turn > 0 && turn <= MAX_TURN) ->
        bool same = 1;
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                same = (same && (prevTwo[r].col[c] == buffer[r].col[c]));
            }
        }
        assert(!same);
	cur_id = PRINT_ID;
    od;
}

//Update the board
proctype BoardTransition() {
    int r, c;
    int live;

    do
    :: cur_id == TRANS_ID && (turn > 0 && turn <= MAX_TURN) ->
        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(live, r, c);
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
                board[r].col[c] = buffer[r].col[c];
            }
        }

        turn++;
        cur_id = OSCILLATOR_ID;
    :: turn > MAX_TURN ->
        break;
    od;
}

init {
    run BoardInit();
    run BoardPrint();
    run StorePreviousStates();
    run BoardTransition();
    run OscillatorSearch();
}

