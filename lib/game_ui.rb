require "json"
require "./lib/hangman_engine.rb"

class GameUI

    def initialize
        # nil -> nil

        @hangman_game_instance = HangmanGame.new()
        # Stores whether the main menu has been entered at least once (to decide how to display menu) 
        @first_menu = true
    end

    def intro_menu
        # nil -> nil
        # Show intro menu and handle responses.

        puts "Welcome to hangman!\n" if @first_menu
        @first_menu = false if @first_menu
        puts "Please enter a key below to select an option:"
        puts "\t1 - Start a new game"
        puts "\t2 - Load last saved game"
        puts "\tany other key to exit"
        puts "\n"

        # Gets menu selection
        user_menu_entry = gets.chomp
        puts "\n"

        # Starts a new game when 1 is entered
        if user_menu_entry == "1"
            system "clear"
            new_game()
        # Loads a game when 2 is entered
        elsif user_menu_entry == "2"
            system "clear"
            continue_saved_game()
        else
            puts "Exiting game, bye!"
        end
    end

    def display_board_state ()
        # HangmanGame -> str
        # Shows the current game board, guesses made and mistake count

        puts "Current Game State:"

        # Show guess board
        puts "Guess Board: #{@hangman_game_instance.get_guess_board}"
        # Show guesses
        puts "\tGuesses: #{@hangman_game_instance.get_guesses}"
        # Show mistake count
        puts "\tMistakes: #{@hangman_game_instance.mistakes}"
        puts "Enter 1 to save game."
        puts "Enter 2 to exit to main menu"
        puts "\n"

    end

    def new_game
        # nil -> nil
        # Starts a fresh game of hangman, resets board and continues game from there.
        # Note: uses continue_round

        # Set up the game board and reset existing values
        setup_hangman()
        # Continue round with fresh board
        continue_round()
    end

    def continue_saved_game()
        # nil -> nil
        # Loads and resume a hangman game

        # Loads game and stores the amount of mistakes allowed
        mistakes_allowed = load_game()
        # Stores true if a finished game was loaded (game won or max mistakes made)
        game_ended = @hangman_game_instance.guess_word_found? || @hangman_game_instance.max_mistakes_made?
        # If the game has ended show a game end message immediately and return to menu
        if game_ended
            _round_end_message(@hangman_game_instance.guess_word_found?)
        else
            # continues round from load state
            continue_round()
        end
    end

    def continue_round (lower_word_length=5, upper_word_length=12)
        #nil -> nil
        # Continues a round from the current board state

        # Boolean to track if the game has been won
        game_won = false
        # Boolean to allow exiting the current game 
        exit_game = false

        # Keeps playing till the player wins or makes too many mistakes
        # Steps: show board state > get and add guess and update board > 
        until game_won || exit_game || (@hangman_game_instance.mistakes >= @hangman_game_instance.mistakes_allowed)
            # Show board state before guess
            display_board_state()
            # Get user entry and handle it
            # stores return value in exit game because it returns true when exit requested
            exit_game = _handle_user_entry()
            # Sets game won to true when match is found
            game_won = true if @hangman_game_instance.guess_word_found?
        end

        # If game was exited before completion returns to intro menu
        if exit_game
            intro_menu()
        # If game was completed moves to game end message
        else
            puts _round_end_message(game_won)
            puts "\n"
            puts "Returning to main menu."
            puts "\n"
            intro_menu()
        end
    end

    def setup_hangman ()
        # HangmanGame, int, int -> nil
        # Sets up a round of hangman with a new word with length between
        # lower_word_length and upper_word_length.

        # Reset HangmanGame board (guess_word and guess_board is reset in set_new_word)
        @hangman_game_instance.reset_used_letters
        @hangman_game_instance.reset_mistake_count
        # Sets a new guess_word and sets the guess_board
        # according to the length of the guess_word
        @hangman_game_instance.set_new_word()
    end

    def save_game()
        # nil -> nil
        # Create a savefile in a directory called savedata in the root folder.
        # Note: creates savedata directory if it doesn't exist
        # Note: uses JSON format
        # Note: save file is called saved_game.json

        # Create savedata directory unless it already exists
        Dir.mkdir("./savedata") unless Dir.exists?("./savedata")
        # Opens save file in savedata directory to store save data
        save_file = File.open("./savedata/saved_game.json", "w")

        # Get all required data to save
        data_content = _get_save_data()
        # convert to a JSON string
        data_string = JSON.pretty_generate(data_content) 
        # Store JSON sata string in our save file
        save_file.puts(data_string)

        save_file.close()

    end

    def load_game ()
        # nil -> nil
        # Create a savefile in a directory called savedata in the root folder.
        # Returns an int for mistakes allowed
        # Note: save file is called saved_game.json.
        # Note: aborts if save file not found.

        if File.exists?("./savedata/saved_game.json")
            # load the save file in savedata
            data_content_file = File.open("./savedata/saved_game.json")
            # Get data content file as a string
            data_content = data_content_file.read
            # Convert the json object to a hash with the save data
            load_data = JSON.parse(data_content)
            # Load data into the hangman game
            @hangman_game_instance.set_game_state(
            load_data["guess_word"],
            load_data["guess_board"],
            load_data["used_letters"],
            load_data["mistakes"],
            load_data["mistakes_allowed"],
            load_data["lower_letter_range"],
            load_data["upper_letter_range"]
            )

            # close data content file
            data_content_file.close
        # Let user know if no save file was found
        # Returns to intro menu
        else
            puts "No save file found."
            intro_menu()
            return 0
        end
    end

    # Private methods
    private

    # SECTION START: helper functions to play rounds

    def _add_valid_guess (user_entry)
        # nil -> bool
        # Tries to add a guess.
        # Returns true if the letter gets added successfully else returns false.
        # Note: this asks the user for a guess itself, does not take a guess. 

        # Boolean to see if the guess addition succeeded
        guess_succeeded = true

        # Tries to add guess
        begin

            @hangman_game_instance.add_guess(user_entry)
        # If the guess addition failed set guess_succeeded to false
        rescue => exception
            guess_succeeded = false
        end

        guess_succeeded
        
    end

    def _handle_user_entry
        # nil -> nil
        # Prompts the user until a valid guess is provided and enters it into the game.
        # Returns false unless the user entry is 2, then returns true.

        # Checks if the guess was valid and got added
        guess_was_added = false

        # Tries getting a valid guess until the guess was valid and added 
        until guess_was_added

            # No guess parameter, it does a gets request itself
            user_entry = gets.chomp
            # When 1 is entered saves the game
            if user_entry == "1"
                system "clear"
                save_game()
                puts "Game saved!\n"
            elsif user_entry == "2"
                system "clear"
                puts "Exiting to main menu.\n\n"
                # Returns true, this is to know when to exit the game
                return true
            else
                system "clear"
                # If it succeeds it returns true
                guess_was_added = _add_valid_guess(user_entry)
                puts "Entry was not valid, please try again\n\n" unless guess_was_added
                display_board_state()
            end

        end
        system "clear"
        return false

    end

    def _round_end_message(win_status)
        # bool -> nil
        # Displays a game end message.
        # Note: different messages for winning or losing.
        # Note: reveals word on loss.

        # CHeck if game is won
        if win_status == true
            # Show win quote
            result = "Congratulations! You guessed the word correctly!"
        # If game wasn't won
        else
            # Show loss quote
            result = "Game over, you have made #{@hangman_game_instance.mistakes_allowed} mistakes.\n"
            # Reveal the word
            result += "The correct word was: #{@hangman_game_instance.get_guess_word}"
        end
        result
    end

    # SECTION END

    def _get_save_data ()
        # HangmanGame -> hash
        # gets a hash containing all data from the hangman game and GameUI to be saved

        result = @hangman_game_instance.get_game_state
    end

end
