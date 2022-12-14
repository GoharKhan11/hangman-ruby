require "json"
require "./lib/generate_word_bank.rb"
require "./lib/invalid_word_error.rb"
require "./lib/invalid_entry_error.rb"

class HangmanGame

   def initialize ()
        @guess_word = []
        @guess_board = []
        @used_letters = []
        @mistakes = 0
        @mistakes_allowed = 6
        # Notes the range of word lengths in the already existing wordbank
        @lower_letter_range = 5
        @upper_letter_range = 12
    end

    attr_reader :mistakes
    attr_reader :mistakes_allowed
    attr_reader :lower_letter_range
    attr_reader :upper_letter

    def set_new_word (lower_word_length=5, upper_word_length=12)
        # int, int -> nil
        # Gets a random word within the desired length, split the letters
        # into array elements and saves it in the class @guess_word.
        # Note: array makes it easier to go through.
        # Note: uses get_new_word

        # Get a random new word and saves in all lower case
        random_word = _get_new_word(lower_word_length=5, upper_word_length=12)
        random_word.downcase!
        # Split and store the random word
        @guess_word = random_word.split("")
        # Sets the game board as _ for each letter to be guessed by default
        @guess_board = Array.new(random_word.length, "_")
    
    end

    def set_game_state(set_guess_word, set_guess_board, set_used_letters,
        set_mistakes, set_mistakes_allowed,
         set_lower_letter_range=5, set_upper_letter_range=12)
        # array, array, array, int, int, int -> nil
        # Set all existing attributes of the hangman game.
        # Note: this is used to load games.

        @guess_word = set_guess_word
        @guess_board = set_guess_board
        @used_letters = set_used_letters
        @mistakes = set_mistakes
        @mistakes_allowed = set_mistakes_allowed
        @lower_letter_range = set_lower_letter_range
        @upper_letter_range = set_upper_letter_range
    end

    def add_guess (guess_letter)
        # str -> nil
        # Takes a letter being guessed and adds it to the guessed letters.
        # If the letter is correct it updates the guess board with the correct letters.
        # Warning: letters already guessed raise an error
        # Warning: if the guess word is an empty string returns an error

        # If the guess word is an empty string raise an error
        if @guess_word.length == 0
            raise InvalidWordError.new("the word is an empty string")
        end

        unless is_single_letter?(guess_letter)
            raise InvalidEntryError.new("This is not a valid entry, please enter a letter")
        end

        # Makes the guess letter lower case since we want to be case insensitive
        guess_letter.downcase!
        # If the letter hasn't been used, apply the guess
        unless @used_letters.include?(guess_letter)

            # Adds guess to used letters
            @used_letters.push(guess_letter)
            # Checks and reveals any matches with the guess word and updates board
            _update_matching_letters(guess_letter)

        # If the guess has been used raise an error
        else
            raise InvalidEntryError.new("This letter has already been used")
        end

    end

    def get_guess_word
        # nil -> str
        # Returns the word being guessed

        @guess_word.join("")
    end

    def get_guesses ()
        # nil -> str
        # Returns a string of the letters used so far in the game.
        return @used_letters.join(", ")
    end

    def get_guess_board ()
        # nil -> str
        # Returns a string to show the word being guessed and missing letters as _ characters.
        return @guess_board.join(" ")
    end

    def get_game_state
        # nil -> hash
        # Returns a has of all attributes and their values.
        # Note: used to save game state.

        hangman_data = {
            guess_word: @guess_word,
            guess_board: @guess_board,
            used_letters: @used_letters,
            mistakes: @mistakes,
            mistakes_allowed: @mistakes_allowed,
            lower_letter_range: @lower_letter_range,
            upper_letter_range: @upper_letter_range
        }
    end

    def guess_word_found?
        # nil -> bool
        # Checks if the current word on the guess board matches the guess word

        @guess_board.join("") == get_guess_word
    end

    def max_mistakes_made?
        # nil -> bool
        # Returns true if mistakes have reached or exceeded mistakes_allowed

        @mistakes == @mistakes_allowed
    end

    def reset_guess_word
        # nil -> nil
        # Sets @guess_word to []
        
        @guess_word = []
    end

    def reset_guess_board
        # nil -> nil
        # Sets @guess_board to []
        
        @guess_board = []
    end

    def reset_used_letters
        # nil -> nil
        # Sets @used_letters to []
        
        @used_letters = []
    end

    def reset_mistake_count
        # nil -> nil
        # Sets @mistakes to 0
        
        @mistakes = 0
    end


    # Private methods start here
    private

    # SECTION START: helper methods for set_new_word method
    # Helping methods to get a random word from set_new_word within the desired letter range

    def _generate_wordbank(lower_word_length, upper_word_length)
        # int, int -> nil
        # Generate a wordbank of desired length words

        # Generates a new bank only if there isn't already a word bank of viable sized words
        # Note: this is to prevent wasting resources making a new game wordbank each time if not needed
        # Note: to be used in get_new_word
        File.exists?("./lib/game_wordbank.txt")
        unless ((@lower_letter_range == lower_word_length) &&
            (@upper_letter_range == upper_word_length) &&
            File.exists?("./lib/game_wordbank.txt"))

            # Create the wordbank with word length in the desired range
            trim_word_bank("./lib/", "./lib/word_bank.txt", lower_word_length, upper_word_length)
            # Store the word bank length limits for next game
            @lower_letter_range = lower_word_length
            @upper_letter_range = upper_word_length
        end
    end

    def _get_random_word ()
        # nil -> nil
        # Get a random word from the game_wordbank.txt file

        # Gets the word bank from the game wordbank file (made using trim_word_bank) and save in a string
        word_list = File.open("./lib/game_wordbank.txt", "r").read
        # Make word list string into an array
        word_list_array = word_list.split("\n")
        # Get a random element of the word list array
        random_word = word_list_array.sample()
        return random_word
    end

    def _get_new_word (lower_word_length=5, upper_word_length=12)
        # int, int -> nil
        # Gets a new word of the desired length.

        # Create a wordbank file for the game with words within the desired length
        _generate_wordbank(lower_word_length, upper_word_length)
        # Get a random word from the trimmed wordbank
        result = _get_random_word()
        # return the random word
        return result
    end

    # SECTION END

    # Section START: helper methods for add_guess

    def _update_matching_letters (guess_letter)
        # str -> nil
        # Checks if the letter exists in the guess word and updates the game board
        # in positions where it exists.

        # Keep track of whether any letter match has been found
        match_found = false

        # Go through each letter of the guess word to match (keep index to update board)
        @guess_word.each_with_index do |letter, index|
            # Check if the letter matches current index in guess word
            if letter == guess_letter
                # Reveals the letter in the current position in the guess board
                @guess_board[index] = letter
                # Since at least one letter has matched we make match found true
                match_found = true unless match_found
            end
        end

        # If no letter matched then adds a mistake
        @mistakes += 1 unless match_found
        
    end

    def is_single_letter? (entry_string)
        # any -> bool
        # Checks if the entered object is a string
        # containing a single letter

        # Check if entry is a string of length 1 and not a digit
        if (entry_string.is_a?(String)) && (entry_string.length == 1) &&
            (entry_string.ord >= 65) && (entry_string.ord <= 122)
            
            return true
        else
            return false
        end
    end


    # SECTION END

end
