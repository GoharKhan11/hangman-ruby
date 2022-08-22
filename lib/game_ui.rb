class GameUI

    def display_board_state (hangman_game_instance)
        # HangmanGame -> str
        # Shows the current game board, guesses made and mistake count

        # Show guess board
        puts "Guess Board: #{hangman_game_instance.get_guess_board}"
        # Show guesses
        puts "Guesses: #{hangman_game_instance.get_guesses}"
        # Show mistake count
        puts "Mistakes: #{hangman_game_instance.mistakes}"

    end

    def play_round (hangman_game_instance, lower_word_length=5, upper_word_length=12, mistakes_allowed=6)
        # HangmanGame, int, int -> nil
        # Plays a round of hangman.
        # lower_word_length and upper_word_length are used to set a new word.

        # Setup the hangman board
        setup_hangman(hangman_game_instance, lower_word_length, upper_word_length)

        # Intro messages
        puts "Welcome to hangman!" 
        puts "you will get a random word between #{lower_word_length} and #{upper_word_length} letters."
        puts "If you guess a letter wrong #{mistakes_allowed} times then you lose."

        # Boolean to track if the game has been won
        game_won = false

        # puts "#{hangman_game_instance.get_guess_word}"
        
        # Keeps playing till the player wins or makes too many mistakes
        # Steps: show board state > get and add guess and update board > 
        until game_won || (hangman_game_instance.mistakes >= mistakes_allowed)
            # Show current board state and then add line break (for readability)
            puts "current board state:"
            display_board_state(hangman_game_instance)
            puts "\n"

            # Checks if the guess was valid and got added
            guess_was_added = false

            # Tries getting a valid guess until the guess was valid and added 
            until guess_was_added
                # No guess parameter, it does a gets request itself
                # If it succeeds it returns true
                guess_was_added = _add_valid_guess(hangman_game_instance)
                puts "Entry was not valid, please try again" unless guess_was_added
            end

            game_won = true if hangman_game_instance.guess_word_found?

        end

        # CHeck if game is won
        if game_won == true
            puts "Congratulations! You guessed the word correctly!"
        else
            puts "Game over, you have made #{mistakes_allowed} mistakes."
            puts "The correct word was: #{hangman_game_instance.get_guess_word}"
        end

    end

    def setup_hangman (hangman_game_instance, lower_word_length=5, upper_word_length=12)
        # HangmanGame, int, int -> nil
        # Sets up a round of hangman with a new word with length between
        # lower_word_length and upper_word_length.

        # Reset HangmanGame board (guess_word and guess_board is reset in set_new_word)
        hangman_game_instance.reset_used_letters
        hangman_game_instance.reset_mistake_count
        # Sets a new guess_word and sets the guess_board
        # according to the length of the guess_word
        hangman_game_instance.set_new_word(lower_word_length, upper_word_length)
    end

    # Private methods
    private

    # SECTION START: play_round helper functions

    def _add_valid_guess (hangman_game_instance)
        # nil -> bool
        # Tries to add a guess.
        # Returns true if the letter gets added successfully else returns false.
        # Note: this asks the user for a guess itself, does not take a guess. 

        # Boolean to see if the guess addition succeeded
        guess_succeeded = true

        # Gets input from the user for the hangman letter (remove trailing end line)
        user_letter = gets.chomp

        # Tries to add guess
        begin
            hangman_game_instance.add_guess(user_letter)
        # If the guess addition failed set guess_succeeded to false
        rescue => exception
            guess_succeeded = false
        end
        return guess_succeeded
        
    end

    # SECTION END

end