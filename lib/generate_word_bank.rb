def trim_word_bank (save_directory, word_bank_file, lower_letter_limit, upper_letter_limit)
    # str, str, int, int -> nil
    # Takes in a file path where each line is a word.
    # Creates a file containing the words that have a letter count
    # between the upper and lower limit.
    # Saves the viable words in a text file in the desired directory.
    # Note: the limits are inclusive.
    # Note: new file name is game_wordbank.txt

    # Open desired Files
    # Open source file containing entire wordbank (read mode)
    word_source = File.open(word_bank_file, "r")
    # Create filename and path using provided directory
    trimmed_wordbank_location = save_directory + "game_wordbank.txt"
    # Create or rewrite restricted word list text file in lib directory
    trimmed_wordbank = File.open(trimmed_wordbank_location, "w")
    
    # Gets contents from word source file
    word_list = word_source.read
    # Each word is on a separate line so splits each word to an array item
    word_list_array = word_list.split("\n")

    # Goes through each word in the array
    word_list_array.each do |word|
        word_length = word.length
        # Add current word to the trimmed wordbank file if it has valid length 
        if (word_length >= lower_letter_limit) && (word_length <= upper_letter_limit)
            trimmed_wordbank.puts(word)
        end
    end

    # Close all open files
    word_source.close
    trimmed_wordbank.close

end