
module collected.heap;

import std.string;

abstract class AbstractHeap(T) : AbstractCollection!T
{
	T front();
	alias pop front;
	alias dequeue front;
}

class Heap(T, alias less = "a < b") : AbstractHeap!T
{
	private {
		T[] data;
		const INITIAL_SIZE = 8;
	}

	this() {
		data = new T[INITIAL_SIZE];
	}

	override void add(T item) {
		data[len++] = item;
		if (size > 1) {
			bubbleUp();
		}

		// maybe grow the array:
		if (size == data.length) {
			data.length *= cast(uint)(data.length*GROWTH_FACTOR);
		}
	}
	alias add push;
	alias add enqueue;

	public T pop() {
		auto retval = data[0];
		size--;
		data[0] = data[size];

		if (size > 1) {
			bubbleDown();
			// maybe shrink the array:
			if (size/(cast(double)data.length) < (1.0/GROWTH_FACTOR)) {
				data = data[0..size];
			}
		}
		return retval;
	}

	private void bubbleUp() {
		auto index = size-1;
		auto parent = parentIndex(index);
		while (true) {
			auto a = data[parent];
			auto b = data[index];
			if (mixin(less)) {
				swap(parent, index);
				index = parent;
				parent = parentIndex(index);
				if (index == 0) { break; }
			} else {
				break;
			}
		}
	}

	// TODO: resume here
	private void bubbleDown() {
		auto index = 0u;
		auto left = leftChild(index);
		auto right = left + 1;
		auto child = left;
		if (hasRightChild(index)) {
			child = (compare(data[left],data[right], isMax) > 0)? left : right;
		}

		while (compare(data[index], data[child], isMax) < 0 ) {
			swap(index, child);
			index = child;

			if (isLeaf(index)) {
				break;
			}

			left = leftChild(index);
			right = left + 1;
			child = left;
			if (hasRightChild(index)) {
				child = (compare(data[left],data[right], isMax) > 0)? left : right;
			}
			debug writefln("left=%d, right=%d, size=%d", left, right, size);
		}
	}

	private auto leftChild(size_t parent) {
		return (2 * parent) + 1;
	}

	private bool hasRightChild(size_t index) {
		return (size > rightChild(index));
	}

	private auto rightChild(size_t parent) {
		return leftChild(parent) + 1;
	}

	private auto parentIndex(size_t child) {
		if (child & 1) {
			return (child - 1)/2;
		} else {
			return (child - 2)/2;
		}
	}

	private bool isLeaf(size_t index) {
		return (size >= leftChild(index));
	}

	private void swap(size_t a, size_t b) {
		auto temp = data[a];
		data[a] = data[b];
		data[b] = temp;
	}

	public string toString() {
		return format(data[0..size]);
	}
}

template HeapT(T) {

	class Heap
	{
		private bool isMax = true;
		const auto INITIAL_SIZE = 8;
		const double GROWTH_FACTOR = 1.7;

		private T[] data;
		private size_t size;
		//private int delegate(T a, T b) compareD;
		private int function(T, T, bool) compare;

		this(bool isMaxHeap=true) {
			this(&defaultCompare, isMaxHeap);
		}

		this( int function(T a, T b, bool) func, bool isMaxHeap=true) {
			this.data = new T[8];
			this.compare = func;
			this.isMax = isMaxHeap;
		}

		private void bubbleDown() {
			auto index = 0u;
			auto left = leftChild(index);
			auto right = left + 1;
			auto child = left;
			if (hasRightChild(index)) {
				child = (compare(data[left],data[right], isMax) > 0)? left : right;
			}

			while (compare(data[index], data[child], isMax) < 0 ) {
				swap(index, child);
				index = child;

				if (isLeaf(index)) {
					break;
				}

				left = leftChild(index);
				right = left + 1;
				child = left;
				if (hasRightChild(index)) {
					child = (compare(data[left],data[right], isMax) > 0)? left : right;
				}
				debug writefln("left=%d, right=%d, size=%d", left, right, size);
			}
		}

	} // end of Heap

	int defaultCompare(T a, T b, bool isMax) {
		int retval = 0;
		if (a > b) {
			retval = -1;
		}
		else if (b > a) {
			retval = 1;
		}
		retval = (isMax)? retval : retval * -1;
		return retval;
	}

} // end Template


