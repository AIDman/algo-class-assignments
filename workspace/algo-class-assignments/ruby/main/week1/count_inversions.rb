# The file contains all the 100,000 integers between 1 and 100,000 (including both) in some random order( no integer is repeated).
# Your task is to find the number of inversions in the file given (every row has a single integer between 1 and 100,000). 
# Assume your array is from 1 to 100,000 and i-th row of the file gives you the i-th entry of the array.

$inversion_counter = 0

def initialize_input_array(filename)
  input = []
  File.open(filename, 'r') do |file|
    while line = file.gets
      input.push line.to_i 10
    end
  end
  input
end

def count_inversions(input_array=[])
  return input_array if input_array.size <= 1

  first_sorted_array = count_inversions input_array[0..input_array.size / 2 - 1]
  second_sorted_array = count_inversions input_array[input_array.size / 2..input_array.size]

  result_array = []
  i = 0
  j = 0
  input_array.size.times.each do |k|
    if i < first_sorted_array.size && (j >= second_sorted_array.size || first_sorted_array[i] <= second_sorted_array[j])
      result_array[k] = first_sorted_array[i]
      i += 1
    elsif j < second_sorted_array.size && (i >= first_sorted_array.size || first_sorted_array[i] > second_sorted_array[j])
      result_array[k] = second_sorted_array[j]
      j += 1
      
      # counting inversions
      $inversion_counter += first_sorted_array.size - i
    end
  end
  result_array
end

if (ARGV.size > 0)
  input_array = initialize_input_array ARGV[0]
  count_inversions(input_array)
  print "Iversions count: #{$inversion_counter}"
else
  print "File name should be specified as the only one argument!"
end