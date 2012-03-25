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