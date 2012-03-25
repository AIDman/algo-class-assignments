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
