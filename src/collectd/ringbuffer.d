
module collectd.ringbuffer;

import collectd.collection;
import core.exception;
import core.vararg;
import std.algorithm;
import std.conv;
import std.stdio;

/**
An array-based implementation of a ring buffer.
*/
class RingBuffer(T) : Collection!T
{
	private {
		size_t len;
		size_t head;
		T[] data;
	}

	/**
	 constucts a new RingBuffer of the
	 specified size.
	 */
	public this(size_t len) {
		data.length = len;
	}

	// make sure that the index is
	// within the bounds of the buffer:
	private void checkRange(size_t i) {
		if (i > len) {
			throw new RangeError(" index out of bounds: " ~ to!string(i));
		}
	}

	// gets the ith most recently added item
	private auto getIndex(size_t i) {
		if (i <= head ) {
			return head - i;
		} else {
			return data.length - (i - head);
		}
	}

	@property
	size_t size() { return len; }

	bool isEmpty() { return len == 0; }

	bool contains(T item) {
		auto i = 0;
		auto j = head;
		while (i < len) {
			if (data[j] == item) {
				return true;
			}
			i++;
			j++;
			if (j == data.length)
				j = 0;
		}
		return false;
	}

	void clear() {
		len = 0;
		head = 0;
	}

	@property
	T front() {	return data[getIndex(0)]; }

	private void popFront() {
		if (len > 0) {
			len--;
			head--;
			if (head < 0) {
				head += data.length;
			}
		}
	}

	T remove() {
		T item = front();
		popFront();
		return item;
	}

	bool remove(T item) {
		throw new Exception("opperation not supported");
	}

	// allows the use of the dollar symbol
	alias length opDollar;

	T opIndex(size_t i) {
		checkRange(i);
		return data[getIndex(i)];
	}

	void opIndexAssign(T value, size_t i) {
		checkRange(i);
		data[getIndex(i)] = value;
	}

	void addAll(T[] items ...) {
		foreach (item; items) {
			append(item);
		}
	}

	void add(T item) {
		head++;
		head %= data.length;
		data[head] = item;
		if (len < data.length) {
			len++;
		}
	}

	void opOpAssign(string op)(T item) {
		static if (op == "+") {
			add(item);
		}
	}

	int opApply(int delegate(T) d) {
		int result = 0;
		for (int i=0; i < len; ++i) {
			result = d(data[getIndex(i)]);
			if (result) return result;
		}
		return result;
	}

	public string toString() {
		auto str = "[";
		foreach (i; 0 .. len-1) {
			str ~= to!string(data[getIndex(i)]);
			str ~= ",";
		}
		str ~= to!string(data[getIndex(len-1)]);
		str ~= "]";
		return str;
	}

	unittest
	{
		auto b = RingBuffer!int(4);
		b.append(1,2);
		assert(b[0] == 2);
		b.append(3,4,5,6);
		assert(b[0] == 6);
		assert(b[b.length-1] == 3);
		assert(b[$-1] == 3);
	}
}


