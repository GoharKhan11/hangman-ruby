require "json"
require "./lib/generate_word_bank.rb"
require "./lib/invalid_word_error.rb"

class HangmanGame

    def initialize ()
        @guess_word = []
        @guess_board = []
        @used_letters = []
        @mistakes = 0
        # Notes the range of word lengths in the already existing wordbank
        @lower_letter_range = 0
        @upper_letter_range = 0
    end

    def set_new_word (lower_word_length=5, upper_word_length=12)
        # int, int -> nil
        # Gets a random word within the desired length, split the letters
        # into array elements and saves it in the class @guess_word.
        # Note: array makes it easier to go through.
        # Note: uses get_new_word

        # Get a random new word
        random_word = _get_new_word(lower_word_length=5, upper_word_length=12)
        # Split and store the random word
        @guess_word = random_word.split("")
    
    end

    def get_guess_word
        # nil -> str
        # Returns the word being guessed

        @guess_word.join("")
    end

    def add_guess (guess_letter)
        # str -> nil
        # Takes a letter being guessed and adds it to the guessed letters.
        # If the letter is correct it updates the guess board with the correct letters.
        # Note: letters already guessed raise an error

        if @guess_word.length == 0
            raise InvalidWordError.new("the word is an empty string")
        end

    end

    def get_guesses ()
        # nil -> str
        # Returns a string of the letters used so far in the game.
        return @used_letters.join(" ")
    end

    def get_guess_board ()
        # nil -> str
        # Returns a string to show the word being guessed and missing letters as _ characters.
        return @guess_board.join(" ")
    end

        # Private methods start here
        private

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

end

hangman = HangmanGame.new()
hangman.set_new_word()
puts hangman.get_guess_word