package by.grodnosoft.algoclass.week2;

import java.io.BufferedReader;
import java.io.DataInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;

/**
 * The file contains all of the integers between 1 and 10,000 (inclusive) in unsorted order (with no integer repeated). 
 * The integer in the i-th row of the file gives you the i-th entry of an input array.
 * Your task is to compute the total number of comparisons used to sort the given input file by QuickSort. 
 * As you know, the number of comparisons depends on which elements are chosen as pivots, so we'll ask you to explore three different pivoting rules.
 * You should not count comparisons one-by-one. Rather, when there is a recursive call on a subarray of length m, 
 * you should simply add m−1 to your running total of comparisons. (This is because the pivot element will be compared to each of the other m−1 elements in the subarray in this recursive call.)
 * 
 * WARNING: The Partition subroutine can be implemented in several different ways, and different implementations can give you differing numbers of comparisons. 
 * For this problem, you should implement the Partition subroutine as it is described in the video lectures (otherwise you might get the wrong answer).
 * 
 * DIRECTIONS FOR PROBLEMS:
 * - For the first part of the programming assignment, you should always use the first element of the array as the pivot element.
 * - Compute the number of comparisons, always using the final element of the given array as the pivot element.
 *   Recall from the lectures that, just before the main Partition subroutine, you should exchange the pivot element (i.e., the last element) with the first element.
 * - Compute the number of comparisons, using the "median-of-three" pivot rule. 
 *   [This primary motivation behind this rule is to do a little bit of extra work to get much better performance on input arrays that are already sorted.] 
 *   In more detail, you should choose the pivot as follows. Consider the first, middle, and final elements of the given array. 
 *   (If the array has odd length it should be clear what the "middle" element is; for an array with even length 2k, use the k-th element as the "middle" element. 
 *   So for the array: 4 5 6 7, the "middle" element is the second one ---- 5 and not 6!) 
 *   Identify which of these three elements is the median (i.e., the one whose value is in between the other two), and use this as your pivot. 
 *   SUBTLE POINT: A careful analysis would keep track of the comparisons made in identifying the median of the three elements. 
 *   You should NOT do this. That is, as in the previous two problems, you should simply add m−1 to your running total of comparisons every time you recurse on a subarray with length m.
 * 
 * @author ddudnik
 *
 */
public class CountQuickSortComparisons {
	
	private static BigDecimal comparisonCounter = new BigDecimal(0);
	
	public static enum PivotSelection{
		FIRST,
		LAST,
		MEDIAN
	}

	public static void main(String[] args) throws IOException {
		String fName = args[0];
		if (fName == null || fName.isEmpty()){
			throw new IllegalArgumentException("File name should be specified as the only one argument!");
		}
		int[] input = initializeInputArray(fName);
		
		CountQuickSortComparisons.comparisonCounter = new BigDecimal(0);
		performQuickSort(input.clone(), PivotSelection.FIRST);
		System.out.println("First element selected as pivot, comparisons count: " + CountQuickSortComparisons.comparisonCounter.longValueExact());
		
		CountQuickSortComparisons.comparisonCounter = new BigDecimal(0);
		performQuickSort(input.clone(), PivotSelection.LAST);
		System.out.println("Last element selected as pivot, comparisons count: " + CountQuickSortComparisons.comparisonCounter.longValueExact());

		CountQuickSortComparisons.comparisonCounter = new BigDecimal(0);
		performQuickSort(input.clone(), PivotSelection.MEDIAN);
		System.out.println("Median of three element selected as pivot, comparisons count: " + CountQuickSortComparisons.comparisonCounter.longValueExact());
	}
	
	private static int[] performQuickSort(int[] input, PivotSelection pivotSelection){
		if (input.length <= 1){
			return input;
		}
		
		int pivotIndex = 0;
		
		switch (pivotSelection) {
		case FIRST:
			pivotIndex = 0;
			break;
		case LAST:
			pivotIndex = input.length - 1;
			break;
		case MEDIAN:
			int firstElement = input[0];
			int lastElement = input[input.length - 1];
			int middleElement = 0;
			int middleIndex = 0;
			if (input.length % 2 == 0){
				middleIndex = input.length / 2;
			}else{
				middleIndex = (input.length + 1) / 2; 
			}
			middleIndex--;
			middleElement = input[middleIndex];
			
			int[] three = new int[]{firstElement, middleElement, lastElement};
			Arrays.sort(three);
			int pivot = three[1];
			
			if (pivot == firstElement){
				pivotIndex = 0;
			}else if (pivot == lastElement){
				pivotIndex = input.length - 1;
			}else{
				pivotIndex = middleIndex;
			}
			
			break;
		default:
			throw new RuntimeException("Wrong pivot selection!");
		}

		// counting comparisons
		comparisonCounter = comparisonCounter.add(new BigDecimal(input.length - 1));

		int pivotElement = input[pivotIndex];
		partition(input, pivotIndex);
		
		Collection<Integer> first = new ArrayList<Integer>();
		Collection<Integer> second = new ArrayList<Integer>();
		for (int element : input){
			if (element < pivotElement){
				first.add(element);
			}else if (element > pivotElement){
				second.add(element);
			}
		}
		
		int[] firstArray = collectionToArray(first);
		int[] secondArray = collectionToArray(second);
		
		int[] firstSorted = performQuickSort(firstArray, pivotSelection);
		int[] secondSorted = performQuickSort(secondArray, pivotSelection);
		
		int[] firstSortedNew = Arrays.copyOf(firstSorted, firstSorted.length + 1);
		firstSortedNew[firstSortedNew.length - 1] = pivotElement;
		
		return concat(firstSortedNew, secondSorted);
	}
	
	private static void partition(int[] input, int pivotIndex){

		int pivot = input[pivotIndex];
		if (pivotIndex > 0){
			swap(input, 0, pivotIndex);
		}
		
		int i = 1;
		for (int j = 1; j < input.length; j++){
			if (input[j] < pivot){
				swap(input, j, i);
				i++;
			}
		}
		
		swap(input, 0, i -1);
	}
	
	private static int[] collectionToArray(Collection<Integer> collection){
		int[] result = new int[collection.size()];
		int i = 0;
		for (Integer element : collection){
			result[i] = element.intValue();
			i++;
		}
		return result;
	}
	
	private static int[] concat(int[] A, int[] B) {
		int[] C = new int[A.length + B.length];
		System.arraycopy(A, 0, C, 0, A.length);
		System.arraycopy(B, 0, C, A.length, B.length);
		return C;
	}
	
	private static void swap(int[] input, int i, int j){
		int temp = input[i];
		input[i] = input[j];
		input[j] = temp;
	}
	
	private static int[] initializeInputArray(String fileName) throws NumberFormatException, IOException{
		FileInputStream fis = new FileInputStream(fileName);
		DataInputStream in = new DataInputStream(fis);
		BufferedReader reader = new BufferedReader(new InputStreamReader(in));
		
		int[] input = new int[10000]; 
		String strLine;
		int i = 0;
		while ((strLine = reader.readLine()) != null)   {
			input[i] = Integer.parseInt(strLine);
			i++;
		}
		in.close();
		
		return input;
	}
}
