#define ROWS 10
#define COLS 10
#define TRANS_ID 0
#define PRINT_ID 1
#define SEARCH_ID 2
#define MAX_TURN 20
#define get_live (live, r, c) (live = 0; \
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

//State variables
bool cur_id = 0;
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
        printf("Next Turn\n");

        for(r : 0 .. ROWS - 1) {
            for(c : 0 .. COLS - 1) {
                get_live(live, r, c);
                printf(" %d (%d) ", board[r].col[c], live);
            }
            printf("\n");
        }

        cur_id = TRANS_ID;
    :: turn > MAX_TURN ->
        break;
    od;
};

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
        cur_id = PRINT_ID;
    :: turn > MAX_TURN ->
        break;
    od
}

init {
    run BoardInit();
    run BoardPrint();
    run BoardTransition();
}
