# The file contains all of the integers between 1 and 10,000 (inclusive) in unsorted order (with no integer repeated). 
# The integer in the i-th row of the file gives you the i-th entry of an input array.
# Your task is to compute the total number of comparisons used to sort the given input file by QuickSort. 
# As you know, the number of comparisons depends on which elements are chosen as pivots, so we'll ask you to explore three different pivoting rules.
# You should not count comparisons one-by-one. Rather, when there is a recursive call on a subarray of length m, 
# you should simply add m−1 to your running total of comparisons. (This is because the pivot element will be compared to each of the other m−1 elements in the subarray in this recursive call.)
# 
# WARNING: The Partition subroutine can be implemented in several different ways, and different implementations can give you differing numbers of comparisons. 
# For this problem, you should implement the Partition subroutine as it is described in the video lectures (otherwise you might get the wrong answer).
# 
# DIRECTIONS FOR PROBLEMS:
# - For the first part of the programming assignment, you should always use the first element of the array as the pivot element.
# - Compute the number of comparisons, always using the final element of the given array as the pivot element.
#   Recall from the lectures that, just before the main Partition subroutine, you should exchange the pivot element (i.e., the last element) with the first element.
# - Compute the number of comparisons, using the "median-of-three" pivot rule. 
#   [This primary motivation behind this rule is to do a little bit of extra work to get much better performance on input arrays that are already sorted.] 
#   In more detail, you should choose the pivot as follows. Consider the first, middle, and final elements of the given array. 
#   (If the array has odd length it should be clear what the "middle" element is; for an array with even length 2k, use the k-th element as the "middle" element. 
#   So for the array: 4 5 6 7, the "middle" element is the second one ---- 5 and not 6!) 
#   Identify which of these three elements is the median (i.e., the one whose value is in between the other two), and use this as your pivot. 
#   SUBTLE POINT: A careful analysis would keep track of the comparisons made in identifying the median of the three elements. 
#   You should NOT do this. That is, as in the previous two problems, you should simply add m−1 to your running total of comparisons every time you recurse on a subarray with length m.

$comparison_counter = 0

def initialize_input_array(filename)
  input = []
  File.open(filename, 'r') do |file|
    while line = file.gets
      input.push line.to_i 10
    end
  end
  input
end

class PivotSelection
  FIRST=1
  LAST=2
  MEDIAN=3
end

class Array

  def swap!(a, b)
         self[a], self[b] = self[b], self[a]
    self
  end
    
  def quicksort_partition!(pivot_index)
    raise IndexError, "#{pivot_index} >= size (#{self.size}) !!!" if pivot_index >= self.size
    
    pivot = self[pivot_index]
    if pivot_index > 0
      self.swap!(0, pivot_index)
    end
    
    split_index = 1;
    self.each_with_index do |item, index|
      if index == 0
        next
      end
      if item < pivot
        self.swap!(index, split_index)
        split_index += 1
      end
    end
    
    self.swap!(0, split_index - 1)
    
    self
 end
end

def perform_quicksort(input_array, pivot_selection)
    return input_array if input_array.size <= 1
    
    if PivotSelection::FIRST == pivot_selection
      pivot_index = 0
    elsif PivotSelection::LAST == pivot_selection
      pivot_index = input_array.size - 1
    elsif PivotSelection::MEDIAN == pivot_selection
      first = input_array[0]
      last = input_array[input_array.size - 1]
      middle = 0
      middle_index = 0
      if input_array.size.even?
        middle_index = input_array.size/2
      else
        middle_index = (input_array.size + 1)/2
      end
      middle_index -= 1
      middle = input_array[middle_index]
      
      pivot = [first, middle, last].sort[1]
      if pivot == first
        pivot_index = 0
      elsif pivot == last
        pivot_index = input_array.size - 1
      else
        pivot_index = middle_index
      end
      
    else
      raise "Wrong pivot selection!"
    end
    
    pivot_element = input_array[pivot_index]
    
    # counting comparisons
    $comparison_counter += input_array.size - 1

    begin
      input_array.quicksort_partition! pivot_index
    rescue Exception => e
      puts "Wrong pivot index!"
      puts e.message
      puts e.backtrace.inspect
      return input_array  
    end
    
    first, second = input_array.partition do |item|
      item < pivot_element
    end
    second.shift
    
    sorted_first = perform_quicksort(first, pivot_selection)
    
    sorted_second = perform_quicksort(second, pivot_selection)
    
    sorted_first.push(pivot_element)
    sorted_first + sorted_second
end

if (ARGV.size > 0)
  input_array = initialize_input_array ARGV[0]

  $comparison_counter = 0
  perform_quicksort(Marshal.load(Marshal.dump(input_array)), PivotSelection::FIRST)
  puts "First element selected as pivot, comparisons count: #{$comparison_counter}"
  
  $comparison_counter = 0
  perform_quicksort(Marshal.load(Marshal.dump(input_array)), PivotSelection::LAST)
  puts "Last element selected as pivot, comparisons count: #{$comparison_counter}"

  $comparison_counter = 0
  perform_quicksort(Marshal.load(Marshal.dump(input_array)), PivotSelection::MEDIAN)
  puts "Median of three selected as pivot, comparisons count: #{$comparison_counter}"
  
else
  puts "File name should be specified as the only one argument!"
end