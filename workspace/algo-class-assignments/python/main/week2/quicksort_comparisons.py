"""
The file contains all of the integers between 1 and 10,000 (inclusive) in unsorted order (with no integer repeated).
The integer in the i-th row of the file gives you the i-th entry of an input array.
Your task is to compute the total number of comparisons used to sort the given input file by QuickSort.
As you know, the number of comparisons depends on which elements are chosen as pivots, so we'll ask you to explore
three different pivoting rules. You should not count comparisons one-by-one.
Rather, when there is a recursive call on a sub-array of length m, you should simply add m−1 to your running total of comparisons.
(This is because the pivot element will be compared to each of the other m−1 elements in the subarray in this recursive call.)

WARNING: The Partition subroutine can be implemented in several different ways,
and different implementations can give you differing numbers of comparisons.
For this problem, you should implement the Partition subroutine as it is described in the video lectures
(otherwise you might get the wrong answer).

DIRECTIONS FOR PROBLEMS:
- For the first part of the programming assignment, you should always use the first element of the array as the pivot element.
- Compute the number of comparisons, always using the final element of the given array as the pivot element.
  Recall from the lectures that, just before the main Partition subroutine, you should exchange the pivot element
  (i.e., the last element) with the first element.
- Compute the number of comparisons, using the "median-of-three" pivot rule.
  [This primary motivation behind this rule is to do a little bit of extra work to get much better performance on input arrays that are already sorted.]
  In more detail, you should choose the pivot as follows. Consider the first, middle, and final elements of the given array.
  (If the array has odd length it should be clear what the "middle" element is; for an array with even length 2k,
  use the k-th element as the "middle" element.
  So for the array: 4 5 6 7, the "middle" element is the second one ---- 5 and not 6!)
  Identify which of these three elements is the median (i.e., the one whose value is in between the other two), and use this as your pivot.
  SUBTLE POINT: A careful analysis would keep track of the comparisons made in identifying the median of the three elements.
  You should NOT do this. That is, as in the previous two problems, you should simply add m−1 to your running total
  of comparisons every time you recur on a sub-array with length m.

First element selected as pivot, comparisons count: 162085
Last element selected as pivot, comparisons count: 164123
Median of three selected as pivot, comparisons count: 138382
"""
import sys


def initialize_input_array(filename):
    with open(filename, 'r') as file:
        return [int(line.rstrip(), 10) for line in file if line.rstrip().isdigit()]


class PivotSelection(object):
    FIRST, LAST, MEDIAN = range(1, 4)


def swap(lst, a, b):
    lst[a], lst[b] = lst[b], lst[a]


def partition(lst, pivot_index):
    list_len = len(lst)
    if pivot_index >= list_len:
        raise Exception("%d >= size (%d) !!!" % (pivot_index, list_len))

    if pivot_index > 0:
        swap(lst, 0, pivot_index)

    split_index = 1
    for index, item in enumerate(lst):
        if index > 0 and item < lst[0]:
            swap(lst, index, split_index)
            split_index += 1

    swap(lst, 0, split_index - 1)
    return lst[:split_index - 1], lst[split_index:]


def pivot_index(pivot_selection, input_array):
    input_len = len(input_array)
    if PivotSelection.FIRST == pivot_selection:
        return 0
    elif PivotSelection.LAST == pivot_selection:
        return input_len - 1
    elif PivotSelection.MEDIAN == pivot_selection:
        first = input_array[0]
        last = input_array[-1]
        if input_len % 2 == 0:
            middle_index = int(input_len / 2) - 1
        else:
            middle_index = int((input_len + 1) / 2) - 1
        middle = input_array[middle_index]
        pivot = sorted([first, middle, last])[1]
        if pivot == first:
            return 0
        elif pivot == last:
            return input_len - 1
        else:
            return middle_index
    else:
        raise Exception("Wrong pivot selection!")


def count_comparisons(input_array, pivot_selection, comparison_counter):
    if len(input_array) <= 1:
        return comparison_counter

    first, second = partition(input_array, pivot_index(pivot_selection, input_array))
    first_count = count_comparisons(first, pivot_selection, comparison_counter)
    second_count = count_comparisons(second, pivot_selection, comparison_counter)

    return comparison_counter + len(input_array) - 1 + first_count + second_count


if len(sys.argv) > 1:
    input_array = initialize_input_array(sys.argv[1])
    print("First element selected as pivot: " + str(
        count_comparisons(list(input_array), PivotSelection.FIRST, 0)))
    print("Last element selected as pivot: " + str(
        count_comparisons(list(input_array), PivotSelection.LAST, 0)))
    print("Median of three selected as pivot: " + str(
        count_comparisons(list(input_array), PivotSelection.MEDIAN, 0)))
else:
    print("File name should be specified as the only one argument!")