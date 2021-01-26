# TODO: Queen
# TODO: King
# TODO: Knight
# TODO: Rook
# TODO: Castling, queenside and kingside
# TODO: En passant
# TODO: Moving puts king in check (illegal) (P, N, B, R, Q, K)
# TODO: Merge black and white rules so that code isn't getting huge

mutable struct Board
   color
    piece
end

# Simple board initialization
standard_board = Board([2  2  2  2  2  2  2  2;
                        2  2  2  2  2  2  2  2;
                        0  0  0  0  0  0  0  0;
                        0  0  0  0  0  0  0  0;
                        0  0  0  0  0  0  0  0;
                        0  0  0  0  0  0  0  0;
                        1  1  1  1  1  1  1  1;
                        1  1  1  1  1  1  1  1],
                       ['R'  'N'  'B'  'Q'  'K'  'B'  'N'  'R';
                        'P'  'P'  'P'  'P'  'P'  'P'  'P'  'P';
                        ' '  ' '  ' '  ' '  ' '  ' '  ' '  ' ';
                        ' '  ' '  ' '  ' '  ' '  ' '  ' '  ' ';
                        ' '  ' '  ' '  ' '  ' '  ' '  ' '  ' ';
                        ' '  ' '  ' '  ' '  ' '  ' '  ' '  ' ';
                        'P'  'P'  'P'  'P'  'P'  'P'  'P'  'P';
                        'R'  'N'  'B'  'Q'  'K'  'B'  'N'  'R'])

# Useful utility functions
function print_board(board::Board)
    for row in 1:8
        for col in 1:8
            piece = board.piece[row, col]
            if piece == ' '
                print("   ")
            else
               color_human = '#'
                if board.color[row, col] == 1
                   color_human = 'w'
                elseif board.color[row, col] == 2
                   color_human = 'b'
                end
                print(piece,color_human, ' ')
            end
        end
        println()
    end
end

# Convert a piece in X, Y representation (X being side to side and Y
# being up to down) to array representation for the computer
cr(x, y) = (9 - y, x)

# Give true or false value on if the location is outside of the board
function outside_board(x, y)
    x < 1 || x > 8 || y < 1 || y > 8
end

# Whether it is legal or not, this function will do the move
function force_move!(board::Board, x, y, d_x, d_y)
    row = 9 - y
    col = x
    dest_row = 9 - d_y
    dest_col = d_x

    board.color[dest_row, dest_col] = board.color[row, col]
    board.color[row, col] = 0

    board.piece[dest_row, dest_col] = board.piece[row, col]
    board.piece[row, col] = ' '
end

# This will only move the piece if the move is a legal move
function check_legal_move(board::Board, x, y, d_x, d_y)::Bool
    row = 9 - y
    col = x
    dest_row = 9 - d_y
    dest_col = d_x

    # Identify the type of piece, and then split into the rules on if it is
    # legal or not.
    piece = board.piece[row, col]
    color = board.color[row, col]

    # Disallow moving to exact same square
    if x == d_x && y == d_y
        return false
    end

    # PAWN MOVES
    # =============
    if piece == 'P'
        # White pawn
        if color == 1
            # Staying in same file
            if x == d_x
                # One space forward
                if d_x - y == 1
                    if board.piece[dest_row, dest_col] == ' '
                        return true
                    else
                        return false
                    end
                # Two spaces forward
                elseif d_y - y == 2 && y == 2
                    if board.piece[dest_row, dest_col] == ' ' && board.piece[row-1, col] == ' '
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            # Capturing to the side
            elseif abs(d_x - x) == 1 && d_y - y == 1
                if board.color[dest_row, dest_col] == 2
                    return true
                else
                    return false
                end
            # Something else
            else
                return false
            end
        # Black pawn
        elseif color == 2
            # Staying in same file
            if x == d_x
                # One space forward
                if y - d_y == 1
                    if board.piece[dest_row, dest_col] == ' '
                        return true
                    else
                        return false
                    end
                # Two spaces forward
                elseif y - d_y == 2 && y == 7
                    if board.piece[dest_row, dest_col] == ' ' && board.piece[row+1, col] == ' '
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            # Capturing to the side
            elseif abs(d_x - x) == 1 && d_y - y == 1
                if board.color[dest_row, dest_col] == 2
                    return true
                else
                    return false
                end
            # Something else
            else
                return false
            end
        end
    # KNIGHT MOVES
    # ====================
    elseif piece == 'N'
        # Check valid knight move
        if (abs(x - d_x) == 2 && abs(y - d_y) == 1) || (abs(x - d_x) == 1 && abs(y - d_y) == 2)
            # Check to make sure not capturing own color
            if board.color[dest_row, dest_col] == color
                return false
            else
                return true
            end
        else
            return false
        end
    # BISHOP MOVES
    # =================
    elseif piece == 'B'
        # Check valid bishop move
        if (abs(x - d_x) == abs(y - d_y))
            # Check to make sure not capturing own color
            if board.color[dest_row, dest_col] == color
                return false
            else
                # Make sure not moving through any other pieces
                sign_x = 1
                if x - d_x >= 1
                    sign_x = -1
                end
                sign_y = 1
                if y - d_y >= 1
                    sign_y = -1
                end

                # Set move counter to 1 and check places between where
                # you are trying to move to. First check that bishop is
                # skipping at least one square
                if abs(x - d_x >= 2)
                    for m_c = 1:(x-d_x-1)
                        if board.piece[row - sign_y * m_c, col + sign_x * m_c] != ' '
                            return false
                        end
                    end
                end

                return true
            end
        else
            return false
        end
    # Nonexistent piece
    else
        return false
    end
end

# Actually creates the legal move. First checks it then performs it if
# it is valid.
function move!(board::Board, x, y, d_x, d_y)
    if check_legal_move(board, x, y, d_x, d_y)
        force_move!(board, x, y, d_x, d_y)
    end
end

print_board(standard_board)
println()
move!(standard_board, 5, 2, 5, 4)
force_move!(standard_board, 5, 8, 2, 5)
move!(standard_board, 6, 1, 2, 5)
print_board(standard_board)

print(cr(4, 5))
