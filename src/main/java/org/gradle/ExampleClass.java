package org.gradle;

public class ExampleClass {

	public static void main(String[] args) {
		throwException();
	}
	
	public static void throwException(){
		int i = 10 / 0;
		i /= 0;
		System.out.println(Integer.toString(i));
	}

}
