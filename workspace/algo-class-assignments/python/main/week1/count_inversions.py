"""
The file contains all the 100,000 integers between 1 and 100,000 (including both) in some random order (no integer is repeated).
Your task is to find the number of inversions in the file given (every row has a single integer between 1 and 100,000).
Assume your array is from 1 to 100,000 and i-th row of the file gives you the i-th entry of the array.
2407905288
"""
import sys


def initialize_input_array(filename):
    with open(filename, 'r') as file:
        return [int(line.rstrip(), 10) for line in file if line.rstrip().isdigit()]


def count_inversions(input_array, inversion_counter):
    input_length = len(input_array)
    if input_length <= 1:
        return input_array, inversion_counter

    first_sorted, first_counter = count_inversions(input_array[:int(input_length / 2)], inversion_counter)
    second_sorted, second_counter = count_inversions(input_array[int(input_length / 2):], inversion_counter)

    result_array, i, j = [0] * input_length, 0, 0
    for k in range(input_length):
        len1 = len(first_sorted)
        if i < len1 and (j >= len(second_sorted) or first_sorted[i] <= second_sorted[j]):
            result_array[k] = first_sorted[i]
            i += 1
        elif j < len(second_sorted) and (i >= len1 or first_sorted[i] > second_sorted[j]):
            result_array[k] = second_sorted[j]
            j += 1
            # counting inversions
            inversion_counter += len1 - i
    return result_array, inversion_counter + first_counter + second_counter

if len(sys.argv) > 1:
    print("Inversions count: %s" % count_inversions(initialize_input_array(sys.argv[1]), 0)[1])
else:
    print("File name should be specified as the only one argument!")
