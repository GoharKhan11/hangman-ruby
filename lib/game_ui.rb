class GameUI

    def display_board_state (hangman_game_instance)
        # HangmanGame -> str
        # Shows the current game board, guesses made and mistake count

        # Show guess board
        puts "Guess Board: #{hangman.get_guess_board}"
        # Show guesses
        puts "Guesses: #{hangman.get_guesses}"
        # Show mistake count
        puts "Mistakes: #{hangman.mistakes}"

    end

    def play_round (hangman_game_instance)
        # HangmanGame -> nil
        # Plays a round of hangman
    end

    def setup_hangman (hangman_game_instance, lower_word_length, upper_word_length)
        # Sets up a round of hangman with a new word

end